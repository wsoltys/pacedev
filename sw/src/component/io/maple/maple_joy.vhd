library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.maple_pkg.all;

entity maple_joy is
	generic (
		MHZ				: natural := 48
	);
  port
  (
  	clk      	: in std_logic;                         --	48 MHz
		reset			: in std_logic;
		sense			: in std_logic;
		oe				: out std_logic;
		a					: inout std_logic;
		b					: inout std_logic;
		joystate	: out joystate_type
	);
end maple_joy;

architecture SYN of maple_joy is

	constant NPKTS : integer := 2;

	constant maple_pkt : maple_pkt_type(0 to 2) := (
		X"01200000",								-- Request device information
		X"09200001", X"00000001"		-- Get condition
	);

	subtype maple_pkt_addr is integer range maple_pkt'low to maple_pkt'high+1;
	subtype maple_pkt_num is integer range 0 to NPKTS;
	type maple_idx_type is array (0 to NPKTS-1) of maple_pkt_addr;
	
	constant maple_pkt_start	: maple_idx_type	:= ( 0, 1 );
	constant maple_pkt_end		: maple_idx_type	:= ( 0, 2 );

	signal poll						: std_logic;

	signal wr_npkt				: maple_pkt_num;
	signal wr_pkt_start		: integer;
	signal wr_pkt_end			: integer;

	signal wr_addr				: maple_pkt_addr;
	signal wr_docsum			: std_logic;
	signal wr_done				: std_logic;
	
	signal wr_req					: std_logic;
	signal wr_d_in				: maple_byte;
	signal wr_csum				: maple_byte;
	signal wr_word				: maple_word;
	signal wr_bsel				: std_logic_vector(1 downto 0);

	signal rd_d_out				: maple_byte;				-- Incoming byte
	signal rd_avail				: std_logic;				-- Incoming byte available
	signal rd_csum				: maple_byte;				-- Accumulated read checksum
	signal rd_busy				: std_logic;				-- Currently reading maple packet
	signal rd_word				: maple_word;				-- Incoming maple 32-bit word
	signal rd_sample			: std_logic;				-- Word available to read
	signal rd_bsel				: std_logic_vector(1 downto 0);	-- Which byte we are reading of the word
	signal rd_csum_match	: std_logic;				-- True for one clock after read if checksum matches
	signal rd_pkt					: maple_pkt_type(0 to 2);		-- Incoming read joystick state

	signal rd_cnt					: integer range 0 to 15;		-- Read word count

begin

	mbus : work.maple_bus 
		generic map ( MHZ	=> MHZ )
	  port map (
	  	clk			=> clk,
			reset		=> reset,
			
			-- Maple bus signals
			sense		=> sense,
			oe			=> oe,
			a				=> a,
			b				=> b,
			
			-- Control interface
			d_in		=> wr_d_in,
			wrreq		=> wr_req,
			
			d_out		=> rd_d_out,
			rdavail	=> rd_avail,
			rdbusy	=> rd_busy
		);

	-- Manage periodic polling
	process(clk, reset)
		variable cnt		: integer;
	begin
		if reset = '1' then
			cnt := 0;
			poll <= '0';
			
		elsif rising_edge(clk) then
			poll <= '0';
			if sense = '1' then
				if cnt < MHZ*100000 then	-- 100Hz poll frequency
					cnt := cnt + 1;
				else
					poll <= '1';
					cnt := 0;
				end if;
			else
				cnt := 0;
			end if;
		end if;
	end process;

	-- Load current packet data into write fifo
	wr_req <= not wr_done;
	process(clk, poll, wr_done)
	begin
		if reset = '1' then
			wr_addr <= 0;
			wr_done <= '0';
			wr_bsel <= "00";
			wr_csum <= (others => '0');
			
		elsif rising_edge(clk) then
			if poll = '1' then
				wr_addr <= wr_pkt_start;
				wr_done <= '0';
				wr_bsel <= "00";
				wr_csum <= (others => '0');
			elsif wr_done = '0' then
				wr_csum <= wr_csum xor wr_d_in;
				if wr_addr <= wr_pkt_end then
					if wr_bsel = "11" then
						wr_addr <= wr_addr + 1;
					end if;
				else
					wr_done <= '1';
				end if;
				if wr_bsel < "11" then
					wr_bsel <= wr_bsel + "01";
				else
					wr_bsel <= "00";
				end if;
			end if;

			wr_pkt_start <= maple_pkt_start(wr_npkt);
			wr_pkt_end <= maple_pkt_end(wr_npkt);
		end if;
	end process;
	
	-- Lookup write packet ram
	process(wr_addr, wr_csum)
	begin
		if wr_addr >= maple_pkt'low and wr_addr <= wr_pkt_end then
			wr_word <= maple_pkt(wr_addr);
		else
			wr_word <= X"000000" & wr_csum;
		end if;
	end process;
	
	-- Mux write bytes from wr_word
	process(wr_bsel, wr_word)
	begin
		case wr_bsel is
		when "00" =>		wr_d_in <= wr_word(7 downto 0);
		when "01" =>		wr_d_in <= wr_word(15 downto 8);
		when "10" =>		wr_d_in <= wr_word(23 downto 16);
		when others =>	wr_d_in <= wr_word(31 downto 24);
		end case;
	end process;
	
	-- Convert read bytes into words
	process(clk, reset)
		variable rd_avail_0		: std_logic;
		variable rd_busy_0		: std_logic;
		variable sense_0			: std_logic;
	begin
		if reset = '1' then
			wr_npkt <= 0;
			rd_cnt <= 0;
			rd_avail_0 := '0';
			rd_busy_0 := '0';
			rd_bsel <= "00";
			rd_word <= (others => '0');
			rd_csum <= (others => '0');
			
		elsif rising_edge(clk) then
			-- Handle write packet selection
			if sense = '1' and sense_0 = '0' then
				wr_npkt <= 0;
			elsif rd_csum_match = '1' and wr_npkt < NPKTS-1 then
				wr_npkt <= wr_npkt + 1;
			end if;
		
			if rd_busy = '0' and rd_busy_0 = '0' then
				rd_cnt <= 0;
				rd_avail_0 := '0';
				rd_busy_0 := '0';
				rd_bsel <= "00";
				rd_word <= (others => '0');
				rd_csum <= (others => '0');
			else
				-- Accumulate and sample word every four bytes
				rd_sample <= '0';
				if rd_avail = '1' and rd_avail_0 = '0' then
					rd_csum <= rd_csum xor rd_d_out;
					rd_word <= rd_d_out & rd_word(31 downto 8);
					if rd_bsel = "11" then
						rd_sample <= '1';
						rd_bsel <= "00";
					else
						rd_bsel <= rd_bsel + "01";
					end if;
				end if;

				-- Handle word counter			
				-- Rising edge of rd_busy
				if rd_busy = '1' and rd_busy_0 = '0' then
					rd_cnt <= 0;
				elsif rd_sample = '1' then
					rd_cnt <= rd_cnt + 1;
				end if;

			end if;

			-- Check checksum at end of packet
			-- Falling edge of rd_busy
			rd_csum_match <= '0';
			if rd_busy = '0' and rd_busy_0 = '1' then
				if rd_csum = X"00" then
					rd_csum_match <= '1';
				end if;
			end if;
						
			rd_avail_0 := rd_avail;
			rd_busy_0 := rd_busy;
			sense_0 := sense;
		end if;
	end process;

	-- Save read joystate
	process(clk, reset)
	begin
		if reset = '1' then
			rd_pkt <= (others => (others => '0'));
			joystate <= (jx => X"00", jy => X"00", lv => X"00", rv => X"00", others => '0');
			
		elsif rising_edge(clk) then
			if rd_sample = '1' then
				case rd_cnt is
				when 1 =>		rd_pkt(0) <= rd_word;
				when 2 =>		rd_pkt(1) <= rd_word;
				when 3 =>		rd_pkt(2) <= rd_word;
				when others =>
				end case;
			end if;
			
			-- If the checksum matched, copy joystate to output
			if rd_csum_match = '1' then
				joystate.start		<= rd_pkt(1)(27);
				joystate.a				<= rd_pkt(1)(26);
				joystate.b				<= rd_pkt(1)(25);
				joystate.x				<= rd_pkt(1)(18);
				joystate.y				<= rd_pkt(1)(17);
				joystate.d_up			<= rd_pkt(1)(28);
				joystate.d_down		<= rd_pkt(1)(29);
				joystate.d_left		<= rd_pkt(1)(30);
				joystate.d_right	<= rd_pkt(1)(31);
				joystate.jx				<= rd_pkt(2)(31 downto 24); 
				joystate.jy				<= rd_pkt(2)(23 downto 16);
				joystate.lv				<= rd_pkt(1)(7 downto 0);
				joystate.rv				<= rd_pkt(1)(15 downto 8);
			end if;
		end if;
	end process;
	
end SYN;
