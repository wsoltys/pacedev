-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity SCRAMBLE_SND_0 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(10 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_SND_0 is

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
    attribute INIT_00 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0272C3";
    attribute INIT_01 of inst : label is "80DB40D30E3ED908FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_02 of inst : label is "FB200523778000210C06C9FB08D9006FCD10D6006BF240FE0064FA30FE1328B7";
    attribute INIT_03 of inst : label is "172803FE162802FE152801FEC8B700A6CDC9FB08D9C9FB08D900E7CDC9FB08D9";
    attribute INIT_04 of inst : label is "800632AFC9800432AFC9800232AFC9800032AFC9800A32AF192805FE182804FE";
    attribute INIT_05 of inst : label is "BE23231B28BE23231B28BE23231B28BE23231B28BE8000210006C9800832AFC9";
    attribute INIT_06 of inst : label is "3E7023C9043E7023C9033E7023C9023E7023C9013E7023C9AF1B28BE23231B28";
    attribute INIT_07 of inst : label is "3A80123201F1CD80003A7320B700A6CDAFC0B700A6CD801A32C9063E7023C905";
    attribute INIT_08 of inst : label is "80173201FACD80153201F1CD801A3A80143201F1CD80043A80133201F1CD8002";
    attribute INIT_09 of inst : label is "183201FACD80143201F1CD800A3A80133201F1CD80083A80123201F1CD80063A";
    attribute INIT_0A of inst : label is "01E3CD80002180173A4701F1CD01E3CD80062180183A7928B780173A6328B780";
    attribute INIT_0B of inst : label is "801A3A232805FE202804FE1D2803FE1A2802FE172801FE3E1801C3F2B801F1CD";
    attribute INIT_0C of inst : label is "C9800632801A3AC9800432801A3AC9800232801A3AC9800032801A3AC9800A32";
    attribute INIT_0D of inst : label is "0221131880002118188004210A2802FE092801FEC8B780173AC9800832801A3A";
    attribute INIT_0E of inst : label is "0821F318800621C900362377801A3A800A21102802FE0F2801FE80183A0E1880";
    attribute INIT_0F of inst : label is "80132180123AC97E1900165F024221C97E2323022802FE2323082801FEEE1880";
    attribute INIT_10 of inst : label is "BE80153A0226FABE801421C9023E0240FABE80153A0234FABE80143A0215FABE";
    attribute INIT_11 of inst : label is "C9033EC9AF023DFABE801521C9AFC9013EC9AF022FFABE801521C9033E0232FA";
    attribute INIT_12 of inst : label is "1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100C9AF";
    attribute INIT_13 of inst : label is "0031F92084FE7C237080002100062F2E2D2C2B2A292827262524232221201F1E";
    attribute INIT_14 of inst : label is "20D3800F323F3E10D3073E80D3800E323F3E40D3073E77800C2290002156ED84";
    attribute INIT_15 of inst : label is "D30F3EF62080E680DB40D30F3EFB0455CD044DCD0445CD043DCD0435CD042DCD";
    attribute INIT_16 of inst : label is "023EF30000FB0804CD80003A034BCAB780013A801032013EF3F62880E680DB40";
    attribute INIT_17 of inst : label is "035DCAB780053A801032033EF30000FB0804CD80023A0354CAB780033A801032";
    attribute INIT_18 of inst : label is "F30000FB0804CD80063A0366CAB780073A801032043EF30000FB0804CD80043A";
    attribute INIT_19 of inst : label is "CAB7800B3A801032063EF30000FB0804CD80083A036FCAB780093A801032053E";
    attribute INIT_1A of inst : label is "80043A02F0C30381CD80023A02DAC30381CD80003A02B2C30804CD800A3A0378";
    attribute INIT_1B of inst : label is "B2C30381CD800A3A0332C30381CD80083A031CC30381CD80063A0306C30381CD";
    attribute INIT_1C of inst : label is "2803FE182802FE162801FE80103AE9EB56235E1903CD2100165F87E503922102";
    attribute INIT_1D of inst : label is "800532013EC9800332013EC9800132013EC9800B32013E1E2805FE1C2804FE1A";
    attribute INIT_1E of inst : label is "B913A9121D0CF90AB00A3409B8093C08C0045DC9800932013EC9800732013EC9";
    attribute INIT_1F of inst : label is "000000000000000C6D0BE30B3C11000000000010C010B21043103C102E0DC70D";
    attribute INIT_20 of inst : label is "000000000000000000133412B6121911800D7A00000000000000000000000000";
    attribute INIT_21 of inst : label is "D30A3EC980D3AF40D3093EC980D3AF40D3083E00000000000000000000000000";
    attribute INIT_22 of inst : label is "80103AC920D3AF10D30A3EC920D3AF10D3093EC920D3AF10D3083EC980D3AF40";
    attribute INIT_23 of inst : label is "CD0906C90455CD04B8CD24062D2805FE282804FE232803FE1E2802FE192801FE";
    attribute INIT_24 of inst : label is "0445CD04B8CD0906C9043DCD04AACD2406C90435CD04AACD1206C9042DCD04AA";
    attribute INIT_25 of inst : label is "B0800F3A10D3073EC980D3800E32B0800E3A40D3073EC9044DCD04B8CD1206C9";
    attribute INIT_26 of inst : label is "7804062C2805FE2C2804FE2C2803FE2C2802FE202801FE80103AC920D3800F32";
    attribute INIT_27 of inst : label is "180206C980D37C40D3780480D37D40D3780006C920D37C10D3780420D37D10D3";
    attribute INIT_28 of inst : label is "202804FE1E2803FE1C2802FE182801FE80103AD2180206D6180006EA180406EE";
    attribute INIT_29 of inst : label is "F018201EFB16F618101EFD16C90562CD081EFE16C90571CD201EFB16222805FE";
    attribute INIT_2A of inst : label is "D37B40D37AC920D37B10D37A055BFA04FE80103ADC18101EFD16E218081EFE16";
    attribute INIT_2B of inst : label is "C920D3800F32B3A2800F3A10D3073EC980D3800E32B3A2800E3A40D3073EC980";
    attribute INIT_2C of inst : label is "16C90571CD041EDF16222805FE202804FE1E2803FE1C2802FE182801FE80103A";
    attribute INIT_2D of inst : label is "3ADC18021EEF16E218011EF716F018041EDF16F618021EEF16C90562CD011EF7";
    attribute INIT_2E of inst : label is "F616C90571CD001EDB16222805FE202804FE1E2803FE1C2802FE182801FE8010";
    attribute INIT_2F of inst : label is "103ADC18001EED16E218001EF616F018001EDB16F618001EED16C90562CD001E";
    attribute INIT_30 of inst : label is "D3083EC920D37810D30A3E1C2805FE1C2804FE1C2803FE1C2802FE182801FE80";
    attribute INIT_31 of inst : label is "10D37A0644FA04FE80103AE218093EE618083EF2180A3EF618093EC980D37840";
    attribute INIT_32 of inst : label is "05FE1A2804FE1A2803FE1A2802FE172801FE80103AC95F80DB40D37AC95F20DB";
    attribute INIT_33 of inst : label is "E418093EE818083EF3180A3EF718093EC980DB40D3083EC920DB10D30A3E1A28";
    attribute INIT_34 of inst : label is "046F20DB10D37804062C2805FE2C2804FE2C2803FE2C2802FE202801FE80103A";
    attribute INIT_35 of inst : label is "06EA180406EE180206C96780DB40D378046F80DB40D3780006C96720DB10D378";
    attribute INIT_36 of inst : label is "FF11252802FE242801FE232806FE222805FE212804FE80103AD2180206D61800";
    attribute INIT_37 of inst : label is "3F11E318FFCF11E818FFF311ED18FFFC11C977800C226FA57B67A47A800C2AF3";
    attribute INIT_38 of inst : label is "11242802FE232801FE222806FE212805FE202804FE80103AD918FCFF11DE18FF";
    attribute INIT_39 of inst : label is "3F11E418FFCF11E918FFF311EE18FFFC11C9800C226FA57B67A47A800C2AF3FF";
    attribute INIT_3A of inst : label is "02FE1A2801FE192806FE182805FE172804FE80103A0708CDDA18FCFF11DF18FF";
    attribute INIT_3B of inst : label is "020011E818008011ED18002011F218000811F718000211C907F6CD0800111B28";
    attribute INIT_3C of inst : label is "CD0400111B2802FE1A2801FE192806FE182805FE172804FE80103A0708CDE318";
    attribute INIT_3D of inst : label is "3A0708CDE318010011E818004011ED18001011F218000411F718000111C907F6";
    attribute INIT_3E of inst : label is "000311C907F6CD0C00111B2802FE1A2801FE192806FE182805FE172804FE8010";
    attribute INIT_3F of inst : label is "226FB57B67B47A800C2AE318030011E81800C011ED18003011F218000C11F718";
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
