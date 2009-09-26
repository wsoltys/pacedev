-- -----------------------------------------------------------------------
--
--                                 FPGA 64
--
--     A fully functional commodore 64 implementation in a single FPGA
--
-- -----------------------------------------------------------------------
-- Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
-- -----------------------------------------------------------------------
--
-- System runs on 32 Mhz (derived from a 50MHz clock). 
-- The VIC-II runs in the first 4 cycles of 32 Mhz clock.
-- The CPU runs in the last 16 cycles. Effective cpu speed is 1 Mhz.
-- 4 additional cycles are used to interface with the C-One IEC port.
-- 
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.project_pkg.all;

-- -----------------------------------------------------------------------

entity fpga64_pace is
	generic (
		ENABLE_VIDEO_CFG_OSD  : boolean := false;
		ENABLE_OSD            : boolean := false;
		resetCycles           : integer := 4095
	);
	port(
		sysclk : in std_logic;
		clk32 : in std_logic;
		reset_n : in std_logic;

		-- keyboard interface (use any ordinairy PS2 keyboard)
		kbd_clk: in std_logic;
		kbd_dat: in std_logic;

		-- external memory
		ramAddr: out unsigned(16 downto 0);
		ramData_i: in unsigned(7 downto 0);
		ramData_o: out unsigned(7 downto 0);

		ramCE: out std_logic;
		ramWe: out std_logic;

		-- VGA interface
		hsync: out std_logic;
		vsync: out std_logic;
		r : out unsigned(7 downto 0);
		g : out unsigned(7 downto 0);
		b : out unsigned(7 downto 0);
		
		-- cartridge port
		game : in std_logic;
		exrom : in std_logic;
		irq_n : inout std_logic;
		nmi_n : inout std_logic;
		dma_n : in std_logic;
		ba : out std_logic;
		dot_clk: out std_logic;
		cpu_clk: out std_logic;

		-- joystick interface
		joyA: in unsigned(5 downto 0);
		joyB: in unsigned(5 downto 0);

		-- serial port, for connection to pheripherals
		serioclk : out std_logic;
		ces : out std_logic_vector(3 downto 0);

		-- (internal) SID connections
		sid_pot_x				: inout std_logic;
		sid_pot_y				: inout std_logic;
		sid_audio_out		: out std_logic;
		sid_audio_data	: out std_logic_vector(17 downto 0);

		-- IEC
		sb_data_oe			: out std_logic;
		sb_data_in			: in std_logic;
		sb_clk_oe				: out std_logic;
		sb_clk_in				: in std_logic;
		sb_atn_oe				: out std_logic;
		sb_atn_in				: in std_logic;
				
		--Connector to the SID
		SIDclk: out std_logic;
		still: out unsigned(15 downto 0)
	);
end fpga64_pace;

-- -----------------------------------------------------------------------

architecture rtl of fpga64_pace is
	-- System state machine
	type sysCycleDef is (
		CYCLE_IDLE0, CYCLE_IDLE1, CYCLE_IDLE2, CYCLE_IDLE3,
		CYCLE_IDLE4, CYCLE_IDLE5, CYCLE_IDLE6, CYCLE_IDLE7,
		CYCLE_IDLE8,
		CYCLE_IEC0, CYCLE_IEC1, CYCLE_IEC2, CYCLE_IEC3,
		CYCLE_VIC0, CYCLE_VIC1, CYCLE_VIC2, CYCLE_VIC3,
		CYCLE_CPU0, CYCLE_CPU1, CYCLE_CPU2, CYCLE_CPU3,
		CYCLE_CPU4, CYCLE_CPU5, CYCLE_CPU6, CYCLE_CPU7,
		CYCLE_CPUP, CYCLE_CPUQ,
		CYCLE_CPU8, CYCLE_CPU9, CYCLE_CPUA, CYCLE_CPUB,
		CYCLE_CPUC, CYCLE_CPUD, CYCLE_CPUE, CYCLE_CPUF
	);

	signal sysCycle : sysCycleDef := sysCycleDef'low;
	signal sysCycleCnt : unsigned(2 downto 0);
	signal phi0_cpu : std_logic;
	signal phi0_vic : std_logic;
	signal cpuHasBus : std_logic;
	
	signal cycleRestart : std_logic;
	signal cycleRestartReg1 : std_logic;
	signal cycleRestartReg2 : std_logic;
	signal cycleRestartEdge : std_logic;

	signal dotClkReg : std_logic;
	signal dotClkCnt : integer range 0 to 7;

	signal baLoc: std_logic;
	signal irqLoc: std_logic;
	signal nmiLoc: std_logic;

	signal enableCpu: std_logic;
	signal enableVic : std_logic;
	signal enablePixel : std_logic;

	signal irq_cia1: std_logic;
	signal irq_cia2: std_logic;
	signal irq_vic: std_logic;

	signal systemWe: std_logic;
	signal pulseWrRam: std_logic;
	signal pulseWrIo: std_logic;
	signal pulseRd: std_logic;
	signal colorWe : std_logic;
	signal systemAddr: unsigned(16 downto 0);
	signal ramDataReg : unsigned(7 downto 0);

	signal cs_vic: std_logic;
	signal cs_sid: std_logic;
	signal cs_color: std_logic;
	signal cs_cia1: std_logic;
	signal cs_cia2: std_logic;
	signal cs_ram: std_logic;
	signal cs_ioE: std_logic;
	signal cs_ioF: std_logic;
	signal cs_romL: std_logic;
	signal cs_romH: std_logic;

	signal reset: std_logic := '1';
	signal reset_cnt: integer range 0 to resetCycles := 0;

	signal bankSwitch: unsigned(2 downto 0);

-- CIA signals
signal enableCia : std_logic;
signal cia1Do: unsigned(7 downto 0);
signal cia2Do: unsigned(7 downto 0);

-- keyboard
signal newScanCode: std_logic;
signal theScanCode: unsigned(7 downto 0);

-- I/O
signal cia1_pai: unsigned(7 downto 0);
signal cia1_pao: unsigned(7 downto 0);
signal cia1_pad: unsigned(7 downto 0);
signal cia1_pbi: unsigned(7 downto 0);
signal cia1_pbo: unsigned(7 downto 0);
signal cia1_pbd: unsigned(7 downto 0);
signal cia2_pai: unsigned(7 downto 0);
signal cia2_pao: unsigned(7 downto 0);
signal cia2_pad: unsigned(7 downto 0);
signal cia2_pbi: unsigned(7 downto 0);
signal cia2_pbo: unsigned(7 downto 0);
signal cia2_pbd: unsigned(7 downto 0);

	signal debugWE: std_logic := '0';
	signal debugData: unsigned(7 downto 0) := (others => '0');
	signal debugAddr: integer range 2047 downto 0 := 0;

	signal cpuWe: std_logic;
	signal cpuAddr: unsigned(15 downto 0);
	signal cpuDi: unsigned(7 downto 0);
	signal cpuDo: unsigned(7 downto 0);
	signal cpuIO: unsigned(7 downto 0);

	signal vicDi: unsigned(7 downto 0);
	signal vicAddr: unsigned(15 downto 0);
	signal vicData: unsigned(7 downto 0);
	signal lastVicDi : unsigned(7 downto 0);

	signal colorQ : unsigned(3 downto 0);
	signal colorData : unsigned(3 downto 0);

	signal cpuDebugOpcode: unsigned(7 downto 0);
	signal cpuDebugPc: unsigned(15 downto 0);
	signal cpuDebugA: unsigned(7 downto 0);
	signal cpuDebugX: unsigned(7 downto 0);
	signal cpuDebugY: unsigned(7 downto 0);
	signal cpuDebugS: unsigned(7 downto 0);
	signal cpuStep : std_logic;
	signal traceKey : std_logic;
	signal trace2Key : std_logic;

-- video
signal cyclesPerLine : unsigned(11 downto 0);
signal scanConverterFaster : std_logic;

signal vicColorIndex : unsigned(3 downto 0);
signal vicHSync : std_logic;
signal vicVSync : std_logic;

signal vgaColorIndex : unsigned(3 downto 0);
signal vgaR : unsigned(7 downto 0);
signal vgaG : unsigned(7 downto 0);
signal vgaB : unsigned(7 downto 0);
signal vgaVSync : std_logic;
signal vgaHSync : std_logic;
signal vgaDebug : std_logic;
signal vgaDebugDim : std_logic;
signal debuggerOn : std_logic;	
signal traceStep : std_logic;

-- config
signal videoKey : std_logic;
signal ntscMode : std_logic;

signal videoConfigVideo : std_logic;
signal videoConfigDim : std_logic;
signal videoConfigShow : std_logic;
signal videoConfigTimeout : unsigned(20 downto 0);

-- added PACE

signal ramdata_o_s      : unsigned(7 downto 0);
signal ramdata_oe_s     : std_logic;
signal ramdata_to_bus   : unsigned(7 downto 0);
signal sidData          : unsigned(7 downto 0);
	
begin
-- -----------------------------------------------------------------------
-- Local signal to outside world
-- -----------------------------------------------------------------------
	ba <= baLoc;

-- -----------------------------------------------------------------------
-- System state machine, controls bus accesses
-- and triggers enables of other components
-- -----------------------------------------------------------------------
	process(clk32)
	begin
		if rising_edge(clk32) then
			cycleRestart <= '0';
			if sysCycle = sysCycleDef'high then
				sysCycle <= sysCycleDef'low;
				sysCycleCnt <= sysCycleCnt + 1;
				cycleRestart <= '1';
			elsif sysCycle = CYCLE_CPU7
			and ntscMode = '1' then
				sysCycle <= CYCLE_CPU8;		-- NTSC 33 Cycles
			elsif sysCycle = CYCLE_CPUP
			and sysCycleCnt /= "001"
			and sysCycleCnt /= "100"
			and sysCycleCnt /= "111" then	-- PAL 34 + 3/8
				sysCycle <= CYCLE_CPU8;
			else
				sysCycle <= sysCycleDef'succ(sysCycle);
			end if;
		end if;
	end process;

	iecClock: process(clk32)
	begin
		if rising_edge(clk32) then
			serioclk <= '1';
			if sysCycle = CYCLE_IEC0
			or sysCycle = CYCLE_IEC1 then
				serioclk <= '0'; --for iec write
			end if;	
		end if;
	end process;

	sidClock: process(clk32)
	begin
		if rising_edge(clk32) then
			-- Toggle SIDclk early to compensate for the delay caused by the gbridge
			if sysCycle = CYCLE_VIC3 then
				SIDclk <= '1';
			end if;
			if sysCycle = CYCLE_CPUD then
				SIDclk <= '0';
			end if;
		end if;
	end process;

	-- PHI0/2-clock emulation
	process(clk32)
	begin
		if rising_edge(clk32) then
			if sysCycle = sysCycleDef'pred(CYCLE_CPU0) then
				phi0_cpu <= '1';
				if baLoc = '1' or cpuWe = '1' then
					cpuHasBus <= '1';
				end if;
			end if;
			if sysCycle = sysCycleDef'high then
				phi0_cpu <= '0';
				cpuHasBus <= '0';
			end if;
			if sysCycle = sysCycleDef'pred(CYCLE_VIC0) then
				phi0_vic <= '1';
			end if;
			if sysCycle = CYCLE_VIC3 then
				phi0_vic <= '0';
			end if;
		end if;
	end process;

	process(clk32)
	begin
		if rising_edge(clk32) then
			enableVic <= '0';
			enableCia <= '0';
			enableCpu <= '0';

			case sysCycle is
			when CYCLE_VIC2 =>
				enableVic <= '1';
			when CYCLE_CPUE =>
				enableCia <= '1';
				enableVic <= '1';
				if baLoc = '1'
				or cpuWe = '1' then
					enableCpu <= '1';
				end if;
			when others =>
				null;
			end case;
		end if;
	end process;
	
	
-- -----------------------------------------------------------------------
-- Cartridge clocks
-- -----------------------------------------------------------------------
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			cycleRestartReg1 <= cycleRestart;
			cycleRestartReg2 <= cycleRestartReg1;
			cycleRestartEdge <= cycleRestartReg2;

			dotClkCnt <= dotClkCnt + 1;
			if dotClkCnt = 6 then
				dotClkReg <= not dotClkReg;
				dotClkCnt <= 0;
				if ntscMode = '1'
				or dotClkReg = '1' then
					dotClkCnt <= 1;
				end if;
			end if;
			if cycleRestartReg2 = '1'
			and cycleRestartEdge = '0' then
				dotClkReg <= '1';
				dotClkCnt <= 0;
			end if;
		end if;
	end process;
	dot_clk <= dotClkReg;
	cpu_clk <= phi0_cpu;

-- -----------------------------------------------------------------------
-- Scan-converter and VGA output
-- -----------------------------------------------------------------------
	myScanConverter: entity work.fpga64_cone_scanconverter
		generic map (
			videoWidth => 4
		)
		port map (
			clk => clk32,
			cyclesPerLine => cyclesPerLine,
			faster => scanConverterFaster,
			hSyncPolarity => '0',
			vSyncPolarity => '0',
			enable_in => enablePixel,
			video_in => vicColorIndex,
			hsync_in => vicHSync,
			vsync_in => vicVSync,
			video_out => vgaColorIndex,
			hsync_out => vgaHSync,
			vsync_out => vgaVSync			
		);
	
	cyclesPerLine <= to_unsigned(1080, 12) when ntscMode = '0' else to_unsigned(1088,12);
	scanConverterFaster <= not ntscMode;
	
	c64colors: entity work.fpga64_rgbcolor
		port map (
			index => vgaColorIndex,
			r => vgaR,
			g => vgaG,
			b => vgaB
		);

	process(clk32)
	begin
		if rising_edge(clk32) then
			r <= vgaR;
			g <= vgaG;
			b <= vgaB;
			if ENABLE_OSD then
        if ENABLE_VIDEO_CFG_OSD then
          if videoConfigShow = '1' and videoConfigDim = '1' then
          --if videoConfigDim = '1' then
            r <= videoConfigVideo & vgaR(7 downto 1);
            g <= videoConfigVideo & vgaG(7 downto 1);
            b <= videoConfigVideo & vgaB(7 downto 1);
          end if;
        end if;
        if DebuggerOn = '1' and vgaDebugDim = '1' then
          r <= vgaDebug & vgaR(7 downto 1);
          g <= vgaDebug & vgaG(7 downto 1);
          b <= vgaDebug & vgaB(7 downto 1);
        end if;				
      end if;
		end if;
	end process;
	hSync <= vgaHSync;
	vSync <= vgaVSync;

-- -----------------------------------------------------------------------
-- Color RAM
-- -----------------------------------------------------------------------
	colorram: entity work.gen_ram
		generic map (
			dWidth => 4,
			aWidth => 10
		)
		port map (
			clk => clk32,
			we => colorWe,
			addr => systemAddr(9 downto 0),
			d => cpuDo(3 downto 0),
			q => colorQ
		);

	process(clk32)
	begin
		if rising_edge(clk32) then
			colorWe <= (cs_color and pulseWrRam);
			colorData <= colorQ;
		end if;
	end process;


-- -----------------------------------------------------------------------
-- PLA and bus-switches
-- -----------------------------------------------------------------------
	buslogic: entity work.fpga64_buslogic
		port map (
			clk => clk32,
			reset => reset,
			cpuHasBus => cpuHasBus,

			bankSwitch => cpuIO(2 downto 0),

			game => game,
			exrom => exrom,

			ramData => ramDataReg,

			cpuWe => cpuWe,
			cpuAddr => cpuAddr,
			cpuData => cpuDo,
			vicAddr => vicAddr,
			vicData => vicData,
			sidData => sidData,
			colorData => colorData,
			cia1Data => cia1Do,
			cia2Data => cia2Do,
			lastVicData => lastVicDi,

			systemWe => systemWe,
			systemAddr => systemAddr(15 downto 0),
			dataToCpu => cpuDi,
			dataToVic => vicDi,

			cs_vic => cs_vic,
			cs_sid => cs_sid,
			cs_color => cs_color,
			cs_cia1 => cs_cia1,
			cs_cia2 => cs_cia2,
			cs_ram => cs_ram,
			cs_ioE => cs_ioE,
			cs_ioF => cs_ioF,
			cs_romL => cs_romL,
			cs_romH => cs_romH
		);
		
  systemAddr(16) <= '0';
  
	process(clk32)
	begin
		if rising_edge(clk32) then
			pulseWrRam <= '0';
			pulseWrIo <= '0';
			pulseRd <= '0';
			if cpuWe = '1' then
				if sysCycle = CYCLE_CPUC then
					pulseWrRam <= '1';
				end if;
				if sysCycle = CYCLE_CPUC then
					pulseWrIo <= '1';
				end if;
			else
				if sysCycle = CYCLE_CPUE then
					pulseRd <= '1';
				end if;
			end if;
		end if;
	end process;

-- -----------------------------------------------------------------------
-- VIC-II video interface chip
-- -----------------------------------------------------------------------
	vic: entity work.video_vicii_656x
		generic map (
			registeredAddress => false,
			emulateRefresh => false,
			emulateLightpen => true,
			emulateGraphics => true
		)			
		port map (
			clk => clk32,
			enaPixel => enablePixel,
			enaData => enableVic,
			phi => phi0_cpu,
			
			baSync => '0',
			ba => baLoc,

			mode6569 => (not ntscMode),
			mode6567old => '0',
			mode6567R8 => ntscMode,
			mode6572 => '0',
			
			cs => cs_vic,
			we => pulseWrIo,
			rd => pulseRd,
			lp_n => cia1_pbi(4),

			aRegisters => cpuAddr(5 downto 0),
			diRegisters => cpuDo,
			di => vicDi,
			diColor => colorData,
			do => vicData,

			vicAddr => vicAddr(13 downto 0),

			hsync => vicHSync,
			vsync => vicVSync,
			colorIndex => vicColorIndex,

			irq_n => irq_vic
		);

	-- Pixel timing
	process(clk32)
	begin
		if rising_edge(clk32) then
			enablePixel <= '0';
			if sysCycle = CYCLE_VIC2
			or sysCycle = CYCLE_IDLE2
			or sysCycle = CYCLE_IDLE6
			or sysCycle = CYCLE_IEC2
			or sysCycle = CYCLE_CPU2
			or sysCycle = CYCLE_CPU6
			or sysCycle = CYCLE_CPUA
			or sysCycle = CYCLE_CPUE then
				enablePixel <= '1';
			end if;
		end if;
	end process;

-- -----------------------------------------------------------------------
-- CIAs
-- -----------------------------------------------------------------------
	cia1: entity work.cia6526
		port map (
			clk => clk32,
			todClk => vicVSync,
			reset => reset,
			enable => enableCia,
			cs => cs_cia1,
			we => pulseWrIo,
			rd => pulseRd,

			addr => cpuAddr(3 downto 0),
			di => cpuDo,
			do => cia1Do,

			ppai => cia1_pai,
			ppao => cia1_pao,
			ppbi => cia1_pbi,
			ppbo => cia1_pbo,

			flag_n => '1',

			irq_n => irq_cia1
		);

	cia2: entity work.cia6526
		port map (
			clk => clk32,
			todClk => vicVSync,
			reset => reset,
			enable => enableCia,
			cs => cs_cia2,
			we => pulseWrIo,
			rd => pulseRd,

			addr => cpuAddr(3 downto 0),
			di => cpuDo,
			do => cia2Do,

			ppai => cia2_pai,
			ppao => cia2_pao,
			ppbi => cia2_pbi,
			ppbo => cia2_pbo,

			flag_n => '1',

			irq_n => irq_cia2
		);

-- -----------------------------------------------------------------------
-- 6510 CPU
-- -----------------------------------------------------------------------
	cpu: entity work.cpu_6510
		generic map (
			pipelineOpcode => false,
			pipelineAluMux => false,
			pipelineAluOut => false
		)
		port map (
			clk => clk32,
			reset => reset,
			enable => enableCpu,
			nmi_n => nmiLoc,
			irq_n => irqLoc,

			di => cpuDi,
			addr => cpuAddr,
			do => cpuDo,
			we => cpuWe,
			
			diIO => "00010111",
			doIO => cpuIO,

			debugOpcode => cpuDebugOpcode,
			debugPc => cpuDebugPc,
			debugA => cpuDebugA,
			debugX => cpuDebugX,
			debugY => cpuDebugY,
			debugS => cpuDebugS
		);

-- -----------------------------------------------------------------------
-- Keyboard
-- -----------------------------------------------------------------------
	myKeyboard: entity work.io_ps2_keyboard
		port map (
			clk => clk32,
			kbd_clk => kbd_clk,
			kbd_dat => kbd_dat,
			interrupt => newScanCode,
			scanCode => theScanCode
		);

	myKeyboardMatrix: entity work.fpga64_keyboard_matrix
		port map (
			clk => clk32,
			theScanCode => theScanCode,
			newScanCode => newScanCode,

			joyA => (not joyA(4 downto 0)),
			joyB => (not joyB(4 downto 0)),
			pai => cia1_pao,
			pbi => cia1_pbo,
			pao => cia1_pai,
			pbo => cia1_pbi,
			
			videoKey => videoKey,
			traceKey => traceKey,
			trace2Key => trace2Key,

			backwardsReadingEnabled => '0'
		);

-- -----------------------------------------------------------------------
-- Reset button
-- -----------------------------------------------------------------------
calcReset: process(clk32)
	begin
		if rising_edge(clk32) then
			if sysCycle = sysCycleDef'high then
				if reset_cnt = resetCycles then
					reset <= '0';
				else
					reset <= '1';
					reset_cnt <= reset_cnt + 1;
				end if;
			end if;
			if reset_n = '0'
			or dma_n = '0' then -- temp reset fix
				reset_cnt <= 0;
			end if;
		end if;
	end process;
	
	-- Video modes
	process(clk32)
	begin
    if reset_n = '0' then
      ntscMode <= '1';
		elsif rising_edge(clk32) then
			if videoKey = '1' then
				ntscMode <= not ntscMode;
			end if;
		end if;
	end process;
	
	GEN_VIDEO_CFG_OSD : if ENABLE_VIDEO_CFG_OSD generate
    -- Video config display (disabled)
    process(clk32)
    begin
      if rising_edge(clk32) then
        if videoKey = '1' then
          videoConfigTimeout <= (others => '1');
        end if;
        if cycleRestart = '1' then
          videoConfigShow <= '0';
          if videoConfigTimeout /= 0 then
            videoConfigTimeout <= videoConfigTimeout - 1;
            videoConfigShow <= '1';
          end if;
        end if;				
      end if;
    end process;
  end generate GEN_VIDEO_CFG_OSD;
  
	displayVideoConfig: entity work.fpga64_hexy_vmode
		generic map (
			xoffset => 200
		)
		port map (
			clk => clk32,
			vSync => vgaVSync,
			hSync => vgaHSync,
			video => videoConfigVideo,
			dim => videoConfigDim,
			ntscMode => ntscMode,
			hSyncPolarity => '0',
			vSyncPolarity => '0'
		);

	mainMemoryBus: process(sysCycle, cpuDo, cs_ram, phi0_cpu, phi0_vic, cpuWe, systemWe, systemAddr)
	begin
		ramAddr <= (others => '0');
		if (phi0_cpu = '1') or (phi0_vic = '1') then
			ramAddr <= systemAddr;
		end if;

		--ramData <= (others => 'Z');
		ramdata_oe_s <= '0';
		if (phi0_cpu = '1') and (cpuWe = '1') then
			ramData_o_s <= cpuDo;
			ramdata_oe_s <= '1';
--			if (cs_sid = '1') and
--			(sysCycle = CYCLE_CPU8 or
--			sysCycle = CYCLE_CPU9 or
--			sysCycle = CYCLE_CPUA or
--			sysCycle = CYCLE_CPUB or
--			sysCycle = CYCLE_CPUC or
--			sysCycle = CYCLE_CPUD or
--			sysCycle = CYCLE_CPUE or
--			sysCycle = CYCLE_CPUF) then
--				for i in 0 to 7 loop
--					ramdata(i) <= 'Z';
--					if cpuDo(i) = '0' then
--						ramData(i) <= '0';
--					end if;
--				end loop;
--			end if;
		elsif sysCycle >= CYCLE_IEC0 and sysCycle <= CYCLE_IEC3 then --IEC write
      -- IEC writes to ram not used but benign on PACE
			ramdata_o_s(5)<= cia2_pao(5);
			ramdata_o_s(4)<= cia2_pao(4);
			ramdata_o_s(3)<= cia2_pao(3);
			-- added for PACE to replace above
      sb_data_oe <= cia2_pao(5);
      sb_clk_oe <= cia2_pao(4);
      sb_atn_oe <= cia2_pao(3);
			ramdata_o_s(2)<= '0';   --lptstrobe
			ramdata_oe_s <= '1';
		end if;

		ramCE <= '1';
		ramWe <= not systemWe;
		if sysCycle = CYCLE_IEC2 or sysCycle = CYCLE_IEC3 then
			ramWe <= '0';
		elsif cs_ram = '1' then
			if sysCycle /= CYCLE_CPU0 and sysCycle /= CYCLE_CPU1 and sysCycle /= CYCLE_CPUF then
				ramCE <= '0';
			end if;
		end if;
	end process;
	
	process(clk32)
	begin
		if rising_edge(clk32) then
			if sysCycle = CYCLE_CPUD
			or sysCycle = CYCLE_VIC2 then
				ramDataReg <= ramData_to_Bus;
			end if;
		end if;
	end process;

--serialBus and SID
	serialBus: process(clk32, sysCycle, cs_sid, cs_ioE, cs_ioF, cs_romL, cs_romH, cpuWe)
	begin
		ces <= "1111";
		if sysCycle = CYCLE_IEC0
		or sysCycle = CYCLE_IEC1
		or sysCycle = CYCLE_IEC2
		or sysCycle = CYCLE_IEC3 then
			ces <= "1011";--iec port
		end if;
		if cs_sid = '1' then
			ces <= "0011"; --SID 1
		end if;
		if cs_romL = '1' then
			ces <= "0000";
		end if;
		if cs_romH = '1' then
			ces <= "0100";
		end if;
		if sysCycle /= CYCLE_CPU0
		and sysCycle /= CYCLE_CPU1
		and sysCycle /= CYCLE_CPUF then
			if cs_ioE = '1' then
				ces <= "0101";
			end if;
			if cs_ioF = '1' then
				ces <= "0001";
			end if;
		end if;
		if rising_edge(clk32) then
			if sysCycle = CYCLE_IEC1 then
        -- modified for PACE
				cia2_pai(7) <= sb_data_in;  --ramdata_to_bus(7);
				cia2_pai(6) <= sb_clk_in;   --ramdata_to_bus(6);
			end if;	
		end if;
	end process;

--	debugBasicScreen: process(systemWe, cpuHasBus, systemData, systemAddr)
--	begin
--		if (pulseWrRam = '1') and (cpuHasBus = '1') and (systemAddr(15 downto 11)="00000") then
--			debugWe <= '1';
--		else
--			debugWe <= '0';
--		end if;
--		debugAddr <= to_integer(systemAddr(10 downto 0));
--		debugData <= systemData;
--	end process;
	
	process(clk32)
	begin
		if rising_edge(clk32) then
			if phi0_vic = '1' then
				lastVicDi <= vicDi;
			end if;
		end if;
	end process;
	
	process(clk32)
	begin
		if rising_edge(clk32) then
			if trace2Key = '1' then
				debuggerOn <= not debuggerOn;
			end if;
		end if;
	end process;

	
	hexyInstance : entity work.fpga64_hexy
		generic map (
			xoffset => 200,
			yoffset => 110
		)
		port map (
			clk => clk32,
			vSync => vgaVSync,
			hSync => vgaHSync,
			video => vgaDebug,
			dim => vgaDebugDim,
			
			spyAddr => cpuAddr,
			spyPc => cpuDebugPc,
			spyDo => cpuDo,
			spyOpcode => cpuDebugOpcode,
			spyA => cpuDebugA,
			spyX => cpuDebugX,
			spyY => cpuDebugY,
			spyS => cpuDebugS
		);

	cia2_pai(5 downto 0) <= cia2_pao(5 downto 0);
	cia2_pbi(7 downto 0) <= cia2_pbo;

-- -----------------------------------------------------------------------
-- VIC bank to address lines
-- -----------------------------------------------------------------------
	vicAddr(14) <= (not cia2_pao(0));
	vicAddr(15) <= (not cia2_pao(1));

-- -----------------------------------------------------------------------
-- Interrupt lines
-- -----------------------------------------------------------------------
	irq_n <= 'Z';
	nmi_n <= 'Z';
	irqLoc <= irq_cia1 and irq_vic and irq_n; 
	nmiLoc <= irq_cia2 and nmi_n;

-- -----------------------------------------------------------------------
-- Dummy silence audio output
-- -----------------------------------------------------------------------
	still <= X"4000";

-- -----------------------------------------------------------------------
--  Added to PACE
-- -----------------------------------------------------------------------

  -- ram bus arbiter
	ramdata_to_bus <= ramdata_o_s when ramdata_oe_s = '1' else
                    ramdata_i;
  ramdata_o <= ramdata_o_s;

	GEN_SID : if C64_HAS_SID generate
		
    signal sidData_s 	: std_logic_vector(sidData'range);
    signal sidWr      : std_logic;
    
  begin
  
    sidWr <= pulseWrRam and phi0_cpu;
    
    sid_inst : entity work.sid6581
      port map
      (
        clk32				=> clk32,
        clk_DAC			=> clk32,
        reset				=> reset,
        cs					=> cs_sid,
        we					=> sidWr,

        addr				=> cpuAddr(4 downto 0),
        di					=> std_logic_vector(cpudo),
        do					=> sidData_s,

        pot_x				=> sid_pot_x,
        pot_y				=> sid_pot_y,
        audio_out		=> sid_audio_out,
        audio_data	=> sid_audio_data
      );
    sidData <= unsigned(sidData_s);

	end generate GEN_SID;

	GEN_NO_SID : if not C64_HAS_SID generate

    signal sidRandom : unsigned(7 downto 0);

  begin
		-- Emulate reading SID register $1B
		process(clk32)
		begin
			if rising_edge(clk32) then
				if cpuAddr(4 downto 0) = "11011" then
					sidData <= sidRandom;
				else
					sidData <= (others => '0');
				end if;
				if enableCpu = '1' then
					sidRandom <= sidRandom + 17; -- Emulate RND number
				end if;
			end if;
		end process;

	end generate GEN_NO_SID;
	
end architecture;

