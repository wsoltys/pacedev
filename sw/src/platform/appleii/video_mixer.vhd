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

  alias a2var					: std_logic_vector(15 downto 0) is graphics_i.bit16(0);
	alias gfxmode				: std_logic_vector(3 downto 0) is a2var(11 downto 8);
					
begin

	rgb_o <=  -- mixed-mode graphics & text
            bitmap_rgb 	when STD_MATCH(gfxmode, "1-10") and video_ctl_i.y < 160 else
            -- full-screen graphics
            bitmap_rgb 	when STD_MATCH(gfxmode, "1-00") else
            -- everything else
            tilemap_rgb;

end architecture SYN;
