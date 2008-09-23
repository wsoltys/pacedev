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
			jamma			: in from_JAMMA_t;

	    -- user outputs
	    dips			: in std_logic_vector(7 downto 0);
	    inputs		: out in8(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

begin

    latchInputs: process (clk, rst_n)
    begin
         -- note: all inputs are active LOW
        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-2 loop
						inputs(i) <= (others =>'1');
					end loop;
					inputs(NUM_INPUTS-1) <= (others =>'0');
        elsif rising_edge (clk) then
          -- map the dipswitches
          if (press or release) = '1' then
          	case data(7 downto 0) is
            	-- IN0
              when SCANCODE_5 =>				-- coin1
              	inputs(0)(0) <= release;
              when SCANCODE_6 =>				-- coin2
                inputs(0)(1) <= release;
              when SCANCODE_9 =>				-- service
                inputs(0)(2) <= release;
              when SCANCODE_1 =>				-- start1
                inputs(0)(3) <= release;
              when SCANCODE_2 =>				-- start2
                inputs(0)(4) <= release;
              -- IN1
              when SCANCODE_LEFT =>			-- left
                inputs(1)(0) <= release;
              when SCANCODE_RIGHT =>		-- right
                inputs(1)(1) <= release;
              when SCANCODE_UP =>				-- up
                inputs(1)(2) <= release;
              when SCANCODE_DOWN =>			-- down
                inputs(1)(3) <= release;
              when SCANCODE_LCTRL =>		-- button1
                inputs(1)(4) <= release;
              when SCANCODE_LALT =>			-- button2
                inputs(1)(5) <= release;
              when SCANCODE_SPACE =>		-- button3
                inputs(1)(6) <= release;
              -- IN2
							-- T.B.D. (cocktail controls)
							-- special keys
							when SCANCODE_F3 =>				-- game reset
								inputs(3)(0) <= press;
              when others =>
            end case;
          end if; -- press or release
          if (reset = '1') then
						for i in 0 to NUM_INPUTS-2 loop
							inputs(i) <= (others =>'1');
						end loop;
          end if;
        end if; -- rising_edge (clk)
    end process latchInputs;

end SYN;


