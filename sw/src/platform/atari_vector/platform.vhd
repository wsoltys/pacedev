library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;
use work.project_pkg.all;

entity platform is
  generic
  (
    NUM_INPUT_BYTES   : integer
  );
  port
  (
    -- clocking and reset
    clkrst_i        : in from_CLKRST_t;

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
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;
    
    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    bitmap_o        : out to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    
    tilemap_i       : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    tilemap_o       : out to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

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

    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );

end platform;

architecture SYN of platform is

	alias clk_sys				  : std_logic is clkrst_i.clk(0);
	alias rst_sys				  : std_logic is clkrst_i.rst(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	
  -- input signals      
  signal in_cs          : std_logic_vector(0 to PACE_INPUTS_NUM_BYTES-1);
	
  -- other signals
  signal rst_platform   : std_logic;
  signal pause          : std_logic;

begin

  -- handle special keys
  process (clk_sys, rst_sys)
    variable spec_keys_r  : std_logic_vector(7 downto 0);
    alias spec_keys       : std_logic_vector(7 downto 0) is inputs_i(PACE_INPUTS_NUM_BYTES-1).d;
  begin
    if rst_sys = '1' then
      rst_platform <= '0';
      pause <= '0';
      spec_keys_r := (others => '0');
    elsif rising_edge(clk_sys) then
      rst_platform <= spec_keys(0);
      if spec_keys_r(1) = '0' and spec_keys(1) = '1' then
        pause <= not pause;
      end if;
      spec_keys_r := spec_keys;
    end if;
  end process;
  
  --
  -- COMPONENT INSTANTIATION
  --

  assert false
    report  "CLK0_FREQ_MHz = " & integer'image(CLK0_FREQ_MHz) & "\n" &
            "CPU_FREQ_MHz = " &  integer'image(CPU_FREQ_MHz) & "\n" &
            "CPU_CLK_ENA_DIV = " & integer'image(ATARI_VECTOR_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

  BLK_ATARI_VECTOR : block
  
    -- 12MHz
    alias clk_12          : std_logic is clkrst_i.clk(0);
    -- add platform/game reset
    alias cpu_reset_h     : std_logic is clkrst_i.rst(0);
    signal soundval       :	STD_LOGIC_VECTOR(7 downto 0);
    signal xval           :	STD_LOGIC_VECTOR(9 downto 0);
    signal yval           :	STD_LOGIC_VECTOR(9 downto 0);
    signal zval	          :	STD_LOGIC_VECTOR(7 downto 0);
    signal rgb	          :	STD_LOGIC_VECTOR(2 downto 0);
    signal O_DBG          : STD_LOGIC_VECTOR(15 downto 0);
    signal buttons        :	STD_LOGIC_VECTOR(14 downto 0);
    
  begin
  
    atari_vector_inst : entity work.bwidow 
      port map 
      (
        clk => clk_12,
        reset_h => cpu_reset_h,
        analog_sound_out => soundval,
        analog_x_out => yval,
        analog_y_out => xval,
        analog_z_out => zval,
        rgb_out => rgb,
        dbg => O_DBG,
        buttons => buttons
      );

    --psxbuttons(15 downto 0): 
    --15:SQUARE 14:CROSS 13:CIRCLE 12:TRIANGLE 11:R1 10:L1 9:R2 8:L2 
    --7:LEFT 6:DOWN 5:RIGHT 4:UP 3:START 2:X 1:X 0:SELECT
    --buttons(14 downto 0): COINAUX COINL COINR START2 START1 FD FU FL FR MU MD ML MR
    buttons <= (others => '0');
    
  end block BLK_ATARI_VECTOR;
  
  -- unused outputs

  flash_o <= NULL_TO_FLASH;
  bitmap_o <= (others => NULL_TO_BITMAP_CTL);
  sprite_o.ld <= '0';
  --graphics_o <= NULL_TO_GRAPHICS;
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o <= (others => '0');
  
end SYN;
