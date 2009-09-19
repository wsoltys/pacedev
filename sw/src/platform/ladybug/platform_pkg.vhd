library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;
use work.target_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	--constant PACE_VIDEO_NUM_BITMAPS 	: natural := 0;
	--constant PACE_VIDEO_NUM_TILEMAPS 	: natural := 1;
	--constant PACE_VIDEO_NUM_SPRITES 	: natural := 8;
	--constant PACE_VIDEO_H_SIZE				: integer := 256; -- technically 240
	--constant PACE_VIDEO_V_SIZE				: integer := 288;
	
	constant PACE_SRAM_DATA_WIDTH				: natural := 8;
	
	--
	-- Platform-specific constants (optional)
	--

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
