library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pwmout is
	generic (
    resolution : integer := 8      -- PWM resolution (bits)
  );
  port
  (
		-- Inputs
    clk       : in std_logic;
    clk_en    : in std_logic;
    reset     : in std_logic;
    oncount   : in std_logic_vector(resolution-1 downto 0);

    -- Outputs
    o         : out std_logic
  );

end pwmout;

architecture SYN of pwmout is
begin

  process(clk, reset, clk_en)
    variable count  : std_logic_vector(resolution-1 downto 0);
    variable out_r  : std_logic;
    constant zero   : std_logic_vector(resolution-1 downto 0) := (others => '0');
  begin
    o <= out_r;

    -- Reset
    if reset = '1' then
      out_r := '0';
      count := (others => '0');

    -- Synchronous logic
    elsif clk_en = '1' and rising_edge(clk) then
      if count = zero then
        out_r := '1';
      end if;
      if count = oncount then
        out_r := '0';
      end if;
      count := count + 1;
    end if;
  end process;

end SYN;

