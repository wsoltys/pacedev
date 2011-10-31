library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

-- NES 2A03 APU sound sub-module
-- Chip-level module, registers and decoding
entity nes_snd is
port
(
	clk         : in    std_logic;
	reset       : in    std_logic;
	clk358_en   : in    std_logic;		-- Expects 21.47727 MHz / 6 clock enable pulse
	clk179_en		: in		std_logic;		-- Expects 21.47727 MHz / 12 (1.79MHz CPU clock) enable pulse
	
	-- CPU I/F
	a						: in		std_logic_vector(4 downto 0);
	d_in				: in		std_logic_vector(7 downto 0);
	d_out				: out		std_logic_vector(7 downto 0);
	rd					: in		std_logic;
	wr					: in		std_logic;
	irq					: out		std_logic;

	-- Sound data
	snd1				: out		std_logic_vector(15 downto 0);
	snd2				: out		std_logic_vector(15 downto 0)
) ;
end nes_snd;

architecture rtl of nes_snd is
	type seq_t is (seq1, seq2, seq3, seq4, seq5);
	constant sim_delay : time := 1 ns;
	--signal clk179_en			: std_logic;
	signal seqphase				: seq_t;
	signal seqphase_next	: seq_t;
	signal seq5mode				: std_logic;
	signal triwav					: std_logic_vector(3 downto 0) := (others => '0');
	signal noiwav					: std_logic_vector(3 downto 0) := (others => '0');
	signal dmcwav					: std_logic_vector(6 downto 0) := (others => '0');
	signal sq1wav					: std_logic_vector(3 downto 0) := (others => '0');
	signal sq2wav					: std_logic_vector(3 downto 0) := (others => '0');
	signal snd1_0					: std_logic_vector(15 downto 0);
	signal snd2_0					: std_logic_vector(15 downto 0);
	signal len_lookup			: unsigned(7 downto 0);
	signal shape_lookup		: std_logic_vector(7 downto 0);
begin

--        Status (read)
-- $4015   if-d nt21   DMC IRQ, frame IRQ, length counter statuses

	-- Sequence states
	proc_sequence : process(seqphase)
	begin
		case seqphase is
		when seq1 => seqphase_next <= seq2;
		when seq2 => seqphase_next <= seq3;
		when seq3 => seqphase_next <= seq4;
		when seq4 =>
			if seq5mode = '0' then seqphase_next <= seq1; else seqphase_next <= seq5; end if;
		when seq5 => seqphase_next <= seq1;
		end case;
	end process proc_sequence;

	-- Lookup table for loading length registers
	length : process(d_in)
	begin
		case d_in(7 downto 3) is
		when "00000" => len_lookup <= X"0A";    when "00010" => len_lookup <= X"14";
    when "00100" => len_lookup <= X"28";    when "00110" => len_lookup <= X"50";
    when "01000" => len_lookup <= X"A0";    when "01010" => len_lookup <= X"3C";
    when "01100" => len_lookup <= X"0E";    when "01110" => len_lookup <= X"1A";
    when "10000" => len_lookup <= X"0C";    when "10010" => len_lookup <= X"18";
    when "10100" => len_lookup <= X"30";    when "10110" => len_lookup <= X"60";
    when "11000" => len_lookup <= X"C0";    when "11010" => len_lookup <= X"48";
    when "11100" => len_lookup <= X"10";    when "11110" => len_lookup <= X"20";
		when "00001" => len_lookup <= X"FE";		when "00011" => len_lookup <= X"02";
		when "00101" => len_lookup <= X"04";		when "00111" => len_lookup <= X"06";
		when "01001" => len_lookup <= X"08";		when "01011" => len_lookup <= X"0A";
		when "01101" => len_lookup <= X"0C";		when "01111" => len_lookup <= X"0E";
		when "10001" => len_lookup <= X"10";		when "10011" => len_lookup <= X"12";
		when "10101" => len_lookup <= X"14";		when "10111" => len_lookup <= X"16";
		when "11001" => len_lookup <= X"18";		when "11011" => len_lookup <= X"1A";
		when "11101" => len_lookup <= X"1C";		when "11111" => len_lookup <= X"1E";
    when others =>	len_lookup <= (others => 'X');
		end case;
	end process length;

	-- Lookup table for loading square wave shapes
	shape : process(d_in)
	begin
		case d_in(7 downto 6) is
		when "00" =>		shape_lookup <= "01000000";
		when "01" =>		shape_lookup <= "01100000";
		when "10" =>		shape_lookup <= "01111000";
		when "11" =>		shape_lookup <= "10011111";
		when others =>	shape_lookup <= (others => 'X');
		end case;
	end process shape;

	-- Lookup table for sound mixer
	mixer : process(triwav,noiwav,dmcwav,sq1wav,sq2wav)
		variable tridmc : integer range 0 to 202;
		variable sqwav	: integer range 0 to 31;
		variable s1o		: std_logic_vector(15 downto 0);
		variable s2o		: std_logic_vector(15 downto 0);
	begin
		tridmc := 3*to_integer(unsigned(triwav)) + 2*to_integer(unsigned(noiwav))
							+ to_integer(unsigned(dmcwav));
		sqwav := to_integer(unsigned(sq1wav)) + to_integer(unsigned(sq2wav));

		-- Sound channel 1, square waves
		case sqwav is
		when 0 => s1o := X"0000";		when 1 => s1o := X"02F8";
		when 2 => s1o := X"05DF";		when 3 => s1o := X"08B4";
		when 4 => s1o := X"0B78";		when 5 => s1o := X"0E2B";
		when 6 => s1o := X"10CF";		when 7 => s1o := X"1363";
		when 8 => s1o := X"15E9";		when 9 => s1o := X"1860";
		when 10 => s1o := X"1ACA";	when 11 => s1o := X"1D26";
		when 12 => s1o := X"1F75";	when 13 => s1o := X"21B7";
		when 14 => s1o := X"23EE";	when 15 => s1o := X"2618";
		when 16 => s1o := X"2838";	when 17 => s1o := X"2A4C";
		when 18 => s1o := X"2C55";	when 19 => s1o := X"2E54";
		when 20 => s1o := X"3049";	when 21 => s1o := X"3234";
		when 22 => s1o := X"3416";	when 23 => s1o := X"35EF";
		when 24 => s1o := X"37BE";	when 25 => s1o := X"3985";
		when 26 => s1o := X"3B43";	when 27 => s1o := X"3CF9";
		when 28 => s1o := X"3EA7";	when 29 => s1o := X"404D";
		when 30 => s1o := X"41EC";	when 31 => s1o := X"4383";
		end case;

		-- Sound channel 2, triangle noise and dmc
		case tridmc is
		when 0 => s2o := X"0000";			when 1 => s2o := X"01B7";
		when 2 => s2o := X"036A";			when 3 => s2o := X"051A";
		when 4 => s2o := X"06C7";			when 5 => s2o := X"0870";
		when 6 => s2o := X"0A15";			when 7 => s2o := X"0BB7";
		when 8 => s2o := X"0D56";			when 9 => s2o := X"0EF2";
		when 10 => s2o := X"108A";		when 11 => s2o := X"121F";
		when 12 => s2o := X"13B1";		when 13 => s2o := X"1540";
		when 14 => s2o := X"16CC";		when 15 => s2o := X"1855";
		when 16 => s2o := X"19DA";		when 17 => s2o := X"1B5D";
		when 18 => s2o := X"1CDD";		when 19 => s2o := X"1E59";
		when 20 => s2o := X"1FD3";		when 21 => s2o := X"214A";
		when 22 => s2o := X"22BF";		when 23 => s2o := X"2430";
		when 24 => s2o := X"259F";		when 25 => s2o := X"270B";
		when 26 => s2o := X"2874";		when 27 => s2o := X"29DA";
		when 28 => s2o := X"2B3E";		when 29 => s2o := X"2C9F";
		when 30 => s2o := X"2DFE";		when 31 => s2o := X"2F5A";
		when 32 => s2o := X"30B4";		when 33 => s2o := X"320B";
		when 34 => s2o := X"3360";		when 35 => s2o := X"34B2";
		when 36 => s2o := X"3601";		when 37 => s2o := X"374F";
		when 38 => s2o := X"389A";		when 39 => s2o := X"39E2";
		when 40 => s2o := X"3B29";		when 41 => s2o := X"3C6D";
		when 42 => s2o := X"3DAF";		when 43 => s2o := X"3EEE";
		when 44 => s2o := X"402B";		when 45 => s2o := X"4166";
		when 46 => s2o := X"429F";		when 47 => s2o := X"43D6";
		when 48 => s2o := X"450B";		when 49 => s2o := X"463D";
		when 50 => s2o := X"476E";		when 51 => s2o := X"489C";
		when 52 => s2o := X"49C8";		when 53 => s2o := X"4AF3";
		when 54 => s2o := X"4C1B";		when 55 => s2o := X"4D41";
		when 56 => s2o := X"4E65";		when 57 => s2o := X"4F88";
		when 58 => s2o := X"50A8";		when 59 => s2o := X"51C7";
		when 60 => s2o := X"52E3";		when 61 => s2o := X"53FE";
		when 62 => s2o := X"5517";		when 63 => s2o := X"562E";
		when 64 => s2o := X"5743";		when 65 => s2o := X"5857";
		when 66 => s2o := X"5969";		when 67 => s2o := X"5A78";
		when 68 => s2o := X"5B87";		when 69 => s2o := X"5C93";
		when 70 => s2o := X"5D9E";		when 71 => s2o := X"5EA7";
		when 72 => s2o := X"5FAE";		when 73 => s2o := X"60B4";
		when 74 => s2o := X"61B8";		when 75 => s2o := X"62BA";
		when 76 => s2o := X"63BB";		when 77 => s2o := X"64BA";
		when 78 => s2o := X"65B8";		when 79 => s2o := X"66B4";
		when 80 => s2o := X"67AE";		when 81 => s2o := X"68A7";
		when 82 => s2o := X"699F";		when 83 => s2o := X"6A94";
		when 84 => s2o := X"6B89";		when 85 => s2o := X"6C7C";
		when 86 => s2o := X"6D6D";		when 87 => s2o := X"6E5D";
		when 88 => s2o := X"6F4C";		when 89 => s2o := X"7039";
		when 90 => s2o := X"7124";		when 91 => s2o := X"720E";
		when 92 => s2o := X"72F7";		when 93 => s2o := X"73DF";
		when 94 => s2o := X"74C5";		when 95 => s2o := X"75A9";
		when 96 => s2o := X"768D";		when 97 => s2o := X"776F";
		when 98 => s2o := X"7850";		when 99 => s2o := X"792F";
		when 100 => s2o := X"7A0D";		when 101 => s2o := X"7AEA";
		when 102 => s2o := X"7BC5";		when 103 => s2o := X"7CA0";
		when 104 => s2o := X"7D79";		when 105 => s2o := X"7E50";
		when 106 => s2o := X"7F27";		when 107 => s2o := X"7FFC";
		when 108 => s2o := X"80D0";		when 109 => s2o := X"81A3";
		when 110 => s2o := X"8275";		when 111 => s2o := X"8345";
		when 112 => s2o := X"8415";		when 113 => s2o := X"84E3";
		when 114 => s2o := X"85B0";		when 115 => s2o := X"867C";
		when 116 => s2o := X"8746";		when 117 => s2o := X"8810";
		when 118 => s2o := X"88D8";		when 119 => s2o := X"89A0";
		when 120 => s2o := X"8A66";		when 121 => s2o := X"8B2B";
		when 122 => s2o := X"8BEF";		when 123 => s2o := X"8CB2";
		when 124 => s2o := X"8D74";		when 125 => s2o := X"8E35";
		when 126 => s2o := X"8EF5";		when 127 => s2o := X"8FB4";
		when 128 => s2o := X"9072";		when 129 => s2o := X"912E";
		when 130 => s2o := X"91EA";		when 131 => s2o := X"92A5";
		when 132 => s2o := X"935F";		when 133 => s2o := X"9418";
		when 134 => s2o := X"94CF";		when 135 => s2o := X"9586";
		when 136 => s2o := X"963C";		when 137 => s2o := X"96F1";
		when 138 => s2o := X"97A5";		when 139 => s2o := X"9858";
		when 140 => s2o := X"990A";		when 141 => s2o := X"99BB";
		when 142 => s2o := X"9A6C";		when 143 => s2o := X"9B1B";
		when 144 => s2o := X"9BC9";		when 145 => s2o := X"9C77";
		when 146 => s2o := X"9D24";		when 147 => s2o := X"9DCF";
		when 148 => s2o := X"9E7A";		when 149 => s2o := X"9F24";
		when 150 => s2o := X"9FCD";		when 151 => s2o := X"A076";
		when 152 => s2o := X"A11D";		when 153 => s2o := X"A1C4";
		when 154 => s2o := X"A269";		when 155 => s2o := X"A30E";
		when 156 => s2o := X"A3B2";		when 157 => s2o := X"A456";
		when 158 => s2o := X"A4F8";		when 159 => s2o := X"A59A";
		when 160 => s2o := X"A63B";		when 161 => s2o := X"A6DB";
		when 162 => s2o := X"A77A";		when 163 => s2o := X"A818";
		when 164 => s2o := X"A8B6";		when 165 => s2o := X"A953";
		when 166 => s2o := X"A9EF";		when 167 => s2o := X"AA8B";
		when 168 => s2o := X"AB25";		when 169 => s2o := X"ABBF";
		when 170 => s2o := X"AC58";		when 171 => s2o := X"ACF1";
		when 172 => s2o := X"AD88";		when 173 => s2o := X"AE1F";
		when 174 => s2o := X"AEB6";		when 175 => s2o := X"AF4B";
		when 176 => s2o := X"AFE0";		when 177 => s2o := X"B074";
		when 178 => s2o := X"B107";		when 179 => s2o := X"B19A";
		when 180 => s2o := X"B22C";		when 181 => s2o := X"B2BD";
		when 182 => s2o := X"B34E";		when 183 => s2o := X"B3DE";
		when 184 => s2o := X"B46D";		when 185 => s2o := X"B4FC";
		when 186 => s2o := X"B58A";		when 187 => s2o := X"B617";
		when 188 => s2o := X"B6A4";		when 189 => s2o := X"B72F";
		when 190 => s2o := X"B7BB";		when 191 => s2o := X"B845";
		when 192 => s2o := X"B8D0";		when 193 => s2o := X"B959";
		when 194 => s2o := X"B9E2";		when 195 => s2o := X"BA6A";
		when 196 => s2o := X"BAF1";		when 197 => s2o := X"BB78";
		when 198 => s2o := X"BBFF";		when 199 => s2o := X"BC84";
		when 200 => s2o := X"BD09";		when 201 => s2o := X"BD8E";
		when 202 => s2o := X"BE12";		--when 203 => s2o := X"BE95";
		--when 204 => s2o := X"BF18";		when 205 => s2o := X"BF9A";
		end case;

		snd1_0 <= s1o after sim_delay;
		snd2_0 <= s2o after sim_delay;
	end process mixer;

	-- Sequential sound logic
	seq : block
		signal seqclk_c 			: integer;
		signal seqclk_en			: std_logic;
		signal seqphase_bits	: std_logic_vector(4 downto 0);
		signal triclk_c				: unsigned(10 downto 0);
		signal trilen_c				: unsigned(7 downto 0);
		signal trilin_c				: unsigned(6 downto 0);
		signal triclk_tc			: std_logic;
		signal trilen_tc			: std_logic;
		signal trilin_tc			: std_logic;
		signal triclk_ld			: std_logic;
		signal trilen_ld			: std_logic;
		signal trilin_ld			: std_logic;
		signal tri_period_s		: unsigned(10 downto 0);
		signal triwav_cnt_s		: unsigned(4 downto 0);
		signal sq1clk_c				: unsigned(10 downto 0);
		signal sq1len_c				: unsigned(7 downto 0);
		signal sq1clk_tc			: std_logic;
		signal sq1len_tc			: std_logic;
		signal sq1clk_ld			: std_logic;
		signal sq1len_ld			: std_logic;
		signal sq1_period_s		: unsigned(10 downto 0);
		signal sq1_gate_s			: std_logic;
	begin
		-- Counter terminal counts
		seqclk_en <= '1' after sim_delay when seqclk_c = 0 else '0' after sim_delay;
		triclk_tc <= '1' after sim_delay when triclk_c = 0 else '0' after sim_delay;
		trilen_tc <= '1' after sim_delay when trilen_c = 0 else '0' after sim_delay;
		trilin_tc <= '1' after sim_delay when trilin_c = 0 else '0' after sim_delay;
		sq1clk_tc <= '1' after sim_delay when sq1clk_c = 0 else '0' after sim_delay;
		sq1len_tc <= '1' after sim_delay when sq1len_c = 0 else '0' after sim_delay;

		-- Decode write signals
		triclk_ld <= '1' after sim_delay when wr = '1' and (a = "01010" or a = "01011") else '0' after sim_delay;
		trilen_ld <= '1' after sim_delay when wr = '1' and a = "01011" else '0' after sim_delay;
		trilin_ld <= '1' after sim_delay when wr = '1' and a = "01000" else '0' after sim_delay;
		sq1clk_ld <= '1' after sim_delay when wr = '1' and (a = "00010" or a = "00011") else '0' after sim_delay;
		sq1len_ld <= '1' after sim_delay when wr = '1' and a = "00011" else '0' after sim_delay;

		seqphase_bits(0) <= '1' after sim_delay when seqphase = seq1 else '0' after sim_delay;
		seqphase_bits(1) <= '1' after sim_delay when seqphase = seq2 else '0' after sim_delay;
		seqphase_bits(2) <= '1' after sim_delay when seqphase = seq3 else '0' after sim_delay;
		seqphase_bits(3) <= '1' after sim_delay when seqphase = seq4 else '0' after sim_delay;
		seqphase_bits(4) <= '1' after sim_delay when seqphase = seq5 else '0' after sim_delay;

		counters : process(clk, reset, clk358_en)
			variable seqclk_cnt 		: integer;
			variable seqclk_reset		: boolean := false;
			variable tri_ctrl				: std_logic;
			variable tri_halt				: std_logic;
			variable tri_period			: unsigned(10 downto 0);
			variable triclk_cnt			: unsigned(10 downto 0);
			variable trilen_cnt			: unsigned(7 downto 0);
			variable trilin_cnt			: unsigned(6 downto 0);
			variable triwav_cnt			: unsigned(4 downto 0);
			variable trilin_load		: unsigned(6 downto 0);
			variable trilin_period	: unsigned(6 downto 0);
			variable sq1_ctrl				: std_logic;
			variable sq1_shape			: std_logic_vector(7 downto 0);
			variable sq1_period			: unsigned(10 downto 0);
			variable sq1_bitcnt			: integer range 0 to 7;
			variable sq1_gate				: std_logic;
			variable sq1clk_cnt			: unsigned(10 downto 0);
			variable sq1len_cnt			: unsigned(7 downto 0);
		begin
			-- Async reset
			clock_edge : if reset = '1' then
				seqclk_cnt	:= 0;	
				seq5mode		<= '0';
				tri_ctrl		:= '0';
				tri_halt		:= '0';
				triwav_cnt	:= (others => '0');
				triclk_cnt	:= (others => '0');
				trilen_cnt	:= (others => '0');
				trilin_cnt	:= (others => '0');
				triwav			<= (others => '0');
				tri_period	:= (others => '0');
				sq1_ctrl		:= '0';
				sq1_shape		:= "01000000";
				sq1_period	:= (others => '0');
				sq1_bitcnt	:= 0;
				sq1_gate		:= '0';
				sq1clk_cnt	:= (others => '0');
				sq1len_cnt	:= (others => '0');
	
			-- Synchronous (clk)
			elsif rising_edge(clk) then
				-- Output signals
				snd1 <= snd1_0;
				snd2 <= snd2_0;

				-- Wave signals
				triwav <= (triwav_cnt(4) xnor triwav_cnt(3)) 	& (triwav_cnt(4) xnor triwav_cnt(2))
					& (triwav_cnt(4) xnor triwav_cnt(1))				& (triwav_cnt(4) xnor triwav_cnt(0));
				if sq1_gate = '1' then sq1wav <= X"F"; else sq1wav <= X"0"; end if;

				-- Slow (CPU) clock
				slowclk_1 : if clk179_en = '1' then
					-- Triangle wave generation
					if triclk_tc = '1' 
							and trilin_tc = '0' 
							and trilen_tc = '0' then
						triwav_cnt := triwav_cnt + to_unsigned(1, triwav_cnt'length);
					end if;
		
					-- Triangle timer
					if triclk_ld = '0' then
						if triclk_tc = '1' then
							triclk_cnt := tri_period;
						elsif triclk_ld = '0' then
							triclk_cnt := triclk_cnt - 1;
						end if;
					end if;

					-- Square wave 1 generation
					if sq1clk_tc = '1' 
							and sq1len_tc = '0' then
						if(sq1_bitcnt < 7) then
							sq1_bitcnt := sq1_bitcnt + 1;
						else
							sq1_bitcnt := 0;
						end if;
						sq1_gate := sq1_shape(sq1_bitcnt);
					end if;
		
					-- Square wave 1 timer
					if sq1clk_ld = '0' then
						if sq1clk_tc = '1' then
							sq1clk_cnt := sq1_period;
						elsif sq1clk_ld = '0' then
							sq1clk_cnt := sq1clk_cnt - 1;
						end if;
					end if;
				end if slowclk_1;
	
				-- Fast (CPU X 2) clock
				fastclk : if clk358_en = '1' then
					-- Clock channel lengths 
					if seqclk_en = '1' and (seqphase = seq2 or seqphase = seq4) then
						if tri_ctrl = '1' then
							trilen_cnt := (others => '0');
						elsif trilen_tc = '0' and trilen_ld = '0' then
							trilen_cnt := trilen_cnt - 1;
						end if;
					end if;
					if seqclk_en = '1' and (seqphase = seq2 or seqphase = seq4) then
						if sq1_ctrl = '1' then
							sq1len_cnt := (others => '0');
						elsif sq1len_tc = '0' and sq1len_ld = '0' then
							sq1len_cnt := sq1len_cnt - 1;
						end if;
					end if;
	
					-- Triangle linear counter
					if seqclk_en = '1' and seqphase /= seq5 and trilin_ld = '0' then
						if tri_halt = '1' then
							trilin_cnt := trilin_load;
						elsif trilin_tc = '0' then
							trilin_cnt := trilin_cnt - 1;
						end if;
						if tri_ctrl = '0' then
							tri_halt := '0';
						end if;
					end if;

					-- Advance sequence
					if seqclk_en = '1' then
						seqphase <= seqphase_next;
					end if;
	
					-- Sequence clock divider (~240Hz)
					if seqclk_cnt = 0 or seqclk_reset then
						seqclk_cnt := 14915;
					else
						seqclk_cnt := seqclk_cnt - 1;
					end if;
				end if fastclk;
		
				-- Slow (CPU) clock
				slowclk_2 : if clk179_en = '1' then
					-- Register writes
					if wr = '1' then
						case a is
	-- $4000/4 ddle nnnn   duty, loop env/disable length, env disable, vol/env period
						when "00000" =>
							case d_in(7 downto 6) is
							when "00" =>	sq1_shape := shape_lookup;
							when "01" =>	sq1_shape := shape_lookup;
							when "10" =>	sq1_shape := shape_lookup;
							when "11" =>	sq1_shape := shape_lookup;
              when others => null;
							end case;
	-- $4001/5 eppp nsss   enable sweep, period, negative, shift
						-- $4002/6 pppp pppp   period low
						when "00010" =>
							sq1_period(7 downto 0) := unsigned(d_in);
						-- $4003/7 llll lppp   length index, period high
						when "00011" =>
							sq1_period(10 downto 8) := unsigned(d_in(2 downto 0));
							sq1len_cnt := len_lookup;
						-- $4008   clll llll   Triangle control, linear counter load
						when "01000" =>
							tri_ctrl := d_in(7);
							trilin_load := unsigned(d_in(6 downto 0));
							trilin_cnt := unsigned(d_in(6 downto 0));
						-- $400A   pppp pppp   Triangle period low
						when "01010" =>	
							tri_period(7 downto 0) := unsigned(d_in);
						-- $400B   llll lppp   Triangle length index, period high
						when "01011" => 
							tri_period(10 downto 8) := unsigned(d_in(2 downto 0));
							trilen_cnt := len_lookup;
							tri_halt := '1';
	--        Noise
	-- $400C   --le nnnn   loop env/disable length, env disable, vol/env period
	-- $400E   s--- pppp   short mode, period index
	-- $400F   llll l---   length index
	--        DMC
	-- $4010   il-- ffff   IRQ enable, loop, frequency index
	-- $4011   -ddd dddd   DAC
	-- $4012   aaaa aaaa   sample address
	-- $4013   llll llll   sample length
	--        Common
	-- $4015   ---d nt21   length ctr enable: DMC, noise, triangle, pulse 2, 1
						-- $4017   fd-- ----   5-frame cycle, disable frame interrupt
						when "10001" =>
							seq5mode <= d_in(7);
							if seq5mode = '1' then
								seqphase <= seq2;
							else
								seqphase <= seq1;
							end if;
							seqclk_reset := true;
						when others =>
              null;
						end case;
					end if;
				end if slowclk_2;
			end if clock_edge;
	
			-- Pass signals out
			seqclk_c <= seqclk_cnt;
			triclk_c <= triclk_cnt;
			trilen_c <= trilen_cnt;
			trilin_c <= trilin_cnt;
			tri_period_s <= tri_period;
			triwav_cnt_s <= triwav_cnt;
			sq1clk_c <= sq1clk_cnt;
			sq1len_c <= sq1len_cnt;
			sq1_period_s <= sq1_period;
			sq1_gate_s <= sq1_gate;
		end process counters;
	
	end block;

end rtl;

