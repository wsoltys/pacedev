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
	
  -- Reference clock is 25MHz
	constant PACE_HAS_PLL								      : boolean := true;
	constant PACE_HAS_FLASH							      : boolean := false;
	constant PACE_HAS_SRAM						        : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1280x1024_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 8;     -- 25*8/5 = 40MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 25;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 108;  	-- 25*108/25 = 108MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  	
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	-- Asteroids-specific constants
					
end;
