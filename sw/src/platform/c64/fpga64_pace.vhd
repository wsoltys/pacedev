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
-- The CPU runs in the next 4 cycles. Effective cpu speed is 1 Mhz.
-- The next 4 cycles are for IEC read and write.
-- 20 bus cycles unused.
-- 
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
library work;
use work.platform_pkg.all;
use work.project_pkg.all;

-- -----------------------------------------------------------------------

entity fpga64_pace is
	generic (
		resetCycles: integer := 15
	);
	port(
		clk50: in std_logic;
		clk32: in std_logic;
		reset_button: in std_logic;

		-- keyboard interface (use any ordinairy PS2 keyboard)
		kbd_clk: in std_logic;
		kbd_dat: in std_logic;

		video_select: in std_logic;

		-- external memory, since the 64K RAM is relatively big to implement in a FPGA
		ramAddr: out unsigned(16 downto 0);
		ramData_i: in unsigned(7 downto 0);
		ramData_o: out unsigned(7 downto 0);
		ramData_oe: out std_logic;

		ramCE: out std_logic;
		ramWe: out std_logic;
		ramOe: out std_logic;
				
		hsync: out std_logic;
		vsync: out std_logic;
		r : out unsigned(7 downto 0);
		g : out unsigned(7 downto 0);
		b : out unsigned(7 downto 0);


		-- joystick interface
		joyA: in unsigned(5 downto 0);
		joyB: in unsigned(5 downto 0);

		-- serial port, for connection to pheripherals
    serioclk		  : out   std_logic;
    ces		          : out   std_logic_vector(3 downto 0);

		leds: out unsigned(7 downto 0);
		-- video-out connect the FPGA to your PAL-monitor, using the CVBS-input
		cvbsOutput: out unsigned(4 downto 0);
		
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

architecture Behavioral of fpga64_pace is
	component fpga64_rgbcolor is
		port (
			index: in unsigned(3 downto 0);
			r: out unsigned(7 downto 0);
			g: out unsigned(7 downto 0);
			b: out unsigned(7 downto 0)
		);
	end component;

	component io_ps2_keyboard
		port (
			clk: in std_logic;
			kbd_clk: in std_logic;
			kbd_dat: in std_logic;

			interrupt: out std_logic;
			scanCode: out unsigned(7 downto 0)
		);
	end component;

signal endOfCycle : std_logic;
signal busCycle: unsigned(5 downto 0);
signal lastCycleVic : std_logic;
signal phi0_cpu : std_logic;
signal phi0_vic : std_logic;
signal ramData_o_s	: unsigned(7 downto 0);
signal ramData_oe_s	: std_logic;

	signal ba: std_logic;
	signal irq_n: std_logic;
	signal nmi_n: std_logic;

	signal cpuGetsBus : std_logic;
	signal enableCpu: std_logic;
	signal enableVic : std_logic;
	signal enableBus : std_logic;

	signal irq_cia1: std_logic;
	signal irq_cia2: std_logic;
	signal irq_vic: std_logic;

	signal ramData_to_bus : unsigned(7 downto 0);
	signal systemWe: std_logic;
	signal pulseWrRam: std_logic;
	signal pulseWrIo: std_logic;
	signal pulseRd: std_logic;
	signal colorWe : std_logic;
	signal systemAddr: unsigned(16 downto 0);

	signal cs_vic: std_logic;
	signal cs_sid: std_logic;
	signal cs_color: std_logic;
	signal cs_cia1: std_logic;
	signal cs_cia2: std_logic;
	signal cs_ram: std_logic;
	signal cselWe: std_logic;

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

	signal sidWriteData: unsigned(7 downto 0);
	signal sidData: unsigned(7 downto 0);
	signal sidRandom : unsigned(7 downto 0);
	
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

	signal SIDaddr: unsigned(4 downto 0);
	signal SIDWr: std_logic;
	signal SIDpostWr: std_logic;

-- video
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
signal hSyncPolarity : std_logic;
signal vSyncPolarity : std_logic;

signal videoConfigVideo : std_logic;
signal videoConfigDim : std_logic;
signal videoConfigShow : std_logic;
signal videoConfigTimeout : unsigned(19 downto 0);

-- keep ModelSim happy
signal notNtscMode : std_logic;
	
begin
	fpga64_busTiming_instance : entity work.fpga64_busTiming(rtl)
		generic map (
			resetCycles => 15,
			noofBusCycles => 32
--			noofBusCycles => 34
		)
		port map (
			clkIn => clk32,
			rstIn => '0',
			rstOut => open,
			endOfCycle => endOfCycle,
			busCycle => busCycle
		);

	myScanDoubler: entity work.fpga64_scandoubler
		generic map (
			videoWidth => 4
		)
		port map (
			clk => clk32,
			hSyncPolarity => hSyncPolarity,
			vSyncPolarity => vSyncPolarity,
			video_in => vicColorIndex,
			hsync_in => vicHSync,
			vsync_in => vicVSync,
			video_out => vgaColorIndex,
			hsync_out => vgaHSync,
			vsync_out => vgaVSync			
		);
	
	c64colors: entity work.fpga64_rgbcolor
		port map (
			index => vgaColorIndex,
			r => vgaR,
			g => vgaG,
			b => vgaB
		);

	colorram: entity work.fpga64_singleram
		generic map (
			ramWidth => 4,
			ramDepthBits => 10
		)
		port map (
			clk => clk32,
			we => colorWe,
			addr => systemAddr(9 downto 0),
			di => cpuDo(3 downto 0),
			do => colorData
		);
	colorWe <= (cs_color and pulseWrRam);

	buslogic: entity work.fpga64_buslogic_roms
		port map (
			clk => clk32,
			reset => reset,
			ena => enableBus,
			busCycle => busCycle,
			cpuGetsBus => cpuGetsBus,

			bankSwitch => cpuIO(2 downto 0),

			ramData => ramData_to_bus,

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
			pulseWr => pulseWrRam,
			systemAddr(15 downto 0) => systemAddr(15 downto 0),
			dataToCpu => cpuDi,
			dataToVic => vicDi,

			cs_vic => cs_vic,
			cs_sid => cs_sid,
			cs_color => cs_color,
			cs_cia1 => cs_cia1,
			cs_cia2 => cs_cia2,
			cs_ram => cs_ram
		);
	systemAddr(16) <= '0';

  notNtscMode <= not ntscMode;
	
	vic: entity work.vicii_6567_6569
		generic map (
			graphicsEnabled => '1'
		)			
		port map (
			clk => clk32,
			enablePixel => enableVic,
			enableData => enableVic,
			endOfCycle => lastCycleVic,
			phi0_cpu => phi0_cpu,
			phi0_vic => phi0_vic,
			mode6569 => notNtscMode,
			mode6567old => '0',
			mode6567R8 => ntscMode,
			
			cs => cs_vic,
			we => pulseWrIo,
			rd => pulseRd,
			lp_n => cia1_pbi(4),

			aRegisters => cpuAddr(5 downto 0),
			diRegisters => cpuDo,
			di => vicDi,
			diColor => colorData,
			do => vicData,

			ba => ba,
			vicAddr => vicAddr(13 downto 0),
--			vid_di => (others => '0'),
			
			hsync => vicHSync,
			vsync => vicVSync,
			colorIndex => vicColorIndex,

			irq_n => irq_vic
		);

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

	cpu: entity work.cpu_6510
		port map (
			clk => clk32,
			reset => reset,
			enable => enableCpu,
			nmi_n => nmi_n,
			irq_n => irq_n,

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

	myKeyboard: entity work.io_ps2_keyboard
		port map (
			clk => clk32,
			kbd_clk => kbd_clk,
			kbd_dat => kbd_dat,
			interrupt => newScanCode,
			scanCode => theScanCode
		);

  BLK_JOYKEY : block

    signal joyA_n : unsigned(4 downto 0);
    signal joyB_n : unsigned(4 downto 0);

	begin
	
		-- make ModelSim happy
    joyA_n <= not JoyA(joyA_n'range);
    joyB_n <= not JoyA(joyB_n'range);

  	myKeyboardMatrix: entity work.fpga64_keyboard_matrix
  		port map (
  			clk => clk32,
				reset => reset,
  			theScanCode => theScanCode,
  			newScanCode => newScanCode,
  
  			joyA => joyA_n(4 downto 0),
  			joyB => joyB_n(4 downto 0),
  			pai => cia1_pao,
  			pbi => cia1_pbo,
  			pao => cia1_pai,
  			pbo => cia1_pbi,
  			
  			videoKey => videoKey,
  			traceKey => traceKey,
  			trace2Key => trace2Key,

  			backwardsReadingEnabled => '0'
  		);
  
  end block BLK_JOYKEY;

	GEN_SID : if C64_HAS_SID generate
		
		BLK_SID : block
		
			signal sidData_s 	: std_logic_vector(sidData'range);
			
		begin
		
			sid_inst : entity work.sid6581
				port map
				(
					clk32				=> clk32,
					clk_DAC			=> clk32,
					reset				=> reset,
					cs					=> cs_sid,
					we					=> SIDpostWr,

					addr				=> SIDaddr,
					di					=> std_logic_vector(sidWriteData),
					do					=> sidData_s,

					pot_x				=> sid_pot_x,
					pot_y				=> sid_pot_y,
					audio_out		=> sid_audio_out,
					audio_data	=> sid_audio_data
				);
			sidData <= unsigned(sidData_s);

		end block BLK_SID;

	end generate GEN_SID;
			
	-- Reset, clock and bus timing
	process(clk32, reset_button)
	begin
		if rising_edge(clk32) then
			if busCycle(5 downto 0)="001000" OR busCycle(5 downto 0)="001001" then
				serioclk <= '0'; --for iec write
			else
				serioclk <= '1';	
			end if;	
			if busCycle(5 downto 2)>"0001" and busCycle(5 downto 2)<"0110" then
				SIDclk <= '1'; --for SIDclk 120ns befor CSEL, because 20-80ns latenz into the gbridge
			else
				SIDclk <= '0';	
			end if;	
			if (endOfCycle = '1') then
				if reset_cnt = resetCycles then
					reset <= '0';
				else
					reset <= '1';
					reset_cnt <= reset_cnt + 1;
				end if;
			end if;
			if reset_button = '1' then
				reset_cnt <= 0;
			end if;
		end if;
	end process;
	
	-- Video modes
	process(clk32)
	begin
		if rising_edge(clk32) then
			if videoKey = '1' then
				ntscMode <= not ntscMode;
				if ntscMode = '1' then
					hSyncPolarity <= not hSyncPolarity;
					if hSyncPolarity = '1' then
						vSyncPolarity <= not vSyncPolarity;
					end if;
				end if;
				videoConfigTimeout <= (others => '1');
			end if;
			if endOfCycle = '1' then
				videoConfigShow <= '0';
				if videoConfigTimeout /= 0 then
					videoConfigTimeout <= videoConfigTimeout - 1;
					videoConfigShow <= '1';
				end if;
			end if;				
		end if;
	end process;

  GEN_VIDEO_CONFIG : if false generate
	
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
  			hSyncPolarity => hSyncPolarity,
  			vSyncPolarity => vSyncPolarity
  		);

  end generate GEN_VIDEO_CONFIG;

	-- XXX CN modified this for split data in/out without testing
	GEN_ORIGINAL_CONE : if false generate
	
		mainMemoryBus: process(cs_ram, systemWe, pulseWrRam, systemAddr)
		begin
			-- Defaults to prevent latches
			ramAddr <= (others => '0');
			ramdata_o_s <= (others => '0');
			ramdata_oe_s <= '0';
			cselWe <= '1';
			if (systemWe = '1') and (phi0_cpu = '1') then
				ramData_o_s <= cpuDo;
				ramdata_oe_s <= '1';
				ramAddr <= systemAddr;
			elsif (phi0_cpu = '1') or (phi0_vic = '1') then
				ramAddr <= systemAddr;
			elsif busCycle(5 downto 1)=B"00101" then --IEC write
				ramdata_o_s(5)<= cia2_pao(5);
				ramdata_o_s(4)<= cia2_pao(4);
				ramdata_o_s(3)<= cia2_pao(3);
				ramdata_o_s(2)<= '0'; --lptstrobe
				ramdata_oe_s <= '1';
				cselWe <= '0';		--auf iecbus schreiben;
			elsif SIDwr = '0' then
				ramdata_o_s <= sidWriteData;	
				ramdata_oe_s <= '1';
				ramAddr(4 downto 0) <= SIDaddr;
			end if;

			ramCE <= '1';
			ramWe <= '1';
			if (phi0_vic = '1') or (phi0_cpu = '1') then
				if cs_ram = '1' then
					if systemWe = '0' then
						ramCE <= '0';
					end if;
					if pulseWrRam = '1' then
						ramCE <= '0';
						ramWe <= '0';
					end if;
				end if;
			elsif (cselWe = '0') or (SIDwr = '0') then
				ramWe <= '0';
			end if;
		end process;

	end generate GEN_ORIGINAL_CONE;
	
	mainMemoryBus: process (cs_ram, systemWe, pulseWrRam, cpuDo, systemAddr)
  begin
  	if systemWe = '1' then
    	ramdata_o_s <= cpudo;
			ramdata_oe_s <= '1';
    else
      ramdata_o_s <= (others => '0');
			ramdata_oe_s <= '0';
    end if;
		ramOE <= (not cs_ram) or systemWe;
    ramCE <= not cs_ram;
    ramWE <= not (cs_ram and pulseWrRam);
    ramAddr <= systemAddr;

  end process;

	serialBus: process(sb_data_in, sb_clk_in, cia2_pao)
	begin
		-- output (always drives '0')
		sb_data_oe <= cia2_pao(5);
		sb_clk_oe <= cia2_pao(4);
		sb_atn_oe <= cia2_pao(3);
		-- input
		cia2_pai(7) <= sb_data_in;
		cia2_pai(6) <= sb_clk_in;
	end process;
	
	--serialBus and SID
	serialBus_cone: process(clk32,cia2_pao,busCycle)
	begin
		still <= X"4000";
 		ces <= "1111";
		SIDwr<='1';
		if busCycle(5 downto 2)=B"0010" then
		 	ces<="1011";--iec port
			if rising_edge(clk32) then
				if busCycle(1 downto 0)="01" then
					-- removed MMc
					--cia2_pai(7) <= ramdata(7);
					--cia2_pai(6) <= ramdata(6);
				end if;	
			end if;
		end if;
		if busCycle(5 downto 4)="01" and SIDpostwr='1' then
		 	ces<="0011";--SID 1
			SIDwr<='0';
		end if;
		if rising_edge(clk32) then	--CPU write into SID
			if (cs_sid='1') and (pulseWrRam='1') and (phi0_cpu = '1') then
				SIDaddr <= cpuAddr(4 downto 0);
			  	sidWriteData <= cpudo;
				SIDpostwr <= '1';
			end if;
			if busCycle(5 downto 2)=B"0111" then
				SIDpostwr <= '0';
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
	
	GEN_NO_SID : if not C64_HAS_SID generate
	
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
			lastCycleVic <= '0';
			enableVic <= '0';
			enableCpu <= '0';
			enableCia <= '0';
			enableBus <= '0';
			pulseWrIo <= '0';
			pulseRd <= '0';
			if busCycle = "011110" then
				lastCycleVic <= '1';
			end if;
			if busCycle(5) = '0' then
				if busCycle(1 downto 0) = "10" then
					enableVic <= '1';
					enableBus <= '1';
					if phi0_cpu = '1' then
						enableCia <= '1';
						if (ba = '1') or (cpuWe = '1') then
							enableCpu <= '1';
						end if;
						if cpuWe = '1' then
							pulseWrIo <= '1';
						else
							pulseRd <= '1';
						end if;
					end if;
				end if;
			end if;				
			if busCycle(1 downto 0) = "11" then
				phi0_vic <= '0';
				phi0_cpu <= '0';
				if phi0_vic = '1' then
					phi0_cpu <= '1';
				end if;
			end if;
			if endOfCycle = '1' then
				phi0_vic <= '1';
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

	process(clk32)
	begin
		if rising_edge(clk32) then
			r <= vgaR;
			g <= vgaG;
			b <= vgaB;
--			if videoConfigShow = '1' and videoConfigDim = '1' then
--			if videoConfigDim = '1' then
--				r <= videoConfigVideo & vgaR(7 downto 1);
--				g <= videoConfigVideo & vgaG(7 downto 1);
--				b <= videoConfigVideo & vgaB(7 downto 1);
--			end if;
--			if vgaDebugDim = '1' then
--				r <= vgaDebug & vgaR(7 downto 1);
--				g <= vgaDebug & vgaG(7 downto 1);
--				b <= vgaDebug & vgaB(7 downto 1);
--			end if;				
		end if;
	end process;
	hSync <= vgaHSync;
	vSync <= vgaVSync;

	leds <= (others => '0');
	cvbsOutput <= (others => '0');

  GEN_HEXY : if false generate		

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

  end generate GEN_HEXY;

	cia2_pai(5 downto 0) <= cia2_pao(5 downto 0);
	cia2_pbi(7 downto 0) <= cia2_pbo;

	vicAddr(14) <= (not cia2_pao(0));
	vicAddr(15) <= (not cia2_pao(1));

	cpuGetsBus <= phi0_vic and (ba or cpuWe);
	
	-- ramData arbitration
	ramData_to_bus <= ramData_i when ramData_oe_s = '0' else ramData_o_s;
	ramData_o <= ramData_o_s;
	
	irq_n <= irq_cia1 and irq_vic;
	nmi_n <= irq_cia2;
end Behavioral;

