library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;

entity inputmapper is
	generic
	(
    NUM_DIPS    : integer := 8;
		NUM_INPUTS	: integer := 2
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
			dips			: in std_logic_vector(NUM_DIPS-1 downto 0);
			inputs		: out from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

begin

    latchInputs: process (clk, rst_n)

			variable ctrl		: std_logic;
			variable esc		: std_logic;
			
    begin

         -- note: all inputs are active HIGH

        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-1 loop
						inputs(i).d <= (others => '0');
					end loop;
					ctrl := '0';
					esc := '0';
        elsif rising_edge (clk) then
          if (press or release) = '1' then
               case data(7 downto 0) is
                    -- row 0
                    when SCANCODE_BACKQUOTE =>			-- TRS(@)
                      inputs(0).d(0) <= press;
                    when SCANCODE_A =>
                      inputs(0).d(1) <= press;
                    when SCANCODE_B =>
                      inputs(0).d(2) <= press;
                    when SCANCODE_C =>
                      inputs(0).d(3) <= press;
                    when SCANCODE_D =>
                      inputs(0).d(4) <= press;
                    when SCANCODE_E =>
                      inputs(0).d(5) <= press;
                    when SCANCODE_F =>
                      inputs(0).d(6) <= press;
                    when SCANCODE_G =>
                      inputs(0).d(7) <= press;
                    -- row 1
                    when SCANCODE_H =>
                      inputs(1).d(0) <= press;
                    when SCANCODE_I =>
                      inputs(1).d(1) <= press;
                    when SCANCODE_J =>
                      inputs(1).d(2) <= press;
                    when SCANCODE_K =>
                      inputs(1).d(3) <= press;
                    when SCANCODE_L =>
                      inputs(1).d(4) <= press;
                    when SCANCODE_M =>
                      inputs(1).d(5) <= press;
                    when SCANCODE_N =>
                      inputs(1).d(6) <= press;
                    when SCANCODE_O =>
                      inputs(1).d(7) <= press;
                    -- row 2
                    when SCANCODE_P =>
                      inputs(2).d(0) <= press;
                    when SCANCODE_Q =>
                      inputs(2).d(1) <= press;
                    when SCANCODE_R =>
                      inputs(2).d(2) <= press;
                    when SCANCODE_S =>
                      inputs(2).d(3) <= press;
                    when SCANCODE_T =>
                      inputs(2).d(4) <= press;
                    when SCANCODE_U =>
                      inputs(2).d(5) <= press;
                    when SCANCODE_V =>
                      inputs(2).d(6) <= press;
                    when SCANCODE_W =>
                      inputs(2).d(7) <= press;
                    -- row 3
                    when SCANCODE_X =>
                      inputs(3).d(0) <= press;
                    when SCANCODE_Y =>
                      inputs(3).d(1) <= press;
                    when SCANCODE_Z =>
                      inputs(3).d(2) <= press;
                    -- row 4
                    when SCANCODE_0 =>
                      inputs(4).d(0) <= press;
                    when SCANCODE_1 =>
                      inputs(4).d(1) <= press;
                    when SCANCODE_2 =>
                      inputs(4).d(2) <= press;
                    when SCANCODE_3 =>
                      inputs(4).d(3) <= press;
                    when SCANCODE_4 =>
                      inputs(4).d(4) <= press;
                    when SCANCODE_5 =>
                      inputs(4).d(5) <= press;
                    when SCANCODE_6 =>
                      inputs(4).d(6) <= press;
                    when SCANCODE_7 =>
                      inputs(4).d(7) <= press;
                    -- row 5
                    when SCANCODE_8 =>
                      inputs(5).d(0) <= press;
                    when SCANCODE_9 =>
                      inputs(5).d(1) <= press;
                    when SCANCODE_QUOTE =>					-- TRS(:)
                      inputs(5).d(2) <= press;
                    when SCANCODE_SEMICOLON =>
                      inputs(5).d(3) <= press;
                    when SCANCODE_COMMA =>
                      inputs(5).d(4) <= press;
                    when SCANCODE_MINUS =>        	-- TRS(_)
                      inputs(5).d(5) <= press;
                    when SCANCODE_PERIOD =>
                      inputs(5).d(6) <= press;
                    when SCANCODE_SLASH =>
                      inputs(5).d(7) <= press;
                    -- row 6
                    when SCANCODE_ENTER =>
                      inputs(6).d(0) <= press;
                    when SCANCODE_HOME =>						-- (EX)TRS(CLR)
                      inputs(6).d(1) <= press;
                    when SCANCODE_INS =>           	-- (EX)TRS(BREAK)
                      inputs(6).d(2) <= press;
                    when SCANCODE_UP =>
                      inputs(6).d(3) <= press;
                    when SCANCODE_DOWN =>
                      inputs(6).d(4) <= press;
                    when SCANCODE_LEFT =>
                      inputs(6).d(5) <= press;
                    when SCANCODE_BACKSPACE =>
                      inputs(6).d(5) <= press;
                    when SCANCODE_RIGHT =>
                      inputs(6).d(6) <= press;
                    when SCANCODE_SPACE =>
                      inputs(6).d(7) <= press;
                    -- row 7
                    when SCANCODE_LSHIFT =>
                      inputs(7).d(0) <= press;
                    when SCANCODE_RSHIFT =>
											inputs(7).d(1) <= press;
										-- special keys
										when SCANCODE_LCTRL =>
											ctrl := press;
										when SCANCODE_ESC =>
											esc := press;
                    when SCANCODE_TAB =>
                      inputs(8).d(1) <= press;
                    when others =>
               end case;
            end if; -- press or release
            if (reset = '1') then
							for i in 0 to NUM_INPUTS-1 loop
								inputs(i).d <= (others => '0');
							end loop;
            end if;
					-- special keys
					inputs(8).d(0) <= ctrl and esc;		-- game reset
        end if; -- rising_edge (clk)
    end process latchInputs;

end architecture SYN;
