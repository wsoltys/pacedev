library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;

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

end target_top;

architecture SYN of target_top is

  signal init       	: std_logic := '1';
  signal reset_i     	: std_logic := '1';
	signal reset_n			: std_logic := '0';

  signal clk_nios     : std_logic := '0';
  signal clk_sdram    : std_logic := '0';
  
  signal audio_l      : std_logic_vector(15 downto 0) := (others => '0');
  signal audio_r      : std_logic_vector(15 downto 0) := (others => '0');
  
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

  reset_i <= init or not key(0);
	reset_n <= not reset_i;

  pll_inst : entity work.nios_pll
    port map
    (
      inclk0		=> clock_50,
      c0		    => open,
      c1		    => clk_nios,
      c2		    => clk_sdram
    );

  nios_inst : entity work.NIOS_SYSTEM
    port map
    (
      -- 1) global signals:
      clk                                         => clk_nios,
      reset_n                                     => reset_n,

      -- the_PIO_IN
      in_port_to_the_PIO_IN                       => (others => '0'),

      -- the_PIO_ISR
      in_port_to_the_PIO_ISR                      => (others => '0'),

      -- the_PIO_OUT
      out_port_from_the_PIO_OUT                   => open,

      -- the_sb16_avalon_wrapper_0
      coe_audio_l_from_the_sb16_avalon_wrapper_0  => audio_l,
      coe_audio_r_from_the_sb16_avalon_wrapper_0  => audio_r,

      -- the_sdram_cpu
      zs_addr_from_the_sdram_cpu                  => dram_addr,
      zs_ba_from_the_sdram_cpu(1)                 => dram_ba_1,
      zs_ba_from_the_sdram_cpu(0)                 => dram_ba_0,
      zs_cas_n_from_the_sdram_cpu                 => dram_cas_n,
      zs_cke_from_the_sdram_cpu                   => dram_cke,
      zs_cs_n_from_the_sdram_cpu                  => dram_cs_n,
      zs_dq_to_and_from_the_sdram_cpu             => dram_dq,
      zs_dqm_from_the_sdram_cpu(1)                => dram_udqm,
      zs_dqm_from_the_sdram_cpu(0)                => dram_ldqm,
      zs_ras_n_from_the_sdram_cpu                 => dram_ras_n,
      zs_we_n_from_the_sdram_cpu                  => dram_we_n
    );
	
	dram_clk <= clk_sdram;
	
  BLK_AUDIO : block
    alias aud_clk    		: std_logic is clk_nios;
    signal aud_data_l  	: std_logic_vector(audio_l'range);
    signal aud_data_r  	: std_logic_vector(audio_r'range);
  begin

    -- enable each channel independantly for debugging
    -- convert to 16-bit signed 2'complement
    aud_data_l <= (audio_l - X"8000") when sw(9) = '0' else (others => '0');
    aud_data_r <= (audio_r - X"8000") when sw(8) = '0' else (others => '0');

    -- Audio
    audif_inst : entity work.audio_if
      generic map 
      (
        REF_CLK       => 18432000,  -- Set REF clk frequency here
        SAMPLE_RATE   => 48000,     -- 48000 samples/sec
        DATA_WIDTH    => 16,			  --	16		Bits
        CHANNEL_NUM   => 2  			  --	Dual Channel
      )
      port map
      (
        -- Inputs
        clk           => aud_clk,
        reset         => reset_i,
        datal         => aud_data_l,
        datar         => aud_data_r,
    
        -- Outputs
        aud_xck       => aud_xck,
        aud_adclrck   => aud_adclrck,
        aud_daclrck   => aud_daclrck,
        aud_bclk      => aud_bclk,
        aud_dacdat    => aud_dacdat,
        next_sample   => open
      );

  end block BLK_AUDIO;
  
  -- disable SD card
  sd_clk <= '0';
  sd_dat <= 'Z';
  sd_dat3 <= 'Z';
  sd_cmd <= 'Z';

  -- disable JTAG
  tdo <= 'Z';
  
  -- *MUST* be high to use 27MHz clock as input
  -- td_reset <= '1';

  -- GPIO

  BLK_AV : block
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
    av_init : I2C_AV_Config
      port map
      (
        --	Host Side
        iCLK							=> clock_50,
        iRST_N						=> reset_n,
        
        --	I2C Side
        I2C_SCLK					=> I2C_SCLK,
        I2C_SDAT					=> I2C_SDAT
      );
  end block BLK_AV;

  BLK_CHASER : block
    signal pwmen      	: std_logic;
    signal chaseen    	: std_logic;
  begin
  
    pchaser: entity work.pwm_chaser 
      generic map(nleds  => 8, nbits => 8, period => 4, hold_time => 12)
      port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => reset_i, fade => X"0F", ledout => ledg(7 downto 0));

    -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
    process(clock_50, reset_i)
      variable pcount     : std_logic_vector(9 downto 0);
      variable pwmen_r    : std_logic;
      variable ccount     : std_logic_vector(18 downto 0);
      variable chaseen_r  : std_logic;
    begin
      pwmen <= pwmen_r;
      chaseen <= chaseen_r;
      if reset_i = '1' then
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

  BLK_7_SEG : block
  
    component SEG7_LUT is
      port 
      (
        iDIG : in std_logic_vector(3 downto 0); 
        oSEG : out std_logic_vector(6 downto 0)
      );
    end component SEG7_LUT;

  begin
    -- from left to right on the PCB
    --seg7_3: SEG7_LUT port map (iDIG => gp_o.d(51 downto 48), oSEG => hex3);
    --seg7_2: SEG7_LUT port map (iDIG => gp_o.d(47 downto 44), oSEG => hex2);
    --seg7_1: SEG7_LUT port map (iDIG => gp_o.d(43 downto 40), oSEG => hex1);
    --seg7_0: SEG7_LUT port map (iDIG => gp_o.d(39 downto 36), oSEG => hex0);
  end block BLK_7_SEG;
  
end SYN;
