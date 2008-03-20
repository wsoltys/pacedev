library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
    -- Reference clock is 50MHz
	constant PACE_HAS_PLL										  : boolean := true;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 7;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 3;   -- 50*3/7 = 21.428571MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 5;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 4;   -- 50*4/5 = 40MHz
	constant PACE_VIDEO_H_SCALE       			  : integer := 2;
	constant PACE_VIDEO_V_SCALE       			  : integer := 2;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	-- DE2 constants which *MUST* be defined
	
	constant DE2_JAMMA_IS_MAPLE	              : boolean := false;
	constant DE2_JAMMA_IS_NGC                 : boolean := true;

	constant DE2_LCD_LINE2									  : string := " NES TENNIS(VGA)";

	-- NES-specific constants

	constant USE_VIDEO_VBLANK_INTERRUPT       : boolean := true;
	constant NES_USE_INTERNAL_WRAM					  : boolean := true;
	
	--constant NES_CART_NAME									  : string := "tennis";
	constant NES_CART_NAME									  : string := "wreckcrw";

	-- VERTICAL MIRRORING is the "normal" option
	constant NES_MIRROR_VERTICAL						  : boolean := false;
	constant NES_MIRROR_HORIZONTAL					  : boolean := not NES_MIRROR_VERTICAL;
	
end;
