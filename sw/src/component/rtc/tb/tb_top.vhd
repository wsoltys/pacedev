library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_top is
end tb_top;

architecture rtl of tb_top is

	constant	tCYC	:	time := 40 ns;

	signal	clk			:	std_logic := '0';
	signal	reset		:	std_logic := '1';

	signal di				: std_logic := '0';
	signal clk_s		: std_logic := '0';
	signal stb			: std_logic := '0';
	signal cs				: std_logic := '1';

	signal tp				: std_logic;

	--signal din_r		: std_logic_vector(51 downto 0) := (others => '0');

begin

	reset <= '0' after tCYC*2;
	clk <= not clk after tCYC/2;

	process
		variable din_r 		: std_logic_vector(51 downto 0) := (others => '0');
	begin
		wait until reset = '0';
    LP_OUTER : for j in 4 to 7 loop
  		din_r(51 downto 48) := std_logic_vector(to_unsigned(j,4));
  		LP_INNER : for i in 1 to 4 loop
  			di <= din_r(48);
  			clk_s <= '0';
  			wait until rising_edge(clk);
  			wait until rising_edge(clk);
  			clk_s <= '1' after 2 ns;
  			wait until falling_edge(clk);
  			wait until falling_edge(clk);
  			din_r := '0' & din_r(din_r'left downto 1);
  		end loop LP_INNER;
  		stb <= '1';
  		wait until rising_edge(clk);
  		stb <= '0' after 2 ns;
      wait for 40 ms;
    end loop LP_OUTER;

  		din_r(51 downto 48) := std_logic_vector(to_unsigned(8,4));
  		for i in 1 to 4 loop
  			di <= din_r(48);
  			clk_s <= '0';
  			wait until rising_edge(clk);
  			wait until rising_edge(clk);
  			clk_s <= '1' after 2 ns;
  			wait until falling_edge(clk);
  			wait until falling_edge(clk);
  			din_r := '0' & din_r(din_r'left downto 1);
  		end loop;
  		stb <= '1';
  		wait until rising_edge(clk);
  		stb <= '0' after 2 ns;

	end process;

  process
    variable debug_l    : line;

    variable t_start    : time;
    variable t_end      : time;
    variable freq       : natural;

  begin
    t_start := now;
    wait until rising_edge(tp);
    t_end := (now - t_start);
    freq := 1000 ms / t_end;

		write(debug_l, string'("WIDTH="));
		write(debug_l, t_end);
		write(debug_l, string'(" FREQ="));
		write(debug_l, freq);
		writeline(OUTPUT, debug_l);

  end process;

	rtc_inst : entity work.uPD4990A
	  generic map
	  (
	    CLK_32K768_COUNT  => 25000000/32768
	    --CLK_32K768_COUNT  => 7		-- x100 timescale
	  )
	  port map
	  (
	    clk_i             => clk,
	    clk_ena           => '1',
	    reset             => reset,
	    
	    data_in           => di,
	    clk               => clk_s,
	    c                 => "111",
	    stb               => stb,
	    cs                => cs,
	    out_enabl         => '1',
	    
	    data_out          => open,
	    tp                => tp
	  );

end rtl;

