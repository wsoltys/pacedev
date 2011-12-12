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
	signal cpu_irq				    : std_logic;

  -- ROM signals        
	signal bootrom_cs				  : std_logic;
  signal bootrom_d_o        : std_logic_vector(7 downto 0);
	
  -- RAM signals        
	signal ramC_cs				    : std_logic;
  signal ramC_wr            : std_logic;
  signal ramC_d_o           : std_logic_vector(7 downto 0);
	signal ramF_cs				    : std_logic;
  signal ramF_wr            : std_logic;
  signal ramF_d_o           : std_logic_vector(7 downto 0);
  
  -- registers
  signal ioreg_cs           : std_logic;
  signal ioreg_d_o          : std_logic_vector(7 downto 0);

  -- tba
	signal vram_cs				    : std_logic;
  signal vram_d_o           : std_logic_vector(7 downto 0);
  signal vram_wr            : std_logic;
	signal cram_cs				    : std_logic;
  signal cram_d_o           : std_logic_vector(7 downto 0);
  signal cram_wr            : std_logic;
  signal sprite_cs          : std_logic;
  
  -- I/O signals
  signal scroll_cs          : std_logic;
  signal in0_cs             : std_logic;
  signal in1_cs             : std_logic;
  signal in2_cs             : std_logic;
  signal dsw1_cs            : std_logic;
  signal dsw2_cs            : std_logic;
  
  -- other signals   
	alias platform_reset			: std_logic is inputs_i(3).d(0);
	alias osd_toggle          : std_logic is inputs_i(3).d(1);
	alias platform_pause      : std_logic is inputs_i(3).d(2);
	
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
    bootrom_cs <= '1' when STD_MATCH(cpu_a,    X"00"&"--------") else 
                  '0';
    -- RAM $C000-$DFFF (mirrored $E000-$FDFF)
    ramC_cs <=		'1' when STD_MATCH(cpu_a,  "110-------------") else
                  '1' when STD_MATCH(cpu_a,  "111-------------") else
                  '0';
    -- I/O registers $FF00-$FF7F
    ioreg_cs <=   '1' when STD_MATCH(cpu_a,    X"FF"&"0-------") else
                  '0';
    -- RAM $FF80-$FFFF
    ramF_cs <=		'1' when STD_MATCH(cpu_a,    X"FF"&"1-------") else
                  '0';
    -- video ram $1000-$13FF
    vram_cs <=		'1' when STD_MATCH(cpu_a,  "000100----------") else
                  '0';
    -- colour ram $1400-$17FF
    cram_cs <=		'1' when STD_MATCH(cpu_a,  "000101----------") else
                  '0';
    -- sprite 'ram' $2020-$207F
    sprite_cs <=	'1' when STD_MATCH(cpu_a,    X"20"&"001-----") else
                  '1' when STD_MATCH(cpu_a,    X"20"&"01------") else
                  '0';
    -- I/O
    scroll_cs <=  '1' when STD_MATCH(cpu_a, X"3000") else '0';
    in0_cs <=     '1' when STD_MATCH(cpu_a, X"3002") else '0';
    in1_cs <=     '1' when STD_MATCH(cpu_a, X"3003") else '0';
    in2_cs <=     '1' when STD_MATCH(cpu_a, X"3004") else '0';
    dsw1_cs <=    '1' when STD_MATCH(cpu_a, X"3005") else '0';
    dsw2_cs <=    '1' when STD_MATCH(cpu_a, X"3006") else '0';

    -- memory block write enables
    ramC_wr <= ramC_cs and cpu_clk_en and cpu_mem_wr;
    ramF_wr <= ramF_cs and cpu_clk_en and cpu_mem_wr;
    cram_wr <= cram_cs and cpu_clk_en and cpu_mem_wr;

    mem_d_i <=  bootrom_d_o when bootrom_cs = '1' else
                ramC_d_o when ramC_cs = '1' else
                ioreg_d_o when ioreg_cs = '1' else
                ramF_d_o when ramF_cs = '1' else
--                inputs_i(0).d when in0_cs = '1' else
--                inputs_i(1).d when in1_cs = '1' else
--                inputs_i(2).d when in2_cs = '1' else
                (others => 'Z');

    io_d_i <=   X"FF";
    
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
	cpu_reset <= rst_sys or platform_reset;

  BLK_CPU : block
    signal mreq_n   : std_logic;
    signal iorq_n   : std_logic;
    signal rd_n     : std_logic;
    signal wr_n     : std_logic;
  begin
  
	  cpu_mem_rd <= mreq_n nor rd_n;
	  cpu_mem_wr <= mreq_n nor wr_n;
    cpu_io_rd <= iorq_n nor rd_n;
    cpu_io_wr <= iorq_n nor wr_n;
    
    cpu_inst : entity work.T80se
      generic map
      (
        Mode            => 3
      )
      port map
      (
        RESET_n         => not cpu_reset,
        CLK_n           => clk_sys,
        CLKEN           => cpu_clk_en,
        WAIT_n          => '1',
        INT_n           => '1',
        NMI_n           => '1',
        BUSRQ_n         => '1',
        M1_n            => open,
        MREQ_n          => mreq_n,
        IORQ_n          => iorq_n,
        RD_n            => rd_n,
        WR_n            => wr_n,
        RFSH_n          => open,
        HALT_n          => open,
        BUSAK_n         => open,
        A               => cpu_a,
        DI              => cpu_d_i,
        DO              => cpu_d_o
      );
  end block BLK_CPU;
  
	-- irq vblank interrupt
	process (clk_sys, rst_sys)
    variable vblank_r : std_logic_vector(3 downto 0);
    alias vblank_prev : std_logic is vblank_r(vblank_r'left);
    alias vblank_um   : std_logic is vblank_r(vblank_r'left-1);
	begin
		if rst_sys = '1' then
			vblank_r := (others => '0');
      cpu_irq <= '0';
		elsif rising_edge(clk_sys) then
			if vblank_um = '1' and vblank_prev = '0' then
				cpu_irq <= '1';
      elsif vblank_um = '0' then
        cpu_irq <= '0';
			end if;
      -- numeta the vblank
      vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
		end if;
	end process;

  -- scroll register
  process (clk_sys, rst_sys)
  begin
    if rst_sys = '1' then
      graphics_o.bit8(0) <= (others => '0');
    elsif rising_edge(clk_sys) then
      if scroll_cs and cpu_clk_en and cpu_mem_wr then
        graphics_o.bit8(0) <= cpu_d_o;
      end if;
    end if;
  end process;
  
	GEN_FPGA_ROMS : if true generate
  begin
  
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
                  
	end generate GEN_FPGA_ROMS;

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

  BLK_IOREG : block
  begin
  
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
      elsif rising_edge(clk_sys) then
        if cpu_clk_en = '1' then
          if ioreg_cs = '1' then 
            if cpu_mem_rd = '1' then
              case cpu_a(7 downto 0) is
                when X"44" =>
                  -- LY (0-153) (144-153 is VBLANK)
                  -- - TBD unmeta
                  ioreg_d_o <= graphics_i.y(7 downto 0);
                when others =>
                  null;
              end case;
            end if; -- cpu_mem_rd
            if cpu_mem_wr = '1' then
            end if; -- cpu_mem_wr
          end if; -- ioreg_cs
        end if; -- cpu_clk_ena
      end if;
    end process;
    
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

  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  vram_inst : entity work.dpram
    generic map
    (
      init_file		=> GAMEBOY_ROM_DIR & "vram.hex",
      widthad_a		=> 10
    )
    port map
    (
      clock_b			=> clk_sys,
      address_b		=> cpu_a(9 downto 0),
      wren_b			=> vram_wr,
      data_b			=> cpu_d_o,
      q_b					=> vram_d_o,

      clock_a			=> clk_video,
      address_a		=> tilemap_i(1).map_a(9 downto 0),
      wren_a			=> '0',
      data_a			=> (others => 'X'),
      q_a					=> tilemap_o(1).map_d(7 downto 0)
    );
  tilemap_o(1).map_d(tilemap_o(1).map_d'left downto 8) <= (others => 'Z');
  
  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  cram_inst : entity work.dpram
    generic map
    (
      init_file		=> GAMEBOY_ROM_DIR & "cram.hex",
      widthad_a		=> 10
    )
    port map
    (
      clock_b			=> clk_sys,
      address_b		=> cpu_a(9 downto 0),
      wren_b			=> cram_wr,
      data_b			=> cpu_d_o,
      q_b					=> cram_d_o,

      clock_a			=> clk_video,
      address_a		=> tilemap_i(1).attr_a(9 downto 0),
      wren_a			=> '0',
      data_a			=> (others => 'X'),
      q_a					=> tilemap_o(1).attr_d(7 downto 0)
    );
  tilemap_o(1).attr_d(tilemap_o(1).attr_d'left downto 8) <= (others => 'Z');

  -- tile rom (bit 0)
  ss_7_b6_inst : entity work.sprom
    generic map
    (
      init_file		=> GAMEBOY_ROM_DIR & "dmg_rom.hex",
      widthad_a		=> 13
    )
    port map
    (
      clock			=> clk_video,
      address		=> tilemap_i(1).tile_a(12 downto 0),
      q					=> tilemap_o(1).tile_d(7 downto 0)
    );
		
  BLK_SPRITES : block
    signal bit0_1       : std_logic_vector(7 downto 0);   -- offset 0
    signal bit0_2       : std_logic_vector(7 downto 0);   -- offset 0
    signal bit0_3       : std_logic_vector(7 downto 0);   -- offset 16
    signal bit0_4       : std_logic_vector(7 downto 0);   -- offset 16
    signal bit1_1       : std_logic_vector(7 downto 0);
    signal bit1_2       : std_logic_vector(7 downto 0);
    signal bit1_3       : std_logic_vector(7 downto 0);
    signal bit1_4       : std_logic_vector(7 downto 0);
    signal bit2_1       : std_logic_vector(7 downto 0);
    signal bit2_2       : std_logic_vector(7 downto 0);
    signal bit2_3       : std_logic_vector(7 downto 0);
    signal bit2_4       : std_logic_vector(7 downto 0);
    
    signal sprite_a_00  : std_logic_vector(12 downto 0);
    signal sprite_a_16  : std_logic_vector(12 downto 0);
    
  begin

    -- registers
    sprite_reg_o.clk <= clk_sys;
    sprite_reg_o.clk_ena <= cpu_clk_en;
    sprite_reg_o.a <= cpu_a(sprite_reg_o.a'range);
    sprite_reg_o.d <= cpu_d_o;
    sprite_reg_o.wr <= sprite_cs and cpu_clk_en and cpu_mem_wr;

    -- sprite rom (bit 0, part 1/2)
    ss_9_m5_inst : entity work.dprom_2r
      generic map
      (
        --init_file		=> GAMEBOY_ROM_DIR & "ss_9_m5.hex",
        widthad_a		=> 13,
        widthad_b		=> 13
      )
      port map
      (
        clock			  => clk_video,
        address_a   => sprite_a_00,
        q_a 			  => bit0_1,
        address_b   => sprite_a_16,
        q_b         => sprite_o.d(7 downto 0)
      );

  end block BLK_SPRITES;
  
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;
