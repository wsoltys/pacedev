library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

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

    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );
end entity platform;

architecture SYN of platform is

	alias clk_20M					: std_logic is clk_i(0);
	alias clk_video       : std_logic is clk_i(1);
	signal clk_2M_en			: std_logic;
	
  alias eurospi_clk     : std_logic is gp_i(P2A_EUROSPI_CLK);
  alias eurospi_miso    : std_logic is gp_o.d(P2A_EUROSPI_MISO);
  alias eurospi_mosi    : std_logic is gp_i(P2A_EUROSPI_MOSI);
  alias eurospi_ss      : std_logic is gp_i(P2A_EUROSPI_SS);

  signal vram_a         : std_logic_vector(9 downto 0) := (others => '0');
  signal vram_d_i       : std_logic_vector(7 downto 0) := (others => '0');
  signal vram_wr        : std_logic := '0';
  
begin

	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/coco3-becker/roms/coco3gen.hex",
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock			  => clk_video,
			address		  => tilemap_i.tile_a(10 downto 0),
			q           => tilemap_o.tile_d
		);
	
  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../src/platform/coco3-becker/boot/roms/vram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			clock_b			=> clk_20M,
			address_b		=> vram_a,
			wren_b			=> vram_wr,
			data_b			=> vram_d_i,
			q_b					=> open,
	
		  clock_a			=> clk_video,
			address_a		=> tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o.map_d(7 downto 0)
		);
    tilemap_o.map_d(tilemap_o.map_d'left downto 8) <= (others => '0');

  -- interboard spi
  -- - always the slave
  gp_o.oe(P2A_EUROSPI_CLK) <= '0';
  gp_o.oe(P2A_EUROSPI_MISO) <= '1';
  gp_o.oe(P2A_EUROSPI_MOSI) <= '0';
  gp_o.oe(P2A_EUROSPI_SS) <= '0';
  
  -- eurospi state machine
  BLK_EUROSPI : block
  
    constant UNMETA_DELAY   : natural := 2;
    
    -- unmeta pipeline registers
    signal spi_clk_r    : std_logic_vector(UNMETA_DELAY downto 0) := (others => '0');
    signal spi_mosi_r   : std_logic_vector(UNMETA_DELAY downto 0) := (others => '0');
    signal spi_ss_r     : std_logic_vector(UNMETA_DELAY downto 0) := (others => '0');
    
    -- previous values
    alias spi_clk_prev  : std_logic is spi_clk_r(spi_clk_r'left);
    alias spi_mosi_prev : std_logic is spi_mosi_r(spi_mosi_r'left);
    alias spi_ss_prev   : std_logic is spi_ss_r(spi_ss_r'left);
    
    -- unmeta'd values
    alias spi_clk       : std_logic is spi_clk_r(spi_clk_r'left-1);
    alias spi_mosi      : std_logic is spi_mosi_r(spi_mosi_r'left-1);
    alias spi_ss        : std_logic is spi_ss_r(spi_ss_r'left-1);
  
    signal sop_s        : std_logic := '0';   -- start-of-packet semaphore
    signal eop_s        : std_logic := '0';   -- end-of-packet semaphore
    signal eow_s        : std_logic := '0';   -- end of word semaphore

    constant SPI_W_SIZE : natural := 8;
    signal spi_d_i      : std_logic_vector(SPI_W_SIZE-1 downto 0) := (others => '0');
    
    -- packet process semaphores
    signal osd_video_s  : std_logic := '0';
    
  begin
  
    BLK_OSD_VIDEO : block
      type state_t is (IDLE, WAIT_WORD);
      signal state : state_t;
    begin
      process (clk_20M, reset_i)
      begin
        if reset_i = '1' then
          state <= IDLE;
          vram_a <= (others => '0');
          vram_d_i <= (others => '0');
          vram_wr <= '0';
        elsif rising_edge(clk_20M) then
          vram_wr <= '0';   -- default
          if eop_s = '1' then
            state <= IDLE;
          else
            case state is
              when IDLE =>
                vram_a <= (others => '0');
                if osd_video_s = '1' then
                  state <= WAIT_WORD;
                end if;
              when WAIT_WORD =>
                if eow_s = '1' then
                  -- write to video memory
                  vram_d_i <= spi_d_i(vram_d_i'range);
                  vram_wr <= '1';
                  -- increment memory address for next time
                  vram_a <= std_logic_vector(unsigned(vram_a) + 1);
                end if;
              when others =>
                state <= IDLE;
            end case;
          end if;
        end if;
      end process;
    end block BLK_OSD_VIDEO;
    
    BLK_PKT : block
      type state_t is (IDLE, WAIT_WORD, WAIT_EOP);
      signal state : state_t;
    begin
      -- pkt-receive process
      process (clk_20M, reset_i)
      begin
        if reset_i = '1' then
          osd_video_s <= '0';
        elsif rising_edge(clk_20M) then
          osd_video_s <= '0';   -- default
          if sop_s = '1' then
            state <= WAIT_WORD;
          else
            case state is
              when WAIT_WORD =>
                if eow_s = '1' then
                  if spi_d_i(2 downto 0) = "000" then
                    osd_video_s <= '1';
                  end if;
                  state <= WAIT_EOP;
                end if;
              when WAIT_EOP =>
                -- don't need to do anything here,
                -- as SM is reset on start-of-pkt
                null;
              when others =>
                state <= IDLE;
            end case;
          end if;
        end if;
      end process;
    
    end block BLK_PKT;
    
    BLK_BIT : block
      type state_t is (IDLE, SOW, WAIT_BIT);
      signal state : state_t;
    begin
      -- bit-receive process
      process (clk_20M, reset_i)
        variable count : integer range 0 to 7 := 0;
      begin
        if reset_i = '1' then
          state <= IDLE;
          sop_s <= '0';
          eop_s <= '0';
          eow_s <= '0';
        elsif rising_edge(clk_20M) then
          sop_s <= '0';   -- default
          eop_s <= '0';   -- default
          eow_s <= '0';   -- default
          if spi_ss_prev = '1' and spi_ss = '0' then
            sop_s <= '1';
            state <= SOW;
          elsif spi_ss = '1' then
            if spi_ss_prev = '0' then
              eop_s <= '1';
            end if;
            state <= IDLE;
          else
            case state is
              when SOW =>
                count := 0;
                state <= WAIT_BIT;
              when WAIT_BIT =>
                if spi_clk_prev = '1' and spi_clk = '0' then
                  spi_d_i <= spi_d_i(spi_d_i'left-1 downto 0) & spi_mosi;
                  if count = 7 then
                    eow_s <= '1';
                    state <= SOW;
                  else
                    count := count + 1;
                  end if;
                end if;
              when others =>
                state <= IDLE;
            end case;
          end if;
        end if;
      end process;
    end block BLK_BIT;
    
    -- eurospi signal unmeta
    process (clk_20M, reset_i)
    begin
      if reset_i = '1' then
        spi_clk_r <= (others => '0');
        spi_mosi_r <= (others => '0');
        spi_ss_r <= (others => '1');
      elsif rising_edge(clk_20M) then
        spi_clk_r <= spi_clk_r(spi_clk_r'left-1 downto 0) & eurospi_clk;
        spi_mosi_r <= spi_mosi_r(spi_mosi_r'left-1 downto 0) & eurospi_mosi;
        spi_ss_r <= spi_ss_r(spi_ss_r'left-1 downto 0) & eurospi_ss;
      end if;
    end process;

  end block BLK_EUROSPI;
  
  -- unused outputs
	bitmap_o <= NULL_TO_BITMAP_CTL;
	sprite_reg_o <= NULL_TO_SPRITE_REG;
	sprite_o <= NULL_TO_SPRITE_CTL;
  tilemap_o.attr_d <= std_logic_vector(resize(unsigned(switches_i(7 downto 0)), tilemap_o.attr_d'length));
	graphics_o <= NULL_TO_GRAPHICS;
	ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;

end architecture SYN;
