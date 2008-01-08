library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.maple_pkg.all;

entity maple_bus is
	generic (
		MHZ				: natural := 48
	);
  port (
  	clk      	: in std_logic;                        
		reset			: in std_logic;
		
		-- Maple bus signals
		sense			: in std_logic;
		oe				: out std_logic;
		a					: inout std_logic;
		b					: inout std_logic;
		
		-- Control interface
		d_in			: in maple_byte;					-- Data to write out to maple bus
		wrreq			: in std_logic;						-- Write strobe
		d_out			: out maple_byte;					-- Data read from maple bus
		rdavail		: out std_logic;					-- Incoming data available
		rdbusy		: out std_logic						-- Busy reading maple packet
	);
end maple_bus;

architecture SYN of maple_bus is

	-- Maple bus signals
	signal a_in  : std_logic;
	signal b_in  : std_logic;
	signal maple_d_out	: std_logic_vector(1 downto 0);
	
	-- Maple write fifo signals
	signal maple_wr_data : std_logic_vector(7 downto 0);
	signal maple_wrfifo_rdreq : std_logic;
	signal maple_wr_req : std_logic;
	signal maple_wrfifo_empty : std_logic;
	signal maple_oe_wr	: std_logic;
	
	signal wraddr			: integer range 0 to 15;
	signal wrdone			: std_logic;
	
	signal wr_busy		: std_logic;
	signal wr_eof			: std_logic;
	signal wr_stb			: std_logic;
	signal wr_d_in		: std_logic_vector(7 downto 0);
	signal wr_csum		: std_logic_vector(7 downto 0);

	signal rd_sync		: std_logic;
	signal rd_drdy 		: std_logic;
	signal rd_eof			: std_logic;
	signal rd_busy		: std_logic;
	signal rd_data		: std_logic_vector(7 downto 0);
	
begin

	maple_rd : work.maple_read
		port map( clk => clk, reset => reset, a => a_in, b => b_in, 
				  sync => rd_sync, eof => rd_eof, d => rd_data,
				  d_rdy => rd_drdy );
				
	maple_wr : work.maple_write
		generic map ( MHZ => MHZ )
		port map( clk => clk, reset => reset, data_in => wr_d_in, datastb => wr_stb, 
				  eof => wr_eof, busy => wr_busy, m_out => maple_d_out, m_oe => maple_oe_wr );

	maple_wr_fifo: work.mfifo
		port map( aclr => reset, clock => clk, data	=> d_in,
					rdreq => maple_wrfifo_rdreq, wrreq => wrreq, empty => maple_wrfifo_empty,
--					full => null
					q => wr_d_in
	);

	-- Send write data to maple bus when there is data in fifo and maple write not busy
	d_out <= std_logic_vector(rd_data);
	rdavail <= rd_drdy;
	rdbusy <= rd_busy;
	maple_wrfifo_rdreq <= not maple_wrfifo_empty and not wr_busy;
	wr_stb <= maple_wrfifo_rdreq and not rd_busy;
	wr_eof <= maple_wrfifo_empty and not rd_busy and not wr_busy;
	
	-- Load init data into write fifo
	process(clk, reset)
	begin
		if reset = '1' then
			rd_busy <= '0';
		elsif rising_edge(clk) then
			if rd_sync = '1' then
				rd_busy <= '1';
			elsif rd_eof = '1' then
				rd_busy <= '0';
			end if;
		end if;
	end process;
	
	oe <= maple_oe_wr;

	b <= 'Z' when maple_oe_wr = '0' else '0' when maple_d_out(1) = '1' else '1';
	a <= 'Z' when maple_oe_wr = '0' else '0' when maple_d_out(0) = '1' else '1';
			
	b_in <= not b or maple_oe_wr;
	a_in <= not a or maple_oe_wr;
	
end SYN;
