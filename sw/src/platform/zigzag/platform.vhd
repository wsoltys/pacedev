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
	alias clk_video			  : std_logic is clk_i(1);
	
  -- uP signals  
  signal clk_3M_ena     : std_logic;
  signal uP_addr        : std_logic_vector(15 downto 0);
  signal uP_datai       : std_logic_vector(7 downto 0);
  signal uP_datao       : std_logic_vector(7 downto 0);
  signal uPmemwr        : std_logic;
  signal uPnmireq       : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_datao      : std_logic_vector(7 downto 0);
	signal decoded_addr		: std_logic_vector(13 downto 0);	-- mangled by protection
	                        
  -- keyboard signals
	                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
	signal vram_wr				: std_logic;
	signal vram_addr			: std_logic_vector(9 downto 0);
  signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_datao     : std_logic_vector(7 downto 0);

  -- CRAM signals        
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
  signal sprite_cs      : std_logic;
	
begin

  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr(15 downto 0)), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length)) 
								when (wram_cs = '1' and uPmemwr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= wram_cs and not uPmemwr;
  sram_o.we <= wram_cs and uPmemwr;

	wram_datao <= sram_i.d(wram_datao'range);
	
  -- chip select logic
	-- ROM $0000-$1FFF, $2000-$2FFF
  rom_cs <= '1' when uP_addr(15 downto 13) = "000" else 
						'1' when uP_addr(15 downto 12) = X"2" else
						'0';
	-- RAM $4000-$47FF, $5840-$58FF (supposedly writes from $5880 only..)
  wram_cs <= 	'1' when uP_addr(15 downto 11) = "01000" else 
							'1' when (uP_addr(15 downto 8) = X"58" and uP_addr(7 downto 6) /= "00") else
							'0';
	-- VRAM $5000-$53FF
  vram_cs <= '1' when uP_addr(15 downto 11) = "01010" else '0';
	-- CRAM $5800-$583F
  cram_cs <= '1' when uP_addr(15 downto 6) = "0101100000" else '0';
	-- SPRITES $5840-$587F
  sprite_cs <= '1' when uP_addr(15 downto 6) = "0101100001" else '0';
	-- IN0 $6000
  inZero_cs <= '1' when uP_addr = X"6000" else '0';
	-- IN1 $6800
  inOne_cs <= '1' when uP_addr = x"6800" else '0';
	-- DIPS $7000
  dips_cs <= '1' when uP_addr = X"7000" else '0';

	-- memory read mux
	uP_datai <= rom_datao when rom_cs = '1' else
							wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram1_datao when (cram_cs = '1' and uP_addr(0) = '1') else
							cram0_datao when (cram_cs = '1' and uP_addr(0) = '0') else
              inputs_i(0).d when inzero_cs = '1' else
              inputs_i(1).d when inone_cs = '1' else
              not switches_i(up_datai'range) when dips_cs = '1' else
							(others => '0');
	
	vram_wr <= uPmemwr and vram_cs;
	cram_wr <= cram_cs and uPmemwr;

  sprite_reg_o.clk <= clk_30M;
  sprite_reg_o.clk_ena <= clk_3M_ena;
  sprite_reg_o.wr <= upmemwr and sprite_cs;
  sprite_reg_o.a <= uP_addr(sprite_reg_o.a'range);
  sprite_reg_o.d <= up_datao;
  
	-- intena (NMI) $7001
  nmiena_wr <= uPmemwr when uP_addr = X"7001" else '0';
		
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  bitmap_o <= NULL_TO_BITMAP_CTL;
  graphics_o <= NULL_TO_GRAPHICS;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	snd_o <= NULL_TO_SOUND;
	leds_o <= (others => '0');
  gp_o <= (others => '0');
  
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU clock (3MHz from 30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> ZIGZAG_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset_i,
			clk_en		=> clk_3M_ena
		);

  U_uP : entity work.Z80                                                
    port map
    (
      clk			=> clk_30M,                                   
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

	protection_ist : entity work.ZigzagProtection
		port map
		(
	    clk         => clk_30M,
	    clk_ena     => clk_3M_ena,

	    -- address, data
	    addri       => uP_addr,
	    datai       => uP_datao,

	    -- input control
	    mem_wr      => uPmemwr,

	    -- output control
	    addro       => decoded_addr
		);

	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/zigzag/roms/zigrom.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_30M,
			address		=> decoded_addr,
			q					=> rom_datao
		);
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/zigzag/roms/zigvram.hex",
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
  tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

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

	-- note: ZigZag, unlike Galaxian, has separate tile, sprite roms
	
	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/zigzag/roms/tilerom.hex",
			numwords_a	=> 4096,
			widthad_a		=> 12
		)
		port map
		(
			clock			=> clk_video,
			address		=> tilemap_i.tile_a(11 downto 0),
			q					=> tilemap_o.tile_d
		);
	
	spriterom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/zigzag/roms/sprrom.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10,
			width_a			=> 32
		)
		port map
		(
			clock						=> clk_video,
			address					=> sprite_i.a(9 downto 0),
			q(31 downto 24)	=> sprite_o.d(7 downto 0),
			q(23 downto 16)	=> sprite_o.d(15 downto 8),
			q(15 downto 8)	=> sprite_o.d(23 downto 16),
			q(7 downto 0)		=> sprite_o.d(31 downto 24)
		);

end SYN;

