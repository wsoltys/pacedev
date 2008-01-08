--------------------------------------------------------------------------------
-- SubModule FDC_Regs
-- Created   19/08/2005 1:41:15 PM
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.std_match;

entity FDC_regs is 
	port
    (
      clk            : in   std_logic;
      reset          : in   std_logic;

      -- CPU interface
      fdc_addr        : in  std_logic_vector(2 downto 0);
      fdc_datai       : in  std_logic_vector(7 downto 0);
      fdc_datao       : out std_logic_vector(7 downto 0);
      fdc_rd          : in  std_logic;
      fdc_wr          : in  std_logic;

      -- input signal s
      not_ready       : in  std_logic;
      wp              : in  std_logic;
      hd_loaded       : in  std_logic;
      seek_err        : in  std_logic;
      crc_err         : in  std_logic;
      trk_0           : in  std_logic;
      idx_pulse       : in  std_logic;
      busy            : in  std_logic;
      rnf             : in  std_logic;
      lost_data       : in  std_logic;
      drq             : in  std_logic;
      rec_type        : in  std_logic_vector(1 downto 0);
      wr_fault        : in  std_logic;

      data_i          : in  std_logic_vector(7 downto 0);
      data_i_stb      : in  std_logic;
      
      -- output signals
      command         : out std_logic_vector(7 downto 0);
      drive           : out std_logic_vector(1 downto 0);
      track           : out std_logic_vector(7 downto 0);
      sector          : out std_logic_vector(7 downto 0);
      data_o          : out std_logic_vector(7 downto 0);

      cmd_wr_stb      : out std_logic;
      data_rd_stb     : out std_logic;
      data_wr_stb     : out std_logic
   );
end FDC_regs;

architecture SYN of FDC_regs is

  -- Component Declarations

  -- Constants

  constant CMD_REG_ADDR     : std_logic_vector(2 downto 0) := "000";
  constant STATUS_REG_ADDR  : std_logic_vector(2 downto 0) := "000";
  constant TRK_REG_ADDR     : std_logic_vector(2 downto 0) := "001";
  constant SECT_REG_ADDR    : std_logic_vector(2 downto 0) := "010";
  constant DATA_REG_ADDR    : std_logic_vector(2 downto 0) := "011";
  constant SEL_REG_ADDR     : std_logic_vector(2 downto 0) := "100";

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

  alias    CMD                  : std_logic_vector(7 downto 4) is fdc_datai(7 downto 4);
  alias    TRK_UPD_F            : std_logic is fdc_datai(4);
  alias    HD_LOAD_F            : std_logic is fdc_datai(3);
        
  -- Signal Declarations
  
  -- registers
  signal reg_cmd            : std_logic_vector(7 downto 0);   -- $F0
  signal reg_status         : std_logic_vector(7 downto 0);   -- $F0
  signal reg_trk            : std_logic_vector(7 downto 0);   -- $F1
  signal reg_sect           : std_logic_vector(7 downto 0);   -- $F2
  signal reg_data           : std_logic_vector(7 downto 0);   -- $F3
  signal reg_sel            : std_logic_vector(7 downto 0);   -- $F4
                            
  -- status register        
  signal stat_type1         : std_logic_vector(7 downto 0);
  signal stat_rdaddr        : std_logic_vector(7 downto 0);
  signal stat_rdsect        : std_logic_vector(7 downto 0);
  signal stat_rdtrk         : std_logic_vector(7 downto 0);
  signal stat_wrsect        : std_logic_vector(7 downto 0);
  signal stat_wrtrk         : std_logic_vector(7 downto 0);

  signal step_in            : std_logic;  -- current step direction  

begin

  -- wire up status register
  stat_type1 <= not_ready & wp & hd_loaded & seek_err & crc_err & trk_0 & idx_pulse & busy;
  stat_rdaddr <= not_ready & "00" & rnf & crc_err & lost_data & drq & busy;
  stat_rdsect <= not_ready & rec_type & rnf & crc_err & lost_data & drq & busy;
  stat_rdtrk <= not_ready & "0000" & lost_data & drq & busy;
  stat_wrsect <= not_ready & wp & wr_fault & rnf & crc_err & lost_data & drq & busy;
  stat_wrtrk <= not_ready & wp & wr_fault & "00" & lost_data & drq & busy;

  reg_status <= stat_rdsect when reg_cmd(7 downto 5) = "100" else
                stat_wrsect when reg_cmd(7 downto 5) = "101" else
                stat_rdaddr when reg_cmd(7 downto 4) = "1100" else
                stat_rdtrk when reg_cmd(7 downto 4)  = "1110" else
                stat_wrtrk when reg_cmd(7 downto 4)  = "1111" else
                stat_type1;
  
  -- wire up outputs to the controller module
  command <= reg_cmd;
  drive <=  "00" when reg_sel(3 downto 0) = "0001" else
            "01" when reg_sel(3 downto 0) = "0010" else
            "10" when reg_sel(3 downto 0) = "0100" else
            "11";
  track <= reg_trk;
  sector <= reg_sect;
  data_o <= reg_data;
        
  process (clk, reset)
    variable fdc_rd_last_v  : std_logic;
    variable fdc_wr_last_v  : std_logic;
    variable cmd_wr_stb_v   : std_logic;
    variable data_rd_stb_v  : std_logic;
    variable data_wr_stb_v  : std_logic;
  begin
    if reset = '1' then
      fdc_rd_last_v := '0';
      fdc_wr_last_v := '0';
      data_rd_stb_v := '0';

      fdc_datao <= (others => '0');
            
      reg_cmd <= (others => '0');
      reg_trk <= (others => '0');
      reg_sect <= (others => '0');
      reg_data <= (others => '0');
      reg_sel <= (others => '0');
      step_in <= '1';
      
    elsif rising_edge(clk) then

      -- default strobe values
      cmd_wr_stb_v := '0';
      data_rd_stb_v := '0';
      data_wr_stb_v := '0';
      
      -- start of an fdc register read
			if fdc_rd = '1' and fdc_rd_last_v = '0' then
        case fdc_addr is
          when STATUS_REG_ADDR =>
            fdc_datao <= reg_status;
          when TRK_REG_ADDR =>
            fdc_datao <= reg_trk;
          when SECT_REG_ADDR =>
            fdc_datao <= reg_sect;
          when DATA_REG_ADDR =>
            fdc_datao <= reg_data;
            data_rd_stb_v := '1';
          -- WTF???
          when others =>
            fdc_datao <= (others => '0');
        end case;

      -- start of an fdc register write
      elsif fdc_wr = '1' and fdc_wr_last_v = '0' then
        case fdc_addr is
          when CMD_REG_ADDR =>
            reg_cmd <= fdc_datai;
            cmd_wr_stb_v := '1';
            -- some commands update the registers
            if STD_MATCH(CMD, CMD_RESTORE) then
              reg_trk <= (others => '0');
            elsif STD_MATCH(CMD, CMD_SEEK) then
              reg_trk <= reg_data;
            elsif STD_MATCH(CMD, CMD_STEP) then
              -- only update track register if 'T' bit is set
              if TRK_UPD_F = '1' then
                if step_in = '1' then
                  reg_trk <= reg_trk + 1;
                else
                  -- don't step out past track 0
                  if reg_trk /= X"00" then
                    reg_trk <= reg_trk - 1;
                  end if;
                end if;
              end if;
            elsif STD_MATCH(CMD, CMD_STEP_IN) then
              -- only update track register if 'T' bit set.
              if TRK_UPD_F = '1' then
                reg_trk <= reg_trk + 1;
              end if;
              step_in <= '1';
            elsif STD_MATCH(CMD, CMD_STEP_OUT) then
              -- only update track register if 'T' bit set.
              if TRK_UPD_F = '1' then
                -- don't step out past track 0
                if reg_trk /= X"00" then
                  reg_trk <= reg_trk - 1;
                end if;
              end if;
              step_in <= '0';
            end if;
          when TRK_REG_ADDR =>
            reg_trk <= fdc_datai;
          when SECT_REG_ADDR =>
            reg_sect <= fdc_datai;
          when DATA_REG_ADDR =>
            reg_data <= fdc_datai;
            data_wr_stb_v := '1';
          -- WTF???
          when SEL_REG_ADDR =>
            reg_sel <= fdc_datai;
          when others =>
            null;
        end case;

			end if;

      -- disk read data is available
      if data_i_stb = '1' then
        reg_data <= data_i;
      end if;

      fdc_rd_last_v := fdc_rd;
      fdc_wr_last_v := fdc_wr;
    end if;

    -- assign outputs
    cmd_wr_stb <= cmd_wr_stb_v;
    data_rd_stb <= data_rd_stb_v;
    data_wr_stb <= data_wr_stb_v;

  end process;

  -- component instantiations

end SYN;
