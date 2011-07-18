library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

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

  alias le18_en           : std_logic is graphics_i.bit8(0)(6);
  alias pcg80_en_hi       : std_logic is graphics_i.bit8(0)(5);
  alias pcg80_en_lo       : std_logic is graphics_i.bit8(0)(4);
  alias alt_char          : std_logic is graphics_i.bit8(0)(3);
  alias dbl_width         : std_logic is graphics_i.bit8(0)(2);

  alias lnw80_hires_ena   : std_logic is graphics_i.bit8(1)(3);
  
begin

  -- LE18 graphics are XOR'd with standard text video
  -- LNW80 hires graphics is ???
	rgb_o.r <=  bitmap_ctl_o(1).rgb.r xor tilemap_ctl_o(1).rgb.r when (TRS80_M1_HAS_LE18 and le18_en = '1') else
              bitmap_ctl_o(2).rgb.r when (TRS80_M1_IS_LNW80 and lnw80_hires_ena = '1') else
              tilemap_ctl_o(1).rgb.r;
	rgb_o.g <=  bitmap_ctl_o(1).rgb.g xor tilemap_ctl_o(1).rgb.g when (TRS80_M1_HAS_LE18 and le18_en = '1') else
              bitmap_ctl_o(2).rgb.g when (TRS80_M1_IS_LNW80 and lnw80_hires_ena = '1') else
              tilemap_ctl_o(1).rgb.g;
	rgb_o.b <=  bitmap_ctl_o(1).rgb.b xor tilemap_ctl_o(1).rgb.b when (TRS80_M1_HAS_LE18 and le18_en = '1') else
              bitmap_ctl_o(2).rgb.b when (TRS80_M1_IS_LNW80 and lnw80_hires_ena = '1') else
              tilemap_ctl_o(1).rgb.b;

end architecture SYN;
