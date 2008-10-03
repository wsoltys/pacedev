library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity wd179x is
  port
  (
    clk           : in std_logic;
    clk_20M_ena   : in std_logic;
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
  signal status_r     		: std_logic_vector(7 downto 0) := (others => '0');
  signal command_r    		: std_logic_vector(7 downto 0) := (others => '0');
  signal track_r      		: std_logic_vector(7 downto 0) := (others => '0');
  signal sector_r     		: std_logic_vector(7 downto 0) := (others => '0');
  signal data_i_r       	: std_logic_vector(7 downto 0) := (others => '0');
  signal data_o_r       	: std_logic_vector(7 downto 0) := (others => '0');

	-- values read from the IDAM
	signal idam_track				: std_logic_vector(track_r'range);
	signal idam_side				: std_logic_vector(7 downto 0);
	signal idam_sector			: std_logic_vector(sector_r'range);
	signal idam_seclen			: std_logic_vector(7 downto 0);

	-- data from the disc read logic
	signal read_data_r					: std_logic_vector(7 downto 0) := (others => '0');
	signal id_addr_mark_rdy			: std_logic := '0';
	signal data_addr_mark_rdy		: std_logic := '0';
	signal raw_data_rdy					: std_logic := '0';
	signal sector_data_rdy			: std_logic := '0';
                        	
  alias cmd           		: std_logic_vector(7 downto 4) is command_r(7 downto 4);
  alias TRK_UPD_F     		: std_logic is command_r(4);
  alias HD_LOAD_F     		: std_logic is command_r(3);

	signal cmd_busy					: std_logic := '0';

  -- register access strobes
  signal data_rd_stb  		: std_logic := '0';
  signal data_wr_stb  		: std_logic := '0';
  signal cmd_wr_stb   		: std_logic := '0';
  signal trk_wr_stb   		: std_logic := '0';
  signal sec_wr_stb   		: std_logic := '0';

	-- command-type strobes
	signal type_i_stb				: std_logic := '0';
	signal type_i_ack				: std_logic := '0';
	signal type_ii_stb			: std_logic := '0';
	signal type_ii_ack			: std_logic := '0';
	signal type_iii_stb			: std_logic := '0';
	signal type_iii_ack			: std_logic := '0';
                      		
  signal step_in_s    		: std_logic := '0';
  signal hld_s        		: std_logic := '0';
  
begin

  -- micro bus interface
  process (clk, clk_20M_ena, reset)
    variable re_n_r   : std_logic := '0';
    variable we_n_r   : std_logic := '0';
  begin
    if reset = '1' then
      re_n_r := '1';
      we_n_r := '1';
    elsif rising_edge(clk) and clk_20M_ena = '1' then
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
            dal_o <= data_o_r;
            data_rd_stb <= '1';
        end case;
      elsif we_n_r = '1' and we_n = '0' then
        -- leading edge write
        case a is
          when "00" =>
            command_r <= dal_i;
            cmd_wr_stb <= '1';
          when "01" =>
            trk_wr_stb <= '1';
          when "10" =>
            sec_wr_stb <= '1';
          when others =>
						data_i_r <= dal_i;
            data_wr_stb <= '1';
        end case;
      end if;
      re_n_r := re_n;
      we_n_r := we_n;
    end if;
  end process;

	-- process command
	BLK_COMMAND : block

		type STATE_t is ( IDLE, WAIT_FOR_CMD );
		signal state : state_t := IDLE;

	begin

		PROC_CMD_SM: process (clk, clk_20M_ena, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				type_i_stb <= '0';
				type_ii_stb <= '0';
				if cmd_wr_stb = '1' and STD_MATCH(cmd, CMD_FORCE_INTERRUPT) then
					-- interrupt state machine
				else
					case state is
						when IDLE =>
							if cmd_wr_stb = '1' then
								if command_r(7) = '0' then
									-- RESTORE, SEEK, STEP, STEP_IN, STEP_OUT
									type_i_stb <= '1';
									state <= WAIT_FOR_CMD;
								elsif command_r(7 downto 6) = "10" then
									-- READ/WRITE SECTOR
									type_ii_stb <= '1';
									state <= WAIT_FOR_CMD;
								end if;
							end if;
						when WAIT_FOR_CMD =>
							if (type_i_ack or type_ii_ack) = '1' then
								state <= IDLE;
							end if;
						when others =>
					end case;
				end if;
			end if;
		end process PROC_CMD_SM;

		-- drive busy status
		cmd_busy <= '1' when mr_n = '0' or state /= IDLE else '0';

	end block BLK_COMMAND;

	BLK_TYPE_I : block

		constant DIRC_OUT		: std_logic := '0';
		constant DIRC_IN		: std_logic := '1';

		type STATE_t is ( IDLE, RESTORE, SEEK, STEPIO, STEP_WAIT, UPDATE, VERIFY, DONE );
		signal state : STATE_t;

	begin

		process (clk, clk_20M_ena, reset)
			variable dirc_v		: std_logic := '0';
			subtype count_t is integer range 0 to 30*20-1;
			variable count		: count_t;
		begin
			if reset = '1' then
				state <= IDLE;
				dirc_v := DIRC_OUT;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				step <= '0';
				type_i_ack <= '0';
				case state is
					when IDLE =>
						if trk_wr_stb = '1' then
							-- cpu writes directly to track register
							track_r <= data_i_r;
						elsif type_i_stb = '1' then
							if STD_MATCH(cmd, CMD_RESTORE) then
								dirc_v := DIRC_OUT;
								state <= RESTORE;
							elsif STD_MATCH(cmd, CMD_SEEK) then
								if track_r < data_i_r then
									dirc_v := DIRC_IN;
								else
									dirc_v := DIRC_OUT;
								end if;
								state <= SEEK;
							elsif STD_MATCH(cmd, CMD_STEP) then
								state <= STEPIO;
							elsif STD_MATCH(cmd, CMD_STEP_IN) then
								dirc_v := DIRC_IN;
								state <= STEPIO;
							elsif STD_MATCH(cmd, CMD_STEP_OUT) then
								dirc_v := DIRC_OUT;
								state <= STEPIO;
							end if;
						end if;
					when RESTORE =>
						if tr00_n = '0' then
							-- always update track on RESTORE command
							track_r <= X"00";
							state <= DONE;
						else
							state <= STEPIO;
						end if;
					when SEEK =>
						if track_r /= data_i_r then
							state <= STEPIO;
						else
							state <= VERIFY;
						end if;
					when STEPIO =>
						step <= '1';
						case command_r(1 downto 0) is
							when "00" =>
								count := 6*20-1;		-- 6ms
							when "01" =>        	
								count := 12*20-1;		-- 12ms
							when "10" =>        	
								count := 20*20-1;		-- 20ms
							when others =>
								count := 30*20-1;		-- 30ms
						end case;
						state <= STEP_WAIT;
					when STEP_WAIT =>
						if count = 0 then
							if STD_MATCH(cmd, CMD_RESTORE) then
								state <= RESTORE;
							elsif STD_MATCH(cmd, CMD_SEEK) then
								if dirc_v = DIRC_IN then
									track_r <= track_r + 1;
								else
									track_r <= track_r - 1;
								end if;
								state <= SEEK;
							else
								state <= UPDATE;
							end if;
						else
							count := count - 1;
						end if;
					when UPDATE =>
						if command_r(4) = '1' then
							if dirc_v = DIRC_IN then
								track_r <= track_r + 1;
							else
								if track_r /= 0 then
									track_r <= track_r - 1;
								end if;
							end if;
						end if;
						state <= VERIFY;
					when VERIFY =>
						-- no verify atm
						state <= DONE;
					when DONE =>
						type_i_ack <= '1';
						state <= IDLE;
					when others =>
						state <= IDLE;
				end case;
			end if;
			-- drive DIRC output
			dirc <= dirc_v;
		end process;

	end block BLK_TYPE_I;

	BLK_TYPE_II : block

		type STATE_t is ( IDLE, WAIT_IDAM, WAIT_DAM, READ_SECTOR, DONE );
		signal state : STATE_t;

	begin

		process (clk, clk_20M_ena, reset)
			subtype count_t is integer range 0 to 256;
			variable count		: count_t;
		begin
			if reset = '1' then
				state <= IDLE;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				type_ii_ack <= '0';
				case state is
					when IDLE =>
						if sec_wr_stb = '1' then
							-- cpu writes directly to sector register
							sector_r <= dal_i;
						elsif type_ii_stb = '1' then
							if STD_MATCH(cmd, CMD_READ_SECTOR) then
								state <= WAIT_IDAM;
							end if;
						end if;
					when WAIT_IDAM =>
						if id_addr_mark_rdy = '1' then
							if idam_sector = sector_r then
								state <= WAIT_DAM;
							end if;
						end if;
					when WAIT_DAM =>
						if data_addr_mark_rdy = '1' then
							count := 0;
							state <= READ_SECTOR;
						end if;
					when READ_SECTOR =>
						if sector_data_rdy = '1' then
							if count = 255 then
								state <= DONE;
							else
								count := count + 1;
							end if;
						end if;
					when DONE =>
						type_ii_ack <= '1';
						state <= IDLE;
					when others =>
						state <= IDLE;
				end case;
			end if;
		end process;

	end block BLK_TYPE_II;

	BLK_READ : block

		alias raw_data_r			: std_logic_vector(read_data_r'range) is read_data_r;

		type STATE_t is 
		(
			UNKNOWN, 
			GAP2_4E, GAP2_00, GAP2_A1, 
			ID_ADDR_MARK, TRACK, SIDE, SECTOR, SEC_LEN, CRC_1,
			GAP3_4E, GAP3_00, GAP3_A1,
			DAM, USER_DATA, CRC_2
		);
		signal state					: STATE_t;

		-- values read from the disk
		signal crc						: std_logic_vector(15 downto 0);
		signal rd_dam					: std_logic_vector(7 downto 0);

	begin

		-- reads raw data from drive continuously
		-- note that there is no bit/byte synchronisation atm
		-- so drive emulation must be 'in sync'
		PROC_RAW_READ: process (clk, clk_20M_ena, reset)
			variable rclk_r : std_logic := '0';
			variable count 	: std_logic_vector(2 downto 0) := (others => '0');
			variable data_v	: std_logic_vector(7 downto 0) := (others => '0');
		begin
			if reset = '1' then
				rclk_r := '0';
				count := (others => '0');
				data_v := (others => '0');
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				raw_data_rdy <= '0'; -- default
				-- leading edge RCLK
				if rclk_r = '0' and rclk = '1' then
					data_v := data_v(data_v'left-1 downto 0) & '0';
				-- trailing edge rclk
				elsif rclk_r = '1' and rclk = '0' then
					if count = "111" then
						-- finished a byte
						read_data_r <= data_v;
						raw_data_rdy <= '1';
					end if;
					count := count + 1;
				end if;
				-- sample RAW_DATA_n during RCLK high
				if rclk = '1' then
					if raw_read_n = '0' then
						data_v(0) := '1';
					end if;
				end if;
				rclk_r := rclk;
			end if;
		end process PROC_RAW_READ;

		-- reads address mark and flags start of sector
		PROC_I_DAM: process (clk, clk_20M_ena, reset)
			variable count : integer range 0 to 511 := 0;
		begin
			if reset = '1' then
				state <= UNKNOWN;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				id_addr_mark_rdy <= '0'; 		-- default
				data_addr_mark_rdy <= '0';	-- default;
				sector_data_rdy <= '0'; 		-- default
				if raw_data_rdy = '1' then
					case state is
						when UNKNOWN =>
							count := 0;
							state <= GAP2_4E;
						when GAP2_4E =>
							-- at least 22 bytes of $4E
							if raw_data_r = X"4E" then
								count := count + 1;
							elsif raw_data_r = X"00" and count >= 22 then
								count := 1;
								state <= GAP2_00;
							else
								state <= UNKNOWN;
							end if;
						when GAP2_00 =>
							-- exactly 12 bytes of $00
							if raw_data_r = X"00" then
								count := count + 1;
								if count = 12 then
									count := 0;
									state <= GAP2_A1;
								end if;
							else
								state <= UNKNOWN;
							end if;
						when GAP2_A1 =>
							-- exactly 3 bytes of $A1
							if raw_data_r = X"A1" then
								count := count + 1;
								if count = 3 then
									state <= ID_ADDR_MARK;
								end if;
							else
								state <= UNKNOWN;
							end if;
						when ID_ADDR_MARK =>
							if raw_data_r = X"FE" then
								state <= TRACK;
							else
								state <= UNKNOWN;
							end if;
						when TRACK =>
							idam_track <= raw_data_r;
							state <= SIDE;
						when SIDE =>
							idam_side <= raw_data_r;
							state <= SECTOR;
						when SECTOR =>
							idam_sector <= raw_data_r;
							state <= SEC_LEN;
						when SEC_LEN =>
							idam_seclen <= raw_data_r;
							count := 0;
							state <= CRC_1;
						when CRC_1 =>
							crc <= crc(7 downto 0) & raw_data_r;
							count := count + 1;
							if count = 2 then
								-- really need to check CRC here first
								id_addr_mark_rdy <= '1';
								count := 0;
								state <= GAP3_4E;
							end if;
						when GAP3_4E =>
							if raw_data_r = X"4E" then
								count := count + 1;
							elsif raw_data_r = X"00" and count >= 22 then		-- 24?
								count := 1;
								state <= GAP3_00;
							else
								state <= UNKNOWN;
							end if;
						when GAP3_00 =>
							if raw_data_r = X"00" then
								count := count + 1;
							elsif raw_data_r = X"A1" and count >= 8 then
								count := 1;
								state <= GAP3_A1;
							else
								state <= UNKNOWN;
							end if;
						when GAP3_A1 =>
							if raw_data_r = X"A1" then
								count := count + 1;
								if count = 3 then
									state <= DAM;
								end if;
							else
								state <= UNKNOWN;
							end if;
						when DAM =>
							rd_dam <= raw_data_r;
							data_addr_mark_rdy <= '1';
							count := 0;
							state <= USER_DATA;
						when USER_DATA =>
							-- reading user sector data
							count := count + 1;
							if idam_sector = sector_r then
								sector_data_rdy <= '1';
							end if;
							if count = 256 then
								count := 0;
								state <= CRC_2;
							end if;
						when CRC_2 =>
							crc <= crc(7 downto 0) & raw_data_r;
							count := count + 1;
							if count = 2 then
								state <= UNKNOWN;
							end if;
						when others =>
							state <= UNKNOWN;
					end case;
				end if;
			end if;
		end process PROC_I_DAM;

	end block BLK_READ;

  BLK_STATUS : block

    signal sts_type1      		: std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdaddr     		: std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdsect     		: std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdtrk      		: std_logic_vector(7 downto 0) := (others => '0');
    signal sts_wrsect     		: std_logic_vector(7 downto 0) := (others => '0');
    signal sts_wrtrk      		: std_logic_vector(7 downto 0) := (others => '0');
                          		
    -- type I commands    		
    signal s7_not_ready   		: std_logic := '0';
    signal s6_protected   		: std_logic := '0';
    signal s5_head_loaded 		: std_logic := '0';
    signal s4_seek_error  		: std_logic := '0';
    signal s3_crc_error   		: std_logic := '0';
    signal s2_track_00    		: std_logic := '0';
    signal s1_index       		: std_logic := '0';
    signal s0_busy        		: std_logic := '0';
    
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
    
		s0_busy <= cmd_busy;

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
