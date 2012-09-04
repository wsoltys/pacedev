library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.target_pkg.all;
use work.project_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant M52_VIDEO_H_SIZE				      : integer := 256;
	constant M52_VIDEO_V_SIZE				      : integer := 256;
	
	constant PACE_VIDEO_NUM_BITMAPS		    : natural := 3;
	constant PACE_VIDEO_NUM_TILEMAPS	    : natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 64;
	constant PACE_VIDEO_H_SIZE				    : integer := M52_VIDEO_H_SIZE;
	constant PACE_VIDEO_V_SIZE				    : integer := M52_VIDEO_V_SIZE;
	constant PACE_VIDEO_L_CROP            : integer := 0;
	constant PACE_VIDEO_R_CROP            : integer := PACE_VIDEO_L_CROP;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 7;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 6;
	
	--
	-- Platform-specific constants (optional)
	--

  constant PLATFORM                     : string := "m52";
  constant PLATFORM_SRC_DIR             : string := "../../../../../src/platform/" & PLATFORM & "/";
  
	constant CLK0_FREQ_MHz		            : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : natural := 3;
  
	constant M52_CPU_CLK_ENA_DIVIDE_BY    : natural := CLK0_FREQ_MHz / CPU_FREQ_MHz;

	type pal_entry_typ is array (0 to 2) of std_logic_vector(5 downto 0);
	type pal_typ is array (0 to 31) of pal_entry_typ;

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
