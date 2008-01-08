library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SSRAM is
	generic 
	(
		AddrWidth : natural;
		DataWidth : natural := 8
	);
	port 
	(
		Clk 		: in std_logic;
    CE_n 		: in std_logic;
    WE_n 		: in std_logic;
    A 			: in std_logic_vector(AddrWidth-1 downto 0);
    DIn 		: in std_logic_vector(DataWidth-1 downto 0);
    DOut 		: out std_logic_vector(DataWidth-1 downto 0)
	);
end SSRAM;

architecture SYN of SSRAM is
	signal we	: std_logic;
begin

	we <= not CE_n and not WE_n;
	
	ram_inst : entity work.spram
		generic map
		(
			numwords_a	=> 2**(AddrWidth),
			widthad_a		=> AddrWidth,
			width_a			=> DataWidth
		)
		port map
		(
			clock				=> Clk,
			address			=> A,
			wren				=> we,
			data				=> DIn,
			q						=> DOut
		);

end SYN;
