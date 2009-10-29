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

	alias clk_sys					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	signal cpu_reset      : std_logic;

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
	signal wram_wr				: std_logic;
  signal wram_datao     : std_logic_vector(7 downto 0);

  -- RAM signals        
  signal cram_cs        : std_logic;
  signal cram_wr        : std_logic;
	signal cram_up_data 	: std_logic_vector(7 downto 0);
	
  -- interrupt signals
  signal intena_wr      : std_logic;

  -- other signals      
  signal inZero_cs      : std_logic;
  signal inOne_cs       : std_logic;
  signal dips_cs        : std_logic;
  alias game_reset      : std_logic is inputs_i(inputs_i'high).d(0);
	signal newTileAddr		: std_logic_vector(11 downto 0);
  signal sprite_4_cs    : std_logic;
  signal sprite_5_cs    : std_logic;
  --signal wdog_wr        : std_logic;
	
begin

  cpu_reset <= reset_i or game_reset;

	GEN_EXTERNAL_WRAM : if PACE_HAS_SRAM generate
    
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr), sram_o.a'length));
		wram_datao <= sram_i.d(wram_datao'range);
	  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length));
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	  sram_o.cs <= '1';
	  sram_o.oe <=  '1' when ((wram_cs = '1' or (rom_cs = '1' and PACMAN_ROM_IN_SRAM)) and uPmemwr = '0') else 
                  '0';
	  sram_o.we <= wram_wr;
	
	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if not PACE_HAS_SRAM generate
    sram_o <= NULL_TO_SRAM;
	end generate GEN_NO_SRAM;
	
  -- chip select logic
	-- ROM $0000-$3FFF
  rom_cs <= '1' when uP_addr(15 downto 14) = "00" else '0';
  -- VRAM $4000-$43FF/$C000-$C3FF
  vram_cs <= '1' when uP_addr(14 downto 10) = "10000" else '0';
  -- CRAM $4400-$47FF/$C400-$C7FF
  cram_cs <= '1' when uP_addr(14 downto 10) = "10001" else '0';
	-- WRAM $4C00-$4FFF
  wram_cs <= '1' when uP_addr(15 downto 10) = "010011" else '0';
  inZero_cs <= '1' when uP_addr(15 downto 12) = "0101" and uP_addr(7 downto 6) = "00" else '0';
  inOne_cs <= '1' when uP_addr(15 downto 12) = "0101" and uP_addr(7 downto 6) = "01" else '0';
  dips_cs <= '1' when uP_addr(15 downto 12) = "0101" and uP_addr(7 downto 6) = "10" else '0';
  -- SPRITE $4FF0-$4FFF,$5060-507F
  sprite_4_cs <= '1' when STD_MATCH(uP_addr, X"4FF"&"----") else '0';
  sprite_5_cs <= '1' when STD_MATCH(uP_addr, X"50"&"011-----") else '0';

	-- memory read mux
	uP_datai <= rom_datao when rom_cs = '1' else
							wram_datao when wram_cs = '1' else
							vram_datao when vram_cs = '1' else
							cram_up_data when cram_cs = '1' else
              inputs_i(0).d when inzero_cs = '1' else
              inputs_i(1).d when inone_cs = '1' else
              not switches_i(uP_datai'range) when dips_cs = '1' else
							(others => 'X');
	
	-- ram write enables
	vram_wr <= vram_cs and uPmemwr;
	cram_wr <= cram_cs and uPmemwr;
	wram_wr <= wram_cs and uPmemwr;

  -- NMI EN $5000
  intena_wr <= uPmemwr when (uP_addr = X"5000") else '0';
  -- SOUND $5040-$505F
	snd_o.wr <= uPmemwr when (uP_addr(15 downto 5) = X"50"&"010") else '0';
  -- WATCHDOG $50C0-$50FF
  --wdog_wr <= '1' when (uP_addr(15 downto 6) = X"50"&"11") else '0';

  -- sprite registers
  sprite_reg_o.clk <= clk_sys;
  sprite_reg_o.clk_ena <= clk_3M_ena;
  sprite_reg_o.a(sprite_reg_o.a'left downto 5) <= (others => '0');
  sprite_reg_o.a(4 downto 0) <= uP_addr(3 downto 1) & sprite_4_cs & uP_addr(0);
  sprite_reg_o.d <= up_datao;
  sprite_reg_o.wr <= uPmemwr and (sprite_4_cs or sprite_5_cs);
  
	snd_o.a <= uP_addr(snd_o.a'range);
	snd_o.d <= uP_datao;

	-- Snooping stuff
	process (clk_sys, clk_3M_ena, reset_i)
		variable eaten_pill : std_logic;
    variable player_y_i : integer range 0 to 1023;
		variable player_y		: std_logic_vector(9 downto 0);
	begin
		if reset_i = '1' then
			eaten_pill := '0';
		elsif rising_edge(clk_sys) and clk_3M_ena = '1' then
			-- $4DA6:0 determines is player has eaten pill or not
			if uP_addr = X"4DA6" and uPmemwr = '1' then
				eaten_pill := uP_datao(0);
			end if;
			-- $5063/$506B is Y for sprites 1,5 respectively
			if uP_addr = X"506" & not eaten_pill & "011" and uPmemwr = '1' then
				player_y_i := work.platform_pkg.PACE_VIDEO_V_SIZE - to_integer(unsigned(uP_datao));
			end if;
		end if;
		-- show on leds
    player_y := std_logic_vector(to_unsigned(player_y_i, 10));
		leds_o(7 downto 0) <= player_y(7 downto 0);
		--ycentre <= player_y;
	end process;
	
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
	bitmap_o <= NULL_TO_BITMAP_CTL;
	graphics_o <= NULL_TO_GRAPHICS;
	spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o(leds_o'left downto 8) <= (others => '0');
  
  --
  -- COMPONENT INSTANTIATION
  --
  
  assert false
    report  "CLK0_FREQ_MHz = " & integer'image(CLK0_FREQ_MHz) & "\n" &
            "CPU_FREQ_MHz = " &  integer'image(CPU_FREQ_MHz) & "\n" &
            "CPU_CLK_ENA_DIV = " & integer'image(PACMAN_CPU_CLK_ENA_DIVIDE_BY)
      severity note;
      
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> PACMAN_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_sys,
			reset			=> reset_i,
			clk_en		=> clk_3M_ena
		);

  U_uP : entity work.Z80                                                
    port map
    (
      clk 		=> clk_sys,                                   
      clk_en	=> clk_3M_ena,
      reset  	=> cpu_reset,                                     

      addr   	=> uP_addr,
      datai  	=> uP_datai,
      datao  	=> uP_datao,

      m1      => open,
      mem_rd 	=> open,
      mem_wr 	=> uPmemwr,
      io_rd  	=> open,
      io_wr  	=> uPiowr,

      intreq 	=> uPintreq,
      intvec 	=> uPintvec,
      intack 	=> uPintack,
      nmi    	=> '0'
    );

  GEN_INTERNAL_ROM : if not PACMAN_ROM_IN_SRAM generate
    rom_inst : entity work.prg_rom
      port map
      (
        clock			=> clk_sys,
        address		=> up_addr(13 downto 0),
        q					=> rom_datao
      );
  end generate GEN_INTERNAL_ROM;

  GEN_SRAM_ROM : if PACMAN_ROM_IN_SRAM generate
    rom_datao <= sram_i.d(rom_datao'range);
  end generate GEN_SRAM_ROM;
  
	vram_inst : entity work.vram
		port map
		(
			clock_b			=> clk_sys,
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
  tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

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
			clock_b			=> clk_sys,
			address_b		=> uP_addr(9 downto 0),
			wren_b			=> cram_wr,
			data_b			=> uP_datao,
			q_b					=> cram_up_data,
			
			clock_a			=> clk_video,
			address_a		=> vram_addr(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.attr_d(7 downto 0)
		);
  tilemap_o.attr_d(tilemap_o.attr_d'left downto 8) <= (others => '0');
  
  interrupts_inst : entity work.Pacman_Interrupts
    generic map
    (
      USE_VIDEO_VBLANK => PACMAN_USE_VIDEO_VBLANK
    )
	  port map
	  (
	    clk               => clk_sys,
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
			clock			=> clk_video,
			address		=> tilemap_i.tile_a(11 downto 0),
			q					=> tilemap_o.tile_d
		);
	
	spriterom_inst : entity work.sprite_rom
		port map
		(
			clock			=> clk_video,
			address		=> sprite_i.a(9 downto 0),
			q					=> sprite_o.d
		);
	
	GEN_INTERNAL_WRAM : if PACMAN_USE_INTERNAL_WRAM generate
	
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
