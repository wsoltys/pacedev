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

  component MMC_start_DE1_TOP is
    port
    (
       --////////////////////	Clock Input	 	////////////////////	 
       CLOCK_24         : in std_logic_vector(1 downto 0);
       CLOCK_27         : in std_logic_vector(1 downto 0);
       CLOCK_50         : in std_logic;
       EXT_CLOCK        : in std_logic;
       --////////////////////	Push Button		////////////////////
       KEY              : in std_logic_vector(3 downto 0);
       --////////////////////	DPDT Switch		////////////////////
       SW               : in std_logic_vector(9 downto 0);
       --////////////////////	7-SEG Dispaly	////////////////////
       HEX0             : out std_logic_vector(6 downto 0);
       HEX1             : out std_logic_vector(6 downto 0);
       HEX2             : out std_logic_vector(6 downto 0);
       HEX3             : out std_logic_vector(6 downto 0);
       --////////////////////////	LED		///////////////////////
       LEDG             : out std_logic_vector(7 downto 0);
       LEDR             : out std_logic_vector(9 downto 0);
       --////////////////////////	UART	////////////////////////
       UART_TXD         : out std_logic;
       UART_RXD         : in std_logic;
       --/////////////////////	SDRAM Interface		////////////////
       DRAM_DQ          : inout std_logic_vector(15 downto 0);
       DRAM_ADDR        : out std_logic_vector(11 downto 0);
       DRAM_LDQM        : out std_logic;
       DRAM_UDQM        : out std_logic;
       DRAM_WE_N        : out std_logic;
       DRAM_CAS_N       : out std_logic;
       DRAM_RAS_N       : out std_logic;
       DRAM_CS_N        : out std_logic;
       DRAM_BA_0        : out std_logic;
       DRAM_BA_1        : out std_logic;
       DRAM_CLK         : out std_logic;
       DRAM_CKE         : out std_logic;
       --////////////////////	Flash Interface		////////////////
       FL_DQ            : inout std_logic_vector(7 downto 0);
       FL_ADDR          : out std_logic_vector(21 downto 0);
       FL_WE_N          : out std_logic;
       FL_RST_N         : out std_logic;
       FL_OE_N          : out std_logic;
       FL_CE_N          : out std_logic;
       --////////////////////	SRAM Interface		////////////////
       SRAM_DQ          : inout std_logic_vector(15 downto 0);
       SRAM_ADDR        : out std_logic_vector(17 downto 0);
       SRAM_UB_N        : out std_logic;
       SRAM_LB_N        : out std_logic;
       SRAM_WE_N        : out std_logic;
       SRAM_CE_N        : out std_logic;
       SRAM_OE_N        : out std_logic;
       --////////////////////	SD_Card Interface	////////////////
       SD_DAT           : inout std_logic;
       SD_DAT3          : inout std_logic;
       SD_CMD           : inout std_logic;
       SD_CLK           : out std_logic;
       --////////////////////	USB JTAG link	////////////////////
       TDI              : in std_logic;
       TCK              : in std_logic;
       TCS              : in std_logic;
       TDO              : out std_logic;
       --////////////////////	I2C		////////////////////////////
       I2C_SDAT         : inout std_logic;
       I2C_SCLK         : out std_logic;
       --////////////////////	PS2		////////////////////////////
       PS2_DAT          : in std_logic;
       PS2_CLK          : in std_logic;
       --////////////////////	VGA		////////////////////////////
       VGA_HS           : out std_logic;
       VGA_VS           : out std_logic;
       VGA_R            : out std_logic_vector(3 downto 0);
       VGA_G            : out std_logic_vector(3 downto 0);
       VGA_B            : out std_logic_vector(3 downto 0);
       --////////////////	Audio CODEC		////////////////////////
       AUD_ADCLRCK      : inout std_logic;
       AUD_ADCDAT       : in std_logic;
       AUD_DACLRCK      : inout std_logic;
       AUD_DACDAT       : out std_logic;
       AUD_BCLK         : inout std_logic;
       AUD_XCK          : out std_logic;
       --////////////////////	GPIO	////////////////////////////
       GPIO_0           : inout std_logic_vector(35 downto 0);
       GPIO_1           : inout std_logic_vector(35 downto 0)
    );
  end component MMC_start_DE1_TOP;

  signal init         : std_logic;
  signal reset        : std_logic;

  signal key_s        : std_logic_vector(3 downto 0);
  signal switch_s     : std_logic_vector(9 downto 0);
  signal fl_dq_s      : std_logic_vector(7 downto 0);
  signal fl_addr_s    : std_logic_vector(21 downto 0);
  signal fl_oe_n_s    : std_logic;
  signal fl_ce_n_s    : std_logic;
  signal gpio_1_s     : std_logic_vector(35 downto 0);

begin

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock_27(0))
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clock_27(0)) then
			if count = X"FF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

	-- the dipswitch must be "down" for the board to run
	-- this is akin to an "ON" switch flicked down to turn on
	reset <= init or sw(0);
		
  -- keys (pusbuttons) are active LOW on the DE1/2
  --key_s <= not reset & "11" & not reset; -- control (6502 &) system reset
  key_s <= not reset & "11" & not init; -- control 6502 reset
  -- switches are active HIGH on the DE1/2
  -- SW1 must be in the 'ON' position for MMC support
  switch_s <= "00000000" & APPLEII_ENABLE_MMC & '0';

  appleii_freed_inst : MMC_start_DE1_TOP
    port map
    (
       --////////////////////	Clock Input	 	////////////////////	 
       CLOCK_24         => "00",
       CLOCK_27         => "00",
       CLOCK_50         => clock_27(0),  -- 24MHz
       EXT_CLOCK        => '0',
       --////////////////////	Push Button		////////////////////
       KEY              => key_s,
       --////////////////////	DPDT Switch		////////////////////
       SW               => switch_s,
       --////////////////////	7-SEG Dispaly	////////////////////
       HEX0             => open,
       HEX1             => open,
       HEX2             => open,
       HEX3             => open,
       --////////////////////////	LED		///////////////////////
       LEDG             => open,
       LEDR             => open,
       --////////////////////////	UART	////////////////////////
       UART_TXD         => uart_txd,
       UART_RXD         => uart_rxd,
       --/////////////////////	SDRAM Interface		////////////////
       DRAM_DQ          => open,
       DRAM_ADDR        => open,
       DRAM_LDQM        => open,
       DRAM_UDQM        => open,
       DRAM_WE_N        => open,
       DRAM_CAS_N       => open,
       DRAM_RAS_N       => open,
       DRAM_CS_N        => open,
       DRAM_BA_0        => open,
       DRAM_BA_1        => open,
       DRAM_CLK         => open,
       DRAM_CKE         => open,
       --////////////////////	Flash Interface		////////////////
       FL_DQ            => fl_dq_s,
       FL_ADDR          => fl_addr_s,
       FL_WE_N          => open,
       FL_RST_N         => open,
       FL_OE_N          => fl_oe_n_s,
       FL_CE_N          => fl_ce_n_s,
       --////////////////////	SRAM Interface		////////////////
       SRAM_DQ          => sram_dq,
       SRAM_ADDR        => sram_addr,
       SRAM_UB_N        => sram_ub_n,
       SRAM_LB_N        => sram_lb_n,
       SRAM_WE_N        => sram_we_n,
       SRAM_CE_N        => sram_ce_n,
       SRAM_OE_N        => sram_oe_n,
       --////////////////////	SD_Card Interface	////////////////
       SD_DAT           => sd_dat,
       SD_DAT3          => sd_dat3,
       SD_CMD           => sd_cmd,
       SD_CLK           => sd_clk,
       --////////////////////	USB JTAG link	////////////////////
       TDI              => '0',
       TCK              => '0',
       TCS              => '0',
       TDO              => open,
       --////////////////////	I2C		////////////////////////////
       I2C_SDAT         => open,
       I2C_SCLK         => open,
       --////////////////////	PS2		////////////////////////////
       PS2_DAT          => ps2_dat,
       PS2_CLK          => ps2_clk,
       --////////////////////	VGA		////////////////////////////
       VGA_HS           => vga_hs,
       VGA_VS           => vga_vs,
       VGA_R            => vga_r,
       VGA_G            => vga_g,
       VGA_B            => vga_b,
       --////////////////	Audio CODEC		////////////////////////
       AUD_ADCLRCK      => open, --aud_adclrck,
       AUD_ADCDAT       => aud_adcdat,
       AUD_DACLRCK      => aud_daclrck,
       AUD_DACDAT       => aud_dacdat,
       AUD_BCLK         => aud_bclk,
       AUD_XCK          => aud_xck,
       --////////////////////	GPIO	////////////////////////////
       GPIO_0           => gpio_0,
       GPIO_1           => gpio_1_s
     );

  BLK_ROM : block

    signal rom_clk      : std_logic;
    signal c6_d_o       : std_logic_vector(7 downto 0);
    signal d0_d_o       : std_logic_vector(7 downto 0);
    signal e0_d_o       : std_logic_vector(7 downto 0);
    signal f0_d_o       : std_logic_vector(7 downto 0);
    signal rom_d_o      : std_logic_vector(7 downto 0);

  begin

    rom_clk <= gpio_1_s(35);

    rom_d_o <=  -- slot rom, mapped to 16'h0000 + cpu_addr[13:0]
                -- disk rom $C600-$C6FF
                c6_d_o when fl_addr_s(14 downto 12) = "000" and fl_addr_s(11 downto 8) = X"6" else
                -- apple ii rom, mapped to 16'h1000 + cpu_addr[13:0]
                -- $D000-$DFFF, $E000-$EFFF, $F000-$FFFF
                d0_d_o when fl_addr_s(14 downto 12) = "010" else
                e0_d_o when fl_addr_s(14 downto 12) = "011" else
                f0_d_o when fl_addr_s(14 downto 12) = "100" else
                (others => '1');

    fl_dq_s <=  rom_d_o when fl_ce_n_s = '0' and fl_oe_n_s = '0' else
                (others => 'Z');

    c6_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/c6.hex",
        numwords_a	=> 256,
        widthad_a		=> 8
      )
      port map
      (
        address		  => fl_addr_s(7 downto 0),
        clock		    => rom_clk,
        q		        => c6_d_o
      );

    d0_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/d0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        address		  => fl_addr_s(11 downto 0),
        clock		    => rom_clk,
        q		        => d0_d_o
      );

    e0_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/e0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        address		  => fl_addr_s(11 downto 0),
        clock		    => rom_clk,
        q		        => e0_d_o
      );

    f0_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/f0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        address		  => fl_addr_s(11 downto 0),
        clock		    => rom_clk,
        q		        => f0_d_o
      );

  end block BLK_ROM;

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

end SYN;
