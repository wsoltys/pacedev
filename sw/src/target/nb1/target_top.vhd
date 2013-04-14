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

  -- signals
  
  signal init       	: std_logic := '1';
  signal clkrst_i       : from_CLKRST_t;

  signal buttons_i    : from_BUTTONS_t;
  signal switches_i   : from_SWITCHES_t;
  signal leds_o       : to_LEDS_t;
  signal inputs_i     : from_INPUTS_t;
  signal flash_i      : from_FLASH_t;
  signal flash_o      : to_FLASH_t;
	signal sram_i			  : from_SRAM_t;
	signal sram_o			  : to_SRAM_t;	
	signal sdram_i      : from_SDRAM_t;
	--signal sdram_o      : to_SDRAM_t;
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal spi_i        : from_SPI_t;
  signal spi_o        : to_SPI_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;
  
	signal osc_inv					: std_logic;
	
begin

  BLK_CLOCKING : block
    signal pll_inclk			: std_logic;
  begin

    -- choose the PLL input clock
    GEN_PLL_INCLK_REF : if NB1_PLL_INCLK = NANOBOARD_PLL_INCLK_REF generate
      pll_inclk <= clk_ref;
    end generate GEN_PLL_INCLK_REF;
    GEN_PLL_INCLK_BRD : if NB1_PLL_INCLK = NANOBOARD_PLL_INCLK_BRD generate
      pll_inclk <= clk_brd;
    end generate GEN_PLL_INCLK_BRD;
    
    clkrst_i.clk_ref <= pll_inclk;

    GEN_PLL : if PACE_HAS_PLL generate
      pll_inst : entity work.pll
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
          c0      => clkrst_i.clk(0),
          c1      => clkrst_i.clk(1)
        );
    end generate GEN_PLL;
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clk_ref;
      clkrst_i.clk(1) <= clk_brd;
        
    end generate GEN_NO_PLL;

    -- unused clocks on Nanoboard
    clkrst_i.clk(2) <= '0';
    clkrst_i.clk(3) <= '0';

  end block BLK_CLOCKING;
  
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
	
  clkrst_i.arst <= init or not test_button;
  clkrst_i.arst_n <= not clkrst_i.arst;

  GEN_RESETS : for i in 0 to 3 generate
  begin
  
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

  -- buttons - active low
  buttons_i <= std_logic_vector(to_unsigned(0, buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(resize(unsigned(not sw), switches_i'length));
  -- leds
  leds <= leds_o(leds'range);

	-- inputs
	inputs_i.ps2_kclk <= ps2b_clk;
	inputs_i.ps2_kdat <= ps2b_data;
  inputs_i.ps2_mclk <= '0';
  inputs_i.ps2_mdat <= '0';

  -- no JAMMA support (yet)
  inputs_i.jamma_n.coin(1) <= '1';
  inputs_i.jamma_n.p(1).start <= '1';
  inputs_i.jamma_n.p(1).up <= '1';
  inputs_i.jamma_n.p(1).down <= '1';
  inputs_i.jamma_n.p(1).left <= '1';
  inputs_i.jamma_n.p(1).right <= '1';
  inputs_i.jamma_n.p(1).button <= (others => '1');
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
	
  BLK_FLASH : block
  begin
    flash_i.d <= (others => '0');
  end block BLK_FLASH;

  -- static memory
  BLK_SRAM : block
  begin
  
    GEN_SRAM : if PACE_HAS_SRAM generate
      ram_addr <= sram_o.a(ram_addr'range);
      sram_i.d <= std_logic_vector(resize(unsigned(ram0_data), sram_i.d'length));
      ram0_data <= sram_o.d(ram0_data'range) when (sram_o.cs = '1' and sram_o.we = '1') else 
        (others => 'Z');
      ram_cs <= not sram_o.cs;  -- active low
      ram0_oe <= not sram_o.oe; -- active low
      ram0_we <= not sram_o.we; -- active low
    end generate GEN_SRAM;
    
    GEN_NO_SRAM : if not PACE_HAS_SRAM generate
      ram_addr <= (others => 'Z');
      sram_i.d <= (others => '1');
      ram0_data <= (others => 'Z');
      ram_cs <= '1';
      ram0_oe <= '1';
      ram0_we <= '1';  
    end generate GEN_NO_SRAM;
    
  end block BLK_SRAM;

  GEN_NO_SDRAM : if true generate
    sdram_i.d <= (others => '0');
    sdram_i.ack <= '0';
  end generate GEN_NO_SDRAM;
  
  BLK_VIDEO : block
  begin

		video_i.clk <= clkrst_i.clk(1);	-- by convention
    video_i.clk_ena <= '1';
    
    vga_r <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-1);
    vga_g <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-1);
    vga_b <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-1);
    vga_hsyn <= video_o.hsync;
    vga_vsyn <= video_o.vsync;

  end block BLK_VIDEO;

  BLK_AUDIO : block

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

  begin

    dac_inst : MAX1104_DAC                                  
      port map
      (
        CLK      => audio_o.clk,
        DATA     => audio_o.ldata(audio_o.ldata'left downto audio_o.ldata'left-7),
        RST      => clkrst_i.arst,
        SPI_CS   => audio_spics,
        SPI_DIN  => audio_dout,
        SPI_DOUT => audio_din,
        SPI_SCLK => audio_sclk
      );

  end block BLK_AUDIO;

  BLK_SPI : block
  begin
    GEN_SPI : if PACE_HAS_SPI generate
      spi_clk <= spi_o.clk;
      spi_dout <= spi_o.dout;
      spi_mode <= spi_o.mode;
      spi_sel <= spi_o.sel;
      spi_i.din <= spi_din;
    end generate GEN_SPI;

    GEN_NO_SPI : if not PACE_HAS_SPI generate
      spi_clk <= '0';
      spi_dout <= '0';
      spi_mode <= '0';
      spi_sel <= '0';
      spi_i.din <= '0';
    end generate GEN_NO_SPI;

  end block BLK_SPI;
  
  BLK_SERIAL : block
  begin

    GEN_SERIAL : if PACE_HAS_SERIAL generate
      rs_tx <= ser_o.txd;
      ser_i.rxd <= rs_rx;
    end generate GEN_SERIAL;
    
    GEN_NO_SERIAL : if not PACE_HAS_SERIAL generate
      rs_tx <='0';
      ser_i.rxd <= '0';
    end generate GEN_NO_SERIAL;

    rs_rts <= 'Z';
    
  end block BLK_SERIAL;

  -- component instantiation

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
     	sdram_o           => open,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i             => spi_i,
      spi_o             => spi_o,
  
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

end SYN;

