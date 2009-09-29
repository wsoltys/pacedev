library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_VIDEO_NUM_BITMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
	constant PACE_VIDEO_H_SIZE				    : integer := 512;
	constant PACE_VIDEO_V_SIZE				    : integer := 192;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 5;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 9;
	
	--
	-- Platform-specific constants (optional)
	--

  type from_PLATFORM_IO_t is record
  
    sram_i              : from_SRAM_t;
    
    floppy_fifo_clk     : std_logic;
    floppy_fifo_data    : std_logic_vector(7 downto 0);
    floppy_fifo_wr      : std_logic;
    floppy_fifo_flush   : std_logic;
    
  end record;

  type to_PLATFORM_IO_t is record
  
    sram_o              : to_SRAM_t;
    
    floppy_track        : std_logic_vector(7 downto 0);
    floppy_offset       : std_logic_vector(12 downto 0);
    floppy_fifo_full    : std_logic;
    
  end record;

  --function NULL_TO_PLATFORM_IO return to_PLATFORM_IO_t;
  
end;
