library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_HAS_PLL								: boolean := false;	
  constant PACE_CLK0_DIVIDE_BY        : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 1;
  constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 1;

	-- DE2 constants which *MUST* be defined
	
	constant DE2_LCD_LINE2							: string := "BALLY  ASTROCADE";
		
	-- Astrocade-specific constants
	constant ASTROCADE_HAS_CART							: boolean := true;
	constant ASTROCADE_CART_NAME						: string := "muncher";
	--constant ASTROCADE_CART_NAME						: string := "treasure";
			
end;
