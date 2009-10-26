library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_tb is
	port (
		fail:				out  boolean
	);
end ps2_tb;

architecture SYN of ps2_tb is

	signal clk_14M31818 : std_logic	:= '0';
	signal clk_32M      : std_logic	:= '0';
	signal clk_1M_en    : std_logic	:= '0';
	signal reset			  : std_logic	:= '1';
  signal reset_n      : std_logic	:= '0';
  
  signal ps2_kclk     : std_logic := '0';
  signal ps2_kdat     : std_logic := '0';
  
  signal fifo_data    : std_logic_vector(7 downto 0) := (others => '0');
  signal fifo_wrreq   : std_logic := '0';
  signal fifo_full    : std_logic := '0';
  
	signal sim_done		  : boolean := false;
	
begin

	-- Generate CLK and reset
	clk_14M31818 <= not clk_14M31818 after 34921 ps when not sim_done else '0';
	clk_32M <= not clk_32M after 15625 ps when not sim_done else '0';
	reset <= '0' after 100 ns;
  reset_n <= not reset;
  
	tb : process
	begin

    wait until reset = '0';
    wait until rising_edge(clk_14M31818);

    -- MAKE 'Q'

    wait until rising_edge(clk_14M31818);
    fifo_data <= X"71"; -- 'q'
    fifo_wrreq <= '1';
    wait until rising_edge(clk_14M31818);
    fifo_wrreq <= '0';
    wait until rising_edge(clk_14M31818);
    fifo_data <= X"08"; -- BS(extended)
    fifo_wrreq <= '1';
    wait until rising_edge(clk_14M31818);
    fifo_wrreq <= '0';
    wait until rising_edge(clk_14M31818);
    fifo_data <= X"41"; -- 'A'(shifted)
    fifo_wrreq <= '1';
    wait until rising_edge(clk_14M31818);
    fifo_wrreq <= '0';

		wait for 22*3 ms;

    assert false
      report "end of simulation"
        severity failure;
        
		sim_done <= true;
		wait;
	end process;

  host_inst : entity work.apple_ii_ps2_host
    generic map
    (
      CLK_HZ          => 14318181
    )
    port map
    (
      clk             => clk_14M31818,
      reset           => reset,
  
      -- FIFO interface
      fifo_data       => fifo_data,
      fifo_wrreq      => fifo_wrreq,
      fifo_full       => fifo_full,
      fifo_usedw      => open,
          
      -- PS/2 lines
      ps2_kclk        => ps2_kclk,
      ps2_kdat        => ps2_kdat
    );

  -- generate clk_1M_ena
  process (clk_32M, reset)
    variable count : integer range 0 to 31;
  begin
    if reset = '1' then
      count := 0;
    elsif rising_edge(clk_32M) then
      clk_1M_en <= '0';  -- default
      if count = 31 then
        clk_1M_en <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;
  
  device_inst : entity work.ps2kbd
  	port map
  	(
  		Rst_n		        => reset_n,
  		Clk			        => clk_32M,
  		Tick1us		      => clk_1M_en,
  		PS2_Clk		      => ps2_kclk,
  		PS2_Data	      => ps2_kdat,
  		Press		        => open,
  		Release		      => open,
  		Reset		        => open,
  		ScanCode	      => open
    );

end SYN;
