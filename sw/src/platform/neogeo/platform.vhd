library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.sdram_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

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
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

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

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );

end platform;

architecture SYN of platform is

	alias clk_25M           : std_logic is clk_i(1);
	alias clk_video         : std_logic is clk_i(1);
	alias clk_27M           : std_logic is clk_i(3);
	signal clk_12M_ena      : std_logic := '0';
	
	signal reset_neogeo_n   : std_logic := '1';
	signal a_ext            : std_logic_vector(31 downto 0) := (others => '0');
	alias a                 : std_logic_vector(23 downto 1) is a_ext(23 downto 1);
  signal d_i              : std_logic_vector(15 downto 0) := (others => '0');
  signal d_o              : std_logic_vector(15 downto 0) := (others => '0');
  signal dtackn           : std_logic := '0';
  signal asn              : std_logic := '0';
  signal udsn             : std_logic := '0';
  signal ldsn             : std_logic := '0';
  signal rwn              : std_logic := '0';
  signal ipln             : std_logic_vector(2 downto 0) := (others => '1');
  -- write pulse (100MHz) - "fixed" from TG68 core
  signal wr_p             : std_logic;

  -- cpu vector table
  signal vector_cs        : std_logic := '0';
  signal vector_d_o       : std_logic_vector(d_i'range) := (others => '0');
  
  -- cartridge rom
  signal rom1_cs          : std_logic := '0';
  signal rom1_d_o         : std_logic_vector(d_i'range) := (others => '0');

  -- cpu work ram
  signal ram_cs           : std_logic := '0';
  signal ram_d_o          : std_logic_vector(d_i'range) := (others => '0');

  -- hardware registers
  signal reg_cs           : std_logic := '0';
  signal reg_d_o          : std_logic_vector(d_i'range) := (others => '0');
  signal reg_30_cs        : std_logic := '0';
  signal reg_32_cs        : std_logic := '0';
  signal reg_34_cs        : std_logic := '0';
  signal reg_38_cs        : std_logic := '0';
  signal reg_3A_cs        : std_logic := '0';
  signal reg_3C_cs        : std_logic := '0';
  
  -- palette ram
  signal palram_cs        : std_logic := '0';
  signal palram_wr        : std_logic := '0';
  signal palram_d_o       : std_logic_vector(d_i'range) := (others => '0');
  signal palette          : std_logic_vector(255 downto 0) := (others => '0');

  -- memory card
  signal memcard_cs       : std_logic := '0';
  signal memcard_d_o      : std_logic_vector(d_i'range) := (others => '0');

  -- system bios
  signal bios_cs          : std_logic := '0';
  signal bios_d_o         : std_logic_vector(d_i'range) := (others => '0');

  -- battery-back sram
  signal sram_cs          : std_logic := '0';
  signal sram_d_o         : std_logic_vector(d_i'range) := (others => '0');

  -- vram
  signal vram_d_o         : std_logic_vector(15 downto 0) := (others => '0');
  
  -- uPD4990A RTC chip
  signal upd4990a_cs      : std_logic := '0';
  signal upd4990a_d_o     : std_logic_vector(7 downto 6) := (others => '0');

  -- boot data storage (eg. DE1 flash) signals
  signal bootdata_cs      : std_logic := '0';
  signal bootdata_d_o     : std_logic_vector(d_i'range) := (others => '0');
  
  -- sprite data (used during boot) signals
  signal sprdat_cs        : std_logic := '0';
  signal sprdat_d_o       : std_logic_vector(d_i'range) := (others => '0');
  
  -- boot rom signals
  signal bootrom_cs       : std_logic := '0';
  signal bootrom_d_o      : std_logic_vector(d_i'range) := (others => '0');

  -- hardware registers
  signal reg_swp          : std_logic := '0'; -- bios/cart vectors
  signal reg_fix          : std_logic := '0'; -- brd/cart fix layer
  
  -- "magic" register
  signal magic_r          : std_logic_vector(15 downto 0) := (others => '0');
  alias boot_f            : std_logic is magic_r(0);    -- booting
  alias bootdata_f        : std_logic is magic_r(1);    -- bootdata store enabled
  alias bootbank          : std_logic_vector(21 downto 20) is magic_r(3 downto 2);
  signal delayed_dtackn   : std_logic := '1';
  signal sdram_dtackn     : std_logic := '1';
  
begin

  --
  -- clocking
  --
  
  process (clk_25M, reset_i)
    variable count : std_logic_vector(2 downto 0) := (others => '0');
  begin
    if reset_i = '1' then
      count := (others => '0');
    elsif rising_edge(clk_25M) then
      clk_12M_ena <= '0'; -- default
      if count(0) = '0' then
        clk_12M_ena <= '1';
      end if;
      count := count + 1;
    end if;
  end process;
  
  --
  -- address decode logic
  --
  
  -- vectors 128 bytes
  vector_cs   <= '1' when STD_MATCH(a, X"0000" & "0------") else '0';
  -- rombank_1 $000000-$0FFFFF (1MiB)
  rom1_cs     <= '1' when STD_MATCH(a, X"0" & "-------------------") else '0';
  -- rambank $100000-$10FFFF (64KiB)
  ram_cs      <= '1' when STD_MATCH(a, X"10" & "---------------") else '0';
  -- hardware registers $300000-$3FFFFF
  reg_cs      <= '1' when STD_MATCH(a, X"3" & "-------------------") else '0';
  reg_30_cs   <= reg_cs when a(19 downto 17) = "000" else '0';
  reg_32_cs   <= reg_cs when a(19 downto 17) = "001" else '0';
  reg_34_cs   <= reg_cs when a(19 downto 17) = "010" else '0';
  reg_38_cs   <= reg_cs when a(19 downto 17) = "100" else '0';
  upd4990a_cs <= reg_38_cs when a(7 downto 4) = X"5" else '0';
  reg_3A_cs   <= reg_cs when a(19 downto 17) = "101" else '0';
  reg_3C_cs   <= reg_cs when a(19 downto 17) = "110" else '0';
  -- palette ram $400000-$401FFF (8KiB)
  palram_cs   <= '1' when STD_MATCH(a, X"40" & "000------------") else '0';
  -- memcard ram $800000-$800FFF (4KiB)
  memcard_cs  <= '1' when STD_MATCH(a, X"800" & "-----------") else '0';
  -- system_bios $C00000-$C1FFFF (128kiB)
  bios_cs     <= '1' when STD_MATCH(a, X"C" & "000----------------") else '0';
  -- battery-backed sram $D00000-$D0FFFF (64kiB)
  sram_cs     <= '1' when STD_MATCH(a, X"D0" & "---------------") else '0';
  -- bootdata $E00000-$EFFFFF (1MiB)
  bootdata_cs <= '1' when STD_MATCH(a, X"E" & "-------------------") else '0';
  -- sprite data $F00000-$F7FFFF (512kiB)
  sprdat_cs   <= '1' when STD_MATCH(a, X"F" & "0------------------") else '0';
  -- boot rom $FF0000-$FFFFFF (64kiB)
  bootrom_cs  <= '1' when STD_MATCH(a, X"FF" & "---------------") else '0';

  -- writes
  palram_wr <= wr_p when (palram_cs = '1' and a(12 downto 9) = "0000") else '0';

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
        if wr_r = '0' and asn = '0' and rwn = '0' then
          wr_p <= '1';
        end if;
        wr_r := not (asn or rwn);
      end if;
    end if;
  end process;

  --
  -- dtack logic
  --
  
  process (clk_25M)
    variable asn_r : std_logic_vector(10 downto 0) := (others => '1');
  begin
    if reset_neogeo_n = '0' then
      asn_r := (others => '1');
    elsif rising_edge(clk_25M) and clk_12M_ena = '1' then
      delayed_dtackn <= asn_r(2);
      -- de-assertion immediately clears the pipeline
      if asn = '1' then
        asn_r := (others => '1');
      else
        asn_r := asn_r(asn_r'left-1 downto 0) & asn;
      end if;
    end if;
  end process;

  dtackn <= delayed_dtackn when bootdata_f = '1' and bootdata_cs = '1' else
            sdram_dtackn when (bios_cs or ram_cs or sram_cs or memcard_cs or rom1_cs) = '1' else
            asn;

  --
  -- read muxes
  --
  
  BLK_READ_MUX : block
    signal sysstat_a  : std_logic_vector(7 downto 0) := (others => '0');
    signal sysstat_b  : std_logic_vector(7 downto 0) := (others => '0');
  begin
  
    d_i <=  vector_d_o when vector_cs = '1' else
            rom1_d_o when rom1_cs = '1' else
            ram_d_o when ram_cs = '1' else
            reg_d_o when reg_cs = '1' else
            palram_d_o when palram_cs = '1' else
            memcard_d_o when memcard_cs = '1' else
            bios_d_o when bios_cs = '1' else
            sram_d_o when sram_cs = '1' else
            bootdata_d_o when bootdata_cs = '1' else
            sprdat_d_o when sprdat_cs = '1' else
            bootrom_d_o when bootrom_cs = '1' else
            (others => '1');

    vector_d_o <= bootrom_d_o when boot_f = '1' else
                  -- bios_d_o & rom_d_o come from the same source
                  -- so it doesn't matter which we use
                  bios_d_o;

    reg_d_o <=  inputs_i(0).d & not switches_i(7 downto 0) when reg_30_cs = '1' else
                inputs_i(1).d & inputs_i(1).d when reg_34_cs = '1' else
                sysstat_a & sysstat_a when reg_32_cs = '1' else
                sysstat_b & sysstat_b when reg_38_cs = '1' else
                vram_d_o when reg_3C_cs = '1' else
                (others => '1');
                
    sysstat_a <= upd4990a_d_o(7 downto 6) & "11" & inputs_i(2).d(3 downto 0);
    sysstat_b <= "1111" & inputs_i(3).d(3 downto 0);
    
  end block BLK_READ_MUX;

  BLK_FLASH : block
    signal tile_a_r : std_logic_vector(17 downto 0) := (others => '0');
    signal tile_a_rr : std_logic_vector(17 downto 0) := (others => '0');
  begin

    --
    -- on-board flash
    -- mapped into 68k address space for boot rom
    -- then mapped out for tile rom
    --
    
    -- emulate synchronous clocked internal ram for timing in tilemap controller
    process (clk_video)
    begin
      if rising_edge(clk_video) then
        tile_a_rr <= tile_a_r;
        tile_a_r(17) <= reg_fix;
        tile_a_r(16 downto 0) <= tilemap_i.tile_a(16 downto 0);
      end if;
    end process;
    
    flash_o.a <=  bootbank & a(19 downto 1) & ldsn when bootdata_f = '1' else
                  std_logic_vector(resize(unsigned(tile_a_r),flash_o.a'length));
    flash_o.d <= (others => '0');
    flash_o.cs <= '1';
    flash_o.oe <= '1';
    flash_o.we <= '0';

    bootdata_d_o <= flash_i.d(7 downto 0) & flash_i.d(7 downto 0);
    tilemap_o.tile_d <= flash_i.d(7 downto 0);

  end block BLK_FLASH;
  
  BLK_SRAM : block
  begin
  
    --
    -- on-board SRAM
    -- sprite data
    --
    sram_o.a <= std_logic_vector(resize(unsigned(a(18 downto 1)), sram_o.a'length));
    sram_o.d <= std_logic_vector(resize(unsigned(d_o), sram_o.d'length));
    sram_o.be <= "00" & not udsn & not ldsn;
    sram_o.cs <=  sprdat_cs;
    sram_o.oe <= rwn;
    sram_o.we <= wr_p;

    sprdat_d_o <= sram_i.d(sprdat_d_o'range);
    
  end block BLK_SRAM;

  BLK_SDRAM : block
  begin

    sdram_o.clk <= clk_25M;
    sdram_o.rst <= reset_i;
    
    -- map 128KB BIOS, 64KiB RAM, 64KiB SRAM, 4KiB MEMCARD into 1st MiB
    -- map 1MB ROM1 (P1) into 2nd MiB
    sdram_o.a(sdram_o.a'left downto 22) <= (others => '0');
    sdram_o.a(21 downto 18) <= reg_swp & '0' & "00" when vector_cs = '1' else
                              "0000" when bios_cs = '1' else
                              "0010" when ram_cs = '1' else
                              "0011" when sram_cs = '1' else
                              "0100" when memcard_cs = '1' else
                              '1' & a(19 downto 17) when rom1_cs = '1' else
                              (others => '1');
    sdram_o.a(17 downto 2) <= a(16 downto 1);
    sdram_o.d <= X"0000" & d_o;
    sdram_o.sel <= "00" & not (udsn & ldsn);
    sdram_o.we <= not rwn;

    process (clk_25M, reset_i)
      variable cyc_r : std_logic := '0';
    begin
      if reset_i = '1' then
        cyc_r := '0';
      elsif rising_edge(clk_25M) then
        -- assert WB cyc,stb on rising edge of 68k cycle
        if cyc_r = '0' and ((bios_cs or ram_cs or sram_cs or memcard_cs or rom1_cs) = '1') and 
            asn = '0' then
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
        cyc_r := not asn;
      end if;
    end process;
    
    bios_d_o <= sdram_i.d(bios_d_o'range);
    ram_d_o <= sdram_i.d(ram_d_o'range);
    sram_d_o <= sdram_i.d(sram_d_o'range);
    memcard_d_o <= sdram_i.d(memcard_d_o'range);
    rom1_d_o <= sdram_i.d(rom1_d_o'range);

  end block BLK_SDRAM;

  GEN_NOT : if false generate
    assert false
      report "this won't work on stock DE1 hardware"
        severity warning;
    -- hook up Burched SRAM module
    GEN_D: for i in 0 to 15 generate
      --ram_d_o(i) <= gp_i(35-i);
      gp_o.d(35-i) <= d_o(i);
    end generate;
    GEN_A: for i in 0 to 14 generate
      gp_o.d(17-i) <= a(1+i);
    end generate;
    gp_o.d(2) <= sram_cs;                 -- A15
    gp_o.d(1) <= '0';                     -- A16
    gp_o.d(0) <= not (ram_cs or sram_cs); -- CEAn
    gp_o.d(18) <= udsn or not wr_p;       -- upper byte WEn
    gp_o.d(19) <= ldsn or not wr_p;       -- lower byte WEn
  end generate GEN_NOT;
  
  --
  -- hardware registers
  --

  -- magic register
  process (clk_25M, reset_i)
    variable ng_reset_cnt : integer range 0 to 4 := 0;
  begin
    if reset_i = '1' then
      reset_neogeo_n <= '0';
      ng_reset_cnt := 0;
      boot_f <= '1';
      bootdata_f <= '1';
    elsif rising_edge(clk_25M) then
      if bootrom_cs = '1' then
        if wr_p = '1' then
					-- write a '1' to reset the boot flags
					-- - boot flags can never be set (again)
          magic_r(1 downto 0) <= magic_r(1 downto 0) and not d_o(1 downto 0);
          -- - other bits can be set or reset as required
          magic_r(magic_r'left downto 2) <= d_o(d_o'left downto 2);
          -- handle write to reset bit
          if d_o(0) = '1' then
            -- drive neogeo reset
            ng_reset_cnt := ng_reset_cnt'high;
          end if;
        end if;
      end if;
      if ng_reset_cnt = 0 then
        reset_neogeo_n <= '1';
      else
        reset_neogeo_n <= '0';
        ng_reset_cnt := ng_reset_cnt - 1;
      end if;
    end if;
  end process;
  
  -- $3A hardware registers process
  process (clk_25M, reset_i)
  begin
    if reset_i = '1' then
      reg_swp <= '0'; -- bios
      reg_fix <= '0'; -- brd
    elsif rising_edge(clk_25M) then
      if reg_3A_cs = '1' then
        if wr_p = '1' then
          case a(3 downto 1) is
            when "001" => -- 00x3
              reg_swp <= a(4);
            when "101" => -- 00xA
              reg_fix <= a(4);
            when others =>
              null;
          end case;
        end if;
      end if;
    end if;
  end process;
  
  --
  -- interrupts
  --
  process (clk_25M, reset_i)
    variable vblank_r : std_logic := '0';
    variable irq_r    : std_logic_vector(1 to 3) := (others => '0');
  begin
    if reset_i = '1' then
      vblank_r := '0';
    elsif rising_edge(clk_25M) then
      if wr_p = '1' then
        if reg_3C_cs = '1' and a(7 downto 1) = "0000110" then
          -- IRQACK - write a '1' to ACK
          irq_r := irq_r and not (d_o(2) & d_o(1) & d_o(0));
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

  tg68_inst : entity work.TG68
    port map
    (        
      clk           => clk_25M,
      reset         => reset_neogeo_n, -- active low
      clkena_in     => clk_12M_ena,
      data_in       => d_i,
      IPL           => ipln,
      dtack         => dtackn,
      addr          => a_ext,
      data_out      => d_o,
      as            => asn,
      uds           => udsn,
      lds           => ldsn,
      rw            => rwn
    );

  BLK_VRAM : block

    signal vram_a         : std_logic_vector(15 downto 0) := (others => '0');
    signal vram_d_i       : std_logic_vector(15 downto 0) := (others => '0');
    signal vram_wr        : std_logic := '0';

    signal scb1_cs        : std_logic := '0';
    signal vram_scb1_d_o  : std_logic_vector(15 downto 0) := (others => '0');
    signal scb3_cs        : std_logic := '0';
    signal vram_scb3_d_o  : std_logic_vector(15 downto 0) := (others => '0');
    signal scb4_cs        : std_logic := '0';
    signal vram_scb4_d_o  : std_logic_vector(15 downto 0) := (others => '0');

    signal fix1_cs        : std_logic := '0';
    signal vram_fix1_d_o  : std_logic_vector(15 downto 0) := (others => '0');
    signal fix2_cs        : std_logic := '0';
    signal vram_fix2_d_o  : std_logic_vector(15 downto 0) := (others => '0');

  begin
  
    -- vram process
    process (clk_25M, reset_i)
      variable rwn_r    : std_logic := '0';
      variable vram_mod : std_logic_vector(15 downto 0) := (others => '0');
    begin
      if reset_neogeo_n = '0' then
        rwn_r := '0';
        vram_mod := (others => '0');
      elsif rising_edge(clk_25M) then --and clk_12M_ena = '1' then
        vram_wr <= '0'; -- default
        if reg_3C_cs = '1' then
          --if rwn_r = '1' and rwn = '0' then
          if wr_p = '1' then
            -- leading edge write
            case a(7 downto 1) is
              when "0000000" =>
                -- write vram address register
                vram_a <= d_o;
              when "0000001" =>
                -- write vram data register
                -- $7000-$74FF fixed tile layer
                if vram_a(15 downto 11) = "01110" and
                    (vram_a(10) = '0' or vram_a(10 downto 8) = "100") then
                  vram_d_i <= d_o;
                  vram_wr <= '1';
                end if;
              when "0000010" =>
                -- write vram inc register
                vram_mod := d_o;
              when others =>
                null;
            end case;
          --elsif rwn_r = '0' and rwn = '1' then
          elsif rwn_r = '1' and wr_p = '0' then
            -- trailing edge write
            if a(7 downto 1) = "0000001" then
              -- bit 15 is not used for auto-inc/dec
              vram_a(14 downto 0) <= vram_a(14 downto 0) + vram_mod(14 downto 0);
            end if;
          end if;
        end if;
        rwn_r := wr_p; --rwn;
      end if;
    end process;

    vram_d_o <= vram_scb1_d_o when scb1_cs = '1' else
                vram_fix1_d_o when fix1_cs = '1' else
                vram_fix2_d_o when fix2_cs = '1' else
                vram_scb3_d_o when scb3_cs = '1' else
                vram_scb4_d_o when scb4_cs = '1' else
                (others => '0');

    BLK_SPRITES : block
    
      signal vram_scb1_wr   : std_logic := '0';
      signal scb1_d_o       : std_logic_vector(15 downto 0) := (others => '0');
      
      signal vram_scb3_wr   : std_logic := '0';
      signal scb3_d_o       : std_logic_vector(15 downto 0) := (others => '0');
      
      signal vram_scb4_wr   : std_logic := '0';
      signal scb4_d_o       : std_logic_vector(15 downto 0) := (others => '0');
      
    begin

      -- $0000-$6FFF ($0000-$03FF for now)
      scb1_cs <= '1' when STD_MATCH(vram_a, X"0" & "00----------") else '0';
      -- $8200-$83FF ($8200-$821F for now)
      scb3_cs <= '1' when STD_MATCH(vram_a, X"82" & "000-----") else '0';
      -- $8400-$85FF ($8400-$841F for now)
      scb4_cs <= '1' when STD_MATCH(vram_a, X"84" & "000-----") else '0';

      vram_scb1_wr <= vram_wr and scb1_cs;
      vram_scb3_wr <= vram_wr and scb3_cs;
      vram_scb4_wr <= vram_wr and scb4_cs;

      -- Sprite Control Block 1 (name tables) $0000-$7FFF
      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      scb1_inst : entity work.dpram
        generic map
        (
          --init_file		=> "../../../../src/platform/neogeo/roms/vram1.hex",
          numwords_a	=> 32*32, -- only 32 sprites for now
          widthad_a		=> 10,
          width_a     => 16
        )
        port map
        (
          clock_b			=> clk_25M,
          address_b		=> vram_a(9 downto 0),
          wren_b			=> vram_scb1_wr,
          data_b			=> vram_d_i,
          q_b					=> vram_scb1_d_o,

          clock_a		  => clk_video,
          address_a		=> sprite_i.a(9 downto 0),
          data_a		  => (others => '0'),
          wren_a		  => '0',
          q_a		      => scb1_d_o
        );

      -- Sprite Control Block 3 (Y) $8200-$83FF
      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      scb3_inst : entity work.dpram
        generic map
        (
          --init_file		=> "../../../../src/platform/neogeo/roms/vram1.hex",
          numwords_a	=> 32,  -- only 32 sprites for now
          widthad_a		=> 5,
          width_a     => 16
        )
        port map
        (
          clock_b			=> clk_25M,
          address_b		=> vram_a(4 downto 0),
          wren_b			=> vram_scb3_wr,
          data_b			=> vram_d_i,
          q_b					=> vram_scb3_d_o,

          clock_a		  => clk_video,
          address_a		=> sprite_i.a(4 downto 0),
          data_a		  => (others => '0'),
          wren_a		  => '0',
          q_a		      => scb3_d_o
        );
        
      -- Sprite Control Block 4 (X) $8400-$85FF
      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      scb4_inst : entity work.dpram
        generic map
        (
          --init_file		=> "../../../../src/platform/neogeo/roms/vram1.hex",
          numwords_a	=> 32,  -- only 32 sprites for now
          widthad_a		=> 5,
          width_a     => 16
        )
        port map
        (
          clock_b			=> clk_25M,
          address_b		=> vram_a(4 downto 0),
          wren_b			=> vram_scb4_wr,
          data_b			=> vram_d_i,
          q_b					=> vram_scb4_d_o,

          clock_a		  => clk_video,
          address_a		=> sprite_i.a(4 downto 0),
          data_a		  => (others => '0'),
          wren_a		  => '0',
          q_a		      => scb4_d_o
        );
        
    end block BLK_SPRITES;
    
    BLK_FIXED : block
    
      signal vram_fix1_wr   : std_logic := '0';
      signal fix1_d_o       : std_logic_vector(15 downto 0) := (others => '0');
      signal map1_d_o       : std_logic_vector(15 downto 0) := (others => '0');
      
      signal vram_fix2_wr   : std_logic := '0';
      signal fix2_d_o       : std_logic_vector(15 downto 0) := (others => '0');
      signal map2_d_o       : std_logic_vector(15 downto 0) := (others => '0');
    
    begin

      -- $7000-$7400
      fix1_cs <= '1' when STD_MATCH(vram_a, X"7" & "00----------") else '0';
      -- $7400-$74FF
      fix2_cs <= '1' when STD_MATCH(vram_a, X"74" & "--------") else '0';

      vram_fix1_wr <= vram_wr and fix1_cs;
      vram_fix2_wr <= vram_wr and fix2_cs;

      -- fixed layer graphics (part1) $7000-$7400
      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      fix1_inst : entity work.dpram
        generic map
        (
          init_file		=> "../../../../src/platform/neogeo/rams/fix1.hex",
          numwords_a	=> 1024,
          widthad_a		=> 10,
          width_a     => 16
        )
        port map
        (
          clock_b			=> clk_25M,
          address_b		=> vram_a(9 downto 0),
          wren_b			=> vram_fix1_wr,
          data_b			=> vram_d_i,
          q_b					=> vram_fix1_d_o,

          clock_a			=> clk_video,
          address_a		=> tilemap_i.map_a(9 downto 0),
          wren_a			=> '0',
          data_a			=> (others => 'X'),
          q_a					=> map1_d_o
        );
        
      -- fixed layer graphics (part2) $7400-$74FF
      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      fix2_inst : entity work.dpram
        generic map
        (
          init_file		=> "../../../../src/platform/neogeo/rams/fix2.hex",
          numwords_a	=> 256,
          widthad_a		=> 8,
          width_a     => 16
        )
        port map
        (
          clock_b			=> clk_25M,
          address_b		=> vram_a(7 downto 0),
          wren_b			=> vram_fix2_wr,
          data_b			=> vram_d_i,
          q_b					=> vram_fix2_d_o,

          clock_a			=> clk_video,
          address_a		=> tilemap_i.map_a(7 downto 0),
          wren_a			=> '0',
          data_a			=> (others => 'X'),
          q_a					=> map2_d_o
        );

      tilemap_o.map_d <=  map1_d_o(15 downto 0) when tilemap_i.map_a(10) = '0' else 
                          map2_d_o(15 downto 0);

    end block BLK_FIXED;

  end block BLK_VRAM;
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  palram_inst : entity work.palram
    port map
    (
      clock_b		  => clk_25M,
      address_b		=> a(8 downto 1),
      data_b		  => d_o,
      wren_b		  => palram_wr,
      q_b		      => palram_d_o,

      clock_a		  => clk_video,
      address_a		=> tilemap_i.attr_a(3 downto 0),
      data_a		  => (others => '0'),
      wren_a		  => '0',
      q_a		      => palette
    );
  tilemap_o.attr_d <= (others => '0');
  
  GEN_PAL_DATA : for i in 0 to 15 generate
    graphics_o.pal(i) <= palette(i*16+15 downto i*16);
  end generate GEN_PAL_DATA;

  -- bootrom.hex
  bootrom_inst : entity work.testram
    port map
    (
      clock		    => clk_25M,
      address		  => a(11 downto 1),
      data		    => d_o,
      byteena     => "11",
      wren		    => '0',
      q		        => bootrom_d_o
    );

  upd4990a_inst : entity work.uPD4990A
    generic map
    (
      CLK_32K768_COUNT  => 25000000/32768
    )
    port map
    (
      clk_i             => clk_25M,
      clk_ena           => '1',
      reset             => reset_i,
      
      data_in           => d_o(0),
      clk               => d_o(1),
      c                 => "111",
      stb               => d_o(2),
      cs                => upd4990a_cs,
      out_enabl         => '1',
      
      data_out          => upd4990a_d_o(7),
      tp                => upd4990a_d_o(6)
    );

  -- for now, writes to $20000 are latched on the leds
  process (clk_25M)
  begin
    if rising_edge(clk_25M) then
      if wr_p = '1' and a(23 downto 20) = X"2" then
        leds_o(15 downto 0) <= d_o;
      end if;
    end if;
  end process;

  --
  -- unused outputs
  --
  
  bitmap_o <= NULL_TO_BITMAP_CTL;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  graphics_o.bit8_1 <= (others => '0');
  graphics_o.bit16_1 <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  --leds_o <= (others => '0');
  gp_o <= NULL_TO_GP;
  
end SYN;
