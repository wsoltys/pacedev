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
		
  constant PACE_CLK0_DIVIDE_BY        : natural := 25;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 16;   -- 50*16/25 = 32MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 25;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 16;   -- 50*16/25 = 32MHz

	-- DE2-C64-specific constants
	--constant DE2_LCD_LINE2							: string := "  Commodore 64  ";		-- 16 chars exactly
	--constant DE2_LCD_LINE2							: string := "     C1541C     ";		-- 16 chars exactly
	constant DE2_LCD_LINE2							: string := "   C64 w/1541   ";		-- 16 chars exactly

	-- C64-specific constants
	constant C64_HAS_C64								: boolean := true;
	constant C64_HAS_1541								: boolean := true;
	constant C64_HAS_EXT_SB							: boolean := false;
	constant C64_RESET_CYCLES						: natural := 4095;

	-- C64_HAS_C64 configuration
	constant C64_HAS_SID								: boolean := true;

	-- C64_HAS_1541 configuration
	-- bits (1:0) XOR'd with DIPSWITCHES
	constant C64_1541_DEVICE_SELECT			: std_logic_vector(3 downto 0) := X"8";
	constant C64_1541_ROM_NAME					: string := "25196801";
	--constant C64_1541_ROM_NAME					: string := "325302-1_901229-03";
				
end;
