library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
    -- clocks
    clkin_50                         : in std_logic;
    clkin_125                        : in std_logic;
    clkin_sma                        : in std_logic;
    clkout_sma                       : out std_logic;

    -- user pushbuttons, dipswitches and leds
    cpu_resetn                       : in std_logic;
    user_pb                          : in std_logic_vector(3 downto 0);
    user_dipsw                       : in std_logic_vector(7 downto 0);
    user_led                         : out std_logic_vector(7 downto 0);

    -- quad 7-segment display
    seven_seg_a                      : out std_logic;
    seven_seg_b                      : out std_logic;
    seven_seg_c                      : out std_logic;
    seven_seg_d                      : out std_logic;
    seven_seg_e                      : out std_logic;
    seven_seg_f                      : out std_logic;
    seven_seg_g                      : out std_logic;
    seven_seg_dp                     : out std_logic;
    seven_seg_minus                  : out std_logic;
    -- ???
    seven_seg_sel                    : out std_logic_vector(4 downto 1);

    -- SRAM (8MB 32-bit bus)
    sram_ben                         : out std_logic_vector(3 downto 0);
    sram_clk                         : out std_logic;
    sram_csn                         : out std_logic;
    sram_oen                         : out std_logic;
    sram_psn                         : out std_logic;
    sram_wait                        : in std_logic_vector(1 downto 0);
    sram_wen                         : out std_logic;
    sram_advn                        : out std_logic;

    -- FLASH (64MB 16-bit bus)
    flash_cen                        : out std_logic;
    flash_oen                        : out std_logic;
    flash_rdybsyn                    : in std_logic;
    flash_resetn                     : out std_logic;
    flash_wen                        : out std_logic;

    -- shared SRAM/FLASH data/address bus
    fsa                              : out std_logic_vector(24 downto 0);
    fsd                              : inout std_logic_vector(31 downto 0);

    -- DDR memory banks
    --ddr2_ck_n                        : out std_logic_vector(2 downto 0);
    --ddr2_ck_p                        : out std_logic_vector(2 downto 0);
    --ddr2_dm                          : out std_logic_vector(8 downto 0);
    --ddr2_dq                          : inout std_logic_vector(71 downto 0);
    --ddr2_dqs                         : inout std_logic_vector(8 downto 0);

    -- DDR2 bottom bank
    --ddr2bot_a                        : out std_logic_vector(15 downto 0);
    --ddr2bot_active                   : out std_logic; -- LED
    --ddr2bot_ba                       : out std_logic_vector(2 downto 0);
    --ddr2bot_casn                     : out std_logic;
    --ddr2bot_cke                      : out std_logic;
    --ddr2bot_csn                      : out std_logic;
    --ddr2bot_odt                      : out std_logic;
    --ddr2bot_rasn                     : out std_logic;
    --ddr2bot_wen                      : out std_logic;

    -- DDR2 top bank
    --ddr2top_a                        : out std_logic_vector(15 downto 0);
    --ddr2top_active                   : out std_logic; -- LED
    --ddr2top_ba                       : out std_logic_vector(2 downto 0);
    --ddr2top_casn                     : out std_logic;
    --ddr2top_cke                      : out std_logic;
    --ddr2top_csn                      : out std_logic;
    --ddr2top_odt                      : out std_logic;
    --ddr2top_rasn                     : out std_logic;
    --ddr2top_wen                      : out std_logic;

    -- character & graphic LCD
    lcd_data                         : out std_logic_vector(7 downto 0);
    -- character LCD
    lcd_d_cn                         : out std_logic;
    lcd_wen                          : out std_logic;
    lcd_csn                          : out std_logic;
    -- graphic LCD ???
    lcd_e_rdn                        : out std_logic;
    lcd_rstn                         : out std_logic;
    lcd_en                           : out std_logic; -- ???

    enet_gtx_clk                     : in std_logic;
    enet_led_link1000                : out std_logic;
    enet_mdc                         : out std_logic;
    enet_mdio                        : inout std_logic;
    enet_resetn                      : in std_logic;
    enet_rx_clk                      : in std_logic;
    enet_rxd                         : in std_logic_vector(3 downto 0);
    enet_rx_dv                       : in std_logic;
    enet_txd                         : out std_logic_vector(3 downto 0);
    enet_tx_en                       : out std_logic;

    max2_clk                         : in std_logic;
    max_csn                          : in std_logic;
    max_oen                          : in std_logic;
    max_wen                          : in std_logic;

    usb_fd                           : in std_logic_vector(7 downto 0);
    usb_ren                          : in std_logic;
    usb_wen                          : in std_logic;
    usb_ifclk                        : in std_logic;
    usb_cmd_data                     : in std_logic;
    usb_empty                        : in std_logic;
    usb_full                         : in std_logic;

    hsma_sda                         : inout std_logic;
    hsma_scl                         : inout std_logic;
    hsma_clk_out0                    : out std_logic;
    hsma_clk_in0                     : in std_logic;
    hsma_d                           : inout std_logic_vector(3 downto 0);
    hsma_tx_d_p                      : out std_logic_vector(16 downto 0);
    hsma_rx_d_p                      : out std_logic_vector(16 downto 0);
    hsma_tx_d_n                      : out std_logic_vector(16 downto 0);
    hsma_rx_d_n                      : out std_logic_vector(16 downto 0);
    hsma_clk_out_p                   : out std_logic_vector(2 downto 1);
    hsma_clk_in_p                    : in std_logic_vector(2 downto 1);
    hsma_clk_out_n                   : out std_logic_vector(2 downto 1);
    hsma_clk_in_n                    : in std_logic_vector(2 downto 1);
    hsma_rx_led                      : out std_logic;
    hsma_tx_led                      : out std_logic;

    hsmb_sda                         : inout std_logic;
    hsmb_scl                         : inout std_logic;
    hsmb_clk_out0                    : out std_logic;
    hsmb_clk_in0                     : in std_logic;
    hsmb_d                           : inout std_logic_vector(3 downto 0);
    hsmb_tx_d                        : out std_logic_vector(16 downto 0);
    hsmb_rx_d                        : in std_logic_vector(16 downto 0);
    hsmb_clk_in                      : in std_logic_vector(2 downto 1);
    hsmb_clk_out                     : out std_logic_vector(2 downto 1);
    hsmb_rx_led                      : out std_logic;
    hsmb_tx_led                      : out std_logic;

    speaker_out                      : out std_logic
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
  
  -- DVI OUT assignment
  signal bitec_dvi_io_out           : std_logic_vector(23 downto 0);
  alias bitec_dvi_io_out_dvi_clk    : std_logic is hsma_tx_d_n(15);
  signal bitec_dvi_io_out_dvi_ctl   : std_logic_vector(3 downto 1);
  alias bitec_dvi_io_out_dat        : std_logic is hsma_tx_d_p(15);
  alias bitec_dvi_io_out_de         : std_logic is hsma_tx_d_n(10);
  alias bitec_dvi_io_out_hsync      : std_logic is hsma_tx_d_p(11);
  alias bitec_dvi_io_out_idckn      : std_logic is hsma_clk_out_n(1);
  alias bitec_dvi_io_out_idckp      : std_logic is hsma_clk_out_p(1);
  alias bitec_dvi_io_out_dvi_isel   : std_logic is hsma_tx_d_n(14);
  alias bitec_dvi_io_out_msen       : std_logic is hsma_tx_d_p(14);
  alias bitec_dvi_io_out_dvi_pd     : std_logic is hsma_tx_d_n(13);
  alias bitec_dvi_io_out_vsync      : std_logic is hsma_tx_d_n(11);
  alias bitec_dvi_io_out_ddc_ck     : std_logic is hsma_rx_d_n(7);
  alias bitec_dvi_io_out_ddc_dat    : std_logic is hsma_rx_d_p(7);
  alias bitec_dvi_io_out_dvi_dken   : std_logic is hsma_tx_d_n(6);

begin

  BLK_PLL : block
    component pll IS
      PORT
      (
        inclk0		: IN STD_LOGIC  := '0';
        c0		    : OUT STD_LOGIC ;
        c1		    : OUT STD_LOGIC 
      );
    END component pll;
  begin
    GEN_PLL : if PACE_HAS_PLL generate
      pll_inst : pll
        port map
        (
          inclk0	=> clkin_50,
          c0		  => clk_i(0),
          c1		  => clk_i(1)
        );
    end generate GEN_PLL;  
  end block BLK_PLL;
  
  BLK_DVI_OUT : block
  begin
    -- connect DVI OUT CTL lines
    hsma_tx_d_p(13) <= bitec_dvi_io_out_dvi_ctl(1);
    hsma_tx_d_n(12) <= bitec_dvi_io_out_dvi_ctl(2);
    hsma_tx_d_p(12) <= bitec_dvi_io_out_dvi_ctl(3);

    -- connect DVI OUT IO OUT lines
    hsma_tx_d_n(16) <= bitec_dvi_io_out(0);
    hsma_tx_d_p(16) <= bitec_dvi_io_out(1);
    hsma_rx_d_n(16) <= bitec_dvi_io_out(2);
    hsma_rx_d_p(16) <= bitec_dvi_io_out(3);
    hsma_rx_d_n(15) <= bitec_dvi_io_out(4);
    hsma_rx_d_p(15) <= bitec_dvi_io_out(5);
    hsma_rx_d_n(14) <= bitec_dvi_io_out(6);
    hsma_rx_d_p(14) <= bitec_dvi_io_out(7);
    hsma_rx_d_n(13) <= bitec_dvi_io_out(8);
    hsma_rx_d_p(13) <= bitec_dvi_io_out(9);
    hsma_rx_d_n(12) <= bitec_dvi_io_out(10);
    hsma_rx_d_p(12) <= bitec_dvi_io_out(11);
    hsma_rx_d_n(11) <= bitec_dvi_io_out(12);
    hsma_rx_d_p(11) <= bitec_dvi_io_out(13);
    hsma_rx_d_n(10) <= bitec_dvi_io_out(14);
    hsma_rx_d_p(10) <= bitec_dvi_io_out(15);
    hsma_rx_d_n(9) <= bitec_dvi_io_out(16);
    hsma_rx_d_p(9) <= bitec_dvi_io_out(17);
    hsma_rx_d_n(8) <= bitec_dvi_io_out(18);
    hsma_rx_d_p(8) <= bitec_dvi_io_out(19);
    hsma_tx_d_n(8) <= bitec_dvi_io_out(20);
    hsma_tx_d_p(8) <= bitec_dvi_io_out(21);
    hsma_tx_d_n(7) <= bitec_dvi_io_out(22);
    hsma_tx_d_p(7) <= bitec_dvi_io_out(23);

  end block BLK_DVI_OUT;
  
end SYN;
