library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package platform_variant_pkg is

	--
	-- Platform-variant-specific constants (optional)
	--

	constant GOTTLIEB_VIDEO_L_CROP    : integer := 0;
	constant GOTTLIEB_VIDEO_R_CROP    : integer := 0;

  constant GOTTLIEB_NUM_ROMS        : natural := 5;
  constant PLATFORM_VARIANT         : string := "mplanets";
                                                
end;
