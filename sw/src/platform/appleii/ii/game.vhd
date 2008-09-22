library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.STD_MATCH;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;
use work.kbd_pkg.all;

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
    bitmap_addr			: in    std_logic_vector(15 downto 0);   
    bitmap_data			: out   std_logic_vector(7 downto 0);    

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
    spr0_hit        : in std_logic;

    -- graphics (control)
    vblank          : in std_logic;    
		xcentre					: out std_logic_vector(9 downto 0);
		ycentre					: out std_logic_vector(9 downto 0);

    -- OSD
    to_osd          : out to_OSD_t;
    from_osd        : in from_OSD_t;

    -- sound
    snd_rd          : out std_logic;                       
    snd_wr          : out std_logic;
    sndif_datai     : in std_logic_vector(7 downto 0)
  );
end Game;

architecture SYN of Game is

	alias clk_30M					: std_logic is clk_i(0);
	alias clk_video				: std_logic is clk_i(1);
	
	signal reset_n				: std_logic;
	
  -- uP signals  
  signal clk_1M_en			: std_logic;
  signal up_addr        : std_logic_vector(23 downto 0);
	alias addr_bus				: std_logic_vector(15 downto 0) is up_addr(15 downto 0);
  signal up_datai       : std_logic_vector(7 downto 0);
  signal up_datao       : std_logic_vector(7 downto 0);
  signal up_rw_n				: std_logic;
  signal up_irq_n				: std_logic;
	                        
  -- ROM signals        
	signal rom_e_cs				: std_logic;
  signal rom_e_data     : std_logic_vector(7 downto 0);
                        
  -- keyboard signals
  signal keybd_cs 			: std_logic;
  signal keybd_clr			: std_logic;
		                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
	signal vram_wr				: std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);

	-- HGR ram signals
	signal hgr1_cs				: std_logic;
	signal hgr0_cs				: std_logic;
	signal hgr_wr					: std_logic;
	alias hgr_data				: std_logic_vector(7 downto 0) is bitmap_data;
	signal hgr_addr				: std_logic_vector(13 downto 0);
		                        
  -- RAM signals        
	signal ram8_cs				: std_logic;
	signal ram6_cs				: std_logic;
	signal ram0_cs				: std_logic;
  signal wram_cs        : std_logic;
  alias wram_datao     	: std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

  -- other signals      
	signal inputs					: in8(0 to 0);
	signal a2var					: std_logic_vector(15 downto 0);	-- soft switches
	signal flash					: std_logic;
	
begin

	reset_n <= not reset_i;
	
	GEN_PAL_DAT : for i in palette_data'range generate
		palette_data(i) <= (others => '0');
	end generate GEN_PAL_DAT;
	
	xcentre <= (others => '0');
	ycentre <= (others => '0');
	
	-- ROM $E000-FFFF
	rom_e_cs <= 	'1' when STD_MATCH(addr_bus, "111-------------") else '0';
	-- KEYBOARD $C00X
	keybd_cs <= 	'1' when STD_MATCH(addr_bus, "110000000000----") else '0';
	-- ram8 $8000-BFFF
  ram8_cs <= 		'1' when STD_MATCH(addr_bus, "10--------------") else '0';
	-- ram6 $6000-7FFF
  ram6_cs <= 		'1' when STD_MATCH(addr_bus, "011-------------") else '0';
	-- HGR1 $4000-5FFF
  hgr1_cs <= 		'1' when STD_MATCH(addr_bus, "010-------------") else '0';
	-- HGR0 $2000-3FFF
  hgr0_cs <= 		'1' when STD_MATCH(addr_bus, "001-------------") else '0';
	-- RAM $0000-1FFF (excludes video RAM below)
	ram0_cs <=		'1' when STD_MATCH(addr_bus, "000-------------") else '0';
	-- VIDEO $0400-07FF
	vram_cs <= 		'1' when STD_MATCH(addr_bus, "000001----------") else '0';
	-- always write thru to (S)RAM
	wram_cs <= 		'1';
	
	-- memory read mux
	uP_datai <=	rom_e_data when rom_e_cs = '1' else
							inputs(0) when keybd_cs = '1' else
							wram_datao when ram8_cs = '1' else
							wram_datao when ram6_cs = '1' else
							wram_datao when hgr1_cs = '1' else
							wram_datao when hgr0_cs = '1' else
							vram_datao when vram_cs = '1' else	-- this must precede ram0_cs
							wram_datao when ram0_cs = '1' else
							-- C01X routintes
              -- reads bits from a2_var
							'0' & inputs(0)(6 downto 0) when addr_bus = X"C010" else
							(not vblank) & "0000000" when addr_bus = X"C019" else
              a2var(8) & "0000000" when addr_bus = X"C01A" else
              a2var(9) & "0000000" when addr_bus = X"C01B" else
              a2var(10) & "0000000" when addr_bus = X"C01C" else
              a2var(11) & "0000000" when addr_bus = X"C01D" else
							X"00";

	-- read $C01X clears the AY3600 key latch
  keybd_clr <= up_rw_n when STD_MATCH(addr_bus, "110000000001----") else '0';

	-- writes to $C03X toggle speaker output
	snd_wr <= '1' when addr_bus(15 downto 4) = X"C03" else '0';

	-- vram $0400-07FF
  vram_wr <= not up_rw_n and vram_cs;
	hgr_wr <= not up_rw_n and (hgr1_cs or hgr0_cs);
	
  process (clk_30M, reset_i)
  	-- 'softswitch' latches (2 bytes)
  	variable a2var_r    	: std_logic_vector(15 downto 0);
 	begin
		if reset_i = '1' then
    	a2var_r := X"0100"; -- text mode
  	elsif rising_edge (clk_30M) then
			-- write to C00X sets the LSB bits of a2_var
      -- - leave unimplemented atm
      -- read/write to C05X sets the MSB bits of a2_var
      if up_rw_n = '0' and addr_bus(15 downto 4) = X"C05" then
      	case addr_bus(3 downto 1) is
        	when "000" => a2var_r(8) := addr_bus(0); -- gfx/text
          when "001" => a2var_r(9) := addr_bus(0); -- full/mixed
          when "010" => a2var_r(10) := addr_bus(0); -- pg1/pg2
          when "011" => a2var_r(11) := addr_bus(0); -- lores/hires
          when others =>
        end case;
      end if;
    end if;
  	a2var <= a2var_r;
	end process;

	-- flash is the character flash timer
	-- attr_addr(1 downto 0) is flashing/inverse bits
	attr_dout <= EXT(flash & attr_addr(1 downto 0) & X"00", attr_dout'length);

	-- HGR $2000-$5FFF has two (2) 8KB pages of hires graphics
	-- page (a2var(10)) is inverted because hgr memory starts on 8K boundary
	hgr_addr <= not a2var(10) & bitmap_addr(hgr_addr'left-1 downto 0);

	-- use spritedata to expose the softswitches to the graphics core	
	spritedata <= EXT(a2var, spritedata'length);

  -- SRAM signals (may or may not be used)
  sram_o.a <= EXT(addr_bus, sram_o.a'length);
  sram_o.d <= EXT(up_datao, sram_o.d'length);
	sram_o.be <= EXT("1", sram_o.be'length);
  sram_o.cs <= '1';
  sram_o.oe <= wram_cs and up_rw_n;
  sram_o.we <= wram_cs and not up_rw_n;
	
	upaddr <= up_addr(upaddr'range);
	updatao <= up_datao;

  gfxextra_data <= (others => '0');

  -- unused outputs
  snd_rd <= '0';
  sprite_reg_addr <= (others => '0');
	sprite_wr <= '0';
	leds_o <= EXT(inputs(0), leds_o'length);
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU clock enable (1MHz from 30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> 30
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset_i,
			clk_en		=> clk_1M_en
		);

	up_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> reset_n,
			Enable  		=> clk_1M_en,
			Clk     		=> clk_30M,
			Rdy     		=> '1',
			Abort_n 		=> '1',
			IRQ_n   		=> up_irq_n,
			NMI_n   		=> '1',
			SO_n    		=> '1',
			R_W_n   		=> up_rw_n,
			Sync    		=> open,
			EF      		=> open,
			MF      		=> open,
			XF      		=> open,
			ML_n    		=> open,
			VP_n    		=> open,
			VDA     		=> open,
			VPA     		=> open,
			A       		=> up_addr,
			DI      		=> up_datai,
			DO      		=> up_datao
		);

	inputs_inst : entity work.Inputs
		generic map
		(
			NUM_INPUTS	=> 1
		)
	  port map
	  (
	    clk     		=> clk_30M,
	    reset   		=> reset_i,
	    ps2clk  		=> inputs_i.ps2_kclk,
	    ps2data 		=> inputs_i.ps2_kdat,
			jamma				=> inputs_i.jamma_n,

			dips(7 downto 1)	=> (others =>'0'),
	    dips(0)			=> keybd_clr,
	    inputs			=> inputs
	  );

	intgen_inst : entity work.intGen
		port map
		(
	    clk       	=> clk_30M,
	    reset     	=> reset_i,

	    -- inputs
	    --vsync_n   : in     std_logic;
	    --intack    : in     std_logic;

	    -- outputs
	    vblank    	=> open,
	    flash     	=> flash,
	    irq_n     	=> up_irq_n
		);
	
	romE_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../../src/platform/appleii/ii/roms/rom_e.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13
		)
		port map
		(
			clock			=> clk_30M,
			address		=> addr_bus(12 downto 0),
			q					=> rom_e_data
		);
	
	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../../src/platform/appleii/ii/roms/tile0.hex",
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock			=> clk_video,
			address		=> tileaddr(10 downto 0),
			q					=> tileDatao
		);
	
	GEN_ONLY_1_HIRES_PAGE : if APPLE_II_HIRES_PAGES = 1 generate

		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		hgrram_inst : entity work.dpram
			generic map
			(
				init_file		=> "../../../../../../src/platform/appleii/iiplus/roms/hgr.hex",
				numwords_a	=> 8192,
				widthad_a		=> 13
			)
			port map
			(
				-- uP interface
				clock_b			=> clk_30M,
				address_b		=> addr_bus(12 downto 0),
				wren_b			=> hgr_wr,
				data_b			=> up_datao,
				q_b					=> open,				-- 6502 reads from SRAM rather than DPRAM
				
				-- graphics interface
				clock_a			=> clk_video,
				address_a		=> hgr_addr(12 downto 0),
				wren_a			=> '0',
				data_a			=> (others => 'X'),
				q_a					=> hgr_data
			);

	end generate GEN_ONLY_1_HIRES_PAGE;
	
	GEN_2_HIRES_PAGES : if APPLE_II_HIRES_PAGES > 1 generate

		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		hgrram_inst : entity work.dpram
			generic map
			(
				init_file		=> "../../../../../../src/platform/appleii/iiplus/roms/hgr.hex",
				numwords_a	=> 16384,
				widthad_a		=> 14
			)
			port map
			(
				-- uP interface
				clock_b			=> clk_30M,
				address_b		=> addr_bus(13 downto 0),
				wren_b			=> hgr_wr,
				data_b			=> up_datao,
				q_b					=> open,				-- 6502 reads from SRAM rather than DPRAM
				
				-- graphics interface
				clock_a			=> clk_video,
				address_a		=> hgr_addr(13 downto 0),
				wren_a			=> '0',
				data_a			=> (others => 'X'),
				q_a					=> hgr_data
			);

	end generate GEN_2_HIRES_PAGES;
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../../src/platform/appleii/ii/roms/vram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			-- uP interface
			clock_b			=> clk_30M,
			address_b		=> addr_bus(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> up_datao,
			q_b					=> vram_datao,
			
			-- graphics interface
			clock_a			=> clk_video,
			address_a		=> tilemapaddr(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tileMapDatao(7 downto 0)
		);

end SYN;
