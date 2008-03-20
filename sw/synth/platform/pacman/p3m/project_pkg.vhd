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
	
  -- Reference clock is 24.576MHz
	constant PACE_HAS_PLL								      : boolean := true;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_240x320_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 22;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 27;  -- 24.576*27/22 = 30.161455MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 20;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  	-- 24.576*9/20 = 11.059200MHz
	constant PACE_VIDEO_H_SCALE               : integer := 1;
	constant PACE_VIDEO_V_SCALE               : integer := 1;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	-- Pacman-specific constants
			
	constant PACMAN_CPU_CLK_ENA_DIVIDE_BY		  : natural := 10;
	constant PACMAN_1MHz_CLK0_COUNTS				  : natural := 30;
	
	constant PACMAN_USE_INTERNAL_WRAM				  : boolean := true;
	constant USE_VIDEO_VBLANK_INTERRUPT       : boolean := true;
	
end;
