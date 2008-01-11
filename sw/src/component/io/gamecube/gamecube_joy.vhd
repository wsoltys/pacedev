library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.gamecube_pkg.all;

entity gamecube_joy is
	generic (
		MHZ				: natural := 50
	);
  port (
  	clk      	: in std_logic;
		reset			: in std_logic;
		oe				: out std_logic;
		d					: inout std_logic;
		joystate	: out joystate_type
	);
end gamecube_joy;

architecture SYN of gamecube_joy is
	use work.conversion.to_vector;

	-- this should be calculated from MHZ
	constant POLL_1ms_COUNTER_WIDTH		: natural := 20;
	--constant POLL_1ms_COUNTER_WIDTH		: natural := 13;
	
	signal gc_byte_strobe		: std_logic;
	signal gc_d_i						: std_logic;
	signal gc_d_o						: std_logic;
	signal gc_oe						: std_logic;

	signal gc_tx_avail	: std_logic;
	signal gc_tx_din		: std_logic;
	signal gc_tx_dnext	: std_logic;
	signal gc_tx_pkt		: std_logic;
begin
	gc_d_i <= d or gc_oe;
	d <= 'Z' when gc_oe = '0' else gc_d_o;

	-- Handle gamecube data decode
	gcube_input: process (reset, clk)
		constant ones_10			: std_logic_vector(9 downto 0) := (others => '1');
		variable hi_cnt 			: std_logic_vector(9 downto 0);
		variable lo_cnt				: std_logic_vector(9 downto 0);
		variable d_um					: std_logic_vector(2 downto 0);
		variable d_0					: std_logic;
		variable bit					: std_logic;
		variable bit_0				: std_logic;
		variable q						: std_logic;
		variable byte					: std_logic_vector(7 downto 0);
		variable bit_cnt			: std_logic_vector(2 downto 0);
		variable gc_pkt				: packet_type;
		variable joy_detected	: boolean := false;
	begin
		if reset = '1' then
			gc_pkt := (others => (others => '0'));
			d_um := (others => '1');
			hi_cnt := (others => '0');
			lo_cnt := (others => '0');
			d_0 := '0';
			bit := '0';
			bit_0 := '0';
			q := '0';
			byte := (others => '0');
			bit_cnt := (others => '0');
			
			-- initialse analogue controls to 'unattended' values
			-- for the case where there's no controller connected
			joy_detected := false;
			joystate <= (jx => X"80", jy => X"80", lv => X"00", rv => X"00", 
									 cx => X"00", cy => X"00", others => '0');

		elsif rising_edge(clk) then
			gc_byte_strobe <= '0';
			
			if bit = '0' and bit_0 = '1' then
				hi_cnt := (others => '0');
				lo_cnt := (others => '0');
			else
				-- Count data high clocks
				if d_um(2) = '1' then
					if hi_cnt /= ones_10 then
						hi_cnt := hi_cnt + 1;
					end if;
				else
					if lo_cnt /= ones_10 then
						lo_cnt := lo_cnt + 1;
					end if;
					-- at least 1 low pulse means a controller is attached
					joy_detected := true;
				end if;
			end if;
				
			-- Clock data in
			if lo_cnt > hi_cnt then
				q := '0';
			else
				q := '1';
			end if;
			if joy_detected and hi_cnt = ones_10 then
				-- Copy joy state to output
				joystate.start 		<= gc_pkt(7)(4);
				joystate.y 				<= gc_pkt(7)(3);
				joystate.x 				<= gc_pkt(7)(2);
				joystate.b 				<= gc_pkt(7)(1);
				joystate.a 				<= gc_pkt(7)(0);
				joystate.l 				<= gc_pkt(6)(6);
				joystate.r 				<= gc_pkt(6)(5);
				joystate.z 				<= gc_pkt(6)(4);
				joystate.d_up 		<= gc_pkt(6)(3);
				joystate.d_down 	<= gc_pkt(6)(2);
				joystate.d_right	<= gc_pkt(6)(1);
				joystate.d_left 	<= gc_pkt(6)(0);
				joystate.jx 			<= gc_pkt(5);
				joystate.jy 			<= gc_pkt(4);
				joystate.cx 			<= gc_pkt(3);
				joystate.cy 			<= gc_pkt(2);
				joystate.lv 			<= gc_pkt(1);
				joystate.rv 			<= gc_pkt(0);
				byte := (others => '0');
				bit_cnt := (others => '0');
			elsif bit = '1' then
				byte := byte(6 downto 0) & q;
			end if;

			-- Handle counting bits in byte
			if bit = '1' and hi_cnt /= ones_10 then
				if bit_cnt = "111" then
					gc_byte_strobe <= '1';
					gc_pkt := gc_pkt(6 downto 0) & byte;
				end if;
				bit_cnt := bit_cnt + 1;
			end if;
						
			-- Handle bit input
			bit_0 := bit;
			if d_um(2) = '0' and d_0 = '1' then
				bit := '1';
			else 
				bit := '0';
			end if;
						
			d_0 := d_um(2);

			-- Unmeta input data
			d_um := d_um(1 downto 0) & gc_d_i;
		end if;
	end process;

  gctx: work.gc_tx_bit 
	generic map (MHZ => MHZ)
	port map (
		clk					=> clk, 
		reset				=> reset, 
		data_avail	=> gc_tx_avail,
		din					=> gc_tx_din,
		dnext				=> gc_tx_dnext,
		dout				=> gc_d_o,
		oe					=> gc_oe
	);

	gcube_output: process(reset, clk)
		constant req_msg		: std_logic_vector(24 downto 0) := "0100000000000011000000001";
		variable pkt				: std_logic_vector(req_msg'high downto req_msg'low);
		
		variable bit_cnt		: integer;
		variable next_bit		: std_logic;
	begin
		gc_tx_din <= pkt(pkt'high);
		
		if reset = '1' then
			bit_cnt := 0;	
		elsif rising_edge(clk) then
			-- Handle shifting next bit out
			if bit_cnt > 0 then
				gc_tx_avail <= '1';
				if gc_tx_dnext = '1' then
					bit_cnt := bit_cnt - 1;
					pkt := pkt(pkt'high-1 downto 0) & '0';
				end if;
			else
				gc_tx_avail <= '0';
			end if;
		
			-- Start packet if requested and not busy already
			if gc_tx_pkt = '1' and gc_oe = '0' then
				bit_cnt := pkt'length;
				pkt := req_msg;
			end if;
		end if;
	end process;

--	gcube_poll: process(reset, clock_50)
--		variable key3_0 : std_logic;
--	begin
--		if rising_edge(clock_50) then
--			if key3_0 = '1' and key(3) = '0' then
--				gc_tx_pkt <= '1';
--			else
--				gc_tx_pkt <= '0';
--			end if;
--			key3_0 := key(3);
--		end if;
--	end process;

	-- Send poll packet every 1ms
	--gc_tx_pkt <= '0';
	POLL_CNT: entity work.load_upcounter
		generic map( width => POLL_1ms_COUNTER_WIDTH )
		port map( clk => clk, reset => reset, en => '1', ld => gc_tx_pkt, 
				  data => to_vector(POLL_1ms_COUNTER_WIDTH, -(MHZ*1000000*5/1000)), tc => gc_tx_pkt );
	
end;
