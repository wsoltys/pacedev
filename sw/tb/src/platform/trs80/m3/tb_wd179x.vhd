library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.pace_pkg.all;

entity tb_wd179x is
	port (
		fail:				out  boolean := false
	);
end tb_wd179x;

architecture SYN of tb_wd179x is

	constant A_CMD			: std_logic_vector(1 downto 0) := "00";
	constant A_STS			: std_logic_vector(1 downto 0) := A_CMD;
	constant A_TRK			: std_logic_vector(1 downto 0) := "01";
	constant A_SEC			: std_logic_vector(1 downto 0) := "10";
	constant A_DAT			: std_logic_vector(1 downto 0) := "11";

	signal clk					: std_logic	:= '0';
	signal reset				: std_logic	:= '1';
                  	
	signal clk_20M 			: std_logic := '0';

  signal fdc_we_n			: std_logic := '1';
  signal fdc_cs_n			: std_logic := '1';
  signal fdc_re_n			: std_logic := '1';
  signal fdc_a				: std_logic_vector(1 downto 0) := (others => '0');
  signal fdc_dat_i		: std_logic_vector(7 downto 0) := (others => '0');
  signal fdc_dat_o		: std_logic_vector(7 downto 0) := (others => '0');
  signal intrq        : std_logic := '0';
  signal drq          : std_logic := '0';

  signal ds           : std_logic_vector(4 downto 1) := (others => '0');
  signal step         : std_logic := '0';
  signal dirc         : std_logic := '0';
  signal rclk         : std_logic := '0';
  signal raw_read_n   : std_logic := '0';
  signal tr00_n       : std_logic := '0';
  signal ip_n         : std_logic := '0';

	signal mem_a				: std_logic_vector(19 downto 0) := (others => '1');
	signal mem_d				: std_logic_vector(7 downto 0);

	type MEM_t is array (natural range <>) of std_logic_vector(7 downto 0);
	constant mem : MEM_t(0 to 305) := 
	(
		X"FF", X"FF", X"FF", X"FF",
		X"FE",
		X"00", X"00", 	-- track=0
		X"00", X"01",		-- sector=0
		X"12", X"34",		-- CRC
		X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", 
		X"00", X"00", X"00", X"00", X"00", X"00", 
		X"FB",					-- DAM
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"56", X"78",
		X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", 
		X"00", X"00", X"00", X"00", X"00", X"00"
	);

begin

	-- Generate CLK and reset
  clk_20M <= not clk_20M after 25000 ps; -- 20MHz
	reset <= '0' after 10 ns;

	--mem_d <= mem(conv_integer(mem_a));

  wd179x_inst : entity work.wd179x
    port map
    (
      clk           => clk_20M,
      clk_20M_ena   => '1',
      reset         => reset,
      
      -- micro bus interface
      mr_n          => '1',
      we_n          => fdc_we_n,
      cs_n          => fdc_cs_n,
      re_n          => fdc_re_n,
      a             => fdc_a(1 downto 0),
      dal_i         => fdc_dat_i,
      dal_o         => fdc_dat_o,
      clk_1mhz_en   => '1',
      drq           => drq,
      intrq         => intrq,
      
      -- drive interface
      step          => step,
      dirc          => dirc,
      early         => open,    -- not used atm
      late          => open,    -- not used atm
      test_n        => '1',     -- not used
      hlt           => '1',     -- head always engaged atm
      rg            => open,
      sso           => open,
      rclk          => rclk,
      raw_read_n    => raw_read_n,
      hld           => open,    -- not used atm
      tg43          => open,    -- not used on TRS-80 designs
      wg            => open,
      wd            => open,    -- 200ns (MFM) or 500ns (FM) pulse
      ready         => '1',     -- always read atm
      wf_n_i        => '1',     -- no write faults atm
      vfoe_n_o      => open,    -- not used in TRS-80 designs?
      tr00_n        => tr00_n,
      ip_n          => ip_n,
      wprt_n        => '1',     -- never write-protected atm
      dden_n        => '1'      -- single density only atm
    );

	floppy_inst : entity work.floppy
	  port map
	  (
	    clk           => clk_20M,
	    clk_20M_ena   => '1',
	    reset         => reset,

      drvsel        => ds,
	    
	    step          => step,
	    dirc          => dirc,
	    rclk          => rclk,
	    raw_read_n    => raw_read_n,
	    tr00_n        => tr00_n,
	    ip_n          => ip_n,
	
	    -- memory interface
	    mem_a         => mem_a,
	    mem_d_i       => mem_d,
	    mem_d_o       => open,
	    mem_we        => open
	  );

	sram_inst : entity work.sram_512Kx8
		generic map
		(
	 		-- aggressive timing validation based on spec
		  tAA_max  		=> 55 ns,
		  tOHA_min 		=>  2 ns,
		  tACE_max 		=> 55 ns,
		  tDOE_max 		=> 30 ns,
		  tLZOE_min		=> 30 ns,
		  tHZOE_max		=> 25 ns,
		  tLZCE_min		=> 55 ns,
		  tHZCE_max		=> 25 ns,
		  tWC_min  		=> 55 ns,
		  tSCE_min 		=> 50 ns,
		  tAW_min  		=> 50 ns,
		  tHA_min  		=>  0 ns,
		  tSA_min  		=>  0 ns,
		  tPWE_min 		=> 50 ns,
		  tSD_min  		=> 30 ns,
		  tHD_min  		=>  0 ns,
		  tHZWE_max		=> 20 ns, -- no spec
		  tLZWE_min		=> 10 ns, -- no spec
			download_filename => "newdos80.dat",
			download_on_power_up => true
		)
		port map
		(
		  A          => mem_a(18 downto 0),
		  D          => mem_d,
		  NOE        => '0',
		  NCE1       => '0',
		  CE2        => '1',
		  NWE        => '1',
		  NBHE       => '0',
		  NBLE       => '0',
		  NBYTE      => '1'
		);

	process

		-- converts a std_logic_vector into a hex string.
		function hstr(slv: std_logic_vector) return string is
			variable hexlen: integer;
			variable longslv : std_logic_vector(67 downto 0) := (others => '0');
			variable hex : string(1 to 16);
			variable fourbit : std_logic_vector(3 downto 0);
		begin
			hexlen := (slv'left+1)/4;
			if (slv'left+1) mod 4 /= 0 then
				hexlen := hexlen + 1;
			end if;
			longslv(slv'left downto 0) := slv;
			for i in (hexlen -1) downto 0 loop
				fourbit := longslv(((i*4)+3) downto (i*4));
				case fourbit is
					when "0000" => hex(hexlen -I) := '0';
					when "0001" => hex(hexlen -I) := '1';
					when "0010" => hex(hexlen -I) := '2';
					when "0011" => hex(hexlen -I) := '3';
					when "0100" => hex(hexlen -I) := '4';
					when "0101" => hex(hexlen -I) := '5';
					when "0110" => hex(hexlen -I) := '6';
					when "0111" => hex(hexlen -I) := '7';
					when "1000" => hex(hexlen -I) := '8';
					when "1001" => hex(hexlen -I) := '9';
					when "1010" => hex(hexlen -I) := 'A';
					when "1011" => hex(hexlen -I) := 'B';
					when "1100" => hex(hexlen -I) := 'C';
					when "1101" => hex(hexlen -I) := 'D';
					when "1110" => hex(hexlen -I) := 'E';
					when "1111" => hex(hexlen -I) := 'F';
					when "ZZZZ" => hex(hexlen -I) := 'z';
					when "UUUU" => hex(hexlen -I) := 'u';
					when "XXXX" => hex(hexlen -I) := 'x';
					when others => hex(hexlen -I) := '?';
				end case;
			end loop;
			return hex(1 to hexlen);
		end hstr; 

    procedure rd (addr : in std_logic_vector(1 downto 0)) is
    begin
			fdc_a <= addr;
  		fdc_cs_n <= '0';
  		fdc_re_n <= '0';
  		wait until rising_edge(clk_20M);
  		wait for 2 ns;
  		fdc_cs_n <= '1';
  		fdc_re_n <= '1';
    end;

    procedure rd_sts (display : in boolean) is
			variable debug_l : line;
    begin
      rd (A_STS);
			-- and show the result
			if display then
				write(debug_l, string'("STATUS = $") & hstr(fdc_dat_o));
				writeline(OUTPUT, debug_l);
			end if;
    end;

    procedure wr (addr : in std_logic_vector(1 downto 0);
									data : in std_logic_vector(7 downto 0)) is
    begin
			fdc_a <= addr;
			fdc_dat_i <= data;
  		fdc_cs_n <= '0';
  		fdc_we_n <= '0';
  		wait until rising_edge(clk_20M);
  		wait for 2 ns;
  		fdc_cs_n <= '1';
  		fdc_we_n <= '1';
    end;

    procedure wr_cmd (data : in std_logic_vector(7 downto 0)) is
    begin
      wr (A_CMD, data);
    end;

		procedure rd_addr is
			variable data 		: std_logic_vector(7 downto 0);
			variable debug_l 	: line;
		begin
			data := X"C0"; -- read address
			write(debug_l, string'("READ_ADDR: ($") & hstr(data) & string'(")"));
			writeline(OUTPUT, debug_l);
	    wr_cmd (data);
	    for i in 0 to 5 loop
	      wait until drq = '1';
	      rd (A_DAT);
				write(debug_l, hstr(fdc_dat_o));
				write(debug_l, string'(" "));
	    end loop;
			writeline(OUTPUT, debug_l);
	    wait until intrq = '1';
	    rd_sts (true);
			rd (A_SEC);
			write(debug_l, string'("TRACK=($") & hstr(fdc_dat_o) & string'(")"));
			writeline(OUTPUT, debug_l);
		end;

		variable data			: std_logic_vector(7 downto 0);
		variable debug_l 	: line;

	begin

		-- select drive 0
    ds <= "0001";

    wait for 4 ms;
		data := X"D0"; -- force interrupt (none)
		write(debug_l, string'("FORCE_INTERRUPT ($") & hstr(data) & string'(")"));
		writeline(OUTPUT, debug_l);
    wr_cmd (data);
    wait for 1 ms;

		--fdc_dat_i <= X"0B"; -- restore
		data := X"0F"; -- restore (with verify)
		write(debug_l, string'("RESTORE/v ($") & hstr(data) & string'(")"));
		writeline(OUTPUT, debug_l);
    wr_cmd (data);
    wait until intrq = '1';
    rd_sts (true);

    wait for 1 ms;
		rd_addr;

		wait for 1 ms;
		data := X"54";	-- step in, update track, verify
		write(debug_l, string'("STEP_IN/t/v: ($") & hstr(data) & string'(")"));
		writeline(OUTPUT, debug_l);
    wr_cmd (data);
    wait until intrq = '1';
    rd_sts (true);

    wait for 1 ms;
		rd_addr;

		wait for 1 ms;
		wr (A_DAT, X"00");
		wait for 4 us;
		data := X"1C";	-- seek track 0
		write(debug_l, string'("SEEK/v: ($") & hstr(data) & string'(")"));
		writeline(OUTPUT, debug_l);
    wr_cmd (data);
    wait until intrq = '1';
    rd_sts (true);

    wait for 1 ms;
		rd_addr;

		wait for 1 ms;
		wr (A_DAT, X"05");
		wait for 4 us;
		data := X"1C";	-- seek track 5
		write(debug_l, string'("SEEK/v: ($") & hstr(data) & string'(")"));
		writeline(OUTPUT, debug_l);
    wr_cmd (data);
    wait until intrq = '1';
    rd_sts (true);

    wr (A_SEC, X"01");
    wait for 2 us;
		data := X"81"; 				-- read sector
    wr_cmd (data);

    for i in 0 to 255 loop
      wait until drq = '1';
      rd (A_DAT);
    end loop;
    wait until intrq = '1';
    rd_sts (false);

		data := X"20"; -- step
    wr_cmd (data);
    wait until intrq = '1';
    rd_sts (false);

		--fdc_dat_i <= X"D8"; -- force interrupt (immediate)
    --wr_cmd;

    wait for 4 ms;
		data := X"D0"; -- force interrupt (none)
    wr_cmd (data);

    wait for 4 ms;
		data := X"00"; -- RESTORE
    wr_cmd (data);

    wait until intrq = '1';
    rd_sts (false);

		-- select sector 16
		wait for 4 ms;
		fdc_a <= A_SEC;
    wr (A_SEC, X"10");	-- sector 16

		data := X"80";	-- read sector
    wr_cmd (data);

    for i in 0 to 255 loop
      wait until drq = '1';
      rd (A_DAT);
    end loop;

    wait until intrq = '1';

    rd_sts (false);

		wait for 1 ms;
		data := X"50";	-- step in, update track
    wr_cmd (data);

    wait until intrq = '1';
    rd_sts (false);

		wait for 100 ms;		
	end process;

end SYN;
