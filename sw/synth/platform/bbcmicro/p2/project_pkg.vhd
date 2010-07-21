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
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL										  : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_CLK0_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 4;   -- 24*4/3 = 32MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 4;  	-- 24*4/3 = 32MHz

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- P2-specific constants

	constant PACE_ENABLE_ADV724							  : std_logic := '1';
	constant PACE_ADV724_STD								  : std_logic := ADV724_STD_PAL;

	-- BBC-specific constants

  constant BBC_RAM_32K                      : std_logic := '1';
  constant BBC_RAM_16K                      : std_logic := not BBC_RAM_32K;

  -- startup link options (on keyboard PCB)
  constant BBC_STARTUP_OPT_NOT_USED         : std_logic_vector(1 downto 0) := "11";
  constant BBC_STARTUP_OPT_DISK_SPEED       : std_logic_vector(1 downto 0) := "11";
  constant BBC_STARTUP_OPT_SHIFT_BREAK      : std_logic := '1';
  constant BBC_STARTUP_OPT_MODE             : std_logic_vector(2 downto 0) := "110"; -- MODE 6

	constant BBC_1MHz_CLK0_COUNTS				      : natural := 32;

  constant BBC_USE_INTERNAL_RAM             : boolean := false;

  -- implementation options

  constant BBC_USE_T65                      : boolean := true;
  constant BBC_USE_65XX                     : boolean := not BBC_USE_T65;

  constant BBC_USE_ROCKOLA_6845             : boolean := true;
  constant BBC_USE_OC_6845                  : boolean := not BBC_USE_ROCKOLA_6845;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
