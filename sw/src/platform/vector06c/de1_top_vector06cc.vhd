library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
--use work.gamecube_pkg.all;
use work.project_pkg.all;
--use work.platform_pkg.all;
use work.target_pkg.all;

entity de1_top is
  port
  (
    --////////////////////	Clock Input	 	////////////////////	 
    clock_27      : in std_logic_vector(1 downto 0);      --	27 MHz
    clock_50      : in std_logic;                         --	50 MHz
    ext_clock     : in std_logic;                         --	External Clock
    --////////////////////	Push Button		////////////////////
    key           : in std_logic_vector(3 downto 0);      --	Pushbutton[3:0]
    --////////////////////	DPDT Switch		////////////////////
    sw            : in std_logic_vector(9 downto 0);     --	Toggle Switch[9:0]
    --////////////////////	7-SEG Dispaly	////////////////////
    hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
    hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
    hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
    hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
    --////////////////////////	LED		////////////////////////
    ledg          : out std_logic_vector(7 downto 0);     --	LED Green[8:0]
    ledr          : out std_logic_vector(9 downto 0);    --	LED Red[17:0]
    --////////////////////////	UART	////////////////////////
    uart_txd      : out std_logic;                        --	UART Transmitter
    uart_rxd      : in std_logic;                         --	UART Receiver
    --////////////////////////	IRDA	////////////////////////
    -- irda_txd      : out std_logic;                        --	IRDA Transmitter
    -- irda_rxd      : in std_logic;                         --	IRDA Receiver
    --/////////////////////	SDRAM Interface		////////////////
    dram_dq       : inout std_logic_vector(15 downto 0);  --	SDRAM Data bus 16 Bits
    dram_addr     : out std_logic_vector(11 downto 0);    --	SDRAM Address bus 12 Bits
    dram_ldqm     : out std_logic;                        --	SDRAM Low-byte Data Mask 
    dram_udqm     : out std_logic;                        --	SDRAM High-byte Data Mask
    dram_we_n     : out std_logic;                        --	SDRAM Write Enable
    dram_cas_n    : out std_logic;                        --	SDRAM Column Address Strobe
    dram_ras_n    : out std_logic;                        --	SDRAM Row Address Strobe
    dram_cs_n     : out std_logic;                        --	SDRAM Chip Select
    dram_ba_0     : out std_logic;                        --	SDRAM Bank Address 0
    dram_ba_1     : out std_logic;                        --	SDRAM Bank Address 0
    dram_clk      : out std_logic;                        --	SDRAM Clock
    dram_cke      : out std_logic;                        --	SDRAM Clock Enable
    --////////////////////	Flash Interface		////////////////
    fl_dq         : inout std_logic_vector(7 downto 0);   --	FLASH Data bus 8 Bits
    fl_addr       : out std_logic_vector(21 downto 0);    --	FLASH Address bus 22 Bits
    fl_we_n       : out std_logic;                        -- 	FLASH Write Enable
    fl_rst_n      : out std_logic;                        --	FLASH Reset
    fl_oe_n       : out std_logic;                        --	FLASH Output Enable
    fl_ce_n       : out std_logic;                        --	FLASH Chip Enable
    --////////////////////	SRAM Interface		////////////////
    sram_dq       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
    sram_addr     : out std_logic_vector(17 downto 0);    --	SRAM Address bus 18 Bits
    sram_ub_n     : out std_logic;                        --	SRAM High-byte Data Mask 
    sram_lb_n     : out std_logic;                        --	SRAM Low-byte Data Mask 
    sram_we_n     : out std_logic;                        --	SRAM Write Enable
    sram_ce_n     : out std_logic;                        --	SRAM Chip Enable
    sram_oe_n     : out std_logic;                        --	SRAM Output Enable
    --////////////////////	SD_Card Interface	////////////////
    sd_dat        : inout std_logic;                      --	SD Card Data
    sd_dat3       : inout std_logic;                      --	SD Card Data 3
    sd_cmd        : inout std_logic;                      --	SD Card Command Signal
    sd_clk        : out std_logic;                        --	SD Card Clock
    --////////////////////	USB JTAG link	////////////////////
    tdi           : in std_logic;                         -- CPLD -> FPGA (data in)
    tck           : in std_logic;                         -- CPLD -> FPGA (clk)
    tcs           : in std_logic;                         -- CPLD -> FPGA (CS)
      tdo           : out std_logic;                        -- FPGA -> CPLD (data out)
    --////////////////////	I2C		////////////////////////////
    i2c_sdat      : inout std_logic;                      --	I2C Data
    i2c_sclk      : out std_logic;                        --	I2C Clock
    --////////////////////	PS2		////////////////////////////
    ps2_dat       : in std_logic;                         --	PS2 Data
    ps2_clk       : in std_logic;                         --	PS2 Clock
    --////////////////////	VGA		////////////////////////////
    vga_clk       : out std_logic;                        --	VGA Clock
    vga_hs        : out std_logic;                        --	VGA H_SYNC
    vga_vs        : out std_logic;                        --	VGA V_SYNC
    vga_blank     : out std_logic;                        --	VGA BLANK
    vga_sync      : out std_logic;                        --	VGA SYNC
    vga_r         : out std_logic_vector(3 downto 0);     --	VGA Red[3:0]
    vga_g         : out std_logic_vector(3 downto 0);     --	VGA Green[3:0]
    vga_b         : out std_logic_vector(3 downto 0);     --	VGA Blue[3:0]
    --////////////////	Audio CODEC		////////////////////////
    aud_adclrck   : out std_logic;                        --	Audio CODEC ADC LR Clock
    aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
    aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
    aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
    aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
    aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
    --////////////////////	GPIO	////////////////////////////
    gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
    gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
  );
end entity de1_top;

architecture SYN of de1_top is

  component vector06cc is
    port
    (
      --////////////////////	Clock Input	 	////////////////////	 
      CLOCK_27      : in std_logic_vector(1 downto 0);      --	27 MHz
      clk50mhz      : in std_logic;                         --	50 MHz
      --////////////////////	Push Button		////////////////////
      key           : in std_logic_vector(3 downto 0);      --	Pushbutton[3:0]
      --////////////////////	DPDT Switch		////////////////////
      sw            : in std_logic_vector(9 downto 0);     --	Toggle Switch[9:0]
      --////////////////////	7-SEG Dispaly	////////////////////
      hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
      hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
      hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
      hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
      --////////////////////////	LED		////////////////////////
      ledg          : out std_logic_vector(7 downto 0);     --	LED Green[8:0]
      ledr          : out std_logic_vector(9 downto 0);    --	LED Red[17:0]
      --////////////////////////	UART	////////////////////////
      uart_txd      : out std_logic;                        --	UART Transmitter
      uart_rxd      : in std_logic;                         --	UART Receiver
      --////////////////////////	IRDA	////////////////////////
      -- irda_txd      : out std_logic;                        --	IRDA Transmitter
      -- irda_rxd      : in std_logic;                         --	IRDA Receiver
      --////////////////////	SRAM Interface		////////////////
      sram_dq       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
      sram_addr     : out std_logic_vector(17 downto 0);    --	SRAM Address bus 18 Bits
      sram_ub_n     : out std_logic;                        --	SRAM High-byte Data Mask 
      sram_lb_n     : out std_logic;                        --	SRAM Low-byte Data Mask 
      sram_we_n     : out std_logic;                        --	SRAM Write Enable
      sram_ce_n     : out std_logic;                        --	SRAM Chip Enable
      sram_oe_n     : out std_logic;                        --	SRAM Output Enable
      --////////////////////	SD_Card Interface	////////////////
      sd_dat        : inout std_logic;                      --	SD Card Data
      sd_dat3       : inout std_logic;                      --	SD Card Data 3
      sd_cmd        : inout std_logic;                      --	SD Card Command Signal
      sd_clk        : out std_logic;                        --	SD Card Clock
      --////////////////////	USB JTAG link	////////////////////
      tdi           : in std_logic;                         -- CPLD -> FPGA (data in)
      tck           : in std_logic;                         -- CPLD -> FPGA (clk)
      tcs           : in std_logic;                         -- CPLD -> FPGA (CS)
        tdo           : out std_logic;                        -- FPGA -> CPLD (data out)
      --////////////////////	I2C		////////////////////////////
      i2c_sdat      : inout std_logic;                      --	I2C Data
      i2c_sclk      : out std_logic;                        --	I2C Clock
      --////////////////////	PS2		////////////////////////////
      ps2_dat       : in std_logic;                         --	PS2 Data
      ps2_clk       : in std_logic;                         --	PS2 Clock
      --////////////////////	VGA		////////////////////////////
      vga_hs        : out std_logic;                        --	VGA H_SYNC
      vga_vs        : out std_logic;                        --	VGA V_SYNC
      vga_r         : out std_logic_vector(3 downto 0);     --	VGA Red[3:0]
      vga_g         : out std_logic_vector(3 downto 0);     --	VGA Green[3:0]
      vga_b         : out std_logic_vector(3 downto 0);     --	VGA Blue[3:0]
      --////////////////	Audio CODEC		////////////////////////
      aud_adclrck   : out std_logic;                        --	Audio CODEC ADC LR Clock
      aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
      aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
      aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
      aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
      aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
      --////////////////////	GPIO	////////////////////////////
      gpio_0        : inout std_logic_vector(12 downto 0)  --	GPIO Connection 0
    );
  end component vector06cc;

begin

  vector06cc_inst : vector06cc
    port map
    (
      --////////////////////	Clock Input	 	////////////////////	 
      CLOCK_27      => clock_27,
      clk50mhz      => clock_50,
      --////////////////////	Push Button		////////////////////
      key           => "1111",
      --////////////////////	DPDT Switch		////////////////////
      sw            => "1100000000",
      --////////////////////	7-SEG Dispaly	////////////////////
      hex0          => hex0,
      hex1          => hex1,
      hex2          => hex2,
      hex3          => hex3,
      --////////////////////////	LED		////////////////////////
      ledg          => ledg,
      ledr          => ledr,
      --////////////////////////	UART	////////////////////////
      uart_txd      => uart_txd,
      uart_rxd      => uart_rxd,
      --////////////////////////	IRDA	////////////////////////
      -- irda_txd      : out std_logic;                        --	IRDA Transmitter
      -- irda_rxd      : in std_logic;                         --	IRDA Receiver
      --////////////////////	SRAM Interface		////////////////
      sram_dq       => sram_dq,
      sram_addr     => sram_addr,
      sram_ub_n     => sram_ub_n,
      sram_lb_n     => sram_lb_n,
      sram_we_n     => sram_we_n,
      sram_ce_n     => sram_ce_n,
      sram_oe_n     => sram_oe_n,
      --////////////////////	SD_Card Interface	////////////////
      sd_dat        => sd_dat,
      sd_dat3       => sd_dat3,
      sd_cmd        => sd_cmd,
      sd_clk        => sd_clk,
      --////////////////////	USB JTAG link	////////////////////
      tdi           => tdi,
      tck           => tck,
      tcs           => tcs,
      tdo           => tdo,
      --////////////////////	I2C		////////////////////////////
      i2c_sdat      => i2c_sdat,
      i2c_sclk      => i2c_sclk,
      --////////////////////	PS2		////////////////////////////
      ps2_dat       => ps2_dat,
      ps2_clk       => ps2_clk,
      --////////////////////	VGA		////////////////////////////
      vga_hs        => vga_hs,
      vga_vs        => vga_vs,
      vga_r         => vga_r,
      vga_g         => vga_g,
      vga_b         => vga_b,
      --////////////////	Audio CODEC		////////////////////////
      aud_adclrck   => aud_adclrck,
      aud_adcdat    => aud_adcdat,
      aud_daclrck   => aud_daclrck,
      aud_dacdat    => aud_dacdat,
      aud_bclk      => aud_bclk,
      aud_xck       => aud_xck,
      --////////////////////	GPIO	////////////////////////////
      gpio_0        => gpio_0(12 downto 0)
    );

  vga_blank <= '0';
  vga_clk <= '0';
  vga_sync <= '0';

  --/////////////////////	SDRAM Interface		////////////////
  --dram_dq       => dram_dq,
  dram_addr     <= (others => '0');
  dram_ldqm     <= '0';
  dram_udqm     <= '0';
  dram_we_n     <= '1';
  dram_cas_n    <= '1';
  dram_ras_n    <= '1';
  dram_cs_n     <= '1';
  dram_ba_0     <= '0';
  dram_ba_1     <= '0';
  dram_clk      <= '0';
  dram_cke      <= '0';

  --////////////////////	Flash Interface		////////////////
  --fl_dq         => fl_dq,
  fl_addr       <= (others => '0');
  fl_we_n       <= '1';
  fl_rst_n      <= '1';
  fl_oe_n       <= '1';
  fl_ce_n       <= '1';

end SYN;
