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
	
  -- (Programmable) Board clock must be set to 24MHz
  constant PACE_CLK0_DIVIDE_BY        : natural := 8;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 9;   -- 24*9/8 = 27MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 16;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 9;  	-- 24*9/16 = 13.5MHz
	
	constant PACE_VIDEO_H_SCALE         : integer := 2;
	constant PACE_VIDEO_V_SCALE         : integer := 1;

	constant PACE_ENABLE_ADV724					: std_logic := '1';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

	-- Target constant which *MUST* be defined
	
	constant NANOBOARD_PLL_INCLK : NANOBOARD_PLL_INCLK_Type := NANOBOARD_PLL_INCLK_BRD;
		
	-- Moon Cresta-specific constants
			
	constant MOONCRES_CPU_CLK_ENA_DIVIDE_BY	  : natural := 9;
	constant MOONCRES_1MHz_CLK0_COUNTS			  : natural := 27;
	-- needed by Galaxian_Interrupts
	constant GALAXIAN_1MHz_CLK0_COUNTS			: natural := MOONCRES_1MHz_CLK0_COUNTS;
	
	constant USE_VIDEO_VBLANK_INTERRUPT : boolean := false;

end;
