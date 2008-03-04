library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.conv_std_logic_vector;

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

		procedure wr_reg ( d_i 	: in std_logic_vector(7 downto 0) ) is
		begin
	    wait for 5 ns;
			d <= d_i;
	    wait until rising_edge(clk_4M_en);
	    we_n <= '0';
	    wait until rising_edge(clk_4M_en);
	    we_n <= '1';
		end procedure wr_reg;

		procedure wr_freq ( ch : in integer range 0 to 2;
												n  : in integer range 0 to 1023) is
			variable n_s : std_logic_vector(9 downto 0);
		begin
			n_s := conv_std_logic_vector(n, 10);
			d <= '1' & conv_std_logic_vector(ch, 2) & '0' & n_s(3 downto 0);
			wr_reg (d);
			d <= '0' & '0' & n_s(9 downto 4);
			wr_reg (d);
		end procedure wr_freq;

		procedure wr_attn ( ch : in integer range 0 to 3;
												a  : in integer range 0 to 15) is
			variable a_s : std_logic_vector(3 downto 0);
		begin
			a_s := conv_std_logic_vector(a, 4);
			d <= '1' & conv_std_logic_vector(ch, 2) & '1' & a_s;
			wr_reg (d);
		end procedure wr_attn;

  begin
    we_n <= '1';
    wait until reset = '0';
		wr_freq (0, 25);
		wr_attn (0, 12);
		wr_freq (1, 50);
		wr_attn (1, 8);
		wr_freq (2, 12);
		wr_attn (2, 4);
		wr_attn (3, 0);
		-- noise control
		wr_reg ('1' & "110" & "00" & "00");
		wait for 4 ms;
		wr_reg ('1' & "110" & "00" & "01");
		wait for 4 ms;
		wr_reg ('1' & "110" & "00" & "10");
		wait for 4 ms;
		wr_reg ('1' & "110" & "00" & "11");
		wait for 4 ms;
  end process;

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
                	
  		d						=> d,
  		ready				=> open,
  		we_n				=> we_n,
  		ce_n				=> '0',
  
  		audio_out		=> open
  	);

end SYN;
