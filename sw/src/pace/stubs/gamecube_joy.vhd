library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.gamecube_pkg.all;

entity gamecube_joy is
	generic (
		MHZ				: natural := 50
	);
  port (
  	clk      	: in std_logic;
		reset			: in std_logic;
		oe				: out std_logic;
		d					: inout std_logic;
		joystate	: out joystate_type
	);
end gamecube_joy;

architecture SYN of gamecube_joy is
	begin
end;
