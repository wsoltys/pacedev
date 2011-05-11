library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;

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
end entity platform;

architecture SYN of platform is

	alias clk_sys					: std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	
  -- uP signals  
  signal clk_2M_en			: std_logic;
  
  -- main cpu signals
  signal main_a         : std_logic_vector(15 downto 0);
  signal main_d_i       : std_logic_vector(7 downto 0);
  signal main_d_o       : std_logic_vector(7 downto 0);
  signal main_memrd     : std_logic;
  signal main_memwr     : std_logic;
  signal main_iord      : std_logic;
  signal main_iowr      : std_logic;
  signal main_intreq    : std_logic;
  signal main_intvec    : std_logic_vector(7 downto 0);
  signal main_intack    : std_logic;
  signal main_nmi       : std_logic;

  -- sub cpu signals
  signal sub_a          : std_logic_vector(15 downto 0);
  signal sub_d_i        : std_logic_vector(7 downto 0);
  signal sub_d_o        : std_logic_vector(7 downto 0);
  signal sub_memrd      : std_logic;
  signal sub_memwr      : std_logic;
  signal sub_iord       : std_logic;
  signal sub_iowr       : std_logic;
  signal sub_intreq     : std_logic;
  signal sub_intvec     : std_logic_vector(7 downto 0);
  signal sub_intack     : std_logic;
  signal sub_nmi        : std_logic;

  -- sub2 cpu signals
  signal sub2_a         : std_logic_vector(15 downto 0);
  signal sub2_d_i       : std_logic_vector(7 downto 0);
  signal sub2_d_o       : std_logic_vector(7 downto 0);
  signal sub2_memrd     : std_logic;
  signal sub2_memwr     : std_logic;
  signal sub2_iord      : std_logic;
  signal sub2_iowr      : std_logic;
  signal sub2_intreq    : std_logic;
  signal sub2_intvec    : std_logic_vector(7 downto 0);
  signal sub2_intack    : std_logic;
  signal sub2_nmi       : std_logic;

  -- ROM signals        
  signal mainrom_cs     : std_logic;
  signal mainrom_d      : std_logic_vector(7 downto 0);
  
  -- RAM signals
  signal mainram1_cs    : std_logic;
  signal mainram1_d     : std_logic_vector(7 downto 0);
  signal mainram2_cs    : std_logic;
  signal mainram2_d     : std_logic_vector(7 downto 0);
  signal mainram3_cs    : std_logic;
  signal mainram3_d     : std_logic_vector(7 downto 0);
  signal mainram4_cs    : std_logic;
  signal mainram4_d     : std_logic_vector(7 downto 0);
  
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_wr        : std_logic;
  signal wram_datao     : std_logic_vector(7 downto 0);

	-- IO signals
	signal port_cs				: std_logic_vector(5 downto 0);
	signal port_wr				: std_logic_vector(5 downto 2);
	alias game_reset			: std_logic is inputs_i(2).d(0);
	signal shift_dout			: std_logic_vector(7 downto 0);

  -- other signals      
	signal cpu_reset			: std_logic;
  signal uPmem_datai    : std_logic_vector(7 downto 0);
  signal uPio_datai     : std_logic_vector(7 downto 0);
  
	signal bitmap_addr_rotated	: std_logic_vector(12 downto 0);
	
begin

	cpu_reset <= clkrst_i.arst or game_reset;
	
	-- maincpu chip selects
	-- MAINROM $0000-$3FFF
	mainrom_cs  <= '1' when STD_MATCH(main_a, "00--------------") else '0';
	-- WRAM1 $7800-$7FFF
	mainram1_cs <= '1' when STD_MATCH(main_a, "01111-----------") else '0';
	-- WRAM2 $8000-$87FF
	mainram2_cs <= '1' when STD_MATCH(main_a, "10000-----------") else '0';
	-- WRAM3 $9000-$97FF
	mainram3_cs <= '1' when STD_MATCH(main_a, "10010-----------") else '0';
	-- WRAM4 $A000-$A7FF
	mainram4_cs <= '1' when STD_MATCH(main_a, "10100-----------") else '0';

  BLK_MAIN_MUX : block
    signal mem_d_i  : std_logic_vector(7 downto 0) := (others => '0');
    signal io_d_i   : std_logic_vector(7 downto 0) := (others => '0');
  begin
    mem_d_i <=  mainrom_d when mainrom_cs = '1' else
                mainram1_d when mainram1_cs = '1' else
                mainram2_d when mainram2_cs = '1' else
                mainram3_d when mainram3_cs = '1' else
                mainram4_d when mainram4_cs = '1' else
                X"FF";
    io_d_i <= X"FF";
    main_d_i <= mem_d_i when (main_memrd = '1') else io_d_i;
  end block BLK_MAIN_MUX;
  
  -- osd toggle (TAB)
  process (clk_sys, clkrst_i.arst)
    variable osd_key_r  : std_logic;
    variable osd_en_v   : std_logic;
  begin
    if clkrst_i.arst = '1' then
      osd_en_v := '0';
      osd_key_r := '0';
    elsif rising_edge(clk_sys) then
      -- toggle on OSD KEY PRESS
      if inputs_i(2).d(1) = '1' and osd_key_r = '0' then
        osd_en_v := not osd_en_v;
      end if;
      osd_key_r := inputs_i(2).d(1);
    end if;
    osd_o.en <= osd_en_v;
  end process;

  -- unused outputs

  sram_o <= NULL_TO_SRAM;
  graphics_o <= NULL_TO_GRAPHICS;
  tilemap_o <= NULL_TO_TILEMAP_CTL;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --osd_o <= NULL_TO_OSD;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  
  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CPU_FREQ_MHz=" &  integer'image(CPU_FREQ_MHz) &
            " CPU_CLK_ENA_DIV=" & integer'image(INVADERS_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

	-- generate CPU clock (2MHz from 20MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> integer(INVADERS_CPU_CLK_ENA_DIVIDE_BY)
		)
		port map
		(
			clk				=> clk_sys,
			reset			=> clkrst_i.arst,
			clk_en		=> clk_2M_en
		);
		
  main_cpu : entity work.Z80                                                
    port map
    (
      clk			=> clk_sys,                                   
      clk_en	=> clk_2M_en,
      reset  	=> cpu_reset,                                     

      addr   	=> main_a,
      datai  	=> main_d_i,
      datao  	=> main_d_o,

      mem_rd 	=> main_memrd,
      mem_wr 	=> main_memwr,
      io_rd  	=> main_iord,
      io_wr  	=> main_iowr,

      intreq 	=> main_intreq,
      intvec 	=> main_intvec,
      intack 	=> main_intack,
      nmi    	=> main_nmi
    );

  main_rom_inst : entity work.sprom
    generic map
    (
			init_file		=> "../../../../src/platform/galaga/xevious/roms/main.hex",
			widthad_a		=> 14
    )
    port map
    (
      clock		=> clk_sys,
      address => main_a(13 downto 0),
      q				=> mainrom_d
    );

		--
		--	*** WARNING - the contents of the VRAM are offset!!!
		--							- the video won't look right!!!!
		--
		
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		vram_inst : entity work.dpram
	    port map
	    (
	        clock_b   	=> clk_sys,
	        address_b   => uP_addr(12 downto 0),
	        data_b      => uP_datao,
	        q_b					=> vram_datao,
	        wren_b			=> vram_wr,

	        clock_a     => clk_video,
	        address_a   => bitmap_addr_rotated,
      		data_a      => (others => '0'),
	        q_a					=> bitmap_o.d,
      		wren_a			=> '0'
	    );

		GEN_INTERNAL_WRAM : if INVADERS_USE_INTERNAL_WRAM generate
		
			wram_inst : entity work.wram
				port map
				(
					clock				=> clk_sys,
					address			=> uP_addr(9 downto 0),
					data				=> up_datao,
					wren				=> wram_wr,
					q						=> wram_datao
				);
		
		end generate GEN_INTERNAL_WRAM;
		
end SYN;
