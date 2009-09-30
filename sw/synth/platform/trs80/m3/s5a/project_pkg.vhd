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
	
  -- Reference clock is 24.576MHz
	constant PACE_HAS_PLL								      : boolean := true;
  --constant PACE_HAS_SRAM                    : boolean := false;
  --constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  -- * defined in platform package
	--constant PACE_VIDEO_H_SIZE				        : integer := 512;
	--constant PACE_VIDEO_V_SIZE				        : integer := 192;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 75;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 61;    -- 24.576*61/75 = 19.988480MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 60;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 61;  	-- 24.576*61/60 = 24.985600MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 2;   -- 50*2/5 = 20MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 5;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 4;  	-- 50*4/5 = 40MHz
	--constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	--constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1024x768_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 32;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 13;    -- 50*13/32 = 20.3125MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 10;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 13;    -- 50*13/10 = 65MHz
	--constant PACE_VIDEO_H_SCALE       	      : integer := 2;
	--constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 128;
  constant PACE_OSD_YPOS                    : natural := 176;

  -- S5A-specific constants

  constant S5A_DE_GEN                       : std_logic := '0';
  constant S5A_VS_POL                       : std_logic := '0';
  constant S5A_HS_POL                       : std_logic := '0';
  constant S5A_DE_DLY                       : std_logic_vector(11 downto 0) := X"000";
  constant S5A_DE_TOP                       : std_logic_vector(7 downto 0) := X"00";
  constant S5A_DE_CNT                       : std_logic_vector(11 downto 0) := X"000";
  constant S5A_DE_LIN                       : std_logic_vector(11 downto 0) := X"000";

  constant S5A_EMULATE_SRAM                 : boolean := true;
  constant S5A_EMULATED_SRAM_WIDTH          : natural := 8;
  constant S5A_EMULATED_SRAM_WIDTH_AD       : natural := 16;

  constant S5A_EMULATE_FLASH                : boolean := true;
  constant S5A_EMULATED_FLASH_INIT_FILE     : string := "emulated_flash_init_file.hex";
  constant S5A_EMULATED_FLASH_WIDTH         : natural := 8;
  constant S5A_EMULATED_FLASH_WIDTH_AD      : natural := 16;

  constant PACE_HAS_SRAM                    : boolean := S5A_EMULATE_SRAM;
  constant PACE_HAS_FLASH                   : boolean := S5A_EMULATE_FLASH;
  
	-- TRS-80-specific constants
	
  constant TRS80_M3_ROM_IN_FLASH            : boolean := false;

  constant TRS80_M3_HIRES_SUPPORT           : boolean := false;
	constant TRS80_M3_HIRES_WIDTHA            : integer := 14;    -- 16KiB (Max 16KiB)

	constant TRS80_M3_FDC_SUPPORT			        : boolean := false;

  -- *** WARNING: must be false for S5A platform
  constant TRS80_M3_SYSMEM_IN_BURCHED_SRAM  : boolean := false;

  type from_PROJECT_IO_t is record
    dummy     : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    dummy     : std_logic;
  end record;

  --function NULL_TO_PROJECT_IO return to_PROJECT_IO_t;
  
end;
