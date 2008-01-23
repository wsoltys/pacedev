library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant DE2_JAMMA_IS_MAPLE	          : boolean := false;
	constant DE2_JAMMA_IS_NGC             : boolean := false;

	-- OCM-specific constants
	
  constant OCM_DIP_SLOT2_1              : std_logic := '0';
  constant OCM_DIP_SLOT2_0              : std_logic := '0';
  constant OCM_DIP_CPU_CLOCK            : std_logic := '0';
  constant OCM_DIP_DISK_ROM             : std_logic := '1';
  constant OCM_DIP_KEYBOARD             : std_logic := '1';
  constant OCM_DIP_RED_CINCH            : std_logic := '0';
  constant OCM_DIP_VGA_1                : std_logic := '1';
	constant OCM_DIP_VGA_0                : std_logic := '1';

end;
