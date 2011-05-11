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

  -- sub cpu signals
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

  -- sub2 cpu signals
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
	mainrom_cs  <= '1' when STD_MATCH(main_a, "00--------------") else '0';
	-- SUBROM $0000-$1FFF
	subrom_cs   <= '1' when STD_MATCH(sub_a,  "000-------------") else '0';
	-- SUB2ROM $0000-$0FFF
	sub2rom_cs  <= '1' when STD_MATCH(sub2_a, "0000------------") else '0';
	-- WRAM1 $7800-$7FFF
	ram1_cs     <= '1' when STD_MATCH(cpu_a,  "01111-----------") else '0';
	-- WRAM2 $8000-$87FF
	ram2_cs     <= '1' when STD_MATCH(cpu_a,  "10000-----------") else '0';
	-- WRAM3 $9000-$97FF
	ram3_cs     <= '1' when STD_MATCH(cpu_a,  "10010-----------") else '0';
	-- WRAM4 $A000-$A7FF
	ram4_cs     <= '1' when STD_MATCH(cpu_a,  "10100-----------") else '0';
  -- RAMPF0 $B000-$B7FF (foreground attribute)
  rampf0_cs   <= '1' when STD_MATCH(cpu_a,  "10110-----------") else '0';
  -- RAMPF1 $B800-$BFFF (background attribute)
  rampf1_cs   <= '1' when STD_MATCH(cpu_a,  "10111-----------") else '0';
  -- RAMPF2 $C000-$C7FF (foreground tile code )
  rampf2_cs   <= '1' when STD_MATCH(cpu_a,  "11000-----------") else '0';
  -- RAMPF3 $C800-$C8FF (background tile code )
  rampf3_cs   <= '1' when STD_MATCH(cpu_a,  "11001-----------") else '0';

  -- write-enables
  ram1_we <= ram1_cs and cpu_memwr;
  ram2_we <= ram1_cs and cpu_memwr;
  ram3_we <= ram1_cs and cpu_memwr;
  ram4_we <= ram1_cs and cpu_memwr;
  rampf0_we <= rampf0_cs and cpu_memwr;
  rampf1_we <= rampf1_cs and cpu_memwr;
  rampf2_we <= rampf2_cs and cpu_memwr;
  rampf3_we <= rampf3_cs and cpu_memwr;

  -- muxed data signals
  mem_d_o <=  ram1_d_o when ram1_cs = '1' else
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

        intreq 	=> main_intreq,
        intvec 	=> main_intvec,
        intack 	=> main_intack,
        nmi    	=> main_nmi
      );

    main_intreq <= '0';
    main_intvec <= (others => '0');
    main_nmi <= '0';
    
    main_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/galaga/xevious/roms/main.hex",
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
        if cpu_sel = MAIN_CPU and cpu_cyc = "10" then
          -- latch read data for next clock
          if main_memrd = '1' then
            if mainrom_cs = '1' then
              main_d_i <= mainrom_d_o;
            else
              main_d_i <= mem_d_o;
            end if;
          else
            main_d_i <= io_d_o;
          end if;
        end if;
      end if;
    end process;
    
  end generate GEN_MAIN_CPU;
  
  GEN_SUB_CPU : if XEVIOUS_HAS_SUB_CPU generate
  begin
    sub_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_sys,                                   
        clk_en	=> sub_en,
        reset  	=> cpu_reset,                                     

        addr   	=> sub_a,
        datai  	=> sub_d_i,
        datao  	=> sub_d_o,

        mem_rd 	=> sub_memrd,
        mem_wr 	=> sub_memwr,
        io_rd  	=> sub_iord,
        io_wr  	=> sub_iowr,

        intreq 	=> sub_intreq,
        intvec 	=> sub_intvec,
        intack 	=> sub_intack,
        nmi    	=> sub_nmi
      );

    sub_intreq <= '0';
    sub_intvec <= (others => '0');
    sub_nmi <= '0';
    
    sub_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/galaga/xevious/roms/sub.hex",
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
        if cpu_sel = SUB_CPU and cpu_cyc = "10" then
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

  end generate GEN_SUB_CPU;

  GEN_SUB2_CPU : if XEVIOUS_HAS_SUB2_CPU generate
  begin
    sub2_cpu_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_sys,                                   
        clk_en	=> sub2_en,
        reset  	=> cpu_reset,                                     

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
    sub2_nmi <= '0';
    
    sub2_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/galaga/xevious/roms/sub2.hex",
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
        if cpu_sel = SUB2_CPU and cpu_cyc = "10" then
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
			address_a		=> (others => '0'),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> open
		);
  
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
			address_a		=> (others => '0'),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> open
		);
  
  -- VRAM (foreground tile code) $C000-$CFFF
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	rampf2_inst : entity work.dpram
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
			wren_b			=> rampf2_we,
			data_b			=> cpu_d_o,
			q_b					=> rampf2_d_o,
			
			-- graphics interface
			clock_a			=> clk_vid,
			address_a		=> (others => '0'),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> open
		);
  
  -- VRAM (foreground tile code) $C800-$CFFF
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
			address_a		=> (others => '0'),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> open
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
      if inputs_i(2).d(1) = '1' and osd_key_r = '0' then
        osd_en_v := not osd_en_v;
      end if;
      osd_key_r := inputs_i(2).d(1);
    end if;
    osd_o.en <= osd_en_v;
  end process;

  -- unused outputs

  sram_o <= NULL_TO_SRAM;
  graphics_o <= NULL_TO_GRAPHICS;
  tilemap_o <= NULL_TO_TILEMAP_CTL;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --osd_o <= NULL_TO_OSD;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  
end SYN;
