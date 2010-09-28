library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.lpc_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;
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
		vo_po1			: in std_logic;
		vo_rstn			: out std_logic;

		-- I2C on the DVI output connector
		dvo_scl			: inout std_logic;
		dvo_sda			: inout std_logic;

		mix_ckp_a		: in std_logic;
		mix_ckn_a		: in std_logic;
		mix_reset		: in std_logic;
		mix_framen	: in std_logic;
		mix_a				: inout std_logic_vector(3 downto 0);
		mix_a_dir   : out std_logic;
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

		--sp2v5				: inout std_logic_vector(2 downto 1);

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

  alias clk_24M576_a    : std_logic is clk_25_a;
  alias clk_24M576_b    : std_logic is clk_25_b;
  signal init       		: std_logic := '1';

  signal pll_locked     : std_logic := '0';
    
  signal clkrst_i       : from_CLKRST_t;
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
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

  -- PS/2 fifo signals
  signal ps2_fifo_data    : std_logic_vector(7 downto 0) := (others => '0');
  signal ps2_fifo_wrreq   : std_logic := '0';
  signal ps2_fifo_full    : std_logic := '0';
  signal ps2_fifo_usedw   : std_logic_vector(7 downto 0) := (others => '0');

begin

	PROC_RESET : process(clk_24M576_a, pll_locked)
		variable reset_cnt : integer range 0 to 42424:= 0;
	begin
		if pll_locked = '0' then
			init <= '1';
			reset_cnt := 0;
		elsif rising_edge(clk_24M576_a) then
			if reset_cnt /= reset_cnt'high then
				init <= '1';
				reset_cnt := reset_cnt + 1;
			else
				init <= '0';
			end if;
		end if;
	end process PROC_RESET;

  clkrst_i.arst <= init; -- or mix_reset;
	clkrst_i.arst_n <= not clkrst_i.arst;

  BLK_CLOCKING : block

    component pll is
      generic
      (
        -- INCLK
        INCLK0_INPUT_FREQUENCY  : natural;

        -- CLK0
        CLK0_DIVIDE_BY      : natural := 1;
        CLK0_DUTY_CYCLE     : natural := 50;
        CLK0_MULTIPLY_BY    : natural := 1;
        CLK0_PHASE_SHIFT    : string := "0";

        -- CLK1
        CLK1_DIVIDE_BY      : natural := 1;
        CLK1_DUTY_CYCLE     : natural := 50;
        CLK1_MULTIPLY_BY    : natural := 1;
        CLK1_PHASE_SHIFT    : string := "0"
      );
      port
      (
        inclk0							: in std_logic := '0';
        c0		    					: out std_logic;
        c1		    					: out std_logic; 
        c2		    					: out std_logic;
        locked		    			: out std_logic 
      );
    end component pll;

  begin

    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll
        generic map
        (
          -- INCLK0
          INCLK0_INPUT_FREQUENCY  => 40960,

          -- CLK0
          CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
          CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
      
          -- CLK1
          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        )
        port map
        (
          inclk0  => clk_24M576_a,
          c0      => vo_idck,   -- 108MHz
          c1      => clkrst_i.clk(1),  -- 108MHz
          c2      => clkrst_i.clk(0),  -- 40MHz
          locked  => pll_locked
        );
    
        vo_idck_n <= '0';
        
    end generate GEN_PLL;
	
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clk_24M576_a;
      clkrst_i.clk(1) <= clk_24M576_b;
        
    end generate GEN_NO_PLL;
	
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

  BLK_PS2 : block
  begin
  
    ps2_host_inst : entity work.ps2_host
      generic map
      (
        CLK_HZ          => 24576000
      )
      port map
      (
        clk             => clk_24M576_a,
        reset           => clkrst_i.arst,

        -- FIFO interface
        fifo_data       => ps2_fifo_data,
        fifo_wrreq      => ps2_fifo_wrreq,
        fifo_full       => ps2_fifo_full,
        fifo_usedw      => ps2_fifo_usedw,
            
        -- PS/2 lines
        ps2_kclk        => inputs_i.ps2_kclk,
        ps2_kdat        => inputs_i.ps2_kdat
      );

    -- inputs
    inputs_i.ps2_mclk <= '1';
    inputs_i.ps2_mdat <= '1';

  end block BLK_PS2;

  BLK_MIXER_BUS : block

    signal lpc_clk          : std_logic := '0';
    signal lpc_reset_n      : std_logic := '1';
    signal lpc_frame        : std_logic := '0';
    signal lpc_ad_i         : std_logic_vector(3 downto 0) := (others => '0');
    signal lpc_ad_o         : std_logic_vector(3 downto 0) := (others => '0');
    signal lpc_ad_oe        : std_logic := '0';

    signal wb_adr           : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_dat_o         : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_dat_i         : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_sel           : std_logic_vector(3 downto 0) := (others => '0');
    signal wb_tga           : std_logic_vector(1 downto 0) := (others => '0');
    signal wb_we            : std_logic := '0';
    signal wb_stb           : std_logic := '0';
    signal wb_cyc           : std_logic := '0';
    signal wb_ack           : std_logic := '0';
    
    signal ps2_jamma_stb    : std_logic := '0';
    signal ps2_jamma_ack    : std_logic := '0';
    signal ps2_jamma_dat_o  : std_logic_vector(7 downto 0) := (others => '0');
    
    -- custom i/o signals
    signal custom_io_stb    : std_logic := '0';
    signal custom_io_ack    : std_logic := '0';
    signal custom_io_dat_o  : std_logic_vector(7 downto 0) := (others => '0');

    type lpc_reg_a is array (natural range <>) of std_logic_vector(7 downto 0);
    signal lpc_reg      : lpc_reg_a(0 to 3) := (others => (others => '1'));
    
  begin

    lpc_clk <= clk_24M576_a;
    lpc_reset_n <= clkrst_i.arst_n;
    lpc_frame <= not mix_framen;
    
    lpc_periph_inst : wb_lpc_periph
      port map
      (
        clk_i       => lpc_clk,
        nrst_i      => lpc_reset_n,
        wbm_adr_o   => wb_adr,
        wbm_dat_o   => wb_dat_o,
        wbm_dat_i   => wb_dat_i,
        wbm_sel_o   => wb_sel,
        wbm_tga_o   => wb_tga,
        wbm_we_o    => wb_we,
        wbm_stb_o   => wb_stb,
        wbm_cyc_o   => wb_cyc,
        wbm_ack_i   => wb_ack,
        wbm_err_i   => '0',
        dma_chan_o  => open,
        dma_tc_o    => open,
        
        lframe_i    => lpc_frame,
        lad_i       => lpc_ad_i,
        lad_o       => lpc_ad_o,
        lad_oe      => lpc_ad_oe
      );

    -- address decodes
    --
    -- $C0-$CF  - custom i/o
    -- $E0-$EF  - PS/2 & JAMMA
    --  $E0-$E3 -                       (W) JAMMA inputs
    --  $E8     - (R) PS/2 FIFO_WRFULL
    --  $EC     - (R) PS/2 FIFO_USEDW   (W) PS/2 FIFO
    --
    custom_io_stb <= '1' when wb_adr(7 downto 4) = "1100" else '0';
    ps2_jamma_stb <= '1' when wb_adr(7 downto 4) = "1110" else '0';
    --berr <= not (custom_io_stb or ps2_jamma_stb);

    -- read mux
    wb_dat_i(31 downto 8) <= (others => '0');
    wb_dat_i(7 downto 0) <= custom_io_dat_o when custom_io_stb = '1' else
                            ps2_jamma_dat_o when ps2_jamma_stb = '1' else
                            (others => '0');
               
    -- ack mux
    wb_ack <= custom_io_ack when custom_io_stb = '1' else
              ps2_jamma_ack when ps2_jamma_stb = '1' else
              (wb_cyc and wb_stb);  -- berr
              
    process (lpc_clk, lpc_reset_n)
      variable adr : integer range 0 to 3;
      variable wb_cyc_r : std_logic := '0';
    begin
      if lpc_reset_n = '0' then
        lpc_reg <= (others => (others => '1'));
        wb_cyc_r := '0';
      elsif rising_edge(lpc_clk) then
        ps2_fifo_wrreq <= '0';  -- default
        adr := to_integer(unsigned(wb_adr(1 downto 0)));
        if wb_cyc = '1' and ps2_jamma_stb = '1' and wb_cyc_r = '0' then
          if wb_we = '0' then
            -- reads
            case wb_adr(3 downto 2) is
              when "11" =>
                ps2_jamma_dat_o <= ps2_fifo_usedw;
              when "10" =>
                ps2_jamma_dat_o <= "0000000" & ps2_fifo_full;
              when others =>
                ps2_jamma_dat_o <= (others => '0');
            end case;
          else
            -- writes
            case wb_adr(3 downto 2) is
              when "11" =>
                ps2_fifo_data <= wb_dat_o(ps2_fifo_data'range);
                ps2_fifo_wrreq <= '1';
              when others =>
                lpc_reg(adr) <= wb_dat_o(lpc_reg(adr)'range);
            end case;
          end if;
        end if;
        wb_cyc_r := wb_cyc and ps2_jamma_stb;
        -- drive ack
        ps2_jamma_ack <= wb_cyc and ps2_jamma_stb;
      end if;
    end process;
    
    -- lpc drivers
    lpc_ad_i <= mix_a;
    mix_a <= lpc_ad_o when lpc_ad_oe = '1' else (others => 'Z');
    -- drives ST2G3236 level converters
    -- - '0' is output (from mixer), '1' is input (from carrier)
    mix_a_dir <= not lpc_ad_oe;
    
    GEN_JAMMA : for i in 1 to 2 generate
      inputs_i.jamma_n.coin(i) <= lpc_reg((i-1)*2)(0);
      inputs_i.jamma_n.p(i).start <= lpc_reg((i-1)*2)(1);
      inputs_i.jamma_n.p(i).up <= lpc_reg((i-1)*2)(2);
      inputs_i.jamma_n.p(i).down <= lpc_reg((i-1)*2)(3);
      inputs_i.jamma_n.p(i).left <= lpc_reg((i-1)*2)(4);
      inputs_i.jamma_n.p(i).right <= lpc_reg((i-1)*2)(5);
      inputs_i.jamma_n.p(i).button <= lpc_reg((i-1)*2+1)(4 downto 0);
    end generate GEN_JAMMA;

    inputs_i.jamma_n.coin_cnt <= (others => '1');
    inputs_i.jamma_n.service <= '1';
    inputs_i.jamma_n.tilt <= '1';
    inputs_i.jamma_n.test <= '1';
    
    inputs_i.analogue <= (others => (others => '0'));
    
    custom_io_inst : entity work.custom_io
      port map
      (
        -- wishbone (LPC) interface
        wb_clk          => lpc_clk,
        wb_rst          => clkrst_i.arst,
        wb_cyc          => wb_cyc,
        wb_stb          => custom_io_stb,
        wb_adr          => wb_adr(7 downto 0),
        wb_dat_i        => wb_dat_o(7 downto 0),
        wb_dat_o        => custom_io_dat_o,
        wb_we           => wb_we,
        wb_ack          => custom_io_ack,
        
        project_i       => project_i,
        project_o       => project_o,
        platform_i      => platform_i,
        platform_o      => platform_o,
        target_i        => target_i,
        target_o        => target_o
      );

  end block BLK_MIXER_BUS;

  BLK_VIDEO : block
  
    -- VO I2C (INIT) signals
    signal vo_scl_i     : std_logic := '0';
    signal vo_scl_o     : std_logic := '0';
    signal vo_scl_oe_n  : std_logic := '0';
    signal vo_sda_i     : std_logic := '0';
    signal vo_sda_o     : std_logic := '0';
    signal vo_sda_oe_n  : std_logic := '0';

    --signal video_i  : from_VIDEO_t;
    signal reg_i    : VIDEO_REG_t;
    signal rgb_i    : RGB_t;
    --signal video_o  : to_VIDEO_t;
    
  begin
  
    dvo_sm : entity work.dvo_init_i2c_sm_controller
      generic map
      (
        clock_speed => 24576000,
        dsel        => '0',         -- single-ended output clock

        -- DE generation
        DE_GEN      => S5A_DE_GEN,
        VS_POL      => S5A_VS_POL,
        HS_POL      => S5A_HS_POL,
        DE_DLY      => S5A_DE_DLY,
        DE_TOP      => S5A_DE_TOP,
        DE_CNT      => S5A_DE_CNT,
        DE_LIN      => S5A_DE_LIN
      )
      port map
      (
        clk					=> clk_24M576_a,
        clk_ena     => '1',
        reset				=> clkrst_i.arst,

        -- I2C physical interface
        scl_i  	    => vo_scl_i,
        scl_o  	    => vo_scl_o,
        scl_oe_n    => vo_scl_oe_n,
        sda_i  	    => vo_sda_i,
        sda_o  	    => vo_sda_o,
        sda_oe_n    => vo_sda_oe_n
      );

    -- VO I2C (init) drivers
    vo_scl_i <= vo_scl;
    vo_scl <= vo_scl_o when vo_scl_oe_n = '0' else 'Z';
    vo_sda_i <= vo_sda;
    vo_sda <= vo_sda_o when vo_sda_oe_n = '0' else 'Z';

    video_i.clk <= clkrst_i.clk(1);
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.arst;
    
    --vo_idck <= clk_i(1);
    vo_red <= video_o.rgb.r(9 downto 2);
    vo_green <= video_o.rgb.g(9 downto 2);
    vo_blue <= video_o.rgb.b(9 downto 2);
    vo_hsync <= video_o.hsync;
    vo_vsync <= video_o.vsync;
    vo_de <= not (video_o.hblank or video_o.vblank);
    vo_rstn <= clkrst_i.arst_n;

    GEN_TEST_VIDEO : if false generate
      --reg_i.h_scale <= "001";
      --reg_i.v_scale <= "001";
      
      --rgb_i.r <= (others => '1');
      --rgb_i.g <= (others => '0');
      --rgb_i.b <= (others => '0');

      --video_inst : entity work.pace_video_controller
      --  generic map
      --  (
      --    CONFIG		  => PACE_VIDEO_VGA_1280x1024_60Hz,
      --    DELAY       => 3,
      --    H_SIZE      => 240,
      --    V_SIZE      => 256,
      --    H_SCALE     => 1,
      --    V_SCALE     => 1,
      --    BORDER_RGB  => RGB_BLUE
      --  )
      --  port map
      --  (
      --    video_i       => video_i,
      --    reg_i			    => reg_i,
      --    rgb_i         => rgb_i,
      --    video_ctl_o   => open,
      --    video_o       => video_o
      --  );
    end generate GEN_TEST_VIDEO;
    
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
	  	clk_i							=> clkrst_i.clk,
      reset_i          	=> clkrst_i.rst,

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

  -- emulate some SRAM
  GEN_SRAM : if S5A_EMULATE_SRAM generate
    signal wren : std_logic := '0';
  begin
    wren <= sram_o.cs and sram_o.we;
    sram_inst : entity work.spram
      generic map
      (
        numwords_a		=> 2**S5A_EMULATED_SRAM_WIDTH_AD,
        widthad_a			=> S5A_EMULATED_SRAM_WIDTH_AD,
        width_a				=> S5A_EMULATED_SRAM_WIDTH
      )
      port map
      (
        clock		      => clkrst_i.clk(0),
        address		    => sram_o.a(S5A_EMULATED_SRAM_WIDTH_AD-1 downto 0),
        data		      => sram_o.d(S5A_EMULATED_SRAM_WIDTH-1 downto 0),
        wren		      => wren,
        q		          => sram_i.d(S5A_EMULATED_SRAM_WIDTH-1 downto 0)
      );
    sram_i.d(sram_i.d'left downto S5A_EMULATED_SRAM_WIDTH) <= (others => '0');
  end generate GEN_SRAM;
  
  -- emulate some FLASH
  GEN_FLASH : if S5A_EMULATE_FLASH generate
    flash_inst : entity work.sprom
      generic map
      (
        init_file     => S5A_EMULATED_FLASH_INIT_FILE,
        numwords_a		=> 2**S5A_EMULATED_FLASH_WIDTH_AD,
        widthad_a			=> S5A_EMULATED_FLASH_WIDTH_AD,
        width_a				=> S5A_EMULATED_FLASH_WIDTH
      )
      port map
      (
        clock		      => clkrst_i.clk(0),
        address		    => flash_o.a(S5A_EMULATED_FLASH_WIDTH_AD-1 downto 0),
        q		          => flash_i.d(S5A_EMULATED_FLASH_WIDTH-1 downto 0)
      );
    flash_i.d(flash_i.d'left downto S5A_EMULATED_FLASH_WIDTH) <= (others => '0');
  end generate GEN_FLASH;
  
  -- blink a led
  process (clk_24M576_a, clkrst_i.arst)
    variable count : unsigned(22 downto 0) := (others => '0');
  begin
    if clkrst_i.arst = '1' then
      count := (others => '0');
    elsif rising_edge(clk_24M576_a) then
      count := count + 1;
    end if;
    ledout <= pll_locked and count(count'left);
  end process;
  
  vi_pdn <= '1';
  dvi_hotplug <= '1';
  mix_spa <= 'Z';
  mix_spb <= 'Z';
  mix_spc <= 'Z';
  
end architecture SYN;
