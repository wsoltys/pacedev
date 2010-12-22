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
    sram_i	        : in from_SRAM_t;
    sram_o	        : out to_SRAM_t;
    sdram_i	        : in from_SDRAM_t;
    sdram_o	        : out to_SDRAM_t;

    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_t;
    bitmap_o        : out to_BITMAP_CTL_t;
    
    tilemap_i       : in from_TILEMAP_CTL_t;
    tilemap_o       : out to_TILEMAP_CTL_t;

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

	-- need this for projects that don't have it!
	component FDC_1793 is 
		port
	   (
	     clk            : in    std_logic;
	     uPclk          : in    std_logic;
	     reset          : in    std_logic;

	     fdcaddr        : in    std_logic_vector(2 downto 0);
	     fdcdatai       : in    std_logic_vector(7 downto 0);
	     fdcdatao       : out   std_logic_vector(7 downto 0);
	     fdc_rd         : in    std_logic;
	     fdc_wr         : in    std_logic;
	     fdc_drq_int    : out   std_logic;
	     fdc_dto_int		: out   std_logic;

	     spi_clk        : out   std_logic;
	     spi_ena        : out   std_logic;
	     spi_mode       : out   std_logic;
	     spi_sel        : out   std_logic;
	     spi_din        : in    std_logic;
	     spi_dout       : out   std_logic;

	     ser_rx         : in    std_logic;
	     ser_tx         : out   std_logic;

	     debug          : out   std_logic_vector(7 downto 0)
	   );
	end component;

	alias clk_40M					: std_logic is clkrst_i.clk(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	signal clk_2M_ena			: std_logic;
	
  -- uP signals  
  signal cpu_a          : std_logic_vector(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_mem_rd     : std_logic;
  signal cpu_mem_wr     : std_logic;
  signal cpu_io_rd      : std_logic;
  signal cpu_io_wr      : std_logic;
  signal cpu_irq        : std_logic;
  signal cpu_irq_vec    : std_logic_vector(7 downto 0);
  signal cpu_irq_ack    : std_logic;
  signal cpu_nmi        : std_logic;
	alias cpu_io_a				: std_logic_vector(7 downto 0) is cpu_a(7 downto 0);
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_d_o        : std_logic_vector(7 downto 0);
                        
  -- keyboard signals
	signal kbd_cs					: std_logic;
	signal kbd_data				: std_logic_vector(7 downto 0);
		                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);

  -- pcg80 signals
  signal pcg80_cs       : std_logic := '0';
  signal pcg80_d_o      : std_logic_vector(7 downto 0);
  -- le18 signals
  signal le18_cs        : std_logic := '0';
  signal le18_d_o       : std_logic_vector(7 downto 0) := (others => '0');
  
  -- RAM signals        
  signal ram_wr         : std_logic;
  alias ram_datao      	: std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- interrupt signals
	signal int_cs					: std_logic;
  signal int_status     : std_logic_vector(7 downto 0);

  -- fdc signals
	signal fdc_cs					: std_logic;
  signal fdc_rd         : std_logic;
  signal fdc_wr         : std_logic;
  signal fdc_datao      : std_logic_vector(7 downto 0);
  signal fdc_drq_int    : std_logic;
	signal fdc_addr				: std_logic_vector(2 downto 0);

  signal hdd_d          : std_logic_vector(7 downto 0);
  signal hdd_cs         : std_logic := '0';
  
  -- other signals      
	alias game_reset			: std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	signal cpu_reset			: std_logic;  
	signal alpha_joy_cs		: std_logic;
	signal snd_cs					: std_logic;
  signal mem_d          : std_logic_vector(7 downto 0);
  signal io_d           : std_logic_vector(7 downto 0);
  
begin

  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CPU_FREQ_MHz=" &  real'image(CPU_FREQ_MHz) &
            " CPU_CLK_ENA_DIV=" & integer'image(TRS80_M1_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

	cpu_reset <= clkrst_i.arst or game_reset;

  -- not used for now
  cpu_irq_vec <= (others => '0');

  -- read mux
  cpu_d_i <= mem_d when (cpu_mem_rd = '1') else io_d;

  -- SRAM signals (may or may not be used)
  sram_o.a <= std_logic_vector(resize(unsigned(cpu_a), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not ram_wr;
  sram_o.we <= ram_wr;

	-- memory chip selects
	-- ROM $0000-$2FFF, Peter Bartlett's extensions: $3000-$35FF
	rom_cs <= '1' when cpu_a(15 downto 14) = "00" and cpu_a(13 downto 12) /= "11" else 
            '1' when cpu_a(15 downto 11) = "00110" and cpu_a(10 downto 9) /= "11" else
            '0';

	-- RDINTSTATUS $37E0-$37E3 (active high)
	int_cs <= '1' when cpu_a(15 downto 2) = (X"37E" & "00") else '0';
	-- FDC $37EC-$37EF
	fdc_cs <= '1' when cpu_a(15 downto 2) = (X"37E" & "11") else '0';
	-- KEYBOARD $3800-$38FF
	kbd_cs <= '1' when cpu_a(15 downto 10) = (X"3" & "10") else '0';
	-- VRAM $3C00-$3FFF
	vram_cs <= '1' when cpu_a(15 downto 10) = (X"3" & "11") else '0';

	-- memory read strobes	
	fdc_rd <= fdc_cs and cpu_mem_rd;

	-- quick fudge for now
	fdc_addr <= '0' & cpu_a(1 downto 0) when fdc_cs = '1' else
							"100";
	
	-- memory write enables
  fdc_wr <= cpu_mem_wr when (fdc_cs = '1' or cpu_a(15 downto 2) = (X"37E" & "00")) else '0';
	vram_wr <= vram_cs and cpu_mem_wr;
	-- always write thru to RAM
	ram_wr <= cpu_mem_wr;

	-- I/O chip selects
	-- Alpha Joystick $00 (active low)
	alpha_joy_cs <= '1' when cpu_io_a = X"00" else '0';
	-- LE18 $EC-$EF
  le18_cs <= '1' when STD_MATCH(cpu_io_a, X"E" & "11--") else '0';
	-- PCG-80 $FE
	pcg80_cs <= '1' when cpu_io_a = X"FE" else '0';
  -- SOUND $FC-FF (Model I is $FF only)
	snd_cs <= '1' when cpu_io_a = X"FF" else '0';
	
	-- io write enables
	-- SOUND OUTPUT $FC-FF (Model I is $FF only)
	snd_o.a <= cpu_a(snd_o.a'range);
	snd_o.d <= cpu_d_o;
	snd_o.rd <= '0';
  snd_o.wr <= snd_cs and cpu_io_wr;
		
	-- memory read mux
	mem_d <= 	rom_d_o when rom_cs = '1' else
            int_status when int_cs = '1' else
						fdc_datao when fdc_cs = '1' else
						kbd_data when kbd_cs = '1' else
						vram_datao when vram_cs = '1' else
						ram_datao;
	
	-- io read mux
	io_d <= X"FF" when alpha_joy_cs = '1' else
          le18_d_o when le18_cs = '1' else
          hdd_d when hdd_cs = '1' else
					X"FF";
		
	KBD_MUX : process (cpu_a, inputs_i)
  	variable kbd_data_v : std_logic_vector(7 downto 0);
	begin
  	kbd_data_v := X"00";
		for i in 0 to 7 loop
	 		if cpu_a(i) = '1' then
			  kbd_data_v := kbd_data_v or inputs_i(i).d;
		  end if;
		end loop;
  	-- assign the output
		kbd_data <= kbd_data_v;
  end process KBD_MUX;

  graphics_o.bit8_1(3) <= '0';  -- alt character set?
  
  -- software-controlled
  GEN_DBL_WIDTH_TRS80_M1 : if not TRS80_M1_IS_SYSTEM80 generate
    process (clk_40M, cpu_reset)
    begin
      if cpu_reset = '1' then
        graphics_o.bit8_1(2) <= '0';
      elsif rising_edge(clk_40M) then
        if snd_cs = '1' and cpu_io_wr = '1' then
          graphics_o.bit8_1(2) <= cpu_d_o(3);
        end if;
      end if;
    end process;
  end generate GEN_DBL_WIDTH_TRS80_M1;
  
  -- a physical switch on the back of the System 80
  GEN_DBL_WIDTH_SYSTEM80 : if TRS80_M1_IS_SYSTEM80 generate
    graphics_o.bit8_1(2) <= switches_i(9);
  end generate GEN_DBL_WIDTH_SYSTEM80;
  
  -- unused outputs
	sprite_reg_o <= NULL_TO_SPRITE_REG;
	sprite_o <= NULL_TO_SPRITE_CTL;
	ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
  --gp_o <= NULL_TO_GP;

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> TRS80_M1_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_40M,
			reset			=> clkrst_i.rst(0),
			clk_en		=> clk_2M_ena
		);

	up_inst : entity work.Z80                                                
    port map
    (
      clk			=> clk_40M,                                   
      clk_en	=> clk_2M_ena,
      reset  	=> cpu_reset,                                     

      addr   	=> cpu_a,
      datai  	=> cpu_d_i,
      datao  	=> cpu_d_o,

      mem_rd 	=> cpu_mem_rd,
      mem_wr 	=> cpu_mem_wr,
      io_rd  	=> cpu_io_rd,
      io_wr  	=> cpu_io_wr,

      intreq 	=> cpu_irq,
      intvec 	=> cpu_irq_vec,
      intack 	=> cpu_irq_ack,
      nmi    	=> cpu_nmi
    );

  GEN_ROM_ONCHIP : if not TRS80_M1_ROM_IN_FLASH generate
    rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/trs80/m1/roms/" & TRS80_M1_ROM,
        widthad_a		=> 14
      )
      port map
      (
        clock			=> clk_40M,
        address		=> cpu_a(13 downto 0),
        q					=> rom_d_o
      );
  end generate GEN_ROM_ONCHIP;
  
  GEN_ROM_IN_FLASH : if TRS80_M1_ROM_IN_FLASH generate
    flash_o.a <= std_logic_vector(resize(unsigned(cpu_a(13 downto 0)), flash_o.a'length));
    flash_o.we <= '0';
    flash_o.cs <= rom_cs;
    flash_o.oe <= '1';
    rom_d_o <= flash_i.d(rom_d_o'range);
  end generate GEN_ROM_IN_FLASH;
  
	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/trs80/m1/roms/" & TRS80_M1_CHARSET_ROM,
			widthad_a		=> 11
		)
		port map
		(
			clock			=> clk_video,
			address		=> tilemap_i.tile_a(10 downto 0),
			q					=> tilemap_o.tile_d
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
			q_b					=> vram_datao,
	
		  clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
    tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

  GEN_PCG80 : if TRS80_M1_HAS_PCG80 generate

    signal pcg80_a        : std_logic_vector(11 downto 0) := (others => '0');
    alias pcg80_bank      : std_logic_vector(11 downto 10) is pcg80_a(11 downto 10);
    signal pcg80_r        : std_logic_vector(7 downto 0) := (others => '0');
    signal pcg80_wr       : std_logic := '0';
    
  begin
  
    -- PCG-80 register
    process (clk_40M, cpu_reset)
    begin
      if cpu_reset = '1' then
        pcg80_r <= (others => '0');
      elsif rising_edge(clk_40M) then
        -- latch on rising edge IO read cycle
        if pcg80_cs = '1' and cpu_io_wr = '1' then
          -- $20,$A0,$28,$A8 all have bit 5 set
          if cpu_d_o(5) = '1' then
            pcg80_r <= cpu_d_o;
            -- set programming bank
            if cpu_d_o(7 downto 4) = X"6" then
              pcg80_bank <= cpu_d_o(1 downto 0);
            end if;
          end if;
        end if;
      end if;
      -- the rest of the address
      pcg80_a(9 downto 0) <= cpu_a(9 downto 0);
    end process;
    pcg80_wr <= vram_wr when pcg80_r(7 downto 4) = X"6" else '0';

    graphics_o.bit8_1(5) <= pcg80_r(7); -- enable $80-$FF
    graphics_o.bit8_1(4) <= pcg80_r(3); -- enable $00-$7F

    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    pcg80_inst : entity work.dpram
      generic map
      (
        widthad_a		=> 12
      )
      port map
      (
        clock_b			=> clk_40M,
        address_b		=> pcg80_a,
        wren_b			=> pcg80_wr,
        data_b			=> cpu_d_o,
        q_b					=> pcg80_d_o,
    
        -- uses same address as built-in char ROM
        -- - data fed back via 'attribute' port
        clock_a			=> clk_video,
        address_a		=> tilemap_i.tile_a(11 downto 0),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> tilemap_o.attr_d(7 downto 0)
      );
    tilemap_o.attr_d(tilemap_o.attr_d'left downto 8) <= (others => '0');
  end generate GEN_PCG80;

  GEN_NO_PCG80 : if not TRS80_M1_HAS_PCG80 generate
    pcg80_d_o <= (others => '0');
    tilemap_o.attr_d <= (others => '0');
  end generate GEN_NO_PCG80;

  GEN_LE18 : if TRS80_M1_HAS_LE18 generate
    signal le18_ram_a   : std_logic_vector(13 downto 0) := (others => '0');
    signal le18_ram_wr  : std_logic := '0';
    signal le18_ram_i   : std_logic_vector(5 downto 0) := (others => '0');
    signal le18_ram_o   : std_logic_vector(5 downto 0) := (others => '0');
    --
    signal le18_x       : std_logic_vector(5 downto 0) := (others => '0');
    signal le18_y       : std_logic_vector(7 downto 0) := (others => '0');
    signal le18_en      : std_logic := '0';
  begin
  
    process (clk_40M, cpu_reset)
    begin
      if cpu_reset = '1' then
        le18_ram_wr <= '0';
        le18_x <= (others => '0');
        le18_y <= (others => '0');
        le18_en <= '0';
      elsif rising_edge(clk_40M) then
        le18_ram_wr <= '0'; -- default
        -- write to graphics registers
        if le18_cs = '1' then
          if cpu_io_wr = '1' then
            case cpu_io_a(1 downto 0) is
              when "00" =>
                le18_ram_i <= cpu_d_o(le18_ram_i'range);
                le18_ram_wr <= '1';
              when "01" =>
                le18_x <= cpu_d_o(le18_x'range);
              when "10" =>
                le18_y <= cpu_d_o;
              when others =>
                le18_en <= cpu_d_o(0);
            end case;
          elsif cpu_io_rd = '1' then
            case cpu_io_a(1 downto 0) is
              when "00" =>
                -- bit7 should be '1' during blanking
                le18_d_o <= '1' & le18_en & le18_ram_o(5 downto 0);
              when "01" =>
                le18_d_o <= "00" & le18_x;
              when "10" =>
                le18_d_o <= le18_y;
              when others =>
                le18_d_o <= "0000000" & le18_en;
            end case;
          end if; -- cpu_io_wr/rd=1
        end if; -- le18_cs=1
      end if;
    end process;

    -- construct RAM address
    le18_ram_a <= le18_y & le18_x;
    
    -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
    le18_ram_inst : entity work.dpram
      generic map
      (
        widthad_a		=> TRS80_M1_LE18_WIDTHAD,
        width_a     => 6
      )
      port map
      (
        clock_b			=> clk_40M,
        address_b		=> le18_ram_a(TRS80_M1_LE18_WIDTHAD-1 downto 0),
        wren_b			=> le18_ram_wr,
        data_b			=> le18_ram_i,
        q_b					=> le18_ram_o,
    
        clock_a			=> clk_video,
        address_a		=> bitmap_i.a(TRS80_M1_LE18_WIDTHAD-1 downto 0),
        wren_a			=> '0',
        data_a			=> (others => 'X'),
        q_a					=> bitmap_o.d(5 downto 0)
      );
    bitmap_o.d(7 downto 6) <= (others => '0');

    graphics_o.bit8_1(6) <= le18_en;

  end generate GEN_LE18;
    
  GEN_NO_LE18 : if not TRS80_M1_HAS_LE18 generate
    le18_d_o <= X"FF";
    bitmap_o.d <= (others => '0');
  end generate GEN_NO_LE18;
    
  BLK_INTERRUPTS : block
    signal tick_1ms   : std_logic := '0';
    signal timer_irq  : std_logic := '0';
  begin

    -- interrupt register
    process (clk_40M, cpu_reset)
      variable intreg_r : std_logic := '0';
    begin
      if cpu_reset = '1' then
        intreg_r := '0';
        int_status <= (others => '0');
      elsif rising_edge(clk_40M) then
        -- clear interrupts on falling edge of read
        if intreg_r = '1' and (int_cs = '0' or cpu_mem_rd = '0') then
          int_status(6) <= '0';
          int_status(7) <= '0';
        end if;
        -- timer interrupt
        if timer_irq = '1' then
          int_status(7) <= '1';
        end if;
        -- FDC interrupt
        if fdc_drq_int = '1' then
          int_status(6) <= '1';
        end if;
        intreg_r := int_cs and cpu_mem_rd;
      end if;
    end process;

    cpu_irq <= '1' when int_status /= X"00" else '0';
    
    -- 1ms tick for slower counters
    process (clk_40M, cpu_reset)
      subtype count_1ms_t is integer range 0 to CLK0_FREQ_MHz*1000-1;
      variable count_1ms : count_1ms_t := 0;
    begin
      if cpu_reset = '1' then
        count_1ms := 0;
        tick_1ms <= '0';
      elsif rising_edge(clk_40M) then
        tick_1ms <= '0';  -- default
        if count_1ms = count_1ms_t'high then
          count_1ms := 0;
          tick_1ms <= '1';
        else
          count_1ms := count_1ms + 1;
        end if;
      end if;
    end process;
    
    -- TIMER interrupt (40Hz/25ms)
    process (clk_40M, cpu_reset)
      subtype count_25ms_t is integer range 0 to 25-1;
      variable count_25ms : count_25ms_t := 0;
    begin
      if cpu_reset = '1' then
        timer_irq <= '0';
        count_25ms := 0;
      elsif rising_edge(clk_40M) then
        timer_irq <= '0';   -- default
        if tick_1ms = '1' then
          if count_25ms = count_25ms_t'high then
            timer_irq <= '1';
            count_25ms := 0;
          else
            count_25ms := count_25ms + 1;
          end if;
        end if; -- tick_1ms
      end if;
    end process;
    
  end block BLK_INTERRUPTS;

  GEN_FDC : if INCLUDE_FDC_SUPPORT generate
  
    fdc_inst : FDC_1793                                    
      port map
      (
        clk         => clk_40M,
        upclk       => clk_2M_ena,
        reset       => cpu_reset,
                    
        fdcaddr     => fdc_addr,
        fdcdatai    => cpu_d_o,
        fdcdatao    => fdc_datao,
        fdc_rd      => fdc_rd,                      
        fdc_wr      => fdc_wr,                      
        fdc_drq_int => fdc_drq_int,   
        fdc_dto_int => open,         

        spi_clk     => spi_o.clk,
        spi_din     => spi_i.din,                                 
        spi_dout    => spi_o.dout,           
        spi_ena     => spi_o.ena,            
        spi_mode    => spi_o.mode,           
        spi_sel     => spi_o.sel,            
                    
        ser_rx      => ser_i.rxd,                                  
        ser_tx      => ser_o.txd,

        debug       => leds_o(7 downto 0)
      );

  end generate GEN_FDC;

  GEN_NO_FDC : if not INCLUDE_FDC_SUPPORT generate
  
    fdc_datao <= X"FF";
    fdc_drq_int <= '0';
    --leds_o <= (others => '0');
        
  end generate GEN_NO_FDC;

  GEN_HDD : if TRS80_M1_HAS_HDD generate

    signal wb_cyc_stb   : std_logic := '0';
    signal wb_sel       : std_logic_vector(3 downto 0) := (others => '0');
    signal wb_adr       : std_logic_vector(6 downto 2) := (others => '0');
    signal wb_dat_i     : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_dat_o     : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_we        : std_logic := '0';
    signal wb_ack       : std_logic := '0';
    
    type state_t is ( S_IDLE, S_I1, S_R1, S_W1 );
    signal state : state_t := S_IDLE;

    signal hdci_cntl    : std_logic_vector(7 downto 0) := (others => '0');
    alias hdci_enable   : std_logic is hdci_cntl(3);
    signal hdd_irq      : std_logic;

    signal a_cf_us      : ieee.std_logic_arith.unsigned(2 downto 0) := (others => '0');
    signal nior0_cf_s   : std_logic := '0';
    signal niow0_cf_s   : std_logic := '0';
    signal ide_d_r      : std_logic_vector(31 downto 0) := (others => '0');
    
  begin

    platform_o.clk_50M <= clkrst_i.clk_ref;
    platform_o.clk_25M <= clkrst_i.clk(1);    -- maybe
    
    -- to the HDD core
    platform_o.clk <= clk_40M;
    platform_o.rst <= cpu_reset;
    platform_o.arst_n <= clkrst_i.arst_n;

    -- IDE registers
    --
    --  $C0-C2  - original RS registers
    --  $C3     - upper-byte data latch
    --  $C8-CF  - write-thru to IDE device
    --
    
    hdd_cs <= (cpu_io_rd or cpu_io_wr) 
                when STD_MATCH(cpu_a(7 downto 0), X"C"&"----") 
                else '0';
    
    process (clk_40M, cpu_reset)
      variable cpu_io_r : std_logic := '0';
    begin
      if cpu_reset = '1' then
        hdci_cntl <= (others => '0');
        wb_cyc_stb <= '0';
        wb_we <= '0';
        state <= S_I1;
      elsif rising_edge(clk_40M) then
        case state is
          when S_I1 =>
            -- initialise the OCIDE core
            wb_cyc_stb <= '1';
            wb_adr <= "00000";
            wb_dat_i <= X"00000082";   -- enable IDE, IORDY timing
            wb_we <= '1';
            state <= S_W1;
          when S_IDLE =>
            wb_cyc_stb <= '0'; -- default
            -- start a new cycle on rising_edge IORD
            if cpu_io_r = '0' and (cpu_io_rd or cpu_io_wr) = '1' then
              if hdd_cs = '1' then
                case cpu_a(3 downto 0) is
                  when X"0" =>    -- hdci_wp
                  when X"1" =>    -- hdci_cntl
                    hdci_cntl <= cpu_d_o;
                  when X"2" =>    -- hdci_present
                  when X"3" =>    -- high-byte latch
                    if cpu_io_rd = '1' then
                      -- read latch from previous access
                      hdd_d <= ide_d_r(15 downto 8);
                    elsif cpu_io_wr = '1' then
                      -- latch write data for subsequent access
                      ide_d_r(15 downto 8) <= cpu_d_o;
                    end if;
                  when others =>
                    -- IDE device registers @$08-$0F
                    if cpu_a(3) = '1' then
                      -- start a new access to the OCIDEC
                      wb_cyc_stb <= hdd_cs;
                      -- $08-$0F => $10-$17 (ATA registers)
                      wb_adr <= "10" & cpu_a(2 downto 0);
                      wb_dat_i(31 downto 8) <= X"0000" & ide_d_r(15 downto 8);
                      -- Peter Bartlett's drivers require this
                      -- because IDE sectors start at 1, not 0
                      if cpu_a(3 downto 0) = X"B" then
                        wb_dat_i(7 downto 0) <= std_logic_vector(unsigned(cpu_d_o) + 1);
                      else
                        wb_dat_i(7 downto 0) <= cpu_d_o;
                      end if;
                      wb_we <= cpu_io_wr;
                      if cpu_io_rd = '1' then
                        state <= S_R1;
                      else
                        state <= S_W1;
                      end if;
                    end if; -- $08-$0F (device register)
                end case;
              end if; -- ide_cs = '1'
            end if;
          when S_R1 =>
            if wb_ack = '1' then
              -- latch the whole data bus from the core
              ide_d_r <= wb_dat_o;
              -- Peter Bartlett's drivers require this
              -- because IDE sectors start at 1, not 0
              if cpu_a(3 downto 0) = X"B" then
                hdd_d <= std_logic_vector(unsigned(wb_dat_o(hdd_d'range)) - 1);
              else
                hdd_d <= wb_dat_o(hdd_d'range);
              end if;
              wb_cyc_stb <= '0';
              state <= S_IDLE;
            end if;
          when S_W1 =>
            if wb_ack = '1' then
              wb_cyc_stb <= '0';
              state <= S_IDLE;
            end if;
          when others =>
            wb_cyc_stb <= '0';
            state <= S_IDLE;
        end case;
        cpu_io_r := cpu_io_rd or cpu_io_wr;
      end if;
    end process;
      
    -- 16-bit access to PIO registers, otherwise 32
    wb_sel <= "0011" when wb_adr(6) = '1' else "1111";
    
    -- PIO mode timings
    --          0,   1,   2,   3,   4,   5,   6
    -- t1   -  70,  50,  30,  30,  25,  15,  10
    -- t2   - 165, 125, 100,  80,  70,  65,  55
    -- t4   -  30,  20,  15,  10,  10,   5,   5
    -- teoc - 365, 208, 110,  70,  25,  25,  20
    --
    -- n = max(0, round_up((t * clk) - 2))
    --
    atahost_inst : entity work.atahost_top
      generic map
      (
        --TWIDTH          => 5,
        -- PIO mode0 100MHz = 6, 28, 2, 23
        -- PIO mode0 57M272 = 4, 16, 1, 13
        -- PIO mode0 40MHz => 1, 5, 0, 13
        -- PIO mode3 40MHz => 0, 2, 0, 1
        PIO_mode0_T1    => 1,
        PIO_mode0_T2    => 5,
        PIO_mode0_T4    => 0,
        PIO_mode0_Teoc  => 13
      )
      port map
      (
        -- WISHBONE SYSCON signals
        wb_clk_i      => clk_40M,
        arst_i        => clkrst_i.arst_n,
        wb_rst_i      => cpu_reset,

        -- WISHBONE SLAVE signals
        wb_cyc_i      => wb_cyc_stb,
        wb_stb_i      => wb_cyc_stb,
        wb_ack_o      => wb_ack,
        wb_err_o      => open,
        wb_adr_i      => ieee.std_logic_arith.unsigned(wb_adr),
        wb_dat_i      => wb_dat_i,
        wb_dat_o      => wb_dat_o,
        wb_sel_i      => wb_sel,
        wb_we_i       => wb_we,
        wb_inta_o     => open,

        -- ATA signals
        resetn_pad_o  => platform_o.nreset_cf,
        dd_pad_i      => platform_i.dd_i,
        dd_pad_o      => platform_o.dd_o,
        dd_padoe_o    => platform_o.dd_oe,
        da_pad_o      => a_cf_us,
        cs0n_pad_o    => platform_o.nce_cf(1),
        cs1n_pad_o    => platform_o.nce_cf(2),

        diorn_pad_o	  => nior0_cf_s,
        diown_pad_o	  => niow0_cf_s,
        iordy_pad_i	  => platform_i.iordy0_cf,
        intrq_pad_i	  => platform_i.rdy_irq_cf
      );

    platform_o.a_cf <= std_logic_vector(a_cf_us);
    platform_o.nior0_cf <= nior0_cf_s;
    platform_o.niow0_cf <= niow0_cf_s;
    
    -- DMA mode not supported
    platform_o.ndmack_cf <= 'Z';

    -- detect
    --<= platform_i.cd_cf;
    
    -- power
    platform_o.non_cf <= '0';

    BLK_ACTIVITY : block
      signal ide_act : std_logic := '0';
    begin
      -- activity LED(s)
      process (clk_40M, cpu_reset)
        -- 40MHz for 1/10th sec
        subtype count_t is integer range 0 to 40000000/10-1;
        variable count : count_t := 0;
      begin
        if cpu_reset = '1' then
          ide_act <= '0';
          count := 0;
        elsif rising_edge(clk_40M) then
          if nior0_cf_s = '0' or niow0_cf_s = '0' then
            ide_act <= '1';
            count := count_t'high;
          elsif count = 0 then
            ide_act <= '0';
          else
            count := count - 1;
          end if;
        end if;
      end process;
      leds_o(4) <= ide_act;
    end block BLK_ACTIVITY;
    
  end generate GEN_HDD;

  leds_o(leds_o'left downto 5) <= (others => '0');
  -- reserved for floppy drives 0-4
  leds_o(3 downto 0) <= (others => '0');

end architecture SYN;
