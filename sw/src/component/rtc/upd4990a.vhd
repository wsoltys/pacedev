library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity uPD4990A is
  generic
  (
    CLK_32M768_COUNT  : natural
  );
  port
  (
    clk_i             : in std_logic;
    clk_ena           : in std_logic;
    reset             : in std_logic;
    
    data_in           : in std_logic;
    clk               : in std_logic;
    c                 : in std_logic_vector(2 downto 0);
    stb               : in std_logic;
    cs                : in std_logic;
    out_enabl         : in std_logic;
    
    data_out          : out std_logic;
    tp                : out std_logic
  );
end entity uPD4990A;

architecture SYN of uPD4990A is

  signal shift_r    : std_logic_vector(51 downto 0) := (others => '0');
  alias cmd         : std_logic_vector(3 downto 0) is shift_r(51 downto 48);
  alias year_tens   : std_logic_vector(3 downto 0) is shift_r(47 downto 44);
  alias year_units  : std_logic_vector(3 downto 0) is shift_r(43 downto 40);
  alias month       : std_logic_vector(3 downto 0) is shift_r(39 downto 36);
  alias dow         : std_logic_vector(3 downto 0) is shift_r(35 downto 32);
  alias day_tens    : std_logic_vector(3 downto 0) is shift_r(31 downto 28);
  alias day_units   : std_logic_vector(3 downto 0) is shift_r(27 downto 24);
  alias hr_tens     : std_logic_vector(3 downto 0) is shift_r(23 downto 20);
  alias hr_units    : std_logic_vector(3 downto 0) is shift_r(19 downto 16);
  alias min_tens    : std_logic_vector(3 downto 0) is shift_r(15 downto 12);
  alias min_units   : std_logic_vector(3 downto 0) is shift_r(11 downto 8);
  alias sec_tens    : std_logic_vector(3 downto 0) is shift_r(7 downto 4);
  alias sec_units   : std_logic_vector(3 downto 0) is shift_r(3 downto 0);

  signal mode       : std_logic_vector(3 downto 0) := (others => '0');
  
  signal clk_32M768 : std_logic := '0';
  signal clk_4096   : std_logic := '0';
  signal clk_2048   : std_logic := '0';
  signal clk_256    : std_logic := '0';
  signal clk_64     : std_logic := '0';
  signal clk_1s     : std_logic := '0';
  
  signal pulse_1s   : std_logic := '0';
  
begin

  process (clk_i, reset)
    subtype count_t is integer range 0 to CLK_32M768_COUNT-1;
    variable count      : count_t;
    variable tp_count   : std_logic_vector(14 downto 0) := (others => '0');
  begin
    if reset = '1' then
      count := 0;
      tp_count  := (others => '0');
    elsif rising_edge (clk_i) and clk_ena = '1' then
      pulse_1s <= '0';    -- default
      clk_32M768 <= '0';  -- default
      if count = count_t'high then
        clk_32M768 <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
      -- timing pulses
      clk_4096 <= tp_count(2);
      clk_2048 <= tp_count(3);
      clk_256 <= tp_count(6);
      clk_64 <= tp_count(8);
      clk_1s <= tp_count(14);
      if clk_32M768 = '1' then
        tp_count  := tp_count + 1;
        -- fixme!!!
        if tp_count = 0 then
          pulse_1s <= '1';
        end if;
      end if;
    end if;
  end process;

  -- drive TP output
  tp <= clk_64 when mode = "100" else
        clk_256 when mode = "101" else
        clk_2048 when mode = "110" else
        '0'; -- TBD
  
  -- rtc (clock/calendar)
  process (clk_i, reset)
    type dim_t is array (natural range <>) of std_logic_vector(7 downto 0);
    --constant dim : dim_t(1 to 12) :=
    --  { X"30", X"27", X"30", X"29", X"30", X"29", X"30", X"30", X"29", X"30", X"29", X"30" };
  begin
    if reset = '1' then
    elsif rising_edge(clk_i) and clk_ena = '1' then
      if pulse_1s = '1' then
        if sec_units = 9 then
          sec_units <= (others => '0');
          if sec_tens = 5 then
            sec_tens <= (others => '0');
            if min_units = 9 then
              min_units <= (others => '0');
              if min_tens = 5 then
                min_tens <= (others => '0');
                if hr_units = 9 then
                  hr_units <= (others => '0');
                  hr_tens <= hr_tens + 1;
                elsif hr_units = 3 and hr_tens = 2 then
                  hr_units <= (others => '0');
                  if day_units = 9 then
                    day_units <= (others => '0');
                    day_tens <= day_tens + 1;
                  --elsif day_units = dim(month)(3 downto 0) and 
                  else
                    day_units <= day_units + 1;
                  end if;
                else
                  hr_units <= hr_units + 1;
                end if;
              else
                min_tens <= min_tens + 1;
              end if;
            else
              min_units <= min_units + 1;
            end if;
          else
            sec_tens <= sec_tens + 1;
          end if;
        else
          sec_units <= sec_units + 1;
        end if;
      end if;
    end if;
  end process;
  
  process (clk_i, reset)
  begin
    if reset = '1' then
      mode <= (others => '0');
    elsif rising_edge(clk) and clk_ena = '1' then
      if cs = '1' and stb = '1' then
        -- latch command
        case c(2 downto 0) is
          when "000" =>
          when "001" =>
          when "010" =>
          when "011" =>
          when "111" =>
            -- serial transfer mode
          when others =>
            null;
        end case;
        -- latch the current operating mode
        mode <= c;
      end if;
    end if;
  end process;

end architecture SYN;
