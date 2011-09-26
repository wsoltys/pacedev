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

	alias clk_sys					: std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	signal cpu_reset      : std_logic;

  -- uP signals  
  signal clk_1M25_en		: std_logic;
  signal cpu_a_ext      : std_logic_vector(23 downto 0);
  alias cpu_a           : std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_r_wn       : std_logic;
  signal cpu_irq_n      : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_d_o        : std_logic_vector(7 downto 0);
                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
	signal vram_wr				: std_logic;
	signal vram_a			    : std_logic_vector(9 downto 0);
  signal vram_d_o       : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal pokey_cs       : std_logic;
	signal wram_wr				: std_logic;
  signal pokey_d_o      : std_logic_vector(7 downto 0);

  -- other signals      
  signal in0_cs         : std_logic;
  signal in1_cs         : std_logic;
  signal in2_cs         : std_logic;
  alias game_reset      : std_logic is inputs_i(inputs_i'high).d(0);

  -- not used (yet)
  signal wram_cs        : std_logic;
	
begin

  cpu_reset <= clkrst_i.rst(0) or game_reset;

	GEN_EXTERNAL_WRAM : if PACE_HAS_SRAM generate
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a), sram_o.a'length));
		pokey_d_o <= sram_i.d(pokey_d_o'range);
	  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	  sram_o.cs <= '1';
	  sram_o.oe <=  '1' when ((wram_cs = '1' or (rom_cs = '1' and MISSILE_ROM_IN_SRAM)) and cpu_r_wn = '0') else 
                  '0';
	  sram_o.we <= wram_wr;
	
	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if not PACE_HAS_SRAM generate
    sram_o <= NULL_TO_SRAM;
	end generate GEN_NO_SRAM;
	
  -- chip select logic
  -- - ignore cpu_a(15)
  -- VRAM $0000-$4000
  vram_cs <= '1' when cpu_a(14) = '0' else '0';
  -- POKEY $4000-$47FF
  pokey_cs <= '1' when cpu_a(14 downto 11) = "1000" else '0';
  -- IN0 $4800-$48FF
  in0_cs <= '1' when cpu_a(14 downto 8) = "1001000" else '0';
	-- IN1 $4900-$49FF
  in1_cs <= '1' when cpu_a(14 downto 8) = "1001001" else '0';
	-- IN2 $4A00-$4AFF
  in2_cs <= '1' when cpu_a(14 downto 8) = "1001010" else '0';
	-- ROM $5000-$7FFF,$D000-$FFFF
  rom_cs <= '1' when (cpu_a(14 downto 12) = "101" or cpu_a(14 downto 13) = "11") else '0';

	-- memory read mux
	cpu_d_i <=  vram_d_o when vram_cs = '1' else
              inputs_i(0).d when in0_cs = '1' else
              inputs_i(1).d when in1_cs = '1' else
              inputs_i(2).d when in2_cs = '1' else
							pokey_d_o when pokey_cs = '1' else
              rom_d_o when rom_cs = '1' else
							(others => 'X');
	
	-- ram write enables
	vram_wr <= vram_cs and cpu_r_wn;
	wram_wr <= wram_cs and cpu_r_wn;

	snd_o.wr <= '0';
	snd_o.a <= cpu_a(snd_o.a'range);
	snd_o.d <= cpu_d_o;

  --
  -- COMPONENT INSTANTIATION
  --
  
  assert false
    report  "CLK0_FREQ_MHz = " & integer'image(CLK0_FREQ_MHz) & "\n" &
            "CPU_FREQ_MHz = " &  integer'image(CPU_FREQ_MHz) & "\n" &
            "CPU_CLK_ENA_DIV = " & integer'image(MISSILE_CPU_CLK_ENA_DIVIDE_BY)
      severity note;
      
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> MISSILE_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_sys,
			reset			=> clkrst_i.rst(0),
			clk_en		=> clk_1M25_en
		);

	up_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> clkrst_i.arst_n,
			Enable  		=> clk_1M25_en,
			Clk     		=> clk_sys,
			Rdy     		=> '1',
			Abort_n 		=> '1',
			IRQ_n   		=> cpu_irq_n,
			NMI_n   		=> '1',
			SO_n    		=> '1',
			R_W_n   		=> cpu_r_wn,
			Sync    		=> open,
			EF      		=> open,
			MF      		=> open,
			XF      		=> open,
			ML_n    		=> open,
			VP_n    		=> open,
			VDA     		=> open,
			VPA     		=> open,
			A       		=> cpu_a_ext,
			DI      		=> cpu_d_i,
			DO      		=> cpu_d_o
		);

  GEN_INTERNAL_ROM : if not MISSILE_ROM_IN_SRAM generate
    rom_inst : entity work.prg_rom
      port map
      (
        clock			=> clk_sys,
        address		=> cpu_a(13 downto 0),
        q					=> rom_d_o
      );
  end generate GEN_INTERNAL_ROM;

  GEN_SRAM_ROM : if MISSILE_ROM_IN_SRAM generate
    rom_d_o <= sram_i.d(rom_d_o'range);
  end generate GEN_SRAM_ROM;
  
	vram_inst : entity work.vram
		port map
		(
			clock_b			=> clk_sys,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> cpu_d_o,
			q_b					=> vram_d_o,
			
			-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
			clock_a			=> clk_video,
			address_a		=> vram_a,
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> bitmap_o(1).d(7 downto 0)
		);
  bitmap_o(1).d(bitmap_o(1).d'left downto 8) <= (others => '0');

	GEN_INTERNAL_WRAM : if MISSILE_USE_INTERNAL_WRAM generate
	
		wram_inst : entity work.wram
			port map
			(
				clock				=> clk_sys,
				address			=> cpu_a(9 downto 0),
				data				=> cpu_d_o,
				wren				=> wram_wr,
				q						=> pokey_d_o
			);
	
	end generate GEN_INTERNAL_WRAM;
		
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
	tilemap_o <= (others => NULL_TO_TILEMAP_CTL);
	graphics_o <= NULL_TO_GRAPHICS;
	spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o(leds_o'left downto 8) <= (others => '0');
  
end SYN;
