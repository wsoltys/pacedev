-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity SCRAMBLE_PGM_01 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_PGM_01 is

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
    attribute INIT_00 of inst : label is "BF00A065FFFFF9B63E906F179E7C0EF5990DC037FFF9C037F99C73C7F013812F";
    attribute INIT_01 of inst : label is "FB0EACF189100E254300EACD33FFFFFFFFFFFFFFFFFFF910020E200EDC3C2E8E";
    attribute INIT_02 of inst : label is "103E9F303A5F91C00103E9F302A5F20D5439305C2D1233025F0B4F1891009D1E";
    attribute INIT_03 of inst : label is "122228E40422278C0C180100178712A06D8012328E132BE9A01222421FF91C00";
    attribute INIT_04 of inst : label is "0820E0B2801842C002001222872862052812F00A2023317C62317FE060018012";
    attribute INIT_05 of inst : label is "E90906D9460DDD0DF0ED072FE5807236783E3611A0F216FF8002367F12A0720E";
    attribute INIT_06 of inst : label is "320610100170712A06D8010FEE01060E70A697B03ED3607F9EB21736FF672678";
    attribute INIT_07 of inst : label is "0A273160A150C16C06C06A62018121ED023D2023D6018B300A2801801F69018B";
    attribute INIT_08 of inst : label is "2A1B0120E200EDCF6E3F606FF6182AD507EF01A06970712A30180711A00ABB80";
    attribute INIT_09 of inst : label is "A801F01B73BCADB7ADCCA3686B09129AF672FA6E493236302221209B527163E9";
    attribute INIT_0A of inst : label is "9797970E906956916B828D8012830F06A80B80138B0170DA2FDB0121D262870E";
    attribute INIT_0B of inst : label is "97F6FFFF997F6F0ED3D97F6FFFF997F6F0ED201DA600197160C1149D55B6AE99";
    attribute INIT_0C of inst : label is "3327EA36793C106F173DDF88790F06AF9D03D0019F21718F6FFFF997F6F0ED3D";
    attribute INIT_0D of inst : label is "DA5D83670B13DD3232EA0337A360813DD970BB508EA360A1B132D1E20F0DA580";
    attribute INIT_0E of inst : label is "05198702150800000200000200100300200100000100100000009105130F0210";
    attribute INIT_0F of inst : label is "44DE44DFFFFE4E36F01A11D0A178D911D071187B11D04132310630630608138D";
    attribute INIT_10 of inst : label is "8937068FEA4BAE81F01B363EB63E906FF64615718D0E687999D07D0E88F6910B";
    attribute INIT_11 of inst : label is "101AB09063001F58801F863FF36ABBBB01206F0677F6BB033D0526893068FEA5";
    attribute INIT_12 of inst : label is "63606C57555B5A5905040B0A0A09095758515559575057585B4E414D4090021E";
    attribute INIT_13 of inst : label is "A4F5EF02591C0A4FEF445204214308350A1F256F005D17A66B6865626F6C6966";
    attribute INIT_14 of inst : label is "F5416E905F90E13021607F8B1F000004945230BFF52F3308798A0FF7402591C0";
    attribute INIT_15 of inst : label is "B35C04FF7B0F359454025F904545C0DF305F9BEF3EF941C54127EF3ACFC556BE";
    attribute INIT_16 of inst : label is "9F301A5FB05C214052F330BA7FB05C2D12330BA9F91C0A6FE917105D940485E0";
    attribute INIT_17 of inst : label is "02F05EFA4F9CEF02591C005EFA4F340000098F2F60045A035EF2B8F91C00200E";
    attribute INIT_18 of inst : label is "000000004E2A9F3400000000000431A7FB07E9BE12052F330BB4F32591C00F74";
    attribute INIT_19 of inst : label is "1F3400000000000845AFF3400000000000844ADF3400000000000423ABF34000";
    attribute INIT_1A of inst : label is "000849A7F3400000000000848A5F3400000000000847A3F3400000000000846A";
    attribute INIT_1B of inst : label is "0001010001010001010C73CAADAEADCCA7F3400000000008401A9F3400000000";
    attribute INIT_1C of inst : label is "0181810181800181810181800181810101010181800101010101010101000101";
    attribute INIT_1D of inst : label is "0104010104010101018181018182018181018181018181018182018181018181";
    attribute INIT_1E of inst : label is "0101010001010101010001010101010001010101010001010101010001010101";
    attribute INIT_1F of inst : label is "0181810101000101010181800181810101000101000101010181800181800101";
    attribute INIT_20 of inst : label is "8181010101010104010102010104010100010100010101010100010101018180";
    attribute INIT_21 of inst : label is "8101010001818001818101010001818001818101010101010401818201010101";
    attribute INIT_22 of inst : label is "0101000101010101000101020101010101000181810101000181810181810181";
    attribute INIT_23 of inst : label is "0102010100010102010100010102010100010101010100010101010100010101";
    attribute INIT_24 of inst : label is "8101818101818101818001818101818001818101010101818001010101010101";
    attribute INIT_25 of inst : label is "0101010101040101040101010181810181820181810181810181810181820181";
    attribute INIT_26 of inst : label is "8180010101010100010101010100010101010100010101010100010101010100";
    attribute INIT_27 of inst : label is "0101818001818101010001010101818001818101010001010001010101818001";
    attribute INIT_28 of inst : label is "0101010181810101010101040101020101040101000101000101010101000101";
    attribute INIT_29 of inst : label is "8181018181010100018180018181010100018180018181010101010104018182";
    attribute INIT_2A of inst : label is "0001010101010001010101010001010201010101010001818101010001818101";
    attribute INIT_2B of inst : label is "F2F68AF2FFFF78067B2D3E283E02A49D5EF00101000101000101000101010101";
    attribute INIT_2C of inst : label is "01D79690717960E9051F06D25A0F20A0F10A971B0766F7FFFFB8068F706F679A";
    attribute INIT_2D of inst : label is "8C61DA9E7080DE7F6D766D5ED4EDC013DE28C61DA9E7080DE7F6D736D2ED1ED2";
    attribute INIT_2E of inst : label is "56F6D7E6DDEDCEDC01B0E28C61DA9E70856F6D7B6DAED9ED868BD006DC0130E2";
    attribute INIT_2F of inst : label is "1C73C736D2ED771ED860BD9709D9BAD9201D860419086DC01BDE28C61DA9E708";
    attribute INIT_30 of inst : label is "B0C6985479E906FC1197697B09B65854F01AE10FE7FFF86FF15A9006D73C790F";
    attribute INIT_31 of inst : label is "77B09D6585408E7B3112AB09065877B09C6585408E7F01B4111ACCDA987654C9";
    attribute INIT_32 of inst : label is "09E60018F100E7CF610A9809B69A676E287E8718ABF1B0906C6F01BF19B09068";
    attribute INIT_33 of inst : label is "6916B417C1EA7093D70ED86D31DF01B41709D307DE86DB1F01B31D9A0D90687B";
    attribute INIT_34 of inst : label is "E0FFE0FFE0FFE0FFE0FFE0FFE0FFE6154DA9BDA98D576D543D21092093692692";
    attribute INIT_35 of inst : label is "1AB7F12A02103200A05203A06205A00A0D001001001812F5D5D55559855550FF";
    attribute INIT_36 of inst : label is "387E081918121E1118911111D1D262E17FDECF05A5D5100DD9D52F17F10AB7F1";
    attribute INIT_37 of inst : label is "CA66E031F71148F06A36283EE021E4D0826E580671846C6FCC6CCCE0018221E5";
    attribute INIT_38 of inst : label is "210F6387B22A9002F05B0529F01705A06032318FEE03ABB076E01A0F00A7D633";
    attribute INIT_39 of inst : label is "60BA94C0684EE383EE881EED82EEF8C8DA8D8874D00A948D48D48700A4E84680";
    attribute INIT_3A of inst : label is "0509703C7AC06B060019542FF2EF501F641EDDED10A2F16D06DD050810B270E0";
    attribute INIT_3B of inst : label is "2506666644444000222000444433611005061000000000000000000000006177";
    attribute INIT_3C of inst : label is "4506660000000000000000000002666665066606644444444446666666662222";
    attribute INIT_3D of inst : label is "1916111111122117766554433221111115066666777777776666662222224444";
    attribute INIT_3E of inst : label is "11060910B28210D060F1011001092F832D8421E1C1015140B0E0907F7F9F51A5";
    attribute INIT_3F of inst : label is "1F6F1F621F661F71106D4511872862FEDDED1050910B2902170EE60BA9062F45";
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
    attribute INIT_00 of inst : label is "C64A342EFFFFFEE5251015E8C7680368CF20F127FFFCF127FC137237F0DC603A";
    attribute INIT_01 of inst : label is "44464B3333344454554464B04CFFFFFFFFFFFFFFFFFFFCE4A3C303CF72727027";
    attribute INIT_02 of inst : label is "3454444434D3544543454444434D304445555444444545455444533333444444";
    attribute INIT_03 of inst : label is "0344303F1280317F227000402F318030CC4038038380393CF18803000A354454";
    attribute INIT_04 of inst : label is "4032340240260334A2CC2803603603703603A703442442D10442DF3404C24038";
    attribute INIT_05 of inst : label is "3F1D0CCD0039CF23A38C403F3014030C020F0E8034030E0074030E4080341313";
    attribute INIT_06 of inst : label is "2701000502F318030CC403C6F788201078F057F104D007540100076C60E63C02";
    attribute INIT_07 of inst : label is "0301C034A2F120320320300402603031300C2300CF2B702703700040231F2B70";
    attribute INIT_08 of inst : label is "04274A3C303CF72F352F30040EF105C038764A342C3D0803F2B7D08037030F17";
    attribute INIT_09 of inst : label is "34E2FE10DC01C30DC300C0EC4C41207C0E44530D010D0B020C0C0CEEE0125250";
    attribute INIT_0A of inst : label is "C7171713C23123103D10BC4E20BCD0403C6C4E202442A4030AC4420BC0322A40";
    attribute INIT_0B of inst : label is "170E00007170E407D2D170E00007170E407D402D00021482F13FC01CCF0013CC";
    attribute INIT_0C of inst : label is "21128100A00820048807C442A7D04034CB12D0211F617020E00007170E407D2D";
    attribute INIT_0D of inst : label is "03FB100A4A207C0DC03F12171004A207CCF12102DB1004A21D0DC03030403DF1";
    attribute INIT_0E of inst : label is "4A202A4A2F000001000008000000000000000008005000005000CF4A10304A14";
    attribute INIT_0F of inst : label is "00C700C000070000FE1442D4A2023422D4A212A482D4A20DCF032032034A2023";
    attribute INIT_10 of inst : label is "10173DC3F104F03FFE0E2525E52510157E082F8F1013F2A7C1D07D00020ECF12";
    attribute INIT_11 of inst : label is "74B2F111340216874024FEB000E73C3C4B24262C841E7E4B5E4B2F10113C3F1F";
    attribute INIT_12 of inst : label is "0302000F0E0D0C0B0B0A08070706060A0909070504040201000F0F0D0DC4B303";
    attribute INIT_13 of inst : label is "4934444545445493445554455455445554F35454444444490C0B0A0907060504";
    attribute INIT_14 of inst : label is "3444544454544444544454445344444544454449345445444444834554545445";
    attribute INIT_15 of inst : label is "44544444447354455445545444544544445454635444544554544444C3445445";
    attribute INIT_16 of inst : label is "444434D35444445445445454C35444444545454A354454234444444445455444";
    attribute INIT_17 of inst : label is "45444444F35444454544544444D3555433345354444544455444473544543444";
    attribute INIT_18 of inst : label is "444444444434E355544444444445534E35444444454454454540355454454455";
    attribute INIT_19 of inst : label is "F355544444444444534E355544444444444534E355544444444444534E355544";
    attribute INIT_1A of inst : label is "4444534F355544444444444534F355544444444444534F355544444444444534";
    attribute INIT_1B of inst : label is "600D6D600D6D600D6D608C0CC30DC30ACA355544444444445334F35554444444";
    attribute INIT_1C of inst : label is "0D5D500D5D500D4D400D5D500D4D400D6D600D7D700D6D600D6D600D7D700D6D";
    attribute INIT_1D of inst : label is "9D900D9D900D9D900D9D900D9D900D8D800D8D800D7D700D7D700D6D600D6D60";
    attribute INIT_1E of inst : label is "500D6D600D5D500D7D700D6D600D8D800D7D700D9D900D8D800DADA00D9D900D";
    attribute INIT_1F of inst : label is "0D6D600D7D700D6D600D6D600D5D500D6D600D5D500D5D500D5D500D4D400D5D";
    attribute INIT_20 of inst : label is "7D700D8D800D8D800D8D800D8D800D8D800D8D800D8D800D8D800D7D700D7D70";
    attribute INIT_21 of inst : label is "400D5D500D4D400D4D400D6D600D5D500D5D500D6D600D6D600D6D600D7D700D";
    attribute INIT_22 of inst : label is "0D6D600D4D400D6D600D4D400D5D500D6D600D4D400D5D500D4D400D5D500D4D";
    attribute INIT_23 of inst : label is "7D700D6D600D6D600D6D600D6D600D6D600D6D600D5D500D4D400D5D500D4D40";
    attribute INIT_24 of inst : label is "600D6D600D5D500D5D500D4D400D5D500D4D400D6D600D7D700D6D600D6D600D";
    attribute INIT_25 of inst : label is "0D9D900D9D900D9D900D9D900D9D900D9D900D8D800D8D800D7D700D7D700D6D";
    attribute INIT_26 of inst : label is "4D400D5D500D6D600D5D500D7D700D6D600D8D800D7D700D9D900D8D800DADA0";
    attribute INIT_27 of inst : label is "700D7D700D6D600D7D700D6D600D6D600D5D500D6D600D5D500D5D500D5D500D";
    attribute INIT_28 of inst : label is "0D7D700D7D700D8D800D8D800D8D800D8D800D8D800D8D800D8D800D8D800D7D";
    attribute INIT_29 of inst : label is "5D500D4D400D5D500D4D400D4D400D6D600D5D500D5D500D6D600D6D600D6D60";
    attribute INIT_2A of inst : label is "500D4D400D6D600D4D400D6D600D4D400D5D500D6D600D4D400D5D500D4D400D";
    attribute INIT_2B of inst : label is "730E7493000002FE400C63036F40301C03F00D6D600D6D600D6D600D6D600D5D";
    attribute INIT_2C of inst : label is "32DD101001D101310016EE7432D0433D0413C28F121CA4000002FE7420C0E4C4";
    attribute INIT_2D of inst : label is "21E4133041291341E7706D06D07DF17230021E4133041291341E7706D06D07D4";
    attribute INIT_2E of inst : label is "0D1E7706D06D07DF172D0021E413304120D1E7706D06D07DC40CD003DF172D00";
    attribute INIT_2F of inst : label is "13723706D06D8807DC40CDCF11DD0ECD462D00001C003DF17230021E41330412";
    attribute INIT_30 of inst : label is "F1331C007D71015042D0E74F11C30200FE14B290340007E40403C003D7237101";
    attribute INIT_31 of inst : label is "A4F110302009134462403F111302A4F110302009134FE146240300CCCCCCCC3C";
    attribute INIT_32 of inst : label is "1103021452913430E403CF1103103403030FCA4034B2F111300FE14B2CF1113C";
    attribute INIT_33 of inst : label is "318346243413F112D707D10022DFE1462F11D207D710002FE1462DCF23113CAF";
    attribute INIT_34 of inst : label is "68666866686668666866686668666656665556555655565556555CF118318318";
    attribute INIT_35 of inst : label is "03272803412412412413413413413703BE080501422603AEFEDEDCFD0EDCF866";
    attribute INIT_36 of inst : label is "02A7412CF60303CDE0DFCDEEDEF1F1D1B0707E403E0A235C0BC3452728032728";
    attribute INIT_37 of inst : label is "11015402F00103040363036F740203C4130302CE422CE2A222B2227412603033";
    attribute INIT_38 of inst : label is "02C0E026C803C4B3AC3E4B20FE074B23D4B22123F74B2E120E74B2D04B373827";
    attribute INIT_39 of inst : label is "0402C3203D0F7010F7010F7010F70102302302A32403C3C33C33CA4033028E74";
    attribute INIT_3A of inst : label is "000CF11271203E20421C413AF01F001F0010AC0B2403A0320322C3402402D132";
    attribute INIT_3B of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_3C of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_3D of inst : label is "1A20000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_3E of inst : label is "4223402402402BE03070421422413A603360303181412101D1312100C09E443E";
    attribute INIT_3F of inst : label is "1F001F011F001F0010323442603603A0AC0F2C34024021001D1310402C403A34";
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
