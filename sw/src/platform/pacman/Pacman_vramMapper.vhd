---------------------------------------------------------------------------------------------------
--
-- Design       : PACMAN video ram mapper
-- Author       : Mark McDougall
-- DATE         : 12/2003
-- ABSTRACT     : Translates vram address from tilemap controller and rotate screen
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vramMapper is
port
(
    clk     : in     std_logic;

    inAddr  : in     std_logic_vector(11 downto 0);
    outAddr : out    std_logic_vector(9 downto 0)
) ;
end entity vramMapper;

architecture SYN of vramMapper is
begin
  process (clk, inAddr)
  begin
    -- first 64 bytes @offset $3C0
    if inAddr(11 downto 7) = "00000" then
       outAddr(9 downto 6) <= "1111";
       outAddr(5) <= inAddr(6);
       outAddr(4 downto 0) <= not(inAddr(4 downto 0));
    -- last 64 bytes @offset $0
    elsif inAddr(11) = '1' and inAddr(10 downto 7) /= "0000" then
       outAddr(9 downto 6) <= "0000";
       outAddr(5) <= inAddr(6);
       outAddr(4 downto 0) <= not(inAddr(4 downto 0));
    -- first 2 columns do not appear
    elsif inAddr (4 downto 1) = "0000" then
       outAddr(9 downto 5) <= "00000";
       outAddr(4 downto 0) <= "00000";
    -- last 2 columns do not appear
    elsif inAddr (4 downto 1) = "1111" then
       outAddr(9 downto 5) <= "00000";
       outAddr(4 downto 0) <= "00000";
    -- everything else rotated
    else
       outAddr(9 downto 5) <= not(inAddr(4 downto 0));
       outAddr(4 downto 0) <= std_logic_vector(unsigned(inAddr(10 downto 6)) - 2);
    end if;
  end process;
end SYN;


