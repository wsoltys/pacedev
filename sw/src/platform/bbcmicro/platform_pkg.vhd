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
	
  constant PACE_PLATFORM_NAME           : string := "BBC Micro";

  constant PACE_INPUTS_NUM_BYTES        : integer := 17;

	constant CLK0_FREQ_MHz			          : natural := 
    PACE_CLKIN0 * PACE_CLK0_MULTIPLY_BY / PACE_CLK0_DIVIDE_BY;
  constant CPU_FREQ_MHz                 : natural := 1;

	constant BBCMICRO_CPU_CLK_ENA_DIVIDE_BY : natural := CLK0_FREQ_MHz / CPU_FREQ_MHz;

  --
	-- BBCMicro-specific constants (optional)
	--

	constant BBCMICRO_SRC_DIR							: string := "../../../../src/platform/bbcmicro";

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
