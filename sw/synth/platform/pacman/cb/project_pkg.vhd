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

	constant PACE_HAS_PLL								      : boolean := true;
  --constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_AUDIO                   : boolean := true;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_PS2;

  -- Reference clock is 14.31818MHz
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 7;   -- 14.31818*10/7 = 20.45MHz
  constant PACE_CLK0_MULTIPLY_BY            : natural := 10;  -- (used by Pacman)
  constant PACE_CLK1_DIVIDE_BY              : natural := 7;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 20;  -- 14.31818*20/7 = 40.9MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  --
	-- Pacman-specific constants
	--

  constant PACMAN_ROM_IN_SRAM               : boolean := true;
	constant PACMAN_USE_INTERNAL_WRAM				  : boolean := false;
	constant PACMAN_USE_VIDEO_VBLANK          : boolean := true;

  -- derived - do not edit
  
  constant PACE_HAS_SRAM                    : boolean := PACMAN_ROM_IN_SRAM or
                                                          not PACMAN_USE_INTERNAL_WRAM;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
