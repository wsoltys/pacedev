library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- external ROM/RAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_flash_t;
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;

    -- video
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;

    -- audio
    audio_i         : in from_AUDIO_t;
    audio_o         : out to_AUDIO_t;
    
    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;
    
    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );
end entity PACE;

architecture SYN of PACE is

	alias clk_50M						: std_logic is clk_i(0);
	
	signal reset_n					: std_logic;

  signal ps2_kclk         : std_logic;
  signal ps2_kdat         : std_logic;
  
  signal ram_data         : std_logic_vector(7 downto 0);
	signal ram_csn					: std_logic;	
	signal ram_wrln					: std_logic;

begin

	reset_n <= not reset_i;

  ps2_kclk <= inputs_i.ps2_kclk;
  ps2_kdat <= inputs_i.ps2_kdat;
  
	-- SRAM interface	
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	sram_o.cs <= not ram_csn;
	sram_o.oe <= ram_wrln;
	sram_o.we <= not ram_wrln;
  sram_o.d <= std_logic_vector(resize(unsigned(ram_data), sram_o.d'length)) 
								when ram_wrln = '0' else (others => 'Z');

	-- map inputs
	
	video_o.clk <= clk_i(1);	-- by convention

	system09_inst : entity work.My_System09
	  port map
		(
    	SysClk      => clk_50M,
	 		Reset_n     => reset_n,
    	LED         => leds_o(0),

	    -- Memory Interface signals
	    ram_csn     => ram_csn,
	    ram_wrln    => ram_wrln,
	    ram_wrun    => open,
	    ram_addr    => sram_o.a(16 downto 0),
			ram_data_i(15 downto 8)	=> (others => '0'),
	    ram_data_i(7 downto 0)	=> sram_i.d(7 downto 0),
      ram_data_o(15 downto 8) => open,
      ram_data_o(7 downto 0) => ram_data,

			-- Stuff on the peripheral board

	 	 	-- PS/2 Keyboard
		 	kb_clock    => ps2_kclk,
		 	kb_data     => ps2_kdat,

	 		-- PS/2 Mouse interface
--	 mouse_clock : in  Std_Logic;
--	 mouse_data  : in  Std_Logic;

	 		-- Uart Interface
    	rxbit       => ser_i.rxd,
	 		txbit       => ser_o.txd,
    	rts_n       => open,
    	cts_n       => '0',

	 		-- CRTC output signals
	 		v_drive     => video_o.vsync,
    	h_drive     => video_o.hsync,
    	blue_lo     => video_o.rgb.b(8),
    	blue_hi     => video_o.rgb.b(9),
    	green_lo    => video_o.rgb.g(8),
    	green_hi    => video_o.rgb.g(9),
    	red_lo      => video_o.rgb.r(8),
    	red_hi      => video_o.rgb.r(9),
--	   buzzer      : out std_logic;

			-- Compact Flash
    	cf_rst_n     => open,
	 		cf_cs0_n     => open,
	 		cf_cs1_n     => open,
    	cf_rd_n      => open,
    	cf_wr_n      => open,
	 		cf_cs16_n    => open,
    	cf_a         => open,
    	cf_d         => open,

			-- Parallel I/O port
    	porta        => open,
    	portb        => open,

			-- CPU bus
	 		bus_clk      => open,
	 		bus_reset    => open,
	 		bus_rw       => open,
	 		bus_cs       => open,
    	bus_addr     => open,
	 		bus_data     => open,

			-- timer
    	timer_out    => open
	 );
  
  flash_o <= NULL_TO_FLASH;
	sram_o.a(23 downto 17) <= (others => '0');
  audio_o <= NULL_TO_AUDIO;
  spi_o <= NULL_TO_SPI;
  
	-- unused video colour resolution
	video_o.rgb.r(video_o.rgb.r'left-2 downto 0) <= (others => '0');
	video_o.rgb.g(video_o.rgb.g'left-2 downto 0) <= (others => '0');
	video_o.rgb.b(video_o.rgb.b'left-2 downto 0) <= (others => '0');
	
  leds_o(leds_o'left downto 1) <= (others => '0');
  gp_o <= NULL_TO_GP;
  
end SYN;
