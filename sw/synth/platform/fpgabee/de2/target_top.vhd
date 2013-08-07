library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
--use work.maple_pkg.all;
--use work.gamecube_pkg.all;

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
		ps2_dat       : inout std_logic;                      --	PS2 Data
		ps2_clk       : inout std_logic;                      --	PS2 Clock
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

  signal init       	                  : std_logic := '1';
  signal arst                           : std_logic;
  signal rst                            : std_logic;
  
  signal clk_100M                       : std_logic;
  signal clk_37M125                     : std_logic;
  signal clk_3M375_en                   : std_logic;
  signal clk_40M                        : std_logic;
  
  signal ram_a                          : std_logic_vector(17 downto 0);
  signal ram_d_i                        : std_logic_vector(7 downto 0);
  signal ram_d_o                        : std_logic_vector(7 downto 0);
  signal ram_wr                         : std_logic;

  signal vga_hs_s                       : std_logic;
  signal vga_vs_s                       : std_logic;
  
--  signal ps2_clk_io                     : std_logic;
--  signal ps2_dat_io                     : std_logic;
  
	signal seg7                           : std_logic_vector(31 downto 0);
  
begin

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock_50)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(clock_50) then
			if count = X"FFF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

  arst <= init or not key(0);

  clockcore_inst : entity work.clockcore
    port map
    (
      inclk0		=> clock_50,
      c0		    => clk_37M125,
      c1		    => clk_100M,
      c2		    => clk_40M
    );

  process (clk_37M125, rst)
    -- 3.375 * 11 = 37.125
    variable count : integer range 0 to 11-1;
  begin
    if rst = '1' then
      count := 0;
    elsif rising_edge(clk_37M125) then
      clk_3M375_en <= '0';  -- default
      if count = count'high then
        clk_3M375_en <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;
  
  fpgabee_inst : entity work.FpgaBeeCore
    port map
    ( 
      clock_100_000       => clk_100M,
      clock_40_000        => clk_40M,
      clktb_3_375         => clk_37M125,
      clken_3_375         => clk_3M375_en,
      reset               => arst,
      monitor_key         => key(2),
      show_status_panel   => key(3),
      
      ram_addr            => ram_a,
      ram_rd_data         => ram_d_i,
      ram_wr_data         => ram_d_o,
      ram_wr              => ram_wr,
      ram_rd              => open,
      ram_wait            => '0',
      
      vga_red             => vga_r(vga_r'left downto vga_r'left-1),
      vga_green           => vga_g(vga_g'left downto vga_g'left-1),
      vga_blue            => vga_b(vga_b'left downto vga_b'left-1),
      vga_hsync           => vga_hs_s,
      vga_vsync           => vga_vs_s,
      vga_pixel_x         => open,
      vga_pixel_y         => open,

      sd_sclk             => open,
      sd_mosi             => open,
      sd_miso             => '0',
      sd_ss_n             => open,

      ps2_keyboard_data   => ps2_dat,
      ps2_keyboard_clock  => ps2_clk,

      speaker             => open
    );

  -- sram (16-bit)
  ram_d_i <= sram_dq(ram_d_i'range);
  sram_dq <= ram_d_o & ram_d_o when ram_wr = '1' else
              (others => 'Z');
  sram_addr(17 downto 0) <= ram_a(17 downto 0);
  sram_ub_n <= '1';
  sram_lb_n <= '0';
  sram_we_n <= not ram_wr;
  sram_ce_n <= '0';
  sram_oe_n <= ram_wr;

  -- unused colour bits
  vga_r(vga_r'left-2 downto 0) <= (others => '0');
  vga_g(vga_g'left-2 downto 0) <= (others => '0');
  vga_b(vga_b'left-2 downto 0) <= (others => '0');
  
  
  BLK_VIDEO : block

    component I2C_AV_Config
      port
      (
        -- 	Host Side
        iCLK					: in std_logic;
        iRST_N				: in std_logic;
        --	I2C Side
        I2C_SCLK			: out std_logic;
        I2C_SDAT			: inout std_logic
      );
    end component I2C_AV_Config;

  begin

    vga_clk <= clk_40M;
    vga_hs <= vga_hs_s;
    vga_vs <= vga_vs_s;
    vga_sync <= vga_hs_s and vga_vs_s;
    vga_blank <= '1';
  
    av_init : I2C_AV_Config
      port map
      (
        --	Host Side
        iCLK							=> clock_50,
        iRST_N						=> not arst,
        
        --	I2C Side
        I2C_SCLK					=> I2C_SCLK,
        I2C_SDAT					=> I2C_SDAT
      );

  end block BLK_VIDEO;

--  BLK_LCM : block
--
--    component I2S_LCM_Config 
--      port
--      (   --  Host Side
--              iCLK      : in std_logic;
--        iRST_N    : in std_logic;
--        --    I2C Side
--        I2S_SCLK  : out std_logic;
--        I2S_SDAT  : out std_logic;
--        I2S_SCEN  : out std_logic
--      );
--    end component I2S_LCM_Config;
--
--    alias gpio_lcd_o 		: std_logic_vector(35 downto 18) is default_gpio_1_o(35 downto 18);
--    
--    signal lcm_sclk   	: std_logic;
--    signal lcm_sdat   	: std_logic;
--    signal lcm_scen   	: std_logic;
--    signal lcm_data   	: std_logic_vector(7 downto 0);
--    signal lcm_grst  		: std_logic;
--    signal lcm_hsync  	: std_logic;
--    signal lcm_vsync  	: std_logic;
--    signal lcm_dclk  		: std_logic;
--    signal lcm_shdb  		: std_logic;
--    signal lcm_clk			: std_logic;
--
--  begin
--  
--    lcmc: I2S_LCM_Config
--      port map
--      (   --  Host Side
--        iCLK => clock_50,
--        iRST_N => clkrst_i.arst_n, --lcm_grst_n,
--        --    I2C Side
--        I2S_SCLK => lcm_sclk,
--        I2S_SDAT => lcm_sdat,
--        I2S_SCEN => lcm_scen
--      );
--
--    lcm_clk <= video_o.clk;
--    lcm_grst <= not video_i.reset;
--    lcm_dclk	<=	not lcm_clk;
--    lcm_shdb	<=	'1';
--    lcm_hsync <= video_o.hsync;
--    lcm_vsync <= video_o.vsync;
--
--    gpio_lcd_o(19) <= lcm_data(7);
--    gpio_lcd_o(18) <= lcm_data(6);
--    gpio_lcd_o(21) <= lcm_data(5);
--    gpio_lcd_o(20) <= lcm_data(4);
--    gpio_lcd_o(23) <= lcm_data(3);
--    gpio_lcd_o(22) <= lcm_data(2);
--    gpio_lcd_o(25) <= lcm_data(1);
--    gpio_lcd_o(24) <= lcm_data(0);
--    gpio_lcd_o(30) <= lcm_grst;
--    gpio_lcd_o(26) <= lcm_vsync;
--    gpio_lcd_o(35) <= lcm_hsync;
--    gpio_lcd_o(29) <= lcm_dclk;
--    gpio_lcd_o(31) <= lcm_shdb;
--    gpio_lcd_o(28) <= lcm_sclk;
--    gpio_lcd_o(33) <= lcm_scen;
--    gpio_lcd_o(34) <= lcm_sdat;
--
--  end block BLK_LCM;
  
--  BLK_AUDIO : block
--    alias aud_clk    		: std_logic is clkrst_i.clk(2);
--    signal aud_data_l  	: std_logic_vector(audio_o.ldata'range);
--    signal aud_data_r  	: std_logic_vector(audio_o.rdata'range);
--  begin
--
--    -- enable each channel independantly for debugging
--    aud_data_l <= audio_o.ldata when switches_i(17) = '0' else (others => '0');
--    aud_data_r <= audio_o.rdata when switches_i(16) = '0' else (others => '0');
--
--    -- Audio
--    audif_inst : entity work.audio_if
--      generic map 
--      (
--        REF_CLK       => 18432000,  -- Set REF clk frequency here
--        SAMPLE_RATE   => 48000,     -- 48000 samples/sec
--        DATA_WIDTH    => 16,			  --	16		Bits
--        CHANNEL_NUM   => 2  			  --	Dual Channel
--      )
--      port map
--      (
--        -- Inputs
--        clk           => aud_clk,
--        reset         => clkrst_i.arst,
--        datal         => aud_data_l,
--        datar         => aud_data_r,
--    
--        -- Outputs
--        aud_xck       => aud_xck,
--        aud_adclrck   => aud_adclrck,
--        aud_daclrck   => aud_daclrck,
--        aud_bclk      => aud_bclk,
--        aud_dacdat    => aud_dacdat,
--        next_sample   => open
--      );
--
--  end block BLK_AUDIO;
  
  ledg(8) <= '0';
  --ledr(17 downto 8) <= (others => '0');

  -- disable JTAG
  tdo <= 'Z';
  
	-- no IrDA
	irda_txd <= 'Z';
	
  -- disable USB
  otg_data <= (others => 'Z');
  otg_addr <= (others => 'Z');
  otg_cs_n <= '1';
  otg_rd_n <= '1';
  otg_wr_n <= '1';
  otg_rst_n <= '1';

	BLK_LCD_TEST : block

    component LCD_TEST 
      port
      (	--	Host Side
        iCLK          : in std_logic;
        iRST_N        : in std_logic;
        iLINE1				: in std_logic_vector(127 downto 0);
        iLINE2				: in std_logic_vector(127 downto 0);
        --	LCD Side
        LCD_DATA      : out std_logic_vector(7 downto 0);
        LCD_RW        : out std_logic;
        LCD_EN        : out std_logic;
        LCD_RS        : out std_logic
      );
    end component LCD_TEST;

    constant DE2_LCD_LINE1 : string := "FPGABEE         ";
    constant DE2_LCD_LINE2 : string := "- DE2 by TCDEV  ";
    
		signal iline1 : std_logic_vector(127 downto 0);
		signal iline2 : std_logic_vector(127 downto 0);

	begin

		GEN_LINES : for i in 0 to 15 generate
			iline1(i*8+7 downto i*8) <= std_logic_vector(to_unsigned(character'pos(DE2_LCD_LINE1(i+1)),8));
			iline2(i*8+7 downto i*8) <= std_logic_vector(to_unsigned(character'pos(DE2_LCD_LINE2(i+1)),8));
		end generate GEN_LINES;

	  -- LCD
	  lcd_on <= '1';
	  lcd_blon <= '1';
	  lcdt: LCD_TEST 
	    port map
	    (	--	Host Side
				iCLK      => clock_50,
	      iRST_N    => not arst,
				iLINE1		=> iline1,
				iLINE2		=> iline2,
				--	LCD Side
				LCD_DATA  => lcd_data,
	      LCD_RW    => lcd_rw,
	      LCD_EN    => lcd_en,
	      LCD_RS    => lcd_rs
	   	);

	end block BLK_LCD_TEST;

  -- disable ethernet
  enet_data <= (others => 'Z');
  enet_cs_n <= '1';
  enet_wr_n <= '1';
  enet_rd_n <= '1';
  enet_rst_n <= '0';
  enet_clk <= '0';

  BLK_7_SEG : block

    component SEG7_LUT is
      port 
      (
        iDIG : in std_logic_vector(3 downto 0); 
        oSEG : out std_logic_vector(6 downto 0)
      );
    end component;

  begin
    seg7 <= X"FBEEFBEE";
    
    seg7_0: SEG7_LUT port map (iDIG => seg7(31 downto 28), oSEG => hex7);
    seg7_1: SEG7_LUT port map (iDIG => seg7(27 downto 24), oSEG => hex6);
    seg7_2: SEG7_LUT port map (iDIG => seg7(23 downto 20), oSEG => hex5);
    seg7_3: SEG7_LUT port map (iDIG => seg7(19 downto 16), oSEG => hex4);
    seg7_4: SEG7_LUT port map (iDIG => seg7(15 downto 12), oSEG => hex3);
    seg7_5: SEG7_LUT port map (iDIG => seg7(11 downto 8), oSEG => hex2);
    seg7_6: SEG7_LUT port map (iDIG => seg7(7 downto 4), oSEG => hex1);
    seg7_7: SEG7_LUT port map (iDIG => seg7(3 downto 0), oSEG => hex0);
  end block BLK_7_SEG;
  
  -- *MUST* be high to use 27MHz clock as input
  td_reset <= '1';

  BLK_CHASER : block
    signal pwmen      : std_logic;
    signal chaseen    : std_logic;
  begin
    pchaser: work.pwm_chaser 
      generic map(nleds  => 8, nbits => 8, period => 4, hold_time => 12)
      port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => arst, fade => X"0F", ledout => ledg(7 downto 0));

    -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
    process(clock_50, arst)
      variable pcount     : std_logic_vector(9 downto 0);
      variable pwmen_r    : std_logic;
      variable ccount     : std_logic_vector(18 downto 0);
      variable chaseen_r  : std_logic;
    begin
      pwmen <= pwmen_r;
      chaseen <= chaseen_r;
      if arst = '1' then
        pcount := (others => '0');
        ccount := (others => '0');
      elsif rising_edge(clock_50) then
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

  end block BLK_CHASER;
  
  -- LED chaser
--  process (clock_50, reset)
--    variable count : integer range 0 to 4999999;
--    variable led : std_logic_vector(ledr'left downto ledr'right);
--    variable led_dir : std_logic;
--  begin
--    if reset = '1' then
--      count := 0;
--      led_dir := '0';
--      led := "000000000000000001";
--    elsif rising_edge(clock_50) then
--      if count = 0 then
--        count := 4999999; -- 100ms
--        if (led_dir = '0' and led(led'left) = '1') or (led_dir = '1' and led(led'right) = '1') then
--          led_dir := not led_dir;
--        end if;
--        if led_dir = '0' then
--          led := led(led'left-1 downto led'right) & "0";
--        else
--          led := "0" & led(led'left downto led'right+1);
--        end if;
--      else
--        count := count - 1;
--      end if;
--    end if;
--    -- assign outputs
--    ledr <= led;
--  end process;
		    
end SYN;

