library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET : PACETargetType := PACE_TARGET_NANOBOARD_NB1;

	type NANOBOARD_PLL_INCLK_Type is (NANOBOARD_PLL_INCLK_REF,
																		NANOBOARD_PLL_INCLK_BRD);
																		
end;
