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
begin

  latchInputs: process (clk, rst_n)
    variable service  : std_logic;
    variable pause    : std_logic;
  begin

    -- note: all inputs (except service) are active HIGH

    if rst_n = '0' then
      for i in 0 to NUM_INPUTS-1 loop
        inputs(i).d <= (others =>'0');
      end loop;
      pause := '0';
      service := '1';
    elsif rising_edge (clk) then
      -- map the dipswitches
      if (key_down or key_up) = '1' then
        case data(7 downto 0) is
        
            -- IN1
            when SCANCODE_1 =>        -- 1P start
              inputs(0).d(0) <= key_down;
            when SCANCODE_2 =>		    -- 2P start
              inputs(0).d(1) <= key_down;
            when SCANCODE_5 =>		    -- coin 1
              inputs(0).d(2) <= key_down;
            when SCANCODE_6 =>				-- coin 2
              inputs(0).d(3) <= key_down;
            when SCANCODE_F2 =>				-- service
              if key_down = '1' then
                service := not service;
              end if;
            when SCANCODE_F1 =>				-- select
              inputs(0).d(7) <= key_down;

            -- IN4
            when SCANCODE_RIGHT =>
              inputs(3).d(0) <= key_down;
            when SCANCODE_LEFT =>
              inputs(3).d(1) <= key_down;
            when SCANCODE_UP =>
              inputs(3).d(2) <= key_down;
            when SCANCODE_DOWN =>
              inputs(3).d(3) <= key_down;
          when SCANCODE_L =>
              inputs(3).d(4) <= key_down;
            when SCANCODE_J =>
              inputs(3).d(5) <= key_down;
            when SCANCODE_I =>
              inputs(3).d(6) <= key_down;
            when SCANCODE_K =>
              inputs(3).d(7) <= key_down;

              -- special keys
            when SCANCODE_F3 =>				-- game reset
              inputs(3).d(0) <= key_down;
            when SCANCODE_P =>				-- pause (toggle)
              if key_down = '1' then
                pause := not pause;
              end if;
              
            when others =>
        end case;
      end if; -- key_down or key_up

      if (reset = '1') then
        for i in 0 to NUM_INPUTS-1 loop
          inputs(i).d <= (others =>'0');
        end loop;
      end if;

    end if; -- rising_edge (clk)

    inputs(0).d(6) <= service;
    inputs(NUM_INPUTS-1).d(1) <= pause;

  end process latchInputs;

end SYN;
