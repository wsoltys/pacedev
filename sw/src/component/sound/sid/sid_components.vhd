-------------------------------------------------------------------------------------
--
--                                 SID 6581 (voice)
--
--     This piece of VHDL code describes a single SID voice (sound channel)
--
-------------------------------------------------------------------------------------
--	to do:	- better resolution of result signal voice, this is now only 12bits, but it could be 20 !! Problem, it does not fit the PWM-dac
--------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--Implementation Digital to Analog converter
entity pwm_sddac is
	port (
		clk 		: in std_logic;								-- main clock signal, the higher the better
		PWM_in 	: in std_logic_vector(17 downto 0);		--	binary input of signal to be converted
		PWM_out 	: out std_logic								--	PWM output after a simple low-pass filter this is to be considered an analog signal
		);
end pwm_sddac;

architecture SYN of pwm_sddac is
begin
end SYN;
	
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity pwm_sdadc is
  port (
  			clk		: in std_logic;								-- main clock signal (actually the higher the better)
		reset		: in std_logic;								--
		ADC_out 	: out std_logic_vector(7 downto 0);		--	binary input of signal to be converted
		ADC_in 	: inout std_logic								--	"analog" paddle input pin
  		);
end pwm_sdadc;

architecture SYN of pwm_sdadc is
begin
end SYN;
