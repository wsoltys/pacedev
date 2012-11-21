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
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 1;  	  -- 50MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 2;  	  -- 50MHz

	-- DE2 constants which *MUST* be defined
	
	constant DE2_JAMMA_IS_MAPLE	              : boolean := false;
	constant DE2_JAMMA_IS_NGC                 : boolean := true;
	
	constant DE2_LCD_LINE2							      : string := "APPLEII (BECKER)";

	-- AppleII-Becker-specific constants

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
