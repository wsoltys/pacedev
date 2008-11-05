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
    clk       : in     std_logic;
    rst_n     : in     std_logic;

    -- inputs from keyboard controller
    reset     : in     std_logic;
    press     : in     std_logic;
    release   : in     std_logic;
    data      : in     std_logic_vector(7 downto 0);
		-- JAMMA interface
		jamma			: in from_JAMMA_t;

    -- user outputs
    dips			: in		std_logic_vector(NUM_DIPS-1 downto 0);
    inputs		: out   from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
	);
	end inputmapper;

architecture SYN of inputmapper is

begin

    latchInputs: process (clk, rst_n)
			variable jamma_v : from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
			variable keybd_v : from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    begin

         -- note: all inputs are active LOW
        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-2 loop
						jamma_v(i).d := (others =>'1');
						keybd_v(i).d := (others =>'1');
					end loop;
          -- special keys
          jamma_v(NUM_INPUTS-1).d := (others => '1');
          keybd_v(NUM_INPUTS-1).d := (others => '0');	-- because we AND jamma,keybd

        elsif rising_edge (clk) then

					-- handle JAMMA inputs
					jamma_v(0).d(0) := jamma.p(1).up;
					jamma_v(1).d(0) := jamma.p(1).up;
					jamma_v(0).d(1) := jamma.p(1).down;
					jamma_v(1).d(1) := jamma.p(1).down;
					jamma_v(0).d(2) := jamma.p(1).left;
					jamma_v(1).d(2) := jamma.p(1).left;
					jamma_v(0).d(3) := jamma.p(1).right;
					jamma_v(1).d(3) := jamma.p(1).right;
					jamma_v(0).d(4) := jamma.coin(1);
					jamma_v(0).d(5) := jamma.coin(2);
					jamma_v(0).d(7) := jamma.p(1).button(1);
					jamma_v(1).d(4) := jamma.service;
					jamma_v(1).d(5) := jamma.p(1).start;
					jamma_v(1).d(6) := jamma.p(2).start;

          -- handle PS2 inputs
          if (press or release) = '1' then
          	case data(7 downto 0) is
            	-- IN0
              when SCANCODE_LCTRL =>
            		keybd_v(0).d(0) := release;
              when SCANCODE_RIGHT =>
                keybd_v(0).d(1) := release;
              when SCANCODE_5 =>
                keybd_v(0).d(2) := release;
              when SCANCODE_LEFT =>
                keybd_v(0).d(3) := release;
              when SCANCODE_UP =>
                keybd_v(0).d(4) := release;
              when SCANCODE_1 =>
                keybd_v(0).d(5) := release;
              when SCANCODE_LALT =>
                keybd_v(0).d(6) := release;
              --when SCANCODE_I =>
              --  keybd_v(0)(7) := release;
							-- special keys
							when SCANCODE_F3 =>
								keybd_v(1).d(0) := press;
							when SCANCODE_F4 =>
								keybd_v(1).d(1) := press;
              when others =>
								null;
            end case;
          end if; -- press or release

					-- this is PS/2 reset ONLY
          if (reset = '1') then
						for i in 0 to NUM_INPUTS-2 loop
							keybd_v(i).d := (others =>'1');
						end loop;
            -- special keys
            keybd_v(NUM_INPUTS-1).d := (others => '0');
          end if;
        end if; -- rising_edge (clk)

				-- assign outputs
				for i in 0 to NUM_INPUTS-1 loop
					inputs(i).d <= jamma_v(i).d and keybd_v(i).d;
				end loop;

    end process latchInputs;

end SYN;


