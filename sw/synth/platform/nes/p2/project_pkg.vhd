library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL										  : boolean := true;
	-- PAL 	1.773447MHz x 12 = 21.281364
	-- NTSC	1.7897725MHz x 12 = 21.47727
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY          	  : natural := 17;
  constant PACE_CLK0_MULTIPLY_BY        	  : natural := 15;  -- 24*15/17 = 21.176471MHz
  constant PACE_CLK1_DIVIDE_BY          	  : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY        	  : natural := 5;  	-- 24*5/3 = 40MHz
	constant PACE_VIDEO_H_SCALE               : integer := 2;
	constant PACE_VIDEO_V_SCALE               : integer := 2;
	constant PACE_ENABLE_ADV724					      : std_logic := '0';

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	constant PACE_ADV724_STD						      : std_logic := ADV724_STD_PAL;

  -- P2-specific constants
  constant P2_JAMMA_IS_MAPLE                : boolean := false;
  constant P2_JAMMA_IS_NGC                  : boolean := true;

	-- NES-specific constants

	constant USE_VIDEO_VBLANK_INTERRUPT       : boolean := true;
	constant NES_USE_INTERNAL_WRAM					  : boolean := true;
	
	--constant NES_CART_NAME									  : string := "tennis";
	--constant NES_CART_NAME									  : string := "wreckcrw";
	constant NES_CART_NAME									  : string := "smb";
	
	-- VERTICAL MIRRORING is the "normal" option
	constant NES_MIRROR_VERTICAL						  : boolean := true;
	constant NES_MIRROR_HORIZONTAL					  : boolean := not NES_MIRROR_VERTICAL;
	
end;
