library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

  constant PLATFORM_VARIANT   : string := "1942";

  type rom_a is array (natural range <>) of string;
  
  constant CAPCOM_ROM                   : rom_a(0 to 4) := 
                                          (
                                            0 => "srb-03.m3", 
                                            1 => "srb-04.m4",
                                            2 => "srb-05.m5",
                                            3 => "srb-06.m6",
                                            4 => "srb-07.m7"
                                          );
  constant CAPCOM_ROM_WIDTHAD           : natural := 14;

end;
