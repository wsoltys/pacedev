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

  constant PLATFORM_VARIANT             : string := "frogger";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant GALAXIAN_ROM                 : rom_a(0 to 2) := 
                                          (
                                            0 => "frogger.26", 
                                            1 => "frogger.27",
                                            2 => "frsm3.7"
                                          );
  constant GALAXIAN_ROM_WIDTHAD         : natural := 12;
  
  constant GALAXIAN_TILE_ROM            : rom_a(0 to 1) := 
                                          (
                                            0 => "frogger.607", 
                                            1 => "frogger.606"
                                          );
  constant GALAXIAN_TILE_ROM_WIDTHAD    : natural := 11;

  alias GALAXIAN_SPRITE_ROM             : rom_a(0 to 1) is GALAXIAN_TILE_ROM;
  alias GALAXIAN_SPRITE_ROM_WIDTHAD     : natural is GALAXIAN_TILE_ROM_WIDTHAD;
                                          
   -- null range
  constant GALAXIAN_EXTRA_ROM           : rom_a(0 to -1) := (others => "");
                                          
  -- ROM $0000-$3FFF
  constant GALAXIAN_ROM_A         : std_logic_vector(15 downto 0) := "00--------------";
  -- WRAM $8000-$87FF
  constant GALAXIAN_WRAM_A        : std_logic_vector(15 downto 0) := X"8"&"0-----------";
  constant GALAXIAN_WRAM_WIDTHAD  : natural := 11;
  -- VRAM $A800-$ABFF (mirrored $AC00)
  constant GALAXIAN_VRAM_A        : std_logic_vector(15 downto 0) := X"A"&"1-----------";
  -- CRAM $B000-$B0FF (mirrored $B100-$B6FF)
  constant GALAXIAN_CRAM_A        : std_logic_vector(15 downto 0) := X"B0"&   "--------";
  -- SPRITES/BULLETS $B040-$B07F
  constant GALAXIAN_SPRITE_A      : std_logic_vector(15 downto 0) := X"B0"&"01------";
  -- INPUTS (not used - PIA8255)
  constant GALAXIAN_HAS_PIA8255   : boolean := true;
  constant GALAXIAN_INPUTS_A      : std_logic_vector(15 downto 0) := X"----";
  constant GALAXIAN_INPUTS_INC    : std_logic_vector(15 downto 0) := X"0000";
  -- NMIENA $B808
  constant GALAXIAN_NMIENA_A      : std_logic_vector(15 downto 0) := X"B808";
  
	-- Palette : Table of RGB entries	

	constant pal : pal_typ :=
	(
		1 => (0=>"111111", 1=>"000000", 2=>"000000"),
		2 => (0=>"000000", 1=>"000000", 2=>"111101"),
		3 => (0=>"110111", 1=>"110111", 2=>"111101"),
		5 => (0=>"110111", 1=>"110111", 2=>"111101"),
		6 => (0=>"110111", 1=>"011010", 2=>"010011"),
		7 => (0=>"100101", 1=>"011010", 2=>"010011"),
		9 => (0=>"000000", 1=>"110111", 2=>"111101"),
		10 => (0=>"100101", 1=>"111111", 2=>"000000"),
		11 => (0=>"111111", 1=>"010001", 2=>"111101"),
		13 => (0=>"000000", 1=>"000000", 2=>"111101"),
		14 => (0=>"100101", 1=>"000000", 2=>"111101"),
		15 => (0=>"111111", 1=>"000000", 2=>"000000"),
		17 => (0=>"001000", 1=>"110111", 2=>"000000"),
		18 => (0=>"111111", 1=>"010001", 2=>"000000"),
		19 => (0=>"000000", 1=>"110111", 2=>"111101"),
		21 => (0=>"001000", 1=>"110111", 2=>"000000"),
		22 => (0=>"111111", 1=>"000000", 2=>"111101"),
		23 => (0=>"111111", 1=>"111111", 2=>"000000"),
		25 => (0=>"110111", 1=>"110111", 2=>"111101"),
		26 => (0=>"111111", 1=>"000000", 2=>"000000"),
		27 => (0=>"001000", 1=>"110111", 2=>"000000"),
		29 => (0=>"111111", 1=>"111111", 2=>"000000"),
		30 => (0=>"111111", 1=>"000000", 2=>"000000"),
		31 => (0=>"100101", 1=>"000000", 2=>"111101"),
		others => (others => (others => '0'))
	);

end package platform_variant_pkg;
