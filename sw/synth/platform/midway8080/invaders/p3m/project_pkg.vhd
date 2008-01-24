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
  constant PACE_CLK0_DIVIDE_BY              : natural := 16;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 13;  -- 24.576*13/16 = 19.968MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 29;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 13;  -- 24.576*13/29 = 11.016MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 1;

	-- Space Invaders-specific constants
			
	constant INVADERS_CPU_CLK_ENA_DIVIDE_BY		: natural := 10;
	constant INVADERS_1MHz_CLK0_COUNTS				: natural := 20;

	constant INVADERS_USE_INTERNAL_WRAM				: boolean := true;
	constant USE_VIDEO_VBLANK_INTERRUPT 			: boolean := false;
	
end;
