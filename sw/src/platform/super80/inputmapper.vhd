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
		NUM_INPUTS	: integer := 2
	);
	port
	(
	    clk       : in std_logic;
	    rst_n     : in std_logic;

	    -- inputs from keyboard controller
	    reset     : in std_logic;
	    key_up    : in std_logic;
	    key_down  : in std_logic;
	    data      : in std_logic_vector(7 downto 0);
			-- inputs from jamma interface
			jamma			: in from_JAMMA_t;

	    -- user outputs
			dips			: in std_logic_vector(NUM_DIPS-1 downto 0);
			inputs		: out from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
	);
end inputmapper;

architecture SYN of inputmapper is

  alias keymap  : std_logic is dips(dips'left);
  alias jamma_n : from_JAMMA_t is jamma;
  
begin

  PROC_LATCH: process (clk, rst_n)

    variable jamma_v	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    variable keybd_v 	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    variable ctrl		  : std_logic;
    variable esc		  : std_logic;
    variable shift    : std_logic;
			
  begin
     -- note: all inputs are active LOW
    if rst_n = '0' then

      ctrl := '0';
      esc := '0';
      shift := '0';
      for i in 0 to NUM_INPUTS-2 loop
        jamma_v(i).d := (others => '1');  -- b/c active low
        keybd_v(i).d := (others => '1');
      end loop;
      keybd_v(NUM_INPUTS-1).d := (others => '0');

    elsif rising_edge (clk) then
    
      -- handle JAMMA inputs
      jamma_v(4).d(1) := jamma_n.p(1).start;        -- <1>
      jamma_v(6).d(3) := jamma_n.p(1).up;           -- <UP>
      jamma_v(6).d(4) := jamma_n.p(1).down;         -- <DOWN>
      jamma_v(6).d(5) := jamma_n.p(1).left;         -- <LEFT>
      jamma_v(6).d(6) := jamma_n.p(1).right;        -- <RIGHT>
      jamma_v(6).d(7) := jamma_n.p(1).button(1);    -- <SPACE>
      jamma_v(6).d(0) := jamma_n.p(1).button(2);    -- <ENTER>
      jamma_v(6).d(1) := jamma_n.p(1).button(3);    -- <CLEAR>
      jamma_v(6).d(2) := jamma_n.p(1).button(4);    -- <BREAK>
    
      if (key_up or key_down) = '1' then
        case data(7 downto 0) is
          -- row 0
          when SCANCODE_BACKQUOTE =>			-- Super-80 '@'
            keybd_v(0).d(0) := key_up;
          when SCANCODE_H =>
            keybd_v(0).d(1) := key_up;
          when SCANCODE_P =>
            keybd_v(0).d(2) := key_up;
          when SCANCODE_X =>
            keybd_v(0).d(3) := key_up;
          when SCANCODE_1 =>
            keybd_v(0).d(4) := key_up;
          when SCANCODE_9 =>
            keybd_v(0).d(5) := key_up;
          when SCANCODE_SPACE =>
            keybd_v(0).d(6) := key_up;
          when SCANCODE_LALT =>           -- Super-80 REPT
            keybd_v(0).d(7) := key_up;
          -- row 1
          when SCANCODE_A =>
            keybd_v(1).d(0) := key_up;
          when SCANCODE_I =>
            keybd_v(1).d(1) := key_up;
          when SCANCODE_Q =>
            keybd_v(1).d(2) := key_up;
          when SCANCODE_Y =>
            keybd_v(1).d(3) := key_up;
          when SCANCODE_2 =>
            keybd_v(1).d(4) := key_up;
          when SCANCODE_QUOTE =>          -- Super-80 ':'
            keybd_v(1).d(5) := key_up;
          when SCANCODE_BACKSPACE =>
            keybd_v(1).d(6) := key_up;
          when SCANCODE_LSHIFT =>
            keybd_v(1).d(7) := key_up;
            shift := key_down;
          -- row 2
          when SCANCODE_B =>
            keybd_v(2).d(0) := key_up;
          when SCANCODE_J =>
            keybd_v(2).d(1) := key_up;
          when SCANCODE_R =>
            keybd_v(2).d(2) := key_up;
          when SCANCODE_Z =>
            keybd_v(2).d(3) := key_up;
          when SCANCODE_3 =>
            keybd_v(2).d(4) := key_up;
          when SCANCODE_SEMICOLON =>
            keybd_v(2).d(5) := key_up;
          when SCANCODE_TAB =>
            keybd_v(2).d(6) := key_up;
          when SCANCODE_LGUI =>           -- Super-80 FIRE
            keybd_v(2).d(7) := key_up;
          -- row 3
          when SCANCODE_C =>
            keybd_v(3).d(0) := key_up;
          when SCANCODE_K =>
            keybd_v(3).d(1) := key_up;
          when SCANCODE_S =>
            keybd_v(3).d(2) := key_up;
          when SCANCODE_OPENBRKT =>
            keybd_v(3).d(3) := key_up;
          when SCANCODE_4 =>
            keybd_v(3).d(4) := key_up;
          when SCANCODE_COMMA =>
            keybd_v(3).d(5) := key_up;
          when SCANCODE_PGDN =>           -- Super-80 LF
            keybd_v(3).d(6) := key_up;
          when SCANCODE_LCTRL =>
            keybd_v(3).d(7) := key_up;
            ctrl := key_down;
          -- row 4
          when SCANCODE_D =>
            keybd_v(4).d(0) := key_up;
          when SCANCODE_L =>
            keybd_v(4).d(1) := key_up;
          when SCANCODE_T =>
            keybd_v(4).d(2) := key_up;
          when SCANCODE_BACKSLASH =>
            keybd_v(4).d(3) := key_up;
          when SCANCODE_5 =>
            keybd_v(4).d(4) := key_up;
          when SCANCODE_INS =>            -- Super-80 BRK
            keybd_v(4).d(5) := key_up;
          when SCANCODE_ENTER =>          -- Super-80 RETURN
            keybd_v(4).d(6) := key_up;
          when SCANCODE_RIGHT =>
            keybd_v(4).d(7) := key_up;
          -- row 5
          when SCANCODE_E =>
            keybd_v(5).d(0) := key_up;
          when SCANCODE_M =>
            keybd_v(5).d(1) := key_up;
          when SCANCODE_U =>
            keybd_v(5).d(2) := key_up;
          when SCANCODE_CLOSEBRKT =>
            keybd_v(5).d(3) := key_up;
          when SCANCODE_6 =>
            keybd_v(5).d(4) := key_up;
          when SCANCODE_PERIOD =>
            keybd_v(5).d(5) := key_up;
          when SCANCODE_ESC =>
            keybd_v(5).d(6) := key_up;
            esc := key_down;
          when SCANCODE_LEFT =>
            keybd_v(5).d(7) := key_up;
          -- row 6
          when SCANCODE_F =>
            keybd_v(6).d(0) := key_up;
          when SCANCODE_N =>
            keybd_v(6).d(1) := key_up;
          when SCANCODE_V =>
            keybd_v(6).d(2) := key_up;
          when SCANCODE_EQUALS =>         -- Super-80 '^'/'~'
            keybd_v(6).d(3) := key_up;
          when SCANCODE_7 =>
            keybd_v(6).d(4) := key_up;
          when SCANCODE_SLASH =>
            keybd_v(6).d(5) := key_up;
          when SCANCODE_DELETE =>         -- Super-80 DEL
            keybd_v(6).d(6) := key_up;
          when SCANCODE_DOWN =>
            keybd_v(6).d(7) := key_up;
          -- row 7
          when SCANCODE_G =>
            keybd_v(7).d(0) := key_up;
          when SCANCODE_O =>
            keybd_v(7).d(1) := key_up;
          when SCANCODE_W =>
            keybd_v(7).d(2) := key_up;
          when SCANCODE_MINUS =>
            keybd_v(7).d(3) := key_up;
          when SCANCODE_8 =>
            keybd_v(7).d(4) := key_up;
          when SCANCODE_0 =>
            keybd_v(7).d(5) := key_up;
          when SCANCODE_CAPSLOCK =>           -- Super-80 LOCK
            keybd_v(7).d(6) := key_up;
          when SCANCODE_UP =>
            keybd_v(7).d(7) := key_up;
          -- special keys
          when SCANCODE_F7 =>
            keybd_v(8).d(1) := key_down;
          when others =>
        end case;
      end if; -- key_up or key_up
      
      -- special keys
      keybd_v(8).d(0) := ctrl and esc;		-- platform reset

      -- this is PS/2 reset only
      if (reset = '1') then
        for i in 0 to NUM_INPUTS-2 loop
          keybd_v(i).d := (others => '1');
        end loop;
      end if;
    end if; -- rising_edge (clk)
    
    -- assign outputs
    for i in 0 to NUM_INPUTS-2 loop
      inputs(i).d <= jamma_v(i).d and keybd_v(i).d;
    end loop;
    inputs(NUM_INPUTS-1).d <= keybd_v(NUM_INPUTS-1).d;

  end process PROC_LATCH;

end architecture SYN;
