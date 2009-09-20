library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24.576MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  -- Reference clock is 24.576MHz
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  constant PACE_CLK0_DIVIDE_BY              : natural := 96;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 125;  		-- 24.576*125/96 = 32MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 96;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 125;  		-- 24.576*125/96 = 32Mhz

  -- S5A-specific constants
  constant S5A_DE_GEN                       : std_logic := '1';
  constant S5A_VS_POL                       : std_logic := '0';
  constant S5A_HS_POL                       : std_logic := '0';
  --constant S5A_DE_DLY                       : std_logic_vector(11 downto 0) := X"063";  -- 99
  constant S5A_DE_DLY                       : std_logic_vector(11 downto 0) := X"0D5";  -- 213
  constant S5A_DE_TOP                       : std_logic_vector(7 downto 0) := X"28";    -- 40
  --constant S5A_DE_CNT                       : std_logic_vector(11 downto 0) := X"350";  -- 848
  constant S5A_DE_CNT                       : std_logic_vector(11 downto 0) := X"280";  -- 640
  constant S5A_DE_LIN                       : std_logic_vector(11 downto 0) := X"270";  -- 312*2=624???
  
	-- C64-specific constants

	constant C64_HAS_C64								      : boolean := true;
	constant C64_HAS_1541								      : boolean := false;
	constant C64_HAS_EXT_SB							      : boolean := false;
	constant C64_RESET_CYCLES						      : natural := 4095;

	-- C64_HAS_C64 configuration
	constant C64_HAS_SID								      : boolean := true;

	-- C64_HAS_1541 configuration
	constant C64_1541_DEVICE_SELECT			      : std_logic_vector(3 downto 0) := X"8";
	-- 1541 early firmware
	--constant C64_1541_ROM_NAME					      : string := "325302-1_901229-03";
	-- 1541C firmware (track 0 sensor enabled)
	--constant C64_1541_ROM_NAME					      : string := "25196801";
	constant C64_1541_ROM_NAME					      : string := "25196802";

end;