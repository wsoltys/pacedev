library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity sd_if is
	generic (
		sd_width 		: integer := 1		-- 1 or 4-bit data bus
	);
	port
	(
		clk						: in std_logic;
		clk_en_50MHz	: in std_logic;
		reset					: in std_logic;

		sd_clk				: out std_logic;
		sd_cmd_i			: in std_logic;
		sd_cmd_o			: out std_logic;
		sd_cmd_oe		  : out std_logic;
		sd_dat_i			: in std_logic_vector(3 downto 0);
		sd_dat_o			: out std_logic_vector(3 downto 0);
		sd_dat_oe			: out std_logic;
		
		blk						: in std_logic_vector(31 downto 0);
		rd						: in std_logic;
		
		dbg						: out std_logic_vector(31 downto 0);
		dbgsel				: in std_logic_vector(2 downto 0)

	);
end sd_if;

architecture SYN of sd_if is

	type state_type is (init, msg_wait, msg_req, msg_resp, idle);
	type exp_type is (no_resp, short_resp, short_nocrc, long_resp);
	type data_src is (send_none, send_rca, send_hcs, send_data_width, send_blk);
	subtype cmd_type is std_logic_vector(6 downto 0);
	constant dwidth_1	: std_logic_vector(1 downto 0) := "00";	-- 1-bit data bus
	constant dwidth_4	: std_logic_vector(1 downto 0) := "10";	-- 1-bit data bus
	
	constant CMD0		: std_logic_vector(5 downto 0) := "000000";	-- Reset all cards to Idle state
	constant CMD2		: std_logic_vector(5 downto 0) := "000010";	-- Ask CID number
	constant CMD3		: std_logic_vector(5 downto 0) := "000011";	-- Ask to publish a new relative address RCA
	constant CMD17	: std_logic_vector(5 downto 0) := "010001";	-- Read single block
	constant CMD7		: std_logic_vector(5 downto 0) := "000111";	-- Select/Deselect SD Card
	constant CMD13	: std_logic_vector(5 downto 0) := "001101";	-- Send status register
	constant CMD55	: std_logic_vector(5 downto 0) := "110111";	-- Application specific command
	constant ACMD6	: std_logic_vector(5 downto 0) := "000110";	-- Set data line width
	constant ACMD41	: std_logic_vector(5 downto 0) := "101001";	-- Asks the accessed card to send its operating condition 
																															-- register (OCR) content in the response on the CMD line.	
  type msg_rec_type is record
    exp			: exp_type;
    cmd			: std_logic_vector(5 downto 0);
		send		: data_src;
  end record;

	type msg_rec_arr_type is array(natural range <>) of msg_rec_type;

	signal dwidth_s				: std_logic_vector(1 downto 0);
	signal card_rca				: std_logic_vector(15 downto 0) := (others => '0');

	signal msgs : msg_rec_arr_type(0 to 9) := (
		(exp => no_resp, 		cmd => CMD0,		send => send_none),	-- Set cards to init
		(exp => short_resp,	cmd => CMD55,		send => send_none),	-- App cmd
		(exp => short_nocrc,cmd => ACMD41,	send => send_hcs),	-- Return OCR
		(exp => long_resp,	cmd => CMD2,		send => send_none),	-- Return CID
		(exp => short_resp,	cmd => CMD3,		send => send_none),	-- Select and return RCA
		(exp => short_resp,	cmd => CMD7,		send => send_rca),	-- Select card
		(exp => short_resp,	cmd => CMD13,		send => send_rca),	-- Return card status
		(exp => short_resp,	cmd => CMD55,		send => send_rca),	-- App cmd
		(exp => short_resp,	cmd => ACMD6,		send => send_data_width),	-- Set bus width
		(exp => short_resp,	cmd => CMD17,		send => send_blk)	-- Read block
	);
	
	signal msg_cnt_s : integer := 0;

	signal dbg_s					: std_logic_vector(31 downto 0);

--assign command =  (command_count==5'd0)?  {2'b01, CMD0, 32'h0, crc7, 1'b1} :
--                 ((command_count==5'd1)?  {2'b01, CMD55, RCA, 16'h0, crc7, 1'b1} :
--                 ((command_count==5'd2)?  {2'b01, ACMD41, 32'h00FF8000, crc7, 1'b1} : 
--                 ((command_count==5'd3)?  {2'b01, CMD2, 32'h0, crc7, 1'b1} : 
--                 ((command_count==5'd4)?  {2'b01, CMD3, 32'h0, crc7, 1'b1} : 
--                 ((command_count==5'd5)?  {2'b01, CMD7, RCA, 16'h0, crc7, 1'b1}  : 
--                 ((command_count==5'd6)?  {2'b01, CMD13, RCA, 16'h0, crc7, 1'b1} : 
--                 ((command_count==5'd7)?  {2'b01, CMD17, blocknum, crc7, 1'b1}   : 
--                 ((command_count==5'd9)?  {2'b01, ACMD6, 30'h0, mode, 1'b0, crc7, 1'b1} : 
--                 48'hz))))))));
	
	signal cmd_s				: std_logic_vector(37 downto 0);
	signal data_s				: std_logic_vector(31 downto 0);
	signal exp_s				: std_logic_vector(1 downto 0);
	signal poll_s				: std_logic;
	signal expect_resp	: std_logic_vector(1 downto 0);
	signal resp_s				: std_logic_vector(125 downto 0);
	signal resp_err			: std_logic;
	signal cmd_busy			: std_logic;
		
	signal msg					: msg_rec_type;
	signal state_s			: state_type;

	signal card_ocr			: std_logic_vector(31 downto 0);
	signal card_status	: std_logic_vector(31 downto 0);
	signal card_id			: std_logic_vector(119 downto 0);
	
begin
	dbg_s <= card_ocr when dbgsel = "000" else
		"00000000" & card_id(119 downto 96) when dbgsel = "001" else
		card_id(95 downto 64) when dbgsel = "010" else
		card_id(63 downto 32) when dbgsel = "011" else
		card_id(31 downto 0) when dbgsel = "100" else
		X"0000" & card_rca when dbgsel = "101" else
		card_status;

	dwidth_s <= dwidth_4 when sd_width = 4 else dwidth_1;
		
	sd_busif_1 : entity work.sd_busif	
		generic map(sd_width => sd_width)
		port map
		(
			clk						=> clk,
			clk_en				=> clk_en_50MHz,
			reset					=> reset,

			sd_clk				=> sd_clk,
			sd_cmd_i			=> sd_cmd_i,
			sd_cmd_o			=> sd_cmd_o,
			sd_cmd_oe			=> sd_cmd_oe,
			sd_dat_i			=> sd_dat_i,
			sd_dat_o			=> sd_dat_o,
			sd_dat_oe			=> sd_dat_oe,

			expect_resp		=> exp_s,
			cmd						=> cmd_s,
			send_cmd			=> poll_s,
			resp					=> resp_s,
			resp_err			=> resp_err,
			
			busy					=> cmd_busy
		);

	msg <= msgs(msg_cnt_s);
	exp_s <= "00" when msg.exp = no_resp else
					 "01" when msg.exp = short_resp else
					 "11" when msg.exp = short_nocrc else
					 "10";
	data_s <= card_rca & X"0000" when msg.send = send_rca else
						X"00FF8000" when msg.send = send_hcs else
						X"0000000" & "00" & dwidth_s when msg.send = send_data_width else
						blk when msg.send = send_blk else
						(others => '0');
	cmd_s <= msg.cmd & data_s;
	poll_s <= '1' when state_s = msg_req else '0';

	PROC_MSG:process(clk, clk_en_50MHz, reset)
		variable state : state_type;
		variable cnt : integer range 0 to 128;
		subtype msg_cnt_t is integer range msgs'range;
		variable msg_cnt : msg_cnt_t;
	begin
		if reset = '1' then
			state := init;
			msg_cnt := 0;
			cnt := 128;
			card_ocr <= (others => '0');
			card_rca <= (others => '0');
			card_id <= (others => '0');
			card_status <= (others => '0');
		elsif clk_en_50MHz = '1' and rising_edge(clk) then
			if msg_cnt = 2 and state = msg_resp and cmd_busy = '0' and resp_err = '0' then
				card_ocr <= resp_s(31 downto 0);
			end if;
			
			if msg_cnt = 3 and state = msg_resp and cmd_busy = '0' and resp_err = '0' then
				card_id <= resp_s(119 downto 0);
			end if;

			if msg_cnt = 4 and state = msg_resp and cmd_busy = '0' and resp_err = '0' then
				card_rca <= resp_s(31 downto 16);
			end if;
			
			if (msg_cnt >= 5) and state = msg_resp and cmd_busy = '0' and resp_err = '0' then
				card_status <= resp_s(31 downto 0);
			end if;
		
			case state is
			when init =>
				if cmd_busy = '0' then state := msg_wait; end if;
				msg_cnt := 0;
				cnt := 128 - 80;
			
			when msg_wait =>
				if cnt = 128 then 
					state := msg_req;
					cnt := 128 - 4;
				else 
					cnt := cnt + 1;
				end if;
				
			when msg_req =>
				if cnt = 128 then 
					state := msg_resp;
				else 
					cnt := cnt + 1;
				end if;
			
			when msg_resp =>
				if cmd_busy = '0' then
					if resp_err = '0' then 
						if msg_cnt < msgs'high then
					
							-- Repeat read OCR until card is finished power-up sequence
							if msg_cnt = 3 and card_ocr(31) = '0' then
								msg_cnt := 1;
							else
								msg_cnt := msg_cnt + 1;
							end if;
					
							if msg_cnt = msgs'high then
								state := idle;
							else
								state := msg_wait;
								cnt := 128 - 80;
							end if;
						else
							state := idle;
						end if;
					end if;
				end if;
			
			when idle =>
				if rd = '1' then state := msg_wait; end if;
				cnt := 128 - 4;
			end case;

			dbg <= dbg_s;
		end if;
		
		msg_cnt_s <= msg_cnt;
		state_s <= state;
	end process PROC_MSG;

end SYN;
