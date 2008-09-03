library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET      : PACETargetType := PACE_TARGET_DE1;

  constant PACE_FPGA_VENDOR : PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
  constant PACE_FPGA_FAMILY : PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE2;

  constant PACE_CLKIN0      : natural := 50;
  constant PACE_CLKIN1      : natural := 27;
  constant PACE_HAS_SPI     : boolean := false;

	--
	-- DE1-specific constants
	--

    
end;
