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
use work.atari_gtia_pkg.all;
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

  -- clocks
  signal clk_high_en    : std_logic;
  signal clk_colour_en  : std_logic;  
  signal clk_cpu_en     : std_logic;
  -- generate by GTIA
  signal clk_fphi0_en   : std_logic;
  -- only for video debug display
  signal clk_dbg_en     : std_logic;
  
  -- uP signals  
	signal cpu_a_ext			: std_logic_vector(23 downto 0);
    alias cpu_a					: std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_r_wn       : std_logic;
  signal cpu_irq_n      : std_logic;
  signal cpu_nmi_n      : std_logic;
  signal cpu_halt_n     : std_logic;

  -- SELF-TEST ROM
  signal self_cs        : std_logic;
  signal self_d_o       : std_logic_vector(7 downto 0);
  
  -- CART/BASIC
  signal basic_cs       : std_logic;
  signal basic_d_o      : std_logic_vector(7 downto 0);
  
  -- GTIA SIGNALS
  signal gtia_cs        : std_logic;
  signal gtia_d_o       : std_logic_vector(7 downto 0);

  -- POKEY SIGNALS
  signal pokey_cs       : std_logic;
  signal pokey_d_o      : std_logic_vector(7 downto 0);

  -- PIA SIGNALS
  signal pia_cs         : std_logic;
  signal pia_d_o        : std_logic_vector(7 downto 0);

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
	signal kernel_cs			: std_logic;
  signal kernel_d_o     : std_logic_vector(7 downto 0);

  -- RAM signals
  signal ram_cs         : std_logic;
  signal ram_we         : std_logic;
  signal ram_d_o        : std_logic_vector(7 downto 0);

  -- PORTB register
  signal portb_r        : std_logic_vector(7 downto 0);
  signal portb_w        : std_logic_vector(7 downto 0);
  signal portb_oe       : std_logic_vector(7 downto 0);
  
  -- other signals      
	signal cpu_reset			: std_logic;
	alias game_reset			: std_logic is inputs_i(2).d(0);

  -- video
  signal video_o_s        : to_VIDEO_t;
  
begin

	cpu_reset <= rst_sys or game_reset;
  
  -- generate clocks from x16 source
  process (clk_sys, rst_sys)
    variable count    : std_logic_vector(4 downto 0);
    variable pal_cnt  : integer range 0 to 4;
  begin
    if rst_sys = '1' then
      count := (others => '0');
      pal_cnt := 0;
      clk_high_en <= '0';
      clk_colour_en <= '0';
      clk_cpu_en <= '0';
      clk_dbg_en <= '0';
    elsif rising_edge(clk_sys) then
      -- default values
      clk_high_en <= '0';
      clk_colour_en <= '0';
      clk_cpu_en <= '0';
      clk_dbg_en <= '0';
      if count(2 downto 0) = "000" then
        -- 7.15909MHZ (NTSC) / 8.8672375MHz (PAL)
        clk_high_en <= '1';
        if count(3) = '0' then
          -- 3.579545MHz (NTSC) / 4.43361875MHz (PAL)
          clk_colour_en <= '1';
          if ATARI_REGION_NTSC then
            if count(4) = '0' then
              -- 1.789773MHz (NTSC)
              clk_cpu_en <= '1';
            end if;
          elsif ATARI_REGION_PAL then
            -- 4.43361875 * 2/5 = 1.773447MHZ (PAL)
            if pal_cnt = pal_cnt'high then
              pal_cnt := 0;
            else
              if pal_cnt = 0 or pal_cnt = 2 then
                clk_cpu_en <= '1';
              end if;
              pal_cnt := pal_cnt + 1;
            end if;
          end if; -- ATARI_REGION
        end if; -- count(3)=0
      end if; -- count(2..0)
      -- debug video
      if count(0) = '0' then
        clk_dbg_en <= '1';
      end if;
      count := count + 1;
    end if;
  end process;
  
  -- chip selects
  -- SELF-TEST ROM $5000-$57FF
  self_cs <=    '1' when STD_MATCH(cpu_a, "01010-----------") else
                '0';
  -- CARTRIDGE/BASIC $A000-$BFFF
  basic_cs <=   '1' when STD_MATCH(cpu_a, "101-------------") else 
                '0';
  -- KERNEL ROM $C000-$CFFF & $D800-$FFFF (16KB)
  kernel_cs <=  '1' when STD_MATCH(cpu_a, X"C---") else
                '1' when STD_MATCH(cpu_a, "11011-----------") else 
                '1' when STD_MATCH(cpu_a, "111-------------") else 
                '0';
  -- GTIA $D000-D0FF
  gtia_cs <=    '1' when STD_MATCH(cpu_a, X"D0--") else
                '0';
  -- POKEY $D200-D2FF
  pokey_cs <=   '1' when STD_MATCH(cpu_a, X"D2--") else
                '0';
  -- PIA $D300-D3FF
  pia_cs <=     '1' when STD_MATCH(cpu_a, X"D3--") else
                '0';
  -- ANTIC $D400-$D40F (mirrored $D4FF)
  antic_cs <=   '1' when STD_MATCH(cpu_a, X"D4--") else 
                '0';
  -- RAM (everything else)
  ram_cs <= '1';

  -- write-enables
  ram_we <= not cpu_r_wn when ram_cs = '1' else 
            '0';
  
  -- read mux
  cpu_d_i <=  -- kernel must be enabled as well
              self_d_o when (self_cs = '1' and portb_r(7) = '0' and portb_r(0) = '1') else
              basic_d_o when (basic_cs = '1' and portb_r(1) = '0') else
              kernel_d_o when (kernel_cs = '1' and portb_r(0) = '1') else
              gtia_d_o when gtia_cs = '1' else
              pokey_d_o when pokey_cs = '1' else
              pia_d_o when pia_cs = '1' else
              antic_d_o when antic_cs = '1' else
              -- this goes last
              ram_d_o when ram_cs = '1' else
              X"FF";
  
  cpu_irq_n <= '1';
  
  cpu_inst : entity work.T65
    port map
    (
      Mode    		=> "00",	-- 6502
      Res_n   		=> not cpu_reset,
      Enable  		=> clk_cpu_en,
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
  self_d_o <= kernel_d_o;
  
  gtia_inst : atari_gtia
    generic map
    (
      -- NTSC
      VARIANT	  => CO14805
    )
    port map
    (
      clk       => clk_sys,
      clk_en    => clk_cpu_en,
      rst       => rst_sys,

      osc       => clk_colour_en,
      phi2_i    => clk_cpu_en,
      fphi0_o   => clk_fphi0_en,

      -- CPU interface
      a         => cpu_a(4 downto 0),
      d_i       => cpu_d_o,
      d_o       => gtia_d_o,
      cs_n      => not gtia_cs,
      r_wn      => cpu_r_wn,
      halt_n    => open,
      
      -- CTIA/GTIA interface
      an        => antic_an,

      -- joystick
      t         => (others => '1'),
      -- console
      s_i       => (others => '1'),
      s_o       => open,
      
      -- video inputs
      cad3      => '0',
      pal       => '0',
      
      -- RGB output
      clk_vga   => clk_high_en,
      r         => video_o_s.rgb.r(9 downto 2),
      g         => video_o_s.rgb.g(9 downto 2),
      b         => video_o_s.rgb.b(9 downto 2),
      hsync     => video_o_s.hsync,
      vsync     => video_o_s.vsync,
      de        => video_o_s.de,
      
      -- dbg
      dbg       => open
    );
  video_o_s.rgb.r(1 downto 0) <= (others => '0');
  video_o_s.rgb.g(1 downto 0) <= (others => '0');
  video_o_s.rgb.b(1 downto 0) <= (others => '0');
    
  pokey_inst : entity work.ASTEROIDS_POKEY
    port map 
    (
      ADDR      => cpu_a(3 downto 0),
      DIN       => cpu_d_o,
      DOUT      => pokey_d_o,
      DOUT_OE_L => open,
      RW_L      => cpu_r_wn,
      CS        => pokey_cs,
      CS_L      => '0',
      --
      AUDIO_OUT => open,
      --
      PIN       => (others => '0'),
      ENA       => clk_cpu_en,
      CLK       => clk_sys
    );
    
  pia6821_inst : entity work.pia6821
    port map
    (	
      clk       	=> clk_sys,
      rst       	=> rst_sys,
      cs        	=> pia_cs,
      rw        	=> cpu_r_wn,
      addr(1)     => cpu_a(0),
      addr(0)     => cpu_a(1),
      data_in   	=> cpu_d_o,
      data_out  	=> pia_d_o,
      irqa      	=> open,
      irqb      	=> open,
      pa_i        => (others => '0'),
      pa_o				=> open,
      pa_oe				=> open,
      ca1       	=> '0',
      ca2_i      	=> '0',
      ca2_o				=> open,
      ca2_oe			=> open,
      pb_i				=> portb_r,
      pb_o       	=> portb_w,
      pb_oe				=> portb_oe,
      cb1       	=> '0',
      cb2_i      	=> '0',
      cb2_o				=> open,
      cb2_oe			=> open
    );

  -- PORTB (ROM mapping) register
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      -- enable kernel, disable basic, self-test
      -- - the ROM does this too!
      portb_r <= (others => '1');
    elsif rising_edge(clk_sys) then
      for i in 7 downto 0 loop
        if portb_oe(i) = '1' then
          portb_r(i) <= portb_w(i);
        end if;
      end loop;
    end if;
  end process;
  
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
      
      fphi0_i => clk_fphi0_en,
      phi0_o  => open,
      phi2_i  => clk_cpu_en,
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
    
    signal dbg_enable       : std_logic;
    signal dbg_dim          : std_logic;
    signal dbg_video        : std_logic;

  begin
  
    dbg_enable <= '1';
    
    -- mux in antic debug
    video_o.rgb.r <= dbg_video & '0' & video_o_s.rgb.r(9 downto 2) when (dbg_enable and dbg_dim) = '1' else video_o_s.rgb.r;
    video_o.rgb.g <= dbg_video & '0' & video_o_s.rgb.g(9 downto 2) when (dbg_enable and dbg_dim) = '1' else video_o_s.rgb.g;
    video_o.rgb.b <= dbg_video & '0' & video_o_s.rgb.b(9 downto 2) when (dbg_enable and dbg_dim) = '1' else video_o_s.rgb.b;
    video_o.hsync <= video_o_s.hsync;
    video_o.vsync <= video_o_s.vsync;
    video_o.de <= video_o_s.de;

    GEN_GTIA_VIDEO : if true generate
      video_o.clk <= clk_sys;
    else generate
      signal rgb_data			    : RGB_t;
    begin
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
      video_o.clk <= video_o_s.clk;
      rgb_data.r <= (others => '0');
      rgb_data.g <= (others => '0');
      rgb_data.b <= (others => '0');
    end generate GEN_GTIA_VIDEO;
    
    antic_hexy_inst : antic_hexy
      generic map
      (
        yOffset => 232*2,
        xOffset => 200
      )
      port map
      (
        clk       => clk_sys,
        clk_ena   => clk_dbg_en,
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
