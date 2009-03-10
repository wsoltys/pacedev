library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
--use work.video_controller_pkg.all;
--use work.maple_pkg.all;
--use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
    -- clocking
    clk_50M_i       : in std_logic;
    
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

  signal  clk_50M     : std_logic := '0';
  signal  clk_100M    : std_logic := '0';

begin

  pll1_inst : ENTITY work.pll1
    port map
    (
      inclk0		=> clk_50M_i,
      c0		    => clk_50M,
      c1		    => clk_100M,
      locked		=> open
    );

end SYN;
