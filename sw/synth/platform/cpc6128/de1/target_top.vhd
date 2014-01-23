library ieee;
use ieee.std_logic_1164.all;
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
		clock_27      : in std_logic;                         --	27 MHz
		clock_50      : in std_logic;                         --	50 MHz
		ext_clock     : in std_logic;                         --	External Clock
		--////////////////////	Push Button		////////////////////
		key           : in std_logic_vector(3 downto 0);      --	Pushbutton[3:0]
		--////////////////////	DPDT Switch		////////////////////
		sw            : in std_logic_vector(9 downto 0);     --	Toggle Switch[9:0]
		--////////////////////	7-SEG Dispaly	////////////////////
		hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
		hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
		hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
		hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
		--////////////////////////	LED		////////////////////////
		ledg          : out std_logic_vector(7 downto 0);     --	LED Green[8:0]
		ledr          : out std_logic_vector(9 downto 0);    --	LED Red[17:0]
		--////////////////////////	UART	////////////////////////
		uart_txd      : out std_logic;                        --	UART Transmitter
		uart_rxd      : in std_logic;                         --	UART Receiver
		--////////////////////////	IRDA	////////////////////////
		-- irda_txd      : out std_logic;                        --	IRDA Transmitter
		-- irda_rxd      : in std_logic;                         --	IRDA Receiver
		--/////////////////////	SDRAM Interface		////////////////
		dram_dq       : inout std_logic_vector(15 downto 0);  --	SDRAM Data bus 16 Bits
		dram_addr     : out std_logic_vector(11 downto 0);    --	SDRAM Address bus 12 Bits
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
		fl_addr       : inout std_logic_vector(21 downto 0);    --	FLASH Address bus 22 Bits
		fl_we_n       : out std_logic;                        -- 	FLASH Write Enable
		fl_rst_n      : inout std_logic;                        --	FLASH Reset
		fl_oe_n       : inout std_logic;                        --	FLASH Output Enable
		fl_ce_n       : out std_logic;                        --	FLASH Chip Enable
		--////////////////////	SRAM Interface		////////////////
		sram_dq       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
		sram_addr     : out std_logic_vector(17 downto 0);    --	SRAM Address bus 18 Bits
		sram_ub_n     : out std_logic;                        --	SRAM High-byte Data Mask 
		sram_lb_n     : out std_logic;                        --	SRAM Low-byte Data Mask 
		sram_we_n     : out std_logic;                        --	SRAM Write Enable
		sram_ce_n     : out std_logic;                        --	SRAM Chip Enable
		sram_oe_n     : out std_logic;                        --	SRAM Output Enable
		--////////////////////	SD_Card Interface	////////////////
		sd_dat        : inout std_logic;                      --	SD Card Data
		sd_dat3       : inout std_logic;                      --	SD Card Data 3
		sd_cmd        : inout std_logic;                      --	SD Card Command Signal
		sd_clk        : out std_logic;                        --	SD Card Clock
		--////////////////////	USB JTAG link	////////////////////
		tdi           : in std_logic;                         -- CPLD -> FPGA (data in)
		tck           : in std_logic;                         -- CPLD -> FPGA (clk)
		tcs           : in std_logic;                         -- CPLD -> FPGA (CS)
	  tdo           : out std_logic;                        -- FPGA -> CPLD (data out)
		--////////////////////	I2C		////////////////////////////
		i2c_sdat      : inout std_logic;                      --	I2C Data
		i2c_sclk      : out std_logic;                        --	I2C Clock
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
		aud_adclrck   : out std_logic;                        --	Audio CODEC ADC LR Clock
		aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
		aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
		aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
		aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
		aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
		--////////////////////	GPIO	////////////////////////////
		gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
		gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
  );

end target_top;

architecture SYN of target_top is

  constant DE1_HAS_BURCHED_PERIPHERAL   : boolean := false;
  constant DE1_TEST_BURCHED_LEDS        : boolean := false;
  constant DE1_TEST_BURCHED_DIPS        : boolean := false;
  constant DE1_TEST_BURCHED_7SEG        : boolean := false;

  signal init       	  : std_logic := '1';
  
  signal clkrst_i       : from_CLKRST_t;
	signal sram_i			    : from_SRAM_t;
	signal sram_o			    : to_SRAM_t;	

  -- gpio drivers from default logic
  signal default_gpio_0_o   : std_logic_vector(gpio_0'range) := (others => 'Z');
  signal default_gpio_0_oe  : std_logic_vector(gpio_0'range) := (others => 'Z');
  signal default_gpio_1_o   : std_logic_vector(gpio_1'range) := (others => 'Z');
  signal default_gpio_1_oe  : std_logic_vector(gpio_1'range) := (others => 'Z');
	signal seg7               : std_logic_vector(15 downto 0);
	
begin

  BLK_CLOCKING : block
  begin
  
    --clkrst_i.clk_ref <= clock_50;
      
--    pll_27_inst : entity work.pll
--      generic map
--      (
--        -- INCLK0
--        INCLK0_INPUT_FREQUENCY  => 37037,
--
--        -- CLK0 - 18M432Hz for audio
--        CLK0_DIVIDE_BY          => 22,
--        CLK0_MULTIPLY_BY        => 15,
--    
--        -- CLK1 - not used
--        CLK1_DIVIDE_BY          => 1,
--        CLK1_MULTIPLY_BY        => 1
--      )
--      port map
--      (
--        inclk0  => clock_27,
--        c0      => clkrst_i.clk(2),
--        c1      => clkrst_i.clk(3)
--      );

  end block BLK_CLOCKING;
	
  -- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock_50)
		variable count : unsigned(11 downto 0) := (others => '0');
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

  clkrst_i.arst <= init or not key(0);
	clkrst_i.arst_n <= not clkrst_i.arst;

--  GEN_RESETS : for i in 0 to 3 generate
--
--    process (clkrst_i.clk(i), clkrst_i.arst)
--      variable rst_r : std_logic_vector(2 downto 0) := (others => '0');
--    begin
--      if clkrst_i.arst = '1' then
--        rst_r := (others => '1');
--      elsif rising_edge(clkrst_i.clk(i)) then
--        rst_r := rst_r(rst_r'left-1 downto 0) & '0';
--      end if;
--      clkrst_i.rst(i) <= rst_r(rst_r'left);
--    end process;
--
--  end generate GEN_RESETS;
	
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
		maple_joy_inst : maple_joy
			port map
			(
				clk				=> clock_50,
				reset			=> clkrst_i.arst,
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

--		-- map maple bus to jamma inputs
--		-- - same mappings as default mappings for MAMED (DCMAME)
--		inputs_i.jamma_n.coin(1) 				  <= mpj.lv(7);		-- MSB of right analogue trigger (0-255)
--		inputs_i.jamma_n.p(1).start 			<= mpj.start;
--		inputs_i.jamma_n.p(1).up 				  <= mpj.d_up;
--		inputs_i.jamma_n.p(1).down 			  <= mpj.d_down;
--		inputs_i.jamma_n.p(1).left	 			<= mpj.d_left;
--		inputs_i.jamma_n.p(1).right 			<= mpj.d_right;
--		inputs_i.jamma_n.p(1).button(1) 	<= mpj.a;
--		inputs_i.jamma_n.p(1).button(2) 	<= mpj.x;
--		inputs_i.jamma_n.p(1).button(3) 	<= mpj.b;
--		inputs_i.jamma_n.p(1).button(4) 	<= mpj.y;
--		inputs_i.jamma_n.p(1).button(5)	  <= '1';

	end generate GEN_MAPLE;

	GEN_GAMECUBE : if PACE_JAMMA = PACE_JAMMA_NGC generate
	
    -- all this is so we can easily switch GPIO ports for NGC bus!
    alias ngc_i   : std_logic_vector(gpio_0'range) is gpio_0;
    alias ngc_o   : std_logic_vector(default_gpio_0_o'range) is default_gpio_0_o;
    alias ngc_oe  : std_logic_vector(default_gpio_0_oe'range) is default_gpio_0_oe;

    signal gcj  : work.gamecube_pkg.joystate_type;

  begin
	
		GC_JOY: gamecube_joy
			generic map( MHZ => 50 )
  		port map
		  (
  			clk 				=> clock_50,
				reset 			=> clkrst_i.arst,
				d_i 				=> ngc_i(25),
				d_o         => ngc_o(25),
				d_oe 				=> ngc_oe(25),
				joystate 		=> gcj
			);

--		-- map gamecube controller to jamma inputs
--		inputs_i.jamma_n.coin(1) <= not gcj.l;
--		inputs_i.jamma_n.p(1).start <= not gcj.start;
--		inputs_i.jamma_n.p(1).up <= not gcj.d_up;
--		inputs_i.jamma_n.p(1).down <= not gcj.d_down;
--		inputs_i.jamma_n.p(1).left <= not gcj.d_left;
--		inputs_i.jamma_n.p(1).right <= not gcj.d_right;
--		inputs_i.jamma_n.p(1).button(1) <= not gcj.a;
--		inputs_i.jamma_n.p(1).button(2) <= not gcj.b;
--		inputs_i.jamma_n.p(1).button(3) <= not gcj.x;
--		inputs_i.jamma_n.p(1).button(4) <= not gcj.y;
--		inputs_i.jamma_n.p(1).button(5)	<= not gcj.z;
--
--    -- analogue mappings
--    inputs_i.analogue(1) <= gcj.jx & "00";
--    inputs_i.analogue(2) <= gcj.jy & "00";
--    inputs_i.analogue(3) <= (others => '0');
--    inputs_i.analogue(4) <= (others => '0');
    
	end generate GEN_GAMECUBE;
	
  -- static memory
  BLK_SRAM : block
  begin
  
    GEN_SRAM : if PACE_HAS_SRAM generate
      sram_addr <= sram_o.a(sram_addr'range);
      sram_i.d <= std_logic_vector(resize(unsigned(sram_dq), sram_i.d'length));
      sram_dq <= sram_o.d(sram_dq'range) when (sram_o.cs = '1' and sram_o.we = '1') else (others => 'Z');
      sram_ub_n <= not sram_o.be(1);
      sram_lb_n <= not sram_o.be(0);
      sram_ce_n <= not sram_o.cs;
      sram_oe_n <= not sram_o.oe;
      sram_we_n <= not sram_o.we;
    end generate GEN_SRAM;
    
    GEN_NO_SRAM : if not PACE_HAS_SRAM generate
      sram_addr <= (others => 'Z');
      sram_i.d <= (others => '1');
      sram_dq <= (others => 'Z');
      sram_ub_n <= '1';
      sram_lb_n <= '1';
      sram_ce_n <= '1';
      sram_oe_n <= '1';
      sram_we_n <= '1';  
    end generate GEN_NO_SRAM;
    
  end block BLK_SRAM;

  -- disable JTAG
  tdo <= 'Z';
  
  BLK_CPC6128 : block

    COMPONENT a1k100
      PORT(sysclk : IN STD_LOGIC;
         shiftclk : IN STD_LOGIC;
         kb_clk : IN STD_LOGIC;
         kb_data : IN STD_LOGIC;
         mouse_clk : INOUT STD_LOGIC;
         mouse_data : INOUT STD_LOGIC;
         fl_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         idedb : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         key : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         sdata : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         sw : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         vsync : OUT STD_LOGIC;
         hsync : OUT STD_LOGIC;
         iauda : OUT STD_LOGIC;
         lrclk : OUT STD_LOGIC;
         bck : OUT STD_LOGIC;
         sd_we : OUT STD_LOGIC;
         sd_ras : OUT STD_LOGIC;
         sd_cas : OUT STD_LOGIC;
         fl_ce : OUT STD_LOGIC;
         ide1cs : OUT STD_LOGIC;
         ide2cs : OUT STD_LOGIC;
         io_wr : OUT STD_LOGIC;
         io_rd : OUT STD_LOGIC;
         wrena : OUT STD_LOGIC;
         TxD : OUT STD_LOGIC;
         dqm : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         fl_addr : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
         idea : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         sd_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
         sd_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
         sd_cs : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         video : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
    END COMPONENT;

    COMPONENT clock
      PORT(inclk0 : IN STD_LOGIC;
         c0 : OUT STD_LOGIC;
         c1 : OUT STD_LOGIC
      );
    END COMPONENT;

    COMPONENT trex_mux
      PORT(flce_in : IN STD_LOGIC;
         ide1cs : IN STD_LOGIC;
         ide2cs : IN STD_LOGIC;
         io_wr : IN STD_LOGIC;
         io_rd : IN STD_LOGIC;
         wrena : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         cfreset : IN STD_LOGIC;
         flrst : INOUT STD_LOGIC;
         floe : INOUT STD_LOGIC;
         fladdr : INOUT STD_LOGIC_VECTOR(20 DOWNTO 0);
         fladdr_in : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
         fldata : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         Idea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         Idedb : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         flwe : OUT STD_LOGIC;
         cf_cs0 : OUT STD_LOGIC;
         cf_cs1 : OUT STD_LOGIC
      );
    END COMPONENT;

    SIGNAL	ba :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL	dqm :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL	fl_ce_n_ALTERA_SYNTHESIZED :  STD_LOGIC;
    SIGNAL	idea :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL	idedb :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL	sd_cs :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL	sdaddr :  STD_LOGIC_VECTOR(12 DOWNTO 0);
    SIGNAL	sdata :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL	sysclk :  STD_LOGIC;
    SIGNAL	vcc :  STD_LOGIC;
    SIGNAL	video :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
    SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
    SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
    SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
    SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
    SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
    SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(20 DOWNTO 0);
    SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(0 TO 7);

    -- DE1 additions
    
    signal PS2_clk    : std_logic;
    signal PS2_data   : std_logic;
    signal PS2_mclk   : std_logic;
    signal PS2_mdata  : std_logic;
    alias vsync_n     : std_logic is vga_vs;
    alias hsync_n     : std_logic is vga_hs;
    alias aud_data    : std_logic is aud_dacdat;
    alias aud_lrck    : std_logic is aud_daclrck;
    alias aud_bck     : std_logic is aud_bclk;
    alias sd_we_n     : std_logic is dram_we_n;
    alias sd_ras_n    : std_logic is dram_ras_n;
    alias sd_cas_n    : std_logic is dram_cas_n;
    alias TR_TxD      : std_logic is uart_txd;
    alias oled        : std_logic_vector(7 downto 0) is ledr(7 downto 0);
    alias osc_27      : std_logic is clock_27;
    -- end of DE1 additions
    
  begin

    --ocom <= "11111";
    --oseg7 <= "11111111";

    -- DE1 additions
    PS2_clk <= target_top.ps2_clk;
    PS2_data <= ps2_dat;
    -- end of DE1 additions

    b2v_inst : a1k100
    PORT MAP(sysclk => sysclk,
         shiftclk => SYNTHESIZED_WIRE_0,
         kb_clk => PS2_clk,
         kb_data => PS2_data,
         mouse_clk => PS2_mclk,
         mouse_data => PS2_mdata,
         fl_data => fl_dq,
         idedb => idedb,
         key => key,
         sdata => sdata,
         sw => sw,
         vsync => vsync_n,
         hsync => hsync_n,
         iauda => aud_data,
         lrclk => aud_lrck,
         bck => aud_bck,
         sd_we => sd_we_n,
         sd_ras => sd_ras_n,
         sd_cas => sd_cas_n,
         fl_ce => fl_ce_n_ALTERA_SYNTHESIZED,
         ide1cs => SYNTHESIZED_WIRE_1,
         ide2cs => SYNTHESIZED_WIRE_2,
         io_wr => SYNTHESIZED_WIRE_3,
         io_rd => SYNTHESIZED_WIRE_4,
         wrena => SYNTHESIZED_WIRE_5,
         TxD => TR_TxD,
         dqm => dqm,
         fl_addr => SYNTHESIZED_WIRE_6,
         idea => idea,
         LED => oled,
         sd_addr => sdaddr,
         sd_ba => ba,
         sd_cs => sd_cs,
         video => video);



    b2v_inst13 : clock
    PORT MAP(inclk0 => osc_27,
         c0 => sysclk,
         c1 => SYNTHESIZED_WIRE_0);



    b2v_inst4 : trex_mux
    PORT MAP(flce_in => fl_ce_n_ALTERA_SYNTHESIZED,
         ide1cs => SYNTHESIZED_WIRE_1,
         ide2cs => SYNTHESIZED_WIRE_2,
         io_wr => SYNTHESIZED_WIRE_3,
         io_rd => SYNTHESIZED_WIRE_4,
         wrena => SYNTHESIZED_WIRE_5,
         reset => key(3),
         cfreset => key(2),
         flrst => fl_rst_n,
         floe => fl_oe_n,
         fladdr => fl_addr,
         fladdr_in => SYNTHESIZED_WIRE_6,
         fldata => fl_dq,
         Idea => idea,
         Idedb => idedb,
         flwe => fl_we_n,
         cf_cs0 => nv_cs0_n,
         cf_cs1 => nv_cs1_n);

    sd_data <= sdata;
    sd_clk <= sysclk;
    sd_cke <= vcc;
    sd_udqm <= dqm(1);
    sd_ldqm <= dqm(0);
    sd_ba_0 <= ba(0);
    sd_ba_1 <= ba(1);
    sd_cs_n <= sd_cs(0);
    TVRES <= vcc;
    fl_ce_n <= fl_ce_n_ALTERA_SYNTHESIZED;
    blue(0 TO 3) <= video(15 DOWNTO 12);
    green(0 TO 3) <= video(10 DOWNTO 7);
    red(0 TO 3) <= video(4 DOWNTO 1);
    sd_addr(11 DOWNTO 0) <= sdaddr(11 DOWNTO 0);

    vcc <= '1';

  end block BLK_CPC6128;
  
  BLK_AV : block
    component I2C_AV_Config
      port
      (
        -- 	Host Side
        iCLK					: in std_logic;
        iRST_N				: in std_logic;
        --	I2C Side
        I2C_SCLK			: out std_logic;
        I2C_SDAT			: inout std_logic
      );
    end component I2C_AV_Config;
  begin
    av_init : I2C_AV_Config
      port map
      (
        --	Host Side
        iCLK							=> clock_50,
        iRST_N						=> clkrst_i.arst_n,
        
        --	I2C Side
        I2C_SCLK					=> I2C_SCLK,
        I2C_SDAT					=> I2C_SDAT
      );
  end block BLK_AV;

  BLK_CHASER : block
    signal pwmen      	: std_logic;
    signal chaseen    	: std_logic;
  begin
  
    pchaser: entity work.pwm_chaser 
      generic map(nleds  => 8, nbits => 8, period => 4, hold_time => 12)
      port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => clkrst_i.arst, fade => X"0F", ledout => ledg(7 downto 0));

    -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
    process(clock_50, clkrst_i.arst)
      variable pcount     : unsigned(9 downto 0);
      variable pwmen_r    : std_logic;
      variable ccount     : unsigned(18 downto 0);
      variable chaseen_r  : std_logic;
    begin
      pwmen <= pwmen_r;
      chaseen <= chaseen_r;
      if clkrst_i.arst = '1' then
        pcount := (others => '0');
        ccount := (others => '0');
      elsif rising_edge(clock_50) then
        pwmen_r := '0';
        if pcount = 0 then
          pwmen_r := '1';
        end if;
        chaseen_r := '0';
        if ccount = 0 then
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
