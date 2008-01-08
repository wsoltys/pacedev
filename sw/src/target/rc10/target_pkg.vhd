library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET 				: PACETargetType := PACE_TARGET_RC10;
	constant PACE_FPGA_VENDOR		: PACEFpgaVendor_t := PACE_FPGA_VENDOR_XILINX;
	constant PACE_FPGA_FAMILY		: PACEFpgaFamily_t := PACE_FPGA_FAMILY_SPARTAN3;

	constant P2_JAMMA_IS_MAPLE	: boolean := false;
	alias P2_JAMMA_IS_DREAMCAST : boolean is P2_JAMMA_IS_MAPLE;

	constant P2_JAMMA_IS_NGC : boolean := false;
	alias P2_JAMMA_IS_GAMECUBE : boolean is P2_JAMMA_IS_NGC;

end;
