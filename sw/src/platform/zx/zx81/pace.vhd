Library IEEE;
Use     IEEE.std_logic_1164.all;

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
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

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

	alias clk_13M						: std_logic is clk(0);
	signal clk_6M5_en				: std_logic;
	
	signal reset_n					: std_logic;
	signal video						: std_logic;	
	signal csync						: std_logic;
		
  -- spi signals
  signal spi_clk_s        : std_logic;
  signal spi_dout_s       : std_logic;
  signal spi_ena          : std_logic;
  signal spi_mode_s       : std_logic;
  signal spi_sel_s        : std_logic;

	signal leds_s						: std_logic_vector(7 downto 0);
	
begin

	reset_n <= not reset;

	vga_clk <= clk(1);	-- fudge

	clk_6M5_gen : entity work.clk_div
		generic map
		(
			DIVISOR   => 2
		)
	  port map
	  (
	    clk       => clk_13M,
	    reset     => reset,

			clk_en    => clk_6M5_en
	  );

	zx01_inst : entity work.zx01
	  port map
		(
			n_reset			=> reset_n,
	    clock				=> clk_6M5_en,
	    kbd_clk			=> ps2clk,
	    kbd_data		=> ps2data,
	    v_inv				=> '0',
	    usa_uk			=> '1',
	    video				=> video,
	    tape_in			=> '0',
	    tape_out		=> csync,
	    d_lcd				=> open,
	    s						=> open,
	    cp1					=> open,
	    cp2					=> open
		);

	red(9) <= video;
	green(9) <= video;
	blue(9) <= video;
	vsync <= '1';
	hsync <= csync;
		
  spi_clk <= spi_clk_s when (spi_ena = '1') else 'Z';
  spi_dout <= spi_dout_s when (spi_ena = '1') else 'Z';
  spi_mode <= spi_mode_s when (spi_ena = '1') else 'Z';
  spi_sel <= spi_sel_s when (spi_ena = '1') else 'Z';
  
	leds <= leds_s;

	-- used video colour resolution
	red(8 downto 0) <= (others => '0');
	green(8 downto 0) <= (others => '0');
	blue(8 downto 0) <= (others => '0');
	
	-- unused SRAM signals
	sram_o.a <= (others => '0');
	sram_o.d <= (others => '0');
	sram_o.be <= (others => '0');
	sram_o.cs <= '0';
	sram_o.oe <= '0';
	sram_o.we <= '0';
	
end SYN;

