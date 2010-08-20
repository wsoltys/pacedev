library ieee;
use ieee.std_logic_1164.all;
use	ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.kbd_pkg.all;
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
    clk_i             : in std_logic_vector(0 to 3);
    reset_i           : in std_logic_vector(0 to 3);

    -- misc I/O
    buttons_i         : in from_BUTTONS_t;
    switches_i        : in from_SWITCHES_t;
    leds_o            : out to_LEDS_t;

    -- controller inputs
    inputs_i          : in from_MAPPED_INPUTS_t(0 to NUM_INPUT_BYTES-1);

    -- FLASH/SRAM
    flash_i           : in from_FLASH_t;
    flash_o           : out to_FLASH_t;
		sram_i					  : in from_SRAM_t;
		sram_o					  : out to_SRAM_t;
    sdram_i           : in from_SDRAM_t;
    sdram_o           : out to_SDRAM_t;

    -- graphics (control)
    red							  : out		std_logic_vector(7 downto 0);
		green						  : out		std_logic_vector(7 downto 0);
		blue						  : out		std_logic_vector(7 downto 0);
		hsync						  : out		std_logic;
		vsync						  : out		std_logic;

    -- OSD
    osd_i             : in from_OSD_t;
    osd_o             : out to_OSD_t;

    -- sound
    snd_i             : in from_SOUND_t;
    snd_o             : out to_SOUND_t;
    
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
--    1: external 6809 reset
--  Switches
--    9: CART#
--

architecture SYN of platform is

  -- debug build options
  constant BUILD_TEST_VGA_ONLY    : boolean := false;
  
	alias clk_20M					: std_logic is clk_i(0);
	alias rst_20M         : std_logic is reset_i(0);
	--alias clk_57M272			: std_logic is clk_i(0);
	--alias rst_57M272      : std_logic is reset_i(0);
	alias clk_57M272			: std_logic is clk_i(1);
	alias rst_57M272      : std_logic is reset_i(1);

	-- clocks
	signal clk_14M318_ena : std_logic := '0';
	signal clk_q          : std_logic := '0';
	signal clk_e          : std_logic := '0';

	signal cpu_reset			: std_logic;
	
	-- clock helpers
  signal vdgclk         : std_logic;

	-- multiplexed address
	signal ma							: std_logic_vector(7 downto 0);

  signal vdg_data       : std_logic_vector(7 downto 0);
  signal vdg_y          : std_logic_vector(3 downto 0);						
  signal vdg_x          : std_logic_vector(4 downto 0);
  signal vdg_css        : std_logic;
  signal vdg_intn_ext   : std_logic;
  signal vdg_gm         : std_logic_vector(2 downto 0);
  signal vdg_an_g       : std_logic;

  -- uP signals  
  alias cpu_clk         : std_logic is clk_e;
  signal cpu_a          : std_logic_vector(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_r_wn				: std_logic;
  signal cpu_vma				: std_logic;
  signal cpu_irq        : std_logic;
  signal cpu_firq			  : std_logic;
  signal cpu_nmi        : std_logic;

  -- keyboard signals
	signal jamma_s				: from_JAMMA_t;
  signal kbd_matrix			: from_MAPPED_INPUTS_t(0 to 8);
	alias game_reset			: std_logic is kbd_matrix(8).d(0);

  -- PIA-A signals
  signal pia_0_cs				: std_logic;
  signal pia_0_datao  	: std_logic_vector(7 downto 0);
  -- PIA-B signals
  signal pia_1_cs				: std_logic;
  signal pia_1_datao  	: std_logic_vector(7 downto 0);

	-- SAM signals
  signal sam_cs					: std_logic;
	signal sam_a				  : std_logic_vector(15 downto 0);
  signal ras_n          : std_logic;
  signal cas_n          : std_logic;
	signal sam_we_n       : std_logic;
                        
  -- ROM signals        
  signal rom_wr					: std_logic;
  signal rom_datao      : std_logic_vector(7 downto 0);
	signal rom_cs					: std_logic;

  -- EXTROM signals	                        
  signal extrom_datao   : std_logic_vector(7 downto 0);
	signal extrom_cs			: std_logic;

  -- VRAM signals       
  --signal vram_cs        : std_logic;
  signal vram_wr        : std_logic;
  --signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal ram_cs         : std_logic;
  signal ram_datao      : std_logic_vector(7 downto 0);

	-- system chipselect selector from SAM
	signal cs_sel					: std_logic_vector(2 downto 0);

  -- VDG signals
  signal hs_n           : std_logic;
  signal fs_n           : std_logic;
  signal da0            : std_logic;
  signal vdg_sram_cs    : std_logic;

  -- only for test vga controller
	signal vga_clk_s				: std_logic;
	
begin

	--cpu_reset <= rst_57M272 or game_reset;
	cpu_reset <= rst_57M272 or buttons_i(1);
	
  --
  --  Clocking
  --

	-- produce a PAL clock enable
	process (clk_57M272, rst_57M272)
		subtype count_t is integer range 0 to 3;
		variable count : count_t := 0;
	begin
		if rst_57M272 = '1' then
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

	process (clk_57M272, rst_57M272)
    variable ras_n_r  : std_logic := '0';
    variable cas_n_r  : std_logic := '0';
    variable e_r      : std_logic := '0';
    variable q_r      : std_logic := '0';
    variable rd       : std_logic := '0';
	begin
    if rst_57M272 = '1' then
      ras_n_r := '0';
      cas_n_r := '0';
      e_r := '0';
      e_r := '1';
		elsif rising_edge (clk_57M272) then
      if clk_14M318_ena = '1' then
        -- do we even need to latch the data here?
        -- - I don't think so for a real 6809e at least...
        if rd = '1' then
          --ram_datao <= sram_i.d(ram_datao'range);
          rd := '0';
        end if;
        if ras_n = '0' and ras_n_r = '1' then
          sam_a(7 downto 0) <= ma;
        elsif cas_n = '0' and cas_n_r = '1' then
          sam_a(15 downto 8) <= ma;
          rd := '1';
        end if;
        if clk_q = '1' and e_r = '0' then
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

  ram_datao <= sram_i.d(ram_datao'range);

  -- memory read mux
  cpu_d_i <=  pia_0_datao when pia_0_cs = '1' else
              pia_1_datao when pia_1_cs = '1' else
              rom_datao when rom_cs = '1' else
              extrom_datao when extrom_cs = '1' else
              ram_datao when ram_cs = '1' else
              --vram_datao when vram_cs = '1' else
              X"FF";

  -- SRAM signals
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
        clk				=> not clk_e,
        rst				=> cpu_reset,
        rw 	    	=> cpu_r_wn,
        vma 	    => cpu_vma,
        address 	=> cpu_a,
        data_in		=> cpu_d_i,
        data_out 	=> cpu_d_o,
        halt     	=> '0',
        hold     	=> '0',
        irq      	=> cpu_irq,
        firq     	=> cpu_firq,
        nmi      	=> cpu_nmi
      );
  end generate GEN_CPU09;
  
  GEN_REAL_6809 : if COCO1_USE_REAL_6809 generate

    --platform_o.arst <= clkrst_i.arst;
    platform_o.arst <= reset_i(0);
    --platform_o.clk_50M <= clk_rst_i.clk(0);
    platform_o.clk_cpld <= clk_57M272;
    platform_o.button <= buttons_i(platform_o.button'range);
    
    platform_o.cpu_6809_q <= clk_q;
    platform_o.cpu_6809_e <= clk_e;
    platform_o.cpu_6809_rst_n <= not rst_57M272;
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
    leds_o(0) <= platform_i.cpu_6809_r_wn;
    leds_o(1) <= platform_i.cpu_6809_busy;
    leds_o(2) <= platform_i.cpu_6809_lic;
    leds_o(3) <= platform_i.cpu_6809_vma;
    
  end generate GEN_REAL_6809;
  
	sam_inst : entity work.mc6883
		port map
		(
			clk				=> clk_57M272,
			clk_ena   => clk_14M318_ena,
			reset			=> rst_57M272,

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
			we_n		  => sam_we_n
		);

  BLK_74LS138 : block
    signal y    : std_logic_vector(7 downto 0);
  begin
  
    -- assign chipselects from MC6883 selector output
    ram_cs <= y(0);
    extrom_cs <= y(1);
    rom_cs <= y(2);
    --cart_cs <= y(3);  -- CART_CTS
    pia_0_cs <= y(4);
    pia_1_cs <= y(5);
    --spare_cs <= y(6); -- CART_SCS
    -- y(7) is NC

    -- this is yet to be implemented in the 6883/6847
    --vram_cs <= '1' when cpu_a(15 downto 10) = "000001" else '0';

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
      CVBS_NOT_VGA  => false,
			CHAR_ROM_FILE => COCO1_SOURCE_ROOT_DIR & "roms/tiledata.hex"
		)
    port map
    (
			clk			  => clk_57M272,
			clk_ena   => clk_14M318_ena,
      reset     => rst_57M272,

      da0       => da0,

			dd			  => vdg_data,
				
      hs_n      => hs_n,
      fs_n      => fs_n,

      an_g      => vdg_an_g,
      an_s      => '0',
      intn_ext  => vdg_intn_ext,
      gm        => vdg_gm,
      css       => vdg_css,
      inv       => '0',

			red			  => red,
			green		  => green,
			blue		  => blue,
			hsync		  => hsync,
			vsync		  => vsync,
			
			cvbs      => open
    );

  BLK_PIA_0 : block
    signal irqa      	: std_logic;
    signal irqb      	: std_logic;
    signal pa_i       : std_logic_vector(7 downto 0);
    signal pb_o       : std_logic_vector(7 downto 0);
  begin
  
    -- this is ultimately correct
    cpu_irq <= irqa or irqb;
    -- but for now...
    --cpu_irq <= '0';
    
    -- keyboard matrix
    process (clk_20M, reset_i(1))
      variable keys : std_logic_vector(7 downto 0);
    begin
      if reset_i(1) = '1' then
        keys := (others => '0');
      elsif rising_edge (clk_20M) then
        keys := (others => '0');
        -- note that row select is active low
        if pb_o(0) = '0' then
          keys := keys or kbd_matrix(0).d;  -- or right fire button
        end if;
        if pb_o(1) = '0' then
          keys := keys or kbd_matrix(1).d;  -- or left fire button
        end if;
        if pb_o(2) = '0' then
          keys := keys or kbd_matrix(2).d;
        end if;
        if pb_o(3) = '0' then
          keys := keys or kbd_matrix(3).d;
        end if;
        if pb_o(4) = '0' then
          keys := keys or kbd_matrix(4).d;
        end if;
        if pb_o(5) = '0' then
          keys := keys or kbd_matrix(5).d;
        end if;
        if pb_o(6) = '0' then
          keys := keys or kbd_matrix(6).d;
        end if;
        if pb_o(7) = '0' then
          keys := keys or kbd_matrix(7).d;
        end if;
      end if;
      -- key inputs are active low
      -- - bit 7 is joyin (TBD)
      pa_i <= '1' & not keys(6 downto 0);
    end process;

    pia_0_inst : entity work.pia6821
      port map
      (	
        clk       	=> cpu_clk,
        rst       	=> reset_i(0),
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
        ca2_o				=> open,  -- SEL1
        ca2_oe			=> open,
        pb_i				=> (others => 'X'),
        pb_o       	=> pb_o,
        pb_oe				=> open,
        cb1       	=> fs_n,
        cb2_i      	=> 'X',
        cb2_o				=> open,  -- SEL2
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
    signal cart_n     : std_logic;
  begin

    --pa_i(0) <= casin;
    ser_o.txd <= pa_o(1);
    --dac_data <= pa_o(7 downto 2);

    -- #CART
    cart_n <= not switches_i(9);

    pb_i(0) <= ser_i.rxd;
    --sndout <= pb_o(1);
    pb_i(2) <= COCO1_JUMPER_32K_RAM;
    vdg_css <= pb_o(3);
    vdg_intn_ext <= pb_o(4);
    vdg_gm <= pb_o(6 downto 4);
    vdg_an_g <= pb_o(7);
    
    -- this is ultimately correct
    cpu_firq <= irqa or irqb;
    -- but for now...
    --cpu_firq <= '0';
    
    pia_1_inst : entity work.pia6821
      port map
      (	
        clk       	=> cpu_clk,
        rst       	=> reset_i(0),
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
        ca2_o				=> open,  -- CASSMOT
        ca2_oe			=> open,
        pb_i				=> pb_i,
        pb_o       	=> pb_o,
        pb_oe				=> open,
        cb1       	=> cart_n,
        cb2_i      	=> 'X',
        cb2_o				=> open,  -- SNDEN
        cb2_oe			=> open
      );
  end block BLK_PIA_1;
  
  -- COLOR BASIC ROM
  basrom_inst : entity work.sprom
		generic map
		(
			init_file		=> COCO1_SOURCE_ROOT_DIR & "roms/" & COCO1_BASIC_ROM,
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
				init_file		=> COCO1_SOURCE_ROOT_DIR & "roms/" & COCO1_EXTENDED_BASIC_ROM,
				numwords_a	=> 8192,
				widthad_a		=> 13
			)
	  	port map
	  	(
	  		clock		    => clk_57M272,
	  		address		  => cpu_a(12 downto 0),
	  		q			      => extrom_datao
	  	);

	end generate GEN_EXT;

	GEN_NO_EXT : if not COCO1_EXTENDED_COLOR_BASIC generate
    extrom_datao <= (others => '0');
	end generate GEN_NO_EXT;

end architecture SYN;
