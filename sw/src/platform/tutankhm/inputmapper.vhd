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
    key_down  : in std_logic;
    key_up    : in std_logic;
    data      : in std_logic_vector(7 downto 0);
    -- inputs from jamma connector
    jamma			: in from_JAMMA_t;

    -- user outputs
    dips			: in	std_logic_vector(NUM_DIPS-1 downto 0);
    inputs		: out from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

  signal pause  : std_logic;
  
begin

    latchInputs: process (clk, rst_n)
    begin
         -- note: all inputs are active LOW
        if rst_n = '0' then
					for i in 0 to NUM_INPUTS-2 loop
						inputs(i).d <= (others =>'1');
					end loop;
					inputs(NUM_INPUTS-1).d <= (others =>'0');
          pause <= '0';
        elsif rising_edge (clk) then
          -- map the dipswitches
          if (key_down or key_up) = '1' then
          	case data(7 downto 0) is
            	-- IN0
              when SCANCODE_5 =>				-- coin1
              	inputs(0).d(0) <= key_up;
              when SCANCODE_6 =>				-- coin2
                inputs(0).d(1) <= key_up;
              when SCANCODE_9 =>				-- service
                inputs(0).d(2) <= key_up;
              when SCANCODE_1 =>				-- start1
                inputs(0).d(3) <= key_up;
              when SCANCODE_2 =>				-- start2
                inputs(0).d(4) <= key_up;
              -- IN1
              when SCANCODE_LEFT =>			-- left
                inputs(1).d(0) <= key_up;
              when SCANCODE_RIGHT =>		-- right
                inputs(1).d(1) <= key_up;
              when SCANCODE_UP =>				-- up
                inputs(1).d(2) <= key_up;
              when SCANCODE_DOWN =>			-- down
                inputs(1).d(3) <= key_up;
              when SCANCODE_LCTRL =>		-- button1
                inputs(1).d(4) <= key_up;
              when SCANCODE_LALT =>			-- button2
                inputs(1).d(5) <= key_up;
              when SCANCODE_SPACE =>		-- button3
                inputs(1).d(6) <= key_up;
              -- IN2
							-- T.B.D. (cocktail controls)
							-- special keys
							when SCANCODE_F3 =>				-- game reset
								inputs(3).d(0) <= key_down;
							when SCANCODE_P =>				-- pause (toggle)
                if key_down = '1' then
                  pause <= not pause;
                end if;
              when others =>
            end case;
          end if; -- key_down or key_up
          if (reset = '1') then
						for i in 0 to NUM_INPUTS-2 loop
							inputs(i).d <= (others =>'1');
						end loop;
          end if;
        end if; -- rising_edge (clk)
        inputs(3).d(1) <= pause;
    end process latchInputs;

end SYN;
