library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  constant PLATFORM_VARIANT   : string := "xevious";

  type rom_a is array (natural range <>) of string;
  constant GALAGA_ROM                   : rom_a(0 to 3) := 
                                          (
                                            0 => "xvi_1.3p", 
                                            1 => "xvi_2.3m", 
                                            2 => "xvi_3.2m", 
                                            3 => "xvi_4.2l"
                                          );
  constant GALAGA_ROM_WIDTHAD           : natural := 12;

end;
