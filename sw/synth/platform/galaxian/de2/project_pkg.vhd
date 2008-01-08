library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_HAS_PLL								      : boolean := true;	
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 3;   -- 50*3/5 = 30MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 5;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 4;   -- 50*9/25 = 18MHz

	constant PACE_VIDEO_H_SCALE               : integer := 1;
	constant PACE_VIDEO_V_SCALE               : integer := 1;

	-- DE2 constants which *MUST* be defined
	
	constant DE2_LCD_LINE2							      : string := "  GALAXIAN-LCD  ";
		
	-- Galaxian-specific constants
			
	constant GALAXIAN_CPU_CLK_ENA_DIVIDE_BY	  : natural := 10;
	constant GALAXIAN_1MHz_CLK0_COUNTS			  : natural := 30;
	constant GALAXIAN_USE_INTERNAL_WRAM       : boolean := true;
	
	constant USE_VIDEO_VBLANK_INTERRUPT       : boolean := false;
	
end;
