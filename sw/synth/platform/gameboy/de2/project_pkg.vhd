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
	
  -- Reference clock is 50MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := true;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 19;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 16;    -- 50*16/19 = 42M105263Hz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 2;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 1; 	  -- 50*1/2 = 25MHz
--	constant PACE_VIDEO_H_SCALE       	      : integer := 2;
--	constant PACE_VIDEO_V_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 19;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 16;  -- 50*16/19 = 42.105263MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 5;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 4;   -- 50*4/5 = 40MHz
	constant PACE_VIDEO_H_SCALE               : integer := 2;
	constant PACE_VIDEO_V_SCALE               : integer := 2;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_LCM_320x240_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 32;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 27;    -- 50*27/32 = 42M187500Hz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 76;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 27; 	  -- 50*27/76 = 17M763158Hz
--	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
--	constant PACE_VIDEO_V_SCALE       	      : integer := 1;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';
  
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- DE2 constants which *MUST* be defined
  
	constant DE2_LCD_LINE2							      : string := " GAMEBOY (VGA)  ";

	-- GameBoy constants
	
  constant GAMEBOY_CART_IN_FLASH            : boolean := false;
  -- 32KB carts
  --constant GAMEBOY_CART_NAME                : string := "tetris10";
  constant GAMEBOY_CART_NAME                : string := "drmario10";
  constant GAMEBOY_CART_WIDTHAD             : natural := 15;
  -- 64KB carts
--  constant GAMEBOY_CART_NAME                : string := "sml11";
--  constant GAMEBOY_CART_WIDTHAD             : natural := 16;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
