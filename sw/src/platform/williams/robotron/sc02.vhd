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
    vram_a    : out std_logic_vector(15 downto 0)
  );
end entity sc02;

architecture SYN of sc02 is

  type r_a is array (natural range <>) of std_logic_vector(7 downto 0);
  signal r : r_a(0 to 2**3-1);
  
  alias cmd   : std_logic_vector(7 downto 0) is r(0);
  alias mask  : std_logic_vector(7 downto 0) is r(1);
  alias h     : std_logic_vector(7 downto 0) is r(6);
  alias w     : std_logic_vector(7 downto 0) is r(7);
  
begin

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
  
end architecture SYN;
