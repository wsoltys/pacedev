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

	constant PACE_VIDEO_NUM_BITMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 0;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
  --defined in project_pkg for vector display
	--constant PACE_VIDEO_H_SIZE				    : integer := 640;   -- 240
	--constant PACE_VIDEO_V_SIZE				    : integer := 480;   -- 240
  constant PACE_VIDEO_L_CROP            : integer := 0;
  constant PACE_VIDEO_R_CROP            : integer := PACE_VIDEO_L_CROP;
	constant PACE_VIDEO_PIPELINE_DELAY    : integer := 3;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 4;
		
	--
	-- Platform-specific constants (optional)
	--

	constant CLK0_FREQ_MHz			          : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;

  constant VECTREX_SOURCE_ROOT_DIR  : string := "../../../../../src/platform/vectrex/";
  constant VECTREX_ROM_DIR          : string := VECTREX_SOURCE_ROOT_DIR & "roms/";

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
