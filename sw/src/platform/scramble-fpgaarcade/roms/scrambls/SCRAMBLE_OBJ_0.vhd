-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity SCRAMBLE_OBJ_0 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(10 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_OBJ_0 is

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
    attribute INIT_00 of inst : label is "00048692B2F2DE8C0046CE9E9ABAF26200000242FEFE020200387C8682C27C38";
    attribute INIT_01 of inst : label is "00C0C08E9EB0E0C0003C7ED292929E0C00E4E6A2A2A2BE1C00183868C8FEFE08";
    attribute INIT_02 of inst : label is "2A3E2A3E081C1C0800003636141C081C0060F2929296FC78006CF2B29A9A6E0C";
    attribute INIT_03 of inst : label is "00FEFE9090909080007770A8F8A87070001828382C3828180000001818000000";
    attribute INIT_04 of inst : label is "00387CC68282C64400FEFE929292FE6C003E7EC888C87E3E0000000000000000";
    attribute INIT_05 of inst : label is "00387CC682929E9E00FEFE90909090800000FEFE9292928200FEFE8282C67C38";
    attribute INIT_06 of inst : label is "00FEFE183C6EC682000406020202FEFC00008282FEFE828200FEFE101010FEFE";
    attribute INIT_07 of inst : label is "007CFE828282FE7C00FEFE70381CFEFE00FEFE703870FEFE0000FEFE02020202";
    attribute INIT_08 of inst : label is "0064F69292D25E0C00FEFE888C9EF672007CFE828A8EFC7A00FEFE888888F870";
    attribute INIT_09 of inst : label is "00F8FE1C381CFEF800F0F81C0E1CF8F000FCFE020202FEFC00008080FEFE8080";
    attribute INIT_0A of inst : label is "001010101010101000868E9EBAF2E2C20000C0F01E1EF0C000C6EE7C387CEEC6";
    attribute INIT_0B of inst : label is "E0301C0602060F018080C04060301C07C0701C070101010180C0603C06020301";
    attribute INIT_0C of inst : label is "010F0602061C30E0071C306040C0808001010101071C70C0010302063C60C080";
    attribute INIT_0D of inst : label is "010301010306060380C040C040C0808080F01C07010F18F0030E38E080FC0603";
    attribute INIT_0E of inst : label is "3C3C3C3CFF7E3C1801010101010101010000000000000000E060C0C0603010F0";
    attribute INIT_0F of inst : label is "FF818181818181FF3C4299A5A581423C00000000000000000000000000000000";
    attribute INIT_10 of inst : label is "0001030F3D74545400003E28203E023E5454743D0F0301003E2A223E02020000";
    attribute INIT_11 of inst : label is "0020E02000C0202000040F000007080820C000C0202020C00807000708080807";
    attribute INIT_12 of inst : label is "002060A0202000C000040808090600072020C000C02020C00808070007080807";
    attribute INIT_13 of inst : label is "0040202020C000C000040809090700072020C000C02020C00808070007080807";
    attribute INIT_14 of inst : label is "FF8080808080808080808080808080808080808080808080FF80808080808080";
    attribute INIT_15 of inst : label is "8080808080808080FF8080808080808080808080808080808080808080808080";
    attribute INIT_16 of inst : label is "FF8080808080808080808080808080808080808080808080FF80808080808080";
    attribute INIT_17 of inst : label is "80C08080C06060C007060303060C080F010F38E080F0180FC0701C07013F60C0";
    attribute INIT_18 of inst : label is "80F06040E0380C0780C040603C060301070C38604060F0800103063C6040C080";
    attribute INIT_19 of inst : label is "FF8080808080808080808080808080FF8080808080808080FF80808080808080";
    attribute INIT_1A of inst : label is "000080808080C0E00000000107040C0FA0C0C080808000000C0C070401000000";
    attribute INIT_1B of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80808080808080FF8080808080808080";
    attribute INIT_1C of inst : label is "0000000000FFF0C0000000000001037FC0C0F0FF00000000FF7F030100000000";
    attribute INIT_1D of inst : label is "0000000000FFF0C0000000000001037FC0C0F0FF00000000FF7F030100000000";
    attribute INIT_1E of inst : label is "0000000000FFF0C0000000000001037FC0C0F0FF00000000FF7F030100000000";
    attribute INIT_1F of inst : label is "707C5E477F48454D0F1B3F6FFFFDFFFF7F7D454F7F465C70FFFEBFFF7F371F0F";
    attribute INIT_20 of inst : label is "81818181818181FF8181818181818181FF81818181818181FFFFFFFFFFFFFFFF";
    attribute INIT_21 of inst : label is "000000000000C0800000000000000100C0C08080000000000101000000000000";
    attribute INIT_22 of inst : label is "000000000000C0800000000000000100C0C08080000000000101000000000000";
    attribute INIT_23 of inst : label is "00000000000080800000000000000003C0C04000000000000100000000000000";
    attribute INIT_24 of inst : label is "00000000000000800000000000000103C0C00000000000000100000000000000";
    attribute INIT_25 of inst : label is "000000000000C0F00000000000000203C0000000000000000200000000000000";
    attribute INIT_26 of inst : label is "707E7E4E477D7D4F0F1D3F7FDFFFFFFD454D7F7F464E7C70FFFFBFFF7F3F1D0F";
    attribute INIT_27 of inst : label is "0000000000000000000000000000002090B060F0A0404878020307010301090F";
    attribute INIT_28 of inst : label is "706040E0C0D0F0D00703010100070404D0F0C0E0C0C0C0800704000301010100";
    attribute INIT_29 of inst : label is "8080808080C080C00000000001010109D070F0B0E04048780B0F05070301090F";
    attribute INIT_2A of inst : label is "F0E0C0E0C0F0D0D00703010300040704F0D0C0E0C0C0C0800407000301010100";
    attribute INIT_2B of inst : label is "8080C0A0E0C080C8000000010100080948D0B0F0E0404878050703020101090F";
    attribute INIT_2C of inst : label is "F0E0C0E0E0C0D0F00703010203040407D0D0E0E0C0C0C0800404030301010100";
    attribute INIT_2D of inst : label is "80808040E0C0D0D0000001010102010570F0B0E0C0004878050705030101090F";
    attribute INIT_2E of inst : label is "706040E0C0D0F0D00703010100070404D0F0C0E0C0C0C0800704000301010100";
    attribute INIT_2F of inst : label is "705C467E4F4A4F7D0F1F377FFFFDFFFF7D4F459E7E465C70FFEFFFFF7D3F1F0F";
    attribute INIT_30 of inst : label is "8060D0F078D8E0700101070F1D17030FE0C0E0B0C08000000A03060002030101";
    attribute INIT_31 of inst : label is "FFFFFFFF00000000FFFFFF0000000000FFFF000000000000FF00000000000000";
    attribute INIT_32 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF0000FFFFFFFFFF000000";
    attribute INIT_33 of inst : label is "86CF2FC6E0F0F67F01030403273F6FFE1F3670E0C62FCF86F86C3E2703040301";
    attribute INIT_34 of inst : label is "F3CB9182C981D3FF0060C0858DF87000E724243C3C2424E7FFFFFFFFFFFFFFFF";
    attribute INIT_35 of inst : label is "40E0B0E0B0F87888010107020F0D0B15A0C0C080000080800604030101000000";
    attribute INIT_36 of inst : label is "C0C0F060F0C0A0F00102030706030201F0A02020202020400002000000000000";
    attribute INIT_37 of inst : label is "C0C0F0B0E8F0C06000030207030E0507E0C0E040400000000002020000000000";
    attribute INIT_38 of inst : label is "000308106080CC40001002004020130660A2801C020100000103410404081020";
    attribute INIT_39 of inst : label is "04081810D061DE50020181403306090FA0C02030100806011522438102040408";
    attribute INIT_3A of inst : label is "41860890F0B8CCEC10080807070A1C1B982FE8B0C01008041A768F0601020204";
    attribute INIT_3B of inst : label is "81824CE8DCF856E98040231D1E050F1AEED8B0FCB4424121B25B0D171F254080";
    attribute INIT_3C of inst : label is "8880889020101020232111008080804000204080000000000201000000000000";
    attribute INIT_3D of inst : label is "70D0BC7BD0B070C80B3DC70A070D112088840402010100002040810202020204";
    attribute INIT_3E of inst : label is "54B0D43E6CA050F03D2E373B4E8B040748840281804040400B050B1020404080";
    attribute INIT_3F of inst : label is "5ED476DDBC74ECDC57759E333D0F0B1CB2F148D060A02010264B870102050810";
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
