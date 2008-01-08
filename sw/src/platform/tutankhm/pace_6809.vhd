Library IEEE;
Use     IEEE.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk             : in std_logic_vector(0 to 3);
    test_button     : in std_logic;
    reset           : in std_logic;

    -- game I/O
    ps2clk          : inout std_logic;
    ps2data         : inout std_logic;
    dip             : in std_logic_vector(7 downto 0);
		jamma						: in JAMMAInputsType;

    -- external RAM
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
		hblank					: out std_logic;
		vblank					: out std_logic;
    hsync           : out std_logic;
    vsync           : out std_logic;

    -- composite video
    BW_CVBS         : out std_logic_vector(1 downto 0);
    GS_CVBS         : out std_logic_vector(7 downto 0);

    -- sound
    snd_clk         : out std_logic;
    snd_data_l      : out std_logic_vector(15 downto 0);
    snd_data_r      : out std_logic_vector(15 downto 0);

    -- SPI (flash)
    spi_clk         : out std_logic;
    spi_mode        : out std_logic;
    spi_sel         : out std_logic;
    spi_din         : in std_logic;
    spi_dout        : out std_logic;

    -- serial
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;

    -- portal for the external CPU
    gpio_i          : in std_logic_vector(39 downto 0);
    gpio_o          : out std_logic_vector(39 downto 0);

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

  -- uP signals
  signal uPaddr           : std_logic_vector(15 downto 0);
  signal uPdatao          : std_logic_vector(7 downto 0);

  -- graphics signals
  signal gfxextra_data    : std_logic_vector(7 downto 0);
	signal palette_data			: ByteArrayType(15 downto 0);
  signal bitmap_addr     	: std_logic_vector(15 downto 0);
  signal bitmap_data     	: std_logic_vector(7 downto 0);
  signal tilemap_addr     : std_logic_vector(15 downto 0);
  signal tilemap_data     : std_logic_vector(15 downto 0);
  signal tile_addr        : std_logic_vector(15 downto 0);
  signal tile_data        : std_logic_vector(7 downto 0);
  signal attr_addr        : std_logic_vector(9 downto 0);
  signal attr_data        : std_logic_vector(15 downto 0);
  signal sprite_addr      : std_logic_vector(15 downto 0);
  signal sprite_data      : std_logic_vector(31 downto 0);
  signal spritereg_addr   : std_logic_vector(7 downto 0);
  signal sprite_wr        : std_logic;
	signal spr0_hit					: std_logic;
	
  signal vblank_s       	: std_logic;
	signal xcentre					: std_logic_vector(9 downto 0);
	signal ycentre					: std_logic_vector(9 downto 0);
        
  -- sound signals
  signal snd_rd           : std_logic;
  signal snd_wr           : std_logic;
  signal sndif_data       : std_logic_vector(7 downto 0);

  -- spi signals
  signal spi_clk_s        : std_logic;
  signal spi_dout_s       : std_logic;
  signal spi_ena          : std_logic;
  signal spi_mode_s       : std_logic;
  signal spi_sel_s        : std_logic;

	signal leds_s						: std_logic_vector(7 downto 0);
	
begin

	vga_clk <= clk(1);	-- fudge

  spi_clk <= spi_clk_s when (spi_ena = '1') else 'Z';
  spi_dout <= spi_dout_s when (spi_ena = '1') else 'Z';
  spi_mode <= spi_mode_s when (spi_ena = '1') else 'Z';
  spi_sel <= spi_sel_s when (spi_ena = '1') else 'Z';
  
	leds <= leds_s;
	  
  U_Game : entity work.Game                                            
    Port Map
    (
      -- clocking and reset
      clk             => clk,
      reset           => reset,
      test_button     => test_button,
  
      -- inputs
      ps2clk          => ps2clk,
      ps2data         => ps2data,
      dip             => dip,
			jamma						=> jamma,
			
      -- micro buses
      upaddr          => uPaddr,
      updatao         => uPdatao,
  
      -- SRAM
			sram_i					=> sram_i,
			sram_o					=> sram_o,
  
      gfxextra_data   => gfxextra_data,
			palette_data		=> palette_data,
			
      -- graphics (bitmap)
			bitmap_addr			=> bitmap_addr,
			bitmap_data			=> bitmap_data,

      -- graphics (tilemap)
      tileaddr        => tile_addr,
      tiledatao       => tile_data,
      tilemapaddr     => tilemap_addr,
      tilemapdatao    => tilemap_data,
      attr_addr       => attr_addr,
      attr_dout       => attr_data,
  
      -- graphics (sprite)
      sprite_reg_addr => spritereg_addr,
      sprite_wr       => sprite_wr,
      spriteaddr      => sprite_addr,
      spritedata      => sprite_data,
			spr0_hit				=> spr0_hit,
  
      -- graphics (control)
      vblank					=> vblank_s,
			xcentre					=> xcentre,
			ycentre					=> ycentre,
  
      -- sound
      snd_rd          => snd_rd,
      snd_wr          => snd_wr,
      sndif_datai     => sndif_data,
  
      -- spi interface
      spi_clk         => spi_clk_s,
      spi_din         => spi_din,
      spi_dout        => spi_dout_s,
      spi_ena         => spi_ena,
      spi_mode        => spi_mode_s,
      spi_sel         => spi_sel_s,
  
      -- serial
      ser_rx          => ser_rx,
      ser_tx          => ser_tx,
  
      -- portal for the external CPU
      gpio_i          => gpio_i,
      gpio_o          => gpio_o,

      -- on-board leds
      leds            => leds_s
    );

 U_Graphics : entity work.Graphics                                    
    Port Map
    (
      clk             => clk(1),      -- fudge for now
      reset           => reset,
  
			xcentre					=> xcentre,
			ycentre					=> ycentre,

      extra_data      => gfxextra_data,
			palette_data		=> palette_data,
			
			bitmapa					=> bitmap_addr,
			bitmapd					=> bitmap_data,			
      tilemapa        => tilemap_addr,
      tilemapd        => tilemap_data,
      tilea           => tile_addr,
      tiled           => tile_data,
      attra           => attr_addr,
      attrd           => attr_data,
  
      spriteaddr      => sprite_addr,
      spritedata      => sprite_data,
      sprite_reg_addr => spritereg_addr,
      updata          => uPdatao,
      sprite_wr       => sprite_wr,
			spr0_hit				=> spr0_hit,
  
      red             => red,
      green           => green,
      blue            => blue,
			lcm_data				=> lcm_data,
			hblank					=> hblank,
			vblank					=> vblank_s,
      hsync           => hsync,
      vsync           => vsync,
	
      bw_cvbs         => bw_cvbs,
      gs_cvbs         => gs_cvbs
    );

	vblank <= vblank_s;

	SOUND_BLOCK : block
		signal snd_data		: std_logic_vector(7 downto 0);
	begin
	
	  U_Sound : entity work.Sound                                          
	    Port Map
	    (
	      sysclk      => clk(0),    -- fudge for now
	      reset       => reset,

	      sndif_rd    => snd_rd,              
	      sndif_wr    => snd_wr,              
	      sndif_addr  => uPaddr,
	      sndif_datai => uPdatao,

	      snd_clk     => snd_clk,
	      snd_data    => snd_data,           
	      sndif_datao => sndif_data
	    );

		-- route audio to both channels
		snd_data_l <= snd_data & "00000000";
		snd_data_r <= snd_data & "00000000";
	
	end block SOUND_BLOCK;
		
end SYN;
