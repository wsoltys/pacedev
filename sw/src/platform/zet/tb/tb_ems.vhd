library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy_mem is
	port (
		clk				: in std_logic;
    addr			: in std_logic_vector(15 downto 0);
    data			: out std_logic_vector(15 downto 0)
	);
end dummy_mem;

architecture SIM of dummy_mem is
begin
	process (addr)
	begin
	  data <= addr(15 downto 0) after 12 ns; -- 12ns SRAM
	end process;
end SIM;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ems is
	port (
		fail:				out  boolean := false
	);
end entity tb_ems;

architecture SYN of tb_ems is

	signal clk						: std_logic_vector(0 to 3)	:= (others => '0');
	signal reset					: std_logic	:= '1';
                    		
begin

	-- Generate CLK and reset
  clk(0) <= not clk(0) after 7.575757 ns; -- 66MHz
	reset <= '0' after 15 ns;

end SYN;
