library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.kbd_pkg.all;

entity usb_ps2_host is
  generic
  (
    CLK_HZ          : natural
  );
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;

    -- FIFO interface
    fifo_data       : in std_logic_vector(15 downto 0);
    fifo_wrreq      : in std_logic;
    fifo_full       : out std_logic;
        
    -- PS/2 lines
    ps2_kclk        : out std_logic;
    ps2_kdat        : out std_logic
  );
end entity usb_ps2_host;

architecture SYN of usb_ps2_host is

  constant CLK_66k667_div : natural := CLK_HZ / 66667;

  constant extended_f : std_logic_vector(0 to 127) :=
    X"0000_0000_0000_0000_02FF_E880_0600_0000";

  type scancode_t is array (natural range <>) of std_logic_vector(7 downto 0);
  constant scancode : scancode_t(0 to 127) :=
  (
    -- Note: (#)=Extended
    -- $00 - Rsvd, ErrRollover, POSTFail, ErrUndef, a, b, c, d
    X"00", X"00", X"70", X"00", 
    SCANCODE_A, SCANCODE_B, SCANCODE_C, SCANCODE_D,
    -- $08 - e, f, g, h, i, j, k, l
    SCANCODE_E, SCANCODE_F, SCANCODE_G, SCANCODE_H, 
    SCANCODE_I, SCANCODE_J, SCANCODE_K, SCANCODE_L,
    -- $10 - m, n, o, p, q, r, s, t
    SCANCODE_M, SCANCODE_N, SCANCODE_O, SCANCODE_P, 
    SCANCODE_Q, SCANCODE_R, SCANCODE_S, X"2C", --SCANCODE_T,
    -- $18 - u, v, w, x, y, z, 1, 2
    SCANCODE_U, SCANCODE_V, SCANCODE_W, SCANCODE_X, 
    SCANCODE_Y, SCANCODE_Z, SCANCODE_1, SCANCODE_2,
    -- $20 - 3, 4, 5, 6, 7, 8, 9, 0
    SCANCODE_3, SCANCODE_4, SCANCODE_5, SCANCODE_6, 
    SCANCODE_7, SCANCODE_8, SCANCODE_9, SCANCODE_0,
    -- $28 - ENTER, ESC, BS, TAB, SPACE, -, =, [
    SCANCODE_ENTER, SCANCODE_ESC, SCANCODE_BACKSPACE, SCANCODE_TAB, 
    SCANCODE_SPACE, SCANCODE_MINUS, SCANCODE_EQUALS, SCANCODE_OPENBRKT,
    -- $30 - ], \, (?), ;, ', `, COMMA, PERIOD 
    SCANCODE_CLOSEBRKT, SCANCODE_BACKSLASH, X"00", SCANCODE_SEMICOLON,
    SCANCODE_QUOTE, SCANCODE_BACKQUOTE, SCANCODE_COMMA, SCANCODE_PERIOD,
    -- $38 - /, CAPS, F1, F2, F3, F4, F5, F6
    SCANCODE_SLASH, SCANCODE_CAPSLOCK, SCANCODE_F1, SCANCODE_F2, 
    SCANCODE_F3, SCANCODE_F4, SCANCODE_F5, SCANCODE_F6,
    -- $40 - F7, F8, F9, F10, F11, F12, PRTSCR, SCROLLLOCK,
    SCANCODE_F7, SCANCODE_F8, SCANCODE_F9, SCANCODE_F10, 
    SCANCODE_F11, SCANCODE_F12, X"00", SCANCODE_SCROLL, 
    -- $48 - PAUSE, INS, HOME, PGUP, DEL, END, PGDN, RIGHT
    X"00", SCANCODE_INS, SCANCODE_HOME, SCANCODE_PGUP, 
    SCANCODE_DELETE, SCANCODE_END, SCANCODE_PGDN, SCANCODE_RIGHT, 
    -- $50 - LEFT, DOWN, UP, NUMLOCK, KEYPAD/, KEYPAD*, KEYPAD-, KEYPAD+
    SCANCODE_LEFT, SCANCODE_DOWN, SCANCODE_UP, SCANCODE_NUMLOCK, 
    SCANCODE_SLASH, SCANCODE_PADTIMES, SCANCODE_PADMINUS, SCANCODE_PADPLUS, 
    -- $58 - KPENTER, KP1, KP2, KP3, KP4, KP5, KP6, KP7
    SCANCODE_ENTER, SCANCODE_PAD1, SCANCODE_PAD1, SCANCODE_PAD3, 
    SCANCODE_PAD4, SCANCODE_PAD5, SCANCODE_PAD6, SCANCODE_PAD7, 
    -- $60 - KP8, KP9, KP0, KP., (?), APP, PWR, KP=
    SCANCODE_PAD8, SCANCODE_PAD9, SCANCODE_PAD0, SCANCODE_DELETE,
    X"00", X"00", X"00", SCANCODE_PADEQUALS, 
    -- $68 - F13, F14, F15, F16, F17, F18, F19, F20
    X"00", X"00", X"00", X"00",
    X"00", X"00", X"00", X"00",
    -- $70 - F21, F22, F23, F24, EXEC, HELP, MENU, SEL
    X"00", X"00", X"00", X"00",
    X"00", X"00", X"00", X"00",
    -- $78 - STOP, AGAIN, UNDO, CUT, COPY, PASTE, FIND, MUTE
    -- re-purposed as:
    SCANCODE_LCTRL, SCANCODE_LSHIFT, SCANCODE_LALT, SCANCODE_LGUI, 
    X"00", SCANCODE_RSHIFT, X"00", X"00"
  );
    
  signal clk_66k667_en    : std_logic := '0';
  signal ps2_data_r       : std_logic_vector(10 downto 0) := (others => '0');
  signal parity           : std_logic := '0';
  
  signal fifo_q           : std_logic_vector(15 downto 0) := (others => '0');
  signal fifo_rdreq       : std_logic := '0';
  signal fifo_empty       : std_logic := '0';
  
  signal ps2_send_data    : std_logic_vector(7 downto 0) := (others => '0');
  signal ps2_go           : std_logic := '0';
  signal ps2_done         : std_logic := '0';
  
begin

  BLK_SM : block

    type state_t is ( IDLE, 
                      WAIT_EXTEND, WAIT_BREAK, WAIT_DATA, 
                      SEND_DONE );
    signal state  : state_t;

  begin
    process (clk, reset)
      variable make   : std_logic;
      variable code   : integer range 0 to 127 := 0;
    begin
      if reset = '1' then
        state <= IDLE;
        fifo_rdreq <= '0';
        ps2_go <= '0';
      elsif rising_edge(clk) then
        make := fifo_q(15);
        code := to_integer(unsigned(fifo_q(7 downto 0)));
        fifo_rdreq <= '0';
        ps2_go <= '0';    -- default
        if state = IDLE then
          if fifo_empty = '0' then
            -- decide what data to send
            if scancode(code) = X"00" then
              fifo_rdreq <= '1';
              state <= SEND_DONE;
            else
              if extended_f(code) = '1' then
                ps2_send_data <= X"E0";
                state <= WAIT_EXTEND;
              elsif make = '0' then
                ps2_send_data <= X"F0";
                state <= WAIT_BREAK;
              else
                ps2_send_data <= scancode(code);
                state <= WAIT_DATA;
              end if; -- extended
              ps2_go <= '1';
            end if; -- scancode(code) = X"00"
          end if; -- fifo_empty='0'
        else
          case state is
            when WAIT_EXTEND =>
              if ps2_done = '1' then
                if make = '0' then
                  ps2_send_data <= X"F0";
                  state <= WAIT_BREAK;
                else
                  ps2_send_data <= scancode(code);
                  state <= WAIT_DATA;
                end if;
                ps2_go <= '1';
              end if;
            when WAIT_BREAK =>
              if ps2_done = '1' then
                ps2_send_data <= scancode(code);
                ps2_go <= '1';
                state <= WAIT_DATA;
              end if;
            when WAIT_DATA =>
              if ps2_done = '1' then
                fifo_rdreq <= '1';
                state <= SEND_DONE;
              end if;
            when others =>
              state <= IDLE;
           end case;
        end if;
      end if;
    end process;

  end block BLK_SM;

  -- generate 66.667kHz clock enable
  process (clk, reset)
    subtype count_t is integer range 0 to CLK_66k667_div-1;
    variable count : count_t := 0;
  begin
    if reset = '1' then
      count := 0;
    elsif rising_edge(clk) then
      clk_66k667_en <= '0'; -- default
      if count = count_t'high then
        clk_66k667_en <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;

  -- generate (odd) parity
  parity <= not ( fifo_q(7) xor fifo_q(6) xor fifo_q(5) xor fifo_q(4) xor 
                  fifo_q(3) xor fifo_q(2) xor fifo_q(1) xor fifo_q(0) );

  BLK_PS2_SEND : block

    type state_t is ( IDLE, SEND1, SEND2, SEND3, SEND4, SEND_DONE );
    signal state            : state_t;

  begin
  
    process (clk, reset)
      variable count : integer range 0 to ps2_data_r'left;
    begin
      if reset = '1' then
        state <= IDLE;
        ps2_kclk <= '1';
        ps2_kdat <= '1';
        ps2_done <= '0';
      elsif rising_edge(clk) then
        ps2_done <= '0';    -- default
        if state = IDLE then
          ps2_kclk <= '1';
          ps2_kdat <= '1';
          if ps2_go = '1' then
            -- reverse order (since LSB first)
            ps2_data_r <= '1' & parity & ps2_send_data & '0';
            count := ps2_data_r'left;
            state <= SEND1;
          end if;
        elsif clk_66k667_en = '1' then
          case state is
            when SEND1 =>
              ps2_kclk <= '1';
              state <= SEND2;
            when SEND2 =>
              ps2_kclk <= '1';
              ps2_kdat <= ps2_data_r(0);
              state <= SEND3;
            when SEND3 =>
              ps2_kclk <= '0';
              state <= SEND4;
            when SEND4 =>
              ps2_kclk <= '0';
              -- shift data register
              ps2_data_r <= '0' & ps2_data_r(ps2_data_r'left downto 1);
              if count = 0 then
                count := 4;
                state <= SEND_DONE;
              else
                count := count - 1;
                state <= SEND1;
              end if;
            when SEND_DONE =>
              if count = 0 then
                ps2_done <= '1';
                state <= IDLE;
              else
                ps2_kclk <= '1';
                ps2_kdat <= '1';
                count := count - 1;
                state <= SEND_DONE;
              end if;
            when others =>
              state <= IDLE;
           end case;
        end if;
      end if;
    end process;

  end block BLK_PS2_SEND;

  fifo_inst : entity work.ps2_host_fifo
  	port map
  	(
      aclr    => reset,
      
  		wrclk   => clk,
  		data    => fifo_data,
  		wrreq   => fifo_wrreq,
  		wrfull	=> fifo_full,
  		
  		rdclk   => clk,
  		q       => fifo_q,
  		rdreq   => fifo_rdreq,
  		rdempty	=> fifo_empty
  	);

end architecture SYN;
