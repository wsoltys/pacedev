library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET 				: PACETargetType := PACE_TARGET_SWEET_VEC;
	constant PACE_FPGA_VENDOR		: PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
	constant PACE_FPGA_FAMILY		: PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE2;

  constant PACE_CLKIN0        : natural := 24;
  constant PACE_CLKIN1        : natural := 24;
  --constant PACE_HAS_FLASH     : boolean := false; -- can be emulated
  --constant PACE_HAS_SRAM      : boolean := false; -- can be emulated

  type from_TARGET_IO_t is record
    dummy								: std_logic;
  end record;

  type to_TARGET_IO_t is record
    dummy								: std_logic;
  end record;

  --function NULL_TO_TARGET_IO return to_TARGET_IO_t;
  
end;
