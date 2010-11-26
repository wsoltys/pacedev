--
-- SD card command serial interface
-- 
-- Copyright 2008 Chris Nott (chris@pacedev.net)
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity sd_cmdif is
	port
	(
		clk						: in std_logic;
		reset					: in std_logic;

		-- SD card bus interface
		sd_cmd_i		  : in std_logic;
		sd_cmd_o		  : out std_logic;
		sd_cmd_oe		  : out std_logic;

		-- Cooked SD card command serial interface
		send_cmd			: in std_logic;
		busy					: out std_logic;
		expect_resp		: in std_logic_vector(1 downto 0);			-- Expect "00" (no resp), "01" (R1, R6), "10" (R2), "11" (R3) 
		cmd_c					: in std_logic;
		cmd_ce				: out std_logic;
		resp_c				: out std_logic;
		resp_ce				: out std_logic;
		resp_err			: out std_logic		
	);
end sd_cmdif;

architecture SYN of sd_cmdif is
	type cstate_type is (idle, cmdst, cmdtx, cmdbody, cmdcrc, cmden,
		respwait, resptx, respbody, respcrc, respcheck, respen);

	constant cmd_len		: integer := 38;		-- Command length (bits)
	constant crc_len		: integer := 7;			-- CRC length (bits)
	constant resp_len		: integer := 38;		-- Response length (bits)
	constant resp2_len	: integer := 126;		-- Response length (bits) for R2
	constant resp_to		: integer := 100;		-- Response timeout (clocks)
	constant cnt_max		: integer := 256;		-- Max count value

	signal cstate				: cstate_type;
	signal cstate_next	: cstate_type;
	signal sd_cmd_r			: std_logic;
	signal sd_cmd_oe_r	: std_logic;
	
	signal c_nx					: std_logic;		-- sd_cmd_r next value
	signal c_oe_nx			: std_logic;		-- sd_cmd_oe_r next value
	signal c_ld					: integer range 0 to cnt_max;			-- cmd bit counter load value
	signal c_cnt				: integer range 0 to cnt_max;
	signal c_done				: boolean;			-- cmd done
	signal cc_in				: std_logic;		-- cmd shifter input
	signal scc_top			: std_logic;		-- cmd checksum shifter top bit
	signal scc_match		: std_logic;		-- cmd checksum matches received one
	signal resp_err_s		: std_logic;		
	signal busy_nx			: std_logic;
begin
	sd_cmd_o <= sd_cmd_r; -- when sd_cmd_oe_r = '1' else 'Z';
	sd_cmd_oe <= sd_cmd_oe_r;

	resp_c <= sd_cmd_i; -- when sd_cmd_oe_r = '0' else 'X';
	resp_ce <= '1' when cstate = respbody else '0';

	-- Bit/clock counter is done when it reaches cnt_max
	BLK_C_DONE : block
	  signal c_cnt_s : std_logic_vector(8 downto 0);
	begin
	--c_done <= std_logic_vector(to_unsigned(c_cnt, 9))(8) = '1'; -- = cnt_max;
	  c_cnt_s <= std_logic_vector(to_unsigned(c_cnt, 9));
	  c_done <= c_cnt_s(8) = '1';
	end block BLK_C_DONE;

	-- Command channel combinatorial signal process
	cmd_state_machine : process(cstate, send_cmd, cmd_c, scc_top, sd_cmd_i, 
			c_done, expect_resp, scc_match)
		variable cstate_n : cstate_type;
	begin
		cc_in			<= '0';
		c_nx			<= '1';
		c_oe_nx		<= '0';
		busy_nx		<= '1';
		resp_err_s <= '0';
		c_ld			<= cnt_max;
		cmd_ce		<= '0';
		
		-- State transitions
		cstate_n := cstate;
		case cstate is
		when idle 		=>	if send_cmd = '1' then cstate_n := cmdst; end if;
		when cmdst	 	=>	cstate_n := cmdtx;
		when cmdtx	 	=>	cstate_n := cmdbody;
		when cmdbody 	=>	if c_done then cstate_n := cmdcrc; end if;
		when cmdcrc		=>	if c_done then cstate_n := cmden; end if;
		when cmden		=>	
			if expect_resp = "00" then cstate_n := idle; 
			else cstate_n := respwait; end if;
			
		when respwait =>	
			if c_done then 
				resp_err_s <= '1';
				cstate_n := idle; 
			elsif sd_cmd_i = '0' then 
				cstate_n := resptx;
			end if;

		-- Timeout ?
		when resptx		=>	
			if sd_cmd_i = '0' then cstate_n := respbody;
			else
				resp_err_s <= '1';
				cstate_n := idle;
			end if;
			
		when respbody	=>	
			if c_done then cstate_n := respcrc; end if;
			
		when respcrc =>
			if c_done then
				if expect_resp /= "11" and expect_resp /= "10" then 
					cstate_n := respcheck;
				else
					cstate_n := idle;
				end if;
			end if;
			
		when respcheck	=>
			if scc_match = '0' then 
				resp_err_s <= '1';
				cstate_n := idle;
			else
				cstate_n := respen; 
			end if;
			
		when respen		=>	cstate_n := idle;
		end case;

		-- Signals changes related to next state
		case cstate_n is
		when idle 		=>
			busy_nx	<= '0';
		
		when cmdst	 	=> 
			c_oe_nx	<= '1';
			cc_in		<= '0';
			c_nx		<= '0';
			
		when cmdtx	 	=> 
			c_oe_nx	<= '1';
			cc_in		<= '1';
			c_nx		<= '1';

		when cmdbody 	=>
			c_ld		<= cnt_max - cmd_len + 1;
			c_oe_nx	<= '1';
			c_nx		<= cmd_c;
			cc_in		<= cmd_c;
			cmd_ce		<= '1';
			
		when cmdcrc		=>
			c_ld		<= cnt_max - crc_len + 1;
			c_oe_nx	<= '1';
			c_nx		<= scc_top;
			
		when cmden		=>
			c_nx		<= '1';
			c_oe_nx	<= '1';
		
		when respwait =>
			c_ld	<= cnt_max - resp_to + 1;
		
		when resptx		=>
		
		when respbody	=>
			if expect_resp = "10" then
				c_ld	<= cnt_max - resp2_len + 1;
			else
				c_ld		<= cnt_max - resp_len + 1;
			end if;
			cc_in		<= sd_cmd_i;
			
		when respcrc =>
			cc_in		<= sd_cmd_i;
			c_ld		<= cnt_max - crc_len + 1;
			
		when respcheck =>
			cc_in		<= sd_cmd_i;		
		
		when respen =>		
		end case;

		cstate_next <= cstate_n;
	end process cmd_state_machine;

	-- Synchronous logic
	cmd_regs : process(clk, reset)
		variable cc					: std_logic_vector(6 downto 0);			-- Cmd checksum calculation
		variable scc				: std_logic_vector(6 downto 0);			-- Cmd checksum shifter
	begin
		-- Reset
		if reset = '1' then
			cc := (others => '0');
			scc := (others => '0');
			c_cnt <= cnt_max;
			scc_match <= '0';
			resp_err	<= '0';
			cstate <= idle;

		-- Synchronous operation
		elsif rising_edge(clk) then
			cstate			<= cstate_next;
			sd_cmd_r		<= c_nx;
			sd_cmd_oe_r	<= c_oe_nx;
			busy				<= busy_nx;

			-- Saved crc shifter
			if cstate = cmdbody then
				scc := cc;
			end if;
			scc := scc(scc'high-1 downto scc'low) & cc_in;	

			-- Command crc calculation
			if cstate = idle or cstate = respwait then
				cc := (others => '0'); 
			else
				-- Command CRC generator polynomial x^7 + x^3 + 1
				if cstate /= respcrc and cstate /= respcheck then
					cc := cc(5) & cc(4) & cc(3) & (cc(2) xor cc(6) xor cc_in)
											& cc(1) & cc(0) & (cc(6) xor cc_in);
				end if;
			end if;

			-- Command bit/timeout counter				
			if cstate_next /= resptx and c_cnt < cnt_max then
				c_cnt <= c_cnt + 1; 
			else
				c_cnt <= c_ld;
			end if;

			-- Check CRC
			if scc = cc then scc_match <= '1'; else scc_match <= '0'; end if;

			-- Error signal (set-reset)
			if cstate = cmdst then
				resp_err <= '0';
			elsif resp_err_s = '1' then
				resp_err <= '1';
			end if;		
		end if;

		scc_top <= scc(scc'high);
	end process cmd_regs;
end SYN;
