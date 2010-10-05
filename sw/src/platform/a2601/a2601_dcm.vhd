library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity a2601_dcm is
  port
  (
    CLKIN_IN          : in    std_logic; 
    RST_IN            : in    std_logic; 
    CLKFX_OUT         : out   std_logic; 
    CLKIN_IBUFG_OUT   : out   std_logic
  );
end entity a2601_dcm;

architecture SYN of a2601_dcm is
begin

  pll_inst : entity work.pll
    port map
    (
      inclk0  => CLKIN_IN,
      c0      => CLKFX_OUT
    );

end architecture SYN;
