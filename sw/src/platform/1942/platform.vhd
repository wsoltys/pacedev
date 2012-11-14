library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;

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
	alias clk_vid         : std_logic is clkrst_i.clk(1);
	alias rst_sys         : std_logic is clkrst_i.rst(0);
  alias rst_vid         : std_logic is clkrst_i.rst(1);
  
  -- main cpu signals
  signal main_en        : std_logic;
  signal main_a         : std_logic_vector(15 downto 0);
  signal main_d_i       : std_logic_vector(7 downto 0);
  signal main_d_o       : std_logic_vector(7 downto 0);
  signal main_memrd     : std_logic;
  signal main_memwr     : std_logic;
  signal main_iord      : std_logic;
  signal main_iowr      : std_logic;
  signal main_intreq    : std_logic;
  signal main_intvec    : std_logic_vector(7 downto 0);
  signal main_intack    : std_logic;
  signal main_nmi       : std_logic;

  -- sub cpu signals
  signal sub_rst        : std_logic;
  signal sub_en         : std_logic;
  signal sub_a          : std_logic_vector(15 downto 0);
  signal sub_d_i        : std_logic_vector(7 downto 0);
  signal sub_d_o        : std_logic_vector(7 downto 0);
  signal sub_memrd      : std_logic;
  signal sub_memwr      : std_logic;
  signal sub_iord       : std_logic;
  signal sub_iowr       : std_logic;
  signal sub_intreq     : std_logic;
  signal sub_intvec     : std_logic_vector(7 downto 0);
  signal sub_intack     : std_logic;
  signal sub_nmi        : std_logic;
  signal sub_intena     : std_logic;
  signal sub_int        : std_logic;

  -- muxed cpu signals
  signal cpu_a          : std_logic_vector(15 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_memrd      : std_logic;
  signal cpu_memwr      : std_logic;
  signal cpu_iord       : std_logic;
  signal cpu_iowr       : std_logic;
  
  -- muxed data signals
  signal mem_d_o        : std_logic_vector(7 downto 0);
  signal io_d_o         : std_logic_vector(7 downto 0);
  
  -- ROM signals        
  signal mainrom_cs     : std_logic;
  signal mainrom_d_o    : std_logic_vector(7 downto 0);
  signal subrom_cs      : std_logic;
  signal subrom_d_o     : std_logic_vector(7 downto 0);

  -- VRAM signals (names from MAME driver)
  
  -- latches
  signal inputs_cs      : std_logic;
  signal inputs_d_o     : std_logic_vector(7 downto 0);
  signal scroll_cs      : std_logic;
  
  -- foreground attribute ram
  signal vram_cs        : std_logic;
  signal vram_we        : std_logic;
  signal vram_d_o       : std_logic_vector(7 downto 0);
  -- background attribute ram
  signal cram_cs        : std_logic;
  signal cram_we        : std_logic;
  signal cram_d_o       : std_logic_vector(7 downto 0);
  -- foreground tilecode ram
  signal bgram_t_cs     : std_logic;
  signal bgram_t_we     : std_logic;
  signal bgram_t_d_o    : std_logic_vector(7 downto 0);
  -- background tilecode ram
  signal bgram_a_cs     : std_logic;
  signal bgram_a_we     : std_logic;
  signal bgram_a_d_o    : std_logic_vector(7 downto 0);
                        
  -- RAM signals
  
  signal wram_cs        : std_logic;
  signal wram_we        : std_logic;
  signal wram_d_o       : std_logic_vector(7 downto 0);
  
	-- IO signals
	alias game_reset			: std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(0);
	alias osd_toggle      : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(1);
  alias game_pause      : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(2);
  
  -- other signals      
	signal cpu_reset			: std_logic;
	
  signal cnt_sys  : std_logic_vector(3 downto 0) := (others => '0');
  alias cpu_sel   : std_logic_vector(1 downto 0) is cnt_sys(3 downto 2);
  alias cpu_cyc   : std_logic_vector(1 downto 0) is cnt_sys(1 downto 0);
  constant MAIN_CPU : std_logic_vector(cpu_sel'range) := "00";
  constant SUB_CPU  : std_logic_vector(cpu_sel'range) := "01";

  -- purely for debugging (comment-out CPUs)
  signal clk_cpu    : std_logic;
  
begin

  -- for debugging
  clk_cpu <= clk_sys;  
  cpu_reset <= rst_sys or game_reset;
	
  -- clocking
  -- system clock: 64MHz
  -- cpu clocks = 4MHz
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      main_en <= '0';
      sub_en <= '0';
      cnt_sys <= (others => '0');
    elsif rising_edge(clk_sys) then
      main_en <= '0';   -- default
      sub_en <= '0';    -- default
      if cpu_cyc = "00" then
        case cpu_sel is
          when MAIN_CPU =>
            main_en <= '1' and not game_pause;
            cpu_a <= main_a;
            cpu_d_o <= main_d_o;
            cpu_memrd <= main_memrd;
            cpu_memwr <= main_memwr;
            cpu_iord <= main_iord;
            cpu_iowr <= main_iowr;
          when SUB_CPU =>
            sub_en <= '1' and not game_pause;
            cpu_a <= sub_a;
            cpu_d_o <= sub_d_o;
            cpu_memrd <= sub_memrd;
            cpu_memwr <= sub_memwr;
            cpu_iord <= sub_iord;
            cpu_iowr <= sub_iowr;
          when others =>
        end case;
      end if;
      cnt_sys <= std_logic_vector(unsigned(cnt_sys) + 1);
    end if;
  end process;

	-- chip selects
	-- MAINROM $0000-$BFFF
	mainrom_cs      <= '0' when STD_MATCH(main_a, "11--------------") else '1';
	-- SUBROM $0000-$1FFF
	subrom_cs       <= '1' when STD_MATCH(sub_a,  "000-------------") else '0';
  -- INPUTS $C000-$C004
  inputs_cs       <= '1' when STD_MATCH(cpu_a,       X"C00"&"0---") else '0';
  -- SCROLL $C802-$C803
  scroll_cs       <= '1' when STD_MATCH(cpu_a,       X"C80"&"001-") else '0';
  -- VRAM $D000-$D3FF (foreground tile code)
  vram_cs         <= '1' when STD_MATCH(cpu_a, X"D"&"00----------") else '0';
  -- CRAM $D400-$D7FF (background attribute)
  cram_cs         <= '1' when STD_MATCH(cpu_a, X"D"&"01----------") else '0';
  -- BGRAM_T $D800-$DBFF (background tile code)
  bgram_t_cs      <= '1' when STD_MATCH(cpu_a, X"D"&"10-----0----") else '0';
  -- BGRAM_A $D800-$DBFF (background attr)
  bgram_a_cs      <= '1' when STD_MATCH(cpu_a, X"D"&"10-----1----") else '0';
	-- WRAM1 $E000-$EFFF
	wram_cs         <= '1' when STD_MATCH(cpu_a, X"E"&"------------") else '0';
  
  -- write-enables, pulse for 1 clock only
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      vram_we <= '0';
      cram_we <= '0';
      bgram_t_we <= '0';
      bgram_a_we <= '0';
      wram_we <= '0';
    elsif rising_edge(clk_sys) then
      vram_we <= '0';
      cram_we <= '0';
      bgram_t_we <= '0';
      bgram_a_we <= '0';
      wram_we <= '0';
      if cpu_cyc = "10" and cpu_memwr = '1' then
        vram_we <= vram_cs;
        cram_we <= cram_cs;
        bgram_t_we <= bgram_t_cs;
        bgram_a_we <= bgram_a_cs;
        wram_we <= wram_cs;
      end if;
    end if;
  end process;

  -- muxed data signals
  mem_d_o <=  inputs_d_o when inputs_cs = '1' else
              vram_d_o when vram_cs = '1' else
              cram_d_o when cram_cs = '1' else
              bgram_t_d_o when bgram_t_cs = '1' else
              bgram_a_d_o when bgram_a_cs = '1' else
              wram_d_o when wram_cs = '1' else
              X"FF";
              
  io_d_o <= X"FF";

  GEN_MAIN_CPU : if true generate
  begin
    main_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_cpu,
        clk_en	=> main_en,
        reset  	=> cpu_reset,                                     

        addr   	=> main_a,
        datai  	=> main_d_i,
        datao  	=> main_d_o,

        mem_rd 	=> main_memrd,
        mem_wr 	=> main_memwr,
        io_rd  	=> main_iord,
        io_wr  	=> main_iowr,

        intreq 	=> main_intreq,
        intvec 	=> main_intvec,
        intack 	=> main_intack,
        nmi    	=> main_nmi
      );

    BLK_MAINROM : block
      type d_a is array (natural range <>) of std_logic_vector(7 downto 0);
      signal srb_d_o          : d_a(CAPCOM_ROM'range);
      signal mainrom_bank_r   : std_logic_vector(1 downto 0);
    begin

      process (clk_sys, rst_sys)
      begin
        if rst_sys = '1' then
          mainrom_bank_r <= (others => '0');
        elsif rising_edge(clk_sys) then
          if cpu_sel = MAIN_CPU and cpu_cyc = "11" then
            if STD_MATCH(cpu_a, X"C806") and cpu_memwr = '1' then
              mainrom_bank_r <= cpu_d_o(mainrom_bank_r'range);
            end if;
          end if;
        end if;
      end process;
      
      -- $0000-$3FFF, $4000-$7FFF, $8000-$8FFF (banked)
      mainrom_d_o <=  srb_d_o(0) when STD_MATCH(main_a, "00--------------") else
                      srb_d_o(1) when STD_MATCH(main_a, "01--------------") else
                      srb_d_o(2) when (STD_MATCH(main_a, "10--------------") and 
                        mainrom_bank_r = "00") else
                      srb_d_o(3) when (STD_MATCH(main_a, "10--------------") and 
                        mainrom_bank_r = "01") else
                      srb_d_o(4);
                      
      GEN_MAINROM : for i in CAPCOM_ROM'range generate
      begin
        main_rom_inst : entity work.sprom
          generic map
          (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          CAPCOM_ROM(i) & ".hex",
            widthad_a		=> CAPCOM_ROM_WIDTHAD
          )
          port map
          (
            clock		=> clk_sys,
            address => main_a(13 downto 0),
            q				=> srb_d_o(i)
          );
      end generate GEN_MAINROM;
      
    end block BLK_MAINROM;
    
    -- data latch
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        null;
      elsif rising_edge(clk_sys) then
        if cpu_sel = MAIN_CPU and cpu_cyc = "11" then
          -- latch read data for next clock
          if main_memrd = '1' then
            if mainrom_cs = '1' then
              -- patch out ROM tests for now
              case main_a is
--                -- 20 15 (jr nz,$278)
--                when X"0261" | X"0262" =>
--                  main_d_i <= X"00";  -- NOP
                when others =>
                  main_d_i <= mainrom_d_o;
              end case;
            else
              main_d_i <= mem_d_o;
            end if;
          elsif main_iord = '1' then
            main_d_i <= io_d_o;
          end if;
        end if;
      end if;
    end process;
    
    -- generate interrupts
    -- - scanlines 0 and 240
    process (clk_sys, rst_sys)
      subtype count_t is integer range 0 to 255;
      type count_a is array (natural range <>) of count_t;
      variable count_r : count_a(4 downto 0);
      alias count_prev  : count_t is count_r(count_r'left);
      alias count_um    : count_t is count_r(count_r'left-1);
    begin
      if rst_sys = '1' then
        count_r := (others => 0);
        main_intvec <= (others => '0');
        main_intreq <= '0';
        main_nmi <= '0';
      elsif rising_edge(clk_sys) then
        -- handle ACK
        if main_intack = '1' then
          main_intreq <= '0';
        end if;
        -- generate interrupt (priority)
        if count_prev /= count_um then
          case count_um is
            when 0 =>
              -- RST8
              main_intvec <= X"CF";
              main_intreq <= '1';
            when 240 =>
              -- RST10
              main_intvec <= X"D7";
              main_intreq <= '1';
            when others =>
              null;
          end case;
        end if; -- count_prev /= count_um
        -- unmeta the video counter
        count_r(count_r'left-1 downto 1) := count_r(count_r'left-2 downto 0);
        count_r(0) := to_integer(unsigned(graphics_i.y(7 downto 0)));
      end if;
    end process;
    
  end generate GEN_MAIN_CPU;
  
  GEN_AUDIO_CPU : if CAPCOM_1942_HAS_AUDIO_CPU generate
  begin
    sub_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_cpu,                                   
        clk_en	=> sub_en,
        reset  	=> sub_rst,                                     

        addr   	=> sub_a,
        datai  	=> sub_d_i,
        datao  	=> sub_d_o,

        mem_rd 	=> sub_memrd,
        mem_wr 	=> sub_memwr,
        io_rd  	=> sub_iord,
        io_wr  	=> sub_iowr,

        intreq 	=> sub_int,
        intvec 	=> sub_intvec,
        intack 	=> sub_intack,
        nmi    	=> sub_nmi
      );

    sub_int <= sub_intreq and sub_intena;
    sub_intvec <= (others => '0');
    sub_nmi <= '0';
    
    sub_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" & 
                        "sub.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock		=> clk_sys,
        address => sub_a(12 downto 0),
        q				=> subrom_d_o
      );

    -- data latch
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        null;
      elsif rising_edge(clk_sys) then
        if cpu_sel = SUB_CPU and cpu_cyc = "11" then
          -- latch read data for next clock
          if sub_memrd = '1' then
            if subrom_cs = '1' then
              sub_d_i <= subrom_d_o;
            else
              sub_d_i <= mem_d_o;
            end if;
          elsif sub_iord = '1' then
            sub_d_i <= io_d_o;
          end if;
        end if;
      end if;
    end process;

  else generate
    sub_memrd <= '0';
    sub_memwr <= '0';
    sub_iord <= '0';
    sub_iowr <= '0';
  end generate GEN_AUDIO_CPU;

  -- dipswitches and inputs
  process (clk_sys, rst_sys)
    variable i  : integer range 0 to 7;
  begin
    if rst_sys = '1' then
      null;
    elsif rising_edge(clk_sys) then
      case cpu_a(3 downto 0) is
        when X"0" =>
          inputs_d_o <= inputs_i(0).d;
        when X"1" =>
          inputs_d_o <= inputs_i(1).d;
        when X"2" =>
          inputs_d_o <= inputs_i(2).d;
        when X"3" =>
          -- DSWA: 3 lives, 20K/80K/80K+, Upright, 1C1C
          inputs_d_o <= X"C0" or X"30" or X"00" or X"07";
        when X"4" =>
          -- DSWB: screen stop off, easy, flip screen off, service off, 1C1C
          inputs_d_o <= X"80" or X"40" or X"10" or X"08" or X"07";
        when others =>
          null;
      end case;
    end if;
  end process;
  
  -- video hardware latches
  process (clk_sys, rst_sys)
    variable scroll : std_logic_vector(15 downto 0);
  begin
    if rst_sys = '1' then
      scroll := (others => '0');
    elsif rising_edge(clk_sys) then
      if cpu_sel = MAIN_CPU and cpu_cyc = "11" then
        if scroll_cs = '1' and cpu_memwr = '1' then
          if cpu_a(0) = '0' then
            scroll(7 downto 0) := cpu_d_o;
          else
            scroll(15 downto 8) := cpu_d_o;
          end if; -- cpu_a(0)
        end if; -- scroll_cs & cpu_memwr
      end if; -- sel_cpu_MAIN_CPU
    end if;
    graphics_o.bit16(0) <= scroll;
  end process;
  
  BLK_GFX : block
    type d_a is array (natural range <>) of std_logic_vector(7 downto 0);
    signal tile_d_o   : d_a(CAPCOM_TILE_ROM'range);
  begin
    
    -- GFX1 (foreground characters)
    gfx1_inst : entity work.sprom
      generic map
      (
        init_file		  => PLATFORM_VARIANT_SRC_DIR & "roms/" & 
                            CAPCOM_CHAR_ROM(0) & ".hex",
        widthad_a     => CAPCOM_CHAR_ROM_WIDTHAD
      )
      port map
      (
        clock		=> clk_vid,
        address => tilemap_i(1).tile_a(CAPCOM_CHAR_ROM_WIDTHAD-1 downto 0),
        q				=> tilemap_o(1).tile_d(7 downto 0)
      );
    tilemap_o(1).tile_d(tilemap_o(1).tile_d'left downto 8) <= (others => '0');
    
    GEN_TILEROM : for i in CAPCOM_TILE_ROM'range generate
    begin
      -- GFX2 (background characters)
      gfx2_inst : entity work.sprom
        generic map
        (
          init_file		  => PLATFORM_VARIANT_SRC_DIR & "roms/" & 
                              CAPCOM_TILE_ROM(i) & ".hex",
          widthad_a     => CAPCOM_TILE_ROM_WIDTHAD
        )
        port map
        (
          clock		=> clk_vid,
          address => tilemap_i(2).tile_a(CAPCOM_TILE_ROM_WIDTHAD-1 downto 0),
          q				=> tile_d_o(i)
        );
    end generate GEN_TILEROM;

    tilemap_o(2).tile_d(23 downto 0) <= tile_d_o(0) & tile_d_o(2) & tile_d_o(4) 
                                          when tilemap_i(2).tile_a(CAPCOM_TILE_ROM_WIDTHAD) = '0' else
                                        tile_d_o(1) & tile_d_o(3) & tile_d_o(5);
    tilemap_o(2).tile_d(tilemap_o(2).tile_d'left downto 24) <= (others => '0');
    
    -- GFX3 (sprite characters)
    gfx3_inst : entity work.sprom
      generic map
      (
        init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" & "gfx3.hex",
        widthad_a     => 16
      )
      port map
      (
        clock		=> clk_vid,
        address => sprite_i.a(15 downto 0),
        q				=> sprite_o.d(7 downto 0)
      );
    sprite_o.d(sprite_o.d'left downto 8) <= (others => '0');

  end block BLK_GFX;
  
  -- VRAM (foreground tile code) $D000-$D3FF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
      init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" & "vram.hex",
			widthad_a		=> 10
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_sys,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> vram_we,
			data_b			=> cpu_d_o,
			q_b					=> vram_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> tilemap_i(1).map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d(7 downto 0)
		);
  tilemap_o(1).map_d(tilemap_o(1).map_d'left downto 8) <= (others => '0');

  -- CRAM (foreground colour) $D400-$D7FF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram_inst : entity work.dpram
		generic map
		(
      init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" & "cram.hex",
			widthad_a		=> 10
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_sys,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> cram_we,
			data_b			=> cpu_d_o,
			q_b					=> cram_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> tilemap_i(1).attr_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).attr_d(7 downto 0)
		);
  tilemap_o(1).attr_d(tilemap_o(1).attr_d'left downto 8) <= (others => '0');
  
  -- BGRAM (background tile code) $D800-$DBFF
  -- - consists of 16 bytes of map interleaved with 16 bytes of attr
  -- - so break it into 2 blocks so we can read in parallel
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	bgram_t_inst : entity work.dpram
		generic map
		(
      init_file		          => PLATFORM_VARIANT_SRC_DIR & "roms/" & "bgram_t.hex",
			widthad_a		          => 9
		)
		port map
		(
			-- uP interface
			clock_b			          => clk_sys,
			address_b(8 downto 4) => cpu_a(9 downto 5),
			address_b(3 downto 0) => cpu_a(3 downto 0),
			wren_b			          => bgram_t_we,
			data_b			          => cpu_d_o,
			q_b					          => bgram_t_d_o,
			
			-- graphics interface
			clock_a			          => clk_vid,
			address_a(8 downto 4) => tilemap_i(2).map_a(9 downto 5),
			address_a(3 downto 0) => tilemap_i(2).map_a(3 downto 0),
			wren_a			          => '0',
			data_a			          => (others => 'X'),
			q_a					          => tilemap_o(2).map_d(7 downto 0)
		);
  tilemap_o(2).map_d(tilemap_o(2).map_d'left downto 8) <= (others => '0');
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	bgram_a_inst : entity work.dpram
		generic map
		(
      init_file		          => PLATFORM_VARIANT_SRC_DIR & "roms/" & "bgram_a.hex",
			widthad_a		          => 9
		)
		port map
		(
			-- uP interface
			clock_b			          => clk_sys,
			address_b(8 downto 4) => cpu_a(9 downto 5),
			address_b(3 downto 0) => cpu_a(3 downto 0),
			wren_b			          => bgram_a_we,
			data_b			          => cpu_d_o,
			q_b					          => bgram_a_d_o,
			
			-- graphics interface
			clock_a			          => clk_vid,
			address_a(8 downto 4) => tilemap_i(2).attr_a(9 downto 5),
			address_a(3 downto 0) => tilemap_i(2).attr_a(3 downto 0),
			wren_a			          => '0',
			data_a			          => (others => 'X'),
			q_a					          => tilemap_o(2).attr_d(7 downto 0)
		);
  tilemap_o(2).attr_d(tilemap_o(2).attr_d'left downto 8) <= (others => '0');
  
  -- WRAM1 $E000-$EFFF
  wram_inst : entity work.spram
		generic map
		(
			widthad_a			=> 12
		)
    port map
    (
      clock				=> clk_sys,
      address			=> cpu_a(11 downto 0),
      data				=> cpu_d_o,
      wren				=> wram_we,
      q						=> wram_d_o
    );

  -- osd toggle (TAB)
  process (clk_sys, clkrst_i.arst)
    variable osd_key_r  : std_logic;
    variable osd_en_v   : std_logic;
  begin
    if clkrst_i.arst = '1' then
      osd_en_v := '0';
      osd_key_r := '0';
    elsif rising_edge(clk_sys) then
      -- toggle on OSD KEY PRESS
      if osd_toggle = '1' and osd_key_r = '0' then
        osd_en_v := not osd_en_v;
      end if;
      osd_key_r := osd_toggle;
    end if;
    osd_o.en <= osd_en_v;
  end process;

  -- unused outputs

  sram_o <= NULL_TO_SRAM;
  --graphics_o <= NULL_TO_GRAPHICS;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  --sprite_o <= NULL_TO_SPRITE_CTL;
  --osd_o <= NULL_TO_OSD;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  
end SYN;
