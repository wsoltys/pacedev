library ieee;
use ieee.std_logic_1164.all;

library work;
use work.target_pkg.all;
use work.project_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 1;
	
  -- depends on build or simulation
  --constant A2061_SOURCE_ROOT_DIR  : string;

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
