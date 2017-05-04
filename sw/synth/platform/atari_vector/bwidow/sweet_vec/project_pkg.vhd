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
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  constant PACE_CLK0_DIVIDE_BY              : natural := 2;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;       -- 24*1/2 = 12MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 24;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 65;  	  -- 24*65/24 = 65MHz

  -- SWEET_VEC-specific constants
  
  --
	-- Atari Vector-specific constants
	--
	
  --
	-- Black Widow-specific constants
	--
  constant BWIDOW_EXTERNAL_ROM              : boolean := true;
  
	-- derived - do not edit

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
