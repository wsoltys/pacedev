library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.A2601_CART_NAME;

entity cart_rom is
  port
  (
    clk   : in std_logic;
    d     : out std_logic_vector(7 downto 0);
    a     : in std_logic_vector(11 downto 0)
  );
end entity cart_rom;

architecture SYN of cart_rom is
begin

  rom_inst : entity work.sprom
    generic map
    (
      init_file		  => "../../../src/platform/a2601/roms/" & A2601_CART_NAME,
      numwords_a	  => 2**12,
      widthad_a		  => 12
    )
    port map
    (
      clock         => clk,
      address       => a,
      q             => d
    );

end architecture SYN;
