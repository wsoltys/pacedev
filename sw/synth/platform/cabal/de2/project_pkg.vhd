library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_HAS_PLL										: boolean := true;
  constant PACE_CLK0_DIVIDE_BY        		: natural := 5;
  constant PACE_CLK0_MULTIPLY_BY      		: natural := 3;   -- 50*3/5 = 30MHz
  constant PACE_CLK1_DIVIDE_BY        		: natural := 5;
  constant PACE_CLK1_MULTIPLY_BY      		: natural := 4;   -- 50*9/25 = 18MHz

	constant PACE_VIDEO_H_SCALE       			: integer := 1;
	constant PACE_VIDEO_V_SCALE       			: integer := 1;

  -- DE2-specific constants
	constant DE2_JAMMA_IS_MAPLE	            : boolean := false;
	constant DE2_JAMMA_IS_NGC               : boolean := true;

	constant DE2_LCD_LINE2									: string := "   CABAL-LCD    ";		-- 16 chars exactly

	-- Cabal-specific constants
			
	constant CABAL_USE_WF68K_CORE						: boolean := true;
	constant CABAL_USE_TG68_CORE						: boolean := not CABAL_USE_WF68K_CORE;
	
	constant CABAL_CPU_CLK_ENA_DIVIDE_BY		: natural := 10;
	constant CABAL_1MHz_CLK0_COUNTS				  : natural := 30;
	
	constant USE_VIDEO_VBLANK_INTERRUPT     : boolean := false;
	
end;
