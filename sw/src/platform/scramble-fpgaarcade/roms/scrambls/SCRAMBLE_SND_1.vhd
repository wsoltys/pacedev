-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity SCRAMBLE_SND_1 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(10 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_SND_1 is

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

  attribute INITP_00 : string;
  attribute INITP_01 : string;
  attribute INITP_02 : string;
  attribute INITP_03 : string;
  attribute INITP_04 : string;
  attribute INITP_05 : string;
  attribute INITP_06 : string;
  attribute INITP_07 : string;

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

  component RAMB16_S9
    --pragma translate_off
    generic (
      INITP_00 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_01 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_02 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_03 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_04 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_05 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_06 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_07 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";

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
      DO    : out std_logic_vector (7 downto 0);
      DOP   : out std_logic_vector (0 downto 0);
      ADDR  : in  std_logic_vector (10 downto 0);
      CLK   : in  std_logic;
      DI    : in  std_logic_vector (7 downto 0);
      DIP   : in  std_logic_vector (0 downto 0);
      EN    : in  std_logic;
      SSR   : in  std_logic;
      WE    : in  std_logic 
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
    attribute INIT_00 of inst : label is "182801FE80103AC8B7E9EB56235E1908602100165F87E5081721C8B7C977800C";
    attribute INIT_01 of inst : label is "C9800132800032AFC9800B32800A32AF282805FE242804FE202803FE1C2802FE";
    attribute INIT_02 of inst : label is "C9800932800832AFC9800732800632AFC9800532800432AFC9800332800232AF";
    attribute INIT_03 of inst : label is "10CE10C710581051104A0DD40DCE13CE124E0D1F0B290AAD0A3109B509390000";
    attribute INIT_04 of inst : label is "00000000000000000000000000000000000000000CA30C120B73112000000000";
    attribute INIT_05 of inst : label is "00000000000000000000000000000000000000000000135B12DE121A11B10D97";
    attribute INIT_06 of inst : label is "802232043E802022801E22008021801D321F3E801C320F3E801B32033E0B2CCD";
    attribute INIT_07 of inst : label is "802B32802A32083E8028220800218027320A3E802632033E802432802332403E";
    attribute INIT_08 of inst : label is "00218034220200218033320A3E803232033E8030320C3E802E22802C22004021";
    attribute INIT_09 of inst : label is "3E0B2CCDC9FF3EC9803D22002021803B32803A32083E80382202002180362208";
    attribute INIT_0A of inst : label is "2332203E802232013E802022801E22008021801D321F3E801C320F3E801B3203";
    attribute INIT_0B of inst : label is "22004021802B32802A32083E8028220800218027320D3E802632033E80243280";
    attribute INIT_0C of inst : label is "8036220800218034220200218033320E3E803232033E803032023E802E22802C";
    attribute INIT_0D of inst : label is "801B32023E0B2CCDC9FF3EC9803D22010021803B32803A32183E803822000121";
    attribute INIT_0E of inst : label is "802432802332203E802232013E802022801E22008021801D32083E801C320F3E";
    attribute INIT_0F of inst : label is "2E22802C22004021802B32802A32083E8028220800218027320A3E802632033E";
    attribute INIT_10 of inst : label is "22000121803622080021803422020021803332083E803232033E803032033E80";
    attribute INIT_11 of inst : label is "1C320E3E801B32033E0B2CCDC9FF3EC9803D22002021803B32803A32203E8038";
    attribute INIT_12 of inst : label is "2632033E802432802332203E802232013E802022801E22008021801D321F3E80";
    attribute INIT_13 of inst : label is "32033E802E22802C22004021802B32802A32083E8028220800218027320C3E80";
    attribute INIT_14 of inst : label is "203E8038220001218036220800218034220200218033320F3E803232033E8030";
    attribute INIT_15 of inst : label is "321F3E801C320F3E801B32033E0B2CCDC9FF3EC9803D22002021803B32803A32";
    attribute INIT_16 of inst : label is "320C3E802632033E802432802332403E802232043E802022801E22008021801D";
    attribute INIT_17 of inst : label is "033E803032083E802E22802C22003021802B32802A32083E8028220800218027";
    attribute INIT_18 of inst : label is "32803A32013E803822010021803622080021803422020021803332093E803232";
    attribute INIT_19 of inst : label is "FE801B3AC9006FCD153E006FCD143E006FCD133EC9FF3EC9803D22002021803B";
    attribute INIT_1A of inst : label is "00060580CD054CCD5E801D210616802532AF07BCCD232802FE222801FE212800";
    attribute INIT_1B of inst : label is "FE80253A054CCD5E801D210616DB180782CDE0180748CDE51806C7CDC905FECD";
    attribute INIT_1C of inst : label is "AF05FECD473E283D064BCD7780233A0E20358024213C2802FE272801FE1E2800";
    attribute INIT_1D of inst : label is "34802521802022801E2A0C20B57C2B80202ADD183480252105FECD47801C3AC9";
    attribute INIT_1E of inst : label is "054CCD041E0616B218802532AFB81834802521062035802221C418802022C918";
    attribute INIT_1F of inst : label is "CD04C6CD80282A803132AF07BCCD1B2802FE1A2801FE192800FE80263AC9FF3E";
    attribute INIT_20 of inst : label is "802E2A2E2801FE1F2800FE80313AE3180782CDE8180748CDED1806C7CDC9050D";
    attribute INIT_21 of inst : label is "3A05FECD4780273AC9AF0036803121392835803021802E22802C2A4020B57C2B";
    attribute INIT_22 of inst : label is "473480312104203D064BCD77802A3ACC2035802B21EB1834803121802B32802A";
    attribute INIT_23 of inst : label is "AF07BCCD222802FE212801FE202800FE80323AC9FF3ECC18802E22B81805FECD";
    attribute INIT_24 of inst : label is "82CDE1180748CDE61806C7CDC905FECD4780333A050DCD04C6CD80362A803C32";
    attribute INIT_25 of inst : label is "0720BA7C80345BED52ED803D5BEDB70680CD322801FE222800FE803C3ADC1807";
    attribute INIT_26 of inst : label is "CE18803822D318803C32013E0720B57C2B80382AC9AF04C6CD80362A0320BB7D";
    attribute INIT_27 of inst : label is "804332AF0748CDC9FF3EB81805FECD4706283D064BCD77803B3AC82035803A21";
    attribute INIT_28 of inst : label is "3AC905FECD080604C6CD004021804022002021803F32083E050DCD804232023E";
    attribute INIT_29 of inst : label is "020011190010110680CD1A2835803F218040223728B57C2B80402A0B20B78043";
    attribute INIT_2A of inst : label is "1805FECD4706283D064BCD803F32083EC9AF04C6CD0040210320BB7D0720BA7C";
    attribute INIT_2B of inst : label is "32083E0782CDA5180D08CD804332013E052035804221804022002021C9FF3ED5";
    attribute INIT_2C of inst : label is "221728B57C2B80452AC905FECD0B06050DCD04C6CD0040218045220A00218044";
    attribute INIT_2D of inst : label is "7332003E06C7CDC9FF3EC9AF04C6CD190002110680CD08360C20358044218045";
    attribute INIT_2E of inst : label is "C8FFFE007EDD0018805821DD0618805021DDC9050DCD06C7CD0F8EC3050DCD80";
    attribute INIT_2F of inst : label is "77DD0E05FA01D6077EDD0E05C24600CBDD0177DD80723AC00135DDC9AF0DE5CD";
    attribute INIT_30 of inst : label is "DD0275DD230EB6C21FFE0E9ACA1FE6477E0366DD026EDDC00035DD05FECD4707";
    attribute INIT_31 of inst : label is "900E900E900E730E5D0E45C9D556235E090E352100064F0F0F0F0FE0E6780374";
    attribute INIT_32 of inst : label is "026EDD2318807053ED56235E090EE621000621CB4E0366DD026EDD0E900E900E";
    attribute INIT_33 of inst : label is "0777DD0677DD7E0366DD026EDD0D180177DD8072327E090F7E2100064E0366DD";
    attribute INIT_34 of inst : label is "CD00060EA4CDC9FF0036DD05FECD00060E09C30374DD0275DD230366DD026EDD";
    attribute INIT_35 of inst : label is "073D1FE678C10EA4CDC5F71807C90077DD0410013E47070707E0E678341805FE";
    attribute INIT_36 of inst : label is "DD230366DD026EDD05FECD0777DD780646DD04C6CDEB56235E0980702A00064F";
    attribute INIT_37 of inst : label is "0F360F320F2E0F2A0F260F220F1E0F1A0F160F120F0E0F0A0F06C90374DD0275";
    attribute INIT_38 of inst : label is "0436047604B90501054E059E05F3064E06AE0714078007F2086B0F420F3E0F3A";
    attribute INIT_39 of inst : label is "01AC01C501E001FD021B023B025D028102A702CF02FA03270357038A03C003F9";
    attribute INIT_3A of inst : label is "00AA00B400BE00CA00D600E300F000FE010D011D012E014001530168017D0194";
    attribute INIT_3B of inst : label is "42570047004C00500055005A005F0065006B00710078007F0087008F009700A0";
    attribute INIT_3C of inst : label is "07074F0780733AB0ED0018018050110FC12105060708090A0B0C1A1D21252C34";
    attribute INIT_3D of inst : label is "1323127E0FBECD127E8062110FB7CD805A110FB7CD805211090FD92100064F91";
    attribute INIT_3E of inst : label is "5F102D100D0FEB000000000000010100000000000001010000000000000101C9";
    attribute INIT_3F of inst : label is "8C888C8F8C888C6C6C80AC6C6C80AC095F0D3F0A1F10FF10EB10D51097107C10";
  begin
  inst : RAMB16_S9
      --pragma translate_off
      generic map (
        INITP_00 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_01 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_02 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_03 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_04 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_05 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_06 => x"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_07 => x"0000000000000000000000000000000000000000000000000000000000000000",

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
        DO   => DATA(7 downto 0),
        DOP  => open,
        ADDR => rom_addr,
        CLK  => CLK,
        DI   => "00000000",
        DIP  => "0",
        EN   => ENA,
        SSR  => '0',
        WE   => '0'
        );
  end generate;
end RTL;
