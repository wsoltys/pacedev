library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	constant PACE_HAS_PLL                     : boolean := true;
	constant PACE_HAS_SRAM                    : boolean := false;
	constant PACE_HAS_FLASH                   : boolean := false;
	constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SPI                     : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
  -- Reference clock is 20MHz
	-- NTSC (x16)
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   	  -- 20*1/1 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 9;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 26;  	  -- 20*26/9 = ~57M272Hz
	-- PAL (x16)
  --constant PACE_CLK0_DIVIDE_BY        : natural := 6;
  --constant PACE_CLK0_MULTIPLY_BY      : natural := 5;   	-- 24*5/6 = 20MHz
  --constant PACE_CLK1_DIVIDE_BY        : natural := 1;
  --constant PACE_CLK1_MULTIPLY_BY      : natural := 3;  		-- 24*3/1 = 72MHz

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- NB1-specific constants that must be defined
  constant NB1_PLL_INCLK              			: NANOBOARD_PLL_INCLK_Type := NANOBOARD_PLL_INCLK_REF;
  constant NB1_INCLK0_INPUT_FREQUENCY 			: natural := 50000;   -- 20MHz
  constant PACE_CLKIN0                      : natural := PACE_CLKIN0_REF;

end;
