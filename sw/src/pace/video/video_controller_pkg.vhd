library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package video_controller_pkg is

  type PACEVideoController_t is
  (
    PACE_VIDEO_NONE,                  -- PACE video controller not used
    PACE_VIDEO_VGA_240x320_60Hz,      -- P3M video
    PACE_VIDEO_VGA_640x480_60Hz,      -- generic VGA (25.175MHz)
    PACE_VIDEO_VGA_800x600_60Hz,      -- generic VGA (40MHz)
    PACE_VIDEO_VGA_1024x768_60Hz,     -- XVGA (65MHz)
    PACE_VIDEO_LCM_320x240_60Hz,      -- DE2 LCD
    PACE_VIDEO_CVBS_720x288p_50Hz     -- generic composite
  );

  type PACEVideoDisplay_t is
  (
    PACE_DISPLAY_NONE,
    PACE_DISPLAY_VGA,
    PACE_DISPLAY_CVBS,
    PACE_DISPLAY_TFT
  );

  type RGB_t is record
    r : std_logic_vector(9 downto 0);
    g : std_logic_vector(9 downto 0);
    b : std_logic_vector(9 downto 0);
  end record;

  function NULL_RGB return RGB_t;

  constant RGB_BLACK    : RGB_t := ((others=>'0'),(others=>'0'),(others=>'0'));
  constant RGB_RED      : RGB_t := ((others=>'1'),(others=>'0'),(others=>'0'));
  constant RGB_GREEN    : RGB_t := ((others=>'0'),(others=>'1'),(others=>'0'));
  constant RGB_YELLOW   : RGB_t := ((others=>'1'),(others=>'1'),(others=>'0'));
  constant RGB_BLUE     : RGB_t := ((others=>'0'),(others=>'0'),(others=>'1'));
  constant RGB_MAGENTA  : RGB_t := ((others=>'1'),(others=>'0'),(others=>'1'));
  constant RGB_CYAN     : RGB_t := ((others=>'0'),(others=>'1'),(others=>'1'));
  constant RGB_WHITE    : RGB_t := ((others=>'1'),(others=>'1'),(others=>'1'));
  
	type VIDEO_REG_t is record
		h_scale		: std_logic_vector(2 downto 0);
		v_scale		: std_logic_vector(2 downto 0);
	end record;

  type from_VIDEO_t is record
    clk       : std_logic;
    clk_ena   : std_logic;
    reset     : std_logic;
  end record;
  
  type to_VIDEO_t is record
    clk       : std_logic;
    rgb       : rgb_t;
    hsync     : std_logic;
    vsync     : std_logic;
    hblank    : std_logic;
    vblank    : std_logic;
  end record;

  type from_VIDEO_CTL_t is record
    clk       : std_logic;
    clk_ena   : std_logic;
    stb       : std_logic;
    hblank    : std_logic;
    vblank    : std_logic;
    x         : std_logic_vector(10 downto 0);
    y         : std_logic_vector(10 downto 0);
  end record;
  
  subtype BITMAP_D_t is std_logic_vector(7 downto 0);
  subtype BITMAP_A_t is std_logic_vector(15 downto 0);
  
  type to_BITMAP_CTL_t is record
    d         : BITMAP_D_t;
  end record;
  
  function NULL_TO_BITMAP_CTL return to_BITMAP_CTL_t;

  type from_BITMAP_CTL_t is record
    a         : BITMAP_A_t;
    rgb       : RGB_t;
    set       : std_logic;
  end record;

  subtype TILEMAP_D_t is std_logic_vector(15 downto 0);
  subtype TILEMAP_A_t is std_logic_vector(15 downto 0);
  subtype TILE_A_t is std_logic_vector(15 downto 0);
  subtype TILE_D_t is std_logic_vector(7 downto 0);
  subtype ATTR_A_t is std_logic_vector(9 downto 0);
  subtype ATTR_D_t is std_logic_vector(15 downto 0);
  
  type to_TILEMAP_CTL_t is record
    map_d     : TILEMAP_D_t;
    tile_d    : TILE_D_t;
    attr_d    : ATTR_D_t;
  end record;
  
  function NULL_TO_TILEMAP_CTL return to_TILEMAP_CTL_t;

  type from_TILEMAP_CTL_t is record
    map_a     : TILEMAP_A_t;
    tile_a    : TILE_A_t;
    attr_a    : ATTR_A_t;
    rgb       : RGB_t;
    set       : std_logic;
  end record;

  subtype PAL_ENTRY_t is std_logic_vector(7 downto 0);
  type PAL_A_t is array (natural range <>) of PAL_ENTRY_t;
  
  type to_GRAPHICS_t is record
    pal       : PAL_A_t(15 downto 0);
    -- for various uses
    bit8_1    : std_logic_vector(7 downto 0);
    bit16_1   : std_logic_vector(15 downto 0);
  end record;

  function NULL_TO_GRAPHICS return to_GRAPHICS_t;

  type from_GRAPHICS_t is record
    y         : std_logic_vector(10 downto 0);
    vblank    : std_logic;
  end record;

  component pace_video_controller is
    generic
    (
      CONFIG		  : PACEVideoController_t := PACE_VIDEO_NONE;
      DELAY       : integer := 1;
      H_SIZE      : integer;
      V_SIZE      : integer;
      --H_SCALE     : integer;
      --V_SCALE     : integer;
      BORDER_RGB  : RGB_t := RGB_BLACK
    );
    port
    (
      -- clocking etc
      video_i       : in from_VIDEO_t;
      
      -- register interface
      reg_i			    : in VIDEO_REG_t;
      
      -- video input data
      rgb_i         : in RGB_t;

      -- control signals (out)
      video_ctl_o   : from_VIDEO_CTL_t;
      
      -- Outputs to video
      video_o       : out to_VIDEO_t
    );
  end component pace_video_controller;

end;
