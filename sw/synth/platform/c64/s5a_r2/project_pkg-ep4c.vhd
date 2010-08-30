library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  --constant S5AR2_DE_GEN                       : std_logic := '0';
  --constant S5AR2_VS_POL                       : std_logic := '0';
  --constant S5AR2_HS_POL                       : std_logic := '0';
  --constant S5AR2_DE_DLY                       : std_logic_vector(11 downto 0) := X"000";
  --constant S5AR2_DE_TOP                       : std_logic_vector(7 downto 0) := X"00";
  --constant S5AR2_DE_CNT                       : std_logic_vector(11 downto 0) := X"000";
  --constant S5AR2_DE_LIN                       : std_logic_vector(11 downto 0) := X"000";

  -- Need to manually generate DE on this platform
  -- - note that only NTSC (60Hz) mode is available on most monitors
  -- - so use constants for NTSC mode
  constant S5AR2_DE_GEN                       : std_logic := '1';
  constant S5AR2_VS_POL                       : std_logic := '0';
  constant S5AR2_HS_POL                       : std_logic := '0';
  constant S5AR2_DE_DLY                       : std_logic_vector(11 downto 0) := X"063";  -- 99
  --constant S5AR2_DE_DLY                       : std_logic_vector(11 downto 0) := X"0FF";  -- 255
  --constant S5AR2_DE_TOP                       : std_logic_vector(7 downto 0) := X"10";    -- 16
  constant S5AR2_DE_TOP                       : std_logic_vector(7 downto 0) := X"28";    -- 40
  --constant S5AR2_DE_CNT                       : std_logic_vector(11 downto 0) := X"350";  -- 848
  constant S5AR2_DE_CNT                       : std_logic_vector(11 downto 0) := X"280";  -- 640
  --constant S5AR2_DE_LIN                       : std_logic_vector(11 downto 0) := X"20C";  -- 262*2=524
  constant S5AR2_DE_LIN                       : std_logic_vector(11 downto 0) := X"1E0";  -- 480

end;
