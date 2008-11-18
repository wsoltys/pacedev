library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
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
	
	signal clk_i			  : std_logic_vector(0 to 3);
  signal init       	: std_logic := '1';
  signal reset_i     	: std_logic := '1';
	signal reset_n			: std_logic := '0';

  signal buttons_i    : from_BUTTONS_t;
  signal switches_i   : from_SWITCHES_t;
  signal leds_o       : to_LEDS_t;
  signal inputs_i     : from_INPUTS_t;
  signal flash_i      : from_FLASH_t;
  signal flash_o      : to_FLASH_t;
	signal sram_i			  : from_SRAM_t;
	signal sram_o			  : to_SRAM_t;	
	signal sdram_i      : from_SDRAM_t;
	signal sdram_o      : to_SDRAM_t;
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  
begin

  BLK_CLOCKING : block
  begin

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
          c0      => clk_i(0),
          c1      => clk_i(1)
        );
    
    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clk_i(0) <= clk_24M576;
      clk_i(1) <= clk_24M576;
        
    end generate GEN_NO_PLL;

    -- unused clocks on P3M
    clk_i(2) <= '0';
    clk_i(3) <= '0';
	
  end block BLK_CLOCKING;
  
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

  -- hold power supply
  power_button <= '0';
  batt_shutdown <= '0';

	reset_i <= init;
		
  -- buttons - active low
  buttons_i <= std_logic_vector(to_unsigned(0, buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(to_unsigned(0, switches_i'length));
  -- leds
  -- (none)

	inputs_i.ps2_kclk <= gpio3;
	inputs_i.ps2_kdat <= gpio1;
  inputs_i.ps2_mclk <= '0';
  inputs_i.ps2_mdat <= '0';
	
	GEN_NO_JAMMA : if PACE_JAMMA = PACE_JAMMA_NONE generate
		inputs_i.jamma_n.coin(1) <= '1';
		inputs_i.jamma_n.p(1).start <= '1';
		inputs_i.jamma_n.p(1).up <= '1';
		inputs_i.jamma_n.p(1).down <= '1';
		inputs_i.jamma_n.p(1).left <= '1';
		inputs_i.jamma_n.p(1).right <= '1';
		inputs_i.jamma_n.p(1).button <= (others => '1');
  end generate GEN_NO_JAMMA;
  
	-- not currently wired to any inputs
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

  BLK_FLASH : block
  begin
    flash_a <= (others => 'X');
    flash_ce <= '1';
    flash_oe <= '1';
    flash_we <= '1';
    flash_byte <= '1';
    flash_rp <= '1';
    flash_i.d <= (others => '0');
  end block BLK_FLASH;

  GEN_NO_SRAM : if true generate
    sram_i.d <= (others => '1');
  end generate GEN_NO_SRAM;

  BLK_SDRAM : block
  begin
  
    GEN_NO_SDRAM : if not PACE_HAS_SDRAM generate
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
	
    GEN_SDRAM : if PACE_HAS_SDRAM generate
      sdram_i.d <= std_logic_vector(resize(unsigned(sdram_dq), sdram_i.d'length));
      sdram_dq <= sdram_o.d(sdram_dq'range) when sdram_o.we_n = '0' else (others => 'Z');
      sdram_addr <= sdram_o.a(sdram_addr'range);
      sdram_dqm(1) <= sdram_o.ldqm;
      sdram_dqm(0) <= sdram_o.udqm;
      sdram_nwe <= sdram_o.we_n;
      sdram_ncas <= sdram_o.cas_n;
      sdram_nras <= sdram_o.ras_n;
      sdram_ncs <= sdram_o.cs_n;
      sdram_ba <= sdram_o.ba;
      sdram_clock <= sdram_o.clk;
      sdram_cke <= sdram_o.cke;
    end generate GEN_SDRAM;

  end block BLK_SDRAM;
  
  BLK_VIDEO : block
  begin

		video_i.clk <= clk_i(1);	-- by convention

    -- video requires 5.568MHz clock
    -- - PLL can't generate that low, so derive from 11.136MHz
    process (video_i.clk, reset_i)
    begin
      if reset_i = '1' then
        video_i.clk_ena <= '0';
      elsif rising_edge(video_i.clk) then
        video_i.clk_ena <= not video_i.clk_ena;
      end if;
    end process;

    lcd_dclk <= video_i.clk_ena;
    lcd_red <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-5);
    lcd_green <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-5);
    lcd_blue <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-5);
    lcd_hsync <= video_o.hsync;

    -- generate other LCD signals
    -- lcm_data(1) is lcd_vblank
    lcd_dtmg <= not (video_o.vblank or video_o.hblank);
    lcd_pci <= '1';

    -- generate lcd backlight PWM output
    process (clk_24M576, reset_i)
      variable count : std_logic_vector(17 downto 0);
    begin
      if reset_i = '1' then
        count := (others => '0');
      elsif rising_edge(clk_24M576) then
        count := count + 1;
      end if;
      lcd_led <= count(count'left);
    end process;

  end block BLK_VIDEO;

  sd_clk <= 'Z';
  sd_cmd <= 'Z';
  sd_dat0 <= 'Z';	
	-- ensure weak pullups on these pins
	sd_cd_dat3 <= 'Z';
	sd_dat1 <= 'Z';
	sd_dat2 <= 'Z';

  -- some unused stuff
  eeprom_cs <= '1'; -- rename this to eeprom_cs_n

  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clk_i							=> clk_i,
      reset_i          	=> reset_i,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => leds_o,
      
      -- controller inputs
      inputs_i          => inputs_i,

     	-- external ROM/RAM
     	flash_i           => flash_i,
      flash_o           => flash_o,
      sram_i        		=> sram_i,
      sram_o        		=> sram_o,
     	sdram_i           => sdram_i,
     	sdram_o           => sdram_o,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i.din         => '0',
      spi_o             => open,
  
      -- serial
      ser_i             => ser_i,
      ser_o             => ser_o,
      
      -- general purpose
      gp_i              => (others => '0'),
      gp_o              => open
    );

end SYN;
