library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET : PACETargetType := PACE_TARGET_DE1;

	constant DE2_JAMMA_IS_MAPLE	: boolean := false;
	alias DE2_JAMMA_IS_DREAMCAST : boolean is DE2_JAMMA_IS_MAPLE;

	constant DE2_JAMMA_IS_NGC : boolean := not DE2_JAMMA_IS_MAPLE;
	alias DE2_JAMMA_IS_GAMECUBE : boolean is DE2_JAMMA_IS_NGC;

	--
	-- DE2-specific constants
	--
	
	constant DE2_LCD_LINE1							: string := "   PACE  2007   ";		-- 16 chars exactly
	
end;
