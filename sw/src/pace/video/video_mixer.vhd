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
      
      graphics_i    : in to_GRAPHICS_t;
      rgb_o         : out RGB_t
  );
end entity pace_video_mixer;
  
architecture SYN of pace_video_mixer is
begin

	rgb_o <=  sprite_rgb when sprite_set = '1' and sprite_pri = '1' else
            tilemap_rgb when tilemap_set = '1' else
						sprite_rgb when sprite_set = '1' else
						bitmap_rgb;

end architecture SYN;
