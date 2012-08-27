library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uni_spi_tx is
	port
  (
    clk           : in std_logic;
    rst           : in std_logic;
    
    spi_en        : out std_logic;
    spi_clk       : out std_logic;
    spi_d         : out std_logic;
    
    go            : in std_logic;
    data          : in std_logic_vector(31 downto 0)
  );
end entity uni_spi_tx;

architecture SYN of uni_spi_tx is
begin

    process (clk, rst)
      variable spi_go_r   : std_logic_vector(3 downto 0);
      alias spi_go_prev   : std_logic is spi_go_r(spi_go_r'left);
      alias spi_go_um     : std_logic is spi_go_r(spi_go_r'left-1);
      variable spi_d_r    : std_logic_vector(data'range);
      variable count      : unsigned(6 downto 0);
      variable spi_clk_v  : std_logic;
    begin
      if rst = '1' then
        spi_go_r := (others => '0');
        count := (others => '1');
      elsif rising_edge(clk) then
        -- start a transfer
        if spi_go_prev = '0' and spi_go_um = '1' then
          -- this should be stable before 'go'
          spi_d_r := data;
          count := (others => '0');
          spi_clk_v := '0';
        elsif count(count'left) = '0' then
          spi_clk_v := not spi_clk_v;
          if spi_clk_v = '0' then
            spi_d_r := spi_d_r(spi_d_r'left-1 downto 0) & '0';
          end if;
          count := count + 1;
        end if;
        -- unmeta the spi_pio_o 'go' signal
        spi_go_r := spi_go_r(spi_go_r'left-1 downto 0) & go;
      end if;
      -- assign to pin
      spi_en <= not count(count'left);
      spi_clk <= spi_clk_v;
      spi_d <= spi_d_r(spi_d_r'left);
    end process;
    
  end architecture SYN;
  
