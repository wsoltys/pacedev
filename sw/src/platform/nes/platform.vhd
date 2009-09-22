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

end platform;

architecture SYN of platform is

	alias clk_21M28				: std_logic is clk_i(0);
	alias clk_video				: std_logic is clk_i(1);
	
	signal reset_n				: std_logic;
	
  -- uP signals  
  signal clk_1M77_en		: std_logic;
  signal up_addr        : std_logic_vector(23 downto 0);
	alias addr_bus				: std_logic_vector(15 downto 0) is up_addr(15 downto 0);
  signal up_datai       : std_logic_vector(7 downto 0);
  signal up_datao       : std_logic_vector(7 downto 0);
  signal up_rw_n				: std_logic;
  signal up_irq_n				: std_logic;
	signal up_nmi_n				: std_logic;
	                        
  -- ROM signals        
	signal prg_cs					: std_logic;
	signal prg_addr				: std_logic_vector(14 downto 0);
  signal prg_data      	: std_logic_vector(7 downto 0);
	signal chr_data				: std_logic_vector(7 downto 0);
		                        
	signal ppu_cs					: std_logic;
	signal ppu_wr					: std_logic;
	signal ppu_data				: std_logic_vector(7 downto 0);
	
  -- VRAM signals       
	signal vram_wr				: std_logic;
	signal aram_wr				: std_logic;
	signal vram_addr			: std_logic_vector(15 downto 0);
  signal vram_datai     : std_logic_vector(7 downto 0);
  signal vram_datao     : std_logic_vector(7 downto 0);
		                        
  -- RAM signals        
  signal wram_cs        : std_logic;
	signal wram_wr				: std_logic;
	signal wram_addr			: std_logic_vector(10 downto 0);
	signal wram_datao			: std_logic_vector(7 downto 0);

	signal joy_cs					: std_logic;
	signal joy_wr					: std_logic;
	signal joy_data				: std_logic_vector(7 downto 0);

	-- sprite DMA
	signal dma_cs					: std_logic;
	signal dma_wr					: std_logic;
	signal dma_addr				: std_logic_vector(15 downto 0);
	alias dma_count				: std_logic_vector(7 downto 0) is dma_addr(7 downto 0);
	signal up_rdy					: std_logic;

	-- DMC
	signal dmc_cs					: std_logic;
	signal dmc_wr					: std_logic;
	signal dmc_datao			: std_logic_vector(7 downto 0);
							
  -- keyboard signals
	signal joypad1				: std_logic_vector(23 downto 0);
	signal joypad2				: std_logic_vector(23 downto 0);
	alias cpu_reset				: std_logic is inputs_i(6).d(0);
	alias cpu_pause				: std_logic is inputs_i(6).d(1);

	signal game_reset			: std_logic;
	signal game_reset_n		: std_logic;
			
	type ppu_reg_t is array (natural range <>) of std_logic_vector(7 downto 0);
	signal ppu_reg 			: ppu_reg_t(7 downto 0);
	alias ppu_ctl1 			: std_logic_vector(7 downto 0) is ppu_reg(0);
	alias ppu_ctl2 			: std_logic_vector(7 downto 0) is ppu_reg(1);
	alias ppu_status 		: std_logic_vector(7 downto 0) is ppu_reg(2);
	alias ppu_sptmem_a 	: std_logic_vector(7 downto 0) is ppu_reg(3);
	alias ppu_sptmem_d 	: std_logic_vector(7 downto 0) is ppu_reg(4);
	alias ppu_bg_scroll	: std_logic_vector(7 downto 0) is ppu_reg(5);
	alias ppu_mem_a 		: std_logic_vector(7 downto 0) is ppu_reg(6);
	alias ppu_mem_d 		: std_logic_vector(7 downto 0) is ppu_reg(7);
	signal in_vblank		: std_logic;
	type pal_reg_t is array (natural range <>) of std_logic_vector(7 downto 0);
	signal ppu_pal			: pal_reg_t(31 downto 0);
	signal pal_wr				: std_logic;
	signal hscroll			: std_logic_vector(7 downto 0);
	signal vscroll			: std_logic_vector(7 downto 0);
		
	-- sprite "RAM"
	alias spr_addr			: std_logic_vector(7 downto 0) is ppu_reg(3);

	signal mirrored_vram_addr_10 		: std_logic;
	
begin

	reset_n <= not reset_i;
	game_reset <= reset_i or cpu_reset;
	game_reset_n <= not game_reset;

	-- SRAM signals always driven		
  sram_o.a <= std_logic_vector(resize(unsigned(wram_addr), sram_o.a'length));
  sram_o.d <= std_logic_vector(resize(unsigned(up_datao), sram_o.d'length));
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));

	-- WRAM $0000-$1FFF (mirrored 4 times)
	wram_cs <= 	'1' when STD_MATCH(addr_bus, "000-------------") else '0';
	-- PPU registers $2000-$3FFF (mirrored)
	ppu_cs <= 	'1' when STD_MATCH(addr_bus, "001-------------") else '0';
	dma_cs <=   '1' when STD_MATCH(addr_bus,            X"4014") else '0';
	-- DMC registers $4010-$4015
	-- don't worry about overlap with DMA yet...
	dmc_cs <=		'1' when STD_MATCH(addr_bus,    X"401" & "0---") else '0';
	-- JOYPAD ports $4016,$4017
	joy_cs <=   '1' when STD_MATCH(addr_bus,    X"401" & "011-") else '0';
	-- ROM $8000-$BFFF & $C000-$FFFF
  prg_cs <= 	'1' when STD_MATCH(addr_bus, "11--------------") else 
							'1' when STD_MATCH(addr_bus, "10--------------") else 
							'0';
	prg_addr <= addr_bus(14 downto 0);
	
	-- memory read mux
	uP_datai <=	wram_datao when wram_cs = '1' else
							ppu_data when ppu_cs = '1' else
							joy_data when joy_cs = '1' else
							-- DMC must come *after* JOY because of decode overlap
							dmc_datao when dmc_cs = '1' else
							prg_data when prg_cs = '1' else
							(others => '0');

	-- write enables
	wram_wr <= wram_cs and not up_rw_n;
	ppu_wr <= ppu_cs and not up_rw_n;
	dma_wr <= dma_cs and not up_rw_n;
	dmc_wr <= dmc_cs and not up_rw_n;
	joy_wr <= joy_cs and not up_rw_n;
	
	-- NMI generation
	up_nmi_n <= (not in_vblank) when ppu_ctl1(7) = '1' else '1';

	-- PPU registers
	process (clk_21M28, clk_1M77_en, reset_i)
		variable state_2005 	: std_logic;
		variable state_2006 	: std_logic;
		variable vram_buffer	: std_logic_vector(7 downto 0);
		variable vblank_r 		: std_logic_vector(3 downto 0);
		alias vblank_unmeta 	: std_logic is vblank_r(vblank_r'left-1);
		alias vblank_prev			: std_logic is vblank_r(vblank_r'left);
		variable spr0_hit_r		: std_logic;
		
	begin
		if reset_i = '1' then
			in_vblank <= '0';
			vram_wr <= '0';
			aram_wr <= '0';
			pal_wr <= '0';
			ppu_reg <= (others => (others => '0'));
			state_2005 := '0';
			state_2006 := '0';
			spr0_hit_r := '0';
		elsif rising_edge(clk_21M28) then
		
			-- handle vblank start/stop and sprite0-hit
			-- note: current 60Hz but will come from PPU later
			if vblank_prev = '0' and vblank_unmeta = '1' then
				in_vblank <= '1';
			elsif vblank_unmeta = '0' then
				if vblank_prev = '1' then
					spr0_hit_r := '0';
				end if;
				if spr0_hit = '1' then
					spr0_hit_r := '1';
				end if;
				in_vblank <= '0';
			end if;

			if clk_1M77_en = '1' then

				-- post-increment address
				if vram_wr = '1' or pal_wr = '1' then
					if ppu_ctl1(2) = '1' then
						vram_addr <= vram_addr + 32;
					else
						vram_addr <= vram_addr + 1;
					end if;
				end if;
				
				-- defaults
				vram_wr <= '0';
				aram_wr <= '0';
				pal_wr <= '0';
												
				if ppu_cs = '1' then
					if ppu_wr = '0' then
						-- read register value
						if addr_bus(2 downto 0) = "010" then
							-- PPU STATUS
							ppu_data <= in_vblank & spr0_hit_r & "000000";
						elsif addr_bus(2 downto 0) = "111" then
							-- VRAM DATA
							-- - a quirk in the PPU
							--   the 1st read after setting the address doesn't work
							ppu_data <= vram_buffer;
							vram_buffer := vram_datao;
						else
							ppu_data <= ppu_reg(conv_integer(addr_bus(2 downto 0)));
						end if;
						-- side-effects
						case addr_bus(2 downto 0) is
							when "010" =>
								in_vblank <= '0';		-- reset flag
								state_2005 := '0';
								state_2006 := '0';
							when others =>
								null;
						end case;
					else
						-- always write registers
						ppu_reg(conv_integer(addr_bus(2 downto 0))) <= up_datao;
						-- side-effects
						case addr_bus(2 downto 0) is
							when "101" =>
								if state_2005 = '0' then
									-- horizontal
									hscroll <= up_datao;
								else
									-- vertical
									vscroll <= up_datao;
								end if;
								state_2005 := not state_2005;
							when "100" =>
								-- write sprite memory
								-- TBA
								-- increment address
								spr_addr <= spr_addr + 1;
							when "110" =>
								-- write VRAM address
								if state_2006 = '0' then
									vram_addr(15 downto 8) <= up_datao;	-- high byte
								else
									vram_addr(7 downto 0) <= up_datao;	-- low byte
								end if;
								state_2006 := not state_2006;
							when "111" =>
								-- write to VRAM
								if vram_addr(15 downto 12) = X"2" then
									-- PPU name tables
									vram_datai <= up_datao;
									vram_wr <= '1';
									-- shadow write to ARAM $3C0-$3FF/$7C0-$7FF/$BC0-$BFF/$FC0-$FFF
									if vram_addr(9 downto 6) = "1111" then
										aram_wr <= '1';
									end if;
								elsif vram_addr(15 downto 8) = X"3F" then
									-- palette register
									ppu_pal(conv_integer(vram_addr(4 downto 0))) <= up_datao;
									pal_wr <= '1';
								end if;
							when others =>
								null;
						end case;
					end if;
				end if;
			end if; -- clk_1M77_en = '1'
			vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
		end if; -- rising_edge()
	end process;

  sprite_reg_o.clk <= clk_21M28;
  sprite_reg_o.clk_ena <= clk_1M77_en;
  
	-- (sprite) DMA
	process (clk_21M28, clk_1M77_en, reset_i)
		variable dip			: std_logic := '0';
		variable state		: std_logic := '0';
		variable dma_data	: std_logic_vector(7 downto 0) := (others => '0');
	begin
		if reset_i = '1' then
			dip := '0';
			state := '0';
		elsif rising_edge(clk_21M28) then
			if clk_1M77_en = '1' then
				-- defaults
				sprite_reg_o.wr <= '0';
				if dip = '0' then
					if dma_wr = '1' then
						dma_addr(15 downto 8) <= up_datao;
						dma_count <= (others => '0');
						-- start the DMA
						dip := '1';
						state := '0';
					end if; -- dma_wr = '1'
				else
					if state = '0' then
						-- fetch from cpu RAM
						dma_data := wram_datao;
					else
						-- external sprite registers
						sprite_reg_o.a <= dma_count;
						sprite_reg_o.d <= dma_data;
						sprite_reg_o.wr <= '1';
						if dma_count = X"FF" then
							dip := '0';
						else
							dma_count <= dma_count + 1;
						end if;
					end if;
					state := not state;
				end if; -- dip
			end if; -- clk_1M77_en = '1'
		end if; -- rising_edge(clk_21M28)
		-- drive 6502 RDY input
		up_rdy <= not (dip or cpu_pause);
	end process;

	-- controller inputs
	process (clk_21M28, clk_1M77_en, reset_i)
		variable joy_reset : std_logic;
	begin
		if reset_i = '1' then
			joy_reset := '0';
		elsif rising_edge(clk_21M28) then
			if clk_1M77_en = '1' then
				if joy_cs = '1' then
					if joy_wr = '0' then
						-- read from joy port
						if joy_reset = '0' then
							if up_addr(0) = '0' then
								joypad1 <= '0' & joypad1(joypad1'left downto 1);
							else
								joypad2 <= '0' & joypad2(joypad2'left downto 1);
							end if;
						end if;
					else
						-- write to joy port $4016
						if up_addr(0) = '0' then
							-- latch joypad values on 1->0 transition of bit 0
							if joy_reset = '1' and up_datao(0) = '0' then
								joypad1 <= inputs_i(2).d & inputs_i(1).d & inputs_i(0).d;
								joypad2 <= inputs_i(5).d & inputs_i(4).d & inputs_i(3).d;
							end if;
							joy_reset := up_datao(0);
						end if; -- $4016
					end if; -- write to joy port
				end if; -- joy_cs = '1'
			end if; -- clk_1M77_en = '1'
		end if; -- rising_edge(clk_21M28)
	end process;
	
	joy_data(7 downto 1) <= "0001000";
	joy_data(0) <= joypad1(0) when up_addr(0) = '0' else joypad2(0);

	-- DMC
	process (clk_21M28, clk_1M77_en, reset_i)
		variable length_cnt : std_logic_vector(7 downto 0) := (others => '0');
		variable dmc_mode		: std_logic_vector(1 downto 0) := "00";
		variable dmc_en			: std_logic := '0';
		variable dmc_irq		: std_logic := '0';
	begin
		if reset_i = '1' then
			dmc_en := '0';
			dmc_irq := '0';
		elsif rising_edge(clk_21M28) then
			if clk_1M77_en = '1' then
				if dmc_cs = '1' then
					if dmc_wr = '0' then
						-- reading from DMC registers
						case addr_bus(2 downto 0) is
							-- $4015 is the only R/W register
							when "101" =>
								dmc_datao <= dmc_irq & "00" & dmc_en & "0000";
							when others =>
								null;
						end case;
					else
						-- writing to DMC registers
						case addr_bus(2 downto 0) is
							when "000" =>
								dmc_mode := up_datao(7 downto 6);
								if up_datao(7) = '0' then
									dmc_irq := '0';
								end if;
							when "011" =>
								length_cnt := up_datao;
							when "101" =>
								dmc_en := up_datao(4);
								dmc_irq := '0';
							when others =>
								null;
						end case;
					end if;
				else
					-- not a register access
					-- - simulate playing a sound...
					-- - don't worry about non-IRQ looping yet...
					if dmc_en = '1' then
						if length_cnt /= 0 then
							length_cnt := length_cnt - 1;
							if length_cnt = 0 and dmc_mode(1) = '1' then
								dmc_irq := '1';
							end if;
						end if;
					end if;
				end if; -- dmc_cs = '1'
			end if; -- clk_1M77_en = '1'
		end if; -- rising_edge(clk_21M28)
		-- drive interrupt outputs
		up_irq_n <= not dmc_irq;
	end process;
	
	GEN_PAL : for i in 15 downto 0 generate
		-- only do tile palette for now
		graphics_o.pal(i) <= std_logic_vector(resize(unsigned(ppu_pal(i)),graphics_o.pal(i)'length));
	end generate GEN_PAL;
	
  --
  -- COMPONENT INSTANTIATION
  --

	-- generate CPU clock enable (1.77MHz from 21.28MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> 12
		)
		port map
		(
			clk				=> clk_21M28,
			reset			=> reset_i,
			clk_en		=> clk_1M77_en
		);

	up_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> game_reset_n,
			Enable  		=> clk_1M77_en,
			Clk     		=> clk_21M28,
			Rdy     		=> up_rdy,
			Abort_n 		=> '1',
			IRQ_n   		=> up_irq_n,
			NMI_n   		=> up_nmi_n,
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

	GEN_INTERNAL_WRAM : if NES_USE_INTERNAL_WRAM generate

		cpu_ram_inst : ENTITY work.spram
			GENERIC map
			(
				numwords_a	=> 2048,
				widthad_a		=> 11
			)
			PORT map
			(
				clock			=> clk_21M28,
				address		=> wram_addr,
				data			=> up_datao,
				wren			=> wram_wr,
				q					=> wram_datao
			);

	  -- SRAM signals (not used)
	  sram_o.cs <= '0';
	  sram_o.oe <= '0';
	  sram_o.we <= '0';

	end generate GEN_INTERNAL_WRAM;
	
	GEN_EXTERNAL_WRAM : if not NES_USE_INTERNAL_WRAM generate
	  sram_o.cs <= wram_cs;
	  sram_o.oe <= wram_cs and up_rw_n;
	  sram_o.we <= wram_wr;
		wram_datao <= sram_i.d(wram_datao'range);
	end generate GEN_EXTERNAL_WRAM;
		
	wram_addr <= 	addr_bus(10 downto 0) when up_rdy = '1' else
								dma_addr(10 downto 0);

	ppu_ram_inst : entity work.dpram
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		generic map
		(
			init_file		=> "../../../../src/platform/nes/rams/vram.hex",
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock_b			=> clk_21M28,
			address_b(10)					=> mirrored_vram_addr_10,
			address_b(9 downto 0)	=> vram_addr(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> vram_datai,
			q_b					=> vram_datao,

			clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(10 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
	tilemap_o.map_d(15 downto 8) <= (others => '0');
	--
	-- *** this actually depends on the cart wiring
	--
	GEN_VERTICAL_MIRRORING : if NES_MIRROR_VERTICAL generate
		-- eg. Super Mario Bros.
		mirrored_vram_addr_10 <= vram_addr(10);
		-- only valid for horizontally scrolling games
  	graphics_o.bit8_1 <= hscroll;
	end generate GEN_VERTICAL_MIRRORING;
	
	GEN_HORIZONTAL_MIRRORING : if NES_MIRROR_HORIZONTAL generate
		-- eg. Wrecking Crew
		mirrored_vram_addr_10 <= vram_addr(11);
		-- only valid for vertically scrolling games
  	graphics_o.bit8_1 <= vscroll;
	end generate GEN_HORIZONTAL_MIRRORING;

	-- this one block contains attribute RAM for *both* internal tables		
	ppu_attr_inst : entity work.dpram
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		generic map
		(
			init_file		=> "../../../../src/platform/nes/rams/aram.hex",
			numwords_a	=> 128,
			widthad_a		=> 7
		)
		port map
		(
			clock_b								=> clk_21M28,
			address_b(6)					=> mirrored_vram_addr_10,
			address_b(5 downto 0)	=> vram_addr(5 downto 0),
			wren_b								=> aram_wr,
			data_b								=> vram_datai,
			q_b										=> open,

			clock_a								=> clk_video,
			address_a(6)					=> tilemap_i.attr_a(6),
			address_a(5 downto 0)	=> tilemap_i.attr_a(5 downto 0),
			wren_a								=> '0',
			data_a								=> (others => 'X'),
			q_a										=> tilemap_o.attr_d(7 downto 0)
		);
	-- fudge - pass PPU CTL1 register value to MAPCTL
	tilemap_o.attr_d(15 downto 8) <= ppu_ctl1;
		
	prg_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/nes/carts/" & NES_CART_NAME & "_prg.hex",
			numwords_a	=> 32768,
			widthad_a		=> 15
		)
		port map
		(
			clock			=> clk_21M28,
			address		=> prg_addr(14 downto 0),
			q					=> prg_data
		);
	
	chr_rom_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/nes/carts/" & NES_CART_NAME & "_chr.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13,
			width_b			=> 16,
			numwords_b	=> 4096,
			widthad_b		=> 12
		)
		port map
		(
			clock				=> clk_video,
			
			-- tilemap i/f
			address_a		=> tilemap_i.tile_a(12 downto 0),
			q_a					=> tilemap_o.tile_d,
			
			-- sprite i/f
			address_b		=> sprite_i.a(11 downto 0),
			q_b(15 downto 8)	=> sprite_o.d(23 downto 16),
			q_b(7 downto 0)		=> sprite_o.d(31 downto 24)
		);
	-- fudge 8-pixel wide sprite
	sprite_o.d(15 downto 0) <= (others => '0');

  -- unused outputs
  flash_o <= NULL_TO_FLASH;
	bitmap_o.d <= (others => '0');
	graphics_o.bit16_1 <= (others => '0');
	osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
	spi_o <= NULL_TO_SPI;
	ser_o <= NULL_TO_SERIAL;
	leds_o <= std_logic_vector(resize(unsigned(inputs_i(0).d),leds_o'length));
	
end SYN;
