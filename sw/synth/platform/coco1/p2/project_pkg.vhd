library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
	-- NTSC (x16)
  constant PACE_CLK0_DIVIDE_BY              : natural := 13;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 31;    -- 50*31/13 = 57M143Hz (57.23077)
  constant PACE_CLK1_DIVIDE_BY              : natural := 13;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 31;  	-- 50*31/13 = 57M143Hz (57.23077)
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;
	-- PAL (x16)
  --constant PACE_CLK0_DIVIDE_BY        : natural := 6;
  --constant PACE_CLK0_MULTIPLY_BY      : natural := 5;   	-- 24*5/6 = 20MHz
  --constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  --constant PACE_CLK1_MULTIPLY_BY      : natural := 3;  		-- 24*3/1 = 72MHz

	--constant PACE_VIDEO_H_SCALE         : integer := 2;
	--constant PACE_VIDEO_V_SCALE         : integer := 2;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

  -- P2-specific constants
  constant P2_JAMMA_IS_MAPLE          : boolean := false;
  constant P2_JAMMA_IS_NGC            : boolean := true;

  -- Coco1-specific constants

  constant COCO1_USE_REAL_6809              : boolean := true;
  --constant COCO1_BASIC_ROM                  : string := "bas10.hex";
  constant COCO1_BASIC_ROM                  : string := "bas11.hex";
  --constant COCO1_BASIC_ROM                  : string := "bas12.hex";
  --constant COCO1_EXTENDED_BASIC_ROM         : string := "extbas10.hex";
  constant COCO1_EXTENDED_BASIC_ROM         : string := "extbas11.hex";
  constant COCO1_EXTENDED_COLOR_BASIC       : boolean := false;
  constant COCO1_JUMPER_32K_RAM             : std_logic := '1';
	constant COCO1_CVBS                       : boolean := true;
	
	-- derived - do not edit
	constant COCO1_VGA                        : boolean := not COCO1_CVBS;
	constant PACE_ENABLE_ADV724					      : std_logic := to_std_logic(COCO1_CVBS);

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
