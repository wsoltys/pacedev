library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
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
	
  -- component instantiation

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

  pace_inst : entity work.pace                                            
    port map
    (
      -- clocks and resets
      clk                => clk,
      test_button      	=> test_button_p,
      reset            	=> reset,
  
      -- game I/O
      ps2clk           	=> ps2b_clk,
      ps2data          	=> ps2b_data,
      dip              	=> sw,
  		jamma								=> jamma_s,

      -- external RAM
      sram_i            => sram_i,
      sram_o            => sram_o,
  
      -- VGA video
      red(9 downto 8)		=> vga_r,
      green(9 downto 8)	=> vga_g,
      blue(9 downto 8)		=> vga_b,
      hsync            	=> vga_hsyn,
      vsync            	=> vga_vsyn,
  
      -- composite video
      BW_CVBS          	=> bw_cvbs,
      GS_CVBS          	=> gs_cvbs,
  
      -- sound
      snd_clk          	=> snd_clk,
      snd_data_l       	=> snd_data,
      snd_data_r       	=> open,
  
      -- SPI (flash)
      spi_clk          	=> spi_clk_s,
      spi_mode         	=> spi_mode_s,
      spi_sel          	=> spi_sel_s,
      spi_din          	=> spi_din,
      spi_dout         	=> spi_dout_s,
  
      -- serial
      ser_tx           	=> rs_tx,
      ser_rx           	=> rs_rx,
  
      -- debug
      leds             	=> leds
    );
    
end SYN;

