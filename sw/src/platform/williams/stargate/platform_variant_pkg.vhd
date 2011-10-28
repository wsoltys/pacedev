library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  -- MAME says 292x240, but it's clipped in PACE
	constant WILLIAMS_VIDEO_H_SIZE		: integer := 292+8;
	constant WILLIAMS_VIDEO_V_SIZE		: integer := 240+8;

  constant WILLIAMS_HAS_BLITTER     : boolean := false;
  constant WILLIAMS_SC02_REVISION   : integer := 2;
  constant WILLIAMS_SC02_CLIP_ADDR  : unsigned(15 downto 0) := (others => '0');

  constant WILLIAMS_NVRAM_WIDTH     : integer := 4;
  
  constant PLATFORM_VARIANT         : string := "stargate";
  
end;
