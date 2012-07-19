library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.project_pkg.all;

entity inputmapper is
	generic
	(
    NUM_DIPS    : positive := 8;
    NUM_INPUTS	: positive := 2
	);
	port
	(
    clk       : in std_logic;
    rst_n     : in std_logic;

    -- inputs from keyboard controller
    reset     : in std_logic;
    key_down  : in std_logic;
    key_up    : in std_logic;
    data      : in std_logic_vector(7 downto 0);
    -- inputs from jamma interface
    jamma			: in from_JAMMA_t;

    -- user outputs
    dips			: in std_logic_vector(NUM_DIPS-1 downto 0);
    inputs		: out from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
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
            2 => (others => (0=>not BBC_STARTUP_OPT_NOT_USED(1), others =>'0')),
            3 => (others => (0=>not BBC_STARTUP_OPT_NOT_USED(0), others =>'0')),
            4 => (others => (0=>not BBC_STARTUP_OPT_DISK_SPEED(1), others =>'0')),
            5 => (others => (0=>not BBC_STARTUP_OPT_DISK_SPEED(0), others =>'0')),
            6 => (others => (0=>not BBC_STARTUP_OPT_SHIFT_BREAK, others =>'0')),
            7 => (others => (0=>not BBC_STARTUP_OPT_MODE(2), others =>'0')),
            8 => (others => (0=>not BBC_STARTUP_OPT_MODE(1), others =>'0')),
            9 => (others => (0=>not BBC_STARTUP_OPT_MODE(0), others =>'0')),
            others => ((others => (others => '0')))
          );
          ctrl := '0';
          esc := '0';
        elsif rising_edge (clk) then
          if (key_down or key_up) = '1' then
               case data(7 downto 0) is
                  -- column 0
                  when SCANCODE_LSHIFT | SCANCODE_RSHIFT =>   -- "SHIFT"
                    inputs(0).d(0) <= key_down;
                  when SCANCODE_Q =>              -- "Q"
                    inputs(0).d(1) <= key_down;
                  when SCANCODE_PAD0 =>           -- "F0"
                    inputs(0).d(2) <= key_down;
                  when SCANCODE_1 =>              -- "1"
                    inputs(0).d(3) <= key_down;
                  when SCANCODE_CAPSLOCK =>       -- "CAPS LOCK"
                    inputs(0).d(4) <= key_down;
                  when SCANCODE_LALT =>           -- "SHIFT LOCK"
                    inputs(0).d(5) <= key_down;
                  when SCANCODE_TAB =>            -- "TAB"
                    inputs(0).d(6) <= key_down;
                  when SCANCODE_ESC =>            -- "ESCAPE"
                    inputs(0).d(7) <= key_down;
                    esc := key_down;
                  -- column 1
                  when SCANCODE_LCTRL =>          -- "CTRL"
                    inputs(1).d(0) <= key_down;
                    ctrl := key_down;
                  when SCANCODE_3 =>              -- "3"
                    inputs(1).d(1) <= key_down;
                  when SCANCODE_W =>              -- "W"
                    inputs(1).d(2) <= key_down;
                  when SCANCODE_2 =>              -- "2"
                    inputs(1).d(3) <= key_down;
                  when SCANCODE_A =>              -- "A"
                    inputs(1).d(4) <= key_down;
                  when SCANCODE_S =>              -- "S"
                    inputs(1).d(5) <= key_down;
                  when SCANCODE_Z =>              -- "Z"
                    inputs(1).d(6) <= key_down;
                  when SCANCODE_PAD1 =>           -- "F1"
                    inputs(1).d(7) <= key_down;
                  -- column 2
                  when SCANCODE_4 =>              -- "4"
                    inputs(2).d(1) <= key_down;
                  when SCANCODE_E =>              -- "E"
                    inputs(2).d(2) <= key_down;
                  when SCANCODE_D =>              -- "D"
                    inputs(2).d(3) <= key_down;
                  when SCANCODE_X =>              -- "X"
                    inputs(2).d(4) <= key_down;
                  when SCANCODE_C =>              -- "C"
                    inputs(2).d(5) <= key_down;
                  when SCANCODE_SPACE =>          -- " "
                    inputs(2).d(6) <= key_down;
                  when SCANCODE_PAD2 =>           -- "F2"
                    inputs(2).d(7) <= key_down;
                  -- column 3
                  when SCANCODE_5 =>              -- "5"
                    inputs(3).d(1) <= key_down;
                  when SCANCODE_T =>              -- "T"
                    inputs(3).d(2) <= key_down;
                  when SCANCODE_R =>              -- "R"
                    inputs(3).d(3) <= key_down;
                  when SCANCODE_F =>              -- "F"
                    inputs(3).d(4) <= key_down;
                  when SCANCODE_G =>              -- "G"
                    inputs(3).d(5) <= key_down;
                  when SCANCODE_V =>              -- "V"
                    inputs(3).d(6) <= key_down;
                  when SCANCODE_PAD3 =>           -- "F3"
                    inputs(3).d(7) <= key_down;
                  -- column 4
                  when SCANCODE_PAD4 =>           -- "F4"
                    inputs(4).d(1) <= key_down;
                  when SCANCODE_7 =>              -- "7"
                    inputs(4).d(2) <= key_down;
                  when SCANCODE_6 =>              -- "6"
                    inputs(4).d(3) <= key_down;
                  when SCANCODE_Y =>              -- "Y"
                    inputs(4).d(4) <= key_down;
                  when SCANCODE_H =>              -- "H"
                    inputs(4).d(5) <= key_down;
                  when SCANCODE_B =>              -- "B"
                    inputs(4).d(6) <= key_down;
                  when SCANCODE_PAD5 =>           -- "F5"
                    inputs(4).d(7) <= key_down;
                  -- column 5
                  when SCANCODE_8 =>              -- "8"
                    inputs(5).d(1) <= key_down;
                  when SCANCODE_I =>              -- "I"
                    inputs(5).d(2) <= key_down;
                  when SCANCODE_U =>              -- "U"
                    inputs(5).d(3) <= key_down;
                  when SCANCODE_J =>              -- "J"
                    inputs(5).d(4) <= key_down;
                  when SCANCODE_N =>              -- "N"
                    inputs(5).d(5) <= key_down;
                  when SCANCODE_M =>              -- "M"
                    inputs(5).d(6) <= key_down;
                  when SCANCODE_PAD6 =>           -- "F6"
                    inputs(5).d(7) <= key_down;
                  -- column 6
                  when SCANCODE_PAD7 =>           -- "F7"
                    inputs(6).d(1) <= key_down;
                  when SCANCODE_9 =>              -- "9"
                    inputs(6).d(2) <= key_down;
                  when SCANCODE_O =>              -- "O" (letter O)
                    inputs(6).d(3) <= key_down;
                  when SCANCODE_K =>              -- "K"
                    inputs(6).d(4) <= key_down;
                  when SCANCODE_L =>              -- "L"
                    inputs(6).d(5) <= key_down;
                  when SCANCODE_COMMA =>          -- ","
                    inputs(6).d(6) <= key_down;
                  when SCANCODE_PAD8 =>           -- "F8"
                    inputs(6).d(7) <= key_down;
                  -- column 7
                  when SCANCODE_MINUS =>          -- "-"
                    inputs(7).d(1) <= key_down;
                  when SCANCODE_0 =>              -- "0" (zero)
                    inputs(7).d(2) <= key_down;
                  when SCANCODE_P =>              -- "P"
                    inputs(7).d(3) <= key_down;
                  when SCANCODE_BACKSLASH =>      -- "@"
                    inputs(7).d(4) <= key_down;
                  when SCANCODE_SEMICOLON =>      -- ";"
                    inputs(7).d(5) <= key_down;
                  when SCANCODE_PERIOD =>         -- "."
                    inputs(7).d(6) <= key_down;
                  when SCANCODE_PAD9 =>           -- "F9"
                    inputs(7).d(7) <= key_down;
                  -- column 8
                  when SCANCODE_EQUALS =>         -- "^"
                    inputs(8).d(1) <= key_down;
                  when SCANCODE_TILDE =>          -- "_"
                    inputs(8).d(2) <= key_down;
                  when SCANCODE_OPENBRACE =>      -- "["
                    inputs(8).d(3) <= key_down;
                  when SCANCODE_QUOTE =>          -- ":"
                    inputs(8).d(4) <= key_down;
                  when SCANCODE_CLOSEBRACE =>     -- "]"
                    inputs(8).d(5) <= key_down;
                  when SCANCODE_SLASH =>          -- "/"
                    inputs(8).d(6) <= key_down;
                  --when SCANCODE_9_BACKSLASH2 =>   -- "\\"
                  --  inputs(8)(7) <= key_down;
                  -- column 9
                  --when SCANCODE_LEFT =>           -- "left"
                  --  inputs(9)(1) <= key_down;
                  --when SCANCODE_DOWN =>           -- "down"
                  --  inputs(9)(2) <= key_down;
                  --when SCANCODE_UP =>             -- "up"
                  --  inputs(9)(3) <= key_down;
                  when SCANCODE_ENTER =>          -- "return"
                    inputs(9).d(4) <= key_down;
                  when SCANCODE_BACKSPACE =>      -- "delete"
                    inputs(9).d(5) <= key_down;
                  --when SCANCODE_END =>            -- "copy"
                  --  inputs(9)(6) <= key_down;
                  --when SCANCODE_RIGHT =>          -- "right"
                  --  inputs(9)(7) <= key_down;
                  when others =>
                    null;
               end case;
            end if; -- key_down or key_up
            if (reset = '1') then
              inputs <= 
              (
                2 => (others => (0=>not BBC_STARTUP_OPT_NOT_USED(1), others =>'0')),
                3 => (others => (0=>not BBC_STARTUP_OPT_NOT_USED(0), others =>'0')),
                4 => (others => (0=>not BBC_STARTUP_OPT_DISK_SPEED(1), others =>'0')),
                5 => (others => (0=>not BBC_STARTUP_OPT_DISK_SPEED(0), others =>'0')),
                6 => (others => (0=>not BBC_STARTUP_OPT_SHIFT_BREAK, others =>'0')),
                7 => (others => (0=>not BBC_STARTUP_OPT_MODE(2), others =>'0')),
                8 => (others => (0=>not BBC_STARTUP_OPT_MODE(1), others =>'0')),
                9 => (others => (0=>not BBC_STARTUP_OPT_MODE(0), others =>'0')),
                others => ((others => (others => '0')))
              );
              ctrl := '0';
              esc := '0';
            end if;
					-- special keys
					inputs(16).d(0) <= ctrl and esc;		-- game reset
        end if; -- rising_edge (clk)
    end process latchInputs;

end SYN;


