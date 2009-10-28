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

	constant PACE_VIDEO_NUM_BITMAPS 	    : natural := 0;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
	constant PACE_VIDEO_H_SIZE				    : integer := 512;
	constant PACE_VIDEO_V_SIZE				    : integer := 192;
  constant PACE_VIDEO_PIPELINE_DELAY    : integer := 5;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 9;
	
	--
	-- Platform-specific constants (optional)
	--

	constant CLK0_FREQ_MHz		            : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : natural := 2;
  
	constant TRS80_M3_CPU_CLK_ENA_DIVIDE_BY : natural := CLK0_FREQ_MHz / CPU_FREQ_MHz;

  type from_PLATFORM_IO_t is record
  
    sram_i              : from_SRAM_t;
    
    floppy_fifo_clk     : std_logic;
    floppy_fifo_data    : std_logic_vector(7 downto 0);
    floppy_fifo_wr      : std_logic;
    
  end record;

  type to_PLATFORM_IO_t is record
  
    sram_o              : to_SRAM_t;
    
    floppy_track        : std_logic_vector(7 downto 0);
    --floppy_offset       : std_logic_vector(12 downto 0);
    floppy_fifo_full    : std_logic;

    seg7                : std_logic_vector(15 downto 0);
    
  end record;

  --function NULL_TO_PLATFORM_IO return to_PLATFORM_IO_t;
  
end;
