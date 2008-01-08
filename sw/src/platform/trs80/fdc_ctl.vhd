--------------------------------------------------------------------------------
-- SubModule FDC_Ctl
-- Created   19/08/2005 1:41:15 PM
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.std_match;

entity FDC_ctl is 
	port
    (
      clk            : in   std_logic;
      reset          : in   std_logic;
      
      -- input signals
      command         : in std_logic_vector(7 downto 0);
      drive           : in std_logic_vector(1 downto 0);
      track           : in std_logic_vector(7 downto 0);
      sector          : in std_logic_vector(7 downto 0);
      data_i          : in std_logic_vector(7 downto 0);

      cmd_wr_stb      : in std_logic;
      data_rd_stb     : in std_logic;
      data_wr_stb     : in std_logic;

      -- output signals
      not_ready       : out std_logic;
      wp              : out std_logic;
      hd_loaded       : out std_logic;
      seek_err        : out std_logic;
      crc_err         : out std_logic;
      trk_0           : out std_logic;
      idx_pulse       : out std_logic;
      busy            : out std_logic;
      rnf             : out std_logic;
      lost_data       : out std_logic;
      drq             : out std_logic;
      rec_type        : out std_logic_vector(1 downto 0);
      wr_fault        : out std_logic;

      data_o          : out std_logic_vector(7 downto 0);
      data_o_stb      : out std_logic;
      intreq          : out std_logic;

      -- SPI signals
      spi_clk        : out   std_logic;
      spi_ena        : out   std_logic;
      spi_mode       : out   std_logic;
      spi_sel        : out   std_logic;
      spi_din        : in    std_logic;
      spi_dout       : out   std_logic;
      
      debug           : out   std_logic_vector(7 downto 0)
   );
end FDC_ctl;

architecture SYN of FDC_ctl is

  -- Component Declarations

  component FDC_spi is 
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
  end component;

  -- Constants

  constant CMD_RESTORE          : std_logic_vector(7 downto 4) := "0000";
  constant CMD_SEEK             : std_logic_vector(7 downto 4) := "0001";
  constant CMD_STEP             : std_logic_vector(7 downto 4) := "001-";
  constant CMD_STEP_IN          : std_logic_vector(7 downto 4) := "010-";
  constant CMD_STEP_OUT         : std_logic_vector(7 downto 4) := "011-";
  constant CMD_READ_SECTOR      : std_logic_vector(7 downto 4) := "100-";
  constant CMD_WRITE_SECTOR     : std_logic_vector(7 downto 4) := "101-";
  constant CMD_READ_ADDRESS     : std_logic_vector(7 downto 4) := "1100";
  constant CMD_READ_TRACK       : std_logic_vector(7 downto 4) := "1110";
  constant CMD_WRITE_TRACK      : std_logic_vector(7 downto 4) := "1111";
  constant CMD_FORCE_INTERRUPT  : std_logic_vector(7 downto 4) := "1101";

  alias    CMD                  : std_logic_vector(7 downto 4) is command(7 downto 4);
        
  -- Signal Declarations

  signal flash_addr 	          : std_logic_vector(23 downto 0);
  signal rd_sect_stb            : std_logic;

  signal wb_clk			            : std_logic;
  signal wb_rst			            : std_logic;
  signal wb_adr			            : std_logic_vector(4 downto 0);
  signal wb_dat_i		            : std_logic_vector(31 downto 0);
  signal wb_dat_o		            : std_logic_vector(31 downto 0);
  signal wb_sel			            : std_logic_vector(3 downto 0);
  signal wb_we			            : std_logic;
  signal wb_stb			            : std_logic;
  signal wb_cyc			            : std_logic;
  signal wb_ack			            : std_logic;
  signal wb_int                 : std_logic;

  signal intreq_1               : std_logic;
  signal intreq_4               : std_logic;
  signal intreq_rdsect          : std_logic;

begin

  -- some defaults (to change)
  not_ready       <= '0';
  wp              <= '0';
  hd_loaded       <= '1';
  seek_err        <= '0';
  crc_err         <= '0';
  trk_0           <= '1' when track = X"00" else '0'; -- not quite correct
  --busy            <= '0';
  rnf             <= '0';
  lost_data       <= '0';
  -- BIG FUDGE  - Newdos/80 III Boot disk JVC image has DAM=(DD)F8 on Track 9, Sect 8-17
  --            - however the 1793 only has deleted/data address mark (LSB of rec_type)
  --            - need to set this bit for above tracks or won't boot!
  --rec_type        <= "01" when (track = X"09" and sector(4 downto 3) /= "00") else "00";
	-- Model I (NEWDOS/80 at least)
  rec_type        <= "01" when track = X"11" else "00";
  -- similar for LDOS 5.3.1
  --rec_type        <= "01" when (track = X"13") else "00";
  wr_fault        <= '0';

  -- wire-OR the interrupts together
  intreq <= intreq_1 or intreq_4 or intreq_rdsect;

  -- generate the index pulse (2% of revolution)
  -- 300RPM (5 RPS, or 200ms/rev)
  -- T.B.D. motor stays spinning for 2s
  process (clk, reset)
    variable idx_count_v : integer range 0 to 4000000;
    variable intreq_v : std_logic;
  begin
    if reset = '1' then
      idx_pulse <= '0';
      idx_count_v := 0;
      intreq_v := '0';
    elsif rising_edge(clk) then
      intreq_v := '0';
      idx_count_v := idx_count_v + 1;
      -- activate for 2% of the time (4ms)
      if idx_count_v < 80000 then
        idx_pulse <= '1';
      else
        -- wrap at 200ms
        if idx_count_v = 4000000 then
          idx_count_v := 0;
          -- technically this is a bit early, but the TRS-80 will never know
          -- most efficient to do it here, no need for another comparison
          if CMD = CMD_FORCE_INTERRUPT and command(2) = '1' then
            intreq_v := '1';
          end if;
        end if;
        idx_pulse <= '0';
      end if;
    end if;

    intreq_4 <= intreq_v;

  end process;
  
  process (clk, reset)
    variable rd_sect_stb_v  : std_logic;
    variable intreq_v       : std_logic;
  begin
    if reset = '1' then

      flash_addr <= (others => '0');
      debug (5 downto 0) <= (others => '0');

      rd_sect_stb_v := '0';
      intreq_v := '0';
            
    elsif rising_edge(clk) then

      -- by assigning a default value, we get a 1-clock pulse
      rd_sect_stb_v := '0';
      intreq_v := '0';

      -- write to the command register
			if cmd_wr_stb = '1' then
        if STD_MATCH(CMD, CMD_RESTORE) then
          --flash_addr <= "000" & track & sector(4 downto 0) & X"00";
          intreq_v := '1';
        elsif STD_MATCH(CMD, CMD_SEEK) then
          --flash_addr <= "000" & track & sector(4 downto 0) & X"00";
          intreq_v := '1';
        elsif STD_MATCH(CMD, CMD_STEP) then
          --flash_addr <= "000" & track & sector(4 downto 0) & X"00";
          intreq_v := '1';
        elsif STD_MATCH(CMD, CMD_STEP_IN) then
          --flash_addr <= "000" & track & sector(4 downto 0) & X"00";
          intreq_v := '1';
        elsif STD_MATCH(CMD, CMD_STEP_OUT) then
          --flash_addr <= "000" & track & sector(4 downto 0) & X"00";
          intreq_v := '1';
        elsif STD_MATCH(CMD, CMD_READ_SECTOR) then
          flash_addr <= "000" & drive & track(5 downto 0) & sector(4 downto 0) & X"00";
          rd_sect_stb_v := '1';
        elsif STD_MATCH(CMD, CMD_FORCE_INTERRUPT) then
          -- generate immediately on 'immediate' or 'not-ready-to-ready'
          if (command(0) or command (3)) = '1' then
            intreq_v := '1';
          end if;
        else
          debug (0) <= '1';
        end if;
      
      -- start of an fdc register write
      elsif data_rd_stb = '1' then
        null;
        
      elsif data_wr_stb = '1' then
        null;
        
			end if;

    end if;

    rd_sect_stb <= rd_sect_stb_v;
    intreq_1 <= intreq_v;

  end process;

  -- SECTOR READ SM

  RD_SECT_SM : block

    type STATE_TYPE is (IDLE, RD_1, RD_2, RD_3, RD_4, RD_5, RD_6, RD_7, RD_8, RD_9, RD_10, RD_11, RD_12);

    signal state        : STATE_TYPE;
    signal next_state   : STATE_TYPE;
		
		signal count			  : integer range 0 to 256;
		
    signal wb_cycle_s   : std_logic;

  begin

    -- handle wishbone cycle generation
    wb_cyc <= wb_cycle_s and not wb_ack;
    wb_stb <= wb_cycle_s and not wb_ack;

    data_o <= wb_dat_o(7 downto 0);

    process (clk, reset)
    begin
      if reset = '1' then
        state <= IDLE after 1 ns;
      elsif rising_edge(clk) then
        state <= next_state after 1 ns;
      end if;
    end process;
  
    -- state machine
    process (state, rd_sect_stb, wb_ack, wb_int, data_rd_stb)
    begin

      next_state <= state;

      busy <= '0';
      drq <= '0';
      data_o_stb <= '0';

      wb_cycle_s <= '0';
      wb_adr <= (others => 'X');
      wb_dat_i <= (others => 'X');
      wb_we <= '0';
      
      intreq_rdsect <= '0';

      case state is

        when IDLE =>
          if rd_sect_stb = '1' then
            next_state <= RD_1;
          end if;

        -- setup the flash read from address command
        when RD_1 =>
          busy <= '1';
          wb_adr <= "00000";               -- TX 0
          wb_dat_i <= X"03" & flash_addr;  -- READ from address
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            next_state <= RD_2;
          end if;

        -- write the configuration (ASS=0, 32-bit)
        when RD_2 =>
          busy <= '1';
          wb_adr <= "10000";           -- CTRL
          wb_dat_i <= X"0000" & "00" & "01010" & '0' & '0' & "0100000";
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            next_state <= RD_3;
          end if;

        -- select the slave (SPI)
        when RD_3 =>
          busy <= '1';
          wb_adr <= "11000";           -- slave select
          wb_dat_i <= X"00000001";     -- slave 0
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            next_state <= RD_4;
          end if;

        -- hit the GO bit
        when RD_4 =>
          busy <= '1';
          wb_adr <= "10000";           -- CTRL
          wb_dat_i <= X"0000" & "00" & "01010" & '1' & '0' & "0100000";
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            next_state <= RD_5;
          end if;

        -- wait for SPI to finish
        when RD_5 =>
          busy <= '1';
          if wb_int = '1' then
            next_state <= RD_6;
          end if;

        -- write the configuration (ASS=0, 8-bit)
        when RD_6 =>
          busy <= '1';
          wb_adr <= "10000";           -- CTRL
          wb_dat_i <= X"0000" & "00" & "01010" & '0' & '0' & "0001000";
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            -- now read the first data byte in the sector
            next_state <= RD_7;
          end if;

        -- hit the GO bit to read a data byte
        when RD_7 =>
          busy <= '1';
          wb_adr <= "10000";           -- CTRL
          wb_dat_i <= X"0000" & "00" & "01010" & '1' & '0' & "0001000";
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            next_state <= RD_8;
          end if;

        -- wait for SPI to finish
        when RD_8 =>
          busy <= '1';
          if wb_int = '1' then
            -- update the data register
            next_state <= RD_9;
          end if;

        -- wait for data register to be read
        when RD_9 =>
          busy <= '1';
          -- read data register from SPI
          wb_adr <= "00000";
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            data_o_stb <= '1'; -- latch into data register
            drq <= '1';   -- signal data is ready in the register
            next_state <= RD_10;
          end if;

        when RD_10 =>
          busy <= '1';
          -- single-clock for counter to decrement            
          next_state <= RD_11;

        when RD_11 =>
          busy <= '1';
          drq <= '1';   -- signal data is ready in the register
          if data_rd_stb = '1' then
            if count = 0 then
              intreq_rdsect <= '1';
              next_state <= RD_12;
            else
              next_state <= RD_7;
            end if;
          end if;

        -- de-select the slave
        when RD_12 =>
          wb_adr <= "11000";           -- slave select
          wb_dat_i <= X"00000000";     -- nothing selected
          wb_we <= '1';
          wb_cycle_s <= '1';
          if wb_ack = '1' then
            wb_cycle_s <= '0';
            next_state <= IDLE;
          end if;

      end case;
    end process;

		process (clk, reset)
		begin
			if reset = '1' then
				count <= 0;
        debug(7 downto 6) <= (others =>'0');
			elsif rising_edge(clk) then
        case state is
          when IDLE =>
            debug(7 downto 6) <= (others => '0');
          when RD_1 => 
						-- simulate drive lights
            debug(7) <= drive(0);
						debug(6) <= not drive(0);
          when RD_6 =>
            count <= 256;
          when RD_10 =>
            count <= count - 1;
          when others =>
            null;
        end case;
			end if;
		end process;
		
  end block RD_SECT_SM;

  -- component instantiations

  fdc_spi_inst : fdc_spi
  port map
    (
      wb_clk_i    => clk,
      wb_rst_i    => reset,
      wb_adr_i    => wb_adr,
      wb_dat_i    => wb_dat_i,
      wb_dat_o    => wb_dat_o,
      wb_sel_i    => "1111",
      wb_we_i     => wb_we,
      wb_stb_i    => wb_stb,
      wb_cyc_i    => wb_cyc,
      wb_ack_o    => wb_ack,
      --wb_err_o    
      wb_int_o    => wb_int,
    
      -- SPI signals
      spi_clk     => spi_clk,
      spi_ena     => spi_ena,
      spi_mode    => spi_mode,
      spi_sel     => spi_sel,
      spi_din     => spi_din,
      spi_dout    => spi_dout
    );

end SYN;
