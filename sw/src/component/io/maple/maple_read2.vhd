library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Decodes maple bus data
-- B:  --_____________----______-.._------__-__--
-- A:  ---__-__-__-__---____--___.._____-_______-

entity maple_read is
	port(
		signal clk			: in std_logic;
		signal reset		: in std_logic;
		signal a				: in std_logic;
		signal b				: in std_logic;
		signal sync			: out std_logic;
		signal eof			: out std_logic;
		signal d				: out std_logic_vector(7 downto 0);
		signal d_rdy		: out std_logic
	);
end entity maple_read;

architecture rtl of maple_read is
	signal ma				: std_logic_vector(2 downto 0);
	signal mb				: std_logic_vector(2 downto 0);
	signal lastb		: std_logic;
	signal clka			: std_logic;
	signal clkb			: std_logic;
	signal clkbit		: std_logic;
	signal newbit		: std_logic;

	signal sync_tc	: std_logic;
	signal synci		: std_logic;
	signal eof_1		: std_logic;
	signal eofi			: std_logic;
	
	signal di				: std_logic_vector(7 downto 0);
	signal d_rdy_0	: std_logic;
begin
	sync <= synci;
	eof <= eofi;
	d <= di;

--	(* Oops, glitches! *)
--	A <- {regs 1 2 M'[0] $}
--	B <- {regs 1 2 M'[1] $}

--	ClkA <- {FallingEdge B $}
--	ClkB <- {FallingEdge A $}
--	ClkBit <- (ClkA '&' ('~' rLastA)) '|' (ClkB '&' rLastA)
--	NewBit <- (ClkA '&' A) '|' (ClkB '&' B)
	
	-- Unmeta inputs
	process(clk, reset)
	begin
		if reset = '1' then
			ma <= (others => '0');
			mb <= (others => '0');
		elsif rising_edge(clk) then
			ma <= ma(1 downto 0) & a;
			mb <= mb(1 downto 0) & b;
		end if;
	end process;

	-- Detect falling edges and work out which bit to clock
	clka <= '1' when ma(2) = '1' and ma(1) = '0' else '0';
	clkb <= '1' when mb(2) = '1' and mb(1) = '0' else '0';
	clkbit <= (clka and lastb) or (clkb and not lastb);
	newbit <= (clka and mb(1)) or (clkb and ma(1)); 
	
--	(* Did we last see A or B falling edge *)
--	rLastA <- {reg 1 (Sync 'then' '0' 'else' 
--		ClkBit 'then' ('~' rLastA) 'else' rLastA) $}

	process(clk, reset)
	begin
		if reset = '1' then
			lastb <= '0';
			eof_1 <= '0';
			d_rdy <= '0';
			di <= (others => '0');
			
		elsif rising_edge(clk) then
			-- Keep track of which edge to clock next
			if synci = '1' then
				lastb <= '0';
			elsif clkbit = '1' then
				lastb <= not lastb;
			end if;
			
			-- Count eof pulses up to 2
			if ma(1) = '1' then 
				eof_1 <= '0';
			elsif clkb = '1' then
				eof_1 <= '1';
			end if;
			
			-- Delay data ready 1 clock
			d_rdy <= d_rdy_0 and clkbit;
			
			-- Shift in new bit when ClkBit is asserted *)
			if clkbit = '1' then
				di <= di(6 downto 0) & newbit;
			end if;
		end if;
	end process;
	
--	(* Count sync pulses up to 4 *)
--	rScnt <- {UpNCounter 3 ClkB ClkA $}
--	Sync <- ClkB '&' (rScnt '==' {ones (width rScnt) $})
--	Sync_int <- {StretchPulse IntHoldClks Sync $}

	-- Count first three sync pulses
	SCNT: entity work.load_upcounter
		generic map( width => 3 )
		port map( clk => clk, reset => reset, en => clka, ld => mb(1), 
				  data => "100", tc => sync_tc );
--				  data => to_vector(3, -3), tc => sync_tc );
				
	synci <= clka and sync_tc;
	
--	(* Count eof pulses up to 2 *)
--	rEcnt <- {reg 1 (ClkB 'then' '0' 'else'
--		ClkA 'then' '1' 'else' rEcnt) $}
--	Eof <- '~' A '&' ClkA '&' rEcnt
--	Eof_int <- {StretchPulse IntHoldClks Eof $}

	eofi <= not ma(1) and clkb and eof_1;
		
--	(* Count bits since sync / last byte *)
--	rDcnt <- {UpCounter {clog2 DataLength $} Sync ClkBit $}
--	Data_ready <- ClkB '&' (rDcnt '==' {ones (width rDcnt) $})
--	(* Stretch and delay byte ready *)
--	Data_ready_int <- {reg 1 {StretchPulse IntHoldClks Data_ready $} $} 
	
	DCNT: entity work.load_upcounter
		generic map( width => 3 )
		port map( clk => clk, reset => reset, en => clkbit, ld => synci, 
				  data => (others => '0'), tc => d_rdy_0 );
	
--	(* Shift in new bit when ClkBit is asserted *)
--	T_in <- ClkBit 'then' (T'[(DataLength - 2):0] '++' NewBit) 'else' T
--	T <- {reg DataLength T_in $}

end rtl;