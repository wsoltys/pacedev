library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity m68k_if is
  generic (
    -- Default clock ratio for 8MHz from 50MHz
    clk_mult        : integer := 8;       -- Clock frequency multiplier
    clk_div         : integer := 25       -- Clock frequency divider
  );
  port (
		-- DE2 IO bus signals
  	mainclk    			: in 		std_logic;		-- IO_A28
    cpuclk          : out   std_logic;    -- IO_A29, rising edge 8-25MHz
    cpuclken        : out   std_logic;    -- Clock enable signal for internal logic
		reset						: in 		std_logic;		-- IO_A30
		io							: inout std_logic_vector(31 downto 0);

		-- MC68K signals
		m68k_reset_o_n	: in	std_logic;
		m68k_reset_i_n	: out	std_logic;
		m68k_halt_o_n		: in	std_logic;
		m68k_halt_i_n		: out	std_logic;
		m68k_d_o				: in	std_logic_vector(15 downto 0);
		m68k_d_i				: out	std_logic_vector(15 downto 0);
		m68k_a					: out	std_logic_vector(23 downto 1);
		m68k_fc					: out	std_logic_vector(2 downto 0);
		m68k_ipl_n 			: in	std_logic_vector(2 downto 0);
		m68k_berr_n 		:	in	std_logic;
		m68k_vpa_n  		:	in	std_logic;
		m68k_e					:	out	std_logic;
		m68k_vma_n  		:	out	std_logic;
		m68k_br_n				: in	std_logic;
		m68k_bgack_n		: in	std_logic;
		m68k_bg_n				: out	std_logic;
		m68k_dtack_n		: in	std_logic;
		m68k_rd_nwr			: out	std_logic;
		m68k_lds_n			: out	std_logic;
		m68k_uds_n			: out	std_logic;
		m68k_as_n				: out	std_logic;

    -- Mux bus control signals
		m68k_sync				: out std_logic;	-- 'sync' pulse occurs during rd1
		m68k_do_wr			: in	std_logic;	-- assert (during 'sync') to update (write) outputs

		-- Output enable for tristate MC68K outputs
		m68k_oe_reset		: in std_logic;
		m68k_oe_halt		: in std_logic;
		m68k_oe_d				: in std_logic
	);
end m68k_if;

architecture SYN of m68k_if is
	type state_type is (idle, rd0, rd1, rd2, wr0, wr1);

  alias cclk            : std_logic is io(29);
  
	-- State machine signals
	signal state					: state_type;
	signal next_state			: state_type;

	-- IO bus signals
	signal io_wr					: std_logic;
	signal io_di					: std_logic_vector(21 downto 0);
	signal io_do					: std_logic_vector(21 downto 0);
	signal io_oe					: std_logic;
	signal io_ext					: std_logic;

	signal io_wr_0				: std_logic;
  signal cnt_s          : integer;
  
begin

	-- Assign signals to IO bus
	io_di		<= io(21 downto 0);
	io(21 downto 0) <= io_do when io_oe = '1' else (others => 'Z');
	io(22) <= io_ext;
	io_wr <= io(23);
 	io(28) <= mainclk;
	io(30) <= reset;

	io_do <= "00000000000000000" & m68k_ipl_n & m68k_oe_halt & m68k_oe_reset when state = wr1
		else m68k_oe_d & m68k_vpa_n & m68k_br_n & m68k_bgack_n & m68k_berr_n & m68k_dtack_n & m68k_d_o;

	io_oe <= '1' when state = wr0 or state = wr1 else '0';

	m68k_sync <= '1' when state = rd1 else '0';
	io_ext <= m68k_do_wr;

	-- State machine
	io_sm : process(state, io_wr)
	begin
		case state is
		when idle =>		next_state <= rd0;
--		 			next_state <= ig0;
--		when ig0	=>			next_state <= ig1;
--		when ig1	=>			next_state <= ig2;
--		when ig2	=>			next_state <= rd0;
		when wr0	=>			next_state <= wr1;
		when wr1	=>			next_state <= rd0;
		when rd0	=>			next_state <= rd1;
		when rd1	=>			next_state <= rd2;
		when rd2	=>			next_state <= wr0;
		end case;
--		if io_wr = '1' then next_state <= rd2; end if;
	end process;

	-- Registers
	reg : process(reset, mainclk)
	begin
		if reset = '1' then
			state					<= idle;
			m68k_d_i			<= (others => '0');
			m68k_reset_i_n<= '1';
			m68k_halt_i_n	<= '1';
			m68k_a				<= (others => '0');
			m68k_rd_nwr		<= '1';
			m68k_lds_n		<= '1';
			m68k_uds_n		<= '1';
			m68k_as_n			<= '1';
			m68k_fc				<= (others => '0');
			m68k_e				<= '0';
			m68k_vma_n		<= '1';
			m68k_bg_n			<= '1';

			io_wr_0				<= '0';

		elsif rising_edge(mainclk) then
			state <= next_state;
			if state = rd0 then
				m68k_a(22 downto 1) <= io_di;
			end if;

			if state = rd1 then
        m68k_a(23) <= io_di(20);
				m68k_rd_nwr <= io_di(19);
				m68k_lds_n <= io_di(18);
				m68k_uds_n <= io_di(17);
				m68k_as_n <= io_di(16);
				m68k_d_i <= io_di(15 downto 0);
			end if;

			if state = rd2 then
				m68k_reset_i_n <= io_di(7);
				m68k_halt_i_n <= io_di(6);
				m68k_fc <= io_di(5 downto 3);
				m68k_e <= io_di(2);
				m68k_vma_n <= io_di(1);
				m68k_bg_n <= io_di(0);
			end if;

--			io_wr_0 <= io_wr;
		end if;
	end process reg;

  -- Clock generator
	clkgen : process(reset, mainclk)
    variable cnt : integer;
    variable clk : std_logic;
	begin
		if reset = '1' then
      cnt := 0;
      clk := '0';
      cclk <= '0';
      cpuclken <= '0';
      
		elsif rising_edge(mainclk) then
      cpuclk <= cclk;   -- cpuclk lags one clock for clock recovery at remote
      cpuclken <= '0';
      cclk <= clk;
      cnt := cnt + clk_mult;
      if cnt >= clk_div then
        cnt := cnt - clk_div;
        if clk = '0' then
          cpuclken <= '1';
        end if;
        clk := not clk;
      end if;
    end if;
    cnt_s <= cnt;
  end process clkgen;
  
end SYN;


