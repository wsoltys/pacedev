library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.maple_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
generic
  (
    BOARD_REV             : std_logic_vector (7 downto 0) := X"A2"
  );
port
  (
    -- clocking
    clock0            : in std_logic;
    clock8            : in std_logic;
                      
    -- ethernet       
    COL_enet          : in std_logic;
    CRS_enet          : in std_logic;
    RXCLK_enet        : in std_logic;
    RXD_enet          : in std_logic_vector(3 downto 0);
    RXDV_enet         : in std_logic;
    RXER_enet         : in std_logic;
    TXCLK_enet        : in std_logic;
    MDIO_enet         : inout std_logic;
    MDC_enet          : out std_logic;
    TXD_enet          : out std_logic_vector(3 downto 0);
    TXEN_enet         : out std_logic;
    TXER_enet         : out std_logic;
    RESET_enet        : out std_logic;
    RIP_enet          : in std_logic;
    MDINT_enet        : in std_logic;
                      
    -- PIO            
    mac_addr          : inout std_logic;
    sw2_1             : in std_logic;
    led               : out std_logic;
    ext_enable        : in std_logic;
                      
    -- sdram 1 MEB
    clk_dr1           : out std_logic;
    a_dr1             : out std_logic_vector(12 downto 0);
    ba_dr1            : out std_logic_vector(1 downto 0);
    ncas_dr1          : out std_logic;
    cke_dr1           : out std_logic;
    ncs_dr1           : out std_logic;
    d_dr1             : inout std_logic_vector(31 downto 0);
    dqm_dr1           : out std_logic_vector(1 downto 0);
    nras_dr1          : out std_logic;
    nwe_dr1           : out std_logic;
    
    -- sdram 2 NIOS
    clk_dr2           : out std_logic;
    a_dr2             : out std_logic_vector(12 downto 0);
    ba_dr2            : out std_logic_vector(1 downto 0);
    ncas_dr2          : out std_logic;
    cke_dr2           : out std_logic;
    ncs_dr2           : out std_logic;
    d_dr2             : inout std_logic_vector(31 downto 0);
    dqm_dr2           : out std_logic_vector(3 downto 0);
    nras_dr2          : out std_logic;
    nwe_dr2           : out std_logic;

    -- compact flash
    iordy0_cf         : in std_logic;
    rdy_irq_cf        : in std_logic;
    cd_cf             : in std_logic;
    a_cf              : out std_logic_vector(2 downto 0);
    nce_cf            : out std_logic_vector(2 downto 1);
    d_cf              : inout std_logic_vector(15 downto 0);
    nior0_cf          : out std_logic;
    niow0_cf          : out std_logic;
    non_cf            : out std_logic;
    reset_cf          : out std_logic;
    ndmack_cf         : out std_logic;
    dmarq_cf          : in std_logic;

		-- GAT serial port
		gat_txd						  : out std_logic;
		gat_rxd						  : in std_logic;
		
		-- I2C
		clk_ee							  : inout std_logic;
		data_ee							  : inout std_logic;
		
    -- System ROMS
		nromsoe					  : out std_logic;
		
		-- MEB
    bd                : inout std_logic_vector(31 downto 0);
    ba25              : out std_logic;
    ba24              : out std_logic;
    ba23              : in std_logic;
    ba22              : out std_logic;
    ba21              : in std_logic;
    ba20              : out std_logic;
    ba19              : in std_logic;
    ba18              : in std_logic;
    ba17              : in std_logic;
    ba16              : inout std_logic;
    ba15              : in std_logic;
    ba14              : inout std_logic;
    ba13              : in std_logic;
    ba12              : in std_logic;
    ba11              : in std_logic;
    ba10              : in std_logic;
    ba9               : out std_logic;
    ba8               : in std_logic;
    ba7               : in std_logic;
    ba6               : out std_logic;
    ba5               : in std_logic;
    ba4               : out std_logic;
    ba3               : out std_logic;
    ba2               : in std_logic;
		nmebwait				  : out std_logic; 
		nmebint					  : in std_logic;
		nbwr						  : in std_logic;
		nreset2					  : in std_logic;
		nromsdis				  : out std_logic;
		butres					  : in std_logic;
		nromgdis				  : out std_logic;
		nbrd						  : in std_logic;
		nbcs2						  : in std_logic;
		nbcs4						  : in std_logic;
		nbcs0						  : in std_logic;	
		
		-- MEMORY
    ba_ns							: out std_logic_vector(19 downto 0);
    bd_ns							: inout std_logic_vector(31 downto 0);
    nwe_s             : out std_logic;    -- sram only
    ncs_s             : out std_logic;    -- sram only
    nce_n             : out std_logic;    -- eeprom only
    noe_ns            : out std_logic
  );
end target_top;

architecture SYN of target_top is

  alias clk_24M       : std_logic is clock8;
	alias ps2_mclk      : std_logic is bd(14);
	alias ps2_mdat      : std_logic is bd(10);
  alias sd_cmd        : std_logic is bd(1);
  alias sd_dat3       : std_logic is bd(9);
  alias sd_clk        : std_logic is bd(15);
  alias sd_dat        : std_logic is bd(7);

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
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  
	-- maple/dreamcast controller interface
	signal maple_sense	: std_logic;
	signal maple_oe			: std_logic;
	signal mpj				  : work.maple_pkg.joystate_type;

	-- gamecube controller interface
	signal gcj					: work.gamecube_pkg.joystate_type;

	signal bd_out				: std_logic_vector(31 downto 0);
		
	signal gpio_i				: std_logic_vector(9 downto 2);
	signal gpio_o				: std_logic_vector(gpio_i'range);
	signal gpio_oe			: std_logic_vector(gpio_i'range);
	
begin

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
        inclk0							: in std_logic  := '0';
        c0		    					: out std_logic ;
        c1		    					: out std_logic 
      );
    end component;

  begin

    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll
        generic map
        (
          -- INCLK0
          INCLK0_INPUT_FREQUENCY  => 41667,

          -- CLK0
          CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
          CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
      
          -- CLK1
          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
        )
        port map
        (
          inclk0  => clock0,
          c0      => clk_i(0),
          c1      => clk_i(1)
        );
    
    end generate GEN_PLL;
	
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clk_i(0) <= clock0;
      clk_i(1) <= clock8;
        
    end generate GEN_NO_PLL;
	
  end block BLK_CLOCKING;

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock0)
		variable count : std_logic_vector (7 downto 0) := X"00";
	begin
		if rising_edge(clock0) then
			if count = X"FF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

	-- the dipswitch must be "down" for the board to run
	-- this is akin to an "ON" switch flicked down to turn on
	reset_i <= init or sw2_1;
		
  -- unused clocks on P2
  clk_i(2) <= clock8;
  clk_i(3) <= '0';

  -- buttons - active low
  buttons_i <= EXT("0", buttons_i'length);
  -- switches - up = high
  switches_i <= EXT("0", switches_i'length);
  -- leds
  -- (none)
  
	-- inputs
	inputs_i.ps2_kclk <= ba16;
	inputs_i.ps2_kdat <= ba14;
  inputs_i.ps2_mclk <= bd(14);
  inputs_i.ps2_mdat <= bd(10);

	GEN_MAPLE : if PACE_JAMMA = PACE_JAMMA_MAPLE generate
  end generate GEN_MAPLE;

	GEN_GAMECUBE : if PACE_JAMMA = PACE_JAMMA_NGC generate
	
		GC_JOY: gamecube_joy
			generic map
			( 
				MHZ => 24
			)
  		port map
		  (
  			clk 				=> clk_24M,
				reset 			=> reset_i,
				oe 					=> open,
				d 					=> bd(4),
				joystate 		=> gcj
			);

		-- map gamecube controller to jamma inputs
		inputs_i.jamma_n.coin(1) <= not gcj.l;
		inputs_i.jamma_n.p(1).start <= not gcj.start;
		inputs_i.jamma_n.p(1).up <= not (gcj.d_up or (gcj.jy(7) and gcj.jy(6)));
		inputs_i.jamma_n.p(1).down <= not (gcj.d_down or not (gcj.jy(7) or gcj.jy(6)));
		inputs_i.jamma_n.p(1).left <= not (gcj.d_left or not (gcj.jx(7) or gcj.jx(6)));
		inputs_i.jamma_n.p(1).right <= not (gcj.d_right or (gcj.jx(7) and gcj.jx(6)));
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

  BLK_FLASH : block
  begin
    flash_i.d <= (others => '0');
  end block BLK_FLASH;

  -- static memory
  BLK_SRAM : block
  begin
  
    GEN_SRAM : if PACE_HAS_SRAM generate
      ba_ns <= sram_o.a(ba_ns'range);
      sram_i.d <= EXT(bd_ns, sram_i.d'length);
      bd_ns <= sram_o.d(bd_ns'range) when (sram_o.cs = '1' and sram_o.we = '1') else (others => 'Z');
      ncs_s <= not sram_o.cs;
      noe_ns <= not sram_o.oe;
      nwe_s <= not sram_o.we;
    end generate GEN_SRAM;
    
    GEN_NO_SRAM : if not PACE_HAS_SRAM generate
      ba_ns <= (others => 'Z');
      sram_i.d <= (others => '1');
      bd_ns <= (others => 'Z');
      ncs_s <= '1';
      noe_ns <= '1';
      nwe_s <= '1';  
    end generate GEN_NO_SRAM;
    
  end block BLK_SRAM;

  BLK_SDRAM : block
  begin
    GEN_NO_SDRAM : if not PACE_HAS_SDRAM generate

      clk_dr1 <= '1';
      a_dr1 <= (others => 'Z');
      ba_dr1 <= (others => 'Z');
      ncas_dr1 <= 'Z';
      cke_dr1 <= 'Z';
      ncs_dr1 <= 'Z';
      d_dr1 <= (others => 'Z');
      dqm_dr1 <= (others => 'Z');
      nras_dr1 <= 'Z';
      nwe_dr1 <= '1';

      clk_dr2 <= '1';
      a_dr2 <= (others => 'Z');
      ba_dr2 <= (others => 'Z');
      ncas_dr2 <= 'Z';
      cke_dr2 <= 'Z';
      ncs_dr2 <= 'Z';
      d_dr2 <= (others => 'Z');
      dqm_dr2 <= (others => 'Z');
      nras_dr2 <= 'Z';
      nwe_dr2 <= '1';

    end generate GEN_NO_SDRAM;

  end block BLK_SDRAM;

  BLK_VIDEO : block

    signal ad724_stnd		: std_logic;

  begin

		video_i.clk <= clk_i(1);	-- by convention
    video_i.clk_ena <= '1';

    bd_out(20) <= video_o.rgb.r(9);
    bd_out(27) <= video_o.rgb.r(8);
    bd_out(30) <= video_o.rgb.r(7);
    bd_out(22) <= video_o.rgb.r(6);
    ba25 <= video_o.rgb.g(9);
    nromgdis <= video_o.rgb.g(8);
    bd_out(26) <= video_o.rgb.g(7);
    bd_out(28) <= video_o.rgb.g(6);
    bd_out(16) <= video_o.rgb.b(9);
    bd_out(23) <= video_o.rgb.b(8);
    bd_out(24) <= video_o.rgb.b(7);
    ba24 <= video_o.rgb.b(6);

    ba22 <= video_o.hsync;
    nromsdis <= video_o.vsync;

    -- drive encoder enable
    ba3 <= PACE_ENABLE_ADV724;
    -- drive PAL/NTSC selector
    ad724_stnd <= PACE_ADV724_STD;
    ba6 <= ad724_stnd;
    ba4 <= not ad724_stnd;

  end block BLK_VIDEO;

  BLK_AUDIO : block

    alias audio_left    : std_logic is ba9;
    alias audio_right   : std_logic is ba20;

  begin

    -- audio PWM
    -- clock is 24Mhz, sample rate 24kHz
    process (clk_24M, reset_i)
      variable count : integer range 0 to 1023;
      variable audio_sample_l : std_logic_vector(9 downto 0);
      variable audio_sample_r : std_logic_vector(9 downto 0);
    begin
      if reset_i = '1' then
        count := 0;
      elsif rising_edge(clk_24M) then
        if count = 1023 then
          -- 24kHz tick - latch a sample (only 10 bits or 1024 steps)
          audio_sample_l := audio_o.ldata(audio_o.ldata'left downto audio_o.ldata'left-9);
          audio_sample_r := audio_o.rdata(audio_o.rdata'left downto audio_o.rdata'left-9);
          count := 0;
        else
          audio_left <= '0';  -- default
          audio_right <= '0'; -- default
          if audio_sample_l > count then
            audio_left <= '1';
          end if;
          if audio_sample_r > count then
            audio_right <= '1';
          end if;
          count := count + 1;
        end if;
      end if;
    end process;
    
  end block BLK_AUDIO;

  BLK_SERIAL : block
  begin
    GEN_NO_SERIAL : if not PACE_HAS_SERIAL generate
      gat_txd <='0';
      ser_i.rxd <= '0';
    end generate GEN_NO_SERIAL;
  end block BLK_SERIAL;
  
	GEN_NO_ENET : if true generate
		MDIO_enet <= 'Z';
		MDC_enet <= 'Z';
		TXD_enet <= (others => 'Z');
		TXEN_enet <= 'Z';
		TXER_enet <= 'Z';
		RESET_enet <= 'Z';
	end generate GEN_NO_ENET;
		
	GEN_NO_SSN : if true generate
		mac_addr <= 'Z';
	end generate GEN_NO_SSN;
	
	GEN_NO_CF : if true generate
		a_cf <= (others => 'Z');
		d_cf <= (others => 'Z');
		nce_cf <= (others => 'Z');
		nior0_cf <= 'Z';
		niow0_cf <= 'Z';
		non_cf <= '1';
		reset_cf <= 'Z';
		ndmack_cf <= 'Z';
	end generate GEN_NO_CF;

	GEN_NO_I2C : if true generate
		clk_ee <= 'Z';
		data_ee <= 'Z';
	end generate GEN_NO_I2C;
	
	nromsoe <= 'Z';
	nmebwait <= 'Z';
	nce_n <= 'Z';
	bd_out(18) <= 'Z';
	bd_out(25) <= 'Z';
					
	-- GPIO inputs					
	gpio_i(2) <= bd(15);
	gpio_i(3) <= ba18;
	gpio_i(4) <= bd(7);
	gpio_i(5) <= bd(1);
	gpio_i(6) <= bd(14);
	gpio_i(7) <= bd(9);
	gpio_i(8) <= bd(10);
	gpio_i(9) <= bd(4);
	
	-- GPIO drivers
	gpio_oe <= (others => '0');
	--bd(15) <= gpio_o(2) when gpio_oe(2) = '1' else 'Z'; -- sd_clk
	--ba18 <= gpio_o(3) when gpio_oe(3) = '1' else 'Z'; -- input only
	--bd(7) <= gpio_o(4) when gpio_oe(4) = '1' else 'Z'; -- sd_dat
	--bd(1) <= gpio_o(5) when gpio_oe(5) = '1' else 'Z'; -- sd_cmd
	--bd(14) <= gpio_o(6) when gpio_oe(6) = '1' else 'Z'; -- ps2_mclk
	--bd(9) <= gpio_o(7) when gpio_oe(7) = '1' else 'Z'; -- sd_dat3
	--bd(10) <= gpio_o(8) when gpio_oe(8) = '1' else 'Z'; -- ps2_mdat
	--bd(4) <= gpio_o(9) when gpio_oe(9) = '1' else 'Z'; -- gamecube data io
	
	-- BD drivers
	bd(0) <= 'Z';
	bd(2) <= 'Z';
	bd(3) <= 'Z';
	bd(5) <= 'Z';
	bd(6) <= 'Z';
	bd(8) <= 'Z';
	bd(11) <= 'Z';
	bd(12) <= 'Z';
	bd(13) <= 'Z';
	bd(16) <= bd_out(16);
	bd(17) <= 'Z';
	bd(18) <= bd_out(18);
	bd(19) <= 'Z';
	bd(20) <= bd_out(20);
	bd(21) <= 'Z';
	bd(22) <= bd_out(22);
	bd(23) <= bd_out(23);
	bd(24) <= bd_out(24);
	bd(25) <= bd_out(25);
	bd(26) <= bd_out(26);
	bd(27) <= bd_out(27);
	bd(28) <= bd_out(28);
	bd(29) <= 'Z';
	bd(30) <= bd_out(30);
	bd(31) <= 'Z';

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
      gp_i              => (others => '0'),
      gp_o              => open
    );

  BLK_CHASER : block
  begin
    -- flash the led so we know it's alive
    process (clk_24M, reset_i)
      variable count : std_logic_vector(21 downto 0);
    begin
      if reset_i = '1' then
        count := (others => '0');
      elsif rising_edge(clk_24M) then
        count := count + 1;
      end if;
      led <= count(count'left);
    end process;
  end block BLK_CHASER;

end SYN;
