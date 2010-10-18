library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

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

	alias clk_30M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	
	signal reset_n				: std_logic;
	
  -- uP signals  
  signal clk_1M_en			: std_logic;
  signal cpu_a_ext      : std_logic_vector(23 downto 0);
	alias cpu_a				    : std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_r_wn				: std_logic;
  signal cpu_irq_n			: std_logic;
	                        
  -- ROM signals        
	signal basic_rom_cs		: std_logic;
  signal basic_rom_d_o  : std_logic_vector(7 downto 0);
                        
  -- VRAM signals       
	signal chrram_cs			: std_logic;
	signal chrram_wr			: std_logic;
  signal chrram_d_o     : std_logic_vector(7 downto 0);

  -- RAM signals
  signal wram_cs        : std_logic;
  alias wram_d_o     	  : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- other signals      
	signal inputs					: from_MAPPED_INPUTS_t(0 to 0);
	
begin

	reset_n <= not reset_i;
	
	-- ROM $C000-FFFF
	basic_rom_cs <= '1' when STD_MATCH(cpu_a, "11--------------") else '0';
	-- TEXT VIDEO $BB80-BFE0 ($B800-BFFF)
	chrram_cs <= 		'1' when STD_MATCH(cpu_a, "10111-----------") else '0';
	-- always write thru to (S)RAM
	wram_cs <= 		'1';
	
	-- memory read mux
	cpu_d_i <=	basic_rom_d_o when basic_rom_cs = '1' else
							chrram_d_o when chrram_cs = '1' else
							wram_d_o; -- when wram_cs = '1'

	-- vram write signal
  chrram_wr <= not cpu_r_wn and chrram_cs;
	
	-- use spritedata to expose the softswitches to the graphics core	
	graphics_o.pal <= (others => (others => '0'));
	graphics_o.bit8_1 <= (others => '0');
	--graphics_o.bit16_1 <= std_logic_vector(resize(unsigned(a2var), graphics_o.bit16_1'length));

  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= wram_cs and cpu_r_wn;
  sram_o.we <= wram_cs and not cpu_r_wn;
	
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  snd_o.rd <= '0';
  spi_o <= NULL_TO_SPI;
	leds_o <= std_logic_vector(resize(unsigned(inputs(0).d), leds_o'length));
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU clock enable (1MHz from 30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> integer(ORIC_CPU_CLK_ENA_DIVIDE_BY)
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset_i,
			clk_en		=> clk_1M_en
		);

	cpu_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> reset_n,
			Enable  		=> clk_1M_en,
			Clk     		=> clk_30M,
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

	basic_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/oric/roms/" & ORIC_BASIC_ROM,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_30M,
			address		=> cpu_a(13 downto 0),
			q					=> basic_rom_d_o
		);
	
	chr_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/oric/roms/" & ORIC_CHR0_ROM,
			widthad_a		=> 10
		)
		port map
		(
			clock			=> clk_video,
			address		=> tilemap_i.tile_a(9 downto 0),
			q					=> tilemap_o.tile_d
		);
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	chr_ram_inst : entity work.dpram
		generic map
		(
			--init_file		=> "",
			widthad_a		=> 11
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_30M,
			address_b		=> cpu_a(10 downto 0),
			wren_b			=> chrram_wr,
			data_b			=> cpu_d_o,
			q_b					=> chrram_d_o,
			
			-- graphics interface
			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
  tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

--  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
--  hgrram_inst : entity work.dpram
--    generic map
--    (
--      init_file		=> "../../../../../../src/platform/appleii/iiplus/roms/hgr.hex",
--      numwords_a	=> 16384,
--      widthad_a		=> 14
--    )
--    port map
--    (
--      -- uP interface
--      clock_b			=> clk_30M,
--      address_b		=> cpu_a(13 downto 0),
--      wren_b			=> hgr_wr,
--      data_b			=> cpu_d_o,
--      q_b					=> open,				-- 6502 reads from SRAM rather than DPRAM
--      
--      -- graphics interface
--      clock_a			=> clk_video,
--      address_a		=> hgr_addr(13 downto 0),
--      wren_a			=> '0',
--      data_a			=> (others => 'X'),
--      q_a					=> hgr_data
--    );

end SYN;
