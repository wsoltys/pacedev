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
use work.project_pkg.all;
use work.mce6309_pack.all;

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
    sram_i	        : in from_SRAM_t;
    sram_o	        : out to_SRAM_t;
    sdram_i	        : in from_SDRAM_t;
    sdram_o	        : out to_SDRAM_t;

    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    bitmap_o        : out to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    
    tilemap_i       : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    tilemap_o       : out to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

    sprite_reg_o    : out to_SPRITE_REG_t;
    sprite_i        : in from_SPRITE_CTL_t;
    sprite_o        : out to_SPRITE_CTL_t;
    spr0_hit	      : in std_logic;

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
end entity platform;

architecture SYN of platform is

	alias clk_40M					: std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	signal clk_2M_ena			: std_logic;
	
  -- uP signals  
  alias cpu_clk             : std_logic is clk_40M;
  alias cpu_clk_en          : std_logic is clk_2M_ena;
  signal cpu_a              : std_logic_vector(15 downto 0);
  signal cpu_rw             : std_logic;
  signal cpu_vma            : std_logic;
  signal cpu_d_i            : std_logic_vector(7 downto 0);
  signal cpu_d_o            : std_logic_vector(7 downto 0);
  signal cpu_halt           : std_logic;
  signal cpu_hold           : std_logic;
  signal cpu_irq            : std_logic;
  signal cpu_nmi            : std_logic;
  signal cpu_firq           : std_logic;
	                        
  -- ROM signals        
	signal rom_cs					    : std_logic;
  signal rom_d_o            : std_logic_vector(7 downto 0);
                        
  -- keyboard signals
	signal kbd_cs					    : std_logic;
	signal kbd_d_o				    : std_logic_vector(7 downto 0);
		                        
  -- VRAM signals       
	signal vram_cs				    : std_logic;
  signal vram_wr            : std_logic;
  signal vram_d_o           : std_logic_vector(7 downto 0);

  -- RAM signals        
  signal ram_wr             : std_logic;
  alias ram_d_o      	      : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- interrupt signals
  signal vector_cs          : std_logic;
	signal int_cs					    : std_logic;
  signal int_status         : std_logic_vector(7 downto 0);

  -- other signals      
	alias game_reset			    : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	signal cpu_reset			    : std_logic;  

begin

  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CPU_FREQ_MHz=" &  real'image(CPU_FREQ_MHz) &
            " CPU_CLK_ENA_DIV=" & integer'image(MCE6309_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

  -- check invalid combinations of options
  
	cpu_reset <= clkrst_i.arst or game_reset;

  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not ram_wr;
  sram_o.we <= ram_wr;

	-- memory chip selects
  -- ROM $0000-$07FF
	rom_cs <= '1' when cpu_a(15 downto 11) = "00000" else '0';
	-- RDINTSTATUS $37E0-$37E3 (active high)
	int_cs <= '1' when cpu_a(15 downto 2) = (X"37E" & "00") else '0';
	-- KEYBOARD $3800-$38FF
	kbd_cs <= '1' when cpu_a(15 downto 10) = (X"3" & "10") else '0';
	-- VRAM $3C00-$3FFF
	vram_cs <= '1' when cpu_a(15 downto 10) = (X"3" & "11") else '0';
  -- VECTORS $FFFE=$FFFF
  vector_cs <= '1' when cpu_a(15 downto 4) = X"FFF" else '0';
  
	-- memory write enables
	vram_wr <= vram_cs and not cpu_rw;
  
	-- always write thru to RAM
	ram_wr <= not cpu_rw;

  BLK_RD_MUX : block
    signal mem_d              : std_logic_vector(7 downto 0);
  begin
    -- read mux
    cpu_d_i <= mem_d when cpu_rw = '1';

    -- memory read mux
    mem_d <= 	rom_d_o when rom_cs = '1' else
              kbd_d_o when kbd_cs = '1' else
              vram_d_o when vram_cs = '1' else
              X"00" when vector_cs = '1' else
              ram_d_o;
    
  end block BLK_RD_MUX;
  
	KBD_MUX : process (cpu_a, inputs_i)
  	variable kbd_d_o_v : std_logic_vector(7 downto 0);
	begin
  	kbd_d_o_v := X"00";
		for i in 0 to 7 loop
	 		if cpu_a(i) = '1' then
			  kbd_d_o_v := kbd_d_o_v or inputs_i(i).d;
		  end if;
		end loop;
  	-- assign the output
		kbd_d_o <= kbd_d_o_v;
  end process KBD_MUX;

  graphics_o.bit8(0)(3) <= '0';  -- alt character set?
  
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> MCE6309_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_40M,
			reset			=> clkrst_i.rst(0),
			clk_en		=> clk_2M_ena
		);

  cpu_halt <= '0';
  cpu_hold <= '0';

  GEN_CPU : if MCE6309_USE_CPU09 generate
  begin
    cpu_inst : entity work.cpu09
      generic map
      (
        CLK_POL   => '1'
      )
      port map 
      (    
        clk	      => cpu_clk,
        clk_en    => cpu_clk_en,
        rst       => cpu_reset,
        rw	      => cpu_rw,
        vma       => cpu_vma,
        addr      => cpu_a(15 downto 0),
        data_in   => cpu_d_i,
        data_out  => cpu_d_o,
        halt      => cpu_halt,
        hold      => cpu_hold,
        irq       => cpu_irq,
        nmi       => cpu_nmi,
        firq      => cpu_firq
      );
  else generate
    cpu_inst : entity work.mce6309
      generic map
      (
        MODE            => M6809,
        CYCLE_ACCURATE  => true,
        HAS_BDM         => true
      )
      port map
      (
        -- clocking, reset
        clk             => cpu_clk,
        clken           => cpu_clk_en,
        reset           => cpu_reset,
        
        -- bus signals
        rw              => cpu_rw,
        vma             => cpu_vma,
        address         => cpu_a(15 downto 0),
        data_i  	      => cpu_d_i,
        data_o 		 	    => cpu_d_o,
        data_oe 		    => open,
        lic 				    => open,
        halt      	    => cpu_halt,
        hold      	    => cpu_hold,
        irq       	    => cpu_irq,
        firq      	    => cpu_firq,
        nmi       	    => cpu_nmi,
        
        -- bdm signals
        bdm_clk         => '0',
        bdm_rst         => '0',
        bdm_mosi        => '0',
        bdm_miso        => open,
        bdm_i           => '0',
        bdm_o           => open,
        bdm_oe          => open,
        
        -- misc signals
        op_fetch        => open
      );
  end generate GEN_CPU;
  
  rom_inst : entity work.sprom
    generic map
    (
      init_file		=> "../../../../../src/test/mce6309/roms/rom1.hex",
      widthad_a		=> 11
    )
    port map
    (
      clock			=> clk_40M,
      address		=> cpu_a(10 downto 0),
      q					=> rom_d_o
    );
  
	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/trs80/m1/roms/" & TRS80_M1_CHARSET_ROM,
			widthad_a		=> 11
		)
		port map
		(
			clock			=> clk_video,
			address		=> tilemap_i(1).tile_a(10 downto 0),
			q					=> tilemap_o(1).tile_d(7 downto 0)
		);
	
  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../src/platform/trs80/m3/roms/trsvram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			clock_b			=> clk_40M,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> cpu_d_o,
			q_b					=> vram_d_o,
	
		  clock_a			=> clk_video,
			address_a		=> tilemap_i(1).map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d(7 downto 0)
		);
    tilemap_o(1).map_d(tilemap_o(1).map_d'left downto 8) <= (others => '0');
    
--  BLK_INTERRUPTS : block
--    signal tick_1ms   : std_logic := '0';
--    signal timer_irq  : std_logic := '0';
--  begin
--
--    -- interrupt register
--    process (clk_40M, cpu_reset)
--      variable intreg_r : std_logic := '0';
--    begin
--      if cpu_reset = '1' then
--        intreg_r := '0';
--        int_status <= (others => '0');
--      elsif rising_edge(clk_40M) then
--        -- clear interrupts on falling edge of read
--        if intreg_r = '1' and (int_cs = '0' or cpu_mem_rd = '0') then
--          int_status(6) <= '0';
--          int_status(7) <= '0';
--        end if;
--        -- timer interrupt
--        if timer_irq = '1' then
--          int_status(7) <= '1';
--        end if;
--        -- FDC interrupt
--        if fdc_drq_int = '1' then
--          int_status(6) <= '1';
--        end if;
--        intreg_r := int_cs and cpu_mem_rd;
--      end if;
--    end process;
--
--    cpu_irq <= '1' when int_status /= X"00" else '0';
--    
--    -- 1ms tick for slower counters
--    process (clk_40M, cpu_reset)
--      subtype count_1ms_t is integer range 0 to CLK0_FREQ_MHz*1000-1;
--      variable count_1ms : count_1ms_t := 0;
--    begin
--      if cpu_reset = '1' then
--        count_1ms := 0;
--        tick_1ms <= '0';
--      elsif rising_edge(clk_40M) then
--        tick_1ms <= '0';  -- default
--        if count_1ms = count_1ms_t'high then
--          count_1ms := 0;
--          tick_1ms <= '1';
--        else
--          count_1ms := count_1ms + 1;
--        end if;
--      end if;
--    end process;
--    
--    -- TIMER interrupt (40Hz/25ms)
--    process (clk_40M, cpu_reset)
--      subtype count_25ms_t is integer range 0 to 25-1;
--      variable count_25ms : count_25ms_t := 0;
--    begin
--      if cpu_reset = '1' then
--        timer_irq <= '0';
--        count_25ms := 0;
--      elsif rising_edge(clk_40M) then
--        timer_irq <= '0';   -- default
--        if tick_1ms = '1' then
--          if count_25ms = count_25ms_t'high then
--            timer_irq <= '1';
--            count_25ms := 0;
--          else
--            count_25ms := count_25ms + 1;
--          end if;
--        end if; -- tick_1ms
--      end if;
--    end process;
--    
--  end block BLK_INTERRUPTS;

  leds_o <= (others => '0');

  -- unused outputs
  snd_o <= NULL_TO_SOUND;
	sprite_reg_o <= NULL_TO_SPRITE_REG;
	sprite_o <= NULL_TO_SPRITE_CTL;
	ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
  --gp_o <= NULL_TO_GP;

end architecture SYN;
