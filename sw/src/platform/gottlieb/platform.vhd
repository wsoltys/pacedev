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

	alias clk_20M					    : std_logic is clkrst_i.clk(0);
  alias rst_20M             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
  signal clk_5M_en			    : std_logic;
	signal clk_5M_en_n		    : std_logic;
	signal cpu_rd_n				    : std_logic;
	signal cpu_wr_n				    : std_logic;
  signal cpu_iom            : std_logic;
	signal cpu_a_ext	        : std_logic_vector(19 downto 0);
	alias cpu_a	              : std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
	signal cpu_d_i			      : std_logic_vector(7 downto 0);
	signal cpu_d_o			      : std_logic_vector(7 downto 0);
	signal cpu_intr				    : std_logic;
	signal cpu_inta				    : std_logic;
	signal cpu_nmi				    : std_logic;

  -- SPRITE signals
	signal sprite_cs				  : std_logic;
  signal sprite_wr          : std_logic;
  
  -- RAM signals        
	signal wram_cs				    : std_logic;
  signal wram_wr            : std_logic;
  alias wram_d_o      	    : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- VRAM/CRAM signals       
	signal vram_cs				    : std_logic;
	signal vram_wr				    : std_logic;
  signal vram_d_o           : std_logic_vector(7 downto 0);
	signal cram_cs				    : std_logic;
	signal cram_wr				    : std_logic;
  signal cram_d_o           : std_logic_vector(7 downto 0);

  -- ROM signals        
	signal rom_cs				      : std_logic;
  signal rom_d_o            : std_logic_vector(7 downto 0);
	
  -- I/O signals
	signal io_cs				      : std_logic;
  signal io_d_o             : std_logic_vector(7 downto 0);
	signal palette_cs			    : std_logic;
	signal palette_r			    : PAL_A_t(0 to 15);
	signal nvram_cs				    : std_logic;
	signal nvram_wr				    : std_logic;
	signal nvram_d_o          : std_logic_vector(7 downto 0);
	                        
  -- other signals   
  signal general_output_r       : std_logic_vector(7 downto 0);
    alias background_priority   : std_logic is general_output_r(0);
  
	alias platform_reset			    : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	alias platform_pause          : std_logic is inputs_i(NUM_INPUT_BYTES-1).d(1);
	
begin

	-- cpu09 core uses negative clock edge
	clk_5M_en_n <= not (clk_5M_en and not platform_pause);
	--clk_5M_en_n <= not (clk_5M_en and not platform_pause) or cpu_halt;

	-- add game reset later
	cpu_reset <= rst_20M or platform_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(16 downto 0)	<= 	std_logic_vector(resize(unsigned(cpu_a), 17));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length)) 
								when (wram_wr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not wram_wr;
  sram_o.we <= wram_wr;

	-- nvram $0000-$0FFF
	nvram_cs <=		'1' when STD_MATCH(cpu_a, X"0"&"------------") else '0';
	-- RAM $1000-$1FFF, $2000-$2FFF
	wram_cs <=		'1' when STD_MATCH(cpu_a, X"1"&"------------") else
                '1' when STD_MATCH(cpu_a, X"2"&"------------") else
								'0';
  -- sprite ram $3000-$30FF
  sprite_cs <=	'1' when STD_MATCH(cpu_a,    X"30"&"--------") else
                '0';
  -- video ram $3800-$3BFF
  vram_cs <=		'1' when STD_MATCH(cpu_a, X"3"&"10----------") else
                '0';
  -- character ram $4000-$4FFF
  cram_cs <=		'1' when STD_MATCH(cpu_a, X"4"&"------------") else
                '0';
  -- Palette $5000-$501F
	palette_cs <=	'1' when STD_MATCH(cpu_a,    X"50"&"000-----") else '0';
  -- I/O $5800-$5FFF
  io_cs <=		  '1' when STD_MATCH(cpu_a, X"5"&"1-----------") else
                '0';
	-- ROM $A000-$FFFF
  --            $A000-$BFFF
	rom_cs <= 	  '1' when STD_MATCH(cpu_a,  "101-------------") else 
  --            $C000-$FFFF
                '1' when STD_MATCH(cpu_a,  "11--------------") else 
                '0';

  -- memory block write enables
	nvram_wr <= nvram_cs and not cpu_iom and not cpu_wr_n;
  sprite_wr <= sprite_cs and not cpu_iom and not cpu_wr_n;
  wram_wr <= wram_cs and not cpu_iom and not cpu_wr_n;
  vram_wr <= vram_cs and not cpu_iom and not cpu_wr_n;
  cram_wr <= cram_cs and not cpu_iom and not cpu_wr_n;

	-- memory read mux
	cpu_d_i <=  nvram_d_o when nvram_cs = '1' else
							wram_d_o when wram_cs = '1' else
							vram_d_o when vram_cs = '1' else
							cram_d_o when cram_cs = '1' else
							--palette_d_o when palette_cs = '1' else
							io_d_o when io_cs = '1' else
              rom_d_o when rom_cs = '1' else
							(others => '0');
		
  -- system timing
  process (clk_20M, rst_20M)
    -- 20/4=5MHz
    variable count : integer range 0 to 20/4-1;
  begin
    if rst_20M = '1' then
      count := 0;
    elsif rising_edge(clk_20M) then
      clk_5M_en <= '0'; -- default
      case count is
        when 0 =>
          clk_5M_en <= '1';
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

  BLK_CPU : block
  begin
    cpu_inst : entity work.cpu86
       port map
       ( 
          clk      => clk_5M_en,
          dbus_in  => cpu_d_i,
          intr     => cpu_intr,
          nmi      => cpu_nmi,
          por      => cpu_reset,
          abus     => cpu_a_ext,
          dbus_out => cpu_d_o,
          cpuerror => open,
          inta     => cpu_inta,
          iom      => cpu_iom,
          rdn      => cpu_rd_n,
          -- external (active low) (sync) reset
          resoutn  => open,
          -- early wr strobe negation for d/a hold
          wran     => open,
          wrn      => cpu_wr_n
       );
  end block BLK_CPU;
  
  BLK_INTERRUPTS : block
  begin
  
    -- NMI connected to VBLANK
    process (clk_20M, rst_20M)
      -- NMI must be high for more than 2 cycles
      -- - according to the 8088 datasheet anyway
      variable nmi_cnt  : integer range 0 to 20;
      variable vblank_r : std_logic_vector(3 downto 0);
      alias vblank_prev : std_logic is vblank_r(vblank_r'left);
      alias vblank_um   : std_logic is vblank_r(vblank_r'left-1);
    begin
      if rst_20M = '1' then
        vblank_r := (others => '0');
        cpu_nmi <= '0';
      elsif rising_edge(clk_20M) then
        if vblank_prev /= vblank_um and 
            vblank_um = PACE_VIDEO_V_SYNC_POLARITY then
          nmi_cnt := nmi_cnt'high;
          cpu_nmi <= '1';
        elsif nmi_cnt = 0 then
          cpu_nmi <= '0';
        else
          nmi_cnt := nmi_cnt - 1;
        end if;
        -- unmeta VBLANK
        vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
      end if;
    end process;
    
    -- cpu interrupts
    cpu_intr <= '0';  -- not connected

  end block BLK_INTERRUPTS;
  
	-- Battery-backed CMOS RAM
	nvram_inst : entity work.spram
		generic map
		(
			init_file		=> VARIANT_RAM_DIR & "nvram.hex",
			widthad_a		=> 12,
			width_a		  => 8
		)
		port map
		(
			clock				=> clk_20M,
			address			=> cpu_a(11 downto 0),
			wren				=> nvram_wr,
			data				=> cpu_d_o,
			q						=> nvram_d_o
		);

  -- sprites
  sprite_reg_o.clk <= clk_20M;
  sprite_reg_o.clk_ena <= clk_5M_en;
  sprite_reg_o.wr <= sprite_wr;
  sprite_reg_o.a <= cpu_a(sprite_reg_o.a'range);
  sprite_reg_o.d <= cpu_d_o;
    
  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  vram_inst : entity work.dpram
    generic map
    (
      init_file		=> VARIANT_RAM_DIR & "vram.hex",
      widthad_a		=> 10
    )
    port map
    (
      clock_b			=> clk_20M,
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

  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  cram_inst : entity work.dpram
    generic map
    (
      --numwords_a	=> 4096,
      widthad_a		=> 12
    )
    port map
    (
      clock_b			=> clk_20M,
      address_b		=> cpu_a(11 downto 0),
      wren_b			=> cram_wr,
      data_b			=> cpu_d_o,
      q_b					=> cram_d_o,

      clock_a			=> clk_video,
      address_a		=> tilemap_i(1).map_a(11 downto 0),
      wren_a			=> '0',
      data_a			=> (others => 'X'),
      q_a					=> tilemap_o(1).map_d(15 downto 8)
    );

	-- implementation of palette RAM
	process (clk_20M, rst_20M)
		variable entry_i : integer range 0 to 15;
	begin
		if rising_edge(clk_20M) then
      if clk_5M_en = '1' then
        if palette_cs = '1' and cpu_iom = '0' and cpu_wr_n = '0' then
          entry_i := to_integer(unsigned(cpu_a(4 downto 1)));
          if cpu_a(0) = '0' then
            -- even bytes G=(7..4) B=(3..0)
            palette_r(entry_i)(7 downto 0) <= cpu_d_o;
          else
            -- odd bytes R=(3..0)
            palette_r(entry_i)(15 downto 8) <= cpu_d_o;
          end if; -- cpu_a(0)
        end if; -- palette_cs,cpu_iom,cpu_wr_n
      end if; -- clk_5M_en
		end if;
		graphics_o.pal <= palette_r;
	end process;

  -- I/O
  process (clk_20M, rst_20M)
  begin
    if rst_20M = '1' then
      general_output_r <= (others => '0');
    elsif rising_edge(clk_20M) then
      if io_cs = '1' then
        if cpu_iom = '0' then
          if cpu_rd_n = '0' then
            case cpu_a(3 downto 0) is
              when X"0" =>
                -- DSW
                io_d_o <= X"00";
              when X"1" =>
                -- IN1 (coin, start etc)
                io_d_o <= inputs_i(0).d;
              when X"2" | X"3" =>
                -- IN2,3 (trackball H,V) (unused)
                io_d_o <= X"FF";
              when X"4" =>
                -- IN4 (joystick)
                io_d_o <= inputs_i(3).d;
              when others =>
                null;
            end case;
          elsif cpu_wr_n = '0' then
            case cpu_a(3 downto 0) is
              when X"3" =>
                general_output_r <= cpu_d_o;
              when others =>
                null;
            end case;
          end if; -- cpu_rd_n/cpu_wr_n
        end if; -- cpu_iom
      end if; -- io_cs
    end if;
  end process;

  -- sets priority between background tilemap and sprites
  graphics_o.bit8(0) <= (0 => background_priority, others => '0');
  
	GEN_FPGA_ROMS : if true generate
    type rom_data_t is array (natural range <>) of std_logic_vector(7 downto 0);
    signal rom_data : rom_data_t(4 downto 0);
  begin

    GEN_ROMS : for i in GOTTLIEB_NUM_ROMS-1 downto 0 generate
    begin
      rom_inst : entity work.sprom
        generic map
        (
          init_file		=> VARIANT_ROM_DIR & "rom" & integer'image(i) & ".hex",
          widthad_a		=> 13
        )
        port map
        (
          clock			=> clk_20M,
          address		=> cpu_a(12 downto 0),
          q					=> rom_data(i)
        );
    end generate GEN_ROMS;
        
    rom_d_o <=  rom_data(4) when STD_MATCH(cpu_a, "011-------------") else
                rom_data(3) when STD_MATCH(cpu_a, "100-------------") else
                rom_data(2) when STD_MATCH(cpu_a, "101-------------") else
                rom_data(1) when STD_MATCH(cpu_a, "110-------------") else
                rom_data(0) when STD_MATCH(cpu_a, "111-------------") else
                (others => '0');
                  
	end generate GEN_FPGA_ROMS;

  --
  -- graphics (not mapped to CPU)
  --
  
  -- TILES
  
	GEN_FPGA_BG_ROMS : if true generate
    type tile_data_t is array (natural range <>) of std_logic_vector(7 downto 0);
    signal tile_d_o : tile_data_t(0 to 1);
  begin
    GEN_BG_ROMS : for i in 0 to 1 generate
      begin
        bg_rom_inst : entity work.sprom
          generic map
          (
            init_file		=> VARIANT_ROM_DIR & "bg" & integer'image(i) & ".hex",
            widthad_a		=> 12
          )
          port map
          (
            clock			=> clk_video,
            address		=> tilemap_i(1).tile_a(11 downto 0),
            q					=> tile_d_o(i)
          );
      end generate GEN_BG_ROMS;
    tilemap_o(1).tile_d(tilemap_o(1).tile_d'left downto 8) <= (others => '0');
    tilemap_o(1).tile_d(7 downto 0) <= 
      tile_d_o(0) when tilemap_i(1).tile_a(12) = '0' else
      tile_d_o(1);
	end generate GEN_FPGA_BG_ROMS;

  -- SPRITES
  
  GEN_FPGA_FG_ROMS : if true generate
    type sprite_data_t is array (natural range <>) of std_logic_vector(15 downto 0);
    signal sprite_d_o : sprite_data_t(0 to 3);
  begin
    GEN_FG_ROMS : for i in 3 downto 0 generate
      begin
        -- cheating by accessing 16-bits at a time
        fg_rom_inst : entity work.dprom_2r
          generic map
          (
            init_file		=> VARIANT_ROM_DIR & "fg" & integer'image(i) & ".hex",
            widthad_a		=> 13,
            widthad_b		=> 13
          )
          port map
          (
            clock			              => clk_video,
            address_a(12 downto 1)  => sprite_i.a(12 downto 1),
            address_a(0)            => '0',
            q_a 			              => sprite_d_o(i)(15 downto 8),
            address_b(12 downto 1)  => sprite_i.a(12 downto 1),
            address_b(0)            => '1',
            q_b                     => sprite_d_o(i)(7 downto 0)
          );
      end generate GEN_FG_ROMS;
      
      -- construct the sprite row
      GEN_1 : for b1 in 15 downto 0 generate
        GEN_2 : for b2 in 3 downto 0 generate
          sprite_o.d(b1*4+b2) <= sprite_d_o(b2)(b1);
        end generate GEN_2;
      end generate GEN_1;
    
  end generate GEN_FPGA_FG_ROMS;
  
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;
