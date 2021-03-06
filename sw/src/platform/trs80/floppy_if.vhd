library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity floppy_if is
  generic
  (
    NUM_TRACKS      : integer := 35
  );
  port
  (
    clk           : in std_logic;
    clk_20M_ena   : in std_logic;
    reset         : in std_logic;
    
    drv_ena       : in std_logic_vector(4 downto 1);
    drv_sel       : in std_logic_vector(4 downto 1);
    
    step          : in std_logic;
    dirc          : in std_logic;
    rg            : in std_logic;
    rclk          : out std_logic;
    raw_read_n    : out std_logic;
    wg            : in std_logic;
    wd            : in std_logic;
    tr00_n        : out std_logic;
    ip_n          : out std_logic;

    -- media interface

    track         : out std_logic_vector(7 downto 0);
    dat_i         : in std_logic_vector(7 downto 0);
    dat_o         : out std_logic_vector(7 downto 0);
    wr            : out std_logic;
    -- random-access control
    offset        : out std_logic_vector(12 downto 0);
    -- fifo control
    rd            : out std_logic;
    flush         : out std_logic;
    
    debug         : out std_logic_vector(31 downto 0)
  );
end entity floppy_if;

architecture SYN of floppy_if is

  signal clk_1M_ena   : std_logic := '0';

	type track_a is array (natural range <>) of std_logic_vector(7 downto 0);
  signal track_r      : track_a(4 downto 0);
  signal offset_s     : std_logic_vector(offset'range);
  
  signal ena          : std_logic := '0';
	signal drv					: integer range 0 to 4 := 0;

begin

	ena <= 	drv_ena(1) when drv_sel(1) = '1' else
					drv_ena(2) when drv_sel(2) = '1' else
					drv_ena(3) when drv_sel(3) = '1' else
					drv_ena(4) when drv_sel(4) = '1' else
					'0';
					
	drv <= 	1 when drv_sel(1) = '1' else
					2 when drv_sel(2) = '1' else
					3 when drv_sel(3) = '1' else
					4 when drv_sel(4) = '1' else
					0;

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
      track_r <= (others => (others => '0'));
    elsif rising_edge(clk) and clk_20M_ena = '1' then
      flush <= '0';
      if ena = '1' then
        -- leading edge of step
        if step_r = '0' and step = '1' then
          if dirc = '0' then
            -- step out (decrement track)
            if track_r(drv) /= 0 then
              track_r(drv) <= track_r(drv) - 1;
            end if;
          else
            -- step in (increment track)
            if track_r(drv) < NUM_TRACKS-1 then
              track_r(drv) <= track_r(drv) + 1;
            end if;
          end if;
          flush <= '1'; -- flush FIFO
        end if;
      end if;
      step_r := step;
    end if;
  end process;

  -- track 0 indicator 
  -- - works even when not "enabled" (no floppy)
  tr00_n <= '0' when track_r(drv) = 0 else '1';

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
				rd <= '0';
				raw_read_n <= '1';
				ip_n <= '1';
      elsif rising_edge(clk) and clk_1M_ena = '1' then
        rd <= '0';          -- default
        raw_read_n <= '1';  -- default
        -- memory address
        if phase = "00" and bbit = "000" then
          offset_s <= byte;
        end if;
        -- rclk
        if phase = "01" then
          rclk <= '1';
        elsif phase = "11" then
          rclk <= '0';
        end if;
        -- data latch (1us memory assumed)
        if phase = "01" and bbit = "000" then
          read_data_r := dat_i;
          rd <= '1';
        end if;
        if phase = "10" then
          -- handle reads (from the media)
          raw_read_n <= ena and not read_data_r(read_data_r'left);
          read_data_r := read_data_r(read_data_r'left-1 downto 0) & '0';
          --raw_read_n <= ena and not read_data_r(read_data_r'right);
          --read_data_r := '0' & read_data_r(read_data_r'left downto 1);
        end if;
        -- generate index pulse (min 10us)
        ip_n <= '1'; -- default
        if count < 1000 then
          -- no index pulse if no floppy
          ip_n <= not ena;
        end if;
        if count = 6272*8*4-1 then
          count := (others => '0');
        else
          count := count + 1;
        end if;
      end if;
    end process PROC_RD;
  
  end block BLK_READ;

  BLK_WRITE : block

    signal raw_data_rdy   : std_logic := '0';
    signal write_data_r   : std_logic_vector(7 downto 0) := (others => '0');

    -- fudge
    alias wclk            : std_logic is wd;

  begin

		-- reads raw data from drive continuously
		-- note that there is no bit/byte synchronisation atm
		-- so drive emulation must be 'in sync'
		PROC_RAW_WRITE: process (clk, clk_20M_ena, reset)
			variable wclk_r : std_logic := '0';
			variable count 	: std_logic_vector(2 downto 0) := (others => '0');
			variable data_v	: std_logic_vector(7 downto 0) := (others => '0');
		begin
			if reset = '1' then
				wr <= '0';
				wclk_r := '0';
				count := (others => '0');
				data_v := (others => '0');
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				raw_data_rdy <= '0'; 	-- default
				wr <= '0';						-- default
				-- leading edge WCLK
				if wclk_r = '0' and wclk = '1' then
					data_v := data_v(data_v'left-1 downto 0) & '0';
				-- trailing edge rclk
				elsif wclk_r = '1' and wclk = '0' then
					if count = "111" then
						-- finished a byte
						write_data_r <= data_v;
						raw_data_rdy <= '1';
						wr <= wg;
					end if;
					count := count + 1;
				end if;
				-- sample RAW_DATA_n during WCLK high
				if wclk = '1' then
					if wd = '0' then
						data_v(0) := '1';
					end if;
				end if;
				wclk_r := wclk;
			end if;
		end process PROC_RAW_WRITE;

  end block BLK_WRITE;

  -- assign outputs
  track <= track_r(drv);
  offset <= offset_s;

  -- output the track to debug
  debug(31 downto 16) <= std_logic_vector(RESIZE(unsigned(offset_s), 16));
  debug(15 downto 8) <= track_r(drv);
  debug(7 downto 0) <= dat_i;

  -- not used
  dat_o <= (others => '0');
  
end architecture SYN;
