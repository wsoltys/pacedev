library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.EXT;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.platform_pkg.all;
use work.project_pkg.all;

entity c1541_top is
	generic
	(
		DEVICE_SELECT		: std_logic_vector(1 downto 0)
	);
	port
	(
		clk_32M					: in std_logic;
		reset						: in std_logic;

		-- serial bus
		sb_data_oe			: out std_logic;
		sb_data_in			: in std_logic;
		sb_clk_oe				: out std_logic;
		sb_clk_in				: in std_logic;
		sb_atn_oe				: out std_logic;
		sb_atn_in				: in std_logic;
		
		-- drive-side interface
		ds							: in std_logic_vector(1 downto 0);		-- device select
		act							: out std_logic;											-- activity LED

		-- generic drive mechanism i/o ports
		mech_in					: in std_logic_vector(63 downto 0);
		mech_out				: out std_logic_vector(63 downto 0);
		mech_io					: inout std_logic_vector(63 downto 0)
	);
end c1541_top;

architecture SYN of c1541_top is

		constant BUILD_NIOS_DRIVE_MECH : boolean := true;

		alias clk_NIOS		: std_logic is mech_in(0);
		alias sdram_addr	: STD_LOGIC_VECTOR(12 DOWNTO 0) is mech_out(12 downto 0);
    alias sdram_ba		: STD_LOGIC_VECTOR(1 DOWNTO 0) is mech_out(14 downto 13);
    alias sdram_cas_n	: STD_LOGIC is mech_out(15);
    alias sdram_cke		: STD_LOGIC is mech_out(16);
    alias sdram_cs_n	: STD_LOGIC is mech_out(17);
    alias sdram_dq		: STD_LOGIC_VECTOR(31 DOWNTO 0) is mech_io(31 downto 0);
    alias sdram_dqm		: STD_LOGIC_VECTOR(3 DOWNTO 0) is mech_out(21 downto 18);
    alias sdram_ras_n	: STD_LOGIC is mech_out(22);
    alias sdram_we_n	: STD_LOGIC is mech_out(23);

		signal c1541_reset			: std_logic;
		
		signal wps_n						: std_logic;
		signal tr00_sense_n			: std_logic;

		-- fifo-related signals
		signal fifo_gpi					: std_logic_vector(15 downto 0);
		signal fifo_gpo					: std_logic_vector(fifo_gpi'range);
		signal fifo_wrclk				: std_logic;
		signal fifo_data				: std_logic_vector(7 downto 0);
		signal fifo_wrreq				: std_logic;
		signal fifo_wrfull			: std_logic;
		signal fifo_wrusedw			: std_logic_vector(7 downto 0);

		-- signals to the mechanism emulation
		-- - these toggle on a step change
		signal stp_in						: std_logic;
		signal stp_out					: std_logic;
		
	begin

		c1541_core_inst : entity work.c1541_core
			generic map
			(
				DEVICE_SELECT		=> C64_1541_DEVICE_SELECT(1 downto 0)
			)
			port map
			(
				clk_32M					=> clk_32M,
				reset						=> c1541_reset,

				-- serial bus
				sb_data_oe			=> sb_data_oe,
				sb_data_in			=> sb_data_in,
				sb_clk_oe				=> sb_clk_oe,
				sb_clk_in				=> sb_clk_in,
				sb_atn_oe				=> sb_atn_oe,
				sb_atn_in				=> sb_atn_in,

				-- drive-side interface				
				
				-- external signals
				ds							=> ds,
				act							=> act,

				-- mechanism interface signals				
				wps_n						=> wps_n,
				tr00_sense_n		=> tr00_sense_n,
				stp_in					=> stp_in,
				stp_out					=> stp_out,	

        -- fifo signals
        fifo_wrclk      => fifo_wrclk,
        fifo_data       => fifo_data,
        fifo_wrreq      => fifo_wrreq,
        fifo_wrfull     => fifo_wrfull,
        fifo_wrusedw    => fifo_wrusedw
			);

		GEN_DRIVE_MECH : if BUILD_NIOS_DRIVE_MECH generate
		
			BLK_DRIVE_MECH : block
			
				signal reset_n						: std_logic;
				signal drive_logic_gpi		: std_logic_vector(7 downto 0);
				signal drive_logic_gpo		: std_logic_vector(7 downto 0);
				
				signal drive_mech_gpi			: std_logic_vector(31 downto 0);
				signal drive_mech_gpo			: std_logic_vector(31 downto 0);
				
			begin

				fifo_wrclk <= clk_NIOS;
				reset_n <= not reset;
				
				-- hook up drive mech signals to the NIOS PIO ports
				drive_logic_gpi <= EXT(stp_out & stp_in & "000", drive_logic_gpi'length);
				c1541_reset <= reset or drive_logic_gpo(7);
				wps_n <= drive_logic_gpo(1);
				tr00_sense_n <= drive_logic_gpo(0);

				-- hook up fifo control				
				fifo_wrreq <= fifo_gpo(0);
				fifo_gpi(8) <= fifo_wrfull;
				fifo_gpi(7 downto 0) <= fifo_wrusedw;

				-- hook up the drive mech gpio
				drive_mech_gpi(0) <= mech_in(34); 	-- cd_cf
				mech_out(56) <= drive_mech_gpo(0);	-- non_cf
				
				drive_mech_inst : entity work.C1541_NIOS
		      port map
					(
		      	-- 1) global signals:
		        clk 											=> clk_NIOS,
		        reset_n 									=> reset_n,

						-- the_ocide3_controller_0
            cs0n_pad_o_from_the_ocide3_controller_0 => mech_out(36),
            cs1n_pad_o_from_the_ocide3_controller_0 => mech_out(35),
            da_pad_o_from_the_ocide3_controller_0 => mech_out(34 downto 32),
            dd_pad_i_to_the_ocide3_controller_0 => mech_in(50 downto 35),
            dd_pad_o_from_the_ocide3_controller_0 => mech_out(52 downto 37),
            dd_padoe_o_from_the_ocide3_controller_0 => mech_out(53),
            diorn_pad_o_from_the_ocide3_controller_0 => mech_out(54),
            diown_pad_o_from_the_ocide3_controller_0 => mech_out(55),
            dmackn_pad_o_from_the_ocide3_controller_0 => mech_out(58),
            dmarq_pad_i_to_the_ocide3_controller_0 => mech_in(51),
            intrq_pad_i_to_the_ocide3_controller_0 => mech_in(33),
            iordy_pad_i_to_the_ocide3_controller_0 => mech_in(32),
            resetn_pad_o_from_the_ocide3_controller_0 => mech_out(57),
            wb_dma_done_i_to_the_ocide3_controller_0 => '0',
            wb_dma_err_o_from_the_ocide3_controller_0 => open,
            wb_dma_req_o_from_the_ocide3_controller_0 => open,
            wb_dma_rty_o_from_the_ocide3_controller_0 => open,
            wb_err_o_from_the_ocide3_controller_0 => open,
            wb_rst_i_to_the_ocide3_controller_0 => '0',
            wb_rty_o_from_the_ocide3_controller_0 => open,

		        -- the_pio_di
		        in_port_to_the_pio_di 		=> (others => '0'),

		        -- the_pio_do
		        out_port_from_the_pio_do	=> fifo_data,

						-- the_pio_fifo
            in_port_to_the_pio_fifo 		=> fifo_gpi,
            out_port_from_the_pio_fifo 	=> fifo_gpo,

		        -- the_pio_gpi
		        in_port_to_the_pio_gpi 		=> drive_logic_gpi,

		        -- the_pio_gpo
		        out_port_from_the_pio_gpo => drive_logic_gpo,

						-- the_pio_mech_in
            out_port_from_the_pio_mech_in => drive_mech_gpo,

            -- the_pio_mech_io
            in_port_to_the_pio_mech_io => (others => '0'),

            -- the_pio_mech_out
            in_port_to_the_pio_mech_out => drive_mech_gpi,

		        -- the_sdram_0
		        zs_addr_from_the_sdram_0 	=> sdram_addr(work.C1541_NIOS.zs_addr_from_the_sdram_0'range),
		        zs_ba_from_the_sdram_0 		=> sdram_ba,
		        zs_cas_n_from_the_sdram_0 => sdram_cas_n,
		        zs_cke_from_the_sdram_0 	=> sdram_cke,
		        zs_cs_n_from_the_sdram_0 	=> sdram_cs_n,
		        zs_dq_to_and_from_the_sdram_0 => sdram_dq(work.C1541_NIOS.zs_dq_to_and_from_the_sdram_0'range),
		        zs_dqm_from_the_sdram_0 	=> sdram_dqm(work.C1541_NIOS.zs_dqm_from_the_sdram_0'range),
		        zs_ras_n_from_the_sdram_0 => sdram_ras_n,
		        zs_we_n_from_the_sdram_0 	=> sdram_we_n
		      );

			end block BLK_DRIVE_MECH;

	end generate GEN_DRIVE_MECH;
	
	GEN_NO_DRIVE_MECH : if not BUILD_NIOS_DRIVE_MECH generate
	
		wps_n <= '1';
		tr00_sense_n <= '0';

		fifo_wrclk <= '0';		
		fifo_wrreq <= '0';
		fifo_data <= (others => '0');
	
	end generate GEN_NO_DRIVE_MECH;
	
end SYN;
