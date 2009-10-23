library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_HAS_PLL								      : boolean := true;
	
  -- Reference clock is 48MHz
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 2;    -- 48/2.0 = 24MHz
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;    -- (used by SI)
  constant PACE_CLK1_DIVIDE_BY              : natural := 6;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 5;  	-- 48*5/6 = 40MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  --
	-- Space Invaders-specific constants
	--
	
  constant INVADERS_ROM_IN_FLASH            : boolean := PACE_HAS_FLASH;
	constant INVADERS_USE_INTERNAL_WRAM				: boolean := true;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
