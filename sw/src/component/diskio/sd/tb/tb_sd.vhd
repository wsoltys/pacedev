library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity tb_sd is
	port (
		fail:				out  boolean := false
	);
end tb_sd;

architecture SYN of tb_sd is

  component sdModel is
    port
    (
      sdClk   : in std_logic;
      cmd     : inout std_logic;
      dat     : inout std_logic_vector(3 downto 0)
    );
  end component sdModel;
  
  signal clk_20   : std_logic := '0';
  signal arst     : std_logic := '1';

  signal sd_clk   : std_logic := '0';
  signal sd_cmd   : std_logic := '0';
  signal sd_dat   : std_logic_vector(3 downto 0) := (others => '0');    

	signal dbg				: std_logic_vector(31 downto 0);
  signal sw         : std_logic_vector(17 downto 0);     --	Toggle Switch[17:0]
	signal blk_s			: std_logic_vector(31 downto 0);
	signal rd_s				: std_logic;

  signal sd_cmd_i   : std_logic := '0';
  signal sd_cmd_o   : std_logic := '0';
  signal sd_cmd_oe  : std_logic := '0';
  signal sd_dat_i   : std_logic_vector(3 downto 0) := (others => '0');    
  signal sd_dat_o   : std_logic_vector(3 downto 0) := (others => '0');    
  signal sd_dat_oe  : std_logic;    
  
begin

	-- Generate CLK and reset
  clk_20 <= not clk_20 after 25 ns;
	arst <= '0' after 100 ns;

  sw <= (others => '0');

	SD_GEN_0 : if true generate
	begin

  	BLK0 : block
  		type block_type is array(natural range <>) of std_logic_vector(31 downto 0);
  		signal block_r	: block_type(2 downto 0);
  		signal rd_r		: std_logic_vector(2 downto 0);
  	begin
  		sd_if_1 : entity work.sd_if 
			generic map(sd_width => 4)
			port map (
  			clk						=> clk_20,
  			clk_en_50MHz	=> '1',
  			reset					=> arst,
  
  			sd_clk				=> sd_clk,
        sd_cmd_i      => sd_cmd_i,
        sd_cmd_o      => sd_cmd_o,
        sd_cmd_oe     => sd_cmd_oe,
        sd_dat_i      => sd_dat_i,
        sd_dat_o      => sd_dat_o,
        sd_dat_oe     => sd_dat_oe,
  			
  			blk						=> block_r(2),
  			rd						=> rd_r(2),
  			
  			dbg						=> dbg,
  			dbgsel				=> sw(2 downto 0)
  		);
  		
  		process(clk_20)
  		begin
  			if rising_edge(clk_20) then
  				for i in 2 downto 1 loop
  					block_r(i) <= block_r(i-1);
  					rd_r(i) <= rd_r(i-1);
  				end loop;
  				block_r(0) <= blk_s;
  				rd_r(0) <= rd_s;
  			end if;
  		end process;
	  end block BLK0;

	end generate SD_GEN_0;

  PROC_TEST : process
  begin
    rd_s <= '0';
		blk_s <= X"00000000";
    wait until arst = '0';
		wait for 120 us;
    wait until rising_edge(clk_20);
    rd_s <= '1';
    wait until rising_edge(clk_20);
    rd_s <= '0';
		wait for 60 us;
		blk_s <= X"00000200";
    wait until rising_edge(clk_20);
    rd_s <= '1';
    wait until rising_edge(clk_20);
    rd_s <= '0';
    wait;
  end process PROC_TEST;

  sd_cmd <= 'H';
  sd_dat <= (others => 'H');

  sd_card : sdModel
    port map
    (
      sdClk       => sd_clk,
  		cmd			    => sd_cmd,
  		dat			    => sd_dat
    );

  sd_cmd_i <= sd_cmd;
  sd_cmd <= sd_cmd_o when sd_cmd_oe = '1' else 'Z';
  sd_dat_i <= sd_dat;
  sd_dat <= sd_dat_o when sd_dat_oe = '1' else (others => 'Z');
  
end SYN;
