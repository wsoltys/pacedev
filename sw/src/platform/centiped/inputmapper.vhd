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

  begin

    -- note: all inputs are active LOW

    if rst_n = '0' then
      inputs(0).d <= "10101111";
      inputs(1).d <= (others => '1');
      inputs(2).d <= (others => '1');
    elsif rising_edge (clk) then
      if (key_down or key_up) = '1' then
        case data(7 downto 0) is
          -- IN0
          -- bit6 is vblank
          when SCANCODE_S =>
               inputs(0).d(5) <= key_up;

          -- IN1
          when SCANCODE_5 =>
               inputs(1).d(7) <= key_up;
          when SCANCODE_6 =>
               inputs(1).d(6) <= key_up;
          when SCANCODE_7 =>
               inputs(1).d(5) <= key_up;
          when SCANCODE_LCTRL =>
               inputs(1).d(2) <= key_up;
          when SCANCODE_2 =>
               inputs(1).d(1) <= key_up;
          when SCANCODE_1 =>
               inputs(1).d(0) <= key_up;

          when others =>
        end case;
      end if; -- key_down or key_up
      if (reset = '1') then
        inputs(0).d <= "10101111";
        inputs(1).d <= (others => '1');
        inputs(2).d <= (others => '1');
      end if;
    end if; -- rising_edge (clk)
  end process latchInputs;

end SYN;


