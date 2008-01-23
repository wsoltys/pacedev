library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package video_controller_pkg is

  component pace_video_controller is
    generic
    (
      delay   : in integer := 0   -- Number of clocks to delay sync and blank signals
    );
    port
    (
  		-- Inputs
      clk     	: in std_logic;
      reset   	: in std_logic;
      r_i     	: in std_logic_vector(9 downto 0);
      g_i     	: in std_logic_vector(9 downto 0);
      b_i     	: in std_logic_vector(9 downto 0);
  		xcentre 	: in std_logic_vector(9 downto 0);
  		ycentre 	: in std_logic_vector(9 downto 0);
  
  		-- Video control signals (out)
      strobe  	: out std_logic;
      pixel_x 	: out std_logic_vector(9 downto 0);
      pixel_y 	: out std_logic_vector(9 downto 0);
      hblank  	: out std_logic;
      vblank  	: out std_logic;
  
      -- Outputs
      red     	: out std_logic_vector(9 downto 0);
      green   	: out std_logic_vector(9 downto 0);
      blue    	: out std_logic_vector(9 downto 0);
  		lcm_data	: out std_logic_vector(9 downto 0);
      vsync   	: out std_logic;
      hsync   	: out std_logic
    );
  end component pace_video_controller;

end;

