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

  constant PLATFORM_VARIANT             : string := "zigzag";
  constant PLATFORM_VARIANT_SRC_DIR     : string := PLATFORM_SRC_DIR & PLATFORM_VARIANT & "/";
  
  type rom_a is array (natural range <>) of string;
  constant GALAXIAN_ROM                 : rom_a(0 to 3) := 
                                          (
                                            0 => "zz_d1.7l", 
                                            1 => "zz_d2.7k",
                                            2 => "zz_d4.7f",
                                            3 => "zz_d3.7h"
                                          );
  constant GALAXIAN_ROM_WIDTHAD         : natural := 12;
  
  constant GALAXIAN_TILE_ROM            : rom_a(0 to 1) := 
                                          (
                                            0 => "zz_6.1h", 
                                            1 => "zz_5.1k"
                                          );
  constant GALAXIAN_TILE_ROM_WIDTHAD    : natural := 11;

  alias GALAXIAN_SPRITE_ROM             : rom_a(0 to 1) is GALAXIAN_TILE_ROM;
  alias GALAXIAN_SPRITE_ROM_WIDTHAD     : natural is GALAXIAN_TILE_ROM_WIDTHAD;
                                          
   -- null range
  constant GALAXIAN_EXTRA_ROM           : rom_a(0 to -1) := (others => "");
                                          
  -- (same as "galaxian")
  
  -- ROM $0000-$3FFF
  constant GALAXIAN_ROM_A         : std_logic_vector(15 downto 0) := "00--------------";
  -- WRAM $4000-$47FF
  constant GALAXIAN_WRAM_A        : std_logic_vector(15 downto 0) := X"4"&"0-----------";
  constant GALAXIAN_WRAM_WIDTHAD  : natural := 12;
  -- VRAM $5000-$57FF
  constant GALAXIAN_VRAM_A        : std_logic_vector(15 downto 0) := X"5"&"0-----------";
  -- CRAM $5800-$5BFF
  constant GALAXIAN_CRAM_A        : std_logic_vector(15 downto 0) := X"5"&"10----------";
  -- SPRITES/BULLETS $5840-$587F
  constant GALAXIAN_SPRITE_A      : std_logic_vector(15 downto 0) := X"58"&"01------";
  -- INPUTS $6000,$6800,$7000
  constant GALAXIAN_HAS_PIA8255   : boolean := false;
  constant GALAXIAN_INPUTS_A      : std_logic_vector(15 downto 0) := X"6000";
  constant GALAXIAN_INPUTS_INC    : std_logic_vector(15 downto 0) := X"0800";
  -- NMIENA $7001
  constant GALAXIAN_NMIENA_A      : std_logic_vector(15 downto 0) := X"7"&"---------001";
  
	-- Palette : Table of RGB entries	

	constant pal : pal_typ :=
	(
		1 => (0=>"111111", 1=>"000000", 2=>"111101"),
		2 => (0=>"000000", 1=>"110111", 2=>"111101"),
		3 => (0=>"111111", 1=>"111111", 2=>"000000"),
		5 => (0=>"011010", 1=>"011010", 2=>"111101"),
		6 => (0=>"110111", 1=>"000000", 2=>"111101"),
		7 => (0=>"000000", 1=>"111111", 2=>"000000"),
		9 => (0=>"000000", 1=>"110111", 2=>"111101"),
		10 => (0=>"101110", 1=>"010001", 2=>"000000"),
		11 => (0=>"111111", 1=>"011010", 2=>"000000"),
		13 => (0=>"110111", 1=>"110111", 2=>"111101"),
		14 => (0=>"110111", 1=>"000000", 2=>"000000"),
		15 => (0=>"111111", 1=>"000000", 2=>"000000"),
		17 => (0=>"001000", 1=>"010001", 2=>"101010"),
		18 => (0=>"111111", 1=>"000000", 2=>"000000"),
		19 => (0=>"110111", 1=>"110111", 2=>"111101"),
		21 => (0=>"000000", 1=>"110111", 2=>"111101"),
		22 => (0=>"110111", 1=>"111111", 2=>"111101"),
		23 => (0=>"111111", 1=>"000000", 2=>"000000"),
		25 => (0=>"000000", 1=>"111111", 2=>"000000"),
		26 => (0=>"111111", 1=>"000000", 2=>"000000"),
		27 => (0=>"110111", 1=>"111111", 2=>"111101"),
		29 => (0=>"111111", 1=>"000000", 2=>"000000"),
		30 => (0=>"111111", 1=>"111111", 2=>"000000"),
		31 => (0=>"110111", 1=>"111111", 2=>"111101"),
		others => (others => (others => '0'))
	);

end package platform_variant_pkg;
