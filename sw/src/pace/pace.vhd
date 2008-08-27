Library IEEE;
Use     IEEE.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- external ROM/RAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_flash_t;
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- video
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;

    -- audio
    audio_i         : in from_AUDIO_t;
    audio_o         : out to_AUDIO_t;
    
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
end entity PACE;

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

  -- OSD signals
  signal to_osd           : to_OSD_t;
  signal from_osd         : from_OSD_t;

  -- sound signals
  signal snd_rd           : std_logic;
  signal snd_wr           : std_logic;
  signal sndif_data       : std_logic_vector(7 downto 0);

begin

	video_o.clk <= clk_i(1);	-- fudge
  
  U_Game : entity work.Game                                            
    Port Map
    (
      -- clocking and reset
      clk_i           => clk_i,
      reset_i         => reset_i,
      
      -- misc inputs and outputs
      buttons_i       => buttons_i,
      switches_i      => switches_i,
      leds_o          => leds_o,
      
      -- controller inputs
      inputs_i        => inputs_i,

      -- micro buses
      upaddr          => uPaddr,
      updatao         => uPdatao,
  
      -- FLASH/SRAM
      flash_i         => flash_i,
      flash_o         => flash_o,
			sram_i					=> sram_i,
			sram_o					=> sram_o,
  
      -- spi interface
      spi_i           => spi_i,
      spi_o           => spi_o,
  
      -- serial
      ser_i           => ser_i,
      ser_o           => ser_o,

      -- general purpose I/O
      gp_i            => gp_i,
      gp_o            => gp_o,

      --
      --
      --
      
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
      
			-- OSD
			to_osd          => to_osd,
			from_osd        => from_osd
    );

 U_Graphics : entity work.Graphics                                    
    Port Map
    (
      clk             => clk_i(1),      -- fudge for now
      reset           => reset_i,
  
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
  
			-- OSD
			to_osd          => to_osd,
			from_osd        => from_osd,

      red             => video_o.rgb.r,
      green           => video_o.rgb.g,
      blue            => video_o.rgb.b,
			lcm_data				=> open,
			hblank					=> video_o.hblank,
			vblank					=> vblank_s,
      hsync           => video_o.hsync,
      vsync           => video_o.vsync,
	
      bw_cvbs         => open,
      gs_cvbs         => open
    );

	video_o.vblank <= vblank_s;

	SOUND_BLOCK : block
		signal snd_data		: std_logic_vector(7 downto 0);
	begin
	
	  U_Sound : entity work.Sound                                          
	    Port Map
	    (
	      sysclk      => clk_i(0),    -- fudge for now
	      reset       => reset_i,

	      sndif_rd    => snd_rd,              
	      sndif_wr    => snd_wr,              
	      sndif_addr  => uPaddr,
	      sndif_datai => uPdatao,

	      snd_clk     => audio_o.clk,
	      snd_data    => snd_data,           
	      sndif_datao => sndif_data
	    );

		-- route audio to both channels
		audio_o.ldata <= snd_data & "00000000";
		audio_o.rdata <= snd_data & "00000000";
	
	end block SOUND_BLOCK;
		
end SYN;
