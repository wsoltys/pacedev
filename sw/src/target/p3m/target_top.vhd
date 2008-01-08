library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
generic
  (
    BOARD_REV         : std_logic_vector (3 downto 0) := X"A"
  );
port
  (
    -- clocking
    clock             : in std_logic;
    power_button      : out std_logic;
                      
    -- sdram 1 MEB
    sdram_clock       : out std_logic;
    sdram_addr        : out std_logic_vector(12 downto 0);
    sdram_ba          : out std_logic_vector(1 downto 0);
    sdram_ncas        : out std_logic;
    sdram_cke         : out std_logic;
    sdram_ncs         : out std_logic;
    sdram_dq          : inout std_logic_vector(15 downto 0);
    sdram_dqm         : out std_logic_vector(1 downto 0);
    sdram_nras        : out std_logic;
    sdram_nwe         : out std_logic;

    -- flash
		flash_a						: out std_logic_vector(21 downto 0);
		flash_d						: inout std_logic_vector(15 downto 0);
    flash_ce          : out std_logic;
		flash_oe					: out std_logic;
		flash_we					: out std_logic;
		flash_byte				: out std_logic;
		flash_rp					: out std_logic;		-- reset/block temporary unprotect
		flash_rb					: in std_logic;			-- read busy

		-- i2c DAC
		max_ad_scl				: inout std_logic;
		max_ad_sda				: inout std_logic;
		
    -- e2c
    eeprom_cs         : out std_logic;

    -- video
		lcd_dclk					: out std_logic;
    lcd_red           : out std_logic_vector(5 downto 0);
    lcd_green         : out std_logic_vector(5 downto 0);
    lcd_blue          : out std_logic_vector(5 downto 0);
    lcd_hsync         : out std_logic;
    lcd_pci           : out std_logic;
    lcd_led           : out std_logic;
    lcd_dtmg          : out std_logic;

		-- SD/MMC
		-- SD (SD/SPI Mode) pins
		mmc1							: inout std_logic;
		mmc2							: inout std_logic;
		mmc5							: out std_logic;
		mmc7							: inout std_logic;
		mmc8							: inout std_logic;
		mmc9							: inout std_logic;
		-- MMC pins
		mmc10							: in std_logic;
		mmc11							: in std_logic;
		mmca							: in std_logic;
		mmcb							: in std_logic;
		mmcc							: in std_logic;
		mmcd							: in std_logic;
		mmc_cd						: in std_logic;
		mmc_wp						: in std_logic;
		
		-- gpio
		gpio1							: in std_logic;
		gpio3							: in std_logic;
		gpio5							: in std_logic;
		gpio6							: in std_logic;
		gpio7							: in std_logic;
		gpio8							: in std_logic;
		gpio9							: in std_logic;
		
    -- misc
    st1               : in std_logic;
    st2               : in std_logic;
    batt_shutdown     : out std_logic
  );
end target_top;

architecture SYN of target_top is

  alias clk_24M576    : std_logic is clock;

	-- SD (SD Mode)
	alias sd_cd_dat3		: std_logic is mmc1;
	alias sd_cmd				: std_logic is mmc2;
	alias sd_clk				: std_logic is mmc5;
	alias sd_dat0				: std_logic is mmc7;
	alias sd_dat1				: std_logic is mmc8;
	alias sd_dat2				: std_logic is mmc9;
	-- SD (SPI Mode)
	alias sd_spi_cs			: std_logic is mmc1;
	alias sd_spi_di			: std_logic is mmc2;
	alias sd_spi_sclk		: std_logic is mmc5;
	alias sd_spi_do			: std_logic is mmc7;
	
  signal clk          : std_logic_vector(0 to 3);
  signal init        	: std_logic;
	signal reset				: std_logic;

	signal ps2clk_s			: std_logic;
	signal ps2dat_s			: std_logic;
	signal jamma_s			: JAMMAInputsType;

  signal hblank_s     : std_logic;
  signal vblank_s     : std_logic;
	signal lcd_vblank		: std_logic;
		
begin

  -- hold power supply
  power_button <= '0';
  batt_shutdown <= '0';

	ps2clk_s <= gpio3;
	ps2dat_s <= gpio1;
	
	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clk_24M576)
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clk_24M576) then
			if count = X"FF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

	reset <= init;
		
  -- unused clocks on P3M
  clk(2) <= '0';
  clk(3) <= '0';

	GEN_PLL : if PACE_HAS_PLL generate
	
	  pll_inst : entity work.pll
	    generic map
	    (
        -- INCLK0
        INCLK0_INPUT_FREQUENCY  => 40690,

	      -- CLK0
	      CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
	      CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
	  
	      -- CLK1
	      CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
	      CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
	    )
	    port map
	    (
	      inclk0  => clk_24M576,
	      c0      => clk(0),
	      c1      => clk(1)
	    );
  
	end generate GEN_PLL;
	
	GEN_NO_PLL : if not PACE_HAS_PLL generate

		-- feed input clocks into PACE core
		clk(0) <= clk_24M576;
		clk(1) <= clk_24M576;
			
	end generate GEN_NO_PLL;
	
	GEN_NO_SDRAM : if true generate
		sdram_clock <= '1';
		sdram_addr <= (others => 'Z');
		sdram_ba <= (others => 'Z');
		sdram_ncas <= 'Z';
		sdram_cke <= 'Z';
		sdram_ncs <= 'Z';
		sdram_dq <= (others => 'Z');
		sdram_dqm <= (others => 'Z');
		sdram_nras <= 'Z';
		sdram_nwe <= '1';
	end generate GEN_NO_SDRAM;
	
	assert (not (P3M_JAMMA_IS_MAPLE and P3M_JAMMA_IS_GAMECUBE))
		report "Cannot choose both MAPLE and GAMECUBE interfaces"
		severity error;
	
	GEN_NO_JAMMA : if not P3M_JAMMA_IS_GAMECUBE generate
	
		jamma_s.coin(1) <= '1';
		jamma_s.p(1).start <= '1';
		jamma_s.p(1).up <= '1';
		jamma_s.p(1).down <= '1';
		jamma_s.p(1).left <= '1';
		jamma_s.p(1).right <= '1';
		jamma_s.p(1).button <= (others => '1');

	end generate GEN_NO_JAMMA;	

	jamma_s.coin_cnt <= (others => '1');
	jamma_s.service <= '1';
	jamma_s.tilt <= '1';
	jamma_s.test <= '1';
	
	-- no player 2
	jamma_s.coin(2) <= '1';
	jamma_s.p(2).start <= '1';
	jamma_s.p(2).up <= '1';
	jamma_s.p(2).down <= '1';
	jamma_s.p(2).left <= '1';
	jamma_s.p(2).right <= '1';
	jamma_s.p(2).button <= (others => '1');

  -- generate lcd backlight PWM output
  process (clk_24M576, reset)
    variable count : std_logic_vector(17 downto 0);
  begin
    if reset = '1' then
      count := (others => '0');
    elsif rising_edge(clk_24M576) then
      count := count + 1;
    end if;
    lcd_led <= count(count'left);
  end process;

  -- generate other LCD signals
	-- lcm_data(1) is lcd_vblank
  lcd_dtmg <= not (lcd_vblank or hblank_s);
  lcd_pci <= '1';

  sd_clk <= 'Z';
  sd_cmd <= 'Z';
  sd_dat0 <= 'Z';	
	-- ensure weak pullups on these pins
	sd_cd_dat3 <= 'Z';
	sd_dat1 <= 'Z';
	sd_dat2 <= 'Z';

  -- some unused stuff
	flash_a <= (others => 'X');
  flash_ce <= '1';
	flash_oe <= '1';
	flash_we <= '1';
	flash_byte <= '1';
	flash_rp <= '1';
  eeprom_cs <= '1'; -- rename this to eeprom_cs_n

	PACE_INST : entity work.PACE
	  port map
	  (
	     -- clocks and resets
			clk								=> clk,
			test_button      	=> '0',
	    reset            	=> reset,

	    -- game I/O
	    ps2clk           	=> ps2clk_s,
	    ps2data          	=> ps2dat_s,
	    dip              	=> (others => '0'),
			jamma							=> jamma_s,
			
	    -- external RAM
	    sram_i.d        	=> (others => 'X'),
	    sram_o        		=> open,

	    -- VGA video
			lcm_data(0)				=> lcd_dclk,
			lcm_data(1)				=> lcd_vblank,
	    red(9 downto 4)   => lcd_red,
	    green(9 downto 4) => lcd_green,
	    blue(9 downto 4)  => lcd_blue,
	    hsync            	=> lcd_hsync,
	    vsync            	=> open,
      hblank            => hblank_s,
      vblank            => vblank_s,

	    -- composite video
	    BW_CVBS          	=> open,
	    GS_CVBS          	=> open,

	    -- sound
	    snd_clk          	=> open,
	    snd_data         	=> open,

	    -- SPI (flash)
	    spi_clk          	=> open,
	    spi_mode         	=> open,
	    spi_sel          	=> open,
	    spi_din          	=> '0',
	    spi_dout         	=> open,

	    -- serial
	    ser_tx           	=> open,
	    ser_rx           	=> 'X',

	    -- debug
	    leds             	=> open
	  );

end SYN;
