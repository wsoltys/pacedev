library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

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
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity tb_coco3 is
	port (
		fail:				out  boolean := false
	);
end tb_coco3;

architecture SYN of tb_coco3 is
	signal clk			: std_logic_vector(0 to 3)	:= (others => '0');
	signal reset		: std_logic	:= '1';

	signal jamma		: JAMMAInputsType;
	signal sram_a		: std_logic_vector(23 downto 0);
	signal sram_do	: std_logic_vector(31 downto 0);
	signal sram_di	: std_logic_vector(31 downto 0);
	signal sram_be	: std_logic_vector(3 downto 0);
	signal sram_cs	: std_logic;
	signal sram_oe	: std_logic;
	signal sram_we	: std_logic;

  signal nwe      : std_logic;
  signal noe      : std_logic;
  signal nbhe     : std_logic;
  signal nble     : std_logic;
  signal sram_d   : std_logic_vector(15 downto 0);

	signal sram_a_delayed : std_logic_vector(18 downto 0);

begin
	-- Generate CLK and reset
  clk(0) <= not clk(0) after 10 ns; -- 50MHz
	reset <= '0' after 15 ns;

  nwe <= not sram_we;
  noe <= not sram_oe;
  nbhe <= not sram_be(1);
  nble <= not sram_be(0);
  sram_do <= X"0000" & sram_d;
	-- add delays because sram model latches D after CS/WE goes away, and A,D is not held in this case
  sram_d <= sram_di(15 downto 0) when (sram_cs = '1' and sram_we <= '1') else (others => 'Z') after 1 ns;
	sram_a_delayed <= sram_a(sram_a_delayed'range) after 1 ns;

	PACE_INST : entity work.PACE
	  port map
	  (
	     -- clocks and resets
			clk								=> clk,
			test_button      	=> '0',
	    reset            	=> reset,

	    -- game I/O
	    ps2clk           	=> open,
	    ps2data          	=> open,
	    dip              	=> (others => '0'),
			jamma							=> jamma,
			
	    -- external RAM
	    sram_i.d        	=> sram_do,
			sram_o.a					=> sram_a,
	    sram_o.d       		=> sram_di,
			sram_o.be					=> sram_be,
			sram_o.cs					=> sram_cs,
			sram_o.oe					=> sram_oe,
			sram_o.we					=> sram_we,

	    -- VGA video
	    red              	=> open,
	    green            	=> open,
	    blue             	=> open,
	    hsync            	=> open,
	    vsync            	=> open,

	    -- composite video
	    BW_CVBS          	=> open,
	    GS_CVBS          	=> open,

	    -- sound
	    snd_clk          	=> open,
	    snd_data         	=> open,

	    -- SPI (flash)
	    spi_clk          	=> open,
	    spi_mode         	=> open,
	    spi_sel          	=> open,
	    spi_din          	=> '0',
	    spi_dout         	=> open,

	    -- serial
	    ser_tx           	=> open,
	    ser_rx           	=> '0',

	    -- debug
	    leds             	=> open
	  );

  SRAM : entity work.SRAM8MBit
    generic map
    (
      clear_on_power_up => true,

      tAA_max => 0 ns,
      tOHA_min => 0 ns,
      tACE_max => 0 ns,
      tDOE_max => 0 ns,
      tLZOE_min => 0 ns,
      tHZOE_max => 11.9 ns,
      tLZCE_min => 0 ns,
      tHZCE_max => 11.9 ns,

      tWC_min => 11.9 ns,
      tSCE_min => 0 ns,
      tAW_min => 11.9 ns,
      tHA_min => 0 ns,
      tSA_min => 0 ns,
      tPWE_min => 11.9 ns,
      tSD_min => 11.9 ns,
      tHD_min => 0 ns,
      tHZWE_max => 0 ns,
      tLZWE_min => 0 ns
    )
    port map
    (
      NCE1    => '0',
      CE2     => sram_cs,
      NWE     => nwe,
      NOE     => noe,
      NBHE    => '0',
      NBLE    => '0',
      NBYTE   => '1',
                                              -- in byte mode
      A     => sram_a_delayed,
      D     => sram_d
  );

	sram_do(31 downto 16) <= (others => '0');

end SYN;
