library ieee;
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
    clk_50M         : in std_logic;
    exp_clk0	    : in std_logic;
    exp_clk1	    : in std_logic;

 	key           : in std_logic_vector(3 downto 0);	--	Pushbutton[3:0]
	sw            : in std_logic_vector(8 downto 0);     --	Toggle Switch[8:0]

    -- output LEDs
    led               : out std_logic_vector(7 downto 0);
    ledg               : out std_logic_vector(7 downto 0);
	 
	 -- PSDRAM Interface		
	sram_dq       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
	sram_addr     : out std_logic_vector(22 downto 0);    --	SRAM Address bus 23 Bits
	sram_ub_n     : out std_logic;                        --	SRAM High-byte Data Mask 
	sram_lb_n     : out std_logic;                        --	SRAM Low-byte Data Mask 
	sram_we_n     : out std_logic;                        --	SRAM Write Enable
	sram_ce_n     : out std_logic;                        --	SRAM Chip Enable
	sram_oe_n     : out std_logic;                        --	SRAM Output Enable
	sram_adv_n 		: out std_logic;								--# MT-ADV  <=0
	sram_clk_n		: out std_logic;								--# MT-CLK	<=0
	sram_cre_n		: out std_logic; 								--# MT-CRE	<=1
	-- Nexys MEMORY:Controls for IC14 (Flash ROM):
	fl_rst_n 			: out std_logic				; -- # RP#	<=1
	fl_ce_n			 : out std_logic				;  --# ST-CE	<=1

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
    
    -- vga
    -- Nexys2 with 12bit colour mod fitted!!

    red               : out std_logic_vector(3 downto 0);
    green             : out std_logic_vector(3 downto 0);
    blue              : out std_logic_vector(3 downto 0);
    hsync             : out std_logic;
    vsync             : out std_logic;
    
    -- audio
    audio_left        : out std_logic;
    audio_right       : out std_logic
    
    -- expansion header
    -- TBD
  );
end target_top;

architecture SYN of target_top is

  signal clk_i		: std_logic_vector(0 to 3);
  signal init       	: std_logic := '1';
  signal reset_i     	: std_logic := '1';
  signal reset_n	: std_logic := '0';

  signal buttons_i	: from_BUTTONS_t;
  signal switches_i	: from_SWITCHES_t;
  signal leds_o		: to_LEDS_t;
  signal inputs_i	: from_INPUTS_t;
  signal flash_i	: from_FLASH_t;
  signal flash_o	: to_FLASH_t;
  signal sram_i		: from_SRAM_t;
  signal sram_o		: to_SRAM_t;
  signal sdram_i		: from_SDRAM_t;
  signal sdram_o		: to_SDRAM_t;	
  signal video_i	: from_VIDEO_t;
  signal video_o	: to_VIDEO_t;
  signal audio_i	: from_AUDIO_t;
  signal audio_o	: to_AUDIO_t;
  signal ser_i		: from_SERIAL_t;
  signal ser_o		: to_SERIAL_t;
  
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
          INCLK0_INPUT_FREQUENCY  => 50, -- period 20.000ns
  
          -- CLK0
          CLK0_DIVIDE_BY          => 2.5,		--PACE_CLK0_DIVIDE_BY,
      
          -- CLK1
          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        )
        port map
        (
          inclk0  => clk_50M,
          c0      => clk_i(0),
          c1      => clk_i(1)
        );
		  
   
    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate
  
      -- feed input clocks into PACE core
      clk_i(0) <= clk_50M;
      clk_i(1) <= exp_clk0;
        
    end generate GEN_NO_PLL;
    
    -- unused clocks on Nexys2
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

  -- buttons - active high
  buttons_i <= std_logic_vector(resize(unsigned(key), buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(resize(unsigned(sw), switches_i'length));
		
  -- leds
  led <= leds_o(led'range);
  
	-- inputs 
  inputs_i.ps2_kclk <= keybd_clk;
  inputs_i.ps2_kdat <= keybd_data;
  keybd_clk <= 'Z';
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
    GEN_SRAM : if PACE_HAS_SRAM generate
      sram_addr <= sram_o.a(sram_addr'range);
      sram_i.d <= std_logic_vector(resize(unsigned(sram_dq), sram_i.d'length));
      sram_dq <= sram_o.d(sram_dq'range) when (sram_o.cs = '1' and sram_o.we = '1') else (others => 'Z');
      sram_ub_n <= not sram_o.be(1);
      sram_lb_n <= not sram_o.be(0);
      sram_ce_n <= not sram_o.cs;
      sram_oe_n <= not sram_o.oe;
      sram_we_n <= not sram_o.we;
		-- force async accesses
		sram_adv_n <= '0' ;
		sram_clk_n <= '0' ;	--# MT-CLK	<=0
		sram_cre_n <= '1' ;	--# MT-CRE	<=1
		-- keep flash from interfering
		fl_rst_n <= '1' ;		 -- # RP#	<=1
		fl_ce_n	<= '1' ;		 --# ST-CE	<=1

    end generate GEN_SRAM;
    
    GEN_NO_SRAM : if not PACE_HAS_SRAM generate
      sram_addr <= (others => 'Z');
      sram_i.d <= (others => '1');
      sram_dq <= (others => 'Z');
      sram_ub_n <= '1';
      sram_lb_n <= '1';
      sram_ce_n <= '1';
      sram_oe_n <= '1';
      sram_we_n <= '1'; 
		-- keep flash from interfering
		fl_rst_n <= '1' ;		 -- # RP#	<=1
		fl_ce_n	<= '1' ;		 --# ST-CE	<=1
    end generate GEN_NO_SRAM;
  end block BLK_SRAM;

  BLK_SDRAM : block
  begin
  end block BLK_SDRAM;

  BLK_VIDEO : block
  begin

    video_i.clk <= clk_i(1);	-- by convention
    video_i.clk_ena <= '1';
    video_i.reset <= reset_i;

    red <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-3);
    green <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-3);
    blue <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-3);
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
      sdram_i         => sdram_i,
      sdram_o         => sdram_o,

  
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
