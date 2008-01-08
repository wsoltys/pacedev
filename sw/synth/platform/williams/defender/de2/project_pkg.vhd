library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  constant PACE_CLK0_DIVIDE_BY        : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY      : natural := 2;   -- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY        : natural := 5;
  constant PACE_CLK1_MULTIPLY_BY      : natural := 4;   -- 50*9/25 = 18MHz

	constant PACE_VIDEO_H_SCALE         : integer := 1;
	constant PACE_VIDEO_V_SCALE         : integer := 1;

	-- Defender constants
	
	constant DEFENDER_ROMS_IN_SRAM			: boolean := true;	
	constant DEFENDER_VRAM_WIDTHAD			: integer := 15;	-- 32kB
	
end;
