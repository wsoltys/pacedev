library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 48MHz
	constant PACE_HAS_PLL											: boolean := true;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY        			: natural := 2;		-- 48/2 = 24MHz
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- (used by pacman)
  constant PACE_CLK1_DIVIDE_BY        			: natural := 6;
  constant PACE_CLK1_MULTIPLY_BY      			: natural := 5;  	-- 48*5/6 = 40MHz
	constant PACE_VIDEO_H_SCALE         			: integer := 2;
	constant PACE_VIDEO_V_SCALE         			: integer := 2;

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	-- Pacman-specific constants
			
	constant PACMAN_USE_INTERNAL_WRAM				: boolean := true;
	constant PACMAN_USE_VIDEO_VBLANK 		    : boolean := true;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
