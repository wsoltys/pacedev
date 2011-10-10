library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;
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

	constant TUTANKHAM_VRAM_SIZE		: integer := 2**TUTANKHAM_VRAM_WIDTHAD;

	alias clk_30M					: std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	signal cpu_reset			: std_logic;

	alias video_counter		: std_logic_vector(7 downto 0) is graphics_i.y(7 downto 0);
		
  -- uP signals  
  signal clk_1M5_en			: std_logic;
	signal clk_1M5_en_n		: std_logic;
	signal cpu_rw					: std_logic;
	signal cpu_vma				: std_logic;
	signal cpu_a				  : std_logic_vector(15 downto 0);
	signal cpu_d_i			  : std_logic_vector(7 downto 0);
	signal cpu_d_o			  : std_logic_vector(7 downto 0);
	signal cpu_irq				: std_logic;
	signal cpu_firq				: std_logic;
	signal cpu_nmi				: std_logic;
  signal cpu_opfetch    : std_logic;
  
  -- ROM signals        
	signal rom_a_cs				: std_logic;
  signal rom_a_data     : std_logic_vector(7 downto 0);
	signal rom_c_cs				: std_logic;
  signal rom_c_data     : std_logic_vector(7 downto 0);
	signal sram_addr_hi		: std_logic_vector(16 downto 12);
	
	-- video counter
	signal video_counter_cs	: std_logic;	
	
	-- banked signals
	signal bank_r					: std_logic_vector(3 downto 0);
	signal data_9_cs			: std_logic;
	signal data_9000			: std_logic_vector(7 downto 0);
	                        
  -- VRAM signals       
	signal vram0_cs				: std_logic;
  signal vram0_wr       : std_logic;
  signal vram0_data     : std_logic_vector(7 downto 0);

  -- RAM signals        
	signal wram_cs				: std_logic;
  signal wram_wr        : std_logic;
  --alias wram_data      	: std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);
  -- declare this for some debugging (for coco1)
  signal wram_data      : std_logic_vector(7 downto 0);

	signal intena_cs			: std_logic;
	signal intena_r				: std_logic;
		
	signal palette_cs			: std_logic;
	signal palette_wr			: std_logic;
	signal palette_r			: PAL_A_t(15 downto 0);
	
	signal dip2_cs				: std_logic;
	signal dip1_cs				: std_logic;
	signal in2_cs					: std_logic;
	signal in1_cs					: std_logic;
	signal in0_cs					: std_logic;
	
  -- other signals      
	alias game_reset			: std_logic is inputs_i(3).d(0);

begin

	-- cpu09 core uses negative clock edge
	clk_1M5_en_n <= not clk_1M5_en;

	-- add game reset later
	cpu_reset <= clkrst_i.rst(0) or game_reset;
	
  -- SRAM signals (may or may not be used)
 sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(16 downto 0) <= -- Graphics ROM starts at $10000 in 4KB banks - mapped to $9000
          ('1' & bank_r & cpu_a(11 downto 0)) when data_9_cs = '1' else
          std_logic_vector(resize(unsigned(cpu_a), 17));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not wram_wr;
  sram_o.we <= wram_wr;

	-- chip selects

	-- video ram $0000-$7FFF
	vram0_cs <=		      '1' when STD_MATCH(cpu_a,  "0---------------") else '0';
	-- Palette RAM $8000-$800F
	palette_cs <=	      '1' when STD_MATCH(cpu_a, X"800"      &"----") else '0';
	-- banked area $9000-$9FFF
	data_9_cs <= 	      '1' when STD_MATCH(cpu_a, X"9"&"------------") else '0';
	-- ROM $A000-$BFFF,$C000-$FFFF
	rom_a_cs <= 	      '1' when STD_MATCH(cpu_a,  "101-------------") else '0';
	rom_c_cs <= 	      '1' when STD_MATCH(cpu_a,  "11--------------") else '0';
	-- video counter $C800-$CBFF
	video_counter_cs <= '1' when STD_MATCH(cpu_a, X"C"&"10----------") else '0';

  GEN_TUTANKHAM_IO : if PLATFORM_VARIANT = "tutankham" generate
  
    -- DIPS2 $8160
    dip2_cs <=		'1' when STD_MATCH(cpu_a, X"816"&"----") else '0';
    -- IN0 $8180
    in0_cs <=			'1' when STD_MATCH(cpu_a, X"818"&"----") else '0';
    -- IN1 $81A0
    in1_cs <=			'1' when STD_MATCH(cpu_a, X"81A"&"----") else '0';
    -- IN2 $81C0
    in2_cs <=			'1' when STD_MATCH(cpu_a, X"81C"&"----") else '0';
    -- DIPS1 $81E0
    dip1_cs <=		'1' when STD_MATCH(cpu_a, X"81E"&"----") else '0';
    -- Interrupt Enable $8200
    intena_cs <= 	'1' when STD_MATCH(cpu_a, X"8200") else '0';
    -- RAM $8800-$8FFF
    wram_cs <=		'1' when STD_MATCH(cpu_a, X"8"&"1-----------") else '0';

  end generate GEN_TUTANKHAM_IO;
  
  GEN_JUNOFRST_IO : if PLATFORM_VARIANT = "junofrst" generate
  
    -- DIPS2 $8010
    dip2_cs <=		'1' when STD_MATCH(cpu_a, X"8010") else '0';
    -- IN0 $8020
    in0_cs <=			'1' when STD_MATCH(cpu_a, X"8020") else '0';
    -- IN1 $8024
    in1_cs <=			'1' when STD_MATCH(cpu_a, X"8024") else '0';
    -- IN2 $8028
    in2_cs <=			'1' when STD_MATCH(cpu_a, X"8028") else '0';
    -- DIPS1 $802C
    dip1_cs <=		'1' when STD_MATCH(cpu_a, X"802C") else '0';
    -- Interrupt Enable $8030
    intena_cs <= 	'1' when STD_MATCH(cpu_a, X"8030") else '0';
    -- RAM $8100-$8FFF
    wram_cs <=		'1' when STD_MATCH(cpu_a, X"8"&"------------") else '0';

  end generate GEN_JUNOFRST_IO;
  
	-- memory read mux
	cpu_d_i <= 	vram0_data when vram0_cs = '1' else
									"11111011" when dip2_cs = '1' else
									inputs_i(0).d when in0_cs = '1' else
									inputs_i(1).d when in1_cs = '1' else
									inputs_i(2).d when in2_cs = '1' else
									X"ff" when dip1_cs = '1' else
                  -- needs to come *after* the above since it shadows
									wram_data when wram_cs = '1' else
									data_9000 when data_9_cs = '1' else
									rom_a_data when rom_a_cs = '1' else
                  rom_c_data when rom_c_cs = '1' else
									(others => '0');
	
	vram0_wr <= vram0_cs and clk_1M5_en and not cpu_rw;
	palette_wr <= palette_cs and not cpu_rw;

	-- memory write enables
	--process (clk_30M, clk_1M5_en)
	--begin
	--	if rising_edge(clk_30M) then
	--		if clk_1M5_en = '1' then
	--			-- only write thru to WRAM
	--			wram_wr <= not cpu_rw and wram_cs;
	--		else
	--			wram_wr <= '0';
	--		end if;
	--	end if;
	--end process;

  wram_wr <= wram_cs and not cpu_rw and clk_1M5_en;
		
	-- implementation of the banking register
	process (clk_30M, clk_1M5_en, cpu_reset)
		variable bank_offset_v : std_logic_vector(bank_r'range);
	begin
		if cpu_reset = '1' then
			bank_r <= (others => '0');
			sram_addr_hi <= (others => '0');
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			if cpu_rw = '0' and 
          ((PLATFORM_VARIANT = "tutankham" and STD_MATCH(cpu_a, X"8300")) or
           (PLATFORM_VARIANT = "junofrst" and STD_MATCH(cpu_a, X"8060"))) then
				bank_r <= cpu_d_o(bank_r'range);
			end if;
		end if;
	end process;
	
	-- implementation of scroll register
	process (clk_30M, clkrst_i.rst(0))
	begin
		if clkrst_i.rst(0) = '1' then
			graphics_o.bit8(0) <= (others => '0');
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			if cpu_rw = '0' and 
          ((PLATFORM_VARIANT = "tutankham" and STD_MATCH(cpu_a, X"8100")) or
           (PLATFORM_VARIANT = "junofrst" and STD_MATCH(cpu_a, X"8033"))) then
				graphics_o.bit8(0) <= cpu_d_o;
			end if;
		end if;
	end process;
	
	-- implementation of palette RAM
	process (clk_30M, clkrst_i.rst(0))
		variable offset : integer;
	begin
    if clkrst_i.rst(0) = '1' then
      palette_r(0) <= X"5555";
      palette_r(1) <= X"AAAA";
      palette_r(2) <= X"FFFF";
      palette_r(3) <= X"8080";
		elsif rising_edge(clk_30M) then
      if clk_1M5_en = '1' then
        if palette_wr = '1' then
          offset := conv_integer(cpu_a(3 downto 0));
          palette_r(offset) <= cpu_d_o;
        end if;
      end if;
		end if;
		graphics_o.pal <= palette_r;
	end process;
	
	-- implementation of cpu interrupt enable register
	process (clk_30M, clk_1M5_en, cpu_reset)
	begin
		if cpu_reset = '1' then
			intena_r <= '0';
		elsif rising_edge(clk_30M) then
      if clk_1M5_en = '1' then
        if intena_cs = '1' and cpu_rw = '0' then
          intena_r <= cpu_d_o(0);
        end if;
      end if;
		end if;
	end process;
	
	-- vblank interrupt at 30Hz
	process (clk_30M, clkrst_i.rst(0))
		variable toggle_v 	: std_logic := '0';
		variable vblank_r		: std_logic_vector(2 downto 0) := (others => '0');
		alias vblank_prev 	: std_logic is vblank_r(vblank_r'left);
		alias vblank_unmeta : std_logic is vblank_r(vblank_r'left-1);
		subtype count_t is integer range 0 to 7;
		variable count			: count_t;
	begin
		if clkrst_i.rst(0) = '1' then
			toggle_v := '0';
			vblank_r := (others => '0');
			cpu_irq <= '0';
			count := 0;
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			-- detect rising edge of vblank
			if vblank_unmeta = '1' and vblank_prev = '0' then
				toggle_v := not toggle_v;
				if toggle_v = '1' then
					count := count_t'high;
				end if;
			elsif count /= 0 then
				count := count - 1;
			end if;
			-- shift vblank into unmeta pipeline
			vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
		end if;
		-- drive IRQ only every second VBLANK
		if count = 0 then
			cpu_irq <= '0';
		else
			cpu_irq <= intena_r and vblank_unmeta;
		end if;
	end process;

	-- cpu interrupts
	cpu_firq <= '0';
	cpu_nmi <= '0';

  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  tilemap_o <= (others => NULL_TO_TILEMAP_CTL);
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');

  GEN_CPU09 : if not TUTANKHAM_USE_REAL_6809 generate
    signal decrypted_d_i  : std_logic_vector(cpu_d_i'range);
  begin
  
    clk_en_inst : entity work.clk_div
      generic map
      (
        DIVISOR		=> TUTANKHAM_CPU_CLK_ENA_DIVIDE_BY
      )
      port map
      (
        clk				=> clk_30M,
        reset			=> clkrst_i.rst(0),
        clk_en		=> clk_1M5_en
      );
		
    cpu_inst : entity work.cpu09f
      port map
      (	
        clk				=> clk_1M5_en_n,
        rst				=> cpu_reset,
        rw				=> cpu_rw,
        vma				=> cpu_vma,
        fetch     => cpu_opfetch,
        addr		  => cpu_a,
        data_in		=> decrypted_d_i,
        data_out	=> cpu_d_o,
        halt			=> '0',
        hold			=> '0',
        irq				=> cpu_irq,
        firq			=> cpu_firq,
        nmi				=> cpu_nmi
      );

    GEN_STOCK_6809 : if not PLATFORM_HAS_KONAMI_CPU generate
      decrypted_d_i <= cpu_d_i;
    end generate GEN_STOCK_6809;
    
    GEN_KONAMI : if PLATFORM_HAS_KONAMI_CPU generate
      decrypted_d_i(7) <= ((cpu_d_i(7) and not cpu_a(1)) or (not cpu_d_i(7) and cpu_a(1))) 
                              when cpu_opfetch = '1' else
                            cpu_d_i(7);
      decrypted_d_i(6) <= cpu_d_i(6);
      decrypted_d_i(5) <= ((cpu_d_i(5) and cpu_a(1)) or (not cpu_d_i(5) and not cpu_a(1))) 
                              when cpu_opfetch = '1' else
                            cpu_d_i(5);
      decrypted_d_i(4) <= cpu_d_i(4);
      decrypted_d_i(3) <= ((cpu_d_i(3) and not cpu_a(3)) or (not cpu_d_i(3) and cpu_a(3))) 
                              when cpu_opfetch = '1' else
                            cpu_d_i(3);
      decrypted_d_i(2) <= cpu_d_i(2);
      decrypted_d_i(1) <= ((cpu_d_i(1) and cpu_a(3)) or (not cpu_d_i(1) and not cpu_a(3))) 
                              when cpu_opfetch = '1' else
                            cpu_d_i(1);
      decrypted_d_i(0) <= cpu_d_i(0);
    end generate GEN_KONAMI;
    
    wram_data <= sram_i.d(7 downto 0);

  end generate GEN_CPU09;
  
  GEN_REAL_6809 : if TUTANKHAM_USE_REAL_6809 generate
  begin

    --platform_o.arst <= clkrst_i.arst;
    platform_o.arst <= clkrst_i.rst(0);
    --platform_o.clk_50M <= clk_rst_i.clk(0);
    platform_o.clk_cpld <= clkrst_i.clk(0);
    platform_o.button <= buttons_i(platform_o.button'range);

    process (clk_30M, clkrst_i.rst(0))
      variable count : std_logic_vector(4 downto 0) := (others => '0');
    begin
      if clkrst_i.rst(0) = '1' then
        platform_o.cpu_6809_q <= '0';
        platform_o.cpu_6809_e <= '0';
        count := (others => '0');
      elsif rising_edge(clk_30M) then
        clk_1M5_en <= '0';  -- default
        case count is
          when "00111" =>
            platform_o.cpu_6809_q <= '1';
          when "01111" =>
            platform_o.cpu_6809_e <= '1';
          when "10001" =>
            -- this is where coco1 latches cpu address LSB
            cpu_a(7 downto 0) <= platform_i.cpu_6809_a(7 downto 0);
          when "10111" =>
            platform_o.cpu_6809_q <= '0';
            -- this is where coco1 latches cpu address MSB
            cpu_a(15 downto 8) <= platform_i.cpu_6809_a(15 downto 8);
            -- this is where coco1 enables writes to SRAM
            -- - just use clk_1M5_en in this case
            clk_1M5_en <= '1';
          when "11001" =>
            -- this is where coco1 latches sram data for CPU
            wram_data <= sram_i.d(7 downto 0);
          when "11111" =>
            platform_o.cpu_6809_e <= '0';
          when others =>
            null;
        end case;
        count := count + 1;
      end if;
    end process;

    platform_o.cpu_6809_rst_n <= not cpu_reset;
    cpu_rw <= platform_i.cpu_6809_r_wn;
    cpu_vma <= platform_i.cpu_6809_vma;
    --cpu_a <= platform_i.cpu_6809_a;
    platform_o.cpu_6809_d_i <= cpu_d_i;
    cpu_d_o <= platform_i.cpu_6809_d_o;
    platform_o.cpu_6809_halt_n <= '1';
    platform_o.cpu_6809_irq_n <= not cpu_irq;
    platform_o.cpu_6809_firq_n <= not cpu_firq;
    platform_o.cpu_6809_nmi_n <= not cpu_nmi;
    platform_o.cpu_6809_tsc <= '0';
    
  end generate GEN_REAL_6809;

	GEN_SRAM_ROMS : if TUTANKHAM_ROMS_IN_SRAM generate

		rom_c_data	<= sram_i.d(rom_c_data'range);
		rom_a_data	<= sram_i.d(rom_a_data'range);
		data_9000 	<= sram_i.d(data_9000'range);
		
	end generate GEN_SRAM_ROMS;
	
	GEN_FPGA_ROMS : if not TUTANKHAM_ROMS_IN_SRAM generate
    type data_9000_t is array (natural range <>) of std_logic_vector(7 downto 0);
    signal data_9000_c    : data_9000_t(1 to 9);
	begin
    
    rom_C000_inst : entity work.sprom
      generic map
      (
        init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & PLATFORM_VARIANT & 
                        "/roms/romC000.hex",
        numwords_a	=> 16384,
        widthad_a		=> 14
      )
      port map
      (
        clock			=> clk_30M,
        address		=> cpu_a(13 downto 0),
        q					=> rom_c_data
      );
    
    rom_A000_inst : entity work.sprom
      generic map
      (
        init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & PLATFORM_VARIANT &
                        "/roms/romA000.hex",
        numwords_a	=> 8192,
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_30M,
        address		=> cpu_a(12 downto 0),
        q					=> rom_a_data
      );
    
    GEN_TUTANKHM_ROM_DATA : if PLATFORM_VARIANT = "tutankham" generate
    
      GEN_TUTANKHM_ROMS : for i in 1 to 9 generate
        rom_c_inst : entity work.sprom
          generic map
          (
            init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & PLATFORM_VARIANT &
                            "/roms/c" & integer'image(i) & ".hex",
            --numwords_a	=> 4096,
            widthad_a		=> 12
          )
          port map
          (
            clock			=> clk_30M,
            address		=> cpu_a(11 downto 0),
            q					=> data_9000_c(i)
          );
      end generate GEN_TUTANKHM_ROMS;

      data_9000 <=  data_9000_c(1) when bank_r = X"0" else
                    data_9000_c(2) when bank_r = X"1" else
                    data_9000_c(3) when bank_r = X"2" else
                    data_9000_c(4) when bank_r = X"3" else
                    data_9000_c(5) when bank_r = X"4" else
                    data_9000_c(6) when bank_r = X"5" else
                    data_9000_c(7) when bank_r = X"6" else
                    data_9000_c(8) when bank_r = X"7" else
                    data_9000_c(9) when bank_r = X"8" else
                    (others => 'Z');
                    
    end generate GEN_TUTANKHM_ROM_DATA;
  
    GEN_JUNOFRST_ROM_DATA : if PLATFORM_VARIANT = "junofrst" generate

      GEN_JUNOFRST_ROMS : for i in 1 to 6 generate
        rom_c_inst : entity work.sprom
          generic map
          (
            init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & PLATFORM_VARIANT &
                            "/roms/c" & integer'image(i) & ".hex",
            --numwords_a	=> 8192,
            widthad_a		=> 13
          )
          port map
          (
            clock			            => clk_30M,
            address(12)           => bank_r(0),
            address(11 downto 0)  => cpu_a(11 downto 0),
            q					            => data_9000_c(i)
          );
      end generate GEN_JUNOFRST_ROMS;

      data_9000 <=  data_9000_c(1) when bank_r(3 downto 1) = "000" else
                    data_9000_c(2) when bank_r(3 downto 1) = "001" else
                    data_9000_c(3) when bank_r(3 downto 1) = "010" else
                    data_9000_c(4) when bank_r(3 downto 1) = "011" else
                    data_9000_c(5) when bank_r(3 downto 1) = "100" else
                    data_9000_c(6) when bank_r(3 downto 1) = "101" else
                    (others => 'Z');
                    
    end generate GEN_JUNOFRST_ROM_DATA;
  
	end generate GEN_FPGA_ROMS;
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram0_inst : entity work.dpram
		generic map
		(
			init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & PLATFORM_VARIANT &
                      "/roms/vram.hex",
			numwords_a	=> TUTANKHAM_VRAM_SIZE,
			widthad_a		=> TUTANKHAM_VRAM_WIDTHAD
		)
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> cpu_a(TUTANKHAM_VRAM_WIDTHAD-1 downto 0),
			wren_b			=> vram0_wr,
			data_b			=> cpu_d_o,
			q_b					=> vram0_data,

			clock_a			=> clk_video,
			address_a		=> bitmap_i(1).a(TUTANKHAM_VRAM_WIDTHAD-1 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> bitmap_o(1).d
		);

end SYN;
