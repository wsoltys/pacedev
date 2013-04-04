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

entity target_top is
	port
	(
		clock		        :	 IN STD_LOGIC;

    --
    -- MVS connector
    --
    
    clk_24M         : out std_logic;
    clk_12M         : out std_logic;
    clk_8M          : out std_logic;
    clk_4MB         : out std_logic;
    reset           : out std_logic;
    
    -- C ROM, S ROM & LO ROM address/data bus???
    p               : out std_logic_vector(23 downto 0);
    -- C ROM address latch
    pck1b           : out std_logic;
    -- S ROM address latch
    pck2b           : out std_logic;
    
    -- C ROM A(4) line, data bus
    ca4             : out std_logic;
    cr              : inout std_logic_vector(31 downto 0);
    
    -- S ROM A(3) line, data bus
    sa3_2h1         : out std_logic;
    fix             : inout std_logic_vector(7 downto 0);
    
    -- ????
    sdrd            : inout std_logic_vector(1 downto 0);

    sdrom
    sdmrd
    
    -- Z80 address, data bus
    sda             : out std_logic_vector(15 downto 0);
    sdd             : inout std_logic_vector(7 downto 0);
    
    -- tied to SYSTEMB on 1-slot boards
    -- goes LOW when slot is in use
    slotcs_n        : in std_logic;
    
    -- 68K address bus
    a               : out std_logic_vector(23 downto 1);
    
    -- ??
    X68kclkb        : out std_logic;
    
    -- add 1 cycle delay for P1 ROM reads
    romwait_n       : in std_logic;
    -- add 0-3 cycle delays for P2 ROM reads
    pwait_n         : in std_logic_vector(1 downto 0);

    pdtact          : 

    -- $000000-$0FFFFF P1 ROM read
    romoe_n         : out std_logic;
    
    -- ADPCM-B ROM data/address bus
    sdpad           : inout std_logic_vector(7 downto 0);
    -- ADPCM-A ROM data/address bus
    sdrad           : inout std_logic_vector(7 downto 0);
    -- ??
    sdroe_n         : out std_logic;
    -- ??
    sdrmpx          : 
    --
    sdra            : out std_logic_vector(23 downto 20);
    sdra            : out std_logic_vector(9 downto 8);
    -- $200000-$2FFFFF any access
    portadrs_n      : out std_logic;
    -- $200000-$2FFFFF odd byte write
    portwel_n       : out std_logic;
    -- $200000-$2FFFFF even byte write
    portweu_n       : out std_logic;
    -- $200000-$2FFFFF odd byte read
    portoel_n       : out std_logic;
    -- $200000-$2FFFFF even byte read
    portoeu_n       : out std_logic;
    
    
    
    
		--ddr_rqz		      :	 IN STD_LOGIC;
		ddr_ba		      :	 OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		--ddr_ck		      :	 OUT STD_LOGIC;
		--ddr_ck_n		    :	 OUT STD_LOGIC;
		ddr_cke		      :	 OUT STD_LOGIC;
		ddr_cs_n		    :	 OUT STD_LOGIC;
		ddr_dm		      :	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		ddr_ras_n		    :	 OUT STD_LOGIC;
		ddr_cas_n		    :	 OUT STD_LOGIC;
		ddr_we_n		    :	 OUT STD_LOGIC;
		ddr_reset_n		  :	 OUT STD_LOGIC;
		ddr_odt		      :	 OUT STD_LOGIC;
		ddr_a		        :	 OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
		--ddr_dq		      :	 INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		--ddr_dqs		      :	 INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		--ddr_dqs_n		    :	 INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- SPI
		spi_MISO		    :	 IN STD_LOGIC;
		spi_MOSI		    :	 OUT STD_LOGIC;
		spi_CLK		      :	 OUT STD_LOGIC;
		spi_CS_n		    :	 OUT STD_LOGIC;

		i2c_sda		      :	 INOUT STD_LOGIC;
		i2c_scl		      :	 INOUT STD_LOGIC
	);
end entity target_top;

architecture SYN of target_top is

  component pll is
    port
    (
      refclk        : in std_logic;
      rst           : in std_logic;
      outclk_0      : out std_logic;
      locked        : out std_logic
    );
  end component pll;
  
	component pll2 is
		port 
    (
			refclk        : in  std_logic := 'X'; -- clk
			rst           : in  std_logic := 'X'; -- reset
			outclk_0      : out std_logic;        -- clk
			locked        : out std_logic         -- export
		);
	end component pll2;

  component cmp_lvds_even is
    port 
    (
      tx_in         : in std_logic_vector(27 downto 0);
      tx_inclock    : in std_logic;
      tx_out        : out std_logic_vector(3 downto 0)
    );
  end component cmp_lvds_even;
  
  component lvds_stream is
    port
    (
      vs            : in std_logic;
      hs            : in std_logic;
      de            : in std_logic;
      lvds_in       : in std_logic_vector(23 downto 0);
      lvds_out      : out std_logic_vector(27 downto 0)
    );
  end component lvds_stream;
  
  signal dvi_clk        : std_logic;
  signal dvi_out        : std_logic_vector(23 downto 0);
  signal lvds_out       : std_logic_vector(27 downto 0);
  signal hs             : std_logic;
  signal vs             : std_logic;
  signal de             : std_logic;
  
begin

  pll_inst : pll
    port map
    (
      refclk      => clock,
      rst         => '0',
      outclk_0    => dvi_clk,
      locked      => open
    );

  pll2_inst : pll2
    port map
    (
      refclk      => dvi_clk,
      rst         => '0',
      outclk_0    => lvds_even_clk,
      locked      => open
    );

  lvds_stream_inst : lvds_stream
    port map
    (
      vs          => vs,
      hs          => hs,
      de          => de,
      lvds_in     => dvi_out,
      lvds_out    => lvds_out
    );

  lvds_even_inst : cmp_lvds_even
    port map
    (
      tx_in       => lvds_out,
      tx_inclock  => dvi_clk,
      tx_out      => lvds_even
    );
    
  hdmi_reset <= '1';
  hdmi_cs_n <= '0';
  lcd_enable <= '1';
  video_in_reset <= '1';
  
  comp_scl <= 'Z';
  comp_sda <= 'Z';
  i2c_scl <= 'Z';
  i2c_sda <= 'Z';
  
  --
  -- PACE
  --
  BLK_PACE : block
  
    alias clk_50M   : std_logic is clock;
    alias clk_72M   : std_logic is dvi_clk;
    
    signal init     : std_logic := '1';
    
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
  
    reset_gen : process (clk_50M)
      variable reset_cnt : integer := 999999;
    begin
      if rising_edge(clk_50M) then
        if reset_cnt > 0 then
          init <= '1';
          reset_cnt := reset_cnt - 1;
        else
          init <= '0';
        end if;
      end if;
    end process reset_gen;

    -- assign PACE clocks
    clkrst_i.clk_ref <= clk_50M;
    clkrst_i.clk(0) <= clk_50M;
    clkrst_i.clk(1) <= clk_72M;

    -- async resets
    clkrst_i.arst <= init;
    clkrst_i.arst_n <= not clkrst_i.arst;

    -- sync resets
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

    buttons_i <= (others => '0');
    switches_i <= (others => '0');

    BLK_JAMMA : block
    begin
      GEN_PLAYER: for i in 1 to 2 generate
      begin
        inputs_i.jamma_n.coin(i) <= '1';
        inputs_i.jamma_n.p(i).start <= '1';
        inputs_i.jamma_n.p(i).up <= '1';
        inputs_i.jamma_n.p(i).down <= '1';
        inputs_i.jamma_n.p(i).left <= '1';
        inputs_i.jamma_n.p(i).right <= '1';
        GEN_BUTTON: for j in 1 to 5 generate
          inputs_i.jamma_n.p(i).button(j) <= '1';
        end generate GEN_BUTTON;
      end generate GEN_PLAYER;
      inputs_i.jamma_n.coin_cnt <= (others => '1');
      inputs_i.jamma_n.service <= '1';
      inputs_i.jamma_n.tilt <= '1';
      inputs_i.jamma_n.test <= '1';
    end block BLK_JAMMA;
    
    video_i.clk <= clkrst_i.clk(1);
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);

    -- hook up video stream
    dvi_out(23 downto 16) <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-7);
    dvi_out(15 downto 8) <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-7);
    dvi_out(7 downto 0) <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-7);
    hs <= video_o.hsync;
    vs <= video_o.vsync;
    --de <= video_o.de;
    de <= not (video_o.hblank or video_o.vblank);
    
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
    GEN_FLASH : if ROCKY_EMULATE_FLASH generate
      flash_inst : entity work.sprom
        generic map
        (
          init_file     => ROCKY_EMULATED_FLASH_INIT_FILE,
          --numwords_a    => 2**ROCKY_EMULATED_FLASH_WIDTH_AD,
          widthad_a			=> ROCKY_EMULATED_FLASH_WIDTH_AD,
          width_a				=> ROCKY_EMULATED_FLASH_WIDTH
        )
        port map
        (
          clock		      => clkrst_i.clk(0),
          address		    => flash_o.a(ROCKY_EMULATED_FLASH_WIDTH_AD-1 downto 0),
          q		          => flash_i.d(ROCKY_EMULATED_FLASH_WIDTH-1 downto 0)
        );
      flash_i.d(flash_i.d'left downto ROCKY_EMULATED_FLASH_WIDTH) <= (others => '0');
    end generate GEN_FLASH;
    
    -- emulate some SRAM
    GEN_SRAM : if ROCKY_EMULATE_SRAM generate
      signal wren : std_logic := '0';
    begin
      wren <= sram_o.cs and sram_o.we;
      sram_inst : entity work.spram
        generic map
        (
          --numwords_a		=> 2**ROCKY_EMULATED_SRAM_WIDTH_AD,
          widthad_a			=> ROCKY_EMULATED_SRAM_WIDTH_AD,
          width_a				=> ROCKY_EMULATED_SRAM_WIDTH
        )
        port map
        (
          clock		      => clkrst_i.clk(0),
          address		    => sram_o.a(ROCKY_EMULATED_SRAM_WIDTH_AD-1 downto 0),
          data		      => sram_o.d(ROCKY_EMULATED_SRAM_WIDTH-1 downto 0),
          wren		      => wren,
          q		          => sram_i.d(ROCKY_EMULATED_SRAM_WIDTH-1 downto 0)
        );
      sram_i.d(sram_i.d'left downto ROCKY_EMULATED_SRAM_WIDTH) <= (others => '0');
    end generate GEN_SRAM;

  end block BLK_PACE;
    
end architecture SYN;
