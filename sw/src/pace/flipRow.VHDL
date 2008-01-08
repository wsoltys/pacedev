library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity flipRow is 
	generic
	(
		WIDTH		: natural := 32
	);
	port
	(
    rowIn   : in     std_logic_vector(WIDTH-1 downto 0);
    flip    : in     std_logic;
    rowOut  : out    std_logic_vector(WIDTH-1 downto 0)
	);
end flipRow;

architecture SYN of flipRow is

	constant HALF	: natural := (WIDTH / 2) - 1;

begin
    
	GEN_FLIP : for i in 0 to HALF generate
		rowOut((HALF-i)*2+1 downto (HALF-i)*2) <= rowIn(i*2+1 downto i*2) when flip = '1' else
																							rowIn((HALF-i)*2+1 downto (HALF-i)*2);
	end generate GEN_FLIP;

end SYN;



