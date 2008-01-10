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

	--
	-- DE2-specific constants
	--
	
	constant DE1_LCD_LINE1							: string := "   PACE  2008   ";		-- 16 chars exactly
	
end;
