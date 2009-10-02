library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity target_top is
  port
  (
		clock50		                  :	 IN STD_LOGIC;
		clock_source		            :	 IN STD_LOGIC;
		reset_n		                  :	 IN STD_LOGIC;

		user_led		                :	 OUT STD_LOGIC_VECTOR(7 DOWNTO 1);

		BITEC_DVI_IO_IN_ODCK		    :	 IN STD_LOGIC;
		BITEC_DVI_IO_IN		          :	 IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		BITEC_DVI_IO_IN_DE		      :	 IN STD_LOGIC;
		BITEC_DVI_IO_IN_HSYNC		    :	 IN STD_LOGIC;
		BITEC_DVI_IO_IN_VSYNC		    :	 IN STD_LOGIC;

		BITEC_DVI2_IO_IN_ODCK		    :	 IN STD_LOGIC;
		BITEC_DVI_IO_IN1		        :	 IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		BITEC_DVI2_IO_IN_DE		      :	 IN STD_LOGIC;
		BITEC_DVI2_IO_IN_HSYNC		  :	 IN STD_LOGIC;
		BITEC_DVI2_IO_IN_VSYNC		  :	 IN STD_LOGIC;

		BITEC_DVI_IO_OUT_IDCKp		  :	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_IDCKn		  :	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT		        :	 OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		BITEC_DVI_IO_OUT_DE		      :	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_HSYNC		  :	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_VSYNC		  :	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_DVI_PD		  :	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_DVI_DKEN		:	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_DVI_ISEL		:	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_DVI_CTL1		:	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_DVI_CTL2		:	 OUT STD_LOGIC;
		BITEC_DVI_IO_OUT_DVI_CTL3		:	 OUT STD_LOGIC;

		scl		                      :	 INOUT STD_LOGIC;
		sda		                      :	 INOUT STD_LOGIC;

		memtop_addr		              :	 OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		memtop_ba		                :	 OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		memtop_cas_n		            :	 OUT STD_LOGIC;
		memtop_clk		              :	 INOUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		memtop_clk_n		            :	 INOUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		memtop_cke		              :	 OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		memtop_cs_n		              :	 OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		memtop_dm		                :	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		memtop_dq		                :	 INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		memtop_dqs		              :	 INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		memtop_odt		              :	 OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		memtop_ras_n		            :	 OUT STD_LOGIC;
		memtop_we_n		              :	 OUT STD_LOGIC;

		BITEC_QV_RESETB		          :	 OUT STD_LOGIC;
		BITEC_QV_TVP5154_SCL		    :	 INOUT STD_LOGIC;
		BITEC_QV_TVP5154_SDA		    :	 INOUT STD_LOGIC
	);
end target_top;

architecture SYN of target_top is

	signal clk_i			  : std_logic_vector(0 to 3);
  signal init       	: std_logic := '1';
  signal reset_i     	: std_logic := '1';

  signal buttons_i    : from_BUTTONS_t;
  signal switches_i   : from_SWITCHES_t;
  signal leds_o       : to_LEDS_t;
  signal inputs_i     : from_INPUTS_t;
  signal flash_i      : from_FLASH_t;
  signal flash_o      : to_FLASH_t;
	signal sram_i			  : from_SRAM_t;
	signal sram_o			  : to_SRAM_t;	
	signal sdram_i      : from_SDRAM_t;
	signal sdram_o      : to_SDRAM_t;
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;
  
begin

  -- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock50)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(clock50) then
			if count = X"FFF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

  reset_i <= init or not reset_n;
	
  BLK_PLL : block
    component pll IS
      generic
      (
        -- INCLK
        INCLK0_INPUT_FREQUENCY  : natural;

        -- CLK0
        CLK0_DIVIDE_BY          : natural := 1;
        CLK0_DUTY_CYCLE         : natural := 50;
        CLK0_MULTIPLY_BY        : natural := 1;
        CLK0_PHASE_SHIFT        : string := "0";

        -- CLK1
        CLK1_DIVIDE_BY          : natural := 1;
        CLK1_DUTY_CYCLE         : natural := 50;
        CLK1_MULTIPLY_BY        : natural := 1;
        CLK1_PHASE_SHIFT        : string := "0"
      );
      port
      (
        inclk0		: IN STD_LOGIC  := '0';
        c0		    : OUT STD_LOGIC ;
        c1		    : OUT STD_LOGIC ;
        c2		    : OUT STD_LOGIC ;
        locked		: OUT STD_LOGIC 
      );
    END component pll;
  begin
    GEN_PLL : if PACE_HAS_PLL generate
      pll_inst : pll
        generic map
        (
          INCLK0_INPUT_FREQUENCY  => 20000,

          -- CLK0
          CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
          CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
      
          -- CLK1
          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        )
        port map
        (
          inclk0	=> clock50,
          c0      => BITEC_DVI_IO_OUT_IDCKp,  -- 108MHz
          c1      => clk_i(1),                -- 108MHz
          c2      => clk_i(0),                -- 40MHz
          locked  => open
        );
    end generate GEN_PLL;  
  end block BLK_PLL;

  BLK_VIDEO : block

    signal clk_110M       : std_logic;
    signal clk_121M       : std_logic;
    
    signal vga_valid      : std_logic;
    signal vga_hs         : std_logic;
    signal vga_vs         : std_logic;
    
    signal dvi_4bpp_data  : std_logic_vector(11 downto 0);
    
  begin

		video_i.clk <= clk_i(1);	-- by convention
		video_i.clk_ena <= '1';
    video_i.reset <= reset_i;
    
    vga_valid <= not (video_o.hblank or video_o.vblank);
    vga_hs <= not video_o.hsync;
    vga_vs <= not video_o.vsync;
    
    GEN_VIP : if false generate

      --dvi_out_pll_inst : entity work.dvi_out_pll
      --  port map
      --  (
      --    inclk0	=> clock50,
      --    c0		  => clk_110M,
      --    c1		  => clk_121M
      --  );

      --vga_2_dvi_inst : entity work.vga_800x600_dvi_1280x1024
      --  port map
      --  (
          -- 1) global signals:
      --    altmemddr_0_aux_full_rate_clk_out => open,
      --    altmemddr_0_aux_half_rate_clk_out => open,
      --    altmemddr_0_phy_clk_out => open,
      --    clk_121M => clk_121M,
      --    clk_125M => clock_source,
      --    reset_n => reset_n,

          -- the_alt_vip_cti_0
      --    overflow_from_the_alt_vip_cti_0 => user_led(1),
      --    vid_clk_to_the_alt_vip_cti_0 => video_o.clk,
      --    vid_data_to_the_alt_vip_cti_0(23 downto 16) => video_o.rgb.r(9 downto 2),
      --    vid_data_to_the_alt_vip_cti_0(15 downto 8) => video_o.rgb.g(9 downto 2),
      --    vid_data_to_the_alt_vip_cti_0(7 downto 0) => video_o.rgb.b(9 downto 2),
      --    vid_datavalid_to_the_alt_vip_cti_0 => vga_valid,
      --    vid_f_to_the_alt_vip_cti_0 => '0',
      --    vid_h_sync_to_the_alt_vip_cti_0 => vga_hs,
      --    vid_locked_to_the_alt_vip_cti_0 => '1',
      --    vid_v_sync_to_the_alt_vip_cti_0 => vga_vs,

          -- the_alt_vip_itc_0
      --    underflow_from_the_alt_vip_itc_0 => user_led(2),
      --    vid_clk_to_the_alt_vip_itc_0 => clk_110M,
      --    vid_data_from_the_alt_vip_itc_0 => BITEC_DVI_IO_OUT,
      --    vid_datavalid_from_the_alt_vip_itc_0 => BITEC_DVI_IO_OUT_DE,
      --    vid_f_from_the_alt_vip_itc_0 => open,
      --    vid_h_from_the_alt_vip_itc_0 => open,
      --    vid_h_sync_from_the_alt_vip_itc_0 => BITEC_DVI_IO_OUT_HSYNC,
      --    vid_v_from_the_alt_vip_itc_0 => open,
      --    vid_v_sync_from_the_alt_vip_itc_0 => BITEC_DVI_IO_OUT_VSYNC,

          -- the_altmemddr_0
      --    global_reset_n_to_the_altmemddr_0 => reset_n,
      --    local_init_done_from_the_altmemddr_0 => open,
      --    local_refresh_ack_from_the_altmemddr_0 => open,
      --    local_wdata_req_from_the_altmemddr_0 => open,
      --    mem_addr_from_the_altmemddr_0 => memtop_addr,
      --    mem_ba_from_the_altmemddr_0 => memtop_ba,
      --    mem_cas_n_from_the_altmemddr_0 => memtop_cas_n,
      --    mem_cke_from_the_altmemddr_0 => memtop_cke(0),
      --    mem_clk_n_to_and_from_the_altmemddr_0 => memtop_clk_n(0),
      --    mem_clk_to_and_from_the_altmemddr_0 => memtop_clk(0),
      --    mem_cs_n_from_the_altmemddr_0 => memtop_cs_n(0),
      --    mem_dm_from_the_altmemddr_0 => memtop_dm,
      --    mem_dq_to_and_from_the_altmemddr_0 => memtop_dq,
      --    mem_dqs_to_and_from_the_altmemddr_0 => memtop_dqs,
      --    mem_odt_from_the_altmemddr_0 => memtop_odt(0),
      --    mem_ras_n_from_the_altmemddr_0 => memtop_ras_n,
      --    mem_we_n_from_the_altmemddr_0 => memtop_we_n,
      --    reset_phy_clk_n_from_the_altmemddr_0 => open
      -- );

      --BITEC_DVI_IO_OUT_IDCKp <= clk_110M;

    end generate GEN_VIP;
    
    GEN_NO_VIP : if true generate
    
      --BITEC_DVI_IO_OUT_IDCKp <= video_o.clk;
      BITEC_DVI_IO_OUT(23 downto 16) <= video_o.rgb.r(9 downto 2);
      BITEC_DVI_IO_OUT(15 downto 8) <= video_o.rgb.g(9 downto 2);
      BITEC_DVI_IO_OUT(7 downto 0) <= video_o.rgb.b(9 downto 2);
      BITEC_DVI_IO_OUT_DE <= vga_valid;
      BITEC_DVI_IO_OUT_HSYNC <= vga_hs;
      BITEC_DVI_IO_OUT_VSYNC <= vga_vs;

      user_led(2 downto 1) <= leds_o(1 downto 0);

    end generate GEN_NO_VIP;
    
    -- expand 12 to 24-bit colour
    --BITEC_DVI_IO_OUT <= dvi_4bpp_data(11 downto 8) & "0000" &
    --                    dvi_4bpp_data(7 downto 4) & "0000" &
    --                    dvi_4bpp_data(3 downto 0) & "0000";

    BITEC_QV_RESETB <= reset_n;
		BITEC_DVI_IO_OUT_IDCKn <= '0';
		BITEC_DVI_IO_OUT_DVI_PD <= '1';
		BITEC_DVI_IO_OUT_DVI_DKEN <= '0';
		BITEC_DVI_IO_OUT_DVI_ISEL <= '0';
		BITEC_DVI_IO_OUT_DVI_CTL1 <= '0';
		BITEC_DVI_IO_OUT_DVI_CTL2 <= '0';
		BITEC_DVI_IO_OUT_DVI_CTL3 <= '0';

  end block BLK_VIDEO;

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
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

  -- emulate some SRAM
  GEN_SRAM : if CYC3DEV_EMULATE_SRAM generate
    signal wren : std_logic := '0';
  begin
    wren <= sram_o.cs and sram_o.we;
    sram_inst : entity work.spram
      generic map
      (
        numwords_a		=> 2**CYC3DEV_EMULATED_SRAM_WIDTH_AD,
        widthad_a			=> CYC3DEV_EMULATED_SRAM_WIDTH_AD,
        width_a				=> CYC3DEV_EMULATED_SRAM_WIDTH
      )
      port map
      (
        clock		      => clk_i(0),
        address		    => sram_o.a(CYC3DEV_EMULATED_SRAM_WIDTH_AD-1 downto 0),
        data		      => sram_o.d(CYC3DEV_EMULATED_SRAM_WIDTH-1 downto 0),
        wren		      => wren,
        q		          => sram_i.d(CYC3DEV_EMULATED_SRAM_WIDTH-1 downto 0)
      );
    sram_i.d(sram_i.d'left downto CYC3DEV_EMULATED_SRAM_WIDTH) <= (others => '0');
  end generate GEN_SRAM;
  
  -- emulate some FLASH
  GEN_FLASH : if CYC3DEV_EMULATE_FLASH generate
    flash_inst : entity work.sprom
      generic map
      (
        init_file     => CYC3DEV_EMULATED_FLASH_INIT_FILE,
        numwords_a		=> 2**CYC3DEV_EMULATED_FLASH_WIDTH_AD,
        widthad_a			=> CYC3DEV_EMULATED_FLASH_WIDTH_AD,
        width_a				=> CYC3DEV_EMULATED_FLASH_WIDTH
      )
      port map
      (
        clock		      => clk_i(0),
        address		    => flash_o.a(CYC3DEV_EMULATED_FLASH_WIDTH_AD-1 downto 0),
        q		          => flash_i.d(CYC3DEV_EMULATED_FLASH_WIDTH-1 downto 0)
      );
    flash_i.d(flash_i.d'left downto CYC3DEV_EMULATED_FLASH_WIDTH) <= (others => '0');
  end generate GEN_FLASH;
  
  user_led(7 downto 3) <= leds_o(6 downto 2);

end SYN;
