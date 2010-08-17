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

  subtype cycle_t is unsigned(3 downto 0);
  signal cycle          : cycle_t := (others => '0');
	
	signal cpu_reset			: std_logic;
	
	-- clock helpers
  signal vdgclk         : std_logic;

  -- system signals
  signal sys_write      : std_logic;
	
	-- multiplexed address
	signal ma							: std_logic_vector(7 downto 0);

	signal mpu_addr				: std_logic_vector(15 downto 0);

  alias vdg_addr        : std_logic_vector(15 downto 0) is mpu_addr;
  signal vdg_data       : std_logic_vector(7 downto 0);
  signal vdg_y          : std_logic_vector(3 downto 0);						
  signal vdg_x          : std_logic_vector(4 downto 0);

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
  signal sam_datao			: std_logic_vector(7 downto 0);
                        
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
	signal y              : std_logic_vector(7 downto 0);

  -- VDG signals
  signal hs_n           : std_logic;
  signal fs_n           : std_logic;
  signal da0            : std_logic;
  signal vdg_sram_cs    : std_logic;

  -- only for test vga controller
	signal vga_clk_s				: std_logic;
	
begin

	cpu_reset <= rst_57M272; -- or game_reset;
	
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

  -- generate master cycle count
	process (clk_57M272, rst_57M272)
  begin
    if rst_57M272 = '1' then
      cycle <= (others => '0');
    elsif rising_edge (clk_57M272) then
      if (clk_14M318_ena = '1') then
        cycle <= cycle + 1;
      end if;
    end if;
  end process;
  
  --	
	-- system control
  --

  -- assign chipselects from MC6883 selector output
	ram_cs <= y(0) or y(7);
  extrom_cs <= y(1);
  rom_cs <= y(2);
  pia_0_cs <= y(4);
  pia_1_cs <= y(5);
  -- this is yet to be implemented in the 6883/6847
  --vram_cs <= '1' when cpu_a(15 downto 10) = "000001" else '0';

  --
  -- generate system cycles
  --
	process (clk_57M272, rst_57M272)
	begin
    if rst_57M272 = '1' then
      null;
		elsif rising_edge (clk_57M272) then
			-- defaults
      sys_write <= '0';
      vdg_sram_cs <= '0';
      vram_wr <= '0';
      if clk_14M318_ena = '1' then
        case cycle is
          when X"0" =>
            -- latch VDG address (row)
            vdg_addr(7 downto 0) <= ma;
          when X"3" =>
            -- latch VDG address (column)
            vdg_addr(15 downto 8) <= ma;
          when X"4" =>
            -- read SRAM data here because we're multiplexing it with CPU
            vdg_sram_cs <= '1';
          when X"5" =>
            vdg_data <= sram_i.d(vdg_data'range);
          when X"6" =>
            if hs_n = '1' and fs_n = '1' then
              vram_wr <= '1';
            end if;
          when X"8" =>
            -- latch MPU address (row)
            mpu_addr(7 downto 0) <= ma;
          when X"B" =>
            -- latch MPU address (column)
            mpu_addr(15 downto 8) <= ma;
            -- enable bus write i/o
            sys_write <= '1';
          when X"C" =>
            -- read SRAM data here because we're multiplexing it with video
            ram_datao <= sram_i.d(ram_datao'range);
          when others =>
        end case;
      end if; -- clk_14M318_ena
		end if;
	end process;

  -- memory read mux
  cpu_d_i <=  pia_0_datao when pia_0_cs = '1' else
              rom_datao when rom_cs = '1' else
              extrom_datao when extrom_cs = '1' else
              ram_datao when ram_cs = '1' else
              --vram_datao when vram_cs = '1' else
              X"FF";

  -- SRAM signals
  sram_o.a <= std_logic_vector(resize(unsigned(mpu_addr), sram_o.a'length));
  --sram_data <= cpu_d_o when (cpu_vma = '1' and ram_cs = '1' and cpu_r_wn = '0' and vdg_sram_cs = '0') 
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  --sram_o.cs <= (cpu_vma and ram_cs) or vdg_sram_cs;
  sram_o.cs <= '1';
	sram_o.oe <= cpu_r_wn or vdg_sram_cs;
	sram_o.we <= sys_write and not cpu_r_wn;

  -- CPU interrupts	
	cpu_nmi <= '0';

  --
  --  COMPONENT INSTANTIATION
  --

  GEN_CPU09 : if not COCO1_USE_REAL_6809 generate
    cpu_inst : entity work.cpu09
      port map
      (	
        clk				=> clk_e,
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
			
			-- dynamic addresses
			z				  => ma,

			-- ram
			--ras0_n	: out std_logic;
			--cas_n		: out std_logic;
			--we_n		: out std_logic;
			
			-- clock generation
			q					=> clk_q,
			e					=> clk_e
		);

	U11_inst : entity work.ttl_74ls138_p
		port map
		(
			a			=> cs_sel(0),
			b			=> cs_sel(1),
			c			=> cs_sel(2),
			
			g1		=> '1',
			g2a		=> '1',
			g2b		=> '1',

      y     => y			
		);

  vdg_inst : entity work.mc6847
		generic map
		(
      CVBS_NOT_VGA  => false,
			CHAR_ROM_FILE => COCO1_SOURCE_ROOT_DIR & "roms/tiledata.hex"
		)
    port map
    (
			clk			=> clk_57M272,
			clk_ena => clk_14M318_ena,
      reset   => rst_57M272,

      hs_n    => hs_n,
      fs_n    => fs_n,
      da0     => da0,

			dd			=> vdg_data,
				
			red			=> red,
			green		=> green,
			blue		=> blue,
			hsync		=> hsync,
			vsync		=> vsync,

      cvbs    => open --cvbs
    );

  BLK_PIA_0 : block
    signal pia_irqa      	: std_logic;
    signal pia_irqb      	: std_logic;
    signal pia_pa         : std_logic_vector(7 downto 0);
    signal pia_pb         : std_logic_vector(7 downto 0);
    signal pia_ca1       	: std_logic;
    signal pia_ca2       	: std_logic;
    signal pia_cb1       	: std_logic;
    signal pia_cb2       	: std_logic;
  begin
    -- PIA edge inputs
    pia_ca1 <= '0';   -- HS
    pia_ca2 <= '0';   -- SEL1
    pia_cb1 <= '0';   -- FS
    pia_cb2 <= '0';   -- SEL2
    
    -- this is ultimately correct
    --cpu_irq <= pia_irqa or pia_irqb;
    -- but for now...
    cpu_irq <= '0';
    
    -- keyboard matrix
    process (clk_20M, reset_i(1))
      variable keys : std_logic_vector(7 downto 0);
    begin
      if reset_i(1) = '1' then
        keys := (others => '0');
      elsif rising_edge (clk_20M) then
        keys := (others => '0');
        -- note that row select is active low
        if pia_pb(0) = '0' then
          keys := keys or kbd_matrix(0).d;
        end if;
        if pia_pb(1) = '0' then
          keys := keys or kbd_matrix(1).d;
        end if;
        if pia_pb(2) = '0' then
          keys := keys or kbd_matrix(2).d;
        end if;
        if pia_pb(3) = '0' then
          keys := keys or kbd_matrix(3).d;
        end if;
        if pia_pb(4) = '0' then
          keys := keys or kbd_matrix(4).d;
        end if;
        if pia_pb(5) = '0' then
          keys := keys or kbd_matrix(5).d;
        end if;
        if pia_pb(6) = '0' then
          keys := keys or kbd_matrix(6).d;
        end if;
        if pia_pb(7) = '0' then
          keys := keys or kbd_matrix(7).d;
        end if;
      end if;
      -- key inputs are active low
      -- - bit 7 is joyin (TBD)
      pia_pa <= '1' & not keys(6 downto 0);
    end process;

    -- PIA (keyboard)
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
        irqa      	=> pia_irqa,
        irqb      	=> pia_irqb,
        pa_i        => pia_pa,
        pa_o				=> open,
        pa_oe				=> open,
        ca1       	=> pia_ca1,
        ca2_i      	=> pia_ca2,
        ca2_o				=> open,
        ca2_oe			=> open,
        pb_i				=> (others => 'X'),
        pb_o       	=> pia_pb,
        pb_oe				=> open,
        cb1       	=> pia_cb1,
        cb2_i      	=> pia_cb2,
        cb2_o				=> open,
        cb2_oe			=> open
      );
  end block BLK_PIA_0;
  
  BLK_PIA_1 : block
    signal pia_irqa      	: std_logic;
    signal pia_irqb      	: std_logic;
    signal pia_pa         : std_logic_vector(7 downto 0);
    signal pia_pb         : std_logic_vector(7 downto 0);
    signal pia_ca1       	: std_logic;
    signal pia_ca2       	: std_logic;
    signal pia_cb1       	: std_logic;
    signal pia_cb2       	: std_logic;
  begin
    -- PIA edge inputs
    pia_ca1 <= '0';   -- CD
    pia_ca2 <= '0';   -- CASSMOT
    pia_cb1 <= '0';   -- *CART
    pia_cb2 <= '0';   -- SNDEN

    -- jumper on the PCB (RAMSZ)
    pia_pb(2) <= COCO1_JUMPER_32K_RAM;
    
    -- this is ultimately correct
    --cpu_firq <= pia_irqa or pia_irqb;
    -- but for now...
    cpu_firq <= '0';
    
    -- PIA (keyboard)
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
        irqa      	=> pia_irqa,
        irqb      	=> pia_irqb,
        pa_i        => pia_pa,
        pa_o				=> open,
        pa_oe				=> open,
        ca1       	=> pia_ca1,
        ca2_i      	=> pia_ca2,
        ca2_o				=> open,
        ca2_oe			=> open,
        pb_i				=> (others => 'X'),
        pb_o       	=> pia_pb,
        pb_oe				=> open,
        cb1       	=> pia_cb1,
        cb2_i      	=> pia_cb2,
        cb2_o				=> open,
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
