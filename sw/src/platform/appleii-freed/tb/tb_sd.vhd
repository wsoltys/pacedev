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

	component spi_controller is
		port
		(
	    CS_N						: out std_logic;
	    MOSI						: out std_logic;
	    MISO						: in std_logic;
	    SCLK						: out std_logic;
	    ram_write_addr	: out std_logic_vector(13 downto 0);
	    ram_di					: out std_logic_vector(7 downto 0);
	    ram_we					: out std_logic;
	    track						: in std_logic_vector(5 downto 0);
	    block_to_read		: in std_logic_vector(22 downto 0);
	    block_read_cmd	: in std_logic;
	  	track_mode			: in std_logic;
	    CLK_14M					: in std_logic;
	    reset						: in std_logic;
	    is_idle					: out std_logic
		);
	end component spi_controller;

	signal clk_28M571		: std_logic := '0';
	signal reset				: std_logic := '1';

	signal cs_n							: std_logic;
	signal mosi							: std_logic;
	signal sclk							: std_logic;
	signal ram_write_addr		: std_logic_vector(13 downto 0);
	signal ram_di						: std_logic_vector(7 downto 0);
	signal ram_we						: std_logic;
	signal is_idle					: std_logic;

begin

	-- Generate CLK and reset
  clk_28M571 <= not clk_28M571 after 17500 ps; -- 28M571Hz

	reset <= '0' after 100 ns;

	spi_controller_inst : entity work.spi_controller
		port map
		(
	    CS_N						=> cs_n,
	    MOSI						=> mosi,
	    MISO						=> '0',
	    SCLK						=> sclk,
	    ram_write_addr	=> ram_write_addr,
	    ram_di					=> ram_di,
	    ram_we					=> ram_we,
	    track						=> (others => '0'),
	    block_to_read		=> (others => '0'),
	    block_read_cmd	=> '0',
	  	track_mode			=> '0',
	    CLK_14M					=> clk_28M571,
	    reset						=> reset,
	    is_idle					=> is_idle
		);

end SYN;
