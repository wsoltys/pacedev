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

  signal pause  : std_logic;
  
begin

  latchInputs: process (clk, rst_n)

  begin

    -- note: all inputs are active HIGH

    if rst_n = '0' then
      for i in 0 to NUM_INPUTS-1 loop
        inputs(i).d <= (others =>'0');
      end loop;
      pause <= '0';
    elsif rising_edge (clk) then
      -- map the dipswitches
      if (press or release) = '1' then
        case data(7 downto 0) is
        
            -- IN0
            when SCANCODE_UP =>				-- up
              inputs(0).d(0) <= press;
            when SCANCODE_DOWN =>			-- down
              inputs(0).d(1) <= press;
            when SCANCODE_LEFT =>			-- left
              inputs(0).d(2) <= press;
            when SCANCODE_RIGHT =>		-- right
              inputs(0).d(3) <= press;
            when SCANCODE_1 =>				-- start1
              inputs(0).d(4) <= press;
            when SCANCODE_2 =>				-- start2
              inputs(0).d(5) <= press;
            when SCANCODE_W =>				-- fire up
              inputs(0).d(6) <= press;
            when SCANCODE_Z =>				-- fire down
              inputs(0).d(7) <= press;

            -- IN1
            when SCANCODE_A =>		    -- fire left
              inputs(1).d(0) <= press;
            when SCANCODE_S =>		    -- fire right
              inputs(1).d(1) <= press;
              
            -- IN2
            when SCANCODE_F1 =>				-- auto up
              inputs(2).d(0) <= press;
            when SCANCODE_F2 =>				-- advance
              inputs(2).d(1) <= press;
            when SCANCODE_7 =>				-- coin3
              inputs(2).d(2) <= press;
            when SCANCODE_9 =>				-- highscore reset
              inputs(2).d(3) <= press;
            when SCANCODE_5 =>				-- coin1
              inputs(2).d(4) <= press;
            when SCANCODE_6 =>				-- coin2
              inputs(2).d(5) <= press;

            -- special keys
            when SCANCODE_F3 =>				-- game reset
              inputs(3).d(0) <= press;
            when SCANCODE_P =>				-- pause (toggle)
              if press = '1' then
                pause <= not pause;
              end if;
              
            when others =>
        end case;
      end if; -- press or release

      if (reset = '1') then
        for i in 0 to NUM_INPUTS-1 loop
          inputs(i).d <= (others =>'0');
        end loop;
      end if;

    end if; -- rising_edge (clk)

    inputs(3).d(1) <= pause;

  end process latchInputs;

end SYN;
