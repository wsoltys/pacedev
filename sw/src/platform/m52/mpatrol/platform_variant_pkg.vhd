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

  constant PLATFORM_VARIANT             : string := "mpatrol";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant M52_ROM                      : rom_a(0 to 3) := 
                                          (
                                            0 => "mpa-1.3m", 
                                            1 => "mpa-2.3l",
                                            2 => "mpa-3.3k",
                                            3 => "mpa-4.3j"
                                          );
  constant M52_ROM_WIDTHAD              : natural := 12;

  constant M52_CHAR_ROM                 : rom_a(0 to 1) := 
                                          (
                                            0 => "mpe-5.3e", 
                                            1 => "mpe-4.3f"
                                          );

  constant M52_SPRITE_ROM               : rom_a(0 to 1) := 
                                          (
                                            0 => "mpb-2.3m", 
                                            1 => "mpb-1.3n"
                                          );

  constant M52_BG_ROM                   : rom_a(0 to 2) := 
                                          (
                                            2 => "mpe-1.3l",  -- mountains
                                            1 => "mpe-2.3k",  -- hills
                                            0 => "mpe-3.3h"   -- cityscape
                                          );

                                          
	-- Palette : Table of RGB entries	

	constant pal : pal_typ :=
	(
		3 => (0=>"110111", 1=>"110111", 2=>"111101"),
		5 => (0=>"110111", 1=>"010001", 2=>"000000"),
		6 => (0=>"000000", 1=>"000000", 2=>"111101"),
		7 => (0=>"111111", 1=>"111111", 2=>"000000"),
		9 => (0=>"000000", 1=>"011010", 2=>"111101"),
		10 => (0=>"111111", 1=>"000000", 2=>"000000"),
		11 => (0=>"111111", 1=>"111111", 2=>"000000"),
		13 => (0=>"000000", 1=>"000000", 2=>"111101"),
		14 => (0=>"100101", 1=>"000000", 2=>"111101"),
		15 => (0=>"111111", 1=>"000000", 2=>"000000"),
		17 => (0=>"000000", 1=>"000000", 2=>"111101"),
		18 => (0=>"000000", 1=>"100101", 2=>"101010"),
		19 => (0=>"111111", 1=>"000000", 2=>"000000"),
		23 => (0=>"111111", 1=>"000000", 2=>"000000"),
		25 => (0=>"110111", 1=>"110111", 2=>"111101"),
		26 => (0=>"111111", 1=>"000000", 2=>"000000"),
		27 => (0=>"000000", 1=>"110111", 2=>"111101"),
		29 => (0=>"110111", 1=>"110111", 2=>"010011"),
		30 => (0=>"111111", 1=>"000000", 2=>"000000"),
		31 => (0=>"110111", 1=>"000000", 2=>"111101"),
		others => (others => (others => '0'))
	);

end package platform_variant_pkg;
