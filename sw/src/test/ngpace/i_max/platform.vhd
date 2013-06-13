library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.sdram_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

--
--  Since I've already forgotten this once (and wasted a few hours "debugging")
--  - SW(0)=ON
--    - Menu system. Use <1> to toggle through BIOS screens
--  - SW(7..0) = 01000100 (play a game on freeplay)
-- Flash memory map
-- $000000 - sfix.sfx (bios fixed tilemap graphics) 128KiB
-- $020000 - 021-s1.bin (cart fixed tilemap graphics) 128KiB
-- $040000 - sp-s2.sp1 (BIOS code) 128KiB
-- $100000 - 021-p1.bin (cart code) up to 1MiB
-- $200000 - 021-c1.bin (sprite data) up to 1MiB
--

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

  -- build options
  constant BUILD_INSYS_SPRITE_RAM   : boolean := false;
  constant N_CORES                  : integer := 32;
  constant N_RAMS                   : integer := 2;
  
	alias clk_25M           : std_logic is clkrst_i.clk(1);
  alias rst_25M           : std_logic is clkrst_i.rst(1);
	alias clk_video         : std_logic is clkrst_i.clk(1);
  alias rst_video         : std_logic is clkrst_i.rst(1);
	alias clk_27M           : std_logic is clkrst_i.clk(3);
  alias rst_27M           : std_logic is clkrst_i.rst(3);
	signal clk_12M_ena      : std_logic := '0';
	
  type a_a is array (natural range <>) of std_logic_vector(31 downto 0);
  type d_a is array (natural range <>) of std_logic_vector(15 downto 0);
  
	signal reset_neogeo_n   : std_logic := '1';
	signal a_ext            : a_a(0 to N_CORES-1) := (others => (others => '0'));
	--alias a                 : a_a(1 to N_CORES) is a_ext(1)(23 downto 1);
  signal d_i              : std_logic_vector(15 downto 0) := (others => '0');
  signal d_o              : d_a(0 to N_CORES-1) := (others => (others => '0'));
  signal dtackn           : std_logic := '0';
  signal asn              : std_logic_vector(0 to N_CORES-1) := (others => '0');
  signal udsn             : std_logic_vector(0 to N_CORES-1) := (others => '0');
  signal ldsn             : std_logic_vector(0 to N_CORES-1) := (others => '0');
  signal rwn              : std_logic_vector(0 to N_CORES-1) := (others => '0');
  signal ipln             : std_logic_vector(2 downto 0) := (others => '1');
  -- write pulse (100MHz) - "fixed" from TG68 core
  signal wr_p             : std_logic;

  -- hardware registers
  signal reg_3C_cs        : std_logic := '0';
  
  signal sdram_dtackn     : std_logic := '1';
  signal sys_count        : std_logic_vector(7 downto 0);
  signal core             : integer range 0 to 63;
  signal ena              : std_logic_vector(0 to N_CORES-1);
  
  signal ram_d_o          : d_a(0 to N_RAMS-1);
  
begin

  --
  -- clocking
  --
  
  process (clk_25M, rst_25M)
    variable count : std_logic_vector(2 downto 0) := (others => '0');
  begin
    if rst_25M = '1' then
      count := (others => '0');
    elsif rising_edge(clk_25M) then
      clk_12M_ena <= '0'; -- default
      if count(0) = '0' then
        clk_12M_ena <= '1';
      end if;
      count := count + 1;
    end if;
  end process;
  
  process (clk_25M, rst_25M)
  begin
    if rst_25M = '1' then
      sys_count <= (others => '0');
    elsif rising_edge(clk_25M) then
      if clk_12M_ena = '1' then
        sys_count <= sys_count + 1;
        core <= to_integer(unsigned(sys_count(sys_count'left downto 2)));
      end if;
    end if;
  end process;
  
  --
  -- wr_p logic
  --
  
  process (clk_25M)
    variable wr_r : std_logic;
  begin
    if rising_edge(clk_25M) then
      wr_p <= '0'; -- default
      if clk_12M_ena = '1' then
        -- leading edge write cycle
        if wr_r = '0' and asn(core) = '0' and rwn(core) = '0' then
          wr_p <= '1';
        end if;
        wr_r := not (asn(core) or rwn(core));
      end if;
    end if;
  end process;

  --
  -- dtack logic
  --

  dtackn <= sdram_dtackn;
  d_i <=  ram_d_o(0) when a_ext(core)(18 downto 17) = "00" else
          ram_d_o(1) when a_ext(core)(18 downto 17) = "01" else
          sdram_i.d(d_i'range);

  BLK_SDRAM : block
  begin

    sdram_o.clk <= clk_25M;
    sdram_o.rst <= rst_25M;
    
    -- map 128KB BIOS, 64KiB RAM, 64KiB SRAM, 4KiB MEMCARD into 1st MiB
    -- map 1MB ROM1 (P1) into 2nd MiB
    sdram_o.a(sdram_o.a'left downto 22) <= (others => '0');
    sdram_o.a(21 downto 18) <= a_ext(core)(20 downto 17);
    sdram_o.a(17 downto 2) <= a_ext(core)(16 downto 1);
    sdram_o.d <= X"0000" & d_o(core);
    sdram_o.sel <= "00" & not (udsn(core) & ldsn(core));
    sdram_o.we <= not rwn(core);

    process (clk_25M, rst_25M)
      variable cyc_r : std_logic := '0';
    begin
      if rst_25M = '1' then
        cyc_r := '0';
      elsif rising_edge(clk_25M) then
        -- assert WB cyc,stb on rising edge of 68k cycle
        if cyc_r = '0' and asn(core) = '0' then
          sdram_o.cyc <= '1';
          sdram_o.stb <= '1';
        -- de-assert WB cyc,stb immediately on ACK from sdram controller
        elsif sdram_i.ack = '1' then
          sdram_o.cyc <= '0';
          sdram_o.stb <= '0';
        end if;
        -- Ensure that ~12MHz 68k sees DTACKn asserted
        if sdram_i.ack = '1' then
          sdram_dtackn <= '0';
        elsif clk_12M_ena = '1' then
          sdram_dtackn <= '1';
        end if;
        cyc_r := not asn(core);
      end if;
    end process;
    
  end block BLK_SDRAM;

  --
  -- interrupts
  --
  process (clk_25M, rst_25M)
    variable vblank_r : std_logic := '0';
    variable irq_r    : std_logic_vector(1 to 3) := (others => '0');
  begin
    if rst_25M = '1' then
      vblank_r := '0';
    elsif rising_edge(clk_25M) then
      if wr_p = '1' then
        if reg_3C_cs = '1' and a_ext(core)(7 downto 1) = "0000110" then
          -- IRQACK - write a '1' to ACK
          irq_r := irq_r and not (d_o(core)(2) & d_o(core)(1) & d_o(core)(0));
        end if;
      end if;
      -- latch interrupt on rising edge vblank
      if vblank_r = '0' and graphics_i.vblank = '1' then
        irq_r(1) := '1';
      end if;
      vblank_r := graphics_i.vblank;
    end if;
    -- priority-encoded interrupts
    if irq_r(3) = '1' then
      ipln <= not "011";      -- cold boot
    elsif irq_r(2) = '1' then
      ipln <= not "010";      -- display position
    elsif irq_r(1) = '1' then
      ipln <= not "001";      -- vblank
    else
      ipln <= not "000";
    end if;
  end process;
  
  --
  -- COMPONENT INSTANTIATION
  --

  GEN_CORES : for i in 0 to N_CORES-1 generate
  begin
  
    ena(i) <= clk_12M_ena when core = i else '0';
    
    tg68_inst : entity work.TG68
      port map
      (        
        clk           => clk_25M,
        reset         => reset_neogeo_n, -- active low
        clkena_in     => ena(i),
        data_in       => d_i,
        IPL           => ipln,
        dtack         => dtackn,
        addr          => a_ext(i),
        data_out      => d_o(i),
        as            => asn(i),
        uds           => udsn(i),
        lds           => ldsn(i),
        rw            => rwn(i)
      );
  end generate GEN_CORES;
  
  GEN_RAM : for i in 0 to N_RAMS-1 generate
    component onchip_ram
      PORT
      (
        clock		  : IN STD_LOGIC  := '1';
        address	  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        data		  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        wren		  : IN STD_LOGIC ;
        q		      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
      );
    end component;
    signal we : std_logic_vector(0 to N_RAMS-1);
  begin
    we(i) <= not rwn(core) 
              when i = to_integer(unsigned(a_ext(core)(18 downto 17)))
              else '0';
    ram_inst : onchip_ram
      port map
      (
        clock		  => clk_25M,
        address	  => a_ext(core)(16 downto 1),
        data		  => d_o(core),
        wren		  => we(i),
        q		      => ram_d_o(i)
      );
  end generate GEN_RAM;
  
  --
  -- unused outputs
  --
  
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  graphics_o.bit8(0) <= (others => '0');
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  --leds_o <= (others => '0');
  
end SYN;
