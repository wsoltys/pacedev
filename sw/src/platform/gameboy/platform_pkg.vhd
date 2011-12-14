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
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 4;
		
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

	type palette_entry_t is array (0 to 2) of std_logic_vector(5 downto 0);
	type palette_entry_a is array (0 to 3) of palette_entry_t;

	constant pal : palette_entry_a :=
	(
    1 => (0=>"100111", 1=>"100111", 2=>"100111"),
    2 => (0=>"000000", 1=>"100011", 2=>"000000"),
    3 => (0=>"011100", 1=>"001011", 2=>"000111"),
		others => (others => (others => '0'))
	);
 
  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
