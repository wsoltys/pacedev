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
	constant PACE_VIDEO_H_SIZE				    : integer := 512;
	constant PACE_VIDEO_V_SIZE				    : integer := 512;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 1;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 3;
	
	--
	-- Platform-specific constants (optional)
	--

	constant CLK0_FREQ_MHz			          : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : natural := 3;

	constant PACMAN_CPU_CLK_ENA_DIVIDE_BY : natural := CLK0_FREQ_MHz / CPU_FREQ_MHz;

	-- Palette : Table of RGB entries	

	type pal_entry_typ is array (0 to 2) of std_logic_vector(5 downto 0);
	type pal_typ is array (0 to 15) of pal_entry_typ;

	constant pal : pal_typ :=
	(
		1 => (0=>"111111", 1=>"000000", 2=>"000000"),
		2 => (0=>"110111", 1=>"100101", 2=>"010001"),
		3 => (0=>"111111", 1=>"101110", 2=>"110111"),
		5 => (0=>"000000", 1=>"111111", 2=>"110111"),
		6 => (0=>"010001", 1=>"101110", 2=>"110111"),
		7 => (0=>"111111", 1=>"101110", 2=>"010001"),
		9 => (0=>"111111", 1=>"111111", 2=>"000000"),
		11 => (0=>"001000", 1=>"001000", 2=>"110111"),
		12 => (0=>"000000", 1=>"111111", 2=>"000000"),
		13 => (0=>"010001", 1=>"101110", 2=>"100101"),
		14 => (0=>"111111", 1=>"101110", 2=>"100101"),
		15 => (0=>"110111", 1=>"110111", 2=>"110111"),
		others => (others => (others => '0'))
	);

	-- Colour Look-up Table (CLUT) : Table of palette entries
	-- - each row has four (4) palette indexes
	--   decoded from 2 bits of tile data
	
	type clut_entry_typ is array (0 to 3) of std_logic_vector(3 downto 0);
	type clut_typ is array (0 to 31) of clut_entry_typ;

	constant clut : clut_typ :=
	(
		1 => (0=>X"0", 1=>X"F", 2=>X"B", 3=>X"1"),
		3 => (0=>X"0", 1=>X"F", 2=>X"B", 3=>X"3"),
		5 => (0=>X"0", 1=>X"F", 2=>X"B", 3=>X"5"),
		7 => (0=>X"0", 1=>X"F", 2=>X"B", 3=>X"7"),
		9 => (0=>X"0", 1=>X"B", 2=>X"1", 3=>X"9"),
		14 => (0=>X"0", 1=>X"F", 2=>X"0", 3=>X"E"),
		15 => (0=>X"0", 1=>X"1", 2=>X"C", 3=>X"F"),
		16 => (0=>X"0", 1=>X"E", 2=>X"0", 3=>X"B"),
		17 => (0=>X"0", 1=>X"C", 2=>X"B", 3=>X"E"),
		18 => (0=>X"0", 1=>X"C", 2=>X"F", 3=>X"1"),
		20 => (0=>X"0", 1=>X"1", 2=>X"2", 3=>X"F"),
		21 => (0=>X"0", 1=>X"7", 2=>X"C", 3=>X"2"),
		22 => (0=>X"0", 1=>X"9", 2=>X"6", 3=>X"F"),
		23 => (0=>X"0", 1=>X"D", 2=>X"C", 3=>X"F"),
		24 => (0=>X"0", 1=>X"5", 2=>X"3", 3=>X"9"),
		25 => (0=>X"0", 1=>X"F", 2=>X"B", 3=>X"0"),
		26 => (0=>X"0", 1=>X"E", 2=>X"0", 3=>X"B"),
		27 => (0=>X"0", 1=>X"E", 2=>X"0", 3=>X"B"),
		29 => (0=>X"0", 1=>X"F", 2=>X"E", 3=>X"1"),
		30 => (0=>X"0", 1=>X"F", 2=>X"B", 3=>X"E"),
		31 => (0=>X"0", 1=>X"E", 2=>X"0", 3=>X"F"),
		others => (others => (others => '0'))
	);

	-- pacman (only) has an off-by-1 bug with the first 3 sprites
	-- see MAME vidhrdw/pacman.c for details
	constant XOFFSETHACK 						: natural := 1;
	constant SOUND_ROM_INIT_FILE		: string := "../../../../src/platform/pacman/roms/pacsnd.hex";

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
