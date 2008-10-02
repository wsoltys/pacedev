library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

entity tb_wd179x is
	port (
		fail:				out  boolean := false
	);
end tb_wd179x;

architecture SYN of tb_wd179x is

	signal clk					: std_logic	:= '0';
	signal reset				: std_logic	:= '1';
                  	
	signal clk_20M 			: std_logic := '0';

  signal fdc_we_n			: std_logic := '1';
  signal fdc_cs_n			: std_logic := '1';
  signal fdc_re_n			: std_logic := '1';
  signal fdc_a				: std_logic_vector(1 downto 0) := (others => '0');
  signal fdc_dat_i		: std_logic_vector(7 downto 0) := (others => '0');
  signal fdc_dat_o		: std_logic_vector(7 downto 0) := (others => '0');

  signal step         : std_logic := '0';
  signal dirc         : std_logic := '0';
  signal rclk         : std_logic := '0';
  signal raw_read_n   : std_logic := '0';
  signal tr00_n       : std_logic := '0';
  signal ip_n         : std_logic := '0';

	signal mem_a				: std_logic_vector(19 downto 0) := (others => '1');
	signal mem_d				: std_logic_vector(7 downto 0);

	type MEM_t is array (natural range <>) of std_logic_vector(7 downto 0);
	constant mem : MEM_t(0 to 305) := 
	(
		X"FF", X"FF", X"FF", X"FF",
		X"FE",
		X"00", X"00", 	-- track=0
		X"00", X"01",		-- sector=0
		X"12", X"34",		-- CRC
		X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", 
		X"00", X"00", X"00", X"00", X"00", X"00", 
		X"FB",					-- DAM
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"00", X"01", X"02", X"03", X"04", X"05", X"06", X"07", X"08", X"09", X"0A", X"0B", X"0C", X"0D", X"0E", X"0F",
		X"56", X"78",
		X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", 
		X"00", X"00", X"00", X"00", X"00", X"00"
	);

begin

	-- Generate CLK and reset
  clk_20M <= not clk_20M after 25000 ps; -- 20MHz
	reset <= '0' after 10 ns;

	mem_d <= mem(conv_integer(mem_a));

  wd179x_inst : entity work.wd179x
    port map
    (
      clk           => clk_20M,
      clk_20M_ena   => '1',
      reset         => reset,
      
      -- micro bus interface
      mr_n          => '1',
      we_n          => fdc_we_n,
      cs_n          => fdc_cs_n,
      re_n          => fdc_re_n,
      a             => fdc_a(1 downto 0),
      dal_i         => fdc_dat_i,
      dal_o         => fdc_dat_o,
      clk_1mhz_en   => '1',
      drq           => open,
      intrq         => open,
      
      -- drive interface
      step          => step,
      dirc          => dirc,
      early         => open,    -- not used atm
      late          => open,    -- not used atm
      test_n        => '1',     -- not used
      hlt           => '1',     -- head always engaged atm
      rg            => open,
      sso           => open,
      rclk          => rclk,
      raw_read_n    => raw_read_n,
      hld           => open,    -- not used atm
      tg43          => open,    -- not used on TRS-80 designs
      wg            => open,
      wd            => open,    -- 200ns (MFM) or 500ns (FM) pulse
      ready         => '1',     -- always read atm
      wf_n_i        => '1',     -- no write faults atm
      vfoe_n_o      => open,    -- not used in TRS-80 designs?
      tr00_n        => tr00_n,
      ip_n          => ip_n,
      wprt_n        => '1',     -- never write-protected atm
      dden_n        => '1'      -- single density only atm
    );

	floppy_inst : entity work.floppy
	  port map
	  (
	    clk           => clk_20M,
	    clk_20M_ena   => '1',
	    reset         => reset,
	    
	    step          => step,
	    dirc          => dirc,
	    rclk          => rclk,
	    raw_read_n    => raw_read_n,
	    tr00_n        => tr00_n,
	    ip_n          => ip_n,
	
	    -- memory interface
	    mem_a         => mem_a,
	    mem_d_i       => mem_d,
	    mem_d_o       => open,
	    mem_we        => open
	  );

	process
	begin
		wait for 4 ms;
		fdc_a <= "00";
		fdc_dat_i <= X"00";
		fdc_cs_n <= '0';
		fdc_we_n <= '0';
		wait until rising_edge(clk_20M);
		wait for 2 ns;
		fdc_cs_n <= '1';
		fdc_we_n <= '1';

		wait for 1 ms;
		fdc_dat_i <= X"50";	-- step in, update track
		fdc_cs_n <= '0';
		fdc_we_n <= '0';
		wait until rising_edge(clk_20M);
		wait for 2 ns;
		fdc_cs_n <= '1';
		fdc_we_n <= '1';

		wait for 100 ms;		
	end process;

end SYN;
