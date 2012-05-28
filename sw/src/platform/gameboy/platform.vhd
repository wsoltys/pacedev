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

	alias clk_sys             : std_logic is clkrst_i.clk(0);
  alias rst_sys             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
  signal clk_4M19_en			  : std_logic;
	signal cpu_clk_en         : std_logic;
	signal cpu_mem_rd         : std_logic;
	signal cpu_mem_wr         : std_logic;
	signal cpu_io_rd          : std_logic;
	signal cpu_io_wr          : std_logic;
	signal cpu_a				      : std_logic_vector(15 downto 0);
	signal cpu_d_i			      : std_logic_vector(7 downto 0);
	signal cpu_d_o			      : std_logic_vector(7 downto 0);
	signal cpu_int_n				  : std_logic;
	signal cpu_int_ack			  : std_logic;
	signal cpu_int_vec        : std_logic_vector(7 downto 0);

  -- ROM signals        
	signal bootrom_cs				  : std_logic;
  signal bootrom_d_o        : std_logic_vector(7 downto 0);
	
  -- CART signals
  signal cart0_cs           : std_logic;
  signal cart0_d_o          : std_logic_vector(7 downto 0);
  signal cart4_cs           : std_logic;
  signal cart4_d_o          : std_logic_vector(7 downto 0);
  signal cartA_cs           : std_logic;
  signal cartA_wr           : std_logic;
  signal cartA_d_o          : std_logic_vector(7 downto 0);
  
    -- VIDEO RAM
	signal video_ram_cs				: std_logic;
  signal video_ram_d_o      : std_logic_vector(7 downto 0);

  -- SPRITE signals
  signal oam_cs             : std_logic;
  signal oam_wr             : std_logic;
  
  -- RAM signals        
	signal ramC_cs				    : std_logic;
  signal ramC_wr            : std_logic;
  signal ramC_d_o           : std_logic_vector(7 downto 0);
	signal ramF_cs				    : std_logic;
  signal ramF_wr            : std_logic;
  signal ramF_d_o           : std_logic_vector(7 downto 0);
  
  -- registers
  signal io_cs              : std_logic;
  signal io_d_o             : std_logic_vector(7 downto 0);
  signal ie_cs              : std_logic;
  -- individual registers
  signal p1_r               : std_logic_vector(7 downto 0);   -- $FF00
  signal tima_r             : std_logic_vector(7 downto 0);   -- $FF05
  signal tma_r              : std_logic_vector(7 downto 0);   -- $FF06
  signal tac_r              : std_logic_vector(7 downto 0);   -- $FF07
  signal if_r               : std_logic_vector(7 downto 0);   -- $FF0F
  signal lcdc_r             : std_logic_vector(7 downto 0);   -- $FF40
  signal stat_r             : std_logic_vector(7 downto 0);   -- $FF41
  signal scy_r              : std_logic_vector(7 downto 0);   -- $FF42
  signal scx_r              : std_logic_vector(7 downto 0);   -- $FF43
  signal lyc_r              : std_logic_vector(7 downto 0);   -- $FF45
  signal bootsel_r          : std_logic;                      -- $FF50
  signal ie_r               : std_logic_vector(7 downto 0);   -- $FFFF
  
  -- other signals   
	alias platform_rst			  : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	alias osd_toggle          : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(1);
	alias platform_pause      : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(2);
	
begin

  GEN_SRAM_IF : if false generate
  begin
    -- SRAM signals (may or may not be used)
    sram_o.a(sram_o.a'left downto 17) <= (others => '0');
    sram_o.a(16 downto 0)	<= 	std_logic_vector(resize(unsigned(cpu_a), 17));
    sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length)) 
                  when (ramC_wr = '1') else (others => 'Z');
    sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
    sram_o.cs <= '1';
    sram_o.oe <= not ramC_wr;
    sram_o.we <= ramC_wr;
  end generate GEN_SRAM_IF;
  
  BLK_DECODE : block
    signal mem_d_i    : std_logic_vector(7 downto 0);
    signal io_d_i     : std_logic_vector(7 downto 0);
  begin
  
    -- BOOTROM $0000-$00FF
    bootrom_cs <=   '1' when STD_MATCH(cpu_a,    X"00"&"--------") else 
                    '0';
    -- CART ROM (BANK 1) $0000-$3FFF
    cart0_cs <=     '1' when STD_MATCH(cpu_a,  "00--------------") else
                    '0';
    -- CART ROM (BANK 2) $4000-$7FFF
    cart4_cs <=     '1' when STD_MATCH(cpu_a,  "01--------------") else
                    '0';
    -- VIDEO RAM $8000-$9FFF
    video_ram_cs <= '1' when STD_MATCH(cpu_a,  "100-------------") else
                    '0';
    -- CART banked RAM $A000-$BFFF
    cartA_cs <=     '1' when STD_MATCH(cpu_a,  "101-------------") else
                    '0';
    -- RAM $C000-$DFFF (mirrored $E000-$FDFF)
    ramC_cs <=		  '1' when STD_MATCH(cpu_a,  "110-------------") else
                    '1' when STD_MATCH(cpu_a,  "111-------------") else
                    '0';
    -- OBJECT ATTRIBUTE (sprite) memory $FE00-$FE9F
    oam_cs <=       '1' when STD_MATCH(cpu_a,    X"FE"&"0-------") else
                    '1' when STD_MATCH(cpu_a,    X"FE"&"100-----") else
                    '0';
    -- sound and I/O registers $FF00-$FF7F
    io_cs <=        '1' when STD_MATCH(cpu_a,    X"FF"&"0-------") else
                    '0';
    -- RAM $FF80-$FFFF
    ramF_cs <=		  '1' when STD_MATCH(cpu_a,    X"FF"&"1-------") else
                    '0';
    ie_cs <=        '1' when STD_MATCH(cpu_a,             X"FFFF") else
                    '0';

    -- memory block write enables
    cartA_wr <= cartA_cs and cpu_clk_en and cpu_mem_wr;
    ramC_wr <= (ramC_cs and not oam_cs and not io_cs and not ramF_cs) 
                  and cpu_clk_en and cpu_mem_wr;
    oam_wr <= oam_cs and cpu_clk_en and cpu_mem_wr;
    ramF_wr <= (ramF_cs and cpu_clk_en and cpu_mem_wr) or
                -- fudge for broken LD($FF00+C),A
                (cpu_a(7) and cpu_clk_en and cpu_io_wr);

    mem_d_i <=  bootrom_d_o when (bootrom_cs = '1' and bootsel_r = '0') else
                cart0_d_o when cart0_cs = '1' else
                cart4_d_o when cart4_cs = '1' else
                video_ram_d_o when video_ram_cs = '1' else
                --cartA_d_o when cartA_cs = '1' else
                io_d_o when io_cs = '1' else
                ie_r when ie_cs = '1' else
                -- decode RAM blocks *after* ioreg, ie because it overlaps
                -- decode RAMF block before ramC block because they overlap
                ramF_d_o when ramF_cs = '1' else
                ramC_d_o when ramC_cs = '1' else
--                inputs_i(0).d when in0_cs = '1' else
--                inputs_i(1).d when in1_cs = '1' else
--                inputs_i(2).d when in2_cs = '1' else
                (others => '0');

    -- can do I/O to $FF00-$FFFF
    io_d_i <=   io_d_o when cpu_a(7) = '0' else
                ramF_d_o;
    
    -- memory read mux
    cpu_d_i <=  mem_d_i when cpu_mem_rd = '1' else
                io_d_i;
                
  end block BLK_DECODE;
  
  -- system timing
  -- sys_clk is 42MHz
  -- cpu_clk is 4.194304MHz
  process (clk_sys, rst_sys)
    variable count : integer range 0 to 10-1;
  begin
    if rst_sys = '1' then
      count := 0;
    elsif rising_edge(clk_sys) then
      clk_4M19_en <= '0'; -- default
      case count is
        when 0 =>
          clk_4M19_en <= '1';
        when others =>
          null;
      end case;
      if count = count'high then
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;

	cpu_clk_en <= clk_4M19_en and not platform_pause;

	-- add game reset later
	cpu_reset <= rst_sys or platform_rst;

  BLK_CPU : block
    signal m1_n     : std_logic;
    signal mreq_n   : std_logic;
    signal iorq_n   : std_logic;
    signal rd_n     : std_logic;
    signal wr_n     : std_logic;
    signal di       : std_logic_vector(7 downto 0);
  begin
  
	  cpu_mem_rd <= mreq_n nor rd_n;
	  cpu_mem_wr <= mreq_n nor wr_n;
    cpu_io_rd <= iorq_n nor rd_n;
    cpu_io_wr <= iorq_n nor wr_n;
    cpu_int_ack <= m1_n nor iorq_n;
    
    di <= cpu_int_vec when (cpu_mem_rd = '0' and cpu_io_rd = '0') else
          cpu_d_i;
    
    cpu_inst : entity work.GBse
      port map
      (
        RESET_n         => not cpu_reset,
        CLK_n           => clk_sys,
        CLKEN           => cpu_clk_en,
        WAIT_n          => '1',
        INT_n           => cpu_int_n,
        NMI_n           => '1',
        BUSRQ_n         => '1',
        M1_n            => m1_n,
        MREQ_n          => mreq_n,
        IORQ_n          => iorq_n,
        RD_n            => rd_n,
        WR_n            => wr_n,
        RFSH_n          => open,
        HALT_n          => open,
        BUSAK_n         => open,
        A               => cpu_a,
        DI              => di,
        DO              => cpu_d_o
      );
  end block BLK_CPU;
  
  dmg_rom_inst : entity work.sprom
    generic map
    (
      init_file		=> GAMEBOY_ROM_DIR & "dmg_rom.hex",
      widthad_a		=> 8
    )
    port map
    (
      clock			=> clk_sys,
      address		=> cpu_a(7 downto 0),
      q					=> bootrom_d_o
    );
                
	GEN_CART_ROM : if not GAMEBOY_CART_IN_FLASH generate
  begin
    cart0_inst : entity work.sprom
      generic map
      (
        init_file		=> GAMEBOY_CART_DIR & GAMEBOY_CART_NAME & ".hex",
        widthad_a		=> GAMEBOY_CART_WIDTHAD
      )
      port map
      (
        clock			=> clk_sys,
        address		=> cpu_a(GAMEBOY_CART_WIDTHAD-1 downto 0),
        q					=> cart0_d_o
      );
      cart4_d_o <= cart0_d_o;
  else generate
    flash_o.a <= std_logic_vector(resize(unsigned(cpu_a(GAMEBOY_CART_WIDTHAD-1 downto 0)),
                                          flash_o.a'length));
    flash_o.we <= '0';
    flash_o.cs <= '1';
    flash_o.oe <= '1';
    cart0_d_o <= flash_i.d(cart0_d_o'range);
	end generate GEN_CART_ROM;

  BLK_VRAM : block
  
    type bit_a is array (natural range <>) of std_logic;
    type byte_a is array (natural range <>) of std_logic_vector(7 downto 0);
    type word_a is array (natural range <>) of std_logic_vector(15 downto 0);
    
    signal tile_d_cs  : bit_a(0 to 2);
    signal tile_d_wr  : bit_a(0 to 2);
    signal tile_d_o   : byte_a(0 to 2);
    signal tile_d_q   : word_a(0 to 2);

    signal map_d_cs   : bit_a(0 to 1);
    signal map_d_wr   : bit_a(0 to 1);
    signal map_d_o    : byte_a(0 to 1);
    signal map_d_q    : byte_a(0 to 1);
    
  begin

    -- $8000-$87FF
    tile_d_cs(0) <= video_ram_cs when cpu_a(12 downto 11) = "00" else '0';
    -- $8800-$8FFF
    tile_d_cs(1) <= video_ram_cs when cpu_a(12 downto 11) = "01" else '0';
    -- $9000-$97FF
    tile_d_cs(2) <= video_ram_cs when cpu_a(12 downto 11) = "10" else '0';
    -- $9800-$9BFF
    map_d_cs(0) <= video_ram_cs when cpu_a(12 downto 10) = "110" else '0';
    -- $9C00-$9FFF
    map_d_cs(1) <= video_ram_cs when cpu_a(12 downto 10) = "111" else '0';

    video_ram_d_o <=  
      tile_d_o(0) when tile_d_cs(0) = '1' else
      tile_d_o(1) when tile_d_cs(1) = '1' else
      tile_d_o(2) when tile_d_cs(2) = '1' else
      map_d_o(0) when map_d_cs(0) = '1' else                      
      map_d_o(1);

    -- this register affects the tile addr generation
    graphics_o.bit8(0) <= lcdc_r;
    graphics_o.bit8(1) <= scy_r;
    graphics_o.bit8(2) <= scx_r;
    
    -- tile data mux
    tilemap_o(1).tile_d(15 downto 0) <=
      tile_d_q(0) when (lcdc_r(4) = '1' and tilemap_i(1).tile_a(11) = '0') else
      tile_d_q(2) when (lcdc_r(4) = '0' and tilemap_i(1).tile_a(11) = '1') else
      tile_d_q(1);

    -- tile map mux
    tilemap_o(1).map_d(7 downto 0) <= 
      map_d_q(0) when lcdc_r(3) = '0' else
      map_d_q(1);

    GEN_TILE_D_RAM : for i in 0 to 2 generate

      tile_d_wr(i) <= tile_d_cs(i) when cpu_mem_wr = '1' else '0';

      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      tile_d_inst : entity work.dpram_ex
        generic map
        (
          init_file		=> "",
          widthad_a		=> 10,
          width_a     => 16,
          widthad_b		=> 11,
          width_b     => 8
        )
        port map
        (
          clock_b			=> clk_sys,
          address_b		=> cpu_a(10 downto 0),
          wren_b			=> tile_d_wr(i),
          data_b			=> cpu_d_o,
          q_b					=> tile_d_o(i),

          clock_a			=> clk_video,
          address_a		=> tilemap_i(1).tile_a(10 downto 1),
          wren_a			=> '0',
          data_a			=> (others => 'X'),
          q_a					=> tile_d_q(i)
        );

    end generate GEN_TILE_D_RAM;
    
    GEN_MAP_D_RAM : for i in 0 to 1 generate
    
      map_d_wr(i) <= map_d_cs(i) when cpu_mem_wr = '1' else '0';

      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      map_d_inst : entity work.dpram
        generic map
        (
          init_file		=> "",
          widthad_a		=> 10
        )
        port map
        (
          clock_b			=> clk_sys,
          address_b		=> cpu_a(9 downto 0),
          wren_b			=> map_d_wr(i),
          data_b			=> cpu_d_o,
          q_b					=> map_d_o(i),

          clock_a			=> clk_video,
          address_a		=> tilemap_i(1).map_a(9 downto 0),
          wren_a			=> '0',
          data_a			=> (others => 'X'),
          q_a					=> map_d_q(i)
        );

    end generate GEN_MAP_D_RAM;
    
  end block BLK_VRAM;

  -- cartridge RAM
  GEN_RAM_A000 : if false generate
  begin
    -- this in on the cart... fudge
    ram_A000_inst : entity work.spram
      generic map
      (
        widthad_a			=> 13
      )
      port map
      (
        clock				=> clk_sys,
        address			=> cpu_a(12 downto 0),
        data				=> cpu_d_o,
        wren				=> cartA_wr,
        q						=> cartA_d_o
      );
  end generate GEN_RAM_A000;
  
  -- Internal RAM $C000-$DFFF
  -- - mirrored at $E000-$FDFF
  ram_C000_inst : entity work.spram
		generic map
		(
			widthad_a			=> 13
		)
    port map
    (
      clock				=> clk_sys,
      address			=> cpu_a(12 downto 0),
      data				=> cpu_d_o,
      wren				=> ramC_wr,
      q						=> ramC_d_o
    );

  BLK_SPRITES : block
  
    signal sprite_d_cs    : std_logic;
    signal sprite_d_wr    : std_logic;
    
  begin

    -- registers
    sprite_reg_o.clk <= clk_sys;
    sprite_reg_o.clk_ena <= cpu_clk_en;
    sprite_reg_o.a <= cpu_a(sprite_reg_o.a'range);
    sprite_reg_o.d <= cpu_d_o;
    sprite_reg_o.wr <= oam_wr;

    -- for now, mirror sprite memory

     -- $8000-$8FFF
    sprite_d_cs <= video_ram_cs when cpu_a(12) = '0' else '0';
    sprite_d_wr <= sprite_d_cs and cpu_clk_en and cpu_mem_wr;
    
    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    sprite_d_inst : entity work.dpram_ex
      generic map
      (
        init_file		=> "",
        widthad_a		=> 11,
        width_a     => 16,
        widthad_b		=> 12,
        width_b     => 8
      )
      port map
      (
        clock_b			=> clk_sys,
        address_b		=> cpu_a(11 downto 0),
        wren_b			=> sprite_d_wr,
        data_b			=> cpu_d_o,
        q_b					=> open,

        clock_a			=> clk_video,
        address_a		=> sprite_i.a(11 downto 1),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> sprite_o.d(15 downto 0)
      );

  end block BLK_SPRITES;
  
  BLK_IOREG : block

    signal io_rd          : std_logic;
    signal io_wr          : std_logic;
    
    signal ioreg_d_o      : std_logic_vector(7 downto 0);
    signal snd_cs         : std_logic;
    
    signal tick_262k144   : std_logic;
    signal tick_65k536    : std_logic;
    signal tick_16k384    : std_logic;
    signal tick_4k096     : std_logic;
    signal ly_um          : std_logic_vector(7 downto 0);
    signal hblank_um      : std_logic;
    signal vblank_um      : std_logic;
    
    -- interrupts
    signal vblank_p       : std_logic;
    signal tima_p         : std_logic;
  begin

    io_rd <= (io_cs and cpu_mem_rd) or cpu_io_rd;
    io_wr <= (io_cs and cpu_mem_wr) or cpu_io_wr;
    
    process (clk_sys, platform_rst)
    begin
      if platform_rst = '1' then
--        tima_r <= X"00";
        tma_r <= X"00";
        tac_r <= X"00";
        lcdc_r <= X"91";
        scy_r <= X"00";
        scx_r <= X"00";
        bootsel_r <= '0';
      elsif rising_edge(clk_sys) then
        -- READS
        if io_rd = '1' then
          case cpu_a(7 downto 0) is
            when X"00" =>
              if p1_r(4) = '0' then
                ioreg_d_o <= inputs_i(0).d;
              elsif p1_r(5) = '0' then
                ioreg_d_o <= inputs_i(1).d;
              end if;
            when X"05" =>
              ioreg_d_o <= tima_r;
            when X"06" =>
              ioreg_d_o <= tma_r;
            when X"07" =>
              ioreg_d_o <= tac_r;
            when X"0F" =>
              ioreg_d_o <= if_r;
            when X"40" =>
              ioreg_d_o <= lcdc_r;
            when X"41" =>
              ioreg_d_o <= stat_r;
            when X"42" =>
              ioreg_d_o <= scy_r;
            when X"43" =>
              ioreg_d_o <= scx_r;
            when X"44" =>
              -- LY (0-153) (144-153 is VBLANK)
              ioreg_d_o <= ly_um;
            when X"45" =>
              ioreg_d_o <= lyc_r;
            when others =>
              null;
          end case;
        -- WRITES
        elsif io_wr = '1' then
          if cpu_clk_en = '1' then
            case cpu_a(7 downto 0) is
              when X"00" =>
                p1_r <= cpu_d_o;
              when X"06" =>
                tma_r <= cpu_d_o;
              when X"07" =>
                tac_r <= cpu_d_o;
              when X"40" =>
                lcdc_r <= cpu_d_o;
              when X"42" =>
                scy_r <= cpu_d_o;
              when X"43" =>
                scx_r <= cpu_d_o;
              when X"45" =>
                lyc_r <= cpu_d_o;
              when X"50" =>
                -- can never go back
                bootsel_r <= '1';
              when others =>
                null;
            end case;
          end if; -- cpu_clk_en
        end if; -- cpu_mem_rd/wr
      end if;
    end process;

    -- $FF41 - STAT
    stat_r(2) <=  '1' when ly_um = lyc_r else 
                  '0';
    stat_r(1 downto 0) <= "00" when hblank_um = '1' else
                          "01" when vblank_um = '1' else
                          --"10" when (dma) else
                          "11";
    
    -- interrupt register and interrupts
    -- $FF0F
    process (clk_sys, platform_rst)
      variable vblank_r : std_logic;
      variable p14_r    : std_logic_vector(3 downto 0);
      variable p14_d    : std_logic_vector(3 downto 0);
      variable p15_r    : std_logic_vector(3 downto 0);
      variable p15_d    : std_logic_vector(3 downto 0);
    begin
      if platform_rst = '1' then
        if_r <= (others => '0');
        vblank_r := '0';
      elsif rising_edge(clk_sys) then

        -- register
        -- WRITES
        if io_wr = '1' then
          if cpu_clk_en = '1' then
            case cpu_a(7 downto 0) is
              when X"0F" =>
                if_r <= cpu_d_o;
              when others =>
                null;
            end case;
          end if; -- cpu_clk_en
        end if; -- cpu_mem_rd/wr
        
        -- interrupts
        -- bit 0 VBLANK
        if vblank_r = '0' and vblank_p = '1' then
          if_r(0) <= '1';
        end if;
        vblank_r := vblank_p;
        -- bit 2 TIMA
        if tima_p = '1' then
          if_r(2) <= '1';
        end if;
        -- bit 4 INPUTS (falling edge on any input)
        p14_d := inputs_i(0).d(p14_r'range) xor p14_r;
        if (not inputs_i(0).d(p14_d'range) and p14_d) /= "0000" then
          if_r(4) <= '1';
        end if;
        p14_r := inputs_i(0).d(p14_r'range);
        p15_d := inputs_i(1).d(p15_r'range) xor p15_r;
        if (not inputs_i(1).d(p15_d'range) and p15_d) /= "0000" then
          if_r(4) <= '1';
        end if;
        p15_r := inputs_i(1).d(p15_r'range);
        
        -- interrupt acknowledge
        if cpu_int_n = '0' then
          if cpu_int_ack = '1' then
            if ie_r(0) = '1' and if_r(0) = '1' then
              if_r(0) <= '0';
            elsif ie_r(1) = '1' and if_r(1) = '1' then
              if_r(1) <= '0';
            elsif ie_r(2) = '1' and if_r(2) = '1' then
              if_r(2) <= '0';
            elsif ie_r(3) = '1' and if_r(3) = '1' then
              if_r(3) <= '0';
            elsif ie_r(4) = '1' and if_r(4) = '1' then
              if_r(4) <= '0';
            end if;
          end if; -- cpu_int_ack
        end if; -- cpu_int_n
        
      end if;
    end process;
    
    -- generate CPU interrupt line
    cpu_int_n <=  '0' when (ie_r(4 downto 0) and if_r(4 downto 0)) /= "00000" else
                  '1';
    
    -- latch interrupt vector (priority encoded)
    process (clk_sys, platform_rst)
      variable if_rr : std_logic_vector(if_r'range);
    begin
      if platform_rst = '1' then
        if_rr := (others => '0');
      elsif rising_edge(clk_sys) then
        if if_r /= if_rr then
          if if_rr(0) = '1' then
            cpu_int_vec <=  X"40";
          elsif if_rr(1) = '1' then
            cpu_int_vec <=  X"48";
          elsif if_rr(2) = '1' then
            cpu_int_vec <=  X"50";
          elsif if_rr(3) = '1' then
            cpu_int_vec <=  X"58";
          elsif if_rr(4) = '1' then
            cpu_int_vec <=  X"60";
          end if;
        end if;
        if_rr := if_r;
      end if;
    end process;

    -- timer implementation
    process (clk_sys, platform_rst)
      variable count : unsigned(9 downto 0);
    begin
      if platform_rst = '1' then
        tima_r <= (others => '0');
        count := (others => '0');
      elsif rising_edge(clk_sys) then
      
        if clk_4M19_en = '1' then
          tick_262k144 <= '0';
          tick_65k536 <= '0';
          tick_16k384 <= '0';
          tick_4k096 <= '0';
          if count(3 downto 0) = "0000" then
            tick_262k144 <= '1';
            if count(5 downto 4) = "00" then
              tick_65k536 <= '1';
              if count(7 downto 6) = "00" then
                tick_16k384 <= '1';
                if count(9 downto 8) = "00" then
                  tick_4k096 <= '1';
                end if; -- 9..8
              end if; -- 7..6
            end if; -- 5..4
          end if; -- 3 downto 0
          count := count + 1;
        end if; -- clk_4M19_en
        
        -- register
        -- WRITES
        if io_wr = '1' then
          if cpu_clk_en = '1' then
            case cpu_a(7 downto 0) is
              when X"05" =>
                tima_r <= cpu_d_o;
              when others =>
                null;
            end case;
          end if; -- cpu_clk_en
        end if; -- cpu_mem_rd/wr

        -- timer
        tima_p <= '0'; -- default
        if tac_r(2) = '1' then
          if (tac_r(1 downto 0) = "00" and tick_4k096 = '1' ) or
              (tac_r(1 downto 0) = "01" and tick_262k144 = '1') or
              (tac_r(1 downto 0) = "10" and tick_65k536 = '1') or
              (tac_r(1 downto 0) = "11" and tick_16k384 = '1') then
            if tima_r = X"FF" then
              -- reload with TMA
              tima_r <= tma_r;
              -- generate interrupt
              tima_p <= '1';
            else
              tima_r <= std_logic_vector(unsigned(tima_r) + 1);
            end if;
          end if;
        end if;
        
      end if;
    end process;
    
    -- unmeta the video Y coordinate
    process (clk_sys, rst_sys)
      type ly_t is array (natural range <>) of std_logic_vector(7 downto 0);
      variable ly_r : ly_t(3 downto 0);
      variable hblank_r : std_logic_vector(3 downto 0);
      variable vblank_r : std_logic_vector(3 downto 0);
    begin
      if rst_sys = '1' then
        ly_r := (others => (others => '0'));
        hblank_r := (others => '0');
        vblank_r := (others => '0');
        vblank_p <= '0';
      elsif rising_edge(clk_sys) then
        -- ensure we don't wrap at 256
        vblank_p <= '0';
        if graphics_i.y(10 downto 8) = "000" then
          -- VBLANK starts at line 144
          if ly_um = X"90" then
            vblank_p <= '1';
          end if;
          ly_r := ly_r(ly_r'left-1 downto 0) & graphics_i.y(7 downto 0);
        else
          ly_r := ly_r(ly_r'left-1 downto 0) & X"FF";
        end if;
        hblank_r := hblank_r(hblank_r'left-1 downto 0) & graphics_i.hblank;
        vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
      end if;
      ly_um <= ly_r(ly_r'left);
      hblank_um <= hblank_r(hblank_r'left);
      vblank_um <= vblank_r(vblank_r'left);
    end process;

    -- sound implementation
    
    -- $FF10-$FF3F
    snd_cs <= '1' when STD_MATCH(cpu_a(7 downto 0), "0001----") else
              '1' when STD_MATCH(cpu_a(7 downto 0), "001-----") else
              '0';

    snd_o.a <= cpu_a(snd_o.a'range);
    snd_o.d <= cpu_d_o;
    snd_o.rd <= snd_cs and cpu_clk_en and io_rd;
    snd_o.wr <= snd_cs and cpu_clk_en and io_wr;
    
    -- read MUX
    io_d_o <= snd_i.d when snd_cs = '1' else
              ioreg_d_o;
    
  end block BLK_IOREG;
  
  -- Internal RAM $FF80-$FFFF
  ram_FF80_inst : entity work.spram
		generic map
		(
			widthad_a			=> 7
		)
    port map
    (
      clock				=> clk_sys,
      address			=> cpu_a(6 downto 0),
      data				=> cpu_d_o,
      wren				=> ramF_wr,
      q						=> ramF_d_o
    );

  -- interrupt register
  BLK_IE : block
  begin
    process (clk_sys, platform_rst)
    begin
      if platform_rst = '1' then
        ie_r <= (others => '0');
      elsif rising_edge(clk_sys) then
        if ie_cs = '1' then
          if cpu_mem_wr = '1' then
            if cpu_clk_en = '1' then
              ie_r <= cpu_d_o;
            end if;
          end if;
        end if;
      end if;
    end process;
  end block BLK_IE;
  
  -- unused outputs
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;
