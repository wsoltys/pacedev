-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library UNISIM;
  use UNISIM.Vcomponents.all;

entity SCRAMBLE_LUT is
  port (
    ADDR        : in    std_logic_vector(4 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_LUT is

  signal rom_addr : std_logic_vector(11 downto 0);

begin

  p_addr : process(ADDR)
  begin
     rom_addr <= (others => '0');
     rom_addr(4 downto 0) <= ADDR;
  end process;

  p_rom : process(rom_addr)
  begin
    DATA <= (others => '0');
    case rom_addr is
      when x"000" => DATA <= x"00";
      when x"001" => DATA <= x"07";
      when x"002" => DATA <= x"C0";
      when x"003" => DATA <= x"F6";
      when x"004" => DATA <= x"00";
      when x"005" => DATA <= x"F6";
      when x"006" => DATA <= x"5E";
      when x"007" => DATA <= x"5C";
      when x"008" => DATA <= x"00";
      when x"009" => DATA <= x"F0";
      when x"00A" => DATA <= x"3C";
      when x"00B" => DATA <= x"D7";
      when x"00C" => DATA <= x"00";
      when x"00D" => DATA <= x"C0";
      when x"00E" => DATA <= x"C4";
      when x"00F" => DATA <= x"07";
      when x"010" => DATA <= x"00";
      when x"011" => DATA <= x"31";
      when x"012" => DATA <= x"17";
      when x"013" => DATA <= x"F0";
      when x"014" => DATA <= x"00";
      when x"015" => DATA <= x"31";
      when x"016" => DATA <= x"C7";
      when x"017" => DATA <= x"3F";
      when x"018" => DATA <= x"00";
      when x"019" => DATA <= x"F6";
      when x"01A" => DATA <= x"07";
      when x"01B" => DATA <= x"31";
      when x"01C" => DATA <= x"00";
      when x"01D" => DATA <= x"3F";
      when x"01E" => DATA <= x"07";
      when x"01F" => DATA <= x"C4";
      when others => DATA <= (others => '0');
    end case;
  end process;
end RTL;
