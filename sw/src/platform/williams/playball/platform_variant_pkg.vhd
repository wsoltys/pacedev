library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.platform_pkg.WILLIAMS_SOURCE_ROOT_DIR;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  constant PLATFORM_VARIANT         : string := "playball";
  
  constant VARIANT_SOURCE_ROOT_DIR  : string := WILLIAMS_SOURCE_ROOT_DIR & 
                                                PLATFORM_VARIANT & "/";
  constant VARIANT_ROM_DIR          : string := VARIANT_SOURCE_ROOT_DIR &
                                                "roms/";
                                                
end;
