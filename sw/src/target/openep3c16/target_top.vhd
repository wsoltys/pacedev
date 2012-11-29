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
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
    (
      --////////////////////	Clock Input	 	////////////////////	 
      clock_50      : in std_logic;                       --	50 MHz
      --////////////////////	Push Button		////////////////////
      reset             : in std_logic;      --	Pushbutton
      --////////////////////////	Joystick	////////////////////////
      joy_up            : in std_logic;
      joy_down          : in std_logic;
      joy_left          : in std_logic;
      joy_right         : in std_logic;
      joy_center        : in std_logic;
      --////////////////////////	Speaker		////////////////////////
      speaker           : out std_logic;
      --////////////////////////	LED		////////////////////////
      led          : out std_logic_vector(3 downto 0);     --	LED [3:0]
      --////////////////////	VGA		////////////////////////////
      vga_hs        : out std_logic;                        --	VGA H_SYNC
      vga_vs        : out std_logic;                        --	VGA V_SYNC
      vga_r         : out std_logic_vector(3 downto 0);     --	VGA Red[3:0]
      vga_g         : out std_logic_vector(3 downto 0);     --	VGA Green[3:0]
      vga_b         : out std_logic_vector(3 downto 0);      --	VGA Blue[3:0]
      --////////////////////	EPCS		////////////////////////////
      DATA0	    : in std_logic;                          --	DATA0
      DCLK	    : out std_logic;                         --	DCLK
      FLASH_nCE	    : out std_logic;                         --	FLASH NCE
      ASDO	    : out std_logic                          --	ASDO
  );    
  
end target_top;

architecture SYN of target_top is

  signal init       	: std_logic := '1';
  
  signal clkrst_i       : from_CLKRST_t;
  signal buttons_i      : from_BUTTONS_t;
  signal switches_i     : from_SWITCHES_t;
  signal leds_o         : to_LEDS_t;
  signal inputs_i       : from_INPUTS_t;
  signal flash_i        : from_FLASH_t;
  signal flash_o        : to_FLASH_t;
  signal sram_i			: from_SRAM_t;
  signal sram_o			: to_SRAM_t;	
  signal sdram_i        : from_SDRAM_t;
  signal sdram_o        : to_SDRAM_t;
  signal video_i        : from_VIDEO_t;
  signal video_o        : to_VIDEO_t;
  signal audio_i        : from_AUDIO_t;
  signal audio_o        : to_AUDIO_t;
  signal ser_i          : from_SERIAL_t;
  signal ser_o          : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

--//********************
		--////////////////////	Push Button	& DPDT	////////////////////
  signal clock_16      : std_logic;                        --	16 MHz Generated Manually from 50Mhz
  signal clock_27      : std_logic;                        --	27 MHz Generated Manually from 50Mhz

  signal ledi          : std_logic_vector(3 downto 0);
  
--//********************

begin

 led <= not ledi;
  
	-- // Need Clock 50Mhz to Clock 27Mhz

  BLK_CLOCKING : block
  begin
    clkrst_i.clk_ref <= clock_50;
  
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_50_inst : entity work.pllclk_ez --entity work.pllclk_ez  --entity work.pll
        port map
        (
          inclk0  => clock_50,
          c0      => clkrst_i.clk(0),  --30Mhz
          c1      => clkrst_i.clk(1),  --40Mhz
          c2      => clock_16,         --16Mhz
          c3      => clock_27,         --27.27Mhz
          c4      => clkrst_i.clk(2)   --18.46Mhz
        );

    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate
   
      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clock_50;
      clkrst_i.clk(1) <= clock_27;
        
    end generate GEN_NO_PLL;
      
  end block BLK_CLOCKING;
	
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

  clkrst_i.arst <= init or (not reset and not joy_center);
  clkrst_i.arst_n <= not clkrst_i.arst;

  GEN_RESETS : for i in 0 to 3 generate

    process (clkrst_i.clk(i), clkrst_i.arst)
      variable rst_r : std_logic_vector(2 downto 0) := (others => '0');
    begin
      if clkrst_i.arst = '1' then
        rst_r := (others => '1');
      elsif rising_edge(clkrst_i.clk(i)) then
        rst_r := rst_r(rst_r'left-1 downto 0) & '0';
      end if;
      clkrst_i.rst(i) <= rst_r(rst_r'left);
    end process;

  end generate GEN_RESETS;
	
	-- inputs

	GEN_NO_JAMMA : if PACE_JAMMA = PACE_JAMMA_NONE generate
		inputs_i.jamma_n.coin(1) <= reset;
		inputs_i.jamma_n.p(1).start <= joy_center;
		inputs_i.jamma_n.p(1).up <= joy_up;
		inputs_i.jamma_n.p(1).down <= joy_down;
		inputs_i.jamma_n.p(1).left <= joy_left;
		inputs_i.jamma_n.p(1).right <= joy_right;
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
		
  BLK_VIDEO : block
  begin

    video_i.clk <= clkrst_i.clk(1);	-- by convention
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);
    
    vga_r <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-3);
    vga_g <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-3);
    vga_b <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-3);
    vga_hs <= video_o.hsync;
    vga_vs <= video_o.vsync;
 
  end block BLK_VIDEO;

  BLK_AUDIO : block
  begin
  
    dac         : entity work.sigma_delta_dac
      port map (
        clk     => clock_50,
        din     => audio_o.ldata(15 downto 8),
        dout    => speaker
      );        
    
  end block BLK_AUDIO;
 
 pace_inst : entity work.pace                                            
   port map
   (
     -- clocks and resets
     clkrst_i					=> clkrst_i,

     -- misc inputs and outputs
     buttons_i         => buttons_i,
     switches_i        => switches_i,
     leds_o            => open,
     
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
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

  BLK_CHASER : block
    signal pwmen      	: std_logic;
    signal chaseen    	: std_logic;
  begin
  
    pchaser: entity work.pwm_chaser 
      generic map(nleds  => 4, nbits => 8, period => 4, hold_time => 12)
      port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => clkrst_i.arst, fade => X"0F", ledout  => ledi );  --ledg(7 downto 0));

    -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
    process(clock_50, clkrst_i.arst)
      variable pcount     : std_logic_vector(9 downto 0);
      variable pwmen_r    : std_logic;
      variable ccount     : std_logic_vector(18 downto 0);
      variable chaseen_r  : std_logic;
    begin
      pwmen <= pwmen_r;
      chaseen <= chaseen_r;
      if clkrst_i.arst = '1' then
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

end SYN;
