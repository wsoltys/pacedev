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
	-- PAL
  --constant PACE_CLK0_DIVIDE_BY        : natural := 16;
  --constant PACE_CLK0_MULTIPLY_BY      : natural := 7;   	-- 24*7/16 = 10.5MHz (10.4832MHz)
  --constant PACE_CLK1_DIVIDE_BY        : natural := 8;
  --constant PACE_CLK1_MULTIPLY_BY      : natural := 7;  		-- 24*7/8 = 21MHz (used for scan doubler)
	-- NTSC
	constant PACE_HAS_PLL								: boolean := true;
  constant PACE_CLK0_DIVIDE_BY        : natural := 56;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 25;   	-- 24*25/56 = 10.714MHz (10.64448MHz)
  constant PACE_CLK1_DIVIDE_BY        : natural := 28;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 25;  	-- 24*25/28 = 21.428MHz (used for scan doubler)

	constant PACE_SRAM_DATA_WIDTH				: natural := 8;
	
	--constant PACE_ENABLE_ADV724					: std_logic := '1';
	--constant PACE_ADV724_STD						: std_logic := ADV724_STD_PAL;
	constant PACE_ADV724_STD						: std_logic := ADV724_STD_NTSC;

  -- P2-specific constants
  constant P2_JAMMA_IS_MAPLE          : boolean := false;
  constant P2_JAMMA_IS_NGC            : boolean := true;

	-- TRS-80-specific constants
	
	constant TRS_LEVEL1_INTERNAL				: boolean := false;
	constant TRS_EXTERNAL_ROM_RAM				: boolean := not TRS_LEVEL1_INTERNAL;

	constant TRS_VIDEO_VGA							: std_logic := '1';
	constant TRS_VIDEO_CVBS							: std_logic := not TRS_VIDEO_VGA;
	-- derived
	constant PACE_ENABLE_ADV724					: std_logic := TRS_VIDEO_CVBS;
		
	--constant TRS_ROM_FILENAME						: string := "trs_rom1.hex";
	constant TRS_ROM_FILENAME						: string := "trs_rom2.hex";
	--constant TRS_ROM_FILENAME						: string := "sys80_rom.hex";
	
end;
