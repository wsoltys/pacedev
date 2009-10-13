library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET 				: PACETargetType := PACE_TARGET_CARTEBLANCHE_250;
	constant PACE_FPGA_VENDOR		: PACEFpgaVendor_t := PACE_FPGA_VENDOR_XILINX;
	constant PACE_FPGA_FAMILY		: PACEFpgaFamily_t := PACE_FPGA_FAMILY_SPARTAN3E;

  constant PACE_CLKIN0        : natural := 14;
  constant PACE_CLKIN1        : natural := 14;
  constant PACE_HAS_SDRAM     : boolean := false;
  constant PACE_HAS_FLASH     : boolean := false;

  type from_TARGET_IO_t is record
    not_used  : std_logic;
  end record;

  type to_TARGET_IO_t is record
    not_used  : std_logic;
  end record;

end;
