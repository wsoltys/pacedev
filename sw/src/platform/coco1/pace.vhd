library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
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
end PACE;

architecture SYN of PACE is

	constant CLK_1US_COUNTS : integer := 
    integer(PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY);

	signal mapped_inputs		: from_MAPPED_INPUTS_t(0 to PACE_INPUTS_NUM_BYTES-1);

	signal vga_red					: std_logic_vector(7 downto 0);
	signal vga_green				: std_logic_vector(7 downto 0);
	signal vga_blue					: std_logic_vector(7 downto 0);
	signal vga_hsync				: std_logic;
	signal vga_vsync				: std_logic;

	signal to_sound         : to_SOUND_t;
	signal from_sound       : from_sound_t;
	
  signal to_osd           : to_OSD_t;
  signal from_osd         : from_OSD_t;

begin

	-- hook up VGA output
	video_o.clk <= clk_i(1);
	video_o.rgb.r <= vga_red(7 downto 0) & "00";
	video_o.rgb.g <= vga_green(7 downto 0) & "00";
	video_o.rgb.b <= vga_blue(7 downto 0) & "00";
	video_o.hsync <= vga_hsync;
	video_o.vsync <= vga_vsync;
	    
  kbd_inst : entity work.inputs
    generic map
    (
      NUM_DIPS        => PACE_NUM_SWITCHES,
      NUM_INPUTS	    => PACE_INPUTS_NUM_BYTES,
      CLK_1US_DIV	    => CLK_1US_COUNTS
    )
    port map
    (
      clk     		    => clk_i(0),
      reset   		    => reset_i,
      ps2clk  		    => inputs_i.ps2_kclk,
      ps2data 		    => inputs_i.ps2_kdat,
      jamma				    => inputs_i.jamma_n,

      dips				    => switches_i,
      inputs			    => mapped_inputs
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
      reset_i         => reset_i,
      
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
      
      -- graphics (control)
	    red     				=> vga_red,
	    green   				=> vga_green,
	    blue    				=> vga_blue,
  	  hsync   				=> vga_hsync,
	    vsync						=> vga_vsync,

      --cvbs            => GS_CVBS,

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

	SOUND_BLOCK : block
		signal snd_data		: std_logic_vector(7 downto 0);
    signal snd_a      : std_logic_vector(15 downto 0);
	begin

    snd_a <= std_logic_vector(resize(unsigned(to_sound.a), snd_a'length));
    
	  sound_inst : entity work.Sound                                          
	    Port Map
	    (
	      sysclk      => clk_i(0),    -- fudge for now
	      reset       => reset_i,

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

