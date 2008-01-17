library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;

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
    ba20              : in std_logic;
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
    ba9               : in std_logic;
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

  alias ps2_kclk      : std_logic is ba16;
  alias ps2_kdat      : std_logic is ba14;
  alias sd_cmd        : std_logic is bd(1);
  alias sd_dat3       : std_logic is bd(9);
  alias sd_clk        : std_logic is bd(15);
  alias sd_dat        : std_logic is bd(7);

  signal clk          : std_logic_vector(0 to 3);
  signal init        	: std_logic;
	signal reset				: std_logic;
	signal reset_n			: std_logic;
	
	signal ad724_stnd		: std_logic;
	signal red_s				: std_logic_vector(9 downto 4);
	signal blue_s				: std_logic_vector(9 downto 4);
	signal green_s			: std_logic_vector(9 downto 4);

	signal bd_out				: std_logic_vector(31 downto 0);

	signal jamma_s			: JAMMAInputsType;
	
	signal sram_addr_s	: std_logic_vector(23 downto 0);

	-- signals needed by OCM core

	signal cpuclk				: std_logic;
	signal dip_s				: std_logic_vector(7 downto 0);
	
	signal sltsltsl_n		: std_logic;
	signal sltrd_n			: std_logic;
	signal sltwr_n			: std_logic;
	signal sltadr				: std_logic_vector(15 downto 0);
	signal sltdat				: std_logic_vector(7 downto 0);

	signal sltcs1_n			: std_logic;
	signal sltcs2_n			: std_logic;
	signal sltcs12_n		: std_logic;
	signal sltrfsh_n		: std_logic;
	signal sltwait_n		: std_logic;
	signal sltint_n			: std_logic;
	signal sltm1_n			: std_logic;
	signal sltmerq_n		: std_logic;

	signal bios_rom_data	: std_logic_vector(7 downto 0);
	signal ext_rom_data		: std_logic_vector(7 downto 0);
				
begin

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	-- init time is 48ms
	process (clock0)
		variable count : std_logic_vector (9 downto 0) := (others => '0');
		subtype c2_type is integer range 0 to 1125;
		variable count2 : c2_type := 0;
	begin
		if rising_edge(clock0) then
			if count2 = c2_type'high then
				init <= '0';
			else
				count := count + 1;
				if count = 0 then
					count2 := count2 + 1;
				end if;
				-- fudge a reset pulse
				if count2 > 255 and count2 < 512 then
					init <= '0';
				else
					init <= '1';
				end if;
			end if;
		end if;
	end process;

	-- the dipswitch must be "down" for the board to run
	-- this is akin to an "ON" switch flicked down to turn on
	reset <= init or sw2_1;
	reset_n <= not reset;
			
  -- unused clocks on P2
	clk(0) <= clock0;
	clk(1) <= '0';
  clk(2) <= '0';
  clk(3) <= '0';

	-- attach sram
	ba_ns <= sram_addr_s(ba_ns'range);
	ncs_s <= '1';
	noe_ns <= '1';
	nwe_s <= '1';
	
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
	
	-- default the dipswitches
	-- note: they get inverted in emsx_top before being used
  dip_s <= not (OCM_DIP_SLOT2_1 &
                OCM_DIP_SLOT2_0 &
                OCM_DIP_CPU_CLOCK &
                OCM_DIP_DISK_ROM &
                OCM_DIP_KEYBOARD &
                OCM_DIP_RED_CINCH &
                OCM_DIP_VGA_1 &
                OCM_DIP_VGA_0);

	-- slot data bus driver
	sltdat <= bios_rom_data when (sltsltsl_n = '0' and sltrd_n = '0' and sltadr(15) = '0') else 
						ext_rom_data when (sltsltsl_n = '0' and sltrd_n = '0' and sltadr(15) = '1') else 
						(others =>'Z');

	sltcs1_n <= 'Z';
	sltcs2_n <= 'Z';
	sltcs12_n <= 'Z';
	sltrfsh_n <= 'Z';
	sltwait_n <= 'Z';
	sltint_n <= 'Z';
	sltm1_n <= 'Z';
	sltmerq_n <= 'Z';

	ocm_inst : entity work.emsx_top
	  port map
		(
	    -- Clock, Reset ports
	    pClk21m     => clock8,						-- VDP clock ... 21.48MHz
	    pExtClk     => clock0,						-- Reserved (for multi FPGAs)
	    pCpuClk     => cpuclk,						-- CPU clock ... 3.58MHz (up to 10.74MHz/21.48MHz)
	--  pCpuRst_n   : out std_logic;			-- CPU reset

	    -- MSX cartridge slot ports
	    pSltClk     => cpuclk,						-- pCpuClk returns here, for Z80, etc.
	    pSltRst_n   => reset_n,						-- pCpuRst_n returns here
	    pSltSltsl_n => sltsltsl_n,
	    pSltSlts2_n => open,
	    pSltIorq_n  => open,
	    pSltRd_n    => sltrd_n,
	    pSltWr_n    => sltwr_n,
	    pSltAdr     => sltadr,
	    pSltDat     => sltdat,
	    pSltBdir_n  => open,							-- Bus direction (not used in master mode)

	    pSltCs1_n   => sltcs1_n,
	    pSltCs2_n   => sltcs2_n,
	    pSltCs12_n  => sltcs12_n,
	    pSltRfsh_n  => sltrfsh_n,
	    pSltWait_n  => sltwait_n,
	    pSltInt_n   => sltint_n,
	    pSltM1_n    => sltm1_n,
	    pSltMerq_n  => sltmerq_n,

	    pSltRsv5    => open,							-- Reserved
	    pSltRsv16   => open,							-- Reserved (w/ external pull-up)
	    pSltSw1     => open,								-- Reserved (w/ external pull-up)
	    pSltSw2     => open,							-- Reserved

	    -- SD-RAM ports
	    pMemClk     => clk_dr1,						-- SD-RAM Clock
	    pMemCke     => cke_dr1,						-- SD-RAM Clock enable
	    pMemCs_n    => ncs_dr1,						-- SD-RAM Chip select
	    pMemRas_n   => nras_dr1,					-- SD-RAM Row/RAS
	    pMemCas_n   => ncas_dr1,					-- SD-RAM /CAS
	    pMemWe_n    => nwe_dr1,						-- SD-RAM /WE
	    pMemUdq     => dqm_dr1(1),				-- SD-RAM UDQM
	    pMemLdq     => dqm_dr1(0),				-- SD-RAM LDQM
	    pMemBa1     => ba_dr1(1),					-- SD-RAM Bank select address 1
	    pMemBa0     => ba_dr1(0),					-- SD-RAM Bank select address 0
	    pMemAdr     => a_dr1,							-- SD-RAM Address
	    pMemDat     => d_dr1(15 downto 0),	-- SD-RAM Data

	    -- PS/2 keyboard ports
	    pPs2Clk     => ps2_kclk,
	    pPs2Dat     => ps2_kdat,

	    -- Joystick ports (Port_A, Port_B)
	    pJoyA       => open,
	    pStrA       => open,
	    pJoyB       => open,
	    pStrB       => open,

	    -- SD/MMC slot ports
	    pSd_Ck      => sd_clk,						-- pin 5
	    pSd_Cm      => sd_cmd,						-- pin 2
	    pSd_Dt(3)   => sd_dat3,						-- pin 1(D3)
	    pSd_Dt(2)   => open,							-- pin 9(D2)
	    pSd_Dt(1)   => open,							-- pin 8(D1)
	    pSd_Dt(0)   => sd_dat,						-- pin 7(D0)

	    -- DIP switch, Lamp ports
	    pDip        => dip_s,							-- 0=ON,  1=OFF(default on shipment)
	    pLed        => open,							-- 0=OFF, 1=ON(green)
	    pLedPwr     => open,							-- 0=OFF, 1=ON(red) ...Power & SD/MMC access lamp

	    -- Video, Audio/CMT ports
	    pDac_VR     => red_s,							-- RGB_Red / Svideo_C
	    pDac_VG     => green_s,						-- RGB_Grn / Svideo_Y
	    pDac_VB     => blue_s,						-- RGB_Blu / CompositeVideo
	    pDac_SL     => open,							-- Sound-L
	    pDac_SR     => open,							-- Sound-R / CMT

	    pVideoHS_n  => ba22,							-- Csync(RGB15K), HSync(VGA31K)
	    pVideoVS_n  => nromsdis,					-- Audio(RGB15K), VSync(VGA31K)

	    pVideoClk   => open,							-- (Reserved)
	    pVideoDat   => open,							-- (Reserved)

	    -- Reserved ports (USB)
	    pUsbP1      => open,
	    pUsbN1      => open,
	    pUsbP2      => open,
	    pUsbN2      => open,

	    -- Reserved ports
	    pIopRsv14   => 'X',
	    pIopRsv15   => 'X',
	    pIopRsv16   => 'X',
	    pIopRsv17   => 'X',
	    pIopRsv18   => 'X',
	    pIopRsv19   => 'X',
	    pIopRsv20   => 'X',
	    pIopRsv21   => 'X'
	  );

	--bios_rom_inst : entity work.sprom
	--	generic map
	--	(
	--		init_file		=> "../../../../../src/platform/msx/ocm/roms/msx2_rom.hex",
	--		numwords_a	=> 32768,
	--		widthad_a		=> 15
	--	)
	--	port map
	--	(
	--		clock				=> cpuclk,
	--		address			=> sltadr(14 downto 0),
	--		q						=> bios_rom_data
	--	);

	--ext_rom_inst : entity work.sprom
	--	generic map
	--	(
	--		init_file		=> "../../../../../src/platform/msx/ocm/roms/msx2ext_rom.hex",
	--		numwords_a	=> 16384,
	--		widthad_a		=> 14
	--	)
	--	port map
	--	(
	--		clock				=> cpuclk,
	--		address			=> sltadr(13 downto 0),
	--		q						=> ext_rom_data
	--	);
	
  -- BD drivers
	bd(0) <= 'Z';
	bd(1) <= 'Z';
	bd(2) <= 'Z';
	bd(3) <= 'Z';
	bd(4) <= 'Z';
	bd(5) <= 'Z';
	bd(6) <= 'Z';
	bd(7) <= 'Z';
	bd(8) <= 'Z';
	bd(9) <= 'Z';
	bd(10) <= 'Z';
	bd(11) <= 'Z';
	bd(12) <= 'Z';
	bd(13) <= 'Z';
	bd(14) <= 'Z';
	bd(15) <= 'Z';
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
	process (clk(0), reset)
		variable count : std_logic_vector(21 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk(0)) then
			count := count + 1;
		end if;
		led <= count(count'left);
	end process;

end SYN;
