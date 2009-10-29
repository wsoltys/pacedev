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
  --constant PACE_SRAM                        : boolean := false;
  
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 12;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 5;   -- 48*5/12 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 21;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 11;  -- 48*11/21 = 25.143MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- RC10-specific constants
  
  constant RC10_EMULATE_SRAM                : boolean := true;
  constant RC10_EMULATED_SRAM_KB            : natural := 16;
  
	-- LDR-specific constants

  type LDR_Platform_t is
  (
    PLATFORM_PACMAN
  );

  constant LDR_PLATFORM       : LDR_Platform_t := PLATFORM_PACMAN;
  constant LDR_NAME           : string := "PACMAN  ";
  constant LDR_BANK           : std_logic_vector(3 downto 0) := X"0";
  
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  -- *** derived *** - do not edit
  
  constant PACE_SRAM                        : boolean := RC10_EMULATE_SRAM;

end;
