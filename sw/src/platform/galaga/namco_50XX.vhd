library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity namco_50xx is
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
    
    r_wn          : in std_logic;
    irq_n         : in std_logic;
    tc_n          : in std_logic;
    
    cmd           : in std_logic_vector(7 downto 0);
    ans           : out std_logic_vector(7 downto 0)
  );
 end entity namco_50xx;
 
 architecture SYN of namco_50xx is
 
  signal control  : std_logic_vector(7 downto 0) := (others => '0');
  
 begin
 
  process (clk, rst)
    variable irq_n_r  : std_logic := '0';
  begin
    if rst = '1' then
      irq_n_r := '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        -- read/write on leading-edge IRQn
        if irq_n_r = '1' and irq_n = '0' then
          if r_wn = '0' then
            -- write
          else
            -- read
          end if; -- r_wn
        end if; -- irq_n
        irq_n_r := irq_n;
      end if; -- clk_en
    end if;
  end process;
  
 end architecture SYN;
 