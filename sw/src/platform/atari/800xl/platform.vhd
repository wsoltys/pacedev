library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.antic_pkg.all;

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
end entity platform;

architecture SYN of platform is

	alias clk_sys					: std_logic is clkrst_i.clk(0);
  alias rst_sys         : std_logic is clkrst_i.rst(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	
  -- uP signals  
  signal cpu_clk_en     : std_logic;
	signal cpu_a_ext			: std_logic_vector(23 downto 0);
    alias cpu_a					: std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_rw_n       : std_logic;
  signal cpu_irq_n      : std_logic;
  signal cpu_nmi_n      : std_logic;

  -- ANTIC signals
  signal antic_a_o      : std_logic_vector(15 downto 0);
  signal antic_d_o      : std_logic_vector(7 downto 0);
  signal antic_r_wn     : std_logic;
  signal antic_halt     : std_logic;
  signal antic_nmi_i    : std_logic;
  signal antic_nmi_o    : std_logic;
  signal antic_rdy      : std_logic;
  signal antic_an       : std_logic_vector(2 downto 0);
  
  -- ROM signals        
	signal rom0_cs				: std_logic;
  signal rom0_datao     : std_logic_vector(7 downto 0);
	signal rom1_cs				: std_logic;                        
	signal rom1_datao			: std_logic_vector(7 downto 0);
	
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_wr        : std_logic;
  signal wram_datao     : std_logic_vector(7 downto 0);

	-- IO signals
	signal port_cs				: std_logic_vector(5 downto 0);
	signal port_wr				: std_logic_vector(5 downto 2);
	alias game_reset			: std_logic is inputs_i(2).d(0);
	signal shift_dout			: std_logic_vector(7 downto 0);

  -- other signals      
	signal cpu_reset			: std_logic;
  signal cpu_mem_d_i    : std_logic_vector(7 downto 0);
  signal cpu_io_d_i     : std_logic_vector(7 downto 0);
  
  signal spec_key_en    : std_logic_vector(7 downto 0);
  alias osd_key_en      : std_logic is spec_key_en(1);
  alias rot_key_en      : std_logic is spec_key_en(2);
  
begin

  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CPU_FREQ_MHz=" &  integer'image(CPU_FREQ_MHz) &
            " CPU_CLK_ENA_DIV=" & integer'image(INVADERS_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

	cpu_reset <= clkrst_i.arst or game_reset;

  -- generate 2MHz CPU clock from 20MHz source
  process (clk_sys, rst_sys)
    variable count : integer range 0 to 9;
  begin
    if rst_sys = '1' then
      count := 0;
      cpu_clk_en <= '0';
    elsif rising_edge(clk_sys) then
      cpu_clk_en <= '0';  -- default
      if count = count'high then
        count := 0;
        cpu_clk_en <= '1';
      else
        count := count + 1;
      end if;
    end if;
  end process;
  
  cpu_inst : entity work.T65
    port map
    (
      Mode    		=> "00",	-- 6502
      Res_n   		=> not cpu_reset,
      Enable  		=> cpu_clk_en,
      Clk     		=> clk_sys,
      Rdy     		=> '1',
      Abort_n 		=> '1',
      IRQ_n   		=> cpu_irq_n,
      NMI_n   		=> cpu_nmi_n,
      SO_n    		=> '1',
      R_W_n   		=> cpu_rw_n,
      Sync    		=> open,
      EF      		=> open,
      MF      		=> open,
      XF      		=> open,
      ML_n    		=> open,
      VP_n    		=> open,
      VDA     		=> open,
      VPA     		=> open,
      A       		=> cpu_a_ext,
      DI      		=> cpu_d_i,
      DO      		=> cpu_d_o
    );
    
  antic_inst : antic
    generic map
    (
      VARIANT	=> CO21697
    )
    port map
    (
      clk     => clk_sys,
      clk_en  => '1',
      rst     => clkrst_i.rst(0),
      
      fphi0_i => clk_sys,
      phi0_o  => open,
      phi2_i  => clk_sys,
      res_n   => '1',

      -- CPU interface
      a_i     => cpu_a,
      a_o     => antic_a_o,
      d_i     => cpu_d_o,
      d_o     => antic_d_o,
      r_wn_i  => cpu_rw_n,
      r_wn_o  => antic_r_wn,
      halt_n  => antic_halt,
      rnmi_n  => antic_nmi_i,
      nmi_n   => antic_nmi_o,
      rdy     => antic_rdy,
      
      -- CTIA/GTIA interface
      an      => antic_an,

      -- light pen input
      lp_n    => '0',
      -- unused (DRAM refresh)
      ref_n   => open
    );
		
  -- unused outputs

  --graphics_o <= NULL_TO_GRAPHICS;
  --tilemap_o <= NULL_TO_TILEMAP_CTL;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --osd_o <= NULL_TO_OSD;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  
end SYN;
