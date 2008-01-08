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
	
  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY        		: natural := 1;
  constant PACE_CLK0_MULTIPLY_BY      		: natural := 1;  	  -- 50MHz
  constant PACE_CLK1_DIVIDE_BY        		: natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      		: natural := 2;  	  -- 50MHz

	-- DE2 constants which *MUST* be defined
	
	constant DE2_LCD_LINE2							: string := "APPLEII (BECKER)";

	-- Coco3-specific constants

end;
