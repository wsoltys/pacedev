library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;


entity target_top is
  port
    (
-- Clocks
		clk8 : in std_logic;
		phi2_n : in std_logic;
		dotclock_n : in std_logic;

-- Bus
		romlh_n : in std_logic;
		ioef_n : in std_logic;

-- Buttons
		freeze_n : in std_logic;

-- MMC/SPI
		spi_miso : in std_logic;
		mmc_cd_n : in std_logic;
		mmc_wp : in std_logic;

-- MUX CPLD
		mux_clk : out std_logic;
		mux : out unsigned(3 downto 0);
		mux_d : out unsigned(3 downto 0);
		mux_q : in unsigned(3 downto 0);

-- USART
		usart_tx : in std_logic;
		usart_clk : in std_logic;
		usart_rts : in std_logic;
		usart_cts : in std_logic;

-- SDRam
		sd_clk : out std_logic;
		sd_data : inout unsigned(15 downto 0);
		sd_addr : out unsigned(12 downto 0);
		sd_we_n : out std_logic;
		sd_ras_n : out std_logic;
		sd_cas_n : out std_logic;
		sd_ba_0 : out std_logic;
		sd_ba_1 : out std_logic;
		sd_ldqm : out std_logic;
		sd_udqm : out std_logic;

-- Video
		red : out std_logic_vector(4 downto 0);
		grn : out std_logic_vector(4 downto 0);
		blu : out std_logic_vector(4 downto 0);
		nHSync : out std_logic;
		nVSync : out std_logic;

-- Audio
		sigmaL : out std_logic;
		sigmaR : out std_logic
	);
  
end target_top;

architecture SYN of target_top is


  signal init       	: std_logic := '1';  
  signal CLOCK_100	: std_logic;
  
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

-- Chameleon signals

	signal ena_1mhz : std_logic;
	signal ena_1khz : std_logic;
	
-- System state
	signal no_clock : std_logic;
	signal docking_station : std_logic;
	signal reset : std_logic;
	signal button_reset_n : std_logic;

-- LEDs
	signal led_green : std_logic := '0';
	signal led_red : std_logic := '0';
	signal ir : std_logic;

	signal joystick1 : unsigned(5 downto 0);
	signal joystick2 : unsigned(5 downto 0);
	signal joystick3 : unsigned(5 downto 0);
	signal joystick4 : unsigned(5 downto 0);
	
	signal ir_joya : unsigned(5 downto 0);
	signal ir_joyb : unsigned(5 downto 0);
	signal ir_start : std_logic;
	signal ir_coin : std_logic;

-- C64 keyboard
	signal keys : unsigned(63 downto 0);
	signal restore_key_n : std_logic;
	signal c64_nmi_n : std_logic; -- Replaces restore_key_n in C64 mode.

-- PS/2 Keyboard
	signal ps2_keyboard_clk_in : std_logic;
	signal ps2_keyboard_dat_in : std_logic;
	signal ps2_keyboard_clk_out : std_logic;
	signal ps2_keyboard_dat_out : std_logic;

-- PS/2 Mouse
	signal ps2_mouse_clk_in: std_logic;
	signal ps2_mouse_dat_in: std_logic;
	signal ps2_mouse_clk_out: std_logic;
	signal ps2_mouse_dat_out: std_logic;

	signal joya : unsigned(5 downto 0);
	signal joyb : unsigned(5 downto 0);
	
--//********************


begin

	-- Combine joystick signals from io entity and IR port.
	joya <= ir_joya and joystick1;
	joyb <= ir_joyb and joystick2;
	

	sd_clk<='0'; -- Freeze SDRAM since we can't access sd_cs

	switches<="00";
	buttons <= freeze_n & usart_cts;

-- // Need Clock 50Mhz to Clock 27Mhz

	my1Mhz : entity work.chameleon_1mhz
		generic map (
			clk_ticks_per_usec => 100
		)
		port map (
			clk => CLOCK_100,
			ena_1mhz => ena_1mhz,
			ena_1mhz_2 => open
		);

	my1Khz : entity work.chameleon_1khz
		port map (
			clk => CLOCK_100,
			ena_1mhz => ena_1mhz,
			ena_1khz => ena_1khz
		); 


-- -----------------------------------------------------------------------
--
-- The I/O driving entity.
--
-- -----------------------------------------------------------------------
	myIO : entity work.chameleon_io
		generic map (
			enable_docking_station => true,
			enable_c64_joykeyb => true,
			enable_c64_4player => true
		)
		port map (
		-- Clocks
			clk => CLOCK_100,
			clk_mux => CLOCK_100,
			ena_1mhz => ena_1MHz,
			reset => init, -- reset,
			
			no_clock => no_clock,
			docking_station => docking_station,
			
		-- Chameleon FPGA pins
			-- C64 Clocks
			phi2_n => phi2_n,
			dotclock_n => dotclock_n,
			-- C64 cartridge control lines
			io_ef_n => ioef_n,
			rom_lh_n => romlh_n,
			-- SPI bus
			spi_miso => spi_miso,
			-- CPLD multiplexer
			mux_clk => mux_clk,
			mux => mux,
			mux_d => mux_d,
			mux_q => mux_q,

		-- LEDs
			led_green => led_green,
			led_red => led_red,
			ir => ir,
		
		-- PS/2 Keyboard
			ps2_keyboard_clk_out => ps2_keyboard_clk_out,
			ps2_keyboard_dat_out => ps2_keyboard_dat_out,
			ps2_keyboard_clk_in => ps2_keyboard_clk_in,
			ps2_keyboard_dat_in => ps2_keyboard_dat_in,
	
		-- PS/2 Mouse
			ps2_mouse_clk_out => ps2_mouse_clk_out,
			ps2_mouse_dat_out => ps2_mouse_dat_out,
			ps2_mouse_clk_in => ps2_mouse_clk_in,
			ps2_mouse_dat_in => ps2_mouse_dat_in,

		-- Buttons
			button_reset_n => button_reset_n,
			spi_raw_clk => '0',
			spi_raw_mosi => '0',

		-- Joysticks
			joystick1 => joystick1,
			joystick2 => joystick2,
			joystick3 => joystick3,
			joystick4 => joystick4,

		-- Keyboards
			keys => keys,
			restore_key_n => restore_key_n,
			c64_nmi_n => c64_nmi_n
			
		);

-- CDTV IR decoder

myIr : entity work.chameleon_cdtv_remote
	port map (
		clk => CLOCK_100,
		ena_1mhz => ena_1mhz,
		ir => ir,

--		trigger : out std_logic;
--
--		key_1 : out std_logic;
--		key_2 : out std_logic;
--		key_3 : out std_logic;
--		key_4 : out std_logic;
--		key_5 : out std_logic;
--		key_6 : out std_logic;
--		key_7 : out std_logic;
--		key_8 : out std_logic;
--		key_9 : out std_logic;
--		key_0 : out std_logic;
--		key_escape : out std_logic;
--		key_enter : out std_logic;
--		key_genlock : out std_logic;
--		key_cdtv : out std_logic;
		key_power => ir_coin,
--		key_rew : out std_logic;
		key_play => ir_start,
--		key_ff : out std_logic;
--		key_stop : out std_logic;
--		key_vol_up : out std_logic;
--		key_vol_dn : out std_logic;
		joystick_a => ir_joya,
		joystick_b => ir_joyb
--		debug_code : out unsigned(11 downto 0)
	);

		

  BLK_CLOCKING : block
  begin
    clkrst_i.clk_ref <= CLOCK_100;
  
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_50_inst : entity work.pllclk_ez --entity work.pllclk_ez  --entity work.pll
        port map
        (
          inclk0  => clk8,
			 c0		=> CLOCK_100,	-- system clock
          c1      => clkrst_i.clk(1)  --video clock
        );
		  clkrst_i.clk(0)<=CLOCK_100;

    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate
   
      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clk8; -- Not much point doing this really,
      clkrst_i.clk(1) <= clk8; -- the 8MHz clock is too low to be useful without a PLL.
        
    end generate GEN_NO_PLL;
      
  end block BLK_CLOCKING;
	
  -- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (CLOCK_100)
		variable count : std_logic_vector (15 downto 0) := (others => '0');
	begin
		if rising_edge(CLOCK_100) then
			if count = X"FFFF" then
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
		inputs_i.jamma_n.coin(1) <= buttons(0) and not ir_coin;
		inputs_i.jamma_n.p(1).start <= buttons(1) and not ir_start;
		inputs_i.jamma_n.p(1).up <= joya(0);
		inputs_i.jamma_n.p(1).down <= joya(1);
		inputs_i.jamma_n.p(1).left <= joya(2);
		inputs_i.jamma_n.p(1).right <= joya(3);
		inputs_i.jamma_n.p(1).button(1) <= joya(4);
		inputs_i.jamma_n.p(1).button(2) <= joya(5);
		inputs_i.jamma_n.p(1).button(3) <= '1';
		inputs_i.jamma_n.p(1).button(4) <= '1';
		inputs_i.jamma_n.p(1).button(5) <= '1';
		inputs_i.jamma_n.p(2).up <= joyb(0);
		inputs_i.jamma_n.p(2).down <= joyb(1);
		inputs_i.jamma_n.p(2).left <= joyb(2);
		inputs_i.jamma_n.p(2).right <= joyb(3);
		inputs_i.jamma_n.p(2).button(1) <= joyb(4);
		inputs_i.jamma_n.p(2).button(2) <= joyb(5);
		inputs_i.jamma_n.p(2).button(3) <= '1';
		inputs_i.jamma_n.p(2).button(4) <= '1';
		inputs_i.jamma_n.p(2).button(5) <= '1';
        end generate GEN_NO_JAMMA;
  
	-- not currently wired to any inputs
	inputs_i.jamma_n.coin_cnt <= (others => '1');
	inputs_i.jamma_n.coin(2) <= '1';
	inputs_i.jamma_n.p(2).start <= '1';
--	inputs_i.jamma_n.p(2).up <= '1';
--	inputs_i.jamma_n.p(2).down <= '1';
--	inputs_i.jamma_n.p(2).left <= '1';
--	inputs_i.jamma_n.p(2).right <= '1';
--	inputs_i.jamma_n.p(2).button <= (others => '1');
	inputs_i.jamma_n.service <= '1';
	inputs_i.jamma_n.tilt <= '1';
	inputs_i.jamma_n.test <= '1';
		
  BLK_VIDEO : block
  begin

    video_i.clk <= clkrst_i.clk(1);	-- by convention
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);
    
    red <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-4);
    grn <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-4);
    blu <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-4);
    nHSync <= video_o.hsync;
    nVSync <= video_o.vsync;
 
  end block BLK_VIDEO;

  BLK_AUDIO : block
  begin
  
    dacl : entity work.sigma_delta_dac
      port map (
        clk     => CLOCK_100,
        din     => audio_o.ldata(15 downto 8),
        dout    => sigmaL
      );        

    dacr : entity work.sigma_delta_dac
      port map (
        clk     => CLOCK_100,
        din     => audio_o.rdata(15 downto 8),
        dout    => sigmaR
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
