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

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
--  constant PACE_CLK0_DIVIDE_BY        		  : natural := 1;
--  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 1;     -- 24*1/1 = 24MHz
--  constant PACE_CLK1_DIVIDE_BY        		  : natural := 3;
--  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 5;  	  -- 24*5/3 = 40MHz
--	constant PACE_VIDEO_H_SCALE         		  : integer := 2;
--	constant PACE_VIDEO_V_SCALE         		  : integer := 2;
--	constant PACE_ENABLE_ADV724							  : std_logic := '0';
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1024x768_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 5;       -- 24*5/3 = 40MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 24;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 65;  	  -- 24*65/24 = 65MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
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
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 8;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 9;   -- 24*9/8 = 27MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 16;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 9;		-- 24*9/16 = 13.5MHz
--	constant PACE_VIDEO_H_SCALE               : integer := 2;
--	constant PACE_VIDEO_V_SCALE               : integer := 1;
--	constant PACE_ENABLE_ADV724					      : std_logic := '1';
--	constant USE_VIDEO_VBLANK_INTERRUPT 		  : boolean := false;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';
  
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S6M-specific constants
  
  constant S6M_DE_GEN                       : std_logic := '0';
  constant S6M_VS_POL                       : std_logic := '0';
  constant S6M_HS_POL                       : std_logic := '0';
  constant S6M_DE_DLY                       : std_logic_vector(11 downto 0) := X"000";
  constant S6M_DE_TOP                       : std_logic_vector(7 downto 0) := X"00";
  constant S6M_DE_CNT                       : std_logic_vector(11 downto 0) := X"000";
  constant S6M_DE_LIN                       : std_logic_vector(11 downto 0) := X"000";

  constant S6M_HAS_PS2                      : boolean := false;
  
  constant S6M_DOUBLE_VDO_IDCK              : boolean := false;
  
  constant S6M_EMULATED_SRAM_WIDTH_AD       : natural := 16;
  constant S6M_EMULATED_SRAM_WIDTH          : natural := 8;
  constant S6M_HAS_FLOPPY_IF                : boolean := false;
  
	-- Pacman-specific constants
			
	constant PACMAN_ROM_IN_SRAM               : boolean := false;
	constant PACMAN_USE_VIDEO_VBLANK          : boolean := true;
	constant PACMAN_USE_INTERNAL_WRAM				  : boolean := true;

  constant S6M_EMULATE_FLASH                : boolean := false;
  constant S6M_EMULATED_FLASH_INIT_FILE     : string := "";
  constant S6M_EMULATED_FLASH_WIDTH_AD      : natural := 10;
  constant S6M_EMULATED_FLASH_WIDTH         : natural := 8;
  
	-- derived - do not edit

  constant S6M_EMULATE_SRAM                 : boolean := PACMAN_ROM_IN_SRAM or 
                                                          not PACMAN_USE_INTERNAL_WRAM;
  constant PACE_HAS_FLASH                   : boolean := S6M_EMULATE_FLASH;
  constant PACE_HAS_SRAM                    : boolean := S6M_EMULATE_SRAM;
	
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
