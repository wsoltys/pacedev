library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

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
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_t;
    bitmap_o        : out to_BITMAP_CTL_t;
    
    tilemap_i       : in from_TILEMAP_CTL_t;
    tilemap_o       : out to_TILEMAP_CTL_t;

    sprite_reg_o    : out to_SPRITE_REG_t;
    sprite_i        : in from_SPRITE_CTL_t;
    sprite_o        : out to_SPRITE_CTL_t;
		spr0_hit				: in std_logic;

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

end platform;

architecture SYN of platform is

	alias clk_50M				  : std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	
	signal a              : std_logic_vector(15 downto 0) := (others => '0');
  signal d_o            : std_logic_vector(15 downto 0) := (others => '0');
  
  signal wram_cs        : std_logic := '0';
  signal wram_d_o       : std_logic_vector(d_o'range) := (others => '0');
  signal wram_wr        : std_logic := '0';

  signal vram_a         : std_logic_vector(15 downto 0) := (others => '0');
  signal vram1_d_o      : std_logic_vector(d_o'range) := (others => '0');
  signal vram1_wr       : std_logic := '0';
  signal map1_d         : std_logic_vector(15 downto 0) := (others => '0');
  signal vram2_d_o      : std_logic_vector(d_o'range) := (others => '0');
  signal vram2_wr       : std_logic := '0';
  signal map2_d         : std_logic_vector(15 downto 0) := (others => '0');

  signal palram_wr      : std_logic := '0';
  signal palram_d_o     : std_logic_vector(15 downto 0) := (others => '0');
  signal palette        : std_logic_vector(255 downto 0) := (others => '0');
  
begin

  -- SRAM signals (may or may not be used)
  process (clk_video)
  begin
    if rising_edge(clk_video) then
      sram_o.a <= std_logic_vector(resize(unsigned(tilemap_i.tile_a(16 downto 0)), sram_o.a'length));
      --sram_o.d <= (others => '0');
    end if;
  end process;
  --tilemap_o.tile_d <= sram_i.d(15 downto 8) when tilemap_i.tile_a(0) = '1' else sram_i.d(7 downto 0);
  tilemap_o.tile_d <= sram_i.d(7 downto 0);
  sram_o.be <= std_logic_vector(to_unsigned(3, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= '1';
  sram_o.we <= '0';

  vram1_wr <= '0';
  vram2_wr <= '0';
  
  -- unused outputs

  flash_o <= NULL_TO_FLASH;
  bitmap_o <= NULL_TO_BITMAP_CTL;
  sprite_o.ld <= '0';
  graphics_o.bit8_1 <= (others => '0');
  graphics_o.bit16_1 <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o <= (others => '0');
  gp_o <= NULL_TO_GP;
  
  --
  -- COMPONENT INSTANTIATION
  --

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram1_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/neogeo/roms/vram1.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10,
			width_a     => 16
		)
		port map
		(
			clock_b			=> clk_50M,
			address_b		=> vram_a(9 downto 0),
			wren_b			=> vram1_wr,
			data_b			=> d_o,
			q_b					=> vram1_d_o,

			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> map1_d
		);
		
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram2_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/neogeo/roms/vram2.hex",
			numwords_a	=> 256,
			widthad_a		=> 8,
			width_a     => 16
		)
		port map
		(
			clock_b			=> clk_50M,
			address_b		=> vram_a(7 downto 0),
			wren_b			=> vram2_wr,
			data_b			=> d_o,
			q_b					=> vram2_d_o,

			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(7 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> map2_d
		);

  tilemap_o.map_d <=  map1_d(7 downto 0) & map1_d(15 downto 8)
                        when tilemap_i.map_a(10) = '0' else 
                      map2_d(7 downto 0) & map2_d(15 downto 8);
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  palram_inst : entity work.palram
    port map
    (
      clock_b		  => clk_50M,
      address_b		=> a(7 downto 0),
      data_b		  => d_o,
      wren_b		  => palram_wr,
      q_b		      => palram_d_o,

      clock_a		  => clk_video,
      address_a		=> tilemap_i.attr_a(3 downto 0),
      data_a		  => (others => '0'),
      wren_a		  => '0',
      q_a		      => palette
    );

  GEN_PAL_DATA : for i in 0 to 15 generate
    graphics_o.pal(i) <= palette(i*16+15 downto i*16);
  end generate GEN_PAL_DATA;
  
end SYN;
