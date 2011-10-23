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

    busy      : out std_logic;
    vram_sel  : out std_logic;
    
    -- memory interface
    mem_wr    : out std_logic;
    mem_a     : out std_logic_vector(15 downto 0);
    mem_d_i   : in std_logic_vector(7 downto 0);
    mem_d_o   : out std_logic_vector(7 downto 0)
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

  -- aliases of a fashion
  signal src_a  : std_logic_vector(15 downto 0);
  signal dst_a  : std_logic_vector(15 downto 0);

  type state_t is 
  ( 
    S_IDLE, S_HALTING, 
    S_BLIT_0, S_BLIT_1, S_BLIT_2, S_BLIT_3, S_BLIT_4,
    S_INC 
  );
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
    variable src      : unsigned(src_a'range);
    variable dst      : unsigned(dst_a'range);
    variable sstart   : unsigned(src_a'range);
    variable dstart   : unsigned(dst_a'range);
    variable w        : integer range 0 to 256;   -- yes 256!
    variable h        : integer range 0 to 256;
    variable x        : integer range 0 to 256;
    variable y        : integer range 0 to 256;
    variable d_sx     : integer range 0 to 256;
    variable d_sy     : integer range 0 to 256;
    variable d_dx     : integer range 0 to 256;
    variable d_dy     : integer range 0 to 256;
    variable keepmask : std_logic_vector(7 downto 0);
    variable d_i      : std_logic_vector(mem_d_i'range);
    variable d_o      : std_logic_vector(mem_d_o'range);
  begin
    if rst = '1' then
      halt <= '0';
      busy <= '0';
      state <= S_IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        mem_wr <= '0'; -- default
        case state is
          when S_IDLE =>
            if wr = '1' then
              if to_integer(unsigned(a)) = 0 then
                halt <= '1';
                state <= S_HALTING;
              end if;
            end if;
          when S_HALTING =>
            if ba_bs = '1' then
              busy <= '1';
              sstart := unsigned(src_a);
              dstart := unsigned(dst_a);
              src := sstart;
              dst := dstart;
              w := to_integer(unsigned(r(6)));
              h := to_integer(unsigned(r(7)));
              -- handle bug in SC01
              if REVISION = 1 then
                w := to_integer(to_unsigned(w,9) xor to_unsigned(4,9));
                h := to_integer(to_unsigned(h,9) xor to_unsigned(4,9));
              end if;
              if w = 0 then
                w := 1;
              elsif w = 255 then
                w := 256;
              end if;
              if h = 0 then
                h := 1;
              elsif h = 255 then
                h := 256;
              end if;
              x := 1;
              y := 1;
              if src_inc = '1' then
                d_sx := 256;
                d_sy := 1;
              else
                d_sx := 1;
                d_sy := w;
              end if;
              if dst_inc = '1' then
                d_dx := 256;
                d_dy := 1;
              else
                d_dx := 1;
                d_dy := w;
              end if;
              keepmask(7 downto 4) := (others => odd);
              keepmask(3 downto 0) := (others => even);
              state <= S_BLIT_0;
            end if;
          when S_BLIT_0 =>
            -- read from currently selected space
            vram_sel <= '0';
            mem_a <= std_logic_vector(src);
            state <= S_BLIT_1;
          when S_BLIT_1 =>
            state <= S_BLIT_2;
          when S_BLIT_2 =>
            mem_d_o <= mem_d_i;
            state <= S_BLIT_3;
          when S_BLIT_3 =>
            -- force write to VRAM
            vram_sel <= '1';
            mem_a <= std_logic_vector(dst);
            state <= S_BLIT_4;
          when S_BLIT_4 =>
            mem_wr <= '1';
            state <= S_INC;
          when S_INC =>
            state <= S_BLIT_0;  -- default
            if x = w then
              if y = h then
                busy <= '0';
                halt <= '0';
                state <= S_IDLE;
              else
                x := 1;
                y := y + 1;
                sstart := sstart + d_sy;
                dstart := dstart + d_dy;
              end if;
              src := sstart;
              dst := dstart;
            else
              x := x + 1;
              src := src + d_sx;
              dst := dst + d_dx;
            end if;
          when others =>
            busy <= '0';
            halt <= '0';
            state <= S_IDLE;
        end case;
      end if; -- clk_en
    end if;
  end process;
  
end architecture SYN;
