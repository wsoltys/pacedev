library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	NES Background Generator
--

architecture BITMAP_1 of bitmapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  alias rgb       : RGB_t is ctl_o.rgb;
  
	signal clut_entry		: std_logic_vector(7 downto 0);
	signal pal_entry 		: pal_entry_typ;

begin

	clut_entry <= clut(0);
	pal_entry <= pal(conv_integer(clut_entry(5 downto 0)));
	rgb.r <= pal_entry(0) & "0000";
	rgb.g <= pal_entry(1) & "0000";
	rgb.b <= pal_entry(2) & "0000";

	ctl_o.a <= (others => '0');
	ctl_o.set <= '1';
	
end BITMAP_1;

