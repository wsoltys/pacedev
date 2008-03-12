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

entity target_top is
generic
  (
    BOARD_REV             : std_logic_vector (7 downto 0) := X"A2"
  );
port
  (
    -- clocking
    clock0            : in std_logic;
    clock8            : in std_logic;
                      
    -- ethernet       
    COL_enet          : in std_logic;
    CRS_enet          : in std_logic;
    RXCLK_enet        : in std_logic;
    RXD_enet          : in std_logic_vector(3 downto 0);
    RXDV_enet         : in std_logic;
    RXER_enet         : in std_logic;
    TXCLK_enet        : in std_logic;
    MDIO_enet         : inout std_logic;
    MDC_enet          : out std_logic;
    TXD_enet          : out std_logic_vector(3 downto 0);
    TXEN_enet         : out std_logic;
    TXER_enet         : out std_logic;
    RESET_enet        : out std_logic;
    RIP_enet          : in std_logic;
    MDINT_enet        : in std_logic;
                      
    -- PIO            
    mac_addr          : inout std_logic;
    sw2_1             : in std_logic;
    led               : out std_logic;
    ext_enable        : in std_logic;
                      
    -- sdram 1 MEB
    clk_dr1           : out std_logic;
    a_dr1             : out std_logic_vector(12 downto 0);
    ba_dr1            : out std_logic_vector(1 downto 0);
    ncas_dr1          : out std_logic;
    cke_dr1           : out std_logic;
    ncs_dr1           : out std_logic;
    d_dr1             : inout std_logic_vector(31 downto 0);
    dqm_dr1           : out std_logic_vector(1 downto 0);
    nras_dr1          : out std_logic;
    nwe_dr1           : out std_logic;
    
    -- sdram 2 NIOS
    clk_dr2           : out std_logic;
    a_dr2             : out std_logic_vector(12 downto 0);
    ba_dr2            : out std_logic_vector(1 downto 0);
    ncas_dr2          : out std_logic;
    cke_dr2           : out std_logic;
    ncs_dr2           : out std_logic;
    d_dr2             : inout std_logic_vector(31 downto 0);
    dqm_dr2           : out std_logic_vector(3 downto 0);
    nras_dr2          : out std_logic;
    nwe_dr2           : out std_logic;

    -- compact flash
    iordy0_cf         : in std_logic;
    rdy_irq_cf        : in std_logic;
    cd_cf             : in std_logic;
    a_cf              : out std_logic_vector(2 downto 0);
    nce_cf            : out std_logic_vector(2 downto 1);
    d_cf              : inout std_logic_vector(15 downto 0);
    nior0_cf          : out std_logic;
    niow0_cf          : out std_logic;
    non_cf            : out std_logic;
    reset_cf          : out std_logic;
    ndmack_cf         : out std_logic;
    dmarq_cf          : in std_logic;

		-- GAT serial port
		gat_txd						  : out std_logic;
		gat_rxd						  : in std_logic;
		
		-- I2C
		clk_ee							  : inout std_logic;
		data_ee							  : inout std_logic;
		
    -- System ROMS
		nromsoe					  : out std_logic;
		
		-- MEB
    bd                : inout std_logic_vector(31 downto 0);
    ba25              : out std_logic;
    ba24              : out std_logic;
    ba23              : in std_logic;
    ba22              : out std_logic;
    ba21              : in std_logic;
    ba20              : out std_logic;
    ba19              : in std_logic;
    ba18              : in std_logic;
    ba17              : in std_logic;
    ba16              : inout std_logic;
    ba15              : in std_logic;
    ba14              : inout std_logic;
    ba13              : in std_logic;
    ba12              : in std_logic;
    ba11              : in std_logic;
    ba10              : in std_logic;
    ba9               : out std_logic;
    ba8               : in std_logic;
    ba7               : in std_logic;
    ba6               : out std_logic;
    ba5               : in std_logic;
    ba4               : out std_logic;
    ba3               : out std_logic;
    ba2               : in std_logic;
		nmebwait				  : out std_logic; 
		nmebint					  : in std_logic;
		nbwr						  : in std_logic;
		nreset2					  : in std_logic;
		nromsdis				  : out std_logic;
		butres					  : in std_logic;
		nromgdis				  : out std_logic;
		nbrd						  : in std_logic;
		nbcs2						  : in std_logic;
		nbcs4						  : in std_logic;
		nbcs0						  : in std_logic;	
		
		-- MEMORY
    ba_ns							: out std_logic_vector(19 downto 0);
    bd_ns							: inout std_logic_vector(31 downto 0);
    nwe_s             : out std_logic;    -- sram only
    ncs_s             : out std_logic;    -- sram only
    nce_n             : out std_logic;    -- eeprom only
    noe_ns            : out std_logic;

    -- JTAG
    tdi               : in std_logic;
    tck               : in std_logic;
    tms               : in std_logic;
    tdo               : out std_logic
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

  alias clk_24M       : std_logic is clock8;
  alias audio_left    : std_logic is ba9;
  alias audio_right   : std_logic is ba20;
  alias ps2_kclk      : std_logic is ba16;
  alias ps2_kdat      : std_logic is ba14;
	alias ps2_mclk      : std_logic is bd(14);
	alias ps2_mdat      : std_logic is bd(10);
  alias sd_cmd        : std_logic is bd(1);
  alias sd_dat3       : std_logic is bd(9);
  alias sd_clk        : std_logic is bd(15);
  alias sd_dat        : std_logic is bd(7);
  alias hsync         : std_logic is ba22;
  alias vsync         : std_logic is nromsdis;

  signal init        	: std_logic;
	signal reset				: std_logic;
	
	signal ad724_stnd		: std_logic;
	signal red_s				: std_logic_vector(9 downto 0);
	signal blue_s				: std_logic_vector(9 downto 0);
	signal green_s			: std_logic_vector(9 downto 0);

  signal snd_data_l   : std_logic_vector(15 downto 0);
  signal snd_data_r   : std_logic_vector(15 downto 0);

	signal bd_out				: std_logic_vector(31 downto 0);

	signal ps2clk_s			: std_logic;
	signal ps2dat_s			: std_logic;
		
	signal gpio_i				: std_logic_vector(9 downto 2);
	signal gpio_o				: std_logic_vector(gpio_i'range);
	signal gpio_oe			: std_logic_vector(gpio_i'range);
	
begin

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock0)
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clock0) then
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
	reset <= init or sw2_1;
		
  de1_top_inst : de1_top
    port map
    (
      --////////////////////	Clock Input	 	////////////////////	 
      clock_27(1)   => clock0,  -- 24Mhz
      clock_27(0)   => clock0,  -- 24Mhz
      clock_50      => clock8,  -- 24Mhz
      ext_clock     => '0',     -- not supported
      --////////////////////	Push Button		////////////////////
      key           => (others => '1'),
      --////////////////////	DPDT Switch		////////////////////
      sw            => (others => '0'),
      --////////////////////	7-SEG Dispaly	////////////////////
      hex0          => open,
      hex1          => open,
      hex2          => open,
      hex3          => open,
      --////////////////////////	LED		////////////////////////
      ledg          => open,
      ledr          => open,
      --////////////////////////	UART	////////////////////////
      uart_txd      => gat_txd,
      uart_rxd      => gat_rxd,
      --////////////////////////	IRDA	////////////////////////
      -- irda_txd      : out std_logic;                        --	IRDA Transmitter
      -- irda_rxd      : in std_logic;                         --	IRDA Receiver
      --/////////////////////	SDRAM Interface		////////////////
      dram_dq       => d_dr2(15 downto 0),
      dram_addr     => a_dr2(11 downto 0),
      dram_ldqm     => dqm_dr2(1),
      dram_udqm     => dqm_dr2(0),
      dram_we_n     => nwe_dr2,
      dram_cas_n    => ncas_dr2,
      dram_ras_n    => nras_dr2,
      dram_cs_n     => ncs_dr2,
      dram_ba_0     => ba_dr2(0),
      dram_ba_1     => ba_dr2(1),
      dram_clk      => clk_dr2,
      dram_cke      => cke_dr2,
      --////////////////////	Flash Interface		////////////////
      fl_dq         => open,
      fl_addr       => open,
      fl_we_n       => open,
      fl_rst_n      => open,
      fl_oe_n       => open,
      fl_ce_n       => open,
      --////////////////////	SRAM Interface		////////////////
      sram_dq       => bd_ns(15 downto 0),
      sram_addr     => ba_ns(17 downto 0),
      sram_ub_n     => open,
      sram_lb_n     => open,
      sram_we_n     => nwe_s,
      sram_ce_n     => ncs_s,
      sram_oe_n     => noe_ns,
      --////////////////////	SD_Card Interface	////////////////
      sd_dat        => sd_dat,
      sd_dat3       => sd_dat3,
      sd_cmd        => sd_cmd,
      sd_clk        => sd_clk,
      --////////////////////	USB JTAG link	////////////////////
      tdi           => tdi,
      tck           => tck,
      tcs           => tms,
      tdo           => tdo,
      --////////////////////	I2C		////////////////////////////
      i2c_sdat      => open,
      i2c_sclk      => open,
      --////////////////////	PS2		////////////////////////////
      ps2_dat       => ps2_kdat,
      ps2_clk       => ps2_kclk,
      --////////////////////	VGA		////////////////////////////
      vga_clk       => open,
      vga_hs        => hsync,
      vga_vs        => vsync,
      vga_blank     => open,
      vga_sync      => open,
      vga_r         => red_s(9 downto 6),
      vga_g         => green_s(9 downto 6),
      vga_b         => blue_s(9 downto 6),
      --////////////////	Audio CODEC		////////////////////////
      aud_adclrck   => open,
      aud_adcdat    => '0',
      aud_daclrck   => open,
      aud_dacdat    => open,
      aud_bclk      => open,
      aud_xck       => open,
      --////////////////////	GPIO	////////////////////////////
      gpio_0        => open,
      gpio_1        => open
    );

  -- unused SRAM address lines
  ba_ns(19 downto 19) <= (others => '0');
  -- unused SDRAM lines
  a_dr2(12) <= '0';
  dqm_dr2(3 downto 2) <= (others => '0');

	-- assign video outputs
	bd_out(20) <= red_s(9);
	bd_out(27) <= red_s(8);
	bd_out(30) <= red_s(7);
	bd_out(22) <= red_s(6);
	ba25 <= green_s(9);
	nromgdis <= green_s(8);
	bd_out(26) <= green_s(7);
	bd_out(28) <= green_s(6);
	bd_out(16) <= blue_s(9);
	bd_out(23) <= blue_s(8);
	bd_out(24) <= blue_s(7);
	ba24 <= blue_s(6);

	-- drive encoder enable
	ba3 <= PACE_ENABLE_ADV724;
	
	-- drive PAL/NTSC selector
	ad724_stnd <= PACE_ADV724_STD;
	
	ba6 <= ad724_stnd;
	ba4 <= not ad724_stnd;

	-- GPIO - not driven
	gpio_oe <= (others => '0');

  -- audio PWM
  -- clock is 24Mhz, sample rate 24kHz
  process (clk_24M, reset)
    variable count : integer range 0 to 1023;
    variable audio_sample_l : std_logic_vector(9 downto 0);
    variable audio_sample_r : std_logic_vector(9 downto 0);
  begin
    if reset = '1' then
      count := 0;
    elsif rising_edge(clk_24M) then
      if count = 1023 then
        -- 24kHz tick - latch a sample (only 10 bits or 1024 steps)
        audio_sample_l := snd_data_l(snd_data_l'left downto snd_data_l'left-9);
        audio_sample_r := snd_data_r(snd_data_r'left downto snd_data_l'left-9);
        count := 0;
      else
        audio_left <= '0';  -- default
        audio_right <= '0'; -- default
        if audio_sample_l > count then
          audio_left <= '1';
        end if;
        if audio_sample_r > count then
          audio_right <= '1';
        end if;
        count := count + 1;
      end if;
    end if;
  end process;
  
	-- drive active-low SRAM signals
	--ncs_s <= not sram_o.cs;
	--noe_ns <= not sram_o.oe;
	--nwe_s <= not sram_o.we;
	
	GEN_NO_ENET : if true generate
		MDIO_enet <= 'Z';
		MDC_enet <= 'Z';
		TXD_enet <= (others => 'Z');
		TXEN_enet <= 'Z';
		TXER_enet <= 'Z';
		RESET_enet <= 'Z';
	end generate GEN_NO_ENET;
		
	GEN_NO_SSN : if true generate
		mac_addr <= 'Z';
	end generate GEN_NO_SSN;
	
	GEN_NO_SDRAM_1 : if true generate
		clk_dr1 <= '1';
		a_dr1 <= (others => 'Z');
		ba_dr1 <= (others => 'Z');
		ncas_dr1 <= 'Z';
		cke_dr1 <= 'Z';
		ncs_dr1 <= 'Z';
		d_dr1 <= (others => 'Z');
		dqm_dr1 <= (others => 'Z');
		nras_dr1 <= 'Z';
		nwe_dr1 <= '1';
	end generate GEN_NO_SDRAM_1;
	
	GEN_NO_SDRAM_2 : if false generate
		clk_dr2 <= '1';
		a_dr2 <= (others => 'Z');
		ba_dr2 <= (others => 'Z');
		ncas_dr2 <= 'Z';
		cke_dr2 <= 'Z';
		ncs_dr2 <= 'Z';
		d_dr2 <= (others => 'Z');
		dqm_dr2 <= (others => 'Z');
		nras_dr2 <= 'Z';
		nwe_dr2 <= '1';
	end generate GEN_NO_SDRAM_2;
	
	GEN_NO_CF : if true generate
		a_cf <= (others => 'Z');
		d_cf <= (others => 'Z');
		nce_cf <= (others => 'Z');
		nior0_cf <= 'Z';
		niow0_cf <= 'Z';
		non_cf <= '1';
		reset_cf <= 'Z';
		ndmack_cf <= 'Z';
	end generate GEN_NO_CF;

	GEN_NO_I2C : if true generate
		clk_ee <= 'Z';
		data_ee <= 'Z';
	end generate GEN_NO_I2C;
	
	nromsoe <= 'Z';
	nmebwait <= 'Z';
	nce_n <= 'Z';
	bd_out(18) <= 'Z';
	bd_out(25) <= 'Z';
					
	-- GPIO inputs					
	gpio_i(2) <= bd(15);
	gpio_i(3) <= ba18;
	gpio_i(4) <= bd(7);
	gpio_i(5) <= bd(1);
	gpio_i(6) <= bd(14);
	gpio_i(7) <= bd(9);
	gpio_i(8) <= bd(10);
	gpio_i(9) <= bd(4);
	
	-- GPIO drivers
	--bd(15) <= gpio_o(2) when gpio_oe(2) = '1' else 'Z'; -- sd_clk
	--ba18 <= gpio_o(3) when gpio_oe(3) = '1' else 'Z'; -- input only
	--bd(7) <= gpio_o(4) when gpio_oe(4) = '1' else 'Z'; -- sd_dat
	--bd(1) <= gpio_o(5) when gpio_oe(5) = '1' else 'Z'; -- sd_cmd
	--bd(14) <= gpio_o(6) when gpio_oe(6) = '1' else 'Z'; -- ps2_mclk
	--bd(9) <= gpio_o(7) when gpio_oe(7) = '1' else 'Z'; -- sd_dat3
	--bd(10) <= gpio_o(8) when gpio_oe(8) = '1' else 'Z'; -- ps2_mdat
	--bd(4) <= gpio_o(9) when gpio_oe(9) = '1' else 'Z'; -- gamecube data io
	
	-- BD drivers
	bd(0) <= 'Z';
	bd(2) <= 'Z';
	bd(3) <= 'Z';
	bd(5) <= 'Z';
	bd(6) <= 'Z';
	bd(8) <= 'Z';
	bd(11) <= 'Z';
	bd(12) <= 'Z';
	bd(13) <= 'Z';
	bd(16) <= bd_out(16);
	bd(17) <= 'Z';
	bd(18) <= bd_out(18);
	bd(19) <= 'Z';
	bd(20) <= bd_out(20);
	bd(21) <= 'Z';
	bd(22) <= bd_out(22);
	bd(23) <= bd_out(23);
	bd(24) <= bd_out(24);
	bd(25) <= bd_out(25);
	bd(26) <= bd_out(26);
	bd(27) <= bd_out(27);
	bd(28) <= bd_out(28);
	bd(29) <= 'Z';
	bd(30) <= bd_out(30);
	bd(31) <= 'Z';

	-- flash the led so we know it's alive
	process (clk_24M, reset)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk_24M) then
			count := count + 1;
		end if;
		led <= count(count'left);
	end process;

end SYN;
