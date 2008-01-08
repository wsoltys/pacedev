library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity led_fader is
	generic (
    nbits       : integer := 8       -- Bits to fade
  );
  port
  (
		-- Inputs
    clk       : in std_logic;
    clk_en    : in std_logic;
    pwm_en    : in std_logic;
    reset     : in std_logic;
    ledin     : in std_logic;
    fade      : in std_logic_vector(nbits-1 downto 0);

    -- Outputs
    ledout    : out std_logic
  );
end led_fader;

architecture SYN of led_fader is
  signal ledpwm   : std_logic_vector(nbits-1 downto 0);
begin

  pwm: work.pwmout generic map(nbits)
              port map(clk => clk, clk_en => pwm_en, reset => reset, oncount => ledpwm, o => ledout);

  -- LED fader process
  process(clk, reset, clk_en)
    constant zero: std_logic_vector(nbits-1 downto 0) := (others => '0');
  begin
    -- Reset
    if reset = '1' then
      ledpwm <= (others => '0');

    -- Synchronous logic
    elsif clk_en = '1' and rising_edge(clk) then
      if ledin = '1' then
        ledpwm <= (others => '1');
      elsif ledpwm /= zero then
        if ledpwm > fade then
          ledpwm <= ledpwm - fade;
        else
          ledpwm <= zero;
        end if;
      end if;
    end if;
  end process;
end SYN;

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
  signal ledin : std_logic_vector(nleds-1 downto 0);
begin

  gen: for I in 0 to nleds-1 generate
    fader: work.led_fader 
      generic map(nbits) 
      port map(clk => clk, clk_en => clk_en, pwm_en => pwm_en, reset => reset, 
        ledin => ledin(i), fade => fade, ledout => ledout(i));
  end generate;

	chaser: work.led_chaser
		generic map (nleds => nleds, period => period, bounce => bounce, hold_time => hold_time)
		port map (clk => clk, clk_en => clk_en, reset => reset, ledout => ledin);

end SYN;
