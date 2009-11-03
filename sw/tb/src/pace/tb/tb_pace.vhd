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

entity tb_pace is
	port (
		fail:				out  boolean := false
	);
end tb_pace;

architecture SYN of tb_pace is

	signal clk				: std_logic	:= '0';
	signal reset			: std_logic	:= '1';
                  	
	signal clk_20M 		: std_logic := '0';
	signal clk_40M 		: std_logic := '0';

	signal buttons_i	: from_BUTTONS_t;
	signal switches_i	: from_SWITCHES_t;
	signal inputs_i		: from_INPUTS_t;
	signal flash_i		: from_FLASH_t;
	signal sram_i			: from_SRAM_t;
  signal sdram_i    : from_SDRAM_t;
	signal video_i		: from_VIDEO_t;
	signal audio_i		:	from_AUDIO_t;
	signal spi_i			: from_SPI_t;
	signal ser_i			: from_SERIAL_t;
  signal project_i  : from_PROJECT_IO_t;
  signal project_o  : to_PROJECT_IO_t;
  signal platform_i : from_PLATFORM_IO_t;
  signal platform_o : to_PLATFORM_IO_t;
  signal target_i   : from_TARGET_IO_t;
  signal target_o   : to_TARGET_IO_t;

begin
	-- Generate CLK and reset
  clk_20M <= not clk_20M after 25000 ps; -- 20MHz
  clk_40M <= not clk_40M after 12500 ps; -- 40MHz
	reset <= '0' after 10 ns;

	video_i.clk <= clk_40M;

	pace_inst : entity work.PACE
	  port map
	  (
	  	-- clocks and resets
	    clk_i(0)        => clk_20M,
	    clk_i(1)        => clk_40M,
	    clk_i(2)        => '0',
	    clk_i(3)        => '0',
	    reset_i         => reset,
	
	    -- misc I/O
	    buttons_i       => buttons_i,
	    switches_i      => switches_i,
	    leds_o          => open,
	
	    -- controller inputs
	    inputs_i        => inputs_i,
	
	    -- external ROM/RAM
	    flash_i         => flash_i,
	    flash_o         => open,
	    sram_i       		=> sram_i,
			sram_o					=> open,
	    sdram_i       	=> sdram_i,
			sdram_o					=> open,

	    -- video
	    video_i         => video_i,
	    video_o         => open,
	
	    -- audio
	    audio_i         => audio_i,
	    audio_o         => open,
	    
	    -- SPI (flash)
	    spi_i           => spi_i,
	    spi_o           => open,
	
	    -- serial
	    ser_i           => ser_i,
	    ser_o           => open,
	    
      -- custom i/o
      project_i       => project_i,
      project_o       => project_o,
      platform_i      => platform_i,
      platform_o      => platform_o,
      target_i        => target_i,
      target_o        => target_o
	  );
		
end SYN;
