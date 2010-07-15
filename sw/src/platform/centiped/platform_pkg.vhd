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

	constant PACE_VIDEO_NUM_BITMAPS		    : natural := 0;
	constant PACE_VIDEO_NUM_TILEMAPS	    : natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 16;
	constant PACE_VIDEO_H_SIZE				    : integer := 256;
	constant PACE_VIDEO_V_SIZE				    : integer := 256;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 5;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 3;
		
	--
	-- Platform-specific constants (optional)
	--

	-- Palette : Table of RGB entries	

	type pal_entry_typ is array (0 to 2) of std_logic_vector(5 downto 0);
	type pal_typ is array (0 to 7) of pal_entry_typ;

	constant pal : pal_typ :=
	(
		1 => (0=>"000000", 1=>"100101", 2=>"000000"),
		2 => (0=>"100101", 1=>"000000", 2=>"000000"),
		3 => (0=>"100101", 1=>"100101", 2=>"101010"),
		4 => (0=>"000000", 1=>"000000", 2=>"101010"),
		5 => (0=>"100101", 1=>"100101", 2=>"101010"),
		6 => (0=>"100101", 1=>"000000", 2=>"000000"),
		7 => (0=>"000000", 1=>"100101", 2=>"000000"),
		others => (others => (others => '0'))
	);

	constant CLK0_FREQ_MHz		            : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : natural := 2;
  
	constant CENTIPED_CPU_CLK_ENA_DIVIDE_BY   : natural := CLK0_FREQ_MHz / CPU_FREQ_MHz;

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
