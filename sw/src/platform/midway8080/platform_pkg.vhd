library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;
use work.target_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_VIDEO_NUM_BITMAPS		    : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 0;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
	constant PACE_VIDEO_H_SIZE				    : integer := 224;
	constant PACE_VIDEO_V_SIZE				    : integer := 240; --256; -- why not 240?
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 3;
	
	--
	-- Platform-specific constants (optional)
	--

	constant INVADERS_1MHz_CLK0_COUNTS				: natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
	constant INVADERS_CPU_CLK_ENA_DIVIDE_BY		: natural := 
    INVADERS_1MHz_CLK0_COUNTS / 2;

end;
