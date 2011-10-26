library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

	constant WILLIAMS_VIDEO_H_SIZE		: integer := 304;
	constant WILLIAMS_VIDEO_V_SIZE		: integer := 256;

  constant PLATFORM_VARIANT         : string := "joust";
                                                
end;
