library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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

  -- ROM signals        
  signal mainrom_cs     : std_logic;
  signal mainrom_d      : std_logic_vector(7 downto 0);
  
  -- RAM signals
  
  -- main cpu
  signal mainram1_cs    : std_logic;
  signal mainram1_d     : std_logic_vector(7 downto 0);
  signal mainram2_cs    : std_logic;
  signal mainram2_d     : std_logic_vector(7 downto 0);
  signal mainram3_cs    : std_logic;
  signal mainram3_d     : std_logic_vector(7 downto 0);
  signal mainram4_cs    : std_logic;
  signal mainram4_d     : std_logic_vector(7 downto 0);
  
  -- ram instances
  signal ram1_a         : std_logic_vector(10 downto 0);
  signal ram1_d_i       : std_logic_vector(7 downto 0);
  signal ram1_d_o       : std_logic_vector(7 downto 0);
  signal ram1_we        : std_logic;
  signal ram2_a         : std_logic_vector(10 downto 0);
  signal ram2_d_i       : std_logic_vector(7 downto 0);
  signal ram2_d_o       : std_logic_vector(7 downto 0);
  signal ram2_we        : std_logic;
  signal ram3_a         : std_logic_vector(10 downto 0);
  signal ram3_d_i       : std_logic_vector(7 downto 0);
  signal ram3_d_o       : std_logic_vector(7 downto 0);
  signal ram3_we        : std_logic;
  signal ram4_a         : std_logic_vector(10 downto 0);
  signal ram4_d_i       : std_logic_vector(7 downto 0);
  signal ram4_d_o       : std_logic_vector(7 downto 0);
  signal ram4_we        : std_logic;
  
  -- VRAM signals (names from MAME driver)
  
  -- main cpu
  signal mainrampf0_cs  : std_logic;
  signal mainrampf0_d   : std_logic_vector(7 downto 0);
  signal mainrampf1_cs  : std_logic;
  signal mainrampf1_d   : std_logic_vector(7 downto 0);
  signal mainrampf2_cs  : std_logic;
  signal mainrampf2_d   : std_logic_vector(7 downto 0);
  signal mainrampf3_cs  : std_logic;
  signal mainrampf3_d   : std_logic_vector(7 downto 0);
  
  -- vram instances
  -- foreground attribute ram
	signal rampf0_a      : std_logic_vector(10 downto 0);
  signal rampf0_d_i    : std_logic_vector(7 downto 0);
  signal rampf0_d_o    : std_logic_vector(7 downto 0);
  signal rampf0_we     : std_logic;
  -- background attribute ram
	signal rampf1_a      : std_logic_vector(10 downto 0);
  signal rampf1_d_i    : std_logic_vector(7 downto 0);
  signal rampf1_d_o    : std_logic_vector(7 downto 0);
  signal rampf1_we     : std_logic;
  -- foreground tilecode ram
	signal rampf2_a      : std_logic_vector(10 downto 0);
  signal rampf2_d_i    : std_logic_vector(7 downto 0);
  signal rampf2_d_o    : std_logic_vector(7 downto 0);
  signal rampf2_we     : std_logic;
  -- background tilecode ram
	signal rampf3_a      : std_logic_vector(10 downto 0);
  signal rampf3_d_i    : std_logic_vector(7 downto 0);
  signal rampf3_d_o    : std_logic_vector(7 downto 0);
  signal rampf3_we     : std_logic;
                        
	-- IO signals
	alias game_reset			: std_logic is inputs_i(2).d(0);

  -- other signals      
	signal cpu_reset			: std_logic;
	
  subtype cnt_sys_t is integer range 0 to 11;
  signal cnt_sys : cnt_sys_t := 0;
  
begin

	--cpu_reset <= clkrst_i.arst or game_reset;
  cpu_reset <= rst_sys;
	
  -- clocking
  -- system clock: 36.864MHz
  -- cpu clocks = 3.072MHz
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      main_en <= '0';
      sub_en <= '0';
      sub2_en <= '0';
      cnt_sys <= 0;
    elsif rising_edge(clk_sys) then
      main_en <= '0';   -- default
      sub_en <= '0';    -- default
      sub2_en <= '0';   -- default
      if cnt_sys = 0 then
        main_en <= '1';
      elsif cnt_sys = 4 then
        sub_en <= '1';
      elsif cnt_sys = 8 then
        sub2_en <= '1';
      end if;
      if cnt_sys = cnt_sys_t'high then
        cnt_sys <= 0;
      else
        cnt_sys <= cnt_sys + 1;
      end if;
    end if;
  end process;
  
	-- maincpu chip selects
	-- MAINROM $0000-$3FFF
	mainrom_cs    <= '1' when STD_MATCH(main_a, "00--------------") else '0';
	-- WRAM1 $7800-$7FFF
	mainram1_cs   <= '1' when STD_MATCH(main_a, "01111-----------") else '0';
	-- WRAM2 $8000-$87FF
	mainram2_cs   <= '1' when STD_MATCH(main_a, "10000-----------") else '0';
	-- WRAM3 $9000-$97FF
	mainram3_cs   <= '1' when STD_MATCH(main_a, "10010-----------") else '0';
	-- WRAM4 $A000-$A7FF
	mainram4_cs   <= '1' when STD_MATCH(main_a, "10100-----------") else '0';
  -- RAMPF0 $B000-$B7FF (foreground attribute)
  mainrampf0_cs <= '1' when STD_MATCH(main_a, "10110-----------") else '0';
  -- RAMPF1 $B800-$BFFF (background attribute)
  mainrampf1_cs <= '1' when STD_MATCH(main_a, "10111-----------") else '0';
  -- RAMPF2 $C000-$C7FF (foreground tile code )
  mainrampf2_cs <= '1' when STD_MATCH(main_a, "11000-----------") else '0';
  -- RAMPF3 $C800-$C8FF (background tile code )
  mainrampf3_cs <= '1' when STD_MATCH(main_a, "11001-----------") else '0';

  BLK_MAIN_MUX : block
    signal mem_d_i  : std_logic_vector(7 downto 0) := (others => '0');
    signal io_d_i   : std_logic_vector(7 downto 0) := (others => '0');
  begin
    mem_d_i <=  mainrom_d when mainrom_cs = '1' else
                mainram1_d when mainram1_cs = '1' else
                mainram2_d when mainram2_cs = '1' else
                mainram3_d when mainram3_cs = '1' else
                mainram4_d when mainram4_cs = '1' else
                mainrampf0_d when mainrampf0_cs = '1' else
                mainrampf1_d when mainrampf1_cs = '1' else
                mainrampf2_d when mainrampf2_cs = '1' else
                mainrampf3_d when mainrampf3_cs = '1' else
                X"FF";
    io_d_i <= X"FF";
    main_d_i <= mem_d_i when (main_memrd = '1') else io_d_i;
  end block BLK_MAIN_MUX;

  BLK_RAM_MUX : block
  begin
    -- this needs to be time-sliced between CPUs

    ram1_a <= main_a(ram1_a'range);
    ram1_d_i <= main_d_o;
    mainram1_d <= ram1_d_o;
    ram1_we <= mainram1_cs and main_memwr;

    ram2_a <= main_a(ram2_a'range);
    ram2_d_i <= main_d_o;
    mainram2_d <= ram2_d_o;
    ram2_we <= mainram2_cs and main_memwr;

    ram3_a <= main_a(ram3_a'range);
    ram3_d_i <= main_d_o;
    mainram3_d <= ram3_d_o;
    ram3_we <= mainram3_cs and main_memwr;

    ram4_a <= main_a(ram4_a'range);
    ram4_d_i <= main_d_o;
    mainram4_d <= ram4_d_o;
    ram4_we <= mainram4_cs and main_memwr;

  end block BLK_RAM_MUX;
  
  BLK_VRAM_MUX : block
  begin
    -- this needs to be time-sliced between CPUs

    rampf0_a <= main_a(rampf0_a'range);
    rampf0_d_i <= main_d_o;
    mainrampf0_d <= rampf0_d_o;
    rampf0_we <= mainrampf0_cs and main_memwr;

    rampf1_a <= main_a(rampf1_a'range);
    rampf1_d_i <= main_d_o;
    mainrampf1_d <= rampf1_d_o;
    rampf1_we <= mainrampf1_cs and main_memwr;

    rampf2_a <= main_a(rampf2_a'range);
    rampf2_d_i <= main_d_o;
    mainrampf2_d <= rampf2_d_o;
    rampf2_we <= mainrampf2_cs and main_memwr;

    rampf3_a <= main_a(rampf3_a'range);
    rampf3_d_i <= main_d_o;
    mainrampf3_d <= rampf3_d_o;
    rampf3_we <= mainrampf3_cs and main_memwr;

  end block BLK_VRAM_MUX;
  
  main_cpu : entity work.Z80                                                
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
      q				=> mainrom_d
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
      address			=> ram1_a,
      data				=> ram1_d_i,
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
      address			=> ram2_a,
      data				=> ram2_d_i,
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
      address			=> ram3_a,
      data				=> ram3_d_i,
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
    address			=> ram4_a,
    data				=> ram4_d_i,
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
			address_b		=> rampf0_a,
			wren_b			=> rampf0_we,
			data_b			=> rampf0_d_i,
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
			address_b		=> rampf1_a,
			wren_b			=> rampf1_we,
			data_b			=> rampf1_d_i,
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
			address_b		=> rampf2_a,
			wren_b			=> rampf2_we,
			data_b			=> rampf2_d_i,
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
			address_b		=> rampf3_a,
			wren_b			=> rampf3_we,
			data_b			=> rampf3_d_i,
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
