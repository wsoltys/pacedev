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
  constant PACE_HAS_PLL                     : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_CLK0_DIVIDE_BY        		  : natural := 1; -- not used
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 1; -- not used
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 1; -- not used
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 1; -- not used

	constant PACE_ENABLE_ADV724							  : std_logic := '0';
	constant PACE_ADV724_STD								  : std_logic := ADV724_STD_PAL;

	-- Astrocade-specific constants
	constant ASTROCADE_HAS_CART							  : boolean := true;
	constant ASTROCADE_CART_NAME						  : string := "muncher";
	--constant ASTROCADE_CART_NAME						  : string := "treasure";

  constant ASTROCADE_CART_IN_FLASH          : boolean := PACE_HAS_FLASH;
	
end;
