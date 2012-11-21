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
    variable jamma_v : from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    variable keybd_v : from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
  begin

    -- note: all inputs are active HIGH
    if rst_n = '0' then

      keybd_v(0).d := (others => '0'); 	-- controller 1
      keybd_v(1).d := (others => '0'); 	-- ignored
      keybd_v(2).d := "00001000"; 			-- signature joypad 1
      keybd_v(3).d := (others => '0'); 	-- controller 2
      keybd_v(4).d := (others => '0'); 	-- ignored
      --keybd_v(5) := "00000100"; 			-- signature joypad 2
      keybd_v(5).d := "00000000"; 			-- signature joypad 2 (disconnected)
      keybd_v(6).d := (others => '0');	-- special keys
      for i in 0 to NUM_INPUTS-1 loop
        jamma_v(i).d := (others => '0');
      end loop;

    elsif rising_edge (clk) then

      -- handle JAMMA inputs
      jamma_v(0).d(0) := not jamma.p(1).button(1);
      jamma_v(0).d(1) := not jamma.p(1).button(2);
      jamma_v(0).d(2) := not jamma.coin(1);
      jamma_v(0).d(3) := not jamma.p(1).start;
      jamma_v(0).d(4) := not jamma.p(1).up;
      jamma_v(0).d(5) := not jamma.p(1).down;
      jamma_v(0).d(6) := not jamma.p(1).left;
      jamma_v(0).d(7) := not jamma.p(1).right;

      -- handle PS2 inputs
      if (key_down or key_up) = '1' then
        case data(7 downto 0) is
          -- IN0
          when SCANCODE_LALT =>
            keybd_v(0).d(0) := key_down;
          when SCANCODE_LCTRL =>
            keybd_v(0).d(1) := key_down;
          when SCANCODE_5 | SCANCODE_TAB =>
            keybd_v(0).d(2) := key_down;
          when SCANCODE_1 | SCANCODE_ENTER =>
            keybd_v(0).d(3) := key_down;
          when SCANCODE_UP =>
            keybd_v(0).d(4) := key_down;
          when SCANCODE_DOWN =>
            keybd_v(0).d(5) := key_down;
          when SCANCODE_LEFT =>
            keybd_v(0).d(6) := key_down;
          when SCANCODE_RIGHT =>
            keybd_v(0).d(7) := key_down;
          -- special keys (active high)
          when SCANCODE_F3 =>
            keybd_v(NUM_INPUTS-1).d(0) := key_down;
          when SCANCODE_P =>
            keybd_v(NUM_INPUTS-1).d(1) := key_down;
          when others =>
            null;
        end case;
      end if; -- key_down or key_up

      -- this is a PS/2 reset only
      if (reset = '1') then
        for i in 0 to NUM_INPUTS-1 loop
          keybd_v(i).d := (others =>'0');
        end loop;
      end if;

    end if; -- rising_edge (clk)

    -- assign outputs
    for i in 0 to NUM_INPUTS-1 loop
      inputs(i).d <= keybd_v(i).d or jamma_v(i).d;
    end loop;
      
  end process latchInputs;

end SYN;


