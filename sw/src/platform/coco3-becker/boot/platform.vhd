library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity platform is
  generic
  (
    NUM_INPUT_BYTES   : integer
  );
  port
  (
    -- clocking and reset
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_MAPPED_INPUTS_t(0 to NUM_INPUT_BYTES-1);
		
    -- FLASH/SRAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_FLASH_t;
    sram_i	        : in from_SRAM_t;
    sram_o	        : out to_SRAM_t;
    sdram_i	        : in from_SDRAM_t;
    sdram_o	        : out to_SDRAM_t;

    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_t;
    bitmap_o        : out to_BITMAP_CTL_t;
    
    tilemap_i       : in from_TILEMAP_CTL_t;
    tilemap_o       : out to_TILEMAP_CTL_t;

    sprite_reg_o    : out to_SPRITE_REG_t;
    sprite_i        : in from_SPRITE_CTL_t;
    sprite_o        : out to_SPRITE_CTL_t;
    spr0_hit	      : in std_logic;

    -- various graphics information
    graphics_i      : in from_GRAPHICS_t;
    graphics_o      : out to_GRAPHICS_t;
    
    -- OSD
    osd_i           : in from_OSD_t;
    osd_o           : out to_OSD_t;

    -- sound
    snd_i           : in from_SOUND_t;
    snd_o           : out to_SOUND_t;

    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );
end entity platform;

architecture SYN of platform is

	alias clk_20M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	signal clk_2M_en			: std_logic;
	
  alias eurospi_clk     : std_logic is gp_i(P2A_EUROSPI_CLK);
  alias eurospi_miso    : std_logic is gp_o.d(P2A_EUROSPI_MISO);
  alias eurospi_mosi    : std_logic is gp_i(P2A_EUROSPI_MOSI);
  alias eurospi_ss      : std_logic is gp_i(P2A_EUROSPI_SS);
  
begin

	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/coco3-becker/roms/coco3gen.hex",
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock			  => clk_video,
			address		  => tilemap_i.tile_a(10 downto 0),
			q           => tilemap_o.tile_d
		);
	
  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../src/platform/coco3-becker/boot/roms/vram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			clock_b			=> clk_20M,
			address_b		=> (others => '0'),
			wren_b			=> '0',
			data_b			=> (others => '0'),
			q_b					=> open,
	
		  clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
    tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

  -- interboard spi
  -- - always the slave
  gp_o.oe(P2A_EUROSPI_CLK) <= '0';
  gp_o.oe(P2A_EUROSPI_MISO) <= '1';
  gp_o.oe(P2A_EUROSPI_MOSI) <= '0';
  gp_o.oe(P2A_EUROSPI_SS) <= '0';
  
  -- unused outputs
	bitmap_o <= NULL_TO_BITMAP_CTL;
	sprite_reg_o <= NULL_TO_SPRITE_REG;
	sprite_o <= NULL_TO_SPRITE_CTL;
  tilemap_o.attr_d <= std_logic_vector(resize(unsigned(switches_i(7 downto 0)), tilemap_o.attr_d'length));
	graphics_o <= NULL_TO_GRAPHICS;
	ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;

end architecture SYN;
