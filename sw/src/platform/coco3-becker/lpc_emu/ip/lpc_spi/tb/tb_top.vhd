library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy_mem is
	port (
		clk				: in std_logic;
    addr			: in std_logic_vector(15 downto 0);
    data			: out std_logic_vector(15 downto 0)
	);
end dummy_mem;

architecture SIM of dummy_mem is
begin
	process (addr)
	begin
	  data <= addr(15 downto 0) after 12 ns; -- 12ns SRAM
	end process;
end SIM;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_lpcspi is
	port (
		fail:				out  boolean := false
	);
end entity tb_lpcspi;

architecture SYN of tb_lpcspi is

	signal clk						: std_logic_vector(0 to 3)	:= (others => '0');
	signal reset					: std_logic	:= '1';
                    		
	signal cs							: std_logic := '0';
	signal a							: std_logic_vector(3 downto 0) := (others => '0');
	signal di							: std_logic_vector(31 downto 0) := (others => '0');
	signal do							: std_logic_vector(31 downto 0) := (others => '0');
	signal rd							: std_logic := '0';
	signal wr							: std_logic := '0';
	signal waitrequest_n	: std_logic := '0';
	signal spi_clk				: std_logic := '0';
	signal spi_miso				: std_logic := '0';
	signal spi_mosi				: std_logic := '0';
	signal spi_ss					: std_logic := '0';

begin

	process
	begin
		wait until reset = '0';
		wait until rising_edge(clk(0));
		a <= "0001";
		di <= X"00000002"; -- SSE
		wr <= '1';
		cs <= '1';
		wait until rising_edge(waitrequest_n);
		wait until rising_edge(clk(0));
		cs <= '0';

		wait until rising_edge(clk(0));
		a <= "0010"; -- data register
		di <= X"00000055";
		wr <= '1';
		cs <= '1';
		wait until rising_edge(waitrequest_n);
		wait until rising_edge(clk(0));
		cs <= '0';
		
		wait until cs = '1';
	end process;

	process
	begin
		wait until rising_edge(spi_clk);
		spi_miso <= not spi_miso;
	end process;

	-- Generate CLK and reset
  clk(0) <= not clk(0) after 7.575757 ns; -- 66MHz
	reset <= '0' after 15 ns;

	lpc_spi_inst : entity work.lpc_spi_controller
		port map
		(
			csi_clockreset_clk			=> clk(0),
			csi_clockreset_reset		=> reset,
	                	
			avs_s1_chipselect				=> cs,
			avs_s1_address          => a,
			avs_s1_writedata				=> di,
			avs_s1_readdata					=> do,
			avs_s1_read							=> rd,
			avs_s1_write						=> wr,
			avs_s1_waitrequest_n		=> waitrequest_n,
			ins_irq0_irq						=> open,

			coe_spi_clk         		=> spi_clk,
			coe_spi_miso        		=> spi_miso,
			coe_spi_mosi        		=> spi_mosi,
			coe_spi_ss          		=> spi_ss
		);

end SYN;
