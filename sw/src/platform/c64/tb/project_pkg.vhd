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
  constant PACE_CLK0_MULTIPLY_BY      : natural := 4;  			-- 24*4/3 = 32Mhz
  constant PACE_CLK1_DIVIDE_BY        : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 4;  			-- 24*4/3 = 32MHz

	constant PACE_SRAM_DATA_WIDTH				: natural := 8;
	
	constant PACE_ENABLE_ADV724					: std_logic := '0';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

	-- C64-specific constants

	constant C64_HAS_C64								: boolean := true;
	constant C64_HAS_1541								: boolean := true;
	constant C64_HAS_EXT_SB							: boolean := false;

	-- C64_HAS_C64 configuration
	constant C64_HAS_SID								: boolean := true;

	-- C64_HAS_1541 configuration
	constant C64_1541_DEVICE_SELECT			: std_logic_vector(3 downto 0) := X"8";
	constant C64_1541_ROM_NAME					: string := "25196801_sim";
		
end;
