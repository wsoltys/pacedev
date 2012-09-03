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

  constant PLATFORM_VARIANT             : string := "scramble";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant GALAXIAN_ROM                 : rom_a(0 to 7) := 
                                          (
                                            0 => "s1.2d", 
                                            1 => "s2.2e",
                                            2 => "s3.2f",
                                            3 => "s4.2h",
                                            4 => "s5.2j",
                                            5 => "s6.2l",
                                            6 => "s7.2m",
                                            7 => "s8.2p"
                                          );
  constant GALAXIAN_ROM_WIDTHAD         : natural := 11;
  
  constant GALAXIAN_TILE_ROM            : rom_a(0 to 1) := 
                                          (
                                            0 => "c2.5f", 
                                            1 => "c1.5h"
                                          );

  alias GALAXIAN_SPRITE_ROM             : rom_a(0 to 1) is GALAXIAN_TILE_ROM;
                                          
   -- null range
  constant GALAXIAN_EXTRA_ROM           : rom_a(0 to -1) := (others => "");
                                          
  -- ROM $0000-$3FFF
  constant GALAXIAN_ROM_A         : std_logic_vector(15 downto 0) := "00--------------";
  -- WRAM $4000-$47FF
  constant GALAXIAN_WRAM_A        : std_logic_vector(15 downto 0) := X"4"&"0-----------";
  constant GALAXIAN_WRAM_WIDTHAD  : natural := 11;
  -- VRAM $4800-$4BFF (shadowed $4C00)
  constant GALAXIAN_VRAM_A        : std_logic_vector(15 downto 0) := X"4"&"1-----------";
  -- CRAM $5000-$50FF
  constant GALAXIAN_CRAM_A        : std_logic_vector(15 downto 0) := X"50"&   "--------";
  -- SPRITES/BULLETS $5840-$587F
  constant GALAXIAN_SPRITE_A      : std_logic_vector(15 downto 0) := GALAXIAN_CRAM_A(15 downto 8) &"01------";
  -- INPUTS $8000-$FFFF (PIA8255)
  constant GALAXIAN_HAS_PIA8255   : boolean := true;
  constant GALAXIAN_INPUTS_A      : std_logic_vector(15 downto 0) := "1------1--------";
  -- NMIENA $6801
  constant GALAXIAN_NMIENA_A      : std_logic_vector(15 downto 0) := X"6801";
  
	-- Palette : Table of RGB entries	

	constant pal : pal_typ :=
	(
		1 => (0=>"111111", 1=>"010001", 2=>"000000"),
		2 => (0=>"111111", 1=>"000000", 2=>"111101"),
		3 => (0=>"110111", 1=>"110111", 2=>"111101"),
		5 => (0=>"111111", 1=>"010001", 2=>"000000"),
		6 => (0=>"000000", 1=>"000000", 2=>"111101"),
		7 => (0=>"111111", 1=>"111111", 2=>"000000"),
		9 => (0=>"111111", 1=>"000000", 2=>"000000"),
		10 => (0=>"000000", 1=>"000000", 2=>"111101"),
		11 => (0=>"111111", 1=>"111111", 2=>"000000"),
		13 => (0=>"000000", 1=>"000000", 2=>"111101"),
		14 => (0=>"100101", 1=>"000000", 2=>"111101"),
		15 => (0=>"111111", 1=>"000000", 2=>"000000"),
		17 => (0=>"111111", 1=>"000000", 2=>"111101"),
		18 => (0=>"001000", 1=>"110111", 2=>"000000"),
		19 => (0=>"111111", 1=>"010001", 2=>"000000"),
		21 => (0=>"001000", 1=>"110111", 2=>"000000"),
		22 => (0=>"111111", 1=>"000000", 2=>"111101"),
		23 => (0=>"111111", 1=>"111111", 2=>"000000"),
		25 => (0=>"110111", 1=>"110111", 2=>"111101"),
		26 => (0=>"111111", 1=>"000000", 2=>"000000"),
		27 => (0=>"000000", 1=>"110111", 2=>"111101"),
		29 => (0=>"111111", 1=>"111111", 2=>"000000"),
		30 => (0=>"111111", 1=>"000000", 2=>"000000"),
		31 => (0=>"100101", 1=>"000000", 2=>"111101"),
		others => (others => (others => '0'))
	);

end package platform_variant_pkg;
