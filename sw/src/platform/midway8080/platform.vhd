library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;

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
    sdram_o        : out to_SDRAM_t;


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

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );
end entity platform;

architecture SYN of platform is

	alias clk_24M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	
  -- uP signals  
  signal clk_2M_en			: std_logic;
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
	alias io_addr					: std_logic_vector(7 downto 0) is uP_addr(7 downto 0);
	                        
  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_datao      : std_logic_vector(7 downto 0);
	signal rom2_cs				: std_logic;                        
	signal rom2_datao			: std_logic_vector(7 downto 0);
	
  -- VRAM signals       
	signal vram_cs				: std_logic;
  signal vram_wr        : std_logic;
  signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_wr        : std_logic;
  signal wram_datao     : std_logic_vector(7 downto 0);

	-- IO signals
	signal port_cs				: std_logic_vector(5 downto 0);
	signal port_wr				: std_logic_vector(5 downto 2);
	alias game_reset			: std_logic is inputs_i(2).d(0);
	signal shift_dout			: std_logic_vector(7 downto 0);

  -- other signals      
	signal cpu_reset			: std_logic;
  signal uPmem_datai    : std_logic_vector(7 downto 0);
  signal uPio_datai     : std_logic_vector(7 downto 0);
  
	signal bitmap_addr_rotated	: std_logic_vector(12 downto 0);
	
begin

	cpu_reset <= reset_i or game_reset;
	
  -- read mux
  uP_datai <= uPmem_datai when (uPmemrd = '1') else uPio_datai;

	GEN_EXTERNAL_WRAM : if not INVADERS_USE_INTERNAL_WRAM generate
	
	  -- SRAM signals (may or may not be used)
	  sram_o.a <= std_logic_vector(resize(unsigned(uP_addr), sram_o.a'length));
	  sram_o.d <= std_logic_vector(resize(unsigned(uP_datao), sram_o.d'length));
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	  sram_o.cs <= wram_cs;
	  sram_o.oe <= not wram_wr;
	  sram_o.we <= wram_wr;
		wram_datao <= sram_i.d(wram_datao'range);

	end generate GEN_EXTERNAL_WRAM;

	GEN_NO_SRAM : if INVADERS_USE_INTERNAL_WRAM generate
    sram_o <= NULL_TO_SRAM;
	end generate GEN_NO_SRAM;
	
	-- memory chip selects
	-- ROM $0000-$1FFF
	rom_cs <= '1' when uP_addr(14 downto 13) = "00" else '0';
	-- WRAM $2000-$23FF
	wram_cs <= '1' when uP_addr(14 downto 10) = "01000" else '0';
	-- VRAM $2400-$3FFF
	vram_cs <= '1' when uP_addr(14 downto 13) = "01" and uP_addr(12 downto 10) /= "000" else '0';
	-- ROM2 $4000-$5FFF
	rom2_cs <= '1' when uP_addr(14 downto 13) = "10" else '0';

	-- memory write enables
	vram_wr <= vram_cs and uPmemwr;
	wram_wr <= wram_cs and uPmemwr;

	-- I/O chip selects
	-- inputs port 0
	port_cs(0) <= '1' when uP_addr(2 downto 0) = "000" else '0';
	-- inputs port 1
	port_cs(1) <= '1' when uP_addr(2 downto 0) = "001" else '0';
	-- number of bits to shift ($2)
	port_cs(2) <= '1' when uP_addr(2 downto 0) = "010" else '0';
	-- sound reg #1 ($3)
	port_cs(3) <= '1' when uP_addr(2 downto 0) = "011" else '0';
	-- shifter data ($4)
	port_cs(4) <= '1' when uP_addr(2 downto 0) = "100" else '0';
	-- sound reg #2 ($5)
	port_cs(5) <= '1' when uP_addr(2 downto 0) = "101" else '0';

	-- io write enables
	port_wr(2) <= port_cs(2) and uPiowr;
	port_wr(3) <= port_cs(3) and uPiowr;
	port_wr(4) <= port_cs(4) and uPiowr;
	port_wr(5) <= port_cs(5) and uPiowr;

	-- sound interface
	snd_o.rd <= (port_cs(3) or port_cs(5)) and uPiord; -- not used
	snd_o.wr <= (port_cs(3) or port_cs(5)) and uPiowr;
  snd_o.d <= up_datao;
  snd_o.a <= up_addr(snd_o.a'range);
  
	-- memory read mux
	uPmem_datai <= 	rom_datao when rom_cs = '1' else
									wram_datao when wram_cs = '1' else
									vram_datao when vram_cs = '1' else
									rom2_datao when rom2_cs = '1' else
									(others => '1');
	
	-- io read mux
	uPio_datai <= X"40" when port_cs(0) = '1' else
								inputs_i(0).d when port_cs(1) = '1' else
								inputs_i(1).d when port_cs(2) = '1' else
								shift_dout when port_cs(3) = '1' else
								X"00";

	-- shifter block
	process (clk_24M, reset_i)
		variable shift_din	: std_logic_vector(15 downto 0);
		variable shift_amt 	: std_logic_vector(2 downto 0);
		variable wr2_r 			: std_logic := '0';
		variable wr4_r 			: std_logic := '0';
	begin
		if reset_i = '1' then
			wr2_r := '0';
			wr4_r := '0';
		elsif rising_edge(clk_24M) then
			-- latch on rising edge of WR to port 2 (shift_amt)
			if port_wr(2) = '1' and wr2_r = '0' then
				shift_amt := uP_datao(2 downto 0);
			-- latch on rising edge of WR to port 4 (shift_din)
			elsif port_wr(4) = '1' and wr4_r = '0' then
				shift_din := uP_datao & shift_din(15 downto 8);
			end if;
			wr2_r := port_wr(2);
			wr4_r := port_wr(4);
		end if;

		-- combinatorial logic
    case shift_amt(2 downto 0) is
	    when "000" =>
		    shift_dout <= shift_din(15 downto 8);
		    when "001" =>
		    shift_dout <= shift_din(14 downto 7);
	    when "010" =>
		    shift_dout <= shift_din(13 downto 6);
	    when "011" =>
		    shift_dout <= shift_din(12 downto 5);
	    when "100" =>
		    shift_dout <= shift_din(11 downto 4);
	    when "101" =>
		    shift_dout <= shift_din(10 downto 3);
	    when "110" =>
		    shift_dout <= shift_din(9 downto 2);
	    when "111" =>
		    shift_dout <= shift_din(8 downto 1);
	    when others =>
    end case;

	end process;

	INT_BLOCK : block
	
		constant RST08 : std_logic_vector(7 downto 0) := X"CF";
		constant RST10 : std_logic_vector(7 downto 0) := X"D7";
	
	begin

		process (clk_24M, cpu_reset)
			-- based on 24MHz input clock
			subtype count_60Hz_t is integer range 0 to 399999;
			variable count : count_60Hz_t;
		begin
			if cpu_reset = '1' then
				uPintreq <= '0';
				count := 0;
			elsif rising_edge(clk_24M) then
				-- generate interrupt
				count := count + 1;
				if count = count_60Hz_t'high/2 then
					uPintreq <= '1';
					uPintvec <= RST08;
				elsif count = count_60Hz_t'high then
					count := 0;
					uPintreq <= '1';
					uPintvec <= RST10;
				-- clear interrupt
				elsif uPintack = '1' then
					uPintreq <= '0';
				end if;
			end if;
		end process;

	end block INT_BLOCK;	

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
      if inputs_i(2).d(1) = '1' and osd_key_r = '0' then
        osd_en_v := not osd_en_v;
      end if;
      osd_key_r := inputs_i(2).d(1);
    end if;
    osd_o.en <= osd_en_v;
  end process;

	-- old vram mapper logic
  bitmap_addr_rotated(4 downto 0) <= not bitmap_i.a(12 downto 8);
  bitmap_addr_rotated(12 downto 5) <= bitmap_i.a(7 downto 0) + 32;

	-- this will probably require adjustment
	--xcentre <= std_logic_vector(conv_unsigned(0, xcentre'length));
	--ycentre <= std_logic_vector(conv_unsigned(198, ycentre'length));

  -- unused outputs

  graphics_o <= NULL_TO_GRAPHICS;
  tilemap_o <= NULL_TO_TILEMAP_CTL;
  sprite_reg_o <= NULL_TO_SPRITE_REG;
  sprite_o <= NULL_TO_SPRITE_CTL;
  --osd_o <= NULL_TO_OSD;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
	leds_o <= (others => '0');
  gp_o <= NULL_TO_GP;
  
	-- generate CPU clock (2MHz from 20MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> integer(INVADERS_CPU_CLK_ENA_DIVIDE_BY)
		)
		port map
		(
			clk				=> clk_24M,
			reset			=> reset_i,
			clk_en		=> clk_2M_en
		);
		
  U_uP : entity work.Z80                                                
    port map
    (
      clk			=> clk_24M,                                   
      clk_en	=> clk_2M_en,
      reset  	=> cpu_reset,                                     

      addr   	=> uP_addr,
      datai  	=> uP_datai,
      datao  	=> uP_datao,

      mem_rd 	=> uPmemrd,
      mem_wr 	=> uPmemwr,
      io_rd  	=> uPiord,
      io_wr  	=> uPiowr,

      intreq 	=> uPintreq,
      intvec 	=> uPintvec,
      intack 	=> uPintack,
      nmi    	=> '0'
    );

  GEN_INTERNAL_ROM : if not INVADERS_ROM_IN_FLASH generate
    rom_inst : entity work.invaders_rom
      port map
      (
        clock		=> clk_24M,
        address => uP_addr(12 downto 0),
        q				=> rom_datao
      );
  end generate GEN_INTERNAL_ROM;

  GEN_FLASH_ROM : if INVADERS_ROM_IN_FLASH generate

    process (clk_24M, reset_i, clk_2M_en)
    begin
      if reset_i = '1' then
        null;
      elsif rising_edge (clk_24M) then
        -- 70ns flash - update address and latch every 500ns
        if clk_2M_en = '1' then
          flash_o.a <= std_logic_vector(resize(unsigned(uP_addr(12 downto 0)), flash_o.a'length));
          rom_datao <= flash_i.d;
        end if;
      end if;
    end process;

  end generate GEN_FLASH_ROM;
  
  GEN_NO_FLASH_ROM : if not INVADERS_ROM_IN_FLASH generate
    flash_o.a <= (others => '0');
  end generate GEN_NO_FLASH_ROM;

  flash_o.d <= (others => 'Z');
  flash_o.we <= '0';
  flash_o.cs <= '1';
  flash_o.oe <= '1';

	GEN_ROM2 : if ROM_2_NAME /= "" generate
		rom2_inst : entity work.invaders_rom_2
	    port map
	    (
        clock		=> clk_24M,
        address => uP_addr(11 downto 0),
        q				=> rom2_datao
	    );
	end generate GEN_ROM2;
  
  GEN_NO_ROM2 : if ROM_2_NAME = "" generate
    rom2_datao <= (others => '0');
  end generate GEN_NO_ROM2;

		--
		--	*** WARNING - the contents of the VRAM are offset!!!
		--							- the video won't look right!!!!
		--
		
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		vram_inst : entity work.vram
	    port map
	    (
	        clock_b   	=> clk_24M,
	        address_b   => uP_addr(12 downto 0),
	        data_b      => uP_datao,
	        q_b					=> vram_datao,
	        wren_b			=> vram_wr,

	        clock_a     => clk_video,
	        address_a   => bitmap_addr_rotated,
      		data_a      => (others => '0'),
	        q_a					=> bitmap_o.d,
      		wren_a			=> '0'
	    );

		GEN_INTERNAL_WRAM : if INVADERS_USE_INTERNAL_WRAM generate
		
			wram_inst : entity work.wram
				port map
				(
					clock				=> clk_24M,
					address			=> uP_addr(9 downto 0),
					data				=> up_datao,
					wren				=> wram_wr,
					q						=> wram_datao
				);
		
		end generate GEN_INTERNAL_WRAM;
		
end SYN;
