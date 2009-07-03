library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
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
	signal cpu_reset			: std_logic;
	
  -- uP signals  
  signal clk_3M_ena			: std_logic;
  signal uP_addr        : std_logic_vector(15 downto 0);
  signal uP_datai       : std_logic_vector(7 downto 0);
  signal uP_datao       : std_logic_vector(7 downto 0);
  signal uPmemwr        : std_logic;
	signal uPiowr					: std_logic;
  signal uPintreq       : std_logic;
	signal uPintack				: std_logic;
	signal uPintvec				: std_logic_vector(7 downto 0);
	                        
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
	signal cram_up_data		: std_logic_vector(7 downto 0);
	signal cram_data			: std_logic_vector(7 downto 0);
	
  -- interrupt signals
  signal intena_wr      : std_logic;

  -- other signals      
  signal inZero_cs      : std_logic;
  signal inOne_cs       : std_logic;
  signal dip0_cs        : std_logic;
  signal dip1_cs        : std_logic;
  signal sprite_cs      : std_logic;
	alias game_reset			: std_logic is inputs_i(2).d(0);
	signal newTileAddr		: std_logic_vector(11 downto 0);
  signal sprite_4_wr    : std_logic;
	signal palette_bank		: std_logic;
	signal clut_bank			: std_logic;
	signal gfx_bank				: std_logic;
	
begin

	cpu_reset <= reset_i or game_reset;
	
	GEN_EXTERNAL_WRAM : if not PENGO_USE_INTERNAL_WRAM generate
	
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr), sram_o.a'length));
	  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length));
		wram_datao <= sram_i.d(wram_datao'range);
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	  sram_o.cs <= '1';
	  sram_o.oe <= wram_cs and not uPmemwr;
	  sram_o.we <= wram_wr;

	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if PENGO_USE_INTERNAL_WRAM generate

		sram_o.a <= (others => 'X');
		sram_o.d <= (others => 'X');
		sram_o.be <= (others => '0');
		sram_o.cs <= '0';
		sram_o.oe <= '0';
		sram_o.we <= '0';
			
	end generate GEN_NO_SRAM;
	
  -- chip select logic
	-- ROM $0000-$7FFF
  rom_cs <= 		'1' when STD_MATCH(uP_addr, "0---------------") else '0';
  -- VRAM $8000-$83FF
  vram_cs <= 		'1' when STD_MATCH(uP_addr, "100000----------") else '0';
  -- CRAM $8400-$87FF
  cram_cs <= 		'1' when STD_MATCH(uP_addr, "100001----------") else '0';
	-- WRAM $8800-$8FFF
  wram_cs <= 		'1' when STD_MATCH(uP_addr, "10001-----------") else '0';
	-- DIP1 $9000
  dip1_cs <= 		'1' when STD_MATCH(uP_addr, X"90"  &"00------") else '0';
	-- DIP0 $9040
  dip0_cs <= 		'1' when STD_MATCH(uP_addr, X"90"  &"01------") else '0';
	-- IN1 $9080
  inOne_cs <= 	'1' when STD_MATCH(uP_addr, X"90"  &"10------") else '0';
	-- IN0 $90C0
  inZero_cs <= 	'1' when STD_MATCH(uP_addr, X"90"  &"11------") else '0';

	-- memory read mux
	uP_datai <= rom_datao when rom_cs = '1' else
							wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram_up_data when cram_cs = '1' else
              inputs_i(0).d when inzero_cs = '1' else
              inputs_i(1).d when inone_cs = '1' else
              not switches_i(7 downto 0) when dip0_cs = '1' else
     					-- 1C/1C for both coin mechs
							"11001100" when dip1_cs = '1' else
							(others => 'X');
	
	vram_wr <= uPmemwr and vram_cs;
	cram_wr <= cram_cs and uPmemwr;
	wram_wr <= wram_cs and uPmemwr;
	
  -- INTENA $9040
  intena_wr <= uPmemwr when STD_MATCH(uP_addr, X"9040") else '0';
  -- SPRITE_WR $8FF2-$8FFD, $9022-$902D
  -- $8FFX or $902X
  sprite_cs <= '1' when STD_MATCH(uP_addr, X"8FF"&"----") else
               '1' when STD_MATCH(uP_addr, X"902"&"----") else
               '0';
  -- SOUND $9000-$901F
	snd_o.wr <= uPmemwr when STD_MATCH(uP_addr, X"90"&"000-----") else '0';

	-- bank latches
	process (clk_30M, clk_3M_ena, cpu_reset)
	begin
		if cpu_reset = '1' then
			gfx_bank <= '0';
		elsif rising_edge(clk_30M) and clk_3M_ena = '1' then
			if uPmemwr = '1' then
				if STD_MATCH(uP_addr, X"9042") then
					palette_bank <= uP_datao(0);
				elsif STD_MATCH(uP_addr, X"9046") then
					clut_bank <= uP_datao(0);
				elsif STD_MATCH(uP_addr, X"9047") then
					gfx_bank <= uP_datao(0);
				end if;
			end if;
		end if;
	end process;
	
	sprite_reg_o.clk <= clk_30M;
	sprite_reg_o.clk_ena <= clk_3M_ena;
  sprite_reg_o.a(7 downto 2) <= "000" & uP_addr(3 downto 1);
	-- since we only care about sprite register address when we'r writing
	-- for bit 1 we need '0' when 902X is addressed, or '1' when 8FFX is addressed
	-- - so just use bit 11 of address!
  sprite_reg_o.a(1 downto 0) <= uP_addr(11) & uP_addr(0);
	sprite_reg_o.d <= up_datao;
	sprite_reg_o.wr <= upmemwr and sprite_cs;
	
	tilemap_o.attr_d <= std_logic_vector(resize(unsigned(cram_data), tilemap_o.attr_d'length));
	graphics_o.bit8_1 <= "000000" & palette_bank & clut_bank;
		
  -- unused outputs
  bitmap_o <= NULL_TO_BITMAP_CTL;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  gp_o <= NULL_TO_GP;
	
  --
  -- COMPONENT INSTANTIATION
  --

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> 10
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
      io_wr  	=> uPiowr,

      intreq 	=> uPintreq,
      intvec 	=> uPintvec,
      intack 	=> uPintack,
      nmi    	=> '0'
    );

  GEN_INTERNAL_ROMS : if not PENGO_ROMS_IN_FLASH generate

    rom_inst : entity work.prg_rom
      port map
      (
        clock			=> clk_30M,
        address		=> up_addr(14 downto 0),
        q					=> rom_datao
      );

  end generate GEN_INTERNAL_ROMS;
  
  GEN_EXTERNAL_ROMS : if PENGO_ROMS_IN_FLASH generate

    flash_o.a <= std_logic_vector(resize(unsigned(up_addr(14 downto 0)), flash_o.a'length));
    flash_o.d <= (others => '0');
    flash_o.cs <= '1';
    flash_o.oe <= '1';
    flash_o.we <= '0';

    rom_datao <= flash_i.d(rom_datao'range);
    
  end generate GEN_EXTERNAL_ROMS;
	
	vram_inst : entity work.vram
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> uP_addr(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> uP_datao,
			q_b					=> vram_datao,
			
			-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
			clock_a			=> clk_video,
			address_a		=> vram_addr,
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);

	vrammapper_inst : entity work.vramMapper
		port map
		(
	    clk     => clk_video,

	    inAddr  => tilemap_i.map_a(11 downto 0),
	    outAddr => vram_addr
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram_inst : entity work.cram
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> uP_addr(9 downto 0),
			wren_b			=> cram_wr,
			data_b			=> uP_datao,
			q_b					=> cram_up_data,
			
			clock_a			=> clk_video,
			address_a		=> vram_addr(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> cram_data
		);

  interrupts_inst : entity work.Pacman_Interrupts
    generic map
    (
      USE_VIDEO_VBLANK  => PENGO_USE_VIDEO_VBLANK
    )
	  port map
	  (
	    clk               => clk_30M,
	    clk_ena           => clk_3M_ena,
	    reset             => cpu_reset,

	    z80_data          => uP_datao,
			Z80_addr					=> uP_addr(1 downto 0),
			io_wr							=> uPiowr,
	    intena_wr         => intena_wr,

			vblank						=> graphics_i.vblank,
			
	    -- interrupt status & request lines
			int_ack						=> uPintack,
	    int_req           => uPintreq,
			int_vec						=> uPintvec
	  );

	tilerom_inst : entity work.tile_rom
		port map
		(
			clock									=> clk_video,
			address(12)						=> gfx_bank,
			address(11 downto 0)	=> tilemap_i.tile_a(11 downto 0),
			q											=> tilemap_o.tile_d
		);
	
	spriterom_inst : entity work.sprite_rom
		port map
		(
			clock								=> clk_video,
			address(10)					=> gfx_bank,
			address(9 downto 0)	=> sprite_i.a(9 downto 0),
			q										=> sprite_o.d
		);
	
  GEN_INTERNAL_WRAM : if PENGO_USE_INTERNAL_WRAM generate
  
    wram_inst : entity work.wram
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
