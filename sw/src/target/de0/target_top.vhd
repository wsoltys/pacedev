library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.maple_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
		--////////////////////	Clock Input	 	////////////////////	 
		clock_50      : in std_logic;                         --	50 MHz
		clock_27      : in std_logic;                         --	27 MHz  -- NC on DE0
		ext_clock     : in std_logic;                         --	External Clock
		--////////////////////	Push Button		////////////////////
		key           : in std_logic_vector(2 downto 0);      --	Pushbutton[3:0]
		--////////////////////	DPDT Switch		////////////////////
		sw            : in std_logic_vector(9 downto 0);     --	Toggle Switch[9:0]
		--////////////////////	7-SEG Dispaly	////////////////////
		hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
		hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
		hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
		hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
		--////////////////////////	LED		////////////////////////
		ledg          : out std_logic_vector(9 downto 0);     --	LED Green[9:0]
		--////////////////////////	UART	////////////////////////
		uart_txd      : out std_logic;                        --	UART Transmitter
		uart_rxd      : in std_logic;                         --	UART Receiver
		--////////////////////////	IRDA	////////////////////////
		-- irda_txd      : out std_logic;                        --	IRDA Transmitter
		-- irda_rxd      : in std_logic;                         --	IRDA Receiver
		--/////////////////////	SDRAM Interface		////////////////
		dram_dq       : inout std_logic_vector(15 downto 0);  --	SDRAM Data bus 16 Bits
		dram_addr     : out std_logic_vector(12 downto 0);    --	SDRAM Address bus 12 Bits
		dram_ldqm     : out std_logic;                        --	SDRAM Low-byte Data Mask 
		dram_udqm     : out std_logic;                        --	SDRAM High-byte Data Mask
		dram_we_n     : out std_logic;                        --	SDRAM Write Enable
		dram_cas_n    : out std_logic;                        --	SDRAM Column Address Strobe
		dram_ras_n    : out std_logic;                        --	SDRAM Row Address Strobe
		dram_cs_n     : out std_logic;                        --	SDRAM Chip Select
		dram_ba_0     : out std_logic;                        --	SDRAM Bank Address 0
		dram_ba_1     : out std_logic;                        --	SDRAM Bank Address 0
		dram_clk      : out std_logic;                        --	SDRAM Clock
		dram_cke      : out std_logic;                        --	SDRAM Clock Enable
		--////////////////////	Flash Interface		////////////////
		fl_dq         : inout std_logic_vector(7 downto 0);   --	FLASH Data bus 8 Bits
		fl_addr       : out std_logic_vector(21 downto 0);    --	FLASH Address bus 22 Bits
		fl_we_n       : out std_logic;                        -- 	FLASH Write Enable
		fl_rst_n      : out std_logic;                        --	FLASH Reset
		fl_oe_n       : out std_logic;                        --	FLASH Output Enable
		fl_ce_n       : out std_logic;                        --	FLASH Chip Enable
		--////////////////////	SD_Card Interface	////////////////
		sd_dat        : inout std_logic;                      --	SD Card Data
		sd_dat3       : inout std_logic;                      --	SD Card Data 3
		sd_cmd        : inout std_logic;                      --	SD Card Command Signal
		sd_clk        : out std_logic;                        --	SD Card Clock
		--////////////////////	PS2		////////////////////////////
		ps2_dat       : in std_logic;                         --	PS2 Data
		ps2_clk       : in std_logic;                         --	PS2 Clock
		--////////////////////	VGA		////////////////////////////
		vga_hs        : out std_logic;                        --	VGA H_SYNC
		vga_vs        : out std_logic;                        --	VGA V_SYNC
		vga_r         : out std_logic_vector(3 downto 0);     --	VGA Red[3:0]
		vga_g         : out std_logic_vector(3 downto 0);     --	VGA Green[3:0]
		vga_b         : out std_logic_vector(3 downto 0);     --	VGA Blue[3:0]
		--////////////////	Audio CODEC		////////////////////////
		-- No native sound on DE0 board.
		--////////////////////	GPIO	////////////////////////////
		gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
		gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
		--
		
  );

end target_top;

architecture SYN of target_top is

  constant DE1_HAS_BURCHED_PERIPHERAL   : boolean := false;
  constant DE1_TEST_BURCHED_LEDS        : boolean := false;
  constant DE1_TEST_BURCHED_DIPS        : boolean := false;
  constant DE1_TEST_BURCHED_7SEG        : boolean := false;

	alias gpio_maple 		  : std_logic_vector(35 downto 0) is gpio_0;
	alias gpio_lcd 			  : std_logic_vector(35 downto 0) is gpio_1;
	
	signal clk_i			    : std_logic_vector(0 to 3);
  signal init       	  : std_logic := '1';
  signal reset_i     	  : std_logic := '1';
	signal reset_n			  : std_logic := '0';

  signal buttons_i      : from_BUTTONS_t;
  signal switches_i     : from_SWITCHES_t;
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

  -- gpio drivers from default logic
  signal default_gpio_0_o   : std_logic_vector(gpio_0'range) := (others => 'Z');
  signal default_gpio_1_o   : std_logic_vector(gpio_1'range) := (others => 'Z');
	signal seg7               : std_logic_vector(15 downto 0);
	
begin

  BLK_CLOCKING : block
  begin
  
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_50_inst : entity work.pll
        generic map
        (
          -- INCLK0
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
          inclk0  => clock_50,
          c0      => clk_i(0),
          c1      => clk_i(1)
        );

    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clk_i(0) <= clock_50;
      clk_i(1) <= clock_27;
        
    end generate GEN_NO_PLL;
      
    pll_27_inst : entity work.pll
      generic map
      (
        -- INCLK0
        INCLK0_INPUT_FREQUENCY  => 37037,

        -- CLK0 - 18M432Hz for audio
        CLK0_DIVIDE_BY          => 22,
        CLK0_MULTIPLY_BY        => 15,
    
        -- CLK1 - not used
        CLK1_DIVIDE_BY          => 1,
        CLK1_MULTIPLY_BY        => 1
      )
      port map
      (
        inclk0  => clock_27,
        c0      => clk_i(2),
        c1      => clk_i(3)
      );

  end block BLK_CLOCKING;
	
  -- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock_50)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(clock_50) then
			if count = X"FFF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

  reset_i <= init or not key(0);
	reset_n <= not reset_i;
	
  -- buttons - active low
  buttons_i <= std_logic_vector(resize(unsigned(not key), buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(resize(unsigned(sw), switches_i'length));
  
	-- inputs

  GEN_NO_BURCHED_PERIPHERAL : if not DE1_HAS_BURCHED_PERIPHERAL generate
    -- ps/2
    inputs_i.ps2_kclk <= ps2_clk;
    inputs_i.ps2_kdat <= ps2_dat;
    inputs_i.ps2_mclk <= '0';
    inputs_i.ps2_mdat <= '0';
    -- serial
    uart_txd <= ser_o.txd;
    ser_i.rxd <= uart_rxd;
  end generate GEN_NO_BURCHED_PERIPHERAL;
  
  GEN_BURCHED_PERIPHERAL : if DE1_HAS_BURCHED_PERIPHERAL generate
    -- ps/2
    inputs_i.ps2_kclk <= gpio_0(9);
    inputs_i.ps2_kdat <= gpio_0(10);
    inputs_i.ps2_mclk <= gpio_0(11);
    inputs_i.ps2_mdat <= gpio_0(12);
    -- serial
    default_gpio_0_o(16) <= ser_o.txd;
    ser_i.rxd <= gpio_0(15);
    default_gpio_0_o(17) <= ser_o.rts;
    ser_i.cts <= gpio_0(14);
    -- video
    default_gpio_0_o(8) <= video_o.rgb.r(video_o.rgb.r'left);
    default_gpio_0_o(7) <= video_o.rgb.r(video_o.rgb.r'left-1);
    default_gpio_0_o(6) <= video_o.rgb.g(video_o.rgb.g'left);
    default_gpio_0_o(5) <= video_o.rgb.g(video_o.rgb.g'left-1);
    default_gpio_0_o(4) <= video_o.rgb.b(video_o.rgb.b'left);
    default_gpio_0_o(3) <= video_o.rgb.b(video_o.rgb.b'left-1);
    default_gpio_0_o(2) <= video_o.hsync;
    default_gpio_0_o(1) <= video_o.vsync;
  end generate GEN_BURCHED_PERIPHERAL;
  
	GEN_MAPLE : if PACE_JAMMA = PACE_JAMMA_MAPLE generate
	
    -- all this is so we can easily switch GPIO ports for maple bus!
    alias gpio_maple_i  : std_logic_vector(17 downto 11) is gpio_0;
    alias gpio_maple_o  : std_logic_vector(14 downto 11) is default_gpio_0_o;

    signal maple_sense	: std_logic;
    signal maple_oe			: std_logic;
    signal mpj					: work.maple_pkg.joystate_type;
    signal a            : std_logic;
    signal b            : std_logic;

  begin
  
		-- Dreamcast MapleBus joystick interface
		MAPLE_JOY : entity work.maple_joy
			port map
			(
				clk				=> clock_50,
				reset			=> reset_i,
				sense			=> maple_sense,
				oe				=> maple_oe,
				a					=> a, --gpio_maple(14),
				b					=> b, --gpio_maple(13),
				joystate	=> mpj
			);

    -- insert drivers for a, b here
      
    gpio_maple_o(12) <= maple_oe;
    gpio_maple_o(11) <= not maple_oe;
    maple_sense <= gpio_maple_i(17); -- and sw(0);

		-- map maple bus to jamma inputs
		-- - same mappings as default mappings for MAMED (DCMAME)
		inputs_i.jamma_n.coin(1) 				  <= mpj.lv(7);		-- MSB of right analogue trigger (0-255)
		inputs_i.jamma_n.p(1).start 			<= mpj.start;
		inputs_i.jamma_n.p(1).up 				  <= mpj.d_up;
		inputs_i.jamma_n.p(1).down 			  <= mpj.d_down;
		inputs_i.jamma_n.p(1).left	 			<= mpj.d_left;
		inputs_i.jamma_n.p(1).right 			<= mpj.d_right;
		inputs_i.jamma_n.p(1).button(1) 	<= mpj.a;
		inputs_i.jamma_n.p(1).button(2) 	<= mpj.x;
		inputs_i.jamma_n.p(1).button(3) 	<= mpj.b;
		inputs_i.jamma_n.p(1).button(4) 	<= mpj.y;
		inputs_i.jamma_n.p(1).button(5)	  <= '1';

	end generate GEN_MAPLE;

	GEN_GAMECUBE : if PACE_JAMMA = PACE_JAMMA_NGC generate
	
    signal gcj  : work.gamecube_pkg.joystate_type;
    signal d    : std_logic := '0';

  begin
	
		GC_JOY: gamecube_joy
			generic map( MHZ => 50 )
  		port map
		  (
  			clk 				=> clock_50,
				reset 			=> reset_i,
				--oe 					=> gc_oe,
				d 					=> d, --gpio_maple(25),
				joystate 		=> gcj
			);

    -- insert drivers for d here...

		-- map gamecube controller to jamma inputs
		inputs_i.jamma_n.coin(1) <= not gcj.l;
		inputs_i.jamma_n.p(1).start <= not gcj.start;
		inputs_i.jamma_n.p(1).up <= not gcj.d_up;
		inputs_i.jamma_n.p(1).down <= not gcj.d_down;
		inputs_i.jamma_n.p(1).left <= not gcj.d_left;
		inputs_i.jamma_n.p(1).right <= not gcj.d_right;
		inputs_i.jamma_n.p(1).button(1) <= not gcj.a;
		inputs_i.jamma_n.p(1).button(2) <= not gcj.b;
		inputs_i.jamma_n.p(1).button(3) <= not gcj.x;
		inputs_i.jamma_n.p(1).button(4) <= not gcj.y;
		inputs_i.jamma_n.p(1).button(5)	<= not gcj.z;

	end generate GEN_GAMECUBE;
	
	GEN_NO_JAMMA : if PACE_JAMMA = PACE_JAMMA_NONE generate
		inputs_i.jamma_n.coin(1) <= '1';
		inputs_i.jamma_n.p(1).start <= '1';
		inputs_i.jamma_n.p(1).up <= '1';
		inputs_i.jamma_n.p(1).down <= '1';
		inputs_i.jamma_n.p(1).left <= '1';
		inputs_i.jamma_n.p(1).right <= '1';
		inputs_i.jamma_n.p(1).button <= (others => '1');
  end generate GEN_NO_JAMMA;
  
	-- not currently wired to any inputs
	inputs_i.jamma_n.coin_cnt <= (others => '1');
	inputs_i.jamma_n.coin(2) <= '1';
	inputs_i.jamma_n.p(2).start <= '1';
  inputs_i.jamma_n.p(2).up <= '1';
  inputs_i.jamma_n.p(2).down <= '1';
	inputs_i.jamma_n.p(2).left <= '1';
	inputs_i.jamma_n.p(2).right <= '1';
	inputs_i.jamma_n.p(2).button <= (others => '1');
	inputs_i.jamma_n.service <= '1';
	inputs_i.jamma_n.tilt <= '1';
	inputs_i.jamma_n.test <= '1';
		
	-- show JAMMA inputs on LED bank
--	ledr(17) <= not jamma_n.coin(1);
--	ledr(16) <= not jamma_n.coin(2);
--	ledr(15) <= not jamma_n.p(1).start;
--	ledr(14) <= not jamma_n.p(1).up;
--	ledr(13) <= not jamma_n.p(1).down;
--	ledr(12) <= not jamma_n.p(1).left;
--	ledr(11) <= not jamma_n.p(1).right;
--	ledr(10) <= not jamma_n.p(1).button(1);
--	ledr(9) <= not jamma_n.p(1).button(2);
--	ledr(8) <= not jamma_n.p(1).button(3);
--	ledr(7) <= not jamma_n.p(1).button(4);
--	ledr(6) <= not jamma_n.p(1).button(5);

  -- flash memory
  BLK_FLASH : block
  begin
    fl_rst_n <= '1';

    GEN_FLASH : if PACE_HAS_FLASH generate
      flash_i.d <= fl_dq;
      fl_dq <=  flash_o.d when (flash_o.cs = '1' and flash_o.we = '1' and flash_o.oe = '0') else 
                (others => 'Z');
      fl_addr <= flash_o.a;
      fl_we_n <= not flash_o.we;
      fl_oe_n <= not flash_o.oe;
      fl_ce_n <= not flash_o.cs;
    end generate GEN_FLASH;
    
    GEN_NO_FLASH : if not PACE_HAS_FLASH generate
      flash_i.d <= (others => '1');
      fl_dq <= (others => 'Z');
      fl_addr <= (others => 'Z');
      fl_ce_n <= '1';
      fl_oe_n <= '1';
      fl_we_n <= '1';
    end generate GEN_NO_FLASH;

  end block BLK_FLASH;
  
  BLK_SDRAM : block

    component sdram_0 is 
      port 
      (
        -- inputs:
        signal az_addr : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
        signal az_be_n : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal az_cs : IN STD_LOGIC;
        signal az_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal az_rd_n : IN STD_LOGIC;
        signal az_wr_n : IN STD_LOGIC;
        signal clk : IN STD_LOGIC;
        signal reset_n : IN STD_LOGIC;

        -- outputs:
        signal za_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal za_valid : OUT STD_LOGIC;
        signal za_waitrequest : OUT STD_LOGIC;
        signal zs_addr : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal zs_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal zs_cas_n : OUT STD_LOGIC;
        signal zs_cke : OUT STD_LOGIC;
        signal zs_cs_n : OUT STD_LOGIC;
        signal zs_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal zs_dqm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal zs_ras_n : OUT STD_LOGIC;
        signal zs_we_n : OUT STD_LOGIC
      );
    end component sdram_0;

  begin

    GEN_NO_SDRAM : if not PACE_HAS_SDRAM generate
      dram_addr <= (others => 'Z');
      dram_we_n <= '1';
      dram_cs_n <= '1';
      dram_clk <= '0';
      dram_cke <= '0';
    end generate GEN_NO_SDRAM;
  
    GEN_SDRAM : if PACE_HAS_SDRAM generate
      dram_addr <= (others => 'Z');
      dram_we_n <= '1';
      dram_cs_n <= '1';
      dram_clk <= '0';
      dram_cke <= '0';
    end generate GEN_SDRAM;

  end block BLK_SDRAM;

  BLK_VIDEO : block
  begin

	video_i.clk <= clk_i(1);	-- by convention
	video_i.clk_ena <= '1';
    video_i.reset <= reset_i;
    
    --vga_clk <= video_o.clk;
    vga_r <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-3);
    vga_g <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-3);
    vga_b <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-3);
    vga_hs <= video_o.hsync;
    vga_vs <= video_o.vsync;
    --vga_sync <= video_o.hsync and video_o.vsync;
    --vga_blank <= '1';

  end block BLK_VIDEO;

  BLK_LCM : block

    component I2S_LCM_Config 
      port
      (   --  Host Side
              iCLK      : in std_logic;
        iRST_N    : in std_logic;
        --    I2C Side
        I2S_SCLK  : out std_logic;
        I2S_SDAT  : out std_logic;
        I2S_SCEN  : out std_logic
      );
    end component I2S_LCM_Config;

    alias gpio_lcd_o 		: std_logic_vector(35 downto 18) is default_gpio_1_o(35 downto 18);
    
    signal lcm_sclk   	: std_logic;
    signal lcm_sdat   	: std_logic;
    signal lcm_scen   	: std_logic;
    signal lcm_data   	: std_logic_vector(7 downto 0);
    signal lcm_grst  		: std_logic;
    signal lcm_hsync  	: std_logic;
    signal lcm_vsync  	: std_logic;
    signal lcm_dclk  		: std_logic;
    signal lcm_shdb  		: std_logic;
    signal lcm_clk			: std_logic;

  begin
  
    lcmc: I2S_LCM_Config
      port map
      (   --  Host Side
        iCLK => clock_50,
        iRST_N => reset_n, --lcm_grst_n,
        --    I2C Side
        I2S_SCLK => lcm_sclk,
        I2S_SDAT => lcm_sdat,
        I2S_SCEN => lcm_scen
      );

    lcm_clk <= video_o.clk;
    lcm_grst <= reset_n;
    lcm_dclk	<=	not lcm_clk;
    lcm_shdb	<=	'1';
    lcm_hsync <= video_o.hsync;
    lcm_vsync <= video_o.vsync;

    gpio_lcd_o(19) <= lcm_data(7);
    gpio_lcd_o(18) <= lcm_data(6);
    gpio_lcd_o(21) <= lcm_data(5);
    gpio_lcd_o(20) <= lcm_data(4);
    gpio_lcd_o(23) <= lcm_data(3);
    gpio_lcd_o(22) <= lcm_data(2);
    gpio_lcd_o(25) <= lcm_data(1);
    gpio_lcd_o(24) <= lcm_data(0);
    gpio_lcd_o(30) <= lcm_grst;
    gpio_lcd_o(26) <= lcm_vsync;
    gpio_lcd_o(35) <= lcm_hsync;
    gpio_lcd_o(29) <= lcm_dclk;
    gpio_lcd_o(31) <= lcm_shdb;
    gpio_lcd_o(28) <= lcm_sclk;
    gpio_lcd_o(33) <= lcm_scen;
    gpio_lcd_o(34) <= lcm_sdat;

  end block BLK_LCM;

--  BLK_AUDIO : block
--    alias aud_clk    		: std_logic is clk_i(2);
--    signal aud_data_l  	: std_logic_vector(audio_o.ldata'range);
--    signal aud_data_r  	: std_logic_vector(audio_o.rdata'range);
--  begin

    -- enable each channel independantly for debugging
 --   aud_data_l <= audio_o.ldata when switches_i(9) = '0' else (others => '0');
 --   aud_data_r <= audio_o.rdata when switches_i(8) = '0' else (others => '0');

    -- Audio
 --   audif_inst : entity work.audio_if
 --     generic map 
 --     (
 --       REF_CLK       => 18432000,  -- Set REF clk frequency here
 --       SAMPLE_RATE   => 48000,     -- 48000 samples/sec
 --       DATA_WIDTH    => 16,			  --	16		Bits
 --       CHANNEL_NUM   => 2  			  --	Dual Channel
 --     )
 --     port map
 --     (
 --       -- Inputs
 --       clk           => aud_clk,
 --       reset         => reset_i,
 --       datal         => aud_data_l,
 --       datar         => aud_data_r,
    
        -- Outputs
--        aud_xck       => aud_xck,
--        aud_adclrck   => aud_adclrck,
--        aud_daclrck   => aud_daclrck,
--        aud_bclk      => aud_bclk,
--        aud_dacdat    => aud_dacdat,
--        next_sample   => open
--      );

--  end block BLK_AUDIO;
  
  -- disable SD card
  sd_clk <= '0';
  sd_dat <= 'Z';
  sd_dat3 <= 'Z';
  sd_cmd <= 'Z';

 
  -- GPIO

  GEN_TEST_BURCHED_LEDS : if DE1_TEST_BURCHED_LEDS generate
  
    assert (PACE_JAMMA = PACE_JAMMA_NONE and
            PACE_VIDEO_CONTROLLER_TYPE /= PACE_VIDEO_LCM_320x240_60Hz and
            not DE1_TEST_BURCHED_DIPS and
            not DE1_TEST_BURCHED_7SEG)
      report "DE1_TEST_BURCHED_LEDS not compatible with other DE1 options"
        severity failure;

    process (clock_27, reset_i)
      variable r : std_logic_vector(15 downto 0);
      variable count : std_logic_vector(21 downto 0);
    begin
      if reset_i = '1' then
        r := (0=>'1', others => '0');
        count := (others => '0');
      elsif rising_edge(clock_27) then
        count := count + 1;
        if count = 0 then
          r := r(0) & r(r'left downto 1);
        end if;
      end if;
      gpio_0(17 downto 2) <= r;
      gpio_0(35 downto 20) <= not r;
    end process;
    
  end generate GEN_TEST_BURCHED_LEDS;
  
  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clk_i							=> clk_i,
      reset_i          	=> reset_i,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => open,		-- no red leds on de0
      
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

  BLK_CUSTOM_IO : block
  
    signal custom_gpio_0_o    : std_logic_vector(gpio_0'range);
    signal custom_gpio_0_oe   : std_logic_vector(gpio_0'range);
    signal gpio_0_is_custom   : std_logic_vector(gpio_0'range);
    signal custom_gpio_1_o    : std_logic_vector(gpio_1'range);
    signal custom_gpio_1_oe   : std_logic_vector(gpio_1'range);
    signal gpio_1_is_custom   : std_logic_vector(gpio_1'range);

  begin
  
    custom_io_inst : entity work.custom_io
      port map
      (
        -- GPIO 0 connector
        gpio_0_i          => gpio_0,
        gpio_0_o          => custom_gpio_0_o,
        gpio_0_oe         => custom_gpio_0_oe,
        gpio_0_is_custom  => gpio_0_is_custom,
        
        -- GPIO 1 connector
        gpio_1_i          => gpio_1,
        gpio_1_o          => custom_gpio_1_o,
        gpio_1_oe         => custom_gpio_1_oe,
        gpio_1_is_custom  => gpio_1_is_custom,

        -- 7-segment display
        seg7              => seg7,
        
        -- custom i/o
        project_i         => project_i,
        project_o         => project_o,
        platform_i        => platform_i,
        platform_o        => platform_o,
        target_i          => target_i,
        target_o          => target_o
      );

    GEN_GPIO_0_O : for i in gpio_0'range generate
      default_gpio_0_o(i) <= 'Z';
      gpio_0(i) <=  custom_gpio_0_o(i) when 
                      (gpio_0_is_custom(i) = '1' and custom_gpio_0_oe(i) = '1') else
                    default_gpio_0_o(i) when gpio_0_is_custom(i) = '0' else
                    'Z';
    end generate GEN_GPIO_0_O;
    
    GEN_GPIO_1_O : for i in gpio_1'range generate
      default_gpio_1_o(i) <= 'Z';
      gpio_1(i) <=  custom_gpio_1_o(i) when 
                      (gpio_1_is_custom(i) = '1' and custom_gpio_1_oe(i) = '1') else
                    default_gpio_1_o(i) when gpio_1_is_custom(i) = '0' else
                    'Z';
    end generate GEN_GPIO_1_O;

  end block BLK_CUSTOM_IO;
  
 BLK_CHASER : block
    signal pwmen      	: std_logic;
    signal chaseen    	: std_logic;
  begin
  
    pchaser: entity work.pwm_chaser 
      generic map(nleds  => 8, nbits => 8, period => 4, hold_time => 12)
      port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => reset_i, fade => X"0F", ledout => ledg(7 downto 0));

    -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
    process(clock_50, reset_i)
      variable pcount     : std_logic_vector(9 downto 0);
      variable pwmen_r    : std_logic;
      variable ccount     : std_logic_vector(18 downto 0);
      variable chaseen_r  : std_logic;
    begin
      pwmen <= pwmen_r;
      chaseen <= chaseen_r;
      if reset_i = '1' then
        pcount := (others => '0');
        ccount := (others => '0');
      elsif rising_edge(clock_50) then
        pwmen_r := '0';
        if pcount = std_logic_vector(to_unsigned(0, pcount'length)) then
          pwmen_r := '1';
        end if;
        chaseen_r := '0';
        if ccount = std_logic_vector(to_unsigned(0, ccount'length)) then
          chaseen_r := '1';
        end if;
        pcount := pcount + 1;
        ccount := ccount + 1;
      end if;
    end process;
    
  end block BLK_CHASER;

  BLK_7_SEG : block
  
    component SEG7_LUT is
      port 
      (
        iDIG : in std_logic_vector(3 downto 0); 
        oSEG : out std_logic_vector(6 downto 0)
      );
    end component SEG7_LUT;

  begin
    -- from left to right on the PCB
    seg7_3: SEG7_LUT port map (iDIG => seg7(15 downto 12), oSEG => hex3);
    seg7_2: SEG7_LUT port map (iDIG => seg7(11 downto 8), oSEG => hex2);
    seg7_1: SEG7_LUT port map (iDIG => seg7(7 downto 4), oSEG => hex1);
    seg7_0: SEG7_LUT port map (iDIG => seg7(3 downto 0), oSEG => hex0);
  end block BLK_7_SEG;
  
end SYN;
