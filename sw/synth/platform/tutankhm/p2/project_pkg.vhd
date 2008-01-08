library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								: boolean := true;
  constant PACE_CLK0_DIVIDE_BY        : natural := 4;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 5;   -- 24*5/4 = 30MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 5;  	-- 24*5/3 = 40MHz

	constant PACE_VIDEO_H_SCALE         : integer := 2;
	constant PACE_VIDEO_V_SCALE         : integer := 2;

	constant PACE_ENABLE_ADV724					: std_logic := '0';
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;

	-- Tutankham-specific constants

	constant TUTANKHAM_VRAM_WIDTHAD						: natural := 15;
	constant TUTANKHAM_ROMS_IN_SRAM						: boolean := true;			
	constant TUTANKHAM_CPU_CLK_ENA_DIVIDE_BY	: natural := 20;
	constant TUTANKHAM_1MHz_CLK0_COUNTS			  : natural := 30;
	
	constant USE_VIDEO_VBLANK_INTERRUPT 		  : boolean := false;
	
end;
