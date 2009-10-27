library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity apple_ii_ps2_host is
  generic
  (
    CLK_HZ          : natural
  );
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;

    -- FIFO interface
    fifo_data       : in std_logic_vector(7 downto 0);
    fifo_wrreq      : in std_logic;
    fifo_full       : out std_logic;
        
    -- PS/2 lines
    ps2_kclk        : out std_logic;
    ps2_kdat        : out std_logic
  );
end entity apple_ii_ps2_host;

architecture SYN of apple_ii_ps2_host is

  constant CLK_66k667_div : natural := CLK_HZ / 66667;

  constant extended_f : std_logic_vector(0 to 127) :=
    X"20B80400000000000000000000000001";
  constant shifted_f :  std_logic_vector(0 to 127) :=
    X"000000007EF0002BFFFFFFE300000002";

  type scancode_t is array (natural range <>) of std_logic_vector(7 downto 0);
  constant scancode : scancode_t(0 to 127) :=
  (
    -- Note: (#)=Extended, ($)=Shifted
    -- $00 - NULL, SOH, #STX(INS), ETX, EOT, ENQ, ACK, BEL
    X"00", X"00", X"70", X"00", X"00", X"00", X"00", X"00",
    -- $08 - #BS/LEFT, HT, #LF/DOWN, #VT/UP, #FF(HOME), CR, SO, SI
    X"6B", X"0D", X"72", X"75", X"6C", X"5A", X"00", X"00",
    -- $10 - DLE, DC1, DC2, DC3, DC4, #NAK/RIGHT, SYN, ETB
    X"00", X"00", X"00", X"00", X"00", X"74", X"00", X"00",
    -- $18 - CAN, EM, SUB, ESC, FS, GS, RS, US
    X"00", X"00", X"00", X"76", X"00", X"00", X"00", X"00",
    -- $20 - $<SPACE>, $!, $", $#, $$, $%, $&, '
    X"29", X"16", X"52", X"26", X"25", X"2E", X"3D", X"52",
    -- $28 - $(, $), $*, $+, ,, -, ., /
    X"46", X"45", X"3E", X"55", X"41", X"4E", X"49", X"4A",
    -- $30 - 0, 1, 2, 3, 4, 5, 6, 7
    X"45", X"16", X"1E", X"26", X"25", X"2E", X"36", X"3D",
    -- $38 - 8, 9, $:, ;, $<, =, $>, $?
    X"3E", X"46", X"4C", X"4C", X"41", X"55", X"49", X"4A",
    -- $40 - $@, $A, $B, $C, $D, $E, $F, $G
    X"1E", X"1C", X"32", X"21", X"23", X"24", X"2B", X"34",
    -- $48 - $H, $I, $J, $K, $L, $M, $N, $O
    X"33", X"43", X"3B", X"42", X"4B", X"3A", X"31", X"44",
    -- $50 - $P, $Q, $R, $S, $T, $U, $V, $W
    X"4D", X"15", X"2D", X"1B", X"2C", X"3C", X"2A", X"1D",
    -- $58 - $X, $Y, $Z, [, \, ], $^, $_
    X"22", X"35", X"1A", X"54", X"5D", X"5B", X"36", X"4E",
    -- $60 - `, a, b, c, d, e, f, g
    X"0E", X"1C", X"32", X"21", X"23", X"24", X"2B", X"34",
    -- $68 - h, i, j, k, l, m, n, o
    X"33", X"43", X"3B", X"42", X"4B", X"3A", X"31", X"44",
    -- $70 - p, q, r, s, t, u, v, w
    X"4D", X"15", X"2D", X"1B", X"2C", X"3C", X"2A", X"1D",
    -- $78 - x, y, z, {, |, }, $~, #<DEL>
    X"22", X"35", X"1A", X"54", X"5D", X"5B", X"0E", X"71"
  );
    
  signal clk_66k667_en    : std_logic := '0';
  signal ps2_data_r       : std_logic_vector(10 downto 0) := (others => '0');
  signal parity           : std_logic := '0';
  
  signal fifo_q           : std_logic_vector(7 downto 0) := (others => '0');
  signal fifo_rdreq       : std_logic := '0';
  signal fifo_empty       : std_logic := '0';
  
  signal ps2_send_data    : std_logic_vector(7 downto 0) := (others => '0');
  signal ps2_go           : std_logic := '0';
  signal ps2_done         : std_logic := '0';
  
begin

  BLK_SM : block

    type state_t is ( IDLE, 
                      WAIT_EXTEND_SHIFT, WAIT_DATA, 
                      WAIT_FOR_16ms, 
                      WAIT_EXTEND_BREAK, SEND_BREAK, WAIT_BREAK, WAIT_DATA_BREAK, 
                      WAIT_SHIFT_BREAK, WAIT_SHIFT, 
                      SEND_DONE );
    signal state  : state_t;

  begin
    process (clk, reset)
      subtype count_t is integer range 0 to CLK_HZ/60;
      variable count  : count_t := 0;
      variable ascii  : integer range 0 to 127 := 0;
    begin
      if reset = '1' then
        state <= IDLE;
        fifo_rdreq <= '0';
        ps2_go <= '0';
      elsif rising_edge(clk) then
        ascii := to_integer(unsigned(fifo_q(7 downto 0)));
        fifo_rdreq <= '0';
        ps2_go <= '0';    -- default
        if state = IDLE then
          if fifo_empty = '0' then
            -- decide what data to send
            if extended_f(ascii) = '1' then
              ps2_send_data <= X"E0";
              state <= WAIT_EXTEND_SHIFT;
            elsif shifted_f(ascii) = '1' then
              ps2_send_data <= X"12";
              state <= WAIT_EXTEND_SHIFT;
            else
              ps2_send_data <= scancode(ascii);
              state <= WAIT_DATA;
            end if;
            ps2_go <= '1';
          end if;
        else
          case state is
            when WAIT_EXTEND_SHIFT =>
              if ps2_done = '1' then
                ps2_send_data <= scancode(ascii);
                ps2_go <= '1';
                state <= WAIT_DATA;
              end if;
            when WAIT_DATA =>
              if ps2_done = '1' then
                count := count_t'high;
                state <= WAIT_FOR_16ms;
              end if;
            when WAIT_FOR_16ms =>
              if count = 0 then
                if extended_f(ascii) = '1' then
                  ps2_send_data <= X"E0";
                  ps2_go <= '1';
                  state <= WAIT_EXTEND_BREAK;
                else
                  state <= SEND_BREAK;
                end if;
              else
                count := count - 1;
              end if;
            when WAIT_EXTEND_BREAK =>
              if ps2_done = '1' then
                state <= SEND_BREAK;
              end if;
            when SEND_BREAK =>
              ps2_send_data <= X"F0";
              ps2_go <= '1';
              state <= WAIT_BREAK;
            when WAIT_BREAK =>
              if ps2_done = '1' then
                ps2_send_data <= scancode(ascii);
                ps2_go <= '1';
                state <= WAIT_DATA_BREAK;
              end if;
            when WAIT_DATA_BREAK =>
              if ps2_done = '1' then
                if shifted_f(ascii) = '1' then
                  ps2_send_data <= X"F0";
                  ps2_go <= '1';
                  state <= WAIT_SHIFT_BREAK;
                else
                  fifo_rdreq <= '1';
                  state <= SEND_DONE;
                end if;
              end if;
            when WAIT_SHIFT_BREAK =>
              if ps2_done = '1' then
                ps2_send_data <= X"12";
                ps2_go <= '1';
                state <= WAIT_SHIFT;
              end if;
            when WAIT_SHIFT=>
              if ps2_done <= '1' then
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
      rst     => reset,
      
  		wr_clk  => clk,
  		din     => fifo_data,
  		wr_en   => fifo_wrreq,
  		full		=> fifo_full,
  		
  		rd_clk  => clk,
  		dout    => fifo_q,
  		rd_en   => fifo_rdreq,
  		empty		=> fifo_empty
  	);

end architecture SYN;
