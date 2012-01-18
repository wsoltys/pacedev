library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;
use work.target_pkg.all;
use work.platform_variant_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_VIDEO_NUM_BITMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 0;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
	constant PACE_VIDEO_H_SIZE				    : integer := 512;
	constant PACE_VIDEO_V_SIZE				    : integer := 384;
	constant PACE_VIDEO_L_CROP            : integer := 0;
	constant PACE_VIDEO_R_CROP            : integer := 0;
	constant PACE_VIDEO_PIPELINE_DELAY    : integer := 3;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 4;
		
	--
	-- Platform-specific constants (optional)
	--

	constant CLK0_FREQ_MHz			          : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;

	constant MAC_CPU_CLK_ENA_DIVIDE_BY	  : natural := 
          CLK0_FREQ_MHz / 3;

  constant MAC_SOURCE_ROOT_DIR      : string := "../../../../../src/platform/mac/";
  constant VARIANT_SOURCE_ROOT_DIR  : string := MAC_SOURCE_ROOT_DIR & 
                                                PLATFORM_VARIANT & "/";
  constant VARIANT_ROM_DIR          : string := VARIANT_SOURCE_ROOT_DIR &
                                                "roms/";

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
