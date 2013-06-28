library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

library work;
use work.atari_gtia_pkg.all;

entity atari_gtia is
  generic
  (
    VARIANT	: atari_gtia_variant
  );
  port
  (
    clk     : in std_logic;
    clk_en  : in std_logic;
    rst     : in std_logic;

    osc     : in std_logic;
    phi2_i  : in std_logic;
    fphi0_o : out std_logic;

    -- CPU interface
    a       : in std_logic_vector(4 downto 0);
    d_i     : in std_logic_vector(7 downto 0);
    d_o     : out std_logic_vector(7 downto 0);
    cs_n    : in std_logic;
    r_wn    : in std_logic;
    halt_n  : out std_logic;
    
    -- CTIA/GTIA interface
    an      : in std_logic_vector(2 downto 0);

    -- joystick
    t       : in std_logic_vector(3 downto 0);
    -- console
    s_i     : in std_logic_vector(3 downto 0);
    s_o     : out std_logic_vector(3 downto 0);
    
    -- video inputs
    cad3    : in std_logic;
    pal     : in std_logic;
    
    -- RGB output
    clk_vga : in std_logic;
    r       : out std_logic_vector(7 downto 0);
    g       : out std_logic_vector(7 downto 0);
    b       : out std_logic_vector(7 downto 0);
    hsync   : out std_logic;
    vsync   : out std_logic;
    de      : out std_logic;
    
    -- dbg
    dbg     : out gtia_dbg_t
	);
end entity atari_gtia;

architecture SYN of atari_gtia is

  type RGB_t is record
    r : std_logic_vector(9 downto 0);
    g : std_logic_vector(9 downto 0);
    b : std_logic_vector(9 downto 0);
  end record;

  type RGB_a is array (natural range <>) of RGB_t;

  constant palette : RGB_a(0 to 255) :=
  (
    000 => (r=>X"00", g=>X"00", b=>X"00"),
    001 => (r=>X"25", g=>X"25", b=>X"25"),
    002 => (r=>X"34", g=>X"34", b=>X"34"),
    003 => (r=>X"4F", g=>X"4F", b=>X"4F"),
    004 => (r=>X"5B", g=>X"5B", b=>X"5B"),
    005 => (r=>X"69", g=>X"69", b=>X"69"),
    006 => (r=>X"7B", g=>X"7B", b=>X"7B"),
    007 => (r=>X"8A", g=>X"8A", b=>X"8A"),
    008 => (r=>X"A7", g=>X"A7", b=>X"A7"),
    009 => (r=>X"B9", g=>X"B9", b=>X"B9"),
    010 => (r=>X"C5", g=>X"C5", b=>X"C5"),
    011 => (r=>X"D0", g=>X"D0", b=>X"D0"),
    012 => (r=>X"D7", g=>X"D7", b=>X"D7"),
    013 => (r=>X"E1", g=>X"E1", b=>X"E1"),
    014 => (r=>X"F4", g=>X"F4", b=>X"F4"),
    015 => (r=>X"FF", g=>X"FF", b=>X"FF"),
    016 => (r=>X"4C", g=>X"32", b=>X"00"),
    017 => (r=>X"62", g=>X"3A", b=>X"00"),
    018 => (r=>X"7B", g=>X"4A", b=>X"00"),
    019 => (r=>X"9A", g=>X"60", b=>X"00"),
    020 => (r=>X"B5", g=>X"74", b=>X"00"),
    021 => (r=>X"CC", g=>X"85", b=>X"00"),
    022 => (r=>X"E7", g=>X"9E", b=>X"08"),
    023 => (r=>X"F7", g=>X"AF", b=>X"10"),
    024 => (r=>X"FF", g=>X"C3", b=>X"18"),
    025 => (r=>X"FF", g=>X"D0", b=>X"20"),
    026 => (r=>X"FF", g=>X"D8", b=>X"28"),
    027 => (r=>X"FF", g=>X"DF", b=>X"30"),
    028 => (r=>X"FF", g=>X"E6", b=>X"3B"),
    029 => (r=>X"FF", g=>X"F4", b=>X"40"),
    030 => (r=>X"FF", g=>X"FA", b=>X"4B"),
    031 => (r=>X"FF", g=>X"FF", b=>X"50"),
    032 => (r=>X"99", g=>X"25", b=>X"00"),
    033 => (r=>X"AA", g=>X"25", b=>X"00"),
    034 => (r=>X"B4", g=>X"25", b=>X"00"),
    035 => (r=>X"D3", g=>X"30", b=>X"00"),
    036 => (r=>X"DD", g=>X"48", b=>X"02"),
    037 => (r=>X"E2", g=>X"50", b=>X"09"),
    038 => (r=>X"F4", g=>X"67", b=>X"00"),
    039 => (r=>X"F4", g=>X"75", b=>X"10"),
    040 => (r=>X"FF", g=>X"9E", b=>X"10"),
    041 => (r=>X"FF", g=>X"AC", b=>X"20"),
    042 => (r=>X"FF", g=>X"BA", b=>X"3A"),
    043 => (r=>X"FF", g=>X"BF", b=>X"50"),
    044 => (r=>X"FF", g=>X"C6", b=>X"6D"),
    045 => (r=>X"FF", g=>X"D5", b=>X"80"),
    046 => (r=>X"FF", g=>X"E4", b=>X"90"),
    047 => (r=>X"FF", g=>X"E6", b=>X"99"),
    048 => (r=>X"98", g=>X"0C", b=>X"0C"),
    049 => (r=>X"99", g=>X"0C", b=>X"0C"),
    050 => (r=>X"C2", g=>X"13", b=>X"00"),
    051 => (r=>X"D3", g=>X"20", b=>X"00"),
    052 => (r=>X"E2", g=>X"35", b=>X"00"),
    053 => (r=>X"E3", g=>X"40", b=>X"00"),
    054 => (r=>X"E4", g=>X"40", b=>X"20"),
    055 => (r=>X"E5", g=>X"52", b=>X"30"),
    056 => (r=>X"FD", g=>X"78", b=>X"54"),
    057 => (r=>X"FF", g=>X"8A", b=>X"6A"),
    058 => (r=>X"FF", g=>X"98", b=>X"7C"),
    059 => (r=>X"FF", g=>X"A4", b=>X"8B"),
    060 => (r=>X"FF", g=>X"B3", b=>X"9E"),
    061 => (r=>X"FF", g=>X"C2", b=>X"B2"),
    062 => (r=>X"FF", g=>X"D0", b=>X"BA"),
    063 => (r=>X"FF", g=>X"D7", b=>X"C0"),
    064 => (r=>X"99", g=>X"00", b=>X"00"),
    065 => (r=>X"A9", g=>X"00", b=>X"00"),
    066 => (r=>X"C2", g=>X"04", b=>X"00"),
    067 => (r=>X"D3", g=>X"04", b=>X"00"),
    068 => (r=>X"DA", g=>X"04", b=>X"00"),
    069 => (r=>X"DB", g=>X"08", b=>X"00"),
    070 => (r=>X"E4", g=>X"20", b=>X"20"),
    071 => (r=>X"F6", g=>X"40", b=>X"40"),
    072 => (r=>X"FB", g=>X"70", b=>X"70"),
    073 => (r=>X"FB", g=>X"7E", b=>X"7E"),
    074 => (r=>X"FB", g=>X"8F", b=>X"8F"),
    075 => (r=>X"FF", g=>X"9F", b=>X"9F"),
    076 => (r=>X"FF", g=>X"AB", b=>X"AB"),
    077 => (r=>X"FF", g=>X"B9", b=>X"B9"),
    078 => (r=>X"FF", g=>X"C9", b=>X"C9"),
    079 => (r=>X"FF", g=>X"CF", b=>X"CF"),
    080 => (r=>X"7E", g=>X"00", b=>X"50"),
    081 => (r=>X"80", g=>X"00", b=>X"50"),
    082 => (r=>X"80", g=>X"00", b=>X"5F"),
    083 => (r=>X"95", g=>X"0B", b=>X"74"),
    084 => (r=>X"AA", g=>X"22", b=>X"88"),
    085 => (r=>X"BB", g=>X"2F", b=>X"9A"),
    086 => (r=>X"CE", g=>X"3F", b=>X"AD"),
    087 => (r=>X"D7", g=>X"5A", b=>X"B6"),
    088 => (r=>X"E4", g=>X"67", b=>X"C3"),
    089 => (r=>X"EF", g=>X"72", b=>X"CE"),
    090 => (r=>X"FB", g=>X"7E", b=>X"DA"),
    091 => (r=>X"FF", g=>X"8D", b=>X"E1"),
    092 => (r=>X"FF", g=>X"9D", b=>X"E5"),
    093 => (r=>X"FF", g=>X"A5", b=>X"E7"),
    094 => (r=>X"FF", g=>X"AF", b=>X"EA"),
    095 => (r=>X"FF", g=>X"B8", b=>X"EC"),
    096 => (r=>X"48", g=>X"00", b=>X"6C"),
    097 => (r=>X"5C", g=>X"04", b=>X"88"),
    098 => (r=>X"65", g=>X"0D", b=>X"90"),
    099 => (r=>X"7B", g=>X"23", b=>X"A7"),
    100 => (r=>X"93", g=>X"3B", b=>X"BF"),
    101 => (r=>X"9D", g=>X"45", b=>X"C9"),
    102 => (r=>X"A7", g=>X"4F", b=>X"D3"),
    103 => (r=>X"B2", g=>X"5A", b=>X"DE"),
    104 => (r=>X"BD", g=>X"65", b=>X"E9"),
    105 => (r=>X"C5", g=>X"6D", b=>X"F1"),
    106 => (r=>X"CE", g=>X"76", b=>X"FA"),
    107 => (r=>X"D5", g=>X"83", b=>X"FF"),
    108 => (r=>X"DA", g=>X"90", b=>X"FF"),
    109 => (r=>X"DE", g=>X"9C", b=>X"FF"),
    110 => (r=>X"E2", g=>X"A9", b=>X"FF"),
    111 => (r=>X"E6", g=>X"B6", b=>X"FF"),
    112 => (r=>X"1B", g=>X"00", b=>X"70"),
    113 => (r=>X"22", g=>X"1B", b=>X"8D"),
    114 => (r=>X"37", g=>X"30", b=>X"A2"),
    115 => (r=>X"48", g=>X"41", b=>X"B3"),
    116 => (r=>X"59", g=>X"52", b=>X"C4"),
    117 => (r=>X"63", g=>X"5C", b=>X"CE"),
    118 => (r=>X"6F", g=>X"68", b=>X"DA"),
    119 => (r=>X"7D", g=>X"76", b=>X"E8"),
    120 => (r=>X"87", g=>X"80", b=>X"F8"),
    121 => (r=>X"93", g=>X"8C", b=>X"FF"),
    122 => (r=>X"9D", g=>X"97", b=>X"FF"),
    123 => (r=>X"A8", g=>X"A3", b=>X"FF"),
    124 => (r=>X"B3", g=>X"AF", b=>X"FF"),
    125 => (r=>X"BC", g=>X"B8", b=>X"FF"),
    126 => (r=>X"C4", g=>X"C1", b=>X"FF"),
    127 => (r=>X"DA", g=>X"D1", b=>X"FF"),
    128 => (r=>X"00", g=>X"0D", b=>X"7F"),
    129 => (r=>X"00", g=>X"12", b=>X"A7"),
    130 => (r=>X"00", g=>X"18", b=>X"C0"),
    131 => (r=>X"0A", g=>X"2B", b=>X"D1"),
    132 => (r=>X"1B", g=>X"4A", b=>X"E3"),
    133 => (r=>X"2F", g=>X"58", b=>X"F0"),
    134 => (r=>X"37", g=>X"68", b=>X"FF"),
    135 => (r=>X"49", g=>X"79", b=>X"FF"),
    136 => (r=>X"5B", g=>X"85", b=>X"FF"),
    137 => (r=>X"6D", g=>X"96", b=>X"FF"),
    138 => (r=>X"7F", g=>X"A3", b=>X"FF"),
    139 => (r=>X"8C", g=>X"AD", b=>X"FF"),
    140 => (r=>X"96", g=>X"B4", b=>X"FF"),
    141 => (r=>X"A8", g=>X"C0", b=>X"FF"),
    142 => (r=>X"B7", g=>X"CB", b=>X"FF"),
    143 => (r=>X"C6", g=>X"D6", b=>X"FF"),
    144 => (r=>X"00", g=>X"29", b=>X"5A"),
    145 => (r=>X"00", g=>X"38", b=>X"76"),
    146 => (r=>X"00", g=>X"48", b=>X"92"),
    147 => (r=>X"00", g=>X"5C", b=>X"AC"),
    148 => (r=>X"00", g=>X"71", b=>X"C6"),
    149 => (r=>X"00", g=>X"86", b=>X"D0"),
    150 => (r=>X"0A", g=>X"9B", b=>X"DF"),
    151 => (r=>X"1A", g=>X"A8", b=>X"EC"),
    152 => (r=>X"2B", g=>X"B6", b=>X"FF"),
    153 => (r=>X"3F", g=>X"C2", b=>X"FF"),
    154 => (r=>X"45", g=>X"CB", b=>X"FF"),
    155 => (r=>X"59", g=>X"D3", b=>X"FF"),
    156 => (r=>X"7F", g=>X"DA", b=>X"FF"),
    157 => (r=>X"8F", g=>X"DE", b=>X"FF"),
    158 => (r=>X"A0", g=>X"E2", b=>X"FF"),
    159 => (r=>X"B0", g=>X"EB", b=>X"FF"),
    160 => (r=>X"00", g=>X"38", b=>X"39"),
    161 => (r=>X"00", g=>X"3C", b=>X"48"),
    162 => (r=>X"00", g=>X"3D", b=>X"5B"),
    163 => (r=>X"02", g=>X"66", b=>X"7F"),
    164 => (r=>X"03", g=>X"73", b=>X"83"),
    165 => (r=>X"00", g=>X"9C", b=>X"AA"),
    166 => (r=>X"00", g=>X"A1", b=>X"BB"),
    167 => (r=>X"01", g=>X"A4", b=>X"CC"),
    168 => (r=>X"03", g=>X"BB", b=>X"FF"),
    169 => (r=>X"05", g=>X"DA", b=>X"E2"),
    170 => (r=>X"18", g=>X"E5", b=>X"FF"),
    171 => (r=>X"34", g=>X"EA", b=>X"FF"),
    172 => (r=>X"49", g=>X"EF", b=>X"FF"),
    173 => (r=>X"66", g=>X"F2", b=>X"FF"),
    174 => (r=>X"84", g=>X"F4", b=>X"FF"),
    175 => (r=>X"9E", g=>X"F9", b=>X"FF"),
    176 => (r=>X"00", g=>X"4A", b=>X"00"),
    177 => (r=>X"00", g=>X"5D", b=>X"00"),
    178 => (r=>X"00", g=>X"70", b=>X"00"),
    179 => (r=>X"00", g=>X"8B", b=>X"00"),
    180 => (r=>X"00", g=>X"A9", b=>X"00"),
    181 => (r=>X"00", g=>X"BB", b=>X"05"),
    182 => (r=>X"00", g=>X"BD", b=>X"00"),
    183 => (r=>X"02", g=>X"D0", b=>X"05"),
    184 => (r=>X"1A", g=>X"D5", b=>X"40"),
    185 => (r=>X"5A", g=>X"F1", b=>X"77"),
    186 => (r=>X"82", g=>X"EF", b=>X"A7"),
    187 => (r=>X"84", g=>X"ED", b=>X"D1"),
    188 => (r=>X"89", g=>X"FF", b=>X"ED"),
    189 => (r=>X"7D", g=>X"FF", b=>X"FF"),
    190 => (r=>X"93", g=>X"FF", b=>X"FF"),
    191 => (r=>X"9B", g=>X"FF", b=>X"FF"),
    192 => (r=>X"22", g=>X"4A", b=>X"03"),
    193 => (r=>X"27", g=>X"53", b=>X"04"),
    194 => (r=>X"30", g=>X"64", b=>X"05"),
    195 => (r=>X"3C", g=>X"77", b=>X"0C"),
    196 => (r=>X"45", g=>X"8C", b=>X"11"),
    197 => (r=>X"00", g=>X"B7", b=>X"04"),
    198 => (r=>X"03", g=>X"C2", b=>X"00"),
    199 => (r=>X"1F", g=>X"DD", b=>X"00"),
    200 => (r=>X"3D", g=>X"CD", b=>X"2D"),
    201 => (r=>X"3D", g=>X"CD", b=>X"30"),
    202 => (r=>X"58", g=>X"CC", b=>X"40"),
    203 => (r=>X"60", g=>X"D3", b=>X"50"),
    204 => (r=>X"A2", g=>X"EC", b=>X"55"),
    205 => (r=>X"B3", g=>X"F2", b=>X"4A"),
    206 => (r=>X"BB", g=>X"F6", b=>X"5D"),
    207 => (r=>X"C4", g=>X"F8", b=>X"70"),
    208 => (r=>X"2E", g=>X"3F", b=>X"0C"),
    209 => (r=>X"36", g=>X"4A", b=>X"0F"),
    210 => (r=>X"40", g=>X"56", b=>X"15"),
    211 => (r=>X"46", g=>X"5F", b=>X"17"),
    212 => (r=>X"57", g=>X"77", b=>X"1A"),
    213 => (r=>X"65", g=>X"85", b=>X"1C"),
    214 => (r=>X"74", g=>X"93", b=>X"1D"),
    215 => (r=>X"8F", g=>X"A5", b=>X"25"),
    216 => (r=>X"AD", g=>X"B7", b=>X"2C"),
    217 => (r=>X"BC", g=>X"C7", b=>X"30"),
    218 => (r=>X"C9", g=>X"D5", b=>X"33"),
    219 => (r=>X"D4", g=>X"E0", b=>X"3B"),
    220 => (r=>X"E0", g=>X"EC", b=>X"42"),
    221 => (r=>X"EA", g=>X"F6", b=>X"45"),
    222 => (r=>X"F0", g=>X"FD", b=>X"47"),
    223 => (r=>X"F4", g=>X"FF", b=>X"6F"),
    224 => (r=>X"55", g=>X"24", b=>X"00"),
    225 => (r=>X"5A", g=>X"2C", b=>X"00"),
    226 => (r=>X"6C", g=>X"3B", b=>X"00"),
    227 => (r=>X"79", g=>X"4B", b=>X"00"),
    228 => (r=>X"B9", g=>X"75", b=>X"00"),
    229 => (r=>X"BB", g=>X"85", b=>X"00"),
    230 => (r=>X"C1", g=>X"A1", b=>X"20"),
    231 => (r=>X"D0", g=>X"B0", b=>X"2F"),
    232 => (r=>X"DE", g=>X"BE", b=>X"3F"),
    233 => (r=>X"E6", g=>X"C6", b=>X"45"),
    234 => (r=>X"ED", g=>X"CD", b=>X"57"),
    235 => (r=>X"F5", g=>X"DB", b=>X"62"),
    236 => (r=>X"FB", g=>X"E5", b=>X"69"),
    237 => (r=>X"FC", g=>X"EE", b=>X"6F"),
    238 => (r=>X"FD", g=>X"F3", b=>X"77"),
    239 => (r=>X"FD", g=>X"F3", b=>X"7F"),
    240 => (r=>X"5C", g=>X"27", b=>X"00"),
    241 => (r=>X"5C", g=>X"2F", b=>X"00"),
    242 => (r=>X"71", g=>X"3B", b=>X"00"),
    243 => (r=>X"7B", g=>X"48", b=>X"00"),
    244 => (r=>X"B9", g=>X"68", b=>X"20"),
    245 => (r=>X"BB", g=>X"72", b=>X"20"),
    246 => (r=>X"C5", g=>X"86", b=>X"29"),
    247 => (r=>X"D7", g=>X"96", b=>X"33"),
    248 => (r=>X"E6", g=>X"A4", b=>X"40"),
    249 => (r=>X"F4", g=>X"B1", b=>X"4B"),
    250 => (r=>X"FD", g=>X"C1", b=>X"58"),
    251 => (r=>X"FF", g=>X"CC", b=>X"55"),
    252 => (r=>X"FF", g=>X"D4", b=>X"61"),
    253 => (r=>X"FF", g=>X"DD", b=>X"69"),
    254 => (r=>X"FF", g=>X"E6", b=>X"79"),
    255 => (r=>X"FF", g=>X"EA", b=>X"98")
  );

  type reg_a is array (natural range <>) of std_logic_vector(7 downto 0);
  
  -- WRITE-ONLY
  signal hposp_r    : reg_a(0 to 3);
  signal hposm_r    : reg_a(0 to 3);
  signal sizep_r    : reg_a(0 to 3);
  signal sizem_r    : std_logic_vector(7 downto 0);
  signal grafp_r    : reg_a(0 to 3);
  signal grafm_r    : std_logic_vector(7 downto 0);
  signal colpm_r    : reg_a(0 to 3);
  signal colpf_r    : reg_a(0 to 3);
  signal colbk_r    : std_logic_vector(7 downto 0);
  signal prior_r    : std_logic_vector(7 downto 0);
  signal vdelay_r   : std_logic_vector(7 downto 0);
  signal gractl_r   : std_logic_vector(7 downto 0);
  signal hitclr_r   : std_logic_vector(7 downto 0);
  signal conspk_r   : std_logic_vector(7 downto 0);
  
  -- READ_ONLY
  signal mpf_r    : reg_a(0 to 3);
  signal ppf_r    : reg_a(0 to 3);
  signal mpl_r    : reg_a(0 to 3);
  signal ppl_r    : reg_a(0 to 3);
  signal trig_r   : reg_a(0 to 3);
  signal pal_r    : std_logic_vector(7 downto 0);
  signal consol_r   : std_logic_vector(7 downto 0);
  
  -- video
  signal r_s      : std_logic_vector(7 downto 0);
  signal g_s      : std_logic_vector(7 downto 0);
  signal b_s      : std_logic_vector(7 downto 0);
  signal hsync_s  : std_logic;
  signal vsync_s  : std_logic;
  
begin

  -- clocks
  -- - supplies (in effect) CPU clock to ANTIC
  -- - FPHI0 has the same phase as PHI2
  fphi0_o <= phi2_i;
  
  -- registers
  process (clk, rst)
    variable i  : integer range 0 to 3;
  begin
    if rst = '1' then
      -- WRITE-ONLY
      hposp_r <= (others => (others => '0'));
      hposm_r <= (others => (others => '0'));
      sizep_r <= (others => (others => '0'));
      sizem_r <= (others => '0');
      grafp_r <= (others => (others => '0'));
      grafm_r <= (others => '0');
      colpm_r <= (others => (others => '0'));
      colpf_r <= (others => (others => '0'));
      colbk_r <= X"7F"; --(others => '0');
      prior_r <= (others => '0');
      vdelay_r <= (others => '0');
      gractl_r <= (others => '0');
      hitclr_r <= (others => '0');
      conspk_r <= (others => '0');
      -- READ_ONLY
      mpf_r <= (others => (others => '0'));
      ppf_r <= (others => (others => '0'));
      mpl_r <= (others => (others => '0'));
      ppl_r <= (others => (others => '0'));
      trig_r <= (others => (others => '0'));
      if VARIANT = CO14805 then
        -- NTSC
        pal_r <= "00000111";
      else
        -- PAL/SECAM?
        pal_r <= "00000000";
      end if;
      -- hack for now (no keys active)
      consol_r <= "00001111";
    elsif rising_edge(clk) then
      if phi2_i = '1' then
        if cs_n = '0' then
          i := to_integer(unsigned(a(1 downto 0)));
          if r_wn = '0' then
            -- register writes
            case a is
              when "00000" | "00001" | "00010" | "00011" =>
                hposp_r(i) <= d_i;
              when "00100" | "00101" | "00110" | "00111" =>
                hposm_r(i) <= d_i;
              when "01000" | "01001" | "01010" | "01011" =>
                sizep_r(i) <= d_i;
              when "01100" =>
                sizem_r <= d_i;
              when "01101" =>
                grafp_r(0) <= d_i;
              when "01110" =>
                grafp_r(1) <= d_i;
              when "01111" =>
                grafp_r(2) <= d_i;
              when "10000" =>
                grafp_r(3) <= d_i;
              when "10001" =>
                grafm_r <= d_i;
              when "10010" =>
                colpm_r(0) <= d_i;
              when "10011" =>
                colpm_r(1) <= d_i;
              when "10100" =>
                colpm_r(2) <= d_i;
              when "10101" =>
                colpm_r(3) <= d_i;
              when "10110" =>
                colpf_r(0) <= d_i;
              when "10111" =>
                colpf_r(1) <= d_i;
              when "11000" =>
                colpf_r(2) <= d_i;
              when "11001" =>
                colpf_r(3) <= d_i;
              when "11010" =>
                colbk_r <= d_i;
              when "11011" =>
                prior_r <= d_i;
              when "11100" =>
                vdelay_r <= d_i;
              when "11101" =>
                gractl_r <= d_i;
              when "11110" =>
                hitclr_r <= d_i;
              when "11111" =>
                conspk_r <= d_i;
              when others =>
                null;
            end case;
          else
            -- register reads
            case a is
              when "00000" | "00001" | "00010" | "00011" =>
                d_o <= mpf_r(i);
              when "00100" | "00101" | "00110" | "00111" =>
                d_o <= ppf_r(i);
              when "01000" | "01001" | "01010" | "01011" =>
                d_o <= mpl_r(i);
              when "01100" | "01101" | "01110" | "01111" =>
                d_o <= ppl_r(i);
              when "10000" | "10001" | "10010" | "10011" =>
                d_o <= trig_r(i);
              when "10100" =>
                d_o <= pal_r;
              when "11111" =>
                d_o <= consol_r;
              when others =>
                null;
            end case;
          end if; -- r_wn_i
        end if; -- $D4XX
      end if; -- clk_en
    end if;
  end process;

--  -- HALT (none for now)
--  halt_n <= '1';
--  -- NMI (none for now)
--  nmi_n <= '1';
  
  process (clk, rst)
    variable hblank_r   : std_logic;
    variable hsync_cnt  : integer range 0 to 15;
    variable pal_i      : integer range 0 to 255;
  begin
    if rst = '1' then
      hblank_r := '0';
      hsync_cnt := 0;
    elsif rising_edge(clk) then
      if osc = '1' then
        vsync_s <= '0';   -- default
        case an is
          -- BACKGROUND
          when "000" =>
            pal_i := to_integer(unsigned(colbk_r));
            r_s <= palette(pal_i).r;
            g_s <= palette(pal_i).g;
            b_s <= palette(pal_i).b;
            hblank_r := '0';
          -- VSYNC
          when "001" =>
            vsync_s <= '1';
            r_s <= (others => '0');
            g_s <= (others => '0');
            b_s <= (others => '0');
            hblank_r := '0';
          -- HBLANK/HSYNC
          when "010" | "011" =>
            r_s <= (others => '0');
            g_s <= (others => '0');
            b_s <= (others => '0');
            if hblank_r = '0' then
              hsync_cnt := hsync_cnt'high;
            end if;
            if hsync_cnt > 0 then
              hsync_s <= '1';
              hsync_cnt := hsync_cnt - 1;
            else
              hsync_s <= '0';
            end if;
            hblank_r := '1';
          when others =>
            r_s <= (others => '0');
            g_s <= (others => '0');
            b_s <= (others => '0');
            hblank_r := '0';
        end case;
      end if; -- osc='1'
    end if;
  end process;

  BLK_DBLSCAN : block
    signal b_i    : std_logic;
    signal h_i    : unsigned(7 downto 0);
    signal h_o    : unsigned(7 downto 0);
    signal hs_w   : unsigned(7 downto 0);
    signal r0     : std_logic_vector(7 downto 0);
    signal g0     : std_logic_vector(7 downto 0);
    signal b0     : std_logic_vector(7 downto 0);
    signal r1     : std_logic_vector(7 downto 0);
    signal g1     : std_logic_vector(7 downto 0);
    signal b1     : std_logic_vector(7 downto 0);
  begin
    -- each scanline is 114*2 = 228 clks @~3.5Mhz = ~15kHz
    process (clk, rst)
      variable b        : std_logic;
      variable hsync_r  : std_logic;
    begin
      if rst = '1' then
        b_i <= '0';
        hsync_r := '0';
      elsif rising_edge(clk) then
        if osc = '1' then
          -- start of line - flip buffer
          if hsync_s = '1' and hsync_r = '0' then
            b_i <= not b_i;
            h_i <= to_unsigned(0,h_i'length);
            h_o <= to_unsigned(0,h_o'length);
          else
            h_i <= h_i + 1;
            -- save hsync width
            if hsync_s = '0' and hsync_r = '1' then
              hs_w <= h_i;
            end if;
          end if;
          hsync_r := hsync_s;
        end if;
        if clk_vga = '1' then
          -- end of line, restart buffer
          if h_o = 114*2-1 then
            h_o <= to_unsigned(0,h_o'length);
          else
            h_o <= h_o + 1;
          end if;
          -- generate hsync
          if h_o < hs_w then
            hsync <= '1';
          else
            hsync <= '0';
          end if;
        end if;
      end if;
    end process;
    vsync <= vsync_s;

    buf0 : entity work.dblscanbuf
      port map
      (
        clock		            => clk,
        wraddress		        => std_logic_vector(h_i(7 downto 0)),
        data(23 downto 16)  => r_s,
        data(15 downto 8)   => g_s,
        data(7 downto 0)    => b_s,
        wren		            => b_i,
        rdaddress		        => std_logic_vector(h_o(7 downto 0)),
        q(23 downto 16)     => r0,
        q(15 downto 8)      => g0,
        q(7 downto 0)       => b0
      );
  
    buf1 : entity work.dblscanbuf
      port map
      (
        clock		            => clk,
        wraddress		        => std_logic_vector(h_i(7 downto 0)),
        data(23 downto 16)  => r_s,
        data(15 downto 8)   => g_s,
        data(7 downto 0)    => b_s,
        wren		            => not b_i,
        rdaddress		        => std_logic_vector(h_o(7 downto 0)),
        q(23 downto 16)     => r1,
        q(15 downto 8)      => g1,
        q(7 downto 0)       => b1
      );

    r <= r0 when b_i = '0' else r1;
    g <= g0 when b_i = '0' else g1;
    b <= b0 when b_i = '0' else b1;
    
  end block BLK_DBLSCAN;
  
  BLK_DEBUG : block
  begin
  end block BLK_DEBUG;
  
end architecture SYN;

--
-- This module is based *heavily* on the fpga64_hexy.vhd module from:
--
-- FPGA64
-- Reconfigurable hardware based commodore64 emulator.
-- Copyright 2005-2008 Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.antic_pkg.all;

entity atari_gtia_hexy is
	generic 
	(
		yOffset : integer := 100;
		xOffset : integer := 100
	);
	port 
	(
		clk       : in std_logic;
		clk_ena   : in std_logic;
		vSync     : in std_logic;
		hSync     : in std_logic;
		video     : out std_logic;
		dim       : out std_logic;

    dbg       : in antic_dbg_t
	);
end entity atari_gtia_hexy;

architecture SYN of atari_gtia_hexy is
	signal oldV : std_logic;
	signal oldH : std_logic;
	
	signal vPos : integer range 0 to 1023;
	signal hPos : integer range 0 to 2047;
	
	signal localX : unsigned(8 downto 0);
	signal localX2 : unsigned(8 downto 0);
	signal localX3 : unsigned(8 downto 0);
	signal localY : unsigned(3 downto 0);
	signal runY : std_logic;
	signal runX : std_logic;
	
	signal cChar : unsigned(5 downto 0);
	signal pixels : unsigned(0 to 63);
	
begin
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			if hSync = '0' and oldH = '1' then
				hPos <= 0;
				vPos <= vPos + 1;
			else
				hPos <= hPos + 1;
			end if;
			if vSync = '0' and oldV = '1' then
				vPos <= 0;
			end if;				
			oldH <= hSync;
			oldV <= vSync;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			if hPos = xOffset then
				localX <= (others => '0');
				runX <= '1';
				if vPos = yOffset then
					localY <= (others => '0');
					runY <= '1';
				end if;
			elsif runX = '1' and localX = "111111111" then
				runX <= '0';
				if localY = "111" then
					runY <= '0';
				else	
					localY <= localY + 1;
				end if;									
			else				
				localX <= localX + 1;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			case localX(8 downto 3) is
--			when "000000" => cChar <= "001101"; -- D
--			when "000001" => cChar <= "010110"; -- M
--			when "000010" => cChar <= "001010"; -- A
--			when "000011" => cChar <= "111110"; -- :                  
--			when "000100" => cChar <= "00" & dbg.dmactl(7 downto 4); 
--			when "000101" => cChar <= "00" & dbg.dmactl(3 downto 0); 
--			when "000110" => cChar <= "111111"; --                   
--			when "000111" => cChar <= "001100"; -- C                
--			when "001000" => cChar <= "001100"; -- C                  
--			when "001001" => cChar <= "111110"; -- :                  
--			when "001010" => cChar <= "00" & dbg.chactl(3 downto 0); 
--			when "001011" => cChar <= "111111"; --                   
--			when "001100" => cChar <= "001101"; -- D                  
--			when "001101" => cChar <= "010101"; -- L                  
--			when "001110" => cChar <= "111110"; -- :                   
--			when "001111" => cChar <= "00" & dbg.dlisth(7 downto 4);   
--			when "010000" => cChar <= "00" & dbg.dlisth(3 downto 0);   
--			when "010001" => cChar <= "00" & dbg.dlistl(7 downto 4);  
--			when "010010" => cChar <= "00" & dbg.dlistl(3 downto 0);  
--			when "010011" => cChar <= "111111"; --                    
--			when "010100" => cChar <= "010001"; -- H                  
--			when "010101" => cChar <= "111110"; -- :                  
--			when "010110" => cChar <= "00" & dbg.hscrol(3 downto 0);  
--			when "010111" => cChar <= "111111"; --                    
--			when "011000" => cChar <= "011111"; -- V                  
--			when "011001" => cChar <= "111110"; -- :                 
--			when "011010" => cChar <= "00" & dbg.vscrol(3 downto 0);  
--			when "011011" => cChar <= "111111"; --                    
--			when "011100" => cChar <= "011001"; -- P                  
--			when "011101" => cChar <= "001011"; -- B                  
--			when "011110" => cChar <= "111110"; -- :                  
--			when "011111" => cChar <= "00" & dbg.pmbase(7 downto 4); 			  
--			when "100000" => cChar <= "00" & dbg.pmbase(3 downto 0);        
--			when "100001" => cChar <= "111111"; --                          
--			when "100010" => cChar <= "001100"; -- C                        
--			when "100011" => cChar <= "001011"; -- B                        
--			when "100100" => cChar <= "111110"; -- :                      
--			when "100101" => cChar <= "00" & dbg.chbase(7 downto 4);  
--			when "100110" => cChar <= "00" & dbg.chbase(3 downto 0);  
--			when "100111" => cChar <= "111111"; --                    
--			when "101000" => cChar <= "010111"; -- N                  
--			when "101001" => cChar <= "010110"; -- M
--			when "101010" => cChar <= "010010"; -- I
--			when "101011" => cChar <= "111110"; -- :                  
--			when "101100" => cChar <= "001110"; -- E
--			when "101101" => cChar <= "00" & dbg.nmien(7 downto 4);   
--			when "101110" => cChar <= "011100"; -- S                  
--			when "101111" => cChar <= "00" & dbg.nmist(3 downto 0);   
--			when "110000" => cChar <= "011011"; -- R                  
--			when "110001" => cChar <= "00" & dbg.nmires(3 downto 0);  
--			when "110010" => cChar <= "111111"; --                                                    
--			when "110011" => cChar <= "011111"; -- V                
--			when "110100" => cChar <= "001100"; -- C                
--			when "110101" => cChar <= "111110"; -- :                
--			when "110110" => cChar <= "00" & dbg.vcount(7 downto 4);
--			when "110111" => cChar <= "00" & dbg.vcount(3 downto 0);
--			when "111000" => cChar <= "111111"; --                  
			when others => cChar <= (others => '1');
			end case;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			localX2 <= localX;
			localX3 <= localX2;
			if (runY = '0')
			or (runX = '0') then
				pixels <= (others => '0');
			else
				case cChar is
				when "000000" => pixels <= X"3C666E7666663C00"; -- 0
				when "000001" => pixels <= X"1818381818187E00"; -- 1
				when "000010" => pixels <= X"3C66060C30607E00"; -- 2
				when "000011" => pixels <= X"3C66061C06663C00"; -- 3
				when "000100" => pixels <= X"060E1E667F060600"; -- 4
				when "000101" => pixels <= X"7E607C0606663C00"; -- 5
				when "000110" => pixels <= X"3C66607C66663C00"; -- 6
				when "000111" => pixels <= X"7E660C1818181800"; -- 7
				when "001000" => pixels <= X"3C66663C66663C00"; -- 8
				when "001001" => pixels <= X"3C66663E06663C00"; -- 9

				when "001010" => pixels <= X"183C667E66666600"; -- A
				when "001011" => pixels <= X"7C66667C66667C00"; -- B
				when "001100" => pixels <= X"3C66606060663C00"; -- C
				when "001101" => pixels <= X"786C6666666C7800"; -- D
				when "001110" => pixels <= X"7E60607860607E00"; -- E
				when "001111" => pixels <= X"7E60607860606000"; -- F
				when "010000" => pixels <= X"3C66606E66663C00"; -- G
				when "010001" => pixels <= X"6666667E66666600"; -- H
				when "010010" => pixels <= X"3C18181818183C00"; -- I
				when "010011" => pixels <= X"1E0C0C0C0C6C3800"; -- J
				when "010100" => pixels <= X"666C7870786C6600"; -- K
				when "010101" => pixels <= X"6060606060607E00"; -- L
				when "010110" => pixels <= X"63777F6B63636300"; -- M
				when "010111" => pixels <= X"66767E7E6E666600"; -- N
				when "011000" => pixels <= X"3C66666666663C00"; -- O
				when "011001" => pixels <= X"7C66667C60606000"; -- P
				when "011010" => pixels <= X"3C666666663C0E00"; -- Q
				when "011011" => pixels <= X"7C66667C786C6600"; -- R
				when "011100" => pixels <= X"3C66603C06663C00"; -- S
				when "011101" => pixels <= X"7E18181818181800"; -- T
				when "011110" => pixels <= X"6666666666663C00"; -- U
				when "011111" => pixels <= X"66666666663C1800"; -- V
				when "100000" => pixels <= X"6363636B7F776300"; -- W
				when "100001" => pixels <= X"66663C183C666600"; -- X
				when "100010" => pixels <= X"6666663C18181800"; -- Y
				when "100011" => pixels <= X"7E060C1830607E00"; -- Z
				when "111110" => pixels <= X"0000180000180000"; -- :
				when others   => pixels <= X"0000000000000000"; -- space
				end case;
			end if;
		end if;			
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			video <= pixels(to_integer(localY & localX3(2 downto 0)));
		end if;
	end process;
	
	dim <= runX and runY;
	
end architecture SYN;

