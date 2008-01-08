library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.EXT;

library work;
use work.kbd_pkg.in8;
use work.pace_pkg.all;
use work.project_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk         		: in std_logic_vector(0 to 3);
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
	signal cpu_reset			: std_logic;
	
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
  signal in_cs					: std_logic_vector(0 to 2);
	signal inputs					: in8(0 to 3);
	alias game_reset			: std_logic is inputs(3)(0);
	
	alias  tileCode				: std_logic_vector(8 downto 0) is tileAddr(12 downto 4);
	signal tmpTileAddr		: std_logic_vector(12 downto 0);
	alias  newTileCode		: std_logic_vector(8 downto 0) is tmpTileAddr(12 downto 4);
	signal newTileAddr		: std_logic_vector(12 downto 0);
	alias  spriteCode			: std_logic_vector(6 downto 0) is spriteAddr(10 downto 4);
	signal newSpriteaddr  : std_logic_vector(15 downto 0);   
	alias  newSpriteCode	: std_logic_vector(6 downto 0) is newSpriteAddr(10 downto 4);
	
	signal gfxbank				: std_logic_vector(23 downto 0);
	alias  gfxbank0				: std_logic_vector(7 downto 0) is gfxbank(7 downto 0);
	alias  gfxbank1				: std_logic_vector(7 downto 0) is gfxbank(15 downto 8);
	alias  gfxbank2				: std_logic_vector(7 downto 0) is gfxbank(23 downto 16);
	  
begin

	cpu_reset <= reset or game_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= EXT(uP_addr(13 downto 0), sram_o.a'length);
  sram_o.d <= EXT(uP_datao, sram_o.d'length);
  SRAM_o.be <= EXT("1", sram_o.be'length);
  sram_o.cs <= '1';
  sram_o.oe <= wram_cs and not uPmemwr;
  sram_o.we <= wram_cs and uPmemwr;

	wram_datao <= sram_i.d(wram_datao'range);
	
  -- chip select logic
	-- ROM $0000-$7FFF
  rom_cs <= '1' when uP_addr(15) = '0' else '0';
	-- RAM $8000-$9FFF (shadows below)
  wram_cs <= '1' when uP_addr(15 downto 13) = "100" else '0';
	-- VIDEO RAM (WRITES) $9000-$93FF (READS) $9400-$97FF
  vram_cs <= '1' when uP_addr(15 downto 11) = "10010" else '0';
	-- ATTRIBUTE RAM $9800-983F
  cram_cs <= '1' when uP_addr(15 downto 6) = "1001100000" else '0';
	-- SPRITES & BULLETS $9840-$985F,$9860-$987F
	-- WTF??
  sprite_wr <= uPmemwr when (uP_addr(15 downto 10) = "100110" and uP_addr(7 downto 6) = "01") else '0';
  --sprite_wr <= uPmemwr when (uP_addr(15 downto 7) = (X"98" & "01")) else '0';
	-- INPUTS $A000,$A800,$B000
  in_cs(0) <= '1' when uP_addr(15 downto 11) = "10100" else '0';
  in_cs(1) <= '1' when uP_addr(15 downto 11) = "10101" else '0';
  in_cs(2) <= '1' when uP_addr(15 downto 11) = "10110" else '0';
	-- NMI enable $B000
  nmiena_wr <= uPmemwr when uP_addr = X"B000" else '0';

	-- memory read mux
	uP_datai <= rom_datao when rom_cs = '1' else
							--wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram1_datao when (cram_cs = '1' and uP_addr(0) = '1') else
							cram0_datao when (cram_cs = '1' and uP_addr(0) = '0') else
              inputs(0) when in_cs(0) = '1' else
              inputs(1) when in_cs(1) = '1' else
              inputs(2) when in_cs(2) = '1' else
							wram_datao;
	
	vram_wr <= uPmemwr and vram_cs and not uP_addr(10);
	cram_wr <= uPmemwr and cram_cs;
		
	upaddr <= uP_addr;
	updatao <= uP_datao;
  sprite_reg_addr <= uP_addr(7 downto 0);

	-- implement gfxbank registers
	process (clk_30M, reset)
	begin
		if reset = '1' then
			gfxbank <= (others => '0');
		elsif rising_edge(clk_30M) then
			if uP_addr(15 downto 2) = (X"A00" & "00") then
				if uPmemwr = '1' then
					case uP_addr(1 downto 0) is
						when "00" =>
							gfxbank0 <= uP_datao;
						when "01" =>
							gfxbank1 <= uP_datao;
						when "10" =>
							gfxbank2 <= uP_datao;
						when others =>
					end case;
				end if;
			end if;
		end if;
	end process;

	newTileCode <= 	("000" & tileCode(5 downto 0)) or
									(gfxbank0(2 downto 0) & "000000") or
									(gfxbank1(1 downto 0) & "0000000") or
									"100000000"
										when (gfxbank2 /= X"00") and (tileCode(7 downto 6) = "10") else
									tileCode;
	tmpTileAddr(3 downto 0) <= tileAddr(3 downto 0);
		
	-- mangle tile address according to sprite layout
	-- WIP - can re-arrange sprites to fix
	newTileAddr <= tmpTileAddr(12 downto 6) & tmpTileAddr(4 downto 1) & not tmpTileAddr(5) & tmpTileAddr(0);
	
	-- mangle sprite address based on gfxbank
	-- sprite code is address[10..4]
	newSpriteCode <= 	("000" & spriteCode(3 downto 0)) or
										(gfxbank0(2 downto 0) & "0000") or
										(gfxbank1(1 downto 0) & "00000") or
										"1000000"
											when (gfxbank2 /= X"00") and (spriteCode(5 downto 4) = "10") else
										spriteCode;
	newSpriteAddr(15 downto 11) <= (others => '0');
	newSpriteAddr(3 downto 0) <= spriteAddr(3 downto 0);
	
	xcentre <= (others => '0');
	ycentre <= (others => '0');
	
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

	-- generate CPU clock enable (3MHz from 27/30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> MOONCRES_CPU_CLK_ENA_DIVIDE_BY
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
      reset  	=> cpu_reset,                                     

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

	rom_inst : work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/mooncres/roms/moonrom.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		PORT map
		(
			clock			=> clk_30M,
			address		=> up_addr(13 downto 0),
			q					=> rom_datao
		);
	
	vrom_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/mooncres/roms/moontile.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13,
			numwords_b	=> 2048,
			widthad_b		=> 11,
			width_b			=> 32
		)
		PORT map
		(
			clock										=> clk_40M,
			address_a								=> newTileAddr,
			q_a											=> tileDatao,
			
			address_b								=> newSpriteAddr(10 downto 0),
			q_b(31 downto 24)				=> spriteData(7 downto 0),
			q_b(23 downto 16)				=> spriteData(15 downto 8),
			q_b(15 downto 8)				=> spriteData(23 downto 16),
			q_b(7 downto 0)					=> spriteData(31 downto 24)
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/mooncres/moonvram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		PORT map
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
		PORT map
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
		PORT map
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
			NUM_INPUTS	=> inputs'length,
			CLK_1US_DIV	=> MOONCRES_1MHz_CLK0_COUNTS
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
      reset             => cpu_reset,
  
      z80_data          => uP_datao,
      nmiena_wr         => nmiena_wr,

			vblank						=> vblank,
  
      -- interrupt status & request lines
      nmi_req           => uPnmireq
    );

end SYN;

