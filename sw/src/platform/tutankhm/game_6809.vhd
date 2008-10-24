library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.kbd_pkg.in8;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk							: in std_logic_vector(0 to 3);
    reset           : in std_logic;                       
    test_button     : in std_logic;                       

    -- inputs
    ps2clk          : inout std_logic;                       
    ps2data         : inout std_logic;                       
    dip             : in std_logic_vector(7 downto 0);    
		jamma						: in JAMMAInputsType;
		
    -- micro buses
    upaddr          : out std_logic_vector(15 downto 0);   
    updatao         : out std_logic_vector(7 downto 0);    

    -- SRAM
    sram_i          : in from_SRAM_t;
    sram_o          : out to_SRAM_t;

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
    sndif_datai     : in std_logic_vector(7 downto 0);    

    -- spi interface
    spi_clk         : out std_logic;                       
    spi_din         : in std_logic;                       
    spi_dout        : out std_logic;                       
    spi_ena         : out std_logic;                       
    spi_mode        : out std_logic;                       
    spi_sel         : out std_logic;                       

    -- serial
    ser_rx          : in std_logic;                       
    ser_tx          : out std_logic;                       

    -- portal for the external CPU
    gpio_i          : in std_logic_vector(39 downto 0);
    gpio_o          : out std_logic_vector(39 downto 0);

    -- on-board leds
    leds            : out std_logic_vector(7 downto 0)    
  );
end Game;

architecture SYN of Game is

	constant TUTANKHAM_VRAM_SIZE		: integer := 2**TUTANKHAM_VRAM_WIDTHAD;

	alias clk_30M					: std_logic is clk(0);
	alias clk_40M					: std_logic is clk(1);
	signal cpu_reset			: std_logic;

  alias cpu_6809_q            : std_logic is gpio_o(0);
  alias cpu_6809_e            : std_logic is gpio_o(1);
  alias cpu_6809_a            : std_logic_vector(15 downto 0) is gpio_i(15 downto 0);
  alias cpu_6809_rst_n        : std_logic is gpio_o(2);
  alias cpu_6809_halt_n       : std_logic is gpio_o(3);
  alias cpu_6809_tsc          : std_logic is gpio_o(4);
  alias cpu_6809_nmi_n        : std_logic is gpio_o(5);
  alias cpu_6809_irq_n        : std_logic is gpio_o(6);
  alias cpu_6809_firq_n       : std_logic is gpio_o(7);
  alias cpu_6809_rw_n         : std_logic is gpio_i(16);
  alias cpu_6809_ba           : std_logic is gpio_i(17);
  alias cpu_6809_bs           : std_logic is gpio_i(18);
  alias cpu_6809_busy         : std_logic is gpio_i(19);
  alias cpu_6809_lic          : std_logic is gpio_i(20);
  alias cpu_6809_avma         : std_logic is gpio_i(21);
  alias cpu_6809_d_i          : std_logic_vector(7 downto 0) is gpio_o(15 downto 8);
  alias cpu_6809_d_o          : std_logic_vector(7 downto 0) is gpio_i(29 downto 22);

	-- video counter (scanline) sent by "tilemap controller" via attr_addr
	alias video_counter		: std_logic_vector(7 downto 0) is attr_addr(7 downto 0);
		
  -- uP signals  
	signal clk_1M5_en			: std_logic;
	signal clk_1M5_en_n		: std_logic;
	signal cpu_rw					: std_logic;
	signal cpu_vma				: std_logic;
	signal cpu_addr				: std_logic_vector(15 downto 0);
	signal cpu_data_i			: std_logic_vector(7 downto 0);
	signal cpu_data_o			: std_logic_vector(7 downto 0);
	signal cpu_irq				: std_logic;
	signal cpu_firq				: std_logic;
	signal cpu_nmi				: std_logic;
	                        
  -- ROM signals        
	signal rom_a_cs				: std_logic;
  signal rom_a_data     : std_logic_vector(7 downto 0);
	signal rom_c_cs				: std_logic;
  signal rom_c_data     : std_logic_vector(7 downto 0);
	signal sram_addr_hi		: std_logic_vector(16 downto 12);
	
	-- video counter
	signal video_counter_cs	: std_logic;	
	
	-- banked signals
	signal bank_r					: std_logic_vector(3 downto 0);
	signal data_9_cs			: std_logic;
	signal data_9000			: std_logic_vector(7 downto 0);
	                        
  -- VRAM signals       
	signal vram0_cs				: std_logic;
  signal vram0_wr       : std_logic;
  signal vram0_data     : std_logic_vector(7 downto 0);

  -- RAM signals        
	signal wram_cs				: std_logic;
  signal wram_wr        : std_logic;
  alias wram_data      	: std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);

	signal intena_cs			: std_logic;
	signal intena_r				: std_logic;
		
	signal palette_cs			: std_logic;
	signal palette_wr			: std_logic;
	signal palette_r			: ByteArrayType(15 downto 0);
	
	signal dip2_cs				: std_logic;
	signal dip1_cs				: std_logic;
	signal in2_cs					: std_logic;
	signal in1_cs					: std_logic;
	signal in0_cs					: std_logic;
	
  -- other signals      
	signal inputs					: in8(0 to 3);  
	alias game_reset			: std_logic is inputs(3)(0);

begin

	gpio_o(16) <= clk_1M5_en;
	gpio_o(17) <= vblank;

	GEN_EXT_CLOCK : if DE2_USE_EXT_CPU generate
	
	clk_1M5_en <= gpio_i(30);
	
	end generate;

	-- cpu09 core uses negative clock edge
	clk_1M5_en_n <= not clk_1M5_en;

	-- add game reset later
	cpu_reset <= reset or game_reset;
	
  -- SRAM signals (may or may not be used)
  sram_o.a <= -- Graphics ROM starts at $10000 in 4KB banks - mapped to $9000
						EXT('1' & bank_r & cpu_addr(11 downto 0), sram_o.a'length) when data_9_cs = '1' else
						std_logic_vector(resize(unsigned(cpu_addr), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_data_o), sram_o.d'length));
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not wram_wr;
  sram_o.we <= wram_wr;

	-- memory chip selects
	-- ROM $A000-$BFFF,$C000-$FFFF
	rom_c_cs <= 	'1' when STD_MATCH(cpu_addr,  "11--------------") else '0';
	rom_a_cs <= 	'1' when STD_MATCH(cpu_addr,  "101-------------") else '0';
	-- banked area $9000-$9FFF
	data_9_cs <= 	'1' when STD_MATCH(cpu_addr, X"9"&"------------") else '0';
	-- RAM $8800-$8FFF
	wram_cs <=		'1' when STD_MATCH(cpu_addr, X"8"&"1-----------") else '0';
	-- Interrupt Enable $8200
	intena_cs <= 	'1' when STD_MATCH(cpu_addr, X"8200") else '0';
	-- DIPS1 $81E0
	dip1_cs <=		'1' when STD_MATCH(cpu_addr, X"81E"&"----") else '0';
	-- IN2 $81C0
	in2_cs <=			'1' when STD_MATCH(cpu_addr, X"81C"&"----") else '0';
	-- IN1 $81A0
	in1_cs <=			'1' when STD_MATCH(cpu_addr, X"81A"&"----") else '0';
	-- IN0 $8180
	in0_cs <=			'1' when STD_MATCH(cpu_addr, X"818"&"----") else '0';
	-- DIPS2 $8160
	dip2_cs <=		'1' when STD_MATCH(cpu_addr, X"816"&"----") else '0';
	-- Palette RAM $8000-$800F
	palette_cs <=	'1' when STD_MATCH(cpu_addr, X"800"      &"----") else '0';
	-- video ram $0000-$7FFF
	vram0_cs <=		'1' when STD_MATCH(cpu_addr,  "0---------------") else '0';

	-- video counter $C800-$CBFF
	video_counter_cs <=	'1' when STD_MATCH(cpu_addr, X"C"&"10----------") else '0';
	
	-- memory read mux
	cpu_data_i <= 	rom_c_data when rom_c_cs = '1' else
									rom_a_data when rom_a_cs = '1' else
									data_9000 when data_9_cs = '1' else
									wram_data when wram_cs = '1' else
									X"ff" when dip1_cs = '1' else
									inputs(2) when in2_cs = '1' else
									inputs(1) when in1_cs = '1' else
									inputs(0) when in0_cs = '1' else
									"11011011" when dip2_cs = '1' else
									vram0_data when vram0_cs = '1' else
									(others => '0');
	
	vram0_wr <= vram0_cs and not cpu_rw;
	palette_wr <= palette_cs and not cpu_rw;

	-- memory write enables
	process (clk_30M, clk_1M5_en)
	begin
		if rising_edge(clk_30M) then
			if clk_1M5_en = '1' then
				-- only write thru to WRAM
				wram_wr <= not cpu_rw and wram_cs;
			else
				wram_wr <= '0';
			end if;
		end if;
	end process;
		
	-- implementation of the banking register
	process (clk_30M, clk_1M5_en, cpu_reset)
		variable bank_offset_v : std_logic_vector(bank_r'range);
	begin
		if cpu_reset = '1' then
			bank_r <= (others => '0');
			sram_addr_hi <= (others => '0');
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			if cpu_rw = '0' and STD_MATCH(cpu_addr, X"8300") then
				bank_r <= cpu_data_o(bank_r'range);
			end if;
		end if;
	end process;
	
	-- implementation of scroll register
	process (clk_30M, clk_1M5_en)
	begin
		if reset = '1' then
			gfxextra_data <= (others => '0');
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			if cpu_rw = '0' and STD_MATCH(cpu_addr, X"8100") then
				gfxextra_data <= cpu_data_o;
			end if;
		end if;
	end process;
	
	-- implementation of palette RAM
	process (clk_30M, clk_1M5_en)
		variable offset : integer;
	begin
		if rising_edge(clk_30M) and clk_1M5_en = '1' then
			if palette_wr = '1' then
				offset := conv_integer(cpu_addr(3 downto 0));
				palette_r(offset) <= cpu_data_o;
			end if;
		end if;
		palette_data <= palette_r;
	end process;
	
	-- implementation of cpu interrupt enable register
	process (clk_30M, clk_1M5_en, cpu_reset)
	begin
		if cpu_reset = '1' then
			intena_r <= '0';
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			if intena_cs = '1' and cpu_rw = '0' then
        if cpu_data_o = X"00" then
  				intena_r <= '0';
        else
  				intena_r <= '1';
        end if;
			end if;
		end if;
	end process;
	
	-- vblank interrupt at 30Hz
	process (clk_30M, clk_1M5_en, vblank, reset)
		variable toggle_v 	: std_logic := '0';
		variable vblank_r		: std_logic_vector(2 downto 0) := (others => '0');
		alias vblank_prev 	: std_logic is vblank_r(vblank_r'left);
		alias vblank_unmeta : std_logic is vblank_r(vblank_r'left-1);
		subtype count_t is integer range 0 to 7;
		variable count			: count_t;
	begin
		if reset = '1' then
			toggle_v := '0';
			vblank_r := (others => '0');
			cpu_irq <= '0';
			count := 0;
		elsif rising_edge(clk_30M) and clk_1M5_en = '1' then
			-- detect rising edge of vblank
			if vblank_unmeta = '1' and vblank_prev = '0' then
				toggle_v := not toggle_v;
				if toggle_v = '1' then
					count := count_t'high;
				end if;
			elsif count /= 0 then
				count := count - 1;
			end if;
			-- shift vblank into unmeta pipeline
			vblank_r := vblank_r(vblank_r'left-1 downto 0) & vblank;
		end if;
		-- drive IRQ only every second VBLANK
		if count = 0 then
			cpu_irq <= '0';
		else
			cpu_irq <= intena_r and vblank_unmeta;
		end if;
	end process;

	-- cpu interrupts
	cpu_firq <= '0';
	cpu_nmi <= '0';

	xcentre <= (others => '0');
	ycentre <= (others => '0');
	
  -- unused outputs
	upaddr <= cpu_addr;
	updatao <= cpu_data_o;
	tilemapdatao <= (others => '0');
	tiledatao <= (others => '0');
  attr_dout <= X"00" & dip;
  sprite_reg_addr <= (others => '0');
  sprite_wr <= '0';
  spriteData <= (others => '0');
  snd_rd <= '0';
  snd_wr <= '0';
	spi_clk <= '0';
	spi_dout <= '0';
	spi_ena <= '0';
	spi_mode <= '0';
	spi_sel <= '0';
	ser_tx <= 'X';
	leds <= (others => '0');

	GEN_CLK_DIVISOR : if not DE2_USE_EXT_CPU generate

	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> TUTANKHAM_CPU_CLK_ENA_DIVIDE_BY
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset,
			clk_en		=> clk_1M5_en
		);
		
	end generate;
		
	--cpu_inst : entity work.cpu09
	--	port map
	--	(	
	--		clk				=> clk_1M5_en_n,
	--		rst				=> cpu_reset,
	--		rw				=> cpu_rw,
	--		vma				=> cpu_vma,
	--		address		=> cpu_addr,
	--	  data_in		=> cpu_data_i,
	--	  data_out	=> cpu_data_o,
	--		halt			=> '0',
	--		hold			=> '0',
	--		irq				=> cpu_irq,
	--		firq			=> cpu_firq,
	--		nmi				=> cpu_nmi
	--	);

  cpu_6809_q <= clk_1M5_en_n;
  cpu_6809_e <= '0'; -- tbd
  cpu_addr <= cpu_6809_a;
  cpu_6809_rst_n <= not cpu_reset;
  cpu_6809_halt_n <= '1';
  cpu_6809_tsc <= '0'; -- ???
  cpu_6809_nmi_n <= not cpu_nmi;
  cpu_6809_irq_n <= not cpu_irq;
  cpu_6809_firq_n <= not cpu_firq;
  cpu_rw <= cpu_6809_rw_n;
  --cpu_6809_ba
  --cpu_6809_bs
  --cpu_6809_busy
  --cpu_6809_lic
  cpu_vma <= cpu_6809_avma;
  cpu_6809_d_i <= cpu_data_i;
  cpu_data_o <= cpu_6809_d_o;

	inputs_inst : entity work.Inputs
		generic map
		(
			NUM_INPUTS	=> inputs'length,
			CLK_1US_DIV	=> TUTANKHAM_1MHz_CLK0_COUNTS
		)
	  port map
	  (
	    clk     		=> clk_30M,
	    reset   		=> reset,
	    ps2clk  		=> ps2clk,
	    ps2data 		=> ps2data,
			jamma				=> jamma,

	    dips				=> dip,
	    inputs			=> inputs
	  );

	GEN_SRAM_ROMS : if TUTANKHAM_ROMS_IN_SRAM generate

		rom_c_data	<= sram_i.d(rom_c_data'range);
		rom_a_data	<= sram_i.d(rom_a_data'range);
		data_9000 	<= sram_i.d(data_9000'range);
		
	end generate GEN_SRAM_ROMS;
	
	GEN_FPGA_ROMS : if not TUTANKHAM_ROMS_IN_SRAM generate
	
	rom_C000_inst : entity work.sprom
		generic map
		(
			init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & "roms/romC000.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clk_30M,
			address		=> cpu_addr(13 downto 0),
			q					=> rom_c_data
		);
	
	rom_A000_inst : entity work.sprom
		generic map
		(
			init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & "roms/romA000.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13
		)
		port map
		(
			clock			=> clk_30M,
			address		=> cpu_addr(12 downto 0),
			q					=> rom_a_data
		);
	
		rom_j1_inst : entity work.sprom
			generic map
			(
				init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & "roms/j1.hex",
				numwords_a	=> 4096,
				widthad_a		=> 12
			)
			port map
			(
				clock			=> clk_30M,
				address		=> cpu_addr(11 downto 0),
				q					=> data_9000
			);
		
	end generate GEN_FPGA_ROMS;
	
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram0_inst : entity work.dpram
		generic map
		(
			init_file		=> TUTANKHAM_SOURCE_ROOT_DIR & "roms/vram.hex",
			numwords_a	=> TUTANKHAM_VRAM_SIZE,
			widthad_a		=> TUTANKHAM_VRAM_WIDTHAD
		)
		port map
		(
			clock_b			=> clk_30M,
			address_b		=> cpu_addr(TUTANKHAM_VRAM_WIDTHAD-1 downto 0),
			wren_b			=> vram0_wr,
			data_b			=> cpu_data_o,
			q_b					=> vram0_data,

			clock_a			=> clk_40M,
			address_a		=> bitmap_addr(TUTANKHAM_VRAM_WIDTHAD-1 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> bitmap_data
		);

end SYN;
