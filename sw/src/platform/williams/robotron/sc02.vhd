library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity sc02 is
  generic
  (
    REVISION  : integer := 2
  );
  port
  (
    clk       : in std_logic;
    clk_en    : in std_logic;
    rst       : in std_logic;
    
    -- CPU interface
    wr        : in std_logic;
    d         : in std_logic_vector(7 downto 0);
    a         : in std_logic_vector(2 downto 0);
    ba_bs     : in std_logic;
    halt      : out std_logic;

    -- VRAM interface
    vram_wr   : out std_logic;
    vram_a    : out std_logic_vector(15 downto 0)
  );
end entity sc02;

architecture SYN of sc02 is

  type r_a is array (natural range <>) of std_logic_vector(7 downto 0);
  signal r : r_a(0 to 2**3-1);
  
  alias cmd           : std_logic_vector(7 downto 0) is r(0);
    alias src_inc     : std_logic is cmd(0);
    alias dst_inc     : std_logic is cmd(1);
    alias transparent : std_logic is cmd(3);
    alias solid       : std_logic is cmd(4);
    alias shift       : std_logic is cmd(5);
    alias even        : std_logic is cmd(6);
    alias odd         : std_logic is cmd(7);
  alias mask          : std_logic_vector(7 downto 0) is r(1);
  alias h             : std_logic_vector(7 downto 0) is r(6);
  alias w             : std_logic_vector(7 downto 0) is r(7);

  -- aliases of a fashion
  signal src_a  : std_logic_vector(15 downto 0);
  signal dst_a  : std_logic_vector(15 downto 0);

  type state_t is ( S_IDLE, S_HALTING, S_BLIT, S_INC );
  signal state : state_t := S_IDLE;
  
begin

  -- just to make the code clearer
  src_a <= r(2) & r(3);
  dst_a <= r(4) & r(5);
  
  -- implement registers
  process (clk, rst)
  begin
    if rst = '1' then
    elsif rising_edge(clk) then
      if clk_en = '1' and wr = '1' then
        r(to_integer(unsigned(a))) <= d;
      end if;
    end if;
  end process;

  process (clk, rst)
    variable src  : unsigned(src_a'range);
    variable dst  : unsigned(dst_a'range);
    variable x    : integer range 0 to 2**8-1;
    variable y    : integer range 0 to 2**8-1;
  begin
    if rst = '1' then
      halt <= '0';
      state <= S_IDLE;
    elsif rising_edge(clk) then
      vram_wr <= '0'; -- default
      case state is
        when S_IDLE =>
          if clk_en = '1' and wr = '1' then
            if to_integer(unsigned(a)) = 0 then
              halt <= '1';
              state <= S_HALTING;
            end if;
          end if;
        when S_HALTING =>
          if ba_bs = '1' then
            src := unsigned(src_a);
            dst := unsigned(dst_a);
            x := 0;
            y := 0;
            state <= S_BLIT;
          end if;
        when S_BLIT =>
          vram_wr <= '1';
          state <= S_INC;
        when S_INC =>
          state <= S_BLIT;  -- default
          src := src + 1;
          if x = to_integer(unsigned(w)) then
            if y = to_integer(unsigned(h)) then
              halt <= '0';
              state <= S_IDLE;
            else
              x := 0;
              y := y + 1;
              dst := dst + 256;
            end if;
          else
            x := x + 1;
            dst := dst + 1;
          end if;
        when others =>
          halt <= '0';
          state <= S_IDLE;
      end case;
    end if;
  end process;
  
end architecture SYN;
