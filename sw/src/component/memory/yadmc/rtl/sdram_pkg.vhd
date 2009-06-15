library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package sdram_pkg is

  -- Types

	type from_SDRAM_t is record
		d					: std_logic_vector(31 downto 0);
		ack       : std_logic;
	end record;
	
	type to_SDRAM_t is record
    clk       : std_logic;
    rst       : std_logic;
		a					: std_logic_vector(31 downto 0);
		d					: std_logic_vector(31 downto 0);
		sel			  : std_logic_vector(3 downto 0);
		cyc			  : std_logic;
		stb			  : std_logic;
		we				: std_logic;
	end record;

end;
