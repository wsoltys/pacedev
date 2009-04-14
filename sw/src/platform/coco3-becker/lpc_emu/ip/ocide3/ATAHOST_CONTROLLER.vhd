---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  ATA/ATAPI-5 Host controller (OCIDEC-3)                     ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2001, 2002 Richard Herveille                  ----
----                          richard@asics.ws                   ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------

-- rev.: 1.0 march 8th, 2001. Initial release
--
--  CVS Log
--
--  $Id: atahost_controller.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_controller.vhd,v $
--               Revision 1.1  2002/02/18 14:32:12  rherveille
--               renamed all files to 'atahost_***.vhd'
--               broke-up 'counter.vhd' into 'ud_cnt.vhd' and 'ro_cnt.vhd'
--               changed resD input to generic RESD in ud_cnt.vhd
--               changed ID input to generic ID in ro_cnt.vhd
--               changed core to reflect changes in ro_cnt.vhd
--               removed references to 'count' library
--               changed IO names
--               added disclaimer
--               added CVS log
--               moved registers and wishbone signals into 'atahost_wb_slave.vhd'
--


--  ab 27/7 changed dma interface and handling

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ATAHOST_CONTROLLER is
	generic(
		TWIDTH : natural := 8;                   -- counter width

		PIO_mode0_T1 : natural := 254; 
		PIO_mode0_T2 : natural := 254; 
		PIO_mode0_T4 : natural := 254; 
		PIO_mode0_Teoc : natural := 254
	);
	port(
		clk : in std_logic;  		                    	  -- master clock in
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_IDEen,
		IDEctrl_rst,
		IDEctrl_ppen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;                 -- control register settings

		a : in unsigned(3 downto 0);                  -- address input
		d : in std_logic_vector(31 downto 0);         -- data input
		we : in std_logic;                            -- write enable input '1'=write, '0'=read

		-- PIO registers
		PIO_cmdport_T1,
		PIO_cmdport_T2,
		PIO_cmdport_T4,
		PIO_cmdport_Teoc : in unsigned(7 downto 0);
		PIO_cmdport_IORDYen : in std_logic;           -- PIO compatible timing settings
	
		PIO_dport0_T1,
		PIO_dport0_T2,
		PIO_dport0_T4,
		PIO_dport0_Teoc : in unsigned(7 downto 0);
		PIO_dport0_IORDYen : in std_logic;            -- PIO data-port device0 timing settings

		PIO_dport1_T1,
		PIO_dport1_T2,
		PIO_dport1_T4,
		PIO_dport1_Teoc : in unsigned(7 downto 0);
		PIO_dport1_IORDYen : in std_logic;            -- PIO data-port device1 timing settings

		PIOsel : in std_logic;                        -- PIO controller select
		PIOack : out std_logic;                       -- PIO controller acknowledge
		PIOq : out std_logic_vector(15 downto 0);     -- PIO data out
		PIOtip : buffer std_logic;                    -- PIO transfer in progress
		PIOpp_full : out std_logic;                   -- PIO Write PingPong full

		-- DMA registers
		DMA_dev0_Td,
		DMA_dev0_Teoc : in unsigned(7 downto 0);      -- DMA timing settings for device0

		DMA_dev1_Td,
		DMA_dev1_Teoc : in unsigned(7 downto 0);      -- DMA timing settings for device1

		DMActrl_DMAen,
		DMActrl_dir,
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : in std_logic;                -- DMA settings

		DMAtip : buffer std_logic;                    -- DMA transfer in progress
		DMA_dmarq : out std_logic;                    -- Synchronized ATA DMARQ line

		DMATxFull : buffer std_logic;                 -- DMA transmit buffer full
		DMARxEmpty : buffer std_logic;                -- DMA receive buffer empty

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


		-- ATA signals
		RESETn	: out std_logic;
		DDi	: in std_logic_vector(15 downto 0);
		DDo : out std_logic_vector(15 downto 0);
		DDoe : out std_logic;
		DA	: out unsigned(2 downto 0);
		CS0n	: out std_logic;
		CS1n	: out std_logic;

		DMARQ	: in std_logic;
		DMACKn	: out std_logic;
		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
end entity ATAHOST_CONTROLLER;

architecture SYN of ATAHOST_CONTROLLER is
	--
	-- component declarations
	--
	component ATAHOST_PIO_CONTROLLER is
	generic(
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23           -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk : in std_logic;  		                    	  -- master clock in
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		-- control / registers
		IDEctrl_IDEen,
		IDEctrl_ppen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		-- PIO registers
		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in unsigned(7 downto 0);
		cmdport_IORDYen : in std_logic;            -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in unsigned(7 downto 0);
		dport0_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in unsigned(7 downto 0);
		dport1_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 1

		sel : in std_logic;                           -- PIO controller selected
		ack : out std_logic;                          -- PIO controller acknowledge
		a : in unsigned(3 downto 0);                  -- lower address bits
		we : in std_logic;                            -- write enable input
		d : in std_logic_vector(15 downto 0);
		q : out std_logic_vector(15 downto 0);

		PIOreq : out std_logic;                       -- PIO transfer request
		PPFull : out std_logic;                       -- PIO Write PingPong Full
		go : in std_logic;                            -- start PIO transfer
		done : buffer std_logic;                      -- done with PIO transfer

		PIOa : out unsigned(3 downto 0);              -- PIO address, address lines towards ATA devices
		PIOd : out std_logic_vector(15 downto 0);     -- PIO data, data towards ATA devices

		SelDev : buffer std_logic;                    -- Selected Device, Dev-bit in ATA Device/Head register

		DDi	: in std_logic_vector(15 downto 0);
		DDoe : buffer std_logic;

		DIOR	: buffer std_logic;
		DIOW	: buffer std_logic;
		IORDY	: in std_logic
	);
	end component ATAHOST_PIO_CONTROLLER;

	component ATAHOST_DMA is
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

    busy    : out std_logic;                   -- we are doing a DMA access
		SelDev : in std_logic;                        -- Selected device	

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
	end component ATAHOST_DMA;

	--
	-- signals
	--
	signal SelDev : std_logic;                       -- selected device
	signal DMARxFull : std_logic;                    -- DMA receive buffer full

	-- PIO / DMA signals
	signal PIOgo : std_logic;                 -- start PIO / DMA timing controller
	signal PIOdone, DMAdone : std_logic;             -- PIO / DMA timing controller done

	-- PIO signals
	signal PIOdior, PIOdiow : std_logic;
	signal PIOoe : std_logic;

	-- PIO pingpong signals
	signal PIOd : std_logic_vector(15 downto 0);
	signal PIOa : unsigned(3 downto 0);
	signal PIOreq : std_logic;

	-- DMA signals
	signal DMAd : std_logic_vector(15 downto 0);
	signal DMAdior, DMAdiow : std_logic;

	-- synchronized ATA inputs
	signal sDMARQ, sIORDY : std_logic;
	
	signal DMA_busy : std_logic;     -- DMA core busy

begin

	--
	-- synchronize incoming signals
	--
	synch_incoming: block
		signal cDMARQ : std_logic;                   -- capture DMARQ
		signal cIORDY : std_logic;                   -- capture IORDY
		signal cINTRQ : std_logic;                   -- capture INTRQ
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				cDMARQ <= DMARQ;
				cIORDY <= IORDY;
				cINTRQ <= INTRQ;

				sDMARQ <= cDMARQ;
				sIORDY <= cIORDY;
				irq    <= cINTRQ;
			end if;
		end process;

		DMA_dmarq <= sDMARQ;
	end block synch_incoming;

	--
	-- generate ATA signals
	--
	gen_ata_sigs: block
		signal iDDo : std_logic_vector(15 downto 0);
	begin
		-- generate registers for ATA signals
		gen_regs: process(clk, nReset)
		begin
			if (nReset = '0') then
				RESETn <= '0';
				DIORn  <= '1';
				DIOWn  <= '1';
				DA     <= (others => '0');
				CS0n	  <= '1';
				CS1n	  <= '1';
				DDo    <= (others => '0');
				DDoe   <= '0';
				DMACKn <= '1';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					RESETn <= '0';
					DIORn  <= '1';
					DIOWn  <= '1';
					DA     <= (others => '0');
					CS0n   <= '1';
					CS1n  	<= '1';
					DDo    <= (others => '0');
					DDoe   <= '0';
					DMACKn <= '1';
				else
					RESETn <= not IDEctrl_rst;
					DA     <= PIOa(2 downto 0);
					CS0n	  <= not (not PIOa(3) and PIOtip); -- CS0 asserted when A(3) = '0', negate during DMA transfers
					CS1n	  <= not (    PIOa(3) and PIOtip); -- CS1 asserted when A(3) = '1', negate during DMA transfers

					if (PIOtip = '1') then
						DDo   <= PIOd;
						DDoe  <= PIOoe;
						DIORn <= not PIOdior;
						DIOWn <= not PIOdiow;
					else
						DDo   <= DMAd;
						DDoe  <= DMActrl_dir and DMAtip;
						DIORn <= not DMAdior;
						DIOWn <= not DMAdiow;
					end if;

					DMACKn <= not (DMAtip and not PIOtip);	-- only allow DMA ack if not doing a PIO
				end if;
			end if;
		end process gen_regs;
	end block gen_ata_sigs;
	
	--
	-- generate bus controller statemachine
	--
	statemachine: block
		type states is (idle, PIO_state);
		signal nxt_state, c_state : states; -- next_state, current_state

		signal iPIOgo : std_logic;
	begin
		-- generate next state decoder + output decoder
		gen_nxt_state: process(c_state, DMActrl_DMAen, DMActrl_dir, PIOreq, sDMARQ, DMATxFull, DMARxFull, PIOdone, DMAdone)
		begin
			nxt_state <= c_state; -- initialy stay in current state

			iPIOgo <= '0';

			case c_state is
				-- idle
				when idle =>
					if (PIOreq = '1') then
						nxt_state <= PIO_state;                            -- PIO transfer priority over DMA
						iPIOgo    <= '1';
					end if;

				-- PIO transfer
				when PIO_state =>
					if (PIOdone = '1') then
							nxt_state <= idle;
					end if;

				when others =>
					nxt_state <= idle;                                   -- go to idle state

			end case;
		end process gen_nxt_state;

		-- generate registers
		gen_regs: process(clk, nReset)
		begin
			if (nReset = '0') then
				c_state <= idle;
				PIOgo <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					c_state <= idle;
					PIOgo <= '0';
				else
					c_state <= nxt_state;
					PIOgo <= iPIOgo;
				end if;
			end if;
		end process gen_regs;

		-- generate PIOtip / DMAtip
		gen_tip: process(clk, nReset)
		begin
			if (nReset = '0') then
				PIOtip <= '0';
				DMAtip <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					PIOtip <= '0';
					DMAtip <= '0';
				else
					PIOtip <= iPIOgo or (PIOtip and not PIOdone);
					-- start dma when IDE Req happens or we are still in progress, thsi signal muxes the CF control/data from PIO to DMA
					DMAtip <= DMActrl_DMAen and (sDMARQ or DMA_busy);
				end if;
			end if;
		end process gen_tip;
	end block statemachine;

	--
	-- Hookup PIO controller
	--
	ATAHOST_PIO_CONTROLLER_1: ATAHOST_PIO_CONTROLLER
		generic map(
			TWIDTH => TWIDTH,
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map(
			clk    => clk,
			nReset => nReset,
			rst    => rst,
			IDEctrl_IDEen => IDEctrl_IDEen,
			IDEctrl_ppen  => IDEctrl_ppen,
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,
			cmdport_T1    => PIO_cmdport_T1,
			cmdport_T2    => PIO_cmdport_T2,
			cmdport_T4    => PIO_cmdport_T4,
			cmdport_Teoc  => PIO_cmdport_Teoc,
			cmdport_IORDYen => PIO_cmdport_IORDYen,
			dport0_T1     => PIO_dport0_T1,
			dport0_T2     => PIO_dport0_T2,
			dport0_T4     => PIO_dport0_T4,
			dport0_Teoc   => PIO_dport0_Teoc,
			dport0_IORDYen => PIO_dport0_IORDYen,
			dport1_T1     => PIO_dport1_T1,
			dport1_T2     => PIO_dport1_T2,
			dport1_T4     => PIO_dport1_T4,
			dport1_Teoc   => PIO_dport1_Teoc,
			dport1_IORDYen => PIO_dport1_IORDYen,
			sel    => PIOsel,
			ack    => PIOack,
			a      => a,
			we     => we,
			d      => d(15 downto 0),
			q      => PIOq, 
			PIOreq => PIOreq,
			PPFull => PIOpp_full,
			go     => PIOgo,
			done   => PIOdone,
			PIOa   => PIOa,
			PIOd   => PIOd,
			SelDev => SelDev,
			DDi    => DDi,
			DDoe   => PIOoe,
			DIOR   => PIOdior,
			DIOW   => PIOdiow,
			IORDY  => sIORDY
		);

	--
	-- Hookup DMA access controller
	--
	ATAHOST_DMA_1: ATAHOST_DMA
		port map(
			clk    => clk,
			nReset => nReset,
			rst    => rst,
			IDEctrl_rst    => IDEctrl_rst,
			DMActrl_DMAen  => DMActrl_DMAen, 
			DMActrl_dir    => DMActrl_dir,
			DMActrl_BeLeC0 => DMActrl_BeLeC0,
			DMActrl_BeLeC1 => DMActrl_BeLeC1, 
			dev0_Td   => DMA_dev0_Td,
			dev0_Teoc => DMA_dev0_Teoc, 
			dev1_Td   => DMA_dev1_Td,
			dev1_Teoc => DMA_dev1_Teoc,

      -- WISHBONE SLAVE DMA port signals
      wb_dma_cyc_i => wb_dma_cyc_i,
      wb_dma_stb_i => wb_dma_stb_i,
      wb_dma_ack_o => wb_dma_ack_o,
      wb_dma_rty_o => wb_dma_rty_o,
      wb_dma_err_o => wb_dma_err_o,
      wb_dma_dat_i => wb_dma_dat_i,
      wb_dma_dat_o => wb_dma_dat_o,
      wb_dma_sel_i => wb_dma_sel_i,
      wb_dma_we_i  => wb_dma_we_i,
      wb_dma_req_o => wb_dma_req_o,
      wb_dma_done_i=> wb_dma_done_i,


			busy    => DMA_busy,
			SelDev  => SelDev,
			DDi     => DDi,
			DDo     => DMAd,

			TxFull  => DMATxFull,
			RxFull  => DMARxFull,
			RxEmpty => DMARxEmpty,
			DIOR    => DMAdior,
			DIOW    => DMAdiow,
			DMARQ   => sDMARQ
		);
end architecture SYN;
