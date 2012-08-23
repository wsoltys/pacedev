library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_aspi is
	port (
		fail:				out  boolean
	);
end tb_aspi;

architecture SYN of tb_aspi is

  constant DELAY                    : time := 2 ns;

  signal sim_done                   : boolean := false;
    
  -- NIOS interface
  signal nios_clk                   : std_logic := '0';
  signal nios_reset                 : std_logic := '1';
  signal nios_reset_n               : std_logic;
  signal nios_address               : std_logic_vector(3 downto 0) := (others => '0');
  signal nios_readdata              : std_logic_vector(31 downto 0) := (others => '0');
  signal nios_writedata             : std_logic_vector(31 downto 0) := (others => '0');
  signal nios_read                  : std_logic := '0';
  signal nios_write                 : std_logic := '0';
  signal nios_waitrequest           : std_logic := '0';

	-- SPI interface
	signal spi_clk										: std_logic := '0';
	signal spi_miso										: std_logic;
	signal spi_mosi										: std_logic := '0';
	signal spi_ss_n										: std_logic := '1';
	signal spi_srdy_n									: std_logic;
	signal spi_mrdy_n									: std_logic := '1';

	signal spi_send										: std_logic_vector(7 downto 0) := (others => '0');
	signal spi_recv										: std_logic_vector(7 downto 0) := (others => '0');

begin

	-- Generate CLK and reset
	nios_clk <= not nios_clk after 7 ns when not sim_done else '0';   -- 108 MHz
	nios_reset <= '0' after 100 ns;
	nios_reset_n <= not nios_reset;
  
	tb : process
	
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

    procedure nios_rd ( adr : in std_logic_vector(3 downto 0); 
                        dat : out std_logic_vector(31 downto 0)) is
    begin
      wait until rising_edge(nios_clk);
      nios_address(3 downto 0) <= adr after DELAY;
      nios_read <= '1' after DELAY;
      nios_write <= '0' after DELAY;
      wait until falling_edge(nios_waitrequest);
      --wait until rising_edge(nios_clk);
      nios_read <= '0' after DELAY;
			dat := nios_readdata;
    end procedure nios_rd;

    procedure nios_wr ( adr : in std_logic_vector(3 downto 0); 
                        dat : in std_logic_vector(31 downto 0)) is
    begin
      wait until rising_edge(nios_clk);
      nios_address(3 downto 0) <= adr after DELAY;
      nios_writedata <= dat;
      nios_read <= '0' after DELAY;
      nios_write <= '1' after DELAY;
			loop
      	wait until rising_edge(nios_clk);
				exit when nios_waitrequest = '0';
			end loop;
      nios_write <= '0' after DELAY;
    end procedure nios_wr;
	
    variable debug_l    : line;

    variable rd_data32  : std_logic_vector(31 downto 0) := (others => '0');

	begin

    wait until nios_reset = '0';

    -- check from NIOS side
    wait for 500 ns;
    nios_wr (X"1", X"00000069");
    wait for 2000 ns;
    nios_rd (X"2", rd_data32);
		write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
    nios_rd (X"0", rd_data32);
		write(debug_l, string'(" RD=$") & hstr(rd_data32));
		writeline(OUTPUT, debug_l);

    wait for 100 ns;
    nios_wr (X"1", X"12345678");
    nios_wr (X"1", X"0000005A");
    nios_wr (X"1", X"00000091");
    wait for 100 ns;
    nios_rd (X"2", rd_data32);
		write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
    nios_rd (X"0", rd_data32);
		write(debug_l, string'(" RD=$") & hstr(rd_data32));
		writeline(OUTPUT, debug_l);
    wait for 10000 ns;
    nios_rd (X"2", rd_data32);
		write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
    nios_rd (X"0", rd_data32);
		write(debug_l, string'(" RD=$") & hstr(rd_data32));
		writeline(OUTPUT, debug_l);
    nios_rd (X"2", rd_data32);
		write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
    nios_rd (X"0", rd_data32);
		write(debug_l, string'(" RD=$") & hstr(rd_data32));
		writeline(OUTPUT, debug_l);
    nios_rd (X"2", rd_data32);
		write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
    nios_rd (X"0", rd_data32);
		write(debug_l, string'(" RD=$") & hstr(rd_data32));
		writeline(OUTPUT, debug_l);
        
    wait for 100 ns;
    nios_wr (X"1", X"00000001");
    nios_wr (X"1", X"000000FE");
    nios_wr (X"1", X"00000002");
    nios_wr (X"1", X"000000FD");
    nios_wr (X"1", X"00000004");
    nios_wr (X"1", X"000000FC");
    nios_wr (X"1", X"00000008");
    nios_wr (X"1", X"000000F8");
    nios_wr (X"1", X"00000010");
    nios_wr (X"1", X"000000EF");
    nios_wr (X"1", X"00000020");
    nios_wr (X"1", X"000000DF");
    nios_wr (X"1", X"00000040");
    nios_wr (X"1", X"000000CF");
    nios_wr (X"1", X"00000080");
    nios_wr (X"1", X"0000008F");
    nios_wr (X"1", X"00000099");
    nios_wr (X"1", X"000000AA");
    --nios_wr (X"1", X"000000BB");

    wait for 20000 ns;
		for I in 0 to 16 loop
			nios_rd (X"2", rd_data32);
			write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
			nios_rd (X"0", rd_data32);
			write(debug_l, string'(" RD=$") & hstr(rd_data32));
			writeline(OUTPUT, debug_l);
		end loop;

		nios_wr(X"2", (others => '0'));
		nios_rd (X"2", rd_data32);
		write(debug_l, string'(" NIOS STAT=$") & hstr(rd_data32));
		nios_rd (X"0", rd_data32);
		write(debug_l, string'(" RD=$") & hstr(rd_data32));
		writeline(OUTPUT, debug_l);

		sim_done <= true;
		wait;
	end process;

	SPI : process 
    procedure spi_tx (tx : in std_logic_vector(7 downto 0);
											rx : out std_logic_vector(7 downto 0)) is
    begin
			spi_ss_n <= '0';

			rx := (others => 'X');

			for I in 7 downto 0 loop
				spi_clk <= '0';
				spi_mosi <= tx(I);
				wait for 50 ns;
				spi_clk <= '1';
				rx(I) := spi_miso;
				wait for 50 ns;
				if I = 1 then
					spi_mrdy_n <= '1';
				end if;
			end loop;

			spi_ss_n <= '1';
			spi_clk <= '0';
    end procedure spi_tx;

		variable srx : std_logic_vector(7 downto 0);
		variable cnt : integer := 0;
	begin
		wait for 2000 ns;

		spi_send <= X"F2";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 10 ns;

		spi_send <= X"00";
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		
		spi_send <= X"ab";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 10 ns;
		wait for 1000 ns;

		spi_send <= X"93";
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;

		wait for 1000 ns;

		spi_send <= X"45";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"0F";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"F0";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"A3";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"19";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"2E";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"FF";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"02";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"93";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		spi_send <= X"DD";
		spi_mrdy_n <= '0';
		wait for 1 ns;
		spi_tx(spi_send, srx);
		spi_recv <= srx;
		wait for 1 ns;

		wait for 1000 ns;
		cnt := 0;
		while spi_srdy_n = '0' loop
			if cnt < 6 then
				spi_send <= X"00";
			else
				spi_send <= spi_recv;
				spi_mrdy_n <= '0';
			end if;
			wait for 1 ns;
			spi_tx(spi_send, srx);
			spi_recv <= srx;
			wait for 1 ns;
			cnt := cnt + 1;
		end loop;
		wait;
	end process SPI;

  aspi_inst : entity work.vl_avalon_spi_slave
    generic map
    (
		FIFO_DEPTH => 16,
		BIT_WIDTH => 8
	)
    port map
    (
  	  cpu_clk		           => nios_clk,
  	  cpu_reset           => nios_reset,
  	                  
			-- External SPI interface
			spi_clk							=> spi_clk,
			spi_miso						=> spi_miso,	
			spi_mosi						=> spi_mosi,
			spi_ss_n						=> spi_ss_n,
			spi_srdy_n					=> spi_srdy_n,
			spi_mrdy_n					=> spi_mrdy_n,

			-- NIOS register interface
  	  avs_s1_address       => nios_address,
  	  avs_s1_writedata     => nios_writedata,
  	  avs_s1_readdata      => nios_readdata,
  	  avs_s1_read          => nios_read,
  	  avs_s1_write         => nios_write,
  	  avs_s1_waitrequest   => nios_waitrequest,
  	  s1_irq       		    => open
  	
    );

end SYN;
