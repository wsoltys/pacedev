library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Avalon SPI slave
-- assumes SPI rising edge clock and low idle
-- ss_n min setup before clock rising edge = 2 cpu_clks 
entity vl_avalon_spi_slave is 
	generic
	(
		FIFO_DEPTH							: natural := 16;
		BIT_WIDTH								: natural := 8
	);
	port
	(
		cpu_clk									: in std_logic;
		cpu_reset								: in std_logic;

		-- External SPI interface
		spi_clk									: in std_logic;
		spi_miso								: out std_logic;
		spi_mosi								: in std_logic;
		spi_ss_n								: in std_logic;
		spi_srdy_n							: out std_logic;
		spi_mrdy_n							: in std_logic;

		-- NIOS register interface
		avs_s1_address						: in std_logic_vector(3 downto 0);
		avs_s1_readdata						: out std_logic_vector(31 downto 0);
		avs_s1_writedata					: in std_logic_vector(31 downto 0);
		avs_s1_read								: in std_logic;
		avs_s1_write							: in std_logic;
		avs_s1_waitrequest				: out std_logic;
		
		s1_irq										: out std_logic
	);
end entity vl_avalon_spi_slave;

architecture SYN of vl_avalon_spi_slave is

	function ceil_log2(A: integer) return integer is
	begin
		for I in 1 to 30 loop  -- Works for up to 32 bit integers
			if(2**I > A) then return(I-1);  end if;
		end loop;
		return(30);
	end;

	constant DELAY					: time := 1 ns;
	constant UMLEN					: integer := 3;		-- Unmeta chain length
	
	constant FIFO_BITS			: natural := ceil_log2(FIFO_DEPTH);
	
	signal mfifo_rd					: std_logic;
	signal mfifo_q					: std_logic_vector(BIT_WIDTH-1 downto 0);
	signal mfifo_empty			: std_logic;
	signal mfifo_wr					: std_logic;
	signal mfifo_d					: std_logic_vector(BIT_WIDTH-1 downto 0);
	signal mfifo_full				: std_logic;
	signal mfifo_usedw			: std_logic_vector(FIFO_BITS-1 downto 0);

	signal sfifo_rd					: std_logic;
	signal sfifo_q					: std_logic_vector(BIT_WIDTH-1 downto 0);
	signal sfifo_empty			: std_logic;
	signal sfifo_wr					: std_logic;
	signal sfifo_d					: std_logic_vector(BIT_WIDTH-1 downto 0);
	signal sfifo_full				: std_logic;
	signal sfifo_usedw			: std_logic_vector(FIFO_BITS-1 downto 0);

	signal m_overrun				: std_logic;
begin

	-- FIFO decouples incoming spi_clk from cpu_clk
	BLK_FIFOS : block
		COMPONENT scfifo
		GENERIC (
			add_ram_output_register		: STRING;
--			add_usedw_msb_bit : STRING;
			intended_device_family		: STRING;
			lpm_numwords		: NATURAL;
			lpm_showahead		: STRING;
			lpm_type		: STRING;
			lpm_width		: NATURAL;
			lpm_widthu		: NATURAL;
			overflow_checking		: STRING;
			underflow_checking		: STRING;
			use_eab		: STRING
		);
		PORT (
				clock	: IN STD_LOGIC ;
				usedw	: OUT STD_LOGIC_VECTOR(FIFO_BITS-1 downto 0) ;
				q	: OUT STD_LOGIC_VECTOR (BIT_WIDTH-1 DOWNTO 0);
				empty	: OUT STD_LOGIC ;
				full	: OUT STD_LOGIC ;
				wrreq	: IN STD_LOGIC ;
				aclr	: IN STD_LOGIC ;
				data	: IN STD_LOGIC_VECTOR (BIT_WIDTH-1 DOWNTO 0);
				rdreq	: IN STD_LOGIC 
		);
		END COMPONENT scfifo;
	begin

		-- Master FIFO stores bytes sent from master
		mfifo_inst : scfifo
			generic map
			(
				add_ram_output_register => "OFF",
--				add_usedw_msb_bit => "ON",
				intended_device_family => "Cyclone IV E",
				lpm_numwords => FIFO_DEPTH,
				lpm_showahead => "ON",
				lpm_type => "scfifo",
				lpm_width => BIT_WIDTH,
				lpm_widthu => FIFO_BITS,
				overflow_checking => "ON",
				underflow_checking => "ON",
				use_eab => "OFF"
			)
			port map
			(
				aclr					=> cpu_reset,
											
				clock					=> cpu_clk,
				rdreq					=> mfifo_rd,
				q						 	=> mfifo_q,
				empty					=> mfifo_empty,
				wrreq					=> mfifo_wr,
				data					=> mfifo_d,
				full					=> mfifo_full,
				usedw					=> mfifo_usedw
			);

		-- Slave FIFO queues bytes to send back to master
		sfifo_inst : scfifo
			generic map
			(
				add_ram_output_register => "OFF",
--				add_usedw_msb_bit => "ON",
				intended_device_family => "Cyclone IV E",
				lpm_numwords => FIFO_DEPTH,
				lpm_showahead => "ON",
				lpm_type => "scfifo",
				lpm_width => BIT_WIDTH,
				lpm_widthu => FIFO_BITS,
				overflow_checking => "ON",
				underflow_checking => "ON",
				use_eab => "OFF"
			)
			port map
			(
				aclr					=> cpu_reset,
											
				clock					=> cpu_clk,
				rdreq					=> sfifo_rd,
				q						 	=> sfifo_q,
				empty					=> sfifo_empty,
				wrreq					=> sfifo_wr,
				data					=> sfifo_d,
				full					=> sfifo_full,
				usedw					=> sfifo_usedw
			);

	end block BLK_FIFOS;

	BLK_SPI : block
		signal spi_reset	: std_logic;

		signal s_clk			: std_logic;
		signal s_miso			: std_logic;
		signal s_mosi			: std_logic;
		signal s_ss_n			: std_logic;
		signal s_mrdy_n		: std_logic;
		signal s_srdy_n		: std_logic;

		signal s_clk_rise	: std_logic;
		signal s_ss_n_fall: std_logic;
		signal s_shift		: std_logic;
		signal s_capture	: std_logic;
		signal s_load			: std_logic;
		signal s_lastbit	: std_logic;

		signal mshr				: std_logic_vector(BIT_WIDTH-1 downto 0);
		signal sshr				: std_logic_vector(BIT_WIDTH-1 downto 0);
		signal ssbusy			: std_logic;
		signal bitcnt			: integer range 0 to BIT_WIDTH-1;
		signal s_mrdy_n_r	: std_logic;
	begin

		spi_miso <= s_miso;
		spi_srdy_n <= s_srdy_n;

		s_miso <= sshr(7);
		s_srdy_n <= not ssbusy;
		
		-- Load/capture shifted data at falling edge of ss_n or last bit of byte
		s_capture <= '1' when (s_shift = '1' and bitcnt = BIT_WIDTH-1) else '0';
		s_load <= '1' when (ssbusy = '0' and s_ss_n = '1') or s_capture = '1' else '0';
		s_shift <= s_clk_rise;

		-- Slave FIFO signals
		sfifo_rd <= '1' when s_load = '1' and sfifo_empty = '0' else '0';

		-- Master FIFO signals
		mfifo_d <= mshr;

		-- Check for master (RX) overrun
		m_overrun <= '1' when s_capture = '1' and s_mrdy_n_r = '0' and mfifo_full = '1' else '0';

		-- SPI unmeta signals
		SPI_UM_REG : process (cpu_clk, cpu_reset)
			variable s_clk_um			: std_logic_vector(UMLEN+1 downto 1);
			variable s_ss_n_um		: std_logic_vector(UMLEN+2 downto 1);
			variable s_mosi_um		: std_logic_vector(UMLEN downto 1);
			variable s_mrdy_n_um	: std_logic_vector(UMLEN downto 1);
		begin
			if cpu_reset = '1' then
				s_clk_um := (others => '0');
				s_mosi_um := (others => '0');
				s_ss_n_um := (others => '0');
				s_mrdy_n_um := (others => '0');
				s_clk_rise <= '0';
				s_ss_n_fall <= '0';
			elsif rising_edge(cpu_clk) then
				s_clk_um := s_clk_um(s_clk_um'high-1 downto 1) & spi_clk;
				s_ss_n_um := s_ss_n_um(s_ss_n_um'high-1 downto 1) & spi_ss_n;
				s_mosi_um := s_mosi_um(s_mosi_um'high-1 downto 1) & spi_mosi;
				s_mrdy_n_um := s_mrdy_n_um(s_mrdy_n_um'high-1 downto 1) & spi_mrdy_n;

				if s_clk_um(UMLEN+1) = '0' and s_clk_um(UMLEN) = '1' then
					s_clk_rise <= '1';
				else
					s_clk_rise <= '0';
				end if;

				if s_ss_n_um(UMLEN+2) = '1' and s_ss_n_um(UMLEN+1) = '0' then
					s_ss_n_fall <= '1';
				else
					s_ss_n_fall <= '0';
				end if;
			end if;

			s_clk <= s_clk_um(UMLEN);
			s_mosi <= s_mosi_um(UMLEN);
			s_ss_n <= s_ss_n_um(UMLEN);
			s_mrdy_n <= s_mrdy_n_um(UMLEN);
		end process SPI_UM_REG;

		-- SPI logic
		SPI_REG : process (cpu_clk, cpu_reset, spi_reset)
		begin

			-- SPI shift registers
			if cpu_reset = '1' then
				mshr <= (others => '0');
				sshr <= (others => '0');
				ssbusy <= '0';
				s_mrdy_n_r <= '1';
				s_lastbit <= '0';

			elsif rising_edge(cpu_clk) then	
				if s_shift = '1' then
					mshr <= mshr(BIT_WIDTH-2 downto 0) & s_mosi;
				end if;

				if s_load = '1' then
					if sfifo_rd = '1' then
						sshr <= sfifo_q;
          else
            -- ensure we have crap in the register
						sshr <= X"AA";
					end if;
					ssbusy <= not sfifo_empty;

				elsif s_shift = '1' then
					sshr <= sshr(BIT_WIDTH-2 downto 0) & '0';
					if bitcnt = 0 then
						s_mrdy_n_r <= s_mrdy_n;
					end if;
				end if;

				-- Latch master data one clock after capture
				if s_capture = '1' and s_mrdy_n_r = '0' and mfifo_full = '0' then
					mfifo_wr <= '1';
				else
					mfifo_wr <= '0';
				end if;

			end if;

			-- SPI shift counter
			if spi_reset = '1' then
				bitcnt <= 0;
			elsif rising_edge(cpu_clk) then	
				if s_capture = '1' then
					bitcnt <= 0;
				elsif s_shift = '1' then
					bitcnt <= bitcnt + 1;
				end if;
			end if;

			-- Generate spi_reset
			if cpu_reset = '1' then
				spi_reset <= '1';
			elsif rising_edge(cpu_clk) then
				spi_reset <= s_ss_n;
			end if;
		end process SPI_REG;

	end block BLK_SPI;

	BLK_CPU : block
		signal tx_overrun				: std_logic;
		signal rx_overrun				: std_logic;
		signal rx_rdy_int				: std_logic;
		signal tx_rdy_int				: std_logic;
		signal tx_ovr_int				: std_logic;
		signal rx_ovr_int				: std_logic;
		signal err_int					: std_logic;
		signal waitrequest			: std_logic;
		signal waitrequest_r		: std_logic;
	begin

		-- Master FIFO signals
		mfifo_rd <= '1' when avs_s1_read = '1' and avs_s1_address = X"0" and waitrequest_r = '0' and mfifo_empty = '0' else '0';

		-- Slave FIFO signals
		sfifo_wr <= '1' when avs_s1_write = '1' and avs_s1_address = X"1" and sfifo_full = '0' else '0';
		sfifo_d <= avs_s1_writedata(sfifo_d'range);

		-- CPU Registers
		PROC_REG : process (cpu_clk, cpu_reset)
			variable addr			: std_logic_vector(3 downto 0) := (others => '0');
			variable readdata	: std_logic_vector(31 downto 0) := (others => '0');

		begin
			addr := avs_s1_address;
			readdata := (others => 'X');

			if cpu_reset = '1' then
				tx_overrun <= '0';
				rx_overrun <= '0';

				rx_rdy_int <= '0';
				tx_rdy_int <= '0';
				tx_ovr_int <= '0';
				rx_ovr_int <= '0';
				err_int <= '0';

			elsif rising_edge (cpu_clk) then
				-- Handle register reads
				if avs_s1_read = '1' then
					case addr is
						when X"0" =>	-- rxdata
							readdata := (others => 'X');
							readdata(BIT_WIDTH-1 downto 0) := mfifo_q;
						when X"1" => -- txdata
							readdata := (others => 'X');
						when X"2" =>	-- status
							readdata := X"00000"&"000" & (tx_overrun or rx_overrun) & (not mfifo_empty) & (not sfifo_full) & (not sfifo_empty) & tx_overrun & rx_overrun & "000";
						when X"3" =>	-- control
							readdata := X"00000"&"000" & err_int & rx_rdy_int & tx_rdy_int & '0' & tx_ovr_int & rx_ovr_int & "000";
						when others =>
					end case;

				-- Handle register writes
				elsif avs_s1_write = '1' then
					case addr is
						when X"0" =>	-- rxdata

						when X"1" =>	-- txdata

						when X"2" =>	-- status
							tx_overrun <= '0';
							rx_overrun <= '0';

						when X"3" =>	-- control
							err_int <= avs_s1_writedata(8);
							rx_rdy_int <= avs_s1_writedata(7);
							tx_rdy_int <= avs_s1_writedata(6);
							tx_ovr_int <= avs_s1_writedata(4);
							rx_ovr_int <= avs_s1_writedata(3);
						when others =>
					end case;
				end if; -- read/write

				-- Generate error and interrupt signals
				if avs_s1_write = '1' and avs_s1_address = X"1" and sfifo_full = '1' then
					tx_overrun <= '1';
				end if;
				if m_overrun = '1' then
					rx_overrun <= '1';
				end if;

				s1_irq <= (tx_ovr_int and tx_overrun) 
							or (rx_ovr_int and rx_overrun) 
							or (err_int and (tx_overrun or rx_overrun)) 
							or (tx_rdy_int and (not sfifo_full))
						 	or (rx_rdy_int and (not mfifo_empty));

				avs_s1_readdata <= readdata;
				waitrequest_r <= waitrequest;

			end if;
		end process PROC_REG;

		waitrequest <= avs_s1_read and not waitrequest_r;
		avs_s1_waitrequest <= waitrequest;

	end block BLK_CPU;

end architecture SYN;
		
