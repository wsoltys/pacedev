library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_HAS_PLL								: boolean := true;
	
  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY        : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 5;  			-- 24*5/3 = 40Mhz
  constant PACE_CLK1_DIVIDE_BY        : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 5;  			-- 24*5/3 = 40MHz

	constant PACE_SRAM_DATA_WIDTH				: natural := 8;
	
	constant PACE_ENABLE_ADV724					: std_logic := '1';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

	-- VIC20-specific constants
					
end;
