library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pace_pkg.all;

entity jamma_joypad is
  port
  (
    clk     		: in std_logic;
    reset   		: in std_logic;                               

		jamma				: in from_JAMMA_t;

		joypad_rst	: in std_logic;
		joypad_rd		: in std_logic_vector(1 to 2);
		joypad_d_o	: out std_logic_vector(1 to 2)
  );
end jamma_joypad;

architecture SYN of jamma_joypad is

	signal joypad1_s			: std_logic_vector(23 downto 0) := (others => '0');
	signal joypad2_s			: std_logic_vector(23 downto 0) := (others => '0');

begin

	process (clk, reset)
		variable joypad1_r		: std_logic_vector(23 downto 0) := (others => '0');
		variable joypad2_r		: std_logic_vector(23 downto 0) := (others => '0');
		variable joypad_rst_r	: std_logic := '0';
		variable joypad_rd_r	: std_logic_vector(1 to 2) := (others => '0');
	begin
		if reset = '1' then
			joypad1_r := (others => '0');
			joypad2_r := (others => '0');
			joypad_rst_r := '0';
			joypad_rd_r := (others => '0');
			joypad_d_o <= (others => '0');
		elsif rising_edge(clk) then
			if joypad_rst_r = '1' and joypad_rst = '0' then
				-- latch joystick value on falling edge of reset
				joypad1_r := joypad1_s;
				joypad2_r := joypad2_s;
			elsif joypad_rd_r(1) = '1' and joypad_rd(1) = '0' then
				-- shift joypad data bits on falling edge of rd
				joypad1_r := '0' & joypad1_r(joypad1_r'left downto 1);
			elsif joypad_rd_r(2) = '1' and joypad_rd(2) = '0' then
				-- shift joypad data bits on falling edge of rd
				joypad2_r := '0' & joypad2_r(joypad2_r'left downto 1);
			end if;
			-- latch previous value
			joypad_rst_r := joypad_rst;
			joypad_rd_r := joypad_rd;
		end if;
		-- drive outputs
		joypad_d_o(1) <= joypad1_r(0);
		joypad_d_o(2) <= joypad2_r(0);
	end process;
	
	process (clk, reset)
	begin
		if reset = '1' then
			joypad1_s(23 downto 16) <= "00001000";			-- signature joypad1
			joypad1_s(15 downto 8) <= (others => '0');	-- ignored
			joypad1_s(7 downto 0) <= (others => '0');		-- controller 1
			--joypad2_s(23 downto 16) <= "00000100";			-- signature joypad2
			joypad2_s(23 downto 16) <= "00000000";			-- signature joypad2 (disconnected)
			joypad2_s(15 downto 8) <= (others => '0');	-- ignored
			joypad2_s(7 downto 0) <= (others => '0');		-- controller 2
		elsif rising_edge(clk) then
			-- P1
			joypad1_s(0) <= not jamma.p(1).button(1);
			joypad1_s(1) <= not jamma.p(1).button(2);
			joypad1_s(2) <= not jamma.coin(1);
			joypad1_s(3) <= not jamma.p(1).start;
			joypad1_s(4) <= not jamma.p(1).up;
			joypad1_s(5) <= not jamma.p(1).down;
			joypad1_s(6) <= not jamma.p(1).left;
			joypad1_s(7) <= not jamma.p(1).right;
		end if;
	end process;
	
end SYN;
