library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

entity tb_top is
	port (
		fail:				out  boolean := false
	);
end tb_top;

architecture SYN of tb_top is

	signal clk						: std_logic_vector(0 to 3) := (others => '0');
	signal reset					: std_logic	:= '1';
	signal reset_n				: std_logic;

  signal jamma          : JAMMAInputsType;
  signal sram_i         : from_sram_t;
  signal sram_o         : to_sram_t;

begin

  -- some test clocking stuff
  BLK_TEST_CLOCK : block

    signal clk_32M : std_logic := '0';
    signal clk_1M_pulse : std_logic;
    signal p2_h : std_logic;
    signal clk_4M_en : std_logic;

  begin

    clk_32M <= not clk_32M after 15625 ps;

    process (clk_32M, reset)
      variable count  : std_logic_vector(8 downto 0) := (others => '0');
      alias hcnt : std_logic_vector(1 downto 0) is count(4 downto 3);
    begin
      if rising_edge(clk_32M) then
        -- generate 1MHz pulse
        clk_1M_pulse <= '0';
        --if count(4 downto 0) = "00111" then
        if count(4 downto 0) = "01000" then
          clk_1M_pulse <= '1';
        end if;
        count := count + 1;
      end if;
      p2_h <= not hcnt(1);
      clk_4M_en <= not count(2);
    end process;

  end block BLK_TEST_CLOCK;

  -- some test clocking stuff
  BLK_TEST_CLOCK2 : block

    signal clk_16M : std_logic := '0';
    signal clk_2M_pulse : std_logic;
    signal p2_h : std_logic;
    signal clk_4M_en : std_logic;

  begin

    clk_16M <= not clk_16M after 31250 ps; -- 16MHz

    process (clk_16M, reset)
      variable count  : std_logic_vector(3 downto 0) := (others => '0');
    begin
      if rising_edge(clk_16M) then
        -- generate 1MHz pulse
        clk_2M_pulse <= '0';
        if count(2 downto 0) = "000" then
          clk_2M_pulse <= '1';
        end if;
        count := count + 1;
      end if;
      p2_h <= not count(3);
      clk_4M_en <= not count(1);
    end process;

  end block BLK_TEST_CLOCK2;

	-- Generate CLK and reset
  clk(0) <= not clk(0) after 31250 ps; -- 16MHz
	reset <= '0' after 100 ns;
	reset_n <= not reset;
  clk(1) <= clk(0);
  clk(2 to 3) <= (others => '0');

  pace_inst : entity work.PACE
    port map
    (
    	-- clocks and resets
      clk             => clk,
      test_button     => '0',
      reset           => reset,
  
      -- game I/O
      ps2clk          => open,
      ps2data         => open,
      dip             => (others => '0'),
  		jamma						=> jamma,
  
      -- external RAM
      sram_i       		=> sram_i,
  		sram_o					=> open,
  
      -- VGA video
      red             => open,
      green           => open,
      blue            => open,
      hsync           => open,
      vsync           => open,
  
      -- composite video
      BW_CVBS         => open,
      GS_CVBS         => open,
  
      -- sound
      snd_clk         => open,
      snd_data_l      => open,
      snd_data_r      => open,
  
      -- SPI (flash)
      spi_clk         => open,
      spi_mode        => open,
      spi_sel         => open,
      spi_din         => '0',
      spi_dout        => open,
  
      -- serial
      ser_tx          => open,
      ser_rx          => '0',
  
      -- debug
      leds            => open
    );

end SYN;
