LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY sprom IS
	GENERIC
	(
		init_file		: string := "";
		numwords_a	: natural;
		widthad_a		: natural;
		width_a			: natural := 8
	);
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
	);
END sprom;


ARCHITECTURE SYN OF sprom IS

begin
END SYN;
