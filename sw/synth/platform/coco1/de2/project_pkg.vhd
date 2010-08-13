library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;
--use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 50MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_FLASH                   : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := true;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 50*1/1 = 50MHz
  -- NTSC
  constant PACE_CLK1_DIVIDE_BY              : natural := 7;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 8;  	-- 50*8/7 = 57M143Hz (57.27272)
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 1;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- DE2 constants which *MUST* be defined
  
	constant DE2_LCD_LINE2							      : string := "  COCO1 (NTSC)  ";

	-- Coco1-specific constants
	
	constant COCO1_USE_REAL_6809              : boolean := true;
  constant COCO1_EXTENDED_COLOR_BASIC       : boolean := true;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
