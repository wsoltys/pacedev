library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24.576MHz
	constant PACE_HAS_PLL								      : boolean := true;
  --constant PACE_HAS_FLASH                   : boolean := false;
  --constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  -- Reference clock is 24.576MHz
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  constant PACE_CLK0_DIVIDE_BY              : natural := 45;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 62;  		-- 24.576*62/45 = 33.860267MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 28;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 57;  		-- 24.576*57/28 = 50.029714Mhz

  -- S5A-specific constants
  
  -- Need to manually generate DE on this platform
  -- - note that only NTSC (60Hz) mode is available on most monitors
  -- - so use constants for NTSC mode
  constant S5A_DE_GEN                       : std_logic := '1';
  constant S5A_VS_POL                       : std_logic := '0';
  constant S5A_HS_POL                       : std_logic := '0';
  --constant S5A_DE_DLY                       : std_logic_vector(11 downto 0) := X"063";  -- 99
  constant S5A_DE_DLY                       : std_logic_vector(11 downto 0) := X"0FF";  -- 255
  constant S5A_DE_TOP                       : std_logic_vector(7 downto 0) := X"10";    -- 16
  --constant S5A_DE_CNT                       : std_logic_vector(11 downto 0) := X"350";  -- 848
  constant S5A_DE_CNT                       : std_logic_vector(11 downto 0) := X"280";  -- 640
  --constant S5A_DE_LIN                       : std_logic_vector(11 downto 0) := X"20C";  -- 262*2=524
  constant S5A_DE_LIN                       : std_logic_vector(11 downto 0) := X"1E0";  -- 480

  constant S5A_EMULATE_SRAM                 : boolean := true;
  constant S5A_EMULATED_SRAM_WIDTH          : natural := 8;
  constant S5A_EMULATED_SRAM_WIDTH_AD       : natural := 16;

  constant S5A_EMULATE_FLASH                : boolean := true;
  constant S5A_EMULATED_FLASH_INIT_FILE     : string := "emulated_flash_init_file.hex";
  constant S5A_EMULATED_FLASH_WIDTH         : natural := 8;
  constant S5A_EMULATED_FLASH_WIDTH_AD      : natural := 16;

  constant PACE_HAS_SRAM                    : boolean := S5A_EMULATE_SRAM;
  constant PACE_HAS_FLASH                   : boolean := S5A_EMULATE_FLASH;
  
	-- C64-specific constants

	constant C64_HAS_C64								      : boolean := true;
	constant C64_HAS_1541								      : boolean := true;
	constant C64_HAS_EXT_SB							      : boolean := false;
	constant C64_RESET_CYCLES						      : natural := 4095;

  -- inital video mode
  --constant INITIAL_NTSCMODE                 : std_logic := NTSCMODE_PAL;
  constant INITIAL_NTSCMODE                 : std_logic := NTSCMODE_NTSC;
  
	-- C64_HAS_C64 configuration
	constant C64_HAS_SID								      : boolean := true;

	-- C64_HAS_1541 configuration
	constant C64_1541_DEVICE_SELECT			      : std_logic_vector(3 downto 0) := X"8";
	-- 1541 early firmware
	--constant C64_1541_ROM_NAME					      : string := "325302-1_901229-03";
	-- 1541C firmware (track 0 sensor enabled)
	--constant C64_1541_ROM_NAME					      : string := "25196801";
	constant C64_1541_ROM_NAME					      : string := "25196802";

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
