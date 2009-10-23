library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

	constant ROM_0_NAME		: string := "../../../../../src/platform/midway8080/invadpt2/roms/invadpt20.hex";
	constant ROM_1_NAME		: string := "../../../../../src/platform/midway8080/invadpt2/roms/invadpt21.hex";
	constant VRAM_NAME		: string := "../../../../../src/platform/midway8080/invaders/roms/sivram.hex";
	
end;
