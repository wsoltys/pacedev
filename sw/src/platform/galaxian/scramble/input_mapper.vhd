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

  process (clk, rst_n)
    variable jamma_v	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    variable keybd_v 	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
  begin

       -- note: all inputs are active LOW

      if rst_n = '0' then
        for i in 0 to NUM_INPUTS-2 loop
          jamma_v(i).d := (others =>'1');
          keybd_v(i).d := (others =>'1');
        end loop;
        jamma_v(NUM_INPUTS-1).d := (others =>'0');
        keybd_v(NUM_INPUTS-1).d := (others =>'0');
        
      elsif rising_edge (clk) then

        -- handle JAMMA inputs
        jamma_v(0).d(0) := jamma.coin(1) and jamma.p(1).button(3);
        jamma_v(0).d(1) := jamma.coin(2);
        jamma_v(0).d(2) := jamma.p(1).left;
        jamma_v(0).d(3) := jamma.p(1).right;
        jamma_v(0).d(4) := jamma.p(1).button(1);
        jamma_v(0).d(6) := jamma.service;
        jamma_v(1).d(0) := jamma.p(1).start;
        jamma_v(1).d(1) := jamma.p(2).start;
        
        -- handle PS/2 inputs
        if (key_down or key_up) = '1' then
          case data(7 downto 0) is
            -- IN0
--            when SCANCODE_UP =>
--              keybd_v(0).d(0) := key_up;
            when SCANCODE_LALT =>
              keybd_v(0).d(1) := key_up;
            when SCANCODE_F2 =>
              keybd_v(0).d(2) := key_up;
            when SCANCODE_LCTRL =>
              keybd_v(0).d(3) := key_up;
            when SCANCODE_RIGHT =>
              keybd_v(0).d(4) := key_up;
            when SCANCODE_LEFT =>
              keybd_v(0).d(5) := key_up;
            when SCANCODE_6 =>
              keybd_v(0).d(6) := key_up;
            when SCANCODE_5 =>
              keybd_v(0).d(7) := key_up;
            -- IN1
            when SCANCODE_2 =>
              keybd_v(1).d(6) := key_up;
            when SCANCODE_1 =>
              keybd_v(1).d(7) := key_up;
            -- IN2
            when SCANCODE_UP =>
              keybd_v(2).d(4) := key_up;
            when SCANCODE_DOWN =>
              keybd_v(2).d(6) := key_up;
            -- special keys
            when SCANCODE_F3 =>   -- reset platform
              keybd_v(NUM_INPUTS-1).d(0) := key_down;
            when SCANCODE_P =>    -- pause CPU
              keybd_v(NUM_INPUTS-1).d(1) := key_down;
            when SCANCODE_F4 =>   -- rotate display
              keybd_v(NUM_INPUTS-1).d(2) := key_down;
            when others =>
          end case;
        end if; -- key_down or key_up

        -- this is PS/2 reset only
        if (reset = '1') then
          for i in 0 to NUM_INPUTS-2 loop
            keybd_v(i).d := (others => '1');
          end loop;
          -- special keys
          keybd_v(NUM_INPUTS-1).d := (others => '0');
        end if;
      end if; -- rising_edge (clk)

      -- assign outputs
      inputs(0).d <= jamma_v(0).d and keybd_v(0).d;
      -- LIVES 00=3, 01=4, 10=5, 11=255
      inputs(1).d <= (jamma_v(1).d(7 downto 2) and keybd_v(1).d(7 downto 2)) & "00";
      -- CABINET 00=upright, 08=cocktail
      -- COINAGE 00=1/1,2/1,1/1 02=1/2,1/1,1/2 04=1/3,3/1,1/3 06=1/4,4/1,1/4
      inputs(2).d <= (jamma_v(2).d(7 downto 4) and keybd_v(2).d(6 downto 4)) & "000" & (jamma_v(2).d(0) and keybd_v(2).d(0));
      inputs(NUM_INPUTS-1).d <= jamma_v(NUM_INPUTS-1).d or keybd_v(NUM_INPUTS-1).d;

  end process;

end architecture SYN;


