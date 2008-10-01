library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity wd179x is
  port
  (
    clk           : in std_logic;
    clk_ena       : in std_logic;
    reset         : in std_logic;
    
    -- micro bus interface
    mr_n          : in std_logic;
    we_n          : in std_logic;
    cs_n          : in std_logic;
    re_n          : in std_logic;
    a             : in std_logic_vector(1 downto 0);
    dal_i         : in std_logic_vector(7 downto 0);
    dal_o         : out std_logic_vector(7 downto 0);
    clk_1mhz_en   : in std_logic;
    drq           : out std_logic;
    intrq         : out std_logic;
    
    -- drive interface
    step          : out std_logic;
    dirc          : out std_logic; -- 1=in, 0=out
    early         : out std_logic;
    late          : out std_logic;
    test_n        : in std_logic;
    hlt           : in std_logic;
    rg            : out std_logic;
    sso           : out std_logic;
    rclk          : in std_logic;
    raw_read_n    : in std_logic;
    hld           : out std_logic;
    tg43          : out std_Logic;
    wg            : out std_logic;
    wd            : out std_logic;
    ready         : in std_logic;
    wf_n_i        : in std_logic;
    vfoe_n_o      : out std_logic;
    tr00_n        : in std_logic;
    ip_n          : in std_logic;
    wprt_n        : in std_logic;
    dden_n        : in std_logic
  );
end entity wd179x;

architecture SYN of wd179x is

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

  -- registers
  signal status_r     : std_logic_vector(7 downto 0) := (others => '0');
  signal command_r    : std_logic_vector(7 downto 0) := (others => '0');
  signal track_r      : std_logic_vector(7 downto 0) := (others => '0');
  signal sector_r     : std_logic_vector(7 downto 0) := (others => '0');
  signal data_r       : std_logic_vector(7 downto 0) := (others => '0');
  
  alias CMD           : std_logic_vector(7 downto 4) is command_r(7 downto 4);
  alias TRK_UPD_F     : std_logic is command_r(4);
  alias HD_LOAD_F     : std_logic is command_r(3);

  -- register access strobes
  signal dal_r        : std_logic_vector(dal_i'range);
  signal data_rd_stb  : std_logic := '0';
  signal data_wr_stb  : std_logic := '0';
  signal cmd_wr_stb   : std_logic := '0';
  signal trk_wr_stb   : std_logic := '0';
  signal sec_wr_stb   : std_logic := '0';
  
  signal step_in_s    : std_logic := '0';
  signal hld_s        : std_logic := '0';
  
begin

  -- micro bus interface
  process (clk, clk_ena, reset)
    variable re_n_r   : std_logic := '0';
    variable we_n_r   : std_logic := '0';
  begin
    if reset = '1' then
      re_n_r := '1';
      we_n_r := '1';
    elsif rising_edge(clk) and clk_ena = '1' then
      -- default values
      data_rd_stb <= '0';
      data_wr_stb <= '0';
      cmd_wr_stb <= '0';
      trk_wr_stb <= '0';
      sec_wr_stb <= '0';
      if mr_n = '0' then
        -- master reset
      elsif re_n_r = '1' and re_n = '0' then
        -- leading edge read
        case a is
          when "00" =>
            dal_o <= status_r;
          when "01" =>
            dal_o <= track_r;
          when "10" =>
            dal_o <= sector_r;
          when others =>
            dal_o <= data_r;
            data_rd_stb <= '1';
        end case;
      elsif we_n_r = '1' and we_n = '0' then
        -- leading edge write
        dal_r <= dal_i; -- latch data
        case a is
          when "00" =>
            command_r <= dal_i;
            cmd_wr_stb <= '1';
          when "01" =>
            trk_wr_stb <= '1';
          when "10" =>
            sec_wr_stb <= '1';
          when others =>
            data_wr_stb <= '1';
        end case;
      end if;
      re_n_r := re_n;
      we_n_r := we_n;
    end if;
  end process;

  -- track register
  process (clk, clk_ena, reset)
  begin
    if reset = '1' then
      step_in_s <= '0';
  elsif rising_edge(clk) and clk_ena = '1' then
    if mr_n = '0' then
    else
      if trk_wr_stb = '1' then
        track_r <= dal_r;
      elsif cmd_wr_stb = '1' then
        if STD_MATCH(command_r, CMD_RESTORE) then
          track_r <= X"00";
        elsif STD_MATCH(command_r, CMD_SEEK) then
          track_r <= data_r;
        elsif STD_MATCH(command_r, CMD_STEP) then
          -- only update track register if 'T' bit is set
          if TRK_UPD_F = '1' then
            if step_in_s = '1' then
              track_r <= track_r + 1;
            else
              -- don't step out past track 0
              if track_r /= X"00" then
                track_r <= track_r - 1;
              end if;
            end if;
          end if;
        elsif STD_MATCH(command_r, CMD_STEP_IN) then
          -- only update track register if 'T' bit set.
          if TRK_UPD_F = '1' then
            track_r <= track_r + 1;
          end if;
          step_in_s <= '1';
        elsif STD_MATCH(command_r, CMD_STEP_OUT) then
          -- only update track register if 'T' bit set.
          if TRK_UPD_F = '1' then
            -- don't step out past track 0
            if track_r /= X"00" then
              track_r <= track_r - 1;
            end if;
          end if;
          step_in_s <= '0';
        end if;
      end if;
    end if;
  end if;
  end process;
  
  BLK_STATUS : block

    signal sts_type1      : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdaddr     : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdsect     : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdtrk      : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_wrsect     : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_wrtrk      : std_logic_vector(7 downto 0) := (others => '0');

    -- type I commands
    signal s7_not_ready   : std_logic := '0';
    signal s6_protected   : std_logic := '0';
    signal s5_head_loaded : std_logic := '0';
    signal s4_seek_error  : std_logic := '0';
    signal s3_crc_error   : std_logic := '0';
    signal s2_track_00    : std_logic := '0';
    signal s1_index       : std_logic := '0';
    signal s0_busy        : std_logic := '0';
    
    -- type II/III commands
    signal s5_record_type     : std_logic := '0';
    alias s5_write_fault      : std_logic is s5_record_type;
    signal s4_rnf             : std_logic := '0';
    signal s2_lost_data       : std_logic := '0';
    signal s1_data_request    : std_logic := '0';

  begin

    -- type I commands
    s7_not_ready <= (not ready or mr_n);
    s6_protected <= not wprt_n;
    s5_head_loaded <= hld_s and hlt;
    s1_index <= not ip_n;
    
    -- type II/III commands
    
    -- wire up status register
    sts_type1 <=    s7_not_ready & s6_protected & s5_head_loaded & s4_seek_error & 
                    s3_crc_error & s2_track_00 & s1_index & s0_busy;
    sts_rdaddr <=   s7_not_ready & "00" & s4_rnf & 
                    s3_crc_error & s2_lost_data & s1_data_request & s0_busy;
    sts_rdsect <=   s7_not_ready & '0' & s5_record_type & s4_rnf & 
                    s3_crc_error & s2_lost_data & s1_data_request & s0_busy;
    sts_rdtrk <=    s7_not_ready & "0000" & s2_lost_data & s1_data_request & s0_busy;
    sts_wrsect <=   s7_not_ready & s6_protected & s5_write_fault & s4_rnf & 
                    s3_crc_error & s2_lost_data & s1_data_request & s0_busy;
    sts_wrtrk <=    s7_not_ready & s6_protected & s5_write_fault & "00" & 
                    s2_lost_data & s1_data_request & s0_busy;

    status_r <= sts_rdsect when STD_MATCH(command_r, CMD_READ_SECTOR) else
                sts_wrsect when STD_MATCH(command_r, CMD_WRITE_SECTOR) else
                sts_rdaddr when STD_MATCH(command_r, CMD_READ_ADDRESS) else
                sts_rdtrk when STD_MATCH(command_r, CMD_READ_TRACK) else
                sts_wrtrk when STD_MATCH(command_r, CMD_WRITE_TRACK) else
                sts_type1;

  end block BLK_STATUS;
  
  -- assign outputs
  hld <= hld_s;
  
end architecture SYN;
