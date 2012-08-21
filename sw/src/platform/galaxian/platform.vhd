library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity platform is
  generic
  (
    NUM_INPUT_BYTES   : integer
  );
  port
  (
    -- clocking and reset
    clkrst_i        : in from_CLKRST_t;

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
    
    bitmap_i        : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    bitmap_o        : out to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    
    tilemap_i       : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    tilemap_o       : out to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

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

    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );

end platform;

architecture SYN of platform is

	alias clk_sys				  : std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	
  -- uP signals  
  signal clk_3M_en			: std_logic;
  signal cpu_clk_en     : std_logic;
  signal cpu_a          : std_logic_vector(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_mem_wr     : std_logic;
  signal cpu_nmireq     : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_d_o        : std_logic_vector(7 downto 0);
                        
  -- keyboard signals
	                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
	signal vram_wr				: std_logic;
	signal vram_a			    : std_logic_vector(9 downto 0);
  signal vram_d_o       : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_wr        : std_logic;
  signal wram_d_o       : std_logic_vector(7 downto 0);

  -- RAM signals        
  signal cram_cs        : std_logic;
  signal cram_wr        : std_logic;
	signal cram_d_o		    : std_logic_vector(7 downto 0);
	
  -- interrupt signals
  signal nmiena_wr      : std_logic;

  -- other signals      
  signal inZero_cs      : std_logic;
  signal inOne_cs       : std_logic;
  signal dips_cs        : std_logic;
	signal newTileAddr		: std_logic_vector(11 downto 0);
	
begin

	GEN_EXTERNAL_WRAM : if not GALAXIAN_USE_INTERNAL_WRAM generate
	
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a(13 downto 0)), sram_o.a'length));
	  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
		wram_d_o <= sram_i.d(wram_d_o'range);
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	  sram_o.cs <= '1';
	  sram_o.oe <= wram_cs and not cpu_mem_wr;
	  sram_o.we <= wram_wr;

	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if GALAXIAN_USE_INTERNAL_WRAM generate
    sram_o <= NULL_TO_SRAM;
	end generate GEN_NO_SRAM;
	
  -- chip select logic
  rom_cs <= '1' when cpu_a(15 downto 14) = "00" else '0';
  wram_cs <= '1' when cpu_a(15 downto 11) = "01000" else '0';
  vram_cs <= '1' when cpu_a(15 downto 11) = "01010" else '0';
  cram_cs <= '1' when cpu_a(15 downto 10) = "010110" else '0';
  inZero_cs <= '1' when cpu_a(15 downto 11) = "01100" else '0';
  inOne_cs <= '1' when cpu_a(15 downto 11) = "01101" else '0';
  dips_cs <= '1' when cpu_a(15 downto 11) = "01110" else '0';

	-- memory read mux
	cpu_d_i <= rom_d_o when rom_cs = '1' else
							wram_d_o when wram_cs = '1' else
							vram_d_o when vram_cs = '1' else
							cram_d_o when cram_cs = '1' else
              inputs_i(0).d when inzero_cs = '1' else
              inputs_i(1).d when inone_cs = '1' else
              switches_i(7 downto 0) when dips_cs = '1' else
							(others => 'X');
	
	vram_wr <= cpu_mem_wr and vram_cs;
	cram_wr <= cram_cs and cpu_mem_wr;
	wram_wr <= wram_cs and cpu_mem_wr;
  nmiena_wr <= cpu_mem_wr when (cpu_a(15 downto 12) = "0111" and cpu_a(2 downto 0) = "001") else '0';

  -- sprite registers
  sprite_reg_o.clk <= clk_sys;
  sprite_reg_o.clk_ena <= cpu_clk_en;
  sprite_reg_o.a <= cpu_a(7 downto 0);
  sprite_reg_o.d <= cpu_d_o;
  sprite_reg_o.wr <=  cpu_mem_wr when (cpu_a(15 downto 10) = "010110" and cpu_a(7 downto 6) = "01") 
                      else '0';

	-- mangle tile address according to sprite layout
	newTileAddr <=  tilemap_i(1).tile_a(11 downto 6) & tilemap_i(1).tile_a(4 downto 1) & 
                  not tilemap_i(1).tile_a(5) & tilemap_i(1).tile_a(0);

  -- unused outputs

  flash_o <= NULL_TO_FLASH;
  bitmap_o <= (others => NULL_TO_BITMAP_CTL);
  sprite_o.ld <= '0';
  graphics_o <= NULL_TO_GRAPHICS;
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o <= (others => '0');
  
  --
  -- COMPONENT INSTANTIATION
  --

  assert false
    report  "CLK0_FREQ_MHz = " & integer'image(CLK0_FREQ_MHz) & "\n" &
            "CPU_FREQ_MHz = " &  integer'image(CPU_FREQ_MHz) & "\n" &
            "CPU_CLK_ENA_DIV = " & integer'image(GALAXIAN_CPU_CLK_ENA_DIVIDE_BY)
      severity note;
      
	-- generate CPU enable clock (3MHz from 27/30MHz)
  clk_en_inst : entity work.clk_div
    generic map
    (
      DIVISOR		=> GALAXIAN_CPU_CLK_ENA_DIVIDE_BY
    )
    port map
    (
      clk				=> clk_sys,
      reset			=> clkrst_i.rst(0),
      clk_en		=> clk_3M_en
    );
  
  -- accomodate pause function
  cpu_clk_en <= clk_3M_en and not switches_i(8);
  
  U_uP : entity work.Z80                                                
    port map
    (
      clk 		=> clk_sys,                                   
      clk_en	=> cpu_clk_en,
      reset  	=> clkrst_i.rst(0),                                     

      addr   	=> cpu_a,
      datai  	=> cpu_d_i,
      datao  	=> cpu_d_o,

      mem_rd 	=> open,
      mem_wr 	=> cpu_mem_wr,
      io_rd  	=> open,
      io_wr  	=> open,

      intreq 	=> '0',
      intvec 	=> cpu_d_i,
      intack 	=> open,
      nmi    	=> cpu_nmireq
    );

  interrupts_inst : entity work.Galaxian_Interrupts
    generic map
    (
      USE_VIDEO_VBLANK  => GALAXIAN_USE_VIDEO_VBLANK
    )
    port map
    (
      clk               => clk_sys,
      reset             => clkrst_i.rst(0),
  
      z80_data          => cpu_d_o,
      nmiena_wr         => nmiena_wr,
  
			vblank						=> graphics_i.vblank,
			
      -- interrupt status & request lines
      nmi_req           => cpu_nmireq
    );

	rom_inst : entity work.galaxian_rom
		port map
		(
			clock			=> clk_sys,
			address		=> cpu_a(13 downto 0),
			q					=> rom_d_o
		);
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.galaxian_vram
		port map
		(
			clock_b			=> clk_sys,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> cpu_d_o,
			q_b					=> vram_d_o,

			clock_a			=> clk_video,
			address_a		=> vram_a,
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d(7 downto 0)
		);
  tilemap_o(1).map_d(15 downto 8) <= (others => '0');

	vrammapper_inst : entity work.vramMapper
		port map
		(
	    clk     => clk_video,

	    inAddr  => tilemap_i(1).map_a(12 downto 0),
	    outAddr => vram_a
		);

	cram_inst : entity work.galaxian_cram
		port map
		(
			clock_b			=> clk_sys,
			address_b		=> cpu_a(7 downto 0),
			wren_b			=> cram_wr,
			data_b			=> cpu_d_o,
			q_b					=> cram_d_o,
			
			clock_a			=> clk_video,
			address_a		=> tilemap_i(1).attr_a(7 downto 1),
			q_a					=> tilemap_o(1).attr_d(15 downto 0)
		);

	gfxrom_inst : entity work.galaxian_gfxrom
		port map
		(
			clock										=> clk_video,
			address_a								=> newTileAddr,
			q_a											=> tilemap_o(1).tile_d(7 downto 0),
			
			address_b								=> sprite_i.a(9 downto 0),
			q_b(31 downto 24)				=> sprite_o.d(7 downto 0),
			q_b(23 downto 16)				=> sprite_o.d(15 downto 8),
			q_b(15 downto 8)				=> sprite_o.d(23 downto 16),
			q_b(7 downto 0)					=> sprite_o.d(31 downto 24)
		);

		GEN_INTERNAL_WRAM : if GALAXIAN_USE_INTERNAL_WRAM generate
		
			wram_inst : entity work.galaxian_wram
				--generic map
				--(
				--	numwords_a => 2048,
				--	widthad_a => 11
				--)
				port map
				(
					clock				=> clk_sys,
					address			=> cpu_a(10 downto 0),
					data				=> cpu_d_o,
					wren				=> wram_wr,
					q						=> wram_d_o
				);
		
		end generate GEN_INTERNAL_WRAM;
		
end SYN;
