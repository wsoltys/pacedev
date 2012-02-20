library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 25MHz

  -- S5A-specific constants
  
  constant S5AR2_DE_GEN                     : std_logic := '0';
  constant S5AR2_VS_POL                     : std_logic := '0';
  constant S5AR2_HS_POL                     : std_logic := '0';
  constant S5AR2_DE_DLY                     : std_logic_vector(11 downto 0) := X"000";
  constant S5AR2_DE_TOP                     : std_logic_vector(7 downto 0) := X"00";
  constant S5AR2_DE_CNT                     : std_logic_vector(11 downto 0) := X"000";
  constant S5AR2_DE_LIN                     : std_logic_vector(11 downto 0) := X"000";

  constant S5AR2_HAS_PS2                    : boolean := true;
  
  --
	-- Space Invaders-specific constants
	--

end;
