library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity floppy is
  generic
  (
    NUM_TRACKS      : integer := 35;
    DOUBLE_DENSITY  : boolean := false
  );
  port
  (
    clk           : in std_logic;
    clk_20M_ena   : in std_logic;
    reset         : in std_logic;
    
    step          : in std_logic;
    dirc          : in std_logic;
    rclk          : out std_logic;
    raw_read_n    : out std_logic;
    tr00_n        : out std_logic;
    ip_n          : out std_logic;

    -- memory interface
    mem_a         : out std_logic_vector(19 downto 0);
    mem_d_i       : in std_logic_vector(7 downto 0);
    mem_d_o       : out std_logic_vector(7 downto 0);
    mem_we        : out std_logic;
    
    debug         : out std_logic_vector(15 downto 0)
  );
end entity floppy;

architecture FLASH of floppy is

  signal clk_1M_ena   : std_logic := '0';
  
  signal track_r      : std_logic_vector(7 downto 0) := (others => '0');

begin

  -- 1MHz clock (enable) generate
  process (clk, clk_20M_ena, reset)
    subtype count_t is integer range 0 to 19;
    variable count_v : count_t := 0;
  begin
    if reset = '1' then
      count_v := 0;
    elsif rising_edge(clk) and clk_20M_ena = '1' then
      clk_1M_ena <= '0';
      if count_v = count_t'high then
        clk_1M_ena <= '1';
        count_v := 0;
      else
        count_v := count_v + 1;
      end if;
    end if;
  end process;

  -- handle track register, stepping
  process (clk, clk_20M_ena, reset)
    variable step_r : std_logic := '0';
  begin
    if reset = '1' then
      step_r := '0';
      track_r <= (others => '0');
    elsif rising_edge(clk) and clk_20M_ena = '1' then
      -- leading edge of step
      if step_r = '0' and step = '1' then
        if dirc = '0' then
          -- step out (decrement track)
          if track_r /= 0 then
            track_r <= track_r - 1;
          end if;
        else
          -- step in (increment track)
          if track_r < NUM_TRACKS-1 then
            track_r <= track_r + 1;
          end if;
        end if;
      end if;
      step_r := step;
    end if;
  end process;

  -- track 0 indicator
  tr00_n <= '0' when track_r = 0 else '1';
	-- each track is encoded in 8KiB
  mem_a(19 downto 13) <= track_r(6 downto 0);
  
  BLK_READ : block
  begin
  
    -- we'll start with 4us per bit, 6272 bytes/track = 200ms per track
    PROC_RD: process (clk, clk_1M_ena, reset)
      variable count : std_logic_vector(17 downto 0) := (others => '0');
      alias phase : std_logic_vector(1 downto 0) is count(1 downto 0);
      alias bbit  : std_logic_vector(2 downto 0) is count(4 downto 2);
      alias byte  : std_logic_vector(12 downto 0) is count (17 downto 5);
      variable read_data_r : std_logic_vector(7 downto 0) := (others => '0');
    begin
      if reset = '1' then
        count := (others => '0');
				rclk <= '0';
				raw_read_n <= '1';
				ip_n <= '1';
      elsif rising_edge(clk) and clk_1M_ena = '1' then
        raw_read_n <= '1'; -- default
        -- memory address
        if phase = "00" and bbit = "000" then
          mem_a(12 downto 0) <= byte;
        end if;
        -- rclk
        if phase = "01" then
          rclk <= '1';
        elsif phase = "11" then
          rclk <= '0';
        end if;
        -- data latch (1us memory assumed)
        if phase = "01" and bbit = "000" then
          read_data_r := mem_d_i;
        end if;
        if phase = "10" then
          raw_read_n <= not read_data_r(read_data_r'left);
          read_data_r := read_data_r(read_data_r'left-1 downto 0) & '0';
        end if;
        -- generate index pulse (min 10us)
        ip_n <= '1'; -- default
        if count < 16 then
          ip_n <= '0';
        end if;
        if count = 6272*8*4-1 then
          count := (others => '0');
        else
          count := count + 1;
        end if;
      end if;
    end process PROC_RD;
  
  end block BLK_READ;

  -- output the track to debug
  debug(15 downto 8) <= track_r;
  debug(7 downto 0) <= (others => '0');
  
end architecture FLASH;
