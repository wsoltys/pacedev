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
  constant CPU_FREQ_MHz                 : natural := 2;  -- should be a "real" for 1.77MHz

	constant TRS80_M1_CPU_CLK_ENA_DIVIDE_BY : natural := CLK0_FREQ_MHz / CPU_FREQ_MHz;

	constant INCLUDE_FDC_SUPPORT			: boolean := false;
	
	  type from_PLATFORM_IO_t is record
  
    sram_i              : from_SRAM_t;
    
    floppy_fifo_clk     : std_logic;
    floppy_fifo_data    : std_logic_vector(7 downto 0);
    floppy_fifo_wr      : std_logic;
    
    -- from the HDD core
    hdd_cs              : std_logic;
    hdd_d               : std_logic_vector(7 downto 0);
    hdd_irq             : std_logic;

  end record;

  type to_PLATFORM_IO_t is record
  
    sram_o              : to_SRAM_t;
    
    floppy_track        : std_logic_vector(7 downto 0);
    --floppy_offset       : std_logic_vector(12 downto 0);
    floppy_fifo_full    : std_logic;

    seg7                : std_logic_vector(15 downto 0);
    
    -- to the HDD core
    clk                 : std_logic;
    rst                 : std_logic;
    arst_n              : std_logic;
    cpu_clk_ena         : std_logic;
    cpu_a               : std_logic_vector(15 downto 0);
    cpu_d_o             : std_logic_vector(7 downto 0);
    cpu_io_rd           : std_logic;
    cpu_io_wr           : std_logic;

  end record;

end;
