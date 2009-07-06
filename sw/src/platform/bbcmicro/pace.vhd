library ieee;
use ieee.std_logic_1164.all;

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
    
    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );
end entity PACE;

architecture SYN of PACE is

	constant CLK_1US_COUNTS : integer := 
    integer(PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY);

  signal to_osd           : to_OSD_t;
  signal from_osd         : from_OSD_t;

	signal vga_red					: std_logic_vector(9 downto 0);
	signal vga_green				: std_logic_vector(9 downto 0);
	signal vga_blue					: std_logic_vector(9 downto 0);
	signal vga_hsync				: std_logic;
	signal vga_vsync				: std_logic;
			        
	signal mapped_inputs		: from_MAPPED_INPUTS_t(0 to PACE_INPUTS_NUM_BYTES-1);

begin

	-- hook up VGA output
  video_o.clk <= clk_i(0);
	video_o.rgb.r<= vga_red;
	video_o.rgb.g <= vga_green;
	video_o.rgb.b <= vga_blue;
	video_o.hsync <= vga_hsync;
	video_o.vsync <= vga_vsync;
	    
	inputs_inst : entity work.inputs
		generic map
		(
      NUM_DIPS    => PACE_NUM_SWITCHES,
			NUM_INPUTS	=> PACE_INPUTS_NUM_BYTES,
			CLK_1US_DIV	=> CLK_1US_COUNTS
		)
	  port map
	  (
	    clk     		=> clk_i(0),
	    reset   		=> reset_i,
	    ps2clk  		=> inputs_i.ps2_kclk,
	    ps2data 		=> inputs_i.ps2_kdat,
			jamma				=> inputs_i.jamma_n,

	    dips				=> (others => '0'),
	    inputs			=> mapped_inputs
	  );

  platform_inst : entity work.platform                                            
		generic map
		(
			NUM_INPUT_BYTES => PACE_INPUTS_NUM_BYTES
		)
    Port Map
    (
      -- clocking and reset
      clk_i						=> clk_i,
      reset_i         => reset_i,

      -- misc inputs and outputs
      buttons_i       => buttons_i,
      switches_i      => switches_i,
      leds_o          => leds_o,
      
      -- inputs
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

      -- sound
      audio_i         => audio_i,
      audio_o         => audio_o,
      
			-- OSD
			--osd_i           => from_osd,
			--osd_o           => to_osd,

      -- serial
      ser_i           => ser_i,
      ser_o           => ser_o
    );

  -- not used
  spi_o <= NULL_TO_SPI;
  
end SYN;

