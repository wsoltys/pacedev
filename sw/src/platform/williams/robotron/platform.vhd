library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;
use work.project_pkg.all;

entity platform is
  generic
  (
    NUM_INPUT_BYTES   : integer
  );
  port
  (
    -- clocking and reset
    clkrst_i        : in from_CLKRST_t;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_MAPPED_INPUTS_t(0 to NUM_INPUT_BYTES-1);

    -- FLASH/SRAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_FLASH_t;
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;
		sdram_i         : in from_SDRAM_t;
		sdram_o         : out to_SDRAM_t;

    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    bitmap_o        : out to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    
    tilemap_i       : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    tilemap_o       : out to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

    sprite_reg_o    : out to_SPRITE_REG_t;
    sprite_i        : in from_SPRITE_CTL_t;
    sprite_o        : out to_SPRITE_CTL_t;
		spr0_hit				: in std_logic;

    -- various graphics information
    graphics_i      : in from_GRAPHICS_t;
    graphics_o      : out to_GRAPHICS_t;
    
    -- OSD
    osd_i           : in from_OSD_t;
    osd_o           : out to_OSD_t;

    -- sound
    snd_i           : in from_SOUND_t;
    snd_o           : out to_SOUND_t;
    
    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;

    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );

end platform;

architecture SYN of platform is

	constant ROBOTRON_VRAM_SIZE		: integer := 2**ROBOTRON_VRAM_WIDTHAD;

	alias clk_20M					    : std_logic is clkrst_i.clk(0);
  alias rst_20M             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
  signal clk_1M_en			    : std_logic;
	signal clk_1M_en_n		    : std_logic;
	signal cpu_r_wn				    : std_logic;
	signal cpu_vma				    : std_logic;
	signal cpu_ba				      : std_logic;
	signal cpu_bs				      : std_logic;
	signal cpu_a				      : std_logic_vector(15 downto 0);
	signal cpu_d_i			      : std_logic_vector(7 downto 0);
	signal cpu_d_o			      : std_logic_vector(7 downto 0);
	signal cpu_irq				    : std_logic;
	signal cpu_firq				    : std_logic;
	signal cpu_nmi				    : std_logic;
	signal cpu_halt			      : std_logic;

  -- generic address
  signal mem_a              : std_logic_vector(15 downto 0);
  
  -- ROM signals        
	signal rom0_cs				    : std_logic;
  signal rom0_d_o           : std_logic_vector(7 downto 0);
	signal romD_cs				    : std_logic;
  signal romD_d_o           : std_logic_vector(7 downto 0);
	signal romE_cs				    : std_logic;
  signal romE_d_o           : std_logic_vector(7 downto 0);
	signal romF_cs				    : std_logic;
  signal romF_d_o           : std_logic_vector(7 downto 0);
	
  -- VRAM signals       
	signal vram_cs				    : std_logic;
  signal vram_wr            : std_logic;
  signal vram_d_i           : std_logic_vector(7 downto 0);
  signal vram_d_o           : std_logic_vector(7 downto 0);

  -- RAM signals        
	signal wram_cs				    : std_logic;
  signal wram_wr            : std_logic;
  alias wram_d_o      	    : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- I/O signals
	signal palette_cs			    : std_logic;
	signal palette_r			    : PAL_A_t(15 downto 0);
	signal widget_pia_cs			: std_logic;
	signal widget_pia_d_o			: std_logic_vector(7 downto 0);
	signal rom_pia_cs				  : std_logic;
	signal rom_pia_d_o        : std_logic_vector(7 downto 0);  
	signal rom_pia_irqa			  : std_logic;
	signal rom_pia_irqb			  : std_logic;
	signal vram_select_cs			: std_logic;
  signal vram_select_r      : std_logic;
  signal vram_sel           : std_logic;
  signal sc02_cs            : std_logic;
  signal sc02_wr            : std_logic;
	signal video_counter_cs	  : std_logic;	
	signal nvram_cs				    : std_logic;
	signal nvram_wr				    : std_logic;
	signal nvram_data			    : std_logic_vector(3 downto 0);
	signal io_cs			        : std_logic;
	signal io_d_o			        : std_logic_vector(7 downto 0);
	                        
  -- other signals   
	alias platform_reset			: std_logic is inputs_i(3).d(0);
	alias platform_pause      : std_logic is inputs_i(3).d(1);
	signal va11						    : std_logic;
	signal count240				    : std_logic;
	
begin

	-- cpu09 core uses negative clock edge
	clk_1M_en_n <= not (clk_1M_en and not platform_pause);

	-- add game reset later
	cpu_reset <= rst_20M or platform_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(16 downto 0)	<= 	std_logic_vector(resize(unsigned(mem_a), 17));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length)) 
								when (wram_wr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not wram_wr;
  sram_o.we <= wram_wr;

	-- ROM chip selects
  -- $0000-$8FFF
  --            $0000-$7FFF
	rom0_cs <= 	  '1' when STD_MATCH(mem_a,  "0---------------") else 
  --            $8000-$8FFF
                '1' when STD_MATCH(mem_a, X"8"&"------------") else 
                '0';
  -- video ram $0000-$97FF
  vram_cs <=		'1' when STD_MATCH(mem_a,  "0---------------") else
                '1' when STD_MATCH(mem_a, X"8"&"------------") else
                '1' when STD_MATCH(mem_a, X"9"&"0-----------") else 
                '0';
	-- ROMS $D000-$FFFF
	romD_cs <= 	  '1' when STD_MATCH(mem_a, X"D"&"------------") else '0';
	romE_cs <= 	  '1' when STD_MATCH(mem_a, X"E"&"------------") else '0';
	romF_cs <= 	  '1' when STD_MATCH(mem_a, X"F"&"------------") else '0';

	-- RAM chip selects
	-- RAM $9800-$BFFF
	wram_cs <=		'1' when STD_MATCH(mem_a,  "101-------------") else
								'1' when STD_MATCH(mem_a, X"9"&"1-----------") else
								'0';

  -- I/O chip selects
  -- I/O $C000-$CFFF
	io_cs <=      '1' when STD_MATCH(mem_a, X"C"&"------------") else '0';

	-- I/O decoding
  -- Palette $C000-$C00F
	palette_cs <=				'1' when STD_MATCH(mem_a, X"C00"&"----") else '0';
	-- WIDGET PIA $C804-$C807
	widget_pia_cs <= 		'1' when STD_MATCH(mem_a, X"C80"&"01--") else '0';
	-- ROM PIA $C80C-$C80F
	rom_pia_cs <= 			'1' when STD_MATCH(mem_a, X"C80"&"11--") else '0';
  -- VRAM SWITCH $C900-$C9FF
  vram_select_cs <=   '1' when STD_MATCH(mem_a, X"C9"&"--------") else '0';
	-- blitter $CA00-$CA07
	sc02_cs <=	        '1' when STD_MATCH(mem_a, X"CA0"&"0---") else '0';
	-- video counter $CB00-$CBFF
	video_counter_cs <=	'1' when STD_MATCH(mem_a, X"CB"&"--------") else '0';
	-- nvram $CC00-$CFFF
	nvram_cs <=					'1' when STD_MATCH(mem_a, X"C"&"11----------") else '0';

  -- memory block write enables
	nvram_wr <= (nvram_cs and clk_1M_en and not cpu_r_wn);
  sc02_wr <= sc02_cs and clk_1M_en and not cpu_r_wn;
	
	-- I/O bank
	io_d_o <= -- palette is WO
            widget_pia_d_o when widget_pia_cs = '1' else
						rom_pia_d_o when rom_pia_cs = '1' else
						graphics_i.y(7 downto 2) & "00" when video_counter_cs = '1' else
						(X"F" & nvram_data) when nvram_cs = '1' else
						(others => '0');
								
	-- memory read mux
	cpu_d_i <=  -- ROM $0000-$8FFF, VRAM $0000-$97FF (overlapping)
              -- so decode ROM space first, and fall back to VRAM
              rom0_d_o when (rom0_cs = '1' and vram_sel = '1') else
							vram_d_o when vram_cs = '1' else
							wram_d_o when wram_cs = '1' else
              io_d_o when io_cs = '1' else
              romD_d_o when romD_cs = '1' else
							romE_d_o when romE_cs = '1' else
							romF_d_o when romF_cs = '1' else
							(others => '0');
	
	-- memory write enables
	process (clk_20M, clk_1M_en)
	begin
		if rising_edge(clk_20M) then
			if clk_1M_en = '1' then
				-- always write thru to RAM unless ROM is addressed
				--wram_wr <= not cpu_r_wn and not (rom_d_cs or rom_e_cs or (data_c_cs and sram_addr_hi(16)));
				wram_wr <= not cpu_r_wn and clk_1M_en and wram_cs;
			else
				wram_wr <= '0';
			end if;
		end if;
	end process;
		
	-- implementation of palette RAM
	process (clk_20M)
		variable offset : integer range 0 to 2**4-1;
	begin
		if rising_edge(clk_20M) then
      if clk_1M_en = '1' then
        if palette_cs = '1' and clk_1M_en = '1' and cpu_r_wn = '0' then
          offset := to_integer(unsigned(mem_a(3 downto 0)));
          palette_r(offset) <= cpu_d_o;
        end if;
      end if;
		end if;
		graphics_o.pal <= palette_r;
	end process;

  -- vram select register
	process (clk_20M, platform_reset)
	begin
    if platform_reset = '1' then
      vram_select_r <= '0';
		elsif rising_edge(clk_20M) then
      if clk_1M_en = '1' then
        if vram_select_cs = '1' and cpu_r_wn = '0' then
          -- 0=VRAM, 1=ROM
          vram_select_r <= cpu_d_o(0);
        end if;
      end if;
		end if;
	end process;
  
	-- irqa interrupt at scanline 240
	process (clk_20M, rst_20M)
	begin
		if rst_20M = '1' then
			count240 <= '0';
		elsif rising_edge(clk_20M) then
			if graphics_i.y = std_logic_vector(to_unsigned(0, graphics_i.y'length)) then
				count240 <= '0';
			-- check for 240
			--elsif video_counter = 240 then
			elsif graphics_i.y = std_logic_vector(to_unsigned(239, graphics_i.y'length)) then
				count240 <= '1';
			end if;
		end if;
	end process;

	-- irqb every 16 scanlines
	va11 <= graphics_i.y(5);

	-- cpu interrupts
	cpu_irq <= rom_pia_irqa or rom_pia_irqb;
	cpu_firq <= '0';
	cpu_nmi <= '0';

  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --tilemap_o <= NULL_TO_TILEMAP_CTL;
  graphics_o.bit8(0) <= (others => '0');
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

  -- system timing
  process (clk_20M, rst_20M)
    variable count : integer range 0 to 20-1;
  begin
    if rst_20M = '1' then
      count := 0;
    elsif rising_edge(clk_20M) then
      clk_1M_en <= '0'; -- default
      case count is
        when 0 =>
          clk_1M_en <= '1';
        when others =>
          null;
      end case;
      if count = count'high then
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;

	cpu_inst : entity work.cpu09
		port map
		(	
			clk				=> clk_1M_en_n,
			rst				=> cpu_reset,
			rw				=> cpu_r_wn,
			vma				=> cpu_vma,
      ba        => cpu_ba,
      bs        => cpu_bs,
			addr		  => cpu_a,
		  data_in		=> cpu_d_i,
		  data_out	=> cpu_d_o,
			halt			=> cpu_halt,
			hold			=> '0',
			irq				=> cpu_irq,
			firq			=> cpu_firq,
			nmi				=> cpu_nmi
		);

  BLK_BLITTER : block

    signal ba_bs          : std_logic := '0';
    
    signal blit_busy      : std_logic;
    signal blit_wr        : std_logic;
    signal blit_vram_sel  : std_logic;
    signal blit_a         : std_logic_vector(15 downto 0);
    signal blit_d         : std_logic_vector(7 downto 0);
    
  begin
  
    -- bus available signal to the SC02
    ba_bs <= cpu_ba and cpu_bs;

    mem_a <= blit_a when blit_busy = '1' else cpu_a;
    -- blitter can force VRAM selection
    vram_sel <= '0' when (blit_busy = '1' and blit_vram_sel = '1') else
                  vram_select_r;
    vram_d_i <= blit_d when blit_busy = '1' else cpu_d_o;
    vram_wr <=  blit_wr when blit_busy = '1' else
                (clk_1M_en and not cpu_r_wn);
    
    -- blitter chip(s)
    sc02_inst : entity work.sc02
      generic map
      (
        REVISION  => 1
      )
      port map
      (
        clk       => clk_20M,
        clk_en    => '1',
        rst       => rst_20M,
        
        wr        => sc02_wr,
        d         => cpu_d_o,
        a         => mem_a(2 downto 0),
        ba_bs     => ba_bs,
        halt      => cpu_halt,
        
        busy      => blit_busy,
        vram_sel  => blit_vram_sel,
        
        mem_wr    => blit_wr,
        mem_a     => blit_a,
        mem_d_i   => cpu_d_i,
        mem_d_o   => blit_d
      );

  end block BLK_BLITTER;
  
	-- Battery-backed CMOS RAM
	nvram_inst : entity work.spram
		generic map
		(
			init_file		=> VARIANT_ROM_DIR & "nvram.hex",
			widthad_a		=> 10,
			width_a		  => 4
		)
		port map
		(
			clock				=> clk_20M,
			address			=> mem_a(9 downto 0),
			wren				=> nvram_wr,
			data				=> cpu_d_o(3 downto 0),
			q						=> nvram_data
		);

	GEN_FPGA_ROMS : if true generate
	
		rom_D000_inst : entity work.sprom
			generic map
			(
        init_file		=> VARIANT_ROM_DIR & "sba.hex",
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> mem_a(11 downto 0),
				q					=> romD_d_o
			);
		
		rom_E000_inst : entity work.sprom
			generic map
			(
        init_file		=> VARIANT_ROM_DIR & "sbb.hex",
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> mem_a(11 downto 0),
				q					=> romE_d_o
			);
		
		rom_F000_inst : entity work.sprom
			generic map
			(
        init_file		=> VARIANT_ROM_DIR & "sbc.hex",
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_20M,
				address		=> mem_a(11 downto 0),
				q					=> romF_d_o
			);
		
    GEN_ROMS : for i in 1 to 9 generate
      type rom_data_t is array (natural range <>) of std_logic_vector(7 downto 0);
      signal rom_data : rom_data_t(1 to 9);
    begin

      rom_inst : entity work.sprom
        generic map
        (
          init_file		=> VARIANT_ROM_DIR & "sb" & integer'image(i) & ".hex",
          widthad_a		=> 12
        )
        port map
        (
          clock			=> clk_20M,
          address		=> mem_a(11 downto 0),
          q					=> rom_data(i)
        );
        
      rom0_d_o <= rom_data(1) when STD_MATCH(mem_a, X"0" & "------------") else
                  rom_data(2) when STD_MATCH(mem_a, X"1" & "------------") else
                  rom_data(3) when STD_MATCH(mem_a, X"2" & "------------") else
                  rom_data(4) when STD_MATCH(mem_a, X"3" & "------------") else
                  rom_data(5) when STD_MATCH(mem_a, X"4" & "------------") else
                  rom_data(6) when STD_MATCH(mem_a, X"5" & "------------") else
                  rom_data(7) when STD_MATCH(mem_a, X"6" & "------------") else
                  rom_data(8) when STD_MATCH(mem_a, X"7" & "------------") else
                  rom_data(9) when STD_MATCH(mem_a, X"8" & "------------") else
                  (others => 'Z');
                  
    end generate GEN_ROMS;
    
	end generate GEN_FPGA_ROMS;

  BLK_VRAM : block
  
    signal vram0_cs				: std_logic;
    signal vram0_wr       : std_logic;
    signal vram0_d_o      : std_logic_vector(7 downto 0);
    signal vram8_cs				: std_logic;
    signal vram8_wr       : std_logic;
    signal vram8_d_o      : std_logic_vector(7 downto 0);
    signal vram9_cs				: std_logic;
    signal vram9_wr       : std_logic;
    signal vram9_d_o      : std_logic_vector(7 downto 0);

    signal bitmap0_d_o    : std_logic_vector(7 downto 0);
    signal bitmap8_d_o    : std_logic_vector(7 downto 0);
    signal bitmap9_d_o    : std_logic_vector(7 downto 0);
    
  begin

    -- video ram $0000-$9800
    vram0_cs <=		'1' when STD_MATCH(mem_a,  "0---------------") else '0';
    vram8_cs <=		'1' when STD_MATCH(mem_a, X"8"&"------------") else '0';
    vram9_cs <= 	'1' when STD_MATCH(mem_a, X"9"&"0-----------") else '0';

    vram0_wr <= vram0_cs and vram_wr;
    vram8_wr <= vram8_cs and vram_wr;
    vram9_wr <= vram9_cs and vram_wr;

    vram_d_o <= vram0_d_o when vram0_cs = '1' else
                vram8_d_o when vram8_cs = '1' else
                vram9_d_o;
                
    bitmap_o(1).d <= 	bitmap0_d_o when bitmap_i(1).a(15) = '0' else
                      bitmap8_d_o when bitmap_i(1).a(15 downto 12) = X"8" else
                      bitmap9_d_o;

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    vram0_inst : entity work.dpram
      generic map
      (
        init_file		=> VARIANT_ROM_DIR & "vram.hex",
        widthad_a		=> ROBOTRON_VRAM_WIDTHAD
      )
      port map
      (
        clock_b			=> clk_20M,
        address_b		=> mem_a(ROBOTRON_VRAM_WIDTHAD-1 downto 0),
        wren_b			=> vram0_wr,
        data_b			=> vram_d_i,
        q_b					=> vram0_d_o,

        clock_a			=> clk_video,
        address_a		=> bitmap_i(1).a(ROBOTRON_VRAM_WIDTHAD-1 downto 0),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> bitmap0_d_o
      );

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    vram8_inst : entity work.dpram
      generic map
      (
        --numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        clock_b			=> clk_20M,
        address_b		=> mem_a(11 downto 0),
        wren_b			=> vram8_wr,
        data_b			=> vram_d_i,
        q_b					=> vram8_d_o,

        clock_a			=> clk_video,
        address_a		=> bitmap_i(1).a(11 downto 0),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> bitmap8_d_o
      );

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    vram9_inst : entity work.dpram
      generic map
      (
        --numwords_a	=> 2048,
        widthad_a		=> 11
      )
      port map
      (
        clock_b			=> clk_20M,
        address_b		=> mem_a(10 downto 0),
        wren_b			=> vram9_wr,
        data_b			=> vram_d_i,
        q_b					=> vram9_d_o,

        clock_a			=> clk_video,
        address_a		=> bitmap_i(1).a(10 downto 0),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> bitmap9_d_o
      );

  end block BLK_VRAM;
  
	widget_pia : entity work.pia6821
		port map
		(	
			clk       	=> clk_1M_en,
	    rst       	=> rst_20M,
	    cs        	=> widget_pia_cs,
	    rw        	=> cpu_r_wn,
	    addr      	=> mem_a(1 downto 0),
	    data_in   	=> cpu_d_o,
		 	data_out  	=> widget_pia_d_o,
		 	irqa      	=> open,
		 	irqb      	=> open,
		 	pa_i       	=> inputs_i(0).d,
      pa_o        => open,
      pa_oe       => open,
		 	ca1       	=> '0',
		 	ca2_i      	=> '0',
      ca2_o       => open,
      ca2_oe      => open,
		 	pb_i      	=> inputs_i(1).d,
      pb_o        => open,
      pb_oe       => open,
		 	cb1       	=> '0',
		 	cb2_i      	=> '0',
      cb2_o       => open,
      cb2_oe      => open
		);

	rom_pia : entity work.pia6821
		port map
		(	
			clk       	=> clk_1M_en,
	    rst       	=> rst_20M,
	    cs        	=> rom_pia_cs,
	    rw        	=> cpu_r_wn,
	    addr      	=> mem_a(1 downto 0),
	    data_in   	=> cpu_d_o,
		 	data_out  	=> rom_pia_d_o,
		 	irqa      	=> rom_pia_irqa,
		 	irqb      	=> rom_pia_irqb,
		 	pa_i      	=> inputs_i(2).d,
      pa_o        => open,
      pa_oe       => open,
		 	ca1       	=> count240,
		 	ca2_i      	=> '0',
      ca2_o       => open,
      ca2_oe      => open,
		 	pb_i      	=> (others => '0'),
      pb_o        => open,
      pb_oe       => open,
		 	cb1       	=> va11,
		 	cb2_i      	=> '0',
      cb2_o       => open,
      cb2_oe      => open
		);

end SYN;
