library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sdram_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
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

	component PACE_WF68K00IP_TOP_SOC is
		port 
		(
			CLK						: in std_logic;
			RESET_COREn		: in std_logic; -- Core reset.
			
			-- Address and data:
			ADR_OUT				: out std_logic_vector(23 downto 1);
			ADR_EN				: out std_logic;
			DATA_IN				: in std_logic_vector(15 downto 0);
			DATA_OUT			: out std_logic_vector(15 downto 0);
			DATA_EN				: out std_logic;

			-- System control:
			BERRn					: in std_logic;
			RESET_INn			: in std_logic;
			RESET_OUT_EN	: out std_logic; -- Open drain.
			HALT_INn			: in std_logic;
			HALT_OUT_EN		: out std_logic; -- Open drain.
			
			-- Processor status:
			FC_OUT				: out std_logic_vector(2 downto 0);
			FC_OUT_EN			: out std_logic;
			
			-- Interrupt control:
			AVECn					: in std_logic; -- Originally 68Ks use VPAn.
			IPLn					: in std_logic_vector(2 downto 0);
			
			-- Aynchronous bus control:
			DTACKn				: in std_logic;
			AS_OUTn				: out std_logic;
			AS_OUT_EN			: out std_logic;
			RWn_OUT				: out std_logic;
			RW_OUT_EN			: out std_logic;
			UDS_OUTn			: out std_logic;
			UDS_OUT_EN		: out std_logic;
			LDS_OUTn			: out std_logic;
			LDS_OUT_EN		: out std_logic;
			
			-- Synchronous peripheral control:
			E							: out std_logic;
			VMA_OUTn			: out std_logic;
			VMA_OUT_EN		: out std_logic;
			VPAn					: in std_logic;
			
			-- Bus arbitration control:
			BRn						: in std_logic;
			BGn						: out std_logic;
			BGACKn				: in std_logic
			);
	end component PACE_WF68K00IP_TOP_SOC;

  component TG68 is
    port
    (        
      clk           : in std_logic;
      reset         : in std_logic;
      clkena_in     : in std_logic:='1';
      data_in       : in std_logic_vector(15 downto 0);
      IPL           : in std_logic_vector(2 downto 0):="111";
      dtack         : in std_logic;
      addr          : out std_logic_vector(31 downto 0);
      data_out      : out std_logic_vector(15 downto 0);
      as            : out std_logic;
      uds           : out std_logic;
      lds           : out std_logic;
      rw            : out std_logic
    );
  end component TG68;

	alias clk_12M				  : std_logic is clkrst_i.clk(0);
	alias clk_video			  : std_logic is clkrst_i.clk(1);
	
	-- 68k-specific signals
  signal data_en        : std_logic;
	signal asn						: std_logic;
	signal asn_en					: std_logic;
	signal rwn						: std_logic;
	signal rwn_en					: std_logic;
	signal udsn						: std_logic;
	signal udsn_en				: std_logic;
	signal ldsn						: std_logic;
	signal ldsn_en				: std_logic;
	signal dtackn					: std_logic;
	
  -- uP signals  
	signal reset_n				: std_logic;
  signal cpu_reset_n    : std_logic;
  signal cpu_reset_out_en : std_logic;
  signal cpu_a_ext      : std_logic_vector(31 downto 0);
  alias cpu_a           : std_logic_vector(23 downto 1) is cpu_a_ext(23 downto 1);
  signal cpu_d_i        : std_logic_vector(15 downto 0);
  signal cpu_d_o        : std_logic_vector(15 downto 0);
  signal cpu_rwn				: std_logic;
  signal cpu_nmireq     : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_d_o        : std_logic_vector(15 downto 0);
                        
  -- keyboard signals
	                        
  -- VRAM (text) signals       
	signal tram_cs				: std_logic;
	signal tram_wr				: std_logic;
  signal tram_d_o       : std_logic_vector(15 downto 0);

	-- VARM (background) signals
	signal bgram_cs				: std_logic;
	signal bgram_wr				: std_logic;
	signal bgram_d_o		  : std_logic_vector(15 downto 0);
	                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_d_o       : std_logic_vector(15 downto 0);

  -- RAM signals        
  signal cram_cs        : std_logic;
  signal cram_wr        : std_logic;
	signal cram0_wr				: std_logic;
	signal cram1_wr				: std_logic;
	signal cram0_d_o		  : std_logic_vector(7 downto 0);
	signal cram1_d_o		  : std_logic_vector(7 downto 0);
	
  -- interrupt signals
  signal cpu_ipl_n			: std_logic_vector(2 downto 0);

	signal cpu_fc					: std_logic_vector(2 downto 0);
	signal cpu_fc_en			: std_logic;

  -- other signals      
  signal dips_cs     		: std_logic;
	signal dips_datao			: std_logic_vector(15 downto 0);
	signal track_cs				: std_logic;
  signal inport0_cs     : std_logic;
	signal inport0_datao	: std_logic_vector(15 downto 0);
	signal seibu_cs				: std_logic;
	
	alias game_reset			: std_logic is inputs_i(inputs_i'high).d(0);
	
begin

	reset_n <= not (clkrst_i.arst or game_reset);
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be(3 downto 2) <= (others => '0');
	sram_o.be(1) <= '1' when (udsn_en = '1' and udsn = '0') else '0';
	sram_o.be(0) <= '1' when (ldsn_en = '1' and ldsn = '0') else '0';
  sram_o.cs <= '1';
  sram_o.oe <= (rom_cs or wram_cs) and cpu_rwn;
  sram_o.we <= wram_cs and not cpu_rwn;

	-- only signal write when rwn enabled
	cpu_rwn <= '0' when (rwn_en = '1' and rwn = '0') else '1';
	
	-- chipselect signals
	-- - note: cpu_a _doesn't_ include bit 0
	-- ROM $000000-$03FFFF (256KB)
	rom_cs <= 		'1' when STD_MATCH(cpu_a, X"0"&"00-----------------") else '0';
	-- RAM $040000-$04FFFF (64KB)
	wram_cs <= 		'1' when STD_MATCH(cpu_a,    X"04"&"---------------") else '0';
	-- TEXT RAM $060000-$0607FF (2KB)
	tram_cs <= 		'1' when STD_MATCH(cpu_a,       X"060"&"0----------") else '0';
	-- BACKGROUND RAM $080000-$0803FF (1KB)
	bgram_cs <=		'1' when STD_MATCH(cpu_a,       X"080"&"00---------") else '0';
	-- dipswitches $0A0000-$0A0001 (1 word)
	dips_cs <= 		'1' when STD_MATCH(cpu_a,             X"0A000"&"000") else '0';
	-- trackball(s) $0A0008-$0A000F (4 words)
	track_cs <= 	'1' when STD_MATCH(cpu_a,             X"0A000"&"1--") else '0';
	-- input port 0 $0A0010-$0A0011 (1 word)
	inport0_cs <= '1' when STD_MATCH(cpu_a,             X"0A001"&"000") else '0';
	-- seibu comms $0E8000-$0E800D
	seibu_cs <= 	'1' when STD_MATCH(cpu_a,             X"0E800"&"---") else '0';
	
	-- write signals
	tram_wr <= tram_cs and not cpu_rwn;
	bgram_wr <= bgram_cs and not cpu_rwn;

  GEN_ROM_IN_SRAM : if CABAL_ROM_IN_SRAM generate
    rom_d_o <= sram_i.d(rom_d_o'range);
  end generate GEN_ROM_IN_SRAM;
  
	wram_d_o <= sram_i.d(wram_d_o'range);
	dips_datao <= X"7D70"; -- FreePlay, Easy etc
	inport0_datao <= inputs_i(1).d & inputs_i(0).d; -- buttons
			
	-- read mux
	cpu_d_i <= rom_d_o when rom_cs = '1' else
							tram_d_o when tram_cs = '1' else
							bgram_d_o when bgram_cs = '1' else
							dips_datao when dips_cs = '1' else
							(others => '0') when track_cs = '1' else
							inport0_datao when inport0_cs = '1' else
							(others => '1') when seibu_cs = '1' else
							wram_d_o;

  -- graphics subsystem values		

  -- stretch reset for cpu reset
  process (clk_12M, reset_n)
    variable count : integer range 0 to 15;
  begin
    if reset_n = '0' then
      count := 15;
      cpu_reset_n <= '0';
    elsif rising_edge(clk_12M) then
      if count = 0 then
        cpu_reset_n <= '1';
      else
        count := count - 1;
      end if;
    end if;
  end process;

	-- DTACKn, interrupt generation and acknowledgement
	process (clk_12M, reset_n)
		variable vblank_r : std_logic_vector(3 downto 0) := (others => '0');
		alias vblank_prev : std_logic is vblank_r(vblank_r'left);
		alias vblank_unmeta : std_logic is vblank_r(vblank_r'left-1);
	begin
		if reset_n = '0' then
			cpu_ipl_n <= (others => '1');
			dtackn <= '1';
			vblank_r := (others => '1');
		elsif rising_edge(clk_12M) then
		
			-- handle assertion of interrupt
			-- note race condition between assertion/acknowledgement
			if vblank_unmeta = '1' and vblank_prev = '0' then
				cpu_ipl_n <= not "001"; -- IPL1
			-- experiment
			-- if interrupt hasn't been acknowledged by end of VBLANK
			-- then cancel the interrupt???
			-- this might mask the bug in the core for now...
			elsif vblank_unmeta = '0' then
				cpu_ipl_n <= (others => '1'); -- cancel interrupt
			end if;
			
			-- acknowlegement cycle
			-- note that DTACK, and AVECn should never be asserted simultaneously
			--elsif cpu_fc = "111" and cpu_fc_en = '1' and cpu_a(19 downto 16) = "1111" then
			if cpu_fc = "111" and cpu_fc_en = '1' and cpu_a(3 downto 1) = "001" then
				cpu_ipl_n <= (others => '1'); -- reset interrupt source
				dtackn <= '1';
			else
				dtackn <= not (not asn and asn_en);
			end if;

			vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
		end if;
	end process;

  -- unused outputs
  --bitmap_o <= NULL_TO_BITMAP_CTL;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  graphics_o <= NULL_TO_GRAPHICS;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  snd_o <= NULL_TO_SOUND;
  osd_o <= NULL_TO_OSD;
	leds_o <= (others => '0');
	
  --
  -- COMPONENT INSTANTIATION
  --

	GEN_WF_68K : if CABAL_USE_WF68K_CORE generate
	
		cpu_inst : PACE_WF68K00IP_TOP_SOC
			port map
			(
				CLK						=> clk_12M,
				RESET_COREn		=> cpu_reset_n,
				
				-- Address and data:
				ADR_OUT				=> cpu_a,
				ADR_EN				=> open,
				DATA_IN				=> cpu_d_i,
				DATA_OUT			=> cpu_d_o,
				DATA_EN				=> data_en,

				-- System control:
				BERRn					=> '1',
				RESET_INn			=> '1',
				RESET_OUT_EN	=> cpu_reset_out_en,
				HALT_INn			=> '1',
				HALT_OUT_EN		=> open,
				
				-- Processor status:
				FC_OUT				=> cpu_fc,
				FC_OUT_EN			=> cpu_fc_en,
				
				-- Interrupt control:
				AVECn					=> '0',		-- auto-vectored interrupts
				IPLn					=> cpu_ipl_n,
				
				-- Aynchronous bus control:
				DTACKn				=> dtackn,
				AS_OUTn				=> asn,
				AS_OUT_EN			=> asn_en,
				RWn_OUT				=> rwn,
				RW_OUT_EN			=> rwn_en,
				UDS_OUTn			=> udsn,
				UDS_OUT_EN		=> udsn_en,
				LDS_OUTn			=> ldsn,
				LDS_OUT_EN		=> ldsn_en,
				
				-- Synchronous peripheral control:
				E							=> open,
				VMA_OUTn			=> open,
				VMA_OUT_EN		=> open,
				VPAn					=> '1',
				
				-- Bus arbitration control:
				BRn						=> '1',
				BGn						=> open,
				BGACKn				=> '1'
			);
	end generate GEN_WF_68K;

	GEN_TG68 : if CABAL_USE_TG68_CORE generate
	
		cpu_inst : TG68
   	port map
		(        
			clk           => clk_12M,
			reset         => reset_n, -- active low
      clkena_in     => '1',
      data_in       => cpu_d_i,
      IPL           => cpu_ipl_n,
      dtack         => dtackn,
      addr          => cpu_a_ext,
      data_out      => cpu_d_o,
      as            => asn,
      uds           => udsn,
      lds           => ldsn,
      rw            => rwn
    );

		asn_en <= '1';
		rwn_en <= '1';
		udsn_en <= '1';
		ldsn_en <= '1';
    cpu_fc <= "111";
    cpu_fc_en <= '1';

	end generate GEN_TG68;
	
  GEN_INTERNAL_ROM : if not CABAL_ROM_IN_SRAM generate
  
    rom_inst : entity work.sprom
      generic map
      (
        init_file		=> CABAL_SRC_DIR & "roms/cabalus/maincpu.hex",
        --numwords_a	=> 65536,
        widthad_a		=> 15,
        width_a     => 16
      )
      port map
      (
        clock				=> clk_video,
        address			=> cpu_a(15 downto 1),
        q						=> rom_d_o
      );
    
  end generate GEN_INTERNAL_ROM;

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_text_inst : entity work.dpram
		generic map
		(
			--init_file		=> CABAL_SRC_DIR & "roms/cabal_vram.hex",
			--numwords_a	=> 1024,
			widthad_a		=> 10,
			width_a			=> 16
		)
		port map
		(
			clock_b			=> clk_12M,
			address_b		=> cpu_a(10 downto 1),
			wren_b			=> tram_wr,
			data_b			=> cpu_d_o,
			q_b					=> tram_d_o,

			clock_a			=> clk_video,
			address_a		=> tilemap_i(1).map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d
		);

	GEN_BGRAM : if false generate

		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		vram_bg_inst : entity work.dpram
			generic map
			(
				init_file		=> CABAL_SRC_DIR & "roms/cabal_vram.hex",
				--numwords_a	=> 512,
				widthad_a		=> 9,
				width_a			=> 16
			)
			port map
			(
				clock_b			=> clk_12M,
				address_b		=> cpu_a(9 downto 1),
				wren_b			=> bgram_wr,
				data_b			=> cpu_d_o,
				q_b					=> bgram_d_o,

				clock_a			=> clk_video,
				address_a		=> (others => 'X'),
				wren_a			=> '0',
				data_a			=> (others => 'X'),
				q_a					=> open
			);

	end generate GEN_BGRAM;
	
	chr_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> CABAL_SRC_DIR & "roms/cabal_chr.hex",
			--numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock				=> clk_video,
			address			=> tilemap_i(1).tile_a(13 downto 0),
			q						=> tilemap_o(1).tile_d
		);

end SYN;
