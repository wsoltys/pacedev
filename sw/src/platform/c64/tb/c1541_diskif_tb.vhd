library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.platform_pkg.all;
use work.project_pkg.all;

use std.textio.all;
use IEEE.std_logic_textio.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity c1541_diskif_tb is
end c1541_diskif_tb;

architecture SIM of c1541_diskif_tb is

	constant  verbose : boolean := true;	-- Debug messages

	constant	tCYC	:	time := 10416 ps;   -- 96MHz clock

	signal	clk		        :	std_logic;
  signal  clk_en_32M    : std_logic;
	signal	reset	        :	std_logic;

  -- generic drive mechanism i/o ports
  signal  mech_in				: std_logic_vector(63 downto 0);
  signal  mech_out			: std_logic_vector(63 downto 0);
  signal  mech_io				: std_logic_vector(63 downto 0);

	-- drive-side interface
	signal  di						: std_logic_vector(7 downto 0);		-- disk write data
	signal  do						: std_logic_vector(7 downto 0);		-- disk read data
	signal  mode					: std_logic;											-- read/write
	signal  stp						: std_logic_vector(1 downto 0);		-- stepper motor control
	signal  mtr						: std_logic;											-- stepper motor on/off
	signal  freq					: std_logic_vector(1 downto 0);		-- motor frequency
	signal  sync_n				: std_logic;											-- reading SYNC bytes
	signal  byte_n				: std_logic;											-- byte ready
	signal  wps_n					: std_logic;											-- write-protect sense
	signal  tr00_sense_n	: std_logic;											-- track 0 sense (unused?)

  -- Internal disk image signals
  signal in_a       : std_logic_vector(19 downto 0);  -- Disk image fetch address
  signal in_d       : std_logic_vector(7 downto 0);   -- Disk image fetch data
  signal in_rd      : std_logic;                      -- Fetch disk image data

  signal rom_d      : std_logic_vector(7 downto 0);   -- Disk image fetch data
  signal sel_rom    : std_logic;                      -- Select rom data

	signal ttest			: time;
	
	-- Disk interface internal signals
	signal diskif_track			: track_type;
	
begin

  in_a <= mech_out(19 downto 0);
  in_rd <= mech_out(20);
	mech_in(mech_in'high downto in_d'high+1) <= (others => '0');
  mech_in(in_d'range) <= in_d;
	do <= (others => '0');
	
	-- DUT
	diskif : entity work.c1541_diskif
		port map( clk => clk, clk_en_32M => clk_en_32M, reset => reset, 
							mech_in				=> mech_in, 
							mech_out			=> mech_out, 
							mech_io				=> mech_io, 
            	di      			=> di,
            	do		  			=> do,
            	mode	  			=> mode,
            	stp		  			=> stp,
            	mtr						=> mtr,
            	freq					=> freq,
            	sync_n				=> sync_n,
            	byte_n				=> byte_n,
            	wps_n					=> wps_n,
            	tr00_sense_n	=> tr00_sense_n
				  );

	-- Use signal spy to examine internal signals
	signals : process
		variable verbose_int : integer := 0;
	begin
		if verbose then verbose_int := 1; end if;
		init_signal_spy("/c1541_diskif_tb/diskif/track", "/c1541_diskif_tb/diskif_track", verbose_int, 1);
		wait;
	end process signals;

	-- Generate main clock
	clock_gen : process (clk)
	begin
		if clk = '0' then
			clk <= '1' after tCYC/2;
		else
			clk <= '0' after tCYC/2;
		end if;
	end process clock_gen;

	-- Generate 32MHz clock enable
  clock_divisor : process
  begin
    clk_en_32M <= '0';
		wait until rising_edge(clk);
    clk_en_32M <= '0';
		wait until rising_edge(clk);
    clk_en_32M <= '1';
		wait until rising_edge(clk);
  end process;

	-- Test data rom and pattern generator
	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> PLATFORM_SRC_DIR & "/roms/c1541_diskif_tb.hex",
			numwords_a	=> 262144,
			widthad_a		=> 18
		)
		port map
		(
			clock			=> clk,
			address		=> in_a(17 downto 0),
			q					=> rom_d
		);
  rom_mux : process(rom_d, in_a, sel_rom)
	  variable pattern_d  : std_logic_vector(7 downto 0);   -- Disk image test pattern 
  begin
    pattern_d := in_a(7 downto 0);
    if sel_rom = '1' then
      in_d <= rom_d after 100 ns;
    else
      in_d <= pattern_d after 10 ns;
    end if;
  end process rom_mux; 

	-- Main test bench routine
	tb : process
		variable buf		: line;
		variable tstart	: time;
		variable tend		: time;
		variable tdiff	: time;
	begin
		reset <= '1';
    mode <= '1';
	  stp <= "00";
    mtr <= '0';
	  freq <= "11";
    sel_rom <= '0';

		wait for 1 us;		reset <= '0';
		wait for 1 us;		mtr <= '1';
		
		--
		-- Drive mechanics tests
		--
		
		-- Check we can step up and down through all stepper states
		if(verbose) then
			write(buf, now); write(buf, string'(": INFO Starting basic seek step test")); writeline(output, buf); 
		end if;
		wait for 1 us;		
		stp <= "01";		wait for 1 us;
		assert(diskif_track = 2) report "Incorrect track (should be 2)" severity failure;
		stp <= "10";		wait for 1 us;		
		assert(diskif_track = 3) report "Incorrect track (should be 3)" severity failure;
		stp <= "11";		wait for 1 us;		
		assert(diskif_track = 4) report "Incorrect track (should be 4)" severity failure;
		stp <= "00";		wait for 1 us;		
		assert(diskif_track = 5) report "Incorrect track (should be 5)" severity failure;
		stp <= "11";		wait for 1 us;		
		assert(diskif_track = 4) report "Incorrect track (should be 4)" severity failure;
		stp <= "10";		wait for 1 us;		
		assert(diskif_track = 3) report "Incorrect track (should be 3)" severity failure;
		stp <= "01";		wait for 1 us;		
		assert(diskif_track = 2) report "Incorrect track (should be 2)" severity failure;
		stp <= "00";		wait for 1 us;		
		assert(diskif_track = 1) report "Incorrect track (should be 1)" severity failure;
		stp <= "11";		wait for 1 us;		
		assert(diskif_track = 1) report "Incorrect track (should be 1)" severity failure;
		
		-- Step to track 84
		if(verbose) then
			write(buf, now); write(buf, string'(": INFO Starting invalid seek step test")); writeline(output, buf);
		end if;
		for i in 0 to 19 loop
			stp <= "00";	wait for 1 us;		
			stp <= "01";	wait for 1 us;		
			stp <= "10";	wait for 1 us;		
			stp <= "11";	wait for 1 us;		
		end loop;
		stp <= "00";	wait for 1 us;		
		stp <= "01";	wait for 1 us;		
		stp <= "10";	wait for 1 us;		
		assert(diskif_track = 84) report "Incorrect track (should be 84)" severity failure;			
		stp <= "11";	wait for 1 us;		
		assert(diskif_track = 84) report "Incorrect track (should be 84)" severity failure;
		
		-- Back to 80
		stp <= "10";	wait for 1 us;		
		stp <= "01";	wait for 1 us;		
		stp <= "00";	wait for 1 us;		
		stp <= "11";	wait for 1 us;		
		assert(diskif_track = 80) report "Incorrect track (should be 80)" severity failure;
		stp <= "00";		wait for 1 us;
		assert(diskif_track = 81) report "Incorrect track (should be 81)" severity failure;
		stp <= "01";		wait for 1 us;		
		assert(diskif_track = 82) report "Incorrect track (should be 82)" severity failure;
		stp <= "10";		wait for 1 us;		
		assert(diskif_track = 83) report "Incorrect track (should be 83)" severity failure;
		stp <= "11";		wait for 1 us;		
		assert(diskif_track = 84) report "Incorrect track (should be 84)" severity failure;

		-- Step back a bit and check that invalid steps do nothing
		stp <= "10";		wait for 1 us;		
		stp <= "01";		wait for 1 us;		
		stp <= "00";		wait for 1 us;		
		stp <= "11";		wait for 1 us;		
		assert(diskif_track = 80) report "Incorrect track (should be 80)" severity failure;
		stp <= "01";		wait for 1 us;		
		assert(diskif_track = 80) report "Incorrect track (should be 80)" severity failure;
		stp <= "00";		wait for 1 us;
		assert(diskif_track = 81) report "Incorrect track (should be 81)" severity failure;
		stp <= "10";		wait for 1 us;		
		assert(diskif_track = 81) report "Incorrect track (should be 81)" severity failure;
		stp <= "01";		wait for 1 us;		
		assert(diskif_track = 82) report "Incorrect track (should be 82)" severity failure;
		stp <= "11";		wait for 1 us;		
		assert(diskif_track = 82) report "Incorrect track (should be 82)" severity failure;

		-- Check changing data frequency works as expected (checked in check_byte_timer)
		freq <= "00";
		wait until byte_n = '1';
		wait until byte_n = '0';
		freq <= "01";
		wait until byte_n = '1';
		wait until byte_n = '0';
		freq <= "10";
		wait until byte_n = '1';
		wait until byte_n = '0';
		freq <= "11";
		wait until byte_n = '1';
		wait until byte_n = '0';
		
		--
		-- Disk data tests
		--
		reset <= '1';
    mode <= '1';
	  stp <= "00";
    mtr <= '1';
	  freq <= "11";
    sel_rom <= '1';
		wait for 1 us;

		if(verbose) then
			write(buf, now); write(buf, string'(": INFO Starting sync length test")); writeline(output, buf); 
		end if;
		reset <= '0';
		
		-- Check sync length
		wait until sync_n = '1';
		wait until sync_n = '0';
		tstart := now;
		wait until sync_n = '1';
		tend := now;
		tdiff := tend - tstart;
		if verbose and abs(tdiff - (5*8-10)*3.25 us) >= 10 us then
			write(buf, string'("Sync length was ")); write(buf, tdiff);
			writeline(output, buf);
		end if;
		-- Expect 5 bytes of sync
		assert(abs(tdiff - (5*8-10)*3.25 us) < 10 us) report "Bad sync length" severity failure;
		
		wait for 100 us;
		
		assert false report "SUCCESS: End of simulation" severity failure;
		
	end process tb;

	-- Check the time between byte ready is close to specified amount (in ns)
	-- Note there is some variance because we can't set freq immediately before a bit period
	check_byte_timer : process
		variable tstart	: time;
		variable tend		: time;
		variable tdiff	: time;
		variable texpect: time;
		variable buf 		: line;
	begin
		wait until byte_n = '1';
		wait until byte_n = '0';

		while true loop	
			tstart := now;		
			wait until byte_n = '1';
			wait for 2 ns;
			case freq is
			when "00" => texpect := 8*4 us;
			when "01" => texpect := 8*3.75 us;
			when "10" => texpect := 8*3.5 us;
			when "11" => texpect := 8*3.25 us;
			when others => assert false report "Bad freq value" severity failure;
			end case;
			wait until byte_n = '0';
			tend := now;
			tdiff := tend - tstart;
			if false then --verbose then
				write(buf, string'("Start time    = ")); write(buf, tstart); writeline(output, buf);
				write(buf, string'("End time      = ")); write(buf, tend); writeline(output, buf);
				write(buf, string'("Diff time     = ")); write(buf, tdiff); writeline(output, buf);
				write(buf, string'("Expected time = ")); write(buf, texpect); writeline(output, buf);
				write(buf, string'("Abs diff      = ")); write(buf, abs(texpect - tdiff)); writeline(output, buf);
			end if;
			ttest <= tstart;
			--assert(abs(tdiff - texpect) < 300 ns) report "Byte time mismatch" severity warning;
		end loop;
	end process check_byte_timer;

	-- Check the address value is changed correctly after track change
	check_track_offset : process
		-- Calculate track size in bytes given a track number
		function track_size(ntrack : integer) return integer is
		begin
		if(ntrack <= 34) then			return sectsize_arr(3);		-- Zone 3
		elsif(ntrack <= 48) then	return sectsize_arr(2);		-- Zone 2
		elsif(ntrack <= 60) then	return sectsize_arr(1);		-- Zone 1
		else											return sectsize_arr(0);		-- Zone 0
		end if;
		end function;

		-- Calculate the expected byte offset
		impure function byte_offs(track : track_type) return integer is
			variable offs		: integer := 0;
		begin
			for tr in 1 to track-1 loop offs := offs + track_size(tr); end loop;
			return offs;
		end function byte_offs;
		
		variable buf		: line;
		variable soffs	: integer;
		variable eoffs	: integer;
		variable addr		: integer;
--		variable offs		: integer;
	begin
--		offs := 0;
--		for tr in 1 to 84 loop
--			write(buf, string'("Track ")); write(buf, tr);
--			write(buf, string'(" = ")); write(buf, track_size(tr));
--			write(buf, string'(", cum ")); hwrite(buf, std_ulogic_vector(to_unsigned(offs, 32)));
--			writeline(output, buf);
--			offs := offs + track_size(tr);
--		end loop;
--		write(buf, string'("Image size = "));
--		write(buf, disk_image_limit);
--		writeline(output, buf);
		
		wait until diskif_track'event;
		wait until rising_edge(clk) and clk_en_32M = '1';
		wait until rising_edge(clk) and clk_en_32M = '1';
		addr := to_integer(unsigned(in_a));
		soffs := byte_offs(diskif_track);
		eoffs := soffs + track_size(diskif_track);
		if verbose and (addr < soffs or addr >= eoffs) then
			write(buf, now);
--			write(buf, string'(": Track ")); write(buf, diskif_track);
			write(buf, string'(": Address ")); 
			hwrite(buf, std_ulogic_vector(to_unsigned(addr, 32)));
			write(buf, string'(" is not between [")); 
			hwrite(buf, std_ulogic_vector(to_unsigned(soffs, 32)));
			write(buf, string'(", ")); 
			hwrite(buf, std_ulogic_vector(to_unsigned(eoffs, 32)));
			write(buf, string'(")"));
			writeline(output, buf);
		end if;
		--assert(addr >= soffs and addr < eoffs) report "Address is not within expected track address range" severity failure;
	end process check_track_offset;
	
end SIM;


