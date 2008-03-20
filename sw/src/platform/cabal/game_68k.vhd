library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.in8;
use work.project_pkg.all;
use work.platform_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk             : in std_logic_vector(0 to 3);
    reset           : in std_logic;                       
    test_button     : in std_logic;                       

    -- inputs
    ps2clk          : inout std_logic;                       
    ps2data         : inout std_logic;                       
    dip             : in std_logic_vector(7 downto 0);    
		jamma						: in JAMMAInputsType;
		
    -- micro buses
    upaddr          : out std_logic_vector(15 downto 0);   
    updatao         : out std_logic_vector(7 downto 0);    

    -- SRAM
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    gfxextra_data   : out std_logic_vector(7 downto 0);
		palette_data		: out ByteArrayType(15 downto 0);

    -- graphics (bitmap)
		bitmap_addr			: in std_logic_vector(15 downto 0);
		bitmap_data			: out std_logic_vector(7 downto 0);
		
    -- graphics (tilemap)
    tilemapaddr     : in std_logic_vector(15 downto 0);   
    tilemapdatao    : out std_logic_vector(15 downto 0);    
    tileaddr        : in std_logic_vector(15 downto 0);   
    tiledatao       : out std_logic_vector(7 downto 0);    
    attr_addr       : in std_logic_vector(9 downto 0);    
    attr_dout       : out std_logic_vector(15 downto 0);   

    -- graphics (sprite)
    sprite_reg_addr : out std_logic_vector(7 downto 0);    
    sprite_wr       : out std_logic;                       
    spriteaddr      : in std_logic_vector(15 downto 0);   
    spritedata      : out std_logic_vector(31 downto 0);
		spr0_hit				: in std_logic;

    -- graphics (control)
    vblank          : in std_logic;    
		xcentre					: out std_logic_vector(9 downto 0);
		ycentre					: out std_logic_vector(9 downto 0);
		
    -- OSD
    to_osd          : out to_OSD_t;
    from_osd        : in from_OSD_t;

    -- sound
    snd_rd          : out std_logic;                       
    snd_wr          : out std_logic;
    sndif_datai     : in std_logic_vector(7 downto 0);    

    -- spi interface
    spi_clk         : out std_logic;                       
    spi_din         : in std_logic;                       
    spi_dout        : out std_logic;                       
    spi_ena         : out std_logic;                       
    spi_mode        : out std_logic;                       
    spi_sel         : out std_logic;                       

    -- serial
    ser_rx          : in std_logic;                       
    ser_tx          : out std_logic;                       

    gpio_i          : in std_logic_vector(63 downto 0);
    gpio_o          : out std_logic_vector(63 downto 0);

    -- on-board leds
    leds            : out std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

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

	alias clk_12M				  : std_logic is clk(0);
	alias clk_40M				  : std_logic is clk(1);
	
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
  signal up_addr_ext    : std_logic_vector(31 downto 0);
  alias up_addr         : std_logic_vector(23 downto 1) is up_addr_ext(23 downto 1);
  signal up_datai       : std_logic_vector(15 downto 0);
  signal up_datao       : std_logic_vector(15 downto 0);
  signal up_rwn					: std_logic;
  signal uPnmireq       : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_datao      : std_logic_vector(15 downto 0);
                        
  -- keyboard signals
	                        
  -- VRAM (text) signals       
	signal tram_cs				: std_logic;
	signal tram_wr				: std_logic;
  signal tram_datao     : std_logic_vector(15 downto 0);

	-- VARM (background) signals
	signal bgram_cs				: std_logic;
	signal bgram_wr				: std_logic;
	signal bgram_datao		: std_logic_vector(15 downto 0);
	                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_datao     : std_logic_vector(15 downto 0);

  -- RAM signals        
  signal cram_cs        : std_logic;
  signal cram_wr        : std_logic;
	signal cram0_wr				: std_logic;
	signal cram1_wr				: std_logic;
	signal cram0_datao		: std_logic_vector(7 downto 0);
	signal cram1_datao		: std_logic_vector(7 downto 0);
	
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
	
	signal inputs					: in8(0 to 2);  
	alias game_reset			: std_logic is inputs(inputs'high)(0);
	
begin

	reset_n <= not (reset or game_reset);
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= EXT(up_addr, sram_o.a'length);
  sram_o.d <= EXT(up_datao, sram_o.d'length);
	sram_o.be(3 downto 2) <= (others => '0');
	sram_o.be(1) <= '1' when (udsn_en = '1' and udsn = '0') else '0';
	sram_o.be(0) <= '1' when (ldsn_en = '1' and ldsn = '0') else '0';
  sram_o.cs <= '1';
  sram_o.oe <= (rom_cs or wram_cs) and up_rwn;
  sram_o.we <= wram_cs and not up_rwn;

	-- only signal write when rwn enabled
	up_rwn <= '0' when (rwn_en = '1' and rwn = '0') else '1';
	
	-- chipselect signals
	-- - note: up_addr _doesn't_ include bit 0
	-- ROM $000000-$03FFFF (256KB)
	rom_cs <= 		'1' when STD_MATCH(up_addr, X"0"&"00-----------------") else '0';
	-- RAM $040000-$04FFFF (64KB)
	wram_cs <= 		'1' when STD_MATCH(up_addr,    X"04"&"---------------") else '0';
	-- TEXT RAM $060000-$0607FF (2KB)
	tram_cs <= 		'1' when STD_MATCH(up_addr,       X"060"&"0----------") else '0';
	-- BACKGROUND RAM $080000-$0803FF (1KB)
	bgram_cs <=		'1' when STD_MATCH(up_addr,       X"080"&"00---------") else '0';
	-- dipswitches $0A0000-$0A0001 (1 word)
	dips_cs <= 		'1' when STD_MATCH(up_addr,             X"0A000"&"000") else '0';
	-- trackball(s) $0A0008-$0A000F (4 words)
	track_cs <= 	'1' when STD_MATCH(up_addr,             X"0A000"&"1--") else '0';
	-- input port 0 $0A0010-$0A0011 (1 word)
	inport0_cs <= '1' when STD_MATCH(up_addr,             X"0A001"&"000") else '0';
	-- seibu comms $0E8000-$0E800D
	seibu_cs <= 	'1' when STD_MATCH(up_addr,             X"0E800"&"---") else '0';
	
	-- write signals
	tram_wr <= tram_cs and not up_rwn;
	bgram_wr <= bgram_cs and not up_rwn;
	
	rom_datao <= sram_i.d(rom_datao'range);
	wram_datao <= sram_i.d(wram_datao'range);
	dips_datao <= X"7D70"; -- FreePlay, Easy etc
	inport0_datao <= inputs(1) & inputs(0); -- buttons
			
	-- read mux
	up_datai <= rom_datao when rom_cs = '1' else
							tram_datao when tram_cs = '1' else
							bgram_datao when bgram_cs = '1' else
							dips_datao when dips_cs = '1' else
							(others => '0') when track_cs = '1' else
							inport0_datao when inport0_cs = '1' else
							(others => '1') when seibu_cs = '1' else
							wram_datao;

  -- graphics subsystem values		
	upaddr <= up_addr(16 downto 1);
	updatao <= up_datao(7 downto 0);
  sprite_reg_addr <= up_addr(8 downto 1);

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
	process (clk_12M, reset_n, vblank, cpu_fc, cpu_fc_en)
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
			--elsif cpu_fc = "111" and cpu_fc_en = '1' and up_addr(19 downto 16) = "1111" then
			if cpu_fc = "111" and cpu_fc_en = '1' and up_addr(3 downto 1) = "001" then
				cpu_ipl_n <= (others => '1'); -- reset interrupt source
				dtackn <= '1';
			else
				dtackn <= not (not asn and asn_en);
			end if;

			vblank_r := vblank_r(vblank_r'left-1 downto 0) & vblank;
		end if;
	end process;

  -- unused outputs
	gfxextra_data <= (others => '0');
	GEN_PAL_DAT : for i in palette_data'range generate
		palette_data(i) <= (others => '0');
	end generate GEN_PAL_DAT;
	attr_dout <= (others => '0');
	bitmap_data <= (others => '0');
	spritedata <= (others => '0');
	sprite_wr <= '0';
	spi_clk <= '0';
	spi_dout <= '0';
	spi_ena <= '0';
	spi_mode <= '0';
	spi_sel <= '0';
	ser_tx <= 'X';
	leds <= (others => '0');
  snd_rd <= '0';
	snd_wr <= '0';
	xcentre <= (others => '0');
	ycentre <= (others => '0');
	
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
				ADR_OUT				=> up_addr,
				ADR_EN				=> open,
				DATA_IN				=> up_datai,
				DATA_OUT			=> up_datao,
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
      data_in       => up_datai,
      IPL           => cpu_ipl_n,
      dtack         => dtackn,
      addr          => up_addr_ext,
      data_out      => up_datao,
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
	
	GEN_68K : if CABAL_USE_EXTERNAL_68K generate

    BLK_68K : block

      alias m68k_reset_o_n    : std_logic is gpio_o(0);
      alias m68k_reset_i_n    : std_logic is gpio_i(0);
      alias m68k_halt_o_n     : std_logic is gpio_o(1);
      alias m68k_halt_i_n     : std_logic is gpio_i(1);
      alias m68k_d_o          : std_logic_vector(15 downto 0) is gpio_o(17 downto 2);
      alias m68k_d_i          : std_logic_vector(15 downto 0) is gpio_i(17 downto 2);
      alias m68k_a            : std_logic_vector(23 downto 1) is gpio_i(40 downto 18);
      alias m68k_fc           : std_logic_vector(2 downto 0) is gpio_i(43 downto 41);
      alias m68k_ipl_n        : std_logic_vector(2 downto 0) is gpio_o(20 downto 18);
      alias m68k_berr_n       : std_logic is gpio_o(21);
      alias m68k_vpa_n        : std_logic is gpio_o(22);
      alias m68k_e            : std_logic is gpio_i(44);
      alias m68k_vma_n        : std_logic is gpio_i(45);
      alias m68k_br_n         : std_logic is gpio_o(23);
      alias m68k_bgack_n      : std_logic is gpio_o(24);
      alias m68k_bg_n         : std_logic is gpio_i(46);
      alias m68k_dtack_n      : std_logic is gpio_o(25);
      alias m68k_rd_nwr       : std_logic is gpio_i(47);
      alias m68k_lds_n        : std_logic is gpio_i(48);
      alias m68k_uds_n        : std_logic is gpio_i(49);
      alias m68k_as_n         : std_logic is gpio_i(50);

    begin

      m68k_reset_o_n <= cpu_reset_n;
      m68k_halt_o_n <= '1';
      m68k_d_o <= up_datai;     -- to_the_68k
      m68k_ipl_n <= cpu_ipl_n;
      m68k_berr_n <= '1';
      m68k_vpa_n <= '1';
      m68k_br_n <= '1';
      m68k_bgack_n <= '1';
      m68k_dtack_n <= dtackn;

      up_addr <= m68k_a;
      up_datao <= m68k_d_i;     -- from_the_68k
      cpu_fc <= m68k_fc;
      asn <= m68k_as_n;
      rwn <= m68k_rd_nwr;
      udsn <= m68k_uds_n;
      ldsn <= m68k_lds_n;

    end block BLK_68K;

  end generate GEN_68K;

	inputs_inst : entity work.inputs
		generic map
		(
			NUM_INPUTS	=> inputs'length,
			CLK_1US_DIV	=> CABAL_1MHz_CLK0_COUNTS
		)
	  port map
	  (
	    clk     		=> clk_12M,
	    reset   		=> reset,
	    ps2clk  		=> ps2clk,
	    ps2data 		=> ps2data,
			jamma				=> jamma,

	    dips				=> dip,
	    inputs			=> inputs
	  );

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_text_inst : entity work.dpram
		generic map
		(
			--init_file		=> CABAL_SRC_DIR & "roms/cabal_vram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10,
			width_a			=> 16
		)
		port map
		(
			clock_b			=> clk_12M,
			address_b		=> uP_addr(10 downto 1),
			wren_b			=> tram_wr,
			data_b			=> up_datao,
			q_b					=> tram_datao,

			clock_a			=> clk_40M,
			address_a		=> tilemapaddr(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tileMapDatao
		);

	GEN_BGRAM : if false generate

		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		vram_bg_inst : entity work.dpram
			generic map
			(
				init_file		=> CABAL_SRC_DIR & "roms/cabal_vram.hex",
				numwords_a	=> 512,
				widthad_a		=> 9,
				width_a			=> 16
			)
			port map
			(
				clock_b			=> clk_12M,
				address_b		=> uP_addr(9 downto 1),
				wren_b			=> bgram_wr,
				data_b			=> up_datao,
				q_b					=> bgram_datao,

				clock_a			=> clk_40M,
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
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock				=> clk_40M,
			address			=> tileaddr(13 downto 0),
			q						=> tileDatao
		);

end SYN;
