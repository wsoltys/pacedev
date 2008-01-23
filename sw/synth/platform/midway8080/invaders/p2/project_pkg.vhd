library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL								      : boolean := true;
	
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 24*1/1 = 24MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 5;  	-- 24*5/3 = 40MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  constant PACE_ENABLE_ADV724					      : std_logic := '0';

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 32;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 27;   	-- 24*27/32 = 20M25Hz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 16;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  		-- 24*9/16 = 13.5MHz
  --constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  --constant PACE_VIDEO_V_SCALE       	      : integer := 1;
  --constant PACE_ENABLE_ADV724					      : std_logic := '1';

	constant PACE_ADV724_STD						      : std_logic := ADV724_STD_PAL;

  --
  -- P2-specific constants
  --

  constant P2_JAMMA_IS_MAPLE                : boolean := false;
  constant P2_JAMMA_IS_NGC                  : boolean := true;

  --
	-- Space Invaders-specific constants
	--
	
	constant INVADERS_CPU_CLK_ENA_DIVIDE_BY		: natural := 12;
	constant INVADERS_1MHz_CLK0_COUNTS				: natural := 24;
	--constant INVADERS_CPU_CLK_ENA_DIVIDE_BY		: natural := 10;
	--constant INVADERS_1MHz_CLK0_COUNTS				: natural := 20;

	constant INVADERS_USE_INTERNAL_WRAM				: boolean := true;
	constant USE_VIDEO_VBLANK_INTERRUPT 			: boolean := false;
	
end;

--configuration cfg_TARGET_TOP of target_top is
--	for SYN
--		for pace_inst : PACE
--      for U_Graphics : Graphics
--        for vgacontroller_inst : pace_video_controller
--          use entity work.pace_video_controller(VGA_800X600_60HZ);
--        end for;
--      end for;
--		end for;
--	end for;
--end configuration cfg_TARGET_TOP;
