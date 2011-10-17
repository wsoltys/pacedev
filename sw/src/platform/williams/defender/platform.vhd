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

	constant DEFENDER_VRAM_SIZE		: integer := 2**DEFENDER_VRAM_WIDTHAD;

	alias clk_20M					: std_logic is clkrst_i.clk(0);
	alias clk_video				: std_logic is clkrst_i.clk(1);
	signal cpu_reset			: std_logic;
  alias rst_20M         : std_logic is clkrst_i.rst(0);
  
  -- uP signals  
  signal clk_1M_en			: std_logic;
	signal clk_1M_en_n		: std_logic;
	signal cpu_rw					: std_logic;
	signal cpu_vma				: std_logic;
	signal cpu_addr				: std_logic_vector(15 downto 0);
	signal cpu_data_i			: std_logic_vector(7 downto 0);
	signal cpu_data_o			: std_logic_vector(7 downto 0);
	signal cpu_irq				: std_logic;
	signal cpu_firq				: std_logic;
	signal cpu_nmi				: std_logic;
	                        
  -- ROM signals        
	signal rom_d_cs				: std_logic;
  signal rom_d_data     : std_logic_vector(7 downto 0);
	signal rom_e_cs				: std_logic;
  signal rom_e_data     : std_logic_vector(7 downto 0);
	signal sram_addr_hi		: std_logic_vector(16 downto 12);
	
	-- NVRAM signals
	signal nvram_cs				: std_logic;
	signal nvram_wr				: std_logic;
	signal nvram_data			: std_logic_vector(7 downto 0);

	-- video counter
	signal video_counter_cs	: std_logic;	
	
	-- banked signals
	signal bank_r					: std_logic_vector(2 downto 0);
	signal data_c_cs			: std_logic;
	signal data_c000			: std_logic_vector(7 downto 0);
	signal io_data				: std_logic_vector(7 downto 0);
  signal rom_b0_data    : std_logic_vector(7 downto 0);
  signal rom_b1_data    : std_logic_vector(7 downto 0);
  signal rom_b2_data    : std_logic_vector(7 downto 0);
  signal rom_b6_data    : std_logic_vector(7 downto 0);
	                        
  -- VRAM signals       
	signal vram0_cs				: std_logic;
  signal vram0_wr       : std_logic;
  signal vram0_data     : std_logic_vector(7 downto 0);
	signal vram8_cs				: std_logic;
  signal vram8_wr       : std_logic;
  signal vram8_data     : std_logic_vector(7 downto 0);
	signal vram9_cs				: std_logic;
  signal vram9_wr       : std_logic;
  signal vram9_data     : std_logic_vector(7 downto 0);

	signal bitmap0_data		: std_logic_vector(7 downto 0);
	signal bitmap8_data		: std_logic_vector(7 downto 0);
	signal bitmap9_data		: std_logic_vector(7 downto 0);
	                        
  -- RAM signals        
	signal wram_cs				: std_logic;
  signal wram_wr        : std_logic;
  alias wram_data      	: std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

	signal palette_cs			: std_logic;
	signal palette_wr			: std_logic;
	signal palette_r			: PAL_A_t(15 downto 0);
	
  -- other signals      
	alias game_reset			: std_logic is inputs_i(3).d(0);
	signal pia0_cs				: std_logic;
	signal pia1_cs				: std_logic;
	signal pia0_data			: std_logic_vector(7 downto 0);
	signal pia1_data			: std_logic_vector(7 downto 0);  
	signal va11						: std_logic;
	signal count240				: std_logic;
	signal pia1_irqa			: std_logic;
	signal pia1_irqb			: std_logic;
	
begin

	-- cpu09 core uses negative clock edge
	clk_1M_en_n <= not clk_1M_en;

	-- add game reset later
	cpu_reset <= rst_20M or game_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(16 downto 0)	<= 	sram_addr_hi & cpu_addr(11 downto 0) when data_c_cs = '1' else
								std_logic_vector(resize(unsigned(cpu_addr), 17));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_data_o), sram_o.d'length)) 
								when (wram_wr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not wram_wr;
  sram_o.we <= wram_wr;

	-- memory chip selects
	-- ROM $D000-$FFFF
	rom_d_cs <= 	'1' when STD_MATCH(cpu_addr, X"D"&"------------") else '0';
	rom_e_cs <= 	'1' when STD_MATCH(cpu_addr,  "111-------------") else '0';
	-- banked area $C000-$CFFF
	data_c_cs <= 	'1' when STD_MATCH(cpu_addr, X"C"&"------------") else '0';
	-- RAM $9800-$BFFF
	wram_cs <=		'1' when STD_MATCH(cpu_addr,  "101-------------") else
								'1' when STD_MATCH(cpu_addr, X"9"&"1-----------") else
								'0';
	-- video ram $0000-$9800
	vram9_cs <= 	'1' when STD_MATCH(cpu_addr, X"9"&"0-----------") else '0';
	vram8_cs <=		'1' when STD_MATCH(cpu_addr, X"8"&"------------") else '0';
	vram0_cs <=		'1' when STD_MATCH(cpu_addr,  "0---------------") else '0';

	-- I/O decoding
	-- PIA0 $CC04
	pia0_cs <= 					'1' when STD_MATCH(cpu_addr, X"CC0"&"01--") else '0';
	-- PIA1 $CC00
	pia1_cs <= 					'1' when STD_MATCH(cpu_addr, X"CC0"&"00--") else '0';
	-- video counter $C800-$CBFF
	video_counter_cs <=	'1' when STD_MATCH(cpu_addr, X"C"&"10----------") else '0';
	-- nvram (banked in with I/O) $C400-$C4FF
	nvram_cs <=					'1' when STD_MATCH(cpu_addr, X"C4"&"--------") else '0';
	palette_cs <=				'1' when STD_MATCH(cpu_addr, X"C00"&"----") else '0';
	
	-- I/O bank
	io_data <=		pia0_data when pia0_cs = '1' else
								pia1_data when pia1_cs = '1' else
								graphics_i.y(7 downto 2) & "00" when video_counter_cs = '1' else
								nvram_data when nvram_cs = '1' else
								(others => '0');
								
	-- mux banked area	
	data_c000 <= 	rom_b0_data when bank_r = "001" else
								rom_b1_data when bank_r = "010" else
								rom_b2_data when bank_r = "011" else
								rom_b6_data when bank_r = "111" else
								io_data; -- when bank_r = "000"
	
	-- memory read mux
	cpu_data_i <= 	rom_d_data when rom_d_cs = '1' else
									rom_e_data when rom_e_cs = '1' else
									data_c000 when data_c_cs = '1' else
									wram_data when wram_cs = '1' else
									vram9_data when vram9_cs = '1' else
									vram8_data when vram8_cs = '1' else
									vram0_data when vram0_cs = '1' else
									(others => '0');
	
	vram0_wr <= vram0_cs and not cpu_rw;
	vram8_wr <= vram8_cs and not cpu_rw;
	vram9_wr <= vram9_cs and not cpu_rw;
	palette_wr <= palette_cs and not cpu_rw;
	nvram_wr <= (nvram_cs and not cpu_rw) when bank_r = "000" else '0';
	--wram_wr <= not cpu_rw and not (rom_d_cs or rom_e_cs or (data_c_cs and sram_addr_hi(16)));

	-- memory write enables
	process (clk_20M, clk_1M_en)
	begin
		if rising_edge(clk_20M) then
			if clk_1M_en = '1' then
				-- always write thru to RAM unless ROM is addressed
				wram_wr <= not cpu_rw and not (rom_d_cs or rom_e_cs or (data_c_cs and sram_addr_hi(16)));
			else
				wram_wr <= '0';
			end if;
		end if;
	end process;
		
	-- implementation of the banking register
	process (clk_20M, clk_1M_en, cpu_reset)
		--variable bank_offset_v : std_logic_vector(bank_r'range);
		variable bank_offset_v : integer range 0 to 2**bank_r'length-1;
	begin
		if cpu_reset = '1' then
			bank_r <= (others => '0');
			sram_addr_hi <= (others => '0');
		elsif rising_edge(clk_20M) and clk_1M_en = '1' then
			if cpu_rw = '0' and STD_MATCH(cpu_addr, X"D000") then
				bank_r <= cpu_data_o(bank_r'range);
				-- calculate high bits of sram address
				if cpu_data_o(bank_r'range) = "000" then
					-- strictly speaking, we don't care about sram_addr when bank=0
					-- but this simplifies sram_we masking to protect ROMs
					sram_addr_hi <= '0' & X"C";
				else
					bank_offset_v := to_integer(unsigned(cpu_data_o(bank_r'range))) - 1;
					sram_addr_hi <= "10" & std_logic_vector(to_unsigned(bank_offset_v, bank_r'length));
				end if;
			end if;
		end if;
	end process;
	
	-- implementation of palette RAM
	process (clk_20M, clk_1M_en, palette_r)
		variable offset : integer range 0 to 2**4-1;
	begin
		if rising_edge(clk_20M) and clk_1M_en = '1' then
			if palette_wr = '1' then
				offset := to_integer(unsigned(cpu_addr(3 downto 0)));
				palette_r(offset) <= cpu_data_o;
			end if;
		end if;
		graphics_o.pal <= palette_r;
	end process;
	
	bitmap_o(1).d <= 	bitmap0_data when bitmap_i(1).a(15) = '0' else
                    bitmap8_data when bitmap_i(1).a(15 downto 12) = X"8" else
                    bitmap9_data;

	-- irqa interrupt at scanline 240
	process (clk_20M, rst_20M)
	begin
		if rst_20M = '1' then
			count240 <= '0';
		elsif rising_edge(clk_20M) then
			if graphics_i.y = std_logic_vector(to_unsigned(0, graphics_i.y'length)) then
				count240 <= '0';
			-- check for 240
			--elsif video_counter = 240 then
			elsif graphics_i.y = std_logic_vector(to_unsigned(239, graphics_i.y'length)) then
				count240 <= '1';
			end if;
		end if;
	end process;

	-- irqb every 16 scanlines
	va11 <= graphics_i.y(5);

	-- cpu interrupts
	cpu_irq <= pia1_irqa or pia1_irqb;
	cpu_firq <= '0';
	cpu_nmi <= '0';

  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --tilemap_o <= NULL_TO_TILEMAP_CTL;
  graphics_o.bit8(0) <= (others => '0');
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> 20
		)
		port map
		(
			clk				=> clk_20M,
			reset			=> rst_20M,
			clk_en		=> clk_1M_en
		);
		
	cpu_inst : entity work.cpu09
		port map
		(	
			clk				=> clk_1M_en_n,
			rst				=> cpu_reset,
			rw				=> cpu_rw,
			vma				=> cpu_vma,
			addr		  => cpu_addr,
		  data_in		=> cpu_data_i,
		  data_out	=> cpu_data_o,
			halt			=> '0',
			hold			=> '0',
			irq				=> cpu_irq,
			firq			=> cpu_firq,
			nmi				=> cpu_nmi
		);

	-- Battery-backed CMOS RAM
	nvram_inst : entity work.spram
		generic map
		(
			init_file		=> "../../../../../src/platform/williams/defender/roms/defcmos.hex",
			numwords_a	=> 256,
			widthad_a		=> 8
		)
		port map
		(
			clock				=> clk_20M,
			address			=> cpu_addr(7 downto 0),
			wren				=> nvram_wr,
			data				=> cpu_data_o,
			q						=> nvram_data
		);

	GEN_SRAM_ROMS : if DEFENDER_ROMS_IN_SRAM generate

		rom_d_data <= sram_i.d(rom_d_data'range);
		rom_e_data <= sram_i.d(rom_e_data'range);
		rom_b0_data <= sram_i.d(rom_b0_data'range);
		rom_b1_data <= sram_i.d(rom_b1_data'range);
		rom_b2_data <= sram_i.d(rom_b2_data'range);
		rom_b6_data <= sram_i.d(rom_b6_data'range);

	end generate GEN_SRAM_ROMS;
	
	GEN_FPGA_ROMS : if not DEFENDER_ROMS_IN_SRAM generate
	
		rom_D000_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../../src/platform/williams/defender/roms/rom_d.hex",
				--numwords_a	=> 4096,
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> cpu_addr(11 downto 0),
				q					=> rom_d_data
			);
		
		rom_E000_F000_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../../src/platform/williams/defender/roms/rom_ef.hex",
				--numwords_a	=> 8192,
				widthad_a		=> 13
			)
			port map
			(
				clock			=> clk_20M,
				address		=> cpu_addr(12 downto 0),
				q					=> rom_e_data
			);
		
		rom_bank0_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../../src/platform/williams/defender/roms/rom_b0.hex",
				--numwords_a	=> 4096,
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> cpu_addr(11 downto 0),
				q					=> rom_b0_data
			);
		
		rom_bank1_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../../src/platform/williams/defender/roms/rom_b1.hex",
				--numwords_a	=> 4096,
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> cpu_addr(11 downto 0),
				q					=> rom_b1_data
			);
		
		rom_bank2_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../../src/platform/williams/defender/roms/rom_b2.hex",
				--numwords_a	=> 4096,
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> cpu_addr(11 downto 0),
				q					=> rom_b2_data
			);
		
		rom_bank6_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../../src/platform/williams/defender/roms/rom_b6.hex",
				--numwords_a	=> 2048,
				widthad_a		=> 11
			)
			port map
			(
				clock			=> clk_20M,
				address		=> cpu_addr(10 downto 0),
				q					=> rom_b6_data
			);

	end generate GEN_FPGA_ROMS;
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram0_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../src/platform/williams/defender/roms/vram.hex",
			--numwords_a	=> DEFENDER_VRAM_SIZE,
			widthad_a		=> DEFENDER_VRAM_WIDTHAD
		)
		port map
		(
			clock_b			=> clk_20M,
			address_b		=> cpu_addr(DEFENDER_VRAM_WIDTHAD-1 downto 0),
			wren_b			=> vram0_wr,
			data_b			=> cpu_data_o,
			q_b					=> vram0_data,

			clock_a			=> clk_video,
			address_a		=> bitmap_i(1).a(DEFENDER_VRAM_WIDTHAD-1 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> bitmap0_data
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram8_inst : entity work.dpram
		generic map
		(
			--numwords_a	=> 4096,
			widthad_a		=> 12
		)
		port map
		(
			clock_b			=> clk_20M,
			address_b		=> cpu_addr(11 downto 0),
			wren_b			=> vram8_wr,
			data_b			=> cpu_data_o,
			q_b					=> vram8_data,

			clock_a			=> clk_video,
			address_a		=> bitmap_i(1).a(11 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> bitmap8_data
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram9_inst : entity work.dpram
		generic map
		(
			--numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock_b			=> clk_20M,
			address_b		=> cpu_addr(10 downto 0),
			wren_b			=> vram9_wr,
			data_b			=> cpu_data_o,
			q_b					=> vram9_data,

			clock_a			=> clk_video,
			address_a		=> bitmap_i(1).a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> bitmap9_data
		);

	pia1_0 : entity work.pia6821
		port map
		(	
			clk       	=> clk_1M_en,
	    rst       	=> rst_20M,
	    cs        	=> pia0_cs,
	    rw        	=> cpu_rw,
	    addr      	=> cpu_addr(1 downto 0),
	    data_in   	=> cpu_data_o,
		 	data_out  	=> pia0_data,
		 	irqa      	=> open,
		 	irqb      	=> open,
		 	pa_i       	=> inputs_i(0).d,
      pa_o        => open,
      pa_oe       => open,
		 	ca1       	=> '0',
		 	ca2_i      	=> '0',
      ca2_o       => open,
      ca2_oe      => open,
		 	pb_i      	=> inputs_i(1).d,
      pb_o        => open,
      pb_oe       => open,
		 	cb1       	=> '0',
		 	cb2_i      	=> '0',
      cb2_o       => open,
      cb2_oe      => open
		);

	pia1_1 : entity work.pia6821
		port map
		(	
			clk       	=> clk_1M_en,
	    rst       	=> rst_20M,
	    cs        	=> pia1_cs,
	    rw        	=> cpu_rw,
	    addr      	=> cpu_addr(1 downto 0),
	    data_in   	=> cpu_data_o,
		 	data_out  	=> pia1_data,
		 	irqa      	=> pia1_irqa,
		 	irqb      	=> pia1_irqb,
		 	pa_i      	=> inputs_i(2).d,
      pa_o        => open,
      pa_oe       => open,
		 	ca1       	=> count240,
		 	ca2_i      	=> '0',
      ca2_o       => open,
      ca2_oe      => open,
		 	pb_i      	=> (others => '0'),
      pb_o        => open,
      pb_oe       => open,
		 	cb1       	=> va11,
		 	cb2_i      	=> '0',
      cb2_o       => open,
      cb2_oe      => open
		);

end SYN;
