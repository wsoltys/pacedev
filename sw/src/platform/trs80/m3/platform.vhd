library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

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
    
    bitmap_i        : in from_BITMAP_CTL_t;
    bitmap_o        : out to_BITMAP_CTL_t;
    
    tilemap_i       : in from_TILEMAP_CTL_t;
    tilemap_o       : out to_TILEMAP_CTL_t;

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
end entity platform;

architecture SYN of platform is

  component osd_controller is
    generic
    (
      WIDTH_GPIO  : natural := 8
    );
    port
    (
      clk         : in std_logic;
      clk_en      : in std_logic;
      reset       : in std_logic;

      osd_key     : in std_logic;

      to_osd      : out to_OSD_t;
      from_osd    : in from_OSD_t;

      gpio_i      : in std_logic_vector(WIDTH_GPIO-1 downto 0);
      gpio_o      : out std_logic_vector(WIDTH_GPIO-1 downto 0);
      gpio_oe     : out std_logic_vector(WIDTH_GPIO-1 downto 0)
    );
  end component osd_controller;

	alias clk_20M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	
  -- uP signals  
  signal clk_2M_ena			: std_logic;
  signal uP_addr        : std_logic_vector(15 downto 0);
  signal uP_datai       : std_logic_vector(7 downto 0);
  signal uP_datao       : std_logic_vector(7 downto 0);
  signal uPmemrd        : std_logic;
  signal uPmemwr        : std_logic;
  signal uPiord         : std_logic;
  signal uPiowr         : std_logic;
  signal uPintreq       : std_logic;
  signal uPintvec       : std_logic_vector(7 downto 0);
  signal uPintack       : std_logic;
  signal uPnmireq       : std_logic;
	alias io_addr					: std_logic_vector(7 downto 0) is uP_addr(7 downto 0);
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_datao      : std_logic_vector(7 downto 0);
                        
  -- keyboard signals
	signal kbd_cs					: std_logic;
	signal kbd_data				: std_logic_vector(7 downto 0);
	                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);

  -- hires signals
  signal ulabs_en       : std_logic := '0';
	signal ulabs_wr       : std_logic := '0';
	signal ulabs_dat_o    : std_logic_vector(7 downto 0) := (others => '0');
	
  -- RAM signals        
  signal ram_cs         : std_logic := '0';
  signal ram_wr         : std_logic := '0';
  signal ram_datao      : std_logic_vector(7 downto 0);

  -- interrupt signals
  signal z80_wait_n     : std_logic := '1';
	signal int_cs					: std_logic;
  signal intena_wr      : std_logic;
  signal int_status     : std_logic_vector(7 downto 0);
  signal rtc_intrst     : std_logic;  -- clear RTC interrupt
	signal nmi_cs					: std_logic;
  signal nmiena_wr      : std_logic;
  signal nmi_status     : std_logic_vector(7 downto 0);
  signal nmirst         : std_logic;  -- clear NMI

  -- OSD GPIO signals
  signal gpio_to_osd    : std_logic_vector(7 downto 0);
  signal gpio_from_osd  : std_logic_vector(7 downto 0);

  -- fdc signals
	signal fdc_cs_n			  : std_logic;
	signal fdc_re_n       : std_logic;
	signal fdc_we_n       : std_logic;
  signal fdc_dat_o      : std_logic_vector(7 downto 0);
  signal fdc_drq        : std_logic;
  signal fdc_irq        : std_logic;

  signal drvsel_cs      : std_logic := '0';
  signal drvsel_r       : std_logic_vector(7 downto 0) := (others => '0');
  alias mfm_fm_n        : std_logic is drvsel_r(7);
  alias wsgen           : std_logic is drvsel_r(6);
  alias precomp         : std_logic is drvsel_r(5);
  alias sdsel           : std_logic is drvsel_r(4);
  alias ds              : std_logic_vector(4 downto 1) is drvsel_r(3 downto 0);
  
	signal port_ec        : std_logic_vector(7 downto 0);

  -- other signals      
	alias platform_reset	: std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	signal cpu_reset			: std_logic;  
	signal alpha_joy_cs		: std_logic;
	signal rtc_cs					: std_logic;
	signal snd_cs					: std_logic;
  signal uPmem_datai    : std_logic_vector(7 downto 0);
  signal uPio_datai     : std_logic_vector(7 downto 0);
	
begin

	cpu_reset <= reset_i or platform_reset;
	
  -- not used for now
  uPintvec <= (others => '0');

  -- read mux
  uP_datai <= uPmem_datai when (uPmemrd = '1') else uPio_datai;

  BLK_SYSMEM : block
  
    signal sram_i_s   : from_SRAM_t;
    signal sram_o_s   : to_SRAM_t;
  
  begin

    ram_datao <= sram_i_s.d(ram_datao'range);
    sram_o_s.a <= std_logic_vector(RESIZE(unsigned(uP_addr), sram_o_s.a'length));
    sram_o_s.d <= std_logic_vector(RESIZE(unsigned(uP_datao), sram_o_s.d'length));
    sram_o_s.be <= std_logic_vector(to_unsigned(1, sram_o_s.be'length));
    sram_o_s.cs <= '1';
    sram_o_s.oe <= not ram_wr;
    sram_o_s.we <= ram_wr;

    GEN_DFLT_SYSMEM: if not TRS80_M3_SYSMEM_IN_BURCHED_SRAM generate
      sram_i_s <= sram_i;
      sram_o <= sram_o_s;
    end generate GEN_DFLT_SYSMEM;
    
    GEN_BURCHED_SYSMEM: if TRS80_M3_SYSMEM_IN_BURCHED_SRAM generate
      assert false
        report "TRS80_M3_SYSMEM_IN_BURCHED_SRAM option won't work on stock DE1 hardware"
          severity warning;
      -- hook up Burched SRAM module
      sram_i_s <= platform_i.sram_i;
      platform_o.sram_o <= sram_o_s;
    end generate GEN_BURCHED_SYSMEM;

  end block BLK_SYSMEM;
  
	-- memory chip selects
	-- ROM $0000-$37FF
	rom_cs <= '1' when uP_addr(15 downto 14) = "00" and uP_addr(13 downto 11) /= "111" else '0';
	-- KEYBOARD $3800-$38FF
	kbd_cs <= '1' when uP_addr(15 downto 10) = (X"3" & "10") else '0';
	-- VRAM
	vram_cs <= '1' when uP_addr(15 downto 10) = (X"3" & "11") else '0';
	-- RAM
  ram_cs <= '1' when uP_addr(15 downto 14) = "01" else
            '1' when (uP_addr(15 downto 14) = "10" and TRS80_M3_RAM_SIZE > 16) else
            '1' when (uP_addr(15 downto 14) = "11" and TRS80_M3_RAM_SIZE > 32) else
            '0';
  
	-- memory write enables
	vram_wr <= vram_cs and not ulabs_en and uPmemwr;
	-- microlabs hires graphics (mapped to normal video ram)
	ulabs_wr <= vram_cs and ulabs_en and uPmemwr;
	-- always write thru to RAM
	ram_wr <= ram_cs and uPmemwr;

	-- I/O chip selects
	-- Alpha Joystick $00 (active low)
	alpha_joy_cs <= '1' when io_addr = X"00" else '0';
	-- RDINTSTATUS $E0-E3 (active low)
	int_cs <= '1' when io_addr(7 downto 2) = "111000" else '0';
	-- NMI STATUS $E4
	nmi_cs <= '1' when io_addr = X"E4" else '0';
  -- reset RTC any read $EC-EF
  rtc_cs <= '1' when io_addr(7 downto 2) = "111011" else '0';
	-- FDC $F0-$F3
	fdc_cs_n <= '0' when io_addr(7 downto 2) = "111100" else '1';
	-- DRVSEL $F4
  drvsel_cs <= '1' when io_addr(7 downto 0) = X"F4" else '0';
  -- SOUND $FC-FF (Model I is $FF only)
	snd_cs <= '1' when io_addr(7 downto 2) = "111111" else '0';
	
	-- io read strobes
	nmirst <= nmi_cs and uPiord;
	rtc_intrst <= rtc_cs and uPiord;
  fdc_re_n <= not uPiord;
  
	-- io write enables
	-- WRINTMASKREQ $E0-E3
  intena_wr <= int_cs and uPiowr;
  -- NMIMASKREQ $E4
  nmiena_wr <= nmi_cs and uPiowr;
  -- FDC $F0-$F3
  fdc_we_n <= not uPiowr;
	-- SOUND OUTPUT $FC-FF (Model I is $FF only)
	snd_o.a <= uP_addr(snd_o.a'range);
	snd_o.d <= uP_datao;
	snd_o.rd <= '0';
  snd_o.wr <= snd_cs and uPiowr;
		
	-- memory read mux
	uPmem_datai <= 	rom_datao when rom_cs = '1' else
									kbd_data when kbd_cs = '1' else
									vram_datao when vram_cs = '1' and ulabs_en = '0' else
									ulabs_dat_o when vram_cs = '1' and ulabs_en = '1' else
									ram_datao when ram_cs = '1' else
                  X"FF";
	
	-- io read mux
	uPio_datai <= X"FF" when alpha_joy_cs = '1' else
								(not int_status) when int_cs = '1' else
								(not nmi_status) when nmi_cs = '1' else
								fdc_dat_o when fdc_cs_n = '0' else
								X"FF";
		
	KBD_MUX : process (uP_addr, inputs_i)
  	variable kbd_data_v : std_logic_vector(7 downto 0);
	begin
    
  	kbd_data_v := X"00";
		for i in 0 to 7 loop
	 		if uP_addr(i) = '1' then
			  kbd_data_v := kbd_data_v or inputs_i(i).d;
			  -- hack - 2nd button is also <BREAK>
			  if i = 6 then
          kbd_data_v(2) := kbd_data_v(2) or buttons_i(1);
        end if;
		  end if;
		end loop;

  	-- assign the output
		kbd_data <= kbd_data_v;

  end process KBD_MUX;

  PROC_DRVSEL : process (clk_20M, clk_2M_ena, reset_i)
    subtype count_t is integer range 0 to 3999; -- 2ms watchdog
    variable count : count_t := count_t'high;
  begin
    if reset_i = '1' then
      drvsel_r <= (others => '0');
      count := count_t'high;
      z80_wait_n <= '1';
    elsif rising_edge(clk_20M) then
      if clk_2M_ena = '1' then
        if drvsel_cs = '1' and upiowr = '1' then
          drvsel_r <= up_datao;
          z80_wait_n <= not up_datao(6);
          count := 0;
        elsif count /= count_t'high then
          count := count + 1;
        end if;
      end if;
      -- 'async' reset on reset, irq, drq or 2ms timeout
      if (cpu_reset or fdc_irq or fdc_drq) = '1' or (count = count_t'high) then
        z80_wait_n <= '1';
      end if;
    end if;
  end process PROC_DRVSEL;
  
  -- PORT $EC (various)
  process (clk_20M, clk_2M_ena, reset_i)
  begin
    if reset_i = '1' then
      port_ec <= (others => '0');
    elsif rising_edge(clk_20M) and clk_2M_ena = '1' then
      if io_addr(7 downto 0) = X"EC" then
        if upiowr = '1' then
          port_ec <= up_datao;
        end if;
      end if;
    end if;
  end process;
  graphics_o.bit8_1(7 downto 2) <= port_ec(7 downto 2);

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> 10
		)
		port map
		(
			clk				=> clk_20M,
			reset			=> reset_i,
			clk_en		=> clk_2M_ena
		);

  BLK_Z80 : block
  begin
  
    up_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_20M,                                   
        clk_en	=> clk_2M_ena,
        reset  	=> cpu_reset,                                     

        addr   	=> uP_addr,
        datai  	=> uP_datai,
        datao  	=> uP_datao,

        mem_rd 	=> uPmemrd,
        mem_wr 	=> uPmemwr,
        io_rd  	=> uPiord,
        io_wr  	=> uPiowr,

        wait_n  => z80_wait_n,
        intreq 	=> uPintreq,
        intvec 	=> uPintvec,
        intack 	=> uPintack,
        nmi    	=> uPnmireq
      );
  end block BLK_Z80;
  
	rom_inst : entity work.trs80_rom
		port map
		(
			clock			=> clk_20M,
			address		=> up_addr(13 downto 0),
			q					=> rom_datao
		);
	
	tilerom_inst : entity work.trs80_tile_rom
		port map
		(
			clock			=> clk_video,
			address		=> tilemap_i.tile_a(11 downto 0),
			q					=> tilemap_o.tile_d
		);

  GEN_HIRES: if TRS80_M3_HIRES_SUPPORT generate

    BLK_HIRES : block
      signal hires_a  : std_logic_vector(13 downto 0) := (others => '0');   -- Max 16KiB
      signal mode_r   : std_logic_vector(7 downto 0) := (others => '0');
    begin

      process (clk_20M, cpu_reset)
        variable wr_r   : std_logic := '0';
      begin
        if cpu_reset = '1' then
          mode_r <= (others => '0');
          ulabs_en <= '0';
          wr_r := '0';
        elsif rising_edge(clk_20M) then
          if io_addr = X"FF" then
            -- write to the mode register
            if wr_r = '0' and upiowr = '1' then
              -- leading-edge write
              if up_datao(5) = '1' then
                mode_r <= up_datao;
              end if;
            end if;
          end if;
          wr_r := upiowr;
        end if;
        ulabs_en <= mode_r(7);
      end process;

      hires_a(13 downto 10) <= mode_r(4 downto 1);
      hires_a(9 downto 0) <= up_addr(9 downto 0);

      -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
      hires_ram_inst : entity work.trs80_hires_ram
        port map
        (
          clock_b			=> clk_20M,
          address_b		=> hires_a(TRS80_M3_HIRES_WIDTHA-1 downto 0),
          wren_b			=> ulabs_wr,
          data_b			=> up_datao,
          q_b					=> ulabs_dat_o,

          clock_a			=> clk_video,
          address_a		=> bitmap_i.a(TRS80_M3_HIRES_WIDTHA-1 downto 0),
          wren_a			=> '0',
          data_a			=> (others => 'X'),
          q_a					=> bitmap_o.d(7 downto 0)
        );

      graphics_o.bit8_1(1 downto 0) <= '0' & mode_r(6);

    end block BLK_HIRES;
  end generate GEN_HIRES;
    
  GEN_NO_HIRES : if not TRS80_M3_HIRES_SUPPORT generate
    bitmap_o <= NULL_TO_BITMAP_CTL;
    graphics_o.bit8_1(1 downto 0) <= "00";
  end generate GEN_NO_HIRES;
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.trs80_vram
		port map
		(
			clock_b			=> clk_20M,
			address_b		=> uP_addr(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> uP_datao,
			q_b					=> vram_datao,

			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
	tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

  interrupts_inst : entity work.TRS80_Interrupts                    
    port map
    (
      clk           => clk_20M,
      reset         => cpu_reset,

      -- enable inputs                    
      z80_data      => uP_datao,
      intena_wr     => intena_wr,                  
      nmiena_wr     => nmiena_wr,
                  
      -- IRQ inputs
      reset_btn_int => '0',
      fdc_drq_int   => fdc_irq,                    
      fdc_dto_int   => '0',

      -- IRQ/status outputs
      int_status    => int_status,
      int_req       => uPintreq,
      nmi_status    => nmi_status,
      nmi_req       => uPnmireq,

      -- interrupt clear inputs
      rtc_reset     => rtc_intrst,
      nmi_reset     => nmirst
    );

  GEN_FDC : if TRS80_M3_FDC_SUPPORT generate
  
    component wd179x is
      port
      (
        clk           : in std_logic;
        clk_20M_ena   : in std_logic;
        reset         : in std_logic;
        
        -- micro bus interface
        mr_n          : in std_logic;
        we_n          : in std_logic;
        cs_n          : in std_logic;
        re_n          : in std_logic;
        a             : in std_logic_vector(1 downto 0);
        dal_i         : in std_logic_vector(7 downto 0);
        dal_o         : out std_logic_vector(7 downto 0);
        clk_1mhz_en   : in std_logic;
        drq           : out std_logic;
        intrq         : out std_logic;
        
        -- drive interface
        step          : out std_logic;
        dirc          : out std_logic; -- 1=in, 0=out
        early         : out std_logic;
        late          : out std_logic;
        test_n        : in std_logic;
        hlt           : in std_logic;
        rg            : out std_logic;
        sso           : out std_logic;
        rclk          : in std_logic;
        raw_read_n    : in std_logic;
        hld           : out std_logic;
        tg43          : out std_Logic;
        wg            : out std_logic;
        wd            : out std_logic;
        ready         : in std_logic;
        wf_n_i        : in std_logic;
        vfoe_n_o      : out std_logic;
        tr00_n        : in std_logic;
        ip_n          : in std_logic;
        wprt_n        : in std_logic;
        dden_n        : in std_logic;

        -- temp fudge!!!
        wr_dat_o			: out std_logic_vector(7 downto 0);
        
        debug         : out std_logic_vector(31 downto 0)
      );
    end component wd179x;
    
    component floppy_if is
      generic
      (
        NUM_TRACKS      : integer := 35
      );
      port
      (
        clk           : in std_logic;
        clk_20M_ena   : in std_logic;
        reset         : in std_logic;
        
        drv_ena       : in std_logic_vector(4 downto 1);
        drv_sel       : in std_logic_vector(4 downto 1);
        
        step          : in std_logic;
        dirc          : in std_logic;
        rg            : in std_logic;
        rclk          : out std_logic;
        raw_read_n    : out std_logic;
        wg            : in std_logic;
        wd            : in std_logic;
        tr00_n        : out std_logic;
        ip_n          : out std_logic;

        -- media interface

        track         : out std_logic_vector(7 downto 0);
        dat_i         : in std_logic_vector(7 downto 0);
        dat_o         : out std_logic_vector(7 downto 0);
        wr            : out std_logic;
        -- random-access control
        offset        : out std_logic_vector(12 downto 0);
        -- fifo control
        rd            : out std_logic;
        flush         : out std_logic;
        
        debug         : out std_logic_vector(31 downto 0)
      );
    end component floppy_if;
    
    component floppy_fifo is
      port
      (
        aclr		: IN STD_LOGIC  := '0';
        data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        rdclk		: IN STD_LOGIC ;
        rdreq		: IN STD_LOGIC ;
        wrclk		: IN STD_LOGIC ;
        wrreq		: IN STD_LOGIC ;
        q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        rdempty		: OUT STD_LOGIC ;
        wrfull		: OUT STD_LOGIC 
      );
    end component floppy_fifo;
    
    constant FLOPPY_USE_FLASH : boolean := true;
    constant FLOPPY_USE_SRAM  : boolean := true;

    -- drive assignments
    constant DS_FLASH   : natural := 1;
    constant DS_SRAM    : natural := 2;
    constant DS_FIFO_1  : natural := 3;
    constant DS_FIFO_2  : natural := 4;
    
    signal sync_reset   : std_logic := '1';
    
    signal step         : std_logic := '0';
    signal dirc         : std_logic := '0';
    signal rg           : std_logic := '0';
    signal rclk         : std_logic := '0';
    signal raw_read_n   : std_logic := '0';
    signal wg           : std_logic := '0';
    signal wd           : std_logic := '0';
    signal tr00_n       : std_logic := '0';
    signal ip_n         : std_logic := '0';
    signal wprt_n       : std_logic := '1';
    
    signal de_s         : std_logic_vector(4 downto 1);

    -- floppy data
    signal track              : std_logic_vector(7 downto 0) := (others => '0');
    signal offset             : std_logic_vector(12 downto 0) := (others => '0');
    signal rd_data_from_media : std_logic_vector(7 downto 0) := (others => '0');
    signal rd_data_from_flash_media : std_logic_vector(rd_data_from_media'range) := (others => '0');
    signal rd_data_from_sram_media  : std_logic_vector(rd_data_from_media'range) := (others => '0');
    signal rd_data_from_fifo  : std_logic_vector(7 downto 0) := (others => '0');
    signal wr_data_to_media   : std_logic_vector(7 downto 0) := (others => '0');
    signal media_wr           : std_logic := '0';
    
    signal fifo_rd      : std_logic := '0';
    signal fifo_wr      : std_logic := '0';
    signal fifo_flush   : std_logic := '0';

    signal floppy_dbg   : std_logic_vector(31 downto 0) := (others => '0');
    signal wd179x_dbg   : std_logic_vector(31 downto 0) := (others => '0');
    
  begin

    process (clk_20M, reset_i)
      variable reset_r : std_logic_vector(3 downto 0) := (others => '0');
    begin
      if reset_i = '1' then
        reset_r := (others => '1');
      elsif rising_edge(clk_20M) then
        reset_r := reset_r(reset_r'left-1 downto 0) & platform_reset;
      end if;
      sync_reset <= reset_r(reset_r'left);
    end process;
    
    wd179x_inst : wd179x
      port map
      (
        clk           => clk_20M,
        clk_20M_ena   => '1',
        reset         => sync_reset,
        
        -- micro bus interface
        mr_n          => '1',
        we_n          => fdc_we_n,
        cs_n          => fdc_cs_n,
        re_n          => fdc_re_n,
        a             => up_addr(1 downto 0),
        dal_i         => uP_datao,
        dal_o         => fdc_dat_o,
        clk_1mhz_en   => '1',
        drq           => fdc_drq,
        intrq         => fdc_irq,
        
        -- drive interface
        step          => step,
        dirc          => dirc,
        early         => open,    -- not used atm
        late          => open,    -- not used atm
        test_n        => '1',     -- not used
        hlt           => '1',     -- head always engaged atm
        rg            => rg,
        sso           => open,
        rclk          => rclk,
        raw_read_n    => raw_read_n,
        hld           => open,    -- not used atm
        tg43          => open,    -- not used on TRS-80 designs
        wg            => wg,
        wd            => wd,      -- 200ns (MFM) or 500ns (FM) pulse
        ready         => '1',     -- always read atm
        wf_n_i        => '1',     -- no write faults atm
        vfoe_n_o      => open,    -- not used in TRS-80 designs?
        tr00_n        => tr00_n,
        ip_n          => ip_n,
        wprt_n        => wprt_n,
        dden_n        => '0',     -- double density only atm
        
        wr_dat_o      => wr_data_to_media,

        debug         => wd179x_dbg
      );
      
    floppy_if_inst : floppy_if
      generic map
      (
        NUM_TRACKS      => 40
      )
      port map
      (
        clk           => clk_20M,
        clk_20M_ena   => '1',
        reset         => sync_reset,
        
        -- drive select lines
        drv_ena       => de_s,
        drv_sel       => ds,
        
        step          => step,
        dirc          => dirc,
        rg            => rg,
        rclk          => rclk,
        raw_read_n    => raw_read_n,
        wg            => wg,
        wd            => wd,
        tr00_n        => tr00_n,
        ip_n          => ip_n,
        
        -- media interface

        track         => track,
        dat_i         => rd_data_from_media,
        dat_o         => open,
        wr            => media_wr,
        -- random-access control
        offset        => offset,
        -- fifo control
        rd            => fifo_rd,
        flush         => fifo_flush,
        
        debug         => floppy_dbg
      );

    BLK_FIFO : block
      signal fifo_rd_pulse	: std_logic := '0';
      signal fifo_empty     : std_logic := '0';   -- not used
      signal fifo_full      : std_logic := '0';
    begin

      process (clk_20M, sync_reset)
        subtype count_t is integer range 0 to 7;
        variable count      : count_t := 0;
        variable offset_v   : std_logic_vector(12 downto 0) := (others => '0');
        variable fifo_rd_r	: std_logic := '0';
      begin
        if sync_reset = '1' then
          count := 0;
          offset_v := (others => '0');
        elsif rising_edge(clk_20M) then

          -- fifo read pulse is too wide - edge-detect
          fifo_rd_pulse <= '0';	-- default
          if fifo_rd = '1' and fifo_rd_r = '0' then
            fifo_rd_pulse <= '1';
          end if;
          fifo_rd_r := fifo_rd;

          --fifo_wr <= '0';   -- default
          --if count = count_t'high then
          --  if fifo_full = '0' then
          --    fifo_wr <= '1';
          --    if offset_v = 6272-1 then
          --      offset_v := (others => '0');
          --    else
          --      offset_v := offset_v + 1;
          --    end if;
          --  end if;
          --  count := 0;
          --else
          --  count := count + 1;
          --  -- don't update when writing to FIFO
          --  flash_o.a(12 downto 0) <= offset_v;
          --end if;
        end if;
      end process;

      platform_o.floppy_track <= track;
      --platform_o.floppy_offset <= offset;
      
      fifo_inst : floppy_fifo
        PORT map
        (
          rdclk		  => clk_20M,
          q		      => rd_data_from_fifo,
          rdreq		  => fifo_rd_pulse,
          rdempty		=> fifo_empty,

          wrclk		  => platform_i.floppy_fifo_clk,
          data		  => platform_i.floppy_fifo_data,
          wrreq		  => platform_i.floppy_fifo_wr,
          wrfull		=> platform_o.floppy_fifo_full,
          aclr      => fifo_flush
        );

    end block BLK_FIFO;

    GEN_FLASH_FLOPPY : if FLOPPY_USE_FLASH generate
      flash_o.a(flash_o.a'left downto 20) <= (others => '0');
      -- support 1 drive in flash for now
      flash_o.a(19) <=  '0' when ds(DS_FLASH) = '1' else
                        --'1' when ds(2) = '1' else
                        '0';
      -- each track is encoded in 8KiB
      -- - 40 tracks is 320(512) KiB
      flash_o.a(18 downto 13) <= track(5 downto 0);
      flash_o.a(12 downto 0) <= offset;
      flash_o.cs <= '1';
      flash_o.oe <= '1';
      flash_o.we <= '0';

      rd_data_from_flash_media <= flash_i.d;
    end generate GEN_FLASH_FLOPPY;
    
    GEN_SRAM_FLOPPY : if FLOPPY_USE_SRAM generate
      signal sram_i_s   : from_SRAM_t;
      signal sram_o_s   : to_SRAM_t;
    begin

      sram_o_s.a(sram_o_s.a'left downto 19) <= (others => '0');
      -- support 1 drive in sram for now
      -- - DE1/DE2 SRAM doesn't have A(18)!!!
      sram_o_s.a(18) <= '0' when ds(DS_SRAM) = '1' else
                        --'1' when ds(DS_SRAM_2) = '1' else
                        '0';
      sram_o_s.a(17 downto 12) <= track(5 downto 0);
      sram_o_s.a(11 downto 0) <= offset(12 downto 1);
      sram_o_s.be <= "00" & offset(0) & not offset(0);
      sram_o_s.cs <= ds(DS_SRAM);
      sram_o_s.oe <= not wg;
      sram_o_s.we <= media_wr;

      rd_data_from_sram_media <=  sram_i_s.d(15 downto 8) when offset(0) = '1' else
                                  sram_i_s.d(7 downto 0);

      sram_o_s.d(sram_o_s.d'left downto 16) <= (others => '0');
      -- only 1 of these will be enabled
      sram_o_s.d(15 downto 0) <= wr_data_to_media & wr_data_to_media;

      GEN_DFLT_SRAM_FLOPPY : if TRS80_M3_SYSMEM_IN_BURCHED_SRAM generate
        sram_i_s <= sram_i;
        sram_o <= sram_o_s;
      end generate GEN_DFLT_SRAM_FLOPPY;
      
      GEN_BURCHED_SRAM_FLOPPY : if not TRS80_M3_SYSMEM_IN_BURCHED_SRAM generate
        sram_i_s <= platform_i.sram_i;
        platform_o.sram_o <= sram_o_s;
      end generate GEN_BURCHED_SRAM_FLOPPY;
      
    end generate GEN_SRAM_FLOPPY;

    GEN_NO_SRAM_FLOPPY : if not FLOPPY_USE_SRAM generate
      rd_data_from_sram_media <= (others => '1');
    end generate GEN_NO_SRAM_FLOPPY;

    rd_data_from_media <= rd_data_from_flash_media when ds(DS_FLASH) = '1' else
                          rd_data_from_sram_media when ds(DS_SRAM) = '1' else
                          rd_data_from_fifo;
                            
    -- drive enable switches
    de_s <= not switches_i(3 downto 0);

    -- write-protect the flash drive
    wprt_n <= '0' when ds(DS_FLASH) = '1' else '1';
      
    platform_o.seg7 <=  -- memory address
                        floppy_dbg(31 downto 16) when switches_i(5 downto 4) = "11" else 
                        -- track & data byte
                        floppy_dbg(15 downto 0) when switches_i(5 downto 4) = "10" else
                        -- idam track and sector
                        wd179x_dbg(31 downto 16) when switches_i(5 downto 4) = "01" else
                        -- track & sector registers
                        wd179x_dbg(15 downto 0);

    leds_o(9) <= not tr00_n;

    -- extend the step signal so we can see it on the LED
    process (clk_20M, clk_2M_ena)
      subtype count_t is integer range 0 to 199999;  -- 100ms
      variable count : count_t := 0;
      variable step_r : std_logic := '0';
    begin
      if rising_edge(clk_20M) then
        -- leading edge step
        if step_r = '0' and step = '1' then
          count := count_t'high;
          leds_o(8) <= '1';
        elsif clk_2M_ena = '1' then
          if count /= 0 then
            count := count - 1;
          else
            leds_o(8) <= '0';
          end if;
        end if;
        step_r := step;
      end if;
    end process;

    leds_o(7) <= not ip_n;
    leds_o(6) <= wg;
    
    leds_o(3) <= ds(4);
    leds_o(2) <= ds(3);
    leds_o(1) <= ds(2);
    leds_o(0) <= ds(1);
    
  end generate GEN_FDC;

  GEN_NO_FDC : if not TRS80_M3_FDC_SUPPORT generate
                
    fdc_dat_o <= X"FF";
    fdc_drq <= '0';
    fdc_irq <= '0';
    leds_o <= (others => '0');
        
  end generate GEN_NO_FDC;

  -- wire some keys to the osd module
  gpio_to_osd(0) <= inputs_i(6).d(3); -- UP
  gpio_to_osd(1) <= inputs_i(6).d(4); -- DOWN
  gpio_to_osd(2) <= inputs_i(6).d(5); -- LEFT
  gpio_to_osd(3) <= inputs_i(6).d(6); -- RIGHT
  gpio_to_osd(4) <= inputs_i(6).d(0); -- ENTER
  gpio_to_osd(7 downto 5) <= (others => '0');

  GEN_OSD : if PACE_HAS_OSD generate

    osd_inst : osd_controller
      generic map
      (
        WIDTH_GPIO  => gpio_to_osd'length
      )
      port map
      (
        clk         => clk_20M,
        clk_en      => '1',
        reset       => cpu_reset,

        osd_key     => inputs_i(8).d(1),

        to_osd      => osd_o,
        from_osd    => osd_i,

        gpio_i      => gpio_to_osd,
        gpio_o      => gpio_from_osd
      );

  end generate GEN_OSD;
  
  -- unused outputs
	sprite_reg_o <= NULL_TO_SPRITE_REG;
	sprite_o <= NULL_TO_SPRITE_CTL;
  tilemap_o.attr_d <= std_logic_vector(RESIZE(unsigned(switches_i(7 downto 0)), tilemap_o.attr_d'length));
	graphics_o.pal <= (others => (others => '0'));
	ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;

end architecture SYN;
