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
  constant GALAXIAN_TILE_ROM_WIDTHAD    : natural := 12;
  
  alias GALAXIAN_SPRITE_ROM             : rom_a(0 to 1) is GALAXIAN_TILE_ROM;
  alias GALAXIAN_SPRITE_ROM_WIDTHAD     : natural is GALAXIAN_TILE_ROM_WIDTHAD;
                                          
  -- ROM $0000-$5FFF
  constant GALAXIAN_ROM_A         : std_logic_vector(15 downto 0) := "00--------------";
  -- WRAM $6000-$6FFF
  constant GALAXIAN_WRAM_A        : std_logic_vector(15 downto 0) := X"6---";
  constant GALAXIAN_WRAM_WIDTHAD  : natural := 12;
  -- VRAM $9000-$93FF (shadowed $9400)
  constant GALAXIAN_VRAM_A        : std_logic_vector(15 downto 0) := X"9"&"0-----------";
  -- CRAM $9800-$98FF
  constant GALAXIAN_CRAM_A        : std_logic_vector(15 downto 0) := X"98"&   "--------";
  -- SPRITES/BULLETS $9840-$987F
  constant GALAXIAN_SPRITE_A      : std_logic_vector(15 downto 0) := GALAXIAN_CRAM_A(15 downto 8) &"01------";
  -- INPUTS $C000,$C400,$C800
  constant GALAXIAN_HAS_PIA8255   : boolean := false;
  constant GALAXIAN_INPUTS_A      : std_logic_vector(15 downto 0) := X"C000";
  constant GALAXIAN_INPUTS_INC    : std_logic_vector(15 downto 0) := X"0400";
  -- NMIENA $C801
  constant GALAXIAN_NMIENA_A      : std_logic_vector(15 downto 0) := X"C801";
  
	-- Palette : Table of RGB entries	

	constant pal : pal_typ :=
	(
     1 => (0=>"000000", 1=>"110111", 2=>"111101"),  -- "00000000","11011110","11110111"),
     2 => (0=>"100101", 1=>"111111", 2=>"000000"),  -- "10010111","11111111","00000000"),
     3 => (0=>"111111", 1=>"010001", 2=>"111101"),  -- "11111111","01000111","11110111"),
     5 => (0=>"110111", 1=>"110111", 2=>"111101"),  -- "11011110","11011110","11110111"),
     6 => (0=>"110111", 1=>"011010", 2=>"010011"),  -- "11011110","01101000","01001111"),
     7 => (0=>"100101", 1=>"011010", 2=>"010011"),  -- "10010111","01101000","01001111"),
     9 => (0=>"111111", 1=>"000000", 2=>"000000"),  -- "11111111","00000000","00000000"),
    10 => (0=>"000000", 1=>"000000", 2=>"111101"),  -- "00000000","00000000","11110111"),
    11 => (0=>"110111", 1=>"110111", 2=>"111101"),  -- "11011110","11011110","11110111"),
    13 => (0=>"000000", 1=>"000000", 2=>"111101"),  -- "00000000","00000000","11110111"),
    14 => (0=>"100101", 1=>"000000", 2=>"111101"),  -- "10010111","00000000","11110111"),
    15 => (0=>"111111", 1=>"000000", 2=>"000000"),  -- "11111111","00000000","00000000"),
    17 => (0=>"001000", 1=>"110111", 2=>"000000"),  -- "00100001","11011110","00000000"),
    18 => (0=>"111111", 1=>"010001", 2=>"000000"),  -- "11111111","01000111","00000000"),
    19 => (0=>"000000", 1=>"110111", 2=>"111101"),  -- "00000000","11011110","11110111"),
    21 => (0=>"111111", 1=>"000000", 2=>"000000"),  -- "11111111","00000000","00000000"),
    22 => (0=>"111111", 1=>"011010", 2=>"000000"),  -- "11111111","01101000","00000000"),
    23 => (0=>"111111", 1=>"111111", 2=>"000000"),  -- "11111111","11111111","00000000"),
    25 => (0=>"110111", 1=>"110111", 2=>"111101"),  -- "11011110","11011110","11110111"),
    26 => (0=>"111111", 1=>"000000", 2=>"000000"),  -- "11111111","00000000","00000000"),
    27 => (0=>"001000", 1=>"110111", 2=>"000000"),  -- "00100001","11011110","00000000"),
    28 => (0=>"111111", 1=>"111111", 2=>"111101"),  -- "11111111","11111111","11110111"),
    29 => (0=>"111111", 1=>"011010", 2=>"000000"),  -- "11111111","01101000","00000000"),
    30 => (0=>"101110", 1=>"010001", 2=>"000000"),  -- "10111000","01000111","00000000"),
    31 => (0=>"011010", 1=>"001000", 2=>"000000"),  -- "01101000","00100001","00000000"),
		others => (others => (others => '0'))
	);

end package platform_variant_pkg;
