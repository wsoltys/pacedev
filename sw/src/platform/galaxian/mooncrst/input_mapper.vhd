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
    -- input from jamma connector
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
      jamma_v(1).d(2) := jamma.p(1).left;
      jamma_v(0).d(3) := jamma.p(1).right;
      jamma_v(1).d(3) := jamma.p(1).right;
      jamma_v(0).d(4) := jamma.p(1).button(1);
      jamma_v(1).d(4) := jamma.p(1).button(1);
      jamma_v(1).d(0) := jamma.p(1).start;
      jamma_v(1).d(1) := jamma.p(2).start;
      
      -- handle PS/2 inputs
      keybd_v(0).d(6 downto 5) := not dips(7 downto 6); -- unknown/reset, cabinet
      keybd_v(1).d(7 downto 6) := not dips(5 downto 4); -- language, bonus life
      keybd_v(2).d(3 downto 0) := not dips(3 downto 0); -- coinage
      if (key_down or key_up) = '1' then
        case data(7 downto 0) is
          -- IN0
          when SCANCODE_5 =>
            keybd_v(0).d(0) := key_down;
          when SCANCODE_6 =>
            keybd_v(0).d(1) := key_down;
          when SCANCODE_LEFT =>
            keybd_v(0).d(2) := key_down;
            keybd_v(1).d(2) := key_down;
          when SCANCODE_RIGHT =>
            keybd_v(0).d(3) := key_down;
            keybd_v(1).d(3) := key_down;
          when SCANCODE_LCTRL =>
            keybd_v(0).d(4) := key_down;
            keybd_v(1).d(4) := key_down;
          -- IN1
          when SCANCODE_1 =>
            keybd_v(1).d(0) := key_down;
          when SCANCODE_2 =>
            keybd_v(1).d(1) := key_down;
          -- special keys
          when SCANCODE_F3 =>
            keybd_v(3).d(0) := key_down;
          when others =>
        end case;
      end if; -- key_down or key_up

      -- this is PS/2 reset ONLY
      if (reset = '1') then
        for i in 0 to NUM_INPUTS-1 loop
          keybd_v(i).d := (others => '0');
        end loop;
      end if;
    end if; -- rising_edge (clk)

    -- assign outputs
    for i in 0 to NUM_INPUTS-1 loop
      inputs(i).d <= not jamma_v(i).d or keybd_v(i).d;
    end loop;

  end process latchInputs;

end SYN;


