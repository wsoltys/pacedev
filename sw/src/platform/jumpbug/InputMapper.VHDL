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
	    clk       : in     std_logic;
	    rst_n     : in     std_logic;

	    -- inputs from keyboard controller
	    reset     : in     std_logic;
	    press     : in     std_logic;
	    release   : in     std_logic;
	    data      : in     std_logic_vector(7 downto 0);
			-- inputs from JAMMA interface
			jamma			: in JAMMAInputsType;

	    -- user outputs
	    dips			: in		std_logic_vector(7 downto 0);
	    inputs		: out   in8(0 to NUM_INPUTS-1)
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
                    when SCANCODE_5 =>
                         inputs(0)(0) <= press;
                    when SCANCODE_6 =>
                         inputs(0)(1) <= press;
                    when SCANCODE_LEFT =>
                         inputs(0)(2) <= press;
                    when SCANCODE_RIGHT =>
                         inputs(0)(3) <= press;
                    when SCANCODE_LCTRL =>
                         inputs(0)(4) <= press;
                    when SCANCODE_UP =>
                         inputs(0)(5) <= press;
                    when SCANCODE_DOWN =>
                         inputs(0)(6) <= press;
                    -- IN1
                    when SCANCODE_1 =>
                         inputs(1)(0) <= press;
                    when SCANCODE_2 =>
                         inputs(1)(1) <= press;
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


