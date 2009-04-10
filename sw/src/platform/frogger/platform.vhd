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
  signal uPmemrd        : std_logic;
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
	signal pia0_cs				: std_logic;
	signal pia1_cs				: std_logic;
	signal sprite_cs      : std_logic;
	signal pia0_datao			: std_logic_vector(7 downto 0);
	alias game_reset			: std_logic is inputs_i(3).d(0);
	signal cpu_reset			: std_logic;
	signal newTileAddr		: std_logic_vector(11 downto 0);
	
begin

	cpu_reset <= reset_i or game_reset;

	GEN_EXTERNAL_WRAM : if not FROGGER_USE_INTERNAL_WRAM generate
	
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr(13 downto 0)), sram_o.a'length));
	  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length));
		wram_datao <= sram_i.d(wram_datao'range);
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	  sram_o.cs <= '1';
	  sram_o.oe <= wram_cs and not uPmemwr;
	  sram_o.we <= wram_wr;

	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if FROGGER_USE_INTERNAL_WRAM generate

		sram_o.a <= (others => 'X');
		sram_o.d <= (others => 'X');
		sram_o.be <= (others => '0');
		sram_o.cs <= '0';
		sram_o.oe <= '0';
		sram_o.we <= '0';
			
	end generate GEN_NO_SRAM;
	
  -- chip select logic
  rom_cs <= '1' when uP_addr(15 downto 14) = "00" else '0';
  wram_cs <= '1' when uP_addr(15 downto 11) = (X"8" & "0") else '0';
  vram_cs <= '1' when uP_addr(15 downto 10) = (X"A" & "10") else '0';
  cram_cs <= '1' when uP_addr(15 downto 6) = (X"B0" & "00") else '0';
  pia1_cs <= '1' when uP_addr(15 downto 12) = X"D" else '0';
  pia0_cs <= '1' when uP_addr(15 downto 12) = X"E" else '0';

	-- memory read mux
	uP_datai <= rom_datao when rom_cs = '1' else
							--wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							(others => '1') when uP_addr(15 downto 10) = (X"A" & "11") else
							cram1_datao when (cram_cs = '1' and uP_addr(0) = '1') else
							cram0_datao when (cram_cs = '1' and uP_addr(0) = '0') else
							snd_i.d when pia1_cs = '1' else
							pia0_datao when pia0_cs = '1' else
							wram_datao; --(others => '0');
	
	vram_wr <= uPmemwr and vram_cs;
	-- how does this work if it's mirrored in sprite ram???
	cram_wr <= uPmemwr and cram_cs;
	wram_wr <= uPmemwr and wram_cs;
  nmiena_wr <= uPmemwr when uP_addr(15 downto 2) = (X"B80" & "10") else '0';
  sprite_cs <= '1' when uP_addr(15 downto 5) = (X"B0" & "010") else '0';

  sprite_reg_o.clk <= clk_30M;
  sprite_reg_o.clk_ena <= clk_3M_ena;
  sprite_reg_o.a <= up_addr(sprite_reg_o.a'range);
  sprite_reg_o.d <= up_datao;
  sprite_reg_o.wr <= upmemwr and sprite_cs;
  
	-- mangle tile address according to sprite layout
	-- WIP - can re-arrange sprites to fix
	newTileAddr <=  tilemap_i.tile_a(11 downto 6) & tilemap_i.tile_a(4 downto 1) & 
                  not tilemap_i.tile_a(5) & tilemap_i.tile_a(0);

  snd_o.a <= up_addr(snd_o.a'range);
  snd_o.d <= up_datao;
  snd_o.rd <= uPmemrd when pia1_cs = '1' else '0';
	snd_o.wr <= uPmemwr when pia1_cs = '1' else '0';

  -- unused outputs
  flash_o <= NULL_TO_FLASH;
	bitmap_o <= NULL_TO_BITMAP_CTL;
  graphics_o <= NULL_TO_GRAPHICS;
	spi_o <= NULL_TO_SPI;
	ser_o <= NULL_TO_SERIAL;
	osd_o <= NULL_TO_OSD;
	leds_o <= std_logic_vector(resize(unsigned(inputs_i(0).d), leds_o'length));
	gp_o <= NULL_TO_GP;
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU clock (3MHz from 27/30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> FROGGER_CPU_CLK_ENA_DIVIDE_BY
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

      mem_rd 	=> uPmemrd,
      mem_wr 	=> uPmemwr,
      io_rd  	=> open,
      io_wr  	=> open,

      intreq 	=> '0',
      intvec 	=> (others => 'X'),
      intack 	=> open,
      nmi    	=> uPnmireq
    );

	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/frogger/roms/frogrom.hex",
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
			init_file		=> "../../../../src/platform/frogger/roms/frogvram.hex",
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
			numwords_a			=> 128,
			widthad_a				=> 7
		)
		port map
		(
			clock_b					=> clk_30M,
			address_b				=> uP_addr(7 downto 1),
			wren_b					=> cram0_wr,
			data_b					=> uP_datao,
			q_b							=> cram0_datao,
			
			clock_a					=> clk_video,
			address_a				=> tilemap_i.attr_a(7 downto 1),
			wren_a					=> '0',
			data_a					=> (others => 'X'),
			-- mangle attr_dout so we can use galaxian tilemap controller
			q_a(7 downto 4)	=> tilemap_o.attr_d(3 downto 0),
			q_a(3 downto 0)	=> tilemap_o.attr_d(7 downto 4)
		);

	cram1_wr <= cram_wr and uP_addr(0);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram_inst_1 : entity work.dpram
		generic map
		(
			numwords_a			=> 128,
			widthad_a				=> 7
		)
		port map
		(
			clock_b					=> clk_30M,
			address_b				=> uP_addr(7 downto 1),
			wren_b					=> cram1_wr,
			data_b					=> uP_datao,
			q_b							=> cram1_datao,
			
			clock_a					=> clk_video,
			address_a				=> tilemap_i.attr_a(7 downto 1),
			wren_a					=> '0',
			data_a					=> (others => 'X'),
			-- mangle attr_dout so we can use galaxian tilemap controller
			q_a(7 downto 3)	=> tilemap_o.attr_d(15 downto 11),
			q_a(2 downto 1) => tilemap_o.attr_d(9 downto 8),
			q_a(0) 					=> tilemap_o.attr_d(10)
		);

  interrupts_inst : entity work.Galaxian_Interrupts
    generic map
    (
      USE_VIDEO_VBLANK  => FROGGER_USE_VIDEO_VBLANK
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

	gfxrom_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/frogger/roms/gfxrom.hex",
			numwords_a	=> 4096,
			widthad_a		=> 12,
			numwords_b	=> 1024,
			widthad_b		=> 10,
			width_b			=> 32
		)
		port map
		(
			clock										=> clk_video,
			address_a								=> newTileAddr,
			q_a											=> tilemap_o.tile_d,
			
			address_b								=> sprite_i.a(9 downto 0),
			q_b(31 downto 24)				=> sprite_o.d(7 downto 0),
			q_b(23 downto 16)				=> sprite_o.d(15 downto 8),
			q_b(15 downto 8)				=> sprite_o.d(23 downto 16),
			q_b(7 downto 0)					=> sprite_o.d(31 downto 24)
		);

	pia8255_0_inst : entity work.pia8255
		port map
		(
			-- uC interface
			clk			=> clk_30M,
			clken		=> '1',
			reset		=> cpu_reset,
			a				=> uP_addr(2 downto 1),
			d_i			=> uP_datai,
			d_o			=> pia0_datao,
			cs			=> pia0_cs,
			rd			=> uPmemrd,
			wr			=> uPmemwr,
			
			-- I/O interface
			pa_i		=> inputs_i(0).d,
			pa_o		=> open,
			pb_i		=> inputs_i(1).d,
			pb_o		=> open,
			pc_i		=> inputs_i(2).d,
			pc_o		=> open
		);
		
		GEN_INTERNAL_WRAM : if FROGGER_USE_INTERNAL_WRAM generate
		
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
