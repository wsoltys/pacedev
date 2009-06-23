--
-- Small state machine to seed DVO I2C registers after reset
--
-- prescale = 25MHz / 5 * (100 KHz) - 1 = 0x0031
--
-- Loads I2C master registers:
-- PRERlo (0x00) <= 0x31
-- PRERhi (0x01) <= 0x00
-- CTR    (0x02) <= 0x80
--
-- Loads DVI registers:
-- CTL_1_MODE (0x08) <= 0xFF	-- Enable transceiver
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library altera;
--use altera.altera_syn_attributes.all;

entity i2c_sm is
	generic
	(
		clock_speed	: integer := 33333333;	-- Input clock speed (Hz)
		i2c_speed		: integer := 2000000			-- I2C toggle rate (Hz)
	);
	port
	(
		reset				: in std_logic;
		clk					: in std_logic;
		clk_ena		  : in std_logic;
		timeout_err	: out std_logic;

    -- interface to i2c_sm		
		is_idle     : out std_logic;
		ready       : out std_logic;
		last_byte   : in std_logic;
		do_tx       : in std_logic;
		txbyte      : in std_logic_vector(7 downto 0);

    -- I2C physical interface
		vo_scl			: inout std_logic;
		vo_sda			: inout std_logic
	);
end entity i2c_sm;

architecture SYN of i2c_sm is

	component i2c_master_top is
		generic(
			ARST_LVL : std_logic := '0'                   -- asynchronous reset level
		);
		port (
			-- wishbone signals
			wb_clk_i  : in  std_logic;                    -- master clock input
			wb_rst_i  : in  std_logic := '0';             -- synchronous active high reset
			arst_i    : in  std_logic := not ARST_LVL;    -- asynchronous reset
			wb_adr_i  : in  std_logic_vector(2 downto 0); -- lower address bits
			wb_dat_i  : in  std_logic_vector(7 downto 0); -- Databus input
			wb_dat_o  : out std_logic_vector(7 downto 0); -- Databus output
			wb_we_i   : in  std_logic;	              -- Write enable input
			wb_stb_i  : in  std_logic;                    -- Strobe signals / core select signal
			wb_cyc_i  : in  std_logic;	              -- Valid bus cycle input
			wb_ack_o  : out std_logic;                    -- Bus cycle acknowledge output
			wb_inta_o : out std_logic;                    -- interrupt request output signal

			-- i2c lines
			scl_pad_i     : in  std_logic;                -- i2c clock line input
			scl_pad_o     : out std_logic;                -- i2c clock line output
			scl_padoen_o  : out std_logic;                -- i2c clock line output enable, active low
			sda_pad_i     : in  std_logic;                -- i2c data line input
			sda_pad_o     : out std_logic;                -- i2c data line output
			sda_padoen_o  : out std_logic                 -- i2c data line output enable, active low
		);
	end component i2c_master_top;

  constant SIM_DELAY    : time := 2 ns;
  
	constant DEV_ADDR_RD	: std_logic_vector(7 downto 0) := X"71";
	constant DEV_ADDR_WR	: std_logic_vector(7 downto 0) := X"70";

	constant TFP410_CTL_1_MODE	: std_logic_vector(7 downto 0) := X"08";

	constant I2C_PRERlo		: std_logic_vector(2 downto 0) := "000";
	constant I2C_PRERhi		: std_logic_vector(2 downto 0) := "001";
	constant I2C_CTR			: std_logic_vector(2 downto 0) := "010";
	constant I2C_TXR			: std_logic_vector(2 downto 0) := "011";
	constant I2C_RXR			: std_logic_vector(2 downto 0) := "011";
	constant I2C_CR				: std_logic_vector(2 downto 0) := "100";
	constant I2C_SR				: std_logic_vector(2 downto 0) := "100";

	constant SR_RxACK			: integer := 7;		-- Received ACK
	constant SR_TIP				: integer := 1;		-- Transfer in progress

	constant CR_STA				: integer := 7;		-- Generate start bit
	constant CR_STO				: integer := 6;		-- Generate stop bit
	constant CR_RD				: integer := 5;		-- Perform read
	constant CR_WR				: integer := 4;		-- Perform write
	constant CR_ACK				: integer := 3;		-- Generate ACK
	constant CR_IACK			: integer := 0;		-- Acknowledge interrupt

	constant prer_int			: integer := clock_speed / i2c_speed - 1;
	constant prer					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(prer_int, 16));

	signal scl_pad_i     	: std_logic;                -- i2c clock line input
	signal scl_pad_o     	: std_logic;                -- i2c clock line output
	signal scl_padoen_o  	: std_logic;                -- i2c clock line output enable, active low
	signal sda_pad_i     	: std_logic;                -- i2c data line input
	signal sda_pad_o     	: std_logic;                -- i2c data line output
	signal sda_padoen_o  	: std_logic;                -- i2c data line output enable, active low

	signal i2addr					: std_logic_vector(2 downto 0);
	signal i2addr_r				: std_logic_vector(2 downto 0);
	signal i2dat_i				: std_logic_vector(7 downto 0);
	signal i2dat_i_r			: std_logic_vector(7 downto 0);
	signal i2dat_o				: std_logic_vector(7 downto 0);
	signal i2dat_o_r			: std_logic_vector(7 downto 0);
	signal i2we						: std_logic;
	signal i2stb					: std_logic;
	signal i2cyc					: std_logic;
	signal i2ack					: std_logic;
	signal i2int					: std_logic;

	--signal is_idle				: std_logic;	-- I2C state machine is idle (ready for command)
	--signal ready					: std_logic;	-- Ready to tx/rx next byte

	--signal last_byte			: std_logic;	-- Last byte to tx/rx
	--signal do_tx					: std_logic;	-- Initiate a tx
	signal tx_first				: std_logic;	-- First byte of transmit
	--signal txbyte					: std_logic_vector(7 downto 0);

begin

	i2c_sm : block
		type i2_state_t is (i2_init, i2_clklo, i2_clkhi, i2_ctl, i2_idle, i2_setreg, i2_getreg, i2_tx, i2_txcmd, i2_txwait, i2_txcheck, i2_fault);

		signal state : i2_state_t;
	begin

		-- I2C wishbone state machine combinatorial
		loadi2c_comb : process(state, txbyte, tx_first, last_byte, i2dat_i_r)
		begin
			i2addr <= (others => 'X');
			i2dat_o <= (others => 'X');
			is_idle <= '0';
			ready <= '0';
			i2stb <= '0';
			i2cyc <= '0';
			i2we <= '1';
			timeout_err <= '0';

			case state is
			when i2_init =>

			when i2_clklo =>		-- Set I2C clock prescalar low
				i2addr <= I2C_PRERlo after SIM_DELAY;
				i2dat_o <= prer(7 downto 0) after SIM_DELAY;

			when i2_clkhi =>		-- Set I2C clock prescalar high
				i2addr <= I2C_PRERhi after SIM_DELAY;
				i2dat_o <= prer(15 downto 8) after SIM_DELAY;

			when i2_ctl =>			-- Set I2C control reg
				i2addr <= I2C_CTR after SIM_DELAY;
				i2dat_o <= X"80" after SIM_DELAY;

			when i2_idle =>			-- Wait for I2C transfer
				is_idle	<= '1' after SIM_DELAY;
				ready <= '1' after SIM_DELAY;

			when i2_tx =>				-- Load I2C tx byte
				i2addr <= I2C_TXR after SIM_DELAY;
				i2dat_o <= txbyte after SIM_DELAY;

			when i2_txcmd =>		-- Set command to send byte
				i2addr <= I2C_CR after SIM_DELAY;
				i2dat_o <= (CR_STA => tx_first, CR_STO => last_byte, CR_WR => '1', others => '0') after SIM_DELAY;

			when i2_txwait =>		-- Read status to see if TX is complete
				i2addr <= I2C_SR after SIM_DELAY;

			when i2_txcheck =>	-- Check status to see if TX is complete
				if i2dat_i_r(SR_TIP) = '0' and i2dat_i_r(SR_RxACK) = '0' then
					ready <= '1' after SIM_DELAY;
				end if;

			when i2_setreg =>		-- Set I2C core register
				i2stb <= '1' after SIM_DELAY;
				i2cyc <= '1' after SIM_DELAY;

			when i2_getreg =>		-- Get I2C core register
				i2stb <= '1' after SIM_DELAY;
				i2cyc <= '1' after SIM_DELAY;
				i2we <= '0' after SIM_DELAY;

			when i2_fault =>
				timeout_err <= '1' after SIM_DELAY;
			end case;
		end process loadi2c_comb;

		-- I2C wishbone state machine registers
		loadi2c_reg : process(clk, reset)
			variable next_state : i2_state_t;
			variable ok_state : i2_state_t;
			variable timeout : integer := 0;
		begin
			if reset = '1' then
				state <= i2_init;
				tx_first <= '1';
				i2dat_i_r <= (others => '0');
				timeout := 255;

			elsif rising_edge(clk) then
				next_state := state;
				if state /= i2_setreg and state /= i2_getreg then
					i2addr_r <= i2addr;
					i2dat_o_r <= i2dat_o;
				end if;

				case state is
				when i2_init =>
					next_state := i2_clklo;

				when i2_clklo =>
					next_state := i2_setreg;
					ok_state := i2_clkhi;

				when i2_clkhi =>
					next_state := i2_setreg;
					ok_state := i2_ctl;

				when i2_ctl =>
					next_state := i2_setreg;
					ok_state := i2_idle;

				when i2_idle =>
					tx_first <= '1';
					if do_tx = '1' then
						next_state := i2_tx;
					end if;

				when i2_tx =>
					next_state := i2_setreg;
					ok_state := i2_txcmd;

				when i2_txcmd =>
					next_state := i2_setreg;
					ok_state := i2_txwait;

				when i2_txwait =>
					next_state := i2_getreg;
					ok_state := i2_txcheck;

				when i2_txcheck =>
					tx_first <= '0';
					if i2dat_i_r(SR_TIP) = '1' then
						next_state := i2_txwait;
					else
						if i2dat_i_r(SR_RxACK) = '0' then
							if do_tx = '1' then
								next_state := i2_tx;
							else
								next_state := i2_idle;
							end if;
						else
							next_state := i2_fault;
						end if;
					end if;

				when i2_fault =>

				when i2_setreg =>
					if i2ack = '1' then
						next_state := ok_state;
					elsif timeout = 0 then
						next_state := i2_fault;
					end if;

				when i2_getreg =>
					if i2ack = '1' then
						i2dat_i_r <= i2dat_i;		-- Latch read data
						next_state := ok_state;
					elsif timeout = 0 then
						next_state := i2_fault;
					end if;

				end case;

				if (state /= i2_setreg and next_state = i2_setreg) or (state /= i2_getreg and next_state = i2_getreg) then
					timeout := 255;
				elsif timeout > 0 then
					timeout := timeout - 1;
				end if;

				state <= next_state;
			end if;
		end process loadi2c_reg;

	end block i2c_sm;

  --
  --  COMPONENT INSTANTIATION
  --
  
	i2c_master : i2c_master_top
		generic map (
			ARST_LVL => '1'
		) port map (
			-- wishbone signals
			wb_clk_i  => clk,
			wb_rst_i  => '0',
			arst_i    => reset,
			wb_adr_i  => i2addr_r,
			wb_dat_i  => i2dat_o_r,
			wb_dat_o  => i2dat_i,
			wb_we_i   => i2we,
			wb_stb_i  => i2stb,
			wb_cyc_i  => i2cyc,
			wb_ack_o  => i2ack,
			wb_inta_o => i2int,

			-- i2c lines
			scl_pad_i     => scl_pad_i,
			scl_pad_o     => scl_pad_o,
			scl_padoen_o  => scl_padoen_o,
			sda_pad_i     => sda_pad_i,
			sda_pad_o     => sda_pad_o,
			sda_padoen_o  => sda_padoen_o
		);

	vo_scl <= scl_pad_o when scl_padoen_o = '0' else 'Z';
	scl_pad_i <= to_x01(vo_scl);
	vo_sda <= sda_pad_o when sda_padoen_o = '0' else 'Z';
	sda_pad_i <= to_x01(vo_sda);
  
end SYN;
