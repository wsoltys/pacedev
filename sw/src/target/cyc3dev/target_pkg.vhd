library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET      : PACETargetType := PACE_TARGET_CYC3DEV;

  constant PACE_FPGA_VENDOR : PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
  constant PACE_FPGA_FAMILY : PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE3;

  constant PACE_CLKIN0      : natural := 50;
  constant PACE_CLKIN1      : natural := 125;
  --constant PACE_CLKIN2      : natural := 25;    -- enet
  constant PACE_HAS_SPI     : boolean := false;

	--
	-- CYC3DEV-specific constants
	--

    
  type from_TARGET_IO_t is record
    not_used  : std_logic;
  end record;

  type to_TARGET_IO_t is record
    not_used  : std_logic;
  end record;

end;
