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
use work.platform_variant_pkg.all;
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
	alias rst_sys				  : std_logic is clkrst_i.rst(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	
  -- cpu signals  
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
  -- ROM $0000-$3FFF
  rom_cs <= '1' when STD_MATCH(cpu_a, "00--------------") else '0';
  wram_cs <= '1' when STD_MATCH(cpu_a, GALAXIAN_WRAM_A) else '0';
  vram_cs <= '1' when STD_MATCH(cpu_a, GALAXIAN_VRAM_A) else '0';
  cram_cs <= '1' when STD_MATCH(cpu_a, GALAXIAN_CRAM_A) else '0';
  -- INPUTS $6000,$6800,$7000
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

  -- sprite registers
  sprite_reg_o.clk <= clk_sys;
  sprite_reg_o.clk_ena <= cpu_clk_en;
  sprite_reg_o.a <= cpu_a(7 downto 0);
  sprite_reg_o.d <= cpu_d_o;
  sprite_reg_o.wr <=  cpu_mem_wr when (cpu_a(15 downto 10) = "010110" and cpu_a(7 downto 6) = "01") 
                      else '0';

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
      reset			=> rst_sys,
      clk_en		=> clk_3M_en
    );
  
  -- accomodate pause function
  cpu_clk_en <= clk_3M_en and not switches_i(8);
  
  cpu_inst : entity work.Z80                                                
    port map
    (
      clk 		=> clk_sys,                                   
      clk_en	=> cpu_clk_en,
      reset  	=> rst_sys,

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

  BLK_INTERRUPTS : block
  
    signal vblank_int     : std_logic;
    signal nmiena_s       : std_logic;

  begin
  
		process (clk_sys, rst_sys)
			variable vblank_r : std_logic_vector(3 downto 0);
			alias vblank_prev : std_logic is vblank_r(vblank_r'left);
			alias vblank_um   : std_logic is vblank_r(vblank_r'left-1);
      -- 1us duty for VBLANK_INT
      variable count    : integer range 0 to CLK0_FREQ_MHz * 1000;
		begin
			if rst_sys = '1' then
				vblank_int <= '0';
				vblank_r := (others => '0');
        count := count'high;
			elsif rising_edge(clk_sys) then
        -- rising edge vblank only
        if vblank_prev = '0' and vblank_um = '1' then
          count := 0;
        end if;
        if count /= count'high then
          vblank_int <= '1';
          count := count + 1;
        else
          vblank_int <= '0';
        end if;
        vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
			end if; -- rising_edge(clk_sys)
		end process;

    -- latch interrupt enables
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        nmiena_s <= '0';
      elsif rising_edge (clk_sys) then
        if cpu_mem_wr then
          if STD_MATCH(cpu_a, X"7"&"---------001") then
            nmiena_s <= cpu_d_o(0);
          end if;
        end if;
      end if; -- rising_edge(clk_sys)
    end process;
    
    -- generate INT
    cpu_nmireq <= '1' when (vblank_int and nmiena_s) /= '0' else '0';
    
  end block BLK_INTERRUPTS;
  
  GEN_ROMS : if true generate
  
    type rom_d_a is array(0 to 7) of std_logic_vector(7 downto 0);
    signal rom_d  : rom_d_a;

    type gfx_rom_d_a is array(GALAXIAN_GFX_ROM'range) of std_logic_vector(7 downto 0);
    signal gfx_rom_d  : gfx_rom_d_a;
    
  begin
    rom_d_o <=  rom_d(0) when cpu_a(13 downto 11) = "000" else
                rom_d(1) when cpu_a(13 downto 11) = "001" else
                rom_d(2) when cpu_a(13 downto 11) = "010" else
                rom_d(3) when cpu_a(13 downto 11) = "011" else
                rom_d(4) when cpu_a(13 downto 11) = "100" else
                rom_d(5) when cpu_a(13 downto 11) = "101" else
                rom_d(6) when cpu_a(13 downto 11) = "110" else
                rom_d(7);

    GEN_CPU_ROMS : for i in GALAXIAN_ROM'range generate
      rom_inst : entity work.sprom
        generic map
        (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          GALAXIAN_ROM(i) & ".hex",
          widthad_a		=> 11
        )
        port map
        (
          clock			=> clk_sys,
          address		=> cpu_a(10 downto 0),
          q					=> rom_d(i)
        );
    end generate GEN_CPU_ROMS;
    
    tilemap_o(1).tile_d(15 downto 0) <=  gfx_rom_d(1) & gfx_rom_d(0);

    --GEN_GFX_ROMS : for i in GALAXIAN_GFX_ROM'range generate
    GEN_GFX_ROMS : for i in 0 to 1 generate
      gfx_rom_inst : entity work.sprom
        generic map
        (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          GALAXIAN_GFX_ROM(i) & ".hex",
          widthad_a		=> 11
        )
        port map
        (
          clock			=> clk_sys,
          address		=> tilemap_i(1).tile_a(10 downto 0),
          q					=> gfx_rom_d(i)
        );
    end generate GEN_GFX_ROMS;

  end generate GEN_ROMS;
  
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
			address_a		=> tilemap_i(1).map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d(7 downto 0)
		);
  tilemap_o(1).map_d(15 downto 8) <= (others => '0');

  -- tilemap colour ram
  -- - even addresses: scroll position
  -- - odd addresses: colour base for row
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

--	gfxrom_inst : entity work.galaxian_gfxrom
--		port map
--		(
--			clock										=> clk_video,
--			address_a								=> tilemap_i(1).tile_a(11 downto 0),
--			q_a											=> tilemap_o(1).tile_d(7 downto 0),
--			
--			address_b								=> sprite_i.a(9 downto 0),
--			q_b(31 downto 24)				=> sprite_o.d(7 downto 0),
--			q_b(23 downto 16)				=> sprite_o.d(15 downto 8),
--			q_b(15 downto 8)				=> sprite_o.d(23 downto 16),
--			q_b(7 downto 0)					=> sprite_o.d(31 downto 24)
--		);

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
  
end SYN;
