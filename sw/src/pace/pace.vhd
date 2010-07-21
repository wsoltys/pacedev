library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.sdram_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic_vector(0 to 3);

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
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;

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

    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );
end entity PACE;

architecture SYN of PACE is

	constant CLK_1US_COUNTS : integer := 
    integer(PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY);

	signal mapped_inputs		: from_MAPPED_INPUTS_t(0 to PACE_INPUTS_NUM_BYTES-1);

  signal to_tilemap_ctl   : to_TILEMAP_CTL_t;
  signal from_tilemap_ctl : from_TILEMAP_CTL_t;

  signal to_bitmap_ctl    : to_BITMAP_CTL_t;
  signal from_bitmap_ctl  : from_BITMAP_CTL_t;

  signal to_sprite_reg    : to_SPRITE_REG_t;
  signal to_sprite_ctl    : to_SPRITE_CTL_t;
  signal from_sprite_ctl  : from_SPRITE_CTL_t;
	signal spr0_hit					: std_logic;

  signal to_graphics      : to_GRAPHICS_t;
	signal from_graphics    : from_GRAPHICS_t;
	
	signal to_sound         : to_SOUND_t;
	signal from_sound       : from_sound_t;
	
  signal to_osd           : to_OSD_t;
  signal from_osd         : from_OSD_t;

begin

  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CLK_1US_COUNTS=" & integer'image(CLK_1US_COUNTS)
      severity note;

	inputs_inst : entity work.inputs
		generic map
		(
      NUM_DIPS        => PACE_NUM_SWITCHES,
			NUM_INPUTS	    => PACE_INPUTS_NUM_BYTES,
			CLK_1US_DIV	    => CLK_1US_COUNTS
		)
	  port map
	  (
	    clk     	      => clk_i(0),
	    reset   	      => reset_i(0),
	    ps2clk  	      => inputs_i.ps2_kclk,
	    ps2data 	      => inputs_i.ps2_kdat,
			jamma			      => inputs_i.jamma_n,
	
	    dips     	      => switches_i,
	    inputs		      => mapped_inputs
	  );

  platform_inst : entity work.platform
    generic map
    (
      NUM_INPUT_BYTES => PACE_INPUTS_NUM_BYTES
    )
    port map
    (
      -- clocking and reset
      clk_i           => clk_i,
      reset_i         => reset_i(0),
      
      -- misc inputs and outputs
      buttons_i       => buttons_i,
      switches_i      => switches_i,
      leds_o          => leds_o,
      
      -- controller inputs
      inputs_i        => mapped_inputs,

      -- FLASH/SRAM/SDRAM
      flash_i         => flash_i,
      flash_o         => flash_o,
			sram_i					=> sram_i,
			sram_o					=> sram_o,
      sdram_i         => sdram_i,
      sdram_o         => sdram_o,
      
      -- graphics
      bitmap_i        => from_bitmap_ctl,
      bitmap_o        => to_bitmap_ctl,
      
      tilemap_i       => from_tilemap_ctl,
      tilemap_o       => to_tilemap_ctl,
      
      sprite_reg_o    => to_sprite_reg,
      sprite_i        => from_sprite_ctl,
      sprite_o        => to_sprite_ctl,
			spr0_hit				=> spr0_hit,
      
      graphics_i      => from_graphics,
      graphics_o      => to_graphics,
      
      -- sound
      snd_i           => from_sound,
      snd_o           => to_sound,
      
			-- OSD
			osd_i           => from_osd,
			osd_o           => to_osd,

      -- spi interface
      spi_i           => spi_i,
      spi_o           => spi_o,
  
      -- serial
      ser_i           => ser_i,
      ser_o           => ser_o,

      -- custom i/o
      project_i       => project_i,
      project_o       => project_o,
      platform_i      => platform_i,
      platform_o      => platform_o,
      target_i        => target_i,
      target_o        => target_o
    );

  graphics_inst : entity work.Graphics                                    
    Port Map
    (
      bitmap_ctl_i    => to_bitmap_ctl,
      bitmap_ctl_o    => from_bitmap_ctl,

      tilemap_ctl_i   => to_tilemap_ctl,
      tilemap_ctl_o   => from_tilemap_ctl,

      sprite_reg_i    => to_sprite_reg,
      sprite_ctl_i    => to_sprite_ctl,
      sprite_ctl_o    => from_sprite_ctl,
      spr0_hit				=> spr0_hit,
      
      graphics_i      => to_graphics,
      graphics_o      => from_graphics,
      
			-- OSD
			to_osd          => to_osd,
			from_osd        => from_osd,

			-- video (incl. clk)
			video_i					=> video_i,
			video_o					=> video_o
    );

	SOUND_BLOCK : block
		signal snd_data		: std_logic_vector(7 downto 0);
    signal snd_a      : std_logic_vector(15 downto 0);
	begin

    snd_a <= std_logic_vector(resize(unsigned(to_sound.a), snd_a'length));
    
	  sound_inst : entity work.Sound
      generic map
      (
        CLK_MHz     => CLK0_FREQ_MHz
      )
	    port map
	    (
	      sysclk      => clk_i(0),    -- fudge for now
	      reset       => reset_i(0),

	      sndif_rd    => to_sound.rd,              
	      sndif_wr    => to_sound.wr,              
	      sndif_addr  => snd_a,
	      sndif_datai => to_sound.d,

	      snd_clk     => audio_o.clk,
	      snd_data    => snd_data,           
	      sndif_datao => from_sound.d
	    );

		-- route audio to both channels
		audio_o.ldata <= snd_data & "00000000";
		audio_o.rdata <= snd_data & "00000000";
	
	end block SOUND_BLOCK;
		
end SYN;
