library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
--use work.maple_pkg.all;
--use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
		--////////////////////	Clock Input	 	////////////////////	 
		clock_27      : in std_logic;                         --	27 MHz
		clock_50      : in std_logic;                         --	50 MHz
		ext_clock     : in std_logic;                         --	External Clock
		--////////////////////	Push Button		////////////////////
		key           : in std_logic_vector(3 downto 0);      --	Pushbutton[3:0]
		--////////////////////	DPDT Switch		////////////////////
		sw            : in std_logic_vector(17 downto 0);     --	Toggle Switch[17:0]
		--////////////////////	7-SEG Dispaly	////////////////////
		hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
		hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
		hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
		hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
		hex4          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 4
		hex5          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 5
		hex6          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 6
		hex7          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 7
		--////////////////////////	LED		////////////////////////
		ledg          : out std_logic_vector(8 downto 0);     --	LED Green[8:0]
		ledr          : out std_logic_vector(17 downto 0);    --	LED Red[17:0]
		--////////////////////////	UART	////////////////////////
		uart_txd      : out std_logic;                        --	UART Transmitter
		uart_rxd      : in std_logic;                         --	UART Receiver
		--////////////////////////	IRDA	////////////////////////
		irda_txd      : out std_logic;                        --	IRDA Transmitter
		irda_rxd      : in std_logic;                         --	IRDA Receiver
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
		--////////////////////	ISP1362 Interface	////////////////
		otg_data      : inout std_logic_vector(15 downto 0);  --	ISP1362 Data bus 16 Bits
		otg_addr      : out std_logic_vector(1 downto 0);     --	ISP1362 Address 2 Bits
		otg_cs_n      : out std_logic;                        --	ISP1362 Chip Select
		otg_rd_n      : out std_logic;                        --	ISP1362 Write
		otg_wr_n      : out std_logic;                        --	ISP1362 Read
		otg_rst_n     : out std_logic;                        --	ISP1362 Reset
		otg_fspeed    : out std_logic;                        --	USB Full Speed,	0 = Enable, Z = Disable
		otg_lspeed    : out std_logic;                        --	USB Low Speed, 	0 = Enable, Z = Disable
		otg_int0 			: in std_logic;                         --	ISP1362 Interrupt 0
		otg_int1 			: in std_logic;                         --	ISP1362 Interrupt 1
		otg_dreq0 		: in std_logic;                         --	ISP1362 DMA Request 0
		otg_dreq1 		: in std_logic;                         --	ISP1362 DMA Request 1
		otg_dack0_n   : out std_logic;                        --	ISP1362 DMA Acknowledge 0
		otg_dack1_n   : out std_logic;                        --	ISP1362 DMA Acknowledge 1
		--////////////////////	LCD Module 16X2		////////////////
		lcd_data      : inout std_logic_vector(7 downto 0);   --	LCD Data bus 8 bits
		lcd_on        : out std_logic;                        --	LCD Power ON/OFF
		lcd_blon      : out std_logic;                        --	LCD Back Light ON/OFF
		lcd_rw        : out std_logic;                        --	LCD Read/Write Select, 0 = Write, 1 = Read
		lcd_en        : out std_logic;                        --	LCD Enable
		lcd_rs        : out std_logic;                        --	LCD Command/Data Select, 0 = Command, 1 = Data
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
		vga_r         : out std_logic_vector(9 downto 0);     --	VGA Red[9:0]
		vga_g         : out std_logic_vector(9 downto 0);     --	VGA Green[9:0]
		vga_b         : out std_logic_vector(9 downto 0);     --	VGA Blue[9:0]
		--////////////	Ethernet Interface	////////////////////////
		enet_data     : inout std_logic_vector(15 downto 0);  --	DM9000A DATA bus 16Bits
		enet_cmd      : out std_logic;                        --	DM9000A Command/Data Select, 0 = Command, 1 = Data
		enet_cs_n     : out std_logic;                        --	DM9000A Chip Select
		enet_wr_n     : out std_logic;                        --	DM9000A Write
		enet_rd_n     : out std_logic;                        --	DM9000A Read
		enet_rst_n    : out std_logic;                        --	DM9000A Reset
		enet_int      : in std_logic;                         --	DM9000A Interrupt
		enet_clk      : out std_logic;                        --	DM9000A Clock 25 MHz
		--////////////////	Audio CODEC		////////////////////////
		aud_adclrck   : out std_logic;                        --	Audio CODEC ADC LR Clock
		aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
		aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
		aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
		aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
		aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
		--////////////////	TV Decoder		////////////////////////
		td_data       : in std_logic_vector(7 downto 0);      --	TV Decoder Data bus 8 bits
		td_hs         : in std_logic;                         --	TV Decoder H_SYNC
		td_vs         : in std_logic;                         --	TV Decoder V_SYNC
		td_reset      : out std_logic;                        --	TV Decoder Reset
		--////////////////////	GPIO	////////////////////////////
		gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
		gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
  );

end target_top;

architecture SYN of target_top is

  component de1_top is
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
  end component de1_top;

	alias gpio_maple 		: std_logic_vector(35 downto 0) is gpio_0;
	alias gpio_lcd 			: std_logic_vector(35 downto 0) is gpio_1;
	
begin

  de1_top_inst : de1_top
    port map
    (
      --////////////////////	Clock Input	 	////////////////////	 
      clock_27(1)   => clock_27,
      clock_27(0)   => clock_27,
      clock_50      => clock_50,
      ext_clock     => '0',     -- not supported
      --////////////////////	Push Button		////////////////////
      key           => key,
      --////////////////////	DPDT Switch		////////////////////
      sw            => sw(9 downto 0),
      --////////////////////	7-SEG Dispaly	////////////////////
      hex0          => hex0,
      hex1          => hex1,
      hex2          => hex2,
      hex3          => hex3,
      --////////////////////////	LED		////////////////////////
      ledg          => ledg(7 downto 0),
      ledr          => ledr(9 downto 0),
      --////////////////////////	UART	////////////////////////
      uart_txd      => uart_txd,
      uart_rxd      => uart_rxd,
      --////////////////////////	IRDA	////////////////////////
      -- irda_txd      : out std_logic;                        --	IRDA Transmitter
      -- irda_rxd      : in std_logic;                         --	IRDA Receiver
      --/////////////////////	SDRAM Interface		////////////////
      dram_dq       => dram_dq,
      dram_addr     => dram_addr,
      dram_ldqm     => dram_ldqm,
      dram_udqm     => dram_udqm,
      dram_we_n     => dram_we_n,
      dram_cas_n    => dram_cas_n,
      dram_ras_n    => dram_ras_n,
      dram_cs_n     => dram_cs_n,
      dram_ba_0     => dram_ba_0,
      dram_ba_1     => dram_ba_1,
      dram_clk      => dram_clk,
      dram_cke      => dram_cke,
      --////////////////////	Flash Interface		////////////////
      fl_dq         => fl_dq,
      fl_addr       => fl_addr,
      fl_we_n       => fl_we_n,
      fl_rst_n      => fl_rst_n,
      fl_oe_n       => fl_oe_n,
      fl_ce_n       => fl_ce_n,
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
      vga_clk       => vga_clk,
      vga_hs        => vga_hs,
      vga_vs        => vga_vs,
      vga_blank     => vga_blank,
      vga_sync      => vga_sync,
      vga_r         => vga_r(9 downto 6),
      vga_g         => vga_g(9 downto 6),
      vga_b         => vga_b(9 downto 6),
      --////////////////	Audio CODEC		////////////////////////
      aud_adclrck   => aud_adclrck,
      aud_adcdat    => aud_adcdat,
      aud_daclrck   => aud_daclrck,
      aud_dacdat    => aud_dacdat,
      aud_bclk      => aud_bclk,
      aud_xck       => aud_xck,
      --////////////////////	GPIO	////////////////////////////
      gpio_0        => gpio_0,
      gpio_1        => gpio_1
    );

    vga_r(5 downto 0) <= (others => '0');
    vga_g(5 downto 0) <= (others => '0');
    vga_b(5 downto 0) <= (others => '0');

end SYN;

