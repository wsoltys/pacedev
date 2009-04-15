library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity AVALON_ATAHOST_TOP is
	generic
	(
		TWIDTH 					: natural := 8;                      -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 		: natural := 6;               -- 70ns
		PIO_mode0_T2 		: natural := 28;              -- 290ns
		PIO_mode0_T4 		: natural := 2;               -- 30ns
		PIO_mode0_Teoc 	: natural := 23;             	-- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

		-- Multiword DMA mode 0 settings  NEW DMA CONTROLLER
		-- (@50MHz clock)
		DMA_mode0_Tm 		: natural := 0;               -- NOT USED
		DMA_mode0_Td 		: natural := 10;              -- 215, (10+1)*20ns = 220
		DMA_mode0_Teoc 	: natural := 12              	-- 480-220 = 260, (12+1)*20ns = 260
	);
	port
	(
		-- WISHBONE SYSCON signals
		csi_clockreset_clk 		: in std_logic;                       -- master clock in
		csi_clockreset_reset 	: in std_logic := '0';                -- synchronous active high reset
		coe_arst_arst   			: in std_logic := '1';                -- asynchronous active low reset

		-- WISHBONE SLAVE registers and PIO signals
		avs_s1_chipselect 		: in std_logic;                       -- valid bus cycle input
		avs_s1_waitrequest_n 	: out std_logic;                      -- strobe acknowledge output
		avs_s1_address 				: in unsigned(6 downto 2);            -- A6 = '1' ATA devices selected
		avs_s1_writedata			: in std_logic_vector(31 downto 0);   -- Databus in
		avs_s1_readdata				: out std_logic_vector(31 downto 0);  -- Databus out
		avs_s1_byteenable			: in std_logic_vector(3 downto 0);    -- Byte select signals
		avs_s1_write					: in std_logic;                       -- Write enable input
		ins_irq1_irq					: out std_logic;                     -- interrupt request signal IDE0

    -- this clock is not connected internally
    -- it is only here to keep SOPC builder happy
		--wb_dma_clk_i : in std_logic;

    -- WISHBONE SLAVE DMA port signals
    avs_s2_chipselect			: in std_logic;                       -- valid bus cycle input
    avs_s2_waitrequest_n	: out std_logic;                      -- strobe acknowledge output
    avs_s2_writedata			: in std_logic_vector(31 downto 0);   -- Databus in
    avs_s2_readdata				: out std_logic_vector(31 downto 0);  -- Databus out
    avs_s2_byteenable			: in std_logic_vector(3 downto 0);    -- Byte select signals
    avs_s2_write					: in std_logic;                       -- Write enable input
    
    coe_dma_req 					: out std_logic;                      -- request a DMA burst
    coe_dma_done					: in std_logic;                       -- DMA burst done

		-- ATA signals
		coe_ata_resetn 				: out std_logic;
		coe_ata_dd_i     			: in  std_logic_vector(15 downto 0);
		coe_ata_dd_o     			: out std_logic_vector(15 downto 0);
		coe_ata_dd_oe   			: out std_logic;
		coe_ata_da     				: out unsigned(2 downto 0);
		coe_ata_cs0n   				: out std_logic;
		coe_ata_cs1n   				: out std_logic;

		coe_ata_diorn	 				: out std_logic;
		coe_ata_diown					: out std_logic;
		coe_ata_iordy					: in  std_logic;
		coe_ata_intrq					: in  std_logic;

		coe_ata_dmarq					: in  std_logic;
		coe_ata_dmackn				: out std_logic
	);
end entity AVALON_ATAHOST_TOP;

architecture SYN of AVALON_ATAHOST_TOP is

	component ATAHOST_TOP is
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
	end component ATAHOST_TOP;

begin

	atahost_top_inst : ATAHOST_TOP
		generic map
		(
			TWIDTH 					=> TWIDTH,
	
			-- PIO mode 0 settings (@100MHz clock)
			PIO_mode0_T1 		=> PIO_mode0_T1,
			PIO_mode0_T2 		=> PIO_mode0_T2,
			PIO_mode0_T4 		=> PIO_mode0_T4,
			PIO_mode0_Teoc 	=> PIO_mode0_Teoc,
	
			-- Multiword DMA mode 0 settings  NEW DMA CONTROLLER
			-- (@50MHz clock)
			DMA_mode0_Tm 		=> DMA_mode0_Tm,
			DMA_mode0_Td 		=> DMA_mode0_Td,
			DMA_mode0_Teoc 	=> DMA_mode0_Teoc
		)
		port map
		(
			-- WISHBONE SYSCON signals
			wb_clk_i 				=> csi_clockreset_clk,
			wb_rst_i 				=> csi_clockreset_reset,
			arst_i   				=> coe_arst_arst,
	
			-- WISHBONE SLAVE registers and PIO signals
			wb_cyc_i 				=> avs_s1_chipselect,
			wb_stb_i 				=> avs_s1_chipselect,
			wb_ack_o 				=> avs_s1_waitrequest_n,
			wb_rty_o 				=> open,
			wb_err_o 				=> open,
			wb_adr_i 				=> avs_s1_address,
			wb_dat_i 				=> avs_s1_writedata,
			wb_dat_o 				=> avs_s1_readdata,
			wb_sel_i 				=> avs_s1_byteenable,
			wb_we_i  				=> avs_s1_write,
			wb_inta_o 			=> ins_irq1_irq,
	
	    -- this clock is not connected internally
	    -- it is only here to keep SOPC builder happy
			--wb_dma_clk_i 		=> '0',
	
	    -- WISHBONE SLAVE DMA port signals
	    wb_dma_cyc_i 		=> avs_s2_chipselect,
	    wb_dma_stb_i 		=> avs_s2_chipselect,
	    wb_dma_ack_o 		=> avs_s2_waitrequest_n,
	    wb_dma_rty_o 		=> open,
	    wb_dma_err_o 		=> open,
	    wb_dma_dat_i 		=> avs_s2_writedata,
	    wb_dma_dat_o 		=> avs_s2_readdata,
	    wb_dma_sel_i 		=> avs_s2_byteenable,
	    wb_dma_we_i  		=> avs_s2_write,
	    
	    wb_dma_req_o 		=> coe_dma_req,
	    wb_dma_done_i		=> coe_dma_done,
	
			-- ATA signals
			resetn_pad_o 		=> coe_ata_resetn,
			dd_pad_i     		=> coe_ata_dd_i,
			dd_pad_o     		=> coe_ata_dd_o,
			dd_padoe_o   		=> coe_ata_dd_oe,
			da_pad_o     		=> coe_ata_da,
			cs0n_pad_o   		=> coe_ata_cs0n,
			cs1n_pad_o   		=> coe_ata_cs1n,
	
			diorn_pad_o	 		=> coe_ata_diorn,
			diown_pad_o	 		=> coe_ata_diown,
			iordy_pad_i	 		=> coe_ata_iordy,
			intrq_pad_i	 		=> coe_ata_intrq,
	
			dmarq_pad_i  		=> coe_ata_dmarq,
			dmackn_pad_o 		=> coe_ata_dmackn
		);

end architecture SYN;



