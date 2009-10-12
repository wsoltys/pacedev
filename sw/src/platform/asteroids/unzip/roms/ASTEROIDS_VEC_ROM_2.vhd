-- generated with romgen by MikeJ
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ASTEROIDS_VEC_ROM_2 is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(10 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of ASTEROIDS_VEC_ROM_2 is

  function romgen_str2slv (str : string) return std_logic_vector is
    variable result : std_logic_vector (str'length*4-1 downto 0);
  begin
    for i in 0 to str'length-1 loop
      case str(str'high-i) is
        when '0'       => result(i*4+3 downto i*4) := x"0";
        when '1'       => result(i*4+3 downto i*4) := x"1";
        when '2'       => result(i*4+3 downto i*4) := x"2";
        when '3'       => result(i*4+3 downto i*4) := x"3";
        when '4'       => result(i*4+3 downto i*4) := x"4";
        when '5'       => result(i*4+3 downto i*4) := x"5";
        when '6'       => result(i*4+3 downto i*4) := x"6";
        when '7'       => result(i*4+3 downto i*4) := x"7";
        when '8'       => result(i*4+3 downto i*4) := x"8";
        when '9'       => result(i*4+3 downto i*4) := x"9";
        when 'A'       => result(i*4+3 downto i*4) := x"A";
        when 'B'       => result(i*4+3 downto i*4) := x"B";
        when 'C'       => result(i*4+3 downto i*4) := x"C";
        when 'D'       => result(i*4+3 downto i*4) := x"D";
        when 'E'       => result(i*4+3 downto i*4) := x"E";
        when 'F'       => result(i*4+3 downto i*4) := x"F";
        when others => result(i*4+3 downto i*4) := "XXXX";
      end case;
    end loop;
    return result;
  end romgen_str2slv;

  attribute INIT_00 : string;
  attribute INIT_01 : string;
  attribute INIT_02 : string;
  attribute INIT_03 : string;
  attribute INIT_04 : string;
  attribute INIT_05 : string;
  attribute INIT_06 : string;
  attribute INIT_07 : string;
  attribute INIT_08 : string;
  attribute INIT_09 : string;
  attribute INIT_0A : string;
  attribute INIT_0B : string;
  attribute INIT_0C : string;
  attribute INIT_0D : string;
  attribute INIT_0E : string;
  attribute INIT_0F : string;

  component RAMB4_S2
    --pragma translate_off
    generic (
      INIT_00 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_01 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_02 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_03 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_04 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_05 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_06 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_07 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_08 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_09 : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0A : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0B : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0C : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0D : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0E : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0F : std_logic_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000"
      );
    --pragma translate_on
    port (
      DO    : out std_logic_vector (1 downto 0);
      DI    : in  std_logic_vector (1 downto 0);
      ADDR  : in  std_logic_vector (10 downto 0);
      WE    : in  std_logic;
      EN    : in  std_logic;
      RST   : in  std_logic;
      CLK   : in  std_logic 
      );
  end component;

  signal rom_addr : std_logic_vector(10 downto 0);

begin

  p_addr : process(ADDR)
  begin
     rom_addr <= (others => '0');
     rom_addr(10 downto 0) <= ADDR;
  end process;

  rom0 : if true generate
    attribute INIT_00 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_03 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_04 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_05 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_06 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_07 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_08 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0B of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0C of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0D of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0E of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0F of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
  begin
    inst : ramb4_s2
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2slv(inst'INIT_00),
        INIT_01 => romgen_str2slv(inst'INIT_01),
        INIT_02 => romgen_str2slv(inst'INIT_02),
        INIT_03 => romgen_str2slv(inst'INIT_03),
        INIT_04 => romgen_str2slv(inst'INIT_04),
        INIT_05 => romgen_str2slv(inst'INIT_05),
        INIT_06 => romgen_str2slv(inst'INIT_06),
        INIT_07 => romgen_str2slv(inst'INIT_07),
        INIT_08 => romgen_str2slv(inst'INIT_08),
        INIT_09 => romgen_str2slv(inst'INIT_09),
        INIT_0A => romgen_str2slv(inst'INIT_0A),
        INIT_0B => romgen_str2slv(inst'INIT_0B),
        INIT_0C => romgen_str2slv(inst'INIT_0C),
        INIT_0D => romgen_str2slv(inst'INIT_0D),
        INIT_0E => romgen_str2slv(inst'INIT_0E),
        INIT_0F => romgen_str2slv(inst'INIT_0F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(1 downto 0),
        DI   => "00",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom1 : if true generate
    attribute INIT_00 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_03 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_04 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_05 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_06 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_07 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_08 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0B of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0C of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0D of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0E of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0F of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
  begin
    inst : ramb4_s2
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2slv(inst'INIT_00),
        INIT_01 => romgen_str2slv(inst'INIT_01),
        INIT_02 => romgen_str2slv(inst'INIT_02),
        INIT_03 => romgen_str2slv(inst'INIT_03),
        INIT_04 => romgen_str2slv(inst'INIT_04),
        INIT_05 => romgen_str2slv(inst'INIT_05),
        INIT_06 => romgen_str2slv(inst'INIT_06),
        INIT_07 => romgen_str2slv(inst'INIT_07),
        INIT_08 => romgen_str2slv(inst'INIT_08),
        INIT_09 => romgen_str2slv(inst'INIT_09),
        INIT_0A => romgen_str2slv(inst'INIT_0A),
        INIT_0B => romgen_str2slv(inst'INIT_0B),
        INIT_0C => romgen_str2slv(inst'INIT_0C),
        INIT_0D => romgen_str2slv(inst'INIT_0D),
        INIT_0E => romgen_str2slv(inst'INIT_0E),
        INIT_0F => romgen_str2slv(inst'INIT_0F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(3 downto 2),
        DI   => "00",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom2 : if true generate
    attribute INIT_00 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_03 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_04 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_05 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_06 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_07 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_08 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0B of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0C of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0D of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0E of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0F of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
  begin
    inst : ramb4_s2
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2slv(inst'INIT_00),
        INIT_01 => romgen_str2slv(inst'INIT_01),
        INIT_02 => romgen_str2slv(inst'INIT_02),
        INIT_03 => romgen_str2slv(inst'INIT_03),
        INIT_04 => romgen_str2slv(inst'INIT_04),
        INIT_05 => romgen_str2slv(inst'INIT_05),
        INIT_06 => romgen_str2slv(inst'INIT_06),
        INIT_07 => romgen_str2slv(inst'INIT_07),
        INIT_08 => romgen_str2slv(inst'INIT_08),
        INIT_09 => romgen_str2slv(inst'INIT_09),
        INIT_0A => romgen_str2slv(inst'INIT_0A),
        INIT_0B => romgen_str2slv(inst'INIT_0B),
        INIT_0C => romgen_str2slv(inst'INIT_0C),
        INIT_0D => romgen_str2slv(inst'INIT_0D),
        INIT_0E => romgen_str2slv(inst'INIT_0E),
        INIT_0F => romgen_str2slv(inst'INIT_0F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(5 downto 4),
        DI   => "00",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom3 : if true generate
    attribute INIT_00 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_03 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_04 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_05 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_06 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_07 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_08 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0B of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0C of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0D of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0E of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0F of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
  begin
    inst : ramb4_s2
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2slv(inst'INIT_00),
        INIT_01 => romgen_str2slv(inst'INIT_01),
        INIT_02 => romgen_str2slv(inst'INIT_02),
        INIT_03 => romgen_str2slv(inst'INIT_03),
        INIT_04 => romgen_str2slv(inst'INIT_04),
        INIT_05 => romgen_str2slv(inst'INIT_05),
        INIT_06 => romgen_str2slv(inst'INIT_06),
        INIT_07 => romgen_str2slv(inst'INIT_07),
        INIT_08 => romgen_str2slv(inst'INIT_08),
        INIT_09 => romgen_str2slv(inst'INIT_09),
        INIT_0A => romgen_str2slv(inst'INIT_0A),
        INIT_0B => romgen_str2slv(inst'INIT_0B),
        INIT_0C => romgen_str2slv(inst'INIT_0C),
        INIT_0D => romgen_str2slv(inst'INIT_0D),
        INIT_0E => romgen_str2slv(inst'INIT_0E),
        INIT_0F => romgen_str2slv(inst'INIT_0F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(7 downto 6),
        DI   => "00",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
end RTL;
