library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.mce6809_pack.all;

entity mce6809_tb is
	port (
		fail:				out  boolean
	);
end mce6809_tb;

architecture SYN of mce6809_tb is
	for syn_cpu : mce6809 use entity work.mce6809 (SYN);
	for beh_cpu : mce6809 use entity work.mce6809 (BEH);

	subtype MemData_idx is integer range 0 to 65535;
	subtype MemData_type is std_logic_vector(7 downto 0);
	type Mem_type is array(MemData_idx) of MemData_type;

	signal clk				: std_logic	:= '0';
	signal reset			: std_logic	:= '1';
	signal syn_read		: std_logic;
	signal syn_vma		: std_logic;
	signal syn_addr		: std_logic_vector(15 downto 0);
	signal syn_data_o	: std_logic_vector(7 downto 0);
	signal beh_read		: std_logic;
	signal beh_vma		: std_logic;
	signal beh_addr		: std_logic_vector(15 downto 0);
	signal beh_data_o	: std_logic_vector(7 downto 0);
	signal mem_read		: std_logic;
	signal mem_addr		: std_logic_vector(15 downto 0);
	signal mem_data		: std_logic_vector(7 downto 0);

	signal match_ext	: std_logic;
begin
	syn_cpu : mce6809 port map (clk => clk, clken => '1', reset => reset, data_i => mem_data, data_o => syn_data_o, rw => syn_read,
		vma => syn_vma, address => syn_addr, halt => '0', hold => '0', irq => '0', firq => '0', nmi => '0');

	beh_cpu : mce6809 port map (clk => clk, clken => '1', reset => reset, data_i => mem_data, data_o => beh_data_o, rw => beh_read,
		vma => beh_vma, address => beh_addr, halt => '0', hold => '0', irq => '0', firq => '0', nmi => '0');

	-- Check external signals match
	match_ext <= '0' when beh_vma /= syn_vma or (syn_vma = '1' and beh_read /= syn_read) or (syn_vma = '1' and beh_addr /= syn_addr) else
		'1';

	-- Generate CLK and reset
	clk <= not clk after 20 ns;
	reset <= '0' after 101 ns;

	mem_read <= syn_read;
	mem_addr <= syn_addr;
	--mem_read <= beh_read;
	--mem_addr <= beh_addr;

	beh_mem : process(mem_read, mem_addr)
		constant mem_delay : time := 12 ns;
		constant mem : Mem_type := (
			0				=>	X"9B",	-- ADDA 10h
			1				=>	X"10",	--
			2				=>	X"9B",	-- ADDA 11h
			3				=>	X"11",	--
			4				=>	X"12",	-- NOP
			5				=>	X"12",	-- NOP
			6				=>	X"1E",	-- EXG D,X
			7				=>	X"01",	-- 
			8				=>	X"4C",	-- INCA
			9				=>	X"5C",	-- INCB
			10			=>	X"1E",	-- EXG X,U
			11			=>	X"13",	--
			12			=>	X"1E",	-- EXG S,U
			13			=>	X"43",	--
			14			=>	X"1E",	-- EXG A,CC
			15			=>	X"8A",	--
			16			=>	X"1E",	-- EXG B,DP
			17			=>	X"9B",	--
			18			=>	X"1E",	-- EXG D,S
			19			=>	X"04",	--
			20			=>	X"9B",	-- ADDA -1
			21			=>	X"FF",	--
			22			=>	X"BB",	-- ADDA #0005h
			23			=>	X"00",	--
			24			=>	X"05",		
			25			=>	X"AB",	-- ADDA ,X
			26			=>	X"84",
			27			=>	X"AB",	-- ADDA 5,X
			28			=>	X"05",
			29			=>	X"12",
			30			=>	X"12",
			31			=>	X"12",
			32			=>	X"12",
			33			=>	X"12",
			others	=>	X"12"
		);
	begin
		mem_data <= mem(conv_integer(mem_addr)) after mem_delay;
		if mem_addr = 65535 then
			assert false report "End of simulation" severity Failure;  
		end if;
	end process beh_mem;

	fail_check : process(clk, reset, match_ext)
	begin
		if rising_edge(clk) and reset = '0' then
			if match_ext = '0' then
				fail <= true;
			else
				fail <= false;
			end if;
		end if;
	end process fail_check;
end SYN;
