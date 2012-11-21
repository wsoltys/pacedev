library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 50MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  -- * defined in platform package
	--constant PACE_VIDEO_H_SIZE				        : integer := 512;
	--constant PACE_VIDEO_V_SIZE				        : integer := 192;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 2;   -- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 2;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 1;  	-- 50*1/2 = 25MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

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

	-- DE2 constants which *MUST* be defined
	
	constant DE2_LCD_LINE2							      : string := "   TRS80M3-VGA  ";
	--constant DE2_LCD_LINE2							      : string := "   TRS80M3-LCD  ";
		
	-- TRS-80-specific constants

  --constant TRS80_M1_ROM                     : string := "level1.hex";
  --constant TRS80_M1_ROM                     : string := "model1a.hex";    -- v1.2
  --constant TRS80_M1_ROM                     : string := "model1b.hex";    -- v1.3
  constant TRS80_M1_ROM                     : string := "m1v13_bartlett.hex";
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
  --constant TRS80_M1_LNW80_HIRES_WIDTHAD     : natural := 14;    -- 16KiB
  constant TRS80_M1_LNW80_HIRES_WIDTHAD     : natural := 12;    -- 4KiB
  constant TRS80_M1_HAS_PCG80               : boolean := (not TRS80_M1_IS_LNW80) and false;
  constant TRS80_M1_HAS_80GRAFIX            : boolean := (not TRS80_M1_IS_LNW80) and false;
  constant TRS80_M1_HAS_LE18                : boolean := (not TRS80_M1_IS_LNW80) and false;
  constant TRS80_M1_LE18_WIDTHAD            : natural := 14;    -- 16KiB
  --constant TRS80_M1_LE18_WIDTHAD            : natural := 13;    -- 8KiB (half-screen)
  constant TRS80_M1_FDC_SUPPORT             : boolean := true;
  constant TRS80_M1_HAS_MIKROKOLOR          : boolean := (not TRS80_M1_IS_LNW80) and true;
  constant TRS80_M1_HAS_HDD                 : boolean := true;
	
  -- derived: do not edit
  constant PACE_HAS_FLASH                   : boolean := TRS80_M1_ROM_IN_FLASH;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
