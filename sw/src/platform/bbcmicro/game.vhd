library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use	ieee.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.platform_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk         		: in std_logic_vector(0 to 3);
    reset           : in    std_logic;                       
    test_button     : in    std_logic;                       

    -- inputs
    ps2clk          : inout std_logic;                       
    ps2data         : inout std_logic;                       
    dip             : in    std_logic_vector(7 downto 0);    

    -- micro buses
    upaddr          : out   std_logic_vector(15 downto 0);   
    updatao         : out   std_logic_vector(7 downto 0);    

    -- SRAM
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    gfxextra_data   : out std_logic_vector(7 downto 0);

    -- graphics (control)
    red							: out		std_logic_vector(7 downto 0);
		green						: out		std_logic_vector(7 downto 0);
		blue						: out		std_logic_vector(7 downto 0);
		hsync						: out		std_logic;
		vsync						: out		std_logic;

    cvbs            : out   std_logic_vector(7 downto 0);
			  
    -- sound
    snd_rd          : out   std_logic;                       
    snd_wr          : out   std_logic;
    sndif_datai     : in    std_logic_vector(7 downto 0);    

    -- spi interface
    spi_clk         : out   std_logic;                       
    spi_din         : in    std_logic;                       
    spi_dout        : out   std_logic;                       
    spi_ena         : out   std_logic;                       
    spi_mode        : out   std_logic;                       
    spi_sel         : out   std_logic;                       

    -- serial
    ser_rx          : in    std_logic;                       
    ser_tx          : out   std_logic;                       

    -- on-board leds
    leds            : out   std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

  --
  -- COMPONENTS
  --

  component crtc6845s is
    port
    (
      -- INPUT
      I_E         : in std_logic;
      I_DI        : in std_logic_vector(7 downto 0);
      I_RS        : in std_logic;
      I_RWn       : in std_logic;
      I_CSn       : in std_logic;
      I_CLK       : in std_logic;
      I_RSTn      : in std_logic;

      -- OUTPUT
      O_RA        : out std_logic_vector(4 downto 0);
      O_MA        : out std_logic_vector(13 downto 0);
      O_H_SYNC    : out std_logic;
      O_V_SYNC    : out std_logic;
      O_DISPTMG   : out std_logic
    );
  end component crtc6845s;

  --
  -- SIGNALS
  --

  signal reset_n            : std_logic;

  -- CPU signals
  signal cpu_d_i            : std_logic_vector(7 downto 0);
  signal cpu_d_o            : std_logic_vector(7 downto 0);

  -- CRTC6845 signals
  signal crtc6845_cs_n      : std_logic;
  signal crtc6845_rs        : std_logic;
  signal crtc6845_e         : std_logic;
  signal crtc6845_rw_n      : std_logic;
  signal crtc6845_ra        : std_logic_vector(4 downto 0);
  signal crtc6845_ma        : std_logic_vector(13 downto 0);
  signal crtc6845_disptmg   : std_logic;

begin

  reset_n <= not reset;

  -- unused outputs
  gfxextra_data <= (others => '0');
  cvbs <= (others => '0');
  snd_rd <= '0';
  snd_wr <= '0';
  spi_clk <= '0';
  spi_dout <= '0';
  spi_ena <= '0';
  spi_mode <= '0';
  spi_sel <= '0';
  ser_tx <= '0';
  leds <= (others => '0');

  --
  --  COMPONENT INSTANTIATION
  --

  BLK_VIDEO : block

    signal crtc6845_hsync : std_logic;
    signal crtc6845_vsync : std_logic;

  begin

    crtc6845s_inst : crtc6845s
      port map
      (
        -- INPUT
        I_E         => crtc6845_e,
        I_DI        => cpu_d_o,
        I_RS        => crtc6845_rs,
        I_RWn       => crtc6845_rw_n,
        I_CSn       => crtc6845_cs_n,
        I_CLK       => clk(0),
        I_RSTn      => reset_n,

        -- OUTPUT
        O_RA        => crtc6845_ra,
        O_MA        => crtc6845_ma,
        O_H_SYNC    => crtc6845_hsync,
        O_V_SYNC    => crtc6845_vsync,
        O_DISPTMG   => crtc6845_disptmg
      );

  end block BLK_VIDEO;
		
end SYN;
