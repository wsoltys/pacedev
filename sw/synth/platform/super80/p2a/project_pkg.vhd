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
--  constant PACE_CLK1_DIVIDE_BY        		  : natural := 3;
--  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 5;     -- 24*5/3 = 40MHz
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

	-- Super-80-specific constants

  -- monochrome colours taken from the RGB palette
  constant SUPER80_MONOCHROME_FG_COLOUR_I   : integer range 0 to 15 := 5;   -- bright green
  constant SUPER80_MONOCHROME_BG_COLOUR_I   : integer range 0 to 15 := 0;   -- black

  -- VARIANTS/BIOSes

--  -- V1.2
--  constant SUPER80_VARIANT                  : string := "super80";
--  constant SUPER80_BIOS_C000                : string := "super80";        -- V1.2
--  constant SUPER80_BIOS_D000                : string := SUPER80_BIOS_C000;
--  constant SUPER80_BIOS_E000                : string := SUPER80_BIOS_C000;
  
  -- V2.2
--  constant SUPER80_VARIANT                  : string := "super80d";
--  constant SUPER80_BIOS_C000                : string := "super80d";       -- V2.2
--  --constant SUPER80_BIOS_C000                : string := "super80f";       -- MDS (original)
--  --constant SUPER80_BIOS_C000                : string := "super80g";       -- MDS (upgraded)
--  constant SUPER80_BIOS_D000                : string := "super80";
--  constant SUPER80_BIOS_E000                : string := "super80";

--  -- El Grafix 4
--  constant SUPER80_VARIANT                  : string := "super80e";
--  constant SUPER80_BIOS_C000                : string := "super80e";       -- MDS (original)
--  constant SUPER80_BIOS_D000                : string := "super80";
--  constant SUPER80_BIOS_E000                : string := "super80";

--  -- With Colour
--  constant SUPER80_VARIANT                  : string := "super80m";
--  constant SUPER80_BIOS_C000                : string := "s80-8r0";        -- v3.8r0
----  constant SUPER80_BIOS_C000                : string := "s80-v37";        -- v3.7
--  constant SUPER80_BIOS_D000                : string := SUPER80_BIOS_C000;
--  constant SUPER80_BIOS_E000                : string := SUPER80_BIOS_C000;

  -- With VDUEB
  constant SUPER80_VARIANT                  : string := "super80r";
  constant SUPER80_BIOS_C000                : string := "super80r";       -- MCE (original)
  --constant SUPER80_BIOS_C000                : string := "super80s";       -- MCE (upgraded)
  constant SUPER80_BIOS_D000                : string := "super80";
  constant SUPER80_BIOS_E000                : string := "super80";

--  -- With Enhanced VDUEB
--  constant SUPER80_VARIANT                  : string := "super80v";
--  constant SUPER80_BIOS_C000                : string := "s80-v37v";
--  constant SUPER80_BIOS_D000                : string := SUPER80_BIOS_C000;
--  constant SUPER80_BIOS_E000                : string := SUPER80_BIOS_C000;
  
  -- Chipspeed colour board
  constant SUPER80_HAS_CHIPSPEED_COLOUR     : boolean := (SUPER80_VARIANT = "super80m" or 
                                                            SUPER80_VARIANT = "super80v") 
                                                          and true;
  constant SUPER80_CHIPSPEED_RGB            : boolean := SUPER80_HAS_CHIPSPEED_COLOUR and true;
  -- derived (do not edit)
  constant SUPER80_CHIPSPEED_COMPOSITE      : boolean := SUPER80_HAS_CHIPSPEED_COLOUR and 
                                                          not SUPER80_CHIPSPEED_RGB;

  -- derived (do not edit)
  constant SUPER80_HAS_VDUEB                : boolean := (SUPER80_VARIANT = "super80r" or 
                                                            SUPER80_VARIANT = "super80v");
                                                        
	-- derived - do not edit
	constant P2A_ENABLE_ADV724					      : std_logic := to_std_logic(SUPER80_HAS_VDUEB);

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
