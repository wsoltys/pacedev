library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package maple_pkg is

	subtype maple_byte is std_logic_vector(7 downto 0);
	subtype maple_word is std_logic_vector(31 downto 0);
	type maple_pkt_type is array (natural range<>) of maple_word;

  type joystate_type is record
    start		: std_logic;											-- Start button
    a				: std_logic;											-- A button
		b				: std_logic;											-- B button
    x				: std_logic;											-- X button
		y				: std_logic;											-- Y button
    d_up		: std_logic;											-- D pad
		d_down	: std_logic;
    d_left	: std_logic;
		d_right	: std_logic;
    jx			: std_logic_vector(7 downto 0);		-- Joystick X
    jy			: std_logic_vector(7 downto 0);		-- Joystick Y
    lv			: std_logic_vector(7 downto 0);		-- Left shoulder value
    rv			: std_logic_vector(7 downto 0);		-- Right shoulder value
	end record;

	component maple_joy is
		generic (
			MHZ				: natural := 48
		);
	  port
	  (
	  	clk      	: in std_logic;                         --	48 MHz
			reset			: in std_logic;
			sense			: in std_logic;
			oe				: out std_logic;
			a					: inout std_logic;
			b					: inout std_logic;
			joystate	: out joystate_type
		);
	end component maple_joy;
	
end;
