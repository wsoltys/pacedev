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

	alias clk_sys					: std_logic is clk_i(0);
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

  -- special i/o signals
  signal sio_cs         : std_logic := '0';
  signal sio_data       : std_logic_vector(7 downto 0) := (others => '0');
  
  -- keyboard signals
	signal kbd_cs					: std_logic;
	signal kbd_data				: std_logic_vector(7 downto 0);
	                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);

  -- RAM signals        
  signal ram_cs         : std_logic := '0';
  signal ram_wr         : std_logic := '0';
  signal ram_datao      : std_logic_vector(7 downto 0);

  signal guestrom_cs    : std_logic := '0';
  signal guestrom_datao : std_logic_vector(7 downto 0) := (others => '0');
  
  signal sram_cs        : std_logic := '0';
  signal sram_wr        : std_logic := '0';
  signal sram_bank      : std_logic_vector(16 downto 14) := (others => '0');
  signal sram_datao     : std_logic_vector(7 downto 0) := (others => '0');
  
  -- interrupt signals
  signal z80_wait_n     : std_logic := '1';

  -- other signals      
	alias platform_reset	: std_logic is inputs_i(NUM_INPUT_BYTES-1).d(0);
	signal cpu_reset			: std_logic;  
  signal uPmem_datai    : std_logic_vector(7 downto 0);
  signal uPio_datai     : std_logic_vector(7 downto 0);
	
begin

	cpu_reset <= reset_i or platform_reset;
	
  -- not used for now
  uPintvec <= (others => '0');

  -- read mux
  uP_datai <= uPmem_datai when (uPmemrd = '1') else uPio_datai;

  -- sram
  sram_datao <= sram_i.d(sram_datao'range);
  sram_o.a(sram_o.a'left downto 17) <= (others => '0');
  sram_o.a(16 downto 14) <= sram_bank;
  sram_o.a(13 downto 0) <= uP_addr(13 downto 0);
  sram_o.d <= std_logic_vector(RESIZE(unsigned(uP_datao), sram_o.d'length));
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not sram_wr;
  sram_o.we <= sram_wr;
    
	-- memory chip selects
	-- ROM (2KB) $0000-$07FF
	rom_cs <=       '1' when STD_MATCH(uP_addr, "00000-----------") else '0';
	-- RAM (2KB) $8000-$0FFF
  ram_cs <=       '1' when STD_MATCH(uP_addr, "00001-----------") else '0';
	-- special I/O $1000-$1FFF
  sio_cs <=       '1' when STD_MATCH(up_addr, "0001------------") else '0';
	-- KEYBOARD $3800-$38FF
	kbd_cs <=       '1' when STD_MATCH(uP_addr, "00111000--------") else '0';
	-- VRAM $3C00-$3FFF
	vram_cs <=      '1' when STD_MATCH(uP_addr, "001111----------") else '0';
  -- GUEST ROM (16KB) $4000-$7FFF
  guestrom_cs <=  '1' when STD_MATCH(uP_addr, "01--------------") else '0';
  -- SRAM (16KB) $8000-$BFFF
  sram_cs <=      '1' when STD_MATCH(uP_addr, "10--------------") else '0';
  
	-- memory write enables
	ram_wr <= ram_cs and uPmemwr;
	vram_wr <= vram_cs and uPmemwr;
  sram_wr <= sram_cs and uPmemwr;
  
	-- memory read mux
	uPmem_datai <= 	rom_datao when rom_cs = '1' else
									ram_datao when ram_cs = '1' else
									sio_data when sio_cs = '1' else
									kbd_data when kbd_cs = '1' else
									vram_datao when vram_cs = '1' else
									guestrom_datao when guestrom_cs = '1' else
									sram_datao when sram_cs = '1' else
                  X"FF";
	
	-- io read mux
	uPio_datai <= X"FF";

  BLK_SIO : block
  begin
    process (clk_sys)
      variable a : integer range 0 to 7 := 0;
    begin
      a := to_integer(unsigned(up_addr(2 downto 0)));
      if rising_edge(clk_sys) then
        if up_addr(3) = '0' then
          sio_data <= "0000" & LDR_BANK;
        else
          sio_data <= std_logic_vector(to_unsigned(character'pos(LDR_NAME(a+1)),8));
        end if;
      end if;
    end process;

    sram_bank <= LDR_BANK(2 downto 0);

  end block BLK_SIO;
  
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

  assert false
    report  "CLK0_FREQ_MHz=" & integer'image(CLK0_FREQ_MHz) &
            " CPU_FREQ_MHz=" &  integer'image(CPU_FREQ_MHz) &
            " CPU_CLK_ENA_DIV=" & integer'image(TRS80_M3_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> integer(TRS80_M3_CPU_CLK_ENA_DIVIDE_BY)
		)
		port map
		(
			clk				=> clk_sys,
			reset			=> reset_i,
			clk_en		=> clk_2M_ena
		);

  BLK_Z80 : block
  begin
  
    up_inst : entity work.Z80                                                
      port map
      (
        clk			=> clk_sys,                                   
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
			clock			=> clk_sys,
			address		=> up_addr(10 downto 0),
			q					=> rom_datao
		);
	
	ram_inst : entity work.trs80_ram
    port map
    (
      clock		  => clk_sys,
      address		=> up_addr(10 downto 0),
      data		  => up_datao,
      wren		  => ram_wr,
      q		      => ram_datao
    );

	tilerom_inst : entity work.trs80_tile_rom
		port map
		(
			clock			=> clk_video,
			address		=> tilemap_i.tile_a(11 downto 0),
			q					=> tilemap_o.tile_d
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.trs80_vram
		port map
		(
			clock_b			=> clk_sys,
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

  guestrom_inst : entity work.guest_rom
    port map
    (
      clock			=> clk_sys,
      address		=> up_addr(13 downto 0),
      q					=> guestrom_datao
    );

  -- unused outputs
	sprite_reg_o <= NULL_TO_SPRITE_REG;
	sprite_o <= NULL_TO_SPRITE_CTL;
  tilemap_o.attr_d <= std_logic_vector(RESIZE(unsigned(switches_i(7 downto 0)), tilemap_o.attr_d'length));
  bitmap_o <= NULL_TO_BITMAP_CTL;
  graphics_o.bit8_1 <= (others => '0');
	graphics_o.pal <= (others => (others => '0'));
	ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;

end architecture SYN;
