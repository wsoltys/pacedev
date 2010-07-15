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
	
	constant PACE_HAS_PLL								      : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;

  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY              : natural := 21;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 31;  		-- 24*31/21 = 35.429MHz (want 35.469)
  constant PACE_CLK1_DIVIDE_BY              : natural := 21;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 31;  		-- (not used)

	-- Videopac-specific constants
	constant VIDEOPAC_CART_NAME					: string := "kcmunch.hex";
					
  -- flag that this project is not currently supported
  -- - instantiate a dummy _deferred_ constant to pull in the package body
  constant NOT_SUPPORTED                    : boolean;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
