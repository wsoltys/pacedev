library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flave_interface is
	generic
	(
		ADDRESS_LENGTH	: integer := 30
	);
  port
  (
	  clock           : in std_logic;
	  reset           : in std_logic;

    reset_n         : in std_logic;	                  
	  address         : in std_logic_vector(10 downto 0);
	  data            : inout std_logic_vector(15 downto 0);
	  read_n          : in std_logic;
	  access_n        : in std_logic;
	  waitrequest_n   : out std_logic;
	  irq_n           : out std_logic;

		-- Interrupts out to PIO block acting as interrupt controller
	  interrupts      : out std_logic_vector(15 downto 0);
	
	  m_address       : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	  m_writedata     : out std_logic_vector(31 downto 0);
	  m_readdata      : in std_logic_vector(31 downto 0);
	  m_read          : out std_logic;
	  m_write         : out std_logic;
	  m_byteenable    : out std_logic_vector(3 downto 0);
	  m_waitrequest   : in std_logic;
	  m_irq           : in std_logic_vector(15 downto 0)
	);
end entity flave_interface;

architecture SYN of flave_interface is

	constant DELAY		: time := 2 ns;
	
	function minimum(a : integer; b : integer) return integer is
	begin
		if a < b then
			return a;
		else
			return b;
		end if;
	end function minimum;

  type state_t is (S_IDLE, S_RD_ADDR, S_RD_DLO, S_RD_DHI, S_RD_WAIT, S_WR_ADDR, S_WR_DLO, S_WR_DHI, S_WR_COMMIT1, S_WR_COMMIT2);
  signal state					: state_t := S_IDLE;
  signal next_state			: state_t := S_IDLE;

  signal m_writedata_s	: std_logic_vector(31 downto 0);
  signal byteenable_s		: std_logic_vector(3 downto 0);
  signal byteenable_r		: std_logic_vector(3 downto 0);
      
  signal data_r					: std_logic_vector(15 downto 0);

begin

  -- combinatorial assignments
  data <= m_readdata(31 downto 16) after DELAY when state = S_RD_DHI else 
		m_readdata(15 downto 0) after DELAY when state = S_RD_DLO else
		(others => 'Z') after DELAY;
  --data <= data_r after DELAY when state = S_RD_DLO or state = S_RD_WAIT else 
	--	(others => 'Z') after DELAY;
	m_address(12 downto 0) <= address(10 downto 0) & "00" after DELAY;
	waitrequest_n	<= '0' after DELAY when m_waitrequest = '1' or 
									(state = S_WR_DLO or state = S_WR_COMMIT1) else '1' after DELAY;
	byteenable_s	<= data(15 downto 12) after DELAY;		-- During S_RD_ADDR or S_WR_ADDR only
	m_byteenable	<= byteenable_r;
	m_writedata		<= m_writedata_s;
	
	-- Generate IRQ from hard-coded interrupt sources or'd together (SYNC for vid1, vid2 and vidout)
	--irq_n <= not (m_irq(2) or m_irq(3) or m_irq(4));
	irq_n <= not m_irq(0);
	interrupts <= m_irq;

  process (state, read_n, access_n, address, data, m_waitrequest, m_readdata, byteenable_s, byteenable_r)
  begin
		m_read          <= '0' after DELAY;
		m_write         <= '0' after DELAY;

		next_state			<= state after DELAY;

		case state is
		when S_IDLE =>

		when S_RD_ADDR =>
			if byteenable_s(3) = '1' or byteenable_s(2) = '1' then
				next_state <= S_RD_DHI after DELAY;
			else
				next_state <= S_RD_DLO after DELAY;
			end if;

		when S_RD_DHI =>
			m_read <= '1';

			if m_waitrequest = '0' then
				if byteenable_r(1) = '1' or byteenable_r(0) = '1' then
					next_state <= S_RD_DLO after DELAY;
				else
					next_state <= S_IDLE after DELAY;
				end if;
			end if;

		when S_RD_DLO =>
			m_read <= '1';

			if m_waitrequest = '0' then
				next_state <= S_IDLE after DELAY;
			end if;

		-- Wait one clock for read to complete to the master
		when S_RD_WAIT =>
			next_state <= S_IDLE after DELAY;

		when S_WR_ADDR =>
			if byteenable_s(3) = '1' or byteenable_s(2) = '1' then
				next_state <= S_WR_DHI;
			else
				next_state <= S_WR_DLO;
			end if;

		when S_WR_DHI =>

			if byteenable_r(1) = '1' or byteenable_r(0) = '1' then
				next_state <= S_WR_DLO;
			else
				next_state <= S_WR_COMMIT1;
			end if;

		when S_WR_DLO =>
			next_state <= S_WR_COMMIT1;

		when S_WR_COMMIT1 =>
			m_write <= '1' after DELAY;
			if m_waitrequest = '0' then
				next_state <= S_IDLE;
			end if;

		when S_WR_COMMIT2 =>
			next_state <= S_IDLE;

		when others =>
			next_state <= S_IDLE;

		end case;

		-- Always restart statemachine when access is asserted
		if access_n = '0' then
			if read_n = '0' then
				next_state <= S_RD_ADDR;
			else
				next_state <= S_WR_ADDR;
			end if;
		end if;

  end process;

  process (clock, reset, reset_n)
  begin
		-- Always restart statemachine when access is asserted
    if reset = '1' or reset_n = '0' then
			state <= S_IDLE;
			m_address(m_address'high downto 13) <= (others => '0');
  		byteenable_r		<= (others => '0');
			m_writedata_s		<= X"B0B0B0B0" after DELAY;

    elsif rising_edge(clock) then

			case state is
			when S_RD_ADDR | S_WR_ADDR =>
				byteenable_r <= byteenable_s;
				m_address(ADDRESS_LENGTH-1 downto 24) <= data(ADDRESS_LENGTH-25 downto 0);
				m_address(minimum(ADDRESS_LENGTH-1, 23) downto 13) <= address(minimum(ADDRESS_LENGTH-1, 23) - 13 downto 0);

			when S_RD_DHI =>
				data_r <= m_readdata(31 downto 16);

			when S_RD_DLO =>
				data_r <= m_readdata(15 downto 0);

			when S_WR_DHI =>
				m_writedata_s(31 downto 16) <= data;

			when S_WR_DLO =>
				m_writedata_s(15 downto 0) <= data;

			when S_WR_COMMIT1 =>
				m_writedata_s <= m_writedata_s;

			when others =>
				m_writedata_s	<= X"B0B0B0B0" after DELAY;
			end case;

			state <= next_state;

    end if;
  end process;

  
end architecture SYN;
