library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity led_chaser is
	generic (
    nleds       : integer := 8;      -- Number of LEDs
    period      : integer := 32;     -- Chaser period (in clocks)
    bounce      : std_logic := '1';  -- Bounce led
    hold_time   : integer := 16      -- Number of periods to hold at each end (0 to disable)
  );
  port
  (
		-- Inputs
    clk       : in std_logic;
    clk_en    : in std_logic;
    reset     : in std_logic;

    -- Outputs
    ledout    : out std_logic_vector(nleds-1 downto 0)
  );

end led_chaser;

architecture SYN of led_chaser is
begin

  -- Magic LED process
  process(clk, reset, clk_en)
    variable leds       : std_logic_vector(nleds-1 downto 0);
    variable secdiv_cnt : integer;
    variable secdiv     : std_logic;
    variable dir        : std_logic;
    variable hold       : std_logic;
    variable hold_cnt   : integer;
  begin
    ledout <= leds;

    -- Reset
    if reset = '1' then
      leds := (0 => '1', others => '0');
      secdiv_cnt := 0;
      secdiv := '0';
      dir := '1';

    -- Synchronous logic
    elsif clk_en = '1' and rising_edge(clk) then
      -- LED hold counter
      if secdiv = '1' and hold = '1' then
        if hold_cnt < hold_time then
          hold_cnt := hold_cnt + 1;
        else
          hold := '0';
        end if;
      end if;

      -- Chaser logic
      if secdiv = '1' and hold = '0' then
        if bounce = '0' or dir = '1' then
          leds := leds(nleds-2 downto 0) & leds(nleds-1);
        else
          leds := leds(0) & leds(nleds-1 downto 1);
        end if;
        if leds(nleds-1) = '1' then
          if hold_time > 0 then
            hold_cnt := 0;
            hold := '1';
          end if;
          dir := '0';
        elsif leds(0) = '1' then
          if hold_time > 0 then
            hold_cnt := 0;
            hold := '1';
          end if;
          dir := '1';
        end if;
      end if;

      -- Calculate period HZ divisor pulse
      secdiv := '0';
      secdiv_cnt := secdiv_cnt + 1;
      if secdiv_cnt >= period then
        secdiv_cnt := 0;
        secdiv := '1';
      end if;
    end if;
  end process;

end SYN;
