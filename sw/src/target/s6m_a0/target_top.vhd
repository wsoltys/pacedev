library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
	port
	(
	 --main resets
	   -- main FPGA reset will be based on PLL locked signal 
		-- probably all pll_locked signals tied together, but minimum nios_pll
		-- along with soft_reset_n coming from MCU (performing power management)
	 soft_reset_n   : in std_logic;
	 
	 -- main clock inputs
	 clk24_1v5 : in std_logic; -- 1.5 v
	 clk24_3v3	: in std_logic; --3.3 v 
	 clk24_spare : in std_logic; --3.3 v 

    --DDR3 interface - soft controller - 64 bits
	 --Hynix 533 MHz 16bit address, one cklock bit, one chip select, 8 DQS groups 
    ddr64_a      : out std_logic_vector(15 downto 0);    
	 ddr64_ba     : out std_logic_vector(2 downto 0);
	 ddr64_odt    : out std_logic_vector(0 downto 0);
   -- can't compile with these unconnected, so comment out
	 --ddr64_ck     : out std_logic_vector(0 downto 0);
	 --ddr64_ck_n   : out std_logic_vector(0 downto 0);
	 ddr64_cs_n   : out std_logic_vector(0 downto 0);
	 ddr64_cke     : out std_logic_vector(0 downto 0);
	 ddr64_ras_n   : out   std_logic_vector(0 downto 0); 
	 ddr64_cas_n   : out   std_logic_vector(0 downto 0); 
	 ddr64_we_n    : out std_logic_vector(0 downto 0);
	 ddr64_dq      : inout std_logic_vector(63 downto 0);
   -- can't compile with these unconnected, so comment out
	 --ddr64_dqs     : inout std_logic_vector(7 downto 0);
	 --ddr64_dqs_n    : inout std_logic_vector(7 downto 0);
	 ddr64_dm      : out std_logic_vector(7 downto 0);
	 ddr64_reset_n : out std_logic;
	 oct_0_rzqin   : in std_logic;
	 
    -- video from the main unit ---3.3 V
    hdmi_vsync    : in std_logic;
    hdmi_hsync    : in std_logic;
    hdmi_scdt     : in std_logic;
    hdmi_de       : in std_logic;
    hdmi_red      : in std_logic_vector(7 downto 0);
    hdmi_green    : in std_logic_vector(7 downto 0);
    hdmi_blue     : in std_logic_vector(7 downto 0);
    hdmi_odck     : in std_logic;

    -- DVI output, 1V5 I/O 1 pix/clk, 24-bit mode
	 vdo_red			  : out std_logic_vector(7 downto 0);
	 vdo_green		  : out std_logic_vector(7 downto 0);
	 vdo_blue		  : out std_logic_vector(7 downto 0);
	 vdo_idck		  : out std_logic;   --Differential	1.5-V	SSTL	Class	I
	 vdo_hsync		  : out std_logic;
	 vdo_vsync		  : out std_logic;
	 vdo_de			  : out std_logic;

    -- DVI input, 1 pix/clk, 24-bit mode 3.3-V	LVCMOS 
	 vdi_odck			: in std_logic;
	 vdi_red				: in std_logic_vector(7 downto 0);
	 vdi_green			: in std_logic_vector(7 downto 0);
	 vdi_blue			: in std_logic_vector(7 downto 0);
	 vdi_de				: in std_logic;
	 vdi_vsync			: in std_logic;
	 vdi_hsync			: in std_logic;
	 vdi_scdt			: in std_logic;

    -- VGA input, 1 pix/clk, 30-bit mode 3.3-V	LVCMOS
	 vai_dataclk	: in std_logic;
	 vai_extclk		: out std_logic;
	 vai_red			: in std_logic_vector(7 downto 0); --used to be 10 pins
	 vai_green		: in std_logic_vector(7 downto 0);
	 vai_blue		: in std_logic_vector(7 downto 0);
	 vai_vsout		: in std_logic;
	 vai_hsout		: in std_logic;
	 vai_vsync		: in std_logic;
	 vai_hsync		: in std_logic;
	 vai_sogout		: in std_logic;
	 vai_datavalid	: in std_logic;
	 vai_resetb_n	: out std_logic;
	 vai_coast		: out std_logic;

    -- VGA output, 1 pix/clk, 30-bit mode  ------1.8	V
	 vao_clk	     : out std_logic;
	 vao_red		  : out std_logic_vector(7 downto 0); --used to be 10 pins
	 vao_green	  : out std_logic_vector(7 downto 0);
	 vao_blue	  : out std_logic_vector(7 downto 0);
	 vao_hsync    : out std_logic;  --3.3-V	LVCMOS
	 vao_vsync    : out std_logic;  --3.3-V	LVCMOS
	 vao_blank_n  : out std_logic;
	 vao_sync_n	  : out std_logic;
	 vao_sync_t	  : out std_logic;
	 vao_m1		  : out std_logic;
	 vao_m2		  : out std_logic;
----------------------------------------------------------------------------------
------cyclone 4 part
--------------------------------------------------------------------------
    -- I2C on the DVI input connector ---3.3-V	LVCMOS
	 dvi_eep_scl			  : inout std_logic;
	 dvi_eep_sda			  : inout std_logic;
    dvi_dis_eep_ddc       : out   std_logic := '1';   -- disabled
    dvi_eep_wp            : out   std_logic := 'Z';   -- default h/w

	 dvi_fpga_scl			  : inout std_logic;
	 dvi_fpga_sda			  : inout std_logic;
    dvi_dis_fpga_ddc      : out   std_logic := '0';   -- enabled

    dvi_en_i2c            : out   std_logic := 'Z';
    dvi_connect           : out   std_logic := '1';   -- connected
    dvi_oen               : out   std_logic := '0';   -- enabled
    
    -- I2C on the DVI output connector
	 dvo_scl			        : inout std_logic;
	 dvo_sda			        : inout std_logic;

    -- I2C to the TFP410 (DVI out transmitter) 
    vdo_scl               : inout std_logic;
    vdo_sda               : inout std_logic;
    
    -- I2C on the video ADC 
	 vai_scl			        : inout std_logic;
	 vai_sda			        : inout std_logic;

	 -- I2C on the HDMI input connector 
	 hdmi_fpga_scl		     : inout std_logic;
	 hdmi_fpga_sda		     : inout std_logic;
    
	 -- Interface to/from the USB MCU
	 mcu_ep1_rdy_n         : in    std_logic;
	 mcu_ep2_rdy_n         : in    std_logic;
	 mcu_ep3_rdy_n         : in    std_logic;
    mcu_spi_irq_n         : out   std_logic;
    mcu_spi_srdy_n        : out   std_logic;
    mcu_spi_mrdy_n        : in    std_logic;
	 ------
    mcu_spi_nss		     : in    std_logic_vector(1 downto 0);
	 mcu_spi_sck		     : in    std_logic;
	 mcu_spi_miso		     : out   std_logic;
	 mcu_spi_mosi		     : in    std_logic;
	 ------
	 nios_alive_n          : out   std_logic;
	 ------
	 mcu_sda               : inout std_logic;
	 mcu_scl               : inout std_logic;
	 
	 -- Touchscreen serial ports
	 ser_ts_tx		        : out   std_logic;
	 ser_ts_rx		        : in    std_logic;
	 ser_ts_rts	           : out   std_logic;
	 ser_ts_cts	           : in    std_logic;
	 ser_pc_tx		        : out   std_logic;
	 ser_pc_rx		        : in    std_logic;
	 ser_pc_rts	           : out   std_logic;
	 ser_pc_cts	           : in    std_logic;
	 rs232_gpio            : inout std_logic;

	 -- External USB controller 2.5 Volts
	 usb_resetn	           : out std_logic;  --outside
	 usb_a				     : out std_logic_vector(16 downto 1); --outside
	 usb_d				     : inout std_logic_vector(31 downto 0);
	 usb_csn			        : out std_logic;
	 usb_rdn			        : out std_logic;
	 usb_wrn			        : out std_logic;
	 usb_be                : out std_logic_vector(3 downto 0);
	 usb_intn		        : in std_logic;  --outside
	 usb_dreq		        : in std_logic_vector(1 downto 0);
	 usb_dack			     : out std_logic_vector(1 downto 0);    
	 usb_clk		           : out std_logic;

	 -- USB power and LED control signals 3.3-V	LVCMOS
	 usb_led_host	        : inout std_logic;
	 usb_led_client	     : inout std_logic;
	 usb_client_pwr        : inout std_logic;
	 usb_passthru_pwr      : inout std_logic;
	
    -- Video control signals
	 vdi_pdn			        : out std_logic; --3.3-V	LVCMOS
	 vai_pdn			        : out std_logic;
	 hdmi_pdn			     : out std_logic;
	 vdo_po1			        : in std_logic;
	 vdo_rstn		        : out std_logic;
	 dvi_hotplug_n         : out std_logic := '1';	-- HOTPLUG on the DVI input connector
	 hdmi_hotplug_n	     : out std_logic := '1';	-- HOTPLUG on the DVI input connector
	 vdi_present		     : in std_logic;
	 hdmi_present		     : in std_logic;
	 avi_disconnect	     : out std_logic;
--	 clk24_en              : out std_logic;
		
    -- leds
	 led_hdmi		        : out std_logic;
	 led_avo			        : out std_logic;
	 led_dvo			        : out std_logic;
	 led_avi			        : out std_logic;
	 led_dvi			        : out std_logic;
	 led_nios              : out std_logic;
	 
      -- spi eeprom
    ee_ck               : out std_logic;
    ee_si               : out std_logic;
    ee_so               : in std_logic;
    ee_csn              : out std_logic;
     ---security
	 ow_data              : inout std_logic;
    -- debug header 
    dbgio               : inout std_logic_vector(7 downto 0);
    -- test points (default to in)
	 tp82                  : in std_logic;
	 tp83                  : in std_logic;
	 tp84                  : in std_logic;
	 tp109                 : in std_logic

	 -- "external" configuration pins to EPCS
	    -- Altera does not allow specifically calling out pins as dual-purpose in desiggn
	    -- but, adding EPCS flash programmer will automagically connect to pins
	 -- altera_reserved_dclk         : out   std_logic;             -- dclk
	 -- altera_reserved_sce          : out   std_logic;             -- sce
	 -- altera_reserved_sdo          : out   std_logic;             -- sdo
	 -- altera_reserved_data0        : in    std_logic              -- data0

	);
end entity target_top;

architecture SYN of target_top is

  constant ONBOARD_CLOCK_SPEED  : integer := 24000000;

  -- reset signals
  signal init               : std_logic := '1';
	signal reset					    : std_logic := '1';
	signal reset_n            : STD_LOGIC := '0';
	--signal soft_reset_n		    : STD_LOGIC := '0';

  -- aliased clock pins
  alias clk_24M             : std_logic is clk24_3v3;
  --alias clk_24M576_b        : std_logic is clk24_a;

  signal clk_108M     : std_logic := '0';
  signal vip_clk      : std_logic := '0';
  signal vdo_clk_x2   : std_logic := '0';
  
  signal pll_locked     : std_logic := '0';

  -- clocks
  signal clkrst_i       : from_CLKRST_t;
  signal buttons_i    	: from_BUTTONS_t;
  signal switches_i   	: from_SWITCHES_t;
  signal leds_o         : to_LEDS_t;
  signal inputs_i       : from_INPUTS_t;
  signal flash_i        : from_FLASH_t;
  signal flash_o        : to_FLASH_t;
	signal sram_i			    : from_SRAM_t;
	signal sram_o			    : to_SRAM_t;	
	signal sdram_i        : from_SDRAM_t;
	signal sdram_o        : to_SDRAM_t;
	signal video_i        : from_VIDEO_t;
  signal video_o        : to_VIDEO_t;
  signal audio_i        : from_AUDIO_t;
  signal audio_o        : to_AUDIO_t;
  signal ser_i          : from_SERIAL_t;
  signal ser_o          : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

  signal ps2_kclk       : std_logic;
  signal ps2_kdat       : std_logic;
  signal ps2_mclk       : std_logic;
  signal ps2_mdat       : std_logic;

begin

	reset_gen : process (clk_24M)
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

  clkrst_i.arst <= init; -- or not vid_reset_n;
	clkrst_i.arst_n <= not clkrst_i.arst;
  -- for the EP4C-derived logic
  reset <= init;
  reset_n <= not reset;

  BLK_CLOCKING : block
  
  component pll is
    port (
      refclk   : in  std_logic := '0'; --  refclk.clk
      rst      : in  std_logic := '0'; --   reset.reset
      outclk_0 : out std_logic;        -- outclk0.clk
      outclk_1 : out std_logic;        -- outclk1.clk
      outclk_2 : out std_logic;        -- outclk2.clk
      locked   : out std_logic         --  locked.export
    );
  end component pll;

  begin

    clkrst_i.clk_ref <= clk_24M;
    
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll
--        generic map
--        (
--          -- INCLK0
--          INCLK0_INPUT_FREQUENCY  => 41666,
--
--          -- CLK0
--          CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
--          CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
--      
--          -- CLK1
--          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
--          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
--        )
        port map
        (
          refclk      => clk_24M,
          rst         => reset,
          outclk_0    => clkrst_i.clk(0),
          outclk_1    => clkrst_i.clk(1),
          outclk_2    => vdo_clk_x2,
          locked      => pll_locked
        );
    
    else generate

      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clk_24M;
      clkrst_i.clk(1) <= clk_24M;
        
    end generate GEN_PLL;

  end block BLK_CLOCKING;

  GEN_RESETS : for i in 0 to 3 generate

    process (clkrst_i.clk(i), clkrst_i.arst)
      variable rst_r : std_logic_vector(2 downto 0) := (others => '0');
    begin
      if clkrst_i.arst = '1' then
        rst_r := (others => '1');
      elsif rising_edge(clkrst_i.clk(i)) then
        rst_r := rst_r(rst_r'left-1 downto 0) & '0';
      end if;
      clkrst_i.rst(i) <= rst_r(rst_r'left);
    end process;

  end generate GEN_RESETS;
	
  -- buttons
  buttons_i <= std_logic_vector(to_unsigned(0, buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(to_unsigned(0, switches_i'length));
  -- leds
  --ledout <= leds_o(0);
  
  -- inputs
  process (clkrst_i)
    variable kdat_r : std_logic_vector(2 downto 0);
    variable mdat_r : std_logic_vector(2 downto 0);
    variable kclk_r : std_logic_vector(2 downto 0);
    variable mclk_r : std_logic_vector(2 downto 0);
  begin
    if clkrst_i.rst(0) = '1' then
      kdat_r := (others => '0');
      mdat_r := (others => '0');
      kclk_r := (others => '0');
      mclk_r := (others => '0');
    elsif rising_edge(clkrst_i.clk(0)) then
      kdat_r := kdat_r(kdat_r'left-1 downto 0) & ps2_kdat;
      mdat_r := mdat_r(mdat_r'left-1 downto 0) & ps2_mdat;
      kclk_r := kclk_r(kclk_r'left-1 downto 0) & ps2_kclk;
      mclk_r := mclk_r(mclk_r'left-1 downto 0) & ps2_mclk;
    end if;
    inputs_i.ps2_kdat <= kdat_r(kdat_r'left);
    inputs_i.ps2_mdat <= mdat_r(mdat_r'left);
    inputs_i.ps2_kclk <= kclk_r(kclk_r'left);
    inputs_i.ps2_mclk <= mclk_r(mclk_r'left);
  end process;
  
  BLK_JAMMA : block
  
  begin
  
    inputs_i.jamma_n.coin(1) <= '1';
    inputs_i.jamma_n.p(1).start <= '1';
    inputs_i.jamma_n.p(1).up <= '1';
    inputs_i.jamma_n.p(1).down <= '1';
    inputs_i.jamma_n.p(1).left <= '1';
    inputs_i.jamma_n.p(1).right <= '1';
    inputs_i.jamma_n.p(1).button(1) <= '1';
    inputs_i.jamma_n.p(1).button(2) <= '1';
    inputs_i.jamma_n.p(1).button(3) <= '1';
    inputs_i.jamma_n.p(1).button(4) <= '1';
    inputs_i.jamma_n.p(1).button(5) <= '1';
    
    inputs_i.jamma_n.coin(2) <= '1';
    inputs_i.jamma_n.p(2).start <= '1';
    inputs_i.jamma_n.p(2).up <= '1';
    inputs_i.jamma_n.p(2).down <= '1';
    inputs_i.jamma_n.p(2).left <= '1';
    inputs_i.jamma_n.p(2).right <= '1';
    inputs_i.jamma_n.p(2).button(1) <= '1';
    inputs_i.jamma_n.p(2).button(2) <= '1';
    inputs_i.jamma_n.p(2).button(3) <= '1';
    inputs_i.jamma_n.p(2).button(4) <= '1';
    inputs_i.jamma_n.p(2).button(5) <= '1';

    inputs_i.jamma_n.coin_cnt <= (others => '1');
    inputs_i.jamma_n.service <= '1';
    inputs_i.jamma_n.tilt <= '1';
    inputs_i.jamma_n.test <= '1';
    
  end block BLK_JAMMA;

  BLK_VIDEO : block
    type state_t is (IDLE, S1, S2, S3);
    signal state : state_t := IDLE;
  begin
  
    video_i.clk <= clkrst_i.clk(1);
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);

    -- DVI (digital) output
    GEN_VDO_IDCK : if not S6M_DOUBLE_VDO_IDCK generate
      vdo_idck <= video_o.clk;
    else generate
      vdo_idck <= vdo_clk_x2;
    end generate GEN_VDO_IDCK;
    vdo_red <= video_o.rgb.r(9 downto 2);
    vdo_green <= video_o.rgb.g(9 downto 2);
    vdo_blue <= video_o.rgb.b(9 downto 2);
    vdo_hsync <= video_o.hsync;
    vdo_vsync <= video_o.vsync;
    vdo_de <= not (video_o.hblank or video_o.vblank);

    -- VGA (analogue) output
		vao_clk <= video_o.clk;
		vao_red <= video_o.rgb.r(9 downto 2);
		vao_green <= video_o.rgb.g(9 downto 2);
		vao_blue <= video_o.rgb.b(9 downto 2);
    vao_hsync <= video_o.hsync;
    vao_vsync <= video_o.vsync;
		vao_blank_n <= '1';
		vao_sync_t <= '0';

    -- configure the THS8135 video DAC
    process (video_o.clk, clkrst_i.arst)
      subtype count_t is integer range 0 to 9;
      variable count : count_t := 0;
    begin
      if clkrst_i.arst = '1' then
        state <= IDLE;
        vao_sync_n <= '1';
        vao_m1 <= '0';
        vao_m2 <= '0';
      elsif rising_edge(video_o.clk) then
        case state is
          when IDLE =>
            count := 0;
            state <= S1;
          when S1 =>
            vao_sync_n <= '0';
            vao_m1 <= '0';  -- BLNK_INT (full-range)
            vao_m2 <= '0';  -- sync insertion on 1?
            if count = count_t'high then
              count := 0;
              state <= S2;
            else
              count := count + 1;
            end if;
          when S2 =>
            vao_sync_n <= '1';
            -- RGB mode
            vao_m1 <= '0';
            vao_m2 <= '0';
            if count = count_t'high then
              state <= S3;
            else
              count := count + 1;
            end if;
          when S3 =>
            null;
        end case;
      end if;
    end process;
    
  end block BLK_VIDEO;
  
  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clkrst_i					=> clkrst_i,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => leds_o,
      
      -- controller inputs
      inputs_i          => inputs_i,

     	-- external ROM/RAM
     	flash_i           => flash_i,
      flash_o           => flash_o,
      sram_i        		=> sram_i,
      sram_o        		=> sram_o,
     	sdram_i           => sdram_i,
     	sdram_o           => sdram_o,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i.din         => '0',
      spi_o             => open,
  
      -- serial
      ser_i             => ser_i,
      ser_o             => ser_o,
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

  -- emulate some FLASH
  GEN_FLASH : if S6M_EMULATE_FLASH generate
    flash_inst : entity work.sprom
      generic map
      (
        init_file     => S6M_EMULATED_FLASH_INIT_FILE,
        widthad_a			=> S6M_EMULATED_FLASH_WIDTH_AD,
        width_a				=> S6M_EMULATED_FLASH_WIDTH
      )
      port map
      (
        clock		      => clkrst_i.clk(0),
        address		    => flash_o.a(S6M_EMULATED_FLASH_WIDTH_AD-1 downto 0),
        q		          => flash_i.d(S6M_EMULATED_FLASH_WIDTH-1 downto 0)
      );
    flash_i.d(flash_i.d'left downto S6M_EMULATED_FLASH_WIDTH) <= (others => '0');
  end generate GEN_FLASH;
  
  -- emulate some SRAM
  GEN_SRAM : if S6M_EMULATE_SRAM generate
    signal wren : std_logic := '0';
  begin
    wren <= sram_o.cs and sram_o.we;
    sram_inst : entity work.spram
      generic map
      (
        --numwords_a		=> 2**S6M_EMULATED_SRAM_WIDTH_AD,
        widthad_a			=> S6M_EMULATED_SRAM_WIDTH_AD,
        width_a				=> S6M_EMULATED_SRAM_WIDTH
      )
      port map
      (
        clock		      => clkrst_i.clk(0),
        address		    => sram_o.a(S6M_EMULATED_SRAM_WIDTH_AD-1 downto 0),
        data		      => sram_o.d(S6M_EMULATED_SRAM_WIDTH-1 downto 0),
        wren		      => wren,
        q		          => sram_i.d(S6M_EMULATED_SRAM_WIDTH-1 downto 0)
      );
    sram_i.d(sram_i.d'left downto S6M_EMULATED_SRAM_WIDTH) <= (others => '0');
  end generate GEN_SRAM;

  BLK_PS2 : block
  
  begin
--    GEN_PS2 : if S6M_HAS_PS2 generate
--    
--      signal ps2_ps2_kclk : std_logic;
--      signal ps2_ps2_kdat : std_logic;
--      signal usb_ps2_kclk : std_logic;
--      signal usb_ps2_kdat : std_logic;
--      
--      alias ps2_fifo_data   : std_logic_vector(15 downto 0) is keybd_pio_o(15 downto 0);
--      alias ps2_use_usb     : std_logic is keybd_pio_o(31);
--      alias ps2_fifo_wren   : std_logic is keybd_pio_o(30);
--      signal ps2_fifo_wrreq : std_logic;
--      
--    begin
--    
--      ps2_kclk <= ps2_ps2_kclk when ps2_use_usb = '0' else
--                  usb_ps2_kclk;
--      ps2_kdat <= ps2_ps2_kdat when ps2_use_usb = '0' else
--                  usb_ps2_kdat;
--                  
--      -- this is the VEB Button Board (MCE-as-S5D@1)
--      -- - configured as PS/2 input
--      ps2_ps2_kdat <= dbgio(5);
--      ps2_mdat <= dbgio(4);
--      ps2_ps2_kclk <= dbgio(7);
--      ps2_mclk <= dbgio(6);
--      dbgio(7 downto 4) <= (others => 'Z');
--
--      process (clk_24M, reset)
--        variable wren_r : std_logic_vector(3 downto 0);
--        alias wren_prev : std_logic is wren_r(wren_r'left);
--        alias wren_um   : std_logic is wren_r(wren_r'left-1);
--      begin
--        if reset = '1' then
--        elsif rising_edge(clk_24M) then
--          ps2_fifo_wrreq <= '0';
--          if wren_prev = '0' and wren_um = '1' then
--            ps2_fifo_wrreq <= '1';
--          end if;
--          wren_r := wren_r(wren_r'left-1 downto 0) & ps2_fifo_wren;
--        end if;
--      end process;
--      
--      ps2_host_inst : entity work.usb_ps2_host
--        generic map
--        (
--          CLK_HZ          => 24000000
--        )
--        port map
--        (
--          clk             => clk_24M,
--          reset           => reset,
--      
--          -- FIFO interface
--          fifo_data       => ps2_fifo_data,
--          fifo_wrreq      => ps2_fifo_wrreq,
--          fifo_full       => open,
--              
--          -- PS/2 lines
--          ps2_kclk        => usb_ps2_kclk,
--          ps2_kdat        => usb_ps2_kdat
--        );
--    else generate
      ps2_kdat <= dbgio(5);
      ps2_mdat <= dbgio(4);
      ps2_kclk <= dbgio(7);
      ps2_mclk <= dbgio(6);
--      vid_reset_n <= '1';
--    end generate GEN_PS2;
--
  end block BLK_PS2;
  
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
        DE_GEN      => S6M_DE_GEN,
        VS_POL      => S6M_VS_POL,
        HS_POL      => S6M_HS_POL,
        DE_DLY      => S6M_DE_DLY,
        DE_TOP      => S6M_DE_TOP,
        DE_CNT      => S6M_DE_CNT,
        DE_LIN      => S6M_DE_LIN
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
        led_hdmi	<= count(count'left);
        led_avo	<= count(count'left-1);
        led_dvo	<= count(count'left-2);
        led_avi	<= count(count'left-3);
        led_dvi	<= count(count'left-4);
        led_nios	<= count(count'left-5);
    end process;
  end block BLK_FLASHER;

  -- constant drivers
	vai_pdn			  <= '0'; --reset_pio(2);
  vdo_rstn      <= reset_n;
  --clk24_en      <= '1';
  
  dvi_connect   <= '1';
  dvi_oen       <= '0';

  dbgio <= (others => 'Z');
  
end;
