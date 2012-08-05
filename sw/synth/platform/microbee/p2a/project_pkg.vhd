library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

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
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := true;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 5;     -- 24*5/3 = 40MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 2;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 1;  	  -- 24*1/2 = 12MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	constant P2A_ADV724_STD						        : std_logic := ADV724_STD_PAL;
	constant P2A_ENABLE_ADV724					      : std_logic := '1';

	-- Microbee-specific constants

  -- VARIANTS

  constant MICROBEE_VARIANT                 : string := "mbee";
  
  type bios_a is array (natural range <>) of string;
  
  -- BIOSES

  -- BASIC 5.10
--  constant MICROBEE_BIOS                    : bios_a(0 to 3) := 
--                                              (
--                                                0 => "bas510a.ic25", 
--                                                1 => "bas510b.ic27",
--                                                2 => "bas510c.ic28",
--                                                3 => "bas510d.ic30"
--                                              );
--  constant MICROBEE_BIOS_WIDTHAD            : natural := 12;
                                                
  -- BASIC 5.22
  constant MICROBEE_BIOS                    : bios_a(0 to 1) := 
                                              (
                                                0 => "bas522a.rom", 
                                                1 => "bas522b.rom"
                                              );
  constant MICROBEE_BIOS_WIDTHAD            : natural := 13;
  
                                                        
	-- derived - do not edit

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
