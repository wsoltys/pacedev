library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity JumpBugProtection is
port
(
    -- address, data
    addri       : in     std_logic_vector(11 downto 0);
    datao       : out    std_logic_vector(7 downto 0)
) ;
end JumpBugProtection;

architecture beh of JumpBugProtection is
begin
    datao <= X"4F" when addri = X"114" else
             X"D3" when addri = X"118" else
             X"CF" when addri = X"214" else
             X"02" when addri = X"235" else
             X"00" when addri = X"311" else
             X"00";
end beh;

