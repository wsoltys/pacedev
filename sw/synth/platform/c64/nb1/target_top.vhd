library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
    -- clocks and reset
    clk_brd     : in    std_logic;                           
    clk_ref     : in    std_logic;                           
    test_button : in    std_logic;                           

    -- inputs
    ps2b_clk    : inout std_logic;                           
    ps2b_data   : inout std_logic;                           
    sw          : in    std_logic_vector(7 downto 0);        

    -- external RAM
    ram_addr    : out   std_logic_vector(23 downto 0);       
    ram0_data   : inout std_logic_vector(7 downto 0);        
    ram_cs      : out   std_logic;                           
    ram0_oe     : out   std_logic;                           
    ram0_we     : out   std_logic;                           

    -- VGA video
    vga_r       : out   std_logic_vector(1 downto 0);        
    vga_g       : out   std_logic_vector(1 downto 0);        
    vga_b       : out   std_logic_vector(1 downto 0);        
    vga_hsyn    : out   std_logic;                           
    vga_vsyn    : out   std_logic;                            

    -- composite video
    hb5         : out   std_logic;       -- BW_CVBS(1)
    hb3         : out   std_logic;       -- BW_CVBS(0)

    hb7         : out   std_logic;       -- GS_CVBS(7)
    hb9         : out   std_logic;       -- GS_CVBS(6)
    hb11        : out   std_logic;       -- GS_CVBS(5)
    hb13        : out   std_logic;       -- GS_CVBS(4)
    hb15        : out   std_logic;       -- GS_CVBS(3)
    hb17        : out   std_logic;       -- GS_CVBS(2)
    hb19        : out   std_logic;       -- GS_CVBS(1)
    hb18        : out   std_logic;       -- GS_CVBS(0)

    -- sound
    audio_din   : out   std_logic;                           
    audio_dout  : in    std_logic;                           
    audio_sclk  : out   std_logic;                           
    audio_spics : out   std_logic;                           

    -- spi
    spi_clk     : out   std_logic;                           
    spi_mode    : out   std_logic;                           
    spi_sel     : out   std_logic;                           
    spi_din     : in    std_logic;                           
    spi_dout    : out   std_logic;                           

    -- serial
    rs_tx       : out   std_logic;                           
    rs_rx       : in    std_logic;                           
    rs_cts      : in    std_logic;                           
    rs_rts      : out   std_logic;                           

		-- special mod for xternal xtal
		ha3					: in		std_logic;
		ha7					: out		std_logic;
		ha11				: out		std_logic;
		
    -- debug
    leds        : out   std_logic_vector(7 downto 0)
  );
end target_top;


architecture SYN of target_top is

	-- components
	
	-- so we don't have to include the pll component in the project
	-- if there is no 'pace pll'
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
			inclk0							: in std_logic  := '0';
			c0		    					: out std_logic ;
			c1		    					: out std_logic 
		);
	end component;

  component MAX1104_DAC                                     
    port
    (
      CLK      : in  STD_LOGIC;                            
      DATA     : in  STD_LOGIC_VECTOR(7 downto 0);         
      RST      : in  STD_LOGIC;                            
      SPI_CS   : out STD_LOGIC;                            
      SPI_DIN  : in  STD_LOGIC;                            
      SPI_DOUT : out STD_LOGIC;                            
      SPI_SCLK : out STD_LOGIC                             
    );
  end component;

  -- signals
  
  signal clk            : std_logic_vector(0 to 3);
	signal pll_inclk			: std_logic;
	
	-- SRAM active-high signals
	signal sram_i				  : from_SRAM_t;
	signal sram_o				  : to_SRAM_t;
	
  signal test_button_p  : std_logic;
  signal init           : std_logic;
  signal reset          : std_logic;
  signal bw_cvbs        : std_logic_vector(1 downto 0);
  signal gs_cvbs        : std_logic_vector(7 downto 0);
  signal snd_clk        : std_logic;
  signal snd_data       : std_logic_vector(15 downto 0);

	signal jamma_s				: JAMMAInputsType;

  -- spi signals
  signal spi_clk_s        : std_logic;
  signal spi_dout_s       : std_logic;
  signal spi_mode_s       : std_logic;
  signal spi_sel_s        : std_logic;
  
	signal osc_inv					: std_logic;

	signal gpio_i						: std_logic_vector(9 downto 2);
	signal gpio_o						: std_logic_vector(gpio_i'range);
	signal gpio_oe					: std_logic_vector(gpio_i'range);
	
	-- these might change
	alias ext_sb_data_in		: std_logic is gpio_i(2);
	alias ext_sb_clk_in			: std_logic is gpio_i(3);
	alias ext_sb_atn_in			: std_logic is gpio_i(4);

	alias ext_sb_data_out		: std_logic is gpio_o(5);
	alias ext_sb_clk_out		: std_logic is gpio_o(6);
	alias ext_sb_atn_out		: std_logic is gpio_o(7);
		
	alias ext_sb_data_oe		: std_logic is gpio_oe(5);
	alias ext_sb_clk_oe			: std_logic is gpio_oe(6);
	alias ext_sb_atn_oe			: std_logic is gpio_oe(7);

	signal d_cf_i						: std_logic_vector(15 downto 0);
	signal d_cf_o						: std_logic_vector(15 downto 0);
	signal d_cf_oe					: std_logic;
	
	signal leds_s				: std_logic_vector(7 downto 0);
			
begin

	-- choose the PLL input clock
	GEN_PLL_INCLK_REF : if NB1_PLL_INCLK = NANOBOARD_PLL_INCLK_REF generate
		pll_inclk <= clk_ref;
	end generate GEN_PLL_INCLK_REF;
	GEN_PLL_INCLK_BRD : if NB1_PLL_INCLK = NANOBOARD_PLL_INCLK_BRD generate
		pll_inclk <= clk_brd;
	end generate GEN_PLL_INCLK_BRD;
	
  -- unused clocks on Nanoboard
  clk(2) <= '0';
  clk(3) <= '0';

	-- JAMMA signals are all active LOW
	jamma_s.coin_cnt <= (others => '1');
	jamma_s.service <= '1';
	jamma_s.tilt <= '1';
	jamma_s.test <= '1';
	jamma_s.coin <= (others => '1');
	GEN_JAMMA_P : for i in 1 to 2 generate
		jamma_s.p(i).start <= '1';
		jamma_s.p(i).up <= '1';
		jamma_s.p(i).down <= '1';
		jamma_s.p(i).left <= '1';
		jamma_s.p(i).right <= '1';
		jamma_s.p(i).button <= (others => '1');
	end generate GEN_JAMMA_P;
	
  spi_clk <= spi_clk_s;
  spi_dout <= spi_dout_s;
  spi_mode <= spi_mode_s;
  spi_sel <= spi_sel_s;
  
	rs_rts <= 'Z';
	ha11 <= 'Z';
	
  -- reset logic
  test_button_p <= not test_button;
  reset <= init or test_button_p;
    
	-- attach sram
	ram_addr <= sram_o.a(ram_addr'range);
	sram_i.d <= EXT(ram0_data, sram_i.d'length);
	ram0_data <= sram_o.d(ram0_data'range) when sram_o.cs = '1' and sram_o.we = '1' else (others => 'Z');
  ram_cs <= not sram_o.cs;  -- active low
  ram0_oe <= not sram_o.oe; -- active low
  ram0_we <= not sram_o.we; -- active low

  -- black & white composite output
  hb5 <= bw_cvbs(1);
  hb3 <= bw_cvbs(0);

  -- grey-scale composite output
  hb7  <= gs_cvbs(7);
  hb9  <= gs_cvbs(6);
  hb11 <= gs_cvbs(5);
  hb13 <= gs_cvbs(4);
  hb15 <= gs_cvbs(3);
  hb17 <= gs_cvbs(2);
  hb19 <= gs_cvbs(1);
  hb18 <= gs_cvbs(0);
  
	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clk_ref)
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clk_ref) then
			if count = X"FF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;
	
	-- special mod for external xtal
	osc_inv <= not ha3;
	ha7 <= osc_inv;
	
  pll_inst : pll
    generic map
    (
      -- INCLK0
      INCLK0_INPUT_FREQUENCY  => NB1_INCLK0_INPUT_FREQUENCY,

      -- CLK0
      CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
      CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
  
      -- CLK1
      CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
      CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
    )
    port map
    (
      inclk0  => pll_inclk,
      c0      => clk(0),
      c1      => clk(1)
    );
  
  dac_inst : MAX1104_DAC                                  
    port map
    (
      CLK      => snd_clk,
      DATA     => snd_data(15 downto 8),
      RST      => reset,
      SPI_CS   => audio_spics,
      SPI_DIN  => audio_dout,
      SPI_DOUT => audio_din,
      SPI_SCLK => audio_sclk
    );

	PACE_INST : entity work.PACE
	  port map
	  (
	     -- clocks and resets
			clk								=> clk,
			test_button      	=> test_button_p,
	    reset            	=> reset,

	    -- game I/O
	    ps2clk           	=> ps2b_clk,
	    ps2data          	=> ps2b_data,
	    dip              	=> (others => '0'),
			jamma							=> jamma_s,
			
	    -- external RAM
	    sram_addr        	=> sram_addr_s,
	    sram_dq_i        	=> sram_dq_i,
	    sram_dq_o        	=> sram_dq_o,
	    sram_cs_n        	=> sram_cs_n,
	    sram_oe_n        	=> noe_ns,
	    sram_we_n        	=> sram_we_n,

	    -- VGA video
	    red              	=> red_s,
	    green            	=> green_s,
	    blue             	=> blue_s,
	    hsync            	=> ba22,
	    vsync            	=> nromsdis,

	    -- composite video
	    BW_CVBS          	=> open,
	    GS_CVBS          	=> open,

	    -- sound
	    snd_clk          	=> open,
	    snd_data_l       	=> open,
	    snd_data_r       	=> open,

	    -- SPI (flash)
	    spi_clk          	=> open,
	    spi_mode         	=> open,
	    spi_sel          	=> open,
	    spi_din          	=> '0',
	    spi_dout         	=> open,

	    -- serial
	    ser_tx           	=> gat_txd,
	    ser_rx           	=> gat_rxd,

			-- SB (IEC) port
			ext_sb_data_in		=> ext_sb_data_in,
			ext_sb_data_oe		=> ext_sb_data_oe,
			ext_sb_clk_in			=> ext_sb_clk_in,
			ext_sb_clk_oe			=> ext_sb_clk_oe,
			ext_sb_atn_in			=> ext_sb_atn_in,
			ext_sb_atn_oe			=> ext_sb_atn_oe,

			-- generic drive mechanism i/o ports
			
			-- SDRAM
			mech_in(0)							=> clk(1),						-- clk_nios
			mech_in(31 downto 1)		=> (others => '0'),
			mech_out(12 downto 0)		=> a_dr2,
			mech_out(14 downto 13)	=> ba_dr2,
			mech_out(15)						=> ncas_dr2,
			mech_out(16)						=> cke_dr2,
			mech_out(17)						=> ncs_dr2,
			mech_out(21 downto 18)	=> dqm_dr2,
			mech_out(22)						=> nras_dr2,
			mech_out(23)						=> nwe_dr2,
			mech_io(31 downto 0)		=> d_dr2,

			-- OCIDE controller
			mech_in(32)							=> iordy0_cf,
			mech_in(33)							=> rdy_irq_cf,
			mech_in(34)							=> cd_cf,
			mech_out(34 downto 32)	=> a_cf,
			mech_out(35)						=> nce_cf(2),
			mech_out(36)						=> nce_cf(1),
			mech_in(50 downto 35)		=> d_cf_i,
			mech_out(52 downto 37)	=> d_cf_o,
			mech_out(53)						=> d_cf_oe,
			mech_out(54)						=> nior0_cf,
			mech_out(55)						=> niow0_cf,
			mech_out(56)						=> non_cf,
			mech_out(57)						=> reset_cf,
			mech_out(58)						=> ndmack_cf,
			mech_in(51)							=> dmarq_cf,
			
	    -- debug
	    leds             				=> leds_s
	  );

	-- hook up sram signals
	ncs_s <= sram_cs_n;
	nwe_s <= sram_we_n;

	-- only drive '0'
	ext_sb_data_out <= '0';
	ext_sb_clk_out <= '0';
	ext_sb_atn_out <= '0';

	-- unused gpio
	gpio_oe(9 downto 8) <= (others => '0');
	gpio_oe(4 downto 2) <= (others => '0');
	
	-- flash the led so we know it's alive
	process (clk(0), reset)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk(0)) then
			count := count + 1;
		end if;
		--led <= count(count'left);
	end process;

	-- C1541 activity led
	led <= not leds_s(0);
	
end SYN;
