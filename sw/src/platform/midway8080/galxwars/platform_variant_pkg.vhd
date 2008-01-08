library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

	constant ROM_1_NAME		: string := "../../../../../src/platform/midway8080/galxwars/roms/galxwars0.hex";
	constant ROM_2_NAME		: string := "../../../../../src/platform/midway8080/galxwars/roms/galxwars1.hex";
	constant VRAM_NAME		: string := "../../../../../src/platform/midway8080/invaders/roms/sivram.hex";
	
end;
