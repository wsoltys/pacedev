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
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 6;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 5;   -- 24*5/6 = 20MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 19;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 20; 	-- 24*20/19 = 25.263158MHz
--	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
--	constant PACE_VIDEO_V_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '0';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '0';
  
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 5;     -- 24*5/3 = 40MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 5;  	  -- 24*5/3 = 40MHz
	constant PACE_VIDEO_H_SCALE         		  : integer := 1;
	constant PACE_VIDEO_V_SCALE         		  : integer := 2;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1280x1024_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 96;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 157;     -- 24.675*157/96 = 40.192MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 11;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 48;  	  -- 24.576*48/11 = 107.24MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
--  constant PACE_ENABLE_ADV724					      : std_logic := '0';

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 8;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 9;   -- 24*9/8 = 27MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 16;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 9;		-- 24*9/16 = 13.5MHz
	--constant PACE_VIDEO_H_SCALE               : integer := 2;
	--constant PACE_VIDEO_V_SCALE               : integer := 1;
	--constant PACE_ENABLE_ADV724					      : std_logic := '1';
	--constant USE_VIDEO_VBLANK_INTERRUPT 		  : boolean := false;

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S5A-specific constants

  -- need 64KB of RAM for the TRS-80  
  constant S5AR2_EMULATE_SRAM               : boolean := true;
  constant S5AR2_EMULATED_SRAM_WIDTH_AD     : natural := 16;
  constant S5AR2_EMULATED_SRAM_WIDTH        : natural := 8;
  constant S5AR2_DOUBLE_VDO_IDCK            : boolean := false;
  
  constant S5AR2_EMULATED_FLASH_INIT_FILE   : string := "";
  constant S5AR2_EMULATE_FLASH              : boolean := false;
  constant S5AR2_EMULATED_FLASH_WIDTH_AD    : natural := 10;
  constant S5AR2_EMULATED_FLASH_WIDTH       : natural := 8;

  constant S5AR2_HAS_FLOPPY_IF              : boolean := true;

	-- TRS-80-specific constants

  --constant TRS80_M1_ROM                     : string := "level1.hex";
  --constant TRS80_M1_ROM                     : string := "model1a.hex";    -- v1.2
  constant TRS80_M1_ROM                     : string := "model1b.hex";    -- v1.3
  --constant TRS80_M1_ROM                     : string := "m1v13_bartlett.hex";
  --constant TRS80_M1_ROM                     : string := "sys80.hex";
  --constant TRS80_M1_ROM                     : string := "lnw80.hex";
  --constant TRS80_M1_ROM                     : string := "lnw80_bartlett.hex";

  -- original Model I, no arrow keys
  --constant TRS80_M1_CHARSET_ROM             : string := "trs80_m1_tile_0.hex";
  -- standard Model I, no lowercase
  --constant TRS80_M1_CHARSET_ROM             : string := "trs80_m1_tile_1.hex";
  -- replacement Model I with lowercase mod
  constant TRS80_M1_CHARSET_ROM             : string := "trs80_m1_tile_2.hex";
  --constant TRS80_M1_CHARSET_ROM             : string := "lnw_chr.hex";

  constant TRS80_M1_ROM_IN_FLASH            : boolean := false;

  constant TRS80_M1_IS_SYSTEM80             : boolean := (TRS80_M1_ROM = "sys80.hex");
  constant TRS80_M1_IS_LNW80                : boolean := (TRS80_M1_ROM(1 to 5) = "lnw80");
  constant TRS80_M1_LNW80_HIRES_WIDTHAD     : natural := 14;    -- 16KiB
  constant TRS80_M1_HAS_PCG80               : boolean := (not TRS80_M1_IS_LNW80) and false;
  constant TRS80_M1_HAS_80GRAFIX            : boolean := (not TRS80_M1_IS_LNW80) and false;
  constant TRS80_M1_HAS_LE18                : boolean := (not TRS80_M1_IS_LNW80) and false;
  constant TRS80_M1_LE18_WIDTHAD            : natural := 14;    -- 16KiB
  constant TRS80_M1_FDC_SUPPORT             : boolean := true;
  constant TRS80_M1_HAS_HDD                 : boolean := false;
  constant TRS80_M1_HAS_MIKROKOLOR          : boolean := (not TRS80_M1_IS_LNW80) and true;
	
	-- derived - do not edit

  constant PACE_HAS_SRAM                    : boolean := S5AR2_EMULATE_SRAM;
  constant PACE_HAS_FLASH                   : boolean := S5AR2_EMULATE_FLASH;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
