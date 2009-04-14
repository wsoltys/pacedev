------------------------------------------------------------------------------
-- Copyright (C) 2005 Aristocrat Technologies Australia
-------------------------------------------------------------------------------
-- Title      : MK7 Core FPGA Implementation
-- Project    : MK7 Main Board FPGA Development
-------------------------------------------------------------------------------
-- File       : atahost_dma.vhd
-- Author     : Andrew Betzis <ab@vl.com.au>
-- Company    : Virtual Logic Pty Ltd for Aristocrat Leisure Industries
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: New IDE DMA implemenation for OpenCores ATA controller
--              uses a seperate WB bus for DMA data paths
--              TX and RX FIFO
--              timing is based on only two parameters now Td and Teoc
--              Calculation is as follows
--                take Td from data sheet
--                Td register = CEIL(Td / clock period) -1
--                calculate residual cycle time
--                Teoc = To [cycle time] - (Td register+1)*clock period
--                Teoc register = CEIL(Teoc / clock period) -1
-------------------------------------------------------------------------------
-- Data sheets: 
-------------------------------------------------------------------------------
-- Notes      : 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-08-02  A01      ab   Created
-------------------------------------------------------------------------------


---------------------------
-- DMA Access Controller --
---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity ATAHOST_DMA is
	port(
		clk : in std_logic;                           -- master clock
		nReset : in std_logic;                        -- asynchronous active low reset
		rst : in std_logic;                           -- synchronous active high reset

		IDEctrl_rst : in std_logic;                   -- IDE control register bit0, 'rst'

    -- WISHBONE SLAVE DMA port signals
    wb_dma_cyc_i : in std_logic;                       -- valid bus cycle input
    wb_dma_stb_i : in std_logic;                       -- strobe/core select input
    wb_dma_ack_o : out std_logic;                      -- strobe acknowledge output
    wb_dma_rty_o : out std_logic;                      -- retry output
    wb_dma_err_o : out std_logic;                      -- error output
    wb_dma_dat_i : in std_logic_vector(31 downto 0);   -- Databus in
    wb_dma_dat_o : out std_logic_vector(31 downto 0);  -- Databus out
    wb_dma_sel_i : in std_logic_vector(3 downto 0);    -- Byte select signals
    wb_dma_we_i  : in std_logic;                       -- Write enable input

    wb_dma_req_o : out std_logic;                      -- request a DMA burst
    wb_dma_done_i: in std_logic;                       -- DMA burst done
		
		SelDev : in std_logic;                        -- Selected device	
    busy    : out std_logic;                   -- we are doing a DMA access

		dev0_Td,
		dev0_Teoc : in unsigned(7 downto 0);          -- DMA mode timing device 0
		dev1_Td,
		dev1_Teoc : in unsigned(7 downto 0);          -- DMA mode timing device 1

		DMActrl_DMAen,
		DMActrl_dir,
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : in std_logic;                -- control register settings

		TxFull : buffer std_logic;                    -- DMA transmit buffer full
		RxEmpty : buffer std_logic;                   -- DMA receive buffer empty
		RxFull : out std_logic;                       -- DMA receive buffer full

		DMARQ : in std_logic;                         -- ATA devices request DMA transfer

		DDi : in std_logic_vector(15 downto 0);       -- Data from ATA DD bus
		DDo : out std_logic_vector(15 downto 0);      -- Data towards ATA DD bus

		DIOR,
		DIOW : buffer std_logic 
	);
end entity ATAHOST_DMA;
 
architecture SYN of ATAHOST_DMA is

type STATE_TYPE is (IDLE, WR_FIRST_WORD, WR_FIRST_OFF, WR_LAST_WORD,
                  RD_FIRST_WORD, RD_FIRST_OFF, RD_LAST_WORD);

signal tim_done       : std_logic;    -- timer expired
signal tim_ld_td_st   : std_logic;    -- load timer for td period
signal tim_ld_teoc_st : std_logic;    -- Teoc
signal state          : STATE_TYPE;
signal state_next     : STATE_TYPE;
signal tx_do          : std_logic_vector(31 downto 0); -- output from transmit store
signal tx_empty       : std_logic;    -- transmit store empty
signal tx_full        : std_logic;    
signal tx_wr          : std_logic;    -- write to tx stream
signal tx_rd          : std_logic;    -- read data out of fifo
signal rx_di          : std_logic_vector(31 downto 0); -- assembled dword from ide port
signal rx_empty       : std_logic;    -- transmit store empty
signal rx_full        : std_logic;    
signal rx_full_almost        : std_logic;    -- one less than full to ensure we dont start a read while fif is being written from previous
signal rx_wr          : std_logic;    -- write to rx fifo
signal rx_ack         : std_logic;    -- ack data out of fifo (look ahead fifo)
signal reset_async    : std_logic;    -- async reset
signal cycle_write_first    : std_logic;    -- doing write of forst word
signal byte_swap      : std_logic;    -- need to swap bytes
signal write          : std_logic;    -- doing a write to IDE

signal req_active     : std_logic;  -- request from drive is to be acted apon


component ATAHOST_FIFO_RX
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wrreq		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		almost_full		: OUT STD_LOGIC 
	);
end component;

component ATAHOST_FIFO_TX
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wrreq		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC 
	);
end component;

begin
  -- down timer to time each phase, period is setting
  CYCLETIMER: process (clk, nReset)
    variable delay_count_v : integer;
  begin
		if (nReset = '0') then
        delay_count_v := 0;
    elsif  rising_edge(clk) then
      if rst = '1' then
        delay_count_v := 0;
      else
        -- pre load counter based on strobes
        if    (tim_ld_td_st = '1') then
  				if (SelDev = '1') then
            delay_count_v := conv_integer(unsigned(dev1_Td));
				  else                     
            delay_count_v := conv_integer(unsigned(dev0_Td));
          end if;
        elsif (tim_ld_teoc_st = '1') then
  				if (SelDev = '1') then
            delay_count_v := conv_integer(unsigned(dev1_Teoc));
				  else                     
            delay_count_v := conv_integer(unsigned(dev0_Teoc));
          end if;
        elsif delay_count_v /= 0 then
          delay_count_v := delay_count_v - 1; -- coutn if not expired
        end if;

        if delay_count_v = 0 then -- detect 0 count load
          tim_done <= '1';
        else   
          tim_done <= '0';
        end if;
      end if;
    end if;
  end process;

  -- state machine
  STATE_TRANS: process (clk, nReset)
  begin
		if (nReset = '0') then
        state <= IDLE;
    elsif  rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
      else
        state <= state_next;
      end if;
    end if;
  end process;

  -- state decode
  STATE_ASSIGN: process (state, tim_done, req_active, write, tx_empty, rx_full_almost)
  begin
    -- init defaults
      tim_ld_td_st <= '0';
      tim_ld_teoc_st <= '0';

      state_next <= state;    -- default, spin in current state

      case state is
      when IDLE =>
        -- wait for timer to expire from previous cycle and for dma flag
        if (tim_done = '1') and (req_active = '1')  then
          -- can we do a write
          if write = '1' and tx_empty = '0' then 
            -- there is someting to send
            state_next <= WR_FIRST_WORD;
            tim_ld_td_st <= '1';
          elsif write = '0' and rx_full_almost = '0' then
            -- there is room to receive
            state_next <= RD_FIRST_WORD;
            tim_ld_td_st <= '1';
          end if;
        end if;
      
      -- do two write pulses for first and last word
      -- we could also see if DMARQ has gone off and abort the cycle, but this could shorten the R/w pulse withs and be bad
      when WR_FIRST_WORD =>
        -- wait for write pulse to finish
        if tim_done = '1' then
          state_next <= WR_FIRST_OFF;
          tim_ld_teoc_st <= '1';
        end if;
      when WR_FIRST_OFF =>
        if tim_done = '1' then
          state_next <= WR_LAST_WORD;
          tim_ld_td_st <= '1';
        end if;
      when WR_LAST_WORD =>
        if tim_done = '1' then
          state_next <= IDLE;   -- go to idle but start timer
          tim_ld_teoc_st <= '1';
        end if;
        
      -- reads
      when RD_FIRST_WORD =>
        -- wait for write pulse to finish
        if tim_done = '1' then
          state_next <= RD_FIRST_OFF;
          tim_ld_teoc_st <= '1';
        end if;
      when RD_FIRST_OFF =>
        if tim_done = '1' then
          state_next <= RD_LAST_WORD;
          tim_ld_td_st <= '1';
        end if;
      when RD_LAST_WORD =>
        if tim_done = '1' then
          state_next <= IDLE; -- return to idle but start timer
          tim_ld_teoc_st <= '1';
        end if;
      when others =>
        state_next <= IDLE; -- catch a fall
      end case;
  end process;
  
  DELAY_GEN: process(clk)
  begin
    if  rising_edge(clk) then
      -- delay activation to there is a 1 clock delay between DMA_ACK and first R/W pulse although Ti = 0 ns to be sure
      req_active <= DMARQ and DMActrl_DMAen;  
    end if;
  end process;

	
	-- RX fifo, look ahead fifo,
  -- high water mark is set on below full to ensure that we dont start new read before previosu read's data has propogated the full flag (if full)
  ATAHOST_FIFO_RX_1 : ATAHOST_FIFO_RX PORT MAP (
		data	 => rx_di,
		wrreq	 => rx_wr,
		rdreq	 => rx_ack,
		clock	 => clk,
		aclr	 => IDEctrl_rst,
		q	 => wb_dma_dat_o,
		full	 => rx_full,
		empty	 => rx_empty,
		almost_full	 => rx_full_almost
	);

	-- TX fifo, this fifo needs a read before data is valid
  ATAHOST_FIFO_TX_1 : ATAHOST_FIFO_TX PORT MAP (
		data	 => wb_dma_dat_i,
		wrreq	 => tx_wr,
		rdreq	 => tx_rd,
		clock	 => clk,
		aclr	 => IDEctrl_rst,
		q	 => tx_do,
		full	 => tx_full,
		empty	 => tx_empty
	);


  write <= DMActrl_dir;

  -- data register access
  -- respond to any address as we only have the dma controller
  tx_wr <= wb_dma_cyc_i and wb_dma_stb_i and wb_dma_we_i and not tx_full;
	rx_ack <= wb_dma_cyc_i and wb_dma_stb_i and not wb_dma_we_i and not rx_empty;

	-- WB interface
	wb_dma_ack_o <= tx_wr or rx_ack;   -- ack straight away
  wb_dma_rty_o <= '0';
  wb_dma_err_o <= '0';
  
  -- request a DMA if (writing and TX empty, or reading a RX not empty)
  -- drop DMA request *only* on receipt of an ACK from the DMA controller
  -- - ensures req active for entire chunk (DMA cycle)
  -- - note that we must give ACK processing priority
  REQ_GEN:process (clk)
  begin
    if rising_edge (clk) then
      if DMActrl_DMAen = '1' then
        if wb_dma_done_i = '1' then
          wb_dma_req_o <= '0';
        elsif (((write and tx_empty) or (not write and not rxempty))) = '1' then
          wb_dma_req_o <= '1';
        end if;
      end if;
    end if;
  end process;
	

  -- we are in progress if not in IDLE or in IDLE ans timer has not yet expired
  busy <= '1' when (state /= IDLE) or (tim_done /= '1') else '0';

	
	-- ide signals
  DIOR <= '1' when (state = RD_FIRST_WORD) or (state = RD_LAST_WORD) else '0';
  DIOW <= '1' when (state = WR_FIRST_WORD) or (state = WR_LAST_WORD) else '0';

  -- decode when we are in write cycles
  cycle_write_first <= '1' when (state = WR_FIRST_WORD) or (state = WR_FIRST_OFF) else '0';

  -- pick the correct byte swap
	byte_swap <=	(not SelDev and DMActrl_BeLeC0) or (SelDev and DMActrl_BeLeC1);

  -- first word is lo part of WB bus in non byte swapped mode     
  DDo( 7 downto 0) <= tx_do(31 downto 24) when byte_swap = '1' and cycle_write_first = '1' else
                      tx_do(15 downto  8) when byte_swap = '1' and cycle_write_first = '0' else
                      tx_do( 7 downto  0) when byte_swap = '0' and cycle_write_first = '1' else
                      tx_do(23 downto 16) when byte_swap = '0' and cycle_write_first = '0';
  DDo(15 downto 8) <= tx_do(23 downto 16) when byte_swap = '1' and cycle_write_first = '1' else
                      tx_do( 7 downto  0) when byte_swap = '1' and cycle_write_first = '0' else
                      tx_do(15 downto  8) when byte_swap = '0' and cycle_write_first = '1' else
                      tx_do(31 downto 24) when byte_swap = '0' and cycle_write_first = '0';
  
  -- ack data out of tx fifo at end of cycle
  tx_rd <= '1' when (state = IDLE) and (state_next = WR_FIRST_WORD) else '0'; 
  
	TxFull <= tx_full;
	RxEmpty <= rx_empty;
	RxFull <= rx_full;

                        
  -- received data from cf
  -- latch first and last word and then write to FIFO,
  -- note that as OFF time will be 1+ clocks there is time to pipleline the write to fifo
  -- need to gen strobe to latch dat at end of read pulse
  -- note read pulse is pipelined by 1 clock outside this module, so data is valid on next clock after read pulse
  -- so strobe on transition to OFF state for last word
	-- ide receive register
	RXREG: process(clk)
		variable reg_v : std_logic_vector(31 downto 0);
		variable  rd_first_word_v, rd_first_word_del_v  : std_logic;    -- delay of the current states
		variable  rd_last_word_v, rd_last_word_del_v  : std_logic;
		
	begin
    -- first word strobe    
		if rising_edge(clk) then

      -- decode the state
      if state = RD_FIRST_WORD then
        rd_first_word_v := '1';
      else 
        rd_first_word_v := '0';
      end if;
      -- look for state ending
      if rd_first_word_v = '0' and rd_first_word_del_v ='1' then
        -- just got out of thsi state, latch the data bus and the DIOR/DIOW and 1 clock delayed so data is 1 clock delayed
        if byte_swap = '1' then
          reg_v(15 downto 8) := DDi(7 downto 0);
          reg_v( 7 downto 0) := DDi(15 downto 8);
        else
          reg_v(15 downto 0) := DDi(15 downto 0);
        end if;
      end if;        
      rd_first_word_del_v := rd_first_word_v;
      
      if state = RD_LAST_WORD then
        rd_last_word_v := '1';
      else 
        rd_last_word_v := '0';
      end if;
      if rd_last_word_v = '0' and rd_last_word_del_v ='1' then
        -- last word
        if byte_swap = '1' then
          reg_v(31 downto 24) := DDi(7 downto 0);
          reg_v(23 downto 16) := DDi(15 downto 8);
        else
          reg_v(31 downto 16) := DDi(15 downto 0);
        end if;
      end if;        

		  -- write to the fifo 1 clock after the register is full
		  if rd_last_word_del_v = '1' and rd_last_word_v = '0'  then
		    rx_wr <= '1';
      else
        rx_wr <= '0';
      end if;

      rd_last_word_del_v := rd_last_word_v;
    end if;
    rx_di <= reg_v;
  end process;
		
end architecture SYN;

