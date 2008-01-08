library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pll4x is
  port
	(
      inclk0 : in std_logic := '0';     -- 21.48MHz input to PLL    (external I/O pin, from crystal oscillator)
      c0     : out std_logic ;          -- 21.48MHz output from PLL (internal LEs, for VDP, internal-bus, etc.)
      c1     : out std_logic ;          -- 85.92MHz output from PLL (internal LEs, for SD-RAM)
      e0     : out std_logic            -- 85.92MHz output from PLL (external I/O pin, for SD-RAM)
  );
  end pll4x;

architecture SYN of pll4x is
begin

	pll_inst : ENTITY work.pll4x_cycii
		PORT map
		(
			inclk0		=> inclk0,
			c0				=> c0,
			c1				=> c1,
			c2				=> e0
		);

end SYN;
