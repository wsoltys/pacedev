library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

entity tb_top is
	port (
		fail:				out  boolean := false
	);
end tb_top;

architecture SYN of tb_top is

	signal clk_24M				: std_logic := '0';

begin

	-- Generate CLK and reset
  clk_24M <= not clk_24M after 20833 ps; -- 24MHz

  target_top_inst : entity work.target_top
    port map
      (
        -- clocking
        clock0            => clk_24M,
        clock8            => clk_24M,
                          
        -- ethernet       
        COL_enet          => '0',
        CRS_enet          => '0',
        RXCLK_enet        => '0',
        RXD_enet          => (others => '0'),
        RXDV_enet         => '0',
        RXER_enet         => '0',
        TXCLK_enet        => '0',
        MDIO_enet         => open,
        MDC_enet          => open,
        TXD_enet          => open,
        TXEN_enet         => open,
        TXER_enet         => open,
        RESET_enet        => open,
        RIP_enet          => '0',
        MDINT_enet        => '0',
                          
        -- PIO            
        mac_addr          => open,
        sw2_1             => '0',
        led               => open,
        ext_enable        => '0',
                          
        -- sdram 1 MEB
        clk_dr1           => open,
        a_dr1             => open,
        ba_dr1            => open,
        ncas_dr1          => open,
        cke_dr1           => open,
        ncs_dr1           => open,
        d_dr1             => open,
        dqm_dr1           => open,
        nras_dr1          => open,
        nwe_dr1           => open,
        
        -- sdram 2 NIOS
        clk_dr2           => open,
        a_dr2             => open,
        ba_dr2            => open,
        ncas_dr2          => open,
        cke_dr2           => open,
        ncs_dr2           => open,
        d_dr2             => open,
        dqm_dr2           => open,
        nras_dr2          => open,
        nwe_dr2           => open,
    
        -- compact flash
        iordy0_cf         => '0',
        rdy_irq_cf        => '0',
        cd_cf             => '0',
        a_cf              => open,
        nce_cf            => open,
        d_cf              => open,
        nior0_cf          => open,
        niow0_cf          => open,
        non_cf            => open,
        reset_cf          => open,
        ndmack_cf         => open,
        dmarq_cf          => '0',
    
    		-- GAT serial port
    		gat_txd						=> open,
    		gat_rxd						=> '0',
    		
    		-- I2C
    		clk_ee						=> open,
    		data_ee						=> open,
    		
        -- System ROMS
    		nromsoe					  => open,
    		
    		-- MEB
        bd                => open,
        ba25              => open,
        ba24              => open,
        ba23              => '0',
        ba22              => open,
        ba21              => '0',
        ba20              => open,
        ba19              => '0',
        ba18              => '0',
        ba17              => '0',
        ba16              => open,
        ba15              => '0',
        ba14              => open,
        ba13              => '0',
        ba12              => '0',
        ba11              => '0',
        ba10              => '0',
        ba9               => open,
        ba8               => '0',
        ba7               => '0',
        ba6               => open,
        ba5               => '0',
        ba4               => open,
        ba3               => open,
        ba2               => '0',
    		nmebwait				  => open,
    		nmebint					  => '0',
    		nbwr						  => '0',
    		nreset2					  => '0',
    		nromsdis				  => open,
    		butres					  => '0',
    		nromgdis				  => open,
    		nbrd						  => '0',
    		nbcs2						  => '0',
    		nbcs4						  => '0',
    		nbcs0						  => '0',
    		
    		-- MEMORY
        ba_ns							=> open,
        bd_ns							=> open,
        nwe_s             => open,
        ncs_s             => open,
        nce_n             => open,
        noe_ns            => open
      );

end SYN;
