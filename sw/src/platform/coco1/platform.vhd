
--
--  TO DO:
--
--  - add volume control to output - target-specific
--  - add support for cassette input
--  - tidy-up 6847 code, and test CVBS
--  - more complex artifacting support
--  - test semi-graphics and tidy-up 6883
--  - add support for high speed poke?
--  - add mouse support
--  - add hires joystick support (CocoMax?)
--  - add floppy disk support (WD177X)
--  - add deluxe RS232 support
--  - add Orchestra-90 support
--  - add multi-pak support?
--  - add OSD control panel
--

library ieee;
use ieee.std_logic_1164.all;
use	ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.kbd_pkg.all;
use work.video_controller_pkg.to_VIDEO_t;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity platform is
  generic
  (
    NUM_INPUT_BYTES   : integer
  );
  port
  (
    -- clocking and reset
    clkrst_i          : in from_CLKRST_t;

    -- misc I/O
    buttons_i         : in from_BUTTONS_t;
    switches_i        : in from_SWITCHES_t;
    leds_o            : out to_LEDS_t;

    -- controller inputs
    inputs_i          : in from_MAPPED_INPUTS_t(0 to NUM_INPUT_BYTES-1);
    jamma_i           : in from_JAMMA_t;
    analogue_i        : in analogue_in_a(1 to 4);
    
    -- FLASH/SRAM
    flash_i           : in from_FLASH_t;
    flash_o           : out to_FLASH_t;
		sram_i					  : in from_SRAM_t;
		sram_o					  : out to_SRAM_t;
    sdram_i           : in from_SDRAM_t;
    sdram_o           : out to_SDRAM_t;

    -- graphics (control)
    video_o           : out to_VIDEO_t;

    -- OSD
    osd_i             : in from_OSD_t;
    osd_o             : out to_OSD_t;

    -- sound
    audio_i           : in from_AUDIO_t;
    audio_o           : out to_AUDIO_t;
    
    -- SPI (flash)
    spi_i             : in from_SPI_t;
    spi_o             : out to_SPI_t;

    -- serial
    ser_i             : in from_SERIAL_t;
    ser_o             : out to_SERIAL_t;

    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );
end entity platform;

--
--  Buttons
--    0: system-wide reset
--    1: platform reset
--    2: cpu reset
--  Switches
--    7   Swap joytick left/right
--    6   Artifacting enable
--    5   Cassette output to speaker
--    4:  CART#
--    3:0 Flash 16KB bank select
--

architecture SYN of platform is

	alias clk_57M272			  : std_logic is clkrst_i.clk(0);
	alias rst_57M272        : std_logic is clkrst_i.rst(0);

	-- clocks
	signal clk_14M318_ena   : std_logic := '0';
	signal clk_q            : std_logic := '0';
	signal clk_e            : std_logic := '0';

  signal target_rst       : std_logic := '0';
  signal platform_rst     : std_logic := '0';
	signal cpu_rst			    : std_logic := '0';
	
	-- clock helpers
  signal vdgclk           : std_logic;

	-- multiplexed address
	signal ma							  : std_logic_vector(7 downto 0);

  signal vdg_data         : std_logic_vector(7 downto 0);
  signal vdg_y            : std_logic_vector(3 downto 0);						
  signal vdg_x            : std_logic_vector(4 downto 0);
  signal vdg_css          : std_logic;
  signal vdg_intn_ext     : std_logic;
  signal vdg_gm           : std_logic_vector(2 downto 0);
  signal vdg_an_g         : std_logic;

  signal r_s              : std_logic_vector(7 downto 0);
  signal g_s              : std_logic_vector(7 downto 0);
  signal b_s              : std_logic_vector(7 downto 0);
  signal hs_s             : std_logic;
  signal vs_s             : std_logic;
  
  -- uP signals  
  alias cpu_clk           : std_logic is clk_e;
  signal cpu_clk_n        : std_logic;
  signal cpu_a            : std_logic_vector(15 downto 0);
  signal cpu_d_i          : std_logic_vector(7 downto 0);
  signal cpu_d_o          : std_logic_vector(7 downto 0);
  signal cpu_r_wn				  : std_logic;
  signal cpu_vma				  : std_logic;
  signal cpu_irq          : std_logic;
  signal cpu_firq			    : std_logic;
  signal cpu_nmi          : std_logic;

  -- PIA-A signals
  signal pia_0_cs				  : std_logic;
  signal pia_0_datao  	  : std_logic_vector(7 downto 0);
  -- PIA-B signals
  signal pia_1_cs				  : std_logic;
  signal pia_1_datao  	  : std_logic_vector(7 downto 0);
  
	-- SAM signals
  signal sam_cs					  : std_logic;
	signal sam_a				    : std_logic_vector(15 downto 0);
  signal ras_n            : std_logic;
  signal cas_n            : std_logic;
	signal sam_we_n         : std_logic;
  signal sam_dbg          : std_logic_vector(15 downto 0);
  
  -- ROM signals        
  signal rom_wr					  : std_logic;
  signal rom_datao        : std_logic_vector(7 downto 0);
	signal rom_cs					  : std_logic;

  -- EXTROM signals	                        
  signal extrom_datao     : std_logic_vector(7 downto 0);
	signal extrom_cs			  : std_logic;

  -- RAM signals        
  signal ram_rd           : std_logic;
  signal ram_datao        : std_logic_vector(7 downto 0);

	-- system chipselect selector from SAM
	signal cs_sel					  : std_logic_vector(2 downto 0);

  -- VDG signals
  signal hs_n             : std_logic;
  signal fs_n             : std_logic;
  signal da0              : std_logic;
  signal vdg_sram_cs      : std_logic;

  -- cartridge signals
  signal cart_n           : std_logic;
  signal cart_cs          : std_logic;
  signal cart_d_o         : std_logic_vector(7 downto 0);

  -- (Glenside) IDE adapter signals
  signal ide_cs           : std_logic;
  signal ide_d_o          : std_logic_vector(7 downto 0);
  
  -- other coco signals
  signal casdin           : std_logic := '0';
  signal cassmot          : std_logic := '0';
  signal dac_data         : std_logic_vector(5 downto 0);
  signal snden            : std_logic := '0';
  signal sel              : std_logic_vector(2 downto 1);
  signal sndout           : std_logic := '0';
  signal joyin            : std_logic := '0';
  signal cart_bank        : std_logic_vector(3 downto 0) := (others => '0');
  
  alias ps2_platform_rst  : std_logic is inputs_i(8).d(0);
  alias ps2_cpu_rst       : std_logic is inputs_i(8).d(1);
  alias ps2_left_fire     : std_logic is inputs_i(8).d(2);
  alias ps2_right_fire    : std_logic is inputs_i(8).d(3);
  alias ps2_volume_up     : std_logic is inputs_i(8).d(4);
  alias ps2_volume_dn     : std_logic is inputs_i(8).d(5);
  alias ps2_video_hexy    : std_logic is inputs_i(8).d(6);

  alias sw_joystick       : std_logic is switches_i(7);
  alias sw_artifact_en    : std_logic is switches_i(6);
  alias sw_cassette_out   : std_logic is switches_i(5);
  --alias sw_cart_n         : std_logic is switches_i(4);
  signal sw_cart_n        : std_logic := '0';
  alias hw_cart_bank      : std_logic_vector(3 downto 0) is switches_i(3 downto 0);

  alias jamma_left_fire   : std_logic is jamma_i.p(1).button(1);
  alias jamma_right_fire  : std_logic is jamma_i.p(1).button(2);
  
begin

  target_rst <= rst_57M272 or buttons_i(0);

  -- extend CPU reset
  process (clk_57M272, target_rst)
    subtype count_t is integer range 0 to 31;
    variable count : count_t := 0;
    variable ext_rst : std_logic := '1';
  begin
    if target_rst = '1' then
      platform_rst <= '1';
      cpu_rst <= '1';
      ext_rst := '1';
    elsif rising_edge(clk_57M272) then
      if platform_rst = '1' then
        ext_rst := '1';
        count := 0;
      else
        if count = count_t'high then
          ext_rst := '0';
        elsif cpu_clk_n = '0' then
          count := count + 1;
        end if;
      end if;
      platform_rst <= target_rst or buttons_i(1) or ps2_platform_rst;
      cpu_rst <= ext_rst or buttons_i(2) or ps2_cpu_rst;
    end if;
  end process;
  
  -- always 'insert' cartridge if internal
  -- - this won't auto-start because bank="0000"
  sw_cart_n <= switches_i(4) or to_std_logic(COCO1_CART_INTERNAL);
  
  -- for ModelSim only!!!
  cpu_clk_n <= not cpu_clk;
  	
  --
  --  Clocking
  --

	-- produce a PAL/NTSC clock enable
	process (clk_57M272, platform_rst)
		subtype count_t is integer range 0 to 3;
		variable count : count_t := 0;
	begin
		if platform_rst = '1' then
			count := 0;
		elsif rising_edge(clk_57M272) then
      clk_14M318_ena <= '0';  -- default
			if count = count_t'high then
        clk_14M318_ena <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
		end if;
	end process;

	process (clk_57M272, platform_rst)
    variable ras_n_r  : std_logic := '0';
    variable cas_n_r  : std_logic := '0';
    variable e_r      : std_logic := '0';
    variable q_r      : std_logic := '0';
	begin
    if platform_rst = '1' then
      ras_n_r := '0';
      cas_n_r := '0';
      e_r := '0';
      q_r := '0';
		elsif rising_edge (clk_57M272) then
      if clk_14M318_ena = '1' then
        -- need to latch for CPU09 core
        if not COCO1_USE_REAL_6809 then
          if ras_n = '1' and ras_n_r = '0' and clk_e = '1' then
            ram_datao <= sram_i.d(ram_datao'range);
          end if;
        end if;
        if ras_n = '0' and ras_n_r = '1' then
          sam_a(7 downto 0) <= ma;
        elsif cas_n = '0' and cas_n_r = '1' then
          sam_a(15 downto 8) <= ma;
        end if;
        if clk_q = '1' and q_r = '0' then
          vdg_data <= sram_i.d(ram_datao'range);
        end if;
        -- for edge-detect
        ras_n_r := ras_n;
        cas_n_r := cas_n;
        e_r := clk_e;
        q_r := clk_q;
      end if;
		end if;
	end process;

  GEN_RAM_NO_LATCH : if COCO1_USE_REAL_6809 generate
    ram_datao <= sram_i.d(ram_datao'range);
  end generate GEN_RAM_NO_LATCH;

  -- memory read mux
  cpu_d_i <=  pia_0_datao when pia_0_cs = '1' else
              pia_1_datao when pia_1_cs = '1' else
              -- does this need to go thru SAM?
              ide_d_o when ide_cs = '1' else
              cart_d_o when (cart_cs = '1' and sw_cart_n = '1') else
              rom_datao when rom_cs = '1' else
              extrom_datao when extrom_cs = '1' else
              ram_datao when ram_rd = '1' else
              X"FF";

  -- SRAM signals
  -- the 6883 is not used to select RAM
  -- - rather the S=0 output is used to set the bus direction on the 74LS244
  -- - i.e. the output is RAM_RD
  sram_o.a <= std_logic_vector(resize(unsigned(sam_a), sram_o.a'length));
  --sram_data <= cpu_d_o when (cpu_vma = '1' and ram_cs = '1' and cpu_r_wn = '0' and vdg_sram_cs = '0') 
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  --sram_o.cs <= (cpu_vma and ram_cs) or vdg_sram_cs;
  sram_o.cs <= '1';
	sram_o.oe <= sam_we_n;
	sram_o.we <= not sam_we_n;

  -- CPU interrupts	
	cpu_nmi <= '0';

  --
  --  COMPONENT INSTANTIATION
  --

  GEN_CPU09 : if not COCO1_USE_REAL_6809 generate
    cpu_inst : entity work.cpu09
      port map
      (	
        clk				=> cpu_clk_n,
        rst				=> cpu_rst,
        rw 	    	=> cpu_r_wn,
        vma 	    => cpu_vma,
        addr      => cpu_a,
        data_in		=> cpu_d_i,
        data_out 	=> cpu_d_o,
        halt     	=> '0',
        hold     	=> '0',
        irq      	=> cpu_irq,
        firq     	=> cpu_firq,
        nmi      	=> cpu_nmi
      );
    
    -- display the CPU09 address bus on the 7-segment display  
    platform_o.seg7 <= cpu_a;
    
  end generate GEN_CPU09;
  
  GEN_REAL_6809 : if COCO1_USE_REAL_6809 generate

    platform_o.arst <= target_rst;
    platform_o.clk_cpld <= clk_57M272;
    
    platform_o.cpu_6809_q <= clk_q;
    platform_o.cpu_6809_e <= clk_e;
    platform_o.cpu_6809_rst_n <= not cpu_rst;
    cpu_r_wn <= platform_i.cpu_6809_r_wn;
    cpu_vma <= platform_i.cpu_6809_vma;
    cpu_a <= platform_i.cpu_6809_a;
    platform_o.cpu_6809_d_i <= cpu_d_i;
    cpu_d_o <= platform_i.cpu_6809_d_o;
    platform_o.cpu_6809_halt_n <= '1';
    platform_o.cpu_6809_irq_n <= not cpu_irq;
    platform_o.cpu_6809_firq_n <= not cpu_firq;
    platform_o.cpu_6809_nmi_n <= not cpu_nmi;
    platform_o.cpu_6809_tsc <= '0';

    -- so they don't get optimised-out
    leds_o(6) <= platform_i.cpu_6809_r_wn;
    leds_o(7) <= platform_i.cpu_6809_busy;
    leds_o(8) <= platform_i.cpu_6809_lic;
    leds_o(9) <= platform_i.cpu_6809_vma;
    
  end generate GEN_REAL_6809;
  
	sam_inst : entity work.mc6883
		port map
		(
			clk				=> clk_57M272,
			clk_ena   => clk_14M318_ena,
			reset			=> platform_rst,

			-- input
			a					=> cpu_a,
			rw_n			=> cpu_r_wn,

			-- vdg signals
			da0				=> da0,
			hs_n			=> hs_n,
			vclk		  => vdgclk,
			
			-- peripheral address selects		
			s					=> cs_sel,
			
			-- clock generation
			e					=> clk_e,
			q					=> clk_q,

			-- dynamic addresses
			z				  => ma,

			-- ram
			ras0_n	  => ras_n,
			cas_n		  => cas_n,
			we_n		  => sam_we_n,
			
			dbg       => sam_dbg
		);

  BLK_74LS138 : block
    signal y    : std_logic_vector(7 downto 0);
  begin
  
    -- assign chipselects from MC6883 selector output
    ram_rd <= y(0);
    extrom_cs <= y(1);
    rom_cs <= y(2);
    cart_cs <= y(3);
    pia_0_cs <= y(4);
    pia_1_cs <= y(5);
    --spare_cs <= y(6); -- CART_SCS
    -- y(7) is NC

    U11_inst : entity work.ttl_74ls138_p
      port map
      (
        a			=> cs_sel(0),
        b			=> cs_sel(1),
        c			=> cs_sel(2),
        
        g1		=> '1',   -- comes from CART_SLENB#
        g2a		=> '1',   -- come from E NOR cs_sel(2)
        g2b		=> '1',

        y     => y			
      );
  end block BLK_74LS138;
  
  vdg_inst : entity work.mc6847
		generic map
		(
      T1_VARIANT    => false,
			CHAR_ROM_FILE => COCO1_ROM_DIR & COCO1_MC6847_ROM,
      
      CVBS_NOT_VGA  => COCO1_CVBS
		)
    port map
    (
			clk			        => clk_57M272,
			clk_ena         => clk_14M318_ena,
      reset           => platform_rst,

      da0             => da0,

			dd			        => vdg_data,
				
      hs_n            => hs_n,
      fs_n            => fs_n,

      an_g            => vdg_an_g,
      an_s            => vdg_data(7),
      intn_ext        => vdg_intn_ext,
      gm              => vdg_gm,
      css             => vdg_css,
      inv             => vdg_data(6),

			red			        => r_s, 
			green		        => g_s, 
			blue		        => b_s, 
			hsync		        => hs_s, 
			vsync		        => vs_s, 
			-- needed for digital video
			hblank          => video_o.hblank,
			vblank          => video_o.vblank,
			
      -- special inputs
      artifact_en     => sw_artifact_en,
      artifact_set    => '0',
      artifact_phase  => '0',
      
			cvbs            => open
    );

  BLK_SND : block
  
    signal audio_data         : std_logic_vector(audio_o.ldata'range);
    signal audio_atten        : integer range 0 to 15 := 0;
    
  begin
  
    PROC_SND_MUX : process (clk_57M272, platform_rst)
    begin
      if platform_rst = '1' then
        audio_data <= (others => '0');
      elsif rising_edge(clk_57M272) then
        if sw_cassette_out = '1' then
          if cassmot = '1' then
            -- special case, cassette goes to speaker
            audio_data(audio_data'left downto audio_data'left-1) <= (others => dac_data(5));
            audio_data(audio_data'left-2 downto audio_data'left-3) <= (others => dac_data(4));
            audio_data(audio_data'left-4 downto audio_data'left-5) <= (others => dac_data(3));
            audio_data(audio_data'left-6 downto audio_data'left-7) <= (others => dac_data(2));
            audio_data(audio_data'left-8 downto audio_data'left-9) <= (others => dac_data(1));
            audio_data(audio_data'left-10 downto audio_data'left-11) <= (others => dac_data(0));
            audio_data(audio_data'left-12 downto 0) <= (others => '0');
          end if;
        elsif snden = '1' then
          case sel is
            when "00" =>
              -- 6-bit sound from the DAC
              audio_data(audio_data'left downto audio_data'left-5) <= dac_data;
              audio_data(audio_data'left-6 downto 0) <= (others => '0');
            when "01" =>
              -- from the cassette
              -- - not yet supported
              audio_data <= (others => '0');
            when "10" =>
              -- from the cartridge connector
              -- - not yet supported
              audio_data <= (others => '0');
            when others =>
              audio_data <= (others => '0');
          end case;
        else
          -- 1-bit sound from PIA
          audio_data <= (audio_data'left=>sndout, others => '0');
        end if;
      end if;
    end process PROC_SND_MUX;

    PROC_SND_ATTEN : process (clk_57M272, platform_rst)
      variable audio_data_atten : std_logic_vector(audio_o.ldata'range);
    begin
      if platform_rst = '1' then
        audio_data_atten := (others => '0');
      elsif rising_edge(clk_57M272) then
        -- the DE1 audio codec has a volume control
        -- - but for a quick hack, we'll do it here
        -- - and fix the implementation later
        case audio_atten is
          when 0 =>   audio_data_atten := audio_data;
          when 1 =>   audio_data_atten := "0" & audio_data(15 downto 1);
          when 2 =>   audio_data_atten := "00" & audio_data(15 downto 2);
          when 3 =>   audio_data_atten := "000" & audio_data(15 downto 3);
          when 4 =>   audio_data_atten := "0000" & audio_data(15 downto 4);
          when 5 =>   audio_data_atten := "000000" & audio_data(15 downto 6);
          when 6 =>   audio_data_atten := "00000000" & audio_data(15 downto 8);
          when 7 =>   audio_data_atten := "0000000000" & audio_data(15 downto 10);
          when others =>   
                      audio_data_atten := (others => '0');
        end case;
        -- assign to output
        audio_o.ldata <= audio_data_atten;
        audio_o.rdata <= audio_data_atten;
      end if;
    end process;

    -- edge-detect on the colume control keys
    process (clk_57M272, target_rst)
      variable up_r : std_logic := '0';
      variable dn_r : std_logic := '0';
    begin
      if target_rst = '1' then
        up_r := '0';
        dn_r := '0';
        audio_atten <= 0;
      elsif rising_edge(clk_57M272) then
        if ps2_volume_up = '1' and up_r = '0' and audio_atten /= 0 then
            audio_atten <= audio_atten - 1;
        elsif ps2_volume_dn = '1' and dn_r = '0' and audio_atten /= 15 then
            audio_atten <= audio_atten + 1;
        end if;
        up_r := ps2_volume_up;
        dn_r := ps2_volume_dn;
      end if;
    end process;
    
  end block BLK_SND;
  
  BLK_CASSETTE : block
  begin
    casdin <= '0';
    --<= cassmot;
  end block BLK_CASSETTE;
  
  BLK_PIA_0 : block
    signal irqa      	: std_logic;
    signal irqb      	: std_logic;
    signal pa_i       : std_logic_vector(7 downto 0);
    signal pb_o       : std_logic_vector(7 downto 0);
    signal joy        : std_logic_vector(1 to 4) := (others => '0');
  begin
  
    -- this is ultimately correct
    cpu_irq <= irqa or irqb;
    
    -- keyboard matrix
    process (clk_57M272, target_rst)
      variable keys : std_logic_vector(7 downto 0);
    begin
      if target_rst = '1' then
        keys := (others => '0');
      elsif rising_edge (clk_57M272) then
        keys := (others => '0');
        -- note that row select is active low
        if pb_o(0) = '0' then
          keys := keys or inputs_i(0).d;
        end if;
        if pb_o(1) = '0' then
          keys := keys or inputs_i(1).d;
        end if;
        if pb_o(2) = '0' then
          keys := keys or inputs_i(2).d;
        end if;
        if pb_o(3) = '0' then
          keys := keys or inputs_i(3).d;
        end if;
        if pb_o(4) = '0' then
          keys := keys or inputs_i(4).d;
        end if;
        if pb_o(5) = '0' then
          keys := keys or inputs_i(5).d;
        end if;
        if pb_o(6) = '0' then
          keys := keys or inputs_i(6).d;
        end if;
        if pb_o(7) = '0' then
          keys := keys or inputs_i(7).d;
        end if;
      end if;
      
      -- key inputs are active low
      -- - bit 7 is joyin (TBD)
      pa_i <= joyin & not keys(6 downto 2) & 
                (not (keys(1) or ps2_left_fire) and jamma_left_fire) &
                (not (keys(0) or ps2_right_fire) and jamma_right_fire);
    end process;

    BLK_JOY : block
      type joy_analogue_a is array (natural range <>) of std_logic_vector(9 downto 4);
      signal joy_analogue : joy_analogue_a(1 to 4);
    begin
      -- use D-pad for 'digital' inputs & invert analogue Y axes
      joy_analogue(1) <= (others => '0') when jamma_i.p(1).left = '0' else
                         (others => '1') when jamma_i.p(1).right = '0' else
                          analogue_i(1)(9 downto 4);
      joy_analogue(2) <= (others => '0') when jamma_i.p(1).up = '0' else
                         (others => '1') when Jamma_i.p(1).down = '0' else
                         not analogue_i(2)(9 downto 4);
      joy_analogue(3) <= analogue_i(3)(9 downto 4);
      joy_analogue(4) <= not analogue_i(4)(9 downto 4);

      GEN_JOY_SAMPLES : for i in joy'range generate
      begin
        joy(i) <= '1' when joy_analogue(i) >= dac_data else '0';
      end generate GEN_JOY_SAMPLES;

      joyin <=  joy(1) when sel = "00" and sw_joystick = '0' else   -- right X
                joy(2) when sel = "01" and sw_joystick = '0' else   -- right Y
                joy(3) when sel = "10" and sw_joystick = '0' else   -- left X
                joy(4) when sel = "11" and sw_joystick = '0' else   -- left Y
                joy(3) when sel = "00" and sw_joystick = '1' else
                joy(4) when sel = "01" and sw_joystick = '1' else
                joy(1) when sel = "10" and sw_joystick = '1' else
                joy(2);
    end block BLK_JOY;
    
    pia_0_inst : entity work.pia6821
      port map
      (	
        clk       	=> clk_14M318_ena,
        rst       	=> platform_rst,
        cs        	=> pia_0_cs,
        rw        	=> cpu_r_wn,
        addr      	=> cpu_a(1 downto 0),
        data_in   	=> cpu_d_o,
        data_out  	=> pia_0_datao,
        irqa      	=> irqa,
        irqb      	=> irqb,
        pa_i        => pa_i,
        pa_o				=> open,
        pa_oe				=> open,
        ca1       	=> hs_n,
        ca2_i      	=> 'X',
        ca2_o				=> sel(1),
        ca2_oe			=> open,
        pb_i				=> (others => 'X'),
        pb_o       	=> pb_o,
        pb_oe				=> open,
        cb1       	=> fs_n,
        cb2_i      	=> 'X',
        cb2_o				=> sel(2),
        cb2_oe			=> open
      );
  end block BLK_PIA_0;
  
  BLK_PIA_1 : block
    signal irqa      	: std_logic;
    signal irqb      	: std_logic;
    signal pa_i       : std_logic_vector(7 downto 0);
    signal pa_o       : std_logic_vector(7 downto 0);
    signal pb_i       : std_logic_vector(7 downto 0);
    signal pb_o       : std_logic_vector(7 downto 0);
  begin

    pa_i(0) <= casdin;
    ser_o.txd <= pa_o(1);
    dac_data <= pa_o(7 downto 2);

    pb_i(0) <= ser_i.rxd;
    sndout <= pb_o(1);
    pb_i(2) <= COCO1_JUMPER_32K_RAM;
    vdg_css <= pb_o(3);
    vdg_intn_ext <= pb_o(4);
    vdg_gm <= pb_o(6 downto 4);
    vdg_an_g <= pb_o(7);
    
    -- this is ultimately correct
    cpu_firq <= irqa or irqb;
    
    pia_1_inst : entity work.pia6821
      port map
      (	
        clk       	=> clk_14M318_ena,
        rst       	=> platform_rst,
        cs        	=> pia_1_cs,
        rw        	=> cpu_r_wn,
        addr      	=> cpu_a(1 downto 0),
        data_in   	=> cpu_d_o,
        data_out  	=> pia_1_datao,
        irqa      	=> irqa,
        irqb      	=> irqb,
        pa_i        => pa_i,
        pa_o				=> pa_o,
        pa_oe				=> open,
        ca1       	=> ser_i.dcd,
        ca2_i      	=> 'X',
        ca2_o				=> cassmot,
        ca2_oe			=> open,
        pb_i				=> pb_i,
        pb_o       	=> pb_o,
        pb_oe				=> open,
        cb1       	=> cart_n,
        cb2_i      	=> 'X',
        cb2_o				=> snden,
        cb2_oe			=> open
      );
  end block BLK_PIA_1;

  -- COLOR BASIC ROM
  basrom_inst : entity work.sprom
		generic map
		(
			init_file		=> COCO1_ROM_DIR & COCO1_BASIC_ROM,
			numwords_a	=> 8192,
			widthad_a		=> 13
		)
  	port map
  	(
  		clock		    => clk_57M272,
  		address		  => cpu_a(12 downto 0),
  		q			      => rom_datao
  	);

	GEN_EXT : if COCO1_EXTENDED_COLOR_BASIC generate
	  -- EXTENDED COLOR BASIC ROM
	  extbasrom_inst : entity work.sprom
			generic map
			(
				init_file		=> COCO1_ROM_DIR & COCO1_EXTENDED_BASIC_ROM,
				numwords_a	=> 8192,
				widthad_a		=> 13
			)
	  	port map
	  	(
	  		clock		    => clk_57M272,
	  		address		  => cpu_a(12 downto 0),
	  		q			      => extrom_datao
	  	);
  else generate
    extrom_datao <= (others => '0');
	end generate GEN_EXT;

	GEN_CART : if COCO1_CART_INTERNAL generate
	  cart_inst : entity work.sprom
			generic map
			(
				init_file		=> COCO1_ROM_DIR & COCO1_CART_NAME,
				numwords_a	=> 2**COCO1_CART_WIDTHAD,
				widthad_a		=> COCO1_CART_WIDTHAD
			)
	  	port map
	  	(
	  		clock		    => clk_57M272,
	  		address		  => cpu_a(COCO1_CART_WIDTHAD-1 downto 0),
	  		q			      => cart_d_o
	  	);
  else generate
    -- only support 16x16KB cartridges atm
    flash_o.a(flash_o.a'left downto 18) <= (others => '0');
    flash_o.a(17 downto 14) <= cart_bank;
    flash_o.a(13 downto 0) <= cpu_a(13 downto 0);
    cart_d_o <= flash_i.d(cart_d_o'range);
    flash_o.cs <= cart_cs;
    flash_o.oe <= cpu_r_wn;
    flash_o.we <= '0';
	end generate GEN_CART;
  
  -- CART# signal is tied to 'Q' on a real cartridge
  -- - BANKS 0,1 are reserved for DOS (non-autostart)
  cart_n <= '1' when (sw_cart_n = '0' or cart_bank(3 downto 1) = "000") else clk_q;

  -- MPI
  process (clk_57M272, target_rst)
    variable hw_r : std_logic_vector(cart_bank'range) := (others => '0');
    variable sw_r : std_logic_vector(cart_bank'range) := (others => '0');
  begin
    if target_rst = '1' then
      hw_r := hw_cart_bank;
      cart_bank <= hw_cart_bank;
--    elsif rising_edge(clk_57M272) then
--      -- MPI switch changed?
--      if hw_cart_bank /= hw_r then
--        cart_bank <= hw_cart_bank;
--      end if;
--      -- software switch accessed?
--      if cpu_clk_n = '0' and cpu_r_wn = '0' and cpu_a = X"FF7F" then
--        cart_bank <= cpu_d_o(cart_bank'range);
--      end if;
--      hw_r := hw_cart_bank;
    end if;
  end process;
  -- show selected slot on the LEDs
  leds_o(3 downto 0) <= cart_bank;
  
  GEN_IDE : if COCO1_HAS_IDE generate

    type state_t is ( S_IDLE, S_I1, S_R1, S_W1 );
    signal state : state_t := S_IDLE;

    signal ide_d_r  : std_logic_vector(31 downto 0) := (others => '0');
    
  begin

    -- IDE registers
    --
    -- 0 - Data
    -- 1 - Error(rd)/Features(wr)
    -- 2 - Sector count
    -- 3 - Sector number
    -- 4 - Cylinder low byte
    -- 5 - Cylinder high byte
    -- 6 - Device/head
    -- 7 - Command
    -- 8 - Latch
    -- -
    -- 9 - Flash Bank Select (bit7=wr,bit1:0=bank)
    --
    -- Setting the base address
    -- $FF50-$FF59 is the default
    -- $FF4X,$FF5X,$FF6X,$FF7X available
    --
    -- $FF78-$FF79,$FF7C RTC registers
    --

    ide_cs <= '1' when STD_MATCH(cpu_a, X"FF5"&"----") else '0';
    
    platform_o.wb_clk <= clk_57M272;
    platform_o.wb_rst <= rst_57M272;
    platform_o.wb_arst_n <= '1';

    platform_o.clk_50M <= clkrst_i.clk_ref;
    
    process (clk_57M272, platform_rst)
      variable cpu_clk_r : std_logic := '0';
    begin
      if platform_rst = '1' then
        platform_o.wb_cyc_stb <= '0';
        platform_o.wb_we <= '0';
        state <= S_I1;
      elsif rising_edge(clk_57M272) then
        case state is
          when S_I1 =>
            -- initialise the OCIDE core
            platform_o.wb_cyc_stb <= '1';
            platform_o.wb_adr <= "00000";
            platform_o.wb_dat <= X"00000080";   -- enable IDE
            platform_o.wb_we <= '1';
            state <= S_W1;
          when S_IDLE =>
            platform_o.wb_cyc_stb <= '0'; -- default
            -- start a new cycle on falling_edge cpu_clk
            if cpu_clk = '0' and cpu_clk_r = '1' then
              if ide_cs = '1' then
                if cpu_a(3 downto 0) = X"8" then
                  if cpu_r_wn = '1' then
                    -- read latch from previous access
                    ide_d_o <= ide_d_r(15 downto 8);
                  else
                    -- latch write data for subsequent access
                    ide_d_r(15 downto 8) <= cpu_d_o;
                  end if;
                else
                  -- start a new access
                  platform_o.wb_cyc_stb <= ide_cs;
                  if cpu_a(3) = '0' then
                    -- $00-$07 => $10-$17 (ATA registers)
                    platform_o.wb_adr <= '1' & cpu_a(3 downto 0);
                  else
                    -- $0C-$0F => $00-$03 (core registers)
                    platform_o.wb_adr <= "000" & cpu_a(1 downto 0);
                  end if;
                  platform_o.wb_dat <= X"0000" & ide_d_r(15 downto 8) & cpu_d_o;
                  platform_o.wb_we <= not cpu_r_wn;
                  if cpu_r_wn = '1' then
                    state <= S_R1;
                  else
                    state <= S_W1;
                  end if;
                end if; -- latch/access
              end if; -- ide_cs = '1'
            end if;
          when S_R1 =>
            if platform_i.wb_ack = '1' then
              -- latch the whole data bus from the core
              ide_d_r <= platform_i.wb_dat;
              ide_d_o <= platform_i.wb_dat(ide_d_o'range);
              state <= S_IDLE;
            end if;
          when S_W1 =>
            if platform_i.wb_ack = '1' then
              state <= S_IDLE;
            end if;
          when others =>
            state <= S_IDLE;
        end case;
        cpu_clk_r := cpu_clk;
      end if;
    end process;
    
  end generate GEN_IDE;

  -- some debug stuff
  BLK_DEBUG : block

    signal dbg_clk_ena  : std_logic := '0';
    signal dbg_video    : std_logic := '0';
    signal dbg_dim      : std_logic := '0';
    signal dbg_enable   : std_logic := '0';
    
  begin

    process (clk_57M272, rst_57M272)
      variable count  : std_logic := '0';
      variable f10_r  : std_logic := '0';
    begin
      if rst_57M272 = '1' then
        count := '0';
        f10_r := '0';
        dbg_enable <= '0';
      elsif rising_edge(clk_57M272) then
        count := not count;
        if ps2_video_hexy = '1' and f10_r = '0' then
          dbg_enable <= not dbg_enable;
        end if;
        f10_r := ps2_video_hexy;
      end if;
      dbg_clk_ena <= count;
    end process;
    
    vmode_debug_inst : entity work.vmode_hexy
    	generic map
    	(
    		xOffset   => 272,
    		yOffset   => 480
    	)
    	port map
    	(
    		clk       => clk_57M272,
    		clk_ena   => dbg_clk_ena,
    		vSync     => vs_s,
    		hSync     => hs_s,
    		video     => dbg_video,
    		dim       => dbg_dim,
    		
    		sam_dbg   => unsigned(sam_dbg),
    		an_g      => vdg_an_g,
    		an_s      => vdg_data(7),
    		intn_ext  => vdg_intn_ext,
    		gm        => unsigned(vdg_gm),
    		css       => vdg_css,
    		inv       => vdg_data(6)
    	);

    -- mux in debug video
    video_o.clk <= clk_57M272;
    video_o.rgb.r <= dbg_video & '0' & r_s when (dbg_enable and dbg_dim) = '1' else r_s & "00";
    video_o.rgb.g <= dbg_video & '0' & g_s when (dbg_enable and dbg_dim) = '1' else g_s & "00";
    video_o.rgb.b <= dbg_video & '0' & b_s when (dbg_enable and dbg_dim) = '1' else b_s & "00";
    video_o.hsync <= hs_s;
    video_o.vsync <= vs_s;
      
  end block BLK_DEBUG;
  
end architecture SYN;
