library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
  --constant PACE_CLK0_DIVIDE_BY        : natural := 16;
  --constant PACE_CLK0_MULTIPLY_BY      : natural := 7;   	-- 24*7/16 = 10.5MHz (10.4832MHz)
  --constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  --constant PACE_CLK1_MULTIPLY_BY      : natural := 1;  		-- 24MHz (not used)

	--constant PACE_SRAM_DATA_WIDTH				: natural := 8;
	
	--constant PACE_VIDEO_H_SCALE       	: integer := 2;
	--constant PACE_VIDEO_V_SCALE       	: integer := 1;

	constant PACE_ENABLE_ADV724					  : std_logic := '0';
	constant PACE_ADV724_STD						  : std_logic := ADV724_STD_PAL;

	-- OCM-specific constants
	
  constant OCM_DIP_SLOT2_1              : std_logic := '0';
  constant OCM_DIP_SLOT2_0              : std_logic := '0';
  constant OCM_DIP_CPU_CLOCK            : std_logic := '0';
  constant OCM_DIP_DISK_ROM             : std_logic := '0';
  constant OCM_DIP_KEYBOARD             : std_logic := '1';
  constant OCM_DIP_RED_CINCH            : std_logic := '0';
  constant OCM_DIP_VGA_1                : std_logic := not PACE_ENABLE_ADV724;
	constant OCM_DIP_VGA_0                : std_logic := not PACE_ENABLE_ADV724;

end;
