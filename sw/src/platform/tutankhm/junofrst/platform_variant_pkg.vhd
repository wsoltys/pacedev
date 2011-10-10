library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  constant PLATFORM_VARIANT         : string := "junofrst";
	constant PLATFORM_HAS_KONAMI_CPU  : boolean := true;
  
end;
