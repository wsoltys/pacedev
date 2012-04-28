library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  -- MAME says 292x240, but it's clipped in PACE
	constant WILLIAMS_VIDEO_H_SIZE		: integer := 292+8;
	constant WILLIAMS_VIDEO_V_SIZE		: integer := 240+8;
	constant WILLIAMS_VIDEO_L_CROP    : integer := 0;
	constant WILLIAMS_VIDEO_R_CROP    : integer := 0;

  constant PLATFORM_VARIANT         : string := "qbert";
                                                
end;
