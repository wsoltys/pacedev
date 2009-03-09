library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET        : PACETargetType := PACE_TARGET_COCO3PLUS;

  constant PACE_FPGA_VENDOR   : PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
  constant PACE_FPGA_FAMILY   : PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE3;

  constant PACE_CLKIN0        : natural := 50;
  constant PACE_CLKIN1        : natural := 27;
  constant PACE_HAS_SPI       : boolean := true;

	--
	-- COCO3PLUS-specific constants
	--

	-- ADV724 constants
	constant ADV724_STD_PAL		  : std_logic := '0';
	constant ADV724_STD_NTSC	  : std_logic := not ADV724_STD_PAL;
    
end;
