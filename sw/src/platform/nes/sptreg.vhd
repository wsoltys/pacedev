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
	signal bg				: std_logic;
	
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if wr = '1' then
				case addr is
					when "00" =>
						sptY <= '0' & din;
					when "01" =>
						sptNum <= "0000" & din;
					when "10" =>
						yFlip <= din(7);
						xFlip <= din(6);
						bg <= din(5);
						SptColour <= "000000" & din(1 downto 0);
					when others =>
						sptX <= din;
				end case;
			end if;
		end if;
	end process;
	
	sptFlags <= "00000" & bg & yFlip & xFlip;
	sptPri <= not bg;

end SYN;
