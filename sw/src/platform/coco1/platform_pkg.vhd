library ieee;
use ieee.std_logic_1164.all;

library work;
use work.target_pkg.all;
use work.project_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 9;
	
	constant GALAXIAN_1MHz_CLK0_COUNTS			  : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;

	constant GALAXIAN_CPU_CLK_ENA_DIVIDE_BY	  : natural := 
    GALAXIAN_1MHz_CLK0_COUNTS / 3;

  -- debug build options
  constant BUILD_TEST_VGA_ONLY    : boolean := false;
  
  -- CoCo build options
  constant EXTENDED_COLOR_BASIC   : boolean := true;

  -- depends on build or simulation
  constant COCO1_SOURCE_ROOT_DIR  : string;

	--
	-- Platform-specific constants (optional)
	--

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
