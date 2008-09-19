library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET : PACETargetType := PACE_TARGET_P3M;

  constant PACE_CLKIN0        : natural := 24;
  constant PACE_CLKIN1        : natural := 0;

end;
