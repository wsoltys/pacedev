library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.video_controller_pkg.RGB_t;

package sprite_pkg is

  subtype SPRITE_N_t is std_logic_vector(11 downto 0);
  subtype SPRITE_A_t is std_logic_vector(7 downto 0);
  subtype SPRITE_D_t is std_logic_vector(7 downto 0);
  
  type from_SPRITE_REG_t is record
    n         : SPRITE_N_t;
    x         : std_logic_vector(10 downto 0);
    y         : std_logic_vector(10 downto 0);
    xflip     : std_logic;
    yflip     : std_logic;
    colour    : std_logic_vector(7 downto 0);
    pri       : std_logic;
  end record;
  
  type to_SPRITE_REG_t is record
    clk       : std_logic;
    clk_ena   : std_logic;
    wr        : std_logic;
    a         : SPRITE_A_t;
    d         : SPRITE_D_t;
  end record;

end package sprite_pkg;
