library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
port
  (
    -- clocking
    clk_48M           : in std_logic;
    exp_clk0			    : in std_logic;
    exp_clk1			    : in std_logic;

    -- output LEDs
    led               : out std_logic_vector(7 downto 0);
    
    -- 7-segment display #0
    seven_seg0_a      : out std_logic;
    seven_seg0_b      : out std_logic;
    seven_seg0_c      : out std_logic;
    seven_seg0_d      : out std_logic;
    seven_seg0_e      : out std_logic;
    seven_seg0_f      : out std_logic;
    seven_seg0_g      : out std_logic;
    seven_seg0_dp     : out std_logic;
    
    -- 7-segment display #1
    seven_seg1_a      : out std_logic;
    seven_seg1_b      : out std_logic;
    seven_seg1_c      : out std_logic;
    seven_seg1_d      : out std_logic;
    seven_seg1_e      : out std_logic;
    seven_seg1_f      : out std_logic;
    seven_seg1_g      : out std_logic;
    seven_seg1_dp     : out std_logic;

    -- joystick
    joy_left          : in std_logic;
    joy_right         : in std_logic;
    joy_up            : in std_logic;
    joy_down          : in std_logic;
    joy_fire          : in std_logic;
    
    -- PS/2
    mouse_data        : inout std_logic;
    mouse_clk         : inout std_logic;
    keybd_data        : inout std_logic;
    keybd_clk         : inout std_logic;
    
    -- serial
    rs232_cts         : in std_logic;
    rs232_rx          : in std_logic;
    rs232_rts         : out std_logic;
    rs232_tx          : out std_logic;
    
    -- ADC0
    adc0_data         : in std_logic_vector(9 downto 0);
    adc0_trigger      : out std_logic;
    adc0_dc_offset    : out std_logic;
    adc0_standby      : out std_logic;
    adc0_irs          : out std_logic;
    adc0_clock        : out std_logic;
    
    -- ADC1
    adc1_data         : in std_logic_vector(9 downto 0);
    adc1_trigger      : out std_logic;
    adc1_dc_offset    : out std_logic;
    adc1_standby      : out std_logic;
    adc1_irs          : out std_logic;
    adc1_clock        : out std_logic;
    
    adc_shutdown_n    : out std_logic;
    
    -- vga
    red               : out std_logic_vector(6 downto 0);
    green             : out std_logic_vector(6 downto 0);
    blue              : out std_logic_vector(6 downto 0);
    hsync             : out std_logic;
    vsync             : out std_logic;
    ddc_data          : out std_logic;
    ddc_clock         : out std_logic;
    
    -- lcd
    lcd_data          : out std_logic_vector(7 downto 0);
    lcd_enable        : out std_logic;
    
    -- camera
    cam_reset         : out std_logic;
    cam_pwr_dn        : out std_logic;
    cam_sccb_data     : in std_logic;
    cam_sccb_clk      : in std_logic;
    cam_vsync         : in std_logic;
    cam_href          : in std_logic;
    cam_xtal_clk      : in std_logic;
    cam_clk_out       : in std_logic;
    cam_data          : in std_logic_vector(9 downto 0);
    
    -- audio
    audio_left        : out std_logic;
    audio_right       : out std_logic;
    piezo_0           : out std_logic;
    piezo_1           : out std_logic;
    
    -- usb micro
    usb_data          : inout std_logic_vector(7 downto 0);
    usb_we            : out std_logic;
    usb_fifo_full     : in std_logic;
    usb_fifo_empty    : in std_logic;
    usb_gpif          : in std_logic_vector(3 downto 0);
    
    -- CAN
    can_driver_in     : in std_logic;
    can_rx_out        : out std_logic;
    can_standby       : out std_logic;
    
    -- servo motor
    servo_pwm         : out std_logic_vector(3 downto 0)
    
    -- expansion header
    -- TBD
  );
end target_top;

architecture SYN of target_top is

	-- so we don't have to include the pll component in the project
	-- if there is no 'pace pll'
	component pll is
	  generic
	  (
	    -- INCLK
	    INCLK0_INPUT_FREQUENCY  : natural;

	    -- CLK0
	    CLK0_DIVIDE_BY      : real := 2.0;
	    CLK0_DUTY_CYCLE     : natural := 50;
	    CLK0_PHASE_SHIFT    : string := "0";

	    -- CLK1
	    CLK1_DIVIDE_BY      : natural := 1;
	    CLK1_DUTY_CYCLE     : natural := 50;
	    CLK1_MULTIPLY_BY    : natural := 1;
	    CLK1_PHASE_SHIFT    : string := "0"
	  );
		port
		(
			inclk0							: in std_logic  := '0';
			c0		    					: out std_logic ;
			c1		    					: out std_logic 
		);
	end component;

  signal clk          : std_logic_vector(0 to 3);
  signal init        	: std_logic;
	signal reset				: std_logic;
	
	signal red_s				: std_logic_vector(9 downto 0);
	signal blue_s				: std_logic_vector(9 downto 0);
	signal green_s			: std_logic_vector(9 downto 0);

  signal snd_data_l   : std_logic_vector(15 downto 0);
  signal snd_data_r   : std_logic_vector(15 downto 0);
  
	signal jamma_s			: JAMMAInputsType;
		
begin

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clk(1))
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clk(1)) then
			if count = X"FF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

	reset <= init;
		
  -- unused clocks on P2
  clk(2) <= exp_clk0;
  clk(3) <= exp_clk1;

	GEN_PLL : if PACE_HAS_PLL generate
	
	  pll_inst : pll
	    generic map
	    (
        -- INCLK0
        INCLK0_INPUT_FREQUENCY  => 20, -- period 20.833ns

	      -- CLK0
	      CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
	  
	      -- CLK1
	      CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
	      CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
	    )
	    port map
	    (
	      inclk0  => clk_48M,
	      c0      => clk(0),
	      c1      => clk(1)
	    );
  
	end generate GEN_PLL;
	
	GEN_NO_PLL : if not PACE_HAS_PLL generate

		-- feed input clocks into PACE core
		clk(0) <= clk_48M;
		clk(1) <= exp_clk0;
			
	end generate GEN_NO_PLL;
	
	assert (not (P2_JAMMA_IS_MAPLE and P2_JAMMA_IS_GAMECUBE))
		report "Cannot choose both MAPLE and GAMECUBE interfaces"
		severity error;
	
  jamma_s.coin(1) <= '1';
  jamma_s.p(1).start <= '1';
  jamma_s.p(1).up <= not joy_up;
  jamma_s.p(1).down <= not joy_down;
  jamma_s.p(1).left <= not joy_right; -- is the manual wrong?
  jamma_s.p(1).right <= not joy_left; -- is the manual wrong?
  jamma_s.p(1).button(1) <= not joy_fire;
  jamma_s.p(1).button(2 to 5) <= (others => '1');

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
	
	PACE_INST : entity work.PACE
	  port map
	  (
	     -- clocks and resets
			clk								=> clk,
			test_button      	=> '0',
	    reset            	=> reset,

	    -- game I/O
	    ps2clk           	=> mouse_clk,
	    ps2data          	=> mouse_data,
	    dip              	=> (others => '0'),
			jamma							=> jamma_s,
			
	    -- external RAM
	    sram_i.d       		=> (others => '0'),
	    sram_o        		=> open,

	    -- VGA video
	    red              	=> red_s,
	    green            	=> green_s,
	    blue             	=> blue_s,
	    hsync            	=> hsync,
	    vsync            	=> vsync,

	    -- composite video
	    BW_CVBS          	=> open,
	    GS_CVBS          	=> open,

	    -- sound
	    snd_clk          	=> open,
	    snd_data_l       	=> snd_data_l,
      snd_data_r        => snd_data_r,

	    -- SPI (flash)
	    spi_clk          	=> open,
	    spi_mode         	=> open,
	    spi_sel          	=> open,
	    spi_din          	=> '0',
	    spi_dout         	=> open,

	    -- serial
	    ser_tx           	=> rs232_tx,
	    ser_rx           	=> rs232_rx,

	    -- debug
	    leds             	=> led
	  );

  red <= red_s(9 downto 3);
  green <= green_s(9 downto 3);
  blue <= blue_s(9 downto 3);

  -- audio PWM
  -- clock is 48Mhz, sample rate 48kHz
  process (clk(1), reset)
    variable count : integer range 0 to 1023;
    variable audio_sample_l : std_logic_vector(9 downto 0);
    variable audio_sample_r : std_logic_vector(9 downto 0);
  begin
    if reset = '1' then
      count := 0;
    elsif rising_edge(clk(1)) then
      if count = 1023 then
        -- 48kHz tick - latch a sample (only 10 bits or 1024 steps)
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
  
	-- flash the led so we know it's alive
	process (clk(0), reset)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk(0)) then
			count := count + 1;
		end if;
		seven_seg0_dp <= count(count'left);
		seven_seg1_dp <= not count(count'left);
	end process;

  seven_seg0_a <= '0';
  seven_seg0_b <= '0';
  seven_seg0_c <= '0';
  seven_seg0_d <= '0';
  seven_seg0_e <= '0';
  seven_seg0_f <= '0';
  seven_seg0_g <= '0';
  
  seven_seg1_a <= '0';
  seven_seg1_b <= '0';
  seven_seg1_c <= '0';
  seven_seg1_d <= '0';
  seven_seg1_e <= '0';
  seven_seg1_f <= '0';
  seven_seg1_g <= '0';
  
end SYN;
