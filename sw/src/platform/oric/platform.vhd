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

	alias clk_32M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	
	signal reset_n				: std_logic;

  signal sys_cycle      : std_logic_vector(4 downto 0) := (others => '0');
  signal clk_1M_ena		  : std_logic;
  signal clk_4M_ena		  : std_logic;
	
  -- uP signals  
  signal cpu_a_ext      : std_logic_vector(23 downto 0);
	alias cpu_a				    : std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_r_wn				: std_logic;
  signal cpu_irq_n			: std_logic;
  signal cpu_nmi_n			: std_logic;
	      
	signal io_cs          : std_logic := '0';
	
	-- VIA6522 signals
  signal via_cs         : std_logic := '0';
  signal via_d_o        : std_logic_vector(7 downto 0);
  
  -- ROM signals        
	signal basic_rom_cs		: std_logic := '0';
  signal basic_rom_d_o  : std_logic_vector(7 downto 0);

  -- STD CHARSET signals
  signal std_chrset_cs  : std_logic := '0';
  signal std_chrset_d_o : std_logic_vector(7 downto 0);
  signal std_chrset_wr  : std_logic := '0';
  
  -- VRAM signals       
	signal chrram_cs			: std_logic := '0';
	signal chrram_wr			: std_logic := '0';
  signal chrram_d_o     : std_logic_vector(7 downto 0);

  -- RAM signals
  signal wram_cs        : std_logic := '0';
  alias wram_d_o     	  : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- other signals      
	signal inputs					: from_MAPPED_INPUTS_t(0 to 0);
	
begin

	reset_n <= not reset_i;

  -- RESET BUTTON on the ORIC is connected to NMI
  cpu_nmi_n <= not buttons_i(1);
  
	-- ROM $C000-FFFF
	basic_rom_cs <=   '1' when STD_MATCH(cpu_a, "11--------------") else '0';
	-- TEXT VIDEO $BB80-BFE0 ($B800-BFFF)
	chrram_cs <= 		  '1' when STD_MATCH(cpu_a, "10111-----------") else '0';
	-- STD CHARSET text mode ($B400-$B7FF)
  std_chrset_cs <=  '1' when STD_MATCH(cpu_a, "101101----------") else '0';
	-- IO $0300-$03FF
  io_cs <=          '1' when STD_MATCH(cpu_a, "00000011--------") else '0';
  -- VIA6522 $0300-$030F
  via_cs <=         '1' when STD_MATCH(cpu_a, "000000110000----") else '0';
  
	-- always write thru to (S)RAM
	wram_cs <= 		    '1';
	
	-- memory read mux
	cpu_d_i <=	basic_rom_d_o when basic_rom_cs = '1' else
							chrram_d_o when chrram_cs = '1' else
							std_chrset_d_o when std_chrset_cs = '1' else
							-- this must precede io_cs logic
							via_d_o when via_cs = '1' else
							X"FF" when io_cs = '1' else
							wram_d_o; -- when wram_cs = '1'

	-- write signals
  chrram_wr <= not cpu_r_wn and chrram_cs;
  std_chrset_wr <= not cpu_r_wn and std_chrset_cs;
	
	-- use spritedata to expose the softswitches to the graphics core	
	graphics_o.pal <= (others => (others => '0'));
	graphics_o.bit8(0) <= (others => '0');
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

  process (clk_32M, reset_i)
  begin
    if reset_i = '1' then
      sys_cycle <= (others => '0');
    elsif rising_edge(clk_32M) then
      clk_4M_ena <= '0';  -- default
      clk_1M_ena <= '0';  -- default
      if sys_cycle(2 downto 0) = "000" then
        clk_4M_ena <= '1';
        if sys_cycle(4 downto 3) = "00" then
          clk_1M_ena <= '1';
        end if;
      end if;
      sys_cycle <= std_logic_vector(unsigned(sys_cycle) + 1);
    end if;
  end process;
  
	cpu_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> reset_n,
			Enable  		=> clk_1M_ena,
			Clk     		=> clk_32M,
			Rdy     		=> '1',
			Abort_n 		=> '1',
			IRQ_n   		=> cpu_irq_n,
			NMI_n   		=> cpu_nmi_n,
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

  BLK_VIA6522 : block
  
    signal via6522_p2     : std_logic;
    signal via6522_clk4   : std_logic;
  
  begin

    -- clocks for 6522
    -- P2 must lead cpu_clk_en by 1 system clock
    -- - and is same frequency as cpu_clk but 50% duty cycle
    -- clk4 goes low on rising edge of P2
    process (clk_32M, reset_i)
    begin
      if reset_i = '1' then
        via6522_p2 <= '1';
        via6522_clk4 <= '0';
      elsif rising_edge(clk_32M) then
        if sys_cycle(3 downto 0) = "1111" then
          via6522_p2 <= not via6522_p2;
        end if;
        if sys_cycle(1 downto 0) = "11" then
          via6522_clk4 <= not via6522_clk4;
        end if;
      end if;
    end process;
    
    sysvia_inst : entity work.m6522
      port map
      (
        I_RS              => cpu_a(3 downto 0),
        I_DATA            => cpu_d_o,
        O_DATA            => via_d_o,
        O_DATA_OE_L       => open,

        I_RW_L            => cpu_r_wn,
        I_CS1             => via_cs,
        I_CS2_L           => '0',

        O_IRQ_L           => cpu_irq_n,

        -- port a
        I_CA1             => '0',
        I_CA2             => '0',
        O_CA2             => open,
        O_CA2_OE_L        => open,

        I_PA              => (others => '0'),
        O_PA              => open,
        O_PA_OE_L         => open,

        -- port b
        I_CB1             => '0',
        O_CB1             => open,
        O_CB1_OE_L        => open,

        I_CB2             => '0',
        O_CB2             => open,
        O_CB2_OE_L        => open,

        I_PB              => (others => '0'),
        O_PB              => open,
        O_PB_OE_L         => open,

        I_P2_H            => via6522_p2,      -- high for phase 2 clock   ____----__
        RESET_L           => reset_n,
        ENA_4             => via6522_clk4,    -- 4x system clock (4MHZ)   _-_-_-_-_-
        CLK               => clk_32M
      );

  end block BLK_VIA6522;

	basic_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/oric/roms/" & ORIC_BASIC_ROM,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_32M,
			address		=> cpu_a(13 downto 0),
			q					=> basic_rom_d_o
		);
	
--	chr_rom_inst : entity work.sprom
--		generic map
--		(
--			init_file		=> "../../../../src/platform/oric/roms/" & ORIC_CHR0_ROM,
--			widthad_a		=> 10
--		)
--		port map
--		(
--			clock			=> clk_video,
--			address		=> tilemap_i.tile_a(9 downto 0),
--			q					=> tilemap_o.tile_d
--		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  std_chrset_ram_inst : entity work.dpram
		generic map
		(
			widthad_a		=> 10
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_32M,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> std_chrset_wr,
			data_b			=> cpu_d_o,
			q_b					=> std_chrset_d_o,
			
			-- graphics interface
			clock_a			=> clk_video,
			address_a		=> tilemap_i.tile_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.tile_d
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
			clock_b			=> clk_32M,
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
--      clock_b			=> clk_32M,
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
