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
    p             : in std_logic_vector(3 downto 0);
    o             : in std_logic_vector(7 downto 0);
    k             : in std_logic_vector(3 downto 0);
    r             : in std_logic_vector(15 downto 0);
    
    to_n          : in std_logic;
    tc_n          : in std_logic;
    irq_n         : in std_logic
  );
 end entity namco_51xx;
 
 architecture SYN of namco_51xx is
 
 begin
 
  -- cpu interface
  process (clk, rst)
  begin
    if rst = '1' then
    elsif rising_edge(clk) then
      if clk_en = '1' then
        
      end if; -- clk_en
    end if;
  end process;
  
 end architecture SYN;
 