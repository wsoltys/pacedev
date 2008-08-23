library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 50MHz
	constant PACE_HAS_PLL										: boolean := true;
	-- PAL 	1.773447MHz x 12 = 21.281364
	-- NTSC	1.7897725MHz x 12 = 21.47727
  constant PACE_CLK0_DIVIDE_BY          	: natural := 7;
  constant PACE_CLK0_MULTIPLY_BY        	: natural := 3;   -- 50*3/7 = 21.428571MHz
  constant PACE_CLK1_DIVIDE_BY          	: natural := 7;
  constant PACE_CLK1_MULTIPLY_BY        	: natural := 3; 	-- 50*3/7 = 21.428571MHz

	constant PACE_ENABLE_ADV724					    : std_logic := '0';

  -- DE1-specific constants
  constant DE1_JAMMA_IS_MAPLE             : boolean := false;
  constant DE1_JAMMA_IS_NGC               : boolean := true;

	-- NES-specific constants

	constant NES_USE_INTERNAL_WRAM					: boolean := true;
	
	-- VERTICAL MIRRORING is the "normal" option
	constant NES_MIRROR_VERTICAL						: boolean := true;
	constant NES_MIRROR_HORIZONTAL					: boolean := not NES_MIRROR_VERTICAL;
	
end;
