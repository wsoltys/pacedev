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

entity target_top is
	port
	(
		v18_pgood		: in std_logic;
	
		lvds_clk		: in std_logic;
		lvds_a			: in std_logic_vector(3 downto 0);
		lvds_detect	: in std_logic;
		lvds_mode		: in std_logic;

    -- 1 pix/clk, 24-bit mode
		vi_odck			: in std_logic;
		vi_red			: in std_logic_vector(7 downto 0);
		vi_green		: in std_logic_vector(7 downto 0);
		vi_blue			: in std_logic_vector(7 downto 0);
		vi_de				: in std_logic;
		vi_vsync		: in std_logic;
		vi_hsync		: in std_logic;
		vi_scdt			: in std_logic;
		vi_pdn			: out std_logic;

		-- I2C on the DVI input connector
		dvi_scl			: inout std_logic;
		dvi_sda			: inout std_logic;

		-- HOTPLUG on the DVI input connector
		dvi_hotplug	: out std_logic := '1';

    -- single-edge mode 24-bits/pixel
    -- ISEL=high (I2C enabled)
    -- CTL(3:1) is hard-wired I2C address
		vo_idck	  	: out std_logic;
		vo_idck_n   : out std_logic;
		vo_red			: out std_logic_vector(7 downto 0);
		vo_green		: out std_logic_vector(7 downto 0);
		vo_blue			: out std_logic_vector(7 downto 0);
		vo_de	    	: out std_logic;
		vo_hsync		: out std_logic;
		vo_vsync		: out std_logic;
		-- 3.3V only below
		vo_scl			: inout std_logic;
		vo_sda			: inout std_logic;
		vo_po1			: out std_logic;
		vo_rstn			: out std_logic;

		-- I2C on the DVI output connector
		dvo_scl			: inout std_logic;
		dvo_sda			: inout std_logic;

		mix_ckp_a		: in std_logic;
		mix_ckn_a		: in std_logic;
		mix_reset		: in std_logic;
		mix_framen	: in std_logic;
		mix_a				: inout std_logic_vector(3 downto 0);
		mix_spa			: inout std_logic;
		mix_spb			: inout std_logic;
		mix_spc			: inout std_logic;
		mix_irqn		: in std_logic;

		mix_ckp_b		: in std_logic;
		mix_ckn_b		: in std_logic;

		pt_ts_tx		: out std_logic;
		pt_ts_rx		: in std_logic;
		pt_pc_tx		: out std_logic;
		pt_pc_rx		: in std_logic;

		mx_ts_tx		: in std_logic;
		mx_ts_rx		: out std_logic;
		mx_pc_tx		: in std_logic;
		mx_pc_rx		: out std_logic;

		clk_25_a		: in std_logic;
		clk_25_b		: in std_logic;
		clk_25_c		: in std_logic;
		
		clk_25_sp		: in std_logic_vector(2 downto 0);	-- Other clocks routed to spare clock inputs
		
--		clk_test		: in std_logic;					-- Clock on test points

		sp2v5				: inout std_logic_vector(2 downto 1);

		fa_odt : out std_logic_vector(0 downto 0);
		fa_clk : inout std_logic_vector(1 downto 0);
		fa_clk_n : inout std_logic_vector(1 downto 0);
		fa_cs_n : out std_logic_vector(0 downto 0);
		fa_cke : out std_logic_vector(0 downto 0);
		fa_a : out std_logic_vector(14 downto 0);
		fa_ba : out std_logic_vector(2 downto 0);
		fa_ras_n : out std_logic;
		fa_cas_n : out std_logic;
		fa_we_n : out std_logic;
		fa_dq : inout std_logic_vector(63 downto 0);
		fa_dqs : inout std_logic_vector(7 downto 0);
		fa_dm : out std_logic_vector(7 downto 0);

		fb_odt : out std_logic_vector(0 downto 0);
		fb_clk : inout std_logic_vector(0 downto 0);
		fb_clk_n : inout std_logic_vector(0 downto 0);
		fb_cs_n : out std_logic_vector(0 downto 0);
		fb_cke : out std_logic_vector(0 downto 0);
		fb_a : out std_logic_vector(14 downto 0);
		fb_ba : out std_logic_vector(2 downto 0);
		fb_ras_n : out std_logic;
		fb_cas_n : out std_logic;
		fb_we_n : out std_logic;
		fb_dq : inout std_logic_vector(31 downto 0);
		fb_dqs : inout std_logic_vector(3 downto 0);
		fb_dm : out std_logic_vector(3 downto 0);

		ledout		: out std_logic
	);

end entity target_top;

architecture SYN of target_top is

  component dvo_pll IS
    PORT
    (
      areset			: IN STD_LOGIC  := '0';
      inclk0			: IN STD_LOGIC  := '0';
      c0					: OUT STD_LOGIC ;
      c1					: OUT STD_LOGIC ;
      locked			: OUT STD_LOGIC 
    );
  end component dvo_pll;

	signal clk_i			  	: std_logic_vector(0 to 3);
  signal init       		: std_logic := '1';
  signal reset_i     		: std_logic := '1';
	signal reset_n				: std_logic := '0';

  signal buttons_i    	: from_BUTTONS_t;
  signal switches_i   	: from_SWITCHES_t;
  signal leds_o       	: to_LEDS_t;
  signal inputs_i     	: from_INPUTS_t;
  signal flash_i      	: from_FLASH_t;
  signal flash_o      	: to_FLASH_t;
	signal sram_i			  	: from_SRAM_t;
	signal sram_o			  	: to_SRAM_t;	
	signal sdram_i      	: from_SDRAM_t;
	signal sdram_o      	: to_SDRAM_t;
	signal video_i      	: from_VIDEO_t;
  signal video_o      	: to_VIDEO_t;
  signal audio_i      	: from_AUDIO_t;
  signal audio_o      	: to_AUDIO_t;
  signal ser_i        	: from_SERIAL_t;
  signal ser_o        	: to_SERIAL_t;
  signal gp_i         	: from_GP_t;
  signal gp_o         	: to_GP_t;
  
	signal vo_pll_clk			: std_logic;
	signal vo_clk					: std_logic;

begin

	PROC_RESET : process(clk_25_a)
		variable reset_cnt : integer := 999999;
	begin
		if rising_edge(clk_25_a) then
			if reset_cnt > 0 then
				init <= '1';
				reset_cnt := reset_cnt - 1;
			else
				init <= '0';
			end if;
		end if;
	end process PROC_RESET;

  reset_i <= init;
	reset_n <= not reset_i;

  BLK_CLOCKING : block

    component pll_3 is
      --generic
      --(
        -- INCLK
        --INCLK0_INPUT_FREQUENCY  : natural;

        -- CLK0
        --CLK0_DIVIDE_BY      : natural := 1;
        --CLK0_DUTY_CYCLE     : natural := 50;
        --CLK0_MULTIPLY_BY    : natural := 1;
        --CLK0_PHASE_SHIFT    : string := "0";

        -- CLK1
        --CLK1_DIVIDE_BY      : natural := 1;
        --CLK1_DUTY_CYCLE     : natural := 50;
        --CLK1_MULTIPLY_BY    : natural := 1;
        --CLK1_PHASE_SHIFT    : string := "0"
      --);
      port
      (
        inclk0							: in std_logic := '0';
        c0		    					: out std_logic;
        c1		    					: out std_logic; 
        c2		    					: out std_logic 
      );
    end component pll_3;

  begin

    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll_3
        --generic map
        --(
          -- INCLK0
          --INCLK0_INPUT_FREQUENCY  => 40000,

          -- CLK0
          --CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
          --CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
      
          -- CLK1
          --CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          --CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        --)
        port map
        (
          inclk0  => clk_25_c,
          c0      => vo_idck,
          c1      => clk_i(1),
          c2      => clk_i(0)
        );
    
        vo_idck_n <= '0';
        
    end generate GEN_PLL;
	
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clk_i(0) <= clk_25_a;
      clk_i(1) <= clk_25_b;
        
    end generate GEN_NO_PLL;
	
  end block BLK_CLOCKING;

  -- buttons
  buttons_i <= std_logic_vector(to_unsigned(0, buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(to_unsigned(0, switches_i'length));
  -- leds
  --ledout <= leds_o(0);

	-- inputs
	inputs_i.ps2_kclk <= '1';
	inputs_i.ps2_kdat <= '1';
  inputs_i.ps2_mclk <= '1';
  inputs_i.ps2_mdat <= '1';

  GEN_JAMMA : for i in 1 to 2 generate
    inputs_i.jamma_n.coin(i) <= '1';
    inputs_i.jamma_n.p(i).start <= '1';
    inputs_i.jamma_n.p(i).up <= '1';
    inputs_i.jamma_n.p(i).down <= '1';
    inputs_i.jamma_n.p(i).left <= '1';
    inputs_i.jamma_n.p(i).right <= '1';
    inputs_i.jamma_n.p(i).button <= (others => '1');
  end generate GEN_JAMMA;

	inputs_i.jamma_n.coin_cnt <= (others => '1');
	inputs_i.jamma_n.service <= '1';
	inputs_i.jamma_n.tilt <= '1';
	inputs_i.jamma_n.test <= '1';
  
  BLK_VIDEO : block
  
    --signal video_i  : from_VIDEO_t;
    signal reg_i    : VIDEO_REG_t;
    signal rgb_i    : RGB_t;
    --signal video_o  : to_VIDEO_t;
    
  begin
  
    dvo_sm : entity work.i2c_sm_controller
      generic map
      (
        clock_speed => 25000000,
        dsel        => '0'          -- single-ended output clock
      )
      port map
      (
        clk					=> clk_25_a,
        clk_ena     => '1',
        reset				=> reset_i,

        -- I2C physical interface
        i2c_scl			=> vo_scl,
        i2c_sda			=> vo_sda
      );

    video_i.clk <= clk_i(1);
    video_i.clk_ena <= '1';
    video_i.reset <= reset_i;
    
    --vo_idck <= clk_i(1);
    vo_red <= video_o.rgb.r(9 downto 2);
    vo_green <= video_o.rgb.g(9 downto 2);
    vo_blue <= video_o.rgb.b(9 downto 2);
    vo_hsync <= video_o.hsync;
    vo_vsync <= video_o.vsync;
    vo_de <= not (video_o.hblank or video_o.vblank);
    vo_rstn <= reset_n;

  end block BLK_VIDEO;

  BLK_SERIAL : block
  
    constant BUILD_SERIAL_LOOPBACK  : boolean := true;
  
  begin
    GEN_SERIAL_LOOPBACK : if BUILD_SERIAL_LOOPBACK generate
      -- Loop back serial pins for testing
      pt_ts_tx		<= pt_ts_rx;
      pt_pc_tx		<= pt_pc_rx;
      mx_ts_rx		<= mx_ts_tx;
      mx_pc_rx		<= mx_pc_tx;
    end generate GEN_SERIAL_LOOPBACK;
    
    GEN_SERIAL_PASSTHRU : if not BUILD_SERIAL_LOOPBACK generate
      -- pass thru serial pins for end-to-end testing
      pt_ts_tx		<= mx_ts_tx;
      pt_pc_tx		<= mx_pc_tx;
      mx_ts_rx    <= pt_ts_rx;
      mx_pc_rx    <= pt_pc_rx;
    end generate GEN_SERIAL_PASSTHRU;
  end block BLK_SERIAL;
  
  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clk_i							=> clk_i,
      reset_i          	=> reset_i,

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
      
      -- general purpose
      gp_i              => gp_i,
      gp_o              => gp_o,
      
      -- SB (IEC) port
      ext_sb_data_in	  => '0',
      ext_sb_data_oe	  => open,
      ext_sb_clk_in		  => '0',
      ext_sb_clk_oe		  => open,
      ext_sb_atn_in		  => '0',
      ext_sb_atn_oe		  => open,

      -- generic drive mechanism i/o ports
      mech_in					  => (others => '0'),
      mech_out				  => open,
      mech_io					  => open
    );

  -- blink a led
  process (clk_25_a, reset_i)
    variable count : unsigned(22 downto 0) := (others => '0');
  begin
    if reset_i = '1' then
      count := (others => '0');
    elsif rising_edge(clk_25_a) then
      count := count + 1;
    end if;
    ledout <= count(count'left);
  end process;
  
end architecture SYN;
