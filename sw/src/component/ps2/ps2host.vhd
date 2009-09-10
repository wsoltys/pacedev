library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ps2_host is
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
    fifo_usedw      : out std_logic_vector(7 downto 0);
        
    -- PS/2 lines
    ps2_kclk        : out std_logic;
    ps2_kdat        : out std_logic
  );
end entity ps2_host;

architecture SYN of ps2_host is

  constant CLK_66k667_div : natural := CLK_HZ / 66667;
  
  signal clk_66k667_en    : std_logic := '0';
  signal ps2_data_r       : std_logic_vector(10 downto 0) := (others => '0');
  signal parity           : std_logic := '0';
  
  signal fifo_q           : std_logic_vector(7 downto 0) := (others => '0');
  signal fifo_rdreq       : std_logic := '0';
  signal fifo_empty       : std_logic := '0';
  
  type state_t is ( IDLE, SEND1, SEND2, SEND3, SEND4, SEND_DONE );
  signal state            : state_t;
  
begin

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
  
  process (clk, reset)
    variable count : integer range 0 to ps2_data_r'left;
  begin
    if reset = '1' then
      state <= IDLE;
      ps2_kclk <= '1';
      ps2_kdat <= '1';
      fifo_rdreq <= '0';
    elsif rising_edge(clk) then
      fifo_rdreq <= '0';  -- default
      if state = IDLE then
        ps2_kclk <= '1';
        ps2_kdat <= '1';
        if fifo_empty = '0' then
          -- reverse order (since LSB first)
          ps2_data_r <= '1' & parity & fifo_q & '0';
          fifo_rdreq <= '1';
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

  fifo_inst : entity work.ps2_fifo
  	port map
  	(
  		clock		=> clk,

  		data		=> fifo_data,
  		wrreq		=> fifo_wrreq,
  		full		=> fifo_full,
  		usedw		=> fifo_usedw,
  		
  		q		    => fifo_q,
  		rdreq		=> fifo_rdreq,
  		empty		=> fifo_empty
  	);

end architecture SYN;
