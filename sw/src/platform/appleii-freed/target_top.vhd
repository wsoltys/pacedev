library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
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

  component MMC_start_DE1_TOP is
    port
    (
       --////////////////////	Clock Input	 	////////////////////	 
       CLOCK_24         : in std_logic_vector(1 downto 0);
       CLOCK_27         : in std_logic_vector(1 downto 0);
       CLOCK_50         : in std_logic;
       EXT_CLOCK        : in std_logic;
       --////////////////////	Push Button		////////////////////
       KEY              : in std_logic_vector(3 downto 0);
       --////////////////////	DPDT Switch		////////////////////
       SW               : in std_logic_vector(9 downto 0);
       --////////////////////	7-SEG Dispaly	////////////////////
       HEX0             : out std_logic_vector(6 downto 0);
       HEX1             : out std_logic_vector(6 downto 0);
       HEX2             : out std_logic_vector(6 downto 0);
       HEX3             : out std_logic_vector(6 downto 0);
       --////////////////////////	LED		///////////////////////
       LEDG             : out std_logic_vector(7 downto 0);
       LEDR             : out std_logic_vector(9 downto 0);
       --////////////////////////	UART	////////////////////////
       UART_TXD         : out std_logic;
       UART_RXD         : in std_logic;
       --/////////////////////	SDRAM Interface		////////////////
       DRAM_DQ          : inout std_logic_vector(15 downto 0);
       DRAM_ADDR        : out std_logic_vector(11 downto 0);
       DRAM_LDQM        : out std_logic;
       DRAM_UDQM        : out std_logic;
       DRAM_WE_N        : out std_logic;
       DRAM_CAS_N       : out std_logic;
       DRAM_RAS_N       : out std_logic;
       DRAM_CS_N        : out std_logic;
       DRAM_BA_0        : out std_logic;
       DRAM_BA_1        : out std_logic;
       DRAM_CLK         : out std_logic;
       DRAM_CKE         : out std_logic;
       --////////////////////	Flash Interface		////////////////
       FL_DQ            : inout std_logic_vector(7 downto 0);
       FL_ADDR          : out std_logic_vector(21 downto 0);
       FL_WE_N          : out std_logic;
       FL_RST_N         : out std_logic;
       FL_OE_N          : out std_logic;
       FL_CE_N          : out std_logic;
       --////////////////////	SRAM Interface		////////////////
       SRAM_DQ          : inout std_logic_vector(15 downto 0);
       SRAM_ADDR        : out std_logic_vector(17 downto 0);
       SRAM_UB_N        : out std_logic;
       SRAM_LB_N        : out std_logic;
       SRAM_WE_N        : out std_logic;
       SRAM_CE_N        : out std_logic;
       SRAM_OE_N        : out std_logic;
       --////////////////////	SD_Card Interface	////////////////
       SD_DAT           : inout std_logic;
       SD_DAT3          : inout std_logic;
       SD_CMD           : inout std_logic;
       SD_CLK           : out std_logic;
       --////////////////////	USB JTAG link	////////////////////
       TDI              : in std_logic;
       TCK              : in std_logic;
       TCS              : in std_logic;
       TDO              : out std_logic;
       --////////////////////	I2C		////////////////////////////
       I2C_SDAT         : inout std_logic;
       I2C_SCLK         : out std_logic;
       --////////////////////	PS2		////////////////////////////
       PS2_DAT          : in std_logic;
       PS2_CLK          : in std_logic;
       --////////////////////	VGA		////////////////////////////
       VGA_HS           : out std_logic;
       VGA_VS           : out std_logic;
       VGA_R            : out std_logic_vector(3 downto 0);
       VGA_G            : out std_logic_vector(3 downto 0);
       VGA_B            : out std_logic_vector(3 downto 0);
       --////////////////	Audio CODEC		////////////////////////
       AUD_ADCLRCK      : inout std_logic;
       AUD_ADCDAT       : in std_logic;
       AUD_DACLRCK      : inout std_logic;
       AUD_DACDAT       : out std_logic;
       AUD_BCLK         : inout std_logic;
       AUD_XCK          : out std_logic;
       --////////////////////	GPIO	////////////////////////////
       GPIO_0           : inout std_logic_vector(35 downto 0);
       GPIO_1           : inout std_logic_vector(35 downto 0)
     );
  end component MMC_start_DE1_TOP;

  alias clk_24M       : std_logic is clock8;
  alias audio_left    : std_logic is ba9;
  alias audio_right   : std_logic is ba20;
  alias ps2_kclk      : std_logic is ba16;
  alias ps2_kdat      : std_logic is ba14;
	alias ps2_mclk      : std_logic is bd(14);
	alias ps2_mdat      : std_logic is bd(10);
  alias sd_cmd        : std_logic is bd(1);
  alias sd_dat3       : std_logic is bd(9);
  alias sd_clk        : std_logic is bd(15);
  alias sd_dat        : std_logic is bd(7);
  alias hsync         : std_logic is ba22;
  alias vsync         : std_logic is nromsdis;

  signal clk          : std_logic_vector(0 to 3);
  signal init        	: std_logic;
	signal reset				: std_logic;
	
	signal ad724_stnd		: std_logic;
	signal red_s				: std_logic_vector(9 downto 0);
	signal blue_s				: std_logic_vector(9 downto 0);
	signal green_s			: std_logic_vector(9 downto 0);

  signal snd_data_l   : std_logic_vector(15 downto 0);
  signal snd_data_r   : std_logic_vector(15 downto 0);

	signal bd_out				: std_logic_vector(31 downto 0);

	signal jamma_s			: JAMMAInputsType;
	-- gamecube controller interface
	signal gcj					: work.gamecube_pkg.joystate_type;
	alias gcj_data			: std_logic is bd(4);
		
	signal gpio_i				: std_logic_vector(9 downto 2);
	signal gpio_o				: std_logic_vector(gpio_i'range);
	signal gpio_oe			: std_logic_vector(gpio_i'range);

  -- appleii-freed signals
  signal key          : std_logic_vector(3 downto 0);
  signal fl_dq        : std_logic_vector(7 downto 0);
  signal fl_addr      : std_logic_vector(21 downto 0);
  signal fl_oe_n      : std_logic;
  signal fl_ce_n      : std_logic;
  signal gpio_1       : std_logic_vector(35 downto 0);

begin

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
	reset <= init or sw2_1;
		
	-- assign video outputs
	bd_out(20) <= red_s(9);
	bd_out(27) <= red_s(8);
	bd_out(30) <= red_s(7);
	bd_out(22) <= red_s(6);
	ba25 <= green_s(9);
	nromgdis <= green_s(8);
	bd_out(26) <= green_s(7);
	bd_out(28) <= green_s(6);
	bd_out(16) <= blue_s(9);
	bd_out(23) <= blue_s(8);
	bd_out(24) <= blue_s(7);
	ba24 <= blue_s(6);

	-- drive encoder enable
	ba3 <= PACE_ENABLE_ADV724;
	
	-- drive PAL/NTSC selector
	ad724_stnd <= PACE_ADV724_STD;
	
	ba6 <= ad724_stnd;
	ba4 <= not ad724_stnd;

	-- GPIO - not driven
	gpio_oe <= (others => '0');
	
	GEN_GAMECUBE : if P2_JAMMA_IS_NGC generate
	
		GC_JOY: gamecube_joy
			generic map
			( 
				MHZ => 24
			)
  		port map
		  (
  			clk 				=> clk_24M,
				reset 			=> reset,
				oe 					=> open,
				d 					=> gcj_data,
				joystate 		=> gcj
			);

		-- map gamecube controller to jamma inputs
		jamma_s.coin(1) <= not gcj.l;
		jamma_s.p(1).start <= not gcj.start;
		jamma_s.p(1).up <= not (gcj.d_up or (gcj.jy(7) and gcj.jy(6)));
		jamma_s.p(1).down <= not (gcj.d_down or not (gcj.jy(7) or gcj.jy(6)));
		jamma_s.p(1).left <= not (gcj.d_left or not (gcj.jx(7) or gcj.jx(6)));
		jamma_s.p(1).right <= not (gcj.d_right or (gcj.jx(7) and gcj.jx(6)));
		jamma_s.p(1).button(1) <= not gcj.a;
		jamma_s.p(1).button(2) <= not gcj.b;
		jamma_s.p(1).button(3) <= not gcj.x;
		jamma_s.p(1).button(4) <= not gcj.y;
		jamma_s.p(1).button(5)	<= not gcj.z;
		
	end generate GEN_GAMECUBE;

	GEN_NO_JAMMA : if not P2_JAMMA_IS_NGC generate
	
		jamma_s.coin(1) <= '1';
		jamma_s.p(1).start <= '1';
		jamma_s.p(1).up <= '1';
		jamma_s.p(1).down <= '1';
		jamma_s.p(1).left <= '1';
		jamma_s.p(1).right <= '1';
		jamma_s.p(1).button <= (others => '1');

	end generate GEN_NO_JAMMA;	

	jamma_s.coin_cnt <= (others => '1');
	jamma_s.service <= '1';
	jamma_s.tilt <= '1';
	jamma_s.test <= '1';
	
	-- no player 2
	jamma_s.coin(2) <= '1';
	jamma_s.p(2).start <= '1';
	jamma_s.p(2).up <= '1';
	jamma_s.p(2).down <= '1';
	jamma_s.p(2).left <= '1';
	jamma_s.p(2).right <= '1';
	jamma_s.p(2).button <= (others => '1');

  key <= "000" & not reset;

  appleii_freed_inst : MMC_start_DE1_TOP
    port map
    (
       --////////////////////	Clock Input	 	////////////////////	 
       CLOCK_24         => "00",
       CLOCK_27         => "00",
       CLOCK_50         => clock0,  -- 24MHz
       EXT_CLOCK        => '0',
       --////////////////////	Push Button		////////////////////
       KEY              => key,
       --////////////////////	DPDT Switch		////////////////////
       SW               => "0000000010",
       --////////////////////	7-SEG Dispaly	////////////////////
       HEX0             => open,
       HEX1             => open,
       HEX2             => open,
       HEX3             => open,
       --////////////////////////	LED		///////////////////////
       LEDG             => open,
       LEDR             => open,
       --////////////////////////	UART	////////////////////////
       UART_TXD         => gat_txd,
       UART_RXD         => gat_rxd,
       --/////////////////////	SDRAM Interface		////////////////
       DRAM_DQ          => open,
       DRAM_ADDR        => open,
       DRAM_LDQM        => open,
       DRAM_UDQM        => open,
       DRAM_WE_N        => open,
       DRAM_CAS_N       => open,
       DRAM_RAS_N       => open,
       DRAM_CS_N        => open,
       DRAM_BA_0        => open,
       DRAM_BA_1        => open,
       DRAM_CLK         => open,
       DRAM_CKE         => open,
       --////////////////////	Flash Interface		////////////////
       FL_DQ            => fl_dq,
       FL_ADDR          => fl_addr,
       FL_WE_N          => open,
       FL_RST_N         => open,
       FL_OE_N          => fl_oe_n,
       FL_CE_N          => fl_ce_n,
       --////////////////////	SRAM Interface		////////////////
       SRAM_DQ          => bd_ns(15 downto 0),
       SRAM_ADDR        => ba_ns(17 downto 0),
       SRAM_UB_N        => open,
       SRAM_LB_N        => open,
       SRAM_WE_N        => nwe_s,
       SRAM_CE_N        => ncs_s,
       SRAM_OE_N        => noe_ns,
       --////////////////////	SD_Card Interface	////////////////
       SD_DAT           => sd_dat,
       SD_DAT3          => sd_dat3,
       SD_CMD           => sd_cmd,
       SD_CLK           => sd_clk,
       --////////////////////	USB JTAG link	////////////////////
       TDI              => '0',
       TCK              => '0',
       TCS              => '0',
       TDO              => open,
       --////////////////////	I2C		////////////////////////////
       I2C_SDAT         => open,
       I2C_SCLK         => open,
       --////////////////////	PS2		////////////////////////////
       PS2_DAT          => ps2_kdat,
       PS2_CLK          => ps2_kclk,
       --////////////////////	VGA		////////////////////////////
       VGA_HS           => hsync,
       VGA_VS           => vsync,
       VGA_R            => red_s(9 downto 6),
       VGA_G            => green_s(9 downto 6),
       VGA_B            => blue_s(9 downto 6),
       --////////////////	Audio CODEC		////////////////////////
       AUD_ADCLRCK      => '0',
       AUD_ADCDAT       => '0',
       AUD_DACLRCK      => open,
       AUD_DACDAT       => open,
       AUD_BCLK         => open,
       AUD_XCK          => open,
       --////////////////////	GPIO	////////////////////////////
       GPIO_0           => open,
       GPIO_1           => gpio_1
     );

  -- unused SRAM address lines
  ba_ns(19 downto 18) <= (others => '0');

  BLK_ROM : block

    signal rom_clk      : std_logic;
    signal c6_d_o       : std_logic_vector(7 downto 0);
    signal d0_d_o       : std_logic_vector(7 downto 0);
    signal e0_d_o       : std_logic_vector(7 downto 0);
    signal f0_d_o       : std_logic_vector(7 downto 0);
    signal rom_d_o      : std_logic_vector(7 downto 0);

  begin

    rom_clk <= gpio_1(35);

    rom_d_o <=  c6_d_o when fl_addr(15) = '0' and fl_addr(13 downto 8) = "000110" else
                d0_d_o when fl_addr(15) = '1' and fl_addr(13 downto 12) = "01" else
                e0_d_o when fl_addr(15) = '1' and fl_addr(13 downto 12) = "10" else
                f0_d_o when fl_addr(15) = '1' and fl_addr(13 downto 12) = "11" else
                (others => '1');

    fl_dq <=  rom_d_o when fl_ce_n = '0' and fl_oe_n = '0' else
              (others => 'Z');

    c6_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/c6.hex",
        numwords_a	=> 256,
        widthad_a		=> 8
      )
      port map
      (
        address		  => fl_addr(7 downto 0),
        clock		    => rom_clk,
        q		        => c6_d_o
      );

    d0_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/d0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        address		  => fl_addr(11 downto 0),
        clock		    => rom_clk,
        q		        => d0_d_o
      );

    e0_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/e0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        address		  => fl_addr(11 downto 0),
        clock		    => rom_clk,
        q		        => e0_d_o
      );

    f0_rom : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/appleii-freed/roms/f0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        address		  => fl_addr(11 downto 0),
        clock		    => rom_clk,
        q		        => f0_d_o
      );

  end block BLK_ROM;

  -- audio PWM
  -- clock is 24Mhz, sample rate 24kHz
  process (clk_24M, reset)
    variable count : integer range 0 to 1023;
    variable audio_sample_l : std_logic_vector(9 downto 0);
    variable audio_sample_r : std_logic_vector(9 downto 0);
  begin
    if reset = '1' then
      count := 0;
    elsif rising_edge(clk_24M) then
      if count = 1023 then
        -- 24kHz tick - latch a sample (only 10 bits or 1024 steps)
        audio_sample_l := snd_data_l(snd_data_l'left downto snd_data_l'left-9);
        audio_sample_r := snd_data_r(snd_data_r'left downto snd_data_l'left-9);
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
	
	GEN_NO_SDRAM_1 : if true generate
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
	end generate GEN_NO_SDRAM_1;
	
	GEN_NO_SDRAM_2 : if true generate
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
	end generate GEN_NO_SDRAM_2;
	
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

	-- flash the led so we know it's alive
	process (clk_24M, reset)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk_24M) then
			count := count + 1;
		end if;
		led <= count(count'left);
	end process;

end SYN;
