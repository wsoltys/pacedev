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

  constant PLATFORM_VARIANT             : string := "galaxian";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant GALAXIAN_ROM                 : rom_a(0 to 4) := 
                                          (
                                            0 => "galmidw.u", 
                                            1 => "galmidw.v",
                                            2 => "galmidw.w",
                                            3 => "galmidw.y",
                                            4 => "7l"
                                          );
  constant GALAXIAN_GFX_ROM             : rom_a(0 to 1) := 
                                          (
                                            0 => "1h.bin", 
                                            1 => "1k.bin"
                                          );
  
  -- WRAM $4000-$47FF
  constant GALAXIAN_WRAM_A    : std_logic_vector(15 downto 0) := X"4"&"0-----------";
  -- VRAM $5000-$57FF
  constant GALAXIAN_VRAM_A    : std_logic_vector(15 downto 0) := X"5"&"0-----------";
  -- CRAM $5800-$5BFF
  constant GALAXIAN_CRAM_A    : std_logic_vector(15 downto 0) := X"5"&"10----------";
  
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
