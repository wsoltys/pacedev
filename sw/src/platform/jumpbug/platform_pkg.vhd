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
	
	constant PACE_VIDEO_NUM_BITMAPS		: natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS	: natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	: natural := 16;
	constant PACE_VIDEO_H_SIZE				: integer := 256;
	constant PACE_VIDEO_V_SIZE				: integer := 256;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 5;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 2;
	
	--
	-- Platform-specific constants (optional)
	--

	constant JUMPBUG_1MHz_CLK0_COUNTS			    : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;

	constant JUMPBUG_CPU_CLK_ENA_DIVIDE_BY	  : natural := 
    JUMPBUG_1MHz_CLK0_COUNTS / 3;

	constant GALAXIAN_1MHz_CLK0_COUNTS	      : natural := 
    JUMPBUG_1MHz_CLK0_COUNTS;

	-- Palette : Table of RGB entries	

	type pal_entry_typ is array (0 to 2) of std_logic_vector(5 downto 0);
	type pal_typ is array (0 to 31) of pal_entry_typ;

	constant pal : pal_typ :=
	(
		1 => (0=>"010001", 1=>"111111", 2=>"010011"),
		2 => (0=>"110111", 1=>"110111", 2=>"000000"),
		3 => (0=>"111111", 1=>"000000", 2=>"000000"),
		5 => (0=>"000000", 1=>"110111", 2=>"111101"),
		6 => (0=>"000000", 1=>"111111", 2=>"000000"),
		7 => (0=>"111111", 1=>"011010", 2=>"000000"),
		9 => (0=>"111111", 1=>"000000", 2=>"111101"),
		10 => (0=>"000000", 1=>"110111", 2=>"111101"),
		11 => (0=>"111111", 1=>"111111", 2=>"000000"),
		13 => (0=>"011010", 1=>"011010", 2=>"111101"),
		14 => (0=>"110111", 1=>"000000", 2=>"111101"),
		15 => (0=>"000000", 1=>"111111", 2=>"000000"),
		17 => (0=>"110111", 1=>"110111", 2=>"000000"),
		18 => (0=>"111111", 1=>"000000", 2=>"000000"),
		19 => (0=>"000000", 1=>"110111", 2=>"111101"),
		21 => (0=>"011010", 1=>"110111", 2=>"000000"),
		22 => (0=>"111111", 1=>"111111", 2=>"000000"),
		23 => (0=>"011010", 1=>"011010", 2=>"111101"),
		25 => (0=>"111111", 1=>"111111", 2=>"000000"),
		26 => (0=>"111111", 1=>"010001", 2=>"010011"),
		27 => (0=>"110111", 1=>"000000", 2=>"111101"),
		29 => (0=>"110111", 1=>"000000", 2=>"111101"),
		30 => (0=>"111111", 1=>"111111", 2=>"000000"),
		31 => (0=>"111111", 1=>"111111", 2=>"111101"),
		others => (others => (others => '0'))
	);

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
