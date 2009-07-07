library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

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

	signal clk_i			  : std_logic_vector(0 to 3);
  signal init       	: std_logic := '1';
  signal reset_i     	: std_logic := '1';
	signal reset_n			: std_logic := '0';

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
  signal gp_i         : from_GP_t;
  signal gp_o         : to_GP_t;
  
	signal pll_inclk			: std_logic;
	
  signal bw_cvbs        : std_logic_vector(1 downto 0);
  signal gs_cvbs        : std_logic_vector(7 downto 0);
  signal snd_clk        : std_logic;
  signal snd_data       : std_logic_vector(15 downto 0);

	signal osc_inv					: std_logic;

	-- these might change
	alias ext_sb_data_in		: std_logic is gp_i(2);
	alias ext_sb_clk_in			: std_logic is gp_i(3);
	alias ext_sb_atn_in			: std_logic is gp_i(4);

	alias ext_sb_data_out		: std_logic is gp_o.d(5);
	alias ext_sb_clk_out		: std_logic is gp_o.d(6);
	alias ext_sb_atn_out		: std_logic is gp_o.d(7);
		
	alias ext_sb_data_oe		: std_logic is gp_o.oe(5);
	alias ext_sb_clk_oe			: std_logic is gp_o.oe(6);
	alias ext_sb_atn_oe			: std_logic is gp_o.oe(7);

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
  clk_i(2) <= '0';
  clk_i(3) <= '0';

	-- JAMMA signals are all active LOW
	inputs_i.jamma_n.coin_cnt <= (others => '1');
	inputs_i.jamma_n.service <= '1';
	inputs_i.jamma_n.tilt <= '1';
	inputs_i.jamma_n.test <= '1';
	inputs_i.jamma_n.coin <= (others => '1');
	GEN_JAMMA_P : for i in 1 to 2 generate
		inputs_i.jamma_n.p(i).start <= '1';
		inputs_i.jamma_n.p(i).up <= '1';
		inputs_i.jamma_n.p(i).down <= '1';
		inputs_i.jamma_n.p(i).left <= '1';
		inputs_i.jamma_n.p(i).right <= '1';
		inputs_i.jamma_n.p(i).button <= (others => '1');
	end generate GEN_JAMMA_P;
	
	rs_rts <= 'Z';
	ha11 <= 'Z';
	
  -- reset logic
  switches_i(0) <= not test_button;
  reset_i <= init or switches_i(0);
    
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
      c0      => clk_i(0),
      c1      => clk_i(1)
    );
  
  dac_inst : MAX1104_DAC                                  
    port map
    (
      CLK      => snd_clk,
      DATA     => snd_data(15 downto 8),
      RST      => reset_i,
      SPI_CS   => audio_spics,
      SPI_DIN  => audio_dout,
      SPI_DOUT => audio_din,
      SPI_SCLK => audio_sclk
    );

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

	-- only drive '0'
	ext_sb_data_out <= '0';
	ext_sb_clk_out <= '0';
	ext_sb_atn_out <= '0';

	-- unused gpio
	gp_o.oe(9 downto 8) <= (others => '0');
	gp_o.oe(4 downto 2) <= (others => '0');
	
	-- flash the led so we know it's alive
	process (clk_i(0), reset_i)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset_i = '1' then
			count := (others => '0');
		elsif rising_edge(clk_i(0)) then
			count := count + 1;
		end if;
		--led <= count(count'left);
	end process;

	-- C1541 activity led
	leds_o(0) <= not leds_s(0);
	
end SYN;
