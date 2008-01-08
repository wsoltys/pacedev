library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity pacSnd is
port
(
    -- Pacman sound controller
    clk         : in     std_logic;
    reset       : in   std_logic;
    snd_pulse   : in   std_logic;
    -- CPU I/F
    cpu_a       : in     std_logic_vector(4 downto 0);
    cpu_d_in    : in     std_logic_vector(3 downto 0);
    cpu_d_out   : out  std_logic_vector(3 downto 0);
    cpu_rd      : in   std_logic;
    cpu_wr      : in   std_logic;
    -- ROM I/F
    rom_a       : out  std_logic_vector(7 downto 0);
    rom_d       : in   std_logic_vector(3 downto 0);
    rom_rd      : out  std_logic;
    -- Sound output
    sound_out   : out    std_logic_vector(7 downto 0);

    testvoc1Out : out  std_logic_vector(7 downto 0);
    testvoc2Out : out  std_logic_vector(7 downto 0);
    testvoc3Out : out  std_logic_vector(7 downto 0)
) ;
end pacSnd;

architecture rtl of pacSnd is

    type PlayStates is (Idle, UpdateFreqCnt, FetchCH1, FetchCH2, FetchCH3, CalcCH3_1, CalcCH3_2);

    signal data_out : std_logic_vector(3 downto 0);

    signal voc1Out : std_logic_vector(7 downto 0);
    signal voc2Out : std_logic_vector(7 downto 0);
    signal voc3Out : std_logic_vector(7 downto 0);
    signal mixedsnd : std_logic_vector (7 downto 0);

begin

    cpu_d_out <= data_out;
    rom_rd <= '0'; -- unused

    -- Registers
    process (clk, reset, voc1Out, voc2Out, voc3Out, mixedsnd)
       variable main_sm   : PlayStates;

       variable voc1FreqCnt : std_logic_vector(19 downto 0);
       variable voc1Wav   : std_logic_vector(2 downto 0);
       variable voc1Freq    : std_logic_vector(19 downto 0);
       variable voc1Vol   : std_logic_vector(3 downto 0);

       variable voc2FreqCnt : std_logic_vector(19 downto 4);
       variable voc2Wav   : std_logic_vector(2 downto 0);
       variable voc2Freq    : std_logic_vector(19 downto 4);
       variable voc2Vol   : std_logic_vector(3 downto 0);

       variable voc3FreqCnt : std_logic_vector(19 downto 4);
       variable voc3Wav   : std_logic_vector(2 downto 0);
       variable voc3Freq    : std_logic_vector(19 downto 4);
       variable voc3Vol   : std_logic_vector(3 downto 0);

       variable voc1Samp  : std_logic_vector(3 downto 0);
       variable voc2Samp  : std_logic_vector(3 downto 0);
       variable voc3Samp  : std_logic_vector(3 downto 0);

       variable voc1Calc  : std_logic_vector(7 downto 0);
       variable voc2Calc  : std_logic_vector(7 downto 0);
       variable voc3Calc  : std_logic_vector(7 downto 0);
    begin

       voc1Out(5 downto 0) <= voc1Calc(7 downto 2);
       voc1Out(7 downto 6) <= b"00";
       voc2Out(5 downto 0) <= voc2Calc(7 downto 2);
       voc2Out(7 downto 6) <= b"00";
       voc3Out(5 downto 0) <= voc3Calc(7 downto 2);
       voc3Out(7 downto 6) <= b"00";

       testvoc1Out <= voc1Out;
       testvoc2Out <= voc2Out;
       testvoc3Out <= voc3Out;

       mixedsnd(7 downto 0) <= voc1Out(7 downto 0) + voc2Out(7 downto 0) + voc3Out (7 downto 0);
       sound_out(7 downto 0) <= mixedsnd(7 downto 0);

       if reset = '1' then

          main_sm 			:= Idle;
          voc1FreqCnt 	:= (others => '0');
          voc1Wav 			:= (others => '0');
           voc1Freq 		:= (others => '0');
          voc1Vol 			:= (others => '0');
            voc2FreqCnt := (others => '0');
          voc2Wav 			:= (others => '0');
           voc2Freq 		:= (others => '0');
          voc2Vol 			:= (others => '0');
            voc3FreqCnt := (others => '0');
          voc3Wav 			:= (others => '0');
           voc3Freq 		:= (others => '0');
          voc3Vol 			:= (others => '0');

        elsif rising_edge(clk) then

          -- Sound play state machine
          case main_sm is
             when Idle =>
                -- snd_pulse starts sound calculations
                if snd_pulse = '1' then
                   main_sm := UpdateFreqCnt;
                end if;

             when UpdateFreqCnt =>
                voc1FreqCnt := voc1FreqCnt + voc1Freq;
                voc2FreqCnt := voc2FreqCnt + voc2Freq;
                voc3FreqCnt := voc3FreqCnt + voc3Freq;
                main_sm := FetchCH1;

             when FetchCH1 =>
                rom_a(7 downto 5) <= voc1Wav(2 downto 0);
                rom_a(4 downto 0) <= voc1FreqCnt(19 downto 15);
                main_sm := FetchCH2;

             when FetchCH2 =>
                rom_a(7 downto 5) <= voc2Wav(2 downto 0);
                rom_a(4 downto 0) <= voc2FreqCnt(19 downto 15);
                main_sm := FetchCH3;

             when FetchCH3 =>
                voc1Samp := rom_d;
                voc1Calc := voc1Samp * voc1Vol;
                rom_a(7 downto 5) <= voc3Wav(2 downto 0);
                rom_a(4 downto 0) <= voc3FreqCnt(19 downto 15);
                main_sm := CalcCH3_1;

             when CalcCH3_1 =>
                voc2Samp := rom_d;
                voc2Calc := voc2Samp * voc2Vol;
                main_sm := CalcCH3_2;

             when CalcCH3_2 =>
                voc3Samp := rom_d;
                voc3Calc := voc3Samp * voc3Vol;
                main_sm := Idle;

          end case;

          -- CPU Write
          if cpu_wr = '1' then
             case cpu_a is
                -- Voice 1 Frequency Count
                when b"00000" =>
                   voc1FreqCnt(3 downto 0) := cpu_d_in(3 downto 0);
                when b"00001" => voc1FreqCnt(7 downto 4) := cpu_d_in(3 downto 0);
                when b"00010" => voc1FreqCnt(11 downto 8) := cpu_d_in(3 downto 0);
                when b"00011" => voc1FreqCnt(15 downto 12) := cpu_d_in(3 downto 0);
                when b"00100" => voc1FreqCnt(19 downto 16) := cpu_d_in(3 downto 0);

                -- Voice 1 Waveform
                when b"00101" => voc1Wav(2 downto 0) := cpu_d_in(2 downto 0);

                -- Voice 2 Frequency Count
                when b"00110" => voc2FreqCnt(7 downto 4) := cpu_d_in(3 downto 0);
                when b"00111" => voc2FreqCnt(11 downto 8) := cpu_d_in(3 downto 0);
                when b"01000" => voc2FreqCnt(15 downto 12) := cpu_d_in(3 downto 0);
                when b"01001" => voc2FreqCnt(19 downto 16) := cpu_d_in(3 downto 0);

                -- Voice 2 Waveform
                when b"01010" => voc2Wav(2 downto 0) := cpu_d_in(2 downto 0);

                -- Voice 3 Frequency Count
                when b"01011" => voc3FreqCnt(7 downto 4) := cpu_d_in(3 downto 0);
                when b"01100" => voc3FreqCnt(11 downto 8) := cpu_d_in(3 downto 0);
                when b"01101" => voc3FreqCnt(15 downto 12) := cpu_d_in(3 downto 0);
                when b"01110" => voc3FreqCnt(19 downto 16) := cpu_d_in(3 downto 0);

                -- Voice 3 Waveform
                when b"01111" => voc3Wav(2 downto 0) := cpu_d_in(2 downto 0);

                -- Voice 1 Frequency
                when b"10000" => voc1Freq(3 downto 0) := cpu_d_in(3 downto 0);
                when b"10001" => voc1Freq(7 downto 4) := cpu_d_in(3 downto 0);
                when b"10010" => voc1Freq(11 downto 8) := cpu_d_in(3 downto 0);
                when b"10011" => voc1Freq(15 downto 12) := cpu_d_in(3 downto 0);
                when b"10100" => voc1Freq(19 downto 16) := cpu_d_in(3 downto 0);

                -- Voice 1 Volume
                when b"10101" => voc1Vol(3 downto 0) := cpu_d_in(3 downto 0);

                -- Voice 2 Frequency
                when b"10110" => voc2Freq(7 downto 4) := cpu_d_in(3 downto 0);
                when b"10111" => voc2Freq(11 downto 8) := cpu_d_in(3 downto 0);
                when b"11000" => voc2Freq(15 downto 12) := cpu_d_in(3 downto 0);
                when b"11001" => voc2Freq(19 downto 16) := cpu_d_in(3 downto 0);

                -- Voice 2 Volume
                when b"11010" => voc2Vol(3 downto 0) := cpu_d_in(3 downto 0);

                -- Voice 3 Frequency Count
                when b"11011" => voc3Freq(7 downto 4) := cpu_d_in(3 downto 0);
                when b"11100" => voc3Freq(11 downto 8) := cpu_d_in(3 downto 0);
                when b"11101" => voc3Freq(15 downto 12) := cpu_d_in(3 downto 0);
                when b"11110" => voc3Freq(19 downto 16) := cpu_d_in(3 downto 0);

                -- Voice 3 Volume
                when b"11111" => voc3Vol(3 downto 0) := cpu_d_in(3 downto 0);
                
                when others => null;
             end case;
          end if;

          -- CPU Read
        if cpu_rd = '1' then
           case cpu_a is
              -- Voice 1 Frequency Count
              when b"00000" => data_out(3 downto 0) <= voc1FreqCnt(3 downto 0);
              when b"00001" => data_out(3 downto 0) <= voc1FreqCnt(7 downto 4);
              when b"00010" => data_out(3 downto 0) <= voc1FreqCnt(11 downto 8);
              when b"00011" => data_out(3 downto 0) <= voc1FreqCnt(15 downto 12);
              when b"00100" => data_out(3 downto 0) <= voc1FreqCnt(19 downto 16);

              -- Voice 1 Waveform
              when b"00101" => data_out(2 downto 0) <= voc1Wav(2 downto 0); data_out(3) <= '0';

              -- Voice 2 Frequency Count
              when b"00110" => data_out(3 downto 0) <= voc2FreqCnt(7 downto 4);
              when b"00111" => data_out(3 downto 0) <= voc2FreqCnt(11 downto 8);
              when b"01000" => data_out(3 downto 0) <= voc2FreqCnt(15 downto 12);
              when b"01001" => data_out(3 downto 0) <= voc2FreqCnt(19 downto 16);

              -- Voice 2 Waveform
              when b"01010" => data_out(2 downto 0) <= voc2Wav(2 downto 0); data_out(3) <= '0';

              -- Voice 3 Frequency Count
              when b"01011" => data_out(3 downto 0) <= voc3FreqCnt(7 downto 4);
              when b"01100" => data_out(3 downto 0) <= voc3FreqCnt(11 downto 8);
              when b"01101" => data_out(3 downto 0) <= voc3FreqCnt(15 downto 12);
              when b"01110" => data_out(3 downto 0) <= voc3FreqCnt(19 downto 16);

              -- Voice 3 Waveform
              when b"01111" => data_out(2 downto 0) <= voc3Wav(2 downto 0); data_out(3) <= '0';

              -- Voice 1 Frequency
              when b"10000" => data_out(3 downto 0) <= voc1Freq(3 downto 0);
              when b"10001" => data_out(3 downto 0) <= voc1Freq(7 downto 4);
              when b"10010" => data_out(3 downto 0) <= voc1Freq(11 downto 8);
              when b"10011" => data_out(3 downto 0) <= voc1Freq(15 downto 12);
              when b"10100" => data_out(3 downto 0) <= voc1FreqCnt(19 downto 16);

              -- Voice 1 Volume
              when b"10101" => data_out(3 downto 0) <= voc1Vol(3 downto 0);

              -- Voice 2 Frequency
              when b"10110" => data_out(3 downto 0) <= voc2Freq(7 downto 4);
              when b"10111" => data_out(3 downto 0) <= voc2Freq(11 downto 8);
              when b"11000" => data_out(3 downto 0) <= voc2Freq(15 downto 12);
              when b"11001" => data_out(3 downto 0) <= voc2Freq(19 downto 16);

              -- Voice 2 Volume
              when b"11010" => data_out(3 downto 0) <= voc2Vol(3 downto 0);

              -- Voice 3 Frequency Count
              when b"11011" => data_out(3 downto 0) <= voc3Freq(7 downto 4);
              when b"11100" => data_out(3 downto 0) <= voc3Freq(11 downto 8);
              when b"11101" => data_out(3 downto 0) <= voc3Freq(15 downto 12);
              when b"11110" => data_out(3 downto 0) <= voc3Freq(19 downto 16);

              -- Voice 3 Volume
              when b"11111" => data_out(3 downto 0) <= voc3Vol(3 downto 0);
              
              when others => null;
           end case;
        end if;
        end if;
    end process;
end rtl;


