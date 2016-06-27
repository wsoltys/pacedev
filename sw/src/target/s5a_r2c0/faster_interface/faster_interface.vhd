library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity faster_interface is
	generic
	(
		ADDRESS_LENGTH	: integer := 29
	);
  port
  (
	  clock           : in std_logic;
	  reset           : in std_logic;
	                  
	  s_address       : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	  s_writedata     : in std_logic_vector(31 downto 0);
	  s_readdata      : out std_logic_vector(31 downto 0);
	  s_read          : in std_logic;
	  s_write         : in std_logic;
	  s_waitrequest   : out std_logic;
	  s_irq           : out std_logic;
		s_byteenable		: in std_logic_vector(3 downto 0);
	
    address         : out std_logic_vector(10 downto 0);
    data            : inout std_logic_vector(15 downto 0);
	  read_n          : out std_logic;
	  access_n        : out std_logic;
	  irq_n           : in std_logic;
	  waitrequest_n   : in std_logic
  );
end entity faster_interface;

architecture SYN of faster_interface is

	constant DELAY		: time := 2 ns;

 	function minimum(a : integer; b : integer) return integer is
	begin
		if a < b then
			return a;
		else
			return b;
		end if;
	end function minimum;

	type state_t is (S_IDLE, S_RD_ADDR, S_RD_DLO, S_RD_DHI, S_WR_ADDR, S_WR_DLO, S_WR_DHI, S_DONE);
  signal state      : state_t := S_IDLE;
  signal next_state : state_t := S_IDLE;
  
	signal data_out		: std_logic_vector(15 downto 0);
	signal data_drive	: std_logic;
  
begin

  -- combinatorial assignments
	--s_waitrequest <= '0' after DELAY when state = S_IDLE else '1' after DELAY;
	s_waitrequest <= '0' after DELAY when state = S_DONE else '1' after DELAY;
  read_n <= not s_read after DELAY;
	data <= data_out after DELAY when data_drive = '1' else (others => 'Z') after DELAY;
	access_n <= '0' after DELAY when state = S_IDLE and (s_read ='1' or s_write = '1') else '1' after DELAY;
  s_irq <= not irq_n;

  process (state, s_read, s_write, s_byteenable, s_writedata, s_address, waitrequest_n)
  begin
		data_drive		<= '0';
		data_out			<= (others => 'X');
		address				<= s_address(10 downto 0);

		next_state		<= state;

		case state is
		when S_IDLE =>
			if s_read = '1' then
				next_state <= S_RD_ADDR;
			elsif s_write = '1' then
				next_state <= S_WR_ADDR;
			end if;

		when S_RD_ADDR =>
			address(minimum(s_address'high-11, 10) downto 0) <= s_address(minimum(s_address'high, 21) downto 11);
			data_out <= s_byteenable & 
				std_logic_vector(resize(unsigned(s_address(ADDRESS_LENGTH-1 downto 22)), 12));
			data_drive <= '1';
			
			if s_byteenable(3) = '1' or s_byteenable(2) = '1' then
				next_state <= S_RD_DHI;
			else
				next_state <= S_RD_DLO;
			end if;

			if s_read = '0' then	-- catchall in case master drops read
				next_state <= S_DONE;
			end if;

		when S_RD_DHI =>
			if waitrequest_n = '1' then
				if s_byteenable(1) = '1' or s_byteenable(0) = '1' then
					next_state <= S_RD_DLO;
				else
					next_state <= S_DONE;
				end if;
			end if;
			
			if s_read = '0' then	-- catchall in case master drops read
				next_state <= S_IDLE;
			end if;

		when S_RD_DLO =>
			if waitrequest_n = '1' then
				next_state <= S_DONE;
			end if;

			if s_read = '0' then	-- catchall in case master drops read
				next_state <= S_DONE;
			end if;

		when S_WR_ADDR =>
			address(minimum(s_address'high-11, 10) downto 0) <= s_address(minimum(s_address'high, 21) downto 11);
			data_out <= s_byteenable & 
				std_logic_vector(resize(unsigned(s_address(ADDRESS_LENGTH-1 downto 22)), 12));
			data_drive <= '1';
			if s_byteenable(3) = '1' or s_byteenable(2) = '1' then
				next_state <= S_WR_DHI;
			else
				next_state <= S_WR_DLO;
			end if;

			if s_write = '0' then	-- catchall in case master drops write
				next_state <= S_DONE;
			end if;

		when S_WR_DHI =>
			data_out <= s_writedata(31 downto 16);
			data_drive <= '1';

			if s_byteenable(1) = '1' or s_byteenable(0) = '1' then
				next_state <= S_WR_DLO;
			else
				next_state <= S_DONE;
			end if;

			if s_write = '0' then	-- catchall in case master drops write
				next_state <= S_DONE;
			end if;

		when S_WR_DLO =>
			data_out <= s_writedata(15 downto 0);
			data_drive <= '1';

			if waitrequest_n = '1' then
				next_state <= S_DONE;
			end if;

			if s_write = '0' then	-- catchall in case master drops write
				next_state <= S_DONE;
			end if;

		when S_DONE =>
			next_state <= S_IDLE;

		when others =>
			next_state <= S_IDLE;
		end case;
  end process;
  
  process (clock, reset)
  begin
    if reset = '1' then
      state <= S_IDLE;
			s_readdata <= (others => '0');

    elsif rising_edge(clock) then
			if state = S_RD_DHI then
				s_readdata(31 downto 16) <= data;
			end if;

			if state = S_RD_DLO then
				s_readdata(15 downto 0) <= data;
			end if;

			state <= next_state;

    end if;
  end process;
  
end architecture SYN;
