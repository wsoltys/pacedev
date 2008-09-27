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
		NUM_INPUTS  : integer := 2
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
			-- inputs from jamma connector
			jamma			: in from_JAMMA_t;

	    -- user outputs
	    dips			: in	std_logic_vector(NUM_DIPS-1 downto 0);
	    inputs		: out from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

begin

    latchInputs: process (clk, rst_n)
			variable jamma_v	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
			variable keybd_v 	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    begin

         -- note: all inputs are active HIGH

        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-1 loop
						jamma_v(i).d := (others =>'1');
						keybd_v(i).d := (others =>'0');
					end loop;
					
        elsif rising_edge (clk) then

					-- handle JAMMA inputs
					jamma_v(0).d(0) := jamma.coin(1);
					jamma_v(0).d(1) := jamma.coin(2);
					jamma_v(0).d(2) := jamma.p(1).left;
					jamma_v(0).d(3) := jamma.p(1).right;
					jamma_v(0).d(4) := jamma.p(1).button(1);
					jamma_v(0).d(6) := jamma.service;
					jamma_v(1).d(0) := jamma.p(1).start;
					jamma_v(1).d(1) := jamma.p(2).start;
					
					-- handle PS/2 inputs
          if (press or release) = '1' then
          	case data(7 downto 0) is
            	-- IN0
              when SCANCODE_5 =>
              	keybd_v(0).d(0) := press;
              when SCANCODE_6 =>
                keybd_v(0).d(1) := press;
              when SCANCODE_LEFT =>
                keybd_v(0).d(2) := press;
              when SCANCODE_RIGHT =>
                keybd_v(0).d(3) := press;
              when SCANCODE_LCTRL =>
                keybd_v(0).d(4) := press;
              when SCANCODE_S =>
                keybd_v(0).d(6) := press;
              -- IN1
              when SCANCODE_1 =>
                keybd_v(1).d(0) := press;
              when SCANCODE_2 =>
                keybd_v(1).d(1) := press;
              when others =>
            end case;
          end if; -- press or release

					-- this is PS/2 reset only
          if (reset = '1') then
						for i in 0 to NUM_INPUTS-1 loop
							keybd_v(i).d := (others =>'0');
						end loop;
           end if;
        end if; -- rising_edge (clk)

				-- assign outputs
				for i in 0 to NUM_INPUTS-1 loop
					inputs(i).d <= not jamma_v(i).d or keybd_v(i).d;
				end loop;

    end process latchInputs;

end architecture SYN;


