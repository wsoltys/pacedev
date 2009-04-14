---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  ATA/ATAPI-5 IDE controller with DMA support                ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2002 Richard Herveille                        ----
----                    richard@asics.ws                         ----
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

--
-- rev.:	1.0  Alpha version Januar 1st, 2001
-- rev.: 1.0a Removed all references to records.vhd. Make core compatible with VHDL to Verilog translator tools
--            Changed DMA_req signal generation. Make the core compatible with the latest version of the OpenCores DMA engine
-- rev.: 1.1  june 18th, 2001. Changed wishbone address-input from ADR_I(4 downto 0) to ADR(6 downto 2)
-- rev.: 1.1a june 19th, 2001. Simplified DAT_O output multiplexor
--
--  CVS Log
--
--  $Id: atahost_top.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_top.vhd,v $
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
--

--
-- DeviceType: OCIDEC-3: OpenCores IDE Controller type3
-- Features: PIO Compatible Timing, PIO Fast Timing 0/1, Single/Multiword DMA Timing 0/1
-- DeviceID: 0x03
-- RevNo : 0x00

--
-- Host signals:
-- Reset
-- DIOR-		read strobe. The falling edge enables data from device onto DD. The rising edge latches data at the host.
-- DIOW-		write strobe. The rising edge latches data from DD into the device.
-- DMACK-	DMA acknowledge
-- DA(2:0)		3bit binary coded adress
-- CS0-		select command block registers
-- CS1-		select control block registers

--ab 1/8 added WB DMA port to connect direct to IDE DMA
-- renamed instances


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ATAHOST_TOP is
	generic(
		TWIDTH : natural := 8;                      -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;                -- 70ns
		PIO_mode0_T2 : natural := 28;               -- 290ns
		PIO_mode0_T4 : natural := 2;                -- 30ns
		PIO_mode0_Teoc : natural := 23;             -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

		-- Multiword DMA mode 0 settings  NEW DMA CONTROLLER
		-- (@50MHz clock)
		DMA_mode0_Tm : natural := 0;                -- NOT USED
		DMA_mode0_Td : natural := 10;               -- 215, (10+1)*20ns = 220
		DMA_mode0_Teoc : natural := 12              -- 480-220 = 260, (12+1)*20ns = 260
	);
	port(
		-- WISHBONE SYSCON signals
		wb_clk_i : in std_logic;                       -- master clock in
		arst_i   : in std_logic := '1';                -- asynchronous active low reset
		wb_rst_i : in std_logic := '0';                -- synchronous active high reset

		-- WISHBONE SLAVE registers and PIO signals
		wb_cyc_i : in std_logic;                       -- valid bus cycle input
		wb_stb_i : in std_logic;                       -- strobe/core select input
		wb_ack_o : out std_logic;                      -- strobe acknowledge output
		wb_rty_o : out std_logic;                      -- retry output
		wb_err_o : out std_logic;                      -- error output
		wb_adr_i : in unsigned(6 downto 2);            -- A6 = '1' ATA devices selected
		                                               --       A5 = '1' CS1- asserted, '0' CS0- asserted
		                                               --       A4..A2 ATA address lines
		                                               -- A6 = '0' ATA controller selected
		wb_dat_i : in std_logic_vector(31 downto 0);   -- Databus in
		wb_dat_o : out std_logic_vector(31 downto 0);  -- Databus out
		wb_sel_i : in std_logic_vector(3 downto 0);    -- Byte select signals
		wb_we_i  : in std_logic;                       -- Write enable input
		wb_inta_o : out std_logic;                     -- interrupt request signal IDE0

    -- this clock is not connected internally
    -- it is only here to keep SOPC builder happy
		--wb_dma_clk_i : in std_logic;

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
		resetn_pad_o : out std_logic;
		dd_pad_i     : in  std_logic_vector(15 downto 0);
		dd_pad_o     : out std_logic_vector(15 downto 0);
		dd_padoe_o   : out std_logic;
		da_pad_o     : out unsigned(2 downto 0);
		cs0n_pad_o   : out std_logic;
		cs1n_pad_o   : out std_logic;

		diorn_pad_o	 : out std_logic;
		diown_pad_o	 : out std_logic;
		iordy_pad_i	 : in  std_logic;
		intrq_pad_i	 : in  std_logic;

		dmarq_pad_i  : in  std_logic;
		dmackn_pad_o : out std_logic
	);
end entity ATAHOST_TOP;

architecture SYN of ATAHOST_TOP is

	constant ARST_LVL : std_logic := '0';                -- asynchronous reset level

	--
	-- Device ID
	--
	constant DeviceId : unsigned(3 downto 0) := x"3";
	constant RevisionNo : unsigned(3 downto 0) := x"0";

	--
	-- component declarations
	--
	component ATAHOST_WB_SLAVE is
	generic(
		DeviceID   : unsigned(3 downto 0) := x"0";
		RevisionNo : unsigned(3 downto 0) := x"0";

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;                -- 70ns
		PIO_mode0_T2 : natural := 28;               -- 290ns
		PIO_mode0_T4 : natural := 2;                -- 30ns
		PIO_mode0_Teoc : natural := 23;             -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

		-- Multiword DMA mode 0 settings
		DMA_mode0_Tm : natural := 255;   
		DMA_mode0_Td : natural := 255;   
		DMA_mode0_Teoc : natural := 255  
	);
	port(
		-- WISHBONE SYSCON signals
		clk_i  : in std_logic;		                   	-- master clock in
		arst_i : in std_logic := '1';               -- asynchronous active low reset
		rst_i  : in std_logic := '0';               -- synchronous active high reset

		-- WISHBONE SLAVE signals
		cyc_i : in std_logic;                       -- valid bus cycle input
		stb_i : in std_logic;                       -- strobe/core select input
		ack_o : out std_logic;                      -- strobe acknowledge output
		rty_o : out std_logic;                      -- retry output
		err_o : out std_logic;                      -- error output
		adr_i : in unsigned(6 downto 2);            -- A6 = '1' ATA devices selected
		                                            --          A5 = '1' CS1- asserted, '0' CS0- asserted
		                                            --          A4..A2 ATA address lines
		                                            -- A6 = '0' ATA controller selected
		dat_i  : in std_logic_vector(31 downto 0);  -- Databus in
		dat_o  : out std_logic_vector(31 downto 0); -- Databus out
		sel_i  : in std_logic_vector(3 downto 0);   -- Byte select signals
		we_i   : in std_logic;                      -- Write enable input
		inta_o : out std_logic;                     -- interrupt request signal IDE0

		-- PIO control input
		PIOsel     : buffer std_logic;
		PIOtip,                                         -- PIO transfer in progress
		PIOack     : in std_logic;                      -- PIO acknowledge signal
		PIOq       : in std_logic_vector(15 downto 0);  -- PIO data input
		PIOpp_full : in std_logic;                      -- PIO write-ping-pong buffers full
		irq        : in std_logic;                      -- interrupt signal input

		-- DMA control inputs
		DMAtip,                                     -- DMA transfer in progress
		DMARxEmpty,                                 -- DMA receive buffer empty
		DMATxFull,                                  -- DMA transmit buffer full
		DMA_dmarq : in std_logic;                   -- wishbone DMA request

		-- outputs
		-- control register outputs
		IDEctrl_rst,
		IDEctrl_IDEen,
		IDEctrl_FATR1,
		IDEctrl_FATR0,
		IDEctrl_ppen,
		DMActrl_DMAen,
		DMActrl_dir,
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : out std_logic;

		-- CMD port timing registers
		PIO_cmdport_T1,
		PIO_cmdport_T2,
		PIO_cmdport_T4,
		PIO_cmdport_Teoc    : buffer unsigned(7 downto 0);
		PIO_cmdport_IORDYen : out std_logic;

		-- data-port0 timing registers
		PIO_dport0_T1,
		PIO_dport0_T2,
		PIO_dport0_T4,
		PIO_dport0_Teoc    : buffer unsigned(7 downto 0);
		PIO_dport0_IORDYen : out std_logic;

		-- data-port1 timing registers
		PIO_dport1_T1,
		PIO_dport1_T2,
		PIO_dport1_T4,
		PIO_dport1_Teoc    : buffer unsigned(7 downto 0);
		PIO_dport1_IORDYen : out std_logic;

		-- DMA device0 timing registers
		DMA_dev0_Tm,
		DMA_dev0_Td,
		DMA_dev0_Teoc    : buffer unsigned(7 downto 0);

		-- DMA device1 timing registers
		DMA_dev1_Tm,
		DMA_dev1_Td,
		DMA_dev1_Teoc    : buffer unsigned(7 downto 0)
	);
	end component ATAHOST_WB_SLAVE;

	component ATAHOST_CONTROLLER is
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

		a  : in unsigned(3 downto 0);                 -- address input
		d  : in std_logic_vector(31 downto 0);        -- data input
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
	end component ATAHOST_CONTROLLER;

	-- asynchronous reset signal
	signal arst_signal : std_logic;

	-- primary address decoder
	signal PIOsel : std_logic;        -- controller select, IDE devices select

	-- registers
	-- IDE control register
	signal IDEctrl_IDEen, IDEctrl_rst, IDEctrl_ppen, IDEctrl_FATR0, IDEctrl_FATR1 : std_logic;
	-- PIO compatible timing settings
	signal PIO_cmdport_T1, PIO_cmdport_T2, PIO_cmdport_T4, PIO_cmdport_Teoc : unsigned(7 downto 0);
	signal PIO_cmdport_IORDYen : std_logic;
	-- PIO data register device0 timing settings
	signal PIO_dport0_T1, PIO_dport0_T2, PIO_dport0_T4, PIO_dport0_Teoc : unsigned(7 downto 0);
	signal PIO_dport0_IORDYen : std_logic;  
	-- PIO data register device1 timing settings
	signal PIO_dport1_T1, PIO_dport1_T2, PIO_dport1_T4, PIO_dport1_Teoc : unsigned(7 downto 0);
	signal PIO_dport1_IORDYen : std_logic;
	-- DMA control register
	signal DMActrl_DMAen, DMActrl_dir, DMActrl_BeLeC0, DMActrl_BeLeC1 : std_logic;
	-- DMA data port device0 timing settings
	signal DMA_dev0_Td, DMA_dev0_Tm, DMA_dev0_Teoc : unsigned(7 downto 0);
	-- DMA data port device1 timing settings
	signal DMA_dev1_Td, DMA_dev1_Tm, DMA_dev1_Teoc : unsigned(7 downto 0);

	signal PIOack, PIOtip, DMAtip : std_logic;
	signal PIOq : std_logic_vector(15 downto 0);
	signal PIOpp_full : std_logic;
	signal DMA_dmarq : std_logic; -- synchronized version of DMARQ

	signal DMATxFull, DMARxEmpty : std_logic;

	signal irq : std_logic; -- ATA bus IRQ signal

begin
	-- generate asynchronous reset level
	arst_signal <= arst_i xor ARST_LVL;

	--
	-- hookup wishbone slave
	--
	ATAHOST_WB_SLAVE_1: ATAHOST_WB_SLAVE 
		generic map(
			DeviceID   => DeviceID,
			RevisionNo => RevisionNo,

			-- PIO mode 0 settings
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc,

			-- Multiword DMA mode 0 settings
			DMA_mode0_Tm   => DMA_mode0_Tm,
			DMA_mode0_Td   => DMA_mode0_Td,
			DMA_mode0_Teoc => DMA_mode0_Teoc
		)
		port map(
			-- WISHBONE SYSCON signals
			clk_i => wb_clk_i,
			arst_i => arst_signal,
			rst_i  => wb_rst_i,

			-- WISHBONE SLAVE signals
			cyc_i => wb_cyc_i,
			stb_i => wb_stb_i,
			ack_o => wb_ack_o,
			rty_o => wb_rty_o,
			err_o => wb_err_o,
			adr_i => wb_adr_i,
			dat_i => wb_dat_i,
			dat_o => wb_dat_o,
			sel_i => wb_sel_i,
			we_i  => wb_we_i,
			inta_o => wb_inta_o,

			-- PIO control inputs
			PIOsel     => PIOsel,
			PIOtip     => PIOtip,
			PIOack     => PIOack,
			PIOq       => PIOq,
			PIOpp_full => PIOpp_full,
			irq        => irq,

			-- DMA control inputs
			DMAtip     => DMAtip,
			DMARxEmpty => DMARxEmpty,
			DMATxFull  => DMATxFull,
			DMA_dmarq  => DMA_dmarq,

			-- outputs
			-- control register outputs
			IDEctrl_rst   => IDEctrl_rst,
			IDEctrl_IDEen => IDEctrl_IDEen,
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,
			IDEctrl_ppen  => IDEctrl_ppen,

			DMActrl_DMAen  => DMActrl_DMAen,
			DMActrl_dir    => DMActrl_dir,
			DMActrl_BeLeC0 => DMActrl_BeLeC0,
			DMActrl_BeLeC1 => DMActrl_BeLeC1,

			-- CMD port timing registers
			PIO_cmdport_T1 => PIO_cmdport_T1,
			PIO_cmdport_T2 => PIO_cmdport_T2,
			PIO_cmdport_T4 => PIO_cmdport_T4,
			PIO_cmdport_Teoc => PIO_cmdport_Teoc,
			PIO_cmdport_IORDYen => PIO_cmdport_IORDYen,

			-- data-port0 timing registers
			PIO_dport0_T1 => PIO_dport0_T1,
			PIO_dport0_T2 => PIO_dport0_T2,
			PIO_dport0_T4 => PIO_dport0_T4,
			PIO_dport0_Teoc => PIO_dport0_Teoc,
			PIO_dport0_IORDYen => PIO_dport0_IORDYen,

			-- data-port1 timing registers
			PIO_dport1_T1 => PIO_dport1_T1,
			PIO_dport1_T2 => PIO_dport1_T2,
			PIO_dport1_T4 => PIO_dport1_T4,
			PIO_dport1_Teoc => PIO_dport1_Teoc,
			PIO_dport1_IORDYen => PIO_dport1_IORDYen,

			-- DMA device0 timing registers
			DMA_dev0_Tm => DMA_dev0_Tm,
			DMA_dev0_Td => DMA_dev0_Td,
			DMA_dev0_Teoc => DMA_dev0_Teoc,

			-- DMA device1 timing registers
			DMA_dev1_Tm => DMA_dev1_Tm,
			DMA_dev1_Td => DMA_dev1_Td,
			DMA_dev1_Teoc => DMA_dev1_Teoc
		);


	--
	-- hookup controller section
	--
	ATAHOST_CONTROLLER_1: ATAHOST_CONTROLLER
		generic map(
			TWIDTH => TWIDTH,
			PIO_mode0_T1   => PIO_mode0_T1,
			PIO_mode0_T2   => PIO_mode0_T2,
			PIO_mode0_T4   => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map(
			clk    => wb_clk_i,
			nReset => arst_signal,
			rst    => wb_rst_i,
			irq    => irq,
			IDEctrl_IDEen => IDEctrl_IDEen,
			IDEctrl_rst   => IDEctrl_rst,
			IDEctrl_ppen  => IDEctrl_ppen, 
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,
			a  => wb_adr_i(5 downto 2),
			d  => wb_dat_i,
			we => wb_we_i,
			PIO_cmdport_T1   => PIO_cmdport_T1,
			PIO_cmdport_T2   => PIO_cmdport_T2,
			PIO_cmdport_T4   => PIO_cmdport_T4,
			PIO_cmdport_Teoc => PIO_cmdport_Teoc,
			PIO_cmdport_IORDYen => PIO_cmdport_IORDYen,
			PIO_dport0_T1   => PIO_dport0_T1,
			PIO_dport0_T2   => PIO_dport0_T2,
			PIO_dport0_T4   => PIO_dport0_T4,
			PIO_dport0_Teoc => PIO_dport0_Teoc,
			PIO_dport0_IORDYen => PIO_dport0_IORDYen,
			PIO_dport1_T1   => PIO_dport1_T1,
			PIO_dport1_T2   => PIO_dport1_T2,
			PIO_dport1_T4   => PIO_dport1_T4,
			PIO_dport1_Teoc => PIO_dport1_Teoc,
			PIO_dport1_IORDYen => PIO_dport1_IORDYen,
			PIOsel     => PIOsel,
			PIOack     => PIOack,
			PIOq       => PIOq,
			PIOtip     => PIOtip,
			PIOpp_full => PIOpp_full, 
			DMActrl_DMAen  =>	DMActrl_DMAen,
			DMActrl_dir    => DMActrl_dir,
			DMActrl_BeLeC0 => DMActrl_BeLeC0,
			DMActrl_BeLeC1 => DMActrl_BeLeC1,
			DMA_dev0_Td   => DMA_dev0_Td,
			DMA_dev0_Teoc => DMA_dev0_Teoc,
			DMA_dev1_Td   => DMA_dev1_Td,
			DMA_dev1_Teoc => DMA_dev1_Teoc,
			DMAtip     => DMAtip,
			DMA_dmarq  => DMA_dmarq,
			DMATxFull  => DMATxFull, 
			DMARxEmpty => DMARxEmpty,

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

			RESETn => resetn_pad_o,
			DDi    => dd_pad_i,
			DDo    => dd_pad_o,
			DDoe   => dd_padoe_o,
			DA     => da_pad_o,
			CS0n   => cs0n_pad_o,
			CS1n   => cs1n_pad_o,
			DIORn  => diorn_pad_o,
			DIOWn  => diown_pad_o,
			IORDY  => iordy_pad_i,
			INTRQ  => intrq_pad_i,
			DMARQ  => dmarq_pad_i,
			DMACKn => dmackn_pad_o
		);

end architecture SYN;



