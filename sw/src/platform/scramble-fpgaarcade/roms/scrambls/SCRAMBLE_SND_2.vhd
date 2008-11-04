-- generated with romgen v3.0 by MikeJ
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library UNISIM;
  use UNISIM.Vcomponents.all;

entity SCRAMBLE_SND_2 is
  port (
    CLK         : in    std_logic;
    ENA         : in    std_logic;
    ADDR        : in    std_logic_vector(10 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of SCRAMBLE_SND_2 is


  type ROM_ARRAY is array(0 to 2047) of std_logic_vector(7 downto 0);
  constant ROM : ROM_ARRAY := (
    x"88",x"8C",x"8F",x"8C",x"88",x"8C",x"88",x"8C", -- 0x0000
    x"8F",x"8C",x"88",x"AF",x"FF",x"1F",x"0A",x"5F", -- 0x0008
    x"09",x"A8",x"80",x"68",x"68",x"A8",x"80",x"68", -- 0x0010
    x"68",x"88",x"83",x"88",x"8C",x"88",x"83",x"88", -- 0x0018
    x"83",x"88",x"8C",x"88",x"83",x"88",x"83",x"88", -- 0x0020
    x"8C",x"88",x"83",x"AC",x"FF",x"FF",x"CD",x"C7", -- 0x0028
    x"06",x"3E",x"01",x"32",x"73",x"80",x"CD",x"0D", -- 0x0030
    x"05",x"C3",x"8E",x"0F",x"CD",x"C7",x"06",x"CD", -- 0x0038
    x"0D",x"05",x"C9",x"CD",x"C7",x"06",x"CD",x"0D", -- 0x0040
    x"05",x"C9",x"DD",x"21",x"50",x"80",x"C3",x"DA", -- 0x0048
    x"0D",x"DD",x"21",x"58",x"80",x"C3",x"DA",x"0D", -- 0x0050
    x"DD",x"21",x"60",x"80",x"C3",x"DA",x"0D",x"1F", -- 0x0058
    x"0A",x"3F",x"0E",x"5F",x"08",x"85",x"85",x"85", -- 0x0060
    x"8A",x"8A",x"8A",x"8A",x"91",x"91",x"91",x"91", -- 0x0068
    x"8F",x"8F",x"D6",x"93",x"8F",x"93",x"B6",x"93", -- 0x0070
    x"8F",x"93",x"B6",x"FF",x"1F",x"0A",x"5F",x"08", -- 0x0078
    x"85",x"85",x"85",x"85",x"85",x"85",x"85",x"8E", -- 0x0080
    x"8E",x"8E",x"8E",x"8C",x"8C",x"D3",x"8F",x"8C", -- 0x0088
    x"8F",x"B3",x"8F",x"8C",x"8F",x"B3",x"FF",x"1F", -- 0x0090
    x"0A",x"5F",x"08",x"91",x"91",x"91",x"8A",x"8A", -- 0x0098
    x"8A",x"8A",x"96",x"96",x"96",x"96",x"94",x"94", -- 0x00A0
    x"D6",x"93",x"8F",x"93",x"B6",x"93",x"8F",x"93", -- 0x00A8
    x"B6",x"FF",x"CD",x"C7",x"06",x"3E",x"02",x"32", -- 0x00B0
    x"73",x"80",x"CD",x"0D",x"05",x"C3",x"8E",x"0F", -- 0x00B8
    x"CD",x"C7",x"06",x"CD",x"0D",x"05",x"C9",x"DD", -- 0x00C0
    x"21",x"50",x"80",x"C3",x"DA",x"0D",x"DD",x"21", -- 0x00C8
    x"58",x"80",x"C3",x"DA",x"0D",x"1F",x"0A",x"3F", -- 0x00D0
    x"0A",x"5F",x"09",x"8D",x"8F",x"91",x"8F",x"91", -- 0x00D8
    x"94",x"91",x"8F",x"8D",x"8F",x"91",x"8D",x"8F", -- 0x00E0
    x"8C",x"AD",x"FF",x"1F",x"0A",x"5F",x"09",x"8A", -- 0x00E8
    x"8C",x"8D",x"8C",x"8D",x"8F",x"8D",x"8C",x"8A", -- 0x00F0
    x"8C",x"8D",x"8A",x"8C",x"88",x"AA",x"FF",x"FF", -- 0x00F8
    x"CD",x"BC",x"07",x"21",x"00",x"03",x"22",x"83", -- 0x0100
    x"80",x"21",x"80",x"80",x"36",x"01",x"21",x"00", -- 0x0108
    x"08",x"22",x"81",x"80",x"CD",x"C6",x"04",x"CD", -- 0x0110
    x"0D",x"05",x"06",x"0B",x"CD",x"FE",x"05",x"C9", -- 0x0118
    x"2A",x"83",x"80",x"2B",x"22",x"83",x"80",x"7D", -- 0x0120
    x"B4",x"28",x"52",x"3A",x"80",x"80",x"FE",x"00", -- 0x0128
    x"28",x"1E",x"FE",x"01",x"28",x"0E",x"FE",x"02", -- 0x0130
    x"28",x"05",x"21",x"00",x"0A",x"18",x"08",x"21", -- 0x0138
    x"00",x"06",x"18",x"03",x"21",x"00",x"08",x"22", -- 0x0140
    x"81",x"80",x"CD",x"C6",x"04",x"AF",x"18",x"28", -- 0x0148
    x"2A",x"81",x"80",x"11",x"20",x"00",x"ED",x"52", -- 0x0150
    x"22",x"81",x"80",x"7C",x"FE",x"00",x"28",x"06", -- 0x0158
    x"CD",x"C6",x"04",x"AF",x"18",x"12",x"CD",x"C6", -- 0x0160
    x"04",x"3A",x"80",x"80",x"3C",x"32",x"80",x"80", -- 0x0168
    x"FE",x"04",x"28",x"02",x"AF",x"C9",x"3E",x"01", -- 0x0170
    x"32",x"80",x"80",x"AF",x"C9",x"3E",x"FF",x"C9", -- 0x0178
    x"CD",x"BC",x"07",x"3E",x"01",x"32",x"86",x"80", -- 0x0180
    x"3E",x"20",x"32",x"87",x"80",x"3E",x"06",x"32", -- 0x0188
    x"88",x"80",x"AF",x"32",x"89",x"80",x"32",x"8A", -- 0x0190
    x"80",x"21",x"00",x"03",x"22",x"8D",x"80",x"21", -- 0x0198
    x"00",x"04",x"22",x"8B",x"80",x"CD",x"C6",x"04", -- 0x01A0
    x"CD",x"0D",x"05",x"06",x"0B",x"CD",x"FE",x"05", -- 0x01A8
    x"C9",x"2A",x"8D",x"80",x"2B",x"7C",x"B5",x"28", -- 0x01B0
    x"5D",x"22",x"8D",x"80",x"3A",x"89",x"80",x"FE", -- 0x01B8
    x"00",x"28",x"06",x"FE",x"01",x"28",x"24",x"AF", -- 0x01C0
    x"C9",x"21",x"86",x"80",x"35",x"20",x"F8",x"36", -- 0x01C8
    x"01",x"CD",x"80",x"06",x"B7",x"11",x"08",x"00", -- 0x01D0
    x"ED",x"52",x"CD",x"C6",x"04",x"21",x"87",x"80", -- 0x01D8
    x"35",x"20",x"E4",x"36",x"20",x"21",x"89",x"80", -- 0x01E0
    x"34",x"18",x"DC",x"2A",x"8B",x"80",x"11",x"30", -- 0x01E8
    x"00",x"3A",x"8A",x"80",x"E6",x"01",x"20",x"1B", -- 0x01F0
    x"B7",x"ED",x"52",x"22",x"8B",x"80",x"CD",x"C6", -- 0x01F8
    x"04",x"21",x"88",x"80",x"35",x"20",x"06",x"36", -- 0x0200
    x"06",x"21",x"8A",x"80",x"34",x"21",x"89",x"80", -- 0x0208
    x"35",x"18",x"B4",x"19",x"18",x"E5",x"3E",x"FF", -- 0x0210
    x"C9",x"C9",x"3E",x"FF",x"C9",x"CD",x"82",x"07", -- 0x0218
    x"3E",x"01",x"32",x"A0",x"80",x"3E",x"20",x"32", -- 0x0220
    x"A1",x"80",x"3E",x"10",x"32",x"A2",x"80",x"AF", -- 0x0228
    x"32",x"A5",x"80",x"32",x"A6",x"80",x"21",x"00", -- 0x0230
    x"01",x"22",x"A3",x"80",x"21",x"00",x"05",x"22", -- 0x0238
    x"A7",x"80",x"CD",x"C6",x"04",x"CD",x"0D",x"05", -- 0x0240
    x"06",x"0D",x"CD",x"FE",x"05",x"C9",x"2A",x"A3", -- 0x0248
    x"80",x"2B",x"7C",x"B5",x"28",x"5D",x"22",x"A3", -- 0x0250
    x"80",x"3A",x"A5",x"80",x"FE",x"00",x"28",x"06", -- 0x0258
    x"FE",x"01",x"28",x"24",x"AF",x"C9",x"21",x"A0", -- 0x0260
    x"80",x"35",x"20",x"F8",x"36",x"01",x"CD",x"80", -- 0x0268
    x"06",x"B7",x"11",x"04",x"00",x"ED",x"52",x"CD", -- 0x0270
    x"C6",x"04",x"21",x"A1",x"80",x"35",x"20",x"E4", -- 0x0278
    x"36",x"20",x"21",x"A5",x"80",x"34",x"18",x"DC", -- 0x0280
    x"2A",x"A7",x"80",x"11",x"50",x"00",x"3A",x"A6", -- 0x0288
    x"80",x"E6",x"01",x"20",x"1B",x"B7",x"ED",x"52", -- 0x0290
    x"22",x"A7",x"80",x"CD",x"C6",x"04",x"21",x"A2", -- 0x0298
    x"80",x"35",x"20",x"06",x"36",x"10",x"21",x"A6", -- 0x02A0
    x"80",x"34",x"21",x"A5",x"80",x"35",x"18",x"B4", -- 0x02A8
    x"19",x"18",x"E5",x"3E",x"FF",x"C9",x"CD",x"C7", -- 0x02B0
    x"06",x"3E",x"18",x"32",x"B0",x"80",x"21",x"00", -- 0x02B8
    x"01",x"22",x"B1",x"80",x"AF",x"32",x"B3",x"80", -- 0x02C0
    x"21",x"00",x"02",x"22",x"B4",x"80",x"16",x"06", -- 0x02C8
    x"1E",x"00",x"CD",x"4C",x"05",x"CD",x"80",x"05", -- 0x02D0
    x"06",x"03",x"CD",x"FE",x"05",x"C9",x"2A",x"B4", -- 0x02D8
    x"80",x"2B",x"7C",x"B5",x"28",x"4B",x"22",x"B4", -- 0x02E0
    x"80",x"3A",x"B3",x"80",x"FE",x"00",x"28",x"1B", -- 0x02E8
    x"2A",x"B1",x"80",x"2B",x"7C",x"B5",x"20",x"34", -- 0x02F0
    x"21",x"00",x"01",x"22",x"B1",x"80",x"16",x"06", -- 0x02F8
    x"1E",x"00",x"CD",x"4C",x"05",x"AF",x"32",x"B3", -- 0x0300
    x"80",x"AF",x"C9",x"21",x"B0",x"80",x"35",x"20", -- 0x0308
    x"F8",x"36",x"18",x"16",x"06",x"CD",x"35",x"06", -- 0x0310
    x"1C",x"7B",x"FE",x"08",x"28",x"05",x"CD",x"4C", -- 0x0318
    x"05",x"18",x"E6",x"CD",x"4C",x"05",x"21",x"B3", -- 0x0320
    x"80",x"34",x"18",x"DD",x"22",x"B1",x"80",x"18", -- 0x0328
    x"D8",x"3E",x"FF",x"C9",x"CD",x"BC",x"07",x"3E", -- 0x0330
    x"01",x"32",x"C0",x"80",x"21",x"00",x"08",x"22", -- 0x0338
    x"C3",x"80",x"AF",x"32",x"C5",x"80",x"21",x"00", -- 0x0340
    x"02",x"22",x"C6",x"80",x"21",x"00",x"05",x"CD", -- 0x0348
    x"C6",x"04",x"CD",x"0D",x"05",x"06",x"08",x"CD", -- 0x0350
    x"FE",x"05",x"C9",x"2A",x"C6",x"80",x"2B",x"7C", -- 0x0358
    x"B5",x"28",x"43",x"22",x"C6",x"80",x"21",x"C0", -- 0x0360
    x"80",x"35",x"20",x"2C",x"36",x"01",x"CD",x"80", -- 0x0368
    x"06",x"11",x"08",x"00",x"19",x"ED",x"5B",x"C3", -- 0x0370
    x"80",x"7C",x"BA",x"20",x"18",x"7D",x"BB",x"20", -- 0x0378
    x"14",x"3A",x"C5",x"80",x"B7",x"20",x"13",x"21", -- 0x0380
    x"00",x"0B",x"22",x"C3",x"80",x"3E",x"FF",x"32", -- 0x0388
    x"C5",x"80",x"21",x"00",x"05",x"CD",x"C6",x"04", -- 0x0390
    x"AF",x"C9",x"21",x"00",x"08",x"22",x"C3",x"80", -- 0x0398
    x"AF",x"32",x"C5",x"80",x"18",x"EC",x"3E",x"FF", -- 0x03A0
    x"C9",x"CD",x"48",x"07",x"3E",x"08",x"32",x"D0", -- 0x03A8
    x"80",x"3E",x"05",x"32",x"D1",x"80",x"3E",x"0C", -- 0x03B0
    x"32",x"D2",x"80",x"AF",x"32",x"D3",x"80",x"21", -- 0x03B8
    x"50",x"00",x"CD",x"C6",x"04",x"CD",x"0D",x"05", -- 0x03C0
    x"06",x"00",x"CD",x"FE",x"05",x"C9",x"3A",x"D3", -- 0x03C8
    x"80",x"FE",x"00",x"28",x"18",x"FE",x"01",x"28", -- 0x03D0
    x"26",x"FE",x"02",x"28",x"27",x"FE",x"03",x"28", -- 0x03D8
    x"33",x"21",x"D2",x"80",x"35",x"28",x"32",x"AF", -- 0x03E0
    x"32",x"D3",x"80",x"AF",x"C9",x"CD",x"4B",x"06", -- 0x03E8
    x"3C",x"FE",x"0A",x"20",x"04",x"21",x"D3",x"80", -- 0x03F0
    x"34",x"47",x"CD",x"FE",x"05",x"18",x"EC",x"CD", -- 0x03F8
    x"1C",x"14",x"18",x"E7",x"CD",x"4B",x"06",x"3D", -- 0x0400
    x"20",x"04",x"21",x"D3",x"80",x"34",x"47",x"CD", -- 0x0408
    x"FE",x"05",x"18",x"D7",x"CD",x"29",x"14",x"18", -- 0x0410
    x"D2",x"3E",x"FF",x"C9",x"21",x"D0",x"80",x"35", -- 0x0418
    x"C0",x"3E",x"08",x"77",x"21",x"D3",x"80",x"34", -- 0x0420
    x"C9",x"21",x"D1",x"80",x"35",x"C0",x"3E",x"05", -- 0x0428
    x"77",x"21",x"D3",x"80",x"34",x"C9",x"FF",x"FF", -- 0x0430
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0438
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0440
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0448
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0450
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0458
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0460
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0468
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0470
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0478
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0480
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0488
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0490
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0498
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04A0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04A8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04B0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04B8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04C0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04C8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04D0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04D8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04E0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04E8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04F0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x04F8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0500
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0508
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0510
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0518
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0520
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0528
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0530
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0538
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0540
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0548
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0550
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0558
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0560
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0568
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0570
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0578
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0580
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0588
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0590
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0598
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05A0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05A8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05B0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05B8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05C0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05C8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05D0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05D8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05E0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05E8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05F0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x05F8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0600
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0608
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0610
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0618
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0620
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0628
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0630
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0638
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0640
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0648
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0650
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0658
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0660
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0668
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0670
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0678
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0680
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0688
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0690
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0698
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06A0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06A8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06B0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06B8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06C0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06C8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06D0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06D8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06E0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06E8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06F0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x06F8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0700
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0708
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0710
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0718
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0720
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0728
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0730
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0738
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0740
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0748
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0750
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0758
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0760
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0768
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0770
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0778
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0780
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0788
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0790
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x0798
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07A0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07A8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07B0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07B8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07C0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07C8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07D0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07D8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07E0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07E8
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF", -- 0x07F0
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF"  -- 0x07F8
  );

begin

  p_rom : process
  begin
    wait until rising_edge(CLK);
    if (ENA = '1') then
       DATA <= ROM(to_integer(unsigned(ADDR)));
    end if;
  end process;
end RTL;
