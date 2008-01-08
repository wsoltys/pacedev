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
  constant PACE_CLK0_DIVIDE_BY        : natural := 32;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 27;   	-- 24*27/32 = 20M25Hz
  constant PACE_CLK1_DIVIDE_BY        : natural := 16;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 9;  		-- 24*9/16 = 13.5MHz

	constant PACE_VIDEO_H_SCALE       	: integer := 2;
	constant PACE_VIDEO_V_SCALE       	: integer := 1;

	constant PACE_ENABLE_ADV724					: std_logic := '1';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;
		
	constant USE_VIDEO_VBLANK_INTERRUPT : boolean := false;
	
end;
