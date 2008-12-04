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

         -- note: all inputs are active LOW

        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-1 loop
						jamma_v(i).d := (others =>'1');
						keybd_v(i).d := (others =>'1');
					end loop;
					
        elsif rising_edge (clk) then

					-- handle JAMMA inputs

					jamma_v(0).d(0) := jamma.p(1).up;
					jamma_v(0).d(1) := jamma.p(1).down;
					jamma_v(0).d(2) := jamma.p(1).left;
					jamma_v(0).d(3) := jamma.p(1).right;
					jamma_v(0).d(4) := jamma.p(1).button(1);
					jamma_v(0).d(5) := jamma.p(1).button(2);
					jamma_v(0).d(6) := jamma.p(1).button(3);
					jamma_v(0).d(7) := jamma.p(1).button(4);

					jamma_v(1).d(0) := jamma.p(2).up;
					jamma_v(1).d(1) := jamma.p(2).down;
					jamma_v(1).d(2) := jamma.p(2).left;
					jamma_v(1).d(3) := jamma.p(2).right;
					jamma_v(1).d(4) := jamma.p(2).button(1);
					jamma_v(1).d(5) := jamma.p(2).button(2);
					jamma_v(1).d(6) := jamma.p(2).button(3);
					jamma_v(1).d(7) := jamma.p(2).button(4);

					jamma_v(2).d(0) := jamma.coin(1);
					jamma_v(2).d(1) := jamma.coin(2);
					jamma_v(2).d(2) := jamma.service;

					jamma_v(3).d(0) := jamma.p(1).start;
					jamma_v(3).d(1) := jamma.p(1).button(5);
					jamma_v(3).d(2) := jamma.p(2).start;
					jamma_v(3).d(3) := jamma.p(2).button(5);
					
					-- handle PS/2 inputs
          if (press or release) = '1' then
          	case data(7 downto 0) is
            
            	-- IN0 - REG_P1CNT (ACTIVE LOW)
              when SCANCODE_UP =>
              	keybd_v(0).d(0) := release;
              when SCANCODE_DOWN =>
                keybd_v(0).d(1) := release;
              when SCANCODE_LEFT =>
                keybd_v(0).d(2) := release;
              when SCANCODE_RIGHT =>
                keybd_v(0).d(3) := release;
              when SCANCODE_LCTRL =>
                keybd_v(0).d(4) := release;
              when SCANCODE_LALT =>
                keybd_v(0).d(5) := release;
              when SCANCODE_SPACE =>
                keybd_v(0).d(6) := release;
              when SCANCODE_LSHIFT =>
                keybd_v(0).d(7) := release;
                
              -- IN1 - REG_P2CNT (ACTIVE LOW)
              when SCANCODE_R =>
              	keybd_v(1).d(0) := release;
              when SCANCODE_F =>
                keybd_v(1).d(1) := release;
              when SCANCODE_D =>
                keybd_v(1).d(2) := release;
              when SCANCODE_G =>
                keybd_v(1).d(3) := release;
              when SCANCODE_A =>
                keybd_v(1).d(4) := release;
              when SCANCODE_S =>
                keybd_v(1).d(5) := release;
              when SCANCODE_Q =>
                keybd_v(1).d(6) := release;
              when SCANCODE_W =>
                keybd_v(1).d(7) := release;
                
              -- IN2 - SYSSTAT_A (ACTIVE LOW)
              when SCANCODE_5 =>
                keybd_v(2).d(0) := release;
              when SCANCODE_6 =>
                keybd_v(2).d(1) := release;
              when SCANCODE_9 =>
                keybd_v(2).d(2) := release;

              -- IN3 - SYSSTAT_B (ACTIVE LOW)
              when SCANCODE_1 =>
                keybd_v(3).d(0) := release;
              when SCANCODE_Z =>
                keybd_v(3).d(1) := release;
              when SCANCODE_2 =>
                keybd_v(3).d(2) := release;
              when SCANCODE_E =>
                keybd_v(3).d(3) := release;

              when others =>
            end case;
          end if; -- press or release

					-- this is PS/2 reset only
          if (reset = '1') then
						for i in 0 to NUM_INPUTS-1 loop
							keybd_v(i).d := (others =>'1');
						end loop;
           end if;
        end if; -- rising_edge (clk)

				-- assign outputs
				for i in 0 to NUM_INPUTS-1 loop
					inputs(i).d <= jamma_v(i).d and keybd_v(i).d;
				end loop;

    end process latchInputs;

end architecture SYN;


