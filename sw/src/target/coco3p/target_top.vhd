library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
--use work.maple_pkg.all;
--use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
    -- clocking
    clk_50M         : in std_logic;
    
    -- buttons and switches
    reset_btn       : in std_logic;
    chan_sw         : in std_logic;

    -- joystick (serial protocol)
    joy_clk         : out std_logic_vector(0 to 1);
    joy_dat         : in std_logic_vector(0 to 1);
    
    -- serial (bit-bang muxed with RS232)
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;
    ser_rts         : out std_logic;
    ser_cts         : in std_logic;
    ser_cd          : in std_logic;
    ser_dtr         : out std_logic;
    ser_dsr         : in std_logic;
    
    -- cassette
    cass_in         : in std_logic;
    cass_out        : out std_logic;
    cass_motor      : out std_logic;
    
    -- audio
    audio_l         : out std_logic;
    audio_r         : out std_logic;
    
    -- PS/2
    ps2_kclk        : in std_logic;
    ps2_kdat        : in std_logic;
    ps2_mclk        : in std_logic;
    ps2_mdat        : in std_logic;

    -- video
    vid_r           : out std_logic_vector(5 downto 0);
    vid_g           : out std_logic_vector(5 downto 0);
    vid_b           : out std_logic_vector(5 downto 0);
    vid_hsync       : out std_logic;
    vid_vsync       : out std_logic;
    vid_fsel        : out std_logic;    -- pal/ntsc crystal select for ADV724

    -- cartridge
    cart_halt_n     : in std_logic;
    cart_nmi_n      : in std_logic;
    cart_reset_n    : inout std_logic;
    cart_eclk       : out std_logic;
    cart_qclk       : out std_logic;
    cart_cart_n     : in std_logic;
    cart_d          : inout std_logic_vector(7 downto 0);
    cart_rw_n       : out std_logic;
    cart_a          : out std_logic_vector(15 downto 0);
    cart_cts_n      : out std_logic;
    --cart_snd
    cart_scs_n      : out std_logic;
    cart_slenb_n    : in std_logic;
    
    -- IDE
    ide_reset_n     : out std_logic;
    ide_dd          : inout std_logic_vector(15 downto 0);
    ide_iow_n       : out std_logic;
    ide_ior_n       : out std_logic;
    ide_io_ch_rdy   : in std_logic;
    ide_ale         : out std_logic;
    ide_irqr        : in std_logic;
    ide_iocs16_n    : out std_logic;
    ide_da          : out std_logic_vector(2 downto 0);
    ide_ide_cs      : out std_logic_vector(1 downto 0);
    ide_active_n    : out std_logic;

    -- memory bus
    sram_a          : out std_logic_vector(18 downto 0);    -- 512Kix8 devices
    sram_d          : inout std_logic_vector(15 downto 0);  -- 2x devices wide
    sram_cs_n       : out std_logic_vector(3 downto 0);     -- total of 2MiB
    sram_oe_n       : out std_logic;
    sram_we_n       : out std_logic;
    
    -- SSP to ARM
    ssp_sclk        : out std_logic;
    ssp_mosi1       : in std_logic;
    ssp_miso1       : out std_logic;
    --ssp_ss_n        : out std_logic;  -- always slave
    
    -- serial pass-thru to ARM (for programming)
    arm_ser_tx      : in std_logic;
    arm_ser_rx      : out std_logic
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
	signal sdram_i      : from_SDRAM_t;
	signal sdram_o      : to_SDRAM_t;
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  signal gp_i         : from_GP_t;
  signal gp_o         : to_GP_t;
  
begin

  BLK_CLOCKING : block
  begin
  
    pll1_inst : ENTITY work.pll1
      port map
      (
        inclk0		=> clk_50M,
        c0		    => clk_i(0),
        c1		    => clk_i(1),
        locked		=> open
      );

    clk_i(2) <= clk_i(0);
    clk_i(3) <= clk_i(1);
    
  end block BLK_CLOCKING;

  -- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clk_50M)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(clk_50M) then
			if count = X"FFF" then
				init <= '0';
			else
				count := std_logic_vector(unsigned(count) + 1);
				init <= '1';
			end if;
		end if;
	end process;

  reset_i <= init or reset_btn;
	reset_n <= not reset_i;
	
	-- buttons - active high
  buttons_i <= (0 => reset_btn, others => '0');
  -- switches
  switches_i <= (0 => chan_sw, others => '0');

	-- inputs
	inputs_i.ps2_kclk <= ps2_kclk;
	inputs_i.ps2_kdat <= ps2_kdat;
  inputs_i.ps2_mclk <= ps2_mclk;
  inputs_i.ps2_mdat <= ps2_mdat;

  -- static memory
  BLK_SRAM : block
  begin
  
    GEN_SRAM : if PACE_HAS_SRAM generate
      sram_a <= sram_o.a(sram_a'range);
      sram_i.d <= std_logic_vector(resize(unsigned(sram_d), sram_i.d'length));
      sram_d <= sram_o.d(sram_d'range) when (sram_o.cs = '1' and sram_o.we = '1') else (others => 'Z');
      -- this is completely wrong, but who cares atm
      sram_cs_n(3) <= not sram_o.cs;
      sram_cs_n(2) <= not sram_o.cs;
      sram_cs_n(1) <= not sram_o.cs;
      sram_cs_n(0) <= not sram_o.cs;
      sram_oe_n <= not sram_o.oe;
      sram_we_n <= not sram_o.we;
    end generate GEN_SRAM;
    
    GEN_NO_SRAM : if not PACE_HAS_SRAM generate
      sram_a <= (others => 'Z');
      sram_i.d <= (others => '1');
      sram_d <= (others => 'Z');
      sram_cs_n <= (others => '1');
      sram_oe_n <= '1';
      sram_we_n <= '1';  
    end generate GEN_NO_SRAM;
    
  end block BLK_SRAM;

  BLK_VIDEO : block
  begin

		video_i.clk <= clk_i(1);	-- by convention
		video_i.clk_ena <= '1';
    video_i.reset <= reset_i;
    
    vid_r <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-5);
    vid_g <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-5);
    vid_b <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-5);
    vid_hsync <= video_o.hsync;
    vid_vsync <= video_o.vsync;

  end block BLK_VIDEO;

  BLK_AUDIO : block
  
    alias clk_24M : std_logic is clk_50M;
  
  begin

    -- audio PWM
    -- clock is 24Mhz, sample rate 24kHz
    process (clk_24M, reset_i)
      variable count : integer range 0 to 1023;
      variable audio_sample_l : std_logic_vector(9 downto 0);
      variable audio_sample_r : std_logic_vector(9 downto 0);
    begin
      if reset_i = '1' then
        count := 0;
      elsif rising_edge(clk_24M) then
        if count = 1023 then
          -- 24kHz tick - latch a sample (only 10 bits or 1024 steps)
          audio_sample_l := audio_o.ldata(audio_o.ldata'left downto audio_o.ldata'left-9);
          audio_sample_r := audio_o.rdata(audio_o.rdata'left downto audio_o.rdata'left-9);
          count := 0;
        else
          audio_l <= '0';  -- default
          audio_r <= '0'; -- default
          if unsigned(audio_sample_l) > count then
            audio_l <= '1';
          end if;
          if unsigned(audio_sample_r) > count then
            audio_r <= '1';
          end if;
          count := count + 1;
        end if;
      end if;
    end process;
    
  end block BLK_AUDIO;

  BLK_SERIAL : block
  begin
    GEN_SERIAL : if PACE_HAS_SERIAL generate
      ser_tx <= ser_o.txd;
      ser_i.rxd <= ser_rx;
    end generate GEN_SERIAL;
  end block BLK_SERIAL;
  
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
      gp_i              => gp_i,
      gp_o              => gp_o
    );

end SYN;
