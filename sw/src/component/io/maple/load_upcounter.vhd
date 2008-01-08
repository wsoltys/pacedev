library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity load_upcounter is generic( width : integer );
port (
	clk		: in  std_logic;
	reset	: in  std_logic;
	en		: in  std_logic;
	ld		: in  std_logic;
	data	: in  std_logic_vector(width-1 downto 0);
	cnt		: out std_logic_vector(width-1 downto 0);
	tc		: out std_logic
);
end load_upcounter;

architecture rtl of load_upcounter is
	--use work.conversion.to_vector;

	constant cnt_max		: std_logic_vector(width-1 downto 0) := (others => '1');
--	constant one		: std_logic_vector(width downto 0) := (0 => '1', others => '0');
	signal Q				: std_logic_vector(width-1 downto 0);
--	signal Q_plus_1	: std_logic_vector(width downto 0);
begin
	cnt <= Q;
--	tc <= en and not ld and Q_plus_1(width);

--	Q_plus_1 <= ('0' & Q) + one;

	tc <= '1' when Q = cnt_max else '0';
		
	process (clk, reset)
	begin
		if reset = '1' then
			Q <= (others => '0');
		elsif rising_edge(clk) then
			if ld = '1' then
				Q <= data;
			elsif en = '1' then
				Q <= Q + 1;
			end if;
		end if;
	end process;
end;
