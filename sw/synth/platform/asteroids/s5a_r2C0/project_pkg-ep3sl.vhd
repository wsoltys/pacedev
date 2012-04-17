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
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
	constant PACE_VIDEO_H_SIZE				        : integer := 1024/2;
	constant PACE_VIDEO_V_SIZE				        : integer := 768/2;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 24*1/1 = 24MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 24;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 25; 	-- 24*25/24 = 25MHz
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';
  
--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 24*1/1 = 24MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 3;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 5;  	-- 24*5/3 = 40MHz

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 32;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 27;   	-- 24*27/32 = 20M25Hz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 16;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  		-- 24*9/16 = 13.5MHz

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1280x1024_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;       -- 24*1/1 = 24MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 2;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  	    -- 24*9/2 = 108MHz

  -- only 1x1 scaling supported in asteroids
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 1;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S5A-specific constants
  
  constant S5AR2_DOUBLE_VDO_IDCK            : boolean := false;

  constant S5AR2_EMULATE_FLASH              : boolean := false;
  constant S5AR2_EMULATED_FLASH_INIT_FILE   : string := "";
  constant S5AR2_EMULATED_FLASH_WIDTH_AD    : natural := 13;
  constant S5AR2_EMULATED_FLASH_WIDTH       : natural := 8;

  constant S5AR2_EMULATE_SRAM               : boolean := false;
  constant S5AR2_EMULATED_SRAM_WIDTH_AD     : natural := 16;
  constant S5AR2_EMULATED_SRAM_WIDTH        : natural := 8;

  constant S5AR2_HAS_FLOPPY_IF              : boolean := false;

  -- derived (do not edit)
  
  constant PACE_HAS_SRAM                    : boolean := S5AR2_EMULATE_SRAM;
  constant PACE_HAS_FLASH                   : boolean := S5AR2_EMULATE_FLASH;
    
  --
	-- Asteroids-specific constants
	--
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
