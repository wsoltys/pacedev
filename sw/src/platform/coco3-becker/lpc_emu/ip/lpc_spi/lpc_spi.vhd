library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lpc_spi_controller is
	port
	(
		csi_clockreset_clk		: in std_logic;
		csi_clockreset_reset	: in std_logic;
                	
		avs_s1_chipselect			: in std_logic;
		avs_s1_address        : in std_logic_vector(3 downto 0);
		avs_s1_writedata			: in std_logic_vector(31 downto 0);
		avs_s1_readdata  			: out std_logic_vector(31 downto 0);
		avs_s1_read					  : in std_logic;
		avs_s1_write					: in std_logic;
		avs_s1_waitrequest_n  : out std_logic;
		ins_irq0_irq          : out std_logic;
		
		coe_spi_clk           : out std_logic;
		coe_spi_miso          : in std_logic;
		coe_spi_mosi          : out std_logic;
		coe_spi_ss            : out std_logic
	);
end entity lpc_spi_controller;

architecture SYN of lpc_spi_controller is

  -- alias crappy SOPC names
  alias clk           : std_logic is csi_clockreset_clk;
  alias reset         : std_logic is csi_clockreset_reset;
  alias chipselect    : std_logic is avs_s1_chipselect;
  alias a             : std_logic_vector(3 downto 0) is avs_s1_address;
  alias di            : std_logic_vector(31 downto 0) is avs_s1_writedata;
  alias do            : std_logic_vector(31 downto 0) is avs_s1_readdata;
  alias rd            : std_logic is avs_s1_read;
  alias wr            : std_logic is avs_s1_write;
  alias waitrequest_n : std_logic is avs_s1_waitrequest_n;
  alias irq           : std_logic is ins_irq0_irq;
  alias spi_clk       : std_logic is coe_spi_clk;
  alias spi_miso      : std_logic is coe_spi_miso;
  alias spi_mosi      : std_logic is coe_spi_mosi;
  alias spi_ss        : std_logic is coe_spi_ss;
  
  -- register addresses
  constant aSSPCR0  : std_logic_vector(3 downto 0) := X"0";
  constant aSSPCR1  : std_logic_vector(3 downto 0) := X"1";
  constant aSSPDR   : std_logic_vector(3 downto 0) := X"2";
  constant aSSPSR   : std_logic_vector(3 downto 0) := X"3";
  constant aSSPCPSR : std_logic_vector(3 downto 0) := X"4";
  constant aSSPIMSC : std_logic_vector(3 downto 0) := X"5";
  constant aSSPRIS  : std_logic_vector(3 downto 0) := X"6";
  constant aSSPMIS  : std_logic_vector(3 downto 0) := X"7";
  constant aSSPICR  : std_logic_vector(3 downto 0) := X"8";

  -- registers
  signal rSSPCR0    : std_logic_vector(15 downto 0) := (others => '0');
  signal rSSPCR1    : std_logic_vector(7 downto 0) := (others => '0');
  alias SSE         : std_logic is rSSPCR1(1);
  signal rSSPDR     : std_logic_vector(15 downto 0) := (others => '0');
  signal rSSPSR     : std_logic_vector(7 downto 0) := (others => '0');
  signal rSSPCPSR   : std_logic_vector(7 downto 0) := (others => '0');
  signal rSSPIMSC   : std_logic_vector(7 downto 0) := (others => '0');
  alias TXIM        : std_logic is rSSPIMSC(3);
  alias RXIM        : std_logic is rSSPIMSC(2);
  alias RTIM        : std_logic is rSSPIMSC(1);
  alias RORIM       : std_logic is rSSPIMSC(0);
  signal rSSPRIS    : std_logic_vector(7 downto 0) := (others => '0');
  alias TXRIS       : std_logic is rSSPRIS(3);
  alias RXRIS       : std_logic is rSSPRIS(2);
  alias RTRIS       : std_logic is rSSPRIS(1);
  alias RORRIS      : std_logic is rSSPRIS(0);
  signal rSSPMIS    : std_logic_vector(7 downto 0) := (others => '0');
  alias TXMIS       : std_logic is rSSPMIS(3);
  alias RXMIS       : std_logic is rSSPMIS(2);
  alias RTMIS       : std_logic is rSSPMIS(1);
  alias RORMIS      : std_logic is rSSPMIS(0);
  signal rSSPICR    : std_logic_vector(7 downto 0) := (others => '0');
  alias RTIC        : std_logic is rSSPICR(1);
  alias RORIC       : std_logic is rSSPICR(0);

  signal busy       : std_logic := '0';
  
  -- send FIFO signals
  signal send_fifo_wr         : std_logic := '0';
  signal send_fifo_rd         : std_logic := '0';
  signal send_fifo_q          : std_logic_vector(7 downto 0) := (others => '0');
  signal send_fifo_empty      : std_logic := '0';
  signal send_fifo_full       : std_logic := '0';
  signal send_fifo_used       : std_logic_vector(3 downto 0) := (others => '0');

  -- receive FIFO signals
  signal receive_fifo_wr      : std_logic := '0';
  signal receive_fifo_rd      : std_logic := '0';
  signal receive_fifo_data    : std_logic_vector(7 downto 0) := (others => '0');
  signal receive_fifo_q       : std_logic_vector(7 downto 0) := (others => '0');
  signal receive_fifo_empty   : std_logic := '0';
  signal receive_fifo_full    : std_logic := '0';
  signal receive_fifo_used    : std_logic_vector(3 downto 0) := (others => '0');

  -- internal spi signals
  signal spi_clk_s            : std_logic := '0';
  signal spi_miso_s           : std_logic := '0';
  signal spi_mosi_s           : std_logic := '0';
  signal spi_ss_s             : std_logic := '1';
  
begin

  -- Avalon interface
	process (clk, reset)
		variable rd_r : std_logic := '0';
		variable wr_r : std_logic := '0';
	begin
		if reset = '1' then
			-- clockrate(0) & CPHA(1) & CPOL(0) & FRF(SPI) & DSS(8-bit)
      rSSPCR0 <= X"00" & '1' & '0' & "00" & "0111";
      -- reserved & MS(master) & SSE(disabled) & LBM(normal)
      rSSPCR1 <= X"0" & '0' & '0' & '0' & '0';
			rd_r := '0';
			wr_r := '0';
			waitrequest_n <= '1';
		elsif rising_edge(clk) then
      send_fifo_wr <= '0';      -- default
      receive_fifo_rd <= '0';   -- default
			if chipselect = '1' then
        if rd_r = '0' and rd = '1' then
          -- leading-edge read
          case a is
            when aSSPCR0 =>
              do <= X"0000" & rSSPCR0;
            when aSSPCR1 =>
              do <= X"000000" & rSSPCR1;
            when aSSPDR =>
              do <= X"000000" & receive_fifo_q;
              receive_fifo_rd <= '1';
            when aSSPSR =>
              do <= X"000000" & 
                    "000" & (busy or not send_fifo_empty) & 
                    not receive_fifo_empty & receive_fifo_full &
                    not send_fifo_full & send_fifo_empty;
            when aSSPCPSR =>
              do <= X"000000" & rSSPCPSR;
            when aSSPIMSC =>
              do <= X"000000" & rSSPIMSC;
            when aSSPRIS  =>
              do <= X"000000" & rSSPRIS;
            when aSSPMIS  =>
              do <= X"000000" & rSSPMIS;
            when others =>
              null;
          end case;
        elsif wr_r = '0' and wr = '1' then
          -- leading-edge write
          case a is
            when aSSPCR0 =>
            when aSSPCR1 =>
              rSSPCR1 <= di(rSSPCR1'range);
            when aSSPDR =>
              send_fifo_wr <= '1';
            when aSSPCPSR =>
            when aSSPIMSC =>
            when aSSPICR  =>
            when others =>
              null;
          end case;
        end if;
			end if;
			waitrequest_n <= chipselect;
			rd_r := chipselect and rd;
			wr_r := chipselect and wr;
		end if;
	end process;

  --
  -- interrupt/register logic
  --
  
  -- raw interrupt status register
  RXRIS <= receive_fifo_used(receive_fifo_used'left);   -- half full
  TXRIS <= not send_fifo_used(send_fifo_used'left);     -- half empty

  -- masked interrupt status register
  RXMIS <= RXIM and RXRIS;
  TXMIS <= TXIM and TXRIS;

  irq <= RXMIS or TXMIS;
  
  -- generate the spi clk
  process (clk, reset)
    -- 66/32 = 2.065MHz SPI clock
    variable count : std_logic_vector(4 downto 0) := (others => '0');
  begin
    if reset = '1' then
      count := (others => '0');
    elsif rising_edge(clk) then
      spi_clk_s <= count(count'left);
      count := std_logic_vector(unsigned(count) + 1);
    end if;
  end process;
  
  BLK_SEND_RECV : block
  
    type state_t is (IDLE, SOW, WAIT_SETUP, WAIT_BIT, WAIT_DONE);
    signal state : state_t;
    signal spi_d_o  : std_logic_vector(7 downto 0) := (others => '0');
    
  begin
    PROC_SEND_RECV : process (clk, reset)
      variable spi_clk_r : std_logic := '0';
      variable count : integer range 0 to 7 := 0;
    begin
      if reset = '1' then
        spi_clk_r := '0';
        state <= IDLE;
      elsif rising_edge(clk) then
        busy <= '1';              -- default
        send_fifo_rd <= '0';      -- default
        receive_fifo_wr <= '0';   -- default
        case state is
          when IDLE =>
            busy <= '0';
            spi_ss_s <= '1';  -- default
            -- only if enabled
            if SSE = '1' then
              -- wait for falling edge of spi_clk
              if spi_clk_r = '1' and spi_clk_s = '0' then
                if send_fifo_empty = '0' then
                  spi_ss_s <= '0';
                  state <= SOW;
                end if;
              end if;
            end if;
          when SOW =>
            count := 0;
            -- latch FIFO data, drive SS low
            spi_d_o <= send_fifo_q;
            send_fifo_rd <= '1';
            state <= WAIT_SETUP;
          when WAIT_SETUP =>
            -- wait for rising edge of spi_clk
            if spi_clk_r = '0' and spi_clk_s = '1' then
              -- data setup
              spi_mosi_s <= spi_d_o(spi_d_o'left);
              spi_d_o <= spi_d_o(spi_d_o'left-1 downto 0) & '0';
              state <= WAIT_BIT;
            end if;
          when WAIT_BIT =>
            -- wait for falling edge of spi_clk
            if spi_clk_r = '1' and spi_clk_s = '0' then
              -- latch input bit
              receive_fifo_data <= receive_fifo_data(receive_fifo_data'left-1 downto 0) & spi_miso_s;
              if count = 7 then
                -- latch received byte in FIFO
                receive_fifo_wr <= '1';
                if send_fifo_empty = '0' then
                  state <= SOW;
                else
                  state <= WAIT_DONE;
                end if;
              else
                count := count + 1;
                state <= WAIT_SETUP;
              end if;
            end if;
          when WAIT_DONE =>
            -- wait for rising edge of spi_clk
            if spi_clk_r = '0' and spi_clk_s = '1' then
              -- IDLE state will de-assert SSEL
              state <= IDLE;
            end if;
          when others =>
            state <= IDLE;
        end case;
      	spi_clk_r := spi_clk_s;
      end if;
    end process PROC_SEND_RECV;
    
  end block BLK_SEND_RECV;

  BLK_FIFO : block

    component lpc_spi_fifo IS
      PORT
      (
        clock		: IN STD_LOGIC ;
        data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        rdreq		: IN STD_LOGIC ;
        sclr		: IN STD_LOGIC ;
        wrreq		: IN STD_LOGIC ;
        empty		: OUT STD_LOGIC ;
        full		: OUT STD_LOGIC ;
        q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        usedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
      );
    END component lpc_spi_fifo;

  begin
  
    lpc_send_fifo : lpc_spi_fifo
      port map
      (
        clock		=> clk,
        sclr		=> reset,

        data		=> di(7 downto 0),
        wrreq		=> send_fifo_wr,

        q		    => send_fifo_q,
        rdreq		=> send_fifo_rd,

        empty		=> send_fifo_empty,
        full		=> send_fifo_full,
        usedw		=> send_fifo_used
      );

    lpc_receive_fifo : lpc_spi_fifo
      port map
      (
        clock		=> clk,
        sclr		=> reset,

        data		=> receive_fifo_data,
        wrreq		=> receive_fifo_wr,

        q		    => receive_fifo_q,
        rdreq		=> receive_fifo_rd,

        empty		=> receive_fifo_empty,
        full		=> receive_fifo_full,
        usedw		=> receive_fifo_used
      );

  process (clk, reset)
    variable miso_r : std_logic_vector(1 downto 0) := (others => '0');
    alias miso_unmeta : std_logic is miso_r(miso_r'left);
  begin
    if reset = '1' then
      miso_r := (others => '0');
    elsif rising_edge(clk) then
      spi_miso_s <= miso_unmeta;
      miso_r := miso_r(miso_r'left-1 downto 0) & spi_miso;
    end if;
  end process;
  
  end block BLK_FIFO;
  
  -- drive spi signals
  spi_clk <= spi_clk_s;
  spi_mosi <= spi_mosi_s;
  spi_ss <= spi_ss_s;
  
end SYN;
