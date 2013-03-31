library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
-- use work.maple_pkg.all;
-- use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;


--entity C3BoardToplevel is
--port(
--		clk_50 	: in 	std_logic;
--		reset_button : in std_logic;
--		led_out : out 	std_logic;
--
--		-- SDRAM - chip 1
--		sd1_addr : out std_logic_vector(11 downto 0);
--		sd1_data : inout std_logic_vector(7 downto 0);
--		sd1_ba : out std_logic_vector(1 downto 0);
--		sdram1_clk : out std_logic;
--		sd1_cke : out std_logic;
--		sd1_dqm : out std_logic;
--		sd1_cs : out std_logic;
--		sd1_we : out std_logic;
--		sd1_cas : out std_logic;
--		sd1_ras : out std_logic;
--
--		-- SDRAM - chip 2
--		sd2_addr : out std_logic_vector(11 downto 0);
--		sd2_data : inout std_logic_vector(7 downto 0);
--		sd2_ba : out std_logic_vector(1 downto 0);
--		sdram2_clk : out std_logic;
--		sd2_cke : out std_logic;
--		sd2_dqm : out std_logic;
--		sd2_cs : out std_logic;
--		sd2_we : out std_logic;
--		sd2_cas : out std_logic;
--		sd2_ras : out std_logic;
--		
--		-- VGA
--		vga_red 		: out std_logic_vector(5 downto 0);
--		vga_green 	: out std_logic_vector(5 downto 0);
--		vga_blue 	: out std_logic_vector(5 downto 0);
--		
--		vga_hsync 	: buffer std_logic;
--		vga_vsync 	: buffer std_logic;
--		
--		vga_scandbl : in std_logic;
--
--		-- PS/2
--		ps2k_clk : inout std_logic;
--		ps2k_dat : inout std_logic;
--		ps2m_clk : inout std_logic;
--		ps2m_dat : inout std_logic;
--		
--		-- Audio
--		aud_l : out std_logic;
--		aud_r : out std_logic;
--		
--		-- RS232
--		rs232_rxd : in std_logic;
--		rs232_txd : out std_logic;
--
--		-- SD card interface
--		sd_cs : out std_logic;
--		sd_miso : in std_logic;
--		sd_mosi : out std_logic;
--		sd_clk : out std_logic;
--		
--		-- Power and LEDs
--		power_button : in std_logic;
--		power_hold : out std_logic := '1';
--		leds : out std_logic_vector(3 downto 0);
--		
--		-- Joystick ports
--		joy1 : in std_logic_vector(6 downto 0); -- Fire3, Fire2, Fire 1, Right, Left, Down, Up
--		joy2 : in std_logic_vector(6 downto 0); -- Fire3, Fire2, Fire 1, Right, Left, Down, Up
--
--		-- Any remaining IOs yet to be assigned
--		misc_ios_1 : out std_logic_vector(5 downto 0);
--		misc_ios_21 : out std_logic_vector(1 downto 0);
--		misc_ios_22 : out std_logic_vector(8 downto 0);
--		misc_ios_3 : out std_logic
--	);
--end entity;


entity target_top is
  port
    (
      --////////////////////	Clock Input	 	////////////////////	 
      CLOCK_50      : in std_logic;
		--/////////////////// SD card interface ///////////////////
		sd_cs : out std_logic;
		sd_miso : in std_logic;
		sd_mosi : out std_logic;
		sd_clk : out std_logic;
      --////////////////////////	Speaker		////////////////////////
      AUDIO_L           : out std_logic;
      AUDIO_R           : out std_logic;
      --////////////////////	VGA		////////////////////////////
      VGA_VS        : out std_logic;                        --	VGA H_SYNC
      VGA_HS        : out std_logic;                        --	VGA V_SYNC
      VGA_R         : out std_logic_vector(5 downto 0);     --	VGA Red[3:0]
      VGA_G         : out std_logic_vector(5 downto 0);     --	VGA Green[3:0]
      VGA_B         : out std_logic_vector(5 downto 0);      --	VGA Blue[3:0]

      sd1_cs     : out std_logic;
      sd2_cs     : out std_logic;

		joy1 : in std_logic_vector(6 downto 0); -- Fire3, Fire2, Fire 1, Right, Left, Down, Up
		joy2 : in std_logic_vector(6 downto 0); -- Fire3, Fire2, Fire 1, Right, Left, Down, Up

--		-- Power and LEDs
		power_button : in std_logic;
		power_hold : out std_logic := '1';
		leds : out std_logic_vector(3 downto 0);
		reset_button : in std_logic

      -- DATA0	    : in std_logic;                          --	DATA0
  );    
  
end target_top;

architecture SYN of target_top is

-- Assigns pin location to ports on an entity.
-- Declare the attribute or import its declaration from 
-- altera.altera_syn_attributes
attribute chip_pin : string;

-- Board features

attribute chip_pin of CLOCK_50 : signal is "152";
attribute chip_pin of reset_button : signal is "181";
--attribute chip_pin of led_out : signal is "233";

-- SDRAM (2 distinct 8-bit wide chips)

--attribute chip_pin of sd1_addr : signal is "83,69,82,81,80,78,99,110,63,64,65,68";
--attribute chip_pin of sd1_data : signal is "109,103,111,93,100,106,107,108";
--attribute chip_pin of sd1_ba : signal is "70,71";
--attribute chip_pin of sdram1_clk : signal is "117";
--attribute chip_pin of sd1_cke : signal is "84";
--attribute chip_pin of sd1_dqm : signal is "87";
attribute chip_pin of sd1_cs : signal is "72";
--attribute chip_pin of sd1_we : signal is "88";
--attribute chip_pin of sd1_cas : signal is "76";
--attribute chip_pin of sd1_ras : signal is "73";

--attribute chip_pin of sd2_addr : signal is "142,114,144,139,137,134,148,161,120,119,118,113";
--attribute chip_pin of sd2_data : signal is "166,164,162,160,146,147,159,168";
--attribute chip_pin of sd2_ba : signal is "126,127";
--attribute chip_pin of sdram2_clk : signal is "186";
--attribute chip_pin of sd2_cke : signal is "143";
--attribute chip_pin of sd2_dqm : signal is "145";
attribute chip_pin of sd2_cs : signal is "128";
--attribute chip_pin of sd2_we : signal is "133";
--attribute chip_pin of sd2_cas : signal is "132";
--attribute chip_pin of sd2_ras : signal is "131";


-- Video output via custom board

attribute chip_pin of VGA_R : signal is "13, 9, 5, 240, 238, 236";
attribute chip_pin of VGA_G : signal is "49, 45, 43, 39, 37, 18";
attribute chip_pin of VGA_B : signal is "52, 50, 46, 44, 41, 38";

attribute chip_pin of VGA_HS : signal is "51";
attribute chip_pin of VGA_VS : signal is "55";

-- Audio output via custom board

attribute chip_pin of AUDIO_L : signal is "6";
attribute chip_pin of AUDIO_R : signal is "22";

-- PS/2 sockets on custom board

--attribute chip_pin of ps2k_clk : signal is "235";
--attribute chip_pin of ps2k_dat : signal is "237";
--attribute chip_pin of ps2m_clk : signal is "239";
--attribute chip_pin of ps2m_dat : signal is "4";

-- RS232
--attribute chip_pin of rs232_rxd : signal is "98";
--attribute chip_pin of rs232_txd : signal is "112";

-- SD card interface
attribute chip_pin of sd_cs : signal is "185";
attribute chip_pin of sd_miso : signal is "196";
attribute chip_pin of sd_mosi : signal is "188";
attribute chip_pin of sd_clk : signal is "194";


-- Power and LEDs
attribute chip_pin of power_hold : signal is "171";
attribute chip_pin of power_button : signal is "94";

attribute chip_pin of leds : signal is "173, 169, 167, 135";

--attribute chip_pin of vga_scandbl : signal is "231";

-- Free pins, not yet assigned

--attribute chip_pin of misc_ios_1 : signal is "12,14,56,234,21,57";

--attribute chip_pin of misc_ios_21 : signal is "226,232";
--attribute chip_pin of misc_ios_22 : signal is "176,183,200,202,207,216,218,224,230";
--attribute chip_pin of misc_ios_3 : signal is "95";

attribute chip_pin of joy1 : signal is "201,203,214,217,219,221,223";
attribute chip_pin of joy2 : signal is "184,182,177,197,195,189,187";

  signal init       	: std_logic := '1';  
  signal clock_27       : std_logic;
  
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

  signal switches       : std_logic_vector(1 downto 0);
  signal buttons        : std_logic_vector(1 downto 0);
  
--//********************

begin

--  SDRAM_nCS <= '1';   -- don't select SDRAM
	sd1_cs<='1';
	sd2_cs<='1';
	sd_cs<='1'; -- don't select SD card either
	switches<="00";
	buttons <= power_button & reset_button;

-- // Need Clock 50Mhz to Clock 27Mhz

  BLK_CLOCKING : block
  begin
    clkrst_i.clk_ref <= CLOCK_50;
  
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_50_inst : entity work.pllclk_ez --entity work.pllclk_ez  --entity work.pll
        port map
        (
          inclk0  => CLOCK_50,
          c0      => clkrst_i.clk(0),  --30Mhz
          c1      => clkrst_i.clk(1),  --40Mhz
          c3      => clock_27,         --27.27Mhz
          c4      => clkrst_i.clk(2)   --18.46Mhz
        );

    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate
   
      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= CLOCK_50;
      clkrst_i.clk(1) <= CLOCK_50;
        
    end generate GEN_NO_PLL;
      
  end block BLK_CLOCKING;
	
  -- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (CLOCK_50)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(CLOCK_50) then
			if count = X"FFF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

  clkrst_i.arst <= init;
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

       switches_i(0) <= switches(0);
       switches_i(1) <= switches(1);

       GEN_NO_JAMMA : if PACE_JAMMA = PACE_JAMMA_NONE generate
		inputs_i.jamma_n.coin(1) <= buttons(0);
		inputs_i.jamma_n.p(1).start <= buttons(1);
		inputs_i.jamma_n.p(1).up <= joy1(2);
		inputs_i.jamma_n.p(1).down <= joy1(3);
		inputs_i.jamma_n.p(1).left <= joy1(4);
		inputs_i.jamma_n.p(1).right <= joy1(5);
		inputs_i.jamma_n.p(1).button(1) <= joy1(1);
		inputs_i.jamma_n.p(1).button(2) <= joy1(0);
		inputs_i.jamma_n.p(1).button(3) <= joy1(6);
		inputs_i.jamma_n.p(1).button(4) <= '1';
		inputs_i.jamma_n.p(1).button(5) <= '1';
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
    
    VGA_R <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-5);
    VGA_G <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-5);
    VGA_B <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-5);
    VGA_HS <= video_o.hsync;
    VGA_VS <= video_o.vsync;
 
  end block BLK_VIDEO;

  BLK_AUDIO : block
  begin
  
    dacl : entity work.sigma_delta_dac
      port map (
        clk     => CLOCK_50,
        din     => audio_o.ldata(15 downto 8),
        dout    => AUDIO_L
      );        

    dacr : entity work.sigma_delta_dac
      port map (
        clk     => CLOCK_50,
        din     => audio_o.rdata(15 downto 8),
        dout    => AUDIO_R
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
end SYN;
