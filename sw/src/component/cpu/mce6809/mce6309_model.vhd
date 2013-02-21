library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
use work.mce6309_pack.all;

entity mce6309 is
	port 
	(
	  -- clocking, reset
		clk             : in  std_logic;
		clken           : in  std_logic;
		reset           : in  std_logic;
		
		-- bus signals
		rw              : out std_logic;
		vma             : out std_logic;
		address         : out std_logic_vector(15 downto 0);
		data_i  	      : in  std_logic_vector(7 downto 0);
		data_o 		 	    : out std_logic_vector(7 downto 0);
		data_oe 		    : out std_logic;
		lic 				    : out std_logic;
		halt      	    : in  std_logic;
		hold      	    : in  std_logic;
		irq       	    : in  std_logic;
		firq      	    : in  std_logic;
		nmi       	    : in  std_logic;
		
		-- bdm signals
		bdm_clk         : in std_logic;
		bdm_i           : in std_logic;
		bdm_o           : out std_logic;
		bdm_oe          : out std_logic;
		
		-- misc signals
		op_fetch        : out std_logic
	);
end entity mce6309;

architecture BEH of mce6309 is
	constant SIM_DELAY			: time := 1 ns;

	signal mc_cycle					: integer := 0;
	signal mc_cycle_next		: integer;

	-- CPU registers
	signal		ir						: std_logic_vector(7 downto 0);
	signal		ir_page				: ir_page_type;
	signal		pc						: std_logic_vector(15 downto 0);
	signal		u							: std_logic_vector(15 downto 0);
	signal		s							: std_logic_vector(15 downto 0);
	signal		y							: std_logic_vector(15 downto 0);
	signal		x							: std_logic_vector(15 downto 0);
	signal		acca					: std_logic_vector(7 downto 0);
	signal		accb					: std_logic_vector(7 downto 0);
	signal		dp						: std_logic_vector(7 downto 0);
	signal		cc						: std_logic_vector(7 downto 0);
	signal		ea						: std_logic_vector(15 downto 0);
	signal		post					: std_logic_vector(7 downto 0);
begin
	-- Registers
	regs: process(clk, clken, reset, hold, mc_cycle, data_i)
		variable address_out	: std_logic_vector(15 downto 0) := X"0000";
		variable rw_out				: std_logic := '1';
		variable data_out			: std_logic_vector(7 downto 0) := X"00";
		variable e1						: std_logic_vector(15 downto 0);
		variable e2						: std_logic_vector(15 downto 0);
	begin
		if reset = '1' then
			pc			<= (others => '0');
			ir			<= (others => '0');
			ir_page	<= ir_page0;
			u				<= (others => '0');
			s				<= (others => '0');
			y				<= (others => '0');
			x				<= (others => '0');
			acca 		<= (others => '0');
			accb		<= (others => '0');
			dp			<= (others => '0');
			cc			<= (others => '0');
			ea			<= (others => '0');
			post		<= (others => '0');
		elsif hold = '0' then
			mc_cycle_next <= mc_cycle + 1 after SIM_DELAY;
			vma <= '0';
			data_oe <= '0';

			-- Instruction fetch
			if mc_cycle = 0 then
				vma <= '1' after SIM_DELAY;
				address_out := pc;
				if rising_edge(clk) and clken = '1' then
					pc <= pc + 1;
					ir_page <= ir_page0;
					ir <= data_i;
				end if;
			elsif mc_cycle = 1 then
				vma <= '1' after SIM_DELAY;
				address_out := pc;
				if rising_edge(clk) and clken = '1' then
					if (ir_page /= ir_page0) or (ir(7 downto 4) >= X"6" or ir = X"1E") then
						pc <= pc + 1 after SIM_DELAY;
					end if;
					if ir = X"10" and ir = X"11" then
						if ir = X"10" then
							ir_page <= ir_page1;
						else
							ir_page <= ir_page2;
						end if;
						ir <= data_i after SIM_DELAY;
					end if;
					post <= data_i after SIM_DELAY;
				end if;
			end if;

			-- Execution of opcode
			if ir_page = ir_page0 then
				case ir is
				when X"4A" =>			-- DECA
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;	
						if rising_edge(clk) and clken = '1' then
							acca <= acca - 1 after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"4C" =>			-- INCA
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;	
						if rising_edge(clk) and clken = '1' then
							acca <= acca + 1 after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"5A" =>			-- DECB
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;	
						if rising_edge(clk) and clken = '1' then
							accb <= accb - 1 after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"5C" =>			-- INCB
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;
						if rising_edge(clk) and clken = '1' then
							accb <= accb + 1 after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"8B" =>			-- ADDA (imm)
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;
						if rising_edge(clk) and clken = '1' then
							acca <= acca + data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"96" =>			-- LDA (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp after SIM_DELAY;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						vma <= '1';
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							acca <= data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"97" =>			-- STA (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp after SIM_DELAY;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						vma <= '1';
						address_out := ea;
						data_o <= acca;
						data_oe <= '1';
					when others =>
					end case;
	
				when X"9A" =>			-- ORA (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp after SIM_DELAY;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						vma <= '1';
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							acca <= acca or data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"9B" =>			-- ADDA (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp after SIM_DELAY;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						vma <= '1';
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							acca <= acca + data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"AB" =>			-- ADDA (indexed)
					case mc_cycle is
					when 2 => -- Load offset
						vma <= '1' after SIM_DELAY;
						address_out := pc;
						case post(6 downto 5) is
						when "00" => 		ea <= x;
						when "01" => 		ea <= y;
						when "10" => 		ea <= u;
						when "11" => 		ea <= s;
						when others => 	ea <= (others => 'X');
						end case;
					when 3 =>
						if post(7) = '0' then -- Register address, 5-bit offset
							if rising_edge(clk) and clken = '1' then
								ea <= ea + post(4 downto 0);
							end if;
						else
							if post(3 downto 0) = "0100" then	-- Register address, no offset
								mc_cycle_next <= 0;
								vma <= '1';
								address_out := ea;
								if rising_edge(clk) and clken = '1' then
									acca <= acca + data_i after SIM_DELAY;
								end if;
							end if;
						end if;
					when 4 =>
						if post(7) = '0' then
							mc_cycle_next <= 0;
							vma <= '1';
							address_out := ea;
							if rising_edge(clk) and clken = '1' then
								acca <= acca + data_i after SIM_DELAY;
							end if;
						end if;
					when others =>
					end case;

				when X"BB" =>			-- ADDA (extended)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						address_out := pc;
						vma <= '1' after SIM_DELAY;
						if rising_edge(clk) and clken = '1' then
							pc <= pc + 1 after SIM_DELAY;
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 3 =>
						vma <= '0' after SIM_DELAY;
					when 4 =>
						mc_cycle_next <= 0;
						vma <= '1' after SIM_DELAY;
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							acca <= acca + data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"CB" =>			-- ADDB (imm)
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0 after SIM_DELAY;
						if rising_edge(clk) and clken = '1' then
							accb <= accb + data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"D4" =>			-- ANDA (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp after SIM_DELAY;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						vma <= '1';
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							acca <= acca and data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"DB" =>			-- ADDB (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i after SIM_DELAY;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp after SIM_DELAY;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							accb <= accb + data_i after SIM_DELAY;
						end if;
					when others =>
					end case;

				when X"1E" =>		-- EXG
					case mc_cycle is
					when 7 =>
						if mc_cycle'event then
							case post(3 downto 0) is
							when X"0"	=> e1 := acca & accb;
							when X"1"	=> e1 := x;
							when X"2"	=> e1 := y;
							when X"3"	=> e1 := u;
							when X"4"	=> e1 := s;
							when X"5"	=> e1 := pc;
							when X"8"	=> e1(7 downto 0) := acca;
							when X"9"	=> e1(7 downto 0) := accb;
							when X"A"	=> e1(7 downto 0) := cc;
							when X"B"	=> e1(7 downto 0) := dp;
							when others => e1 := (others => '0');
							end case;

							case post(7 downto 4) is
							when X"0"	=> e2 := acca & accb;
							when X"1"	=> e2 := x;
							when X"2"	=> e2 := y;
							when X"3"	=> e2 := u;
							when X"4"	=> e2 := s;
							when X"5"	=> e2 := pc;
							when X"8"	=> e2(7 downto 0) := acca;
							when X"9"	=> e2(7 downto 0) := accb;
							when X"A"	=> e2(7 downto 0) := cc;
							when X"B"	=> e2(7 downto 0) := dp;
							when others => e2 := (others => '0');
							end case;

							case post(3 downto 0) is
							when X"0"	=> acca <= e2(15 downto 8) after SIM_DELAY; 
													 accb <= e2(7 downto 0) after SIM_DELAY;
							when X"1"	=> x  <= e2 after SIM_DELAY;
							when X"2"	=> y  <= e2 after SIM_DELAY;
							when X"3"	=> u  <= e2 after SIM_DELAY;
							when X"4"	=> s  <= e2 after SIM_DELAY;
							when X"5"	=> pc <= e2 after SIM_DELAY;
							when X"8"	=> acca <= e2(7 downto 0) after SIM_DELAY;
							when X"9"	=> accb <= e2(7 downto 0) after SIM_DELAY;
							when X"A"	=> cc <= e2(7 downto 0) after SIM_DELAY;
							when X"B"	=> dp <= e2(7 downto 0) after SIM_DELAY;
							when others =>
							end case;

							case post(7 downto 4) is
							when X"0"	=> acca <= e1(15 downto 8) after SIM_DELAY; 
													 accb <= e1(7 downto 0) after SIM_DELAY;
							when X"1"	=> x  <= e1 after SIM_DELAY;
							when X"2"	=> y  <= e1 after SIM_DELAY;
							when X"3"	=> u  <= e1 after SIM_DELAY;
							when X"4"	=> s  <= e1 after SIM_DELAY;
							when X"5"	=> pc <= e1 after SIM_DELAY;
							when X"8"	=> acca <= e1(7 downto 0) after SIM_DELAY;
							when X"9"	=> accb <= e1(7 downto 0) after SIM_DELAY;
							when X"A"	=> cc <= e1(7 downto 0) after SIM_DELAY;
							when X"B"	=> dp <= e1(7 downto 0) after SIM_DELAY;
							when others =>
							end case;
						end if;

						mc_cycle_next <= 0 after SIM_DELAY;
					when others =>
					end case;

				when others =>
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0 after SIM_DELAY;
					when others =>
					end case;
				end case;
			end if;
		end if;

		address <= address_out after SIM_DELAY;
		rw <= rw_out after SIM_DELAY;
	end process;
		
	lic <= '1' after SIM_DELAY when mc_cycle_next = 0 else '0' after SIM_DELAY;	

	-- Microcode address
	ma_reg: process(clk, clken, reset)
	begin
		if reset = '1' then
			mc_cycle <= 0;
		elsif rising_edge(clk) and clken = '1' then
			if hold = '0' then
				mc_cycle <= mc_cycle_next after SIM_DELAY;
			end if;
		end if;
	end process;

end architecture BEH;

