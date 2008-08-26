library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.RGB_t;
use work.pace_pkg.to_VIDEO_t;

package video_controller_pkg is

  type PACEVideoController_t is
  (
    PACE_VIDEO_NONE,                  -- PACE video controller not used
    PACE_VIDEO_VGA_800x600_60Hz,      -- generic VGA
    PACE_VIDEO_VGA_240x320_60Hz,      -- P3M video
    PACE_VIDEO_LCM_320x240_60Hz,      -- DE2 LCD
    PACE_VIDEO_CVBS_720x288p_50Hz     -- generic composite
  );

  component pace_video_controller is
    generic
    (
      CONFIG		: PACEVideoController_t := PACE_VIDEO_NONE;
      H_SIZE    : integer;
      V_SIZE    : integer;
      H_SCALE   : integer;
      V_SCALE   : integer;
      DELAY			: integer := 0   		-- Number of clocks to delay sync and blank signals
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
