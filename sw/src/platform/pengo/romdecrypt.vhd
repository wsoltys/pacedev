library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity PengoRomDecrypt is
port
(
    clk           : in     std_logic;

    -- address
    addr          : in     std_logic_vector(15 downto 0);
    m1_n          : in     std_logic;

    -- input data
    encrypt_data  : in     std_logic_vector(7 downto 0);

    -- output data
    decrypt_data  : out    std_logic_vector(7 downto 0)
) ;
end PengoRomDecrypt;

architecture beh of PengoRomDecrypt is
    signal sel : std_logic_vector(3 downto 0);
begin
     sel(3 downto 0) <= addr(12) & addr(8) & addr(4) & addr(0);

     process (clk, m1_n)
     begin

          if (m1_n = '0') then

          -- opcodes
          case sel(3 downto 0) is
               when "0000" | "1011" =>
                    decrypt_data(3) <= encrypt_data(5);
                    decrypt_data(5) <= not encrypt_data(3);
                    decrypt_data(7) <= not encrypt_data(7);
               when "0001" =>
                    decrypt_data(3) <= not encrypt_data(7);
                    decrypt_data(5) <= not encrypt_data(5);
                    decrypt_data(7) <= encrypt_data(3);
               when "0010" | "0101" | "0110" | "0111"  =>
                    decrypt_data(3) <= encrypt_data(7);
                    decrypt_data(5) <= not encrypt_data(3);
                    decrypt_data(7) <= not encrypt_data(5);
               when "0011" | "1010" | "1110" =>
                    decrypt_data(3) <= not encrypt_data(7);
                    decrypt_data(5) <= encrypt_data(3);
                    decrypt_data(7) <= encrypt_data(5);
               when "0100" | "1100" | "1111" =>
                    decrypt_data(3) <= not encrypt_data(3);
                    decrypt_data(5) <= encrypt_data(7);
                    decrypt_data(7) <= encrypt_data(5);
               when "1000" | "1001" =>
                    decrypt_data(3) <= not encrypt_data(3);
                    decrypt_data(5) <= encrypt_data(7);
                    decrypt_data(7) <= not encrypt_data(5);
               when others => -- "1101"
                    decrypt_data(3) <= encrypt_data(3);
                    decrypt_data(5) <= encrypt_data(5);
                    decrypt_data(7) <= encrypt_data(7);
          end case;

          else

          -- operands
          case sel(3 downto 0) is
               when "0000" | "0100" =>
                    decrypt_data(3) <= not encrypt_data(7);
                    decrypt_data(5) <= not encrypt_data(5);
                    decrypt_data(7) <= encrypt_data(3);
               when "0001" | "0011"  =>
                    decrypt_data(3) <= encrypt_data(5);
                    decrypt_data(5) <= not encrypt_data(3);
                    decrypt_data(7) <= not encrypt_data(7);
               when "0010" | "0110" | "1000" | "1011" | "1111"  =>
                    decrypt_data(3) <= encrypt_data(7);
                    decrypt_data(5) <= not encrypt_data(3);
                    decrypt_data(7) <= not encrypt_data(5);
               when "0101" =>
                    decrypt_data(3) <= not encrypt_data(3);
                    decrypt_data(5) <= encrypt_data(7);
                    decrypt_data(7) <= encrypt_data(5);
               when "0111" | "1001" =>
                    decrypt_data(3) <= encrypt_data(3);
                    decrypt_data(5) <= encrypt_data(5);
                    decrypt_data(7) <= encrypt_data(7);
               when "1010" | "1110" =>
                    decrypt_data(3) <= not encrypt_data(7);
                    decrypt_data(5) <= encrypt_data(3);
                    decrypt_data(7) <= encrypt_data(5);

               when others => -- "1100" | "1101"
                    decrypt_data(3) <= not encrypt_data(3);
                    decrypt_data(5) <= encrypt_data(7);
                    decrypt_data(7) <= not encrypt_data(5);
          end case;

          end if;
     end process;

     -- non-encrypted data lines
     decrypt_data(0) <= encrypt_data(0);
     decrypt_data(1) <= encrypt_data(1);
     decrypt_data(2) <= encrypt_data(2);
     decrypt_data(4) <= encrypt_data(4);
     decrypt_data(6) <= encrypt_data(6);

end beh;

