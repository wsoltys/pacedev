library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
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
    sram_i	        : in from_SRAM_t;
    sram_o	        : out to_SRAM_t;
    sdram_i	        : in from_SDRAM_t;
    sdram_o	        : out to_SDRAM_t;

--    -- graphics
--    
--    bitmap_i        : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
--    bitmap_o        : out to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
--    
--    tilemap_i       : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
--    tilemap_o       : out to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
--
--    sprite_reg_o    : out to_SPRITE_REG_t;
--    sprite_i        : in from_SPRITE_CTL_t;
--    sprite_o        : out to_SPRITE_CTL_t;
--    spr0_hit	      : in std_logic;
--
--    -- various graphics information
--    graphics_i      : in from_GRAPHICS_t;
--    graphics_o      : out to_GRAPHICS_t;
    
		-- video (incl. clk)
		video_i					: in from_VIDEO_t;
		video_o					: out to_VIDEO_t;

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

	alias clk_40M					: std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	signal clk_2M_en			: std_logic;
	
  -- uP signals  
  signal cpu_a              : std_logic_vector(15 downto 0);
  signal cpu_d_i            : std_logic_vector(7 downto 0);
  signal cpu_d_o            : std_logic_vector(7 downto 0);
  signal cpu_m1_n           : std_logic;
  signal cpu_mem_rd         : std_logic;
  signal cpu_mem_wr         : std_logic;
  signal cpu_io_rd          : std_logic;
  signal cpu_io_wr          : std_logic;
  signal cpu_irq            : std_logic;
  signal cpu_irq_vec        : std_logic_vector(7 downto 0);
  signal cpu_irq_ack        : std_logic;
  signal cpu_nmi            : std_logic;
	alias cpu_io_a				    : std_logic_vector(7 downto 0) is cpu_a(7 downto 0);

  -- start-of-day hardware signal
  signal sod                : std_logic;
  
  -- ROM signals        
	signal rom_cs					    : std_logic;
  signal rom_d_o            : std_logic_vector(7 downto 0);

  -- port signals
  signal portFX_cs          : std_logic;
  signal portF0_r           : std_logic_vector(7 downto 0);
    alias charset_r         : std_logic is portF0_r(0);
    alias video_r           : std_logic is portF0_r(2);   -- super80v only
    alias snd_r             : std_logic is portF0_r(3);
    alias pcg_r             : std_logic is portF0_r(4);   -- super80r/v only
  signal portF1_r           : std_logic_vector(7 downto 0);
    alias video_page_r      : std_logic_vector(15 downto 9) is portF1_r(7 downto 1);
  signal portF2_r           : std_logic_vector(7 downto 0);
  signal portF8_r           : std_logic_vector(7 downto 0);
    alias kbd_line          : std_logic_vector(7 downto 0) is portF8_r;
  
  -- keyboard signals
	signal kbd_cs					    : std_logic;
	signal kbd_d_o				    : std_logic_vector(7 downto 0);
		                        
  -- VRAM signals       
	signal vram_cs				    : std_logic;
  signal vram_wr            : std_logic;
  signal vram_d_o           : std_logic_vector(7 downto 0);
  -- CRAM signals       
	signal cram_cs				    : std_logic;
  signal cram_wr            : std_logic;
  signal cram_d_o           : std_logic_vector(7 downto 0);

  -- VDUEB signals
  signal crtc6845_cs        : std_logic;
  
  -- pcg80 signals
  signal pcg80_cs           : std_logic := '0';
  signal pcg80_d_o          : std_logic_vector(7 downto 0);
  -- le18 signals
  signal le18_cs            : std_logic := '0';
  signal le18_d_o           : std_logic_vector(7 downto 0) := (others => '0');
  -- lnw80 signals
  signal lnw80_video_ctl_cs   : std_logic := '0';
  signal lnw80_video_ctl_r    : std_logic_vector(7 downto 0) := (others => '0');
    alias gfxram_ena          : std_logic is lnw80_video_ctl_r(3);
    alias gfxmode             : std_logic_vector(1 downto 0) is lnw80_video_ctl_r(2 downto 1);
    alias inverse_ena         : std_logic is lnw80_video_ctl_r(0);
  signal lnw80_hires_ram_cs   : std_logic := '0';
  signal lnw80_hires_ram_wr   : std_logic := '0';
  signal lnw80_hires_ram_d_o  : std_logic_vector(7 downto 0) := (others => '0');
  -- mikrokolor signals
  signal vdp_cs               : std_logic;
  signal vdp_d_o              : std_logic_vector(7 downto 0);
  
  -- RAM signals        
  signal ram_wr             : std_logic;
  alias ram_d_o      	      : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- interrupt signals
	signal int_cs					    : std_logic;
  signal int_status         : std_logic_vector(7 downto 0);

  -- fdc signals
	signal fdc_cs					    : std_logic;
  signal fdc_d_o            : std_logic_vector(7 downto 0);
  signal fdc_drq_int        : std_logic;

  signal hdd_d              : std_logic_vector(7 downto 0);
  signal hdd_cs             : std_logic := '0';
  
  -- other signals      
	alias game_reset			    : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	signal cpu_reset			    : std_logic;  
	signal alpha_joy_cs		    : std_logic;
	signal snd_cs					    : std_logic;

begin

  assert false
    report  "SUPER80_VARIANT=" & SUPER80_VARIANT &
            " SUPER80_BIOS=" & SUPER80_BIOS_C000
      severity note;
      
  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CPU_FREQ_MHz=" &  real'image(CPU_FREQ_MHz) &
            " CPU_CLK_ENA_DIV=" & integer'image(TRS80_M1_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

	cpu_reset <= clkrst_i.arst or game_reset;

  -- not used for now
  cpu_irq_vec <= (others => '0');

  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not ram_wr;
  sram_o.we <= ram_wr;

	-- memory chip selects
	-- ROM $0000-$3FFF (SOD=1), $C000-$EFFF (SOD=0)
	rom_cs <=   '1' when sod = '1' and cpu_a(15 downto 14) = "00" else
              '1' when cpu_a(15 downto 13) = "110" else
              '1' when cpu_a(15 downto 12) = "1110" else
              '0';
  -- CRAM $FE00-$FFFF (Chipspeed Colour Board)
  cram_cs <=  '1' when cpu_a(15 downto 9) = X"F"&"111" else
              '0';
	-- VRAM (all of memory)
	vram_cs <=  '1';
 
   -- io selects
  crtc6845_cs <=  '1' when cpu_a(7 downto 1) = X"1"&"000" else
                  '0';
  portFX_cs <=    '1' when cpu_a(7 downto 4) = X"F" else
                  '0';

  -- start-of-day circuit emulation
  -- ROMs appear at $0000-$3FFF
  -- - until A15,14 high and M1# asserted
  process (clk_40M, cpu_reset)
  begin
    if cpu_reset = '1' then
      sod <= '1';
    elsif rising_edge(clk_40M) then
      if clk_2M_en = '1' then
        if cpu_a(15 downto 14) = "11" and cpu_m1_n = '0' then
          sod <= '0';
        end if;
      end if; -- clk_2M_en
    end if;
  end process;
  
  -- port I/O
  process (clk_40M, cpu_reset)
  begin 
    if cpu_reset = '1' then
      portF0_r <= (others => '0');
      portF1_r <= (others => '0');
    elsif rising_edge(clk_40M) then
      if clk_2M_en = '1' then
        if portFX_cs = '1' then
          if cpu_io_wr = '1' then
            case cpu_a(3 downto 0) is
              when X"0" =>
                -- general purpose output
                portF0_r <= cpu_d_o;
              when X"1" =>
                -- video page
                portF1_r <= cpu_d_o;
              when X"8" =>
                -- keyboard scan line
                portF8_r <= cpu_d_o;
              when others =>
                null;
            end case;
          end if; -- cpu_io_wr
        end if; -- portFX_cs
      end if; -- clk_2M_en
    end if;
  end process;

	-- RDINTSTATUS $37E0-$37E3 (active high)
	int_cs <= '1' when cpu_a(15 downto 2) = (X"37E" & "00") else '0';
	-- FDC $37EC-$37EF
	fdc_cs <= '1' when cpu_a(15 downto 2) = (X"37E" & "11") else '0';
	-- KEYBOARD $3800-$38FF
	kbd_cs <= '1' when cpu_a(15 downto 10) = (X"3" & "10") else '0';

--  -- LNW80 hires RAM ($0000-$3FFF)
--  lnw80_hires_ram_cs <= '1' when TRS80_M1_IS_LNW80 and (gfxram_ena = '1') and 
--                              (cpu_a(15 downto 14) = "00") else '0';
  
	-- memory write enables
  cram_wr <= cram_cs and cpu_mem_wr;
	vram_wr <= vram_cs and cpu_mem_wr;
  lnw80_hires_ram_wr <= lnw80_hires_ram_cs and cpu_mem_wr;
  
	-- always write thru to RAM (except LNW80 hires RAM)
	ram_wr <= (not lnw80_hires_ram_cs) and cpu_mem_wr;

	-- I/O chip selects
	-- Alpha Joystick $00 (active low)
	alpha_joy_cs <= '1' when cpu_io_a = X"00" else '0';
	-- LE18 $EC-$EF
  le18_cs <= '1' when STD_MATCH(cpu_io_a, X"E" & "11--") else '0';
	-- PCG-80 $FE, 80-GRAFIX $FF
--	pcg80_cs <= '1' when (TRS80_M1_HAS_PCG80 and cpu_io_a = X"FE") else 
--              '1' when (TRS80_M1_HAS_80GRAFIX and cpu_io_a = X"FF") else
--              '0';
  -- LNW80 video control register $FE/254
--  lnw80_video_ctl_cs <= '1' when (TRS80_M1_IS_LNW80 and cpu_io_a = X"FE") else '0';
  -- mikrokolor I/O $01-$02
  vdp_cs <= '1' when (cpu_a(7 downto 0) = X"01" or cpu_a(7 downto 0) = X"02") else '0';
  
  -- SOUND $FC-FF (Model I is $FF only)
	snd_cs <= '1' when cpu_io_a = X"FF" else '0';
	
	-- io write enables
	-- SOUND OUTPUT $FC-FF (Model I is $FF only)
	snd_o.a <= cpu_a(snd_o.a'range);
	snd_o.d <= cpu_d_o;
	snd_o.rd <= '0';
  snd_o.wr <= snd_cs and cpu_io_wr;
		
  BLK_RD_MUX : block
    signal mem_d              : std_logic_vector(7 downto 0);
    signal io_d               : std_logic_vector(7 downto 0);
  begin
    -- read mux
    cpu_d_i <= mem_d when (cpu_mem_rd = '1') else io_d;

    -- memory read mux
    mem_d <= 	--lnw80_hires_ram_d_o when lnw80_hires_ram_cs = '1' else
              -- decode ROM before RAM because of SOD logic
              rom_d_o when rom_cs = '1' else
              cram_d_o when (SUPER80_HAS_CHIPSPEED_COLOUR and cram_cs = '1') else
              --int_status when int_cs = '1' else
              --fdc_d_o when fdc_cs = '1' else
              --vram_d_o when vram_cs = '1' else
              vram_d_o;
    
    -- io read mux
    io_d <= --X"FF" when alpha_joy_cs = '1' else
            --le18_d_o when le18_cs = '1' else
            --vdp_d_o when vdp_cs = '1' else
            --hdd_d when hdd_cs = '1' else
            --lnw80_video_ctl_r when lnw80_video_ctl_cs = '1' else
            -- port F2 (dipswitches)
            X"6F" when portFX_cs = '1' and cpu_a(3 downto 0) = X"2" else
            kbd_d_o when portFX_cs = '1' and cpu_a(3 downto 0) = X"A" else
            X"FF";
  end block BLK_RD_MUX;
  
  -- Keyboard Matrix
  process (clk_40M, cpu_reset)
    variable kbd_d_v  : std_logic_vector(7 downto 0);
  begin
    if cpu_reset = '1' then
      kbd_d_v := (others => '1');
    elsif rising_edge(clk_40M) then
      kbd_d_v := (others => '1');
      for i in 0 to 7 loop
        if kbd_line(i) = '0' then
          kbd_d_v := kbd_d_v and inputs_i(i).d;
        end if;
      end loop;
      kbd_d_o <= kbd_d_v;
      -- <CTRL><C><4> generates an interrupt
      cpu_irq <= not (inputs_i(3).d(0) or inputs_i(3).d(4) or inputs_i(3).d(7));
    end if;
  end process;
  
  -- unused outputs
--	sprite_reg_o <= NULL_TO_SPRITE_REG;
--	sprite_o <= NULL_TO_SPRITE_CTL;
--	ser_o <= NULL_TO_SERIAL;
--  spi_o <= NULL_TO_SPI;
  --gp_o <= NULL_TO_GP;

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> TRS80_M1_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_40M,
			reset			=> clkrst_i.rst(0),
			clk_en		=> clk_2M_en
		);

	up_inst : entity work.Z80                                                
    port map
    (
      clk			=> clk_40M,                                   
      clk_en	=> clk_2M_en,
      reset  	=> cpu_reset,                                     

      addr   	=> cpu_a,
      datai  	=> cpu_d_i,
      datao  	=> cpu_d_o,

      m1      => cpu_m1_n,
      mem_rd 	=> cpu_mem_rd,
      mem_wr 	=> cpu_mem_wr,
      io_rd  	=> cpu_io_rd,
      io_wr  	=> cpu_io_wr,

      intreq 	=> cpu_irq,
      intvec 	=> cpu_irq_vec,
      intack 	=> cpu_irq_ack,
      nmi    	=> '0' --cpu_nmi
    );

  GEN_ROM : if true generate
  
    signal romC000_d_o  : std_logic_vector(7 downto 0);
    signal romD000_d_o  : std_logic_vector(7 downto 0);
    signal romE000_d_o  : std_logic_vector(7 downto 0);
    
  begin

    -- only decode A13..12 because SOD moves the ROMs to $0000
    rom_d_o <=  romC000_d_o when cpu_a(13 downto 12) = "00" else
                romD000_d_o when cpu_a(13 downto 12) = "01" else
                romE000_d_o when cpu_a(13 downto 12) = "10" else
                (others => '1');
                
    romC000_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/super80/roms/" &
                        SUPER80_BIOS_C000 & ".u26.hex",
        widthad_a		=> 12
      )
      port map
      (
        clock			=> clk_40M,
        address		=> cpu_a(11 downto 0),
        q					=> romC000_d_o
      );

    romD000_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/super80/roms/" &
                        SUPER80_BIOS_D000 & ".u33.hex",
        widthad_a		=> 12
      )
      port map
      (
        clock			=> clk_40M,
        address		=> cpu_a(11 downto 0),
        q					=> romD000_d_o
      );

    romE000_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/super80/roms/" &
                        SUPER80_BIOS_E000 & ".u42.hex",
        widthad_a		=> 12
      )
      port map
      (
        clock			=> clk_40M,
        address		=> cpu_a(11 downto 0),
        q					=> romE000_d_o
      );

  else generate
  
    flash_o.a <= std_logic_vector(resize(unsigned(cpu_a(13 downto 0)), flash_o.a'length));
    flash_o.we <= '0';
    flash_o.cs <= rom_cs;
    flash_o.oe <= '1';
    rom_d_o <= flash_i.d(rom_d_o'range);
    
  end generate GEN_ROM;
  
  GEN_VIDEO : if SUPER80_HAS_VDUEB generate

    GEN_CRTC6845 : if true generate
    
      component crtc6845s is
        port
        (
          -- INPUT
          I_E         : in std_logic;
          I_DI        : in std_logic_vector(7 downto 0);
          I_RS        : in std_logic;
          I_RWn       : in std_logic;
          I_CSn       : in std_logic;
          I_CLK       : in std_logic;
          I_RSTn      : in std_logic;

          -- OUTPUT
          O_RA        : out std_logic_vector(4 downto 0);
          O_MA        : out std_logic_vector(13 downto 0);
          O_H_SYNC    : out std_logic;
          O_V_SYNC    : out std_logic;
          O_DISPTMG   : out std_logic
        );
      end component crtc6845s;
      
      signal crtc6845_clk     : std_logic;
      signal crtc6845_e       : std_logic;
      signal crtc6845_ra      : std_logic_vector(4 downto 0);
      signal crtc6845_ma      : std_logic_vector(13 downto 0);
      signal crtc6845_hsync   : std_logic;
      signal crtc6845_vsync   : std_logic;
      signal crtc6845_disptmg : std_logic;
      
    begin
    
      crtc6845_clk <= clk_2M_en;
      crtc6845_e <= not clk_2M_en;
      
      crtc6845s_inst : crtc6845s
        port map
        (
          -- INPUT
          I_E         => crtc6845_e,
          I_DI        => cpu_d_o,
          I_RS        => cpu_a(0),
          I_RWn       => not cpu_io_wr,
          I_CSn       => not crtc6845_cs,
          I_CLK       => crtc6845_clk,
          I_RSTn      => not cpu_reset,

          -- OUTPUT
          O_RA        => crtc6845_ra,
          O_MA        => crtc6845_ma,
          O_H_SYNC    => crtc6845_hsync,
          O_V_SYNC    => crtc6845_vsync,
          O_DISPTMG   => crtc6845_disptmg
        );

    else generate
    begin
    end generate GEN_CRTC6845;
    
  else generate
  
    signal tilemap_o        : to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    signal tilemap_i        : from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    signal graphics_o       : to_GRAPHICS_t;
    signal graphics_i       : from_GRAPHICS_t;
    
  begin
  
    graphics_inst : entity work.Graphics                                    
      port map
      (
        bitmap_ctl_i    => (others => NULL_TO_BITMAP_CTL),
        bitmap_ctl_o    => open,

        tilemap_ctl_i   => tilemap_o,
        tilemap_ctl_o   => tilemap_i,

        sprite_reg_i    => NULL_TO_SPRITE_REG,
        sprite_ctl_i    => NULL_TO_SPRITE_CTL,
        sprite_ctl_o    => open,
        spr0_hit				=> open,
        
        graphics_i      => graphics_o,
        graphics_o      => graphics_i,
        
        -- OSD
        to_osd          => NULL_TO_OSD,
        from_osd        => open,

        -- video (incl. clk)
        video_i					=> video_i,
        video_o					=> video_o
      );

    tilerom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/super80/roms/" &
                        SUPER80_VARIANT & ".u27.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address   => tilemap_i(1).tile_a(12 downto 0),
        q					=> tilemap_o(1).tile_d(7 downto 0)
      );

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    vram_inst : entity work.dpram
      generic map
      (
        init_file		=> "",
        --numwords_a	=> 1024,
        widthad_a		=> 16
      )
      port map
      (
        clock_b			            => clk_40M,
        address_b		            => cpu_a(15 downto 0),
        wren_b			            => vram_wr,
        data_b			            => cpu_d_o,
        q_b					            => vram_d_o,
    
        clock_a			            => clk_video,
        address_a(15 downto 9)  => video_page_r,
        address_a(8 downto 0)   => tilemap_i(1).map_a(8 downto 0),
        wren_a			            => '0',
        data_a			            => (others => 'X'),
        q_a					            => tilemap_o(1).map_d(7 downto 0)
      );
      tilemap_o(1).map_d(tilemap_o(1).map_d'left downto 8) <= (others => '0');
  
  end generate GEN_VIDEO;
  
  GEN_CHIPSPEED_COLOUR : if SUPER80_HAS_CHIPSPEED_COLOUR generate
  begin
--    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
--    cram_inst : entity work.dpram
--      generic map
--      (
--        init_file		=> "",
--        --numwords_a	=> 512,
--        widthad_a		=> 9
--      )
--      port map
--      (
--        clock_b			            => clk_40M,
--        address_b		            => cpu_a(8 downto 0),
--        wren_b			            => cram_wr,
--        data_b			            => cpu_d_o,
--        q_b					            => cram_d_o,
--    
--        clock_a			            => clk_video,
--        address_a(8 downto 0)   => tilemap_i(1).attr_a(8 downto 0),
--        wren_a			            => '0',
--        data_a			            => (others => 'X'),
--        q_a					            => tilemap_o(1).attr_d(7 downto 0)
--      );
--      tilemap_o(1).attr_d(tilemap_o(1).attr_d'left downto 8) <= (others => '0');
  end generate GEN_CHIPSPEED_COLOUR;
  
--  GEN_PCG80 : if (TRS80_M1_HAS_PCG80 or TRS80_M1_HAS_80GRAFIX) generate
--
--    signal pcg80_a        : std_logic_vector(11 downto 0) := (others => '0');
--    alias pcg80_bank      : std_logic_vector(11 downto 10) is pcg80_a(11 downto 10);
--    signal pcg80_r        : std_logic_vector(7 downto 0) := (others => '0');
--    signal pcg80_wr       : std_logic := '0';
--    
--  begin
--
--    -- PCG-80 register
--    process (clk_40M, cpu_reset)
--    begin
--      if cpu_reset = '1' then
--        pcg80_r <= (others => '0');
--      elsif rising_edge(clk_40M) then
--        -- latch on rising edge IO read cycle
--        if pcg80_cs = '1' and cpu_io_wr = '1' then
--          -- $20,$A0,$28,$A8 all have bit 5 set
--          if cpu_d_o(5) = '1' then
--            pcg80_r <= cpu_d_o;
--            -- set programming bank
--            if (TRS80_M1_HAS_PCG80 and cpu_d_o(7 downto 4) = X"6") or
--               (TRS80_M1_HAS_80GRAFIX and cpu_d_o = X"60") then
--              pcg80_bank <= cpu_d_o(1 downto 0);
--            end if;
--          end if;
--        end if;
--      end if;
--      -- the rest of the address
--      pcg80_a(9 downto 0) <= cpu_a(9 downto 0);
--    end process;
--    pcg80_wr <= vram_wr when pcg80_r(7 downto 4) = X"6" else '0';
--
--    graphics_o.bit8(0)(5) <= pcg80_r(7); -- enable $80-$FF
--    graphics_o.bit8(0)(4) <= pcg80_r(3); -- enable $00-$7F
--
--    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
--    pcg80_inst : entity work.dpram
--      generic map
--      (
--        widthad_a		=> 12
--      )
--      port map
--      (
--        clock_b			=> clk_40M,
--        address_b		=> pcg80_a,
--        wren_b			=> pcg80_wr,
--        data_b			=> cpu_d_o,
--        q_b					=> pcg80_d_o,
--    
--        -- data fed back via 'attribute' port
--        clock_a			=> clk_video,
--        address_a		=> tilemap_i(1).attr_a(11 downto 0),
--        wren_a			=> '0',
--        data_a			=> (others => 'X'),
--        q_a					=> tilemap_o(1).attr_d(7 downto 0)
--      );
--    tilemap_o(1).attr_d(tilemap_o(1).attr_d'left downto 8) <= (others => '0');
--    
--  else generate
--
--    pcg80_d_o <= (others => '0');
--    --tilemap_o(1).attr_d <= (others => '0');
--    
--  end generate GEN_PCG80;
--
--  GEN_LE18 : if TRS80_M1_HAS_LE18 generate
--    signal le18_ram_a   : std_logic_vector(13 downto 0) := (others => '0');
--    signal le18_ram_wr  : std_logic := '0';
--    signal le18_ram_i   : std_logic_vector(5 downto 0) := (others => '0');
--    signal le18_ram_o   : std_logic_vector(5 downto 0) := (others => '0');
--    --
--    signal le18_x       : std_logic_vector(5 downto 0) := (others => '0');
--    signal le18_y       : std_logic_vector(7 downto 0) := (others => '0');
--    signal le18_en      : std_logic := '0';
--  begin
--  
--    process (clk_40M, cpu_reset)
--    begin
--      if cpu_reset = '1' then
--        le18_ram_wr <= '0';
--        le18_x <= (others => '0');
--        le18_y <= (others => '0');
--        le18_en <= '0';
--      elsif rising_edge(clk_40M) then
--        le18_ram_wr <= '0'; -- default
--        -- write to graphics registers
--        if le18_cs = '1' then
--          if cpu_io_wr = '1' then
--            case cpu_io_a(1 downto 0) is
--              when "00" =>
--                le18_ram_i <= cpu_d_o(le18_ram_i'range);
--                le18_ram_wr <= '1';
--              when "01" =>
--                le18_x <= cpu_d_o(le18_x'range);
--              when "10" =>
--                le18_y <= cpu_d_o;
--              when others =>
--                le18_en <= cpu_d_o(0);
--            end case;
--          elsif cpu_io_rd = '1' then
--            case cpu_io_a(1 downto 0) is
--              when "00" =>
--                -- bit7 should be '1' during blanking
--                le18_d_o <= '1' & le18_en & le18_ram_o(5 downto 0);
--              when "01" =>
--                le18_d_o <= "00" & le18_x;
--              when "10" =>
--                le18_d_o <= le18_y;
--              when others =>
--                le18_d_o <= "0000000" & le18_en;
--            end case;
--          end if; -- cpu_io_wr/rd=1
--        end if; -- le18_cs=1
--      end if;
--    end process;
--
--    -- construct RAM address
--    le18_ram_a <= le18_y & le18_x;
--    
--    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
--    le18_ram_inst : entity work.dpram
--      generic map
--      (
--        widthad_a		=> TRS80_M1_LE18_WIDTHAD,
--        width_a     => 6
--      )
--      port map
--      (
--        clock_b			=> clk_40M,
--        address_b		=> le18_ram_a(TRS80_M1_LE18_WIDTHAD-1 downto 0),
--        wren_b			=> le18_ram_wr,
--        data_b			=> le18_ram_i,
--        q_b					=> le18_ram_o,
--    
--        clock_a			=> clk_video,
--        address_a		=> bitmap_i(1).a(TRS80_M1_LE18_WIDTHAD-1 downto 0),
--        wren_a			=> '0',
--        data_a			=> (others => 'X'),
--        q_a					=> bitmap_o(1).d(5 downto 0)
--      );
--    bitmap_o(1).d(7 downto 6) <= (others => '0');
--
--    graphics_o.bit8(0)(6) <= le18_en;
--
--  else generate
--    
--    le18_d_o <= X"FF";
--    bitmap_o(1).d <= (others => '0');
--    
--  end generate GEN_LE18;
--    
--  GEN_LNW80_VIDEO : if TRS80_M1_IS_LNW80 generate
--  begin
--    process (clk_40M, cpu_reset)
--    begin
--      if cpu_reset = '1' then
--        lnw80_video_ctl_r <= (others => '0');
--      elsif rising_edge(clk_40M) then
--        if cpu_io_wr = '1' then
--          -- port 254 controls LNW video
--          if lnw80_video_ctl_cs = '1' then
--            lnw80_video_ctl_r <= cpu_d_o;
--          end if;
--        end if; -- cpu_io_wr
--      end if; -- rising_edge(clk_40M)
--    end process;
--
--    graphics_o.bit8(1) <= lnw80_video_ctl_r;
--    
--    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
--    lnw80_hires_ram_inst : entity work.dpram
--      generic map
--      (
--        widthad_a		=> TRS80_M1_LNW80_HIRES_WIDTHAD,
--        width_a     => 8
--      )
--      port map
--      (
--        clock_b			=> clk_40M,
--        address_b		=> cpu_a(TRS80_M1_LNW80_HIRES_WIDTHAD-1 downto 0),
--        wren_b			=> lnw80_hires_ram_wr,
--        data_b			=> cpu_d_o,
--        q_b					=> lnw80_hires_ram_d_o,
--    
--        clock_a			=> clk_video,
--        address_a		=> bitmap_i(2).a(TRS80_M1_LNW80_HIRES_WIDTHAD-1 downto 0),
--        wren_a			=> '0',
--        data_a			=> (others => 'X'),
--        q_a					=> bitmap_o(2).d(7 downto 0)
--      );
--
--  else generate
--
--    lnw80_video_ctl_r <= (others => '0');
--    bitmap_o(2).d <= (others => '0');
--    
--  end generate GEN_LNW80_VIDEO;
  
--  GEN_MIKROKOLOR : if TRS80_M1_HAS_MIKROKOLOR generate
--    component vdp is
--      port
--      (
--        clk40m      : in std_logic;
--        clk40m_n    : in std_logic;
--        cpu_rst_n   : in std_logic;
--        cpu_a       : in std_logic_vector(7 downto 0);
--        cpu_din     : in std_logic_vector(7 downto 0);
--        cpu_dout    : out std_logic_vector(7 downto 0);
--        cpu_doe     : out std_logic;
--        cpu_in_n    : in std_logic;
--        cpu_out_n   : in std_logic;
--        cpu_int_n   : out std_logic;
--        sram_a      : out std_logic_vector(18 downto 0);
--        sram_din    : in std_logic_vector(7 downto 0);
--        sram_dout   : out std_logic_vector(7 downto 0);
--        sram_doe    : out std_logic;
--        sram_oe_n   : out std_logic;
--        sram_we_n   : out std_logic;
--        hsync       : out std_logic;
--        vsync       : out std_logic;
--        r           : out std_logic_vector(3 downto 0);
--        g           : out std_logic_vector(3 downto 0);
--        b           : out std_logic_vector(3 downto 0)
--      );
--    end component vdp;
--
--    signal vdp_int_n    : std_logic;
--    
--    signal vdp_ram_a    : std_logic_vector(18 downto 0);
--    signal vdp_ram_d_i  : std_logic_vector(7 downto 0);
--    signal vdp_ram_d_o  : std_logic_vector(7 downto 0);
--    signal vdp_ram_we_n : std_logic;
--
--    signal r            : std_logic_vector(3 downto 0);
--    signal g            : std_logic_vector(3 downto 0);
--    signal b            : std_logic_vector(3 downto 0);
--    
--  begin
--
--    vdp_inst : vdp
--      port map
--      (
--        clk40m      => clk_40M,
--        clk40m_n    => not clk_40M,
--        cpu_rst_n   => not clkrst_i.rst(0),
--        cpu_a       => cpu_a(7 downto 0),
--        cpu_din     => cpu_d_o,
--        cpu_dout    => vdp_d_o,
--        cpu_doe     => open,
--        cpu_in_n    => not cpu_io_rd,
--        cpu_out_n   => not cpu_io_wr,
--        cpu_int_n   => vdp_int_n,
--        sram_a      => vdp_ram_a,
--        sram_din    => vdp_ram_d_i,
--        sram_dout   => vdp_ram_d_o,
--        sram_doe    => open,
--        sram_oe_n   => open,
--        sram_we_n   => vdp_ram_we_n,
--        hsync       => graphics_o.hsync,
--        vsync       => graphics_o.vsync,
--        r           => r,
--        g           => g,
--        b           => b
--      );
--      
--    graphics_o.rgb.r <= "0000" & not r(3 downto 0) & "00";
--    graphics_o.rgb.g <= "0000" & not g(3 downto 0) & "00";
--    graphics_o.rgb.b <= "0000" & not b(3 downto 0) & "00";
--      
--    vdp_ram_inst : entity work.spram
--      generic map
--      (
--        widthad_a	  => 14
--      )
--      port map
--      (
--        clock		    => clk_40M,
--        address		  => vdp_ram_a(13 downto 0),
--        data		    => vdp_ram_d_i,
--        wren		    => not vdp_ram_we_n,
--        q		        => vdp_ram_d_o
--      );
--
--  end generate GEN_MIKROKOLOR;
  
--  GEN_FDC : if TRS80_M1_FDC_SUPPORT generate
--  
--    component wd179x is
--      port
--      (
--        clk           : in std_logic;
--        clk_20M_ena   : in std_logic;
--        reset         : in std_logic;
--        
--        -- micro bus interface
--        mr_n          : in std_logic;
--        we_n          : in std_logic;
--        cs_n          : in std_logic;
--        re_n          : in std_logic;
--        a             : in std_logic_vector(1 downto 0);
--        dal_i         : in std_logic_vector(7 downto 0);
--        dal_o         : out std_logic_vector(7 downto 0);
--        clk_1mhz_en   : in std_logic;
--        drq           : out std_logic;
--        intrq         : out std_logic;
--        
--        -- drive interface
--        step          : out std_logic;
--        dirc          : out std_logic; -- 1=in, 0=out
--        early         : out std_logic;
--        late          : out std_logic;
--        test_n        : in std_logic;
--        hlt           : in std_logic;
--        rg            : out std_logic;
--        sso           : out std_logic;
--        rclk          : in std_logic;
--        raw_read_n    : in std_logic;
--        hld           : out std_logic;
--        tg43          : out std_Logic;
--        wg            : out std_logic;
--        wd            : out std_logic;
--        ready         : in std_logic;
--        wf_n_i        : in std_logic;
--        vfoe_n_o      : out std_logic;
--        tr00_n        : in std_logic;
--        ip_n          : in std_logic;
--        wprt_n        : in std_logic;
--        dden_n        : in std_logic;
--
--        -- temp fudge!!!
--        wr_dat_o			: out std_logic_vector(7 downto 0);
--        
--        debug         : out std_logic_vector(31 downto 0)
--      );
--    end component wd179x;
--    
--    signal clk_20M_ena  : std_logic;
--    
--    signal raw_read_n   : std_logic;
--    signal step         : std_logic;
--    signal dirc         : std_logic;
--    signal wg           : std_logic;
--    signal wd           : std_logic;
--    signal tr00_n       : std_logic;
--    signal ip_n         : std_logic;
--    signal wprt_n       : std_logic;
--    signal rclk         : std_logic;
--    
--  begin
--
--    process (clk_40M, clkrst_i.rst(0))
--    begin
--      if clkrst_i.rst(0) = '1' then
--        clk_20M_ena <= '0';
--      elsif rising_edge(clk_40M) then
--        clk_20M_ena <= not clk_20M_ena;
--      end if;
--    end process;
--    
--    -- inverted for 179X???
--    raw_read_n <= target_i.read_data_n;
--    tr00_n <= target_i.track_zero_n;
--    ip_n <= target_i.index_pulse_n;
--    wprt_n <= target_i.write_protect_n;
--    rclk <= target_i.rclk;
--    
--    target_o.step_n <= not step;
--    target_o.direction_select_n <= not dirc;
--    target_o.write_gate_n <= not wg;
--    target_o.write_data_n <= not wd;
--
--    wd179x_inst : wd179x
--      port map
--      (
--        clk           => clk_40M,
--        clk_20M_ena   => '1',
--        reset         => clkrst_i.rst(0),
--        
--        -- micro bus interface
--        mr_n          => '1',
--        we_n          => not cpu_mem_wr,
--        cs_n          => not fdc_cs,
--        re_n          => not cpu_mem_rd,
--        a             => cpu_a(1 downto 0),
--        dal_i         => cpu_d_o,
--        dal_o         => fdc_d_o,
--        clk_1mhz_en   => '1',
--        drq           => open,    -- NC on M1
--        intrq         => fdc_drq_int,
--        
--        -- drive interface
--        step          => step,
--        dirc          => dirc,
--        early         => open,    -- not used atm
--        late          => open,    -- not used atm
--        test_n        => '1',     -- not used
--        hlt           => '1',     -- head always engaged atm
--        rg            => open,    -- 179X only?
--        sso           => open,
--        rclk          => rclk,
--        raw_read_n    => raw_read_n,
--        hld           => open,    -- not used atm
--        tg43          => open,    -- not used on TRS-80 designs
--        wg            => wg,
--        wd            => wd,      -- 200ns (MFM) or 500ns (FM) pulse
--        ready         => '1',     -- always read atm
--        wf_n_i        => '1',     -- no write faults atm
--        vfoe_n_o      => open,    -- not used in TRS-80 designs?
--        tr00_n        => tr00_n,
--        ip_n          => ip_n,
--        wprt_n        => wprt_n,
--        dden_n        => '0',     -- double density only atm
--        
--        -- 1771-only signals
----        ph3           => '1',     -- NC on M1
----        3pm_n         => '1',     -- tied high on M1
----        xtds_n        => '1',     -- tied high on M1
----        dint_n        => '1',     -- tied high on M1
--        
--        wr_dat_o      => open,
--
--        debug         => open
--      );
--      
--  else generate
--
--    fdc_d_o <= X"FF";
--    fdc_drq_int <= '0';
--    leds_o <= (others => '0');
--        
--  end generate GEN_FDC;

--  GEN_HDD : if TRS80_M1_HAS_HDD generate
--
--    signal wb_cyc_stb   : std_logic := '0';
--    signal wb_sel       : std_logic_vector(3 downto 0) := (others => '0');
--    signal wb_adr       : std_logic_vector(6 downto 2) := (others => '0');
--    signal wb_dat_i     : std_logic_vector(31 downto 0) := (others => '0');
--    signal wb_dat_o     : std_logic_vector(31 downto 0) := (others => '0');
--    signal wb_we        : std_logic := '0';
--    signal wb_ack       : std_logic := '0';
--    
--    type state_t is ( S_IDLE, S_I1, S_R1, S_W1 );
--    signal state : state_t := S_IDLE;
--
--    signal hdci_cntl    : std_logic_vector(7 downto 0) := (others => '0');
--    alias hdci_enable   : std_logic is hdci_cntl(3);
--    signal hdd_irq      : std_logic;
--
--    signal a_cf_us      : ieee.std_logic_arith.unsigned(2 downto 0) := (others => '0');
--    signal nior0_cf_s   : std_logic := '0';
--    signal niow0_cf_s   : std_logic := '0';
--    signal ide_d_r      : std_logic_vector(31 downto 0) := (others => '0');
--    
--  begin
--
--    platform_o.clk_50M <= clkrst_i.clk_ref;
--    platform_o.clk_25M <= clkrst_i.clk(1);    -- maybe
--    
--    -- to the HDD core
--    platform_o.clk <= clk_40M;
--    platform_o.rst <= cpu_reset;
--    platform_o.arst_n <= clkrst_i.arst_n;
--
--    -- IDE registers
--    --
--    --  $C0-C2  - original RS registers
--    --  $C3     - upper-byte data latch
--    --  $C8-CF  - write-thru to IDE device
--    --
--    
--    hdd_cs <= (cpu_io_rd or cpu_io_wr) 
--                when STD_MATCH(cpu_a(7 downto 0), X"C"&"----") 
--                else '0';
--    
--    process (clk_40M, cpu_reset)
--      variable cpu_io_r : std_logic := '0';
--    begin
--      if cpu_reset = '1' then
--        hdci_cntl <= (others => '0');
--        wb_cyc_stb <= '0';
--        wb_we <= '0';
--        state <= S_I1;
--      elsif rising_edge(clk_40M) then
--        case state is
--          when S_I1 =>
--            -- initialise the OCIDE core
--            wb_cyc_stb <= '1';
--            wb_adr <= "00000";
--            wb_dat_i <= X"00000082";   -- enable IDE, IORDY timing
--            wb_we <= '1';
--            state <= S_W1;
--          when S_IDLE =>
--            wb_cyc_stb <= '0'; -- default
--            -- start a new cycle on rising_edge IORD
--            if cpu_io_r = '0' and (cpu_io_rd or cpu_io_wr) = '1' then
--              if hdd_cs = '1' then
--                case cpu_a(3 downto 0) is
--                  when X"0" =>    -- hdci_wp
--                  when X"1" =>    -- hdci_cntl
--                    hdci_cntl <= cpu_d_o;
--                  when X"2" =>    -- hdci_present
--                  when X"3" =>    -- high-byte latch
--                    if cpu_io_rd = '1' then
--                      -- read latch from previous access
--                      hdd_d <= ide_d_r(15 downto 8);
--                    elsif cpu_io_wr = '1' then
--                      -- latch write data for subsequent access
--                      ide_d_r(15 downto 8) <= cpu_d_o;
--                    end if;
--                  when others =>
--                    -- IDE device registers @$08-$0F
--                    if cpu_a(3) = '1' then
--                      -- start a new access to the OCIDEC
--                      wb_cyc_stb <= hdd_cs;
--                      -- $08-$0F => $10-$17 (ATA registers)
--                      wb_adr <= "10" & cpu_a(2 downto 0);
--                      wb_dat_i(31 downto 8) <= X"0000" & ide_d_r(15 downto 8);
--                      -- Peter Bartlett's drivers require this
--                      -- because IDE sectors start at 1, not 0
--                      if cpu_a(3 downto 0) = X"B" then
--                        wb_dat_i(7 downto 0) <= std_logic_vector(unsigned(cpu_d_o) + 1);
--                      else
--                        wb_dat_i(7 downto 0) <= cpu_d_o;
--                      end if;
--                      wb_we <= cpu_io_wr;
--                      if cpu_io_rd = '1' then
--                        state <= S_R1;
--                      else
--                        state <= S_W1;
--                      end if;
--                    end if; -- $08-$0F (device register)
--                end case;
--              end if; -- ide_cs = '1'
--            end if;
--          when S_R1 =>
--            if wb_ack = '1' then
--              -- latch the whole data bus from the core
--              ide_d_r <= wb_dat_o;
--              -- Peter Bartlett's drivers require this
--              -- because IDE sectors start at 1, not 0
--              if cpu_a(3 downto 0) = X"B" then
--                hdd_d <= std_logic_vector(unsigned(wb_dat_o(hdd_d'range)) - 1);
--              else
--                hdd_d <= wb_dat_o(hdd_d'range);
--              end if;
--              wb_cyc_stb <= '0';
--              state <= S_IDLE;
--            end if;
--          when S_W1 =>
--            if wb_ack = '1' then
--              wb_cyc_stb <= '0';
--              state <= S_IDLE;
--            end if;
--          when others =>
--            wb_cyc_stb <= '0';
--            state <= S_IDLE;
--        end case;
--        cpu_io_r := cpu_io_rd or cpu_io_wr;
--      end if;
--    end process;
--      
--    -- 16-bit access to PIO registers, otherwise 32
--    wb_sel <= "0011" when wb_adr(6) = '1' else "1111";
--    
--    -- PIO mode timings
--    --          0,   1,   2,   3,   4,   5,   6
--    -- t1   -  70,  50,  30,  30,  25,  15,  10
--    -- t2   - 165, 125, 100,  80,  70,  65,  55
--    -- t4   -  30,  20,  15,  10,  10,   5,   5
--    -- teoc - 365, 208, 110,  70,  25,  25,  20
--    --
--    -- n = max(0, round_up((t * clk) - 2))
--    --
--    atahost_inst : entity work.atahost_top
--      generic map
--      (
--        --TWIDTH          => 5,
--        -- PIO mode0 100MHz = 6, 28, 2, 23
--        -- PIO mode0 57M272 = 4, 16, 1, 13
--        -- PIO mode0 40MHz => 1, 5, 0, 13
--        -- PIO mode3 40MHz => 0, 2, 0, 1
--        PIO_mode0_T1    => 1,
--        PIO_mode0_T2    => 5,
--        PIO_mode0_T4    => 0,
--        PIO_mode0_Teoc  => 13
--      )
--      port map
--      (
--        -- WISHBONE SYSCON signals
--        wb_clk_i      => clk_40M,
--        arst_i        => clkrst_i.arst_n,
--        wb_rst_i      => cpu_reset,
--
--        -- WISHBONE SLAVE signals
--        wb_cyc_i      => wb_cyc_stb,
--        wb_stb_i      => wb_cyc_stb,
--        wb_ack_o      => wb_ack,
--        wb_err_o      => open,
--        wb_adr_i      => ieee.std_logic_arith.unsigned(wb_adr),
--        wb_dat_i      => wb_dat_i,
--        wb_dat_o      => wb_dat_o,
--        wb_sel_i      => wb_sel,
--        wb_we_i       => wb_we,
--        wb_inta_o     => open,
--
--        -- ATA signals
--        resetn_pad_o  => platform_o.nreset_cf,
--        dd_pad_i      => platform_i.dd_i,
--        dd_pad_o      => platform_o.dd_o,
--        dd_padoe_o    => platform_o.dd_oe,
--        da_pad_o      => a_cf_us,
--        cs0n_pad_o    => platform_o.nce_cf(1),
--        cs1n_pad_o    => platform_o.nce_cf(2),
--
--        diorn_pad_o	  => nior0_cf_s,
--        diown_pad_o	  => niow0_cf_s,
--        iordy_pad_i	  => platform_i.iordy0_cf,
--        intrq_pad_i	  => platform_i.rdy_irq_cf
--      );
--
--    platform_o.a_cf <= std_logic_vector(a_cf_us);
--    platform_o.nior0_cf <= nior0_cf_s;
--    platform_o.niow0_cf <= niow0_cf_s;
--    
--    -- DMA mode not supported
--    platform_o.ndmack_cf <= 'Z';
--
--    -- detect
--    --<= platform_i.cd_cf;
--    
--    -- power
--    platform_o.non_cf <= '0';
--
--    BLK_ACTIVITY : block
--      signal ide_act : std_logic := '0';
--    begin
--      -- activity LED(s)
--      process (clk_40M, cpu_reset)
--        -- 40MHz for 1/10th sec
--        subtype count_t is integer range 0 to 40000000/10-1;
--        variable count : count_t := 0;
--      begin
--        if cpu_reset = '1' then
--          ide_act <= '0';
--          count := 0;
--        elsif rising_edge(clk_40M) then
--          if nior0_cf_s = '0' or niow0_cf_s = '0' then
--            ide_act <= '1';
--            count := count_t'high;
--          elsif count = 0 then
--            ide_act <= '0';
--          else
--            count := count - 1;
--          end if;
--        end if;
--      end process;
--      leds_o(4) <= ide_act;
--    end block BLK_ACTIVITY;
--    
--  end generate GEN_HDD;

  leds_o(leds_o'left downto 5) <= (others => '0');
  -- reserved for floppy drives 0-4
  leds_o(3 downto 0) <= (others => '0');

end architecture SYN;
