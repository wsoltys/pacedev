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

  constant PACE_PLATFORM_NAME           : string := "Tutankham";

	constant PACE_VIDEO_NUM_BITMAPS 	    : natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	    : natural := 0;		-- used for video counter only
	constant PACE_VIDEO_NUM_SPRITES 	    : natural := 0;
	constant PACE_VIDEO_H_SIZE				    : integer := 224;
	constant PACE_VIDEO_V_SIZE				    : integer := 256;
	constant PACE_VIDEO_PIPELINE_DELAY    : integer := 3;
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 4;
	
	--
	-- Platform-specific constants (optional)
	--

	constant CLK0_FREQ_MHz		            : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  --constant CPU_FREQ_MHz                 : natural := 1.5;
  
	constant TUTANKHAM_CPU_CLK_ENA_DIVIDE_BY	: natural := 
    CLK0_FREQ_MHz * 2 / 3;

  constant TUTANKHAM_SOURCE_ROOT_DIR        : string;

  type from_PLATFORM_IO_t is record
    clk_1M5_en        : std_logic;
    -- to connect to real 6809
    cpu_6809_r_wn     : std_logic;
    cpu_6809_vma      : std_logic;
    cpu_6809_a        : std_logic_vector(15 downto 0);
    cpu_6809_d_o      : std_logic_vector(7 downto 0);
  end record;

  type to_PLATFORM_IO_t is record
    arst              : std_logic;
    clk_50M           : std_logic;
    button            : std_logic_vector(3 downto 0);
    -- to connect to real 6809
    cpu_6809_q        : std_logic;
    cpu_6809_e        : std_logic;
    cpu_6809_rst_n    : std_logic;
    cpu_6809_d_i      : std_logic_vector(7 downto 0);
    cpu_6809_halt_n   : std_logic;
    cpu_6809_irq_n    : std_logic;
    cpu_6809_firq_n   : std_logic;
    cpu_6809_nmi_n    : std_logic;
    cpu_6809_tsc      : std_logic;
  end record;

end;
