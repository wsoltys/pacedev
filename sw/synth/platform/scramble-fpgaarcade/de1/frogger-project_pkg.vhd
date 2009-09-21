library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.PACEVideoController_t;
use work.video_controller_pkg.PACE_VIDEO_NONE;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_HAS_PLL								      : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
		
  -- Reference clock is 50MHz
  -- - these settings aren't used, but are for reference only
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;  		-- 50*1/1 = 50MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 2;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 1;  		-- 50*1/2 = 25MHz

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
	--
	-- Scramble/Frogger-specific constants
	--
	
	constant SCRAMBLE_BUILD_SCRAMBLE		: boolean := false;
	constant SCRAMBLE_BUILD_FROGGER			: boolean := not SCRAMBLE_BUILD_SCRAMBLE;

  -- not enough memory in the EP2C20 for sound - gets optimised out
  constant PLATFORM_HAS_SOUND         : boolean := false;
  
	constant SCRAMBLE_VIDEO_CVBS				: std_logic := '0';
	constant SCRAMBLE_VIDEO_VGA					: std_logic := not SCRAMBLE_VIDEO_CVBS;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
