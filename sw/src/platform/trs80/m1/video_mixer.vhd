library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;

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

  alias le18_en     : std_logic is graphics_i.bit8_1(6);
  alias pcg80_en_hi : std_logic is graphics_i.bit8_1(5);
  alias pcg80_en_lo : std_logic is graphics_i.bit8_1(4);
  alias alt_char    : std_logic is graphics_i.bit8_1(3);
  alias dbl_width   : std_logic is graphics_i.bit8_1(2);

begin

  -- LE18 graphics are XOR'd with standard text video
	rgb_o.r <=  bitmap_rgb.r xor tilemap_rgb.r when (TRS80_M1_HAS_LE18 and le18_en = '1') else
              tilemap_rgb.r;
	rgb_o.g <=  bitmap_rgb.g xor tilemap_rgb.g when (TRS80_M1_HAS_LE18 and le18_en = '1') else
              tilemap_rgb.g;
	rgb_o.b <=  bitmap_rgb.b xor tilemap_rgb.b when (TRS80_M1_HAS_LE18 and le18_en = '1') else
              tilemap_rgb.b;

end architecture SYN;
