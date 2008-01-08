library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk             : in std_logic_vector(0 to 3);
    test_button     : in std_logic;
    reset           : in std_logic;

    -- game I/O
    ps2clk          : inout std_logic;
    ps2data         : inout std_logic;
    dip             : in std_logic_vector(7 downto 0);
		jamma						: in JAMMAInputsType;

    -- external RAM
    sram_addr       : out std_logic_vector(23 downto 0);
    sram_dq_i     	: in std_logic_vector(31 downto 0);
    sram_dq_o     	: out std_logic_vector(31 downto 0);
    sram_cs_n       : out std_logic;
    sram_oe_n       : out std_logic;
    sram_we_n       : out std_logic;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
    hsync           : out std_logic;
    vsync           : out std_logic;

    -- composite video
    BW_CVBS         : out std_logic_vector(1 downto 0);
    GS_CVBS         : out std_logic_vector(7 downto 0);

    -- sound
    snd_clk         : out std_logic;
    snd_data_l      : out std_logic_vector(15 downto 0);
    snd_data_r      : out std_logic_vector(15 downto 0);

    -- SPI (flash)
    spi_clk         : out std_logic;
    spi_mode        : out std_logic;
    spi_sel         : out std_logic;
    spi_din         : in std_logic;
    spi_dout        : out std_logic;

    -- serial
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;

		-- SB (IEC) port
		ext_sb_data_in	: in std_logic;
		ext_sb_data_oe	: out std_logic;
		ext_sb_clk_in		: in std_logic;
		ext_sb_clk_oe		: out std_logic;
		ext_sb_atn_in		: in std_logic;
		ext_sb_atn_oe		: out std_logic;

		-- generic drive mechanism i/o ports
		mech_in					: in std_logic_vector(63 downto 0);
		mech_out				: out std_logic_vector(63 downto 0);
		mech_io					: inout std_logic_vector(63 downto 0);

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

  component c1541_top is
    generic
    (
      DEVICE_SELECT		: std_logic_vector(1 downto 0)
    );
    port
    (
      clk_32M					: in std_logic;
      reset						: in std_logic;

      -- serial bus
      sb_data_oe			: out std_logic;
      sb_data_in			: in std_logic;
      sb_clk_oe				: out std_logic;
      sb_clk_in				: in std_logic;
      sb_atn_oe				: out std_logic;
      sb_atn_in				: in std_logic;
      
      -- drive-side interface
      ds							: in std_logic_vector(1 downto 0);		-- device select
      act							: out std_logic;											-- activity LED

      -- generic drive mechanism i/o ports
      mech_in					: in std_logic_vector(63 downto 0);
      mech_out				: out std_logic_vector(63 downto 0);
      mech_io					: inout std_logic_vector(63 downto 0)
    );
  end component c1541_top;

	alias clk_32M								: std_logic is clk(0);
		
	signal sram_addr_s					: unsigned(16 downto 0);
	signal r_s									: unsigned(7 downto 0);
	signal g_s									: unsigned(7 downto 0);
	signal b_s									: unsigned(7 downto 0);
	signal leds_s								: unsigned(leds'range);
	signal snd_data_s						: std_logic_vector(17 downto 0);

	signal c64_sb_data_oe				: std_logic;
	signal c64_sb_clk_oe				: std_logic;
	signal c64_sb_atn_oe				: std_logic;
	signal c64_ramdata_o				: unsigned(7 downto 0);

	signal c1541_sb_data_oe			: std_logic;
	signal c1541_sb_clk_oe			: std_logic;
	signal c1541_sb_atn_oe			: std_logic;

	-- internal serial bus
	signal int_sb_data					: std_logic;
	signal int_sb_clk						: std_logic;
	signal int_sb_atn						: std_logic;

	signal c1541_activity_led		: std_logic;

	signal joyA_s								: unsigned(5 downto 0);
	
begin

	sram_addr <= "0000000" & std_logic_vector(sram_addr_s);
	sram_dq_o(c64_ramdata_o'range) <= std_logic_vector(c64_ramdata_o);

	vga_clk <= clk_32M; -- for DE2
	red <= std_logic_vector(r_s) & "00";
	green <= std_logic_vector(g_s) & "00";
	blue <= std_logic_vector(b_s) & "00";
	
	leds <= std_logic_vector(leds_s(7 downto 1)) & c1541_activity_led;

	-- generate DAC clock
	process (clk_32M, reset)
		-- 32MHz/8 = 4MHz
		variable count : std_logic_vector(2 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk_32M) then
			count := count + 1;
		end if;
		snd_clk <= count(count'left);
	end process;
	
	snd_data_l <= snd_data_s(snd_data_s'left downto snd_data_s'left+1-snd_data_l'length);
	snd_data_r <= snd_data_s(snd_data_s'left downto snd_data_s'left+1-snd_data_r'length);

	GEN_C64 : if C64_HAS_C64 generate
		
		-- active high
		joyA_s(5) <= '0';
		joyA_s(4) <= not jamma.p(1).button(1);
		joyA_s(3) <= not jamma.p(1).right;
		joyA_s(2) <= not jamma.p(1).left;
		joyA_s(1) <= not jamma.p(1).down;
		joyA_s(0) <= not jamma.p(1).up;
		
		fpga64_pace_inst : entity work.fpga64_pace
			generic map
			(
				resetCycles => C64_RESET_CYCLES
			)
			port map
			(
				clk50					=> '0',		-- not used
				clk32					=> clk_32M,
				reset_button	=> reset,

				-- keyboard interface (use any ordinairy PS2 keyboard)
				kbd_clk				=> ps2clk,
				kbd_dat				=> ps2data,

				video_select	=> '0',

				-- external memory, since the 64K RAM is relatively big to implement in a FPGA
				ramAddr				=> sram_addr_s,
				ramData_i			=> unsigned(sram_dq_i(work.fpga64_pace.ramData_i'range)),
				ramData_o			=> c64_ramdata_o,
				ramData_oe		=> open,
				
				ramCE					=> sram_cs_n,
				ramWe					=> sram_we_n,
				ramOe					=> sram_oe_n,
				
				hsync					=> hsync,
				vsync					=> vsync,
				r 						=> r_s,
				g 						=> g_s,
				b 						=> b_s,

				-- joystick interface
				joyA					=> joyA_s,
				joyB					=> (others => '0'),

				-- serial port, for connection to pheripherals
	    	serioclk		  => open,
	    	ces		        => open,

				leds					=> leds_s,
				
				-- video-out connect the FPGA to your PAL-monitor, using the CVBS-input
				cvbsOutput		=> open,
				
				-- (internal) SID connections
				sid_pot_x				=> open,
				sid_pot_y				=> open,
				sid_audio_out		=> open,
				sid_audio_data	=> snd_data_s,
			
				-- IEC
				sb_data_oe			=> c64_sb_data_oe,
				sb_data_in			=> int_sb_data,
				sb_clk_oe				=> c64_sb_clk_oe,
				sb_clk_in				=> int_sb_clk,
				sb_atn_oe				=> c64_sb_atn_oe,
				sb_atn_in				=> int_sb_atn,
					
				--Connector to the SID
				SIDclk					=> open,
				still						=> open
			);

	end generate GEN_C64;

	GEN_NO_C64 : if not C64_HAS_C64 generate
	
		c64_sb_data_oe <= '0';
		c64_sb_clk_oe <= '0';
		c64_sb_atn_oe <= '0';
		
	end generate GEN_NO_C64;
	
	GEN_1541 : if C64_HAS_1541 generate

		c1541_inst : c1541_top
			generic map
			(
				DEVICE_SELECT		=> C64_1541_DEVICE_SELECT(1 downto 0)
			)
			port map
			(
				clk_32M					=> clk_32M,
				reset						=> reset,

				-- serial bus
				sb_data_oe			=> c1541_sb_data_oe,
				sb_data_in			=> int_sb_data,
				sb_clk_oe				=> c1541_sb_clk_oe,
				sb_clk_in				=> int_sb_clk,
				sb_atn_oe				=> c1541_sb_atn_oe,
				sb_atn_in				=> int_sb_atn,

				-- drive-side interface				
				ds							=> dip(1 downto 0),
				act							=> c1541_activity_led,

				-- generic drive mechanism i/o ports
				mech_in					=> mech_in,
				mech_out				=> mech_out,
				mech_io					=> mech_io
			);

	end generate GEN_1541;

	GEN_NO_1541 : if not C64_HAS_1541 generate

		c1541_sb_data_oe <= '0';
		c1541_sb_clk_oe <= '0';
		c1541_sb_atn_oe <= '0';
		
		c1541_activity_led <= '0';
		
	end generate GEN_NO_1541;

	-- wire up the internal, external SB bus
	
	GEN_EXT_SB : if C64_HAS_EXT_SB generate

		BLK_EXT_SB : block
		
			constant UNMETA_STAGES : natural := 2;
			
			signal um_sb_data_in 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			signal um_sb_clk_in 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			signal um_sb_atn_in 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			
		begin
	
			process (clk_32M, reset)
			begin
				if reset = '1' then
					um_sb_data_in <= (others => '1');
					um_sb_clk_in <= (others => '1');
					um_sb_atn_in <= (others => '1');
				elsif rising_edge(clk_32M) then
					um_sb_data_in <= um_sb_data_in(um_sb_data_in'left-1 downto 0) & ext_sb_data_in;
					um_sb_clk_in <= um_sb_clk_in(um_sb_clk_in'left-1 downto 0) & ext_sb_clk_in;
					um_sb_atn_in <= um_sb_atn_in(um_sb_atn_in'left-1 downto 0) & ext_sb_atn_in;
				end if;
			end process;
					
			int_sb_data <= 	'0' when (c64_sb_data_oe = '1' or c1541_sb_data_oe = '1') else
											um_sb_data_in(um_sb_data_in'left);
			int_sb_clk <= 	'0' when (c64_sb_clk_oe = '1' or c1541_sb_clk_oe = '1') else
											um_sb_clk_in(um_sb_clk_in'left);
			int_sb_atn <= 	'0' when (c64_sb_atn_oe = '1' or c1541_sb_atn_oe = '1') else
											um_sb_atn_in(um_sb_atn_in'left);

		end block BLK_EXT_SB;
	
	end generate GEN_EXT_SB;
			
	GEN_NO_EXT_SB : if not C64_HAS_EXT_SB generate
	
		int_sb_data <=	not (c64_sb_data_oe or c1541_sb_data_oe);
		int_sb_clk <= 	not (c64_sb_clk_oe or c1541_sb_clk_oe);
		int_sb_atn <= 	not (c64_sb_atn_oe or c1541_sb_atn_oe);

	end generate GEN_NO_EXT_SB;

	-- doesn't matter if no external bus is connected
	ext_sb_data_oe <= c64_sb_data_oe or c1541_sb_data_oe;
	ext_sb_clk_oe <= c64_sb_clk_oe or c1541_sb_clk_oe;
	ext_sb_atn_oe <= c64_sb_atn_oe or c1541_sb_atn_oe;

	-- unused
	lcm_data <= (others => '0');
	bw_cvbs <= (others => '0');
	gs_cvbs <= (others => '0');
	spi_clk <= '0';
	spi_mode <= '0';
	spi_sel <= '0';
	spi_dout <= '0';
	ser_tx <= '0';

end SYN;

