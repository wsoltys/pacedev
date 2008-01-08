library IEEE;
use IEEE.std_logic_1164.all;
--Use IEEE.std_logic_unsigned.all;
library work;

entity gc_tx_bit is
generic (
	MHZ		: natural	:= 50
);
port (
	clk       	: in std_logic;
	reset     	: in std_logic;

	data_avail	: in std_logic;
	din					: in std_logic;

	dnext				: out std_logic;
	dout				: out	std_logic;
	oe					: out std_logic
);
end gc_tx_bit;

--
--   -___-_----
--
--   IABCDABCDI
--   d ll  hh d
--   l oo  ii l
--   e        e

architecture rtl of gc_tx_bit is
	use work.conversion.to_vector;

	type state_type is (Idle, A, Blo, Bhi, Clo, Chi, D);
	
	constant clken_term	: integer := (MHZ*5000+4999)/4000;
	
	signal clken				: std_logic;
	
	signal next_state		: state_type;
	signal state				: state_type;

begin

	CLKEN_CNT: entity work.load_upcounter
		generic map( width => 9 )
		port map( clk => clk, reset => reset, en => '1', ld => clken, 
				  data => to_vector(9, -clken_term), tc => clken );

	dout <= '0' when state = A or state = Blo or state = Clo else '1';

	state_machine: process(state, data_avail, din) 
	begin
		next_state <= state;

		case state is
		when Idle =>
			if data_avail = '1' then
				next_state <= A;
			end if;

		when A =>		
			if din = '0' then 
				next_state <= Blo;
			else
				next_state <= Bhi;
			end if;
			
		when Blo =>		next_state <= Clo;
		when Bhi =>		next_state <= Chi;
		when Clo =>		next_state <= D;
		when Chi =>		next_state <= D;
		
		when D =>			
			if data_avail = '1' then
				next_state <= A;
			else
				next_state <= Idle;
			end if;
		end case;
	end process state_machine;

	regs: process(clk, reset) 
		variable rstate		: state_type;
		variable rstate_0	: state_type;
		variable roe			: std_logic;
	begin
		state <= rstate;
		oe <= roe;

		if reset = '1' then
			rstate := Idle;
			roe := '0';

		elsif rising_edge(clk) then
			dnext <= '0';
			if rstate_0 /= D and rstate = D then
				dnext <= '1';
			end if;
			
			rstate_0 := rstate;

			if clken = '1' then
				rstate := next_state;

				if next_state /= Idle then
					roe := '1';
				else
					roe := '0';
				end if;
			end if;
		end if;
	end process regs;
end rtl;
