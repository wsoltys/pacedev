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
		clock_speed	: integer;
		i2c_speed		: integer := 400000   -- I2C toggle rate (400kHz)
	);
	port
	(
		reset				: in std_logic;
		clk					: in std_logic;
		clk_ena		  : in std_logic;
		timeout_err	: out std_logic;

    -- interface to i2c_sm		
		is_idle     : out std_logic;
		is_ready    : out std_logic;
		last_byte   : in std_logic;
		do_tx       : in std_logic;
		txbyte      : in std_logic_vector(7 downto 0);
		do_rx       : in std_logic;
		rxbyte      : out std_logic_vector(7 downto 0);

    -- I2C physical interface
		scl_i  	    : in std_logic;
		scl_o  	    : out std_logic;
		scl_oe_n    : out std_logic;
		sda_i  	    : in std_logic;
		sda_o  	    : out std_logic;
		sda_oe_n    : out std_logic
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
	constant CR_NACK			: integer := 3;		-- Generate ACK
	constant CR_IACK			: integer := 0;		-- Acknowledge interrupt

	constant prer_int			: integer := clock_speed / (5 * i2c_speed) - 1;
	constant prer					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(prer_int, 16));

  signal i2c_timeout      : std_logic := '0';

	signal tx_first				  : std_logic;

  signal wb_cyc     : std_logic := '0';
  signal wb_stb     : std_logic := '0';
  signal wb_adr     : std_logic_vector(2 downto 0) := (others => '0');
  signal wb_dat_i   : std_logic_vector(7 downto 0) := (others => '0');
  signal wb_dat_o   : std_logic_vector(7 downto 0) := (others => '0');
  signal wb_we      : std_logic := '0';
  signal wb_ack     : std_logic := '0';
                    
begin

  BLK_SM : block
  
    type state_t is ( init, init_1, init_2,
                      idle, ready,
                      tx_byte_go, wait_tx_byte_1, wait_tx_byte_2, tx_byte_done,
                      rx_byte_go, wait_rx_byte_1, wait_rx_byte_2, rx_byte_done,
                      wait_tip_go, wait_tip_ack_go, wait_tip_ack_1, wait_tip_ack_2, tip_ack_fault, tip_ack_timeout,
                      wb_wr_go, wb_rd_go, wb_wait_ack,
                      done );
    signal state        : state_t := idle;
    signal ok_state     : state_t := idle;
    signal ok_state_r   : state_t := idle;
    
  begin
    
    process (clk, reset)
      subtype timeout_t is integer range 0 to 255;
      variable timeout : timeout_t := timeout_t'low;
      variable last_byte_v : std_logic := '0';
    begin
      if reset = '1' then
        last_byte_v := '0';
        state <= init;
        is_idle <= '0';
        is_ready <= '0';
        i2c_timeout <= '0';
      elsif rising_edge(clk) then

        -- assign defaults
        is_idle <= '0';
        is_ready <= '0';
        
        case state is

          --
          -- INIT
          --
          
          when init =>
            wb_adr <= I2C_PRERlo;
            wb_dat_i <= prer(7 downto 0);
            ok_state <= init_1;
            state <= wb_wr_go;
          when init_1 =>
            wb_adr <= I2C_PRERhi;
            wb_dat_i <= prer(15 downto 8);
            ok_state <= init_2;
            state <= wb_wr_go;
          when init_2 =>
            wb_adr <= I2C_CTR;
            wb_dat_i <= X"80";
            ok_state <= idle;
            state <= wb_wr_go;
                    
          when idle =>
            is_idle <= '1';
            is_ready <= '1';
            tx_first <= '1';
            last_byte_v := last_byte;
            if do_tx = '1' then
              state <= tx_byte_go;
            elsif do_rx = '1' then
              state <= rx_byte_go;            
            end if;

          when ready =>
            is_ready <= '1';
            tx_first <= '0';
            last_byte_v := last_byte;
            if do_tx = '1' then
              state <= tx_byte_go;
            elsif do_rx = '1' then
              state <= rx_byte_go;            
            end if;
            
          --        
          -- TX BYTE
          --
          
          when tx_byte_go =>
            wb_adr <= I2C_TXR;
            wb_dat_i <= txbyte;
            ok_state <= wait_tx_byte_1;
            state <= wb_wr_go;
          when wait_tx_byte_1 =>
            wb_adr <= I2C_CR;
            wb_dat_i <= (CR_STA => tx_first, CR_STO => last_byte_v, CR_WR => '1', others => '0');
            ok_state <= wait_tx_byte_2;
            state <= wb_wr_go;
          when wait_tx_byte_2 =>
            ok_state <= tx_byte_done;
            state <= wait_tip_ack_go;
          when tx_byte_done =>
            if last_byte_v = '1' then
              state <= idle;
            else
              state <= ready;
            end if;
                        
          --        
          -- RX BYTE
          --
          
          when rx_byte_go =>
            wb_adr <= I2C_CR;
            wb_dat_i <= (CR_STO => last_byte_v, CR_RD => '1', CR_NACK => last_byte_v, others => '0');
            ok_state <= wait_rx_byte_1;
            state <= wb_wr_go;
          when wait_rx_byte_1 =>
            ok_state <= wait_rx_byte_2;
            state <= wait_tip_go;
          when wait_rx_byte_2 =>
            wb_adr <= I2C_RXR;
            ok_state <= rx_byte_done;
            state <= wb_rd_go;
          when rx_byte_done =>
            rxbyte <= wb_dat_o;
            if last_byte_v = '1' then
              state <= idle;
            else
              state <= ready;
            end if;
                        
          --        
          -- WAIT TIP AND ACK
          --
          
          when wait_tip_go | wait_tip_ack_go =>
            timeout := timeout_t'high;
            i2c_timeout <= '0';
            ok_state_r <= ok_state;
            state <= wait_tip_ack_1;
          when wait_tip_ack_1 =>
            if timeout = 0 then
              state <= tip_ack_timeout;
            else
              --timeout := timeout - 1;
              wb_adr <= I2C_SR;
              ok_state <= wait_tip_ack_2;
              state <= wb_rd_go;
            end if;
          when wait_tip_ack_2 =>
            if wb_dat_o(SR_TIP) = '1' then
              state <= wait_tip_ack_1;
            -- if expecting and ACK, and don't get it
            elsif wb_dat_i(CR_NACK) /= '1' and wb_dat_o(SR_RxACK) /= '0' then
              state <= tip_ack_fault;
            else
              state <= ok_state_r;
            end if;
          when tip_ack_fault | tip_ack_timeout =>
            i2c_timeout <= '1';
            state <= idle;

          --
          -- WISHBONE
          --
          
          when wb_wr_go =>
            wb_cyc <= '1';
            wb_stb <= '1';
            wb_we <= '1';
            state <= wb_wait_ack;
          when wb_rd_go =>
            wb_cyc <= '1';
            wb_stb <= '1';
            wb_we <= '0';
            state <= wb_wait_ack;
          when wb_wait_ack =>
            if wb_ack = '1' then
              wb_cyc <= '0';
              wb_stb <= '0';
              wb_we <= '0';
              state <= ok_state;
            end if;
                                                    
          when others =>
            state <= idle;
        end case;
      end if;
    end process;
  
  end block BLK_SM;

	i2c_master : i2c_master_top
		generic map (
			ARST_LVL => '1'
		) port map (
			-- wishbone signals
			wb_clk_i  => clk,
			wb_rst_i  => '0',
			arst_i    => reset,
			wb_adr_i  => wb_adr,
			wb_dat_i  => wb_dat_i,
			wb_dat_o  => wb_dat_o,
			wb_we_i   => wb_we,
			wb_stb_i  => wb_stb,
			wb_cyc_i  => wb_cyc,
			wb_ack_o  => wb_ack,
			wb_inta_o => open,

			-- i2c lines
			scl_pad_i     => scl_i,
			scl_pad_o     => scl_o,
			scl_padoen_o  => scl_oe_n,
			sda_pad_i     => sda_i,
			sda_pad_o     => sda_o,
			sda_padoen_o  => sda_oe_n
		);

end SYN;
