library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.maple_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
 port
 (
  --/////////////////////////////  Clock Input   ////////////////////////////
  iCLK_28 : in std_logic; --28.63636 MHz
  iCLK_50 : in std_logic; --50 MHz
  iCLK_50_2 : in std_logic; --50 MHz
  iCLK_50_3 : in std_logic; --50 MHz
  iCLK_50_4 : in std_logic; --50 MHz
  iEXT_CLOCK : in std_logic; --External Clock
  --////////////////////////////  Push Button   ////////////////////////////
  iKEY : in std_logic_vector (3 downto 0); --Pushbutton[3:0]
  --////////////////////////////  DPDT Switch   ////////////////////////////
  iSW : in std_logic_vector (17 downto 0); --Toggle Switch[17:0]
  --////////////////////////////  7-SEG Dispaly  ////////////////////////////
  oHEX0_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 0
  oHEX0_DP : out std_logic; --Seven Segment Digit 0 decimal point
  oHEX1_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 1
  oHEX1_DP : out std_logic; --Seven Segment Digit 1 decimal point
  oHEX2_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 2
  oHEX2_DP : out std_logic; --Seven Segment Digit 2 decimal point
  oHEX3_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 3
  oHEX3_DP : out std_logic; --Seven Segment Digit 3 decimal point
  oHEX4_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 4
  oHEX4_DP : out std_logic; --Seven Segment Digit 4 decimal point
  oHEX5_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 5
  oHEX5_DP : out std_logic; --Seven Segment Digit 5 decimal point
  oHEX6_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 6
  oHEX6_DP : out std_logic; --Seven Segment Digit 6 decimal point
  oHEX7_D : out std_logic_vector (6 downto 0); --Seven Segment Digit 7
  oHEX7_DP : out std_logic; --Seven Segment Digit 7 decimal point
  --////////////////////////////   LED    ////////////////////////////
  oLEDG : out std_logic_vector (8 downto 0); --LED Green[8:0]
  oLEDR : out std_logic_vector (17 downto 0); --LED Red[17:0]
  --////////////////////////////     UART    ////////////////////////////
  oUART_CTS : out std_logic; --UART Clear To Send
  iUART_RTS : in std_logic; --UART Requst To Send
  iUART_RXD : in std_logic; --UART Receiver
  oUART_TXD : out std_logic; --UART Transmitter
  --////////////////////////////     IRDA    ////////////////////////////
  iIRDA_RXD : in std_logic; --IRDA Receiver
  oIRDA_TXD : out std_logic; --IRDA Transmitter
  --//////////////////////////  SDRAM Interface  ///////////////////////////
  DRAM_DQ : inout std_logic_vector (31 downto 0); --SDRAM Data bus 32 Bits
  oDRAM0_A : out std_logic_vector (12 downto 0); --SDRAM0 Address bus 13 Bits
  oDRAM1_A : out std_logic_vector (12 downto 0); --SDRAM1 Address bus 13 Bits
  oDRAM0_LDQM0 : out std_logic; --SDRAM0 Low-byte Data Mask 
  oDRAM1_LDQM0 : out std_logic; --SDRAM1 Low-byte Data Mask 
  oDRAM0_UDQM1 : out std_logic; --SDRAM0 High-byte Data Mask
  oDRAM1_UDQM1 : out std_logic; --SDRAM1 High-byte Data Mask
  oDRAM0_WE_N : out std_logic; --SDRAM0 Write Enable
  oDRAM1_WE_N : out std_logic; --SDRAM1 Write Enable
  oDRAM0_CAS_N : out std_logic; --SDRAM0 Column Address Strobe
  oDRAM1_CAS_N : out std_logic; --SDRAM1 Column Address Strobe
  oDRAM0_RAS_N : out std_logic; --SDRAM0 Row Address Strobe
  oDRAM1_RAS_N : out std_logic; --SDRAM1 Row Address Strobe
  oDRAM0_CS_N : out std_logic; --SDRAM0 Chip Select
  oDRAM1_CS_N : out std_logic; --SDRAM1 Chip Select
  oDRAM0_BA : out std_logic_vector (1 downto 0); --SDRAM0 Bank Address
  oDRAM1_BA : out std_logic_vector (1 downto 0); --SDRAM1 Bank Address
  oDRAM0_CLK : out std_logic; --SDRAM0 Clock
  oDRAM1_CLK : out std_logic; --SDRAM1 Clock
  oDRAM0_CKE : out std_logic; --SDRAM0 Clock Enable
  oDRAM1_CKE : out std_logic; --SDRAM1 Clock Enable
  --/////////////////////////  Flash Interface  /////////////////////////
  --FLASH_DQ:inout std_logic_vector (14 downto 0);--FLASH Data bus 15 Bits
  --FLASH_DQ15_AM1 : inout std_logic; --FLASH Data bus Bit 15 or Address A-1
  oFLASH_A : out std_logic_vector (21 downto 0); --FLASH Address bus 26 Bits
  oFLASH_WE_N : out std_logic; --FLASH Write Enable
  oFLASH_RST_N : out std_logic; --FLASH Reset
  oFLASH_WP_N : out std_logic; --FLASH Write Protect /Programming Acceleration 
  iFLASH_RY_N : in std_logic; --FLASH Ready/Busy output 
  oFLASH_BYTE_N : out std_logic; --FLASH Byte/Word Mode Configuration
  oFLASH_OE_N : out std_logic; --FLASH Output Enable
  oFLASH_CE_N : out std_logic; --FLASH Chip Enable
  ----///////////////////////// SSRAM Interface /////////////////////////
  --SRAM_DQ : inout std_logic_vector (31 downto 0); --SRAM Data Bus 32 Bits
  --SRAM_DPA : inout std_logic_vector (3 downto 0); --SRAM Parity Data Bus
  --oSRAM_A : out std_logic_vector (18 downto 0); --SRAM Address bus 22 Bits
  --oSRAM_ADSC_N : out std_logic; --SRAM Controller Address Status
  --oSRAM_ADSP_N : out std_logic; --SRAM Processor Address Status
  --oSRAM_ADV_N : out std_logic; --SRAM Burst Address Advance
  --oSRAM_BE_N : out std_logic_vector (3 downto 0);--SRAM Byte Write Enable
  --oSRAM_CE1_N : out std_logic; --SRAM Chip Enable
  --oSRAM_CE2 : out std_logic; --SRAM Chip Enable
  --oSRAM_CE3_N : out std_logic; --SRAM Chip Enable
  --oSRAM_CLK : out std_logic; --SRAM Clock
  --oSRAM_GW_N : out std_logic; --SRAM Global Write Enable
  --oSRAM_OE_N : out std_logic; --SRAM Output Enable
  --oSRAM_WE_N : out std_logic; --SRAM Write Enable 
  --////////////////////////// ISP1362 Interface  //////////////////////////
  OTG_D : inout std_logic_vector (15 downto 0); --ISP1362 Data bus 16 Bits
  oOTG_A : out std_logic_vector (1 downto 0); --ISP1362 Address 2 Bits
  oOTG_CS_N : out std_logic; --ISP1362 Chip Select
  oOTG_OE_N : out std_logic; --ISP1362 Read
  oOTG_WE_N : out std_logic; --ISP1362 Write
  oOTG_RESET_N : out std_logic; --ISP1362 Reset
  OTG_FSPEED : inout std_logic; --USB Full Speed
  OTG_LSPEED : inout std_logic;  --USB Low Speed
  iOTG_INT0 : in std_logic; --ISP1362 Interrupt 0
  iOTG_INT1 : in std_logic; --ISP1362 Interrupt 1
  iOTG_DREQ0 : in std_logic; --ISP1362 DMA Request 0
  iOTG_DREQ1 : in std_logic; --ISP1362 DMA Request 1
  oOTG_DACK0_N : out std_logic; --ISP1362 DMA AcknowoLEDGe 0
  oOTG_DACK1_N : out std_logic; --ISP1362 DMA AcknowoLEDGe 1
  --//////////////////////////  LCD Module 16X2  //////////////////////////
  oLCD_ON : out std_logic; --LCD Power ON/OFF
  oLCD_BLON : out std_logic; --LCD Back Light ON/OFF
  oLCD_RW  : out std_logic; --LCD Read/Write Select, 0 = Write, 1 = Read
  oLCD_EN : out std_logic; --LCD Enable
  oLCD_RS : out std_logic; --LCD Command/Data Select, 0 = Command, 1 = Data
  LCD_D : inout std_logic_vector (7 downto 0); --LCD Data bus 8 bits
  --//////////////////////////  SD_Card Interface //////////////////////////
  SD_DAT : inout std_logic; --SD Card Data
  SD_DAT3 : inout std_logic; --SD Card Data 3
  SD_CMD : inout std_logic; --SD Card Command Signal
  oSD_CLK : out std_logic; --SD Card Clock
  --////////////////////////////   I2C    ////////////////////////////
  oI2C_SCLK : out std_logic; --I2C Clock
  I2C_SDAT : inout std_logic; --I2C Data
  --////////////////////////// PS2 Port Interface //////////////////////////
  PS2_KBDAT : inout std_logic; --PS2 Keyboard Data
  PS2_KBCLK : inout std_logic;      --PS2 Keyboard Clock
  PS2_MSDAT : inout std_logic;      --PS2 Mouse Data
  PS2_MSCLK : inout std_logic;      --PS2 Mouse Clock
  --////////////////////////////   VGA    ////////////////////////////
  oVGA_CLOCK : out std_logic;  --VGA Clock
  oVGA_HS  : out std_logic;  --VGA H_SYNC
  oVGA_VS  : out std_logic;  --VGA V_SYNC
  oVGA_BLANK_N : out std_logic;  --VGA BLANK
  oVGA_SYNC_N : out std_logic;  --VGA SYNC
  oVGA_R  : out std_logic_vector (9 downto 0); --VGA Red[9:0]
  oVGA_G  : out std_logic_vector (9 downto 0); --VGA Green[9:0]
  oVGA_B  : out std_logic_vector (9 downto 0); --VGA Blue[9:0]
  --///////////////////////// Ethernet Interface /////////////////////////
  ENET_D  : inout std_logic_vector (15 downto 0); --DM9000A DATA bus 16Bits
  oENET_CMD : out std_logic;  --DM9000A Command/Data Select, 0 = Command, 1 = Data
  oENET_CS_N : out std_logic;  --DM9000A Chip Select
  oENET_IOW_N : out std_logic;  --DM9000A Write
  oENET_IOR_N : out std_logic;  --DM9000A Read
  oENET_RESET_N : out std_logic;  --DM9000A Reset
  iENET_INT : in std_logic;   --DM9000A Interrupt
  oENET_CLK : out std_logic;  --DM9000A Clock 25 MHz
  --//////////////////////////// Audio CODEC  //////////////////////////
  AUD_ADCLRCK : inout std_logic;  --Audio CODEC ADC LR Clock
  iAUD_ADCDAT : in std_logic;   --Audio CODEC ADC Data
  AUD_BCLK : inout std_logic;  --Audio CODEC Bit-Stream Clock
  AUD_DACLRCK : inout std_logic;  --Audio CODEC DAC LR Clock
  AUD_DACDAT : out std_logic;  --Audio CODEC DAC Data
  AUD_XCK  : out std_logic;  --Audio CODEC Chip Clock
  --//////////////////////////// TV Decoder  ////////////////////////////
  iTD1_CLK27 : in std_logic;   --TV Decoder1 Line_Lock Output Clock 
  iTD1_D  : in std_logic_vector (7 downto 0);  --TV Decoder1 Data bus 8 bits
  iTD1_HS  : in std_logic;   --TV Decoder1 H_SYNC
  oTD1_RESET_N : out std_logic;  --TV Decoder1 Reset
  iTD1_VS  : in std_logic;   --TV Decoder1 V_SYNC
  iTD2_CLK27 : in std_logic; --TV Decoder2 Line_Lock Output Clock 
  iTD2_D : in std_logic_vector (7 downto 0);  --TV Decoder2 Data bus 8 bits
  iTD2_HS  : in std_logic;   --TV Decoder2 H_SYNC
  iTD2_VS  : in std_logic;   --TV Decoder2 V_SYNC
  oTD2_RESET_N : out std_logic;  --TV Decoder2 Reset
  --////////////////////////////  GPIO  ////////////////////////////
  --GPIO_0 : inout std_logic_vector (31 downto 0); --GPIO Connection 0 I/O
  --iGPIO_CLKIN_N0 : in std_logic;   --GPIO Connection 0 Clock Input 0
  --iGPIO_CLKIN_P0 : in std_logic;   --GPIO Connection 0 Clock Input 1
  --GPIO_CLKOUT_N0 : inout std_logic;  --GPIO Connection 0 Clock Output 0
  --GPIO_CLKOUT_P0 : inout std_logic;  --GPIO Connection 0 Clock Output 1
  --GPIO_1 : inout std_logic_vector (31 downto 0); --GPIO Connection 1 I/O
  --iGPIO_CLKIN_N1 : in std_logic;   --GPIO Connection 1 Clock Input 0
  --iGPIO_CLKIN_P1 : in std_logic;   --GPIO Connection 1 Clock Input 1
  --GPIO_CLKOUT_N1 : inout std_logic;   --GPIO Connection 1 Clock Output 0
  --GPIO_CLKOUT_P1 : inout std_logic  --GPIO Connection 1 Clock Output 1
  
  --////////////////////////////////////////////////////////////////////////
  --///////////////////////////  FOR PACE  /////////////////////////////////
  --////////////////////////////////////////////////////////////////////////
  
  --//////////////// Dummy SRAM Interface (or external SRAM)  //////////////
  SRAM_DQ  : inout std_logic_vector(15 downto 0); --SRAM Data bus 16 Bits
  SRAM_ADDR   : out std_logic_vector(17 downto 0);  --SRAM Address bus 18 Bits
  SRAM_UB_N   : out std_logic;            --SRAM High-byte Data Mask 
  SRAM_LB_N   : out std_logic;            --SRAM Low-byte Data Mask 
  SRAM_WE_N   : out std_logic;            --SRAM Write Enable
  SRAM_CE_N   : out std_logic;            --SRAM Chip Enable
  SRAM_OE_N   : out std_logic;            --SRAM Output Enable
  --////////////////////////////  PACE FLASH  ////////////////////////////
  FLASH_DQ : inout std_logic_vector (7 downto 0);--ONLY using 8 bits
  --////////////////////////////   PACE GPIO  ////////////////////////////
  GPIO_0  : inout std_logic_vector (35 downto 0); --GPIO Connection 0 I/O
  GPIO_1  : inout std_logic_vector (35 downto 0) --GPIO Connection 1 I/O
  );

end target_top;

architecture SYN of target_top is

 component I2C_AV_Config
  port
  (
   -- Host Side
   iCLK  : in std_logic;
   iRST_N  : in std_logic;
   --I2C Side
   I2C_SCLK : out std_logic;
   I2C_SDAT : inout std_logic
  );
 end component I2C_AV_Config;

 component I2S_LCM_Config 
  port
  (  --Host Side
      iCLK : in std_logic;
   iRST_N  : in std_logic;
   -- I2C Side
   I2S_SCLK : out std_logic;
   I2S_SDAT : out std_logic;
   I2S_SCEN : out std_logic
  );
 end component I2S_LCM_Config;

 component SEG7_LUT is
  port (
   iDIG : in std_logic_vector(3 downto 0); 
   oSEG : out std_logic_vector(6 downto 0)
  );
 end component;

 component LCD_TEST 
  port
  ( --Host Side
   iCLK : in std_logic;
   iRST_N : in std_logic;
   iLINE1 : in std_logic_vector(127 downto 0);
   iLINE2 : in std_logic_vector(127 downto 0);
   --LCD Side
   LCD_DATA : out std_logic_vector(7 downto 0);
   LCD_RW : out std_logic;
   LCD_EN : out std_logic;
   LCD_RS : out std_logic
   );
 end component LCD_TEST;

 alias gpio_maple  : std_logic_vector(35 downto 0) is gpio_0;
 alias gpio_lcd  : std_logic_vector(35 downto 0) is gpio_1;
 signal clk_i : std_logic_vector(0 to 3);
 signal init  :  std_logic := '1';
 signal reset_i  :  std_logic := '1';
 signal reset_n : std_logic := '0';
 signal buttons_i  : from_BUTTONS_t;
 signal switches_i  : from_SWITCHES_t;
 signal leds_o  : to_LEDS_t;
 signal inputs_i   : from_INPUTS_t;
 signal flash_i : from_FLASH_t;
 signal flash_o : to_FLASH_t;
 signal sram_i : from_SRAM_t;
 signal sram_o : to_SRAM_t; 
 signal sdram_i : from_SDRAM_t;
 signal sdram_o : to_SDRAM_t;
 signal video_i : from_VIDEO_t;
 signal video_o : to_VIDEO_t;
 signal audio_i : from_AUDIO_t;
 signal audio_o : to_AUDIO_t;
 signal ser_i : from_SERIAL_t;
 signal ser_o : to_SERIAL_t;
 
 --maple/dreamcast controller interface
 signal maple_sense : std_logic;
 signal maple_oe : std_logic;
 signal mpj : work.maple_pkg.joystate_type;

--gamecube controller interface
 signal gcj : work.gamecube_pkg.joystate_type;  
 signal lcm_sclk   : std_logic;
 signal lcm_sdat   : std_logic;
 signal lcm_scen   : std_logic;
 signal lcm_data   : std_logic_vector(7 downto 0);
 signal lcm_grst  : std_logic;
 signal lcm_hsync  : std_logic;
 signal lcm_vsync  : std_logic;
 signal lcm_dclk  : std_logic;
 signal lcm_shdb  : std_logic;
 signal lcm_clk : std_logic;
 signal yoffs :  std_logic_vector(7 downto 0);
 signal pwmen :  std_logic;
 signal chaseen :  std_logic;
 
begin

 BLK_CLOCKING : block
 begin
 
  GEN_PLL : if PACE_HAS_PLL generate
  
   pll_50_inst : entity work.pll
    generic map
    (
     --INCLK0
     INCLK0_INPUT_FREQUENCY => 20000,
  
     --CLK0
     CLK0_DIVIDE_BY     => PACE_CLK0_DIVIDE_BY,
     CLK0_MULTIPLY_BY    => PACE_CLK0_MULTIPLY_BY,
   
     --CLK1
     CLK1_DIVIDE_BY     => PACE_CLK1_DIVIDE_BY,
     CLK1_MULTIPLY_BY    => PACE_CLK1_MULTIPLY_BY
    )
    port map
    (
     inclk0 => iCLK_50,
     c0   => clk_i(0),
     c1   => clk_i(1)
    );

  end generate GEN_PLL;
  
  GEN_NO_PLL : if not PACE_HAS_PLL generate

   --feed input clocks into PACE core
   clk_i(0) <= iCLK_50;
   clk_i(1) <= iCLK_28;
    
  end generate GEN_NO_PLL;
   
  pll_27_inst : entity work.pll
   generic map
   (
    --INCLK0
    INCLK0_INPUT_FREQUENCY => 37037,

    --CLK0 - 18M432Hz for audio
    CLK0_DIVIDE_BY     => 22,
    CLK0_MULTIPLY_BY    => 15,
  
    --CLK1 - not used
    CLK1_DIVIDE_BY     => 1,
    CLK1_MULTIPLY_BY    => 1
   )
   port map
   (
    inclk0 => iCLK_28,
    c0   => clk_i(2),
    c1   => clk_i(3)
   );

 end block BLK_CLOCKING;
 
 --FPGA STARTUP
 --should extend power-on reset if registers init to '0'
 process (iCLK_50)
  variable count : std_logic_vector (11 downto 0) := (others => '0');
 begin
  if rising_edge(iCLK_50) then
   if count = X"FFF" then
    init <= '0';
   else
    count := count + 1;
    init <= '1';
   end if;
  end if;
 end process;

 reset_i <= init or not iKEY(0);
 reset_n <= not reset_i;
 
 --buttons - active low
 buttons_i <= std_logic_vector(resize(unsigned(not iKEY), buttons_i'length));
 --switches - up = high
 switches_i <= std_logic_vector(resize(unsigned(iSW), switches_i'length));
 --leds
 oLEDR <= leds_o(oLEDR'range);
 
 --inputs
 inputs_i.ps2_kclk <= PS2_KBCLK;
 inputs_i.ps2_kdat <= PS2_KBDAT;
 inputs_i.ps2_mclk <= '0';
 inputs_i.ps2_mdat <= '0';

 GEN_MAPLE : if PACE_JAMMA = PACE_JAMMA_MAPLE generate
 
 --Dreamcast MapleBus joystick interface
 MAPLE_JOY_inst : maple_joy
   port map
   (
    clk    => iCLK_50,
    reset   => reset_i,
    sense   => maple_sense,
    oe    => maple_oe,
    a     => gpio_maple(14),
    b     => gpio_maple(13),
    joystate => mpj
   );
  gpio_maple(12) <= maple_oe;
  gpio_maple(11) <= not maple_oe;
  maple_sense <= gpio_maple(17); --and sw(0);

  --map maple bus to jamma inputs
  --- same mappings as default mappings for MAMED (DCMAME)
  inputs_i.jamma_n.coin(1)      <= mpj.lv(7);  --MSB of right analogue trigger (0-255)
  inputs_i.jamma_n.p(1).start    <= mpj.start;
  inputs_i.jamma_n.p(1).up      <= mpj.d_up;
  inputs_i.jamma_n.p(1).down     <= mpj.d_down;
  inputs_i.jamma_n.p(1).left     <= mpj.d_left;
  inputs_i.jamma_n.p(1).right    <= mpj.d_right;
  inputs_i.jamma_n.p(1).button(1)  <= mpj.a;
  inputs_i.jamma_n.p(1).button(2)  <= mpj.x;
  inputs_i.jamma_n.p(1).button(3)  <= mpj.b;
  inputs_i.jamma_n.p(1).button(4)  <= mpj.y;
  inputs_i.jamma_n.p(1).button(5)  <= '1';

 end generate GEN_MAPLE;

 GEN_GAMECUBE : if PACE_JAMMA = PACE_JAMMA_NGC generate
 
  GC_JOY: gamecube_joy
   generic map( MHZ => 50 )
   port map
   (
    clk     => iCLK_50,
    reset    => reset_i,
    --oe      => gc_oe,
    d      => gpio_0(25),
    joystate   => gcj
   );

  --map gamecube controller to jamma inputs
  inputs_i.jamma_n.coin(1) <= not gcj.l;
  inputs_i.jamma_n.p(1).start <= not gcj.start;
  inputs_i.jamma_n.p(1).up <= not gcj.d_up;
  inputs_i.jamma_n.p(1).down <= not gcj.d_down;
  inputs_i.jamma_n.p(1).left <= not gcj.d_left;
  inputs_i.jamma_n.p(1).right <= not gcj.d_right;
  inputs_i.jamma_n.p(1).button(1) <= not gcj.a;
  inputs_i.jamma_n.p(1).button(2) <= not gcj.b;
  inputs_i.jamma_n.p(1).button(3) <= not gcj.x;
  inputs_i.jamma_n.p(1).button(4) <= not gcj.y;
  inputs_i.jamma_n.p(1).button(5) <= not gcj.z;

 end generate GEN_GAMECUBE;
 
 GEN_NO_JAMMA : if PACE_JAMMA = PACE_JAMMA_NONE generate
  inputs_i.jamma_n.coin(1) <= '1';
  inputs_i.jamma_n.p(1).start <= '1';
  inputs_i.jamma_n.p(1).up <= '1';
  inputs_i.jamma_n.p(1).down <= '1';
  inputs_i.jamma_n.p(1).left <= '1';
  inputs_i.jamma_n.p(1).right <= '1';
  inputs_i.jamma_n.p(1).button <= (others => '1');
 end generate GEN_NO_JAMMA;

 --not currently wired to any inputs
 inputs_i.jamma_n.coin_cnt <= (others => '1');
 inputs_i.jamma_n.coin(2) <= '1';
 inputs_i.jamma_n.p(2).start <= '1';
  inputs_i.jamma_n.p(2).up <= '1';
  inputs_i.jamma_n.p(2).down <= '1';
 inputs_i.jamma_n.p(2).left <= '1';
 inputs_i.jamma_n.p(2).right <= '1';
 inputs_i.jamma_n.p(2).button <= (others => '1');
 inputs_i.jamma_n.service <= '1';
 inputs_i.jamma_n.tilt <= '1';
 inputs_i.jamma_n.test <= '1';
  
 --show JAMMA inputs on LED bank
 GEN_JAMMA_LEDS : if false generate
  oLEDR(17) <= not inputs_i.jamma_n.coin(1);
  oLEDR(16) <= not inputs_i.jamma_n.coin(2);
  oLEDR(15) <= not inputs_i.jamma_n.p(1).start;
  oLEDR(14) <= not inputs_i.jamma_n.p(1).up;
  oLEDR(13) <= not inputs_i.jamma_n.p(1).down;
  oLEDR(12) <= not inputs_i.jamma_n.p(1).left;
  oLEDR(11) <= not inputs_i.jamma_n.p(1).right;
  oLEDR(10) <= not inputs_i.jamma_n.p(1).button(1);
  oLEDR(9) <= not inputs_i.jamma_n.p(1).button(2);
  oLEDR(8) <= not inputs_i.jamma_n.p(1).button(3);
  oLEDR(7) <= not inputs_i.jamma_n.p(1).button(4);
  oLEDR(6) <= not inputs_i.jamma_n.p(1).button(5);
  oLEDR(5 downto 0) <= (others => '0');
 end generate GEN_JAMMA_LEDS;
 
 --flash memory
 BLK_FLASH : block
 begin
  oFLASH_RST_N <= '1';

  GEN_FLASH : if PACE_HAS_FLASH generate
   flash_i.d <= FLASH_DQ;
   FLASH_DQ <= flash_o.d when (flash_o.cs = '1' and flash_o.we = '1' and flash_o.oe = '0') else 
        (others => 'Z');
   oFLASH_A <= flash_o.a;
   oFLASH_WE_N <= not flash_o.we;
   oFLASH_OE_N <= not flash_o.oe;
   oFLASH_CE_N <= not flash_o.cs;
  end generate GEN_FLASH;
  
  GEN_NO_FLASH : if not PACE_HAS_FLASH generate
   flash_i.d <= (others => '1');
   FLASH_DQ <= (others => 'Z');
   oFLASH_A <= (others => 'Z');
   oFLASH_CE_N <= '1';
   oFLASH_OE_N <= '1';
   oFLASH_WE_N <= '1';
  end generate GEN_NO_FLASH;

 end block BLK_FLASH;
 
 --static memory
--BLK_SRAM : block
--begin
--
-- GEN_SRAM : if PACE_HAS_SRAM generate
--  sram_addr <= sram_o.a(sram_addr'range);
--  sram_i.d <= std_logic_vector(resize(unsigned(sram_dq), sram_i.d'length));
--  sram_dq <= sram_o.d(sram_dq'range) when (sram_o.cs = '1' and sram_o.we = '1') else (others => 'Z');
--  sram_ub_n <= not sram_o.be(1);
--  sram_lb_n <= not sram_o.be(0);
--  sram_ce_n <= not sram_o.cs;
--  sram_oe_n <= not sram_o.oe;
--  sram_we_n <= not sram_o.we;
-- end generate GEN_SRAM;
-- 
-- GEN_NO_SRAM : if not PACE_HAS_SRAM generate
--  sram_addr <= (others => 'Z');
--  sram_i.d <= (others => '1');
--  sram_dq <= (others => 'Z');
--  sram_ub_n <= '1';
--  sram_lb_n <= '1';
--  sram_ce_n <= '1';
--  sram_oe_n <= '1';
--  sram_we_n <= '1'; 
-- end generate GEN_NO_SRAM;
-- 
--end block BLK_SRAM;

 BLK_SDRAM : block

  component sdram_0 is 
   port 
   (
    --inputs:
    signal az_addr : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
    signal az_be_n : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
    signal az_cs : IN STD_LOGIC;
    signal az_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    signal az_rd_n : IN STD_LOGIC;
    signal az_wr_n : IN STD_LOGIC;
    signal clk : IN STD_LOGIC;
    signal reset_n : IN STD_LOGIC;

    --outputs:
    signal za_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    signal za_valid : OUT STD_LOGIC;
    signal za_waitrequest : OUT STD_LOGIC;
    signal zs_addr : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
    signal zs_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    signal zs_cas_n : OUT STD_LOGIC;
    signal zs_cke : OUT STD_LOGIC;
    signal zs_cs_n : OUT STD_LOGIC;
    signal zs_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    signal zs_dqm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    signal zs_ras_n : OUT STD_LOGIC;
    signal zs_we_n : OUT STD_LOGIC
   );
  end component sdram_0;

 begin

  GEN_NO_SDRAM : if not PACE_HAS_SDRAM generate
   oDRAM0_A <= (others => 'Z');
   oDRAM0_WE_N <= '1';
   oDRAM0_CS_N <= '1';
   oDRAM0_CLK <= '0';
   oDRAM0_CKE <= '0';
  end generate GEN_NO_SDRAM;
 
  GEN_SDRAM : if PACE_HAS_SDRAM generate
  end generate GEN_SDRAM;

 end block BLK_SDRAM;

 BLK_VIDEO : block
 begin

  video_i.clk <= clk_i(1); --by convention
  video_i.clk_ena <= '1';
  video_i.reset <= reset_i;
  
  oVGA_CLOCK <= video_o.clk;
  oVGA_R    <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-9);
  oVGA_G   <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-9);
  oVGA_B    <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-9);
  oVGA_HS   <= video_o.hsync;
  oVGA_VS   <= video_o.vsync;
  oVGA_SYNC_N   <= video_o.hsync and video_o.vsync;
  oVGA_BLANK_N <= '1';

 end block BLK_VIDEO;

 BLK_AUDIO : block
  alias aud_clk :  std_logic is clk_i(2);
  signal aud_data_l  : std_logic_vector(audio_o.ldata'range);
  signal aud_data_r  : std_logic_vector(audio_o.rdata'range);
 begin

  --enable each channel independantly for debugging
  aud_data_l <= audio_o.ldata when switches_i(9) = '0' else (others => '0');
  aud_data_r <= audio_o.rdata when switches_i(8) = '0' else (others => '0');

  --Audio
  audif_inst : entity work.audio_if
   generic map 
   (
    REF_CLK    => 18432000, --Set REF clk frequency here
    SAMPLE_RATE  => 48000,   --48000 samples/sec
    DATA_WIDTH  => 16,    --16  Bits
    CHANNEL_NUM  => 2     --Dual Channel
   )
   port map
   (
    --Inputs
    clk      => aud_clk,
    reset     => reset_i,
    datal     => aud_data_l,
    datar     => aud_data_r,
  
    --Outputs
    AUD_XCK    => AUD_XCK,
    AUD_ADCLRCK  => AUD_ADCLRCK,
    AUD_DACLRCK  => AUD_DACLRCK,
    AUD_BCLK   => AUD_BCLK,
    AUD_DACDAT  => AUD_DACDAT,
    next_sample  => open
   );

 end block BLK_AUDIO;
 
 BLK_SERIAL : block
 begin
  GEN_SERIAL : if PACE_HAS_SERIAL generate
   oUART_TXD <= ser_o.txd;
   ser_i.rxd <= iUART_RXD;
  end generate GEN_SERIAL;
  GEN_NO_SERIAL : if not PACE_HAS_SERIAL generate
   oUART_TXD <='0';
   ser_i.rxd <= '0';
  end generate GEN_NO_SERIAL;
 end block BLK_SERIAL;
 
 --turn off LEDs
 oHEX0_D <= (others => '1');
 oHEX1_D <= (others => '1');
 oHEX2_D <= (others => '1');
 oHEX3_D <= (others => '1');
 oHEX4_D <= (others => '1');
 oHEX5_D <= (others => '1');
 oHEX6_D <= (others => '1');
 oHEX7_D <= (others => '1');
 oLEDG(8) <= '0';
 oHEX0_DP <= '0';
 oHEX1_DP <= '0';
 oHEX2_DP <= '0';
 oHEX3_DP <= '0';
 oHEX4_DP <= '0';
 oHEX5_DP <= '0';
 oHEX6_DP <= '0';
 oHEX7_DP <= '0';
 --disable SD card
 oSD_CLK <= '0';
 SD_DAT <= 'Z';
 SD_DAT3 <= 'Z';
 SD_CMD <= 'Z';

 --disable JTAG
 --tdo <= 'Z';
 
 --no IrDA
 oIRDA_TXD <= 'Z';
 
 --disable USB
 OTG_D <= (others => 'Z');
 oOTG_A <= (others => 'Z');
 oOTG_CS_N <= '1';
 oOTG_OE_N <= '1';
 oOTG_WE_N <= '1';
 oOTG_RESET_N <= '1';

 BLK_LCD_TEST : block
  signal iline1 : std_logic_vector(127 downto 0);
  signal iline2 : std_logic_vector(127 downto 0);
 begin

  GEN_LINES : for i in 0 to 15 generate
   iline1(i*8+7 downto i*8) <= std_logic_vector(to_unsigned(character'pos(DE2_LCD_LINE1(i+1)),8));
   iline2(i*8+7 downto i*8) <= std_logic_vector(to_unsigned(character'pos(DE2_LCD_LINE2(i+1)),8));
  end generate GEN_LINES;

  --LCD
  oLCD_ON <= '1';
  oLCD_BLON <= '1';
  lcdt: LCD_TEST 
   port map
   ( --Host Side
    iCLK   => iCLK_50,
    iRST_N  => reset_n,
    iLINE1  => iline1,
    iLINE2  => iline2,
    --LCD Side
    LCD_DATA => LCD_D,
    LCD_RW  => oLCD_RW,
    LCD_EN  => oLCD_EN,
    LCD_RS  => oLCD_RS
    );

 end block BLK_LCD_TEST;

 --disable ethernet
 ENET_D <= (others => 'Z');
 oENET_CS_N <= '1';
 oENET_IOW_N <= '1';
 oENET_IOR_N <= '1';
 oENET_RESET_N <= '0';
 oENET_CLK <= '0';

 --Display funkalicious pacman sprite y offset on 7seg display
 --Why? Because we can
 seg7_0: SEG7_LUT port map (iDIG => yoffs(7 downto 4), oSEG => oHEX7_D);
 seg7_1: SEG7_LUT port map (iDIG => yoffs(3 downto 0), oSEG => oHEX6_D);

 --GPIO
 gpio_0 <= (others => 'Z');
 gpio_1 <= (others => 'Z');
  
 --LCM signals
 gpio_lcd(19) <= lcm_data(7);
 gpio_lcd(18) <= lcm_data(6);
 gpio_lcd(21) <= lcm_data(5);
 gpio_lcd(20) <= lcm_data(4);
 gpio_lcd(23) <= lcm_data(3);
 gpio_lcd(22) <= lcm_data(2);
 gpio_lcd(25) <= lcm_data(1);
 gpio_lcd(24) <= lcm_data(0);
 gpio_lcd(30) <= lcm_grst;
 gpio_lcd(26) <= lcm_vsync;
 gpio_lcd(35) <= lcm_hsync;
 gpio_lcd(29) <= lcm_dclk;
 gpio_lcd(31) <= lcm_shdb;
 gpio_lcd(28) <= lcm_sclk;
 gpio_lcd(33) <= lcm_scen;
 gpio_lcd(34) <= lcm_sdat;

 lcmc: I2S_LCM_Config
  port map
  (  --Host Side
   iCLK => iCLK_50,
   iRST_N => reset_n, --lcm_grst_n,
   -- I2C Side
   I2S_SCLK => lcm_sclk,
   I2S_SDAT => lcm_sdat,
   I2S_SCEN => lcm_scen
  );

 lcm_clk <= video_o.clk;
 lcm_grst <= reset_n;
 lcm_dclk <= not lcm_clk;
 lcm_shdb <= '1';
 lcm_hsync <= video_o.hsync;
 lcm_vsync <= video_o.vsync;
 
 pace_inst : entity work.pace                      
  port map
  (
   --clocks and resets
   clk_i       => clk_i,
   reset_i      => reset_i,

   --misc inputs and outputs
   buttons_i     => buttons_i,
   switches_i    => switches_i,
   leds_o      => leds_o,
   
   --controller inputs
   inputs_i     => inputs_i,

   --external ROM/RAM
   flash_i      => flash_i,
   flash_o      => flash_o,
   sram_i      => sram_i,
   sram_o      => sram_o,
   sdram_i      => sdram_i,
   sdram_o      => sdram_o,
 
   --VGA video
   video_i      => video_i,
   video_o      => video_o,
   
   --sound
   audio_i      => audio_i,
   audio_o      => audio_o,

   --SPI (flash)
   spi_i.din     => '0',
   spi_o       => open,
 
   --serial
   ser_i       => ser_i,
   ser_o       => ser_o,
   
   --general purpose
   gp_i       => (others => '0'),
   gp_o       => open
  );

 av_init : I2C_AV_Config
  port map
  (
   --Host Side
   iCLK       => iCLK_50,
   iRST_N      => reset_n,
   
   --I2C Side
   I2C_SCLK     => oI2C_SCLK,
   I2C_SDAT     => I2C_SDAT
  );

 pchaser: work.pwm_chaser 
  generic map(nleds => 8, nbits => 8, period => 4, hold_time => 12)
   port map (clk => iCLK_50, clk_en => chaseen, pwm_en => pwmen, reset => reset_i, fade => X"0F", ledout => oLEDG(7 downto 0));

 --Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
 process(iCLK_50, reset_i)
  variable pcount   : std_logic_vector(9 downto 0);
  variable pwmen_r  : std_logic;
  variable ccount   : std_logic_vector(18 downto 0);
  variable chaseen_r : std_logic;
 begin
  pwmen <= pwmen_r;
  chaseen <= chaseen_r;
  if reset_i = '1' then
   pcount := (others => '0');
   ccount := (others => '0');
  elsif rising_edge(iCLK_50) then
   pwmen_r := '0';
   if pcount = std_logic_vector(to_unsigned(0, pcount'length)) then
    pwmen_r := '1';
   end if;
   chaseen_r := '0';
   if ccount = std_logic_vector(to_unsigned(0, ccount'length)) then
    chaseen_r := '1';
   end if;
   pcount := pcount + 1;
   ccount := ccount + 1;
  end if;
 end process;

 --LED chaser
--process (iCLK_50, reset)
-- variable count : integer range 0 to 4999999;
-- variable led : std_logic_vector(oLEDR'left downto oLEDR'right);
-- variable led_dir : std_logic;
--begin
-- if reset = '1' then
--  count := 0;
--  led_dir := '0';
--  led := "000000000000000001";
-- elsif rising_edge(iCLK_50) then
--  if count = 0 then
--   count := 4999999; --100ms
--   if (led_dir = '0' and led(led'left) = '1') or (led_dir = '1' and led(led'right) = '1') then
--    led_dir := not led_dir;
--   end if;
--   if led_dir = '0' then
--    led := led(led'left-1 downto led'right) & "0";
--   else
--    led := "0" & led(led'left downto led'right+1);
--   end if;
--  else
--   count := count - 1;
--  end if;
-- end if;
-- --assign outputs
-- oLEDR <= led;
--end process;
    
end SYN;

