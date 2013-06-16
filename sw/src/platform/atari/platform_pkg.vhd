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

  -- native orientation
  constant INVADERS_VIDEO_H_SIZE				: integer := 256;
	constant INVADERS_VIDEO_V_SIZE				: integer := 224;

	constant PACE_VIDEO_NUM_BITMAPS		    : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 0;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
	constant PACE_VIDEO_H_SIZE				    : integer := 192*4;
	constant PACE_VIDEO_V_SIZE				    : integer := 262*2;
	constant PACE_VIDEO_L_CROP				    : integer := 0;
	constant PACE_VIDEO_R_CROP				    : integer := 0;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 3;
	
  constant PACE_INPUTS_NUM_BYTES        : integer := 3;

	--
	-- Platform-specific constants (optional)
	--

  constant ATARI_SOURCE_ROOT_DIR    : string := "../../../../../src/platform/atari/";
  constant ATARI_ROM_DIR            : string := ATARI_SOURCE_ROOT_DIR & 
                                                "roms/";
  constant VARIANT_SOURCE_ROOT_DIR  : string := ATARI_SOURCE_ROOT_DIR & 
                                                PLATFORM_VARIANT & "/";
  constant VARIANT_ROM_DIR          : string := VARIANT_SOURCE_ROOT_DIR &
                                                "roms/";

	constant CLK0_FREQ_MHz		            : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : natural := 2;
  
  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end package;
