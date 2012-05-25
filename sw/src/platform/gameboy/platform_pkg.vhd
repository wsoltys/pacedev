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

	constant PACE_VIDEO_NUM_BITMAPS 	    : natural := 0;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 8;
	constant PACE_VIDEO_H_SIZE				    : integer := 160;
	constant PACE_VIDEO_V_SIZE				    : integer := 144;
  constant PACE_VIDEO_L_CROP            : integer := 0;
  constant PACE_VIDEO_R_CROP            : integer := 0;
	constant PACE_VIDEO_PIPELINE_DELAY    : integer := 3;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 3;
		
	--
	-- Platform-specific constants (optional)
	--

	constant CLK0_FREQ_MHz			          : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;

	constant WILLIAMS_CPU_CLK_ENA_DIVIDE_BY	  : natural := 
          CLK0_FREQ_MHz / 3;

  constant GAMEBOY_SOURCE_ROOT_DIR      : string := "../../../../../src/platform/gameboy/";
  constant GAMEBOY_ROM_DIR              : string := GAMEBOY_SOURCE_ROOT_DIR & "roms/";
  constant GAMEBOY_CART_DIR             : string := GAMEBOY_SOURCE_ROOT_DIR & "carts/";

	type palette_entry_t is array (0 to 2) of std_logic_vector(7 downto 0);
	type palette_entry_a is array (0 to 3) of palette_entry_t;

  -- values from wikipedia entry on "console palettes"
	constant pal : palette_entry_a :=
	(
    0 => (0=>X"9B", 1=>X"BC", 2=>X"0F"),
    1 => (0=>X"8B", 1=>X"AC", 2=>X"0F"),
    2 => (0=>X"30", 1=>X"62", 2=>X"30"),
    3 => (0=>X"0F", 1=>X"38", 2=>X"0F")
	);
 
  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
