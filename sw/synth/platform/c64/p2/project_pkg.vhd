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
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  -- Reference clock is 24MHz
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  constant PACE_CLK0_DIVIDE_BY              : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 4;  			-- 24*4/3 = 32MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 4;  			-- 24*4/1 = 96Mhz

	constant PACE_ENABLE_ADV724					      : std_logic := '0';
	constant PACE_ADV724_STD						      : std_logic := ADV724_STD_PAL;

	-- C64-specific constants

	constant C64_HAS_C64								: boolean := true;
	constant C64_HAS_1541								: boolean := true;
	constant C64_HAS_EXT_SB							: boolean := false;
	constant C64_RESET_CYCLES						: natural := 4095;

	-- C64_HAS_C64 configuration
	constant C64_HAS_SID								: boolean := true;

	-- C64_HAS_1541 configuration
	constant C64_1541_DEVICE_SELECT			: std_logic_vector(3 downto 0) := X"8";
	-- 1541 early firmware
	--constant C64_1541_ROM_NAME					: string := "325302-1_901229-03";
	-- 1541C firmware (track 0 sensor enabled)
	--constant C64_1541_ROM_NAME					: string := "25196801";
	constant C64_1541_ROM_NAME					: string := "25196802";

end;
