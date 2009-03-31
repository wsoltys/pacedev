library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := true;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 12;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 25;  	-- 24*25/12 = 50MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 12;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 25;  	-- 24*25/12 = 50MHz

  constant PACE_ENABLE_ADV724					      : std_logic := '0';
  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;

  --constant PACE_HAS_OSD                     : boolean := false;
  --constant PACE_OSD_XPOS                    : natural := 128;
  --constant PACE_OSD_YPOS                    : natural := 176;

	constant PACE_ADV724_STD								  : std_logic := ADV724_STD_PAL;

	-- Boot-specific constants

end;
