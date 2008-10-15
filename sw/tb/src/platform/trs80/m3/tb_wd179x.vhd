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
	signal ds						: std_logic_vector(4 downto 1) := (others => '0');
  signal intrq        : std_logic := '0';
  signal drq          : std_logic := '0';

	signal mem_a				: std_logic_vector(21 downto 0) := (others => '1');
	signal mem_d				: std_logic_vector(7 downto 0);
	signal mem_we_n			: std_logic := '1';
	signal mem_oe_n			: std_logic := '1';

begin

	-- Generate CLK and reset
  clk_20M <= not clk_20M after 25000 ps; -- 20MHz
	reset <= '0' after 10 ns;

	--mem_d <= mem(conv_integer(mem_a));

    BLK_FDC : block

      constant FDC_USE_FIFO : boolean := false;
      
			alias reset_i				: std_logic is reset;
			alias platform_reset	: std_logic is reset;

      signal sync_reset   : std_logic := '1';
      
      signal step         : std_logic := '0';
      signal dirc         : std_logic := '0';
      signal rg           : std_logic := '0';
      signal rclk         : std_logic := '0';
      signal raw_read_n   : std_logic := '0';
      signal wg           : std_logic := '0';
      signal wd           : std_logic := '0';
      signal tr00_n       : std_logic := '0';
      signal ip_n         : std_logic := '0';

      signal de_s         : std_logic_vector(4 downto 1);

      -- floppy data
      signal track              : std_logic_vector(7 downto 0) := (others => '0');
      signal offset             : std_logic_vector(12 downto 0) := (others => '0');
      signal rd_data_from_media : std_logic_vector(7 downto 0) := (others => '0');
      signal rd_data_from_fifo  : std_logic_vector(7 downto 0) := (others => '0');
      signal wr_data_to_media		: std_logic_vector(7 downto 0) := (others => '0');
     	signal media_wr						: std_logic := '0';

      signal fifo_rd      : std_logic := '0';
      signal fifo_wr      : std_logic := '0';
      signal fifo_flush   : std_logic := '0';

      signal floppy_dbg   : std_logic_vector(31 downto 0) := (others => '0');
      signal wd179x_dbg   : std_logic_vector(31 downto 0) := (others => '0');
      
    begin

      process (clk_20M, reset_i)
        variable reset_r : std_logic_vector(3 downto 0) := (others => '0');
      begin
        if reset_i = '1' then
          reset_r := (others => '1');
        elsif rising_edge(clk_20M) then
          reset_r := reset_r(reset_r'left-1 downto 0) & platform_reset;
        end if;
        sync_reset <= reset_r(reset_r'left);
      end process;
      
      wd179x_inst : entity work.wd179x
        port map
        (
          clk           => clk_20M,
          clk_20M_ena   => '1',
          reset         => sync_reset,
          
          -- micro bus interface
          mr_n          => '1',
          we_n          => fdc_we_n,
          cs_n          => fdc_cs_n,
          re_n          => fdc_re_n,
          a             => fdc_a,
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
          rg            => rg,
          sso           => open,
          rclk          => rclk,
          raw_read_n    => raw_read_n,
          hld           => open,    -- not used atm
          tg43          => open,    -- not used on TRS-80 designs
          wg            => wg,
          wd            => wd,      -- 200ns (MFM) or 500ns (FM) pulse
          ready         => '1',     -- always read atm
          wf_n_i        => '1',     -- no write faults atm
          vfoe_n_o      => open,    -- not used in TRS-80 designs?
          tr00_n        => tr00_n,
          ip_n          => ip_n,
          wprt_n        => '1',     -- never write-protected atm
          dden_n        => '1',     -- single density only atm

					-- temp fudge
					wr_dat_o			=> wr_data_to_media,
          
          debug         => wd179x_dbg
        );
        
      wd9216_inst : entity work.wd9216
        port map
        (
          clk           => clk_20M,
          clk_20M_ena   => '1',
          reset         => sync_reset,
        
          dskd_n        => '0',
          sepclk        => open,
          refclk        => '0',
          cd            => "00",
          sepd_n        => open,
      
          debug         => open
        );
        
      floppy_if_inst : entity work.floppy_if
        generic map
        (
          NUM_TRACKS      => 40
        )
        port map
        (
          clk           => clk_20M,
          clk_20M_ena   => '1',
          reset         => sync_reset,
          
          -- drive select lines
          drv_ena       => de_s,
          drv_sel       => ds,
          
          step          => step,
          dirc          => dirc,
          rg            => rg,
          rclk          => rclk,
          raw_read_n    => raw_read_n,
          wg            => wg,
          wd            => wd,
          tr00_n        => tr00_n,
          ip_n          => ip_n,
          
          -- media interface

          track         => track,
          dat_i         => rd_data_from_fifo,
          dat_o         => open,
          -- random-access control
          offset        => offset,
          -- fifo control
          rd            => fifo_rd,
          wr            => media_wr,
          flush         => fifo_flush,
          
          debug         => floppy_dbg
        );

      GEN_FLOPPY_FIFO : if FDC_USE_FIFO generate
        BLK_FIFO : block
					signal fifo_rd_pulse	: std_logic := '0';
          signal fifo_empty   	: std_logic := '0';
          signal fifo_full    	: std_logic := '0';
        begin
          fifo_inst : ENTITY work.floppy_fifo
            PORT map
            (
              rdclk		  => clk_20M,
              q		      => rd_data_from_fifo,
              rdreq		  => fifo_rd_pulse,
              rdempty		=> fifo_empty,

              wrclk		  => clk_20M,
              data		  => rd_data_from_media,
              wrreq		  => fifo_wr,
              wrfull		=> fifo_full,
              aclr      => fifo_flush
            );

          process (clk_20M, sync_reset)
            subtype count_t is integer range 0 to 7;
            variable count    	: count_t := 0;
            variable offset_v 	: std_logic_vector(12 downto 0) := (others => '0');
						variable fifo_rd_r	: std_logic := '0';
          begin
            if sync_reset = '1' then
              count := 0;
              offset_v := (others => '0');
            elsif rising_edge(clk_20M) then

							fifo_rd_pulse <= '0';	-- default
							if fifo_rd = '1' and fifo_rd_r = '0' then
								fifo_rd_pulse <= '1';
							end if;
							fifo_rd_r := fifo_rd;

              fifo_wr <= '0';   -- default
              if count = count_t'high then
                if fifo_full = '0' then
                  fifo_wr <= '1';
                  if offset_v = 6272-1 then
                    offset_v := (others => '0');
                  else
                    offset_v := offset_v + 1;
                  end if;
                end if;
                count := 0;
              else
            		mem_a(12 downto 0) <= offset_v;
                count := count + 1;
              end if;
            end if;
          end process;

        end block BLK_FIFO;
        
      end generate GEN_FLOPPY_FIFO;
      
      GEN_FLOPPY_NO_FIFO : if not FDC_USE_FIFO generate
        -- each track is encoded in 8KiB
        -- - 40 tracks is 320(512) KiB
        mem_a(12 downto 0) <= offset;
        rd_data_from_fifo <= rd_data_from_media;
      end generate GEN_FLOPPY_NO_FIFO;
      
      BLK_FLASH_FLOPPY : block
      begin  

        mem_a(mem_a'left downto 20) <= (others => '0');
        -- support 2 drives in flash for now
        mem_a(19) <=  '0' when ds(1) = '1' else
                      '1' when ds(2) = '1' else
                      '0';
        mem_a(18 downto 13) <= track(5 downto 0);

        rd_data_from_media <= mem_d;

				-- write logic
				mem_d <= wr_data_to_media when wg = '1' else (others => 'Z');
				mem_oe_n <= wg;
				mem_we_n <= not media_wr;

      end block BLK_FLASH_FLOPPY;
      
      -- drive enable switches
      de_s <= "1111";
      
    end block BLK_FDC;

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
		  NOE        => mem_oe_n,
		  NCE1       => '0',
		  CE2        => '1',
		  NWE        => mem_we_n,
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

    procedure wr_cmd (str : in string; data : in std_logic_vector(7 downto 0)) is
			variable debug_l	: line;
    begin
			write(debug_l, str & string'(" (") & hstr(data) & string'(")"));
			writeline(OUTPUT, debug_l);
      wr (A_CMD, data);
    end;

		procedure rd_addr is
			variable data 		: std_logic_vector(7 downto 0);
			variable debug_l 	: line;
		begin
	    wr_cmd ("READ_ADDR", X"C0");
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
		variable count 		: std_logic_vector(7 downto 0) := (others => '0');

	begin

		-- select drive 0
    ds <= "0001";

    wait for 4 ms;
    wr_cmd ("FORCE_INTERRUPT(none)", X"D0");
    wait for 1 ms;

		-- write track
		if false then
			count := (others => '0');
			wr_cmd ("WRITE_TRACK", X"F0");
			for i in 0 to 6271 loop
				wait until drq = '1';
				wr (A_DAT, count);
				wait until drq = '0';
				count := count + 1;
			end loop;
			wait until intrq = '1';
		end if;

		-- write sector
		if false then
			wr (A_SEC, X"0A");	-- sector 10
			wait for 1 ms;
			count := (others => '0');
			wr_cmd ("WRITE_SECTOR", X"A0");
			for i in 0 to 255 loop
				wait until drq = '1';
				wr (A_DAT, count);
				wait until drq = '0';
				count := count + 1;
			end loop;
			wait until intrq = '1';
		end if;

    if false then

  		--fdc_dat_i <= X"0B"; -- restore
      wr_cmd ("RESTORE/v", X"0F");
      wait until intrq = '1';
      rd_sts (true);
  
      wait for 1 ms;
  		rd_addr;
  
  		wait for 1 ms;
      wr_cmd ("STEP_IN/t/v", X"54");	-- step in, update track, verify
      wait until intrq = '1';
      rd_sts (true);
  
      wait for 1 ms;
  		rd_addr;
  
  		wait for 1 ms;
  		wr (A_DAT, X"00");
  		wait for 4 us;
      wr_cmd ("SEEK/v", X"1C");
      wait until intrq = '1';
      rd_sts (true);
  
      wait for 1 ms;
  		rd_addr;
  
  		wait for 1 ms;
  		wr (A_DAT, X"05");
  		wait for 4 us;
      wr_cmd ("SEEK/v", X"1C");
      wait until intrq = '1';
      rd_sts (true);

    end if;

    wr (A_SEC, X"0A");
    wait for 2 us;
    wr_cmd ("READ_SECTOR", X"81");

    for i in 0 to 255 loop
      wait until drq = '1';
      rd (A_DAT);
    end loop;
    wait until intrq = '1';
    rd_sts (false);

    wr_cmd ("STEP", X"20");
    wait until intrq = '1';
    rd_sts (false);

		--fdc_dat_i <= X"D8"; -- force interrupt (immediate)
    --wr_cmd;

    wait for 4 ms;
    wr_cmd ("FORCE_INTERRUPT(none)", X"D0");

    wait for 4 ms;
    wr_cmd ("RESTORE", X"00");

    wait until intrq = '1';
    rd_sts (false);

		-- select sector 16
		wait for 4 ms;
		fdc_a <= A_SEC;
    wr (A_SEC, X"10");	-- sector 16

    wr_cmd ("READ_SECTOR", X"80");

    for i in 0 to 255 loop
      wait until drq = '1';
      rd (A_DAT);
    end loop;

    wait until intrq = '1';

    rd_sts (false);

		wait for 1 ms;
    wr_cmd ("STEP_IN/t", X"50");

    wait until intrq = '1';
    rd_sts (false);

		wait for 100 ms;		
	end process;

end SYN;
