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
	generic (
		data_width		: integer;
	)
	port
	(
		clk						: in std_logic;
		reset					: in std_logic;

		-- SD card bus interface
		sd_dat				: inout std_logic_vector(3 downto 0);

		-- Cooked SD card data serial interface
		read					: in std_logic;
		write					: in std_logic;
		blocksize			: in std_logic_vector(1 downto 0);
		busy					: out std_logic;
		datin_c				: in std_logic;
		datout_c			: in std_logic;
		dat_ce				: out std_logic;
		dat_err				: out std_logic		
	);
end sd_datif;

architecture SYN of sd_datif is
	type dstate_type is (idle, datrdst, datrdbody, datrdcrc);

	constant crc_len		: integer := 16;		-- CRC length (bits)
	constant cnt_max		: integer := 4096;	-- Max count value

	signal dstate				: state_type;
	signal dstate_next	: state_type;
	signal sd_dat_r			: std_logic_vector(3 downto 0);
	signal sd_dat_oe_r	: std_logic;

	signal chunksize		: integer := 4096;	-- Expected size of data chunk

	signal d_nx					: std_logic_vector(3 downto 0);		-- sd_dat_r next value
	signal d_oe_nx			: std_logic;		-- sd_dat_oe_r next value
	signal c_ld					: integer range 0 to cnt_max;			-- data bit counter load value
	signal c_cnt				: integer range 0 to cnt_max;
	signal c_done				: boolean;			-- cmd done
	signal dc_in				: std_logic;		-- cmd shifter input
	signal sdc_match		: std_logic;		-- data checksum matches received one
begin

	sd_dat <= sd_dat_r when sd_dat_oe_r = '1' else (others => 'Z');

	-- Bit/clock counter is done when it reaches cnt_max
	c_done <= c_cnt >= cnt_max;

	-- Data channel combinatorial signal process
	dat_state_machine : process(dstate, sd_dat)
		variable dstate_n : dstate_type;
	begin
		-- State transitions
		dstate_n := dstate;
		case dstate is
		when idle =>
			if read then
				dstate_n := datrdst;
			end if;
		
		when datrdst =>
			if sd_dat = '0' then 
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
			if sdc_match = '0' or sdc_eof then 
				data_err_s <= '1';
			end if;
			dstate_n := idle;

		end case;
		
		-- Signals changes related to next state
		case dstate_n is
		when idle =>
			busy_nx	<= '0';
		
		when datrdst =>
			dc_in		<= sd_dat;
			
		when datrdbody =>
			c_ld		<= cnt_max - chunksize + 1;
			dc_in		<= sd_dat;

		when datrdcrc =>
			c_ld		<= cnt_max - crc_len + 1;
			dc_in		<= sd_dat;
		
		when datarden =>
			dc_in		<= sd_dat;
			sdc_eof_nx <= sd_dat(0);
			--sdc_eof_nx <= sd_dat(0) and sd_dat(1) and sd_dat(2) and sd_dat(3);	-- 4-bit data

		when datacheck =>

		end case;

		dstate_next <= dstate_n;
	end process dat_state_machine;

	-- Synchronous logic
	data_regs : process(clk, reset)
		subtype crc_type is std_logic_vector(15 downto 0);
		variable dc					: array (0 to 3) of crc_type;		-- Data checksum calculation
		variable sdc				: array (0 to 3) of crc_type;		-- Data checksum shifter
	begin
		-- Reset
		if reset = '1' then
			for i in 0 to 3 loop
				dc(i) := (others => '0');
				sdc(i) := (others => '0');
			end loop;
			d_nx			<= (others => '1');
			d_oe_nx		<= '0';
			c_cnt <= c_ld;
			sdc_match <= '0';
			dstate <= idle;

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
					if dstate /= datarxcrc then
						dc(i) := dc(i)(14) & dc(i)(13) & dc(i)(12) & (dc(i)(11) xor dc(i)(15) xor dc_in(i))
								& dc(i)(10)	& dc(i)(9) & dc(i)(8) & dc(i)(7) & dc(i)(6) & (dc(i)(4) xor dc(i)(15) xor dc_in(i))
								& dc(i)(4) & dc(i)(3) & dc(i)(2) & dc(i)(1) & dc(i)(0) & (dc(i)(15) xor dc_in(i));
					end if;
				end if;
			end loop;

			-- Data bit/timeout counter				
			if cstate_next /= resptx and c_cnt < cnt_max then
				c_cnt <= c_cnt + 1; 
			else
				c_cnt <= c_ld;
			end if;

			-- Check CRC
			if sdc = dc then sdc_match <= '1'; else sdc_match <= '0'; end if;

		end if;
	end process data_regs;
end SYN;

