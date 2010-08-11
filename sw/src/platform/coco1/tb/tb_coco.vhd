library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity tb_coco is
	port (
		fail:				out  boolean := false
	);
end tb_coco;

architecture SYN of tb_coco is

  signal clkrst_i       : from_CLKRST_t := (clk=>(others=>'0'), rst=>(others =>'1'),arst=>'1',arst_n=>'0');
  signal buttons_i      : from_BUTTONS_t;
  signal switches_i     : from_SWITCHES_t;
  signal leds_o         : to_LEDS_t;
  signal inputs_i       : from_INPUTS_t;
  signal flash_i        : from_FLASH_t;
  signal flash_o        : to_FLASH_t;
	signal sram_i			    : from_SRAM_t;
	signal sram_o			    : to_SRAM_t;	
	signal sdram_i        : from_SDRAM_t;
	signal sdram_o        : to_SDRAM_t;
	signal video_i        : from_VIDEO_t;
  signal video_o        : to_VIDEO_t;
  signal audio_i        : from_AUDIO_t;
  signal audio_o        : to_AUDIO_t;
  signal ser_i          : from_SERIAL_t;
  signal ser_o          : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

begin

	-- Generate CLK and reset
  clkrst_i.clk(0) <= not clkrst_i.clk(0) after 25000 ps; -- 20MHz
  clkrst_i.clk(1) <= not clkrst_i.clk(1) after  8730 ps; -- 57M272Hz
	clkrst_i.arst <= '0' after 100 ns;
	GEN_RST : for i in 0 to 3 generate
    process (clkrst_i.clk(0))
    begin
      if rising_edge(clkrst_i.clk(i)) then
        clkrst_i.rst(i) <= clkrst_i.arst;
      end if;
    end process;
  end generate GEN_RST;
      
  pace_inst : entity work.PACE
    port map
    (
    	-- clocks and resets
	  	clk_i							=> clkrst_i.clk,
      reset_i          	=> clkrst_i.rst,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => leds_o,
      
      -- controller inputs
      inputs_i          => inputs_i,

     	-- external ROM/RAM
     	flash_i           => flash_i,
      flash_o           => flash_o,
      sram_i        		=> sram_i,
      sram_o        		=> sram_o,
     	sdram_i           => sdram_i,
     	sdram_o           => sdram_o,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i.din         => '0',
      spi_o             => open,
  
      -- serial
      ser_i             => ser_i,
      ser_o             => ser_o,
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

end SYN;
