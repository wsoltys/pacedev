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
	--constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := true;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;

  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 50*1/1 = 50MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 1;  	-- 50*1/1 = 50MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 128;
  constant PACE_OSD_YPOS                    : natural := 176;

  -- these really shouldn't be used - or defined - here
  -- - but worry about it later
  constant P2A_EUROSPI_CLK    : natural := 0;
  constant P2A_EUROSPI_MISO   : natural := 1;
  constant P2A_EUROSPI_MOSI   : natural := 2;
  constant P2A_EUROSPI_SS     : natural := 3;

  constant COCO3_ROMS_IN_FLASH              : boolean := true;
  -- derived - do not edit
	constant PACE_HAS_FLASH                   : boolean := COCO3_ROMS_IN_FLASH;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
