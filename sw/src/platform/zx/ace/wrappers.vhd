library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity ace_rom is
	port 
	(
		Clk	: in std_logic;
		A	: in std_logic_vector(12 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end ace_rom;

architecture SYN of ace_rom is
begin

	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/zx/ace/roms/acerom.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13
		)
		port map
		(
			clock				=> Clk,
			address			=> A,
			q						=> D
		);
		
end SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

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
