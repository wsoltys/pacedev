library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;

entity inputmapper is
	generic
	(
			NUM_INPUTS	: positive := 2
	);
	port
	(
	    clk       : in std_logic;
	    rst_n     : in std_logic;

	    -- inputs from keyboard controller
	    reset     : in std_logic;
	    press     : in std_logic;
	    release   : in std_logic;
	    data      : in std_logic_vector(7 downto 0);
			-- inputs from jamma interface
			jamma			: in from_JAMMA_t;

	    -- user outputs
			dips			: in std_logic_vector(7 downto 0);
			inputs		: out in8(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

	-- fudge for now
	alias clr_key					: std_logic is dips(0);
		
begin

  latchInputs: process (clk, rst_n, reset, press, release, data)

    variable key_waiting 	: std_logic;
		variable key_code			: std_logic_vector(7 downto 0);
    variable shift_r     	: std_logic;
    variable ctrl_r      	: std_logic;
		
  begin

  	if rst_n = '0' then

      key_waiting := '0';
      key_code := (others => '0');
      shift_r := '0';
      ctrl_r := '0';

		elsif rising_edge (clk) then

			-- reset from the keyboard itself
      if (reset = '1') then
				key_waiting := '0';
				key_code := (others => '0');
				for i in 0 to NUM_INPUTS-1 loop
					inputs(i) <= (others => '0');
				end loop;
      end if;

    	-- handle latch clear
      if clr_key = '1' then
      	key_waiting := '0';
      end if;

      -- handle a key make/break
      if (press or release) = '1' then
      	if data = X"12" or data = X"59" then
        	shift_r := not release;
        elsif data = X"14" then
        	ctrl_r := not release;
        else
          -- handle a keypress (make)
          if press = '1' then

          	-- normal codes
           	if shift_r = '0' and ctrl_r = '0' then
              case data(7 downto 0) is
                when SCANCODE_LEFT 				=> key_code := X"08"; -- LEFT
                when SCANCODE_TAB 				=> key_code := X"09"; -- TAB
                when SCANCODE_DOWN 				=> key_code := X"0A"; -- DOWN
                when SCANCODE_UP 					=> key_code := X"0B"; -- UP
                when SCANCODE_ENTER 			=> key_code := X"0D"; -- ENTER
                when SCANCODE_RIGHT 			=> key_code := X"15"; -- RIGHT
                when SCANCODE_ESC 				=> key_code := X"1B"; -- ESC
                when SCANCODE_SPACE 			=> key_code := X"20"; -- SPACE
                when SCANCODE_QUOTE 			=> key_code := X"27"; -- ''"'
                when SCANCODE_COMMA 			=> key_code := X"2C"; -- ',<'
                when SCANCODE_MINUS 			=> key_code := X"2D"; -- '-_'
                when SCANCODE_PERIOD 			=> key_code := X"2E"; -- '.>'
                when SCANCODE_SLASH 			=> key_code := X"2F"; -- '/?'
                when SCANCODE_0 					=> key_code := X"30"; -- '0'
                when SCANCODE_1 					=> key_code := X"31"; -- '1'
                when SCANCODE_2 					=> key_code := X"32"; -- '2'
                when SCANCODE_3 					=> key_code := X"33"; -- '3'
                when SCANCODE_4 					=> key_code := X"34"; -- '4'
                when SCANCODE_5 					=> key_code := X"35"; -- '5'
                when SCANCODE_6 					=> key_code := X"36"; -- '6'
                when SCANCODE_7 					=> key_code := X"37"; -- '7'
                when SCANCODE_8 					=> key_code := X"38"; -- '8'
                when SCANCODE_9 					=> key_code := X"39"; -- '9'
                when SCANCODE_SEMICOLON		=> key_code := X"3B"; -- ';:'
                when SCANCODE_EQUALS 			=> key_code := X"3D"; -- '=+'
                when X"54" => key_code := X"5B"; -- '[{'
                when X"5D" => key_code := X"5C"; -- '\|'
                when X"5B" => key_code := X"5D"; -- ']}'
                when X"0E" => key_code := X"60"; -- '`~'
                when SCANCODE_A 					=> key_code := X"61"; -- 'a'
                when SCANCODE_B 					=> key_code := X"62"; -- 'b'
                when X"21" => key_code := X"63"; -- 'c'
                when X"23" => key_code := X"64"; -- 'd'
                when X"24" => key_code := X"65"; -- 'e'
                when X"2B" => key_code := X"66"; -- 'f'
                when X"34" => key_code := X"67"; -- 'g'
                when X"33" => key_code := X"68"; -- 'h'
                when X"43" => key_code := X"69"; -- 'i'
                when X"3B" => key_code := X"6A"; -- 'j'
                when X"42" => key_code := X"6B"; -- 'k'
                when X"4B" => key_code := X"6C"; -- 'l'
                when X"3A" => key_code := X"6D"; -- 'm'
                when X"31" => key_code := X"6E"; -- 'n'
                when X"44" => key_code := X"6F"; -- 'o'
                when X"4D" => key_code := X"70"; -- 'p'
                when X"15" => key_code := X"71"; -- 'q'
                when X"2D" => key_code := X"72"; -- 'r'
                when X"1B" => key_code := X"73"; -- 's'
                when X"2C" => key_code := X"74"; -- 't'
                when X"3C" => key_code := X"75"; -- 'u'
                when X"2A" => key_code := X"76"; -- 'v'
                when X"1D" => key_code := X"77"; -- 'w'
                when X"22" => key_code := X"78"; -- 'x'
                when X"35" => key_code := X"79"; -- 'y'
                when X"1A" => key_code := X"7A"; -- 'z'
                when X"66" => key_code := X"7F"; -- BACKSPACE
                when others => null;
              end case;

           -- <CTRL> codes
            elsif ctrl_r = '1' and shift_r = '0' then
               case data(7 downto 0) is
                when X"6B" => key_code := X"08"; -- LEFT
                when X"0D" => key_code := X"09"; -- TAB
                when X"72" => key_code := X"0A"; -- DOWN
                when X"75" => key_code := X"0B"; -- UP
                when X"5A" => key_code := X"0D"; -- ENTER
                when X"74" => key_code := X"15"; -- RIGHT
                when X"76" => key_code := X"1B"; -- ESC
                when X"29" => key_code := X"20"; -- SPACE
                when X"52" => key_code := X"27"; -- ''"'
                when X"41" => key_code := X"2C"; -- ',<'
                when X"4E" => key_code := X"2D"; -- '-_'
                when X"49" => key_code := X"2E"; -- '.>'
                when X"4A" => key_code := X"2F"; -- '/?'
                when X"45" => key_code := X"30"; -- '0'
                when X"16" => key_code := X"00"; -- '1'
                when X"1E" => key_code := X"32"; -- '2'
                when X"26" => key_code := X"33"; -- '3'
                when X"25" => key_code := X"34"; -- '4'
                when X"2E" => key_code := X"35"; -- '5'
                when X"36" => key_code := X"1E"; -- '6'
                when X"3D" => key_code := X"37"; -- '7'
                when X"3E" => key_code := X"38"; -- '8'
                when X"46" => key_code := X"39"; -- '9'
                when X"4C" => key_code := X"3B"; -- ';:'
                when X"55" => key_code := X"3D"; -- '=+'
                when X"54" => key_code := X"1B"; -- '[{'
                when X"5D" => key_code := X"1C"; -- '\|'
                when X"5B" => key_code := X"1D"; -- ']}'
                when X"0E" => key_code := X"60"; -- '`~'
                when X"1C" => key_code := X"01"; -- 'a'
                when X"32" => key_code := X"02"; -- 'b'
                when X"21" => key_code := X"03"; -- 'c'
                when X"23" => key_code := X"04"; -- 'd'
                when X"24" => key_code := X"05"; -- 'e'
                when X"2B" => key_code := X"06"; -- 'f'
                when X"34" => key_code := X"07"; -- 'g'
                when X"33" => key_code := X"08"; -- 'h'
                when X"43" => key_code := X"09"; -- 'i'
                when X"3B" => key_code := X"0A"; -- 'j'
                when X"42" => key_code := X"0B"; -- 'k'
                when X"4B" => key_code := X"0C"; -- 'l'
                when X"3A" => key_code := X"0D"; -- 'm'
                when X"31" => key_code := X"0E"; -- 'n'
                when X"44" => key_code := X"0F"; -- 'o'
                when X"4D" => key_code := X"10"; -- 'p'
                when X"15" => key_code := X"11"; -- 'q'
                when X"2D" => key_code := X"12"; -- 'r'
                when X"1B" => key_code := X"13"; -- 's'
                when X"2C" => key_code := X"14"; -- 't'
                when X"3C" => key_code := X"15"; -- 'u'
                when X"2A" => key_code := X"16"; -- 'v'
                when X"1D" => key_code := X"17"; -- 'w'
                when X"22" => key_code := X"18"; -- 'x'
                when X"35" => key_code := X"19"; -- 'y'
                when X"1A" => key_code := X"1A"; -- 'z'
                when X"66" => key_code := X"7F"; -- BACKSPACE
                when others => null;
              end case;

           -- <SHIFT> codes
            elsif shift_r = '1' and ctrl_r = '0' then
              case data(7 downto 0) is
                when X"6B" => key_code := X"08"; -- LEFT
                when X"0D" => key_code := X"09"; -- TAB
                when X"72" => key_code := X"0A"; -- DOWN
                when X"75" => key_code := X"0B"; -- UP
                when X"5A" => key_code := X"0D"; -- ENTER
                when X"74" => key_code := X"15"; -- RIGHT
                when X"76" => key_code := X"1B"; -- ESC
                when X"29" => key_code := X"20"; -- SPACE
                when X"52" => key_code := X"22"; -- ''"'
                when X"41" => key_code := X"CC"; -- ',<'
                when X"4E" => key_code := X"5F"; -- '-_'
                when X"49" => key_code := X"EE"; -- '.>'
                when X"4A" => key_code := X"3F"; -- '/?'
                when X"45" => key_code := X"29"; -- '0'
                when X"16" => key_code := X"21"; -- '1'
                when X"1E" => key_code := X"40"; -- '2'
                when X"26" => key_code := X"23"; -- '3'
                when X"25" => key_code := X"24"; -- '4'
                when X"2E" => key_code := X"25"; -- '5'
                when X"36" => key_code := X"5E"; -- '6'
                when X"3D" => key_code := X"26"; -- '7'
                when X"3E" => key_code := X"2A"; -- '8'
                when X"46" => key_code := X"28"; -- '9'
                when X"4C" => key_code := X"3A"; -- ';:'
                when X"55" => key_code := X"2B"; -- '=+'
                when X"54" => key_code := X"7B"; -- '[{'
                when X"5D" => key_code := X"7C"; -- '\|'
                when X"5B" => key_code := X"7D"; -- ']}'
                when X"0E" => key_code := X"7E"; -- '`~'
                when X"1C" => key_code := X"41"; -- 'A'
                when X"32" => key_code := X"42"; -- 'B'
                when X"21" => key_code := X"43"; -- 'C'
                when X"23" => key_code := X"44"; -- 'D'
                when X"24" => key_code := X"45"; -- 'E'
                when X"2B" => key_code := X"46"; -- 'F'
                when X"34" => key_code := X"47"; -- 'G'
                when X"33" => key_code := X"48"; -- 'H'
                when X"43" => key_code := X"49"; -- 'I'
                when X"3B" => key_code := X"4A"; -- 'J'
                when X"42" => key_code := X"4B"; -- 'K'
                when X"4B" => key_code := X"4C"; -- 'L'
                when X"3A" => key_code := X"4D"; -- 'M'
                when X"31" => key_code := X"4E"; -- 'N'
                when X"44" => key_code := X"4F"; -- 'O'
                when X"4D" => key_code := X"50"; -- 'P'
                when X"15" => key_code := X"51"; -- 'Q'
                when X"2D" => key_code := X"52"; -- 'R'
                when X"1B" => key_code := X"53"; -- 'S'
                when X"2C" => key_code := X"54"; -- 'T'
                when X"3C" => key_code := X"55"; -- 'U'
                when X"2A" => key_code := X"56"; -- 'V'
                when X"1D" => key_code := X"57"; -- 'W'
                when X"22" => key_code := X"58"; -- 'X'
                when X"35" => key_code := X"59"; -- 'Y'
                when X"1A" => key_code := X"5A"; -- 'Z'
                when X"66" => key_code := X"7F"; -- BACKSPACE
                when others => null;
              end case;
            end if;
            
            key_waiting := '1';

          end if; -- press = '1'
        end if;   -- control & shift
      end if;     -- (press or release) = '1'

    end if;       -- reset, rising_edge(clk)

    -- combine the keywaiting latch and the keycode
    inputs(0) <= key_waiting & key_code(6 downto 0);

  end process latchInputs;

end SYN;
