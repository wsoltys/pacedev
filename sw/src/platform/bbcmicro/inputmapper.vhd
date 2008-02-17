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
			jamma			: in JAMMAInputsType;

	    -- user outputs
			dips			: in std_logic_vector(7 downto 0);
			inputs		: out in8(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

begin

    latchInputs: process (clk, rst_n)

			variable ctrl		  : std_logic;
			variable esc		  : std_logic;
			
    begin

         -- note: all inputs are active HIGH

        if rst_n = '0' then
          inputs <= 
          (
            2 => (0=>'0', others =>'0'),  -- (not used)
            3 => (0=>'0', others =>'0'),  -- (not used)
            4 => (0=>'0', others =>'0'),  -- DISC-SPEED:1
            5 => (0=>'0', others =>'0'),  -- DISC-SPEED:0
            6 => (0=>'0', others =>'0'),  -- SHIFT-BREAK
            7 => (0=>'0', others =>'0'),  -- MODE:2
            8 => (0=>'0', others =>'0'),  -- MODE:1
            9 => (0=>'1', others =>'0'),  -- MODE:0
            others => (others => '0')
          );
          ctrl := '0';
          esc := '0';
        elsif rising_edge (clk) then
          if (press or release) = '1' then
               case data(7 downto 0) is
                  -- column 0
                  when SCANCODE_LSHIFT | SCANCODE_RSHIFT =>   -- "SHIFT"
                    inputs(0)(0) <= press;
                  when SCANCODE_Q =>              -- "Q"
                    inputs(0)(1) <= press;
                  --when SCANCODE_0_PAD =>          -- "F0"
                  --  inputs(0)(2) <= press;
                  when SCANCODE_1 =>              -- "1"
                    inputs(0)(3) <= press;
                  --when SCANCODE_CAPS =>           -- "CAPS LOCK"
                  --  inputs(0)(4) <= press;
                  when SCANCODE_LALT =>           -- "SHIFT LOCK"
                    inputs(0)(5) <= press;
                  when SCANCODE_TAB =>            -- "TAB"
                    inputs(0)(6) <= press;
                  when SCANCODE_ESC =>            -- "ESCAPE"
                    inputs(0)(7) <= press;
                    esc := press;
                  -- column 1
                  when SCANCODE_LCTRL =>          -- "CTRL"
                    inputs(1)(0) <= press;
                    ctrl := press;
                  when SCANCODE_3 =>              -- "3"
                    inputs(1)(1) <= press;
                  when SCANCODE_W =>              -- "W"
                    inputs(1)(2) <= press;
                  when SCANCODE_2 =>              -- "2"
                    inputs(1)(3) <= press;
                  when SCANCODE_A =>              -- "A"
                    inputs(1)(4) <= press;
                  when SCANCODE_S =>              -- "S"
                    inputs(1)(5) <= press;
                  when SCANCODE_Z =>              -- "Z"
                    inputs(1)(6) <= press;
                  --when SCANCODE_1_PAD =>          -- "F1"
                  --  inputs(1)(7) <= press;
                  -- column 2
                  when SCANCODE_4 =>              -- "4"
                    inputs(2)(1) <= press;
                  when SCANCODE_E =>              -- "E"
                    inputs(2)(2) <= press;
                  when SCANCODE_D =>              -- "D"
                    inputs(2)(3) <= press;
                  when SCANCODE_X =>              -- "X"
                    inputs(2)(4) <= press;
                  when SCANCODE_C =>              -- "C"
                    inputs(2)(5) <= press;
                  when SCANCODE_SPACE =>          -- " "
                    inputs(2)(6) <= press;
                  --when SCANCODE_2_PAD =>          -- "F2"
                  --  inputs(2)(7) <= press;
                  -- column 3
                  when SCANCODE_5 =>              -- "5"
                    inputs(3)(1) <= press;
                  when SCANCODE_T =>              -- "T"
                    inputs(3)(2) <= press;
                  when SCANCODE_R =>              -- "R"
                    inputs(3)(3) <= press;
                  when SCANCODE_F =>              -- "F"
                    inputs(3)(4) <= press;
                  when SCANCODE_G =>              -- "G"
                    inputs(3)(5) <= press;
                  when SCANCODE_V =>              -- "V"
                    inputs(3)(6) <= press;
                  --when SCANCODE_3_PAD =>          -- "F3"
                  --  inputs(3)(7) <= press;
                  -- column 4
                  --when SCANCODE_4_PAD =>          -- "F4"
                  --  inputs(4)(1) <= press;
                  when SCANCODE_7 =>              -- "7"
                    inputs(4)(2) <= press;
                  when SCANCODE_6 =>              -- "6"
                    inputs(4)(3) <= press;
                  when SCANCODE_Y =>              -- "Y"
                    inputs(4)(4) <= press;
                  when SCANCODE_H =>              -- "H"
                    inputs(4)(5) <= press;
                  when SCANCODE_B =>              -- "B"
                    inputs(4)(6) <= press;
                  --when SCANCODE_5_PAD =>          -- "F5"
                  --  inputs(4)(7) <= press;
                  -- column 5
                  when SCANCODE_8 =>              -- "8"
                    inputs(5)(1) <= press;
                  when SCANCODE_I =>              -- "I"
                    inputs(5)(2) <= press;
                  when SCANCODE_U =>              -- "U"
                    inputs(5)(3) <= press;
                  when SCANCODE_J =>              -- "J"
                    inputs(5)(4) <= press;
                  when SCANCODE_N =>              -- "N"
                    inputs(5)(5) <= press;
                  when SCANCODE_M =>              -- "M"
                    inputs(5)(6) <= press;
                  --when SCANCODE_6_PAD =>          -- "F6"
                  --  inputs(5)(7) <= press;
                  -- column 6
                  --when SCANCODE_7_PAD =>          -- "F7"
                  --  inputs(6)(1) <= press;
                  when SCANCODE_9 =>              -- "9"
                    inputs(6)(2) <= press;
                  when SCANCODE_O =>              -- "O" (letter O)
                    inputs(6)(3) <= press;
                  when SCANCODE_K =>              -- "K"
                    inputs(6)(4) <= press;
                  when SCANCODE_L =>              -- "L"
                    inputs(6)(5) <= press;
                  when SCANCODE_COMMA =>          -- ","
                    inputs(6)(6) <= press;
                  --when SCANCODE_8_PAD =>          -- "F8"
                  --  inputs(6)(7) <= press;
                  -- column 7
                  when SCANCODE_MINUS =>          -- "-"
                    inputs(7)(1) <= press;
                  when SCANCODE_0 =>              -- "0" (zero)
                    inputs(7)(2) <= press;
                  when SCANCODE_P =>              -- "P"
                    inputs(7)(3) <= press;
                  --when SCANCODE_BACKSLASH =>      -- "@"
                  --  inputs(7)(4) <= press;
                  when SCANCODE_SEMICOLON =>      -- ";"
                    inputs(7)(5) <= press;
                  when SCANCODE_PERIOD =>         -- "."
                    inputs(7)(6) <= press;
                  --when SCANCODE_9_PAD =>          -- "F9"
                  --  inputs(7)(7) <= press;
                  -- column 8
                  when SCANCODE_EQUALS =>         -- "^"
                    inputs(8)(1) <= press;
                  --when SCANCODE_TILDE =>          -- "_"
                  --  inputs(8)(2) <= press;
                  --when SCANCODE_OPENBRACE =>      -- "["
                  --  inputs(8)(3) <= press;
                  when SCANCODE_QUOTE =>          -- ":"
                    inputs(8)(4) <= press;
                  --when SCANCODE_CLOSEBRACE =>     -- "]"
                  --  inputs(8)(5) <= press;
                  when SCANCODE_SLASH =>          -- "/"
                    inputs(8)(6) <= press;
                  --when SCANCODE_9_BACKSLASH2 =>   -- "\\"
                  --  inputs(8)(7) <= press;
                  -- column 9
                  when SCANCODE_LEFT =>           -- "left"
                    inputs(9)(1) <= press;
                  when SCANCODE_DOWN =>           -- "down"
                    inputs(9)(2) <= press;
                  when SCANCODE_UP =>             -- "up"
                    inputs(9)(3) <= press;
                  when SCANCODE_ENTER =>          -- "return"
                    inputs(9)(4) <= press;
                  when SCANCODE_BACKSPACE =>      -- "delete"
                    inputs(9)(5) <= press;
                  --when SCANCODE_END =>            -- "copy"
                  --  inputs(9)(6) <= press;
                  when SCANCODE_RIGHT =>          -- "right"
                    inputs(9)(7) <= press;
                  when others =>
                    null;
               end case;
            end if; -- press or release
            if (reset = '1') then
              inputs <= 
              (
                2 => (0=>'0', others =>'0'),  -- (not used)
                3 => (0=>'0', others =>'0'),  -- (not used)
                4 => (0=>'0', others =>'0'),  -- DISC-SPEED:1
                5 => (0=>'0', others =>'0'),  -- DISC-SPEED:0
                6 => (0=>'0', others =>'0'),  -- SHIFT-BREAK
                7 => (0=>'0', others =>'0'),  -- MODE:2
                8 => (0=>'0', others =>'0'),  -- MODE:1
                9 => (0=>'1', others =>'0'),  -- MODE:0
                others => (others => '0')
              );
              ctrl := '0';
              esc := '0';
            end if;
					-- special keys
					inputs(16)(0) <= ctrl and esc;		-- game reset
        end if; -- rising_edge (clk)
    end process latchInputs;

end SYN;


