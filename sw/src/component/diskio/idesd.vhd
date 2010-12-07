library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- the OCIDE controller uses UNSIGNED from here
--use ieee.std_logic_arith.unsigned;

entity ide_sd is
  generic
  (
    -- when emulating devices accessed using LBA mode
    -- - use the *default* values
    LBA_MODE          : boolean := true;
    CYLINDER_BITS     : integer := 16;
    HEAD_BITS         : integer := 4;
    SECTOR_BITS       : integer := 8;
    ID_INIT_FILE      : string
  );
  port
  (
    -- clocking, reset
    clk               : in std_logic;
    clk_ena           : in std_logic;
    rst               : in std_logic;
    
    -- IDE interface
    iordy0_cf         : out std_logic;
    rdy_irq_cf        : out std_logic;
    cd_cf             : out std_logic;
    a_cf              : in std_logic_vector(2 downto 0);
    nce_cf            : in std_logic_vector(2 downto 1);
    d_i               : out std_logic_vector(15 downto 0);
    d_o               : in std_logic_vector(15 downto 0);
    d_oe              : in std_logic;
    nior0_cf          : in std_logic;
    niow0_cf          : in std_logic;
    non_cf            : in std_logic;
    nreset_cf         : in std_logic;
    ndmack_cf         : in std_logic;
    dmarq_cf          : out std_logic;
    
    -- SD/MMC interface
    clk_25M           : in std_logic;
		sd_dat_i          : in std_logic_vector(3 downto 0);
		sd_dat_o          : out std_logic_vector(3 downto 0);
		sd_dat_oe         : out std_logic;
		sd_cmd_i          : in std_logic;
		sd_cmd_o          : out std_logic;
		sd_cmd_oe         : out std_logic;
		sd_clk            : out std_logic
  );
end entity ide_sd;

architecture SYN of ide_sd is

  -- drive geometry
  constant CYLINDERS  : std_logic_vector(15 downto 0) :=
                          std_logic_vector(to_unsigned(2**CYLINDER_BITS,16));
  constant HEADS      : std_logic_vector(15 downto 0) :=
                          std_logic_vector(to_unsigned(2**HEAD_BITS,16));
  constant SECTORS    : std_logic_vector(15 downto 0) :=
                          std_logic_vector(to_unsigned(2**SECTOR_BITS,16));

  -- ATAPI commands
  constant RECALIBRATE            : std_logic_vector(7 downto 0) := X"10";
  constant READ_SECTORS_W_RETRY   : std_logic_vector(7 downto 0) := X"20";
  constant READ_SECTORS_WO_RETRY  : std_logic_vector(7 downto 0) := X"21";
  constant WRITE_SECTORS_W_RETRY  : std_logic_vector(7 downto 0) := X"30";
  constant WRITE_SECTORS_WO_RETRY : std_logic_vector(7 downto 0) := X"31";
  constant SEEK                   : std_logic_vector(7 downto 0) := X"70";
  constant EXEC_DEVICE_DIAGNOSTIC : std_logic_vector(7 downto 0) := X"90";
  constant READ_MULTIPLE          : std_logic_vector(7 downto 0) := X"C4";
  constant WRITE_MULTIPLE         : std_logic_vector(7 downto 0) := X"C5";
  constant IDENTIFY_DEVICE        : std_logic_vector(7 downto 0) := X"EC";
  
  -- input registers
  signal data_r_i     : std_logic_vector(15 downto 0) := (others => '0');
  signal sec_cnt_r_i  : std_logic_vector(7 downto 0) := (others => '0');
  signal lba28_r_i    : std_logic_vector(27 downto 0) := (others => '0');
  alias sec_no_r_i    : std_logic_vector(7 downto 0) is lba28_r_i(7 downto 0);
  alias cyl_lo_r_i    : std_logic_vector(7 downto 0) is lba28_r_i(15 downto 8);
  alias cyl_hi_r_i    : std_logic_vector(7 downto 0) is lba28_r_i(23 downto 16);
  signal dev4_r_i     : std_logic_vector(7 downto 4) := "1010";
  alias lba_r_i       : std_logic is dev4_r_i(6);
  alias dev_r_i       : std_logic is dev4_r_i(4);
  alias hd_r_i        : std_logic_vector(3 downto 0) is lba28_r_i(27 downto 24);
  signal cmd_r_i      : std_logic_vector(7 downto 0) := (others => '0');

  -- output registers
  
  signal data_r_o     : std_logic_vector(15 downto 0) := (others => '0');

  signal err_r_o      : std_logic_vector(7 downto 0) := (others => '0');
  constant UNC        : integer := 6;
  constant MC         : integer := 5;
  constant IDNF       : integer := 4;
  constant MCR        : integer := 3;
  constant ABRT       : integer := 2;
  constant TK0NF      : integer := 1;
  constant AMNF       : integer := 0;

  -- When BSY is set, all other bits are invalid
  -- Status is not valid for 400ns after a command/data cycle
  -- - (22 clocks & 57M272Hz)
  -- Write to CMD register is ignoed when BSY=1
  -- DRQ can only be changed when BSY=1
  -- IDX,DRDY,DF,DSC,CORR can be changed when BSY=0
  
  signal sts_r_o          : std_logic_vector(7 downto 0) := (others => '0');
  constant BSY            : integer := 7;
  constant DRDY           : integer := 6;
  constant DF             : integer := 5;
  constant DSC            : integer := 4;
  constant DRQ            : integer := 3;
  constant CORR           : integer := 2;
  constant IDX            : integer := 1;
  constant ERR            : integer := 0;
  signal read_sts         : std_logic_vector(sts_r_o'range) := (others => '0');
  signal cmd_sts          : std_logic_vector(sts_r_o'range) := (others => '0');
  
  signal cmd_go           : std_logic := '0';
  signal rd_go            : std_logic := '0';
  signal rd_go_25MHz      : std_logic := '0';
  signal rd_done          : std_logic := '0';
  signal rd_done_25MHz    : std_logic := '0';
  
  -- read data fifo signals
  signal rd_fifo_rdreq    : std_logic := '0';
  signal rd_fifo_empty    : std_logic := '0';
  signal rd_fifo_q        : std_logic_vector(15 downto 0) := (others => '0');

  signal lba              : std_logic_vector(36 downto 0) := (others => '0');
  
begin

  process (clk, rst)
    variable nior_r : std_logic := '1';
    variable niow_r : std_logic := '1';
  begin
    if rst = '1' then
      nior_r := '1';
      niow_r := '1';
    elsif rising_edge(clk) then
      if clk_ena = '1' then
        cmd_go <= '0';          -- default
        rd_fifo_rdreq <= '0';   -- default
        if nreset_cf = '0' then
          null;
        elsif nce_cf = "10" then
          -- command block selected
          if nior0_cf = '0' and nior_r = '1' then
            case a_cf is
              when "000" =>   -- data
                d_i <= rd_fifo_q;
                rd_fifo_rdreq <= '1';
              when "001" =>   -- error
                d_i <= X"00" & err_r_o;
              when "010" =>   -- sector_count
              when "011" =>   -- sector_number
              when "100" =>   -- cyl_lo
              when "101" =>   -- cyl_hi
              when "110" =>   -- dev_head
              when others =>  -- status
                d_i(7 downto 0) <= sts_r_o;
            end case;
          elsif niow0_cf = '0' and niow_r = '1' then
            case a_cf is
              when "000" =>   -- data
                data_r_i <= d_o;
              when "001" =>   -- features
              when "010" =>   -- sector_count
                sec_cnt_r_i <= d_o(7 downto 0);
              when "011" =>   -- sector_number
                if LBA_MODE then
                  sec_no_r_i <= d_o(7 downto 0);
                else
                  -- because sectors start at 1 in CHS mode
                  sec_no_r_i <= std_logic_vector(unsigned(d_o(7 downto 0))-1);
                end if;
              when "100" =>   -- cyl_lo
                cyl_lo_r_i <= d_o(7 downto 0);
              when "101" =>   -- cyl_hi
                cyl_hi_r_i <= d_o(7 downto 0);
              when "110" =>   -- dev_head
                dev4_r_i <= d_o(7 downto 4);
                hd_r_i <= d_o(3 downto 0);
              when others =>  -- command
                -- writes to this register are ignored if BSY=1
                if cmd_sts(BSY) = '0' then
                  cmd_r_i <= d_o(7 downto 0);
                  cmd_go <= '1';
                end if;
            end case;
          end if;
        end if; -- nce_cf="10"
        nior_r := nior0_cf;
        niow_r := niow0_cf;
      end if; -- clk_ena='1'
    end if;
  end process;

  iordy0_cf <= '1';
  
  -- BUSY asserted during command unless DRQ asserted
  sts_r_o(BSY) <= cmd_sts(BSY) and not read_sts(DRQ);
  sts_r_o(6 downto 0) <= cmd_sts(6 downto 0) or read_sts(6 downto 0);
  
  BLK_MAIN_SM : block
    type state_t is ( S_IDLE, S_DIAGNOSTIC, S_IDENTIFY, 
                      S_READ_1, S_START_READ, S_WAIT_READ );
    signal state : state_t := S_IDLE;
  begin
    process (clk, rst)
      subtype count_t is integer range 0 to 4;
      variable count : count_t := 0;
    begin
      if rst = '1' then
        cmd_sts <= (others => '0');
        rd_go <= '0';
        state <= S_IDLE;
      elsif rising_edge(clk) then
        if clk_ena = '1' then
          if cmd_go = '1' then
            cmd_sts(BSY) <= '1';      -- default
            cmd_sts(DRDY) <= '0';     -- default
            case cmd_r_i is
              when RECALIBRATE =>
                -- TBD
                -- - CHS: CYL_HI,CYL_LO,HEAD=0,SECTOR=1
                -- - LBA: above all 0
                cmd_sts(BSY) <= '0';
                cmd_sts(DRDY) <= '1';
              when EXEC_DEVICE_DIAGNOSTIC =>
                state <= S_DIAGNOSTIC;
              when IDENTIFY_DEVICE =>
                state <= S_IDENTIFY;
              when READ_SECTORS_W_RETRY | 
                    READ_SECTORS_WO_RETRY =>
                state <= S_READ_1;
              when others =>
                -- do we need to transition back to idle here?
                cmd_sts(BSY) <= '0';
                cmd_sts(DRDY) <= '1';
            end case;
          else
            case state is
              when S_IDLE =>
                cmd_sts(BSY) <= '0';
                cmd_sts(DRDY) <= '1';
              when S_DIAGNOSTIC =>
                -- device 0 passed, device 1 passed or not present
                err_r_o <= X"01"; 
                state <= S_IDLE;
              when S_IDENTIFY =>
                -- set up some read operation here
                count := count_t'high;
                state <= S_START_READ;
              when S_READ_1 =>
                -- set up some read operation here
                count := count_t'high;
                state <= S_START_READ;
              when S_START_READ =>
                -- pulse-extend rd_go for use in 25MHz clock domain
                if count /= 0 then
                  rd_go <= '1';
                  count := count - 1;
                else
                  rd_go <= '0';
                  state <= S_WAIT_READ;
                end if;
              when S_WAIT_READ =>
                if rd_done = '1' then
                  state <= S_IDLE;
                end if;
              when others =>
                state <= S_IDLE;
            end case;
          end if; -- cmd_go='1'
        end if; -- clk_ena='1'
      end if;
    end process;
  end block BLK_MAIN_SM;

  -- create a 25MHz read_go pulse
  process (clk_25M, rst)
    variable rd_go_r : std_logic_vector(4 downto 0) := (others => '0');
  begin
    if rst = '1' then
      rd_go_r := (others => '0');
    elsif rising_edge(clk_25M) then
      rd_go_25MHz <= '0'; -- default
      if rd_go_r(4) = '0' and rd_go_r(3) = '1' then
        rd_go_25MHz <= '1';
      end if;
      rd_go_r := rd_go_r(3 downto 0) & rd_go;
    end if;
  end process;

  -- extract a SYSCLK read_done pulse
  process (clk, rst)
    variable rd_done_r : std_logic_vector(3 downto 0) := (others => '0');
  begin
    if rst = '1' then
      rd_done_r := (others => '0');
      rd_done <= '0';
    elsif rising_edge(clk) then
      rd_done <= '0';
      if rd_done_r(rd_done_r'left) = '0' and rd_done_r(rd_done_r'left-1) = '1' then
        rd_done <= '1';
      end if;
      rd_done_r := rd_done_r(rd_done_r'left-1 downto 0) & rd_done_25MHz;
    end if;
  end process;
  
  BLK_READ : block
  
    -- IDENTIFY_DEVICE ROM signals
    signal id_rom_a       : std_logic_vector(7 downto 0) := (others => '0');
    signal id_rom_d       : std_logic_vector(15 downto 0) := (others => '0');
    
    -- read signals from SD core
    signal sd_rd_go       : std_logic;
    signal sd_rd_d        : std_logic_vector(15 downto 0);
    signal sd_rd_ce       : std_logic;
    signal sd_rd_err      : std_logic;

    -- read FIFO signals
    signal rd_fifo_clr    : std_logic := '0';
    signal rd_fifo_wrreq  : std_logic := '0';
    signal rd_fifo_wrfull : std_logic := '0';
    signal rd_fifo_data   : std_logic_vector(15 downto 0) := (others => '0');
    
    type state_t is ( S_IDLE, S_ID_1, S_RD_1 );
    signal state  : state_t := S_IDLE;
    
  begin
    process (clk_25M, rst)
      subtype count_t is integer range 0 to 255;
      variable count  : count_t := 0;
    begin
      if rst = '1' then
        state <= S_IDLE;
      elsif rising_edge(clk_25M) then
        sd_rd_go <= '0';        -- default
        rd_fifo_wrreq <= '0';   -- default
        rd_done_25MHz <= '0';   -- default
        case state is
          when S_IDLE =>
            if rd_go_25MHz = '1' then
              case cmd_r_i is
                when IDENTIFY_DEVICE =>
                  id_rom_a <= (others => '0');
                  state <= S_ID_1;
                when others =>
                  count := 0;
                  sd_rd_go <= '1';
                  state <= S_RD_1;
              end case;
            end if;
          when S_ID_1 =>
            if rd_fifo_wrfull = '0' then
              rd_fifo_wrreq <= '1';
              case id_rom_a is
                when X"01" =>
                  rd_fifo_data <= CYLINDERS;
                when X"03" =>
                  rd_fifo_data <= HEADS;
                when X"06" =>
                  rd_fifo_data <= SECTORS;
                when others =>
                  rd_fifo_data <= id_rom_d;
              end case;
              if id_rom_a = X"FF" then
                rd_done_25MHz <= '1';
                state <= S_IDLE;
              else
                id_rom_a <= std_logic_vector(unsigned(id_rom_a) + 1);
              end if;
            end if;
          when S_RD_1 =>
            -- not much we can do about wrfull atm
            rd_fifo_data <= sd_rd_d(7 downto 0) & sd_rd_d(15 downto 8);
            rd_fifo_wrreq <= sd_rd_ce;
            if sd_rd_ce = '1' then
              if count = count_t'high then
                rd_done_25MHz <= '1';
                state <= S_IDLE;
              else
                count := count + 1;
              end if;
            end if;
          when others =>
            state <= S_IDLE;
        end case;
      end if;
    end process;
    
    -- IDE IDENTIFY_DEVICE ROM
    iderom_inst : entity work.sprom
      generic map
      (
        init_file		=> ID_INIT_FILE,
        widthad_a   => 8,
        width_a     => 16
      )
      port map
      (
        clock		    => clk_25M,
        address		  => id_rom_a,
        q			      => id_rom_d
      );

    -- read FIFO from ID/SD
    rd_fifo_clr <= rst or rd_go;
    rd_fifo_inst : entity work.sd_rd_fifo
      port map
      (
        aclr		  => rst,
        wrclk		  => clk_25M,
        wrreq		  => rd_fifo_wrreq,
        wrfull		=> rd_fifo_wrfull,
        data		  => rd_fifo_data,

        rdclk		  => clk,
        rdreq		  => rd_fifo_rdreq,
        rdempty		=> rd_fifo_empty,
        q		      => rd_fifo_q
      );
    read_sts(DRQ) <= not rd_fifo_empty;

    GEN_LBA_MODE : if LBA_MODE generate
      lba <= lba28_r_i & "000000000";
    end generate GEN_LBA_MODE;
    
    GEN_CHS_MODE : if not LBA_MODE generate
      lba <=  std_logic_vector(resize(unsigned(
                  cyl_hi_r_i(CYLINDER_BITS-9 downto 0) &
                  cyl_lo_r_i(7 downto 0) &
                  hd_r_i(HEAD_BITS-1 downto 0) &
                  sec_no_r_i(SECTOR_BITS-1 downto 0) & 
                  "000000000"), 
                lba'length));
    end generate GEN_CHS_MODE;
    
    sd_if_inst : entity work.sd_if
      generic map
      (
        sd_width 		  => 1,
        dat_width     => 16
      )
      port map
      (
        clk						=> clk_25M,
        clk_en_50MHz	=> '1',
        reset					=> rst,

        sd_clk				=> sd_clk,
        sd_cmd_i			=> sd_cmd_i,
        sd_cmd_o			=> sd_cmd_o,
        sd_cmd_oe			=> sd_cmd_oe,
        sd_dat_i			=> sd_dat_i,
        sd_dat_o			=> sd_dat_o,
        sd_dat_oe			=> sd_dat_oe,
        
        blk						=> lba(31 downto 0),
        rd						=> sd_rd_go,
        
        read_dat      => sd_rd_d,
        read_ce       => sd_rd_ce,
        read_err      => sd_rd_err,

        dbg						=> open,
        dbgsel				=> "000"
      );

  end block BLK_READ;

end architecture SYN;
