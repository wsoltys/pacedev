library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

entity tb_top is
	port (
		fail:				out  boolean := false
	);
end tb_top;

architecture SYN of tb_top is

	signal clk						: std_logic_vector(0 to 3) := (others => '0');
	signal reset					: std_logic	:= '1';
	signal reset_n				: std_logic;

  signal jamma          : JAMMAInputsType;
  signal sram_i         : from_sram_t;
  signal sram_o         : to_sram_t;

begin

	-- Generate CLK and reset
  clk(0) <= not clk(0) after 23284 ps; -- 21.473684MHz (NTSC)
  -- 21.281364MHz (PAL)
	reset <= '0' after 100 ns;
	reset_n <= not reset;
  clk(1) <= clk(0);
  clk(2 to 3) <= (others => '0');

  pace_inst : entity work.PACE
    port map
    (
    	-- clocks and resets
      clk             => clk,
      test_button     => '0',
      reset           => reset,
  
      -- game I/O
      ps2clk          => open,
      ps2data         => open,
      dip             => (others => '0'),
  		jamma						=> jamma,
  
      -- external RAM
      sram_i       		=> sram_i,
  		sram_o					=> open,
  
      -- VGA video
  		vga_clk					=> open,
      red             => open,
      green           => open,
      blue            => open,
  		lcm_data				=> open,
  		hblank					=> open,
  		vblank					=> open,
      hsync           => open,
      vsync           => open,
  
      -- composite video
      BW_CVBS         => open,
      GS_CVBS         => open,
  
      -- sound
      snd_clk         => open,
      snd_data        => open,
  
      -- SPI (flash)
      spi_clk         => open,
      spi_mode        => open,
      spi_sel         => open,
      spi_din         => '0',
      spi_dout        => open,
  
      -- serial
      ser_tx          => open,
      ser_rx          => '0',
  
      -- debug
      leds            => open
    );

end SYN;
