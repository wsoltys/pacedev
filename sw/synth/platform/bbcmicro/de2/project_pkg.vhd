library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 50MHz
	constant PACE_HAS_PLL										  : boolean := true;
  constant PACE_CLK0_DIVIDE_BY              : natural := 25;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 8;   -- 50*8/25 = 16MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 25;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 8;   -- 50*8/25 = 16MHz

  -- DE2-specific constants
  constant DE2_JAMMA_IS_MAPLE               : boolean := false;
  constant DE2_JAMMA_IS_NGC                 : boolean := true;

	constant DE2_LCD_LINE2							      : string := "   BBC MICRO    ";

	-- BBC-specific constants

  constant BBC_RAM_32K                      : std_logic := '1';
  constant BBC_RAM_16K                      : std_logic := not BBC_RAM_32K;

  -- startup link options (on keyboard PCB)
  constant BBC_STARTUP_OPT_NOT_USED         : std_logic_vector(1 downto 0) := "11";
  constant BBC_STARTUP_OPT_DISK_SPEED       : std_logic_vector(1 downto 0) := "11";
  constant BBC_STARTUP_OPT_SHIFT_BREAK      : std_logic := '1';
  constant BBC_STARTUP_OPT_MODE             : std_logic_vector(2 downto 0) := "110";

	constant BBC_1MHz_CLK0_COUNTS				      : natural := 16;

  constant BBC_USE_INTERNAL_RAM             : boolean := false;

  -- implementation options

  constant BBC_USE_ROCKOLA_6845             : boolean := true;
  constant BBC_USE_OC_6845                  : boolean := not BBC_USE_ROCKOLA_6845;

end;
