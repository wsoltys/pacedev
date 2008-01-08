library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--
	-- Scramble/Frogger-specific constants
	--
	
	constant SCRAMBLE_BUILD_SCRAMBLE		: boolean := true;
	constant SCRAMBLE_BUILD_FROGGER			: boolean := not SCRAMBLE_BUILD_SCRAMBLE;
	
	constant SCRAMBLE_VIDEO_CVBS				: std_logic := '0';
	constant SCRAMBLE_VIDEO_VGA					: std_logic := not SCRAMBLE_VIDEO_CVBS;
				
	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_HAS_PLL								: boolean := false;
		
  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY        : natural := 12;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 5;  		-- 24*5/12 = 10MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 6;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 5;  		-- 24*5/6 = 20MHz

	--constant PACE_VIDEO_H_SCALE         : integer := 2;
	--constant PACE_VIDEO_V_SCALE         : integer := 2;

	constant PACE_SRAM_DATA_WIDTH				: natural := 8;
	
	constant PACE_ENABLE_ADV724					: std_logic := SCRAMBLE_VIDEO_CVBS;
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

end;
