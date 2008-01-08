library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

-- 4-channel mixer
entity mixer4 is
port
(
    -- Sound inputs
    snd_A       : in    std_logic_vector(7 downto 0);
    snd_B       : in    std_logic_vector(7 downto 0);
    snd_C       : in    std_logic_vector(7 downto 0);
    snd_D       : in    std_logic_vector(7 downto 0);

    -- Sound output
    snd_out     : out   std_logic_vector(7 downto 0)
);
end mixer4;

architecture rtl of mixer4 is

    signal tmp_A       : std_logic_vector(7 downto 0);
    signal tmp_B       : std_logic_vector(7 downto 0);
    signal tmp_C       : std_logic_vector(7 downto 0);
    signal tmp_D       : std_logic_vector(7 downto 0);

begin
    tmp_A(5 downto 0) <= snd_A(7 downto 2);
    tmp_A(7 downto 6) <= "00";
    tmp_B(5 downto 0) <= snd_B(7 downto 2);
    tmp_B(7 downto 6) <= "00";
    tmp_C(5 downto 0) <= snd_C(7 downto 2);
    tmp_C(7 downto 6) <= "00";
    tmp_D(5 downto 0) <= snd_D(7 downto 2);
    tmp_D(7 downto 6) <= "00";

    snd_out <= tmp_A + tmp_B + tmp_C + tmp_D;
end rtl;

