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

	constant PACE_VIDEO_NUM_BITMAPS		: natural := 2;
	constant PACE_VIDEO_NUM_TILEMAPS		: natural := 1;
	constant PACE_VIDEO_NUM_SPRITES		: natural := 0;
	constant PACE_VIDEO_H_SIZE				: integer := 32*8;
	constant PACE_VIDEO_V_SIZE				: integer := 16*10;
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

	constant TRS80_M1_CPU_CLK_ENA_DIVIDE_BY : natural := 
                integer(round(real(CLK0_FREQ_MHz) / CPU_FREQ_MHz));

	constant INCLUDE_FDC_SUPPORT			: boolean := false;

	type palette_entry_t is array (0 to 2) of std_logic_vector(7 downto 0);
	type palette_entry_a is array (0 to 15) of palette_entry_t;

	constant rgb_pal : palette_entry_a :=
	(
     2 => (0=>X"00", 1=>X"00", 2=>X"7F"),   -- Blue
     3 => (0=>X"00", 1=>X"00", 2=>X"FF"),   -- Light Blue
     4 => (0=>X"00", 1=>X"7F", 2=>X"00"),   -- Green
     5 => (0=>X"00", 1=>X"FF", 2=>X"00"),   -- Bright Green
     6 => (0=>X"00", 1=>X"7F", 2=>X"7F"),   -- Cyan
     7 => (0=>X"00", 1=>X"FF", 2=>X"FF"),   -- Turquoise
     8 => (0=>X"7F", 1=>X"00", 2=>X"00"),   -- Dark Red
     9 => (0=>X"FF", 1=>X"00", 2=>X"00"),   -- Red
    10 => (0=>X"7F", 1=>X"00", 2=>X"7F"),   -- Purple
    11 => (0=>X"FF", 1=>X"00", 2=>X"FF"),   -- Magenta
    12 => (0=>X"7F", 1=>X"7F", 2=>X"00"),   -- Lime
    13 => (0=>X"FF", 1=>X"FF", 2=>X"00"),   -- Yellow
    14 => (0=>X"BF", 1=>X"BF", 2=>X"BF"),   -- Off-White
    15 => (0=>X"FF", 1=>X"FF", 2=>X"FF"),   -- White
		others => (others => (others => '0'))
	);

	constant comp_pal : palette_entry_a :=
	(
     1 => (0=>X"80", 1=>X"80", 2=>X"80"),   -- Grey
     2 => (0=>X"00", 1=>X"00", 2=>X"FF"),   -- Blue
     3 => (0=>X"FF", 1=>X"FF", 2=>X"80"),   -- Light Yellow
     4 => (0=>X"00", 1=>X"FF", 2=>X"00"),   -- Green
     5 => (0=>X"FF", 1=>X"80", 2=>X"FF"),   -- Light Magenta
     6 => (0=>X"00", 1=>X"FF", 2=>X"FF"),   -- Cyan
     7 => (0=>X"FF", 1=>X"40", 2=>X"40"),   -- Light Red
     8 => (0=>X"FF", 1=>X"00", 2=>X"00"),   -- Red
     9 => (0=>X"00", 1=>X"80", 2=>X"80"),   -- Dark Cyan
    10 => (0=>X"FF", 1=>X"00", 2=>X"FF"),   -- Magenta
    11 => (0=>X"80", 1=>X"FF", 2=>X"80"),   -- Light Green
    12 => (0=>X"FF", 1=>X"FF", 2=>X"00"),   -- Yellow
    13 => (0=>X"00", 1=>X"00", 2=>X"80"),   -- Dark Blue
    14 => (0=>X"FF", 1=>X"FF", 2=>X"FF"),   -- White
		others => (others => (others => '0'))
	);
	
  type from_PLATFORM_IO_t is record

    sram_i              : from_SRAM_t;
    
    floppy_fifo_clk     : std_logic;
    floppy_fifo_data    : std_logic_vector(7 downto 0);
    floppy_fifo_wr      : std_logic;
    
    -- from the IDE device
    iordy0_cf           : std_logic;
    rdy_irq_cf          : std_logic;
    cd_cf               : std_logic;
    dd_i                : std_logic_vector(15 downto 0);
    dmarq_cf            : std_logic;

    -- expansion bus signals
    bus_d               : std_logic_vector(7 downto 0);
    bus_int_n           : std_logic;
    
  end record;

  type to_PLATFORM_IO_t is record
  
    sram_o              : to_SRAM_t;
    
    floppy_track        : std_logic_vector(7 downto 0);
    --floppy_offset       : std_logic_vector(12 downto 0);
    floppy_fifo_full    : std_logic;

    seg7                : std_logic_vector(15 downto 0);
    
    -- to the IDE device
    clk                 : std_logic;
    rst                 : std_logic;
    arst_n              : std_logic;
    a_cf                : std_logic_vector(2 downto 0);
    nce_cf              : std_logic_vector(2 downto 1);
    dd_o                : std_logic_vector(15 downto 0);
    dd_oe               : std_logic;
    nior0_cf            : std_logic;
    niow0_cf            : std_logic;
    non_cf              : std_logic;
    nreset_cf           : std_logic;
    ndmack_cf           : std_logic;
    -- to the SD core
    clk_25M             : std_logic;
    clk_50M             : std_logic;

    -- expansion bus signals
    bus_rst_n           : std_logic;
    bus_a               : std_logic_vector(7 downto 0);
    bus_d               : std_logic_vector(7 downto 0);
    bus_rd_n            : std_logic;
    bus_wr_n            : std_logic;
    
  end record;

end;
