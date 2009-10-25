library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_rom is
  port
  (
    clock     : in std_logic;
    address   : in std_logic_vector(13 downto 0);
    q         : out std_logic_vector(7 downto 0)
  );
end entity galaxian_rom;

architecture SYN of galaxian_rom is
  component xilinx_galaxian_rom is
    port
    (
      clk     : in std_logic;
      addr    : in std_logic_vector(13 downto 0);
      dout    : out std_logic_vector(7 downto 0)
    );
  end component xilinx_galaxian_rom;
begin
  rom_inst : xilinx_galaxian_rom
    port map
    (
      clk     => clock,
      addr    => address,
      dout    => q
    );
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity galaxian_vram is
  port
  (
    clock_b     : in std_logic;
    address_b   : in std_logic_vector(9 downto 0);
    wren_b      : in std_logic;
    data_b      : in std_logic_vector(7 downto 0);
    q_b         : out std_logic_vector(7 downto 0);
    
    clock_a     : in std_logic;
    address_a   : in std_logic_vector(9 downto 0);
    wren_a      : in std_logic;
    data_a      : in std_logic_vector(7 downto 0);
    q_a         : out std_logic_vector(7 downto 0)
  );
end entity galaxian_vram;
 
architecture SYN of galaxian_vram is
begin
   -- RAMB16_S9_S9: Virtex-II/II-Pro, Spartan-3/3E 2k x 8 + 1 Parity bit Dual-Port RAM
   -- Xilinx  HDL Language Template version 8.2.2i

   RAMB16_S9_S9_inst : RAMB16_S9_S9
   generic map (
      INIT_A => X"000", --  Value of output RAM registers on Port A at startup
      INIT_B => X"000", --  Value of output RAM registers on Port B at startup
      SRVAL_A => X"000", --  Port A ouput value upon SSR assertion
      SRVAL_B => X"000", --  Port B ouput value upon SSR assertion
      WRITE_MODE_A => "WRITE_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      WRITE_MODE_B => "WRITE_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      SIM_COLLISION_CHECK => "ALL", -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 511
      INIT_00 => X"1010101010101010101010101010101010101010101010101010101010101010",
      INIT_01 => X"1010101010101010101010101010101010101010101010101010101010101010",
      INIT_02 => X"101010101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_03 => X"6D6C10101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_04 => X"101010101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_05 => X"101010101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_06 => X"10101010101010101010101010101010101010352D2C2C2D2C2C2D2C10101010",
      INIT_07 => X"10101010101010101010101010101010101010372F2E2E2F2E2E2F2E10101010",
      INIT_08 => X"101010101010101010101010101010101010104145444145442C2D2C10101010",
      INIT_09 => X"101010101010101010101010101010101010104347464347462E2F2E10101010",
      INIT_0A => X"10101010101010101010101010101010101010313D3C313D3C312D2C10101010",
      INIT_0B => X"10101010101010101010104010101010101010333F3E333F3E332F2E10101015",
      INIT_0C => X"1010101010101010101010401010101010101041454441454441A5A410101022",
      INIT_0D => X"1010101010101010101010401010101010101043474643474643A7A61010901F",
      INIT_0E => X"10104040404010101010104010101010101010353938353938352D2C10109013",
      INIT_0F => X"10106160404010101010104010101010101010373B3A373B3A372F2E10101023",
      -- Address 512 to 1023
      INIT_10 => X"10106362404010101010104010101010101010414544414544412D2C10101010",
      INIT_11 => X"10104040404010101010104010101010101010434746434746432F2E10101018",
      INIT_12 => X"10101010101010101010104010101010101010313D3C313D3C31A5A410101017",
      INIT_13 => X"2D2C1010101010101010104010101010101010333F3E333F3E33A7A610101019",
      INIT_14 => X"2F2E1010101010101010104010101010101010414544414544412D2C10101018",
      INIT_15 => X"2D2C1010101010101010101010101010101010434746434746432F2E10101010",
      INIT_16 => X"2F2E10101010101010101010101010101010103539383539382C2D2C10101010",
      INIT_17 => X"2D2C1010101010101010101010101010101010373B3A373B3A2E2F2E10109010",
      INIT_18 => X"2F2E1010101010101010101010101010101010414544412D2C2C2D2C10109020",
      INIT_19 => X"65641010101010101010101010101010101010434746432F2E2E2F2E10101025",
      INIT_1A => X"676610101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101001",
      INIT_1B => X"656410101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_1C => X"676610101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_1D => X"101010101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_1E => X"101010101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_1F => X"101010101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      -- Address 1024 to 1535
      INIT_20 => X"1010101010101010101010101010101010101010101010101010101010101010",
      INIT_21 => X"1010101010101010101010101010101010101010101010101010101010101010",
      INIT_22 => X"101010101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_23 => X"6D6C10101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_24 => X"101010101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_25 => X"101010101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_26 => X"10101010101010101010101010101010101010352D2C2C2D2C2C2D2C10101010",
      INIT_27 => X"10101010101010101010101010101010101010372F2E2E2F2E2E2F2E10101010",
      INIT_28 => X"101010101010101010101010101010101010104145444145442C2D2C10101010",
      INIT_29 => X"101010101010101010101010101010101010104347464347462E2F2E10101010",
      INIT_2A => X"10101010101010101010101010101010101010313D3C313D3C312D2C10101010",
      INIT_2B => X"10101010101010101010104010101010101010333F3E333F3E332F2E10101015",
      INIT_2C => X"1010101010101010101010401010101010101041454441454441A5A410101022",
      INIT_2D => X"1010101010101010101010401010101010101043474643474643A7A61010901F",
      INIT_2E => X"10104040404010101010104010101010101010353938353938352D2C10109013",
      INIT_2F => X"10106160404010101010104010101010101010373B3A373B3A372F2E10101023",
      -- Address 1536 to 2047
      INIT_30 => X"10106362404010101010104010101010101010414544414544412D2C10101010",
      INIT_31 => X"10104040404010101010104010101010101010434746434746432F2E10101018",
      INIT_32 => X"10101010101010101010104010101010101010313D3C313D3C31A5A410101017",
      INIT_33 => X"2D2C1010101010101010104010101010101010333F3E333F3E33A7A610101019",
      INIT_34 => X"2F2E1010101010101010104010101010101010414544414544412D2C10101018",
      INIT_35 => X"2D2C1010101010101010101010101010101010434746434746432F2E10101010",
      INIT_36 => X"2F2E10101010101010101010101010101010103539383539382C2D2C10101010",
      INIT_37 => X"2D2C1010101010101010101010101010101010373B3A373B3A2E2F2E10109010",
      INIT_38 => X"2F2E1010101010101010101010101010101010414544412D2C2C2D2C10109020",
      INIT_39 => X"65641010101010101010101010101010101010434746432F2E2E2F2E10101025",
      INIT_3A => X"676610101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101001",
      INIT_3B => X"656410101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_3C => X"676610101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_3D => X"101010101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      INIT_3E => X"101010101010101010101010101010101010102C2D2C2C2D2C2C2D2C10101010",
      INIT_3F => X"101010101010101010101010101010101010102E2F2E2E2F2E2E2F2E10101010",
      -- The next set of INITP_xx are for the parity bits
      -- Address 0 to 511
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 512 to 1023
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1024 to 1535
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1536 to 2047
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DOA => q_a,      -- Port A 8-bit Data Output
      DOB => q_b,      -- Port B 8-bit Data Output
      DOPA => open,    -- Port A 1-bit Parity Output
      DOPB => open,    -- Port B 1-bit Parity Output
      ADDRA(10) => '0',  -- Port A 11-bit Address Input
      ADDRA(9 downto 0) => address_a,  -- Port A 11-bit Address Input
      ADDRB(10) => '0',  -- Port B 11-bit Address Input
      ADDRB(9 downto 0) => address_b,  -- Port B 11-bit Address Input
      CLKA => clock_a,    -- Port A Clock
      CLKB => clock_b,    -- Port B Clock
      DIA => data_a,      -- Port A 8-bit Data Input
      DIB => data_b,      -- Port B 8-bit Data Input
      DIPA => "0",    -- Port A 1-bit parity Input
      DIPB => "0",    -- Port-B 1-bit parity Input
      ENA => '1',      -- Port A RAM Enable Input
      ENB => '1',      -- PortB RAM Enable Input
      SSRA => '0',    -- Port A Synchronous Set/Reset Input
      SSRB => '0',    -- Port B Synchronous Set/Reset Input
      WEA => wren_a,      -- Port A Write Enable Input
      WEB => wren_b       -- Port B Write Enable Input
   );
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity galaxian_cram is
  port
  (
    clock_b     : in std_logic;
    address_b   : in std_logic_vector(7 downto 1);
    wren_b      : in std_logic;
    data_b      : in std_logic_vector(7 downto 0);
    q_b         : out std_logic_vector(7 downto 0);
    
    clock_a     : in std_logic;
    address_a   : in std_logic_vector(7 downto 1);
    wren_a      : in std_logic;
    data_a      : in std_logic_vector(7 downto 0);
    q_a         : out std_logic_vector(7 downto 0)
  );
end entity galaxian_cram;

architecture SYN of galaxian_cram is
begin
	--cram_inst : entity work.dpram
  GEN_CRAM : for i in 0 to 7 generate
    RAM128X1D_inst : RAM128X1D
    generic map 
    (
      INIT => X"00000000000000000000000000000000")
    port map 
    (
      DPRA    => address_a,
      SPO     => q_a(i),

      WCLK    => clock_b,
      A       => address_b,
      WE      => wren_b,
      D       => data_b(i),
      DPO     => q_b(i)
    );
  end generate GEN_CRAM;
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_gfxrom is
  port
  (
    clock       : in std_logic;
    address_a   : in std_logic_vector(11 downto 0);
    q_a         : out std_logic_vector(7 downto 0);
    
    address_b   : in std_logic_vector(9 downto 0);
    q_b         : out std_logic_vector(31 downto 0)
  );
end entity galaxian_gfxrom;

architecture SYN of galaxian_gfxrom is
  component xilinx_galaxian_gfx_rom is
    port 
    (
      addra: IN std_logic_VECTOR(11 downto 0);
      addrb: IN std_logic_VECTOR(9 downto 0);
      clka: IN std_logic;
      clkb: IN std_logic;
      douta: OUT std_logic_VECTOR(7 downto 0);
      doutb: OUT std_logic_VECTOR(31 downto 0)
    );
  end component xilinx_galaxian_gfx_rom;
begin
  gfxrom_inst : xilinx_galaxian_gfx_rom
    port map
    (
      clka    => clock,
      addra   => address_a,
      douta   => q_a,

      clkb    => clock,
      addrb   => address_b,
      doutb   => q_b
    );
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_wram is
  port
  (
    clock     : in std_logic;
    address   : in std_logic_vector(10 downto 0);
    data      : in std_logic_vector(7 downto 0);
    wren      : in std_logic;
    q         : out std_logic_vector(7 downto 0)
  );
end entity galaxian_wram;

architecture SYN of galaxian_wram is
begin
  --wram_inst : entity work.spram
end architecture SYN;
