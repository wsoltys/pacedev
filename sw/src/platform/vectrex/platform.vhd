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

	alias clk_30M					    : std_logic is clkrst_i.clk(0);
  alias rst_30M             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
  signal clk_1M5_en			    : std_logic;
	signal cpu_clk_en         : std_logic;
	signal cpu_r_wn				    : std_logic;
	signal cpu_a				      : std_logic_vector(15 downto 0);
	signal cpu_d_i			      : std_logic_vector(7 downto 0);
	signal cpu_d_o			      : std_logic_vector(7 downto 0);
	signal cpu_irq				    : std_logic;

  -- cart signals        
	signal cart_cs				    : std_logic;
  signal cart_d_o           : std_logic_vector(7 downto 0);

  -- RAM signals        
	signal ram_cs				      : std_logic;
  signal ram_wr             : std_logic;
  alias ram_d_o      	      : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);
  
  -- ROM signals        
	signal rom_cs				      : std_logic;
  signal rom_d_o            : std_logic_vector(7 downto 0);
	
  -- register signals
  signal reg_cs             : std_logic;
  signal reg_d_o            : std_logic_vector(7 downto 0);

  -- 6522 signals
  signal via_cs             : std_logic;
  signal via_d_o            : std_logic_vector(7 downto 0);
  signal via_d_oe_n         : std_logic;
  
  -- other signals   
	alias platform_reset			: std_logic is inputs_i(3).d(0);
	alias osd_toggle          : std_logic is inputs_i(3).d(1);
	alias platform_pause      : std_logic is inputs_i(3).d(2);
	
begin

  -- SRAM signals (may or may not be used)
  sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(10 downto 0)	<= 	std_logic_vector(resize(unsigned(cpu_a), 11));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length)) 
								when (ram_wr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not ram_wr;
  sram_o.we <= ram_wr;

	-- cartridge $0000-$7FFF
	cart_cs <=		'1' when STD_MATCH(cpu_a,  "0---------------") else
								'0';
  -- RAM $C800-$CFFF
  ram_cs <=		  '1' when STD_MATCH(cpu_a, X"C"&"1-----------") else
                '0';
  -- registers $D000-$DFFF
  reg_cs <=		  '1' when STD_MATCH(cpu_a, X"D"&"------------") else
                '0';
  -- ROM $E000-$FFFF
	rom_cs  <= 	  '1' when STD_MATCH(cpu_a,  "111-------------") else 
                '0';

  -- memory block write enables
  ram_wr <= ram_cs and clk_1M5_en and not cpu_r_wn;

	-- memory read mux
	cpu_d_i <=  cart_d_o when cart_cs = '1' else
							ram_d_o when ram_cs = '1' else
							reg_d_o when reg_cs = '1' else
              rom_d_o when rom_cs = '1' else
							(others => 'Z');
		
  -- system timing
  process (clk_30M, rst_30M)
    variable count : integer range 0 to 19-1;
  begin
    if rst_30M = '1' then
      count := 0;
    elsif rising_edge(clk_30M) then
      clk_1M5_en <= '0'; -- default
      case count is
        when 0 =>
          clk_1M5_en <= '1';
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

	-- cpu09 core uses negative clock edge
	--cpu_clk_en <= not (clk_1M5_en and not platform_pause);
	cpu_clk_en <= clk_1M5_en and not platform_pause;

	-- add game reset later
	cpu_reset <= rst_30M or platform_reset;
	
	cpu_inst : entity work.cpu09
    generic map
    (
      CLK_POL   => '1'
    )
		port map
		(	
			clk				=> clk_30M,
      clk_en    => cpu_clk_en,
			rst				=> cpu_reset,
			rw				=> cpu_r_wn,
			vma				=> open,
      --ba        => open,
      --bs        => open,
			addr		  => cpu_a,
		  data_in		=> cpu_d_i,
		  data_out	=> cpu_d_o,
			halt			=> '0',
			hold			=> '0',
			irq				=> cpu_irq,
			firq			=> '0',
			nmi				=> '0'
		);

  BLK_VIA : block
    signal via_pa_i     : std_logic_vector(7 downto 0);
    signal via_pa_o     : std_logic_vector(7 downto 0);
    signal via_pa_oe_n  : std_logic_vector(7 downto 0);
    signal via_pb_i     : std_logic_vector(7 downto 0);
    signal via_pb_o     : std_logic_vector(7 downto 0);
    signal via_pb_oe_n  : std_logic_vector(7 downto 0);
    signal via_i_p2     : std_logic;
    signal via_ena_4    : std_logic;
    
    signal sw           : std_logic_vector(7 downto 0);
    signal zero_n       : std_logic;
    signal blank_n      : std_logic;
  begin
    via_inst : entity work.M6522
      port map
      (
        I_RS              => cpu_a(3 downto 0),
        I_DATA            => cpu_d_o,
        O_DATA            => via_d_o,
        O_DATA_OE_L       => via_d_oe_n,

        I_RW_L            => cpu_r_wn,
        I_CS1             => cpu_a(12),
        I_CS2_L           => not reg_cs,

        O_IRQ_L           => cpu_irq,
        -- port a
        I_CA1             => sw(7),
        I_CA2             => '0',
        O_CA2             => zero_n,
        O_CA2_OE_L        => open,

        I_PA              => via_pa_i,
        O_PA              => via_pa_o,
        O_PA_OE_L         => via_pa_oe_n,

        -- port b
        I_CB1             => '0',
        O_CB1             => open,
        O_CB1_OE_L        => open,

        I_CB2             => '0',
        O_CB2             => blank_n,
        O_CB2_OE_L        => open,

        I_PB              => via_pb_i,
        O_PB              => via_pb_o,
        O_PB_OE_L         => via_pb_oe_n,

        I_P2_H            => via_i_p2,    -- high for phase 2 clock  ____----__
        RESET_L           => not rst_30M,
        ENA_4             => via_ena_4,   -- clk enable
        CLK               => clk_30M
      );
  end block BLK_VIA;
  
  -- registers
  BLK_REGS : block
  begin
    process (clk_30M, rst_30M)
    begin
      if rst_30M = '1' then
      elsif rising_edge(clk_30M) then
        if clk_1M5_en = '1' then
          if reg_cs = '1' then
            if cpu_r_wn = '1' then
              -- reads
              case cpu_a(3 downto 0) is
                when X"0" =>
                when others =>
                  null;
              end case;
            else
              -- writes
              case cpu_a(3 downto 0) is
                when X"0" =>
                when others =>
                  null;
              end case;
            end if; -- cpu_r_wn
          end if; -- reg_cs
        end if; -- clk_1M5_en
      end if; -- rising_edge(clk_30M)
    end process;
    
  end block BLK_REGS;
  
--	-- irq vblank interrupt
--	process (clk_30M, rst_30M)
--    variable vblank_r : std_logic_vector(3 downto 0);
--    alias vblank_prev : std_logic is vblank_r(vblank_r'left);
--    alias vblank_um   : std_logic is vblank_r(vblank_r'left-1);
--	begin
--		if rst_30M = '1' then
--			vblank_r := (others => '0');
--      cpu_irq <= '0';
--		elsif rising_edge(clk_30M) then
--			if vblank_um = '1' and vblank_prev = '0' then
--				cpu_irq <= '1';
--      elsif vblank_um = '0' then
--        cpu_irq <= '0';
--			end if;
--      -- numeta the vblank
--      vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
--		end if;
--	end process;

	GEN_FPGA_ROMS : if true generate
  begin
  
    system_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> VECTREX_ROM_DIR & "system.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_30M,
        address		=> cpu_a(12 downto 0),
        q					=> rom_d_o
      );
    
	end generate GEN_FPGA_ROMS;

  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;
