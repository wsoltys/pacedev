library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity uPD4990A is
  generic
  (
    CLK_32K768_COUNT  : natural
  );
  port
  (
    clk_i             : in std_logic;
    clk_ena           : in std_logic;
    reset             : in std_logic;
    
    data_in           : in std_logic;
    clk               : in std_logic;
    c                 : in std_logic_vector(2 downto 0);
    stb               : in std_logic;
    cs                : in std_logic;
    out_enabl         : in std_logic;
    
    data_out          : out std_logic;
    tp                : out std_logic
  );
end entity uPD4990A;

architecture SYN of uPD4990A is

  signal counter_r  : std_logic_vector(51 downto 0) := X"009C731235958";
  alias cmd         : std_logic_vector(3 downto 0) is counter_r(51 downto 48);
  alias year_tens   : std_logic_vector(3 downto 0) is counter_r(47 downto 44);
  alias year_units  : std_logic_vector(3 downto 0) is counter_r(43 downto 40);
  alias month       : std_logic_vector(3 downto 0) is counter_r(39 downto 36);
  alias dow         : std_logic_vector(3 downto 0) is counter_r(35 downto 32);
  alias day_tens    : std_logic_vector(3 downto 0) is counter_r(31 downto 28);
  alias day_units   : std_logic_vector(3 downto 0) is counter_r(27 downto 24);
  alias hr_tens     : std_logic_vector(3 downto 0) is counter_r(23 downto 20);
  alias hr_units    : std_logic_vector(3 downto 0) is counter_r(19 downto 16);
  alias min_tens    : std_logic_vector(3 downto 0) is counter_r(15 downto 12);
  alias min_units   : std_logic_vector(3 downto 0) is counter_r(11 downto 8);
  alias sec_tens    : std_logic_vector(3 downto 0) is counter_r(7 downto 4);
  alias sec_units   : std_logic_vector(3 downto 0) is counter_r(3 downto 0);

  signal din_r    	: std_logic_vector(51 downto 0) := (others => '0');
  signal dout_r    	: std_logic_vector(51 downto 0) := (others => '0');
  signal time_r    	: std_logic_vector(51 downto 0) := (others => '0');

  signal tp_mode    : std_logic_vector(3 downto 0) := (others => '0');
  
	signal enable_interval        : std_logic := '0';
	signal pulse_resetoutput      : std_logic := '0';
	signal pulse_restartinterval  : std_logic := '0';
  signal pulse_1s   		        : std_logic := '0';
 	signal pulse_1d				        : std_logic := '0';
	signal pulse_timeset	        : std_logic := '0';
	signal pulse_timerd		        : std_logic := '0';

begin

  BLK_TP : block
  
    subtype count_t is integer range 0 to CLK_32K768_COUNT-1;

    signal clk_4096         : std_logic := '0';
    signal clk_2048         : std_logic := '0';
    signal clk_256          : std_logic := '0';
    signal clk_64           : std_logic := '0';
    signal clk_1s           : std_logic := '0';

    signal interval_state   : std_logic := '0';
  
  begin
  
    PROC_TP : process (clk_i, reset)
      variable count      : count_t;
      variable tp_count   : std_logic_vector(14 downto 0) := (others => '0');
    begin
      if reset = '1' then
        count := 0;
        tp_count  := (others => '0');
      elsif rising_edge (clk_i) and clk_ena = '1' then
        pulse_1s <= '0';    -- default
        if count = count_t'high then
          tp_count := tp_count + 1;
          if tp_count = 0 then
            pulse_1s <= '1';
          elsif tp_count = 1 then
            -- latch the current time
            -- after allowing enough time for ripple counters
            time_r <= counter_r;
          end if;
          count := 0;
        else
          count := count + 1;
        end if;
        -- timing pulses
        clk_4096 <= tp_count(2);
        clk_2048 <= tp_count(3);
        clk_256 <= tp_count(6);
        clk_64 <= tp_count(8);
        clk_1s <= tp_count(14);
      end if;
    end process PROC_TP;

    PROC_INTERVAL : process (clk_i, reset)
      -- sub 1s variables
      variable count          : count_t;
      variable s_count        : std_logic_vector(14 downto 0) := (others => '0');
      -- interval variables
      subtype half_cnt_t is integer range 0 to 64;
      type half_cnt_a is array (natural range <>) of half_cnt_t;
      constant half_cnt_limit : half_cnt_a(0 to 3) := (0, 9, 29, 59);
      variable half_cnt       : half_cnt_t;
      variable half_state     : std_logic := '0';
    begin
      if reset = '1' then
        count := 0;
        s_count := (others => '0');
        half_state := '0';
      elsif rising_edge(clk_i) and clk_ena = '1' then

        -- resets output state until next cycle
        if pulse_resetoutput = '1' then
          interval_state <= '1';
        end if;

        -- 1s counter
        if enable_interval = '1' then
          if pulse_restartinterval = '1' then
            count := 0;
            s_count := (others => '0');
            half_cnt := 0;
            half_state := '0';  -- start low
          else
            if count = count_t'high then
              count := 0;
              s_count := s_count + 1;
            else
              count := count + 1;
            end if;
          end if;

          -- 50% duty cycle
          if s_count(s_count'left) = '1' then
            s_count := (others => '0');
            if half_cnt = half_cnt_limit(to_integer(unsigned(tp_mode(1 downto 0)))) then
              half_state := not half_state;
              interval_state <= half_state;
              half_cnt := 0;
            else
              half_cnt := half_cnt + 1;
            end if;
          end if;
        end if; -- enable interval
      end if;
    end process PROC_INTERVAL;

    -- drive TP output
    tp <= clk_64 when tp_mode = "0100" else
          clk_256 when tp_mode = "0101" else
          clk_2048 when tp_mode = "0110" else
          clk_4096 when tp_mode = "0111" else
          interval_state;

  end block BLK_TP;
  
  -- rtc (clock/calendar)
  PROC_TIME : process (clk_i, reset)
  begin
    if reset = '1' then
      -- 9:54:28am
      counter_r(23 downto 0) <= X"095428";
    elsif rising_edge(clk_i) and clk_ena = '1' then
			pulse_1d <= '0'; -- default
			if pulse_timeset = '1' then
				-- set the time from the input data
				counter_r(23 downto 0) <= din_r(23 downto 0);
      elsif pulse_1s = '1' then
        if sec_units = 9 then
          sec_units <= (others => '0');
          if sec_tens = 5 then
            sec_tens <= (others => '0');
            if min_units = 9 then
              min_units <= (others => '0');
              if min_tens = 5 then
                min_tens <= (others => '0');
                if hr_units = 9 then
                  hr_units <= (others => '0');
                  hr_tens <= hr_tens + 1;
                elsif hr_units = 3 and hr_tens = 2 then
                  hr_tens <= (others => '0');
                  hr_units <= (others => '0');
									pulse_1d <= '1';
                else
                  hr_units <= hr_units + 1;
                end if;
              else
                min_tens <= min_tens + 1;
              end if;
            else
              min_units <= min_units + 1;
            end if;
          else
            sec_tens <= sec_tens + 1;
          end if;
        else
          sec_units <= sec_units + 1;
        end if;
      end if;
    end if;
  end process PROC_TIME;

	PROC_DATE : process (clk_i, reset)
    type dim_t is array (natural range <>) of std_logic_vector(7 downto 0);
    constant dim : dim_t(1 to 12) :=
      ( X"31", X"28", X"31", X"30", X"31", X"30", X"31", X"31", X"30", X"31", X"30", X"31" );
		variable m : integer range 1 to 12;
	begin
		m := to_integer(unsigned(month));
		if reset = '1' then
      -- Tue 9th December 2008
      counter_r(47 downto 24) <= X"08C309";
		elsif rising_edge(clk_i) and clk_ena = '1' then
			if pulse_timeset = '1' then
				-- set the date from the data input
				counter_r(47 downto 24) <= din_r(47 downto 24);
			elsif pulse_1d = '1' then
				-- TBD add support for leap years
				if day_tens = dim(m)(7 downto 4) and day_units = dim(m)(3 downto 0) then
					day_tens <= (others => '0');
					day_units <= X"1";
					if month = 12 then
						month <= X"1";
						if year_units = 9 then
							year_units <= (others => '0');
							year_tens <= year_tens + 1;
						else
							year_units <= year_units + 1;
						end if;
					else
						month <= month + 1;
					end if;
				elsif day_units = 9 then
					day_units <= (others => '0');
				else
					day_units <= day_units + 1;
				end if;
				if dow = 7 then
					dow <= X"1";
				else
					dow <= dow + 1;
				end if;
			end if;
		end if;
	end process PROC_DATE;
  
	PROC_SER : process (clk_i, reset)
		variable clk_r	: std_logic := '0';
	begin
		if reset = '1' then
			clk_r := '0';
		elsif rising_edge(clk_i) and clk_ena = '1' then
			if pulse_timerd = '1' then
				-- set the output time from the current time
				dout_r(47 downto 0) <= time_r(47 downto 0);
			end if;
			if cs = '1' then
				if clk = '1' and clk_r = '0' then
					-- clock data on rising edge
					din_r <= data_in & din_r(din_r'left downto 1);
					-- shift register
					dout_r <= '0' & dout_r(dout_r'left downto 1);
				end if;
				-- store last clock state when cs=1
        clk_r := clk;
			end if;
		end if;
	end process PROC_SER;

	-- don't really need an output enable...
	data_out <= dout_r(0) when out_enabl = '1' else '0';

	PROC_CMD : process (clk_i, reset)
		variable stb_r : std_logic := '0';
	begin
		if reset = '1' then
			stb_r := '0';
		elsif rising_edge(clk_i) and clk_ena = '1' then
			pulse_timeset <= '0';         -- default
			pulse_timerd <= '0';          -- default
			pulse_restartinterval <= '0'; -- default
			pulse_resetoutput <= '0';     -- default
			if cs = '1' then
        if stb_r = '0' and stb = '1' then
          -- latch tp_mode on leading edge STB
          case din_r(din_r'left downto din_r'left-3) is
            when "0000" =>		-- register hold mode
            when "0001" =>		-- register shift mode
            when "0010" =>		-- time set and counter hold mode
              pulse_timeset <= '1';
            when "0011" =>		-- time read mode
              pulse_timerd <= '1';
            when "0100" | "0101" | "0110" | "0111" =>
              -- 64Hz/256Hz/2048Hz/4096Hz handled elsewhere
              tp_mode <= din_r(51 downto 48);
            when "1000" | "1001" | "1010" | "1011" =>
              -- 1s/10s/30s/60s
              tp_mode <= din_r(51 downto 48);
              enable_interval <= '1';
              pulse_restartinterval <= '1';
            when "1100" =>    -- interval output flag reset 
              pulse_resetoutput <= '1';
            when "1101" =>    -- interval timer clock run
              enable_interval <= '1';
              pulse_restartinterval <= '1';
            when "1110" =>    -- interval timer clock stop
              enable_interval <= '0';
            when others =>
              null;
          end case;
        end if;
        -- latch previous stb if cs=1
        stb_r := stb;
      end if;
		end if;
	end process;

end architecture SYN;
