library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity ZigzagProtection is
port
(
    clk         : in std_logic;
    clk_ena     : in std_logic;

    -- address, data
    addri       : in std_logic_vector(15 downto 0);
    datai       : in std_logic_vector(7 downto 0);

    -- input control
    mem_wr      : in std_logic;

    -- output control
    addro       : out std_logic_vector(13 downto 0)
) ;
end ZigzagProtection;

architecture beh of ZigzagProtection is
  signal bank_sel_r : std_logic := '0';
begin
  process (clk)
  begin
    if rising_edge(clk) and clk_ena = '1' then
      -- gfxbank_wr $7002
      if addri = X"7002" and mem_wr = '1' then
        if (datai = X"00") then
          bank_sel_r <= '0';
        else
          bank_sel_r <= '1';
        end if;
      end if;
    end if;
  end process;

  -- construct the ROM address using the banking bit
  addro(13) <= addri(13);
  addro(12) <= -- no swapping for $0000-$1FFF
               addri(12) when addri(13) = '0' else
               -- maybe swap $2000-$2FFF & $3000-$3FFF
               addri(12) xor bank_sel_r;
  addro(11 downto 0) <= addri(11 downto 0);

end beh;

