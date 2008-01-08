-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity SCRAMBLE_PGM_23 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_PGM_23 is

  function romgen_str2bv (str : string) return bit_vector is
    variable result : bit_vector (str'length*4-1 downto 0);
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
        when others    => null;
      end case;
    end loop;
    return result;
  end romgen_str2bv;

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
  attribute INIT_10 : string;
  attribute INIT_11 : string;
  attribute INIT_12 : string;
  attribute INIT_13 : string;
  attribute INIT_14 : string;
  attribute INIT_15 : string;
  attribute INIT_16 : string;
  attribute INIT_17 : string;
  attribute INIT_18 : string;
  attribute INIT_19 : string;
  attribute INIT_1A : string;
  attribute INIT_1B : string;
  attribute INIT_1C : string;
  attribute INIT_1D : string;
  attribute INIT_1E : string;
  attribute INIT_1F : string;
  attribute INIT_20 : string;
  attribute INIT_21 : string;
  attribute INIT_22 : string;
  attribute INIT_23 : string;
  attribute INIT_24 : string;
  attribute INIT_25 : string;
  attribute INIT_26 : string;
  attribute INIT_27 : string;
  attribute INIT_28 : string;
  attribute INIT_29 : string;
  attribute INIT_2A : string;
  attribute INIT_2B : string;
  attribute INIT_2C : string;
  attribute INIT_2D : string;
  attribute INIT_2E : string;
  attribute INIT_2F : string;
  attribute INIT_30 : string;
  attribute INIT_31 : string;
  attribute INIT_32 : string;
  attribute INIT_33 : string;
  attribute INIT_34 : string;
  attribute INIT_35 : string;
  attribute INIT_36 : string;
  attribute INIT_37 : string;
  attribute INIT_38 : string;
  attribute INIT_39 : string;
  attribute INIT_3A : string;
  attribute INIT_3B : string;
  attribute INIT_3C : string;
  attribute INIT_3D : string;
  attribute INIT_3E : string;
  attribute INIT_3F : string;

  component RAMB16_S4
    --pragma translate_off
    generic (
      INIT_00 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_01 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_02 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_03 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_04 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_05 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_06 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_07 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_08 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_09 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_10 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_11 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_12 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_13 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_14 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_15 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_16 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_17 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_18 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_19 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_20 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_21 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_22 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_23 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_24 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_25 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_26 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_27 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_28 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_29 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_30 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_31 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_32 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_33 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_34 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_35 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_36 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_37 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_38 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_39 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000"
      );
    --pragma translate_on
    port (
      DO    : out std_logic_vector (3 downto 0);
      ADDR  : in  std_logic_vector (11 downto 0);
      CLK   : in  std_logic;
      DI    : in  std_logic_vector (3 downto 0);
      EN    : in  std_logic;
      SSR   : in  std_logic;
      WE    : in  std_logic 
      );
  end component;

  signal rom_addr : std_logic_vector(11 downto 0);

begin

  p_addr : process(ADDR)
  begin
     rom_addr <= (others => '0');
     rom_addr(11 downto 0) <= ADDR;
  end process;

  rom0 : if true generate
    attribute INIT_00 of inst : label is "BA94511060910B2821055019F201F6C1F6B1F621F661EDDFD14C055019FCEF6B";
    attribute INIT_01 of inst : label is "66CB6C4C26501562AA15420910D081001011F6D1EDDFD1050910B2906170EA60";
    attribute INIT_02 of inst : label is "510CCC34000010CCC34000800CCC34000500CCC213095602400B6A020E0A0C09";
    attribute INIT_03 of inst : label is "6501B6055215629F01756A5423E54A5605501925439D0CCC34000080CCC34000";
    attribute INIT_04 of inst : label is "ED3ED197D86D7860E0014C05501944C6650105531562913156A5C160550194C4";
    attribute INIT_05 of inst : label is "11520EF7211D2E32E332E1811517061010D2322F3023020110921E35D2FD4511";
    attribute INIT_06 of inst : label is "5F0AA527190A2F40518702A9065118F6CE301F0DAAD68D57DBBD9F67156CF615";
    attribute INIT_07 of inst : label is "6903170ED60BA94C060910B28210620027F06001EDDED1832D8421E092F29131";
    attribute INIT_08 of inst : label is "1D8702A9982FFFF8068982F6707AFCF6EF611F7110D2872862F4C050910B297D";
    attribute INIT_09 of inst : label is "AF4011ED2DDF6410621E0523E0A2F0D21010222682E02A87B272FB01A9FC1868";
    attribute INIT_0A of inst : label is "1111101092F02120170600170620177101F90521E203001022DA8702A9FC0F0E";
    attribute INIT_0B of inst : label is "3D303EF0AAAAA39F81827F3238303EF0AA9A0C3C20698110118218207A0D0600";
    attribute INIT_0C of inst : label is "050910B270E060BA2F30621E97D0B280106D40A1706001092FAAA3949E827F32";
    attribute INIT_0D of inst : label is "0D001101101F0EF731F4EF4F2EF50158F0EA66D40A10D28728622F2FED3ED14C";
    attribute INIT_0E of inst : label is "F0EF731FCF631FCFCF50166D40A10D21E8728621E80F0FA2F2F58F51191821DA";
    attribute INIT_0F of inst : label is "E6EE60C1891706001092F2FD97D86DF7EF6214C060509191821DA0D001101101";
    attribute INIT_10 of inst : label is "80800030E818600E83860F82E0E06868030E8D0600E83860E894091C1C1C1C79";
    attribute INIT_11 of inst : label is "2F18D802000C06002028C8D000800485000FDFC84002FE05868020D818000282";
    attribute INIT_12 of inst : label is "800000800828481002028D00000800C0C80082838F800800F02000F2F182000F";
    attribute INIT_13 of inst : label is "100858C00C028006802000C0C80082808C802000C0600180000C003028000801";
    attribute INIT_14 of inst : label is "2A0A0606010FAF60600AF2FD8E002028D8E0020286020020280810008E8C0000";
    attribute INIT_15 of inst : label is "81A0A0606000800602040800686840FAF68680AFAFE0602AFAF60601AF2F6060";
    attribute INIT_16 of inst : label is "680A0A0E0600A020D8E00A8A860600A8A86060000A020181A0A060600A0A0201";
    attribute INIT_17 of inst : label is "81020800686810800686800FAFD0604AF2F6060020A860E81A82868684202868";
    attribute INIT_18 of inst : label is "60601A0A0606010FAF60600AF2FD8E002028D8E0020286020020280810008002";
    attribute INIT_19 of inst : label is "020184A0A0606000800602010800686810FAF68680AFAFE0602AFAF60602AF2F";
    attribute INIT_1A of inst : label is "2868680A0A0E0600A020D8E00A8A860600A8A86060000A020181A0A060600A0A";
    attribute INIT_1B of inst : label is "800281040800686840800686800FAFD0601AF2F6060020A860E84A8286868420";
    attribute INIT_1C of inst : label is "20E86060100086060200086060000CF48601202860600202860C802028C0C800";
    attribute INIT_1D of inst : label is "0000840080000800080C7280008420286060120E860604C0E86060000C660481";
    attribute INIT_1E of inst : label is "00A8A860C80A8A840082A8A860601C0A860600A8A848C80A8A8C0C80A8A8C0C8";
    attribute INIT_1F of inst : label is "1F008A808000A8A808604A8A860600A8A848601A8A860601A8A860601A8A8606";
    attribute INIT_20 of inst : label is "182E906F0771EA1510D060D1111101F7315181322F3023020110921E4CA60509";
    attribute INIT_21 of inst : label is "8FE301B6D1BDBBDF0DAAD68D57DBBD9F7011625E152FE1528EF7211D2E3192E3";
    attribute INIT_22 of inst : label is "60197D86D80718A946D860A106C665010FE12A946D40A10D101063113018FEC9";
    attribute INIT_23 of inst : label is "0E0E051831926D40A1926D360A198F0EA9092F0A29E06C66501832D8421EF2EF";
    attribute INIT_24 of inst : label is "190D060F10110010D060F12112010D062012112019A0C7C7F960A160D9C037B6";
    attribute INIT_25 of inst : label is "11011019512F0521EA0718A916D360A190718A9512F0521E98F0EA00718A0509";
    attribute INIT_26 of inst : label is "40A19092F0A29E06C66501832D8421EF3EF60197D86D80718A90524E0A2F0D00";
    attribute INIT_27 of inst : label is "23E0A2F0D001101101916D360A190718A9512F0521EA0718A00718A05091946D";
    attribute INIT_28 of inst : label is "186D4C0550192228E0928320E8421E4C5605501F0D68D57DBBDA0A5ADF51A905";
    attribute INIT_29 of inst : label is "A4F51AED3ED11E2F2FDA6D360A12F2FF7014101418105501973EDDFD1FCFCF68";
    attribute INIT_2A of inst : label is "60A10550194C06501F2010690F106F77B8AEDA5DED3FD1F2EF6014C05501A7A8";
    attribute INIT_2B of inst : label is "1DE88DDDC9D9080ED0ED701ED1EDF02ED2ED201D9D20F0DA021DA0310E1946D7";
    attribute INIT_2C of inst : label is "18110D87E07130F0DA0410717A9F3C10F62FA927D2ED17D1ED07D0EDF8D2012D";
    attribute INIT_2D of inst : label is "7DE367D58FEED6DCED9E7DD587EEDE9348D39D2FD17DEFD06DD4D91721EF7314";
    attribute INIT_2E of inst : label is "16C0668E84ED6ED68E8483ED5ED0A6DF57E15D98D7DE3C7DE39D4DC5D3E7DE32";
    attribute INIT_2F of inst : label is "8F66D4ED756D3EDF6CF658F46D6ED756D3ED16CF658C84ED6ED906C069F6C069";
    attribute INIT_30 of inst : label is "06C1668F66D4ED736D5EDF6C16B8F46D6ED736D5ED16C1658C84ED6ED906CF60";
    attribute INIT_31 of inst : label is "4ED9F07B9950382D797FB869787F9FB6D196D08F18196D9B7DC4D096DB868899";
    attribute INIT_32 of inst : label is "A6DBED47D46D8ED9747D46D8ED0A7DA6DBED37D36D7EDE869BD885ED3EDA86ED";
    attribute INIT_33 of inst : label is "0EE46D3ED9745D9744D506ED4ED979735D9734D50C85ED3ED9737D36D7ED0A7D";
    attribute INIT_34 of inst : label is "964DD4CF66ED57D4ED2075ED101D944D35D347D46DE337D36D9847DE337DE3C0";
    attribute INIT_35 of inst : label is "60ED90E12423ED252906FFFF862ED59926F706F6ED2021021E18ADD83DAD955D";
    attribute INIT_36 of inst : label is "ED18296E2074ED9E18A112282F86C70EDC86C72ED9101FFF82121ED2229FFFF8";
    attribute INIT_37 of inst : label is "F864ED90E12C27ED2D29FFFF866ED599268874ED91B2BB25A1A25ED388ED5874";
    attribute INIT_38 of inst : label is "D860BD9909DEAD46031501D92821121E74EDCC76EDC9101FFF82925ED2A29FFF";
    attribute INIT_39 of inst : label is "D046D836D836DF7F6FDF2F1F0FFFCEAE3F2ED0F16D0ED301D960BD0FE27D362E";
    attribute INIT_3A of inst : label is "D301D924D405D562866684688D78710AB0516124D0E6D0E6D3C2F713C2F81046";
    attribute INIT_3B of inst : label is "0F935D37D88ED3EDE0F88B287B0B287B0602A38F0DAB0F06AF53EFDB3D301DB3";
    attribute INIT_3C of inst : label is "00EC4EDE077700A68F0DAE0F06A8880B287B00A8B287B0602A934D37D08EC3ED";
    attribute INIT_3D of inst : label is "6D116D006D80E3ED34D34DB3D301DB3D301D8801A945D47D80ED4ED07944D47D";
    attribute INIT_3E of inst : label is "301DB3D301DFCC362FA24D0E6D3C20E1FF6D0E6D3C20619999626D116D006D62";
    attribute INIT_3F of inst : label is "5B0590570F8F5E65C65A658699917276C17A9016D016D0F5D44D44D60715AB3D";
  begin
  inst : RAMB16_S4
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2bv(inst'INIT_00),
        INIT_01 => romgen_str2bv(inst'INIT_01),
        INIT_02 => romgen_str2bv(inst'INIT_02),
        INIT_03 => romgen_str2bv(inst'INIT_03),
        INIT_04 => romgen_str2bv(inst'INIT_04),
        INIT_05 => romgen_str2bv(inst'INIT_05),
        INIT_06 => romgen_str2bv(inst'INIT_06),
        INIT_07 => romgen_str2bv(inst'INIT_07),
        INIT_08 => romgen_str2bv(inst'INIT_08),
        INIT_09 => romgen_str2bv(inst'INIT_09),
        INIT_0A => romgen_str2bv(inst'INIT_0A),
        INIT_0B => romgen_str2bv(inst'INIT_0B),
        INIT_0C => romgen_str2bv(inst'INIT_0C),
        INIT_0D => romgen_str2bv(inst'INIT_0D),
        INIT_0E => romgen_str2bv(inst'INIT_0E),
        INIT_0F => romgen_str2bv(inst'INIT_0F),
        INIT_10 => romgen_str2bv(inst'INIT_10),
        INIT_11 => romgen_str2bv(inst'INIT_11),
        INIT_12 => romgen_str2bv(inst'INIT_12),
        INIT_13 => romgen_str2bv(inst'INIT_13),
        INIT_14 => romgen_str2bv(inst'INIT_14),
        INIT_15 => romgen_str2bv(inst'INIT_15),
        INIT_16 => romgen_str2bv(inst'INIT_16),
        INIT_17 => romgen_str2bv(inst'INIT_17),
        INIT_18 => romgen_str2bv(inst'INIT_18),
        INIT_19 => romgen_str2bv(inst'INIT_19),
        INIT_1A => romgen_str2bv(inst'INIT_1A),
        INIT_1B => romgen_str2bv(inst'INIT_1B),
        INIT_1C => romgen_str2bv(inst'INIT_1C),
        INIT_1D => romgen_str2bv(inst'INIT_1D),
        INIT_1E => romgen_str2bv(inst'INIT_1E),
        INIT_1F => romgen_str2bv(inst'INIT_1F),
        INIT_20 => romgen_str2bv(inst'INIT_20),
        INIT_21 => romgen_str2bv(inst'INIT_21),
        INIT_22 => romgen_str2bv(inst'INIT_22),
        INIT_23 => romgen_str2bv(inst'INIT_23),
        INIT_24 => romgen_str2bv(inst'INIT_24),
        INIT_25 => romgen_str2bv(inst'INIT_25),
        INIT_26 => romgen_str2bv(inst'INIT_26),
        INIT_27 => romgen_str2bv(inst'INIT_27),
        INIT_28 => romgen_str2bv(inst'INIT_28),
        INIT_29 => romgen_str2bv(inst'INIT_29),
        INIT_2A => romgen_str2bv(inst'INIT_2A),
        INIT_2B => romgen_str2bv(inst'INIT_2B),
        INIT_2C => romgen_str2bv(inst'INIT_2C),
        INIT_2D => romgen_str2bv(inst'INIT_2D),
        INIT_2E => romgen_str2bv(inst'INIT_2E),
        INIT_2F => romgen_str2bv(inst'INIT_2F),
        INIT_30 => romgen_str2bv(inst'INIT_30),
        INIT_31 => romgen_str2bv(inst'INIT_31),
        INIT_32 => romgen_str2bv(inst'INIT_32),
        INIT_33 => romgen_str2bv(inst'INIT_33),
        INIT_34 => romgen_str2bv(inst'INIT_34),
        INIT_35 => romgen_str2bv(inst'INIT_35),
        INIT_36 => romgen_str2bv(inst'INIT_36),
        INIT_37 => romgen_str2bv(inst'INIT_37),
        INIT_38 => romgen_str2bv(inst'INIT_38),
        INIT_39 => romgen_str2bv(inst'INIT_39),
        INIT_3A => romgen_str2bv(inst'INIT_3A),
        INIT_3B => romgen_str2bv(inst'INIT_3B),
        INIT_3C => romgen_str2bv(inst'INIT_3C),
        INIT_3D => romgen_str2bv(inst'INIT_3D),
        INIT_3E => romgen_str2bv(inst'INIT_3E),
        INIT_3F => romgen_str2bv(inst'INIT_3F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(3 downto 0),
        ADDR => rom_addr,
        CLK  => CLK,
        DI   => "0000",
        EN   => ENA,
        SSR  => '0',
        WE   => '0'
        );
  end generate;
  rom1 : if true generate
    attribute INIT_00 of inst : label is "02C344223402402402C3442CF001F081F081F091F0810AC03232C3442CF01F00";
    attribute INIT_01 of inst : label is "0320323233442442442442192BE010461182F0010AC012C34024021001D13104";
    attribute INIT_02 of inst : label is "001000222100010002221001100022210011000C035A0259015701560154015C";
    attribute INIT_03 of inst : label is "344203C34424421FE174424422744203C3442221222110002221000100022210";
    attribute INIT_04 of inst : label is "0AC0B211C1FCD101346232C3442C33293442C344244210614423203C3442C321";
    attribute INIT_05 of inst : label is "241323F001413721712174113B2D40402403483A4A2482002413031FC1CC3442";
    attribute INIT_06 of inst : label is "CE403E142C403A3402CA403C03442D0B274822CC2AC23C23C14CCF001032F340";
    attribute INIT_07 of inst : label is "01001D1310402C32134024024024034B3DA404620AC0D2603360303413A131F1";
    attribute INIT_08 of inst : label is "13CA403C4930000CFE74730E4413F1F11F001F001403603603A32C34024021D1";
    attribute INIT_09 of inst : label is "3F00130C19CF0014030340303403A4020024030DD0F403C7C18C7C413CF10201";
    attribute INIT_0A of inst : label is "0401402413DB00462D40462D10432D4402AC4030316C002403302A403CF1D040";
    attribute INIT_0B of inst : label is "181310E4031710131B161F1D141310E403CF1272720C214C2483443403BE030C";
    attribute INIT_0C of inst : label is "C3402402D13204021CC4030311C4024022323402D40462413A17101C18161F1D";
    attribute INIT_0D of inst : label is "BE040401442F01F001F01F1F01F0012304039323402403603603453A0AC0B232";
    attribute INIT_0E of inst : label is "F01F001F1F001F1F1F00193234024030360360303030403453AD1F001C412412";
    attribute INIT_0F of inst : label is "03310011412D40462413A1CC11C1FCF01F0813223C3402C412412BE040401482";
    attribute INIT_10 of inst : label is "43C3D064533D3E053633E2D053533D3D063522D3D052623D2CCF117272727273";
    attribute INIT_11 of inst : label is "653D2D065652D3D065642C2C064653B3C065552B3B065553B3B065543B3C0646";
    attribute INIT_12 of inst : label is "3643C3C064643C3D064632D3D063642D2C064643C2C064652C3C065653C3D065";
    attribute INIT_13 of inst : label is "63633C2C054633C3C063632C2B063633B2B063632B3B063643B2B064633B3B06";
    attribute INIT_14 of inst : label is "035353D3D065353D3D035652C2C065642B2B064633B3B063623B3C062522C3C0";
    attribute INIT_15 of inst : label is "C033333D3D063643D3D064653D3D065353D3D035352D3D035353D3D035653D3D";
    attribute INIT_16 of inst : label is "3C033332C3C033632B2B032323B3B032323B3B063333B3B033333C3C033333C3";
    attribute INIT_17 of inst : label is "C3D063643D3D064653D3D065352D3D035653D3D065343D2C034643C3C064633C";
    attribute INIT_18 of inst : label is "3D3D035353D3D065353D3D035652C2C065642B2B064633B3B063623B3C062633";
    attribute INIT_19 of inst : label is "33C3C033333D3D063643D3D064653D3D065353D3D035352D3D035353D3D03565";
    attribute INIT_1A of inst : label is "633C3C033332C3C033632B2B032323B3B032323B3B063333B3B033333C3C0333";
    attribute INIT_1B of inst : label is "2633C3D063643D3D064653D3D065352D3D035653D3D065343D2C034643C3C064";
    attribute INIT_1C of inst : label is "63523E3E063633E3E064643E3E065553D3E065643E3E064633E2D063622D2C06";
    attribute INIT_1D of inst : label is "063633B3B064643C3C055643D3D064633E3E063523E3E053523E3E063533E3D0";
    attribute INIT_1E of inst : label is "E032323E2D032323D3D032323E3E053323E3E032323D2D032322D2C032322C2B";
    attribute INIT_1F of inst : label is "2F062323C3D032323D3E032323E3E032323D3E032323E3E032323E3E032323E3";
    attribute INIT_20 of inst : label is "413710158844133B2BE03000411412F0013402483A4A2482002413033203C340";
    attribute INIT_21 of inst : label is "30748212C37C11C2CC2AC23C23C14CCF00140303403F341303F0014137241372";
    attribute INIT_22 of inst : label is "00111C1FC22A403C6320340203293482CFF413C6323402BE0A003481482D0721";
    attribute INIT_23 of inst : label is "1320001402C3323402C33203402030403C413A40303032934C2603360303F01F";
    attribute INIT_24 of inst : label is "2CBE03030461462BE03010461462BE030A0481482CF12727A10422F201F12710";
    attribute INIT_25 of inst : label is "0441402C443A4030302A483C0320340212A483C443A4030313040312A403C340";
    attribute INIT_26 of inst : label is "3402C413A40303032934C2603360303F01F00111C1FC22A403C40303403ABE04";
    attribute INIT_27 of inst : label is "303403ABE040481402C0320340202A443C443A4030302A44312A403C3402C632";
    attribute INIT_28 of inst : label is "11FC32C3482C8030341360303603033203C34822CC23C23C14C151310E483C40";
    attribute INIT_29 of inst : label is "18E4C30AC0B2413A1CC03203402453AF00134023402C348211C0AC052F1F1F00";
    attribute INIT_2A of inst : label is "3402C34C2C32834C2F00103142201588020F71CC0AC032F81F08132C34C21B19";
    attribute INIT_2B of inst : label is "27D1C00021F03C0BF07D020BF07D020BF07D402F1D0304034A2D6001010C6320";
    attribute INIT_2C of inst : label is "4023BCCA74A20304034A2CA403CF001C3E453C07F07D07F07D07F07D6BE42141";
    attribute INIT_2D of inst : label is "7D7217D12FF706D06DC07D302A07D12C2CC28C2BC29C14C23C12CC40303F0013";
    attribute INIT_2E of inst : label is "0320303020BD07D5113020BD07D003D6803EEDC107D7207D72C07D07D207D721";
    attribute INIT_2F of inst : label is "1409D07D409D07DF32F351409D07D409D07D032F313220BD07DC03203CF3203C";
    attribute INIT_30 of inst : label is "0320301409D07D409D07DF320311409D07D409D07D0320313220BD07DC032F34";
    attribute INIT_31 of inst : label is "07DCE18C1CF1035EA20FC005566ACF03D003DF1447003DC07D16C003D0312B7C";
    attribute INIT_32 of inst : label is "08D07D07D08D07DCA07D08D07DD07D08D07D07D08D07D1240CD520BD07D420BD";
    attribute INIT_33 of inst : label is "8F716D16DCA03DCA03D030BD07DC3CA03DCA03D03020BD07DCA07D08D07DD07D";
    attribute INIT_34 of inst : label is "C03D14C0E07D07D07D12A07D412DC17D17D207D08D7207D08DE117D7217D7202";
    attribute INIT_35 of inst : label is "E07F121E43307F4321015000FE07FE221264FE207D43341303412F1DC14CC03D";
    attribute INIT_36 of inst : label is "7F41210102A07F01412413433A232707F2232707F14C2500743307F43215000F";
    attribute INIT_37 of inst : label is "0FE07F121E43307F43215000FE07FE22126CA07FC4122243241307F0107F02A0";
    attribute INIT_38 of inst : label is "DC40CDCF11D13C00001402DC43341303707F22707F214C2500743307F4321500";
    attribute INIT_39 of inst : label is "DD03D523D503D1E1E1A19191918151917E07DD00BD07D482DC80CDD1F07D0D07";
    attribute INIT_3A of inst : label is "C4A2DC03D0232030103010302302A40312340203D023D003D4A21F24821E2E23";
    attribute INIT_3B of inst : label is "D0C23D07DD3F307D0307CC027CCC026C0041333040313040312C1CC16C482D16";
    attribute INIT_3C of inst : label is "DDF307D03000413230403130403C17CC024C413CC024C00413C23D07DDDF307D";
    attribute INIT_3D of inst : label is "3D003D003DDFF07D23D03D16C482D16C4A2DD1413C23D07DD8F307DD0C23D07D";
    attribute INIT_3E of inst : label is "482D16C4A2D1DC0E45303D023D4A2212603D003D482202CCCC023D023D023D00";
    attribute INIT_3F of inst : label is "0200200201EF020020020020CCC4130E3413C023D003DC03D23D03D02A41316C";
  begin
  inst : RAMB16_S4
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2bv(inst'INIT_00),
        INIT_01 => romgen_str2bv(inst'INIT_01),
        INIT_02 => romgen_str2bv(inst'INIT_02),
        INIT_03 => romgen_str2bv(inst'INIT_03),
        INIT_04 => romgen_str2bv(inst'INIT_04),
        INIT_05 => romgen_str2bv(inst'INIT_05),
        INIT_06 => romgen_str2bv(inst'INIT_06),
        INIT_07 => romgen_str2bv(inst'INIT_07),
        INIT_08 => romgen_str2bv(inst'INIT_08),
        INIT_09 => romgen_str2bv(inst'INIT_09),
        INIT_0A => romgen_str2bv(inst'INIT_0A),
        INIT_0B => romgen_str2bv(inst'INIT_0B),
        INIT_0C => romgen_str2bv(inst'INIT_0C),
        INIT_0D => romgen_str2bv(inst'INIT_0D),
        INIT_0E => romgen_str2bv(inst'INIT_0E),
        INIT_0F => romgen_str2bv(inst'INIT_0F),
        INIT_10 => romgen_str2bv(inst'INIT_10),
        INIT_11 => romgen_str2bv(inst'INIT_11),
        INIT_12 => romgen_str2bv(inst'INIT_12),
        INIT_13 => romgen_str2bv(inst'INIT_13),
        INIT_14 => romgen_str2bv(inst'INIT_14),
        INIT_15 => romgen_str2bv(inst'INIT_15),
        INIT_16 => romgen_str2bv(inst'INIT_16),
        INIT_17 => romgen_str2bv(inst'INIT_17),
        INIT_18 => romgen_str2bv(inst'INIT_18),
        INIT_19 => romgen_str2bv(inst'INIT_19),
        INIT_1A => romgen_str2bv(inst'INIT_1A),
        INIT_1B => romgen_str2bv(inst'INIT_1B),
        INIT_1C => romgen_str2bv(inst'INIT_1C),
        INIT_1D => romgen_str2bv(inst'INIT_1D),
        INIT_1E => romgen_str2bv(inst'INIT_1E),
        INIT_1F => romgen_str2bv(inst'INIT_1F),
        INIT_20 => romgen_str2bv(inst'INIT_20),
        INIT_21 => romgen_str2bv(inst'INIT_21),
        INIT_22 => romgen_str2bv(inst'INIT_22),
        INIT_23 => romgen_str2bv(inst'INIT_23),
        INIT_24 => romgen_str2bv(inst'INIT_24),
        INIT_25 => romgen_str2bv(inst'INIT_25),
        INIT_26 => romgen_str2bv(inst'INIT_26),
        INIT_27 => romgen_str2bv(inst'INIT_27),
        INIT_28 => romgen_str2bv(inst'INIT_28),
        INIT_29 => romgen_str2bv(inst'INIT_29),
        INIT_2A => romgen_str2bv(inst'INIT_2A),
        INIT_2B => romgen_str2bv(inst'INIT_2B),
        INIT_2C => romgen_str2bv(inst'INIT_2C),
        INIT_2D => romgen_str2bv(inst'INIT_2D),
        INIT_2E => romgen_str2bv(inst'INIT_2E),
        INIT_2F => romgen_str2bv(inst'INIT_2F),
        INIT_30 => romgen_str2bv(inst'INIT_30),
        INIT_31 => romgen_str2bv(inst'INIT_31),
        INIT_32 => romgen_str2bv(inst'INIT_32),
        INIT_33 => romgen_str2bv(inst'INIT_33),
        INIT_34 => romgen_str2bv(inst'INIT_34),
        INIT_35 => romgen_str2bv(inst'INIT_35),
        INIT_36 => romgen_str2bv(inst'INIT_36),
        INIT_37 => romgen_str2bv(inst'INIT_37),
        INIT_38 => romgen_str2bv(inst'INIT_38),
        INIT_39 => romgen_str2bv(inst'INIT_39),
        INIT_3A => romgen_str2bv(inst'INIT_3A),
        INIT_3B => romgen_str2bv(inst'INIT_3B),
        INIT_3C => romgen_str2bv(inst'INIT_3C),
        INIT_3D => romgen_str2bv(inst'INIT_3D),
        INIT_3E => romgen_str2bv(inst'INIT_3E),
        INIT_3F => romgen_str2bv(inst'INIT_3F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(7 downto 4),
        ADDR => rom_addr,
        CLK  => CLK,
        DI   => "0000",
        EN   => ENA,
        SSR  => '0',
        WE   => '0'
        );
  end generate;
end RTL;
