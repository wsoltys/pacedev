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
			NUM_INPUTS  : positive := 2
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
			-- inputs from JAMMA interface
			jamma			: in from_JAMMA_t;

	    -- user outputs
	    dips			: in std_logic_vector(NUM_DIPS-1 downto 0);
	    inputs		: out from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
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
          -- special keys (active high)
          jamma_v(NUM_INPUTS-1).d := (others => '0');
          keybd_v(NUM_INPUTS-1).d := (others => '1');	-- because we AND jamma,keybd

        elsif rising_edge (clk) then

					-- handle JAMMA inputs
					jamma_v(0).d(0) := jamma.p(1).up;
					jamma_v(0).d(1) := jamma.p(1).down;
					jamma_v(0).d(2) := jamma.p(1).left;
					jamma_v(0).d(3) := jamma.p(1).right;
					jamma_v(0).d(4) := jamma.p(1).button(1);
					jamma_v(1).d(0) := jamma.p(2).up;
					jamma_v(1).d(1) := jamma.p(2).down;
					jamma_v(1).d(2) := jamma.p(2).left;
					jamma_v(1).d(3) := jamma.p(2).right;
					jamma_v(1).d(4) := jamma.p(2).button(1);
					jamma_v(2).d(0) := jamma.p(1).start;
					jamma_v(2).d(1) := jamma.p(2).start;
					jamma_v(2).d(2) := jamma.coin(1);

          -- handle PS2 inputs
          if (key_down or key_up) = '1' then
          	case data(7 downto 0) is
            	-- Player 1, 2
              when SCANCODE_UP =>
            		keybd_v(0).d(0) := key_up;
            		keybd_v(1).d(0) := key_up;
              when SCANCODE_DOWN =>
                keybd_v(0).d(1) := key_up;
                keybd_v(1).d(1) := key_up;
              when SCANCODE_LEFT =>
                keybd_v(0).d(2) := key_up;
                keybd_v(1).d(2) := key_up;
              when SCANCODE_RIGHT =>
                keybd_v(0).d(3) := key_up;
                keybd_v(1).d(3) := key_up;
              when SCANCODE_LCTRL =>
                keybd_v(0).d(4) := key_up;
                keybd_v(1).d(4) := key_up;
              when SCANCODE_LALT =>
                keybd_v(0).d(5) := key_up;
                keybd_v(1).d(5) := key_up;
							-- other
              when SCANCODE_1 =>
                keybd_v(2).d(0) := key_up;
              when SCANCODE_2 =>
                keybd_v(2).d(1) := key_up;
              when SCANCODE_5 =>
                keybd_v(2).d(2) := key_up;
              when SCANCODE_6 =>
                keybd_v(2).d(3) := key_up;
              -- special keys (active high)
              when SCANCODE_F3 =>
                keybd_v(3).d(0) := key_down;
              when others =>
								null;
            end case;
          end if; -- key_down or key_up

					-- this is a PS/2 reset only
          if (reset = '1') then
						for i in 0 to NUM_INPUTS-2 loop
							keybd_v(i).d := (others =>'1');
						end loop;
            -- special keys (active high)
            keybd_v(NUM_INPUTS-1).d := (others => '0');
          end if;

        end if; -- rising_edge (clk)

				-- assign outputs
				for i in 0 to NUM_INPUTS-1 loop
					inputs(i).d <= jamma_v(i).d and keybd_v(i).d;
				end loop;
				
    end process latchInputs;

end SYN;
