---------------------------------------------------------------------------------------------------
--
-- Design       : GALAXIAN video ram mapper
-- Author       : Mark McDougall
-- DATE         : 12/2003
-- ABSTRACT     : Translates vram address from tilemap controller and rotate screen
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.all;

entity vramMapper is
port
(
    clk     : in     std_logic;

    inAddr  : in     std_logic_vector(12 downto 0);
    outAddr : out    std_logic_vector(9 downto 0)
);
end vramMapper;

architecture SYN of vramMapper is

begin

  outAddr(9 downto 5) <= not inAddr(4 downto 0);
  outAddr(4 downto 0) <= inAddr(10 downto 6);

end SYN;
