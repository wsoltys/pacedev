--
-- SD card data serial interface
-- 
-- Copyright 2008 Chris Nott (chris@pacedev.net)
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity sd_datif is
	generic 
	(
		sd_width		: integer;		-- Width of SD bus
		dat_width		: integer			-- Width of data in/out bus
	);
	port
	(
		clk						: in std_logic;
		reset					: in std_logic;

		-- SD card bus interface
		sd_dat_i			: in std_logic_vector(3 downto 0);
		sd_dat_o			: out std_logic_vector(3 downto 0);
		sd_dat_oe			: out std_logic;

		-- Cooked SD card data serial interface
		read					: in std_logic;
		write					: in std_logic;
		blocksize			: in std_logic_vector(1 downto 0);
		busy					: out std_logic;
		dati					: out std_logic_vector(dat_width-1 downto 0);
		dati_ce				: out std_logic;
		dati_err			: out std_logic;
		datout				: in std_logic_vector(dat_width-1 downto 0);
		datout_ce			: out std_logic
	);
end sd_datif;

architecture SYN of sd_datif is
	type dstate_type is (idle, datrdst, datrdbody, datrdcrc, datrden, datcheck);

	constant crc_len		: integer := 16;		-- CRC length (bits)
	constant cnt_max		: integer := 4096;	-- Max count value

	signal dstate				: dstate_type;
	signal dstate_next	: dstate_type;
	signal sd_dat_r			: std_logic_vector(3 downto 0);
	signal sd_dat_oe_r	: std_logic;

	signal chunksize		: integer := 512;	-- Expected size of data chunk

	signal d_nx					: std_logic_vector(3 downto 0);		-- sd_dat_r next value
	signal d_oe_nx			: std_logic;		-- sd_dat_oe_r next value
	signal d_ld					: integer range 0 to cnt_max;			-- data bit counter load value
	signal d_cnt				: integer range 0 to cnt_max;
	signal d_done				: boolean;			-- data done
	signal dc_in				: std_logic_vector(3 downto 0);		-- data shifter input
	signal sdc_match		: std_logic;		-- data checksum matches received one
	signal sdc_eof_nx		: std_logic;
	signal sdc_eof			: std_logic;

	signal dati_err_s		: std_logic;
	signal busy_nx			: std_logic;

begin

	sd_dat_o <= sd_dat_r; -- when sd_dat_oe_r = '1' else (others => 'Z');
	sd_dat_oe <= sd_dat_oe_r;

	-- Bit/clock counter is done when it reaches cnt_max
	d_done <= d_cnt >= cnt_max;

	-- Data channel combinatorial signal process
	dat_state_machine : process(dstate, sd_dat_i)
		variable dstate_n : dstate_type;
	begin
		dc_in			<= sd_dat_i;
		d_nx			<= (others => '1');
		d_oe_nx		<= '0';
		busy_nx		<= '1';
		dati_err_s <= '0';
		d_ld			<= cnt_max;

		-- State transitions
		dstate_n := dstate;
		case dstate is
		when idle =>
			if read = '1' then
				dstate_n := datrdst;
			end if;
		
		when datrdst =>
			if sd_dat_i(0) = '0' then 
				dstate_n := datrdbody;
			end if;
			
		when datrdbody =>
			if d_done then
				dstate_n := datrdcrc;
			end if;		

		when datrdcrc =>
			if d_done then
				dstate_n := idle;
			end if;

		when datrden =>
			dstate_n := datcheck;
		
		when datcheck	=>
			if sdc_match = '0' or sdc_eof = '0' then 
				dati_err_s <= '1';
			end if;
			dstate_n := idle;

		end case;
		
		-- Signals changes related to next state
		case dstate_n is
		when idle =>
			busy_nx	<= '0';
		
		when datrdst =>
			dc_in		<= sd_dat_i;
			
		when datrdbody =>
			d_ld		<= cnt_max - chunksize + 1;
			dc_in		<= sd_dat_i;

		when datrdcrc =>
			d_ld		<= cnt_max - crc_len + 1;
			dc_in		<= sd_dat_i;
		
		when datrden =>
			dc_in		<= sd_dat_i;
			sdc_eof_nx <= sd_dat_i(0);
			--sdc_eof_nx <= sd_dat_i(0) and sd_dat_i(1) and sd_dat_i(2) and sd_dat_i(3);	-- 4-bit data

		when datcheck =>

		end case;

		dstate_next <= dstate_n;
	end process dat_state_machine;

	-- Synchronous logic
	data_regs : process(clk, reset)
		subtype crc_type is std_logic_vector(15 downto 0);
		type crc_arr_t is array(0 to 3) of crc_type;
		variable dc					: crc_arr_t;		-- Data checksum calculation
		variable sdc				: crc_arr_t;		-- Data checksum shifter
		variable dati_s			: std_logic_vector(dat_width-1 downto 0);
		subtype dati_cnt_t is integer range 0 to dat_width/sd_width-1;
		variable dati_cnt		: dati_cnt_t;
	begin
		-- Reset
		if reset = '1' then
			for i in 0 to 3 loop
				dc(i) := (others => '0');
				sdc(i) := (others => '0');
			end loop;
			--d_nx				<= (others => '1');
			--d_oe_nx			<= '0';
			d_cnt				<= d_ld;
			sdc_match		<= '0';
			dati_ce			<= '0';
			dati_cnt		:= 0;
			dstate			<= idle;

		-- Synchronous operation
		elsif rising_edge(clk) then
			dstate			<= dstate_next;
			sd_dat_r		<= d_nx;
			sd_dat_oe_r	<= d_oe_nx;
			busy				<= busy_nx;

			-- Generate CRC logic for each data line
			for i in 0 to 3 loop
				-- Saved crc shifter
				if dstate = datrdbody then
					sdc(i) := dc(i);
				end if;
				sdc(i) := sdc(i)(sdc(i)'high-1 downto sdc(i)'low) & dc_in(i);	

				-- Data crc calculation
				if dstate = idle then
					dc(i) := (others => '0'); 
				else
					-- Data CRC generator polynomial x^16 + x^12 + x^5 + 1
					if dstate /= datrdcrc then
						dc(i) := dc(i)(14) & dc(i)(13) & dc(i)(12) & (dc(i)(11) xor dc(i)(15) xor dc_in(i))
								& dc(i)(10)	& dc(i)(9) & dc(i)(8) & dc(i)(7) & dc(i)(6) & (dc(i)(4) xor dc(i)(15) xor dc_in(i))
								& dc(i)(4) & dc(i)(3) & dc(i)(2) & dc(i)(1) & dc(i)(0) & (dc(i)(15) xor dc_in(i));
					end if;
				end if;
			end loop;

			-- Data bit/timeout counter				
			if d_cnt < cnt_max then
				d_cnt <= d_cnt + 1; 
			else
				d_cnt <= d_ld;
			end if;

			-- Check CRC
			if sdc = dc then sdc_match <= '1'; else sdc_match <= '0'; end if;

			-- Error signal (set-reset)
			if dstate = datrdst then
				dati_err <= '0';
			elsif dati_err_s = '1' then
				dati_err <= '1';
			end if;		

			-- Data input shifter
			dati_ce <= '0';
			if sd_dat_oe_r = '0' then
				dati_s := dati_s(dat_width-sd_width-1 downto 0) & sd_dat_i(sd_width-1 downto 0);
				if dati_cnt < dati_cnt_t'high then
					dati_cnt := dati_cnt + 1;
				else 
					dati_cnt := 0;
				end if;
				if dati_cnt = 0 then
					dati_ce <= '1';
				end if;
			end if;
			dati <= dati_s;

		end if;
	end process data_regs;
end SYN;

