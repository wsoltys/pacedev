library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24.576MHz
	constant PACE_HAS_PLL										: boolean := true;
  constant PACE_CLK0_DIVIDE_BY        		: natural := 22;
  constant PACE_CLK0_MULTIPLY_BY      		: natural := 27;  -- 24.576*27/22 = 30.161455MHz
  constant PACE_CLK1_DIVIDE_BY        		: natural := 20;
  constant PACE_CLK1_MULTIPLY_BY      		: natural := 9;  	-- 24.576*9/20 = 11.059200MHz

	constant PACE_VIDEO_H_SCALE         		: integer := 1;
	constant PACE_VIDEO_V_SCALE         		: integer := 1;

	-- Galaxian-specific constants
			
	constant GALAXIAN_CPU_CLK_ENA_DIVIDE_BY	: natural := 10;
	constant GALAXIAN_1MHz_CLK0_COUNTS			: natural := 30;
	
	constant GALAXIAN_USE_INTERNAL_WRAM			: boolean := true;
	
	constant USE_VIDEO_VBLANK_INTERRUPT 		: boolean := false;
	
end;
