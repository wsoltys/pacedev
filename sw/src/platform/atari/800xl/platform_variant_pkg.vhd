library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  constant PLATFORM_VARIANT               : string := "800xl";
  constant PLATFORM_VARIANT_KERNEL_NAME   : string := "co61598b.rom.hex";

  -- BASIC
  --constant PLATFORM_VARIANT_BASIC_NAME    : string := "basic_reva.rom.hex";
  --constant PLATFORM_VARIANT_BASIC_NAME    : string := "basic_revb.rom.hex";
  constant PLATFORM_VARIANT_BASIC_NAME    : string := "basic_revc.rom.hex";
  
end;
