library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;

entity pace_video_mixer is
  port
  (
      bitmap_ctl_o  : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
      tilemap_ctl_o : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
      sprite_rgb    : in RGB_t;
      sprite_set    : in std_logic;
      sprite_pri    : in std_logic;
      
      video_ctl_i   : in from_VIDEO_CTL_t;
      graphics_i    : in to_GRAPHICS_t;
      rgb_o         : out RGB_t
  );
end entity pace_video_mixer;
  
architecture SYN of pace_video_mixer is
  alias mode : std_logic_vector(1 downto 0) is graphics_i.bit8(0)(1 downto 0);
begin

	rgb_o.r <=  tilemap_ctl_o(1).rgb.r when mode = "00" else
              bitmap_ctl_o(1).rgb.r when mode = "11" else
              tilemap_ctl_o(1).rgb.r xor bitmap_ctl_o(1).rgb.r;
	rgb_o.g <=  tilemap_ctl_o(1).rgb.g when mode = "00" else
              bitmap_ctl_o(1).rgb.g when mode = "11" else
              tilemap_ctl_o(1).rgb.g xor bitmap_ctl_o(1).rgb.g;
	rgb_o.b <=  tilemap_ctl_o(1).rgb.b when mode = "00" else
              bitmap_ctl_o(1).rgb.b when mode = "11" else
              tilemap_ctl_o(1).rgb.b xor bitmap_ctl_o(1).rgb.b;

end architecture SYN;
