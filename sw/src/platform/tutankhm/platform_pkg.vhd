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

	constant PACE_VIDEO_NUM_BITMAPS 	  : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	  : natural := 0;		-- used for video counter only
	constant PACE_VIDEO_NUM_SPRITES 	  : natural := 0;
	constant PACE_VIDEO_H_SIZE				  : integer := 224;
	constant PACE_VIDEO_V_SIZE				  : integer := 256;
	constant PACE_VIDEO_PIPELINE_DELAY  : integer := 3;
	
	--
	-- Platform-specific constants (optional)
	--

	constant TUTANKHAM_1MHz_CLK0_COUNTS				: natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
	constant TUTANKHAM_CPU_CLK_ENA_DIVIDE_BY	: natural := 
    TUTANKHAM_1MHz_CLK0_COUNTS * 2 / 3;

  constant TUTANKHAM_SOURCE_ROOT_DIR        : string;

end;
