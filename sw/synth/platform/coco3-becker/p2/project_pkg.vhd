library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_HAS_PLL										  : boolean := true;
	
  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 12;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 25;  	-- 24*25/12 = 50MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 12;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 25;  	-- 24*25/12 = 50MHz

	constant PACE_ENABLE_ADV724							  : std_logic := '0';
	constant PACE_ADV724_STD								  : std_logic := ADV724_STD_PAL;

  -- P2-specific constants
  constant P2_JAMMA_IS_MAPLE                : boolean := false;
  constant P2_JAMMA_IS_NGC                  : boolean := true;

	-- Coco3-specific constants

end;
