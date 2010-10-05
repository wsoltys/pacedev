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
	constant PACE_HAS_PLL								      : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
	-- NTSC (x16)
  constant PACE_CLK0_DIVIDE_BY              : natural := 13;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 31;    -- 50*31/13 = 57M143Hz (57.23077)
  constant PACE_CLK1_DIVIDE_BY              : natural := 13;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 31;  	-- 50*31/13 = 57M143Hz (57.23077)
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_HAS_OSD                     : boolean := false;
  --constant PACE_OSD_XPOS                    : natural := 0;
  --constant PACE_OSD_YPOS                    : natural := 0;

	constant PACE_ADV724_STD						      : std_logic := ADV724_STD_PAL;

	-- A2601-specific constants

	constant A2601_CVBS                       : boolean := true;

  constant A2601_CART_NAME                  : string := "spcinvad.hex";     -- 4KB
  
	-- derived - do not edit
	constant A2601_VGA                        : boolean := not A2601_CVBS;
	constant PACE_ENABLE_ADV724					      : std_logic := to_std_logic(A2601_CVBS);

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
