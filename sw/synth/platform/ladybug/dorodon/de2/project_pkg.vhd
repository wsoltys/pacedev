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
  constant PACE_CLK0_MULTIPLY_BY            : natural := 2;   -- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 25;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 12;  -- 50*12/25 = 24MHz

	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 1;

	-- DE2 constants which *MUST* be defined
	
	constant DE2_JAMMA_IS_MAPLE	              : boolean := false;
	constant DE2_JAMMA_IS_NGC                 : boolean := false;

	constant DE2_LCD_LINE2							      : string := "  DORODON-VGA   ";
		
	-- Ladybug-specific constants

	constant LADYBUG_EXTERNAL_RAM				      : integer := 0;
				
	constant LADYBUG_VIDEO_CVBS					      : std_logic := '0';
	constant LADYBUG_VIDEO_VGA					      : std_logic := not LADYBUG_VIDEO_CVBS;

end;
