--------------------------------------------------------------------------------
-- SubModule FDC_SPI
-- Created   19/08/2005 1:41:15 PM
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.std_match;
library work;
use work.spi_pak.all;

entity FDC_spi is 
	port
    (
      wb_clk_i    : in std_logic;                                 -- master clock input
      wb_rst_i    : in std_logic;                                 -- synchronous active high reset
      wb_adr_i    : in std_logic_vector(4 downto 0);              -- lower address bits
      wb_dat_i    : in std_logic_vector(31 downto 0);             -- databus input
      wb_dat_o    : out std_logic_vector(31 downto 0);            -- databus output
      wb_sel_i    : in std_logic_vector(3 downto 0);              -- byte select inputs
      wb_we_i     : in std_logic;                                 -- write enable input
      wb_stb_i    : in std_logic;                                 -- stobe/core select signal
      wb_cyc_i    : in std_logic;                                 -- valid bus cycle input
      wb_ack_o    : out std_logic;                                -- bus cycle acknowledge output
      wb_err_o    : out std_logic;                                -- termination w/ error
      wb_int_o    : out std_logic;                                -- interrupt request signal output
    
      -- SPI signals
      spi_clk        : out   std_logic;
      spi_ena        : out   std_logic;
      spi_mode       : out   std_logic;
      spi_sel        : out   std_logic;
      spi_din        : in    std_logic;
      spi_dout       : out   std_logic
   );
end FDC_spi;

architecture SYN of FDC_spi is

  -- Component Declarations

  -- Constants

  -- Signal Declarations

  -- SPI interface signals (muxed)
  signal wbm_clk			: std_logic;
  signal wbm_rst			: std_logic;
  signal wbm_adr			: std_logic_vector(4 downto 0);
  signal wbm_dat_i		: std_logic_vector(31 downto 0);
  --signal wbm_dat_o		: std_logic_vector(31 downto 0);
  signal wbm_sel			: std_logic_vector(3 downto 0);
  signal wbm_we				: std_logic;
  signal wbm_stb			: std_logic;
  signal wbm_cyc			: std_logic;
  signal wbm_ack			: std_logic;
  signal wbm_int      : std_logic;
  
  signal spi_init_done  : std_logic;
  
  -- SPI interface signals from intialisation code
  signal wbi_cyc      : std_logic;
  signal wbi_stb      : std_logic;
  signal wbi_adr      : std_logic_vector(4 downto 0);
  signal wbi_dat_i    : std_logic_vector(31 downto 0);
  signal wbi_we       : std_logic;
  
  signal ss_sel				: std_logic_vector(7 downto 0);
  
  -- debug only
  signal spi_mode_s   : std_logic;
  signal wb_cycle_s   : std_logic;


begin

	-- hookup wishbone signals
	wbm_clk <= wb_clk_i;
	wbm_rst <= wb_rst_i;
  wbm_sel <= "1111";

  -- pass WB signals up the hierarchy after SPI initialisation complete
  wb_ack_o <= '0' when spi_init_done = '0' else wbm_ack;
  wb_int_o <= '0' when spi_init_done = '0' else wbm_int;
  
  -- wishbone mux
  wbm_cyc <= wbi_cyc when spi_init_done = '0' else wb_cyc_i;
  wbm_stb <= wbi_stb when spi_init_done = '0' else wb_stb_i;
  wbm_adr <= wbi_adr when spi_init_done = '0' else wb_adr_i;
  wbm_dat_i <= wbi_dat_i when spi_init_done = '0' else wb_dat_i;
  wbm_we <= wbi_we when spi_init_done = '0' else wb_we_i;
    
  -- handle wishbone cycle generation
  wbi_cyc <= wb_cycle_s and not wbm_ack;
  wbi_stb <= wb_cycle_s and not wbm_ack;

  -- SPI signals
  spi_sel <= ss_sel(0);
  spi_mode <= spi_mode_s;
  spi_ena <= '1';
  
  INIT_SM : block

    type STATE_TYPE is (IDLE,
                        SEL_SPI_MUX, SEL_FLASH_1, SEL_FLASH_2, SEL_FLASH_3, SEL_FLASH_4, DESEL_SPI_MUX, 
                        WAKE_FLASH_1, WAKE_FLASH_2, WAKE_FLASH_3, WAKE_FLASH_4, WAKE_FLASH_5, WAKE_FLASH_6,
                        SPI_INIT_FINISH);
    
    signal state        : STATE_TYPE;
    signal next_state   : STATE_TYPE;

  begin

    -- state machine next_state process
    process (wb_clk_i, wb_rst_i)
    begin
      if wb_rst_i = '1' then
        state <= IDLE;
      elsif rising_edge(wb_clk_i) then
        state <= next_state;
      end if;
    end process;

    -- state machine
    process (state, wbm_ack, wbm_int, spi_din)
    begin
      next_state <= state;
      wb_cycle_s <= '0';
      --wbm_adr <= (others => 'X');
      --wbm_dat_i <= (others => 'X');
      case state is
        when IDLE =>
          spi_init_done <= '0';
          spi_mode_s <= '0';
          wbi_adr <= (others => '0');
          wbi_dat_i <= (others => '0');
          wbi_we <= '0';
          next_state <= SEL_SPI_MUX;
        when SEL_SPI_MUX =>
          wbi_adr <= (others => '0');
          -- select SPI mux
          spi_mode_s <= '1';
          next_state <= SEL_FLASH_1;
        when SEL_FLASH_1 =>
          spi_mode_s <= '1';
          -- write the configuration (ASS=0, 8-bit)
          wbi_adr <= "10000";
          wbi_dat_i <= X"0000" & "00" & "01010" & '0' & '0' & "0001000";
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= SEL_FLASH_2;
          end if;
        when SEL_FLASH_2 =>
          spi_mode_s <= '1';
          -- select flash in mux
          wbi_adr <= "00000";
          wbi_dat_i <= X"00000082";
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= SEL_FLASH_3;
          end if;
        when SEL_FLASH_3 =>
          spi_mode_s <= '1';
          -- hit the 'Go' bit
          wbi_adr <= "10000";
          wbi_dat_i <= X"0000" & "00" & "01010" & '1' & '0' & "0001000";
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= SEL_FLASH_4;
          end if;
        when SEL_FLASH_4 =>
          wbi_adr <= "10000";
          spi_mode_s <= '1';
          -- wait for SPI to finish
          if wbm_int = '1' then
            -- de-select SPI mux
            next_state <= DESEL_SPI_MUX;
          end if;
        when DESEL_SPI_MUX =>
          wbi_adr <= "10000";
          spi_mode_s <= '1';
          -- wait for SPIDin to go low
          if spi_din = '0' then
            -- de-select SPI mux
            spi_mode_s <= '0';
            next_state <= WAKE_FLASH_1;
          end if;
        when WAKE_FLASH_1 =>
          wbi_adr <= "00000";           -- TX 0
          wbi_dat_i <= X"00000000";     -- Release from deep power-down
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= WAKE_FLASH_2;
          end if;
        when WAKE_FLASH_2 =>
          wbi_adr <= "00100";           -- TX 1
          wbi_dat_i <= X"000000AB";     -- (cont)
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= WAKE_FLASH_3;
          end if;
        when WAKE_FLASH_3 =>
          -- write the configuration (ASS=1, 40-bit)
          wbi_adr <= "10000";           -- CTRL
          wbi_dat_i <= X"0000" & "00" & "11010" & '0' & '0' & "0101000";
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= WAKE_FLASH_4;
          end if;
        when WAKE_FLASH_4 =>
          wbi_adr <= "11000";           -- slave select
          wbi_dat_i <= X"00000001";     -- slave 0
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= WAKE_FLASH_5;
          end if;
        when WAKE_FLASH_5 =>
          -- hit the GO bit
          wbi_adr <= "10000";           -- CTRL
          wbi_dat_i <= X"0000" & "00" & "11010" & '1' & '0' & "0101000";
          wbi_we <= '1';
          wb_cycle_s <= '1';
          if wbm_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= WAKE_FLASH_6;
          end if;
        when WAKE_FLASH_6 =>
          wbi_adr <= "10000";           -- CTRL
          -- wait for SPI to finish
          if wbm_int = '1' then
            next_state <= SPI_INIT_FINISH;
          end if;
        when SPI_INIT_FINISH =>
          spi_init_done <= '1';
      end case;
    end process;

  end block INIT_SM;

  -- component instantiations

  spi_inst : spi_top
  port map
    (
      wb_clk_i    => wbm_clk,
      wb_rst_i    => wbm_rst,
      wb_adr_i    => wbm_adr,
      wb_dat_i    => wbm_dat_i,
      wb_dat_o    => wb_dat_o,
      wb_sel_i    => wbm_sel,
      wb_we_i     => wbm_we,
      wb_stb_i    => wbm_stb,
      wb_cyc_i    => wbm_cyc,
      wb_ack_o    => wbm_ack,
      --wb_err_o    => wb_err,
      wb_int_o    => wbm_int,

      -- SPI signals
      ss_pad_o    => ss_sel,
      sclk_pad_o  => spi_clk,
      mosi_pad_o  => spi_dout,
      miso_pad_i  => spi_din
    );

end SYN;
