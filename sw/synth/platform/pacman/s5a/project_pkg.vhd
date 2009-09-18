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
	
  -- Reference clock is 24.576MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 45;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 44;    -- 24.576*44/45 = 24MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 27;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 44;  	-- 24.576*44/27 = 40MHz
	constant PACE_VIDEO_H_SCALE         		  : integer := 2;
	constant PACE_VIDEO_V_SCALE         		  : integer := 2;
	constant PACE_ENABLE_ADV724							  : std_logic := '0';

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1280x1024_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 96;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 157;     -- 24.675*157/96 = 40.192MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 11;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 48;  	  -- 24.576*48/11 = 107.24MHz
  --constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  --constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  --constant PACE_ENABLE_ADV724					      : std_logic := '0';

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 8;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 9;   -- 24*9/8 = 27MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 16;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 9;		-- 24*9/16 = 13.5MHz
	--constant PACE_VIDEO_H_SCALE               : integer := 2;
	--constant PACE_VIDEO_V_SCALE               : integer := 1;
	--constant PACE_ENABLE_ADV724					      : std_logic := '1';
	--constant USE_VIDEO_VBLANK_INTERRUPT 		  : boolean := false;

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S5A-specific constants

  constant S5A_EMULATE_SRAM                 : boolean := false;
  constant S5A_EMULATED_SRAM_WIDTH_AD       : natural := 16;
  constant S5A_EMULATED_SRAM_WIDTH          : natural := 8;
  
	-- Pacman-specific constants
			
	constant PACMAN_USE_VIDEO_VBLANK            : boolean := true;
	constant PACMAN_USE_INTERNAL_WRAM				    : boolean := not (PACE_HAS_SRAM or S5A_EMULATE_SRAM);
	
end;
