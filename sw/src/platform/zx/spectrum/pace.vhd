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

	alias clk_28M						: std_logic is clk(0);
	
	signal reset_n					: std_logic;
	signal address					: std_logic_vector(16 downto 0);
	signal data							: std_logic_vector(7 downto 0);
	signal oe_n							: std_logic;
	signal we_n							: std_logic;
	signal ram_cs_n					: std_logic;
	signal rom_cs_n					: std_logic;
	signal rom_data					: std_logic_vector(7 downto 0);
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
	sram_o.be <= EXT("1", sram_o.be'length);
	sram_o.a(address'range) <= address;
	sram_o.d <= EXT(data, sram_o.d'length) when (ram_cs_n = '0' and we_n = '0') else (others => 'Z');
	data <= rom_data when (rom_cs_n = '0' and oe_n = '0') else
					sram_i.d(data'range) when (ram_cs_n = '0' and oe_n = '0') else 
					(others => 'Z');

	vga_clk <= clk(1);	-- fudge

	spectrum_inst : entity work.spectrum48
		port map
		(
			Rst_n			=> reset_n,
			Clk				=> clk_28M,
			PS2_Clk		=> ps2clk,
			PS2_Data	=> ps2data,
			Tape_In		=> '0',
			Tape_Out	=> open,
			Sound			=> open,
			CVBS			=> open,
			CSync			=> csync,
			R					=> red(9 downto 8),
			G					=> green(9 downto 8),
			B					=> blue(9 downto 8),
			OE_n			=> oe_n,
			WE_n			=> we_n,
			RAMCS_n		=> ram_cs_n,
			ROMCS_n		=> rom_cs_n,
			PGM_n			=> open,
			A					=> address,
			D					=> data
		);

	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/zx/spectrum/roms/spec_rom.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock				=> clk_28M,
			address			=> address(13 downto 0),
			q						=> rom_data
		);
		
	vsync <= '1';
	hsync <= csync;
		
  spi_clk <= spi_clk_s when (spi_ena = '1') else 'Z';
  spi_dout <= spi_dout_s when (spi_ena = '1') else 'Z';
  spi_mode <= spi_mode_s when (spi_ena = '1') else 'Z';
  spi_sel <= spi_sel_s when (spi_ena = '1') else 'Z';
  
	leds <= leds_s;

	-- used video colour resolution
	red(7 downto 0) <= (others => '0');
	green(7 downto 0) <= (others => '0');
	blue(7 downto 0) <= (others => '0');
	
	-- unused SRAM signals
	sram_o.a(23 downto address'left+1) <= (others => '0');
	
end SYN;

