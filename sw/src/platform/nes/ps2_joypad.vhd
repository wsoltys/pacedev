library ieee;
use ieee.std_logic_1164.all;

library work;
use work.kbd_pkg.all;

entity ps2_joypad is
  port
  (
    clk     		: in std_logic;
		clk_1M_en		: in std_logic;
    reset   		: in std_logic;                               

    ps2clk  		: inout std_logic;                               
    ps2data 		: inout std_logic;                               

		joypad_rst	: in std_logic;
		joypad_rd		: in std_logic_vector(1 to 2);
		joypad_d_o	: out std_logic_vector(1 to 2)
  );
end ps2_joypad;

architecture SYN of ps2_joypad is

  signal reset_n        : std_logic;
  signal ps2_reset      : std_logic;
  signal ps2_press      : std_logic;
  signal ps2_release    : std_logic;
  signal ps2_scancode   : std_logic_vector(7 downto 0);
    
	signal joypad1_s			: std_logic_vector(23 downto 0) := (others => '0');
	signal joypad2_s			: std_logic_vector(23 downto 0) := (others => '0');

begin

  reset_n <= not reset;

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
			if ps2_reset = '1' then
				joypad1_s(7 downto 0) <= (others => '0');
				joypad2_s(7 downto 0) <= (others => '0');
			elsif (ps2_press or ps2_release) = '1' then
				case ps2_scancode is
					when SCANCODE_LALT =>
          	joypad1_s(0) <= ps2_press;
          when SCANCODE_LCTRL =>
            joypad1_s(1) <= ps2_press;
          when SCANCODE_5 | SCANCODE_TAB =>
            joypad1_s(2) <= ps2_press;
          when SCANCODE_1 | SCANCODE_ENTER =>
            joypad1_s(3) <= ps2_press;
          when SCANCODE_UP =>
            joypad1_s(4) <= ps2_press;
          when SCANCODE_DOWN =>
            joypad1_s(5) <= ps2_press;
          when SCANCODE_LEFT =>
            joypad1_s(6) <= ps2_press;
          when SCANCODE_RIGHT =>
            joypad1_s(7) <= ps2_press;
					when others =>
						null;
				end case;
			end if;
		end if;
	end process;
	
  ps2kbd_inst : entity work.ps2kbd                                        
    port map
    (
      clk      => clk,                                     
      rst_n    => reset_n,
      tick1us  => clk_1M_en,
      ps2_clk  => ps2clk,
      ps2_data => ps2data,
			
      reset    => ps2_reset,
      press    => ps2_press,
      release  => ps2_release,
      scancode => ps2_scancode
    );

end SYN;
