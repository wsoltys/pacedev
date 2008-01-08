package ext is
	function snd_word(v : integer) return integer;
	attribute foreign of snd_word : function is "VHPIDIRECT snd_word";
end ext;

package body ext is
	function snd_word(v : integer) return integer is
	begin
		assert false severity failure;
	end snd_word;
end ext;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ext.all;

entity nes_snd_tb is
	port (
		fail:				out  boolean
	);
end nes_snd_tb;

architecture SYN of nes_snd_tb is
	type char_file is file of character;

	type io_rec is record
		rd		: std_logic;
		wr		: std_logic;
		a			: std_logic_vector(7 downto 0);
		d_in	: std_logic_vector(7 downto 0);
	end record;

	type io_arr is array(natural range <>) of io_rec;

	signal clk				: std_logic	:= '0';
	signal reset			: std_logic	:= '1';
	signal clk358_en	: std_logic := '0';		-- Expects 21.47727 MHz / 6 clock enable pulse
	signal clk179_en	: std_logic := '0';		-- Expects 21.47727 MHz / 12 (1.79MHz CPU clock) enable pulse
	
	-- CPU I/F
	signal ns_a				: std_logic_vector(4 downto 0);
	signal ns_d_in		: std_logic_vector(7 downto 0);
	signal ns_d_out		: std_logic_vector(7 downto 0);
	signal ns_rd			: std_logic;
	signal ns_wr			: std_logic;
	signal ns_irq			: std_logic;

	-- Sound data
	signal ns_snd1		: std_logic_vector(15 downto 0);
	signal ns_snd2		: std_logic_vector(15 downto 0);

	signal sim_done		: boolean := false;
begin
	snd : entity work.nes_snd port map (clk => clk, clk358_en => clk358_en, clk179_en => clk179_en, reset => reset, 
	-- CPU I/F
	a						=> ns_a,
	d_in				=> ns_d_in,
	d_out				=> ns_d_out,
	rd					=> ns_rd,
	wr					=> ns_wr,
	irq					=> ns_irq,

	-- Sound data
	snd1				=> ns_snd1,
	snd2				=> ns_snd2
	);

	-- Generate CLK and reset
	clk <= not clk after 23280 ps when not sim_done else '0';	-- 21.47727 MHz
	reset <= '0' after 100 ns;

	-- Generate clk_en every 6 clocks
	cen : process(clk)
		variable cnt6 : integer := 0;
		variable cnt12 : integer := 0;
	begin
		--if sim_done then wait; end if;
		if rising_edge(clk) then
			clk358_en <= '0' after 1 ns;
			clk179_en <= '0' after 1 ns;
			cnt6 := cnt6 + 1;
			cnt12 := cnt12 + 1;
			if cnt6 = 6 then
				cnt6 := 0;
				clk358_en <= '1';
			end if;
			if cnt12 = 12 then
				cnt12 := 0;
				clk179_en <= '1';
			end if;
		end if;
	end process cen;

	sndout : process
		constant sample_rate : integer := 44100;
		file my_file : char_file;
		variable r : integer;
	begin
		file_open(my_file, "out.raw", write_mode);
		while not sim_done loop
			wait for 1000000000 ns / sample_rate;
			--r := snd_word(to_integer(unsigned(ns_snd2)));
			r := to_integer(unsigned(ns_snd1));
			write(my_file, character'val(r mod 256));
			write(my_file, character'val(r / 256));
		end loop;
		file_close(my_file);
		wait;
	end process;

	tb : process
		constant io : io_arr := (
--			(rd => '0', wr => '1', a => X"15", d_in => X"04"),
--			(rd => '0', wr => '1', a => X"08", d_in => X"C0"),
--			(rd => '0', wr => '1', a => X"0A", d_in => X"20"),
--			(rd => '0', wr => '1', a => X"0B", d_in => X"09"),
--			(rd => '0', wr => '1', a => X"08", d_in => X"40")

			(rd => '0', wr => '1', a => X"15", d_in => X"01"),
			(rd => '0', wr => '1', a => X"00", d_in => X"1F"),
			(rd => '0', wr => '1', a => X"02", d_in => X"20"),
			(rd => '0', wr => '1', a => X"03", d_in => X"21")
		);
	begin
		ns_a <= (others => '0');
		ns_d_in <= (others => '0');
		ns_rd <= '0';
		ns_wr <= '0';

		for i in io'range loop
			wait until rising_edge(clk179_en);
			wait until rising_edge(clk); wait until falling_edge(clk);
			wait until rising_edge(clk); wait until falling_edge(clk);
			-- apu.write_register( 0x4015, 0x04 );
			ns_a <= io(i).a(ns_a'range) after 1 ns;
			ns_d_in <= io(i).d_in after 1 ns;
			ns_rd <= io(i).rd after 1 ns;
			ns_wr <= io(i).wr after 1 ns;
		end loop;

		wait until rising_edge(clk179_en);
		wait until rising_edge(clk); wait until falling_edge(clk);
		wait until rising_edge(clk); wait until falling_edge(clk);
		ns_rd <= '0' after 1 ns;
		ns_wr <= '0' after 1 ns;

		wait for 1000 ms;

		sim_done <= true;
		wait;
	end process;
end SYN;
