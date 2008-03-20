library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.in8;
use work.project_pkg.all;

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

    -- on-board leds
    leds            : out std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

	alias clk_30M				  : std_logic is clk(0);
	alias clk_40M				  : std_logic is clk(1);
	
  -- uP signals  
  signal clk_3M_en			: std_logic;
  signal uP_addr        : std_logic_vector(15 downto 0);
  signal uP_datai       : std_logic_vector(7 downto 0);
  signal uP_datao       : std_logic_vector(7 downto 0);
  signal uPmemwr        : std_logic;
  signal uPnmireq       : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_datao      : std_logic_vector(7 downto 0);
                        
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
	
  -- interrupt signals
  signal nmiena_wr      : std_logic;

  -- other signals      
  signal inZero_cs      : std_logic;
  signal inOne_cs       : std_logic;
  signal dips_cs        : std_logic;
	signal inputs					: in8(0 to 1);  
	signal newTileAddr		: std_logic_vector(11 downto 0);
	
begin

	xcentre <= (others => '0');
	ycentre <= (others => '0');
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= EXT(uP_addr(13 downto 0), sram_o.a'length);
  sram_o.d <= EXT(uP_datao, sram_o.d'length);
  sram_o.be <= EXT("1", sram_o.be'length);
  sram_o.cs <= '1';
  sram_o.oe <= wram_cs and not uPmemwr;
  sram_o.we <= wram_cs and uPmemwr;

	wram_datao <= sram_i.d(wram_datao'range);
	
  -- chip select logic
	-- ROM $0000-$3FFF
  rom_cs <= 	'1' when STD_MATCH(uP_addr,  "00--------------") else '0';
	-- RAM $4000-$47FF,$5080-$50FF
  wram_cs <= 	'1' when STD_MATCH(uP_addr, X"4"&"0-----------") else 
							'1' when STD_MATCH(uP_addr,    X"50"&"1-------") else
							'0';
	-- VRAM $4800-$4BFF,$4C00-$4FFF(mirror)
  vram_cs <= 	'1' when STD_MATCH(uP_addr, X"4"&"1-----------") else '0';
	-- CRAM $5000-$503F
  cram_cs <= 	'1' when STD_MATCH(uP_addr,    X"50"&"00------") else '0';

  inZero_cs <= '1' when uP_addr(15 downto 11) = "01100" else '0';
  inOne_cs <= '1' when uP_addr(15 downto 11) = "01101" else '0';
  dips_cs <= '1' when uP_addr(15 downto 11) = "01110" else '0';

	-- memory read mux
	uP_datai <= X"00" when STD_MATCH(uP_addr, X"00AE") else
							X"00" when STD_MATCH(uP_addr, X"00C2") else
							X"00" when STD_MATCH(uP_addr, X"00C3") else
							X"00" when STD_MATCH(uP_addr, X"00C4") else
							X"00" when STD_MATCH(uP_addr, X"0C22") else
							X"00" when STD_MATCH(uP_addr, X"0C23") else
							X"00" when STD_MATCH(uP_addr, X"0C24") else
							X"00" when STD_MATCH(uP_addr, X"0C71") else
							X"00" when STD_MATCH(uP_addr, X"0C72") else
							X"00" when STD_MATCH(uP_addr, X"0C73") else
							X"00" when STD_MATCH(uP_addr, X"0CF0") else
							X"00" when STD_MATCH(uP_addr, X"0CF1") else
							X"00" when STD_MATCH(uP_addr, X"0D3C") else
							X"00" when STD_MATCH(uP_addr, X"0D3D") else
							X"00" when STD_MATCH(uP_addr, X"0D3E") else
							X"00" when STD_MATCH(uP_addr, X"1D82") else
							X"00" when STD_MATCH(uP_addr, X"1D83") else
							rom_datao when rom_cs = '1' else
							wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram1_datao when (cram_cs = '1' and uP_addr(0) = '1') else
							cram0_datao when (cram_cs = '1' and uP_addr(0) = '0') else
              inputs(0) when inzero_cs = '1' else
              inputs (1) when inone_cs = '1' else
              dip when dips_cs = '1' else
							(others => 'X');
	
	vram_wr <= uPmemwr and vram_cs;
	cram_wr <= cram_cs and uPmemwr;
  nmiena_wr <= uPmemwr when STD_MATCH(uP_addr, X"6801") else '0';
	-- SPRITE $5040-$505F(sprites),$5060-$507F(bullets)
  sprite_wr <= uPmemwr when STD_MATCH(uP_addr, X"50"&"01------") else '0';
		
	upaddr <= uP_addr;
	updatao <= uP_datao;
  sprite_reg_addr <= uP_addr(7 downto 0);

	-- mangle tile address according to sprite layout
	newTileAddr <= tileAddr(11 downto 6) & tileAddr(4 downto 1) & not tileAddr(5) & tileAddr(0);

  gfxextra_data <= (others => '0');
	GEN_PAL_DAT : for i in palette_data'range generate
		palette_data(i) <= (others => '0');
	end generate GEN_PAL_DAT;

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
	snd_wr <= '0';
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU enable clock (3MHz from 27/30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> SCRAMBLE_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset,
			clk_en		=> clk_3M_en
		);

  U_uP : entity work.uPse                                                
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

	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/scramble/roms/scrrom.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_30M,
			address		=> up_addr(13 downto 0),
			q					=> rom_datao
		);
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/scramble/roms/vram.hex",
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

	vrammapper_inst : entity work.vramMapper
		port map
		(
	    clk     => clk_40M,

	    inAddr  => tileMapAddr(12 downto 0),
	    outAddr => vram_addr
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram0_wr <= cram_wr and not uP_addr(0);
	
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
			CLK_1US_DIV	=> GALAXIAN_1MHz_CLK0_COUNTS
		)
	  port map
	  (
	    clk     		=> clk_30M,
	    reset   		=> reset,
	    ps2clk  		=> ps2clk,
	    ps2data 		=> ps2data,
			jamma				=> jamma,

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

	gfxrom_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/scramble/roms/scrgfx.hex",
			numwords_a	=> 4096,
			widthad_a		=> 12,
			numwords_b	=> 1024,
			widthad_b		=> 10,
			width_b			=> 32
		)
		port map
		(
			clock										=> clk_40M,
			address_a								=> newTileAddr,
			q_a											=> tileDatao,
			
			address_b								=> spriteAddr(9 downto 0),
			q_b(31 downto 24)				=> spriteData(7 downto 0),
			q_b(23 downto 16)				=> spriteData(15 downto 8),
			q_b(15 downto 8)				=> spriteData(23 downto 16),
			q_b(7 downto 0)					=> spriteData(31 downto 24)
		);

end SYN;

