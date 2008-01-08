library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity maple_write_tb is
end maple_write_tb;

architecture rtl of maple_write_tb is
	constant	tCYC	:	time := 20833 ps;

	signal	clk		:	std_logic;
	signal	reset	:	std_logic;
	signal	data	:	std_logic_vector(7 downto 0);
	signal	datastb	:	std_logic;
	signal	eof		:	std_logic;
	signal	busy	:	std_logic;
	signal	m_out	:	std_logic_vector(1 downto 0);

	signal rsync	: std_logic;
	signal rdrdy 	: std_logic;
	signal reof		: std_logic;
	signal d_out	: std_logic_vector(7 downto 0);

begin

	maple_rd : entity work.maple_read
		port map( clk => clk, reset => reset, a => m_out(0), b => m_out(1), 
				  sync => rsync, eof => reof, d => d_out,
				  d_rdy => rdrdy );

	maple_wr : entity work.maple_write
		port map( clk => clk, reset => reset, data_in => data, datastb => datastb, 
				  eof => eof, busy => busy, m_out => m_out );

	clock_gen : process (clk)
	begin
		if clk = '0' then
			clk <= '1' after tCYC/2;
		else
			clk <= '0' after tCYC/2;
		end if;
	end process clock_gen ;

	tb : process
	begin
		reset <= '1';
		eof <= '0';
		datastb <= '0';
		data <= X"FF";
		wait for 5 * tCYC;
		reset <= '0';
		wait for 2 * tCYC;
		data <= X"01";
		datastb <= '1';
		wait for 1 * tCYC;
		data <= X"FF";
		datastb <= '0';
		wait until busy = '0';
		data <= X"55";
		datastb <= '1';
		wait for 1 * tCYC;
		data <= X"FF";
		datastb <= '0';
		wait until busy = '0';
		eof <= '1';
		wait for 1 * tCYC;
		eof <= '0';
		wait for 500 * tCYC;

		wait;
	end process tb;

end rtl;

