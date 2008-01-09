library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								: boolean := true;
  constant PACE_CLK0_DIVIDE_BY        : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 1;   -- 24*1/1 = 24MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 5;  	-- 24*5/3 = 40MHz

	constant PACE_VIDEO_H_SCALE       	: integer := 2;
	constant PACE_VIDEO_V_SCALE       	: integer := 2;

	constant PACE_ENABLE_ADV724					: std_logic := '0';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

  -- P2-specific constants
  constant P2_JAMMA_IS_MAPLE          : boolean := false;
  constant P2_JAMMA_IS_NGC            : boolean := true;

	-- Space Invaders-specific constants
			
	constant INVADERS_CPU_CLK_ENA_DIVIDE_BY		: natural := 12;
	constant INVADERS_1MHz_CLK0_COUNTS				: natural := 24;

	constant INVADERS_USE_INTERNAL_WRAM				: boolean := true;
	constant USE_VIDEO_VBLANK_INTERRUPT 			: boolean := false;
	
end;
