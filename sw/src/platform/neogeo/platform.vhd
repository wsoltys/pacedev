library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

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

	alias clk_100M        : std_logic is clk_i(1);  -- actually 25MHz
	alias clk_video       : std_logic is clk_i(1);
	alias clk_27M         : std_logic is clk_i(3);
	signal clk_12M_ena    : std_logic := '0';
	
	signal reset_n        : std_logic := '1';
	signal a_ext          : std_logic_vector(31 downto 0) := (others => '0');
	alias a               : std_logic_vector(23 downto 1) is a_ext(23 downto 1);
  signal d_i            : std_logic_vector(15 downto 0) := (others => '0');
  signal d_o            : std_logic_vector(15 downto 0) := (others => '0');
  signal dtackn         : std_logic := '0';
  signal asn            : std_logic := '0';
  signal udsn           : std_logic := '0';
  signal ldsn           : std_logic := '0';
  signal rwn            : std_logic := '0';
  -- write pulse (100MHz) - "fixed" from TG68 core
  signal wr_p           : std_logic;

  -- boor rom signals
  signal bootrom_cs     : std_logic := '0';
  signal bootrom_d_o    : std_logic_vector(d_i'range) := (others => '0');
  
  -- cpu vector table
  signal vector_cs      : std_logic := '0';
  signal vector_d_o     : std_logic_vector(d_i'range) := (others => '0');
  
  -- cartridge rom
  signal rom1_cs        : std_logic := '0';
  signal rom1_d_o       : std_logic_vector(d_i'range) := (others => '0');

  -- cpu work ram
  signal ram_cs         : std_logic := '0';
  signal ram_d_o        : std_logic_vector(d_i'range) := (others => '0');
  signal ram_wr         : std_logic := '0';

  -- hardware registers
  signal reg_cs         : std_logic := '0';
  signal reg_d_o        : std_logic_vector(d_i'range) := (others => '0');
  signal reg_30_cs      : std_logic := '0';
  signal reg_32_cs      : std_logic := '0';
  signal reg_34_cs      : std_logic := '0';
  signal reg_38_cs      : std_logic := '0';
  signal reg_3A_cs      : std_logic := '0';
  signal reg_3C_cs      : std_logic := '0';
  
  -- palette ram
  signal palram_cs      : std_logic := '0';
  signal palram_wr      : std_logic := '0';
  signal palram_d_o     : std_logic_vector(d_i'range) := (others => '0');
  signal palette        : std_logic_vector(255 downto 0) := (others => '0');

  -- memory card
  signal memcard_cs     : std_logic := '0';
  signal memcard_d_o    : std_logic_vector(d_i'range) := (others => '0');

  -- system bios
  signal bios_cs        : std_logic := '0';
  signal bios_d_o       : std_logic_vector(d_i'range) := (others => '0');

  -- battery-back sram
  signal sram_cs        : std_logic := '0';
  signal sram_d_o       : std_logic_vector(d_i'range) := (others => '0');

  signal vram_a         : std_logic_vector(15 downto 0) := (others => '0');
  signal vram_d_i       : std_logic_vector(d_o'range) := (others => '0');
  signal vram1_d_o      : std_logic_vector(d_i'range) := (others => '0');
  signal vram1_wr       : std_logic := '0';
  signal map1_d         : std_logic_vector(15 downto 0) := (others => '0');
  signal vram2_d_o      : std_logic_vector(d_i'range) := (others => '0');
  signal vram2_wr       : std_logic := '0';
  signal map2_d         : std_logic_vector(15 downto 0) := (others => '0');
  
begin

  reset_n <= not reset_i;
  
  --
  -- clocking
  --
  
  process (clk_100M, reset_i)
    variable count : std_logic_vector(2 downto 0) := (others => '0');
  begin
    if reset_i = '1' then
      count := (others => '0');
    elsif rising_edge(clk_100M) then
      clk_12M_ena <= '0'; -- default
      --if count = "000" then
      -- clk_100M is actually 25MHz, so 25/2=12.5MHz
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
  reg_3A_cs   <= reg_cs when a(19 downto 17) = "101" else '0';
  reg_3C_cs   <= reg_cs when a(19 downto 17) = "110" else '0';
  -- palette ram $400000-$401FFF (8KiB)
  palram_cs   <= '1' when STD_MATCH(a, X"40" & "000------------") else '0';
  -- memcard ram $800000-$800FFF (4KiB)
  memcard_cs  <= '1' when STD_MATCH(a, X"800" & "-----------") else '0';
  -- system_bios $C00000-$C1FFFF (128kiB)
  bios_cs     <= '1' when STD_MATCH(a, X"C" & "000----------------") else '0';
  -- battery-backed sram $D00000-$D0FFFF (64kB)
  sram_cs     <= '1' when STD_MATCH(a, X"D0" & "---------------") else '0';
  -- boot rom $F00000-$FFFFFF (1MiB)
  bootrom_cs  <= '1' when STD_MATCH(a, X"F" & "-------------------") else '0';

  --
  -- wr_p and dtack logic
  --
  
  process (clk_100M)
    variable wr_r : std_logic;
  begin
    if rising_edge(clk_100M) then
      dtackn <= asn;
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
  -- read muxes
  --
  
  d_i <=  vector_d_o when vector_cs = '1' else
          rom1_d_o when rom1_cs = '1' else
          ram_d_o when ram_cs = '1' else
          reg_d_o when reg_cs = '1' else
          palram_d_o when palram_cs = '1' else
          memcard_d_o when memcard_cs = '1' else
          bios_d_o when bios_cs = '1' else
          sram_d_o when sram_cs = '1' else
          bootrom_d_o when bootrom_cs = '1' else
          (others => '1');

  reg_d_o <=  vram1_d_o when (reg_3C_cs = '1' and vram_a(10) = '0') else
              vram2_d_o when (reg_3C_cs = '1' and vram_a(10) = '1') else
              (others => '1');

  --
  --  vectors
  --
  
  -- to be changed!
  vector_d_o <= bootrom_d_o;

  --
  -- cpu work ram (in burched sram atm)
  --
  
  assert false
    report "this won't work on stock DE1 hardware"
      severity warning;
  -- hook up Burched SRAM module
  GEN_D: for i in 0 to 15 generate
    ram_d_o(i) <= gp_i(35-i);
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

  --
  -- hardware registers
  --

  -- vram process
  process (clk_100M, reset_i)
    variable rwn_r    : std_logic := '0';
    variable vram_inc : std_logic_vector(vram_a'range) := (others => '0');
  begin
    if reset_i = '1' then
      rwn_r := '0';
      vram_inc := (others => '0');
    elsif rising_edge(clk_100M) then --and clk_12M_ena = '1' then
      vram1_wr <= '0'; -- default
      vram2_wr <= '0'; -- default
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
                vram1_wr <= not vram_a(10);
                vram2_wr <= vram_a(10);
              end if;
            when "0000010" =>
              -- write vram inc register
              vram_inc := d_o;
            when others =>
              null;
          end case;
        --elsif rwn_r = '0' and rwn = '1' then
        elsif rwn_r = '1' and wr_p = '0' then
          -- trailing edge write
          if a(7 downto 1) = "0000001" then
            vram_a <= vram_a + vram_inc;
          end if;
        end if;
      end if;
      rwn_r := wr_p; --rwn;
    end if;
  end process;

  --
  -- system bios in flash atm
  --

  BLK_SDRAM : block
  begin
  
    sdram_o.a <= a(22 downto 1);
    sdram_o.d <= d_o;
    --dtackn <= sdram_i.waitrequest;
    sdram_o.cs <= bios_cs;
    sdram_o.be_n <= udsn & ldsn;
    sdram_o.rd_n <= not rwn;
    sdram_o.wr_n <= rwn;
    bios_d_o <= sdram_i.d;
    --sdram_i.valid;

  end block BLK_SDRAM;
  
  --
  -- battery-backed sram also stored in burched sram
  --
  sram_d_o <= ram_d_o;

  -- tile data in sram
  -- - emulate synchronous clocked internal ram for timing in tilemap controller
  process (clk_video)
  begin
    if rising_edge(clk_video) then
      sram_o.a <= std_logic_vector(resize(unsigned(tilemap_i.tile_a(16 downto 0)), sram_o.a'length));
    end if;
  end process;
  tilemap_o.tile_d <= sram_i.d(7 downto 0);
  sram_o.be <= std_logic_vector(to_unsigned(3, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= '1';
  sram_o.we <= '0';
  
  --
  -- COMPONENT INSTANTIATION
  --

  tg68_inst : entity work.TG68
    port map
    (        
      clk           => clk_100M,
      reset         => reset_n, -- active low
      clkena_in     => clk_12M_ena,
      data_in       => d_i,
      IPL           => "111",
      dtack         => dtackn,
      addr          => a_ext,
      data_out      => d_o,
      as            => asn,
      uds           => udsn,
      lds           => ldsn,
      rw            => rwn
    );

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram1_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/neogeo/roms/vram1.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10,
			width_a     => 16
		)
		port map
		(
			clock_b			=> clk_100M,
			address_b		=> vram_a(9 downto 0),
			wren_b			=> vram1_wr,
			data_b			=> vram_d_i,
			q_b					=> vram1_d_o,

			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> map1_d
		);
		
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram2_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/neogeo/roms/vram2.hex",
			numwords_a	=> 256,
			widthad_a		=> 8,
			width_a     => 16
		)
		port map
		(
			clock_b			=> clk_100M,
			address_b		=> vram_a(7 downto 0),
			wren_b			=> vram2_wr,
			data_b			=> vram_d_i,
			q_b					=> vram2_d_o,

			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(7 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> map2_d
		);

  tilemap_o.map_d <=  map1_d(7 downto 0) & map1_d(15 downto 8)
                        when tilemap_i.map_a(10) = '0' else 
                      map2_d(7 downto 0) & map2_d(15 downto 8);
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  palram_inst : entity work.palram
    port map
    (
      clock_b		  => clk_100M,
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

  GEN_PAL_DATA : for i in 0 to 15 generate
    graphics_o.pal(i) <= palette(i*16+15 downto i*16);
  end generate GEN_PAL_DATA;

  -- bootrom.hex
  bootrom_inst : entity work.testram
    port map
    (
      clock		    => clk_100M,
      address		  => a(11 downto 1),
      data		    => d_o,
      byteena     => "11",
      wren		    => '0',
      q		        => bootrom_d_o
    );

  -- for now, writes to $1000 are latched on the leds
  process (clk_100M)
  begin
    if rising_edge(clk_100M) then
      if wr_p = '1' and a(12) = '1' then
        leds_o(15 downto 0) <= d_o;
      end if;
    end if;
  end process;

  --
  -- unused outputs
  --
  
  bitmap_o <= NULL_TO_BITMAP_CTL;
  sprite_o.ld <= '0';
  graphics_o.bit8_1 <= (others => '0');
  graphics_o.bit16_1 <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  --leds_o <= (others => '0');

end SYN;
