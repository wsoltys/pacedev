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
	constant PACE_HAS_PLL								      : boolean := true;
  --constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  ---- * defined in platform_pkg
	--constant PACE_VIDEO_H_SIZE				        : integer := 224;
	--constant PACE_VIDEO_V_SIZE				        : integer := 256; -- why not 240?

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 6;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 5;   -- 24*5/6 = 20MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 19;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 20; 	-- 24*20/19 = 25.263158MHz
	--constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	--constant PACE_VIDEO_V_SCALE       	      : integer := 1;
  --constant PACE_ENABLE_ADV724					      : std_logic := '0';

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 24*1/1 = 24MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 5;  	-- 24*5/3 = 40MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  constant PACE_ENABLE_ADV724					      : std_logic := '0';

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 32;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 27;   	-- 24*27/32 = 20M25Hz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 16;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  		-- 24*9/16 = 13.5MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 1;
--  constant PACE_ENABLE_ADV724					      : std_logic := '0';

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	constant PACE_ADV724_STD						      : std_logic := ADV724_STD_PAL;

  --
	-- Space Invaders-specific constants
	--
	
  constant INVADERS_ROM_IN_FLASH            : boolean := false;
	constant INVADERS_USE_INTERNAL_WRAM				: boolean := true;
  constant PACE_HAS_SRAM                    : boolean := not INVADERS_USE_INTERNAL_WRAM;

	constant USE_VIDEO_VBLANK_INTERRUPT 			: boolean := false;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
