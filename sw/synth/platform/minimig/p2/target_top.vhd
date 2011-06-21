library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
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

  alias audio_left    : std_logic is ba9;
  alias audio_right   : std_logic is ba20;
	alias ps2_clk			  : std_logic is ba16;
	alias ps2_dat			  : std_logic is ba14;
	alias ps2_mclk      : std_logic is bd(14);
	alias ps2_mdat      : std_logic is bd(10);
  alias hsync         : std_logic is ba22;
	alias vsync         : std_logic is nromsdis;
  alias sd_cmd        : std_logic is bd(1);
  alias sd_dat3       : std_logic is bd(9);
  alias sd_clk        : std_logic is bd(15);
  alias sd_dat        : std_logic is bd(7);

	signal reset				: std_logic;
	signal reset_n			: std_logic;
  signal init        	: std_logic;

  signal clk_24M      : std_logic;
  signal clk_24M_misc : std_logic;

	signal ad724_stnd		: std_logic;
	signal red_s				: std_logic_vector(9 downto 0);
	signal blue_s				: std_logic_vector(9 downto 0);
	signal green_s			: std_logic_vector(9 downto 0);

  signal snd_data_l   : std_logic_vector(15 downto 0);
  signal snd_data_r   : std_logic_vector(15 downto 0);

	signal bd_out				: std_logic_vector(31 downto 0);

	signal jamma_s			: from_JAMMA_t;
	-- gamecube controller interface
	signal gcj					: work.gamecube_pkg.joystate_type;
	alias gcj_data			: std_logic is bd(4);
	signal gcj_d_i		  : std_logic;
	signal gcj_d_o			: std_logic;
	signal gcj_d_oe	    : std_logic;
		
	signal gpio_i				: std_logic_vector(9 downto 2);
	signal gpio_o				: std_logic_vector(gpio_i'range);
	signal gpio_oe			: std_logic_vector(gpio_i'range);
	
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
  reset_n <= not reset;

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
	
	assert (not (P2_JAMMA_IS_MAPLE and P2_JAMMA_IS_NGC))
		report "Cannot choose both MAPLE and GAMECUBE interfaces"
		severity error;
	
	GEN_GAMECUBE : if P2_JAMMA_IS_NGC generate
	
		GC_JOY: gamecube_joy
			generic map
			( 
				MHZ => 24
			)
  		port map
		  (
  			clk 				=> clk_24M_misc,
				reset 			=> reset,
				d_i 				=> gcj_d_i,
        d_o         => gcj_d_o,
				d_oe 				=> gcj_d_oe,
				joystate 		=> gcj
			);

    gcj_d_i <= gcj_data;
    gcj_data <= gcj_d_o when gcj_d_oe = '1' else 'Z';
    
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

  c24mhz_inst : ENTITY work.c24mhz
    PORT map
    (
      inclk0		    => clock8,
      c0		        => clk_24M,
      c1		        => clk_24M_misc
    );

  minimig_de1_inst : entity work.minimig_de1
    generic map
    (
      HAS_I2C_AV_CONFIG  => false
    )
    port map
    (
      joya          => (others => '1'),
      joyb(5)       => jamma_s.p(1).button(2),
      joyb(4)       => jamma_s.p(1).button(1),
      joyb(3)       => jamma_s.p(1).up,
      joyb(2)       => jamma_s.p(1).down,
      joyb(1)       => jamma_s.p(1).left,
      joyb(0)       => jamma_s.p(1).right,
      sd_dat        => sd_dat,
      joy           => (others => '0'), -- not used
      clock_27(1)   => '0', -- not used
      clock_27(0)   => clock0,
      clock_24(1)   => '0',
      clock_24(0)   => clk_24M,
      ext_clock     => '0', -- not used,
      clock_50      => '0', -- not used
      key           => (others => '1'), -- active low
      sw(9)        => '1', -- 15kHz
      sw(8 downto 4) => (others => '0'), -- not used
      sw(3)         => '1',
      sw(2)         => '1',
      sw(1)         => '1',
      sw(0)         => reset_n,
      aud_adcdat    => '0',
      uart_rxd      => '0',
      tdi           => '0',
      tck           => '0',
      tcs           => '0',
      dram_cke      => cke_dr2,
      dram_dq       => d_dr2(15 downto 0),
      dram_addr     => a_dr2,
      dram_cs_n     => ncs_dr2,
      ledg          => open,
      dram_ba_0     => ba_dr2(0),
      dram_ba_1     => ba_dr2(1),
      dram_we_n     => nwe_dr2,
      dram_ldqm     => dqm_dr2(0),
      dram_ras_n    => nras_dr2,
      dram_udqm     => dqm_dr2(1),
      dram_cas_n    => ncas_dr2,
      fl_dq         => open,
      fl_ce_n       => open,
      fl_oe_n       => open,
      fl_rst_n      => open,
      fl_we_n       => open,
      sram_dq       => open,
      fl_addr       => open,
      sram_addr     => open,
      sram_ub_n     => open,
      sram_lb_n     => open,
      sram_we_n     => open,
      sram_ce_n     => open,
      ps2_mdat      => ps2_mdat,
      sram_oe_n     => open,
      ps2_mclk      => ps2_mclk,
      ps2_dat       => ps2_dat,
      ps2_clk       => ps2_clk,
      vga_hs        => hsync,
      tdo           => open,
      vga_vs        => vsync,
      vga_r         => red_s(9 downto 6),
      vga_g         => green_s(9 downto 6),
      vga_b         => blue_s(9 downto 6),
      sd_dat3       => sd_dat3,
      sd_clk        => sd_clk,
      sd_cmd        => sd_cmd,
      aud_adclrck   => open,
      uart_txd      => gat_txd,
      hex0          => open,
      hex1          => open,
      hex2          => open,
      hex3          => open,
      ledr          => open,
      aud_xck       => audio_left,
      aud_dacdat    => audio_right,
      aud_daclrck   => open,
      aud_bclk      => open,
      dram_clk      => clk_dr2,
      i2c_sclk      => open,
      i2c_sdat      => open
    );
  dqm_dr2(3 downto 2) <= (others => '0');
  d_dr2(31 downto 16) <= (others => '1');

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
	
	GEN_NO_SDRAM_2 : if false generate
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
	--ba18 <= gpio_o(3) when gpio_oe(3) = '1' else 'Z';
	--bd(7) <= gpio_o(4) when gpio_oe(4) = '1' else 'Z'; -- sd_dat
	--bd(1) <= gpio_o(5) when gpio_oe(5) = '1' else 'Z'; -- sd_cmd
	--bd(14) <= gpio_o(6) when gpio_oe(6) = '1' else 'Z';
	--bd(9) <= gpio_o(7) when gpio_oe(7) = '1' else 'Z'; -- sd_dat3
	--bd(10) <= gpio_o(8) when gpio_oe(8) = '1' else 'Z';
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
	process (clk_24M_misc, reset)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk_24M_misc) then
			count := count + 1;
		end if;
		led <= count(count'left);
	end process;

end SYN;
