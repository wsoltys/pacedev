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
end PACE;

architecture SYN of PACE is

	constant CLK_1US_COUNTS : integer := 
    integer(PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY);

	signal mapped_inputs		: from_MAPPED_INPUTS_t(0 to PACE_INPUTS_NUM_BYTES-1);

begin

--  kbd_inst : entity work.inputs
--    generic map
--    (
--      NUM_DIPS        => PACE_NUM_SWITCHES,
--      NUM_INPUTS	    => PACE_INPUTS_NUM_BYTES,
--      CLK_1US_DIV	    => CLK_1US_COUNTS
--    )
--    port map
--    (
--      clk     		    => clk_i(0),
--      reset   		    => reset_i(0),
--      ps2clk  		    => inputs_i.ps2_kclk,
--      ps2data 		    => inputs_i.ps2_kdat,
--      jamma				    => inputs_i.jamma_n,
--
--      dips				    => switches_i,
--      inputs			    => mapped_inputs
--    );

  a2601_inst : entity work.A2601NoFlash
    port map
    (
      clk     => clk_i(0),      -- 24MHz
      cv      => video_o.rgb.r(9 downto 2),
      vsyn    => video_o.vsync,
      hsyn    => video_o.hsync,
      au      => audio_o.ldata(4 downto 0),
      res     => reset_i(0)
    );

end SYN;

