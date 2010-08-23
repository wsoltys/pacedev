library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera;
use altera.altera_syn_attributes.all;

library work;

entity target_top_ep4c is
	port
	(
    -- I2C on the DVI input connector
		dvi_scl			    : inout std_logic;
		dvi_sda			    : inout std_logic;

    -- I2C on the DVI output connector
		dvo_scl			    : inout std_logic;
		dvo_sda			    : inout std_logic;

    -- I2C to the TFP410 (DVI out transmitter)
    vdo_scl       : inout std_logic;
    vdo_sda       : inout std_logic;
    
    -- I2C on the video ADC
		vai_scl			    : inout std_logic;
		vai_sda			    : inout std_logic;

    -- I2C on the SDVO to LVDS transceiver
		vsi_scl			    : inout std_logic;
		vsi_sda			    : inout std_logic;

		veb_ck_a		    : in std_logic;	-- Buffered copy of carrier 24MHz clock
		veb_ck_sp		    : in std_logic;	-- Spare clock output from carrier FPGA
		
		-- Carrier LPC bus interface
		veb_reset		    : in std_logic;
		veb_framen		  : in std_logic;
		veb_a			      : inout std_logic_vector(3 downto 0);
		veb_a_dir   	  : out std_logic;
		veb_irqn		    : in std_logic;
		-- Spare I/O to carrier FPGA
		veb_sp			    : inout std_logic_vector(4 downto 0);

		veb_i2c_clk		  : inout std_logic;
		veb_i2c_dat		  : inout std_logic;
		veb_smb_clk		  : inout std_logic;
		veb_smb_dat		  : inout std_logic;

		-- Touchscreen serial ports
		ser_ts_tx		    : in std_logic;
		ser_ts_rx		    : out std_logic;
		ser_ts_rts	    : out std_logic;
		ser_ts_cts	    : out std_logic;
		ser_pc_tx		    : in std_logic;
		ser_pc_rx		    : out std_logic;
		ser_pc_rts	    : out std_logic;
		ser_pc_cts	    : out std_logic;

		-- LCD B RS485
		lcdb_rx			    : in std_logic;
		lcdb_tx			    : out std_logic;
		lcdb_rtsn		    : out std_logic;

		-- LCD O RS485
		lcdo_rx			    : in std_logic;
		lcdo_tx			    : out std_logic;
		lcdo_rtsn		    : out std_logic;

		-- SRAM
		sram_a			    : out std_logic_vector(17 downto 0);
		sram_d			    : inout std_logic_vector(15 downto 0);
		sram_cs_n		    : out std_logic;
		sram_oe_n		    : out std_logic;
		sram_we_n		    : out std_logic;
		sram_ub_n		    : out std_logic;
		sram_lb_n		    : out std_logic;

		-- Internal USB controller, external PHY
		ul_spd			    : out std_logic;
		ul_rcv			    : in std_logic;
		ul_v_p			    : inout std_logic;
		ul_v_n			    : inout std_logic;
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
		uh_intn		      : in std_logic;
		uh_dreq		      : in std_logic_vector(1 downto 0);
		uh_dack			    : out std_logic_vector(1 downto 0);
		
		uh_clkin		    : out std_logic;
		
		-- Connection to video FPGA
		vid_address		  : out std_logic_vector(10 downto 0);
		vid_data		    : inout std_logic_vector(15 downto 0);
		vid_write_n		  : out std_logic;
		vid_read_n		  : out std_logic;
		vid_waitrequest	: in std_logic;
		vid_irq_n			  : in std_logic;
		vid_clk			    : out std_logic;
		
		vid_spare		    : out std_logic_vector(31 downto 0);
		--vid_sp_clk	    : out std_logic;
		
    -- I2C to the vid FPGA
		vid_scl			    : inout std_logic;
		vid_dat			    : inout std_logic;

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
		veb_pwrgoodn    :	out std_logic;
	
    -- Video control signals
		lvds_sel		    : inout std_logic;
		vdi_pdn			    : out std_logic;
		vai_pdn			    : out std_logic;
		vdo_po1			    : in std_logic;
		vdo_rstn		    : out std_logic;
		dvi_hotplug	    : out std_logic := '1';	-- HOTPLUG on the DVI input connector
		vsi_resetn	    : inout std_logic;

		dbgled			    : out std_logic_vector(9 downto 0);

		clk24_a			    : in std_logic;		-- Buffered copy of on-board 24MHz clock
		
		s3_ck				    : in std_logic;		-- Spare clock input from S3
		
		tp_80           : in std_logic;
		tp_84           : in std_logic
	);

end entity target_top_ep4c;

architecture SYN of target_top_ep4c is

  constant ONBOARD_CLOCK_SPEED  : integer := 24000000;

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
  reset <= init or not tp_84; --veb_reset;
	reset_n <= not reset;

    nios_pll_inst : entity work.ep4c_pll
      port map
      (
        inclk0		=> clk_24M,
        c0		    => clk_120M,        -- 120MHz
        c1		    => clk_108M,        -- 108MHz
        c2		    => open,            -- 108MHz
        c3        => open,            -- 65MHz (1024x768), 108MHz (1280x1024)
        c4        => open,            -- 65MHz (1024x768), 108MHz (1280x1024)
        locked		=> open
      );
  
  BLK_DVO_INIT : block

    signal vdo_scl_i      : std_logic := '0';
    signal vdo_scl_o      : std_logic := '0';
    signal vdo_scl_oe_n   : std_logic := '0';
    signal vdo_sda_i      : std_logic := '0';
    signal vdo_sda_o      : std_logic := '0';
    signal vdo_sda_oe_n   : std_logic := '0';

  begin

    -- VO I2C (init) drivers
    vdo_scl_i <= vdo_scl;
    vdo_scl <= vdo_scl_o when vdo_scl_oe_n = '0' else 'Z';
    vdo_sda_i <= vdo_sda;
    vdo_sda <= vdo_sda_o when vdo_sda_oe_n = '0' else 'Z';

    dvo_sm : entity work.dvo_init_i2c_sm_controller
      generic map
      (
        clock_speed	=> ONBOARD_CLOCK_SPEED,
        dsel        => '0'
      )
      port map
      (
        clk					=> clk_24M,
        clk_ena     => '1',
        reset				=> reset,

        -- I2C physical interface
        scl_i  	    => vdo_scl_i,
        scl_o  	    => vdo_scl_o,
        scl_oe_n    => vdo_scl_oe_n,
        sda_i  	    => vdo_sda_i,
        sda_o  	    => vdo_sda_o,
        sda_oe_n    => vdo_sda_oe_n
      );

  end block BLK_DVO_INIT;

  BLK_CHASER : block
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
      dbgled <= (others => count(count'left));
    end process;
  end block BLK_CHASER;

  -- constant drivers
	v15_s3				<= '0';
	v15_s5				<= '0';
	veb_pwrgoodn <= pok_12v and pok_5v and pok_3v3 and pok_1v9 and v15_pgood;
	lvds_sel		<= 'Z';
	vai_pdn			<= '1';
	dvi_hotplug	<= '1';
	vsi_resetn	<= '1';
  vdi_pdn <= '1';
  vdo_rstn <= reset_n;
  veb_a <= (others => 'Z');
  veb_a_dir <= '1';
  
end architecture SYN;
