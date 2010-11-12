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
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  constant PACE_CLK0_DIVIDE_BY              : natural := 44;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 105;   -- 24*105/44 = 57M272Hz
  constant PACE_CLK1_DIVIDE_BY              : natural := 44;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 105;  	-- 24*105/44 = 57M272Hz

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S5A-specific constants
  
  constant S5AR2_EMULATE_SRAM               : boolean := PACE_HAS_SRAM;
  constant S5AR2_EMULATED_SRAM_WIDTH_AD     : natural := 16;
  constant S5AR2_EMULATED_SRAM_WIDTH        : natural := 8;

	-- Coco1-specific constants

  constant COCO1_USE_REAL_6809              : boolean := false;
  
  --constant COCO1_MC6847_ROM                 : string := "mc6847_pal.hex";
  constant COCO1_MC6847_ROM                 : string := "mc6847_ntsc.hex";
  --constant COCO1_MC6847_ROM                 : string := "mc6847t1_pal.hex";
  --constant COCO1_MC6847_ROM                 : string := "mc6847t1_ntsc.hex";
  
  --constant COCO1_BASIC_ROM                  : string := "bas10.hex";
  constant COCO1_BASIC_ROM                  : string := "bas11.hex";
  --constant COCO1_BASIC_ROM                  : string := "bas12.hex";
  --constant COCO1_EXTENDED_BASIC_ROM         : string := "extbas10.hex";
  constant COCO1_EXTENDED_BASIC_ROM         : string := "extbas11.hex";
  constant COCO1_EXTENDED_COLOR_BASIC       : boolean := true;
  
  constant COCO1_CART_INTERNAL              : boolean := false;
  constant COCO1_CART_WIDTHAD               : integer := 13;
  constant COCO1_CART_NAME                  : string := "clowns.hex";     -- 8KB
  --constant COCO1_CART_NAME                  : string := "dod.hex";        -- 8KB
  --constant COCO1_CART_NAME                  : string := "galactic.hex";   -- 4KB
  --constant COCO1_CART_NAME                  : string := "megabug.hex";    -- 8KB
  --constant COCO1_CART_NAME                  : string := "nebula.hex";     -- 8KB

  constant COCO1_JUMPER_32K_RAM             : std_logic := '1';
	constant COCO1_CVBS                       : boolean := false;

  constant COCO1_HAS_IDE                    : boolean := false;
  
	-- derived - do not edit
  constant PACE_HAS_FLASH                   : boolean := not COCO1_CART_INTERNAL;
	constant COCO1_VGA                        : boolean := not COCO1_CVBS;
  
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
