library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity uPD4990A is
  port
  (
      clk_i       : in std_logic;
      clk_ena     : in std_logic;
      reset       : in std_logic;
      
      data_in     : in std_logic;
      clk         : in std_logic;
      c           : in std_logic_vector(2 downto 0);
      stb         : in std_logic;
      cs          : in std_logic;
      out_enabl   : in std_logic;
      
      data_out    : out std_logic;
      tp          : out std_logic
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
  
begin

  process (clk_i)
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
          when "100" =>
            -- TP = 64Hz
          when "101" =>
            -- TP = 256Hz
          when "110" =>
            -- TP = 2048Hz
          when others =>
            -- serial transfer mode
        end case;
        -- latch the current operating mode
        mode <= c;
      end if;
    end if;
  end process;

end architecture SYN;
