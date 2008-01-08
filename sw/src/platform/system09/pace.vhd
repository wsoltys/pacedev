library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

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
    sram_i          : in from_SRAM_t;
    sram_o          : out to_SRAM_t;

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

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

	alias clk_50M						: std_logic is clk(0);
	
	signal reset_n					: std_logic;

  signal ram_data         : std_logic_vector(7 downto 0);
	signal ram_csn					: std_logic;	
	signal ram_wrln					: std_logic;

begin

	reset_n <= not reset;

	-- SRAM interface	
	sram_o.be <= EXT("1", sram_o.be'length);
	sram_o.cs <= not ram_csn;
	sram_o.oe <= ram_wrln;
	sram_o.we <= not ram_wrln;
  sram_o.d <= EXT(ram_data, sram_o.d'length) when ram_wrln = '0' else (others => 'Z');

	-- map inputs
	
	vga_clk <= clk(1);	-- fudge

  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';

	system09_inst : entity work.My_System09
	  port map
		(
    	SysClk      => clk_50M,
	 		Reset_n     => reset_n,
    	LED         => open,

	    -- Memory Interface signals
	    ram_csn     => ram_csn,
	    ram_wrln    => ram_wrln,
	    ram_wrun    => open,
	    ram_addr    => sram_o.a(16 downto 0),
			ram_data_i(15 downto 8)	=> (others => '0'),
	    ram_data_i(7 downto 0)	=> sram_i.d(7 downto 0),
      ram_data_o(15 downto 8) => open,
      ram_data_o(7 downto 0) => ram_data,

			-- Stuff on the peripheral board

	 	 	-- PS/2 Keyboard
		 	kb_clock    => ps2clk,
		 	kb_data     => ps2data,

	 		-- PS/2 Mouse interface
--	 mouse_clock : in  Std_Logic;
--	 mouse_data  : in  Std_Logic;

	 		-- Uart Interface
    	rxbit       => ser_rx,
	 		txbit       => ser_tx,
    	rts_n       => open,
    	cts_n       => '0',

	 		-- CRTC output signals
	 		v_drive     => vsync,
    	h_drive     => hsync,
    	blue_lo     => blue(8),
    	blue_hi     => blue(9),
    	green_lo    => green(8),
    	green_hi    => green(9),
    	red_lo      => red(8),
    	red_hi      => red(9),
--	   buzzer      : out std_logic;

			-- Compact Flash
    	cf_rst_n     => open,
	 		cf_cs0_n     => open,
	 		cf_cs1_n     => open,
    	cf_rd_n      => open,
    	cf_wr_n      => open,
	 		cf_cs16_n    => open,
    	cf_a         => open,
    	cf_d         => open,

			-- Parallel I/O port
    	porta        => open,
    	portb        => open,

			-- CPU bus
	 		bus_clk      => open,
	 		bus_reset    => open,
	 		bus_rw       => open,
	 		bus_cs       => open,
    	bus_addr     => open,
	 		bus_data     => open,

			-- timer
    	timer_out    => open
	 );
  
	-- unused video colour resolution
	red(7 downto 0) <= (others => '0');
	green(7 downto 0) <= (others => '0');
	blue(7 downto 0) <= (others => '0');
	
	-- unused SRAM signals
	sram_o.a(23 downto 17) <= (others => '0');
	
end SYN;
