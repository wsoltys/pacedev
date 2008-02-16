library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use	ieee.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk         		: in std_logic_vector(0 to 3);
    reset           : in    std_logic;                       
    test_button     : in    std_logic;                       

    -- inputs
    ps2clk          : inout std_logic;                       
    ps2data         : inout std_logic;                       
    dip             : in    std_logic_vector(7 downto 0);    
		jamma						: in JAMMAInputsType;

    -- micro buses
    upaddr          : out   std_logic_vector(15 downto 0);   
    updatao         : out   std_logic_vector(7 downto 0);    

    -- SRAM
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    gfxextra_data   : out std_logic_vector(7 downto 0);

    -- graphics (control)
    red							: out		std_logic_vector(7 downto 0);
		green						: out		std_logic_vector(7 downto 0);
		blue						: out		std_logic_vector(7 downto 0);
		hsync						: out		std_logic;
		vsync						: out		std_logic;

    cvbs            : out   std_logic_vector(7 downto 0);
			  
    -- sound
    snd_rd          : out   std_logic;                       
    snd_wr          : out   std_logic;
    sndif_datai     : in    std_logic_vector(7 downto 0);    

    -- spi interface
    spi_clk         : out   std_logic;                       
    spi_din         : in    std_logic;                       
    spi_dout        : out   std_logic;                       
    spi_ena         : out   std_logic;                       
    spi_mode        : out   std_logic;                       
    spi_sel         : out   std_logic;                       

    -- serial
    ser_rx          : in    std_logic;                       
    ser_tx          : out   std_logic;                       

    -- on-board leds
    leds            : out   std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

  --
  -- COMPONENTS
  --

  component crtc6845s is
    port
    (
      -- INPUT
      I_E         : in std_logic;
      I_DI        : in std_logic_vector(7 downto 0);
      I_RS        : in std_logic;
      I_RWn       : in std_logic;
      I_CSn       : in std_logic;
      I_CLK       : in std_logic;
      I_RSTn      : in std_logic;

      -- OUTPUT
      O_RA        : out std_logic_vector(4 downto 0);
      O_MA        : out std_logic_vector(13 downto 0);
      O_H_SYNC    : out std_logic;
      O_V_SYNC    : out std_logic;
      O_DISPTMG   : out std_logic
    );
  end component crtc6845s;

  --
  -- SIGNALS
  --

  signal reset_n            : std_logic;

  alias clk_16M             : std_logic is clk(0);
  signal clk_8M_en          : std_logic;
  signal clk_4M_en          : std_logic;
  signal clk_2M_en          : std_logic;  -- CPU
  signal clk_1M_en          : std_logic;  -- SAA5050

  -- CPU signals
	alias cpu_clk_en					: std_logic is clk_2M_en;
	signal cpu_a_ext					: std_logic_vector(23 downto 0);
	alias cpu_a								: std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i            : std_logic_vector(7 downto 0);
  signal cpu_d_o            : std_logic_vector(7 downto 0);
	signal cpu_rw_n						: std_logic;
  signal cpu_we             : std_logic;
  signal cpu_nmi_n          : std_logic;
  signal cpu_irq_n          : std_logic;

  -- MOS ROM signals
  signal mos_rom_cs         : std_logic;
  signal mos_rom_d          : std_logic_vector(7 downto 0);

  -- paged ROM signals
  signal paged_rom_r        : std_logic_vector(3 downto 0);
  signal paged_rom_cs       : std_logic;
  signal paged_rom_d        : std_logic_vector(7 downto 0);
  signal rom_12_d           : std_logic_vector(7 downto 0);

  -- RAM signals
  signal ram_cs             : std_logic;
  signal ram_d              : std_logic_vector(7 downto 0);
  signal ram_we             : std_logic;

  -- FRED memory space
  signal fred_cs            : std_logic;
  signal fred_d             : std_logic_vector(7 downto 0);
  signal teletext_cs        : std_logic;
  signal prestel_cs         : std_logic;
  signal ieee488_cs         : std_logic;
  signal acornexp_cs        : std_logic;
  signal cambridge_cs       : std_logic;
  signal winchester_cs      : std_logic;
  signal testhw_cs          : std_logic;
  signal userapp_cs         : std_logic;
  signal jimpage_cs         : std_logic;

  -- JIM memory space
  signal jim_cs             : std_logic;
  signal jim_d              : std_logic_vector(7 downto 0);
  signal jim_page_r         : std_logic_vector(7 downto 0);

  -- SHEILA memory space
  signal sheila_cs          : std_logic;
  signal sheila_d           : std_logic_vector(7 downto 0);
  signal crtc6845_cs        : std_logic;
  signal acia6850_cs        : std_logic;
  signal serialula_cs       : std_logic;
  signal videoula_cs        : std_logic;
  signal pagedrom_cs        : std_logic;
  signal sysvia_cs          : std_logic;
  signal uservia_cs         : std_logic;
  signal fdc8271_cs         : std_logic;
  signal econet_cs          : std_logic;
  signal adc7002_cs         : std_logic;
  signal tubeula_cs         : std_logic;

	signal video_ram_a				: std_logic_vector(14 downto 0);
	signal video_ram_d				: std_logic_vector(7 downto 0);

  signal crtc6845_vsync     : std_logic;

  -- VIA clocks
  signal via6522_p2         : std_logic;
  signal via6522_clk4       : std_logic;

  -- System 6522 VIA $40-$4F (IC3)
  signal sysvia_pa_o        : std_logic_vector(7 downto 0);
  signal sysvia_pa_oe_n     : std_logic_vector(7 downto 0);
  alias kbd_col             : std_logic_vector(3 downto 0) is sysvia_pa_o(3 downto 0);
  alias kbd_row             : std_logic_vector(2 downto 0) is sysvia_pa_o(6 downto 4);
  signal sysvia_pa_i        : std_logic_vector(7 downto 0);
  alias kbd_bit             : std_logic is sysvia_pa_i(7);
  signal sysvia_pb_o        : std_logic_vector(7 downto 0);
  signal sysvia_pb_oe_n     : std_logic_vector(7 downto 0);
  signal sysvia_ca1_i       : std_logic;
  alias vsync_int           : std_logic is sysvia_ca1_i;
  signal sysvia_ca2_i       : std_logic;
  alias kbd_int             : std_logic is sysvia_ca2_i;
  signal sysvia_irq_n       : std_logic;

  -- Addressable Latch (IC32)
  signal addressable_latch  : std_logic_vector(7 downto 0);
  alias shift_led           : std_logic is addressable_latch(7);
  alias caps_led            : std_logic is addressable_latch(6);
  --alias c                   : std_logic_vector(1 downto 0) is addressable_latch(5 downto 4);
  signal c                  : std_logic_vector(1 downto 0);
  alias kbd_we_n            : std_logic is addressable_latch(3);
  alias speech_wr           : std_logic is addressable_latch(2);
  alias speech_rd           : std_logic is addressable_latch(1);
  alias sound_we            : std_logic is addressable_latch(0);

  -- other signals
  signal kbd					      : in8(0 to 16);  
  alias game_reset			    : std_logic is kbd(16)(0);

begin

  -- some simple inversions
  reset_n <= not reset;
  cpu_we <= not cpu_rw_n;

  -- main chip-select logic

  -- RAM $0000-$3FFF (16KB) - mirrored $4000-$7FFF
  ram_cs <=       '1' when STD_MATCH(cpu_a, "0---------------") else '0';
  -- PAGED ROM $8000-$BFFF (16KB)
  paged_rom_cs <= '1' when STD_MATCH(cpu_a, "10--------------") else '0';
  -- MOS ROM $C000-$FFFF (16KB)
  mos_rom_cs <=   '1' when STD_MATCH(cpu_a, "11--------------") else '0';
  -- FRED $FC00-$FCFF
  fred_cs <=      '1' when STD_MATCH(cpu_a, X"FC"&"--------") else '0';
  -- JIM $FD00-$FDFF
  jim_cs <=       '1' when STD_MATCH(cpu_a, X"FD"&"--------") else '0';
  -- SHEILA $FE00-$FEFF
  sheila_cs <=    '1' when STD_MATCH(cpu_a, X"FE"&"--------") else '0';

  -- write-enables
  ram_we <= ram_cs and not cpu_rw_n;

  -- paged rom mux
  paged_rom_d <=  rom_12_d when paged_rom_r = X"C" else
                  (others => '1');

  -- read mux
  cpu_d_i <=  ram_d when ram_cs = '1' else
              paged_rom_d when paged_rom_cs = '1' else
              fred_d when fred_cs = '1' else
              jim_d when jim_cs = '1' else
              sheila_d when sheila_cs = '1' else
              -- MOS ROM must be decoded *after* SHEILA
              mos_rom_d when mos_rom_cs = '1' else
              (others => '1');

  -- interrupt muxes
  cpu_nmi_n <= '1'; -- not used on basic system
  cpu_irq_n <= sysvia_irq_n;

  --
  --  FRED
  --
  BLK_FRED : block

    alias fred_a        : std_logic_vector(7 downto 0) is cpu_a(7 downto 0);

  begin

    teletext_cs <=  fred_cs when STD_MATCH(fred_a, "000100--") else '0';
    -- decode *AFTER* teletext_cs
    prestel_cs <=     fred_cs when STD_MATCH(fred_a, "0001----") else '0';
    ieee488_cs <=     fred_cs when STD_MATCH(fred_a, "00100---") else '0';
    acornexp_cs <=    fred_cs when STD_MATCH(fred_a, "00101---") else '0';
    cambridge_cs <=   fred_cs when STD_MATCH(fred_a, "0011----") else '0';
    winchester_cs <=  fred_cs when STD_MATCH(fred_a, "01000---") else '0';
    testhw_cs <=      fred_cs when STD_MATCH(fred_a, "1000----") else '0';
    userapp_cs <=     fred_cs when STD_MATCH(fred_a, "11------") else '0';
    -- decode *before* userapp_cs
    jimpage_cs <=     fred_cs when STD_MATCH(fred_a, "11111111") else '0';

    -- registers
    process (clk_16M, cpu_clk_en, reset)
    begin
      if reset = '1' then
        jim_page_r <= (others => '0');
      elsif rising_edge(clk_16M) then
        if cpu_clk_en = '1' then
          if jimpage_cs = '1' then
            if cpu_rw_n = '0' then
              jim_page_r <= cpu_d_o;
            end if; -- cpu_rw_n
          end if; -- jimpage_cs
        end if; -- cpu_clk_en
      end if;
    end process;

    fred_d <= jim_page_r when jimpage_cs = '1' else 
              X"FF"; -- *MUST* return $FF

  end block BLK_FRED;

  --
  --  JIM
  --
  BLK_JIM : block
  begin

    jim_d <= X"FF"; -- *MUST* return $FF

  end block BLK_JIM;

  --
  --  SHEILA
  --
  BLK_SHEILA : block

    alias sheila_a      : std_logic_vector(7 downto 0) is cpu_a(7 downto 0);

    signal sysvia_d     : std_logic_vector(7 downto 0);
    signal sysvia_oe_n  : std_logic;

  begin

    crtc6845_cs <=  sheila_cs when STD_MATCH(sheila_a, "00000---") else '0';
    acia6850_cs <=  sheila_cs when STD_MATCH(sheila_a, "00001---") else '0';
    serialula_cs <= sheila_cs when STD_MATCH(sheila_a, "0001----") else '0';
    videoula_cs <=  sheila_cs when STD_MATCH(sheila_a, "0010----") else '0';
    pagedrom_cs  <= sheila_cs when STD_MATCH(sheila_a, "0011----") else '0';
    sysvia_cs <=    sheila_cs when STD_MATCH(sheila_a, "010-----") else '0';
    uservia_cs <=   sheila_cs when STD_MATCH(sheila_a, "011-----") else '0';
    fdc8271_cs <=   sheila_cs when STD_MATCH(sheila_a, "100-----") else '0';
    econet_cs <=    sheila_cs when STD_MATCH(sheila_a, "101-----") else '0';
    adc7002_cs <=   sheila_cs when STD_MATCH(sheila_a, "110-----") else '0';
    tubeula_cs <=   sheila_cs when STD_MATCH(sheila_a, "111-----") else '0';

    sheila_d <= EXT(paged_rom_r, sheila_d'length) when pagedrom_cs = '1' else
                sysvia_d when sysvia_cs = '1' else
                X"FE"; -- *MUST* return $FE

    -- paged ROM process
    process (clk_16M, cpu_clk_en, reset)
    begin
      if reset = '1' then
      elsif rising_edge (clk_16M) then
        if cpu_clk_en = '1' then
          if pagedrom_cs = '1' then
            if cpu_rw_n = '0' then
              paged_rom_r <= cpu_d_o(paged_rom_r'range);
            end if; -- cpuo_rw_n
          end if; -- pagedrom_cs
        end if; -- cpu_clk_en
      end if;
    end process;

    -- keyboard scan process
    process (clk_16M, clk_1M_en, reset)
      variable col : std_logic_vector(3 downto 0);
    begin
      if reset = '1' then
        col := (others => '0');
      elsif rising_edge(clk_16M) then
        if clk_1M_en = '1' then
          -- autoscan only if kbd_we not asserted
          if kbd_we_n = '1' then
            kbd_int <= '0';
            col := col + 1;
            if kbd(conv_integer(col))(7 downto 1) /= "0000000" then
              -- generate interrupt via CA2 of the system VIA
              kbd_int <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;

    -- keyboard selector/mux (74LS251)
    kbd_bit <=  '0' when kbd_we_n = '1' else
                kbd(conv_integer(kbd_col))(conv_integer(kbd_row));
    -- the remainder of the bits *MUST* be 0 for keyboard logic to work
    sysvia_pa_i(6 downto 0) <= sysvia_pa_o(6 downto 0);

    sysvia_inst : entity work.M6522
      port map
      (
        RS              => cpu_a(3 downto 0),
        DATA_IN         => cpu_d_o,
        DATA_OUT        => sysvia_d,
        DATA_OUT_OE_L   => sysvia_oe_n,

        RW_L            => cpu_rw_n,
        CS1             => sysvia_cs,
        CS2_L           => '0',

        IRQ_L           => sysvia_irq_n,

        -- port a
        CA1_IN          => vsync_int,
        CA2_IN          => kbd_int,
        CA2_OUT         => open,
        CA2_OUT_OE_L    => open,

        PA_IN           => sysvia_pa_i,     -- keyboard
        PA_OUT          => sysvia_pa_o,     -- keyboard
        PA_OUT_OE_L     => sysvia_pa_oe_n,

        -- port b
        CB1_IN          => '0', -- ADC end-of-conversion
        CB1_OUT         => open,
        CB1_OUT_OE_L    => open,

        CB2_IN          => '1', -- light-pen strobe
        CB2_OUT         => open,
        CB2_OUT_OE_L    => open,

        PB_IN           => "11111111",      -- speech, joystick fire (active low)
        PB_OUT          => sysvia_pb_o,     -- system latch
        PB_OUT_OE_L     => sysvia_pb_oe_n,

        RESET_L         => reset_n,
        P2_H            => via6522_p2,      -- high for phase 2 clock  ____----__
        CLK_4           => via6522_clk4     -- 4x system clock (4HZ)   _-_-_-_-_-
      );

    -- 74LS259 addressable latch (IC32)
    process (clk_16M, clk_1M_en, reset)
    begin
      if reset = '1' then
        addressable_latch <= (others => '0');
      elsif rising_edge(clk_16M) then
        if clk_1M_en = '1' then
          addressable_latch(conv_integer(sysvia_pb_o(2 downto 0))) <= sysvia_pb_o(3);
        end if;
      end if;
    end process;
    -- temp fudge for now
    c <= "01";

  end block BLK_SHEILA;

  -- unused outputs
  gfxextra_data <= (others => '0');
  cvbs <= (others => '0');
  snd_rd <= '0';
  snd_wr <= '0';
  spi_clk <= '0';
  spi_dout <= '0';
  spi_ena <= '0';
  spi_mode <= '0';
  spi_sel <= '0';
  ser_tx <= '0';
  leds <= (others => '0');

  --
  --  COMPONENT INSTANTIATION
  --

	cpu_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> reset_n,
			Enable  		=> clk_2M_en,
			Clk     		=> clk_16M,
			Rdy     		=> '1',
			Abort_n 		=> '1',
			IRQ_n   		=> cpu_irq_n,
			NMI_n   		=> cpu_nmi_n,
			SO_n    		=> '1',
			R_W_n   		=> cpu_rw_n,
			Sync    		=> open,
			EF      		=> open,
			MF      		=> open,
			XF      		=> open,
			ML_n    		=> open,
			VP_n    		=> open,
			VDA     		=> open,
			VPA     		=> open,
			A       		=> cpu_a_ext,
			DI      		=> cpu_d_i,
			DO      		=> cpu_d_o
		);

  BLK_VIDEO : block

    -- CRTC6545 signals
    signal crtc6845_clk       : std_logic;
    signal crtc6845_e         : std_logic;
    signal crtc6845_cs_n      : std_logic;
	  signal crtc6845_ra        : std_logic_vector(4 downto 0);
	  signal crtc6845_ma        : std_logic_vector(13 downto 0);
    signal crtc6845_disptmg   : std_logic;
    signal crtc6845_hsync     : std_logic;
    signal crtc6845_vsync     : std_logic;

    -- SAA5050 signals
    signal saa5050_dew        : std_logic;
    signal saa5050_de         : std_logic;

    signal video_ULA_de       : std_logic;
		signal video_r				    : std_logic_vector(0 downto 0);
		signal video_g				    : std_logic_vector(0 downto 0);
		signal video_b				    : std_logic_vector(0 downto 0);

  begin

    BLK_VIDEO_ULA : block

			signal control_r		: std_logic_vector(7 downto 0);
			alias flash_r				: std_logic is control_r(0);
			alias teletext_r		: std_logic is control_r(1);
			alias cpl_r					: std_logic_vector(1 downto 0) is control_r(3 downto 2);	-- 10/20/40/80
			alias clk_rate_r		: std_logic is control_r(4);                              -- 1/2MHz
			alias cursor_w_r		: std_logic_vector(1 downto 0) is control_r(6 downto 5);	-- 1/NA/2/4
			alias m_cursor_w_r	: std_logic is control_r(7);

			signal palette_r		: std_logic_vector(7 downto 0);
			alias log_clr_r			: std_logic_vector(3 downto 0) is palette_r(7 downto 4);
			alias act_clr_r			: std_logic_vector(3 downto 0) is palette_r(3 downto 0);

    begin

      -- clock generation - phase-aligned
      process (clk_16M, reset)
        variable count : std_logic_vector(3 downto 0);
      begin
        if reset = '1' then
          count := (others => '0');
					via6522_p2 <= '0';
					via6522_clk4 <= '0';
        elsif rising_edge(clk_16M) then
          clk_8M_en <= '0';
          clk_4M_en <= '0';
          clk_2M_en <= '0';
          clk_1M_en <= '0';
          if count(0) = '0' then
            clk_8M_en <= '1';
            if count(1) = '0' then
              clk_4M_en <= '1';
              if count(2) = '0' then
                clk_2M_en <= '1';
                if count(3) = '0' then
                  clk_1M_en <= '1';
                end if;
              end if;
            end if;
          end if;
          count := count + 1;
          -- clocks for 6522
          -- P2 must lead cpu_clk_en by 1 system clock
          -- - and is same frequency as cpu_clk but 50% duty cycle
          -- clk4 goes low on rising edge of P2
					if count(2 downto 0) = "000" then
          	via6522_p2 <= '1';
					elsif count(2 downto 0) = "100" then
						via6522_p2 <= '0';
					end if;
          via6522_clk4 <= not clk_8M_en;
        end if;
      end process;

      -- registers
      process (clk_16M, reset)
      begin
        if reset = '1' then
					-- MODE 6
					control_r <= X"88"; --(others => '0');
					palette_r <= (others => '0');
        elsif rising_edge(clk_16M) then
					if cpu_clk_en = '1' then
						if videoula_cs = '1' then
              if cpu_rw_n = '0' then
                case cpu_a(0) is
                  when '0' =>
                    control_r <= cpu_d_o;
                  when others =>
                    palette_r <= cpu_d_o;
                end case;
              end if; -- cpu_rw_n
						end if; -- videoula_cs
					end if; -- cpu_clk_en
        end if;
      end process;

			-- de-serialiser
			process (clk_16M, reset)
				variable video_data : std_logic_vector(7 downto 0) := (others => '0');
			begin
				if reset = '1' then
					video_data := (others => '0');
				elsif rising_edge(clk_16M) then
					if clk_1M_en = '1' then
						-- latch data
						video_data := video_ram_d;
					elsif clk_8M_en = '1' then
						-- rotate
						video_data := video_data(6 downto 0) & '0';
					end if;
				end if;
				-- assign RGB outputs
				video_r(video_r'left) <= video_data(video_data'left);
				video_g(video_g'left) <= video_data(video_data'left);
				video_b(video_b'left) <= video_data(video_data'left);
			end process;

      -- the CRTC6845 implementation is not synchronous!!!
      --crtc6845_clk <= clk_1M_en when clk_rate_r = '0' else clk_2M_en;
      crtc6845_clk <= clk_1M_en;

    end block BLK_VIDEO_ULA;

    -- needs inverted CS
    crtc6845_cs_n <= not crtc6845_cs;
    crtc6845_e <= not cpu_clk_en;

    crtc6845s_inst : crtc6845s
      port map
      (
        -- INPUT
        I_E         => crtc6845_e,
        I_DI        => cpu_d_o,
        I_RS        => cpu_a(0),
        I_RWn       => '1', --cpu_rw_n,
        I_CSn       => crtc6845_cs_n,
        I_CLK       => crtc6845_clk,
        I_RSTn      => reset_n,

        -- OUTPUT
        O_RA        => crtc6845_ra,
        O_MA        => crtc6845_ma,
        O_H_SYNC    => crtc6845_hsync,
        O_V_SYNC    => crtc6845_vsync,
        O_DISPTMG   => crtc6845_disptmg
      );

    -- enable output of the video ULA
    video_ULA_de <= crtc6845_disptmg and not crtc6845_ra(3);

    -- interrupt set on negative edge of VSYNC
    -- according to the schematics, the VSYNC output (active high)
    --   from 6845 is connected directly to the CA1 input of the 6522
    --   - so the interrupt will happen at the _end_ of VSYNC
    vsync_int <= crtc6845_vsync;

    BLK_VIDADDR : block

      signal b  : std_logic_vector(4 downto 1);
      signal s  : std_logic_vector(4 downto 1);

    begin

      -- IC36/40/27
      b(1) <= not (c(0) and c(1) and crtc6845_ma(12));
      b(2) <= not (c(1) and b(3) and crtc6845_ma(12));
      b(3) <= c(0) nand crtc6845_ma(12);
      b(4) <= b(3) nand crtc6845_ma(12);

      -- IC39 (74LS283)
      s <= crtc6845_ma(11 downto 8) + b + 1;

      -- MA13=0 (hires), MA13=1 (teletext)
      video_ram_a <=  s(4) & "1111" & crtc6845_ma(9 downto 0) when crtc6845_ma(13) = '1' else
                      s & crtc6845_ma(7 downto 0) & crtc6845_ra(2 downto 0);

    end block BLK_VIDADDR;

    saa505x_inst : entity work.saa505x
      port map
      (
        clk				=> clk(0),
        reset			=> reset,

        si_i_n		=> '0',               -- hard-wired text mode
        si_o			=> open,              -- not used
        data_n		=> '0',               -- not used
        d					=> (others => '0'),
        dlim			=> '0',               -- not used
        glr				=> '0',               -- not used
        dew				=> saa5050_dew,
        crs				=> '0',
        bcs_n			=> '1',
        tlc_n			=> open,
        tr6				=> '0',
        f1				=> '0',
        y					=> open,
        b					=> open,
        g					=> open,
        r					=> open,
        blan			=> open,
        lose			=> '0',
        po				=> '0',
        de				=> saa5050_de
      );

    -- drive VGA outputs
    -- fudge for now
    hsync <= not crtc6845_hsync;
    vsync <= not crtc6845_vsync;
    red <= (others => video_r(video_r'left)) when video_ULA_de = '1' else (others => '0');
    green <= (others => video_g(video_g'left)) when video_ULA_de = '1' else (others => '0');
    blue <= (others => video_b(video_b'left)) when video_ULA_de = '1' else (others => '0');

  end block BLK_VIDEO;

	inputs_inst : entity work.inputs
		generic map
		(
			NUM_INPUTS	=> kbd'length,
			CLK_1US_DIV	=> BBC_1MHz_CLK0_COUNTS
		)
	  port map
	  (
	    clk     		=> clk_16M,
	    reset   		=> reset,
	    ps2clk  		=> ps2clk,
	    ps2data 		=> ps2data,
			jamma				=> jamma,

	    dips				=> (others => '0'),
	    inputs			=> kbd
	  );

  --
  --  MEMORIES
  --

  mos_rom_inst : entity work.mos_rom
    port map
    (
      clock		    => clk_16M,
      address		  => cpu_a(13 downto 0),
      q		        => mos_rom_d
    );

  -- ROM 12
  basic_rom_inst : entity work.basic_rom
    port map
    (
      clock		    => clk_16M,
      address		  => cpu_a(13 downto 0),
      q		        => rom_12_d
    );

	-- this is a fudge for now...
	dram_inst : entity work.dpram
    generic map
    (
			init_file => "dram.hex",
			numwords_a => 16384,
			widthad_a => 14
    )
		port map
		(
			clock_b				=> cpu_clk_en,
			address_b			=> cpu_a(13 downto 0),
			data_b				=> cpu_d_o,
			wren_b				=> ram_we,
			q_b						=> ram_d,

			clock_a				=> clk_16M,
			address_a			=> video_ram_a(13 downto 0),
			data_a				=> (others => '0'),
			wren_a				=> '0',
			q_a						=> video_ram_d
		);
		
end SYN;
