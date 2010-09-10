library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity sd_busif is
--	generic (
--		data_width		: integer;
--	)
	port
	(
		clk						: in std_logic;
		clk_en				: in std_logic;
		reset					: in std_logic;

		sd_clk				: out std_logic;
		sd_cmd				: inout std_logic;
		sd_dat				: inout std_logic_vector(3 downto 0);

		send_cmd			: in std_logic;
		busy					: out std_logic;
		expect_resp		: in std_logic_vector(1 downto 0);			-- Expect "00" (no resp), "01" (R1, R6), "10" (R2), "11" (R3) 
		cmd						: in std_logic_vector(37 downto 0);
		resp					: out std_logic_vector(125 downto 0);
		resp_err			: out std_logic
	);
end sd_busif;

architecture SYN of sd_busif is
	constant short_resp_len		: integer := 38;		-- Short response length (bits)

	signal sc_top			: std_logic;					-- cmd top bit
	signal sc_shift		: std_logic;					-- cmd shift signal
	signal sr_in			: std_logic;					-- response input bit
	signal sr_shift		: std_logic;					-- response shift signal
begin

	sd_clk <= clk;

	sd_cmdif_1 : entity work.sd_cmdif	port map
	(
		clk						=> clk,
		reset					=> reset,

		sd_cmd				=> sd_cmd,

		send_cmd			=> send_cmd,
		expect_resp		=> expect_resp,
		cmd_c					=> sc_top,
		cmd_ce				=> sc_shift,
		resp_c				=> sr_in,
		resp_ce				=> sr_shift,
		resp_err			=> resp_err,
		
		busy					=> busy
	);

	-- Synchronous logic
	process(clk, clk_en, reset)
		variable sc						: std_logic_vector(37 downto 0);		-- cmd shifter
		variable sr						: std_logic_vector(125 downto 0);
		variable send_cmd_0		: std_logic;
	begin
			-- Reset
		if reset = '1' then
			sc := (others => '0');
			sr := (others => '0');
			send_cmd_0 := '0';

		elsif clk_en = '1' and rising_edge(clk) then
			-- Command shifter latch
			if send_cmd = '1' and send_cmd_0 = '0' then
				sc := cmd;
			-- Shift
			elsif sc_shift = '1' then
				sc := sc(sc'high-1 downto sc'low) & '0';
			end if;

			-- Response shifter
			if sr_shift = '1' then
				if expect_resp = "10" then
					sr := sr(sr'high-1 downto sr'high-short_resp_len-1) & sr_in & "00" & X"000000000000000000000";
				else
					sr := sr(sr'high-1 downto sr'low) & sr_in;
				end if;
			end if;

			send_cmd_0 := send_cmd;
		end if;

		sc_top	<= sc(sc'high);
		resp <= sr;
	end process;
end SYN;
