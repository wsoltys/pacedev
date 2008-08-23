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
	
  -- Reference clock is 50MHz
	-- LADYBUG wants 20MHz
	constant PACE_HAS_PLL               : boolean := true;
  constant PACE_CLK0_DIVIDE_BY        : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 2;  		-- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 1;  		-- 20MHz

  -- DE1-specific constants
  constant DE1_JAMMA_IS_MAPLE         : boolean := false;
  constant DE1_JAMMA_IS_NGC           : boolean := true;

	-- Ladybug-specific constants

	constant LADYBUG_EXTERNAL_RAM				: integer := 0;
				
	constant LADYBUG_VIDEO_CVBS					: std_logic := '0';
	constant LADYBUG_VIDEO_VGA					: std_logic := not LADYBUG_VIDEO_CVBS;

end;
