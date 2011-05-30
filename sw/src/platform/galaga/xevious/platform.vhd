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
    
    bitmap_i        : in from_BITMAP_CTL_t;
    bitmap_o        : out to_BITMAP_CTL_t;
    
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
  signal main_intena    : std_logic;
  signal main_int       : std_logic;

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

  -- sub2 cpu signals
  signal sub2_rst       : std_logic;
  signal sub2_en        : std_logic;
  signal sub2_a         : std_logic_vector(15 downto 0);
  signal sub2_d_i       : std_logic_vector(7 downto 0);
  signal sub2_d_o       : std_logic_vector(7 downto 0);
  signal sub2_memrd     : std_logic;
  signal sub2_memwr     : std_logic;
  signal sub2_iord      : std_logic;
  signal sub2_iowr      : std_logic;
  signal sub2_intreq    : std_logic;
  signal sub2_intvec    : std_logic_vector(7 downto 0);
  signal sub2_intack    : std_logic;
  signal sub2_nmireq    : std_logic;
  signal sub2_nmiena    : std_logic;
  signal sub2_nmi       : std_logic;

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
  signal sub2rom_cs     : std_logic;
  signal sub2rom_d_o    : std_logic_vector(7 downto 0);

  -- latches
  signal bosco_latch_cs   : std_logic;
  signal bosco_dsw_cs     : std_logic;
  signal bosco_dswa       : std_logic_vector(7 downto 0);
  signal bosco_dswb       : std_logic_vector(7 downto 0);
  signal bosco_dsw_d_o    : std_logic_vector(1 downto 0);
  
  signal vh_latch_cs      : std_logic;
  
  -- NAMCO custom signals
  signal namco_06xx_cs_n  : std_logic;
  signal namco_06xx_r_wn  : std_logic;
  signal namco_06xx_sd_o  : std_logic_vector(7 downto 0);
  
  -- RAM signals
  
  signal ram1_cs        : std_logic;
  signal ram1_we        : std_logic;
  signal ram1_d_o       : std_logic_vector(7 downto 0);
  signal ram2_cs        : std_logic;
  signal ram2_we        : std_logic;
  signal ram2_d_o       : std_logic_vector(7 downto 0);
  signal ram3_cs        : std_logic;
  signal ram3_we        : std_logic;
  signal ram3_d_o       : std_logic_vector(7 downto 0);
  signal ram4_cs        : std_logic;
  signal ram4_we        : std_logic;
  signal ram4_d_o       : std_logic_vector(7 downto 0);
  
  -- VRAM signals (names from MAME driver)
  
  -- foreground attribute ram
  signal rampf0_cs      : std_logic;
  signal rampf0_we      : std_logic;
  signal rampf0_d_o     : std_logic_vector(7 downto 0);
  -- background attribute ram
  signal rampf1_cs      : std_logic;
  signal rampf1_we      : std_logic;
  signal rampf1_d_o     : std_logic_vector(7 downto 0);
  -- foreground tilecode ram
  signal rampf2_cs      : std_logic;
  signal rampf2_we      : std_logic;
  signal rampf2_d_o     : std_logic_vector(7 downto 0);
  -- background tilecode ram
  signal rampf3_cs      : std_logic;
  signal rampf3_we      : std_logic;
  signal rampf3_d_o     : std_logic_vector(7 downto 0);
                        
	-- IO signals
	alias game_reset			: std_logic is inputs_i(2).d(0);

  -- other signals      
	signal cpu_reset			: std_logic;
	
  signal cnt_sys  : std_logic_vector(3 downto 0) := (others => '0');
  alias cpu_sel   : std_logic_vector(1 downto 0) is cnt_sys(3 downto 2);
  alias cpu_cyc   : std_logic_vector(1 downto 0) is cnt_sys(1 downto 0);
  constant MAIN_CPU : std_logic_vector(cpu_sel'range) := "00";
  constant SUB_CPU  : std_logic_vector(cpu_sel'range) := "01";
  constant SUB2_CPU : std_logic_vector(cpu_sel'range) := "10";
  
begin

	--cpu_reset <= clkrst_i.arst or game_reset;
  cpu_reset <= rst_sys;
	
  -- clocking
  -- system clock: 49.152MHz
  -- cpu clocks = 3.072MHz
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      main_en <= '0';
      sub_en <= '0';
      sub2_en <= '0';
      cnt_sys <= (others => '0');
    elsif rising_edge(clk_sys) then
      main_en <= '0';   -- default
      sub_en <= '0';    -- default
      sub2_en <= '0';   -- default
      if cpu_cyc = "00" then
        case cpu_sel is
          when MAIN_CPU =>
            main_en <= '1';
            cpu_a <= main_a;
            cpu_d_o <= main_d_o;
            cpu_memrd <= main_memrd;
            cpu_memwr <= main_memwr;
            cpu_iord <= main_iord;
            cpu_iowr <= main_iowr;
          when SUB_CPU =>
            sub_en <= '1';
            cpu_a <= sub_a;
            cpu_d_o <= sub_d_o;
            cpu_memrd <= sub_memrd;
            cpu_memwr <= sub_memwr;
            cpu_iord <= sub_iord;
            cpu_iowr <= sub_iowr;
          when SUB2_CPU =>
            sub2_en <= '1';
            cpu_a <= sub2_a;
            cpu_d_o <= sub2_d_o;
            cpu_memrd <= sub2_memrd;
            cpu_memwr <= sub2_memwr;
            cpu_iord <= sub2_iord;
            cpu_iowr <= sub2_iowr;
          when others =>
        end case;
      end if;
      cnt_sys <= std_logic_vector(unsigned(cnt_sys) + 1);
    end if;
  end process;

	-- chip selects
	-- MAINROM $0000-$3FFF
	mainrom_cs      <= '1' when STD_MATCH(main_a, "00--------------") else '0';
	-- SUBROM $0000-$1FFF
	subrom_cs       <= '1' when STD_MATCH(sub_a,  "000-------------") else '0';
	-- SUB2ROM $0000-$0FFF
	sub2rom_cs      <= '1' when STD_MATCH(sub2_a, "0000------------") else '0';
  -- BOSCO DSW $6800-$6807
  bosco_dsw_cs    <= '1' when STD_MATCH(cpu_a,  "0110100000000---") else '0';
  -- BOSCO_LATCHES $6820-$6827
  bosco_latch_cs  <= '1' when STD_MATCH(cpu_a,  "0110100000100---") else '0';
  -- NAMCO 06XX ($7000,$7100)
  namco_06xx_cs_n <= '0' when STD_MATCH(main_a, "0111000-00000000") else '1';
	-- WRAM1 $7800-$7FFF
	ram1_cs         <= '1' when STD_MATCH(cpu_a,  "01111-----------") else '0';
	-- WRAM2 $8000-$87FF
	ram2_cs         <= '1' when STD_MATCH(cpu_a,  "10000-----------") else '0';
	-- WRAM3 $9000-$97FF
	ram3_cs         <= '1' when STD_MATCH(cpu_a,  "10010-----------") else '0';
	-- WRAM4 $A000-$A7FF
	ram4_cs         <= '1' when STD_MATCH(cpu_a,  "10100-----------") else '0';
  -- RAMPF0 $B000-$B7FF (foreground attribute)
  rampf0_cs       <= '1' when STD_MATCH(cpu_a,  "10110-----------") else '0';
  -- RAMPF1 $B800-$BFFF (background attribute)
  rampf1_cs       <= '1' when STD_MATCH(cpu_a,  "10111-----------") else '0';
  -- RAMPF2 $C000-$C7FF (foreground tile code )
  rampf2_cs       <= '1' when STD_MATCH(cpu_a,  "11000-----------") else '0';
  -- RAMPF3 $C800-$C8FF (background tile code )
  rampf3_cs       <= '1' when STD_MATCH(cpu_a,  "11001-----------") else '0';
  -- VH_LATCH $D000-$D07F
  vh_latch_cs     <= '1' when STD_MATCH(cpu_a,  "110100000-------") else '0';
  
  -- write-enables, pulse for 1 clock only
  process (clk_sys, rst_sys)
    variable cpu_memwr_r : std_logic := '0';
  begin
    if rst_sys = '1' then
      null;
    elsif rising_edge(clk_sys) then
      namco_06xx_r_wn <= '1';
      ram1_we <= '0';
      ram2_we <= '0';
      ram3_we <= '0';
      ram4_we <= '0';
      rampf0_we <= '0';
      rampf1_we <= '0';
      rampf2_we <= '0';
      rampf3_we <= '0';
      if cpu_cyc = "10" and cpu_memwr = '1' then
        namco_06xx_r_wn <= namco_06xx_cs_n;
        ram1_we <= ram1_cs;
        ram2_we <= ram2_cs;
        ram3_we <= ram3_cs;
        ram4_we <= ram4_cs;
        rampf0_we <= rampf0_cs;
        rampf1_we <= rampf1_cs;
        rampf2_we <= rampf2_cs;
        rampf3_we <= rampf3_cs;
      end if;
    end if;
  end process;

  -- muxed data signals
  mem_d_o <=  std_logic_vector(resize(unsigned(bosco_dsw_d_o),mem_d_o'length)) 
                when bosco_dsw_cs = '1' else
              namco_06xx_sd_o when namco_06xx_cs_n = '0' else
              ram1_d_o when ram1_cs = '1' else
              ram2_d_o when ram2_cs = '1' else
              ram3_d_o when ram3_cs = '1' else
              ram4_d_o when ram4_cs = '1' else
              rampf0_d_o when rampf0_cs = '1' else
              rampf1_d_o when rampf1_cs = '1' else
              rampf2_d_o when rampf2_cs = '1' else
              rampf3_d_o when rampf3_cs = '1' else
              X"FF";
              
  io_d_o <= X"FF";

  GEN_MAIN_CPU : if true generate
  begin
    main_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_sys,                                   
        clk_en	=> main_en,
        reset  	=> cpu_reset,                                     

        addr   	=> main_a,
        datai  	=> main_d_i,
        datao  	=> main_d_o,

        mem_rd 	=> main_memrd,
        mem_wr 	=> main_memwr,
        io_rd  	=> main_iord,
        io_wr  	=> main_iowr,

        intreq 	=> main_int,
        intvec 	=> main_intvec,
        intack 	=> main_intack,
        nmi    	=> main_nmi
      );

    -- irq enable via bosco_latch
    main_int <= main_intreq and main_intena;
    main_intvec <= (others => '0');
    
    main_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/galaga/xevious/roms/" & 
                        XEVIOUS_VARIANT & "/main.hex",
        widthad_a		=> 14
      )
      port map
      (
        clock		=> clk_sys,
        address => main_a(13 downto 0),
        q				=> mainrom_d_o
      );

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
                -- 20 15 (jr nz,$278)
                when X"0261" | X"0262" =>
                  main_d_i <= X"00";  -- NOP
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
    
    main_vbl_irq_inst : entity work.vbl_gen
      port map
      (
        clk     => clk_sys,
        clk_en  => main_en,
        rst     => rst_sys,
        
        vbl     => graphics_i.vblank,
        irq     => main_intreq,
        ack     => main_intack
      );

  end generate GEN_MAIN_CPU;
  
  GEN_SUB_CPU : if XEVIOUS_HAS_SUB_CPU generate
  begin
    sub_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_sys,                                   
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

    -- irq enable via bosco_latch
    sub_int <= sub_intreq and sub_intena;
    sub_intvec <= (others => '0');
    sub_nmi <= '0';
    
    sub_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/galaga/xevious/roms/" & 
                          XEVIOUS_VARIANT & "/sub.hex",
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
          else
            sub_d_i <= io_d_o;
          end if;
        end if;
      end if;
    end process;

    sub_vbl_irq_inst : entity work.vbl_gen
      port map
      (
        clk     => clk_sys,
        clk_en  => sub_en,
        rst     => rst_sys,
        
        vbl     => graphics_i.vblank,
        irq     => sub_intreq,
        ack     => sub_intack
      );

  end generate GEN_SUB_CPU;

  GEN_SUB2_CPU : if XEVIOUS_HAS_SUB2_CPU generate
  begin
    sub2_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_sys,                                   
        clk_en	=> sub2_en,
        reset  	=> sub2_rst,                                     

        addr   	=> sub2_a,
        datai  	=> sub2_d_i,
        datao  	=> sub2_d_o,

        mem_rd 	=> sub2_memrd,
        mem_wr 	=> sub2_memwr,
        io_rd  	=> sub2_iord,
        io_wr  	=> sub2_iowr,

        intreq 	=> sub2_intreq,
        intvec 	=> sub2_intvec,
        intack 	=> sub2_intack,
        nmi    	=> sub2_nmi
      );

    sub2_intreq <= '0';
    sub2_intvec <= (others => '0');
    -- nmi enable via bosco_latch
    sub2_nmireq <= '0';
    sub2_nmi <= sub2_nmireq and sub2_nmiena;
    
    sub2_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/galaga/xevious/roms/" &
                          XEVIOUS_VARIANT & "/sub2.hex",
        widthad_a		=> 12
      )
      port map
      (
        clock		=> clk_sys,
        address => sub2_a(11 downto 0),
        q				=> sub2rom_d_o
      );

    -- data latch
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        null;
      elsif rising_edge(clk_sys) then
        if cpu_sel = SUB2_CPU and cpu_cyc = "11" then
          -- latch read data for next clock
          if sub2_memrd = '1' then
            if sub2rom_cs = '1' then
              sub2_d_i <= sub2rom_d_o;
            else
              sub2_d_i <= mem_d_o;
            end if;
          else
            sub2_d_i <= io_d_o;
          end if;
        end if;
      end if;
    end process;

  end generate GEN_SUB2_CPU;

  -- bosco dipswitches
  process (clk_sys, rst_sys)
    variable i  : integer range 0 to 7;
  begin
    if rst_sys = '1' then
      -- upright, 3 lives, bonus life 10K,40K,every 40K, Coin1 1C1C
      bosco_dswa <= X"80" or X"60" or X"18" or X"03";
      -- freeze off, easy, Coin2 1C1C, flags bonus life
      bosco_dswb <= X"80" or X"40" or X"0C" or X"02";
    elsif rising_edge(clk_sys) then
      i := to_integer(unsigned(cpu_a(2 downto 0)));
      bosco_dsw_d_o <= bosco_dswa(i) & bosco_dswb(i);
    end if;
  end process;
  
  -- bosco latches
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      main_intena <= '0';
      sub_intena <= '0';
      sub2_nmiena <= '0';
      sub_rst <= '0';
      sub2_rst <= '0';
    elsif rising_edge(clk_sys) then
      if main_en = '1' or sub_en = '1' or sub2_en = '1' then
        if bosco_latch_cs = '1' and cpu_memwr = '1' then
          case cpu_a(2 downto 0) is
            when "000" =>
              main_intena <= cpu_d_o(0);
              -- clear int when (0)=0
            when "001" =>
              sub_intena <= cpu_d_o(0);
              -- clear int when (0)=0
            when "010" =>
              sub2_nmiena <= not cpu_d_o(0);
            when "011" =>
              sub_rst <= not cpu_d_o(0);
              sub2_rst <= not cpu_d_o(0);
            when others =>
              null;
          end case;
        end if; -- bosco_latches_cs, cpu_mem_wr
      end if; -- main_en, sub_en, sub2_en
    end if;
  end process;
  
  -- video hardware latches
  process (clk_sys, rst_sys)
    variable scroll : std_logic_vector(8 downto 0) := (others => '0');
  begin
    if rst_sys = '1' then
      scroll := (others => '0');
    elsif rising_edge(clk_sys) then
      scroll := cpu_a(0) & cpu_d_o;
      if main_en = '1' or sub_en = '1' or sub2_en = '1' then
        if vh_latch_cs = '1' and cpu_memwr = '1' then
          case cpu_a(7 downto 4) is
            when "0000" =>
              -- bg x scroll
              graphics_o.bit16(0) <= std_logic_vector(resize(unsigned(scroll),16));
            when "0001" =>
              -- fg x scroll
              graphics_o.bit16(1) <= std_logic_vector(resize(unsigned(scroll),16));
            when "0010" =>
              -- bg y scroll
              graphics_o.bit16(2) <= std_logic_vector(resize(unsigned(scroll),16));
            when "0011" =>
              -- fg y scroll
              graphics_o.bit16(3) <= std_logic_vector(resize(unsigned(scroll),16));
            when "0111" =>
              -- flip screen
            when others =>
              null;
          end case;
        end if; -- vh_latches_cs, cpu_mem_wr
      end if; -- main_en, sub_en, sub2_en
    end if;
  end process;
  
  BLK_NAMCO_CUSTOM : block
    signal namco_06xx_nmi_n : std_logic;
    signal namco_06xx_id_i  : std_logic_vector(7 downto 0);
    signal namco_06xx_id_o  : std_logic_vector(7 downto 0);
    signal namco_06xx_io_o  : std_logic_vector(1 to 4);
    signal namco_06xx_pin1  : std_logic;
    signal namco_51xx_o     : std_logic_vector(7 downto 0);
    signal namco_50xx_ans   : std_logic_vector(7 downto 0);
  begin
  
    namco_06xx_inst : entity work.namco_06xx
      generic map
      (
        SYS_CLK_Hz    => 49152000,
        CLK_EN_DUTY   => 1
      )
      port map
      (
        clk           => clk_sys,
        clk_en        => '1',
        rst           => rst_sys,
        
        cs_n          => namco_06xx_cs_n,
        r_wn          => namco_06xx_r_wn,
        sel           => main_a(8),
        sd_i          => main_d_o,
        sd_o          => namco_06xx_sd_o,
        nmi_n         => namco_06xx_nmi_n,
        
        id_i          => namco_06xx_id_i,
        id_o          => namco_06xx_id_o,
        io_n          => namco_06xx_io_o,

        pin1          => namco_06xx_pin1
      );

    main_nmi <= not namco_06xx_nmi_n;
    
    -- read mux
    namco_06xx_id_i <=  namco_50xx_ans when namco_06xx_io_o(2) = '0' else
                        namco_51xx_o when namco_06xx_io_o(4) = '0' else
                        (others => '0');
                        
    namco_51xx_inst : entity work.namco_51xx
      generic map
      (
        SYS_CLK_Hz    => 49152000,
        CLK_EN_DUTY   => 16
      )
      port map
      (
        clk           => clk_sys,
        clk_en        => '1',
        rst           => rst_sys,

        si            => '0',                 -- NC
        so            => open,                -- NC
        k(3)          => namco_06xx_pin1,
        k(2 downto 0) => namco_06xx_id_o(2 downto 0),
        r             => (others => '0'),     -- I/O
        p             => open,                -- lamps etc
        o             => namco_51xx_o,
        
        irq_n         => namco_06xx_io_o(4),
        to_n          => '0',                 -- NC
        tc_n          => '0'                  -- VBLANK#
      );
   
    namco_50xx_inst : entity work.namco_50xx
      generic map
      (
        SYS_CLK_Hz    => 49152000,
        CLK_EN_DUTY   => 16
      )
      port map
      (
        clk           => clk_sys,
        clk_en        => '1',
        rst           => rst_sys,
        
        r_wn          => namco_06xx_pin1,
        irq_n         => namco_06xx_io_o(2),
        tc_n          => '0',                   -- NC
        
        cmd           => namco_06xx_id_o,
        ans           => namco_50xx_ans
      );
     
    namco_54xx_inst : entity work.namco_54xx
      generic map
      (
        SYS_CLK_Hz    => 49152000,
        CLK_EN_DUTY   => 16
      )
      port map
      (
        clk           => clk_sys,
        clk_en        => '1',
        rst           => rst_sys,
        
        irq_n         => namco_06xx_io_o(1),
        tc_n          => '0',                   -- NC

        cmd           => namco_06xx_id_o,
        o0            => open,
        o1            => open,
        o2            => open
      );
  end block BLK_NAMCO_CUSTOM;
  
  -- GFX1 (foreground characters)
  gfx1_inst : entity work.sprom
    generic map
    (
      init_file		=> "../../../../../src/platform/galaga/xevious/roms/gfx1.hex",
      widthad_a     => 12
    )
    port map
    (
      clock		=> clk_vid,
      address => tilemap_i(1).tile_a(11 downto 0),
      q				=> tilemap_o(1).tile_d
    );
    
  -- GFX2 (background characters)
  gfx2_inst : entity work.sprom
    generic map
    (
      init_file		=> "../../../../../src/platform/galaga/xevious/roms/gfx2.hex",
      widthad_a     => 13
    )
    port map
    (
      clock		=> clk_vid,
      address => tilemap_i(2).tile_a(12 downto 0),
      q				=> tilemap_o(2).tile_d
    );
    
  -- WRAM1 $7800-$7FFF
  ram1_inst : entity work.spram
		generic map
		(
			widthad_a			=> 11
		)
    port map
    (
      clock				=> clk_sys,
      address			=> cpu_a(10 downto 0),
      data				=> cpu_d_o,
      wren				=> ram1_we,
      q						=> ram1_d_o
    );

  -- WRAM2 $8000-$87FF
  ram2_inst : entity work.spram
		generic map
		(
			widthad_a			=> 11
		)
    port map
    (
      clock				=> clk_sys,
      address			=> cpu_a(10 downto 0),
      data				=> cpu_d_o,
      wren				=> ram2_we,
      q						=> ram2_d_o
    );

  -- WRAM3 $9000-$97FF
  ram3_inst : entity work.spram
		generic map
		(
			widthad_a			=> 11
		)
    port map
    (
      clock				=> clk_sys,
      address			=> cpu_a(10 downto 0),
      data				=> cpu_d_o,
      wren				=> ram3_we,
      q						=> ram3_d_o
    );

  -- WRAM4 $A000-$A7FF
  ram4_inst : entity work.spram
  generic map
  (
    widthad_a			=> 11
  )
  port map
  (
    clock				=> clk_sys,
    address			=> cpu_a(10 downto 0),
    data				=> cpu_d_o,
    wren				=> ram4_we,
    q						=> ram4_d_o
  );

  -- VRAM (foreground attribute) $B000-$B7FF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	rampf0_inst : entity work.dpram
		generic map
		(
			init_file		=> "",
			widthad_a		=> 11
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_sys,
			address_b		=> cpu_a(10 downto 0),
			wren_b			=> rampf0_we,
			data_b			=> cpu_d_o,
			q_b					=> rampf0_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> tilemap_i(1).attr_a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).attr_d(7 downto 0)
		);
  tilemap_o(1).attr_d(tilemap_o(1).attr_d'left downto 8) <= (others => '0');
  
  -- VRAM (background attribute) $B800-$BFFF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	rampf1_inst : entity work.dpram
		generic map
		(
			init_file		=> "",
			widthad_a		=> 11
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_sys,
			address_b		=> cpu_a(10 downto 0),
			wren_b			=> rampf1_we,
			data_b			=> cpu_d_o,
			q_b					=> rampf1_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> tilemap_i(2).attr_a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(2).attr_d(7 downto 0)
		);
  tilemap_o(2).attr_d(tilemap_o(2).attr_d'left downto 8) <= (others => '0');
  
  -- VRAM (foreground tile code) $C000-$C7FF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	rampf2_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../src/platform/galaga/xevious/roms/rampf2.hex",
			widthad_a		=> 11
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_sys,
			address_b		=> cpu_a(10 downto 0),
			wren_b			=> rampf2_we,
			data_b			=> cpu_d_o,
			q_b					=> rampf2_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> tilemap_i(1).map_a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d(7 downto 0)
		);
  tilemap_o(1).map_d(tilemap_o(1).map_d'left downto 8) <= (others => '0');

  -- VRAM (background tile code) $C800-$CFFF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	rampf3_inst : entity work.dpram
		generic map
		(
			init_file		=> "",
			widthad_a		=> 11
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_sys,
			address_b		=> cpu_a(10 downto 0),
			wren_b			=> rampf3_we,
			data_b			=> cpu_d_o,
			q_b					=> rampf3_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> tilemap_i(2).map_a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(2).map_d(7 downto 0)
		);
  tilemap_o(2).map_d(tilemap_o(2).map_d'left downto 8) <= (others => '0');
  
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
      if inputs_i(2).d(1) = '1' and osd_key_r = '0' then
        osd_en_v := not osd_en_v;
      end if;
      osd_key_r := inputs_i(2).d(1);
    end if;
    osd_o.en <= osd_en_v;
  end process;

  -- unused outputs

  sram_o <= NULL_TO_SRAM;
  --graphics_o <= NULL_TO_GRAPHICS;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --osd_o <= NULL_TO_OSD;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  
end SYN;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vbl_gen is
  port
  (
    clk     : in std_logic;
    clk_en  : in std_logic;
    rst     : in std_logic;
    
    vbl     : in std_logic;
    irq     : out std_logic;
    ack     : in std_logic
  );
end entity vbl_gen;

architecture SYN of vbl_gen is
begin
  -- vblank interrupt
  process (clk, rst)
    variable vbl_r : std_logic_vector(3 downto 0);
    alias vbl_prev : std_logic is vbl_r(vbl_r'left);
    alias vbl_um : std_logic is vbl_r(vbl_r'left-1);
  begin
    if rst = '1' then
      irq <= '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        if vbl_prev = '0' and vbl_um = '1' then
          irq <= '1';
        elsif ack = '1' then
          irq <= '0';
        end if;
        vbl_r := vbl_r(vbl_r'left-1 downto 0) & vbl;
      end if;
    end if;
  end process;
 end architecture SYN;
