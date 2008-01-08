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
	
	constant PACE_HAS_PLL								: boolean := true;
	constant NANOBOARD_PLL_INCLK				: NANOBOARD_PLL_INCLK_Type := NANOBOARD_PLL_INCLK_REF;
	constant INCLK0_INPUT_FREQUENCY			: natural := 50000;	-- 20MHz	
	
  -- Reference clock is 20MHz
  constant PACE_CLK0_DIVIDE_BY        : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 8;  			-- 20*5/8 = 32Mhz
  constant PACE_CLK1_DIVIDE_BY        : natural := 5;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 8;  			-- 20*5/8 = 32MHz

  -- NB1-specific constants that must be defined
  constant NB1_PLL_INCLK              : NANOBOARD_PLL_INCLK_Type := NANOBOARD_PLL_INCLK_REF;
  constant NB1_INCLK0_INPUT_FREQUENCY : natural := 50000;   -- 20MHz

	-- C64-specific constants

	constant C64_HAS_C64								: boolean := true;
	constant C64_HAS_1541								: boolean := false;
	constant C64_HAS_EXT_SB							: boolean := false;
	constant C64_RESET_CYCLES						: natural := 4095;

	-- C64_HAS_C64 configuration
	constant C64_HAS_SID								: boolean := false;
				
	-- C64_HAS_1541 configuration
	constant C64_1541_DEVICE_SELECT			: std_logic_vector(3 downto 0) := X"8";
	-- 1541 early firmware
	--constant C64_1541_ROM_NAME					: string := "325302-1_901229-03";
	-- 1541C firmware (track 0 sensor enabled)
	constant C64_1541_ROM_NAME					: string := "25196801";

end;
