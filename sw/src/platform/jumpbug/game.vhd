library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.in8;
use work.project_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
		clk							: in std_logic_vector(0 to 3);
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
    sram_i          : in from_SRAM_t;
    sram_o          : out to_SRAM_t;

    gfxextra_data   : out std_logic_vector(7 downto 0);
		palette_data		: out ByteArrayType(15 downto 0);

    -- graphics (bitmap)
		bitmap_addr			: in std_logic_vector(15 downto 0);
		bitmap_data			: out std_logic_vector(7 downto 0);
		
    -- graphics (tilemap)
    tileaddr        : in std_logic_vector(15 downto 0);   
    tiledatao       : out std_logic_vector(7 downto 0);    
    tilemapaddr     : in std_logic_vector(15 downto 0);   
    tilemapdatao    : out std_logic_vector(15 downto 0);    
    attr_addr       : in std_logic_vector(9 downto 0);    
    attr_dout       : out std_logic_vector(15 downto 0);   

    -- graphics (sprite)
    sprite_reg_addr : out std_logic_vector(7 downto 0);    
    sprite_wr       : out std_logic;                       
    spriteaddr      : in std_logic_vector(15 downto 0);   
    spritedata      : out std_logic_vector(31 downto 0);   
    spr0_hit        : in std_logic;

    -- graphics (control)
    vblank          : in std_logic;    
		xcentre					: out std_logic_vector(9 downto 0);
		ycentre					: out std_logic_vector(9 downto 0);
		
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

    -- on-board leds
    leds            : out std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

	alias clk_30M					: std_logic is clk(0);
	alias clk_40M					: std_logic is clk(1);
	
  -- uP signals  
  signal clk_3M_en			: std_logic;
  signal uP_addr        : std_logic_vector(15 downto 0);
  signal uP_datai       : std_logic_vector(7 downto 0);
  signal uP_datao       : std_logic_vector(7 downto 0);
  signal uPmemwr        : std_logic;
  signal uPnmireq       : std_logic;
	                        
  -- ROM signals        
	signal rom0_cs				: std_logic;
	signal rom1_cs				: std_logic;
  signal rom0_datao     : std_logic_vector(7 downto 0);
  signal rom1_datao     : std_logic_vector(7 downto 0);
                        
  -- keyboard signals
	                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
	signal vram_wr				: std_logic;
	signal vram_addr			: std_logic_vector(9 downto 0);
  signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_datao     : std_logic_vector(7 downto 0);

  -- RAM signals        
  signal cram_cs        : std_logic;
  signal cram_wr        : std_logic;
	signal cram0_wr				: std_logic;
	signal cram1_wr				: std_logic;
	signal cram0_datao		: std_logic_vector(7 downto 0);
	signal cram1_datao		: std_logic_vector(7 downto 0);
	
	-- protection signals
	signal prot_cs				: std_logic;
	signal prot_datao			: std_logic_vector(7 downto 0);
	
  -- interrupt signals
  signal nmiena_wr      : std_logic;

  -- other signals      
  signal inZero_cs      : std_logic;
  signal inOne_cs       : std_logic;
  signal dips_cs        : std_logic;
	signal bank_wr				: std_logic;
	signal inputs					: in8(0 to 1);  
	signal newTileAddr		: std_logic_vector(12 downto 0);
	signal tile0datao			: std_logic_vector(tiledatao'range);
	signal tile1datao			: std_logic_vector(tiledatao'range);
	signal sprite0data 		: std_logic_vector(spritedata'range);
	signal sprite1data 		: std_logic_vector(spritedata'range);

	signal decoded_tileaddr		: std_logic_vector(12 downto 0);
	signal decoded_spriteaddr	: std_logic_vector(10 downto 0);
		
begin

	-- generate CPU clock (3MHz from 30MHz)
	
	xcentre <= (others => '0');
	ycentre <= (others => '0');
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= EXT(uP_addr(13 downto 0), sram_o.a'length);
  sram_o.d <= EXT(uP_datao, sram_o.d'length) when (wram_cs = '1' and uPmemwr = '1') else (others => 'Z');
  sram_o.be <= EXT("1", sram_o.be'length);
  sram_o.cs <= '1';
  sram_o.oe <= wram_cs and not uPmemwr;
  sram_o.we <= wram_cs and uPmemwr;

	wram_datao <= sram_i.d(wram_datao'range);
	
  -- chip select logic
	-- ROM0 $0000-$3FFF
  rom0_cs <= '1' when uP_addr(15 downto 14) = "00" else '0';
	-- RAM $4000-$47FF, $5040-$50FF (supposedly writes only from $5080...)
  wram_cs <= 	'1' when uP_addr(15 downto 11) = "01000" else 
							'1' when (uP_addr(15 downto 8) = X"50" and uP_addr(7 downto 6) /= "00") else
							'0';
	-- VRAM (mirror) $4800-$4BFF, $4C00-$4FFF
  vram_cs <= '1' when uP_addr(15 downto 11) = "01001" else '0';
	-- CRAM $5000-$503F
  cram_cs <= '1' when uP_addr(15 downto 6) = "0101000000" else '0';
	-- IN0 $6000
  inZero_cs <= '1' when uP_addr = X"6000" else '0';
	-- IN1 $6800
  inOne_cs <= '1' when uP_addr = X"6800" else '0';
	-- DIPS $7000
  dips_cs <= '1' when uP_addr = X"7000" else '0';
	-- ROM1 $8000-$AFFF
	rom1_cs <= '1' when (uP_addr(15 downto 14) = "10" and uP_addr(13 downto 12) /= "11") else '0';
	-- Protection $B000-$BFFF
	prot_cs <= '1' when uP_addr(15 downto 12) = X"B" else '0';

	-- memory read mux
	uP_datai <= rom0_datao when rom0_cs = '1' else
							wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram1_datao when (cram_cs = '1' and uP_addr(0) = '1') else
							cram0_datao when (cram_cs = '1' and uP_addr(0) = '0') else
              inputs(0) when inzero_cs = '1' else
              inputs(1) when inone_cs = '1' else
              dip when dips_cs = '1' else
							rom1_datao when rom1_cs = '1' else
							prot_datao when prot_cs = '1' else
							(others => 'X');
	
	vram_wr <= uPmemwr and vram_cs;
	cram_wr <= cram_cs and uPmemwr;
	-- NMI $7001
  nmiena_wr <= uPmemwr when uP_addr = X"7001" else '0';
	-- BANK $6002-$6006 (decode $600X)
	bank_wr <= uPmemwr when uP_addr(15 downto 4) = X"600" else '0';
	-- Sprites $5040-$507F
  sprite_wr <= uPmemwr when uP_addr(15 downto 6) = X"50"&"01" else '0';
  sprite_reg_addr <= uP_addr(7 downto 0);

	-- Sound $5800,$5900
	snd_wr <= uPmemwr when (uP_addr(15 downto 9) = X"5"&"100" and uP_addr(7 downto 0) = X"00") else '0';
		
	upaddr <= uP_addr;
	updatao <= uP_datao;

	-- mangle tile address according to sprite layout
	-- WIP - can re-arrange sprites to fix
	newtileaddr <= decoded_tileAddr(12 downto 6) & decoded_tileAddr(4 downto 1) & 
									not decoded_tileAddr(5) & decoded_tileAddr(0);

  gfxextra_data <= (others => '0');

  -- unused outputs
	bitmap_data <= (others => '0');
	spi_clk <= '0';
	spi_dout <= '0';
	spi_ena <= '0';
	spi_mode <= '0';
	spi_sel <= '0';
	ser_tx <= 'X';
	leds <= (others => '0');
  snd_rd <= '0';
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU clock (3MHz from 30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> JUMPBUG_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset,
			clk_en		=> clk_3M_en
		);

    up_inst : entity work.uPse
      port map
      (
      	clk 		=> clk_30M,                                   
      	clk_en	=> clk_3M_en,
        reset  	=> reset,                                     

        addr   	=> uP_addr,
        datai  	=> uP_datai,
        datao  	=> uP_datao,

        mem_rd 	=> open,
        mem_wr 	=> uPmemwr,
        io_rd  	=> open,
        io_wr  	=> open,

        intreq 	=> '0',
        intvec 	=> uP_datai,
        intack 	=> open,
        nmi    	=> uPnmireq
      );

	protection_inst : entity work.JumpBugProtection
		port map
		(
			addri				=> uP_addr(11 downto 0),
			datao				=> prot_datao
		);
		
	rom0_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/jumpbug/roms/jbugrom0.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_30M,
			address		=> up_addr(13 downto 0),
			q					=> rom0_datao
		);
	
	rom1_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/jumpbug/roms/jbugrom1.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_30M,
			address		=> up_addr(13 downto 0),
			q					=> rom1_datao
		);
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/jumpbug/roms/jbugvram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> uP_addr(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> uP_datao,
			q_b					=> vram_datao,

			clock_a			=> clk_40M,
			address_a		=> vram_addr,
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tileMapDatao(7 downto 0)
		);
  tileMapDatao(15 downto 8) <= (others => '0');

	vrammapper_inst : entity work.vramMapper
		port map
		(
	    clk     => clk_40M,

	    inAddr  => tileMapAddr(12 downto 0),
	    outAddr => vram_addr
		);

	cram0_wr <= cram_wr and not uP_addr(0);
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram_inst_0 : entity work.dpram
		generic map
		(
			numwords_a	=> 128,
			widthad_a		=> 7
		)
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> uP_addr(7 downto 1),
			wren_b			=> cram0_wr,
			data_b			=> uP_datao,
			q_b					=> cram0_datao,
			
			clock_a			=> clk_40M,
			address_a		=> attr_addr(7 downto 1),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> attr_dout(7 downto 0)
		);

	cram1_wr <= cram_wr and uP_addr(0);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram_inst_1 : entity work.dpram
		generic map
		(
			numwords_a	=> 128,
			widthad_a		=> 7
		)
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> uP_addr(7 downto 1),
			wren_b			=> cram1_wr,
			data_b			=> uP_datao,
			q_b					=> cram1_datao,
			
			clock_a			=> clk_40M,
			address_a		=> attr_addr(7 downto 1),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> attr_dout(15 downto 8)
		);

	inputs_inst : entity work.Inputs
		generic map
		(
			NUM_INPUTS	=> 2,
      CLK_1US_DIV => JUMPBUG_1MHz_CLK0_COUNTS
		)
	  port map
	  (
	    clk     		=> clk_30M,
	    reset   		=> reset,
	    ps2clk  		=> ps2clk,
	    ps2data 		=> ps2data,
      jamma       => jamma,

	    dips				=> dip,
	    inputs			=> inputs
	  );

  interrupts_inst : entity work.Galaxian_Interrupts
    port map
    (
      clk               => clk_30M,
      reset             => reset,
  
      z80_data          => uP_datao,
      nmiena_wr         => nmiena_wr,
  
			vblank						=> vblank,
			
      -- interrupt status & request lines
      nmi_req           => uPnmireq
    );

	gfxrom0_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/jumpbug/roms/gfxrom0.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13,
			numwords_b	=> 2048,
			widthad_b		=> 11,
			width_b			=> 32
		)
		port map
		(
			clock										=> clk_40M,
			address_a								=> newTileAddr(12 downto 0),
			q_a											=> tile0Datao,
			
			address_b								=> spriteAddr(10 downto 0),
			q_b(31 downto 24)				=> sprite0Data(7 downto 0),
			q_b(23 downto 16)				=> sprite0Data(15 downto 8),
			q_b(15 downto 8)				=> sprite0Data(23 downto 16),
			q_b(7 downto 0)					=> sprite0Data(31 downto 24)
		);

	gfxrom1_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/jumpbug/roms/gfxrom1.hex",
			numwords_a	=> 4096,
			widthad_a		=> 12,
			numwords_b	=> 1024,
			widthad_b		=> 10,
			width_b			=> 32
		)
		port map
		(
			clock										=> clk_40M,
			address_a								=> newTileAddr(11 downto 0),
			q_a											=> tile1Datao,
			
			address_b								=> spriteAddr(9 downto 0),
			q_b(31 downto 24)				=> sprite1Data(7 downto 0),
			q_b(23 downto 16)				=> sprite1Data(15 downto 8),
			q_b(15 downto 8)				=> sprite1Data(23 downto 16),
			q_b(7 downto 0)					=> sprite1Data(31 downto 24)
		);

	gfxdecode_inst : entity work.gfxDecode
		port map
		(
	    clk              				=> clk_30M,
	    reset            				=> reset,

	    -- bank control
	    bank_addr        				=> uP_addr(3 downto 0),
	    bank_data        				=> uP_datao(0),
	    bank_wr          				=> bank_wr,

	    -- tile address and mux
	    tile_addr_in     				=> tileaddr(12 downto 0),
	    tile_addr_out    				=> decoded_tileaddr,
	    tile0_data       				=> tile0datao,
	    tile1_data       				=> tile1datao,
	    tile_data_out    				=> tiledatao,

	    -- sprite address and mux
	    sprite_addr_in   				=> spriteaddr,
	    sprite_addr_out  				=> decoded_spriteaddr,
	    sprite0_data     				=> sprite0data,
	    sprite1_data     				=> sprite1data,
	    sprite_data_out  				=> spritedata
		);

end SYN;

