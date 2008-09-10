library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.in8;
use work.project_pkg.all;

entity Game is
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
    inputs_i        : in from_INPUTS_t;

    -- micro buses
    upaddr          : out std_logic_vector(15 downto 0);   
    updatao         : out std_logic_vector(7 downto 0);    

    -- FLASH/SRAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_FLASH_t;
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t;
    
    --
    --
    --

    gfxextra_data   : out std_logic_vector(7 downto 0);
		palette_data		: out ByteArrayType(15 downto 0);

    -- graphics (bitmap)
		bitmap_addr			: in std_logic_vector(15 downto 0);
		bitmap_data			: out std_logic_vector(7 downto 0);
		
    -- graphics (tilemap)
    tileaddr        : in std_logic_vector(15 downto 0);   
    tiledatao       : out std_logic_vector(7 downto 0);    
    tilemapaddr     : in std_logic_vector(15 downto 0);   
    tilemapdatao    : out std_logic_vector(15 downto 0);    
    attr_addr       : in std_logic_vector(9 downto 0);    
    attr_dout       : out std_logic_vector(15 downto 0);   

    -- graphics (sprite)
    sprite_reg_addr : out std_logic_vector(7 downto 0);    
    sprite_wr       : out std_logic;                       
    spriteaddr      : in std_logic_vector(15 downto 0);   
    spritedata      : out std_logic_vector(31 downto 0);   
		spr0_hit				: in std_logic;
		
    -- graphics (control)
    vblank					: in std_logic;    
		xcentre					: out std_logic_vector(9 downto 0);
		ycentre					: out std_logic_vector(9 downto 0);

    snd_rd          : out std_logic;
    snd_wr          : out std_logic;
    sndif_datai     : in std_logic_vector(7 downto 0);

    -- OSD
    to_osd          : out to_OSD_t;
    from_osd        : in from_OSD_t
  );
end Game;

architecture SYN of Game is

	alias clk_24M					: std_logic is clk_i(0);
	alias clk_40M					: std_logic is clk_i(1);
	
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);
                        
	-- IO signals
	signal inputs					: in8(0 to 2);
	alias game_reset			: std_logic is inputs(2)(0);
	signal dip_n					: std_logic_vector(7 downto 0);

  -- other signals      
	signal cpu_reset			: std_logic;
  signal uPmem_datai    : std_logic_vector(7 downto 0);
  signal uPio_datai     : std_logic_vector(7 downto 0);
  
begin

	cpu_reset <= reset_i or game_reset;
	dip_n <= not switches_i(dip_n'range);
	
  sram_o.a <= (others => 'X');
  sram_o.d <= (others => 'X');
  sram_o.be <= (others => '0');
  sram_o.cs <= '0';
  sram_o.oe <= '0';
  sram_o.we <= '0';
			
  -- osd toggle (TAB)
  process (clk_24M, reset_i)
    variable osd_key_r  : std_logic;
    variable osd_en_v   : std_logic;
  begin
    if reset_i = '1' then
      osd_en_v := '0';
      osd_key_r := '0';
    elsif rising_edge(clk_24M) then
      -- toggle on OSD KEY PRESS
      if inputs(2)(1) = '1' and osd_key_r = '0' then
        osd_en_v := not osd_en_v;
      end if;
      osd_key_r := inputs(2)(1);
    end if;
    to_osd.en <= osd_en_v;
  end process;

  gfxextra_data <= (others => '0');
	GEN_PAL_DAT : for i in palette_data'range generate
		palette_data(i) <= (others => '0');
	end generate GEN_PAL_DAT;

  -- unused outputs
	tilemapdatao <= (others => '0');
	tiledatao <= (others => '0');
	upaddr <= (others => '0');
	updatao <= (others => '0');
  sprite_reg_addr <= (others => '0');
  sprite_wr <= '0';
  spriteData <= (others => '0');
  attr_dout <= X"00" & dip_n;

	leds_o <= (others => '0');
	
	inputs_inst : entity work.Inputs
		generic map
		(
			NUM_INPUTS	=> 3,
			CLK_1US_DIV	=> TEST_1MHz_CLK0_COUNTS
		)
	  port map
	  (
	    clk     	=> clk_24M,
	    reset   	=> reset_i,
	    ps2clk  	=> inputs_i.ps2_kclk,
	    ps2data 	=> inputs_i.ps2_kdat,
			jamma			=> inputs_i.jamma_n,
	
	    dips     	=> dip_n,
	    inputs		=> inputs
	  );

  flash_o.a <= (others => '0');
  flash_o.d <= (others => 'Z');
  flash_o.we <= '0';
  flash_o.cs <= '1';
  flash_o.oe <= '1';

		--
		--	*** WARNING - the contents of the VRAM are offset!!!
		--							- the video won't look right!!!!
		--
		
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		vram_inst : entity work.dpram
      generic map
      (
        init_file => "",
        numwords_a => 8192,
        widthad_a => 13
      )
	    port map
	    (
	        clock_b   	=> clk_24M,
	        address_b   => (others => '0'),
	        data_b      => (others => '0'),
	        q_b					=> open,
	        wren_b			=> '0',

	        clock_a     => clk_40M,
	        address_a   => bitmap_addr(12 downto 0),
      		data_a      => (others => '0'),
	        q_a					=> bitmap_data,
      		wren_a			=> '0'
	    );

end SYN;
