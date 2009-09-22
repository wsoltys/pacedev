library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	--
	-- Astrocade-specific constants (optional)
	--

	constant ASTROCADE_SRC_DIR							: string := "../../../../src/platform/astrocade";

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
