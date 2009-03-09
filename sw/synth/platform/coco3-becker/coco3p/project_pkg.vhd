library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := true;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
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
