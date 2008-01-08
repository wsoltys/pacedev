library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.EXT;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.platform_pkg.all;
use work.project_pkg.all;

entity c1541_core is
	generic
	(
		DEVICE_SELECT		: std_logic_vector(1 downto 0) := "00"
	);
	port
	(
		clk_32M					: in std_logic;
		reset						: in std_logic;

		-- serial bus
		sb_data_oe			: out std_logic;
		sb_data_in			: in std_logic;
		sb_clk_oe				: out std_logic;
		sb_clk_in				: in std_logic;
		sb_atn_oe				: out std_logic;
		sb_atn_in				: in std_logic;
		
		-- drive-side interface
		ds							: in std_logic_vector(1 downto 0);		-- device select
		act							: out std_logic;											-- activity LED

		-- mechanism interface signals				
		wps_n						: in std_logic;
		tr00_sense_n		: in std_logic;
		stp_in					: out std_logic;
		stp_out					: out std_logic;

		-- fifo signals
    fifo_wrclk      : in std_logic;
    fifo_data       : in std_logic_vector(7 downto 0);
    fifo_wrreq      : in std_logic;
    fifo_wrfull     : out std_logic;
    fifo_wrusedw    : out std_logic_vector(7 downto 0)
	);
end c1541_core;

architecture SYN of c1541_core is

		signal mode 						: std_logic;
		signal stp 							: std_logic_vector(1 downto 0);
		signal mtr 							: std_logic;
		signal freq							: std_logic_vector(1 downto 0);
		signal sync_n						: std_logic;
		signal sync_n_s					: std_logic;
		signal byte_n						: std_logic;
		signal byte_n_s					: std_logic;

		-- fifo-related signals
		signal fifo_wrreq_pulse	: std_logic;
		signal fifo_wrfull_s		: std_logic;
		signal fifo_wrusedw_s   : std_logic_vector(fifo_wrusedw'range);
		signal fifo_aclr				: std_logic;
		signal fifo_q						: std_logic_vector(7 downto 0);
		signal fifo_q_s					: std_logic_vector(fifo_q'range);
		signal fifo_rdclk_en    : std_logic := '0';
		signal fifo_rdreq				: std_logic;
		signal fifo_rdempty			: std_logic;

		signal stp_in_s					: std_logic;
		signal stp_out_s				: std_logic;
		
	begin

		-- monitor the STP inputs for a track change
		process (clk_32M, reset, stp)
			variable stp_r : std_logic_vector(stp'range) := (others => '0');
			variable stp_r_stp : std_logic_vector(3 downto 0) := (others => '0');
		begin
			-- schematic labelling has STP bits reversed
			stp_r_stp := stp_r(0) & stp_r(1) & stp(0) & stp(1);
			if reset = '1' then
				stp_r := (others => '0');
				stp_in_s <= '0';
				stp_out_s <= '0';
				fifo_aclr <= '1';
			elsif rising_edge(clk_32M) then
				fifo_aclr <= '0'; -- default
				if (stp /= stp_r) then
					case stp_r_stp is
						when "0001" | "0110" | "1011" | "1100" =>
							-- increment track, or step in
							stp_in_s <= not stp_in_s;
							fifo_aclr <= '1';
						when "0011" | "0100" | "1001" | "1110" =>
							-- decrement track, or step out
							stp_out_s <= not stp_out_s;
							fifo_aclr <= '1';
						when others =>
							null;
					end case;
				end if;
				stp_r := stp;
			end if;
		end process;
		
		-- assign external outputs
		stp_in <= stp_in_s;
		stp_out <= stp_out_s;
		
		-- produce a single wrreq pulse from the input wrreq signal
		process (fifo_wrclk, reset)
			variable fifo_wrreq_r : std_logic := '0';
		begin
			if reset = '1' then
				fifo_wrreq_r := '0';
				fifo_wrreq_pulse <= '0';
			elsif rising_edge (fifo_wrclk) then
				-- handle writing the fifo
				fifo_wrreq_pulse <= '0'; -- default
				if fifo_wrreq = '1' and fifo_wrreq_r = '0' then
					fifo_wrreq_pulse <= '1';
				end if;				
				fifo_wrreq_r := fifo_wrreq;
			end if;
		end process;
					
		-- FIFO read clock generation (26/28/30/32us)
    -- - this will eventually be based on 'freq' input
		process (clk_32M, reset)
			subtype count_t is integer range 0 to 26*32-1; -- 26us
			variable count : count_t;
		begin
			if reset = '1' then
				fifo_rdclk_en <= '0';
				count := 0;
			elsif rising_edge(clk_32M) then
				fifo_rdclk_en <= '0'; -- default
				if count = count_t'high then
					fifo_rdclk_en <= '1';
					count := 0;
				else
					count := count + 1;
				end if;
			end if;
		end process;

		-- FIFO read control process
		process (clk_32M, reset, mtr, fifo_wrfull_s, fifo_wrusedw_s)
			variable sync_count : std_logic_vector(2 downto 0) := (others => '0');
      variable fifo_rdena : std_logic := '0';
		begin
			if reset = '1' then
				fifo_rdreq <= '0';
				sync_count := (others => '0');
        fifo_rdena := '0';
			elsif rising_edge(clk_32M) then
			
				-- handle reading the fifo
				fifo_rdreq <= '0'; -- default
				if fifo_rdclk_en = '1' then
          -- start reading when motor on and >16 bytes in FIFO
					if mtr = '1' and (fifo_wrfull_s = '1' or fifo_wrusedw_s(7 downto 4) /= "0000") then
            fifo_rdena := '1';
          -- stop reading when motor off or empty FIFO
          elsif mtr = '0' or fifo_rdempty = '1' then
            fifo_rdena := '0';
          end if;
          fifo_q <= fifo_q_s;
          fifo_rdreq <= fifo_rdena;

  				-- sync logic, count FF on fifo_rdreq
  				if mtr = '1' then
  					if fifo_q_s /= X"FF" then
  						sync_count := (others => '0');
  					elsif sync_count /= "111" then
  						sync_count := sync_count + 1;
  					end if;
  				end if;
				
				end if;

			end if;
			-- generate sync_n output
      if mtr = '1' and sync_count > 4 then
        sync_n_s <= '0';
      else
        sync_n_s <= '1';
      end if;
		end process;

		-- stretch the fifo_rdreq signal to produce byte_n
		-- - just needs to be detected on rising edge of cpu enable
		--   so that the internal OV flag is set
		process (clk_32M, reset)
			variable count : integer range 0 to 32+16;
		begin
			if reset = '1' then
				count := 0;
				byte_n_s <= '1';
			elsif rising_edge(clk_32M) then
				if fifo_rdreq = '1' then
					count := 32+16; -- 1.5us wide
					byte_n_s <= '0';
				elsif count = 0 then
					byte_n_s <= '1';
				else
					count := count - 1;
				end if;
			end if;
		end process;

		-- assign external outputs	
		fifo_wrfull <= fifo_wrfull_s;
    fifo_wrusedw <= fifo_wrusedw_s;
    sync_n <= sync_n_s;
    byte_n <= byte_n_s or not sync_n_s;

		--
		--	Component instantiation
		--
		
		c1541_logic_inst : entity work.c1541_logic
			generic map
			(
				DEVICE_SELECT		=> C64_1541_DEVICE_SELECT(1 downto 0)
			)
			port map
			(
				clk_32M					=> clk_32M,
				reset						=> reset,

				-- serial bus
				sb_data_oe			=> sb_data_oe,
				sb_data_in			=> sb_data_in,
				sb_clk_oe				=> sb_clk_oe,
				sb_clk_in				=> sb_clk_in,
				sb_atn_oe				=> sb_atn_oe,
				sb_atn_in				=> sb_atn_in,

				-- drive-side interface				
				ds							=> ds,
				di							=> fifo_q,
				do							=> open,
				mode						=> mode,
				stp							=> stp,
				mtr							=> mtr,
				freq						=> freq,
				sync_n					=> sync_n,
				byte_n					=> byte_n,
				wps_n						=> wps_n,
				tr00_sense_n		=> tr00_sense_n,
				act							=> act
			);

		fifo_inst : entity work.c1541_fifo
			PORT map
			(
				-- written by drive mechanism
				wrclk			=> fifo_wrclk,
				data			=> fifo_data,
				wrreq			=> fifo_wrreq_pulse,
				wrfull		=> fifo_wrfull_s,
				wrusedw		=> fifo_wrusedw_s,
				aclr			=> fifo_aclr,
				
				-- read by 1541 logic block
				rdclk			=> clk_32M,
				q					=> fifo_q_s,
				rdreq			=> fifo_rdreq,
				rdempty		=> fifo_rdempty
			);

end SYN;
