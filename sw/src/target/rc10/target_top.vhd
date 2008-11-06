library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
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
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  
begin

  BLK_CLOCKING : block

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
  
  begin
  
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll
        generic map
        (
          -- INCLK0
          INCLK0_INPUT_FREQUENCY  => 20, -- period 20.833ns
  
          -- CLK0
          CLK0_DIVIDE_BY          => real(PACE_CLK0_DIVIDE_BY),
      
          -- CLK1
          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        )
        port map
        (
          inclk0  => clk_48M,
          c0      => clk_i(0),
          c1      => clk_i(1)
        );
    
    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate
  
      -- feed input clocks into PACE core
      clk_i(0) <= clk_48M;
      clk_i(1) <= exp_clk0;
        
    end generate GEN_NO_PLL;
    
    -- unused clocks on RC10
    clk_i(2) <= exp_clk0;
    clk_i(3) <= exp_clk1;
  
  end block BLK_CLOCKING;
  
	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clk_i(1))
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clk_i(1)) then
			if count = X"FF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

	reset_i <= init;
		
  -- buttons
  buttons_i <= std_logic_vector(to_unsigned(0, buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(to_unsigned(0, switches_i'length));
  -- leds
  led <= leds_o(led'range);
  
	-- inputs (swapped?!?)
  inputs_i.ps2_kclk <= mouse_clk when joy_fire = '0' else keybd_clk;
  mouse_clk <= 'Z';
  inputs_i.ps2_kdat <= mouse_data when joy_fire = '0' else keybd_data;
  mouse_data <= 'Z';
	inputs_i.ps2_mclk <= keybd_clk when joy_fire = '0' else mouse_clk;
  keybd_clk <= 'Z';
	inputs_i.ps2_mdat <= keybd_data when joy_fire = '0' else mouse_data;
  keybd_data <= 'Z';
  
  -- JAMMA wired to on-board joystick
  inputs_i.jamma_n.coin(1) <= '1';
  inputs_i.jamma_n.p(1).start <= '1';
  inputs_i.jamma_n.p(1).up <= not joy_up;
  inputs_i.jamma_n.p(1).down <= not joy_down;
  inputs_i.jamma_n.p(1).left <= not joy_right; -- is the manual wrong?
  inputs_i.jamma_n.p(1).right <= not joy_left; -- is the manual wrong?
  inputs_i.jamma_n.p(1).button(1) <= not joy_fire;
  inputs_i.jamma_n.p(1).button(2 to 5) <= (others => '1');

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
    flash_i.d <= (others => '0');
  end block BLK_FLASH;

  -- static memory
  BLK_SRAM : block
  begin
    sram_i.d <= (others => '1');
  end block BLK_SRAM;

  BLK_SDRAM : block
  begin
  end block BLK_SDRAM;

  BLK_VIDEO : block
  begin

		video_i.clk <= clk_i(1);	-- by convention
    video_i.clk_ena <= '1';
		video_i.reset <= reset_i;

    red <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-6);
    green <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-6);
    blue <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-6);
    hsync <= video_o.hsync;
    vsync <= video_o.vsync;
    
  end block BLK_VIDEO;
  
  BLK_AUDIO : block

    signal snd_data_l   : std_logic_vector(15 downto 0);
    signal snd_data_r   : std_logic_vector(15 downto 0);
  
  begin
  
    -- audio PWM
    -- clock is 48Mhz, sample rate 48kHz
    process (clk_i(1), reset_i)
      variable count : integer range 0 to 1023;
      variable audio_sample_l : std_logic_vector(9 downto 0);
      variable audio_sample_r : std_logic_vector(9 downto 0);
    begin
      if reset_i = '1' then
        count := 0;
      elsif rising_edge(clk_i(1)) then
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

  end block BLK_AUDIO;
  
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
  
	-- flash the led so we know it's alive
	process (clk_i(0), reset_i)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset_i = '1' then
			count := (others => '0');
		elsif rising_edge(clk_i(0)) then
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
