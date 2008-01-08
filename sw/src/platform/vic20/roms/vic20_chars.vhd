-- generated with romgen by MikeJ
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VIC20_CHAR_ROM is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of VIC20_CHAR_ROM is

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

  component RAMB4_S1
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
      DO    : out std_logic_vector (0 downto 0);
      DI    : in  std_logic_vector (0 downto 0);
      ADDR  : in  std_logic_vector (11 downto 0);
      WE    : in  std_logic;
      EN    : in  std_logic;
      RST   : in  std_logic;
      CLK   : in  std_logic 
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
    attribute INIT_00 of inst : label is "1000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "FF04000010080008008110000E4000FF01018080001000000020020408001810";
    attribute INIT_03 of inst : label is "F000000F00FFE00703FF000000101010C00010F010FF01A0FFAA008001F00000";
    attribute INIT_04 of inst : label is "EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_05 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_06 of inst : label is "00FBFFFFEFF7FFF7FF7EEFFFF1BFFF00FEFE7F7FFFEFFFFFFFDFFDFBF7FFE7EF";
    attribute INIT_07 of inst : label is "0FFFFFF0FF001FF8FC00FFFFFFEFEFEF3FFFEF0FEF00FE5F0055FF7FFE0FFFFF";
    attribute INIT_08 of inst : label is "10000000000000003C0000000000000000007800000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "CCCC000010000000000000000000000000000000000000000000000000000010";
    attribute INIT_0B of inst : label is "F000000F0001E00703FF000000101010C00010F010FF33A0FFAA008001F00000";
    attribute INIT_0C of inst : label is "EFFFFFFFFFFFFFFFC3FFFFFFFFFFFFFFFFFF87FFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_0D of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_0E of inst : label is "3333FFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEF";
    attribute INIT_0F of inst : label is "0FFFFFF0FFFE1FF8FC00FFFFFFEFEFEF3FFFEF0FEF00CC5F0055FF7FFE0FFFFF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(0 downto 0),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom1 : if true generate
    attribute INIT_00 of inst : label is "10080040004307637F073F0132465C061C7F7F404101007F3A01411C22367C4E";
    attribute INIT_01 of inst : label is "0608144100001E36033011103646403E02000800082A00000050621214000000";
    attribute INIT_02 of inst : label is "7F080000101CFF1C3C4210001F403C0101024080001000000020020408005C10";
    attribute INIT_03 of inst : label is "F000000F0080E00703FF000000101010C00010F010FF03500055008001F00000";
    attribute INIT_04 of inst : label is "EFF7FFBFFFBCF89C80F8C0FECDB9A3F9E38080BFBEFEFF80C5FEBEE3DDC983B1";
    attribute INIT_05 of inst : label is "F9F7EBBEFFFFE1C9FCCFEEEFC9B9BFC1FDFFF7FFF7D5FFFFFFAF9DEDEBFFFFFF";
    attribute INIT_06 of inst : label is "80F7FFFFEFE300E3C3BDEFFFE0BFC3FEFEFDBF7FFFEFFFFFFFDFFDFBF7FFA3EF";
    attribute INIT_07 of inst : label is "0FFFFFF0FF7F1FF8FC00FFFFFFEFEFEF3FFFEF0FEF00FCAFFFAAFF7FFE0FFFFF";
    attribute INIT_08 of inst : label is "1008004000447C44401C7C202408FC1838780400000000787C02187F2838404E";
    attribute INIT_09 of inst : label is "0608144100001E36033011103646403E02000800082A00000050621214000000";
    attribute INIT_0A of inst : label is "66CC0000104307637F073F0132465C061C7F7F404101007F3A01411C22367C10";
    attribute INIT_0B of inst : label is "F000000F0002E00703FF000000101010C00010F010FF66500055008001F00000";
    attribute INIT_0C of inst : label is "EFF7FFBFFFBB83BBBFE383DFDBF703E7C787FBFFFFFFFF8783FDE780D7C7BFB1";
    attribute INIT_0D of inst : label is "F9F7EBBEFFFFE1C9FCCFEEEFC9B9BFC1FDFFF7FFF7D5FFFFFFAF9DEDEBFFFFFF";
    attribute INIT_0E of inst : label is "9933FFFFEFBCF89C80F8C0FECDB9A3F9E38080BFBEFEFF80C5FEBEE3DDC983EF";
    attribute INIT_0F of inst : label is "0FFFFFF0FFFD1FF8FC00FFFFFFEFEFEF3FFFEF0FEF0099AFFFAAFF7FFE0FFFFF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(1 downto 1),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom2 : if true generate
    attribute INIT_00 of inst : label is "10047F4941450814201840014929220922100240223F41084901412241490A59";
    attribute INIT_01 of inst : label is "091C1441000029490549297F4949404504000800081C00410120642A7F070000";
    attribute INIT_02 of inst : label is "3F780000103E000A422420003F407E0101042080000800FF0020020408007E10";
    attribute INIT_03 of inst : label is "F000000F0080E00703FF000000101010C00010F0100007A000AA008001F00000";
    attribute INIT_04 of inst : label is "EFFB80B6BEBAF7EBDFE7BFFEB6D6DDF6DDEFFDBFDDC0BEF7B6FEBEDDBEB6F5A6";
    attribute INIT_05 of inst : label is "F6E3EBBEFFFFD6B6FAB6D680B6B6BFBAFBFFF7FFF7E3FFBEFEDF9BD580F8FFFF";
    attribute INIT_06 of inst : label is "C087FFFFEFC1FFF5BDDBDFFFC0BF81FEFEFBDF7FFFF7FF00FFDFFDFBF7FF81EF";
    attribute INIT_07 of inst : label is "0FFFFFF0FF7F1FF8FC00FFFFFFEFEFEF3FFFEF0FEFFFF85FFF55FF7FFE0FFFFF";
    attribute INIT_08 of inst : label is "10047F49414C9028402020445404182444040440447D40049809542844443859";
    attribute INIT_09 of inst : label is "091C1441000029490549297F4949404504000800081C00410120642A7F070000";
    attribute INIT_0A of inst : label is "3333000010450814201840014929220922100240223F41084901412241490A10";
    attribute INIT_0B of inst : label is "F000000F0004E00703FF000000101010C00010F01000CCA000AA008001F00000";
    attribute INIT_0C of inst : label is "EFFB80B6BEB36FD7BFDFDFBBABFBE7DBBBFBFBBFBB82BFFB67F6ABD7BBBBC7A6";
    attribute INIT_0D of inst : label is "F6E3EBBEFFFFD6B6FAB6D680B6B6BFBAFBFFF7FFF7E3FFBEFEDF9BD580F8FFFF";
    attribute INIT_0E of inst : label is "CCCCFFFFEFBAF7EBDFE7BFFEB6D6DDF6DDEFFDBFDDC0BEF7B6FEBEDDBEB6F5EF";
    attribute INIT_0F of inst : label is "0FFFFFF0FFFB1FF8FC00FFFFFFEFEFEF3FFFEF0FEFFF335FFF55FF7FFE0FFFFF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(2 downto 2),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom3 : if true generate
    attribute INIT_00 of inst : label is "10FE4149414978081860407F4919510941080C4014417F084909494141490955";
    attribute INIT_01 of inst : label is "09361463642449490949451249497F49086008603E7F1C220256087F14004F00";
    attribute INIT_02 of inst : label is "1F08FF00FF7F00774218C0007E407E01010810800707C0000020020408007F10";
    attribute INIT_03 of inst : label is "F0001F0F0080E00703000000FFF01FF0C0F01FF0FF000F500055008001F00000";
    attribute INIT_04 of inst : label is "EF01BEB6BEB687F7E79FBF80B6E6AEF6BEF7F3BFEBBE80F7B6F6B6BEBEB6F6AA";
    attribute INIT_05 of inst : label is "F6C9EB9C9BDBB6B6F6B6BAEDB6B680B6F79FF79FC180E3DDFDA9F780EBFFB0FF";
    attribute INIT_06 of inst : label is "E0F700FF0080FF88BDE73FFF81BF81FEFEF7EF7FF8F83FFFFFDFFDFBF7FF80EF";
    attribute INIT_07 of inst : label is "0FFFE0F0FF7F1FF8FCFFFFFF000FE00F3F0FE00F00FFF0AFFFAAFF7FFE0FFFFF";
    attribute INIT_08 of inst : label is "10FE41494154A01038404044540424244404787F28847D04A409544444445455";
    attribute INIT_09 of inst : label is "09361463642449490949451249497F49086008603E7F1C220256087F14004F00";
    attribute INIT_0A of inst : label is "9933FF00FF4978081860407F4919510941080C4014417F084909494141490910";
    attribute INIT_0B of inst : label is "F0001F0F0008E00703000000FFF01FF0C0F01FF0FF0099500055008001F00000";
    attribute INIT_0C of inst : label is "EF01BEB6BEAB5FEFC7BFBFBBABFBDBDBBBFB8780D77B82FB5BF6ABBBBBBBABAA";
    attribute INIT_0D of inst : label is "F6C9EB9C9BDBB6B6F6B6BAEDB6B680B6F79FF79FC180E3DDFDA9F780EBFFB0FF";
    attribute INIT_0E of inst : label is "66CC00FF00B687F7E79FBF80B6E6AEF6BEF7F3BFEBBE80F7B6F6B6BEBEB6F6EF";
    attribute INIT_0F of inst : label is "0FFFE0F0FFF71FF8FCFFFFFF000FE00F3F0FE00F00FF66AFFFAAFF7FFE0FFFFF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(3 downto 3),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom4 : if true generate
    attribute INIT_00 of inst : label is "5404413E41490808186040014909410941040C40084041084109494141490949";
    attribute INIT_01 of inst : label is "5163143680004949714945144951424910600880081C221C0449102A14000000";
    attribute INIT_02 of inst : label is "0F7800AA103E000A421800003F407E0101100880080020000020020408FF7E10";
    attribute INIT_03 of inst : label is "0F0F1000F080E0070300000010101000C010000000001FA000AA008001F0FF00";
    attribute INIT_04 of inst : label is "ABFBBEC1BEB6F7F7E79FBFFEB6F6BEF6BEFBF3BFF7BFBEF7BEF6B6BEBEB6F6B6";
    attribute INIT_05 of inst : label is "AE9CEBC97FFFB6B68EB6BAEBB6AEBDB6EF9FF77FF7E3DDE3FBB6EFD5EBFFFFFF";
    attribute INIT_06 of inst : label is "F087FF55EFC1FFF5BDE7FFFFC0BF81FEFEEFF77FF7FFDFFFFFDFFDFBF70081EF";
    attribute INIT_07 of inst : label is "F0F0EFFF0F7F1FF8FCFFFFFFEFEFEFFF3FEFFFFFFFFFE05FFF55FF7FFE0F00FF";
    attribute INIT_08 of inst : label is "5404413E4154A0104040403F540424244404044110804404A47E544444445449";
    attribute INIT_09 of inst : label is "5163143680004949714945144951424910600880081C221C0449102A14000000";
    attribute INIT_0A of inst : label is "CCCC00AA10490808186040014909410941040C40084041084109494141490910";
    attribute INIT_0B of inst : label is "0F0F1000F010E0070300000010101000C0100000000033A000AA008001F0FF00";
    attribute INIT_0C of inst : label is "ABFBBEC1BEAB5FEFBFBFBFC0ABFBDBDBBBFBFBBEEF7FBBFB5B81ABBBBBBBABB6";
    attribute INIT_0D of inst : label is "AE9CEBC97FFFB6B68EB6BAEBB6AEBDB6EF9FF77FF7E3DDE3FBB6EFD5EBFFFFFF";
    attribute INIT_0E of inst : label is "3333FF55EFB6F7F7E79FBFFEB6F6BEF6BEFBF3BFF7BFBEF7BEF6B6BEBEB6F6EF";
    attribute INIT_0F of inst : label is "F0F0EFFF0FEF1FF8FCFFFFFFEFEFEFFF3FEFFFFFFFFFCC5FFF55FF7FFE0F00FF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(4 downto 4),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom5 : if true generate
    attribute INIT_00 of inst : label is "380841687F510714201840014909220922020240084000082209497F227F0A22";
    attribute INIT_01 of inst : label is "0141141C00004949014A45184151445120000800082A4100004926247F070000";
    attribute INIT_02 of inst : label is "07080055101C001C422400001F407E010120048010001000FF20020408005C10";
    attribute INIT_03 of inst : label is "0F0F1000F080E0070300FF0010101000C010000000003F500055008001F0FF00";
    attribute INIT_04 of inst : label is "C7F7BE9780AEF8EBDFE7BFFEB6F6DDF6DDFDFDBFF7BFFFF7DDF6B680DD80F5DD";
    attribute INIT_05 of inst : label is "FEBEEBE3FFFFB6B6FEB5BAE7BEAEBBAEDFFFF7FFF7D5BEFFFFB6D9DB80F8FFFF";
    attribute INIT_06 of inst : label is "F8F7FFAAEFE3FFE3BDDBFFFFE0BF81FEFEDFFB7FEFFFEFFF00DFFDFBF7FFA3EF";
    attribute INIT_07 of inst : label is "F0F0EFFF0F7F1FF8FCFF00FFEFEFEFFF3FEFFFFFFFFFC0AFFFAAFF7FFE0F00FF";
    attribute INIT_08 of inst : label is "380841687F64A02840204004540824184408040020800008A408544444285422";
    attribute INIT_09 of inst : label is "0141141C00004949014A45184151445120000800082A4100004926247F070000";
    attribute INIT_0A of inst : label is "66CC005510510714201840014909220922020240084000082209497F227F0A10";
    attribute INIT_0B of inst : label is "0F0F1000F020E0070300FF0010101000C0100000000066500055008001F0FF00";
    attribute INIT_0C of inst : label is "C7F7BE97809B5FD7BFDFBFFBABF7DBE7BBF7FBFFDF7FFFF75BF7ABBBBBD7ABDD";
    attribute INIT_0D of inst : label is "FEBEEBE3FFFFB6B6FEB5BAE7BEAEBBAEDFFFF7FFF7D5BEFFFFB6D9DB80F8FFFF";
    attribute INIT_0E of inst : label is "9933FFAAEFAEF8EBDFE7BFFEB6F6DDF6DDFDFDBFF7BFFFF7DDF6B680DD80F5EF";
    attribute INIT_0F of inst : label is "F0F0EFFF0FDF1FF8FCFF00FFEFEFEFFF3FEFFFFFFFFF99AFFFAAFF7FFE0F00FF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(5 downto 5),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom6 : if true generate
    attribute INIT_00 of inst : label is "10000060006100637F073F00267F1C7F1C7F7F7F7F20007F1C7F7F411C417C1C";
    attribute INIT_01 of inst : label is "0241140800000636033C27102262003E40000800000000000036460014000000";
    attribute INIT_02 of inst : label is "031000AA100800083C4200FF0E403C0101400280100010000020020408001810";
    attribute INIT_03 of inst : label is "0F0F1000F080E0070300FFFF10101000C010000000007FA000AA008001F0FF00";
    attribute INIT_04 of inst : label is "EFFFFF9FFF9EFF9C80F8C0FFD980E380E380808080DFFF80E38080BEE3BE83E3";
    attribute INIT_05 of inst : label is "FDBEEBF7FFFFF9C9FCC3D8EFDD9DFFC1BFFFF7FFFFFFFFFFFFC9B9FFEBFFFFFF";
    attribute INIT_06 of inst : label is "FCEFFF55EFF7FFF7C3BDFF00F1BFC3FEFEBFFD7FEFFFEFFFFFDFFDFBF7FFE7EF";
    attribute INIT_07 of inst : label is "F0F0EFFF0F7F1FF8FCFF0000EFEFEFFF3FEFFFFFFFFF805FFF55FF7FFE0F00FF";
    attribute INIT_08 of inst : label is "1000006000441C443C1C3C04487C18FC387C7C007F40007F18083838387F201C";
    attribute INIT_09 of inst : label is "0241140800000636033C27102262003E40000800000000000036460014000000";
    attribute INIT_0A of inst : label is "333300AA106100637F073F00267F1C7F1C7F7F7F7F20007F1C7F7F411C417C10";
    attribute INIT_0B of inst : label is "0F0F1000F07CE0070300FFFF10101000C01000000000CCA000AA008001F0FF00";
    attribute INIT_0C of inst : label is "EFFFFF9FFFBBE3BBC3E3C3FBB783E703C78383FF80BFFF80E7F7C7C7C780DFE3";
    attribute INIT_0D of inst : label is "FDBEEBF7FFFFF9C9FCC3D8EFDD9DFFC1BFFFF7FFFFFFFFFFFFC9B9FFEBFFFFFF";
    attribute INIT_0E of inst : label is "CCCCFF55EF9EFF9C80F8C0FFD980E380E380808080DFFF80E38080BEE3BE83EF";
    attribute INIT_0F of inst : label is "F0F0EFFF0F831FF8FCFF0000EFEFEFFF3FEFFFFFFFFF335FFF55FF7FFE0F00FF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(6 downto 6),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
  rom7 : if true generate
    attribute INIT_00 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "01000055100000000081000000400001FF8001FF100010000020020408000010";
    attribute INIT_03 of inst : label is "0F0F1000F080E0070300FFFF10101000C01000000000FF500055FF8001F0FF00";
    attribute INIT_04 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_05 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_06 of inst : label is "FEFFFFAAEFFFFFFFFF7EFFFFFFBFFFFE007FFE00EFFFEFFFFFDFFDFBF7FFFFEF";
    attribute INIT_07 of inst : label is "F0F0EFFF0F7F1FF8FCFF0000EFEFEFFF3FEFFFFFFFFF00AFFFAA007FFE0F00FF";
    attribute INIT_08 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "9933005510000000000000000000000000000000000000000000000000000010";
    attribute INIT_0B of inst : label is "0F0F1000F000E0070300FFFF10101000C0100000000099500055FF8001F0FF00";
    attribute INIT_0C of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_0D of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_0E of inst : label is "66CCFFAAEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEF";
    attribute INIT_0F of inst : label is "F0F0EFFF0FFF1FF8FCFF0000EFEFEFFF3FEFFFFFFFFF66AFFFAA007FFE0F00FF";
  begin
    inst : ramb4_s1
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
        DO   => DATA(7 downto 7),
        DI   => "0",
        ADDR => rom_addr,
        WE   => '0',
        EN   => '1',
        RST  => '0',
        CLK  => CLK
        );
  end generate;
end RTL;
