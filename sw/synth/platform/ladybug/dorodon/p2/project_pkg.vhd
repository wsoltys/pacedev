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
	-- LADYBUG wants 20MHz
	constant PACE_HAS_PLL               : boolean := true;
  constant PACE_CLK0_DIVIDE_BY        : natural := 6;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 5;  		-- 24*5/6 = 20MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 1;  		-- 24MHz

	--constant PACE_VIDEO_H_SCALE         : integer := 2;
	--constant PACE_VIDEO_V_SCALE         : integer := 2;

	-- see below
	--constant PACE_ENABLE_ADV724					: std_logic := '1';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

  -- P2-specific constants
  constant P2_JAMMA_IS_MAPLE          : boolean := false;
  constant P2_JAMMA_IS_NGC            : boolean := true;

	-- Ladybug-specific constants
	
	constant LADYBUG_EXTERNAL_RAM				: integer := 0;
	
	constant LADYBUG_VIDEO_CVBS					: std_logic := '0';
	constant LADYBUG_VIDEO_VGA					: std_logic := not LADYBUG_VIDEO_CVBS;

	constant PACE_ENABLE_ADV724					: std_logic := LADYBUG_VIDEO_CVBS;
					
end;
