Library IEEE;
Use IEEE.std_logic_1164.all;
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
	signal address					: std_logic_vector(16 downto 0);
	signal data							: std_logic_vector(7 downto 0);
	signal oe_n							: std_logic;
	signal we_n							: std_logic;
	signal ram_cs_n					: std_logic;
	
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

	-- external memory logic
	sram_o.cs <= not ram_cs_n;
	sram_o.oe <= not oe_n;
	sram_o.we <= not we_n;
	sram_o.a(address'range) <= address;
	sram_o.d <= EXT(data, sram_o.d'length) when (ram_cs_n = '0' and we_n = '0') else (others => 'Z');
	data <= sram_i.d(data'range) when (ram_cs_n = '0' and oe_n = '0') else 
					(others => 'Z');

	vga_clk <= clk(1);	-- fudge

	-- assign video signals
	red <= (others => video);
	green <= (others => video);
	blue <= (others => video);
	vsync <= '1';
	hsync <= csync;
		
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

	ace_inst : entity work.ace
		port map
		(
			Rst_n			=> reset_n,
			Clk				=> clk_6M5_en,
			PS2_Clk		=> ps2clk,
			PS2_Data	=> ps2data,
			Tape_In		=> '0',
			Tape_Out	=> open,
			Sound			=> open,
			CVBS			=> open,
			Video			=> video,
			Sync			=> csync,
			OE_n			=> oe_n,
			WE_n			=> we_n,
			RAMCS_n		=> ram_cs_n,
			ROMCS_n		=> open,
			PGM_n			=> open,
			A					=> address,
			D					=> data
		);

  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';
  
	leds <= leds_s;

	-- unused SRAM signals
	sram_o.a(23 downto address'left+1) <= (others => '0');
	
end SYN;

