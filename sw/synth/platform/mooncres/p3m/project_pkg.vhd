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
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := true;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_240x320_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 8;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 9;   -- 24*9/8 = 27MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 16;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  	-- 24*9/16 = 13.5MHz
	constant PACE_VIDEO_H_SCALE               : integer := 2;
	constant PACE_VIDEO_V_SCALE               : integer := 1;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	-- Moon Cresta-specific constants
			
	constant MOONCRES_CPU_CLK_ENA_DIVIDE_BY	: natural := 9;
	constant MOONCRES_1MHz_CLK0_COUNTS			: natural := 27;
	-- needed by Galaxian_Interrupts
	alias GALAXIAN_1MHz_CLK0_COUNTS			    : natural is MOONCRES_1MHz_CLK0_COUNTS;
	alias GALAXIAN_CPU_CLK_ENA_DIVIDE_BY    : natural is MOONCRES_CPU_CLK_ENA_DIVIDE_BY;
	
	constant GALAXIAN_USE_INTERNAL_WRAM			: boolean := true;
	constant USE_VIDEO_VBLANK_INTERRUPT     : boolean := false;
	
end;
