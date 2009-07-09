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
	
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SERIAL                  : boolean := false;
	constant PACE_HAS_SPI								      : boolean := false;	
	
  -- Reference clock is 20MHz
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 2;  			-- 20*2/1 = 40Mhz
  constant PACE_CLK1_DIVIDE_BY              : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 2;  			-- 20*2/1 = 40MHz

  -- NB1-specific constants that must be defined
  constant NB1_PLL_INCLK                    : NANOBOARD_PLL_INCLK_Type := NANOBOARD_PLL_INCLK_REF;
  constant NB1_INCLK0_INPUT_FREQUENCY       : natural := 50000;   -- 20MHz
	constant PACE_CLKIN0											: natural := PACE_CLKIN0_REF;

	-- VIC20-specific constants
	--constant VIDEOPAC_CART_NAME					: string := "kcmunch.hex";
					
end;
