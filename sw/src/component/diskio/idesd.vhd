library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- the OCIDE controller uses UNSIGNED from here
use ieee.std_logic_arith.unsigned;

entity ide_sd is
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
    reset_cf          : in std_logic;
    ndmack_cf         : in std_logic;
    dmarq_cf          : out std_logic;
    
    -- SD/MMC interface
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

  constant READ_SECTORS_W_RETRY   : std_logic_vector(7 downto 0) := X"20";
  constant READ_SECTORS_WO_RETRY  : std_logic_vector(7 downto 0) := X"21";
  constant WRITE_SECTORS_W_RETRY  : std_logic_vector(7 downto 0) := X"30";
  constant WRITE_SECTORS_WO_RETRY : std_logic_vector(7 downto 0) := X"31";
  constant SEEK                   : std_logic_vector(7 downto 0) := X"70";
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

  signal sts_r_o      : std_logic_vector(7 downto 0) := (others => '0');
  constant BSY        : integer := 7;
  constant DRDY       : integer := 6;
  constant DF         : integer := 5;
  constant DSC        : integer := 4;
  constant DRQ        : integer := 3;
  constant CORR       : integer := 2;
  constant IDX        : integer := 1;
  constant ERR        : integer := 0;
  
  signal cmd_go       : std_logic := '0';
  signal data_rd_go   : std_logic := '0';
  signal rd_go        : std_logic := '0';
  signal rd_done      : std_logic := '0';
  
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
        cmd_go <= '0';      -- default
        data_rd_go <= '0';  -- default
        if reset_cf = '1' then
        elsif nce_cf = "10" then
          -- command block selected
          if nior0_cf = '0' and nior_r = '1' then
            case a_cf is
              when "000" =>   -- data
                d_i <= data_r_o;
                data_rd_go <= '1';
              when "001" =>   -- error
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
                sec_no_r_i <= d_o(7 downto 0);
              when "100" =>   -- cyl_lo
                cyl_lo_r_i <= d_o(7 downto 0);
              when "101" =>   -- cyl_hi
                cyl_hi_r_i <= d_o(7 downto 0);
              when "110" =>   -- dev_head
                dev4_r_i <= d_o(7 downto 4);
                hd_r_i <= d_o(3 downto 0);
              when others =>  -- command
                cmd_r_i <= d_o(7 downto 0);
                cmd_go <= '1';
            end case;
          end if;
        end if; -- nce_cf="10"
        nior_r := nior0_cf;
        niow_r := niow0_cf;
      end if; -- clk_ena='1'
    end if;
  end process;

  BLK_MAIN_SM : block
    type state_t is ( S_IDLE, S_IDENTIFY, S_READ_1, S_WAIT_READ );
    signal state : state_t := S_IDLE;
  begin
    process (clk, rst)
    begin
      if rst = '1' then
      elsif rising_edge(clk) then
        if clk_ena = '1' then
          rd_go <= '0';   -- default
          case state is
            when S_IDLE =>
              sts_r_o(BSY) <= '1';  -- default
              if cmd_go = '1' then
                case cmd_r_i is
                  when IDENTIFY_DEVICE =>
                    state <= S_IDENTIFY;
                  when READ_SECTORS_W_RETRY =>
                  when READ_SECTORS_WO_RETRY =>
                    state <= S_READ_1;
                  when others =>
                    sts_r_o(BSY) <= '0';
                end case;
              end if;
            when S_IDENTIFY =>
              state <= S_IDLE;
            when S_READ_1 =>
              -- set up some read operation here
              rd_go <= '1';
              state <= S_WAIT_READ;
            when S_WAIT_READ =>
              if rd_done = '1' then
                sts_r_o(BSY) <= '0';
                state <= S_IDLE;
              end if;
            when others =>
              sts_r_o(BSY) <= '0';
              state <= S_IDLE;
          end case;
        end if; -- clk_ena='1'
      end if;
    end process;
  end block BLK_MAIN_SM;
  
  BLK_READ_SM : block
    type state_t is ( S_IDLE, S_LATCH_DATA, S_WAIT_IORD );
    signal state : state_t := S_IDLE;
  begin
    process (clk, rst)
      subtype count_t is integer range 0 to 255;
      variable count : count_t := 0;
    begin
      if rst = '1' then
      elsif rising_edge(clk) then
        if clk_ena = '1' then
          case state is
            when S_IDLE =>
              sts_r_o(DRDY) <= '0';   -- default
              if rd_go = '1' then
                count := 0;
                state <= S_LATCH_DATA;
              end if;
            when S_LATCH_DATA =>
              -- latch data in register & set data ready
              sts_r_o(DRDY) <= '1';
              data_r_o <= std_logic_vector(to_unsigned(count, 16));
              state <= S_WAIT_IORD;
            when S_WAIT_IORD =>
              -- wait for an IORD to increment data
              if data_rd_go = '1' then
                sts_r_o(DRDY) <= '0';
                if count = count_t'high then
                  state <= S_IDLE;
                else
                  count := count + 1;
                  state <= S_LATCH_DATA;
                end if;
              end if;
            when others =>
              null;
          end case;
        end if; -- clk_ena='1'
      end if;
    end process;
  end block BLK_READ_SM;
  
end architecture SYN;
