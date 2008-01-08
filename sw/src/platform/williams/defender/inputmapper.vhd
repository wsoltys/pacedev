library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;

entity inputmapper is
	generic
	(
			NUM_INPUTS : positive := 2
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

    begin

         -- note: all inputs are active HIGH

        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-1 loop
						inputs(i) <= (others =>'0');
					end loop;
        elsif rising_edge (clk) then
          -- map the dipswitches
          if (press or release) = '1' then
               case data(7 downto 0) is
                    -- IN0
                    when SCANCODE_LCTRL =>		-- fire
                      inputs(0)(0) <= press;
                    when SCANCODE_LALT =>			-- thrust
                      inputs(0)(1) <= press;
                    when SCANCODE_SPACE =>		-- smart bomb
                      inputs(0)(2) <= press;
                    when SCANCODE_LSHIFT =>		-- hyperspace
                      inputs(0)(3) <= press;
                    when SCANCODE_2 =>				-- start2
                      inputs(0)(4) <= press;
                    when SCANCODE_1 =>				-- start1
                      inputs(0)(5) <= press;
                    when SCANCODE_Z =>				-- reverse
                      inputs(0)(6) <= press;
                    when SCANCODE_DOWN =>			-- down
                      inputs(0)(7) <= press;
                    -- IN1
                    when SCANCODE_UP =>				-- up
                      inputs(1)(0) <= press;
                    -- IN2
                    when SCANCODE_F1 =>				-- auto up
                      inputs(2)(0) <= press;
                    when SCANCODE_F2 =>				-- advance
                    	inputs(2)(1) <= press;
                    when SCANCODE_7 =>				-- coin3
                    	inputs(2)(2) <= press;
                    when SCANCODE_9 =>				-- highscore reset
                    	inputs(2)(3) <= press;
                    when SCANCODE_5 =>				-- coin1
                    	inputs(2)(4) <= press;
                    when SCANCODE_6 =>				-- coin2
                    	inputs(2)(5) <= press;
										-- special keys
										when SCANCODE_F3 =>				-- game reset
											inputs(3)(0) <= press;
                    when others =>
               end case;
            end if; -- press or release
            if (reset = '1') then
							for i in 0 to NUM_INPUTS-1 loop
								inputs(i) <= (others =>'0');
							end loop;
            end if;
        end if; -- rising_edge (clk)
    end process latchInputs;

end SYN;


