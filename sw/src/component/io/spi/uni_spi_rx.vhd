library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uni_spi_rx is
	port
  (
    clk           : in std_logic;
    rst           : in std_logic;
    
    spi_en        : in std_logic;
    spi_clk       : in std_logic;
    spi_d         : in std_logic;
    
    irq           : out std_logic;
    data          : out std_logic_vector(31 downto 0)
  );
end entity uni_spi_rx;

architecture SYN of uni_spi_rx is
begin
  
  process (clk, rst)
  
    variable spi_en_r   : std_logic_vector(3 downto 0);
    alias spi_en_prev   : std_logic is spi_en_r(spi_en_r'left);
    alias spi_en_um     : std_logic is spi_en_r(spi_en_r'left-1);
    variable spi_clk_r  : std_logic_vector(3 downto 0);
    alias spi_clk_prev  : std_logic is spi_clk_r(spi_clk_r'left);
    alias spi_clk_um    : std_logic is spi_clk_r(spi_clk_r'left-1);
    variable count      : unsigned(5 downto 0); -- 0..64
    variable spi_d_r    : std_logic_vector(3 downto 0);
    alias spi_d_um      : std_logic is spi_d_r(spi_d_r'left-1);
    variable spi_reg    : std_logic_vector(31 downto 0);
  begin
    if rst = '1' then
      spi_en_r := (others => '0');
      spi_clk_r := (others => '0');
      spi_d_r := (others => '0');
      spi_reg := (others => '0');
      irq <= '0';
      data <= (others => '1');
    elsif rising_edge(clk) then
      irq <= '0'; -- default
      -- start of transfer?
      if spi_en_prev = '0' and spi_en_um = '1' then
        count := (others => '0');
      elsif count(count'left) = '0' then
        if spi_clk_prev = '0' and spi_clk_um = '1' then
          -- clock in data on rising edge clk
          spi_reg := spi_reg(spi_reg'left-1 downto 0) & spi_d_um;
          count := count + 1;
        end if;
      else
        irq <= '1';
        data <= spi_reg;
      end if;
      -- unmeta en,clk signals
      spi_en_r := spi_en_r(spi_en_r'left-1 downto 0) & spi_en;
      spi_clk_r := spi_clk_r(spi_clk_r'left-1 downto 0) & spi_clk;
      spi_d_r := spi_d_r(spi_d_r'left-1 downto 0) & spi_d;
    end if;
  end process;

end architecture SYN;
  