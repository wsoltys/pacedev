library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;


entity gbc_snd is
  port
  (
		clk						: in std_logic;
		reset					: in std_logic;
		
		s1_read				: in std_logic;
		s1_write			: in std_logic;
		s1_addr				: in std_logic_vector(5 downto 0);
		s1_readdata		: out std_logic_vector(7 downto 0);
		s1_writedata	: in std_logic_vector(7 downto 0);
		
		snd_left			: out std_logic_vector(15 downto 0);
		snd_right			: out std_logic_vector(15 downto 0)
  );

end gbc_snd;

architecture SYN of gbc_snd is

	constant clk_freq		: integer := 100000000;
	constant snd_freq		: integer := 4194304;

	signal en_snd				: boolean;
	signal en_512				: boolean;	-- 512Hz enable 

	signal en_len				: boolean;	-- Sample length
	signal en_env				: boolean;	-- Envelope
	signal en_sweep			: boolean;	-- Sweep

	signal snd_power		: std_logic;

	signal s1_swper			: std_logic_vector(2 downto 0);		-- Sq1 sweep period
	signal s1_swdir			: std_logic;											-- Sq1 sweep direction
	signal s1_swshift		: std_logic_vector(2 downto 0);		-- Sq1 sweep frequency shift
	signal s1_duty			: std_logic_vector(1 downto 0);		-- Sq1 duty cycle
	signal s1_len				: std_logic_vector(6 downto 0);		-- Sq1 play length
	signal s1_svol			: std_logic_vector(3 downto 0);		-- Sq1 initial volume
	signal s1_envsgn		: std_logic;											-- Sq1 envelope sign
	signal s1_envper		: std_logic_vector(2 downto 0);		-- Sq1 envelope period
	signal s1_freq			: std_logic_vector(10 downto 0);	-- Sq1 frequency
	signal s1_trigger		: std_logic;											-- Sq1 trigger play note
	signal s1_lenchk		: std_logic;											-- Sq1 length check enable

	signal s1_fr2				: std_logic_vector(10 downto 0);	-- Sq1 frequency (shadow copy)
	signal s1_vol				: std_logic_vector(3 downto 0);		-- Sq1 initial volume
	signal s1_envcnt		: std_logic_vector(2 downto 0);		-- Sq1 initial volume
	signal s1_playing		: std_logic;
	signal s1_wav				: std_logic_vector(3 downto 0);		-- Sq1 output waveform

	signal s2_duty			: std_logic_vector(1 downto 0);		-- Sq2 duty cycle
	signal s2_len				: std_logic_vector(6 downto 0);		-- Sq2 play length
	signal s2_svol			: std_logic_vector(3 downto 0);		-- Sq2 initial volume
	signal s2_envsgn		: std_logic;											-- Sq2 envelope sign
	signal s2_envper		: std_logic_vector(2 downto 0);		-- Sq2 envelope period
	signal s2_freq			: std_logic_vector(10 downto 0);	-- Sq2 frequency
	signal s2_trigger		: std_logic;											-- Sq2 trigger play note
	signal s2_lenchk		: std_logic;											-- Sq2 length check enable

	signal s2_fr2				: std_logic_vector(10 downto 0);	-- Sq2 frequency (shadow copy)
	signal s2_vol				: std_logic_vector(3 downto 0);		-- Sq2 initial volume
	signal s2_envcnt		: std_logic_vector(2 downto 0);		-- Sq2 initial volume
	signal s2_playing		: std_logic;
	signal s2_wav				: std_logic_vector(3 downto 0);		-- Sq2 output waveform
begin

	-- Calculate base clock enable (4.194304MHz)
	process(clk, reset)
		constant clk_frac		: unsigned(15 downto 0) := X"0ABD"; --to_unsigned(snd_freq * 65536 / clk_freq, 16);
		variable divacc			: unsigned(15 downto 0);
		variable acc				: unsigned(16 downto 0);
	begin
		if reset = '1' then
			divacc := (others => '0');
		elsif rising_edge(clk) then
			-- Sound base divider clock enable
			acc := ('0'&divacc) + ('0'&clk_frac);
			en_snd <= (acc(16) = '1');
			divacc := acc(15 downto 0);
		end if;
	end process;

	-- Calculate divided and frame sequencer clock enables
	process(clk, en_snd, reset)
		variable cnt_512		: unsigned(12 downto 0);
		variable temp_512		: unsigned(13 downto 0);
		variable framecnt		: integer range 0 to 7 := 0;
	begin
		if reset = '1' then
			cnt_512 := (others => '0');
			framecnt := 0;

		elsif rising_edge(clk) then
			-- Frame sequencer (length, envelope, sweep) clock enables
			en_len <= false;
			en_env <= false;
			en_sweep <= false;
			if en_512 then
				if framecnt = 0 or framecnt = 2 or framecnt = 4 or framecnt = 6 then
					en_len <= true;
				end if;
				if framecnt = 2 or framecnt = 6 then
					en_env <= true;
				end if;
				if framecnt = 7 then
					en_sweep <= true;
				end if;

				if framecnt < 7 then
					framecnt := framecnt + 1;
				else
					framecnt := 0;
				end if;
			end if;

			--
			en_512 <= false;
			if en_snd then
				temp_512 := ('0'&cnt_512) + to_unsigned(1, temp_512'length);
				cnt_512 := temp_512(temp_512'high-1 downto temp_512'low);
				en_512 <= (temp_512(13) = '1');
			end if;
		end if;
	end process;

	-- Registers
	process(clk, snd_power, reset, en_snd, en_len, en_env, en_sweep)
		constant duty_0			: std_logic_vector(0 to 7) := "00000001";
		constant duty_1			: std_logic_vector(0 to 7) := "10000001";
		constant duty_2			: std_logic_vector(0 to 7) := "10000111";
		constant duty_3			: std_logic_vector(0 to 7) := "01111110";
		variable s1_fcnt		: unsigned(10 downto 0);
		variable s1_phase		: integer range 0 to 7;
		variable s1_out			: std_logic;
		variable s2_fcnt		: unsigned(10 downto 0);
		variable s2_phase		: integer range 0 to 7;
		variable s2_out			: std_logic;

		variable acc_fcnt		: unsigned(11 downto 0);
	begin
		-- Sound processing
		if snd_power = '0' then
			s1_playing	<= '0';
			s1_fcnt			:= (others => '0');
			s1_phase		:= 0;
			s1_vol		 	<= "0000";
			s1_envcnt		<= "000";
			s2_playing	<= '0';
			s2_fcnt			:= (others => '0');
			s2_phase		:= 0;
			s2_vol		 	<= "0000";
			s2_envcnt		<= "000";

		elsif rising_edge(clk) then
			if en_snd then
				-- Sq1 frequency timer
				if s1_playing = '1' then
					acc_fcnt := ('0'&s1_fcnt) + to_unsigned(1, acc_fcnt'length);
					if acc_fcnt(acc_fcnt'high) = '1' then
						if s1_phase < 7 then
							s1_phase := s1_phase + 1;
						else
							s1_phase := 0;
						end if;
						s1_fcnt := unsigned(s1_fr2);
					else
						s1_fcnt := acc_fcnt(s1_fcnt'range);
					end if;
				end if;

				-- Sq2 frequency timer
				if s2_playing = '1' then
					acc_fcnt := ('0'&s2_fcnt) + to_unsigned(1, acc_fcnt'length);
					if acc_fcnt(acc_fcnt'high) = '1' then
						if s2_phase < 7 then
							s2_phase := s2_phase + 1;
						else
							s2_phase := 0;
						end if;
						s2_fcnt := unsigned(s2_fr2);
					else
						s2_fcnt := acc_fcnt(s2_fcnt'range);
					end if;
				end if;

				case s1_duty is
				when "00" => s1_out := duty_0(s1_phase);
				when "01" => s1_out := duty_1(s1_phase);
				when "10" => s1_out := duty_2(s1_phase);
				when "11" => s1_out := duty_3(s1_phase);
				when others => null;
				end case;

				if s1_out = '1' then
					s1_wav <= s1_vol;
				else
					s1_wav <= "0000";
				end if;

				case s2_duty is
				when "00" => s2_out := duty_0(s2_phase);
				when "01" => s2_out := duty_1(s2_phase);
				when "10" => s2_out := duty_2(s2_phase);
				when "11" => s2_out := duty_3(s2_phase);
				when others => null;
				end case;

				if s2_out = '1' then
					s2_wav <= s2_vol;
				else
					s2_wav <= "0000";
				end if;
			end if;

			if s1_playing = '1' then
				-- Length counter
				if en_len then
					if s1_len(6) = '0' then
						s1_len <= std_logic_vector(unsigned(s1_len) + to_unsigned(1, s1_len'length));
					end if;
				end if;

				-- Envelope counter
				if en_env then
					if s1_envper /= "000" and s1_envcnt /= s1_envper then
						s1_envcnt <= std_logic_vector(unsigned(s1_envcnt) + to_unsigned(1, s1_envcnt'length));
					else
						if s1_envper /= "000" then
							if s1_envsgn = '1' then
								if s1_vol /= "1111" then 
									s1_vol <= std_logic_vector(unsigned(s1_vol) + to_unsigned(1, s1_vol'length));
								end if;
							else
								if s1_vol /= "0000" then 
									s1_vol <= std_logic_vector(unsigned(s1_vol) - to_unsigned(1, s1_vol'length));
								end if;
							end if;
						end if;

						s1_envcnt <= "000";
					end if;
				end if;

				-- Check for end of playing conditions
				if s1_vol = X"0" or (s1_lenchk = '1' and s1_len(6) = '1') then
					s1_playing <= '0';
					s1_envcnt <= "000";
					s1_wav <= "0000";
				end if;
			end if;

			-- Check sample trigger and start playing
			if s1_trigger = '1' then
				s1_fr2 <= s1_freq;
				s1_fcnt := unsigned(s1_freq);
				s1_playing <= '1';
				s1_vol <= s1_svol;
				s1_envcnt <= "000";
				s1_len(6) <= '0';
			end if;

			if s2_playing = '1' then
				-- Length counter
				if en_len then
					if s2_len(6) = '0' then
						s2_len <= std_logic_vector(unsigned(s2_len) + to_unsigned(1, s2_len'length));
					end if;
				end if;

				-- Envelope counter
				if en_env then
					if s2_envper /= "000" and s2_envcnt /= s2_envper then
						s2_envcnt <= std_logic_vector(unsigned(s2_envcnt) + to_unsigned(1, s2_envcnt'length));
					else
						if s2_envper /= "000" then
							if s2_envsgn = '1' then
								if s2_vol /= "1111" then 
									s2_vol <= std_logic_vector(unsigned(s2_vol) + to_unsigned(1, s2_vol'length));
								end if;
							else
								if s2_vol /= "0000" then 
									s2_vol <= std_logic_vector(unsigned(s2_vol) - to_unsigned(1, s2_vol'length));
								end if;
							end if;
						end if;

						s2_envcnt <= "000";
					end if;
				end if;

				-- Check for end of playing conditions
				if s2_vol = X"0" or (s2_lenchk = '1' and s2_len(6) = '1') then
					s2_playing <= '0';
					s2_envcnt <= "000";
					s2_wav <= "0000";
				end if;
			end if;

			-- Check sample trigger and start playing
			if s2_trigger = '1' then
				s2_fr2 <= s2_freq;
				s2_fcnt := unsigned(s2_freq);
				s2_playing <= '1';
				s2_vol <= s2_svol;
				s2_envcnt <= "000";
				s2_len(6) <= '0';
			end if;

		end if;	-- snd_power

		-- Registers
		if rising_edge(clk) then
			if en_snd then
				s1_trigger <= '0';
				s2_trigger <= '0';
			end if;

			if s1_write = '1' then
				case s1_addr is
		       								-- Square 1
				when "010000" =>	-- NR10 FF10 -PPP NSSS Sweep period, negate, shift
					s1_swper <= s1_writedata(6 downto 4);
					s1_swdir <= s1_writedata(3);
					s1_swshift <= s1_writedata(2 downto 0);
				when "010001" =>	-- NR11 FF11 DDLL LLLL Duty, Length load (64-L)
					s1_duty <= s1_writedata(7 downto 6);
					s1_len(5 downto 0) <= s1_writedata(5 downto 0);
				when "010010" =>	-- NR12 FF12 VVVV APPP Starting volume, Envelope add mode, period
					s1_svol <= s1_writedata(7 downto 4);
					s1_envsgn <= s1_writedata(3);
					s1_envper <= s1_writedata(2 downto 0);
				when "010011" =>	-- NR13 FF13 FFFF FFFF Frequency LSB
					s1_freq(7 downto 0) <= s1_writedata;
				when "010100" =>	-- NR14 FF14 TL-- -FFF Trigger, Length enable, Frequency MSB
					s1_trigger <= s1_writedata(7);
					s1_lenchk <= s1_writedata(6);
					s1_freq(10 downto 8) <= s1_writedata(2 downto 0);

													-- Square 2
				when "010110" =>	-- NR21 FF16 DDLL LLLL Duty, Length load (64-L)
					s2_duty <= s1_writedata(7 downto 6);
					s2_len(5 downto 0) <= s1_writedata(5 downto 0);
				when "010111" =>	-- NR22 FF17 VVVV APPP Starting volume, Envelope add mode, period
					s2_svol <= s1_writedata(7 downto 4);
					s2_envsgn <= s1_writedata(3);
					s2_envper <= s1_writedata(2 downto 0);
				when "011000" =>	-- NR23 FF18 FFFF FFFF Frequency LSB
					s2_freq(7 downto 0) <= s1_writedata;
				when "011001" =>	-- NR24 FF19 TL-- -FFF Trigger, Length enable, Frequency MSB
					s2_trigger <= s1_writedata(7);
					s2_lenchk <= s1_writedata(6);
					s2_freq(10 downto 8) <= s1_writedata(2 downto 0);

--									-- Wave
--				when "011010" =>	-- NR30 FF1A E--- ---- DAC power
--				when "011011" =>	-- NR31 FF1B LLLL LLLL Length load (256-L)
--				when "011100" =>	-- NR32 FF1C -VV- ---- Volume code (00=0%, 01=100%, 10=50%, 11=25%)
--				when "011101" =>	-- NR33 FF1D FFFF FFFF Frequency LSB
--				when "011110" =>	-- NR34 FF1E TL-- -FFF Trigger, Length enable, Frequency MSB
--
--									-- Noise
--				when "100000" =>	-- NR41 FF20 --LL LLLL Length load (64-L)
--				when "100001" =>	-- NR42 FF21 VVVV APPP Starting volume, Envelope add mode, period
--				when "100010" =>	-- NR43 FF22 SSSS WDDD Clock shift, Width mode of LFSR, Divisor code
--				when "100011" =>	-- NR44 FF23 TL-- ---- Trigger, Length enable
--
--									-- Control/Status
--				when "100100" =>	-- NR50 FF24 ALLL BRRR Vin L enable, Left vol, Vin R enable, Right vol
--				when "100101" =>	-- NR51 FF25 NW21 NW21 Left enables, Right enables
				when "100110" =>	-- NR52 FF26 P--- NW21 Power control/status, Channel length statuses
					snd_power <= s1_writedata(7);
--
--									-- Wave Table
--				when "110000" =>	--      FF30 0000 1111 Samples 0 and 1
--				when "110001" =>	--      FF31 0000 1111 Samples 2 and 3
--				when "110010" =>	--      FF32 0000 1111 Samples 4 and 5
--				when "110011" =>	--      FF33 0000 1111 Samples 6 and 31
--				when "110100" =>	--      FF34 0000 1111 Samples 8 and 31
--				when "110101" =>	--      FF35 0000 1111 Samples 10 and 11
--				when "110110" =>	--      FF36 0000 1111 Samples 12 and 13
--				when "110111" =>	--      FF37 0000 1111 Samples 14 and 15
--				when "111000" =>	--      FF38 0000 1111 Samples 16 and 17
--				when "111001" =>	--      FF39 0000 1111 Samples 18 and 19
--				when "111010" =>	--      FF3A 0000 1111 Samples 20 and 21
--				when "111011" =>	--      FF3B 0000 1111 Samples 22 and 23
--				when "111100" =>	--      FF3C 0000 1111 Samples 24 and 25
--				when "111101" =>	--      FF3D 0000 1111 Samples 26 and 27
--				when "111110" =>	--      FF3E 0000 1111 Samples 28 and 29
--				when "111111" =>	--      FF3F 0000 1111 Samples 30 and 31

				when others =>
					null;
				end case;
			end if;

			if s1_read = '1' then
				case s1_addr is
       								-- Square 1
				when "010000" =>	-- NR10 FF10 -PPP NSSS Sweep period, negate, shift
					s1_readdata <= '1' & s1_swper & s1_swdir & s1_swshift;
				when "010001" =>	-- NR11 FF11 DDLL LLLL Duty, Length load (64-L)
					s1_readdata <= s1_duty & "111111";
				when "010010" =>	-- NR12 FF12 VVVV APPP Starting volume, Envelope add mode, period
					s1_readdata <= s1_vol & s1_envsgn & s1_envper;
				when "010011" =>	-- NR13 FF13 FFFF FFFF Frequency LSB
					s1_readdata <= X"FF";
				when "010100" =>	-- NR14 FF14 TL-- -FFF Trigger, Length enable, Frequency MSB
					s1_readdata <= '0' & s1_lenchk & "111111";

													-- Square 2
				when "010110" =>	-- NR21 FF16 DDLL LLLL Duty, Length load (64-L)
					s1_readdata <= s2_duty & "111111";
				when "010111" =>	-- NR22 FF17 VVVV APPP Starting volume, Envelope add mode, period
					s1_readdata <= s2_vol & s2_envsgn & s2_envper;
				when "011000" =>	-- NR23 FF18 FFFF FFFF Frequency LSB
					s1_readdata <= X"FF";
				when "011001" =>	-- NR24 FF19 TL-- -FFF Trigger, Length enable, Frequency MSB
					s1_readdata <= '0' & s2_lenchk & "111111";

				when "100110" =>	-- NR52 FF26 P--- NW21 Power control/status, Channel length statuses
					s1_readdata <= snd_power & "000000" & s1_playing;
				when others =>
					s1_readdata <= X"FF";
				end case;
			end if;
		end if;

		-- Reset register values
		if snd_power = '0' then
			s1_swper		<= (others => '0');
			s1_swdir		<= '0';
			s1_swshift	<= (others => '0');
			s1_duty			<= (others => '0');
			s1_len			<= (others => '0');
			s1_vol			<= (others => '0');
			s1_envsgn		<= '0';
			s1_envper		<= (others => '0');
			s1_freq			<= (others => '0');
			s1_fr2			<= (others => '0');
			s1_lenchk		<= '0';
			s1_trigger	<= '0';
		end if;
		if reset = '1' then
			snd_power <= '0';
		end if;
	end process;

	-- Test
	process(clk, en_512, reset)
		variable l : std_logic_vector(15 downto 0);
	begin
		if reset = '1' then
			l := x"4000";

		elsif rising_edge(clk) then
			if en_512 then
				l := not l;
			end if;
--			snd_left <= l;
		end if;
	end process;

	-- Mixer
	snd_left <= "00" & s1_wav & "00" & X"00";
	snd_right <= "00" & s2_wav & "00" & X"00";

end SYN;
