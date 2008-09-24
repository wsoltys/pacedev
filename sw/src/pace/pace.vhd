Library IEEE;
Use     IEEE.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
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
  signal to_sprite_reg    : to_SPRITE_REG_t;
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
	signal spr0_hit					: std_logic;
	
	signal xcentre					: std_logic_vector(9 downto 0);
	signal ycentre					: std_logic_vector(9 downto 0);

  -- OSD signals
  signal to_osd           : to_OSD_t;
  signal from_osd         : from_OSD_t;

	-- video signals
	signal video_i_s				: from_VIDEO_t;
	signal video_o_s				: to_VIDEO_t;

  -- sound signals
  signal snd_rd           : std_logic;
  signal snd_wr           : std_logic;
  signal sndif_data       : std_logic_vector(7 downto 0);

begin

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
      
      -- micro buses
      upaddr          => uPaddr,
      updatao         => uPdatao,
  
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
      to_sprite_reg   => to_sprite_reg,
      spriteaddr      => sprite_addr,
      spritedata      => sprite_data,
			spr0_hit				=> spr0_hit,
  
      -- graphics (control)
      vblank					=> video_o_s.vblank,
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
      reset           => reset_i,
  
      sprite_reg_i    => to_sprite_reg,
      
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
			spr0_hit				=> spr0_hit,
  
			-- OSD
			to_osd          => to_osd,
			from_osd        => from_osd,

			-- video (incl. clk)
			video_i					=> video_i,
			video_o					=> video_o_s
    );

	video_o <= video_o_s;

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
