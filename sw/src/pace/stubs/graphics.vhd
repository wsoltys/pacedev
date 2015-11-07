library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity Graphics is
  port
  (
    bitmap_ctl_i    : in to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    bitmap_ctl_o    : out from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    tilemap_ctl_i   : in to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    tilemap_ctl_o   : out from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

    sprite_reg_i    : in to_SPRITE_REG_t;
    sprite_ctl_i    : in to_SPRITE_CTL_t;
    sprite_ctl_o    : out from_SPRITE_CTL_t;
		spr0_hit				: out std_logic;
    
    graphics_i      : in to_GRAPHICS_t;
    graphics_o      : out from_GRAPHICS_t;
    
		to_osd          : in to_OSD_t; 
		from_osd        : out from_OSD_t;

		video_i					: in from_VIDEO_t;
		video_o					: out to_VIDEO_t
  );

end Graphics;

architecture SYN of Graphics is

	alias clk 					    : std_logic is video_i.clk;

  signal from_video_ctl   : from_VIDEO_CTL_t;
  signal bitmap_ctl_o_s   : from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
  signal tilemap_ctl_o_s  : from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
  signal sprite_ctl_o_s   : from_SPRITE_CTL_t;
  signal sprite_pri       : std_logic;
  
  signal osd_active       : std_logic;
  signal osd_colour       : std_logic_vector(7 downto 0);

	signal rgb_data			    : RGB_t;
  -- before OSD is mixed in
  signal video_o_s        : to_VIDEO_t;
  
begin

  -- dodgy OSD transparency...
	video_o.clk <= clk;
  video_o.rgb.r <= 	(others => '0');
  video_o.rgb.g <=  (others =>'0');
  video_o.rgb.b <= 	(others => '0');
	video_o.hsync <= '0';
	video_o.vsync <= '0';
	video_o.hblank <= '0';
	video_o.vblank <= '0';

  graphics_o.y <= (others => '0');
  -- should this be the 'real' vblank or the 'active' vblank?
  -- - use the real for now
  graphics_o.hblank <= '0';
  graphics_o.vblank <= '0';
  --graphics_o.vblank <= from_video_ctl.vblank;
    
  osd_active <= '0';
  from_osd <= NULL_FROM_OSD;

end SYN;
