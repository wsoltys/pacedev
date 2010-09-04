library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package gamecube_pkg is

	subtype byte is std_logic_vector(7 downto 0);
	type packet_type is array(7 downto 0) of byte;

  type joystate_type is record
    start		: std_logic;											-- Start button
    a				: std_logic;											-- A button
		b				: std_logic;											-- B button
    x				: std_logic;											-- X button
		y				: std_logic;											-- Y button
    l				: std_logic;											-- Left shoulder limit
		r				: std_logic;											-- Right shoulder limit
		z				: std_logic;											-- Z button
    d_up		: std_logic;											-- D pad
		d_down	: std_logic;
    d_left	: std_logic;
		d_right	: std_logic;
    jx			: std_logic_vector(7 downto 0);		-- Joystick X
    jy			: std_logic_vector(7 downto 0);		-- Joystick Y
    cx			: std_logic_vector(7 downto 0);		-- C stick X
    cy			: std_logic_vector(7 downto 0);		-- C stick Y
    lv			: std_logic_vector(7 downto 0);		-- Left shoulder value
    rv			: std_logic_vector(7 downto 0);		-- Right shoulder value
  end record;

  component gamecube_joy is
    generic (
      MHZ				: natural := 50
    );
    port (
      clk      	: in std_logic;
      reset			: in std_logic;
      d_i				: in std_logic;
      d_o       : out std_logic;
      d_oe			: out std_logic;
      joystate	: out joystate_type
    );
  end component gamecube_joy;

end;
