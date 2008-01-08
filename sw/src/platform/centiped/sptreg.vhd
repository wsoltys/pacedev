Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity sptReg is

	generic
	(
		INDEX			: natural
	);
	port
	(
		clk				: in std_logic;
		wr				: in std_logic;
		din				: in std_logic_vector(7 downto 0);
		addr			: in std_logic_vector(1 downto 0);
		
		sptX			: out std_logic_vector(7 downto 0);
		sptY			: out std_logic_vector(8 downto 0);
		sptFlags	: out std_logic_vector(7 downto 0);
		sptColour	: out std_logic_vector(7 downto 0);
		sptNum 		: out std_logic_vector(11 downto 0);
		sptPri		: out std_logic
	);

end sptReg;

architecture SYN of sptReg is

	signal xFlip		: std_logic;
	signal yFlip		: std_logic;
	
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if wr = '1' then
				case addr is
					when "00" =>
						xFlip <= din(7);
						yFlip <= din(6);
						sptNum <= "000000" & din(0) & din(5 downto 1);
					when "01" =>
						sptX <= not din;
					when "10" =>
						sptY <= '0' & not din;
					when others =>
						SptColour <= din;
				end case;
			end if;
		end if;
	end process;
	
	sptFlags <= "000000" & yFlip & xFlip;
	sptPri <= '1';
	
end SYN;

