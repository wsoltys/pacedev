library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.target_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

package platform_variant_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	--
	-- Platform-specific constants (optional)
	--

  constant PLATFORM_VARIANT             : string := "bwidow";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant BWIDOW_ROM                   : rom_a(0 to 4) := 
                                          (
                                            0 => "galmidw.u", 
                                            1 => "galmidw.v",
                                            2 => "galmidw.w",
                                            3 => "galmidw.y",
                                            4 => "7l"
                                          );
  constant BWIDOW_ROM_WIDTHAD           : natural := 11;

end package platform_variant_pkg;
