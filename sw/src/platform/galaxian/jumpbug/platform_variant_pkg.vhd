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

  constant PLATFORM_VARIANT             : string := "jumpbug";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant GALAXIAN_ROM                 : rom_a(0 to 3) := 
                                          (
                                            0 => "jb1", 
                                            1 => "jb2",
                                            2 => "jb3",
                                            3 => "jb4"
                                          );
  constant GALAXIAN_ROM_WIDTHAD         : natural := 12;
  
  constant GALAXIAN_TILE_ROM            : rom_a(0 to 5) := 
                                          (
                                            0 => "jbl", 
                                            2 => "jbm", 
                                            4 => "jbn", 
                                            1 => "jbi",
                                            3 => "jbj",
                                            5 => "jbk"
                                          );

  alias GALAXIAN_SPRITE_ROM             : rom_a(0 to 5) is GALAXIAN_TILE_ROM;

  -- extra CPU ROMs @$8000
  constant GALAXIAN_EXTRA_ROM           : rom_a(4 to 6) := 
                                          (
                                            4 => "jb5",
                                            5 => "jb6",
                                            6 => "jb7"
                                          );

  -- ROM $0000-$3FFF
  constant GALAXIAN_ROM_A         : std_logic_vector(15 downto 0) := "00--------------";
  -- WRAM $4000-$47FF
  constant GALAXIAN_WRAM_A        : std_logic_vector(15 downto 0) := X"4"&"0-----------";
  constant GALAXIAN_WRAM_WIDTHAD  : natural := 11;
  -- VRAM $4800-$4BFF (shadowed $4C00)
  constant GALAXIAN_VRAM_A        : std_logic_vector(15 downto 0) := X"4"&"1-----------";
  -- CRAM $5000-$50FF
  constant GALAXIAN_CRAM_A        : std_logic_vector(15 downto 0) := X"50"&"--------";
  -- SPRITES/BULLETS $5040-$507F
  constant GALAXIAN_SPRITE_A      : std_logic_vector(15 downto 0) := X"50"&"01------";
  -- INPUTS $6000,$6800,$7000
  constant GALAXIAN_INPUTS_A      : std_logic_vector(15 downto 11) := X"6"&"0";
  -- NMIENA $7001
  constant GALAXIAN_NMIENA_A      : std_logic_vector(15 downto 0) := X"7001";
  
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
