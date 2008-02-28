library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;

entity tb_top is
	port (
		fail:				out  boolean := false
	);
end tb_top;

architecture SYN of tb_top is

  signal clk_32M    : std_logic := '0';
  signal clk_4M_en  : std_logic := '0';
  signal reset      : std_logic := '1';

  signal d          : std_logic_vector(7 downto 0) := (others => '0');
  signal d_s        : std_logic_vector(7 downto 0) := (others => '0');
  signal we_n       : std_logic := '0';

begin

  clk_32M <= not clk_32M after 15625 ps;
	reset <= '0' after 100 ns;

  process (clk_32M, reset)
    variable count : std_logic_vector(2 downto 0) := (others => '0');
  begin
    if reset = '1' then
      count := (others => '0');
    elsif rising_edge(clk_32M) then
      clk_4M_en <= '0';
      if count = "000" then
        clk_4M_en <= '1';
      end if;
      count := count + 1;
    end if;
  end process;

  -- test
  process
  begin
    we_n <= '1';
    wait until reset = '0';
    wait for 5 ns;

    -- T0 frequency - N=25 (5000Hz)
    d <= '1' & "000" & "0000";
    wait until rising_edge(clk_4M_en);
    we_n <= '0';
    wait until rising_edge(clk_4M_en);
    we_n <= '1';
    wait for 5 ns;
    d <= '0' & '0' & "100110";
    wait until rising_edge(clk_4M_en);
    we_n <= '0';
    wait until rising_edge(clk_4M_en);
    we_n <= '1';

    wait for 5 ns;
  end process;

  GEN_D_S : for i in 0 to 7 generate
    d_s(i) <= d(7-i);
  end generate GEN_D_S;

  sn76489_inst : entity work.sn76489
    generic map
    (
      AUDIO_RES   => 16
    )
  	port map
  	(
  		clk					=> clk_32M,
  		clk_en			=> clk_4M_en,
  		reset				=> reset,
                	
  		d						=> d_s,
  		ready				=> open,
  		we_n				=> we_n,
  		ce_n				=> '1',
  
  		audio_out		=> open
  	);

end SYN;
