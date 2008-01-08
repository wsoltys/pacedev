library IEEE;
use IEEE.std_logic_1164.all;
--Use IEEE.std_logic_unsigned.all;
library work;

entity maple_write is
generic (
	MHZ		: natural	:= 48
);
port
(
	clk         : in    std_logic;
	reset       : in    std_logic;

	data_in		: in	std_logic_vector(7 downto 0);
	datastb		: in	std_logic;
	eof			: in	std_logic;

	busy		: out	std_logic;
	m_out		: out	std_logic_vector(1 downto 0);
	m_oe		: out std_logic
);
end maple_write;

--
--   --_____________----______-.._------__-__--
--   ---__-__-__-__---____--___.._____-_______-
--
--   I SSSSSSSSSSSSSSSDDDDDDDDD  DDDD EEEEEEEEI
--   d yyyyyyyyyyyyyyyaaaaaaaaa  aWWW ooooooood
--   l nnnnnnnnnnnnnnnttttttttt  taaa ffffffffl
--   e cccccccccccccccaaaaaaaaa  aiii SABBABBAe
--     ABBABBABBABBACCAAAABBBBA  Bttt
--                     LLL LLL   L
--                     ooo ooo   o
--                     011 011   1
--

architecture rtl of maple_write is
	use work.conversion.to_vector;

	type state_type is (Idle, SyncA, SyncB, SyncC, DataA, DataALo0,
		DataALo1, DataAHi0, DataAHi1, DataB, DataBLo0, DataBLo1,
		DataBHi0, DataBHi1, DataWait,
		EofS, EofA, EofB);
	
	signal c_exp, c_en, c_ld	: std_logic;
	signal c_data				: std_logic_vector(4 downto 0);
	signal c_dsel_125, c_dsel_250, c_dsel_500	: std_logic;
	signal s_exp_i, s_en, s_ld	: std_logic;
	signal s_exp				: std_logic;		-- s_exp is pipelined 1 clock to increase fwax
	signal data					: std_logic_vector(7 downto 0);
	signal m					: std_logic_vector(1 downto 0);
	signal d_bit				: std_logic;
	signal d_shift				: std_logic;

	signal e_exp, e_en, e_ld	: std_logic;
	
	signal next_state			: state_type;
	signal state				: state_type;

begin

	CNT: entity work.load_upcounter
		generic map( width => 5 )
		port map( clk => clk, reset => reset, en => c_en, ld => c_ld, 
				  data => c_data, tc => c_exp );
	SCNT: entity work.load_upcounter
		generic map( width => 3 )
		port map( clk => clk, reset => reset, en => s_en, ld => s_ld, 
				  data => "011", --to_vector(3, -3), 
				  tc => s_exp_i );
	ECNT: entity work.load_upcounter
		generic map( width => 2 )
		port map( clk => clk, reset => reset, en => e_en, ld => e_ld, 
				  data => "01", --to_vector(3, -3), 
				  tc => e_exp );

	d_bit <= data(7);

	d_shift <= '1' when (state /= SyncC and state /= DataA and next_state = DataA) or 
		(state /= DataB and next_state = DataB) else '0';

	busy <= '1' when state /= Idle and state /= DataWait else '0';
	
	m <= "11" when state = Idle or state = SyncC or state = DataAHi0 or state = DataBHi0 or
			state = EofS else 
		"10" when state = DataA or state = DataALo0 or state = DataBHi1 or state = DataWait or state = EofA else
		"01" when state = DataAHi1 or state = DataB or state = DataBLo0 or
			state = SyncA else
		"00";
		
	c_en <= '1'; -- when state = DataA or state = DataALo0 or state = DataAHi0 or state = DataB or state = DataBLo0 or state = DataBHi0 else '0';
	c_ld <= '1' when c_exp = '1' or state = Idle or state = DataWait else '0';
	c_data <= to_vector(5, -25) when c_dsel_500 = '1' else
		to_vector(5, -13) when c_dsel_250 = '1' else
		to_vector(5, -7) when c_dsel_125 = '1' else
			"XXXXX";
	--c_data <= to_vector(5, -MHZ/2) when c_dsel_500 = '1' else
	--	to_vector(5, -MHZ/4) when c_dsel_250 = '1' else
	--	to_vector(5, -MHZ/8) when c_dsel_125 = '1' else
	--		"XXXXX";

	c_dsel_125 <= '1' when --c_exp = '1' and 
		(
		state = SyncC or state = DataA or 
		state = DataALo1 or state = DataAHi1 or state = DataB or
		state = DataBLo1 or state = DataBHi1 or state = DataWait) 
		else '0';

	c_dsel_250 <= '1' when state = Idle or (--c_exp = '1' and 
		(
		state = SyncB or state = DataALo0 or state = DataAHi0 or
		state = DataBLo0 or state = DataBHi0 or state = EofB or state = EofS))
		else '0';

	c_dsel_500 <= '1' when --c_exp = '1' and 
		state = SyncA or state = EofA else '0';

	s_en <= '1' when c_exp = '1' and (state = SyncA or state = DataA
		--state = DataBLo1 or state = DataBHi1
		) else '0';
	s_ld <= '1' when state = Idle or state = SyncC or state = DataWait else '0';

	e_ld <= '1' when state = EofS else '0';
	e_en <= '1' when c_exp = '1' and state = EofB else '0';

	state_machine: process(state, datastb, c_exp, s_exp, d_bit, eof, e_exp) 
	begin

		case state is
		when Idle =>
			if datastb = '1' then
				next_state <= SyncA;
			else
				next_state <= state;
			end if;

		when SyncA =>
			if c_exp = '1' then
				if s_exp = '1' then
					next_state <= SyncC;
				else
					next_state <= SyncB;
				end if;
			else
				next_state <= state;
			end if;

		when SyncB =>
			if c_exp = '1' then
				next_state <= SyncA;
			else
				next_state <= state;
			end if;

		when SyncC =>
			if c_exp = '1' then
				next_state <= DataA;
				--if d_bit = '1' then
				--	next_state <= DataAHi0;
				--else
				--	next_state <= DataALo0;
				--end if;
			else
				next_state <= state;
			end if;

		when DataA =>
			if c_exp = '1' then
				if d_bit = '1' then
					next_state <= DataAHi0;
				else
					next_state <= DataALo0;
				end if;
			else
				next_state <= state;
			end if;

		when DataALo0 =>
			if c_exp = '1' then
				next_state <= DataALo1;
			else
				next_state <= state;
			end if;

		when DataALo1 =>
			if c_exp = '1' then
				next_state <= DataB;
			else
				next_state <= state;
			end if;

		when DataAHi0 =>
			if c_exp = '1' then
				next_state <= DataAHi1;
			else
				next_state <= state;
			end if;

		when DataAHi1 =>
			if c_exp = '1' then
				next_state <= DataB;
			else
				next_state <= state;
			end if;

		when DataB =>
			if c_exp = '1' then
				if d_bit = '1' then
					next_state <= DataBHi0;
				else
					next_state <= DataBLo0;
				end if;
			else
				next_state <= state;
			end if;

		when DataBLo0 =>
			if c_exp = '1' then
				next_state <= DataBLo1;
			else
				next_state <= state;
			end if;

		when DataBLo1 =>
			if c_exp = '1' then
				if s_exp = '1' then
					next_state <= DataWait;
				else
					next_state <= DataA;
				end if;
			else
				next_state <= state;
			end if;

		when DataBHi0 =>
			if c_exp = '1' then
				next_state <= DataBHi1;
			else
				next_state <= state;
			end if;

		when DataBHi1 =>
			if c_exp = '1' then
				if s_exp = '1' then
					next_state <= DataWait;
				else
					next_state <= DataA;
				end if;
			else
				next_state <= state;
			end if;

		when DataWait =>
			if eof = '1' then
				next_state <= EofS;
			elsif datastb = '1' then
				next_state <= DataA;
			else
				next_state <= state;
			end if;

		when EofS =>
			if c_exp = '1' then
				next_state <= EofA;
			else
				next_state <= state;
			end if;

		when EofA =>
			if c_exp = '1' then
				if e_exp = '1' then
					next_state <= Idle;
				else
					next_state <= EofB;
				end if;
			else
				next_state <= state;
			end if;

		when EofB =>
			if c_exp = '1' then
				next_state <= EofA;
			else
				next_state <= state;
			end if;
						
		end case;
	end process state_machine;

	regs: process(clk, reset) 
		variable rstate		: state_type;
		variable rdata		: std_logic_vector(7 downto 0);
		variable rm				: std_logic_vector(1 downto 0);
		variable rs_exp		: std_logic;
		variable oe_r			: std_logic;
	begin
		state <= rstate;
		data <= rdata;
		m_out <= rm;
		s_exp <= rs_exp;
		m_oe <= oe_r;

		if reset = '1' then
			rm := "11";
			rdata := X"00";
			rstate := Idle;
			oe_r := '0';

		elsif rising_edge(clk) then
			rm := m;
			rstate := next_state;
			rs_exp := s_exp_i;

			if state /= Idle then
				oe_r := '1';
			else
				oe_r := '0';
			end if;

			if datastb = '1' and (state = Idle or state = DataWait) then
				rdata := data_in;
			elsif d_shift = '1' then
				rdata(7 downto 1) := rdata(6 downto 0);
				rdata(0) := '0';
			end if;
		end if;
	end process regs;
end rtl;
