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
	constant PACE_VIDEO_NUM_TILEMAPS	    : natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 16;
	constant PACE_VIDEO_H_SIZE				    : integer := 256;
	constant PACE_VIDEO_V_SIZE				    : integer := 256;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 5;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 2;
	
	--
	-- Platform-specific constants (optional)
	--

	constant SCRAMBLE_1MHz_CLK0_COUNTS			  : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;

	constant SCRAMBLE_CPU_CLK_ENA_DIVIDE_BY	  : natural := 
    SCRAMBLE_1MHz_CLK0_COUNTS / 3;

	constant GALAXIAN_1MHz_CLK0_COUNTS				: natural := SCRAMBLE_1MHz_CLK0_COUNTS;

	-- Palette : Table of RGB entries	

	type pal_entry_typ is array (0 to 2) of std_logic_vector(5 downto 0);
	type pal_typ is array (0 to 31) of pal_entry_typ;

	constant pal : pal_typ :=
	(
		1 => (0=>"111111", 1=>"010001", 2=>"000000"),
		2 => (0=>"111111", 1=>"000000", 2=>"111101"),
		3 => (0=>"110111", 1=>"110111", 2=>"111101"),
		5 => (0=>"111111", 1=>"010001", 2=>"000000"),
		6 => (0=>"000000", 1=>"000000", 2=>"111101"),
		7 => (0=>"111111", 1=>"111111", 2=>"000000"),
		9 => (0=>"111111", 1=>"000000", 2=>"000000"),
		10 => (0=>"000000", 1=>"000000", 2=>"111101"),
		11 => (0=>"111111", 1=>"111111", 2=>"000000"),
		13 => (0=>"000000", 1=>"000000", 2=>"111101"),
		14 => (0=>"100101", 1=>"000000", 2=>"111101"),
		15 => (0=>"111111", 1=>"000000", 2=>"000000"),
		17 => (0=>"111111", 1=>"000000", 2=>"111101"),
		18 => (0=>"001000", 1=>"110111", 2=>"000000"),
		19 => (0=>"111111", 1=>"010001", 2=>"000000"),
		21 => (0=>"001000", 1=>"110111", 2=>"000000"),
		22 => (0=>"111111", 1=>"000000", 2=>"111101"),
		23 => (0=>"111111", 1=>"111111", 2=>"000000"),
		25 => (0=>"110111", 1=>"110111", 2=>"111101"),
		26 => (0=>"111111", 1=>"000000", 2=>"000000"),
		27 => (0=>"000000", 1=>"110111", 2=>"111101"),
		29 => (0=>"111111", 1=>"111111", 2=>"000000"),
		30 => (0=>"111111", 1=>"000000", 2=>"000000"),
		31 => (0=>"100101", 1=>"000000", 2=>"111101"),
		others => (others => (others => '0'))
	);

end;
