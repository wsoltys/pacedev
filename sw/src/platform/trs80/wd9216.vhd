library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity wd9216 is
  port
  (
    clk           : in std_logic;
    clk_20M_ena   : in std_logic;
    reset         : in std_logic;
  
    dskd_n        : in std_logic;
    sepclk        : out std_logic;
    refclk        : in std_logic;
    cd            : in std_logic_vector(1 downto 0);
    sepd_n        : out std_logic;

    debug         : out std_logic_vector(31 downto 0)
  );
end entity wd9216;

architecture SYN of wd9216 is

begin
end architecture SYN;
