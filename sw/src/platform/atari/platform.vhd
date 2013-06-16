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
use work.platform_variant_pkg.all;
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
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;
    
    -- sound
    snd_i           : in from_SOUND_t;
    snd_o           : out to_SOUND_t;
    
    -- OSD
    osd_i           : in from_OSD_t;
    osd_o           : out to_OSD_t;

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
  signal cpu_r_wn       : std_logic;
  signal cpu_irq_n      : std_logic;
  signal cpu_nmi_n      : std_logic;
  signal cpu_halt_n     : std_logic;

  -- SELF-TEST ROM
  signal self_en        : std_logic;
  signal self_cs        : std_logic;
  signal self_d_o       : std_logic_vector(7 downto 0);
  
  -- CART/BASIC
  signal basic_en       : std_logic;
  signal basic_cs       : std_logic;
  signal basic_d_o      : std_logic_vector(7 downto 0);
  
  -- ANTIC signals
  signal antic_cs       : std_logic;
  signal antic_a_o      : std_logic_vector(15 downto 0);
  signal antic_d_o      : std_logic_vector(7 downto 0);
  signal antic_r_wn     : std_logic;
  signal antic_nmi_i    : std_logic;
  signal antic_rdy      : std_logic;
  signal antic_an       : std_logic_vector(2 downto 0);
  signal antic_dbg      : antic_dbg_t;
  
  -- KERNEL ROM signals        
	signal kernel_en			: std_logic;
	signal kernel_cs			: std_logic;
  signal kernel_d_o     : std_logic_vector(7 downto 0);

  -- RAM signals
  signal ram_cs         : std_logic;
  signal ram_we         : std_logic;
  signal ram_d_o        : std_logic_vector(7 downto 0);
  
  -- other signals      
	signal cpu_reset			: std_logic;
	alias game_reset			: std_logic is inputs_i(2).d(0);
  
begin

	cpu_reset <= rst_sys or game_reset;

  -- generate 2MHz CPU clock from 24MHz source
  process (clk_sys, rst_sys)
    variable count : integer range 0 to 24/2-1;
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
  
  -- chip selects
  -- self-test ROM $5000-$57FF
  self_cs <=    '1' when STD_MATCH(cpu_a, "01010-----------") else
                '0';
  -- CARTRIDGE/BASIC $A000-$BFFF
  basic_cs <=   '1' when STD_MATCH(cpu_a, "101-------------") else 
                '0';
  -- ANTIC $D400-$D40F (mirrored $D4FF)
  antic_cs <=   '1' when STD_MATCH(cpu_a, X"D4--") else 
                '0';
  -- KERNEL ROM $C000-$CFFF & $D800-$FFFF (16KB)
  kernel_cs <=  '1' when STD_MATCH(cpu_a, X"C---") else
                '1' when STD_MATCH(cpu_a, "11011-----------") else 
                '1' when STD_MATCH(cpu_a, "111-------------") else 
                '0';
  -- RAM (everything else)
  ram_cs <= '1';

  -- write-enables
  ram_we <= not cpu_r_wn when ram_cs = '1' else 
            '0';
  
  -- read mux
  cpu_d_i <=  self_d_o when self_cs = '1' else
              basic_d_o when basic_cs = '1' else
              kernel_d_o when kernel_cs = '1' else
              antic_d_o when antic_cs = '1' else
              -- this goes last
              ram_d_o when ram_cs = '1' else
              X"FF";

  -- MMU
  self_en <= kernel_en;
  basic_en <= '0';
  kernel_en <= '1';
  
  cpu_irq_n <= '1';
  
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
      R_W_n   		=> cpu_r_wn,
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
    
  -- RAM
  ram_d_o <= sram_i.d(ram_d_o'range);
  sram_o.a <= std_logic_vector(RESIZE(unsigned(cpu_a),sram_o.a'length));
  sram_o.d <= std_logic_vector(RESIZE(unsigned(cpu_d_o),sram_o.d'length));
  sram_o.cs <= ram_cs;
  sram_o.oe <= not ram_we;
  sram_o.we <= ram_we;
  sram_o.be <= std_logic_vector(to_unsigned(1,sram_o.be'length));
  
  basic_inst : work.sprom
		generic map
		(
			init_file		=> ATARI_ROM_DIR & PLATFORM_VARIANT_BASIC_NAME,
			--numwords_a	=> 8192,
			widthad_a		=> 13
		)
		port map
		(
			clock			=> clk_sys,
			address		=> cpu_a(12 downto 0),
			q					=> basic_d_o
		);

  kernel_inst : work.sprom
		generic map
		(
			init_file		=> VARIANT_ROM_DIR & PLATFORM_VARIANT_KERNEL_NAME,
			--numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_sys,
			address		=> cpu_a(13 downto 0),
			q					=> kernel_d_o
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
      r_wn_i  => cpu_r_wn,
      r_wn_o  => antic_r_wn,
      halt_n  => cpu_halt_n,
      rnmi_n  => antic_nmi_i,
      nmi_n   => cpu_nmi_n,
      rdy     => antic_rdy,
      
      -- CTIA/GTIA interface
      an      => antic_an,

      -- light pen input
      lp_n    => '0',
      -- unused (DRAM refresh)
      ref_n   => open,
      
      dbg     => antic_dbg
    );

  BLK_TEMP_GRAPHICS : block
  
    signal rgb_data			    : RGB_t;
    signal video_o_s        : to_VIDEO_t;
    
    signal dbg_enable       : std_logic;
    signal dbg_dim          : std_logic;
    signal dbg_video        : std_logic;

  begin
  
    dbg_enable <= '1';
    rgb_data.r <= (others => '0');
    rgb_data.g <= (others => '0');
    rgb_data.b <= (others => '0');
    
    -- mux in antic debug
    video_o.clk <= video_o_s.clk;
    video_o.rgb.r <= dbg_video & '0' & video_o_s.rgb.r(9 downto 2) when (dbg_enable and dbg_dim) = '1' else video_o_s.rgb.r;
    video_o.rgb.g <= dbg_video & '0' & video_o_s.rgb.g(9 downto 2) when (dbg_enable and dbg_dim) = '1' else video_o_s.rgb.g;
    video_o.rgb.b <= dbg_video & '0' & video_o_s.rgb.b(9 downto 2) when (dbg_enable and dbg_dim) = '1' else video_o_s.rgb.b;
    video_o.hsync <= video_o_s.hsync;
    video_o.vsync <= video_o_s.vsync;
    video_o.de <= video_o_s.de;
    
    pace_video_controller_inst : entity work.pace_video_controller
      generic map
      (
        CONFIG		  => PACE_VIDEO_CONTROLLER_TYPE,
        DELAY       => PACE_VIDEO_PIPELINE_DELAY,
        H_SIZE      => PACE_VIDEO_H_SIZE,
        V_SIZE      => PACE_VIDEO_V_SIZE,
        L_CROP      => PACE_VIDEO_L_CROP,
        R_CROP      => PACE_VIDEO_R_CROP,
        H_SCALE     => PACE_VIDEO_H_SCALE,
        V_SCALE     => PACE_VIDEO_V_SCALE,
        H_SYNC_POL  => PACE_VIDEO_H_SYNC_POLARITY,
        V_SYNC_POL  => PACE_VIDEO_V_SYNC_POLARITY,
        BORDER_RGB  => PACE_VIDEO_BORDER_RGB
      )
      port map
      (
        -- clocking etc
        video_i         => video_i,
        
        -- register interface
        reg_i.h_scale	  => "000",
        reg_i.v_scale 	=> "000",
        -- video data signals (in)
        rgb_i		    		=> rgb_data,

        -- video control signals (out)
        video_ctl_o     => open,

        -- VGA signals (out)
        video_o     		=> video_o_s
      );
    
    antic_hexy_inst : antic_hexy
      generic map
      (
        yOffset => 600,
        xOffset => 200
      )
      port map
      (
        clk       => video_o_s.clk,
        clk_ena   => '1',
        vSync     => video_o_s.vsync,
        hSync     => video_o_s.hsync,
        video     => dbg_video,
        dim       => dbg_dim,

        dbg       => antic_dbg
      );

  end block BLK_TEMP_GRAPHICS;
  
  -- unused outputs
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  
end SYN;
