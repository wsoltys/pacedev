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

	constant P3M_JAMMA_IS_MAPLE	: boolean := false;
	alias P3M_JAMMA_IS_DREAMCAST : boolean is P3M_JAMMA_IS_MAPLE;

	constant P3M_JAMMA_IS_NGC : boolean := false; --not P3M_JAMMA_IS_MAPLE;
	alias P3M_JAMMA_IS_GAMECUBE : boolean is P3M_JAMMA_IS_NGC;

end;
