library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity OSD is
  generic
  (
    DUMMY           : std_logic := '0'
  );
  port
  (
    clk             : in std_logic;
    clk_20M_ena     : in std_logic;
    reset           : in std_logic;

    osd_keys        : in std_logic_vector(7 downto 0);

    -- video in
    vid_clk         : in std_logic;
    vid_hsync       : in std_logic;
    vid_vsync       : in std_logic;
    vid_r_i         : in std_logic_vector(9 downto 0);
    vid_g_i         : in std_logic_vector(9 downto 0);
    vid_b_i         : in std_logic_vector(9 downto 0);
    
    -- video out
    vid_r_o         : out std_logic_vector(9 downto 0);
    vid_g_o         : out std_logic_vector(9 downto 0);
    vid_b_o         : out std_logic_vector(9 downto 0);
    
    -- SPI ports
    eurospi_clk     : in std_logic;
    eurospi_miso    : out std_logic;
    eurospi_mosi    : in std_logic;
    eurospi_ss      : in std_logic
  );
end entity OSD;

architecture SYN of OSD is

  signal vram_a         : std_logic_vector(9 downto 0) := (others => '0');
  signal vram_d_i       : std_logic_vector(7 downto 0) := (others => '0');
  signal vram_wr        : std_logic := '0';
  
begin

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
    alias spi_miso      : std_logic is eurospi_miso;
    alias spi_mosi      : std_logic is spi_mosi_r(spi_mosi_r'left-1);
    alias spi_ss        : std_logic is spi_ss_r(spi_ss_r'left-1);
  
    signal sop_s        : std_logic := '0';   -- start-of-packet semaphore
    signal eop_s        : std_logic := '0';   -- end-of-packet semaphore
    signal eow_s        : std_logic := '0';   -- end of word semaphore

    constant SPI_W_SIZE : natural := 8;
    signal spi_d_i      : std_logic_vector(SPI_W_SIZE-1 downto 0) := (others => '0');
    signal spi_d_o      : std_logic_vector(SPI_W_SIZE-1 downto 0) := (others => '0');
    
    -- packet process semaphores
    signal osd_video_s  : std_logic := '0';
    signal ps2_keys_s   : std_logic := '0';
    
  begin
  
    BLK_PS2_KEYS : block
      type state_t is (IDLE, SET_BYTE, WAIT_WORD);
      signal state : state_t;
    begin
      process (clk, reset)
      begin
        if reset = '1' then
          state <= IDLE;
        elsif rising_edge(clk) and clk_20M_ena = '1' then
          if eop_s = '1' then
            state <= IDLE;
          else
            case state is
              when IDLE =>
                if ps2_keys_s = '1' then
                  state <= WAIT_WORD;
                end if;
              when SET_BYTE =>
                -- row six of the TRS-80 keyboard
                spi_d_o <= osd_keys;
                state <= WAIT_WORD;
              when WAIT_WORD =>
                if eow_s = '1' then
                  state <= SET_BYTE;
                end if;
              when others =>
                state <= IDLE;
            end case;
          end if;
        end if;
      end process;
    end block BLK_PS2_KEYS;
    
    BLK_OSD_VIDEO : block
      type state_t is (IDLE, WAIT_WORD, WR_CHAR);
      signal state : state_t;
    begin
      process (clk, reset)
      begin
        if reset = '1' then
          state <= IDLE;
          vram_a <= (others => '0');
          vram_d_i <= (others => '0');
          vram_wr <= '0';
        elsif rising_edge(clk) and clk_20M_ena = '1' then
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
                  state <= WR_CHAR;
                end if;
              when WR_CHAR =>
                -- increment memory address for next time
                vram_a <= std_logic_vector(unsigned(vram_a) + 1);
                state <= WAIT_WORD;
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
      process (clk, reset)
      begin
        if reset = '1' then
          osd_video_s <= '0';
        elsif rising_edge(clk) and clk_20M_ena = '1' then
          osd_video_s <= '0';   -- default
          if sop_s = '1' then
            state <= WAIT_WORD;
          else
            case state is
              when WAIT_WORD =>
                if eow_s = '1' then
                  if spi_d_i(3 downto 0) = X"1" then
                    osd_video_s <= '1';
                  elsif spi_d_i(3 downto 0) = X"2" then
                    ps2_keys_s <= '1';
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
      type state_t is (IDLE, SOW, WAIT_SETUP, WAIT_BIT);
      signal state    : state_t;
      signal spi_d_r  : std_logic_vector(spi_d_o'range) := (others => '0');
    begin
      -- bit-send-and-receive process
      process (clk, reset)
        variable count      : integer range 0 to 7 := 0;
      begin
        if reset = '1' then
          state <= IDLE;
          sop_s <= '0';
          eop_s <= '0';
          eow_s <= '0';
        elsif rising_edge(clk) and clk_20M_ena = '1' then
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
                -- latch output data
                spi_d_r <= spi_d_o;
                state <= WAIT_SETUP;
              when WAIT_SETUP =>
                -- rising edge clk, setup data
                if spi_clk_prev = '0' and spi_clk = '1' then
                  spi_miso <= spi_d_r(spi_d_r'left);
                  spi_d_r <= spi_d_r(spi_d_r'left-1 downto 0) & '0';
                  state <= WAIT_BIT;
                end if;
              when WAIT_BIT =>
                -- falling edge clock, read data
                if spi_clk_prev = '1' and spi_clk = '0' then
                  spi_d_i <= spi_d_i(spi_d_i'left-1 downto 0) & spi_mosi;
                  if count = 7 then
                    eow_s <= '1';
                    state <= SOW;
                  else
                    count := count + 1;
                    state <= WAIT_SETUP;
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
    process (clk, reset)
    begin
      if reset = '1' then
        spi_clk_r <= (others => '0');
        spi_mosi_r <= (others => '0');
        spi_ss_r <= (others => '1');
      elsif rising_edge(clk) and clk_20M_ena = '1' then
        spi_clk_r <= spi_clk_r(spi_clk_r'left-1 downto 0) & eurospi_clk;
        spi_mosi_r <= spi_mosi_r(spi_mosi_r'left-1 downto 0) & eurospi_mosi;
        spi_ss_r <= spi_ss_r(spi_ss_r'left-1 downto 0) & eurospi_ss;
      end if;
    end process;

  end block BLK_EUROSPI;
  
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
			clock_b			=> clk,
			address_b		=> vram_a,
			wren_b			=> vram_wr,
			data_b			=> vram_d_i,
			q_b					=> open,
	
		  clock_a			=> '0', --clk_video,
			address_a		=> (others => '0'), --tilemap_i.map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => '0'),
			q_a					=> open --tilemap_o.map_d(7 downto 0)
		);

  BLK_VIDEO : block
  
    signal vid_y  : std_logic_vector(11 downto 0) := (others => '0');
    signal vid_x  : std_logic_vector(11 downto 0) := (others => '0');
    
  begin
  
    process (vid_clk, reset)
    begin
      if reset = '1' then
        vid_x <= (others => '0');
        vid_y <= (others => '0');
      elsif rising_edge(vid_clk) then
        if vid_vsync = '1' then
          vid_y <= (others => '0');
        elsif vid_hsync = '1' then
          vid_x <= (others => '0');
          vid_y <= std_logic_vector(unsigned(vid_y) + 1);
        else
          vid_x <= std_logic_vector(unsigned(vid_x) + 1);
        end if;
      end if;
    end process;

    process (vid_clk, reset)
    begin
      if reset = '1' then
      elsif rising_edge(vid_clk) then
        if  unsigned(vid_y) > 100 and unsigned(vid_y) < 200 and 
            unsigned(vid_x) > 100 and unsigned(vid_x) < 200 then
          vid_r_o <= (others => '0');
          vid_b_o <= (others => '0');
          vid_g_o <= (others => '0');
        else
          vid_r_o <= (others => '1'); --vid_r_i;
          vid_b_o <= vid_b_i;
          vid_g_o <= vid_g_i;
        end if;
      end if;
    end process;
    
  end block BLK_VIDEO;
  
end architecture SYN;
