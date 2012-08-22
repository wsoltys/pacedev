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

	constant GALAXIAN_INPUTS_NUM_BYTES    : integer := 4;
	
	--
	-- Platform-specific constants (optional)
	--

  constant PLATFORM_VARIANT             : string := "mooncrst";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant GALAXIAN_ROM                 : rom_a(0 to 7) := 
                                          (
                                            0 => "mc1", 
                                            1 => "mc2",
                                            2 => "mc3",
                                            3 => "mc4",
                                            4 => "mc5.7r",
                                            5 => "mc6.8d",
                                            6 => "mc7.8e",
                                            7 => "mc8"
                                          );
  constant GALAXIAN_GFX_ROM             : rom_a(0 to 3) := 
                                          (
                                            0 => "mcs_b", 
                                            1 => "mcs_d", 
                                            2 => "mcs_a", 
                                            3 => "mcs_c"
                                          );

  -- WRAM $8000-$83FF
  constant GALAXIAN_WRAM_A    : std_logic_vector(15 downto 0) := X"8"&"00----------";
  -- VRAM $9000-$93FF
  constant GALAXIAN_VRAM_A    : std_logic_vector(15 downto 0) := X"9"&"00----------";
  -- CRAM $9800-$98FF
  constant GALAXIAN_CRAM_A    : std_logic_vector(15 downto 0) := X"98"&   "--------";
  -- INPUTS $A000,$A800,$B000
  constant GALAXIAN_INPUTS_A  : std_logic_vector(15 downto 0) := X"A"&"0-----------";
  -- NMIENA $B000
  constant GALAXIAN_NMIENA_A  : std_logic_vector(15 downto 0) := X"B000";
  
	-- Palette : Table of RGB entries	

	constant pal : pal_typ :=
	(
    1 => (0=>"010001", 1=>"111111", 2=>"010011"),
    2 => (0=>"110111", 1=>"110111", 2=>"000000"),
    3 => (0=>"111111", 1=>"000000", 2=>"000000"),
    5 => (0=>"000000", 1=>"110111", 2=>"111101"),
    6 => (0=>"000000", 1=>"111111", 2=>"000000"),
    7 => (0=>"111111", 1=>"011010", 2=>"000000"),
    9 => (0=>"111111", 1=>"000000", 2=>"111101"),
    10 => (0=>"000000", 1=>"110111", 2=>"111101"),
    11 => (0=>"111111", 1=>"111111", 2=>"000000"),
    13 => (0=>"011010", 1=>"011010", 2=>"111101"),
    14 => (0=>"110111", 1=>"000000", 2=>"111101"),
    15 => (0=>"000000", 1=>"111111", 2=>"000000"),
    17 => (0=>"110111", 1=>"110111", 2=>"000000"),
    18 => (0=>"111111", 1=>"000000", 2=>"000000"),
    19 => (0=>"000000", 1=>"110111", 2=>"111101"),
    21 => (0=>"011010", 1=>"110111", 2=>"000000"),
    22 => (0=>"111111", 1=>"111111", 2=>"000000"),
    23 => (0=>"011010", 1=>"011010", 2=>"111101"),
    25 => (0=>"111111", 1=>"111111", 2=>"000000"),
    26 => (0=>"111111", 1=>"010001", 2=>"010011"),
    27 => (0=>"110111", 1=>"000000", 2=>"111101"),
    29 => (0=>"110111", 1=>"000000", 2=>"111101"),
    30 => (0=>"111111", 1=>"111111", 2=>"000000"),
    31 => (0=>"111111", 1=>"111111", 2=>"111101"),
		others => (others => (others => '0'))
	);

end package platform_variant_pkg;
