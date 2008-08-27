library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pwm_chaser is
	generic (
    nleds       : integer := 8;       -- Number of LEDs
    nbits       : integer := 8;       -- Bits to fade
    period      : integer := 32;      -- Chaser period (in clocks)
    bounce      : std_logic := '1';   -- Bounce led
    hold_time   : integer := 16       -- Number of periods to hold at each end (0 to disable)
  );
  port
  (
		-- Inputs
    clk       : in std_logic;
    clk_en    : in std_logic;
    pwm_en    : in std_logic;
    reset     : in std_logic;
    fade      : in std_logic_vector(nbits-1 downto 0) := std_logic_vector(conv_unsigned(16, nbits));

    -- Outputs
    ledout    : out std_logic_vector(nleds-1 downto 0)
  );

end pwm_chaser;

architecture SYN of pwm_chaser is
begin
end SYN;
