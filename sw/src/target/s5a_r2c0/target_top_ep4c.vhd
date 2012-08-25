library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera;
use altera.altera_syn_attributes.all;

library work;
use work.project_pkg.all;

entity target_top_ep4c is
	port
	(
    -- I2C on the DVI input connector
		dvi_eep_scl			: inout std_logic;
		dvi_eep_sda			: inout std_logic;
    dvi_dis_eep_ddc : out std_logic := '1';   -- disabled
    dvi_eep_wp      : out std_logic := 'Z';   -- default h/w

		dvi_fpg_scl			: inout std_logic;
		dvi_fpg_sda			: inout std_logic;
    dvi_dis_fpg_ddc : out std_logic := '0';   -- enabled

    dvi_en_i2c      : out std_logic := 'Z';
    dvi_connect     : out std_logic := '1';   -- connected
    dvi_oen         : out std_logic := '0';   -- enabled
    
    -- I2C on the DVI output connector
		dvo_scl			    : inout std_logic;
		dvo_sda			    : inout std_logic;

    -- I2C to the TFP410 (DVI out transmitter)
    vdo_scl         : inout std_logic;
    vdo_sda         : inout std_logic;
    
    -- I2C on the video ADC
		vai_scl			    : inout std_logic;
		vai_sda			    : inout std_logic;

    -- I2C on the SDVO to LVDS transceiver
		--vsi_scl			    : inout std_logic;
		--vsi_sda			    : inout std_logic;

    -- SDVO DDC channel
    sdvo_scl        : inout std_logic;
    sdvo_sda        : inout std_logic;
    
		veb_ck_a		    : in std_logic;	-- Buffered copy of carrier 24MHz clock
		veb_ck_sp		    : in std_logic;	-- Spare clock output from carrier FPGA
		
		-- Carrier LPC bus interface
		veb_reset		    : in std_logic;
		veb_framen		  : in std_logic;
		veb_a			      : inout std_logic_vector(3 downto 0);
		veb_irqn		    : in std_logic;
		-- Spare I/O to carrier FPGA
		veb_sp			    : inout std_logic_vector(4 downto 0);

		veb_i2c_clk		  : inout std_logic;
		veb_i2c_dat		  : inout std_logic;
		veb_smb_clk		  : inout std_logic;
		veb_smb_dat		  : inout std_logic;

		-- Touchscreen serial ports
		ser_ts_tx		    : out std_logic;
		ser_ts_rx		    : in std_logic;
		ser_ts_rts	    : out std_logic;
		ser_ts_cts	    : in std_logic;
		ser_pc_tx		    : out std_logic;
		ser_pc_rx		    : in std_logic;
		ser_pc_rts	    : out std_logic;
		ser_pc_cts	    : in std_logic;

		-- LCD O RS485
		lcdo_rx			    : in std_logic;
		--lcdo_tx			    : out std_logic;
		--lcdo_rtsn		    : out std_logic;

		-- DDR2 memory
		ddr16_a					: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
		ddr16_ba				: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ddr16_cas_n			: OUT STD_LOGIC;
		ddr16_cke				: OUT STD_LOGIC;
		ddr16_clk				: INOUT STD_LOGIC;
		ddr16_clk_n			: INOUT STD_LOGIC;
		ddr16_cs_n			: OUT STD_LOGIC;
		ddr16_dm				: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ddr16_dq				: INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ddr16_dqs				: INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ddr16_odt				: OUT STD_LOGIC;
		ddr16_ras_n			: OUT STD_LOGIC;
		ddr16_we_n			: OUT STD_LOGIC;
		-- Internal USB controller, external PHY
		ul_spd			    : out std_logic;
		ul_rcv			    : in std_logic;
		--ul_v			      : inout std_logic;
		ul_con			    : out std_logic;
		ul_sus			    : out std_logic;
		ul_vbusdet		  : in std_logic;
		ul_rsel			    : out std_logic;
		ul_oen			    : out std_logic;

		-- External USB controller
		uh_resetn	      : out std_logic;
		uh_a				    : out std_logic_vector(16 downto 1);
		uh_d				    : inout std_logic_vector(31 downto 0);
		uh_csn			    : out std_logic;
		uh_rdn			    : out std_logic;
		uh_wrn			    : out std_logic;
		uh_be           : out std_logic_vector(3 downto 0);
		uh_intn		      : in std_logic;
		uh_dreq		      : in std_logic_vector(1 downto 0);
		uh_dack			    : out std_logic_vector(1 downto 0);

    -- S5A ONLY (not Lite)
		uh_clkin0		    : out std_logic;
		uh_clkin1		    : out std_logic;
		
		-- Connection to video FPGA
		vid_reset_n     : inout std_logic;		-- Bridge reset
		vid_reset_core_n : inout std_logic;		-- IP core reset
		vid_address		  : out std_logic_vector(10 downto 0);
		vid_data		    : inout std_logic_vector(15 downto 0);
		vid_write_n		  : out std_logic;
		vid_read_n		  : out std_logic;
		vid_waitrequest	: in std_logic;
		vid_irq_n			  : in std_logic;
		vid_clk			    : out std_logic;
		-- not used
    vid_spare       : in std_logic_vector(29 downto 28);
    
    -- I2C to the vid FPGA
		--vid_scl			    : inout std_logic;
		--vid_sda			    : inout std_logic;

		lvds_a			    : in std_logic_vector(3 downto 0);
		lvds_a_clk	    : in std_logic;
    --lvds_b			    : in std_logic_vector(3 downto 0);
    --lvds_b_clk	    : in std_logic;

    -- LVDS I2C
		lvds_i2c_dat    : inout std_logic;
		lvds_i2c_ck	    : inout std_logic;

    -- Power management signals
		v15_pgood		    : in std_logic;
		v15_s3			    : out std_logic;
		v15_s5			    : out std_logic;
		pok_12v			    : in std_logic;
		pok_5v			    : in std_logic;
		pok_3v3			    : in std_logic;
		pok_1v9			    : in std_logic;
		veb_pwrgoodn    : out std_logic;
		veb_i2c_alertn  : in std_logic;
	
    -- Video control signals
		lvds_sel		    : inout std_logic;
		vdi_pdn			    : out std_logic;
		vai_pdn			    : out std_logic;
		vdo_po1			    : in std_logic;
		vdo_rstn		    : out std_logic;
		dvi_hotplug_n   : out std_logic := '1';	-- HOTPLUG on the DVI input connector
		vsi_resetn	    : inout std_logic;
		vsi_extclk      : out std_logic;

    -- leds
		--vao_led         : out std_logic;
		--vdo_led         : out std_logic;
		--vai_led         : out std_logic;
		--vdi_led         : out std_logic;
    --vli_led         : out std_logic;
    --vsi_led         : out std_logic;

    -- spi eeprom
    ee_ck           : out std_logic;
    ee_si           : out std_logic;
    ee_so           : in std_logic;
    ee_csn          : out std_logic;
    
		clk24_a			    : in std_logic;		-- Buffered copy of on-board 24MHz clock
    clk24_en        : out std_logic;
    
    -- debug header
    -- elements 1,3,5 are virtual pins because fitter barfs
    dbgio           : inout std_logic_vector(7 downto 0);
    
    -- test points (default to in)
		tp82            : in std_logic;
		tp83            : in std_logic;
		tp84            : in std_logic;
		tp109           : in std_logic;
		tp121           : in std_logic
	);

end entity target_top_ep4c;

architecture SYN of target_top_ep4c is

  constant ONBOARD_CLOCK_SPEED  : integer := 24000000;
  constant NIOS_CLOCK_SPEED     : integer := 72500000;

  -- reset signals
  signal init               : std_logic := '1';
	signal reset					    : std_logic := '1';
	signal reset_n            : STD_LOGIC := '0';
	signal soft_reset_n		    : STD_LOGIC := '0';

  -- aliased clock pins
  alias clk_24M             : std_logic is clk24_a;
  --alias clk_24M576_b        : std_logic is clk24_a;
  -- clocks
  
  signal ddc_reset          : std_logic := '0';
  signal dvi_hotplug_s      : std_logic := '0';
  signal dvo_hotplug        : std_logic := '0';
  signal dvo_rdy            : std_logic := '0';
  
  signal led_clk            : std_logic := '0';
	signal test_blink_n	      : std_logic := '1';
  signal clk_120M           : std_logic := '0';
  signal clk_108M           : std_logic := '0';

  -- CYCLONE<->STRATIX SPI signals
  signal audio_pio_i        : std_logic_vector(31 downto 0);
  signal jamma_pio_o        : std_logic_vector(31 downto 0);
  signal keybd_pio_o        : std_logic_vector(31 downto 0);
  signal spi_pio_i          : std_logic_vector(31 downto 0);
  signal spi_pio_o          : std_logic_vector(spi_pio_i'range);
  
begin

	reset_gen : process(clk_24M)
		variable reset_cnt : integer := 999999;
	begin
		if rising_edge(clk_24M) then
			if reset_cnt > 0 then
				init <= '1';
				reset_cnt := reset_cnt - 1;
			else
				init <= '0';
			end if;
		end if;
	end process reset_gen;

  -- can reset the whole chip from the mixer bus
  reset <= init; -- or not tp_84; --veb_reset;
	reset_n <= not reset;

  GEN_VID_RESET : if not S5AR2_HAS_PS2 generate
    vid_reset_n <= dbgio(7);
  end generate GEN_VID_RESET;
  
  ep4c_pll_inst : entity work.ep4c_pll
    port map
    (
      inclk0		=> clk_24M,
      c0		    => open, --uh_clkin,      -- 12MHz
      c1		    => open, --clk_NIOS,      -- 72MHz
      c2		    => vid_clk,       -- 24MHz
      c3        => vsi_extclk,    -- 14.4MHz
      c4		    => uh_clkin1,     -- 12MHz 3V3
      locked		=> open --pll_locked
    );

  uh_clkin0 <= 'Z';
  
  lvdsplla : entity work.lpll
		port map	
		(
			areset			=> reset,
			inclk0			=> lvds_a_clk,
			c0					=> open, --vid_a_fastclk,
			c1					=> open, --vid_a_syncclk,
			c2					=> open, --vli_clk,
			locked			=> open --lvds_locked
		);
	
    -- hook up the debug input (* not available)
    --     5V  - 1  2 - GND
    -- DBGIO0  - 3  4 - DBGIO7
    -- DBGIO1* - 5  6 - DBGIO6
    -- DBGIO2  - 7  8 - DBGIO5*
    -- DBGIO3* - 9 10 - DBGIO4
    --

  GEN_PS2 : if S5AR2_HAS_PS2 generate
  
    alias ps2_kdat  : std_logic is vid_address(3);
    alias ps2_mdat  : std_logic is vid_address(2);
    alias ps2_kclk  : std_logic is vid_address(1);
    alias ps2_mclk  : std_logic is vid_address(0);
    
    signal ps2_ps2_kclk : std_logic;
    signal ps2_ps2_kdat : std_logic;
    signal usb_ps2_kclk : std_logic;
    signal usb_ps2_kdat : std_logic;
    
    alias ps2_fifo_data   : std_logic_vector(7 downto 0) is keybd_pio_o(7 downto 0);
    alias ps2_use_usb     : std_logic is keybd_pio_o(31);
    alias ps2_fifo_wren   : std_logic is keybd_pio_o(30);
    signal ps2_fifo_wrreq : std_logic;
    
  begin
  
    ps2_kclk <= ps2_ps2_kclk when ps2_use_usb = '0' else
                usb_ps2_kclk;
    ps2_kdat <= ps2_ps2_kdat when ps2_use_usb = '0' else
                usb_ps2_kdat;
                
    -- this is the VEB Button Board (MCE-as-S5D@1)
    -- - configured as PS/2 input
    vid_reset_n <= '1';
    ps2_ps2_kdat <= dbgio(5);
    ps2_mdat <= dbgio(4);
    ps2_ps2_kclk <= dbgio(7);
    ps2_mclk <= dbgio(6);
    dbgio(7 downto 4) <= (others => 'Z');

    process (clk_24M, reset)
      variable wren_r : std_logic_vector(3 downto 0);
      alias wren_prev : std_logic is wren_r(wren_r'left);
      alias wren_um   : std_logic is wren_r(wren_r'left-1);
    begin
      if reset = '1' then
      elsif rising_edge(clk_24M) then
        ps2_fifo_wrreq <= '0';
        if wren_prev = '0' and wren_um = '1' then
          ps2_fifo_wrreq <= '1';
        end if;
        wren_r := wren_r(wren_r'left-1 downto 0) & ps2_fifo_wren;
      end if;
    end process;
    
    ps2_host_inst : entity work.usb_ps2_host
      generic map
      (
        CLK_HZ          => 24000000
      )
      port map
      (
        clk             => clk_24M,
        reset           => reset,
    
        -- FIFO interface
        fifo_data       => ps2_fifo_data,
        fifo_wrreq      => ps2_fifo_wrreq,
        fifo_full       => open,
            
        -- PS/2 lines
        ps2_kclk        => usb_ps2_kclk,
        ps2_kdat        => usb_ps2_kdat
      );
    
  end generate GEN_PS2;
  
  BLK_DVO_INIT : block

    signal vdo_scl_i      : std_logic := '0';
    signal vdo_scl_o      : std_logic := '0';
    signal vdo_scl_oe_n   : std_logic := '0';
    signal vdo_sda_i      : std_logic := '0';
    signal vdo_sda_o      : std_logic := '0';
    signal vdo_sda_oe_n   : std_logic := '0';

    signal ctl            : std_logic_vector(3 downto 1) := (others => '0');
    
  begin

    -- VO I2C (init) drivers
    vdo_scl_i <= vdo_scl;
    vdo_scl <= vdo_scl_o when vdo_scl_oe_n = '0' else 'Z';
    vdo_sda_i <= vdo_sda;
    vdo_sda <= vdo_sda_o when vdo_sda_oe_n = '0' else 'Z';
  
    --ctl <= not (dbgio(4) & dbgio(6) & dbgio(7));
    ctl <= "000";

    dvo_sm : entity work.dvo_init_i2c_sm_controller
      generic map
      (
        clock_speed	=> ONBOARD_CLOCK_SPEED,
        dsel        => '0',

        -- DE generation
        DE_GEN      => S5AR2_DE_GEN,
        VS_POL      => S5AR2_VS_POL,
        HS_POL      => S5AR2_HS_POL,
        DE_DLY      => S5AR2_DE_DLY,
        DE_TOP      => S5AR2_DE_TOP,
        DE_CNT      => S5AR2_DE_CNT,
        DE_LIN      => S5AR2_DE_LIN
      )
      port map
      (
        clk					=> clk_24M,
        clk_ena     => '1',
        reset				=> reset,

        -- CTL outputs
        ctl         => ctl,
        
        -- I2C physical interface
        scl_i  	    => vdo_scl_i,
        scl_o  	    => vdo_scl_o,
        scl_oe_n    => vdo_scl_oe_n,
        sda_i  	    => vdo_sda_i,
        sda_o  	    => vdo_sda_o,
        sda_oe_n    => vdo_sda_oe_n
      );

  end block BLK_DVO_INIT;

  BLK_NIOS : block
  
    signal clk_nios           : std_logic;
    signal rst_nios           : std_logic;

    -- here's everything we're not using for now
    signal debug_pio_i        : std_logic_vector(31 downto 0);
    signal debug_pio_o        : std_logic_vector(debug_pio_i'range);

    -- USB interrupts
    signal oxu210hp_int_mask  : std_logic := '0';
    signal uh_intn_s          : std_logic;

    -- not driven by the NIOS at this point
    signal vdo_scl_i          : std_logic := '0';
    signal vdo_scl_o          : std_logic := '0';
    signal vdo_scl_oe_n       : std_logic := '0';
    signal vdo_sda_i          : std_logic := '0';
    signal vdo_sda_o          : std_logic := '0';
    signal vdo_sda_oe_n       : std_logic := '0';

    -- uarts (not used yet)
    signal ser_ts_cts_p       : std_logic;
    signal ser_ts_rts_p       : std_logic;
    signal ser_pc_cts_p       : std_logic;
    signal ser_pc_rts_p       : std_logic;
    
    -- VO PIO (not used yet)
    signal vo_pio_i           : std_logic_vector(7 downto 0);
    signal vo_pio_o           : std_logic_vector(vo_pio_i'range);
    
    -- these signals are only on the LITE
    signal cfg_data           : std_logic;
    signal cfg_dclk_s         : std_logic;
    signal cfg_cson_s         : std_logic;
    signal cfg_asdo_s         : std_logic;
    -- MCU i/f
		signal mcu_pio_i			    : std_logic_vector (7 downto 0);
		signal mcu_pio_o			    : std_logic_vector (mcu_pio_i'range);
    signal mcu_spi_miso       : std_logic;
    signal mcu_spi_mosi       : std_logic;
    signal mcu_spi_sclk       : std_logic;
    signal mcu_spi_ss_n       : std_logic;
    signal mcu_spi_mrdy_n     : std_logic;
    signal mcu_spi_srdy_n     : std_logic;
    -- security chip
    signal sec_data           : std_logic;
    -- USB leds
		signal usb_led_host		    : std_logic;
		signal usb_led_client	    : std_logic;
		signal usb_led_low			  : std_logic;
		signal usb_led_spare		  : std_logic;
    
  begin

    -- should unmeta this!?!
    rst_nios <= init;
    
    -- NIOS
    nios_inst : entity work.ep4c_sopc_system
      port map
      (
        -- 1) global signals:
        altmemddr_0_aux_full_rate_clk_out												=> open,
        altmemddr_0_aux_half_rate_clk_out												=> clk_nios,
        altmemddr_0_phy_clk_out																	=> open,
        clk_24M																									=> clk24_a,
        reset_n                                                 => not rst_nios,

        -- the_altmemddr_0
        global_reset_n_to_the_altmemddr_0												=> reset_n,
        local_init_done_from_the_altmemddr_0										=> open,
        local_refresh_ack_from_the_altmemddr_0									=> open,
        local_wdata_req_from_the_altmemddr_0										=> open,
        mem_addr_from_the_altmemddr_0														=> ddr16_a,			
        mem_ba_from_the_altmemddr_0															=> ddr16_ba(1 downto 0),
        mem_cas_n_from_the_altmemddr_0													=> ddr16_cas_n,
        mem_cke_from_the_altmemddr_0														=> ddr16_cke,
        mem_clk_n_to_and_from_the_altmemddr_0										=> ddr16_clk_n,
        mem_clk_to_and_from_the_altmemddr_0											=> ddr16_clk,
        mem_cs_n_from_the_altmemddr_0														=> ddr16_cs_n,
        mem_dm_from_the_altmemddr_0															=> ddr16_dm,
        mem_dq_to_and_from_the_altmemddr_0											=> ddr16_dq(15 downto 0),
        mem_dqs_to_and_from_the_altmemddr_0											=> ddr16_dqs,
        mem_odt_from_the_altmemddr_0														=> ddr16_odt,
        mem_ras_n_from_the_altmemddr_0													=> ddr16_ras_n,
        mem_we_n_from_the_altmemddr_0														=> ddr16_we_n,
        reset_phy_clk_n_from_the_altmemddr_0										=> open,

        -- the_audio_pio
        in_port_to_the_audio_pio                                => (others => '0'),

        -- the_debug_pio
        in_port_to_the_debug_pio                                => debug_pio_i,
        out_port_from_the_debug_pio                             => debug_pio_o,

        -- the_epcs_spi
        MISO_to_the_epcs_spi																		=> cfg_data,
        SCLK_from_the_epcs_spi																	=> cfg_dclk_s,
        SS_n_from_the_epcs_spi																	=> cfg_cson_s,
        MOSI_from_the_epcs_spi																	=> cfg_asdo_s,

        -- the_jamma_pio
        out_port_from_the_jamma_pio                             => jamma_pio_o,

        -- the_keybd_pio
        out_port_from_the_keybd_pio                             => keybd_pio_o,

        -- the_m95320
        MISO_to_the_m95320                                      => ee_so,
        MOSI_from_the_m95320                                    => ee_si,
        SCLK_from_the_m95320                                    => ee_ck,
        SS_n_from_the_m95320                                    => ee_csn,

        -- the_one_wire_interface_0
        data_to_and_from_the_one_wire_interface_0               => sec_data,

        -- the_oxu210hp_if_0
        coe_uh_a_from_the_oxu210hp_if_0                         => uh_a,
        coe_uh_be_from_the_oxu210hp_if_0                        => uh_be,
        coe_uh_cs_n_from_the_oxu210hp_if_0                      => uh_csn,
        coe_uh_d_to_and_from_the_oxu210hp_if_0                  => uh_d,
        coe_uh_dack_from_the_oxu210hp_if_0                      => uh_dack,
        coe_uh_dreq_to_the_oxu210hp_if_0                        => uh_dreq,
        coe_uh_int_n_to_the_oxu210hp_if_0                       => uh_intn_s,
        coe_uh_rd_n_from_the_oxu210hp_if_0                      => uh_rdn,
        coe_uh_reset_n_from_the_oxu210hp_if_0                   => uh_resetn,
        coe_uh_wr_n_from_the_oxu210hp_if_0                      => uh_wrn,

        -- the_spi_pio
        in_port_to_the_spi_pio                                  => spi_pio_i,
        out_port_from_the_spi_pio                               => spi_pio_o,

        -- the_oxu210hp_int
        in_port_to_the_oxu210hp_int                             => uh_intn,
        out_port_from_the_oxu210hp_int                          => oxu210hp_int_mask,

        -- the_tfp410_i2c_master
        coe_arst_arst_i_to_the_tfp410_i2c_master                => rst_nios,
        coe_i2c_scl_pad_i_to_the_tfp410_i2c_master              => vdo_scl_i,
        coe_i2c_scl_pad_o_from_the_tfp410_i2c_master            => vdo_scl_o,
        coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master         => vdo_scl_oe_n,
        coe_i2c_sda_pad_i_to_the_tfp410_i2c_master              => vdo_sda_i,
        coe_i2c_sda_pad_o_from_the_tfp410_i2c_master            => vdo_sda_o,
        coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master         => vdo_sda_oe_n,

        -- the_uart_pc
        cts_to_the_uart_pc                                      => ser_pc_cts_p,
        rts_from_the_uart_pc                                    => ser_pc_rts_p,
        rxd_led_from_the_uart_pc                                => open,
        rxd_to_the_uart_pc                                      => ser_pc_rx,
        txd_active_from_the_uart_pc                             => open,
        txd_from_the_uart_pc                                    => ser_pc_tx,
        txd_led_from_the_uart_pc                                => open,

        -- the_uart_ts
        cts_to_the_uart_ts                                      => ser_ts_cts_p,
        rts_from_the_uart_ts                                    => ser_ts_rts_p,
        rxd_led_from_the_uart_ts                                => open,
        rxd_to_the_uart_ts                                      => ser_ts_rx,
        txd_active_from_the_uart_ts                             => open,
        txd_from_the_uart_ts                                    => ser_ts_tx,
        txd_led_from_the_uart_ts                                => open,

        -- the_usb_pio
        out_port_from_the_usb_pio(3)														=> usb_led_spare,
        out_port_from_the_usb_pio(2)														=> usb_led_low,
        out_port_from_the_usb_pio(1)														=> usb_led_client,
        out_port_from_the_usb_pio(0)														=> usb_led_host,

        -- the_version_pio
        in_port_to_the_version_pio                              => X"00000001",
        out_port_from_the_version_pio                           => open,

        -- the_vo_pio
        in_port_to_the_vo_pio                                   => vo_pio_i,
        out_port_from_the_vo_pio                                => vo_pio_o
      );

    -- We can disable uh_intn to the nios by setting oxu210hp_int pio to '1'
		uh_intn_s	<= uh_intn or oxu210hp_int_mask;

  end block BLK_NIOS;
  
  BLK_SPI : block
  begin
    -- transmit jamma and keyboard to the STRATIX
    process (clk_24M, reset)
      variable spi_go_r : std_logic_vector(3 downto 0);
      alias spi_go_prev : std_logic is spi_go_r(spi_go_r'left);
      alias spi_go_um   : std_logic is spi_go_r(spi_go_r'left-1);
      variable spi_d_r  : std_logic_vector(jamma_pio_o'range);
      variable count    : unsigned(6 downto 0);
      variable spi_clk  : std_logic;
    begin
      if reset = '1' then
        spi_go_r := (others => '0');
        count := (others => '1');
      elsif rising_edge(clk_24M) then
        -- start a transfer
        if spi_go_prev = '0' and spi_go_um = '1' then
          -- this should be stable before 'go'
          spi_d_r := jamma_pio_o;
          count := (others => '0');
          spi_clk := '0';
        elsif count(count'left) = '0' then
          spi_clk := not spi_clk;
          if spi_clk = '0' then
            spi_d_r := spi_d_r(spi_d_r'left-1 downto 0) & '0';
          end if;
          count := count + 1;
        end if;
        -- unmeta the spi_pio_o 'go' signal
        spi_go_r := spi_go_r(spi_go_r'left-1 downto 0) & spi_pio_o(0);
      end if;
      -- assign to pin
      vid_address(4) <= not count(count'left);
      vid_address(5) <= spi_clk;
      vid_address(6) <= spi_d_r(spi_d_r'left);
    end process;
    
  end block BLK_SPI;
  
  BLK_FLASHER : block
  begin
    -- flash the led so we know it's alive
    process (clk_24M, reset)
      variable count : std_logic_vector(21 downto 0);
    begin
      if reset = '1' then
        count := (others => '0');
      elsif rising_edge(clk_24M) then
        count := std_logic_vector(unsigned(count) + 1);
      end if;
      -- invert this only so it is out-of-phase with the EP3SL LED
      -- if they're both configured from the EPCS64...
      --vao_led <= not count(count'left);
    end process;
  end block BLK_FLASHER;

  -- leds from the EP3SL
  --dbgled(8 downto 5) <= vid_spare(8 downto 5);
  
  BLK_LEDS : block
    signal leds_o : std_logic_vector(7 downto 0);
  begin
    vid_data <= (others => '0');
    leds_o <= vid_data(7 downto 0);
  end block BLK_LEDS;
  
	BLK_CHASER : block

		signal chaseen        : std_logic;
		signal pwmen	        : std_logic;
		signal ledout					: std_logic_vector(3 downto 0);

	begin
	  pchaser: entity work.pwm_chaser
			generic map(nleds  => 4, nbits => 8, period => 4, hold_time => 12)
			port map (clk => clk_24M, clk_en => chaseen, pwm_en => pwmen, reset => reset, fade => X"0F", ledout => ledout);
			
		-- Generate pwmen pulse every 256 clocks, chase pulse every 256k clocks
		process(clk_24M, reset)
			variable pcount     : std_logic_vector(7 downto 0);
			variable pwmen_r    : std_logic;
			variable ccount     : std_logic_vector(17 downto 0);
			variable chaseen_r  : std_logic;
		begin
			pwmen <= pwmen_r;
			chaseen <= chaseen_r;
			if reset = '1' then
				pcount := (others => '0');
				ccount := (others => '0');
			elsif rising_edge(clk_24M) then
				pwmen_r := '0';
				if pcount = std_logic_vector(to_unsigned(0, pcount'length)) then
					pwmen_r := '1';
				end if;
				chaseen_r := '0';
				if ccount = std_logic_vector(to_unsigned(0, ccount'length)) then
					chaseen_r := '1';
				end if;
				pcount := std_logic_vector(unsigned(pcount) + 1);
				ccount := std_logic_vector(unsigned(ccount) + 1);
			end if;
		end process;

    --dbgled(4 downto 0) <= not ledout;
    dbgio(3) <= ledout(3);
    dbgio(2) <= ledout(2);
    dbgio(1) <= ledout(1);
    dbgio(0) <= ledout(0);

	end block BLK_CHASER;

  -- constant drivers
  v15_s3 <= 'Z';
  v15_s5 <= 'Z';
	veb_pwrgoodn  <= not (pok_12v and pok_5v and pok_3v3 and pok_1v9 and v15_pgood);
	lvds_sel		  <= 'Z';
	vai_pdn			  <= '0'; --reset_pio(2);
	vsi_resetn	  <= '1';
  vdo_rstn      <= reset_n;

  clk24_en      <= '1';
  dvi_connect   <= '1';
  dvi_oen       <= '0';

end architecture SYN;
