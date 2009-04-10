library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
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
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

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
    
    bitmap_i        : in from_BITMAP_CTL_t;
    bitmap_o        : out to_BITMAP_CTL_t;
    
    tilemap_i       : in from_TILEMAP_CTL_t;
    tilemap_o       : out to_TILEMAP_CTL_t;

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

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );

end platform;

architecture SYN of platform is

	alias clk_30M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	
  -- uP signals  
  signal clk_3M_ena			: std_logic;
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
  signal sprite_cs      : std_logic;
	signal bank_wr				: std_logic;
	signal newTileAddr		: std_logic_vector(12 downto 0);
	signal tile0datao			: std_logic_vector(tilemap_o.tile_d'range);
	signal tile1datao			: std_logic_vector(tilemap_o.tile_d'range);
	signal sprite0data 		: std_logic_vector(sprite_o.d'range);
	signal sprite1data 		: std_logic_vector(sprite_o.d'range);

	signal decoded_tileaddr		: std_logic_vector(12 downto 0);
	signal decoded_spriteaddr	: std_logic_vector(10 downto 0);
		
begin

  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr(13 downto 0)), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length)) 
                when (wram_cs = '1' and uPmemwr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
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
              inputs_i(0).d when inzero_cs = '1' else
              inputs_i(1).d when inone_cs = '1' else
              switches_i(7 downto 0) when dips_cs = '1' else
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
  sprite_cs <= '1' when uP_addr(15 downto 6) = X"50"&"01" else '0';

	-- Sound $5800,$5900
	snd_o.wr <= uPmemwr when (uP_addr(15 downto 9) = X"5"&"100" and uP_addr(7 downto 0) = X"00") else '0';

  -- sprites
  sprite_reg_o.clk <= clk_30M;
  sprite_reg_o.clk_ena <= clk_3M_ena;
  sprite_reg_o.a <= uP_addr(7 downto 0);
  sprite_reg_o.d <= up_datao;
  sprite_reg_o.wr <= sprite_cs and upmemwr;
  
	-- mangle tile address according to sprite layout
	-- WIP - can re-arrange sprites to fix
	newtileaddr <= decoded_tileAddr(12 downto 6) & decoded_tileAddr(4 downto 1) & 
									not decoded_tileAddr(5) & decoded_tileAddr(0);

  -- unused outputs
	bitmap_o <= NULL_TO_BITMAP_CTL;
	spi_o <= NULL_TO_SPI;
	ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
	gp_o <= NULL_TO_GP;
	
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
			reset			=> reset_i,
			clk_en		=> clk_3M_ena
		);

    up_inst : entity work.Z80
      port map
      (
      	clk 		=> clk_30M,                                   
      	clk_en	=> clk_3M_ena,
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

	protection_inst : entity work.JumpBugProtection
		port map
		(
			addri				=> uP_addr(11 downto 0),
			datao				=> prot_datao
		);

  GEN_INTERNAL_ROMS : if not JUMPBUG_ROMS_IN_FLASH generate

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

    flash_o <= NULL_TO_FLASH;

  end generate GEN_INTERNAL_ROMS;
  
  GEN_FLASH_ROMS : if JUMPBUG_ROMS_IN_FLASH generate

    flash_o.a(flash_o.a'left downto 15) <= (others => '0');
    flash_o.a(14 downto 0) <= rom1_cs & up_addr(13 downto 0);
    flash_o.d <= (others => '0'); -- not used
    flash_o.cs <= rom0_cs or rom1_cs;
    flash_o.oe <= '1';
    flash_o.we <= '0';

    rom0_datao <= flash_i.d;
    rom1_datao <= flash_i.d;
    
  end generate GEN_FLASH_ROMS;
	
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

			clock_a			=> clk_video,
			address_a		=> vram_addr,
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
  tilemap_o.map_d(15 downto 8) <= (others => '0');

	vrammapper_inst : entity work.vramMapper
		port map
		(
	    clk     => clk_video,

	    inAddr  => tilemap_i.map_a(12 downto 0),
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
			
			clock_a			=> clk_video,
			address_a		=> tilemap_i.attr_a(7 downto 1),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.attr_d(7 downto 0)
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
			
			clock_a			=> clk_video,
			address_a		=> tilemap_i.attr_a(7 downto 1),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.attr_d(15 downto 8)
		);

  interrupts_inst : entity work.Galaxian_Interrupts
    port map
    (
      clk               => clk_30M,
      reset             => reset_i,
  
      z80_data          => uP_datao,
      nmiena_wr         => nmiena_wr,
  
			vblank						=> graphics_i.vblank,
			
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
			clock										=> clk_video,
			address_a								=> newTileAddr(12 downto 0),
			q_a											=> tile0Datao,
			
			address_b								=> sprite_i.a(10 downto 0),
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
			clock										=> clk_video,
			address_a								=> newTileAddr(11 downto 0),
			q_a											=> tile1Datao,
			
			address_b								=> sprite_i.a(9 downto 0),
			q_b(31 downto 24)				=> sprite1Data(7 downto 0),
			q_b(23 downto 16)				=> sprite1Data(15 downto 8),
			q_b(15 downto 8)				=> sprite1Data(23 downto 16),
			q_b(7 downto 0)					=> sprite1Data(31 downto 24)
		);

	gfxdecode_inst : entity work.gfxDecode
		port map
		(
	    clk              				=> clk_30M,
	    reset            				=> reset_i,

	    -- bank control
	    bank_addr        				=> uP_addr(3 downto 0),
	    bank_data        				=> uP_datao(0),
	    bank_wr          				=> bank_wr,

	    -- tile address and mux
	    tile_addr_in     				=> tilemap_i.tile_a(12 downto 0),
	    tile_addr_out    				=> decoded_tileaddr,
	    tile0_data       				=> tile0datao,
	    tile1_data       				=> tile1datao,
	    tile_data_out    				=> tilemap_o.tile_d,

	    -- sprite address and mux
	    sprite_addr_in   				=> sprite_i.a,
	    sprite_addr_out  				=> decoded_spriteaddr,
	    sprite0_data     				=> sprite0data,
	    sprite1_data     				=> sprite1data,
	    sprite_data_out  				=> sprite_o.d
		);

end SYN;

