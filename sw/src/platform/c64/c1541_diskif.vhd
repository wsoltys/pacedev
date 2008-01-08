library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.platform_pkg.all;
use work.project_pkg.all;

--
-- Model 1541B
--

entity c1541_diskif is
	port
	(
		clk   					: in std_logic;
    clk_en_32M      : in std_logic;                       -- Clock enable every 32MHz
		reset						: in std_logic;

    -- generic drive mechanism i/o ports
		-- "00..00" & wps_n & in_d(7 downto 0)
    mech_in					: in std_logic_vector(63 downto 0);
		-- "00..00" & read & addr(19 downto 0)
    mech_out				: out std_logic_vector(63 downto 0);
		-- shifter(9 downt 0) & track_offset(13 downto 0) & track(7 downo 0)
    mech_io					: inout std_logic_vector(63 downto 0);

		-- drive-side interface
		di							: out std_logic_vector(7 downto 0);		-- disk read data
		do							: in std_logic_vector(7 downto 0);		-- disk write data
		mode						: in std_logic;											  -- read(1)/write(0)
		stp							: in std_logic_vector(1 downto 0);		-- stepper motor control
		mtr							: in std_logic;											  -- spin motor on/off
		freq						: in std_logic_vector(1 downto 0);		-- motor frequency
		sync_n					: out std_logic;											-- reading SYNC bytes
		byte_n					: out std_logic;											-- byte ready
		wps_n						: out std_logic;											-- write-protect sense
		tr00_sense_n		: out std_logic 											-- track 0 sense (unused?)
	);
end c1541_diskif;

architecture SYN of c1541_diskif is
	-- Simulation delay time
	constant tdelay_sim : time := 1 ns;

	-- Maximum value of bit timer count variable
	constant bit_timer_limit : integer := 16;
	
	type step_type is (step_up, step_down, step_idle);
	
	impure function max_sectsize return integer is
		variable max : integer := 0;
	begin
		for i in sectsize_arr'range loop
			if sectsize_arr(i) > max then max := sectsize_arr(i); end if;
		end loop;
		return max;
	end function;
	
	subtype tracksize_type is integer range 0 to max_sectsize;

	-- Calculate track size in bytes given a track number
	function track_size(ntrack : integer) return tracksize_type is
	begin
		if(ntrack <= 34) then			return sectsize_arr(3);		-- Zone 3
		elsif(ntrack <= 48) then	return sectsize_arr(2);		-- Zone 2
		elsif(ntrack <= 60) then	return sectsize_arr(1);		-- Zone 1
		else											return sectsize_arr(0);		-- Zone 0
		end if;
	end function;

  -- Generate track step signals
  function track_step(stp_now : std_logic_vector(1 downto 0);
											stp_prv : std_logic_vector(1 downto 0)) return step_type is
  begin
    -- Check increment
    if(		 (stp_prv = "00" and stp_now = "01")
        or (stp_prv = "01" and stp_now = "10")
        or (stp_prv = "10" and stp_now = "11")
        or (stp_prv = "11" and stp_now = "00")) then 
			return step_up;
    end if;

    -- Check decrement
    if(		 (stp_prv = "00" and stp_now = "11")
        or (stp_prv = "01" and stp_now = "00")
        or (stp_prv = "10" and stp_now = "01")
        or (stp_prv = "11" and stp_now = "10")) then 
			return step_down;
    end if;

		return step_idle;
  end function;

	-- Calculate 2MHz timer count value for bit timer
	function bit_timer_count(zonesel : std_logic_vector(1 downto 0)) return integer is
		variable val : integer;
	begin
	case zonesel is
		when "11"   => val := bit_timer_limit - 12;		-- Zone 3, 3.25us per bit
		when "10"   => val := bit_timer_limit - 13;		-- Zone 2, 3.50us per bit
		when "01"   => val := bit_timer_limit - 14;		-- Zone 1, 3.75us per bit 
		when others => val := bit_timer_limit - 15;		-- Zone 0, 4.00us per bit
		end case;
		assert(val >= 0) report "Calculated timer value is invalid!" severity failure;
		return val;
	end function;
	
  signal in_a       : std_logic_vector(19 downto 0);  -- Disk image fetch address
  signal in_d       : std_logic_vector(7 downto 0);   -- Disk image fetch data
  signal out_d      : std_logic_vector(7 downto 0);   -- Disk image store data
  signal in_rd      : std_logic;                      -- Fetch disk image data
  signal track      : track_type;											-- Current disk track
  signal stp_o      : std_logic_vector(stp'range);    -- Step previous value
	signal tr00_sense_en	: std_logic;									-- Enable track 0 sense 

	signal dbg_track	: std_logic_vector(7 downto 0);
	signal dbg_offs		: std_logic_vector(13 downto 0);
	signal dbg_shifter: std_logic_vector(9 downto 0);
  signal dbg_bit_timer  : integer range 0 to bit_timer_limit;
  signal dbg_bit_count  : integer range 0 to 8;
	signal dbg_16M		: std_logic;
	signal dbg_4M			: std_logic;
	signal dbg_synchole		: std_logic;									-- Generate sync hole timing for debug
begin

	dbg_track <= std_logic_vector(to_unsigned(track, dbg_track'length));

	-- Connect I/O
  in_d <= mech_in(7 downto 0) after tdelay_sim;
	wps_n <= mech_in(8) after tdelay_sim;
	--tr00_sense_en <= mech_in(9) after tdelay_sim;
  mech_out(in_a'range) <= in_a after tdelay_sim;
  mech_out(in_a'high+1) <= in_rd after tdelay_sim;
	mech_out(in_a'high+2) <= dbg_synchole after tdelay_sim;
	mech_out(in_a'high+3) <= mtr after tdelay_sim;
	mech_out(31 downto 24) <= out_d after tdelay_sim;
  mech_io <= X"00000000" & dbg_shifter & dbg_offs & dbg_track after tdelay_sim;

	-- No write protect for now
  --wps_n <= '1';

	-- Track 0 sense is disconnected in real drive
  --tr00_sense_n <= '0';
	tr00_sense_en <= '1' after tdelay_sim;

  -- Always read from disk image ram
  --in_rd <= '1';

  -- Disk control synchronous logic
  disk_control : process(clk, clk_en_32M, reset)
		variable clk_div			: std_logic_vector(4 downto 0);	-- Divide clock down
		variable clk_div_r		: std_logic_vector(4 downto 0);	-- Previous divisor count value
    variable clk_en_16M		: std_logic;
		variable clk_en_4M		: std_logic;
    variable bit_timer  	: integer range 0 to bit_timer_limit;	-- Data bit timing
    variable clock_bit  	: boolean;        							-- Advance to next bit
    variable bit_count  	: integer range 0 to 8;  				-- Count bits for clock_byte
    variable clock_byte 	: boolean;        							-- Read/write data and advance to next byte
    variable clock_byte_r : boolean;      								-- Previous clock_byte
    variable start      	: integer range 0 to disk_image_limit; -- Track start address (in disk image ram)
    variable offs       	: tracksize_type;								-- Track offset
		variable sync					: std_logic;										-- Data sync signal
		variable in_rd_r			: std_logic;										-- Read/write_n to disk image ram
    variable byterdy_r    : std_logic;                    -- Byte ready signal
    variable byterdy_cnt  : integer;                      -- Byte ready width counter
    constant byterdy_cnt_load : integer := 16;             -- Counter load value

		variable track_size_now_r : tracksize_type;						-- Size of current track
		variable track_size_prv_r : tracksize_type;						-- Size of previous track

    variable data_in    	: std_logic_vector(7 downto 0);	-- Data in from disk image ram
    variable data_out   	: std_logic_vector(7 downto 0);	-- Data out from c64
    variable shifter    	: std_logic_vector(9 downto 0);	-- Simulate drive data shifter
  begin
		-- Debug
		dbg_offs <= std_logic_vector(to_unsigned(offs, dbg_offs'length)) after tdelay_sim;
		dbg_shifter <= shifter after tdelay_sim;
		dbg_bit_timer <= bit_timer after tdelay_sim;
		dbg_bit_count <= bit_count after tdelay_sim;
		dbg_16M <= clk_en_16M after tdelay_sim;
		dbg_4M <= clk_en_4M after tdelay_sim;
		mech_out(in_a'high+4) <= not sync after tdelay_sim;
		
		sync_n <= not sync after tdelay_sim;
    byte_n <= not byterdy_r after tdelay_sim;
		in_rd <= in_rd_r after tdelay_sim;
		
		-- Clock bit time expired
    clock_bit := false;
    if bit_timer = bit_timer_limit then
      clock_bit := true;
    end if;

		-- Clock byte bit count reached
    clock_byte := false;
    if bit_count = 8 then
      clock_byte := true;
    end if;

		-- Reset values
    if reset = '1' then
			clk_div := (others => '0');
      bit_timer := 0;
      bit_count := 1;
			clock_byte_r := false;
			track <= 0;
      start := 0;
      offs := 0;
	    sync := '0';
			in_rd_r := '0';
      byterdy_r := '0';
      byterdy_cnt := byterdy_cnt_load;
      in_a <= (others => '0');
			stp_o <= (others => '0');
			di <= (others => '0');
			tr00_sense_n <= '0';
			track_size_now_r := track_size(track);
			track_size_prv_r := track_size(track);
			data_in := (others => '0');
			data_out := (others => '0');
			shifter := (others => '0');

		-- Synchronous logic (32MHz clock)
    elsif clk_en_32M = '1' and rising_edge(clk) then
      in_a <= std_logic_vector(to_unsigned(start + offs, in_a'length)) after tdelay_sim;
	    byterdy_r := '0';
	    sync := '0';
			track_size_now_r := track_size(track);
			track_size_prv_r := track_size(track-1);
			dbg_synchole <= '0';

			-- Track 0 detection
			if track = 0 and tr00_sense_en = '1' then tr00_sense_n <= '1'; else tr00_sense_n <= '0'; end if;
			
			-- Generate sync
      if mode = '1' and shifter = "1111111111" then
        sync := '1';
      end if;

      -- Handle byte ready width counter
      if byterdy_r = '1' then
        if byterdy_cnt < 64 then
          byterdy_cnt := byterdy_cnt + 1;
        else
          byterdy_r := '0';
        end if;
      else
        byterdy_cnt := byterdy_cnt_load;
      end if;

      -- Assert byte ready
      if clock_byte and sync = '0' then
        byterdy_r := '1';
      end if;

      -- 2MHz timers
      if clk_en_4M = '1' then
				-- Clock data bits
        if clock_bit then
          if mode = '1' then
						shifter := shifter(8 downto 0) & data_in(7);
					else
						shifter := shifter(8 downto 0) & data_out(7);
					end if;
          data_in := data_in(6 downto 0) & '0';
          data_out := data_out(6 downto 0) & '0';

          -- Bit count (up to carry)
          if bit_count < 8 then
            bit_count := bit_count + 1;
          else
            bit_count := 1;
          end if;
        end if;

        -- Bit timer (count up to carry)
        -- Only count while motor is on
        if mtr = '1' and bit_timer < bit_timer_limit then 
					bit_timer := bit_timer + 1; 
        else 
					bit_timer := bit_timer_count(freq);
        end if;
      end if;

      -- Clock data byte in
      if clock_byte and not clock_byte_r then
        di <= shifter(7 downto 0) after tdelay_sim;
				out_d <= shifter(7 downto 0) after tdelay_sim;
        data_in := in_d;
        if offs < track_size_now_r then
          offs := offs + 1;
        else
          offs := 0;
					dbg_synchole <= '1';		-- Sync hole always occurs at track offset 0 for us
        end if;
      end if;

			-- Store data byte out
			if clock_byte_r and not clock_byte then
				data_out := do;
			end if;
			
      -- Handle track step - note stp is badly named on 1541 schematic hence the bit reversal
      case track_step(stp(0) & stp(1), stp_o(0) & stp_o(1)) is
			when step_up =>
		    if track < num_tracks then
					track <= track + 1;
					-- Adjust disk image offset forward to next track
    	    start := start + track_size_now_r;
				end if;
  	    stp_o <= stp after tdelay_sim;
			when step_down =>
		    if track > 0 then
					track <= track - 1;
					-- Adjust disk image offset back to previous track
	        start := start - track_size_prv_r;
				end if;
	      stp_o <= stp after tdelay_sim;
			when others =>
      end case;

			-- Generate disk image memory read/write_n
			if byterdy_r = '1' and mode = '0' then in_rd_r := '0'; else in_rd_r := '1'; end if;

			-- Divided clock enables
			clk_en_16M := '0';
			if clk_div(0) = '1' and clk_div_r(0) = '0' then clk_en_16M := '1'; end if;
			clk_en_4M := '0';
			if clk_div(2) = '1' and clk_div_r(2) = '0' then clk_en_4M := '1'; end if;

      -- Generate clock divider
			clk_div_r := clk_div;
			clk_div := clk_div + std_logic_vector(to_unsigned(1, clk_div'length));

			-- Save clock_byte
			clock_byte_r := clock_byte;
    end if;
  end process;

end SYN;
