library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.maple_pkg.all;

entity maple_joy is
	generic (
		MHZ				: natural := 48
	);
  port
  (
  	clk      	: in std_logic;                         --	48 MHz
		reset			: in std_logic;
		sense			: in std_logic;
		oe				: out std_logic;
		a					: inout std_logic;
		b					: inout std_logic;
		joystate	: out joystate_type
	);
end maple_joy;

architecture SYN of maple_joy is
begin
end SYN;
