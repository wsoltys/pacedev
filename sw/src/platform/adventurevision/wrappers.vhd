library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adventurevision_bios is
  port 
  (
    Clk : in  std_logic;
    A   : in  std_logic_vector(9 downto 0);
    D   : out std_logic_vector(7 downto 0)
  );
end adventurevision_bios;

architecture SYN of adventurevision_bios is

begin
	
  bios_b : entity work.sprom
    generic map 
		(
			numwords_a		=> 1024,
      widthad_a     => 10,
      init_file     => "../../../../src/platform/adventurevision/roms/bios.hex"
    )
    port map 
		(
      clock    			=> Clk,
      address 			=> A,
      q       			=> D
    );

end SYN;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity rom_t41x is
  port 
  (
    Clk : in  std_logic;
    A   : in  std_logic_vector(8 downto 0);
    D   : out std_logic_vector(7 downto 0)
  );
end rom_t41x;

architecture SYN of rom_t41x is

begin
	
  rom_t41x_b : entity work.sprom
    generic map 
		(
			numwords_a		=> 512,
      widthad_a     => 9,
      init_file     => "../../../../src/platform/adventurevision/roms/t41x_rom.hex"
    )
    port map 
		(
      clock    			=> Clk,
      address 			=> A,
      q       			=> D
    );

end SYN;
