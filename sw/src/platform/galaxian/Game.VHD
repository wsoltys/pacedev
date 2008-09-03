library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- micro buses
    upaddr          : out std_logic_vector(15 downto 0);   
    updatao         : out std_logic_vector(7 downto 0);    

    -- FLASH/SRAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_FLASH_t;
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t;

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

    -- OSD
    to_osd          : out to_OSD_t;
    from_osd        : in from_OSD_t
  );

end Game;

architecture SYN of Game is

	alias clk_30M				  : std_logic is clk_i(0);
	alias clk_40M				  : std_logic is clk_i(1);
	
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
  signal wram_wr        : std_logic;
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
	
	GEN_EXTERNAL_WRAM : if not GALAXIAN_USE_INTERNAL_WRAM generate
	
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= EXT(uP_addr(13 downto 0), sram_o.a'length);
	  sram_o.d <= EXT(uP_datao, sram_o.d'length);
		wram_datao <= sram_i.d(wram_datao'range);
		sram_o.be <= EXT("1", sram_o.be'length);
	  sram_o.cs <= '1';
	  sram_o.oe <= wram_cs and not uPmemwr;
	  sram_o.we <= wram_wr;

	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if GALAXIAN_USE_INTERNAL_WRAM generate

		sram_o.a <= (others => 'X');
		sram_o.d <= (others => 'X');
		sram_o.be <= (others => '0');
		sram_o.cs <= '0';
		sram_o.oe <= '0';
		sram_o.we <= '0';
			
	end generate GEN_NO_SRAM;
	
  -- chip select logic
  rom_cs <= '1' when uP_addr(15 downto 14) = "00" else '0';
  wram_cs <= '1' when uP_addr(15 downto 11) = "01000" else '0';
  vram_cs <= '1' when uP_addr(15 downto 11) = "01010" else '0';
  cram_cs <= '1' when uP_addr(15 downto 10) = "010110" else '0';
  inZero_cs <= '1' when uP_addr(15 downto 11) = "01100" else '0';
  inOne_cs <= '1' when uP_addr(15 downto 11) = "01101" else '0';
  dips_cs <= '1' when uP_addr(15 downto 11) = "01110" else '0';

	-- memory read mux
	uP_datai <= rom_datao when rom_cs = '1' else
							wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram1_datao when (cram_cs = '1' and uP_addr(0) = '1') else
							cram0_datao when (cram_cs = '1' and uP_addr(0) = '0') else
              inputs(0) when inzero_cs = '1' else
              inputs (1) when inone_cs = '1' else
              switches_i(7 downto 0) when dips_cs = '1' else
							(others => 'X');
	
	vram_wr <= uPmemwr and vram_cs;
	cram_wr <= cram_cs and uPmemwr;
	wram_wr <= wram_cs and uPmemwr;
  nmiena_wr <= uPmemwr when (uP_addr(15 downto 12) = "0111" and uP_addr(2 downto 0) = "001") else '0';
  sprite_wr <= uPmemwr when (uP_addr(15 downto 10) = "010110" and uP_addr(7 downto 6) = "01") else '0';
		
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
  snd_rd <= '0';
	snd_wr <= '0';
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU enable clock (3MHz from 27/30MHz)
  clk_en_inst : entity work.clk_div
    generic map
    (
      DIVISOR		=> GALAXIAN_CPU_CLK_ENA_DIVIDE_BY
    )
    port map
    (
      clk				=> clk_30M,
      reset			=> reset_i,
      clk_en		=> clk_3M_en
    );
  
  U_uP : entity work.uPse                                                
    port map
    (
      clk 		=> clk_30M,                                   
      clk_en	=> clk_3M_en,
      reset  	=> reset_i,                                     

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
			init_file		=> "../../../../src/platform/galaxian/roms/galxrom.hex",
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
			init_file		=> "../../../../src/platform/galaxian/roms/galxvram.hex",
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
	    reset   		=> reset_i,
	    ps2clk  		=> inputs_i.ps2_kclk,
	    ps2data 		=> inputs_i.ps2_kdat,
			jamma				=> inputs_i.jamma_n,

	    dips				=> switches_i(7 downto 0),
	    inputs			=> inputs
	  );

  interrupts_inst : entity work.Galaxian_Interrupts
    port map
    (
      clk               => clk_30M,
      reset             => reset_i,
  
      z80_data          => uP_datao,
      nmiena_wr         => nmiena_wr,
  
			vblank						=> vblank,
			
      -- interrupt status & request lines
      nmi_req           => uPnmireq
    );

	gfxrom_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/galaxian/roms/gfxrom.hex",
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

		GEN_INTERNAL_WRAM : if GALAXIAN_USE_INTERNAL_WRAM generate
		
			wram_inst : entity work.spram
				generic map
				(
					numwords_a => 2048,
					widthad_a => 11
				)
				port map
				(
					clock				=> clk_30M,
					address			=> uP_addr(10 downto 0),
					data				=> up_datao,
					wren				=> wram_wr,
					q						=> wram_datao
				);
		
		end generate GEN_INTERNAL_WRAM;
		
end SYN;
