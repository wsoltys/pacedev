library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity namco_51xx is
  generic
  (
    SYS_CLK_Hz    : integer;
    CLK_EN_DUTY   : integer := 1
  );
  port
  (
    clk           : in std_logic;
    clk_en        : in std_logic;
    rst           : in std_logic;

    si            : in std_logic;
    so            : out std_logic;
    k             : in std_logic_vector(3 downto 0);
    r             : in std_logic_vector(15 downto 0);
    p             : out std_logic_vector(3 downto 0);
    o             : out std_logic_vector(7 downto 0);
    
    to_n          : in std_logic;
    tc_n          : in std_logic;
    irq_n         : in std_logic
  );
 end entity namco_51xx;
 
 architecture SYN of namco_51xx is
 
  signal cmd : std_logic_vector(2 downto 0) := (others => '0');
  
 begin
 
  -- cpu interface
  process (clk, rst)
    variable irq_n_r        : std_logic := '0';
    variable coincred_mode  : integer range 0 to 6 := 0;
    variable mode           : integer range 0 to 1 := 0;
    variable cnt            : integer range 0 to 2 := 0;
  begin
    if rst = '1' then
      irq_n_r := '0';
      coincred_mode := 0;
      mode := 0;
      cnt := 0;
      cmd <= (others => '0');
    elsif rising_edge(clk) then
      if clk_en = '1' then
        -- latch on IRQn edges
        if irq_n_r /= irq_n then
          -- latch read on leading-edge IRQn
          if irq_n = '0' and k(3) = '1' then
            -- read
            if mode = 0 then
              -- switch mode
              case cnt is
                when 0 =>
                  o <= X"FF";
                when 1 =>
                  o <= X"FF";
                when others =>
                  o <= X"00";
              end case;
            else
              -- credits mode
              case cnt is
                when 0 =>
                  -- credits(BCD)
                  o <= X"00";
                when 1 =>
                  -- JOY
                  o <= X"00";
                when 2 =>
                  -- JOY
                  o <= X"00";
              end case;
            end if;
            if cnt = cnt'high then
              cnt := 0;
            else
              cnt := cnt + 1;
            end if;
          elsif irq_n = '1' and k(3) = '0' then
            -- latch write on rising-edge IRQn
            if coincred_mode > 0 then
              coincred_mode := coincred_mode - 1;
            else
              cmd <= k(2 downto 0);
              case k(2 downto 0) is
                when "001" =>
                  coincred_mode := 4;
                when "010" =>
                  mode := 1;
                  cnt := 0;
                when "101" =>
                  mode := 0;
                  cnt := 0;
                when others =>
                  null;
              end case;
            end if; --coincred_mode
          end if; -- irq_n and k(3)
        end if; -- irq_n_r /= irq_n
        irq_n_r := irq_n;
      end if; -- clk_en
    end if;
  end process;
  
 end architecture SYN;
 