library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
	port (
		fail:				out  boolean
	);
end tb_top;

architecture SYN of tb_top is
	--for syn_cpu : mce_arm2 use entity work.mce_arm2(SYN);

	subtype MemData_idx is integer range 0 to 65535;
	subtype MemData_type is std_logic_vector(31 downto 0);
	type Mem_type is array(MemData_idx) of MemData_type;

	signal clk				: std_logic	:= '0';
	signal reset			: std_logic	:= '1';
  signal ph1_ena    : std_logic := '0';
  signal ph2_ena    : std_logic := '0';
	signal syn_reset  : std_logic := '0';
	signal syn_rn_w   : std_logic := '0';
	signal syn_a      : std_logic_vector(25 downto 0);
	signal syn_d_i	  : std_logic_vector(31 downto 0);
	signal syn_d_o	  : std_logic_vector(31 downto 0);
	signal mem_read		: std_logic;
	signal mem_addr		: std_logic_vector(15 downto 0);
	signal mem_data		: std_logic_vector(31 downto 0);

	signal match_ext	: std_logic;

begin

	syn_cpu : entity work.mce_arm2
    port map 
    (
      -- system signals
      clk_i         => clk,
      reset_i       => reset,
  
      -- clocks
      ph1_ena       => ph1_ena,
      ph2_ena       => ph2_ena,
  
      rn_w          => syn_rn_w,
      opc_n         => open,
      mreq_n        => open,
      abort         => '0',
      irq_n         => '1',
      fiq_n         => '1',
      reset         => syn_reset,
      trans_n       => open,
      m_n           => open,
      seq           => open,
      ale           => '1',
      a             => syn_a,
      abe           => '1',
      d_i           => syn_d_i,
      d_o           => syn_d_o,
      dbe           => '1',
      bn_w          => open,
      cpi_n         => open,
      cpb           => '0',
      cpa           => '1'
    );

	-- Check external signals match
	match_ext <= --'0' when beh_vma /= syn_vma or (syn_vma = '1' and beh_read /= syn_read) or (syn_vma = '1' and beh_addr /= syn_addr) else
		'1';

	-- Generate CLK and reset
	clk <= not clk after 20 ns;
	reset <= '0' after 101 ns;

  -- generate two-phase clock
  process (clk, reset)
    variable count : std_logic_vector(3 downto 0) := (others => '0');
  begin
    if reset = '1' then
      ph1_ena <= '0';
      ph2_ena <= '0';
      syn_reset <= '1';
    elsif rising_edge(clk) then
      ph1_ena <= '0';
      ph2_ena <= '0';
      if count = X"0" then
        ph1_ena <= '1';
        if reset = '0' then
          syn_reset <= '0';
        end if;
      elsif count = X"8" then
        ph2_ena <= '1';
      end if;
      count := std_logic_vector(unsigned(count) + 1);
    end if;
  end process;

	mem_read <= not syn_rn_w;
	mem_addr <= syn_a(mem_addr'left+2 downto 2);
	--mem_read <= beh_read;
	--mem_addr <= beh_addr;
  syn_d_i <= mem_data;

	beh_mem : process(mem_read, mem_addr)
		constant mem_delay : time := 12 ns;
		constant mem : Mem_type := (
			0				=>	X"FFFFFFFF",	  -- NOP
			1				=>	X"E4000042",	  -- AL,LD/STR=$042
			others	=>	X"FFFFFFFF"     -- NOP
		);
	begin
		mem_data <= mem(to_integer(unsigned(mem_addr))) after mem_delay;
		if mem_addr = X"0080" then
			assert false report "End of simulation" severity Failure;  
		end if;
	end process;
end SYN;
