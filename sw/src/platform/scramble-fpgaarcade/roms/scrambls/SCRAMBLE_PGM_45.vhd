-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity SCRAMBLE_PGM_45 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_PGM_45 is

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
    attribute INIT_00 of inst : label is "986001201D0EF0E40D40C40D40C40D40C406F0E40D40C40D40C40D40C4F7F5D0";
    attribute INIT_01 of inst : label is "7F6D47D86F616A94D85D1BA18171A0706050B0A0209F2ED0F16D0ED9709D909D";
    attribute INIT_02 of inst : label is "4ED44D0715AB3D24D0E6DD4DC5D19138151881F1D81B1A8D88D5877ED37D8677";
    attribute INIT_03 of inst : label is "85FEA6D18FE1613898D58D7ED99917D07DF73790F17370E96D8ED99326D08E46";
    attribute INIT_04 of inst : label is "E464ED44D0715A08F5DB3D24DF7D0E6DD4DC5DFE17158151A8111F81B1A87855";
    attribute INIT_05 of inst : label is "20A209208217F0B20A20920821BF6F06606F015F0321FF00219F0C2999326D08";
    attribute INIT_06 of inst : label is "292827131AF2ED0F16D0ED9709D91AD926001301D11F0321BF02215F01216F0B";
    attribute INIT_07 of inst : label is "F80E3EDC7DB3D24D44D35D2E10E6DD4DC5D27147D8634A37D4633A26252F2B2A";
    attribute INIT_08 of inst : label is "41642641699944D0715A917DF50F5DB3D24D3F6D0E6DD4DC5D2F19999917D07D";
    attribute INIT_09 of inst : label is "F0F0F0F0F0F0F0F0F0F0F0F0F0F0F001002FF9B69A699698627FE56846836426";
    attribute INIT_0A of inst : label is "A24001010101F10101F101F101F1F10101F1F1F1F0F1F1F0F1F0F0F1F0F0F0F1";
    attribute INIT_0B of inst : label is "5D3C13B3B353130303030342BF2ED0F16D0ED9709D92BD946001401D08E3871D";
    attribute INIT_0C of inst : label is "0808E3ED917D07DF880E4ED44D30715A67D17AC7DB3D24D44D35D3410E6DD4DC";
    attribute INIT_0D of inst : label is "B65A65965863CF0E00D09944D0715A917DF50F5DB3D24DFF6D0E6DD4DC5D3519";
    attribute INIT_0E of inst : label is "4B453130303F3F3B32F2ED0F16D0ED9709D932D946001401D02E1DA3400F35F5";
    attribute INIT_0F of inst : label is "6D0E6DD4DC5D42199917D07DF80E4EDC7DB3D24D44D35D4110E6DD4DC5D4C14B";
    attribute INIT_10 of inst : label is "E0E0E0E0E0E0E0F42FBB4BA4B94B844CF0A59944D0715A917DF50F5DB3D24DBF";
    attribute INIT_11 of inst : label is "2020222020202020222022202220222222222222220202E2E2E2E0E2E0E2E0E0";
    attribute INIT_12 of inst : label is "E0E0E0E2E0E2E0E2E0E2E0E2E2E2E2E202020222222020222022202020202220";
    attribute INIT_13 of inst : label is "B4B453130303F3F3B51F2ED0F16D0ED9709D941D946001401D01E1DA4100E0E0";
    attribute INIT_14 of inst : label is "5CD5BD56D520405DF5605705005705605503B324D44D35D5210E6DD4DC5D5D14";
    attribute INIT_15 of inst : label is "72EDC16006F16D0ED9909D5FD86001201D2019A0C7C117AF4D16A960A155356D";
    attribute INIT_16 of inst : label is "7D13ED27D6ED70F16D0ED481001D401D88001D401D28001D301D9C79EDC78EDC";
    attribute INIT_17 of inst : label is "0BD9309DD9D0415DD76501D001DA8836D806D9109D4E9D00117D2ED07D1F4ED3";
    attribute INIT_18 of inst : label is "0D64D60D937DD63ED9036D016D937DF3ED18F0DA60F0FA37D561ED17DF2ED386";
    attribute INIT_19 of inst : label is "60BD9909D6CD46001401D02E1DA0F30A97CD78D9CD82D8BD97DA5D97D75D66D6";
    attribute INIT_1A of inst : label is "152FE076D16C0630106D16D66DD626D61BD60BD09ED646D46EC0DE6636DE3318";
    attribute INIT_1B of inst : label is "871DA0F30A9909D6CD86001201D0F30A9909D6CD46001401D01E1DA0F30A90ED";
    attribute INIT_1C of inst : label is "0AEC08BE766F3633A3616F06FF8604634A716A0F30A9909D6CD46001401D08E3";
    attribute INIT_1D of inst : label is "3D3D3D73D00146501D02E1DA90ED152FE16C0630166C16C063019D00E92038CB";
    attribute INIT_1E of inst : label is "626D116D006D09E4646D2ED07E3636D1ED860BD960D9D979D94E401D860BD950";
    attribute INIT_1F of inst : label is "D1ED860BD960D9D977D98E201D860BD9503D3D3D71D00146501D906DF381006D";
    attribute INIT_20 of inst : label is "2006E151906DF311E8D8DD8D8877ED006D626D116D006D09E4646D2ED0FE7636";
    attribute INIT_21 of inst : label is "D1901DF3712A6D901DF3611A6D901DF3510A6D88E8D58D88736FD909DF3317FE";
    attribute INIT_22 of inst : label is "D960D9D98FD94E401D860BD9503D3D3D89D00146501D08E3871DA9122FE01DF3";
    attribute INIT_23 of inst : label is "995D946031501D906DF3A1006D626D116D006D07E3646D2ED0BE5636D1ED860B";
    attribute INIT_24 of inst : label is "9D93D00126301D02E1DA9006D81EDEC681EDE16F06FF8602ED716A860BD9709D";
    attribute INIT_25 of inst : label is "626D116D006D0DE6646D4ED0BE5636D3ED860BD960D9D999D94E401D860BD990";
    attribute INIT_26 of inst : label is "BD960D9D99ED98E201D860BD9909D98D00126301D906D09DF381626D116D006D";
    attribute INIT_27 of inst : label is "08E3871DA82309D626D116D006D626D116D006D0EE7646D4ED0EE7636D3ED860";
    attribute INIT_28 of inst : label is "E4646D4ED0DE6636D3ED860BD960D9D9A7D94E401D860BD9909DA1D00126301D";
    attribute INIT_29 of inst : label is "16A860BD9709D9A8D900126301D906D09DF3A1626D116D006D626D116D006D09";
    attribute INIT_2A of inst : label is "FABAC762FA90F30A98F06A909D626D116D006D83EDEC683EDE16F06FF8604ED7";
    attribute INIT_2B of inst : label is "1AC80FB03A8FB00AE8F0DA0F30A9FEDFADFCDC7DB6DBADBDDA5DC3DAF3C8CF62";
    attribute INIT_2C of inst : label is "001401D0F62FA02E1DA930CCC90ED77634AC72633AC6B406B465010FB04A8FB0";
    attribute INIT_2D of inst : label is "1D816FD0F62FA08E3871DA947D96F6FD836D026D016D106D9309D50F16D0ED46";
    attribute INIT_2E of inst : label is "37D3ED326D9309D50F16D0ED46401DB00E46D34A5077ED9609D5060BD8600120";
    attribute INIT_2F of inst : label is "16D106D9309D50F16D0ED46001401D0F62FA01E1DA918D026D016D106D47D4ED";
    attribute INIT_30 of inst : label is "260F130107B04A87B01AC80FB03A8FB00AE8F0DA0F30A9846D37D06F6FD026D0";
    attribute INIT_31 of inst : label is "026D016D106D9309D50F16D0ED86001201D8261AA913D06C06C16D970940F6CE";
    attribute INIT_32 of inst : label is "00060EB00C3EB00D3FB000833002B5000330B10606000EBC300EB6891A2F176D";
    attribute INIT_33 of inst : label is "008F8003B03003B0320686800F34800230B00CBE300200B10606020606010606";
    attribute INIT_34 of inst : label is "BC300DBF3004830000803003B6020606040606000EB6810686800F3CB00D3E80";
    attribute INIT_35 of inst : label is "00058281060601060602060600048604060604060600060CB00582820606000F";
    attribute INIT_36 of inst : label is "0EBD300CB1B00332B00130B1060602060601060604060604060600060FB00D00";
    attribute INIT_37 of inst : label is "3FB000833002B5000330B40606000EBC300EB68003B30003B6020606000E8C00";
    attribute INIT_38 of inst : label is "320686800F34800230B00CBE300200B1060601060602060600060EB00C3EB00D";
    attribute INIT_39 of inst : label is "00803003B6020606040606000EB6800686800F3CB00D3E80008F8003B03003B0";
    attribute INIT_3A of inst : label is "0601060600060EB00C3EB00D3FB000833002B5000330B10606000EBC300EB680";
    attribute INIT_3B of inst : label is "B00D3E80008F8003B03003B0320686800F34800230B00CBE300200B206060106";
    attribute INIT_3C of inst : label is "F16D0ED86001201D8161AAF000803003B6040606020606000EB6800686800F3C";
    attribute INIT_3D of inst : label is "16D106D9309D50F16D0ED86001201D8461AA91A2F076D026D016D106D9309D50";
    attribute INIT_3E of inst : label is "91A2F376D026D016D106D9309D50F16D0ED86001201D8861AA91A2F276D026D0";
    attribute INIT_3F of inst : label is "7211D2E3192E3182E915106F077E4185EE1E10D060014114010FEE18A902DF7D";
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
    attribute INIT_00 of inst : label is "D00021482D21F1B01B01B01B01B01B01B020F1301301301301301301301FF020";
    attribute INIT_01 of inst : label is "01E707DFC0E41317D17D4122424222E2E2E2C2C2B26E07DD00BD07DCF11DD24C";
    attribute INIT_02 of inst : label is "07D03DCA41316C03D003D07D07D24201252012420125202302312A17D07D0C00";
    attribute INIT_03 of inst : label is "204314D21332722102302317DCCC07D07DA72710117271316D16DCC003DD0F1C";
    attribute INIT_04 of inst : label is "F1C07D03DCA4131203D16C03D07D003D07D07D33262012820129201282010200";
    attribute INIT_05 of inst : label is "013013013026F13013013013025F01002002025F13024F11024F110CCC003DD0";
    attribute INIT_06 of inst : label is "2020202F2CE07DD00BD07DCF11DD2ACD000214C2D29F51028F51028F51027F13";
    attribute INIT_07 of inst : label is "ADFF07D1FC16C03D17D17D252003D07D07D23207D0C48307D0C4832323212020";
    attribute INIT_08 of inst : label is "020020020CCC03DCA413C07DA0203D16C03D203D003D07D07D242CCCCC07D07D";
    attribute INIT_09 of inst : label is "F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0000024F03003003003023FF20020020020";
    attribute INIT_0A of inst : label is "32B800000000F00000F000F000F0F00000F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0";
    attribute INIT_0B of inst : label is "7D2622626252424242424212FE07DD00BD07DCF11DD2DCD00021402DC0F02A41";
    attribute INIT_0C of inst : label is "F1D2F07DC07D07DA03FF07D03D02A41317D4131FC16C03D17D17D282003D07D0";
    attribute INIT_0D of inst : label is "3003003003026F110110CC03DCA413C07DA0203D16C03D303D003D07D07D272C";
    attribute INIT_0E of inst : label is "21202F2F2F2E2E2D2CE07DD00BD07DCF11DD2ACD00021402DC0F4132880F27F0";
    attribute INIT_0F of inst : label is "3D003D07D07D222CCC07D07DADFF07D1FC16C03D17D17D232003D07D07D21221";
    attribute INIT_10 of inst : label is "F0F0F0F0F0F0F0F22F03003003003021F110CC03DCA413C07DA0203D16C03D20";
    attribute INIT_11 of inst : label is "0000000000000000000000000000000000000000000000F0F0F0F0F0F0F0F0F0";
    attribute INIT_12 of inst : label is "F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F000000000000000000000000000000000";
    attribute INIT_13 of inst : label is "121202F2F2F2E2E2D20E07DD00BD07DCF11DD2ECD00021402DC0F4132380F0F0";
    attribute INIT_14 of inst : label is "28C25C24C2380021F0300300300300300302DC03D17D17D232003D07D07D2122";
    attribute INIT_15 of inst : label is "717D203D0300BD07DCF11D26C00021482D462CF1272741344E413104222EC29C";
    attribute INIT_16 of inst : label is "7F907D07F17D2300BD07D000472F482D01472F402D11462F482DC2717D2717D2";
    attribute INIT_17 of inst : label is "0CFCF11F11D0012FC00402F482DE1F03FF03FCD11F011D02107F17D07F9207D0";
    attribute INIT_18 of inst : label is "EC2CC26CC07D0D07DC003D003DC07D207D13040303040307D0C07F07D207F224";
    attribute INIT_19 of inst : label is "40CDCF11D27C00021402DC0F413D0483C2CC26C22C2FC28C2FC26C29C21C2FC2";
    attribute INIT_1A of inst : label is "413F3013D032034A20320320322003DC0CD80CDD1F0C09D0C72D0F0C09D7482C";
    attribute INIT_1B of inst : label is "2A413D0483CF11D27C00021482DD0483CF11D27C00021402DC0F413D0483C3EC";
    attribute INIT_1C of inst : label is "3B7213B750D50C48300426CC00FE90D4834413D0483CF11D27C00021402DC0F0";
    attribute INIT_1D of inst : label is "2F2F2F28C02100402FC0F413C3EC413F3032034A203203203482CE1C2CF10220";
    attribute INIT_1E of inst : label is "003D003D003DD0F0C09D07FD0F0C09D07FC40CDCF201DD29CD00402DC40CFCF1";
    attribute INIT_1F of inst : label is "D07FC40CDCF201DD2FCD00482DC40CFCF12F2F2F2EC02100402FC3ECF001003F";
    attribute INIT_20 of inst : label is "033C7402C3FCF0014112302302A17D003F003D003D003DD0F0C09D07FD0F0C09";
    attribute INIT_21 of inst : label is "01C3DCF001013DC3DCF001013DC3DCF001013D1102302302A0E5EC3CCF0017F3";
    attribute INIT_22 of inst : label is "DCF201DD2BCD00402DC40CFCF12F2F2F2AC02100402FC0F02A413C413F33DCF0";
    attribute INIT_23 of inst : label is "D20CD00001402DC3FCF001003F003D003D003DD0F0C09D07FD0F0C09D07FC40C";
    attribute INIT_24 of inst : label is "1F24C021004C2FC0F413C003DD0BD72030BD7426CC00FE907D4413C40CDCF11D";
    attribute INIT_25 of inst : label is "003D003D003DD0F0C09D07FD0F0C09D07FC40CDCF201DD25CD00402DC40CFCF1";
    attribute INIT_26 of inst : label is "CDCF201DD2BCD00482DC40CFCF11F2AC021004C2FC3EC3DCF001003F003F003F";
    attribute INIT_27 of inst : label is "C0F02A41322C3DC003F003F003F003D003D003DD0F0C09D07FD0F0C09D07FC40";
    attribute INIT_28 of inst : label is "F0C09D07FD0F0C09D07FC40CDCF201DD22CD00402DC40CFCF11F21C021004C2F";
    attribute INIT_29 of inst : label is "413C40CDCF11DD27CD021004C2DC3FC3DCF001003F003F003F003D003D003DD0";
    attribute INIT_2A of inst : label is "5320C6E453130483130403C3DC003D003D003DD0BD72030BD7426CC00FE907D4";
    attribute INIT_2B of inst : label is "1301C5C413C5C413030403D0483C28C22C25C25C2DC26C22C2EC21C2CC23C3E4";
    attribute INIT_2C of inst : label is "021402DC3E453C0F413CE1222C3FC70D483270C4832CC124C00402C5C413C5C4";
    attribute INIT_2D of inst : label is "2DC0E5EC1E453C0F02A413C07D0C0E5E803D003D003D003DCF11D0300BD07D00";
    attribute INIT_2E of inst : label is "07F07D003DCF11F0300BF07F00402FE37F09D4A3F2A17DCF11D0240CD0002148";
    attribute INIT_2F of inst : label is "03D003DCF11D0300BD07D00021402DC0E453C0F413C30C003F003F003F07F07D";
    attribute INIT_30 of inst : label is "000114C2C5C413C5C41301C4C413C4C413030403D0483C003D07D3C7E5E003D0";
    attribute INIT_31 of inst : label is "003D003D003DCF11D0300BD07D00021482DC0E413C30C032032032CF11030B27";
    attribute INIT_32 of inst : label is "E003E2D002D2C002C2B003B3C003C3D003D3D003E3E002D2D002C3CC413A013D";
    attribute INIT_33 of inst : label is "03B2B003B3C003C3D003D3D002D3C003D3D002D2D003D3D003E3E003E3E003E3";
    attribute INIT_34 of inst : label is "D2D002C2C003B3C003C3D003D3E003E3E003E3E002D3D003D3D002D2C002C2B0";
    attribute INIT_35 of inst : label is "D003D3D003E3E003E3E003E3E003D3E003E3E003E3E003E2D003D3D003E3E002";
    attribute INIT_36 of inst : label is "02C2C002B3B003C3C003D3D003E3E003E3E003E3E003E3E003E3E003E2D002D3";
    attribute INIT_37 of inst : label is "C2B003B3C003C3D003D3D003E3E002D2D002C3C003C3D003D3E003E3E002D2D0";
    attribute INIT_38 of inst : label is "D003D3D002D3C003D3D002D2D003D3D003E3E003E3E003E3E003E2D002D2C002";
    attribute INIT_39 of inst : label is "03C3D003D3E003E3E003E3E002D3D003D3D002D2C002C2B003B2B003B3C003C3";
    attribute INIT_3A of inst : label is "E3E003E3E003E2D002D2C002C2B003B3C003C3D003D3D003E3E002D2D002C3C0";
    attribute INIT_3B of inst : label is "C002C2B003B2B003B3C003C3D003D3D002D3C003D3D002D2D003D3D003E3E003";
    attribute INIT_3C of inst : label is "00BD07D00021482DC0E413F003C3D003D3E003E3E003E3E002D3D003D3D002D2";
    attribute INIT_3D of inst : label is "03D003DCF11D0300BD07D00021482DC0E413C413A013D003D003D003DCF11D03";
    attribute INIT_3E of inst : label is "C413A013D003D003D003DCF11D0300BD07D00021482DC0E413C413A013D003D0";
    attribute INIT_3F of inst : label is "0014137241372413713B201588473020F7412BE03080401402CFF7412C30C2CC";
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
