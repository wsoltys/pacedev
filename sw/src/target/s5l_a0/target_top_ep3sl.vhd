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

entity ep3sl_top is
	port
	(
    -- new pins - to be sorted
    hdmi_ctl      : in std_logic_vector(3 downto 0);
    hdmi_vsync    : in std_logic;
    hdmi_hsync    : in std_logic;
    hdmi_scdt     : in std_logic;
    hdmi_de       : in std_logic;
    hdmi_red      : in std_logic_vector(7 downto 0);
    hdmi_green    : in std_logic_vector(7 downto 0);
    hdmi_blue     : in std_logic_vector(7 downto 0);
    hdmi_odck     : in std_logic;
    
    -- DDR3
		ddr64_odt     : out std_logic_vector(0 downto 0);
--		ddr64_clk     : inout std_logic_vector(0 downto 0);
--		ddr64_clk_n   : inout std_logic_vector(0 downto 0);
		ddr64_cs_n    : out std_logic_vector(0 downto 0);
		ddr64_cke     : out std_logic_vector(0 downto 0);
		ddr64_a       : out std_logic_vector(12 downto 0);
		ddr64_ba      : out std_logic_vector(2 downto 0);
		ddr64_ras_n   : out std_logic;
		ddr64_cas_n   : out std_logic;
		ddr64_we_n    : out std_logic;
		ddr64_dq      : inout std_logic_vector(63 downto 0);
--		ddr64_dqs     : inout std_logic_vector(7 downto 0);
--		ddr64_dqsn    : inout std_logic_vector(7 downto 0);
		ddr64_dm      : out std_logic_vector(7 downto 0);
		ddr64_reset_n : out std_logic;

    -- DVI output, 1V5 I/O 1 pix/clk, 24-bit mode
		vdo_red			  : out std_logic_vector(7 downto 0);
		vdo_green		  : out std_logic_vector(7 downto 0);
		vdo_blue		  : out std_logic_vector(7 downto 0);
		vdo_idck		  : out std_logic;
		vdo_hsync		  : out std_logic;
		vdo_vsync		  : out std_logic;
		vdo_de			  : out std_logic;

    -- DVI input, 1 pix/clk, 24-bit mode
		vdi_odck			: in std_logic;
		vdi_red				: in std_logic_vector(7 downto 0);
		vdi_green			: in std_logic_vector(7 downto 0);
		vdi_blue			: in std_logic_vector(7 downto 0);
		vdi_de				: in std_logic;
		vdi_vsync			: in std_logic;
		vdi_hsync			: in std_logic;
		vdi_scdt			: in std_logic;
		--vdi_pdn				: out std_logic;

    -- VGA input, 1 pix/clk, 30-bit mode
		vai_dataclk		: in std_logic;
		vai_extclk		: out std_logic;
		vai_red				: in std_logic_vector(9 downto 0);
		vai_green			: in std_logic_vector(9 downto 0);
		vai_blue			: in std_logic_vector(9 downto 0);
		vai_vsout			: in std_logic;
		vai_hsout			: in std_logic;
		vai_vsync			: in std_logic;
		vai_hsync			: in std_logic;
		vai_sogout		: in std_logic;
		vai_fidout		: in std_logic;
		--vai_pwdn			: out std_logic;
		vai_resetb_n	: out std_logic;
		vai_coast			: out std_logic;
		--vai_scl				: inout std_logic;
		--vai_sda				: inout std_logic;

		-- LVDS video from the Cyclone
		vli_red         : in std_logic_vector(7 downto 0); -- 7..0
		vli_green       : in std_logic_vector(7 downto 0); -- 15..8
		vli_blue        : in std_logic_vector(7 downto 0); -- 23..16
		vli_hsync       : in std_logic;  -- 24
		vli_vsync       : in std_logic;  -- 25
		vli_de          : in std_logic;  -- 26
		vli_locked      : in std_logic;  -- 27
		vli_clk			  	: in std_logic;

    -- I2C to the Cyclone
		--vid_scl			  : inout std_logic;
		--vid_sda			  : inout std_logic;

    -- SDVO to LVDS input, dual 4 channel x 7 
		--vsi_clk			  : in std_logic_vector(1 downto 0);
		--vsi_data		  : in std_logic_vector(7 downto 0);
		--vsi_enavdd	  : in std_logic;
		--vsi_enabkl	  : in std_logic;
		
		vlo_clk			  : out std_logic;
		vlo_data		  : out std_logic_vector(2 downto 0);

    -- VGA output, 1 pix/clk, 30-bit mode
		vao_clk	  	  : out std_logic;
		vao_red			  : out std_logic_vector(9 downto 0);
		vao_green		  : out std_logic_vector(9 downto 0);
		vao_blue		  : out std_logic_vector(9 downto 0);
		vao_hsync     : out std_logic;
		vao_vsync     : out std_logic;
		vao_blank_n   : out std_logic;
		vao_sync_n	  : out std_logic;
		vao_sync_t	  : out std_logic;
		vao_m1			  : out std_logic;
		vao_m2			  : out std_logic;

    -- Connection to video FPGA
		vid_address			  : in std_logic_vector(10 downto 0);
		vid_data				  : inout std_logic_vector(15 downto 0);
		vid_write_n			  : in std_logic;
		vid_read_n			  : in std_logic;
		vid_waitrequest_n	: out std_logic;
		vid_irq_n				  : out std_logic;
		vid_clk					  : in std_logic;
    vid_reset_core    : in std_logic;
    vid_reset         : in std_logic;
    
		vid_spare		  : in std_logic_vector(29 downto 28);

		--clk24_b			  : in std_logic;
		--veb_ck_b		  : in std_logic;

		clk24_c			  : in std_logic;
		veb_ck_c		  : in std_logic;

		clk24_d			  : in std_logic;
		veb_ck_d		  : in std_logic

--		ddr_clk			: in std_logic;
	);

end entity ep3sl_top;

architecture SYN of ep3sl_top is

  constant ONBOARD_CLOCK_SPEED  : integer := 24000000;

  signal init         : std_logic := '1';
  alias clk_24M       : std_logic is clk24_d;
  
  signal clk_108M     : std_logic := '0';
  signal vip_clk      : std_logic := '0';
  signal vdo_clk_x2   : std_logic := '0';
  
  signal pll_locked     : std_logic := '0';
    
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

  clkrst_i.arst <= init or not vid_reset;
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

    clkrst_i.clk_ref <= clk_24M;
    
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll
        generic map
        (
          -- INCLK0
          INCLK0_INPUT_FREQUENCY  => 41666,

          -- CLK0
          CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
          CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
      
          -- CLK1
          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        )
        port map
        (
          inclk0  => clk_24M,
          c0      => clkrst_i.clk(0),
          c1      => clkrst_i.clk(1),
          c2      => vdo_clk_x2,
          locked  => pll_locked
        );
    
    end generate GEN_PLL;
	
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clk_24M;
      clkrst_i.clk(1) <= clk_24M;
        
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
      kdat_r := kdat_r(kdat_r'left-1 downto 0) & vid_address(3);
      mdat_r := mdat_r(mdat_r'left-1 downto 0) & vid_address(2);
      kclk_r := kclk_r(kclk_r'left-1 downto 0) & vid_address(1);
      mclk_r := mclk_r(mclk_r'left-1 downto 0) & vid_address(0);
    end if;
    inputs_i.ps2_kdat <= kdat_r(kdat_r'left);
    inputs_i.ps2_mdat <= mdat_r(mdat_r'left);
    inputs_i.ps2_kclk <= kclk_r(kclk_r'left);
    inputs_i.ps2_mclk <= mclk_r(mclk_r'left);
  end process;
  
  BLK_JAMMA : block
  
    signal spi_fast_clk   : std_logic;
    signal jamma_i        : std_logic_vector(31 downto 0);
  
  begin
  
    spi_pll_inst : entity work.spi_pll
      port map
      (
        inclk0        =>  clk_24M,
        c0            =>  spi_fast_clk
      );

    uni_spi_rx_inst : entity work.uni_spi_rx
      port map
      (
        clk           => spi_fast_clk,
        rst           => clkrst_i.arst,
        
        spi_en        => vid_address(4),
        spi_clk       => vid_address(5),
        spi_d         => vid_address(6),
        
        data          => jamma_i
      );
      
    -- really should unmeta jamma_i...
    
    inputs_i.jamma_n.coin(1) <= jamma_i(9);
    inputs_i.jamma_n.p(1).start <= jamma_i(10);
    inputs_i.jamma_n.p(1).up <= jamma_i(0);
    inputs_i.jamma_n.p(1).down <= jamma_i(3);
    inputs_i.jamma_n.p(1).left <= jamma_i(1);
    inputs_i.jamma_n.p(1).right <= jamma_i(2);
    inputs_i.jamma_n.p(1).button(1) <= jamma_i(4);
    inputs_i.jamma_n.p(1).button(2) <= jamma_i(5);
    inputs_i.jamma_n.p(1).button(3) <= jamma_i(6);
    inputs_i.jamma_n.p(1).button(4) <= jamma_i(7);
    inputs_i.jamma_n.p(1).button(5) <= jamma_i(8);
    
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
    inputs_i.jamma_n.service <= jamma_i(11);
    inputs_i.jamma_n.tilt <= '1';
    inputs_i.jamma_n.test <= '1';
    
  end block BLK_JAMMA;
  
  BLK_AUDIO : block
  
    signal spi_en_s   : std_logic;
    signal spi_go     : std_logic;
    
  begin

    -- this is really crappy, but good enough for testing
    -- what we really should be doing is using a FIFO
    -- clocked in by the audio clock
    -- clocked out by the SPI clock
    -- so we might drop samples, but never glitch
    
    process (clk_24M, clkrst_i.arst)
      type state_t is ( IDLE, SENDING );
      variable state    : state_t;
      variable spi_en_r : std_logic;
    begin
      if clkrst_i.arst = '1' then
        spi_go <= '0';
        state := IDLE;
        spi_en_r := '0';
      elsif rising_edge(clk_24M) then
        spi_go <= '0';  -- default
        case state is
          when IDLE =>
            -- any time we're idle is good to go
            if spi_en_s = '0' then
              spi_go <= '1';
              state := SENDING;
            end if;
          when SENDING =>
            -- wait for falling-edge of spi_en
            if spi_en_r = '1' and spi_en_s = '0' then
              state := IDLE;
            end if;
          when others =>
            null;
        end case;
        spi_en_r := spi_en_s;
      end if;
    end process;
    
    uni_spi_tx_inst : entity work.uni_spi_tx
      port map
      (
        clk                 => clk_24M,
        rst                 => clkrst_i.arst,
        
        spi_en              => spi_en_s,
        spi_clk             => vid_data(9),
        spi_d               => vid_data(10),
        
        go                  => spi_go,
        data(31 downto 16)  => audio_o.ldata,
        data(15 downto 0)   => audio_o.rdata
      );
  
    vid_data(8) <= spi_en_s;
    
  end block BLK_AUDIO;
  
  inputs_i.analogue <= (others => (others => '0'));

  BLK_VIDEO : block
    type state_t is (IDLE, S1, S2, S3);
    signal state : state_t := IDLE;
  begin
  
    video_i.clk <= clkrst_i.clk(1);
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);

    -- DVI (digital) output
    GEN_VDO_IDCK : if not S5AR2_DOUBLE_VDO_IDCK generate
      vdo_idck <= video_o.clk;
    end generate GEN_VDO_IDCK;
    GEN_VDO_IDCKx2 : if S5AR2_DOUBLE_VDO_IDCK generate
      vdo_idck <= vdo_clk_x2;
    end generate GEN_VDO_IDCKx2;
    vdo_red <= video_o.rgb.r(9 downto 2);
    vdo_green <= video_o.rgb.g(9 downto 2);
    vdo_blue <= video_o.rgb.b(9 downto 2);
    vdo_hsync <= video_o.hsync;
    vdo_vsync <= video_o.vsync;
    vdo_de <= not (video_o.hblank or video_o.vblank);

    -- VGA (analogue) output
		vao_clk <= video_o.clk;
		vao_red <= video_o.rgb.r;
		vao_green <= video_o.rgb.g;
		vao_blue <= video_o.rgb.b;
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
  GEN_FLASH : if S5AR2_EMULATE_FLASH generate
    flash_inst : entity work.sprom
      generic map
      (
        init_file     => S5AR2_EMULATED_FLASH_INIT_FILE,
        widthad_a			=> S5AR2_EMULATED_FLASH_WIDTH_AD,
        width_a				=> S5AR2_EMULATED_FLASH_WIDTH
      )
      port map
      (
        clock		      => clkrst_i.clk(0),
        address		    => flash_o.a(S5AR2_EMULATED_FLASH_WIDTH_AD-1 downto 0),
        q		          => flash_i.d(S5AR2_EMULATED_FLASH_WIDTH-1 downto 0)
      );
    flash_i.d(flash_i.d'left downto S5AR2_EMULATED_FLASH_WIDTH) <= (others => '0');
  end generate GEN_FLASH;
  
  -- emulate some SRAM
  GEN_SRAM : if S5AR2_EMULATE_SRAM generate
    signal wren : std_logic := '0';
  begin
    wren <= sram_o.cs and sram_o.we;
    sram_inst : entity work.spram
      generic map
      (
        numwords_a		=> 2**S5AR2_EMULATED_SRAM_WIDTH_AD,
        widthad_a			=> S5AR2_EMULATED_SRAM_WIDTH_AD,
        width_a				=> S5AR2_EMULATED_SRAM_WIDTH
      )
      port map
      (
        clock		      => clkrst_i.clk(0),
        address		    => sram_o.a(S5AR2_EMULATED_SRAM_WIDTH_AD-1 downto 0),
        data		      => sram_o.d(S5AR2_EMULATED_SRAM_WIDTH-1 downto 0),
        wren		      => wren,
        q		          => sram_i.d(S5AR2_EMULATED_SRAM_WIDTH-1 downto 0)
      );
    sram_i.d(sram_i.d'left downto S5AR2_EMULATED_SRAM_WIDTH) <= (others => '0');
  end generate GEN_SRAM;

  GEN_FLOPPY_IF : if S5AR2_HAS_FLOPPY_IF generate
  begin
    -- floppy disk signals
    vid_data(3 downto 0) <= target_o.ds_n;
    vid_data(4) <= target_o.motor_on;
    vid_data(5) <= target_o.step_n;
    vid_data(6) <= target_o.direction_select_n;
    vid_data(7) <= target_o.write_gate_n;
    vid_data(8) <= target_o.write_data_n;
    process (clkrst_i)
      variable rd_n_r     : std_logic_vector(3 downto 0);
      variable wp_n_r     : std_logic_vector(3 downto 0);
      variable ip_n_r     : std_logic_vector(3 downto 0);
      variable tr00_n_r   : std_logic_vector(3 downto 0);
      variable rclk_r     : std_logic_vector(3 downto 0);
    begin
      if clkrst_i.rst(0) = '1' then
        rd_n_r := (others => '1');
        wp_n_r := (others => '1');
        ip_n_r := (others => '1');
        tr00_n_r := (others => '1');
        rclk_r := (others => '1');
      elsif rising_edge(clkrst_i.clk(0)) then
        rd_n_r := rd_n_r(rd_n_r'left-1 downto 0) & vid_data(9);
        wp_n_r := wp_n_r(wp_n_r'left-1 downto 0) & vid_data(10);
        ip_n_r := ip_n_r(ip_n_r'left-1 downto 0) & vid_data(11);
        tr00_n_r := tr00_n_r(tr00_n_r'left-1 downto 0) & vid_data(12);
        rclk_r := rclk_r(rclk_r'left-1 downto 0) & vid_data(13);
      end if;
      target_i.read_data_n <= rd_n_r(rd_n_r'left);
      target_i.write_protect_n <= wp_n_r(wp_n_r'left);
      target_i.index_pulse_n <= ip_n_r(ip_n_r'left);
      target_i.track_zero_n <= tr00_n_r(tr00_n_r'left);
      target_i.rclk <= rclk_r(rclk_r'left);
    end process;
    -- b/c it's defined as inout
    vid_data(vid_data'left downto 9) <= (others => 'Z');
    
  else generate
    vid_data <= (others => 'Z');
  end generate GEN_FLOPPY_IF;
  
  BLK_CHASER : block
  begin
    -- flash the led so we know it's alive
    process (clk_24M, clkrst_i.arst)
      variable count : std_logic_vector(21 downto 0);
    begin
      if clkrst_i.arst = '1' then
        count := (others => '0');
      elsif rising_edge(clk_24M) then
        count := std_logic_vector(unsigned(count) + 1);
      end if;
      --vid_spare(8) <= count(count'left);
    end process;
  end block BLK_CHASER;

  --vid_data(7 downto 0) <= leds_o(7 downto 0);
  
  --vid_spare(31 downto 10) <= (others => 'Z');
  -- route the leds to the cyclone
  --vid_spare(9) <= '1';  -- don't care
  --vid_spare(7 downto 0) <= not leds_o(7 downto 0);
	
end;
