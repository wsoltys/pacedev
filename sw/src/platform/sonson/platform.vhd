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

	alias clk_20M					    : std_logic is clkrst_i.clk(0);
  alias rst_20M             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
  signal clk_2M_en			    : std_logic;
	signal clk_2M_en_n		    : std_logic;
	signal cpu_r_wn				    : std_logic;
	signal cpu_a				      : std_logic_vector(15 downto 0);
	signal cpu_d_i			      : std_logic_vector(7 downto 0);
	signal cpu_d_o			      : std_logic_vector(7 downto 0);
	signal cpu_irq				    : std_logic;

  -- ROM signals        
	signal rom_cs				      : std_logic;
  signal rom_d_o            : std_logic_vector(7 downto 0);
	
  -- RAM signals        
	signal wram_cs				    : std_logic;
  signal wram_wr            : std_logic;
  alias wram_d_o      	    : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);
	signal vram_cs				    : std_logic;
  signal vram_d_o           : std_logic_vector(7 downto 0);
  signal vram_wr            : std_logic;
	signal cram_cs				    : std_logic;
  signal cram_d_o           : std_logic_vector(7 downto 0);
  signal cram_wr            : std_logic;

  -- I/O signals
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

	-- cpu09 core uses negative clock edge
	clk_2M_en_n <= not (clk_2M_en and not platform_pause);
	--clk_2M_en_n <= not (clk_2M_en and not platform_pause) or cpu_halt;

	-- add game reset later
	cpu_reset <= rst_20M or platform_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(16 downto 0)	<= 	std_logic_vector(resize(unsigned(cpu_a), 17));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length)) 
								when (wram_wr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not wram_wr;
  sram_o.we <= wram_wr;

	-- RAM $0000-$0FFF
	wram_cs <=		'1' when STD_MATCH(cpu_a,  "0000------------") else
								'0';
  -- video ram $1000-$13FF
  vram_cs <=		'1' when STD_MATCH(cpu_a,  "000100----------") else
                '0';
  -- colour ram $1400-$17FF
  cram_cs <=		'1' when STD_MATCH(cpu_a,  "000101----------") else
                '0';
  -- I/O
  in0_cs <=     '1' when STD_MATCH(cpu_a, X"3002") else '0';
  in1_cs <=     '1' when STD_MATCH(cpu_a, X"3003") else '0';
  in2_cs <=     '1' when STD_MATCH(cpu_a, X"3004") else '0';
  dsw1_cs <=    '1' when STD_MATCH(cpu_a, X"3005") else '0';
  dsw2_cs <=    '1' when STD_MATCH(cpu_a, X"3006") else '0';
  -- ROM $4000-$FFFF
  --            $4000-$7FFF
	rom_cs  <= 	  '1' when STD_MATCH(cpu_a,  "01--------------") else 
  --            $8000-$FFFF
                '1' when STD_MATCH(cpu_a,  "1---------------") else 
                '0';

  -- memory block write enables
  wram_wr <= wram_cs and clk_2M_en and not cpu_r_wn;
  vram_wr <= vram_cs and clk_2M_en and not cpu_r_wn;
  cram_wr <= cram_cs and clk_2M_en and not cpu_r_wn;

	-- memory read mux
	cpu_d_i <=  wram_d_o when wram_cs = '1' else
							vram_d_o when vram_cs = '1' else
							cram_d_o when cram_cs = '1' else
              inputs_i(0).d when in0_cs = '1' else
              inputs_i(1).d when in1_cs = '1' else
              inputs_i(2).d when in2_cs = '1' else
              -- flip off, service off, coin A, 1C1C
              (X"80" or X"40" or X"10" or X"0F") when dsw1_cs = '1' else
              -- freeze off, easy, 20K/80K/100K, 3 lives
              (X"80" or X"60" or X"08" or X"03") when dsw2_cs = '1' else
              rom_d_o when rom_cs = '1' else
							(others => 'Z');
		
  -- system timing
  process (clk_20M, rst_20M)
    variable count : integer range 0 to 10-1;
  begin
    if rst_20M = '1' then
      count := 0;
    elsif rising_edge(clk_20M) then
      clk_2M_en <= '0'; -- default
      case count is
        when 0 =>
          clk_2M_en <= '1';
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

	cpu_inst : entity work.cpu09
		port map
		(	
			clk				=> clk_2M_en_n,
			rst				=> cpu_reset,
			rw				=> cpu_r_wn,
			vma				=> open,
      --ba        => open,
      --bs        => open,
			addr		  => cpu_a,
		  data_in		=> cpu_d_i,
		  data_out	=> cpu_d_o,
			halt			=> '0',
			hold			=> '0',
			irq				=> cpu_irq,
			firq			=> '0',
			nmi				=> '0'
		);

	-- irq vblank interrupt
	process (clk_20M, rst_20M)
    variable vblank_r : std_logic_vector(3 downto 0);
    alias vblank_prev : std_logic is vblank_r(vblank_r'left);
    alias vblank_um   : std_logic is vblank_r(vblank_r'left-1);
	begin
		if rst_20M = '1' then
			vblank_r := (others => '0');
      cpu_irq <= '0';
		elsif rising_edge(clk_20M) then
			if vblank_um = '1' and vblank_prev = '0' then
				cpu_irq <= '1';
      elsif vblank_um = '0' then
        cpu_irq <= '0';
			end if;
      -- numeta the vblank
      vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
		end if;
	end process;

	GEN_FPGA_ROMS : if true generate
    signal rom4_d_o   : std_logic_vector(7 downto 0);
    signal rom8_d_o   : std_logic_vector(7 downto 0);
    signal romC_d_o   : std_logic_vector(7 downto 0);
  begin
  
    rom_4000_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_01e.hex",
        widthad_a		=> 14
      )
      port map
      (
        clock			=> clk_20M,
        address		=> cpu_a(13 downto 0),
        q					=> rom4_d_o
      );
    
    rom_8000_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_02e.hex",
        widthad_a		=> 14
      )
      port map
      (
        clock			=> clk_20M,
        address		=> cpu_a(13 downto 0),
        q					=> rom8_d_o
      );
      
    rom_C000_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_03e.hex",
        widthad_a		=> 14
      )
      port map
      (
        clock			=> clk_20M,
        address		=> cpu_a(13 downto 0),
        q					=> romC_d_o
      );
		
    rom_d_o <=  rom4_d_o when STD_MATCH(cpu_a, "01--------------") else
                rom8_d_o when STD_MATCH(cpu_a, "10--------------") else
                romC_d_o;
                  
	end generate GEN_FPGA_ROMS;

  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  vram_inst : entity work.dpram
    generic map
    (
      init_file		=> SONSON_ROM_DIR & "vram.hex",
      widthad_a		=> 10
    )
    port map
    (
      clock_b			=> clk_20M,
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
      init_file		=> SONSON_ROM_DIR & "cram.hex",
      widthad_a		=> 10
    )
    port map
    (
      clock_b			=> clk_20M,
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
      init_file		=> SONSON_ROM_DIR & "ss_7_b6.hex",
      widthad_a		=> 13
    )
    port map
    (
      clock			=> clk_video,
      address		=> tilemap_i(1).tile_a(12 downto 0),
      q					=> tilemap_o(1).tile_d(7 downto 0)
    );
		
  -- tile rom (bit 1)
  ss_8_b5_inst : entity work.sprom
    generic map
    (
      init_file		=> SONSON_ROM_DIR & "ss_8_b5.hex",
      widthad_a		=> 13
    )
    port map
    (
      clock			=> clk_video,
      address		=> tilemap_i(1).tile_a(12 downto 0),
      q					=> tilemap_o(1).tile_d(15 downto 8)
    );

  BLK_SPRITES : block
    signal bit0_1 : std_logic_vector(7 downto 0);
    signal bit0_2 : std_logic_vector(7 downto 0);
    signal bit1_1 : std_logic_vector(7 downto 0);
    signal bit1_2 : std_logic_vector(7 downto 0);
    signal bit2_1 : std_logic_vector(7 downto 0);
    signal bit2_2 : std_logic_vector(7 downto 0);
  begin
  
    -- sprite rom (bit 0, part 1/2)
    ss_9_m5_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_9_m5.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address		=> sprite_i.a(12 downto 0),
        q					=> bit0_1
      );
      
    -- sprite rom (bit 0, part 2/2)
    ss_10_m6_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_10_m6.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address		=> sprite_i.a(12 downto 0),
        q					=> bit0_2
      );
      
    sprite_o.d(7 downto 0) <= bit0_1 when sprite_i.a(13) = '0' else
                              bit0_2;
                              
    -- sprite rom (bit 1, part 1/2)
    ss_11_m3_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_11_m3.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address		=> sprite_i.a(12 downto 0),
        q					=> bit1_1
      );
      
    -- sprite rom (bit 0, part 2/2)
    ss_12_m4_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_12_m4.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address		=> sprite_i.a(12 downto 0),
        q					=> bit1_2
      );
      
    sprite_o.d(15 downto 8) <=  bit1_1 when sprite_i.a(13) = '0' else
                                bit1_2;
                              
    -- sprite rom (bit 2, part 1/2)
    ss_13_m1_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_13_m1.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address		=> sprite_i.a(12 downto 0),
        q					=> bit2_1
      );
      
    -- sprite rom (bit 2, part 2/2)
    ss_14_m2_inst : entity work.sprom
      generic map
      (
        init_file		=> SONSON_ROM_DIR & "ss_14_m2.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_video,
        address		=> sprite_i.a(12 downto 0),
        q					=> bit2_2
      );
      
    sprite_o.d(23 downto 16) <= bit2_1 when sprite_i.a(13) = '0' else
                                bit2_2;
                              
  end block BLK_SPRITES;
  
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  graphics_o.bit8(0) <= (others => '0');
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;
