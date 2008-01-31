--
-- I/O multiplexer for custom 6809 interface hanging off GPIO
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity m6809_if is
  port (
		-- IO signals
  	mainclk    			  : in 		std_logic;    -- High speed clock
		reset						  : in 		std_logic;    -- Reset - this must be asserted on startup to sync both ends
    cpuq              : in    std_logic;    -- CPU Q (3MHz clock)
    cpue              : in    std_logic;    -- CPU E (Q delayed 90 degrees)
		io							  : inout std_logic_vector(31 downto 0);

		-- M6809E signals
		m6809e_q					:	out	std_logic;
		m6809e_e					:	out	std_logic;
		m6809e_reset_o_n	: in	std_logic;
		m6809e_halt_o_n		: in	std_logic;
		m6809e_d_o				: in	std_logic_vector(7 downto 0);
		m6809e_d_i				: out	std_logic_vector(7 downto 0);
		m6809e_a					: out	std_logic_vector(15 downto 0);
		m6809e_tsc			  : in std_logic;
		m6809e_nmi_n		  : in std_logic;
		m6809e_irq_n		  : in std_logic;
		m6809e_firq_n		  : in std_logic;
		m6809e_rd_nwr 	  : out std_logic;
		m6809e_ba   		  : out std_logic;
		m6809e_bs   		  : out std_logic;
		m6809e_busy			  : out std_logic;
		m6809e_lic			  : out std_logic;
		m6809e_avma			  : out std_logic;

		-- Output enable for tristate M6809E outputs
		m6809e_oe_reset		: in std_logic;
		m6809e_oe_d				: in std_logic
	);
end m6809_if;

architecture SYN of m6809_if is
	type state_type is (idle, rd0, rd1, wr);

	-- State machine signals
	signal state					: state_type;
	signal next_state			: state_type;

	-- IO bus signals
	signal io_wr					: std_logic;
	signal io_di					: std_logic_vector(23 downto 0);
	signal io_do					: std_logic_vector(23 downto 0);
	signal io_oe					: std_logic;

begin

	-- Assign signals to IO bus
	io_di		<= io(23 downto 0);
	io(23 downto 0) <= io_do when io_oe = '1' else (others => 'Z');
  io(28) <= mainclk;
  io(29) <= cpuq;
  io(30) <= reset;
  io(31) <= cpue;

	io_do <= "000000000" & m6809e_firq_n & m6809e_irq_n & m6809e_nmi_n & m6809e_tsc & 
           m6809e_halt_o_n & m6809e_oe_reset & m6809e_oe_d & m6809e_d_o;

	io_oe <= '1' when state = wr else '0';

  io_wr <= '0';

  m6809e_q <= cpuq;
  m6809e_e <= cpue;

	-- State machine
	io_sm : process(state, io_wr)
	begin
		case state is
		when idle => 			next_state <= rd0;
		when wr 	=>			if io_wr = '1' then next_state <= wr; else next_state <= rd0; end if;
		when rd0	=>			if io_wr = '1' then next_state <= wr; else next_state <= rd1; end if;
		when rd1	=>			if io_wr = '1' then next_state <= wr; else next_state <= wr; end if;
		end case;
	end process;

	-- Registers
	reg : process(reset, mainclk)
	begin
		if reset = '1' then
			state					<= idle;
      m6809e_d_i    <= (others => '0');
      m6809e_a      <= (others => '0');
	    m6809e_rd_nwr <= '0';
      m6809e_ba     <= '0';
      m6809e_bs     <= '0';
      m6809e_busy   <= '0';
      m6809e_lic    <= '0';
      m6809e_avma   <= '0';

		elsif rising_edge(mainclk) then
			state <= next_state;

			if state = rd0 then
	      m6809e_rd_nwr <= io_di(21);
        m6809e_ba     <= io_di(20);
        m6809e_bs     <= io_di(19);
        m6809e_busy   <= io_di(18);
        m6809e_lic    <= io_di(17);
        m6809e_avma   <= io_di(16);
        m6809e_a      <= io_di(15 downto 0);
			end if;

			if state = rd1 then
	      m6809e_rd_nwr <= io_di(21);
        m6809e_ba     <= io_di(20);
        m6809e_bs     <= io_di(19);
        m6809e_busy   <= io_di(18);
        m6809e_lic    <= io_di(17);
        m6809e_avma   <= io_di(16);
				m6809e_d_i    <= io_di(7 downto 0);
			end if;

		end if;
	end process;

end SYN;


