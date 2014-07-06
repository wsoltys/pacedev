-- -----------------------------------------------------------------------
--
-- frequency divider
--
-- -----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
    generic (
        -- scale_factor = clk_in/clk_out*2
        scale_factor : integer
    );
    port (
        clk_in : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out: out STD_LOGIC
    );
end clk_div;

architecture rtl of clk_div is
    constant maxcount : integer := scale_factor-1;
    signal temporal: STD_LOGIC;
    signal counter : integer range 0 to maxcount := 0;
begin
    process (reset, clk_in) begin
        if (reset = '1') then
            temporal <= '0';
            counter <= 0;
        elsif rising_edge(clk_in) then
            if (counter = maxcount) then
                temporal <= NOT(temporal);
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    clk_out <= temporal;
end rtl;