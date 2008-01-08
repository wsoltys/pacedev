library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- Model I

entity TRS80_Interrupts is
  port
  (
    clk               : in    std_logic;
    reset             : in    std_logic;

    z80_data          : in    std_logic_vector(7 downto 0);

    -- interrupt sources
    reset_btn_int     : in    std_logic;                      -- reset button
    fdc_drq_int       : in    std_logic;                      -- data request

    -- interrupt status & request lines
    int_status        : out   std_logic_vector(7 downto 0);   -- read from $37E0
    int_req           : out   std_logic;
    
    -- interrupt resets
    int_reset         : in    std_logic                       -- read from $37E0
  );

end TRS80_Interrupts;

architecture SYN of TRS80_Interrupts is

  signal slow_clk_ena   : std_logic; -- 1MHz
  signal timer_int      : std_logic;
  signal int_status_s	  : std_logic_vector(7 downto 0);
  signal intena_s       : std_logic_vector(7 downto 0);

begin

  -- generate 1MHz (1us) clock enable
  process (clk, reset)
    variable count_v      : natural range 0 to 19;
  begin
    if reset = '1' then
      count_v := 0;
      slow_clk_ena <= '0';
    elsif rising_edge(clk) then
      if count_v = 19 then
        count_v := 0;
        slow_clk_ena <= '1';
      else
        count_v := count_v + 1;
        slow_clk_ena <= '0';
      end if;
    end if;
  end process;

  -- TIMER interrupt (40Hz/25ms)
  process (clk, reset)
    variable count : natural range 0 to 24999;
  begin
    if reset = '1' then
      count := 0;
      timer_int <= '0';
    elsif rising_edge (clk) then
      if slow_clk_ena = '1' then
        if count = 24999 then
          count := 0;
          timer_int <= '1';
        else
          count := count + 1;
          timer_int <= '0';
        end if;
      end if;
    end if;
  end process;

  -- update/clear INT status
  process (clk, reset, timer_int, fdc_drq_int, int_reset)
		variable int_reset_old : std_logic;
  begin
    if reset = '1' then
			int_reset_old := '0';
      int_status_s <= (others => '0');
    elsif rising_edge (clk) then
			-- reading interrupt status also resets bits
			-- - so only reset bits on falling edge of read
			if int_reset_old = '1' and int_reset = '0' then
				int_status_s(6) <= '0';
        int_status_s(7) <= '0';
			end if;
			-- timer
      if timer_int = '1' then
         int_status_s(7) <= '1';
      end if;
			-- FDC
			if fdc_drq_int = '1' then
				int_status_s(6) <= '1';
			end if;
			-- latch for trailing-edge-detect
			int_reset_old := int_reset;
    end if;
  end process;

  -- generate INT
  int_status <= int_status_s;
  int_req <= '1' when (int_status_s) /= X"00" else '0';
  
end SYN;

