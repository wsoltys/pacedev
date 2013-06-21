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
  --constant PACE_HAS_FLASH                   : boolean := false;
  --constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
--  -- NTSC (315/88=3.579545MHz)
--  -- 16x = 57.272727MHz 
--  -- 24*105/44 = 57.272727MHz
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 50;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 21;    -- 24*50/21 = 57.142875MHz
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 5;
--  constant PACE_CLK1_DIVIDE_BY              : natural := 3;     -- 24*5/3 = 40MHz
  -- PAL (4.43361875MHz) 
  -- 16x = 70.9379MHZ
  -- 24*71/24 = 71MHz
  constant PACE_CLK0_MULTIPLY_BY            : natural := 71;
  constant PACE_CLK0_DIVIDE_BY              : natural := 24;    -- 24*71/24 = 71MHz
  constant PACE_CLK1_MULTIPLY_BY            : natural := 213;
  constant PACE_CLK1_DIVIDE_BY              : natural := 128;    -- 24*213/128 = 39.937500

  -- this will all go
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_VIDEO_H_SCALE       	      : integer := 1;
  constant PACE_VIDEO_V_SCALE       	      : integer := 1;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S5A-specific constants
  
  constant S5AR2_DOUBLE_VDO_IDCK            : boolean := false;
  
  -- 64KB of RAM
  constant S5AR2_EMULATE_SRAM               : boolean := true;
  constant S5AR2_EMULATED_SRAM_WIDTH_AD     : natural := 16;
  constant S5AR2_EMULATED_SRAM_WIDTH        : natural := 8;

  constant S5AR2_EMULATED_FLASH_INIT_FILE   : string := "";
  constant S5AR2_EMULATE_FLASH              : boolean := false;
  constant S5AR2_EMULATED_FLASH_WIDTH_AD    : natural := 14;
  constant S5AR2_EMULATED_FLASH_WIDTH       : natural := 8;

  constant S5AR2_HAS_FLOPPY_IF              : boolean := false;

  --
	-- Atari 800XL-specific constants
	--
	
  constant ATARI_REGION_NTSC                : boolean := false;
  constant ATARI_REGION_PAL                 : boolean := not ATARI_REGION_NTSC;
  
  -- derived (do not edit)
  constant PACE_HAS_SRAM                    : boolean := S5AR2_EMULATE_SRAM;
  constant PACE_HAS_FLASH                   : boolean := S5AR2_EMULATE_FLASH;
   
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
