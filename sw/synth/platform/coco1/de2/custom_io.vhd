library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- GPIO 0 connector
    gpio_0_i          : in std_logic_vector(35 downto 0);
    gpio_0_o          : out std_logic_vector(35 downto 0);
    gpio_0_oe         : out std_logic_vector(35 downto 0);
    gpio_0_is_custom  : out std_logic_vector(35 downto 0);
    
    -- GPIO 1 connector
    gpio_1_i          : in std_logic_vector(35 downto 0);
    gpio_1_o          : out std_logic_vector(35 downto 0);
    gpio_1_oe         : out std_logic_vector(35 downto 0);
    gpio_1_is_custom  : out std_logic_vector(35 downto 0);

    -- 7-segment display
    seg7              : out std_logic_vector(31 downto 0);
    
    project_i       : out from_PROJECT_IO_t;
    project_o       : in to_PROJECT_IO_t;
    platform_i      : out from_PLATFORM_IO_t;
    platform_o      : in to_PLATFORM_IO_t;
    target_i        : out from_TARGET_IO_t;
    target_o        : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

  -- use an alias so we can easily switch connectors
  alias gpio_i              : std_logic_vector(35 downto 0) is gpio_1_i;
  alias gpio_o              : std_logic_vector(35 downto 0) is gpio_1_o;
  alias gpio_oe             : std_logic_vector(35 downto 0) is gpio_1_oe;
  alias gpio_is_custom      : std_logic_vector(35 downto 0) is gpio_1_is_custom;
  alias gpio_is_not_used    : std_logic_vector(35 downto 0) is gpio_0_is_custom;

  -- 6809 interface

  type state_type is (idle, rd0, rd1, wr);
  signal state            : state_type;
  signal next_state       : state_type;

  -- IO bus signals
	signal io_wr					  : std_logic;
	signal io_di					  : std_logic_vector(23 downto 0);
	signal io_do					  : std_logic_vector(23 downto 0);
	--signal io_oe			      : std_logic;

  signal m6809e_oe_reset  : std_logic;
  signal m6809e_oe_d      : std_logic;
  
begin

  -- (cpu_rw_n)
  m6809e_oe_d <= '0' when platform_o.arst = '1' else io_di(21);
  m6809e_oe_reset <= platform_o.arst or platform_o.button(1);
  
	-- Assign signals to IO bus
  io_di <= gpio_i(23 downto 0);
  gpio_o(23 downto 0) <= io_do;
  gpio_o(28) <= platform_o.clk_50M;         gpio_oe(28) <= '1';
  gpio_o(29) <= platform_o.cpu_6809_q;      gpio_oe(29) <= '1';
  gpio_o(30) <= platform_o.arst;            gpio_oe(30) <= '1';
  gpio_o(31) <= platform_o.cpu_6809_e;      gpio_oe(31) <= '1';

	io_do <= "000000000" & 
            platform_o.cpu_6809_firq_n & platform_o.cpu_6809_irq_n & platform_o.cpu_6809_nmi_n & 
            platform_o.cpu_6809_tsc & 
            platform_o.cpu_6809_halt_n & 
            m6809e_oe_reset & m6809e_oe_d &
            platform_o.cpu_6809_d_i;

  gpio_oe(23 downto 0) <= (others => '1') when state = wr else (others => '0');
  
  io_wr <= '0';

	-- State machine
	io_sm : process(state, io_wr)
	begin
		case state is
		when idle =>  next_state <= rd0;
		when wr 	=>	if io_wr = '1' then next_state <= wr; else next_state <= rd0; end if;
		when rd0	=>	if io_wr = '1' then next_state <= wr; else next_state <= rd1; end if;
		when rd1	=>	if io_wr = '1' then next_state <= wr; else next_state <= wr; end if;
		end case;
	end process;

	-- Registers
	reg : process(platform_o.arst, platform_o.clk_50M)
	begin
		if platform_o.arst = '1' then
			state					              <= idle;
      platform_i.cpu_6809_d_o     <= (others => '0');
      platform_i.cpu_6809_a       <= (others => '0');
	    platform_i.cpu_6809_r_wn    <= '0';
      --m6809e_ba     <= '0';
      --m6809e_bs     <= '0';
      --m6809e_busy   <= '0';
      --m6809e_lic    <= '0';
      platform_i.cpu_6809_vma     <= '0';

		elsif rising_edge(platform_o.clk_50M) then
			state <= next_state;

			if state = rd0 then
	      platform_i.cpu_6809_r_wn  <= io_di(21);
        --m6809e_ba     <= io_di(20);
        --m6809e_bs     <= io_di(19);
        --m6809e_busy   <= io_di(18);
        --m6809e_lic    <= io_di(17);
        platform_i.cpu_6809_vma   <= io_di(16);
        platform_i.cpu_6809_a     <= io_di(15 downto 0);
        -- show the PC on the 7-segment display
        seg7(15 downto 0) <= io_di(15 downto 0);
			end if;

			if state = rd1 then
	      platform_i.cpu_6809_r_wn  <= io_di(21);
        --m6809e_ba     <= io_di(20);
        --m6809e_bs     <= io_di(19);
        --m6809e_busy   <= io_di(18);
        --m6809e_lic    <= io_di(17);
        platform_i.cpu_6809_vma   <= io_di(16);
				platform_i.cpu_6809_d_o   <= io_di(7 downto 0);
			end if;

		end if;
	end process;

  gpio_is_custom <= (others => '1');
  gpio_is_not_used <= (others => '0');

end architecture SYN;
