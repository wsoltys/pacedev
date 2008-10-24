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
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;

  -- Reference clock is 50MHz
  constant PACE_CLK0_DIVIDE_BY        : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 1;   -- 50*1/1 = 50MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 1;  	-- 24MHz (not used)

	-- System09-specific constants
			
	--constant SYSTEM09_CPU_CLK_ENA_DIVIDE_BY		: natural := 10;
	--constant SYSTEM09_1MHz_CLK0_COUNTS				: natural := 30;
	
	--constant USE_VIDEO_VBLANK_INTERRUPT : boolean := true;
	
end;
