library ieee;
use ieee.std_logic_1164.all;

library work;
use work.target_pkg.all;
use work.project_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 9;
	
  -- depends on build or simulation
  constant COCO1_SOURCE_ROOT_DIR  : string;

	--
	-- Platform-specific constants (optional)
	--

  type from_PLATFORM_IO_t is record
    -- to connect to real 6809
    cpu_6809_r_wn     : std_logic;
    cpu_6809_busy     : std_logic;
    cpu_6809_lic      : std_logic;
    cpu_6809_vma      : std_logic;
    cpu_6809_a        : std_logic_vector(15 downto 0);
    cpu_6809_d_o      : std_logic_vector(7 downto 0);
  end record;

  type to_PLATFORM_IO_t is record
    arst              : std_logic;
    clk_cpld          : std_logic;
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
