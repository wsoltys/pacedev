library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;

package pace_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

  type PACETargetType is
  (
    PACE_TARGET_NANOBOARD_NB1,
    PACE_TARGET_DE2,
    PACE_TARGET_P2,
    PACE_TARGET_P3M,
    PACE_TARGET_DE1,
    PACE_TARGET_RC10
  );

	type PACEFpgaVendor_t is
	(
		PACE_FPGA_VENDOR_ALTERA,
		PACE_FPGA_VENDOR_XILINX
	);

	type PACEFpgaFamily_t is
	(
		PACE_FPGA_FAMILY_CYCLONE1,
		PACE_FPGA_FAMILY_CYCLONE2,
		PACE_FPGA_FAMILY_SPARTAN3
	);

  type PACEJamma_t is
  (
    PACE_JAMMA_NONE,
    PACE_JAMMA_MAPLE,
    PACE_JAMMA_NGC
  );

  -- Types

	type ByteArrayType is array (natural range <>) of std_logic_vector(7 downto 0);

  -- maximums from the DE2 target

  constant PACE_NUM_SWITCHES  : natural := 18;
  subtype from_SWITCHES_t is std_logic_vector(PACE_NUM_SWITCHES-1 downto 0);
  
  constant PACE_NUM_BUTTONS   : natural := 4;
  subtype from_BUTTONS_t is std_logic_vector(PACE_NUM_BUTTONS-1 downto 0);
  
  constant PACE_NUM_LEDS      : natural := 18;
  subtype to_LEDS_t is std_logic_vector(PACE_NUM_LEDS-1 downto 0);
  
	--
	-- JAMMA interface data structures
	-- - note: all signals are active LOW
	--

	type from_JAMMA_player_t is record
		start			: std_logic;
		up				: std_logic;
		down			: std_logic;
		left			: std_logic;
		right			: std_logic;
		button		: std_logic_vector(1 to 5);
	end record;

	type from_JAMMA_player_a is array (natural range <>) of from_JAMMA_player_t;
	
	type from_JAMMA_t is record
		coin_cnt	: std_logic_vector(1 to 2);
		service		: std_logic;
		tilt			: std_logic;
		test			: std_logic;
		coin			: std_logic_vector(1 to 2);
		p					: from_JAMMA_player_a(1 to 2);
	end record;

  --
  -- INPUTS
  --
	type from_INPUTS_t is record
    ps2_kclk  : std_logic;
    ps2_kdat  : std_logic;
    ps2_mclk  : std_logic;
    ps2_mdat  : std_logic;
    jamma_n   : from_JAMMA_t;
  end record;
  
	--
	-- SRAM interface data structure
	--
	type from_SRAM_t is record
		d					: std_logic_vector(31 downto 0);
	end record;
	
	type to_SRAM_t is record
		a					: std_logic_vector(23 downto 0);
		d					: std_logic_vector(31 downto 0);
		be				: std_logic_vector(3 downto 0);
		cs				: std_logic;
		oe				: std_logic;
		we				: std_logic;
	end record;

  function NULL_TO_SRAM return to_SRAM_t;
	
	--
	-- FLASH interface data structure
	--
	type from_FLASH_t is record
		d					: std_logic_vector(7 downto 0);
	end record;
	
	type to_FLASH_t is record
		a					: std_logic_vector(21 downto 0);
		d					: std_logic_vector(7 downto 0);
		we				: std_logic;
		cs				: std_logic;
		oe				: std_logic;
	end record;

  type from_AUDIO_t is record
    clk       : std_logic;
  end record;
  
  type to_AUDIO_t is record
    clk       : std_logic;
    ldata     : std_logic_vector(15 downto 0);
    rdata     : std_logic_vector(15 downto 0);
  end record;
  
  type from_SPI_t is record
    din       : std_logic;
  end record;
  
  type to_SPI_t is record
    clk       : std_logic;
    mode      : std_logic;
    sel       : std_logic;
    ena       : std_logic;
    dout      : std_logic;
  end record;
  
  function NULL_TO_SPI return to_SPI_t;

  type to_SERIAL_t is record
    txd       : std_logic;
  end record;
  
  function NULL_TO_SERIAL return to_SERIAL_t;

  type from_SERIAL_t is record
    rxd       : std_logic;
  end record;
  
  constant PACE_NUM_GPI : natural := 32;
  subtype from_GP_t is std_logic_vector(PACE_NUM_GPI-1 downto 0);
  constant PACE_NUM_GPO : natural := 32;
  subtype to_GP_t is std_logic_vector(PACE_NUM_GPO-1 downto 0);

  function NULL_TO_GP return to_GP_t;
  
 	--
  -- OSD interface data structure
  --
  type from_OSD_t is record
    d         : std_logic_vector(7 downto 0);
  end record;

  function NULL_FROM_OSD return from_OSD_t;

  type to_OSD_t is record
    en        : std_logic;
    a         : std_logic_vector(7 downto 0);
    d         : std_logic_vector(7 downto 0);
    we        : std_logic;
  end record;

  function NULL_TO_OSD return to_OSD_t;

	-- create a constant that automatically determines 
	-- whether this is simulation or synthesis
	constant in_simulation : BOOLEAN := false
	-- synthesis translate_off
	or true
	-- synthesis translate_on
	;
	constant in_synthesis : boolean := not in_simulation;
	
end;
