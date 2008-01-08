library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity TRS80_Interrupts is
  port
  (
    clk               : in    std_logic;
    reset             : in    std_logic;

    z80_data          : in    std_logic_vector(7 downto 0);
    intena_wr         : in    std_logic;
    nmiena_wr         : in    std_logic;

    -- interrupt sources
    reset_btn_int     : in    std_logic;                      -- reset button
    fdc_drq_int       : in    std_logic;                      -- data request
    fdc_dto_int       : in    std_logic;                      -- drive timeout

    -- interrupt status & request lines
    int_status        : out   std_logic_vector(7 downto 0);   -- port $E0-E3
    int_req           : out   std_logic;
    nmi_status        : out   std_logic_vector(7 downto 0);   -- port $E4
    nmi_req           : out   std_logic;
    
    -- interrupt resets
    rtc_reset         : in    std_logic;                      -- read from $EC-EF
    nmi_reset         : in    std_logic                       -- read from $E4
  );

end TRS80_Interrupts;

architecture SYN of TRS80_Interrupts is

  signal slow_clk_ena   : std_logic; -- 1MHz
  signal rtc_int        : std_logic;
  signal int_status_s	  : std_logic_vector(7 downto 0);
  signal nmi_status_s	  : std_logic_vector(7 downto 0);
  signal intena_s       : std_logic_vector(7 downto 0);
  signal nmiena_s       : std_logic_vector(7 downto 0);  

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

  -- latch interrupt enables
  process (clk, reset)
  begin
    if reset = '1' then
      intena_s <= (others => '0');
      nmiena_s <= (others => '0');
    elsif rising_edge (clk) then
      if intena_wr = '1' then
        intena_s <= z80_data;
      end if;
      if nmiena_wr = '1' then
        -- only bits 6,7 implemented, 5 (reset) always enabled
        nmiena_s <= z80_data(7 downto 6) & "100000";
      end if;
    end if;
  end process;

  -- RTC interrupt
  process (clk, reset)
    variable count : natural range 0 to 33332;
  begin
    if reset = '1' then
      count := 0;
      rtc_int <= '0';
    elsif rising_edge (clk) then
      if slow_clk_ena = '1' then
        if count = 33332 then
          count := 0;
          rtc_int <= '1';
        else
          count := count + 1;
          rtc_int <= '0';
        end if;
      end if;
    end if;
  end process;

  -- update/clear INT status
  process (clk, reset)
  begin
    if reset = '1' then
      int_status_s <= (others => '0');
    elsif rising_edge (clk) then
      if rtc_int = '1' then
         int_status_s(2) <= '1';
      elsif (rtc_reset = '1') then
        int_status_s(2) <= '0';
      end if;
    end if;
  end process;

  -- generate INT
  int_status <= int_status_s;
  int_req <= '1' when (int_status_s and intena_s) /= X"00" else '0';
  
  -- update/clear NMI interrupt status
  process (clk, reset)
    variable nmi_reset_v : std_logic;
  begin
    if reset = '1' then
      nmi_reset_v := '0';
      nmi_status_s <= (others => '0');
    elsif rising_edge (clk) then
      if fdc_drq_int = '1' then
        nmi_status_s(7) <= '1';
      elsif fdc_dto_int = '1' then
        nmi_status_s(6) <= '1';
      elsif reset_btn_int = '1' then
        nmi_status_s(5) <= '1';
      -- clear nmi status on *falling* edge of nmi_reset
      elsif nmi_reset = '0' and nmi_reset_v = '1' then
        nmi_status_s <= (others => '0');
      end if;
      -- latch the last value of nmi_reset
      nmi_reset_v := nmi_reset;
    end if;
  end process;

  -- generate NMI
  nmi_status <= nmi_status_s;
  --nmi_req <= '1' when (nmi_status_s and nmiena_s) /= X"00" else '0';
  nmi_req <= '1' when (fdc_drq_int and nmiena_s(7)) /= '0' else '0';
  
end SYN;

