library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_VIDEO_NUM_BITMAPS		: natural := 0;
	constant PACE_VIDEO_NUM_TILEMAPS		: natural := 1;
	constant PACE_VIDEO_NUM_SPRITES		: natural := 0;
--	constant PACE_VIDEO_H_SIZE				: integer := 480;
	constant PACE_VIDEO_H_SIZE				: integer := 64*6;
	constant PACE_VIDEO_V_SIZE				: integer := 192;
	constant PACE_VIDEO_L_CROP          : integer := 0;
	constant PACE_VIDEO_R_CROP          : integer := PACE_VIDEO_L_CROP;
	constant PACE_VIDEO_PIPELINE_DELAY  : integer := 5;
	constant PACE_INPUTS_NUM_BYTES      : integer := 9;
  
	--
	-- Platform-specific constants (optional)
	--
  constant CLK0_FREQ_MHz		            : integer := 
                PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : real := 1.77;

	constant MCE6309_CPU_CLK_ENA_DIVIDE_BY : natural := 
                integer(round(real(CLK0_FREQ_MHz) / CPU_FREQ_MHz));

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
