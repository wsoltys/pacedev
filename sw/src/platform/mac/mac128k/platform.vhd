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

	alias clk_sys             : std_logic is clkrst_i.clk(0);
  alias rst_sys             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
  signal clk_8M_en			    : std_logic;
  signal clk_4M_en			    : std_logic;
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
	signal cpu_en_n		        : std_logic;
	signal cpu_r_wn				    : std_logic;
	signal cpu_a_ext				  : std_logic_vector(31 downto 0);
	alias cpu_a               : std_logic_vector(23 downto 1) is cpu_a_ext(23 downto 1);
	signal cpu_d_i			      : std_logic_vector(15 downto 0);
	signal cpu_d_o			      : std_logic_vector(15 downto 0);
  signal cpu_ipl_n          : std_logic_vector(2 downto 0);
  signal cpu_dtack_n        : std_logic;
  signal cpu_as_n           : std_logic;
  signal cpu_uds_n          : std_logic;
  signal cpu_lds_n          : std_logic;

  -- ROM signals        
	signal rom0_cs				    : std_logic;
  signal rom0_d_o           : std_logic_vector(15 downto 0);
	signal rom0_dtack         : std_logic;
	
  -- RAM signals
  signal ram0_cs            : std_logic;
  signal ram0_d_o           : std_logic_vector(15 downto 0);
  signal ram0_wr            : std_logic;
  
  -- VRAM signals       
	signal vram_cs				    : std_logic;
  signal vram_d_o           : std_logic_vector(15 downto 0);

  -- I/O signals
	signal video_counter_cs	  : std_logic;	
	signal iwm_cs			        : std_logic;
	signal iwm_d_o			      : std_logic_vector(15 downto 0);
	signal via_cs			        : std_logic;
	signal via_d_o			      : std_logic_vector(7 downto 0);
  signal via_irq_n          : std_logic;
  signal via_p2_h           : std_logic;
	signal avec_cs			      : std_logic;
	signal avec_d_o			      : std_logic_vector(15 downto 0);
	                        
  -- other signals   
  signal mem_overlay        : std_logic;
  signal tick_1Hz           : std_logic;
  
	alias platform_reset			: std_logic is inputs_i(3).d(0);
	alias platform_pause      : std_logic is inputs_i(3).d(1);
	
begin

--  Thus far I've actually implemented very little Mac-specific hardware behavior, 
--  so it's suprising that it gets to the question mark disk screen. 
--  The implemented hardware is:
--
--    68000 CPU (synthetic soft-CPU in the FPGA)
--    128 KB ROM from Mac Plus (in external Flash ROM)
--    512 KB RAM (in external SRAM)
--    address decoder maps ROM to $400000 and RAM to $000000
--    IWM floppy controller always returns $1F when read, and otherwise does nothing
--    Reads from address $FFFFFx return 24 + x. This makes interrupt vectors work correctly.
--    VIA is partially implemented: vblank and one second interrupts work, the interrupt enable and flags registers work, and the memory overlay bit works.
--    Video circuit reads from a hard-coded frame buffer address of $3FA700, which wraps around to the correct address in the 512 KB RAM space.

	cpu_en_n <= not (clk_8M_en and not platform_pause);

	-- add game reset later
	cpu_reset <= rst_sys or platform_reset;

	-- RAM chip selects
	-- - RAM $000000-$3FFFFF ($000000-$07FFFF installed - 512KB)
	ram0_cs <=		'1' when (mem_overlay = '0' and 
                          --STD_MATCH(cpu_a,  "00---------------------")) else 
                          STD_MATCH(cpu_a, X"0"&"0------------------")) else 
                '1' when (mem_overlay = '1' and 
                          --STD_MATCH(cpu_a, X"6"&"-------------------")) else 
                          STD_MATCH(cpu_a, X"6"&"0------------------")) else 
								'0';

  -- video ram $3FA000-$3FFFFF
  --            - $3FA000-$3FBFFF
  --vram_cs <=		'1' when STD_MATCH(cpu_a, X"3F"&   "101------------") else 
  -- video ram $07A000-$07FFFF
  --            - $07A000-$07BFFF
  vram_cs <=		'1' when STD_MATCH(cpu_a, X"07"&   "101------------") else 
  --            - $3FC000-$3FFFFF
                --'1' when STD_MATCH(cpu_a, X"3F"&   "11-------------") else 
  --            - $07C000-$07FFFF
                '1' when STD_MATCH(cpu_a, X"07"&   "11-------------") else 
                '0';

	-- ROM chip selects
	rom0_cs <= 	  -- MacPlus (128KB) only aliased $000000-$00FFFF
                '1' when (mem_overlay = '1' and 
                          STD_MATCH(cpu_a, X"0"&"-------------------")) else 
                -- Mac512K (64KB) also aliased $200000-$21FFFF
                '1' when (PLATFORM_VARIANT = "mac512k" and mem_overlay = '1' and 
                          STD_MATCH(cpu_a, X"2"&"-------------------")) else 
                '1' when  STD_MATCH(cpu_a, X"4"&"-------------------") else 
                '0';
                
  -- I/O chip selects
  -- IWM (floppy controller) $C00000-$DFFFFF
	iwm_cs <=     '1' when STD_MATCH(cpu_a,  "110--------------------") else 
                '0';
  -- VIA (6522) $E80000-$EFFFFF
	via_cs <=     '1' when STD_MATCH(cpu_a, X"E"&"1------------------") else 
                '0';

  -- Auto-vector $FFFFF0-$FFFFFF
	avec_cs <=    '1' when STD_MATCH(cpu_a, X"FFFFF"&            "---") else 
                '0';

  -- memory block write enables
  ram0_wr <= ram0_cs and clk_8M_en and not cpu_as_n and not cpu_r_wn;

	-- memory read mux
	cpu_d_i <=  -- decode ROM 1st for vector hack
              rom0_d_o when rom0_cs = '1' else
              vram_d_o when vram_cs = '1' else
							ram0_d_o when ram0_cs = '1' else
              iwm_d_o when iwm_cs = '1' else
              (via_d_o & via_d_o) when via_cs = '1' else
              avec_d_o when avec_cs = '1' else
							(others => '0');
  
  -- system timing
  process (clk_sys, rst_sys)
    --variable count : integer range 0 to 32/4-1;
    variable count : unsigned(4 downto 0);
  begin
    if rst_sys = '1' then
      clk_8M_en <= '0';
      clk_4M_en <= '0';
      count := (others => '0');
    elsif rising_edge(clk_sys) then
      clk_8M_en <= '0'; -- default
      clk_4M_en <= '0'; -- default
      if count(1 downto 0) = "00" then
        clk_8M_en <= '1';
        if count(2) = '0' then
          clk_4M_en <= '1';
        end if;
      end if;
      count := count + 1;
    end if;
    via_p2_h <= not count(count'left);
  end process;

  BLK_CPU : block
    signal wr_p : std_logic;
    signal delayed_dtack_n  : std_logic;
  begin
  
    --
    -- dtack logic
    --
    
    process (clk_sys)
      variable asn_r : std_logic_vector(10 downto 0) := (others => '1');
    begin
      if rst_sys = '1' then
        asn_r := (others => '1');
      elsif rising_edge(clk_sys) and clk_8M_en = '1' then
        delayed_dtack_n <= asn_r(2);
        -- de-assertion immediately clears the pipeline
        if cpu_as_n = '1' then
          asn_r := (others => '1');
        else
          asn_r := asn_r(asn_r'left-1 downto 0) & cpu_as_n;
        end if;
      end if;
    end process;

    cpu_dtack_n <=  --delayed_dtack_n when bootdata_f = '1' and bootdata_cs = '1' else
                    --sdram_dtackn when (bios_cs or ram_cs or sram_cs or memcard_cs or rom1_cs) = '1' else
                    (not rom0_dtack) when rom0_cs = '1' else
                    cpu_as_n;

    --
    -- interrupts
    --
--    process (clk_sys, rst_sys)
--      variable irq_r    : std_logic_vector(1 to 3) := (others => '0');
--    begin
--      if rst_sys = '1' then
--        cpu_ipl_n <= not "000";
--      elsif rising_edge(clk_sys) then
        cpu_ipl_n <= '1' & '1' & via_irq_n;
--      end if;
--    end process;
    
    tg68_inst : entity work.TG68
      port map
      (        
        clk           => clk_sys,
        reset         => not cpu_reset,
        clkena_in     => clk_8M_en,

        data_in       => cpu_d_i,
        IPL           => cpu_ipl_n,
        dtack         => cpu_dtack_n,
        addr          => cpu_a_ext,
        data_out      => cpu_d_o,
        as            => cpu_as_n,
        uds           => cpu_uds_n,
        lds           => cpu_lds_n,
        rw            => cpu_r_wn
      );

  end block BLK_CPU;
  
  BLK_ROM : block
  begin
    flash_o.d <= (others => 'X');
    flash_o.we <= '0';
    flash_o.cs <= rom0_cs;
    flash_o.oe <= '1';

    -- system ROM (64KB/128KB) resides in flash memory
    GEN_FLASH : if PACE_TARGET = PACE_TARGET_DE1 generate
    begin
      process (clk_sys, rst_sys)
        variable state : integer range 0 to 4;
      begin
        if rst_sys = '1' then
        elsif rising_edge(clk_sys) then
          if clk_8M_en = '1' then
            rom0_dtack <= '0';
            if rom0_cs = '1' then
              flash_o.a(flash_o.a'left downto 1) <= 
                std_logic_vector(RESIZE(unsigned(switches_i(0) & cpu_a(16 downto 1)),
                                        flash_o.a'length-1));
              if state = 0 then
                flash_o.a(0) <= '0';
                state := state + 1;
              elsif state = 1 then
                rom0_d_o(7 downto 0) <= flash_i.d(7 downto 0);
                flash_o.a(0) <= '1';
                state := state + 1;
              elsif state = 2 then
                rom0_d_o(15 downto 8) <= flash_i.d(7 downto 0);
                rom0_dtack <= '1';
                state := 0;
              end if;
            end if; -- rom0_cs
          end if; -- clk_8M_en
        end if;
      end process;
          
    else generate
      -- - data bus is 16 bits wide
      flash_o.a <= std_logic_vector(RESIZE(unsigned(cpu_a(16 downto 1)),
                                            flash_o.a'length));
      -- flash contents are byte-swapped
      rom0_d_o <= flash_i.d(7 downto 0) & flash_i.d(15 downto 8);
    end generate GEN_FLASH;
  end block BLK_ROM;

  BLK_RAM : block
  begin
  
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
      elsif rising_edge(clk_sys) then
        if clk_8M_en = '1' and cpu_as_n = '0' then
          -- system RAM (512KB) resides in SRAM
          -- - data bus is 16 bits wide
          sram_o.a <= std_logic_vector(RESIZE(unsigned(cpu_a(18 downto 1)), 
                                              sram_o.a'length));
          sram_o.be <= "00" & not (cpu_uds_n & cpu_lds_n);
        end if;
      end if;
    end process;
    
    sram_o.cs <= ram0_cs;
    sram_o.oe <= not ram0_wr;
    sram_o.we <= ram0_wr;
		sram_o.d(15 downto 0) <= cpu_d_o when ram0_wr = '1' else (others => 'Z');
    ram0_d_o <= sram_i.d(ram0_d_o'range);
    
  end block BLK_RAM;

  GEN_VRAM : if true generate
  
    signal vram0_cs				: std_logic;
    signal vram0_wr       : std_logic;
    signal vram0_d_o      : std_logic_vector(15 downto 0);
    signal vram1_cs				: std_logic;
    signal vram1_wr       : std_logic;
    signal vram1_d_o      : std_logic_vector(15 downto 0);

    signal bitmap0_d_o    : std_logic_vector(15 downto 0);
    signal bitmap1_d_o    : std_logic_vector(15 downto 0);
    
  begin

    -- video ram $3FA000-$3FFFFF
    -- - $3FA000-$3FBFFF
    vram0_cs <=		vram_cs when cpu_a(15 downto 13) = "101" else 
                  '0';
    -- - $3FC000-$3FFFFF
    vram1_cs <=		vram_cs when cpu_a(15 downto 14) = "11" else 
                  '0';

    vram0_wr <= vram0_cs and clk_8M_en and not cpu_as_n and not cpu_r_wn;
    vram1_wr <= vram1_cs and clk_8M_en and not cpu_as_n and not cpu_r_wn;

    vram_d_o <= vram0_d_o when vram0_cs = '1' else
                vram1_d_o;
                
    bitmap_o(1).d <= 	bitmap0_d_o when bitmap_i(1).a(13 downto 12) = "00" else
                      bitmap1_d_o;

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    vram0_inst : entity work.dpram
      generic map
      (
        init_file		=> VARIANT_ROM_DIR & "vram0.hex",
        widthad_a		=> 12,
        width_a     => 16
      )
      port map
      (
        clock_b			=> clk_sys,
        address_b		=> cpu_a(12 downto 1),
        wren_b			=> vram0_wr,
        data_b			=> cpu_d_o,
        q_b					=> vram0_d_o,

        clock_a			=> clk_video,
        address_a		=> bitmap_i(1).a(11 downto 0),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> bitmap0_d_o
      );

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    vram1_inst : entity work.dpram
      generic map
      (
        init_file		            => VARIANT_ROM_DIR & "vram1.hex",
        widthad_a		            => 13,
        width_a                 => 16
      )
      port map
      (
        clock_b			            => clk_sys,
        address_b		            => cpu_a(13 downto 1),
        wren_b			            => vram1_wr,
        data_b			            => cpu_d_o,
        q_b					            => vram1_d_o,

        clock_a			            => clk_video,
        address_a(12)           => not bitmap_i(1).a(12),
        address_a(11 downto 0)  => bitmap_i(1).a(11 downto 0),
        wren_a			            => '0',
        data_a			            => (others => 'X'),
        q_a					            => bitmap1_d_o
      );

  end generate GEN_VRAM;
  
  -- IWM (floppy controller)
  BLK_IWM : block
  begin
    iwm_d_o <= X"1F1F";
  end block BLK_IWM;
  
  BLK_VIA : block
    signal via_o_pa       : std_logic_vector(7 downto 0);
    signal via_o_pa_oe_l  : std_logic_vector(7 downto 0);
    signal via_i_ca1      : std_logic;
    signal via_i_ca2      : std_logic;
  begin

    -- controls ROM/RAM at $000000 (boot vectors)
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        mem_overlay <= '1';
      elsif rising_edge(clk_sys) then
        if via_o_pa_oe_l(4) = '0' then
          mem_overlay <= via_o_pa(4);
        end if;
      end if;
    end process;

    -- unmeta vblank
    process (clk_sys, rst_sys)
      variable vblank_r     : std_logic_vector(3 downto 0);
      alias vblank_um       : std_logic is vblank_r(vblank_r'left);
    begin
      if rst_sys = '1' then
        vblank_r := (others => '0');
      elsif rising_edge(clk_sys) then
        vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
      end if;
      -- VIA should interrupt on edge
      via_i_ca1 <= vblank_um;
    end process;
    
    -- from RTC
    via_i_ca2 <= tick_1Hz;
    
    via6522_inst : entity work.M6522
      port map
      (
        I_RS            => cpu_a(12 downto 9),
        I_DATA          => cpu_d_o(15 downto 8),
        O_DATA          => via_d_o,
        O_DATA_OE_L     => open,

        I_RW_L          => cpu_r_wn,
        I_CS1           => via_cs,
        -- only accessed on upper byte
        I_CS2_L         => cpu_uds_n,

        O_IRQ_L         => via_irq_n,

        -- port a
        I_CA1           => via_i_ca1, -- VBLANK
        I_CA2           => via_i_ca2, -- 1Hz (RTC)
        O_CA2           => open,
        O_CA2_OE_L      => open,

        I_PA            => X"80",   -- MESS MAC driver
        O_PA            => via_o_pa,
        O_PA_OE_L       => via_o_pa_oe_l,

        -- port b
        I_CB1           => '0',
        O_CB1           => open,
        O_CB1_OE_L      => open,

        I_CB2           => '0',
        O_CB2           => open,
        O_CB2_OE_L      => open,

        I_PB            => (others => '0'), -- video/mouse stuff
        O_PB            => open,            -- snd, rtc etc
        O_PB_OE_L       => open,

        RESET_L         => not cpu_reset,
        CLK             => clk_sys,
        I_P2_H          => via_p2_h,      -- high for phase 2 clock  ____----__
        ENA_4           => clk_4M_en      -- 4x system clock (4HZ)   _-_-_-_-_-
      );

  end block BLK_VIA;
  
  BLK_RTC : block
  begin
    process (clk_sys, rst_sys)
      variable count : integer range 0 to 4000000-1;
    begin
      if rst_sys = '1' then
        tick_1Hz <= '0';
        count := 0;
      elsif rising_edge(clk_sys) then
        if clk_4M_en = '1' then
          -- note extended pulse width
          tick_1Hz <= '0';  -- default
          if count = count'high then
            tick_1Hz <= '1';
            count := 0;
          else
            count := count + 1;
          end if;
        end if;
      end if;
    end process;
  end block BLK_RTC;
  
  BLK_AVEC : block
  begin
    -- quick hack for interrupt vectors
    avec_d_o <= X"0018" or cpu_a(3 downto 1);
  end block BLK_AVEC;
  
  -- unused outputs
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

end SYN;
