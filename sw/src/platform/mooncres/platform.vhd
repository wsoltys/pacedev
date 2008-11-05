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
	alias clk_video       : std_logic is clk_i(1);
	signal cpu_reset			: std_logic;
	
  -- uP signals  
  signal clk_3M_ena			: std_logic;
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

  signal sprite_reg_cs  : std_logic;
  
  -- interrupt signals
  signal nmiena_wr      : std_logic;

  -- other signals      
  signal in_cs					: std_logic_vector(0 to 2);
	alias game_reset			: std_logic is inputs_i(3).d(0);
	
	alias  tileCode				: std_logic_vector(8 downto 0) is tilemap_i.tile_a(12 downto 4);
	signal tmpTileAddr		: std_logic_vector(12 downto 0);
	alias  newTileCode		: std_logic_vector(8 downto 0) is tmpTileAddr(12 downto 4);
	signal newTileAddr		: std_logic_vector(12 downto 0);
	alias  spriteCode			: std_logic_vector(6 downto 0) is sprite_i.a(10 downto 4);
	signal newSpriteaddr  : std_logic_vector(15 downto 0);   
	alias  newSpriteCode	: std_logic_vector(6 downto 0) is newSpriteAddr(10 downto 4);
	
	signal gfxbank				: std_logic_vector(23 downto 0);
	alias  gfxbank0				: std_logic_vector(7 downto 0) is gfxbank(7 downto 0);
	alias  gfxbank1				: std_logic_vector(7 downto 0) is gfxbank(15 downto 8);
	alias  gfxbank2				: std_logic_vector(7 downto 0) is gfxbank(23 downto 16);
	  
begin

	cpu_reset <= reset_i or game_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr(13 downto 0)), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length));
  SRAM_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
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
  sprite_reg_cs <= '1' when (uP_addr(15 downto 10) = "100110" and uP_addr(7 downto 6) = "01") else '0';
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
              inputs_i(0).d when in_cs(0) = '1' else
              inputs_i(1).d when in_cs(1) = '1' else
              inputs_i(2).d when in_cs(2) = '1' else
							wram_datao;
	
	vram_wr <= uPmemwr and vram_cs and not uP_addr(10);
	cram_wr <= uPmemwr and cram_cs;

  sprite_reg_o.clk <= clk_30M;
  sprite_reg_o.clk_ena <= clk_3M_ena;
  sprite_reg_o.a <= up_addr(7 downto 0);
  sprite_reg_o.d <= up_datao;
  sprite_reg_o.wr <= upmemwr and sprite_reg_cs;
  
	-- implement gfxbank registers
	process (clk_30M, reset_i)
	begin
		if reset_i = '1' then
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
	tmpTileAddr(3 downto 0) <= tilemap_i.tile_a(3 downto 0);
		
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
	newSpriteAddr(3 downto 0) <= sprite_i.a(3 downto 0);
	
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  bitmap_o <= NULL_TO_BITMAP_CTL;
  graphics_o <= NULL_TO_GRAPHICS;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o <= (others => '0');
  snd_o <= NULL_TO_SOUND;
  gp_o <= (others => '0');
  
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
			reset			=> reset_i,
			clk_en		=> clk_3M_ena
		);
	
  U_uP : entity work.Z80
    port map
    (
      clk 		=> clk_30M,                                   
      clk_en	=> clk_3M_ena,
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
			clock										=> clk_video,
			address_a								=> newTileAddr,
			q_a											=> tilemap_o.tile_d(7 downto 0),
			
			address_b								=> newSpriteAddr(10 downto 0),
			q_b(31 downto 24)				=> sprite_o.d(7 downto 0),
			q_b(23 downto 16)				=> sprite_o.d(15 downto 8),
			q_b(15 downto 8)				=> sprite_o.d(23 downto 16),
			q_b(7 downto 0)					=> sprite_o.d(31 downto 24)
		);
	tilemap_o.tile_d(tilemap_o.tile_d'left downto 8) <= (others => '0');

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
		PORT map
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
		PORT map
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
    generic map
    (
      USE_VIDEO_VBLANK  => MOONCRES_USE_VIDEO_VBLANK
    )
    port map
    (
      clk               => clk_30M,
      reset             => cpu_reset,
  
      z80_data          => uP_datao,
      nmiena_wr         => nmiena_wr,

			vblank						=> graphics_i.vblank,
  
      -- interrupt status & request lines
      nmi_req           => uPnmireq
    );

end SYN;
