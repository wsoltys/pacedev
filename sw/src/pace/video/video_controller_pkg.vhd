library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package video_controller_pkg is

  type PACEVideoController_t is
  (
    PACE_VIDEO_NONE,                  -- PACE video controller not used
    PACE_VIDEO_VGA_800x600_60Hz,      -- generic VGA
    PACE_VIDEO_VGA_240x320_60Hz,      -- P3M video
    PACE_VIDEO_LCM_320x240_60Hz,      -- DE2 LCD
    PACE_VIDEO_CVBS_720x288p_50Hz     -- generic composite
  );

  type RGB_t is record
    r : std_logic_vector(9 downto 0);
    g : std_logic_vector(9 downto 0);
    b : std_logic_vector(9 downto 0);
  end record;

  type RGBArrayType is array (natural range <>) of RGB_t;

  type from_VIDEO_t is record
    clk       : std_logic;
    clk_ena   : std_logic;
  end record;
  
  type to_VIDEO_t is record
    clk       : std_logic;
    rgb       : rgb_t;
    hsync     : std_logic;
    vsync     : std_logic;
    hblank    : std_logic;
    vblank    : std_logic;
  end record;

  constant RGB_BLACK    : RGB_t := ((others=>'0'),(others=>'0'),(others=>'0'));
  constant RGB_RED      : RGB_t := ((others=>'1'),(others=>'0'),(others=>'0'));
  constant RGB_GREEN    : RGB_t := ((others=>'0'),(others=>'1'),(others=>'0'));
  constant RGB_YELLOW   : RGB_t := ((others=>'1'),(others=>'1'),(others=>'0'));
  constant RGB_BLUE     : RGB_t := ((others=>'0'),(others=>'0'),(others=>'1'));
  constant RGB_MAGENTA  : RGB_t := ((others=>'1'),(others=>'0'),(others=>'1'));
  constant RGB_CYAN     : RGB_t := ((others=>'0'),(others=>'1'),(others=>'1'));
  constant RGB_WHITE    : RGB_t := ((others=>'1'),(others=>'1'),(others=>'1'));
  
  component pace_video_controller is
    generic
    (
      CONFIG		  : PACEVideoController_t := PACE_VIDEO_NONE;
      H_SIZE      : integer;
      V_SIZE      : integer;
      H_SCALE     : integer;
      V_SCALE     : integer;
      BORDER_RGB  : RGB_t := RGB_BLACK;
      DELAY			  : integer := 0   		-- Number of clocks to delay sync and blank signals
    );
    port
    (
    clk     	: in std_logic;
    clk_ena   : in std_logic;
    reset   	: in std_logic;
    
    -- video input data
    rgb_i     : in RGB_t;

		-- control signals (out)
    stb  	    : out std_logic;
    x 	      : out std_logic_vector(10 downto 0);
    y 	      : out std_logic_vector(10 downto 0);

    -- Outputs to video
    video_o   : out to_VIDEO_t
    );
  end component pace_video_controller;

end;
