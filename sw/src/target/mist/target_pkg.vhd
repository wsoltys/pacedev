library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
constant PACE_TARGET      : PACETargetType := PACE_TARGET_MIST;
constant PACE_FPGA_VENDOR : PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
constant PACE_FPGA_FAMILY : PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE3;

constant PACE_CLKIN0      : natural := 27;
constant PACE_HAS_SPI     : boolean := false;

	--
	-- MiST-specific
	--
  type from_TARGET_IO_t is record
    q	        : std_logic_vector(7 downto 0);
  end record;

  type to_TARGET_IO_t is record
    a					: std_logic_vector(14 downto 0);
		clk       : std_logic;
  end record;
  
 end;
