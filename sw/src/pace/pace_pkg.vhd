library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

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

  -- Types

  type RGBType is record
    r : std_logic_vector(9 downto 0);
    g : std_logic_vector(9 downto 0);
    b : std_logic_vector(9 downto 0);
  end record;

  type RGBArrayType is array (natural range <>) of RGBType;

	type ByteArrayType is array (natural range <>) of std_logic_vector(7 downto 0);

	--
	-- JAMMA interface data structures
	-- - note: all signals are active LOW
	--

	type JAMMAPlayerInputsType is record
		start			: std_logic;
		up				: std_logic;
		down			: std_logic;
		left			: std_logic;
		right			: std_logic;
		button		: std_logic_vector(1 to 5);
	end record;

	type JAMMAPlayerInputsArrayType is array (natural range <>) of JAMMAPlayerInputsType;
	
	type JAMMAInputsType is record
		coin_cnt	: std_logic_vector(1 to 2);
		service		: std_logic;
		tilt			: std_logic;
		test			: std_logic;
		coin			: std_logic_vector(1 to 2);
		p					: JAMMAPlayerInputsArrayType(1 to 2);
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
	
	-- create a constant that automatically determines 
	-- whether this is simulation or synthesis
	constant in_simulation : BOOLEAN := false
	-- synthesis translate_off
	or true
	-- synthesis translate_on
	;
	constant in_synthesis : boolean := not in_simulation;
	
end;
