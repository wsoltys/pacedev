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

  constant PLATFORM_VARIANT             : string := "ckongg";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;

  constant GALAXIAN_ROM                 : rom_a(0 to 5) := 
                                          (
                                            0 => "g_ck1.bin", 
                                            1 => "ck2.bin",
                                            2 => "g_ck3.bin",
                                            3 => "g_ck4.bin",
                                            4 => "g_ck5.bin",
                                            5 => "g_ck7.bin"
                                          );
                                          
  -- null range
  constant GALAXIAN_EXTRA_ROM           : rom_a(0 to -1) := (others => "");

  constant GALAXIAN_ROM_WIDTHAD         : natural := 12;
  
  constant GALAXIAN_TILE_ROM            : rom_a(0 to 1) := 
                                          (
                                            0 => "ckvid10.bin", 
                                            1 => "ckvid7.bin"
                                          );

  alias GALAXIAN_SPRITE_ROM             : rom_a(0 to 1) is GALAXIAN_TILE_ROM;
                                          
  -- WRAM $6000-$6FFF
  constant GALAXIAN_WRAM_A        : std_logic_vector(15 downto 0) := X"6---";
  constant GALAXIAN_WRAM_WIDTHAD  : natural := 12;
  -- VRAM $9000-$93FF (shadowed $9400)
  constant GALAXIAN_VRAM_A        : std_logic_vector(15 downto 0) := X"9"&"0-----------";
  -- CRAM $9800-$98FF
  constant GALAXIAN_CRAM_A        : std_logic_vector(15 downto 0) := X"98"&   "--------";
  -- INPUTS $C000,$C400,$C800
  constant GALAXIAN_INPUTS_A      : std_logic_vector(15 downto 11) := X"C"&"0";
  -- NMIENA $C801
  constant GALAXIAN_NMIENA_A      : std_logic_vector(15 downto 0) := X"C801";
  
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
