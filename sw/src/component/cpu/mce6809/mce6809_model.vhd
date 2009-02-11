library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.mce6809_pack.all;

entity mce6809 is
	port (
		clk:        in  std_logic;
		clken:      in  std_logic;
		reset:      in  std_logic;
		rw:         out std_logic;
		vma:        out std_logic;
		address:    out std_logic_vector(15 downto 0);
		data_i: 	  in  std_logic_vector(7 downto 0);
		data_o:		 	out std_logic_vector(7 downto 0);
		halt:     	in  std_logic;
		hold:     	in  std_logic;
		irq:      	in  std_logic;
		firq:     	in  std_logic;
		nmi:      	in  std_logic
	);
end;

architecture BEH of mce6809 is
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
			mc_cycle_next <= mc_cycle + 1;
			vma <= '0';

			-- Instruction fetch
			if mc_cycle = 0 then
				vma <= '1';
				address_out := pc;
				if rising_edge(clk) and clken = '1' then
					pc <= pc + 1;
					ir_page <= ir_page0;
					ir <= data_i;
				end if;
			elsif mc_cycle = 1 then
				vma <= '1';
				address_out := pc;
				if rising_edge(clk) and clken = '1' then
					if (ir_page /= ir_page0) or (ir(7 downto 4) >= X"6") then
						pc <= pc + 1;
					end if;
					if ir = X"10" and ir = X"11" then
						if ir = X"10" then
							ir_page <= ir_page1;
						else
							ir_page <= ir_page2;
						end if;
						ir <= data_i;
					end if;
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
							acca <= acca - 1;
						end if;
					when others =>
					end case;

				when X"4C" =>			-- INCA
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;	
						if rising_edge(clk) and clken = '1' then
							acca <= acca + 1;
						end if;
					when others =>
					end case;

				when X"5A" =>			-- DECB
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;	
						if rising_edge(clk) and clken = '1' then
							accb <= accb - 1;
						end if;
					when others =>
					end case;

				when X"5C" =>			-- INCB
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;
						if rising_edge(clk) and clken = '1' then
							accb <= accb + 1;
						end if;
					when others =>
					end case;

				when X"8B" =>			-- ADDA (imm)
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;
						if rising_edge(clk) and clken = '1' then
							acca <= acca + data_i;
						end if;
					when others =>
					end case;

				when X"9B" =>			-- ADDA (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						vma <= '1';
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							acca <= acca + data_i;
						end if;
					when others =>
					end case;

				when X"CB" =>			-- ADDB (imm)
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;
						if rising_edge(clk) and clken = '1' then
							accb <= accb + data_i;
						end if;
					when others =>
					end case;

				when X"DB" =>			-- ADDB (direct)
					case mc_cycle is
					when 1 =>
						if rising_edge(clk) and clken = '1' then
							ea(7 downto 0) <= data_i;
						end if;
					when 2 =>
						if rising_edge(clk) and clken = '1' then
							ea(15 downto 8) <= dp;
						end if;
					when 3 =>
						mc_cycle_next <= 0;
						address_out := ea;
						if rising_edge(clk) and clken = '1' then
							accb <= accb + data_i;
						end if;
					when others =>
					end case;

				when X"1E" =>		-- EXG


				when others =>
					case mc_cycle is
					when 1 =>
						mc_cycle_next <= 0;
					when others =>
					end case;
				end case;
			end if;
		end if;

		address <= address_out;
		rw <= rw_out;
	end process;

	-- Microcode address
	ma_reg: process(clk, clken, reset)
	begin
		if reset = '1' then
			mc_cycle <= 0;
		elsif rising_edge(clk) and clken = '1' then
			if hold = '0' then
				mc_cycle <= mc_cycle_next;
			end if;
		end if;
	end process;

end BEH;

