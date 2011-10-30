library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity sc02 is
  generic
  (
    REVISION  : integer range 1 to 2 := 2;
    CLIP_ADDR : unsigned(15 downto 0) := X"0000"
  );
  port
  (
    clk         : in std_logic;
    clk_en      : in std_logic;
    rst         : in std_logic;
    
    -- CPU interface
    wr          : in std_logic;
    d           : in std_logic_vector(7 downto 0);
    a           : in std_logic_vector(2 downto 0);
    ba_bs       : in std_logic;
    halt        : out std_logic;

    window_en   : in std_logic;
    busy        : out std_logic;
    vram_sel    : out std_logic;
    
    -- memory interface
    mem_wr      : out std_logic;
    mem_a       : out std_logic_vector(15 downto 0);
    mem_d_i     : in std_logic_vector(7 downto 0);
    mem_d_o     : out std_logic_vector(7 downto 0)
  );
end entity sc02;

architecture SYN of sc02 is

  type r_a is array (natural range <>) of std_logic_vector(7 downto 0);
  signal r : r_a(0 to 2**3-1);
  
  alias cmd             : std_logic_vector(7 downto 0) is r(0);
    alias src_inc_f     : std_logic is cmd(0);
    alias dst_inc_f     : std_logic is cmd(1);
    alias no_wrap_f     : std_logic is cmd(2);
    alias transparent_f : std_logic is cmd(3);
    alias solid_f       : std_logic is cmd(4);
    alias shift_f       : std_logic is cmd(5);
    alias even_f        : std_logic is cmd(6);
    alias odd_f         : std_logic is cmd(7);

  -- aliases of a fashion
  signal src_a  : std_logic_vector(15 downto 0);
  signal dst_a  : std_logic_vector(15 downto 0);

  type state_t is 
  ( 
    S_IDLE, S_HALTING, 
    S_BLIT_0, S_BLIT_1, S_BLIT_2, S_BLIT_3, S_BLIT_4,
    S_BLIT_5, S_BLIT_6, S_BLIT_7,
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
    variable src          : unsigned(src_a'range);
    variable dst          : unsigned(dst_a'range);
    variable sstart       : unsigned(src_a'range);
    variable dstart       : unsigned(dst_a'range);
    variable w            : integer range 0 to 257;   -- yes 256!
    variable h            : integer range 0 to 257;
    variable x            : integer range 0 to 257;
    variable y            : integer range 0 to 257;
    variable d_sx         : integer range 0 to 257;
    variable d_sy         : integer range 0 to 257;
    variable d_dx         : integer range 0 to 257;
    variable d_dy         : integer range 0 to 257;
    variable keepmask     : std_logic_vector(7 downto 0);
    variable solid        : std_logic_vector(7 downto 0);
    variable mask         : std_logic_vector(keepmask'range);
    variable src_d_i_buf  : std_logic_vector(11 downto 0);
    alias src_d_i         : std_logic_vector(mem_d_o'range) is src_d_i_buf(11 downto 4);
    variable dst_d_i      : std_logic_vector(mem_d_o'range);
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
              if src_inc_f = '1' then
                d_sx := 256;
                d_sy := 1;
              else
                d_sx := 1;
                d_sy := w;
              end if;
              if dst_inc_f = '1' then
                d_dx := 256;
                d_dy := 1;
              else
                d_dx := 1;
                d_dy := w;
              end if;
              if shift_f = '0' then
                keepmask(7 downto 4) := (others => odd_f);
                keepmask(3 downto 0) := (others => even_f);
                solid := r(1);
              else
                keepmask(7 downto 4) := (others => even_f);
                keepmask(3 downto 0) := (others => odd_f);
                solid := r(1)(3 downto 0) & r(1)(7 downto 4);
                -- must be done here, after all delta calcs
                w := w + 1;
              end if;
              x := 1;
              y := 1;
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
            -- read source byte from ROM/VRAM
            -- account for shifter logic here
            if shift_f = '0' then
              src_d_i := mem_d_i;
            elsif x = 1 then
              src_d_i_buf := "0000" & mem_d_i;
            elsif x /= w then
              src_d_i_buf := src_d_i_buf(3 downto 0) & mem_d_i;
            else
              src_d_i_buf := src_d_i_buf(3 downto 0) & "00000000";
            end if;
            state <= S_BLIT_3;
          when S_BLIT_3 =>
            -- force read/write to/from VRAM
            vram_sel <= '1';
            mem_a <= std_logic_vector(dst);
            state <= S_BLIT_4;
          when S_BLIT_4 =>
            state <= S_BLIT_5;
          when S_BLIT_5 =>
            -- read source byte from VRAM
            dst_d_i := mem_d_i;
            state <= S_BLIT_6;
          when S_BLIT_6 =>
            -- handle shift logic
            if shift_f = '1' and x = 1 then
              mask := "1111" & keepmask(3 downto 0);
            elsif shift_f = '1' and x = w then
              mask := keepmask(7 downto 4) & "1111";
            else
              mask := keepmask;
            end if;
            -- handle transparency
            if transparent_f = '1' then
              if src_d_i(7 downto 4) = "0000" then
                mask(7 downto 4) := (others => '1');
              end if;
              if src_d_i(3 downto 0) = "0000" then
                mask(3 downto 0) := (others => '1');
              end if;
            end if;
            -- handle solid vs source data
            dst_d_i := dst_d_i and mask;
            if solid_f = '1' then
              dst_d_i := dst_d_i or (solid and not mask);
            else
              dst_d_i := dst_d_i or (src_d_i and not mask);
            end if;
            state <= S_BLIT_7;
          when S_BLIT_7 =>
            if window_en = '0' or 
                dst < CLIP_ADDR or dst > X"C000" then
              -- write byte to VRAM
              mem_d_o <= dst_d_i;
              mem_wr <= '1';
            end if;
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
                if no_wrap_f = '1' then
                  -- todo: handle no_wrap_f
                  -- easier with vectors!
                  dstart := dstart + d_dy;
                else
                  dstart := dstart + d_dy;
                end if;
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
