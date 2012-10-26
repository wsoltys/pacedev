library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;

entity pace_video_mixer is
  port
  (
      bitmap_rgb    : in RGB_t;
      bitmap_set    : in std_logic;
      tilemap_rgb   : in RGB_t;
      tilemap_set   : in std_logic;
      sprite_rgb    : in RGB_t;
      sprite_set    : in std_logic;
      sprite_pri    : in std_logic;

      video_ctl_i   : in from_VIDEO_CTL_t;
      graphics_i    : in to_GRAPHICS_t;
      rgb_o         : out RGB_t
  );
end entity pace_video_mixer;
  
architecture SYN of pace_video_mixer is
  -- MicroLabs Model III hires board
  alias mode : std_logic is graphics_i.bit8(0)(0);
begin

	rgb_o.r <=  tilemap_rgb.r when mode = '0' else
              tilemap_rgb.r xor bitmap_rgb.r;
	rgb_o.g <=  tilemap_rgb.g when mode = '0' else
              tilemap_rgb.g xor bitmap_rgb.g;
	rgb_o.b <=  tilemap_rgb.b when mode = '0' else
              tilemap_rgb.b xor bitmap_rgb.b;

end architecture SYN;
