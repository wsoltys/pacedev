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
    dden_n        : in std_logic;

		-- temp fudge!!!
		wr_dat_o			: out std_logic_vector(7 downto 0);
    
    debug         : out std_logic_vector(31 downto 0)
  );
end entity wd179x;

architecture SYN of wd179x is

  -- build options
  constant ENABLE_CRC           : boolean := true;
  
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
  signal track_i_r      	: std_logic_vector(7 downto 0) := (others => '0');
  signal sector_r     		: std_logic_vector(7 downto 0) := (others => '0');
  signal sector_i_r     	: std_logic_vector(7 downto 0) := (others => '0');
  signal data_i_r       	: std_logic_vector(7 downto 0) := (others => '0');
  signal data_o_r       	: std_logic_vector(7 downto 0) := (others => '0');

  alias TRK_UPD_F     		: std_logic is command_r(4);
	alias MULTI_REC_F				: std_logic is command_r(4);
  alias HD_LOAD_F     		: std_logic is command_r(3);
	alias SIDE_CMP_F				: std_logic is command_r(3);
	alias VERIFY_F					: std_logic is command_r(2);
	alias DELAY_15ms_F			: std_logic is command_r(2);
	alias SIDE_CMP_EN_F			: std_logic is command_r(1);
	alias DAM_F							: std_logic is command_r(0);
	alias STEP_RATE					: std_logic_vector(1 downto 0) is command_r(1 downto 0);
  alias cmd           		: std_logic_vector(7 downto 4) is command_r(7 downto 4);

  function crc16 (dat_i : in std_logic; 
                  crc_i : in std_logic_vector(15 downto 0)) 
            return std_logic_vector is
  begin
    -- CRC(x) = x^16 + x^12 + x^5 + 1
    return crc_i(14 downto 12) & (dat_i xor crc_i(11) xor crc_i(15)) & crc_i(10 downto 5) &
            (dat_i xor crc_i(4) xor crc_i(15)) & crc_i(3 downto 0) & (dat_i xor crc_i(15));
  end;

  -- interrupts
  signal irq_mask         : std_logic_vector(3 downto 0) := (others => '0');
  signal irq_set          : std_logic := '0';
  signal irq_clr          : std_logic := '0';

  -- data request
  signal drq_s            : std_logic := '0';
  signal drq_clr          : std_logic := '0';

	-- index pulse
	signal type_i_ip_clr		: std_logic := '0';
	signal type_ii_ip_clr		: std_logic := '0';

	-- values read from the IDAM
	signal idam_track				: std_logic_vector(track_r'range);
	signal idam_side				: std_logic_vector(7 downto 0);
	signal idam_sector			: std_logic_vector(sector_r'range);
	signal idam_seclen			: std_logic_vector(7 downto 0);
	signal idam_dam					: std_logic_vector(7 downto 0);
  -- calculated and latched
  signal rd_crc         	: std_logic_vector(15 downto 0);
  signal wr_crc         	: std_logic_vector(15 downto 0);
  signal type_ii_wr_crc_preset		: std_logic;
  signal type_iii_wr_crc_preset		: std_logic;

	-- data from the disc read logic
	signal read_data_r					: std_logic_vector(7 downto 0) := (others => '0');
	signal id_addr_mark_rdy			: std_logic := '0';
	signal data_addr_mark_nxt		: std_logic := '0';
	signal data_addr_mark_rdy		: std_logic := '0';
	signal raw_data_rdy					: std_logic := '0';
	signal addr_data_rdy        : std_logic := '0';
	signal user_data_rdy			  : std_logic := '0';
	signal user_crc_rdy			    : std_logic := '0';

	-- data to the disk write logic
	signal write_data_written		: std_logic := '0';
                        	
	signal cmd_busy					: std_logic := '0';
  signal latch_status     : std_logic := '0';

  -- register access strobes
  signal data_wr_stb  		: std_logic := '0';
  signal cmd_wr_stb   		: std_logic := '0';
  signal trk_wr_stb   		: std_logic := '0';
  signal sec_wr_stb   		: std_logic := '0';

	-- command-type strobes
	signal type_i_stb				: std_logic := '0';
	signal type_i_ack				: std_logic := '0';
	signal type_ii_stb			: std_logic := '0';
	signal type_ii_drq      : std_logic := '0';
	signal type_ii_ack			: std_logic := '0';
	signal type_iii_stb			: std_logic := '0';
	signal type_iii_drq     : std_logic := '0';
	signal type_iii_ack			: std_logic := '0';
	signal type_iv_stb			: std_logic := '0';

	signal seek_error				: std_logic := '0';
	signal rnf_error				: std_logic := '0';
	signal crc_error				: std_logic := '0';
                        		
  signal step_s           : std_logic := '0';
  signal hld_s        		: std_logic := '0';
	signal type_ii_wg				: std_logic := '0';
	signal type_iii_wg			: std_logic := '0';

  signal wr_dat_s        	: std_logic_vector(7 downto 0) := (others => '0');
  signal trk_dat_o        : std_logic_vector(wr_dat_s'range) := (others => '0');
  signal sec_dat_o        : std_logic_vector(wr_dat_s'range) := (others => '0');
  
begin

  -- micro bus interface
  process (clk, clk_20M_ena, reset)
    variable re_n_r   : std_logic := '0';
    variable we_n_r   : std_logic := '0';
  begin
    if reset = '1' then
      irq_clr <= '0';
      drq_clr <= '0';
      re_n_r := '1';
      we_n_r := '1';
    elsif rising_edge(clk) and clk_20M_ena = '1' then
      -- default values
      irq_clr <= '0';
      drq_clr <= '0';
      data_wr_stb <= '0';
      cmd_wr_stb <= '0';
      trk_wr_stb <= '0';
      sec_wr_stb <= '0';
      if mr_n = '0' then
        -- master reset
      else
        -- drive read data
        case a is
          when "00" =>
            dal_o <= status_r;
          when "01" =>
            dal_o <= track_r;
          when "10" =>
            dal_o <= sector_r;
          when others =>
            dal_o <= data_o_r;
        end case;
        if cs_n = '0' and re_n_r = '1' and re_n = '0' then
          -- reading (leading edge)
          case a is
            when "00" =>
              irq_clr <= '1';
            when "11" =>
              drq_clr <= '1';
            when others =>
              null;
          end case;
        elsif cs_n = '0' and we_n_r = '1' and we_n = '0' then
          -- leading edge write
          case a is
            when "00" =>
              command_r <= dal_i;
              irq_clr <= '1';
              cmd_wr_stb <= '1';
            when "01" =>
              track_i_r <= dal_i;
              trk_wr_stb <= '1';
            when "10" =>
              sector_i_r <= dal_i;
              sec_wr_stb <= '1';
            when others =>
  						data_i_r <= dal_i;
							drq_clr <= '1';
              data_wr_stb <= '1';
          end case;
        end if;
        -- need a delayed IRQ_CLR for FORCE_INTERRUPT command
        if type_iv_stb = '1' then
          irq_clr <= '1';
        end if;
      end if;
      we_n_r := we_n;
    end if;
  end process;

  BLK_IRQ : block
  begin
    -- INTRQ output is open-drain
    PROC_IRQ : process (clk, clk_20M_ena, reset)
    begin
      if reset = '1' then
        intrq <= '0';
      elsif rising_edge(clk) and clk_20M_ena = '1' then
        if irq_set = '1' then
          intrq <= '1';
        elsif irq_clr = '1' then
          intrq <= '0';
        end if;
      end if;
    end process PROC_IRQ;

    -- interrupt logic
    process (clk, clk_20M_ena, reset)
      variable ip_r     : std_logic := '0';
      variable ready_r  : std_logic := '0';
    begin
      if reset = '1' then
        irq_set <= '0';
        ip_r := '0';
        ready_r := '0';
      elsif rising_edge(clk) and clk_20M_ena = '1' then
        irq_set <= '0'; -- default
          -- immediate
        if irq_mask(3) = '1' or
          -- leading edge of index pulse
          (ip_r = '0' and ip_n = '0' and irq_mask(2) = '1') or
          -- ready to not ready transition
          (ready_r = '1' and ready = '0' and irq_mask(1) = '1') or
          -- not ready to ready transition
          (ready_r = '0' and ready = '1' and irq_mask(0) = '1') or
          -- end of command
          ((type_i_ack or type_ii_ack or type_iii_ack) = '1') then
          irq_set <= '1';
        end if;
        -- pipeline
        ip_r := not ip_n;
        ready_r := ready;
      end if;
    end process;

  end block BLK_IRQ;

  BLK_DRQ : block

  begin
  
    -- DRQ output is open-drain
    PROC_DRQ : process (clk, clk_20M_ena, reset)
    begin
      if reset = '1' then
        drq_s <= '0';
      elsif rising_edge(clk) and clk_20M_ena = '1' then
        if (type_ii_drq or type_iii_drq) = '1' then
          drq_s <= '1';
        elsif drq_clr = '1' then
          drq_s <= '0';
        end if;
      end if;
    end process PROC_DRQ;

    -- drive pin
    drq <= drq_s;

  end block BLK_DRQ;

	BLK_IP : block
    signal ip_cnt   : std_logic_vector(3 downto 0) := (others => '0');
	begin

		-- count index pulses
		PROC_IP : process (clk, clk_20M_ena, reset)
			variable ip_r : std_logic := '0';
		begin
			if reset = '1' then
        ip_cnt <= (others => '0');
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				if (type_i_ip_clr or type_ii_ip_clr) = '1' then
					ip_cnt <= (others => '0');
				-- leading edge IPn
				elsif ip_r = '0' and ip_n = '0' then
					ip_cnt <= ip_cnt + 1;
				end if;
				ip_r := not ip_n;
			end if;
		end process PROC_IP;

    -- only valid for read address, read/write sector
    rnf_error <= '0' when ip_cnt < 5 else '1';

	end block BLK_IP;

	-- process command
	BLK_COMMAND : block

		type STATE_t is ( IDLE, WAIT_FOR_CMD );
		signal state : state_t := IDLE;

	begin

		PROC_CMD_SM: process (clk, clk_20M_ena, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				type_i_stb <= '0';    -- default
				type_ii_stb <= '0';   -- default
				type_iii_stb <= '0';  -- default
			  type_iv_stb <= '0';   -- default
			  latch_status <= '0';  -- default
				if cmd_wr_stb = '1' and STD_MATCH(cmd, CMD_FORCE_INTERRUPT) then
					-- TYPE IV - FORCE_INTERRUPT
          irq_mask <= command_r(3 downto 0);
				  type_iv_stb <= '1';
          state <= IDLE;
				else
					case state is
						when IDLE =>
							if cmd_wr_stb = '1' then
								if command_r(7) = '0' then
									-- TYPE I - RESTORE, SEEK, STEP, STEP_IN, STEP_OUT
									type_i_stb <= '1';
									state <= WAIT_FOR_CMD;
								elsif command_r(7 downto 6) = "10" then
									-- TYPE II - READ/WRITE SECTOR
									type_ii_stb <= '1';
									state <= WAIT_FOR_CMD;
								elsif command_r(7 downto 6) = "11" then
                  -- type III - READ ADDRESS, READ/WRITE TRACK
                  type_iii_stb <= '1';
                  state <= WAIT_FOR_CMD;
								end if;
							end if;
						when WAIT_FOR_CMD =>
							if (type_i_ack or type_ii_ack or type_iii_ack) = '1' then
                latch_status <= '1';
								state <= IDLE;
							end if;
						when others =>
              state <= IDLE;
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

		type STATE_t is ( IDLE, RESTORE, SEEK, STEPIO, STEP_WAIT, UPDATE, VERIFY, VERIFY_WAIT_IDAM, VERIFY_IDAM, DONE );
		signal state : STATE_t;

	begin

		PROC_TYPE_I: process (clk, clk_20M_ena, reset)
			variable curr_track	: std_logic_vector(track_r'range) := (others => '0');
			variable dirc_v			: std_logic := '0';
			subtype count_t is integer range 0 to 30*20-1;
			variable count			: count_t;
		begin
			if reset = '1' then
				curr_track := (others => '0');
				track_r <= (others => '0');
				seek_error <= '0';
				state <= IDLE;
				dirc_v := DIRC_OUT;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				step_s <= '0';				  -- default
				type_i_ip_clr <= '0';	  -- default
				type_i_ack <= '0';		  -- default
				if trk_wr_stb = '1' then
					-- cpu writes directly to track register
					track_r <= track_i_r;
				end if;
        if type_iv_stb = '1' then
          state <= IDLE;
        else
  				case state is
  					when IDLE =>
  						if type_i_stb = '1' then
								curr_track := track_r;
								seek_error <= '0';
  							if STD_MATCH(cmd, CMD_RESTORE) then
  								dirc_v := DIRC_OUT;
  								state <= RESTORE;
  							elsif STD_MATCH(cmd, CMD_SEEK) then
  								if curr_track < data_i_r then
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
                else
                  state <= DONE;
  							end if;
  						end if;
  					when RESTORE =>
  						if tr00_n = '0' then
								curr_track := X"00";
  							-- always update track on RESTORE command
  							track_r <= curr_track;
  							state <= VERIFY;
  						else
  							state <= STEPIO;
  						end if;
  					when SEEK =>
							-- NOTE: do we update track_r here while seeking?
							-- what happens when seek is aborted by FORCE_INTERRUPT?
  						if curr_track /= data_i_r then
  							state <= STEPIO;
  						else
								-- NOTE: update flag always set in SEEK command
  							state <= UPDATE;
  						end if;
  					when STEPIO =>
  						step_s <= '1';
							-- update current track
							if dirc_v = DIRC_IN then
								curr_track := curr_track + 1;
							elsif curr_track /= 0 then
                curr_track := curr_track - 1;
							end if;
  						case STEP_RATE is
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
  								state <= SEEK;
  							else
  								state <= UPDATE;
  							end if;
  						else
  							count := count - 1;
  						end if;
  					when UPDATE =>
  						if TRK_UPD_F = '1' then
								track_r <= curr_track;
  						end if;
  						state <= VERIFY;
  					when VERIFY =>
							type_i_ip_clr <= '1';
							state <= VERIFY_WAIT_IDAM;
  					when VERIFY_WAIT_IDAM =>
							if rnf_error = '1' then
								seek_error <= '1';
								state <= DONE;
							elsif VERIFY_F = '1' then
								if id_addr_mark_rdy = '1' then
									state <= VERIFY_IDAM;
								end if;
							else
								state <= DONE;
							end if;
						when VERIFY_IDAM =>
							-- wait until next IDAM read
							if rnf_error = '1' then
								seek_error <= '1';
								state <= DONE;
							elsif id_addr_mark_rdy = '1' then
								if curr_track = idam_track then
  								state <= DONE;
								end if;
							end if;
  					when DONE =>
  						type_i_ack <= '1';
  						state <= IDLE;
  					when others =>
  						state <= DONE;
  				end case;
        end if;
			end if;
			-- drive DIRC output
			dirc <= dirc_v;
		end process PROC_TYPE_I;

	end block BLK_TYPE_I;

	BLK_TYPE_II : block

		type STATE_t is ( IDLE, 
                      WAIT_IDAM, WAIT_DAM, 
                      READ_SECTOR, WAIT_CRC,
                      WRITE_SECTOR_DAM, WRITE_SECTOR_DATA, 
                      DONE );
		signal state : STATE_t;

	begin

		process (clk, clk_20M_ena, reset)
			subtype count_t is integer range 0 to 255;
			variable count		: count_t;
			variable wdw_r    : std_logic := '0';
		begin
			if reset = '1' then
				type_ii_wr_crc_preset <= '0';
				type_ii_drq <= '0';
				type_ii_ack <= '0';
				type_ii_ip_clr <= '0';
				type_ii_wg <= '0';
				wdw_r := '0';
				state <= IDLE;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				type_ii_wr_crc_preset <= '0';		-- default
        type_ii_drq <= '0';     				-- default
				type_ii_ack <= '0';     				-- default
				type_ii_ip_clr <= '0';  				-- default
        if type_iv_stb = '1' then
          state <= IDLE;
        else
  				case state is
  					when IDLE =>
  						if type_ii_stb = '1' then
                type_ii_ip_clr <= '1';
                state <= WAIT_IDAM;
  						end if;
  					when WAIT_IDAM =>
              if rnf_error = '1' then
                state <= DONE;
  						elsif id_addr_mark_rdy = '1' then
  							if idam_sector = sector_r then
                  if STD_MATCH(cmd, CMD_WRITE_SECTOR) then
                    type_ii_drq <= '1';
                  end if;
  								state <= WAIT_DAM;
  							end if;
  						end if;
  					when WAIT_DAM =>
              count := 0;
              if rnf_error = '1' then
                state <= DONE;
              elsif data_addr_mark_nxt = '1' and STD_MATCH(cmd, CMD_WRITE_SECTOR) then
                type_ii_wg <= '1';
                state <= WRITE_SECTOR_DAM;
              elsif data_addr_mark_rdy = '1' and STD_MATCH(cmd, CMD_READ_SECTOR) then
                state <= READ_SECTOR;
              end if;
  					when READ_SECTOR =>
              if user_data_rdy = '1' then
                type_ii_drq <= '1';
                if count = 255 then
                  state <= WAIT_CRC;
                else
                  count := count + 1;
                end if;
  						end if;
  					when WAIT_CRC =>
              if user_crc_rdy <= '1' then
                state <= DONE;
              end if;
            when WRITE_SECTOR_DAM =>
              -- calculate DAM to write
              sec_dat_o <= "111110" & not command_r(0) & not command_r(0);
              if wdw_r = '0' and write_data_written = '1' then
                state <= WRITE_SECTOR_DATA;
              end if;
            when WRITE_SECTOR_DATA =>
              sec_dat_o <= data_i_r;
              if wdw_r = '0' and write_data_written = '1' then
                if count = 255 then
                  state <= DONE;
                else
                  -- data register empty
                  type_ii_drq <= '1';
                  count := count + 1;
                end if;
              end if;
  					when DONE =>
              type_ii_wg <= '0';
              type_ii_ack <= '1';
              state <= IDLE;
  					when others =>
  						state <= DONE;
  				end case;
        end if;
        wdw_r := write_data_written;
			end if;
		end process;

	end block BLK_TYPE_II;

	BLK_TYPE_III : block

		type STATE_t is ( IDLE, 
                      READ_ADDR_WAIT, READ_ADDR, 
                      WAIT_TRACK, 
                      READ_TRACK, 
                      WRITE_TRACK, WRITE_BYTE,
                      DONE );
		signal state : STATE_t;

	begin

		PROC_TYPE_III: process (clk, clk_20M_ena, reset)
      variable ip_r   				: std_logic := '0';
      variable wdw_r  				: std_logic := '0';
      variable is_crc 				: std_logic := '0';
      variable is_crc_preset	: std_logic := '0';
      variable wr_crc_latched	: std_logic_vector(15 downto 0) := (others => '1');
      variable count  				: integer range 0 to 31;
		begin
			if reset = '1' then
				ip_r := '0';
        wdw_r := '0';
        is_crc := '0';
				sector_r <= (others => '0');
				type_iii_wr_crc_preset <= '0';
				type_iii_drq <= '0';
				type_iii_ack <= '0';
				state <= IDLE;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				type_iii_wr_crc_preset <= '0';	-- default;
        type_iii_drq <= '0';  					-- default
        type_iii_ack <= '0';  					-- default
				if sec_wr_stb = '1' then
					-- cpu writes directly to sector register
					sector_r <= sector_i_r;
				end if;
        if type_iv_stb = '1' then
          state <= IDLE;
        else
          case state is
            when IDLE =>
              if type_iii_stb = '1' then
                if STD_MATCH(cmd, CMD_READ_ADDRESS) then
                  state <= READ_ADDR_WAIT;
                elsif STD_MATCH(cmd, CMD_READ_TRACK) then
                  state <= WAIT_TRACK;
                elsif STD_MATCH(cmd, CMD_WRITE_TRACK) then
                  if wprt_n = '0' then
                    state <= DONE;
                  else
                    type_iii_drq <= '1';
                    state <= WAIT_TRACK;
                  end if;
                else
                  state <= DONE;
                end if;
              end if;
            when READ_ADDR_WAIT =>
              if id_addr_mark_rdy = '1' then
                state <= READ_ADDR;
              end if;
            when READ_ADDR =>
              if addr_data_rdy = '1' then
                type_iii_drq <= '1';
              end if;
              if id_addr_mark_rdy = '1' then
								-- TRACK gets written to SECTOR register according to datasheet
								sector_r <= idam_track;
                state <= DONE;
              end if;
            when WAIT_TRACK =>
              if ip_r = '0' and ip_n = '0' then
                -- rising edge IPn (start of pulse)
                if STD_MATCH(cmd, CMD_READ_TRACK) then
                  state <= READ_TRACK;
                else
									type_iii_wg <= '1';
									is_crc := '0';
                  state <= WRITE_TRACK;
                end if;
              end if;
            when READ_TRACK =>
              if ip_r = '0' and ip_n = '0' then
                -- falling edge of IPn (start of next pulse)
                state <= done;
              elsif raw_data_rdy = '1' then
                type_iii_drq <= '1';
              end if;
            when WRITE_TRACK =>
              if ip_r = '0' and ip_n = '0' then
                -- falling edge of IPn (start of next pulse)
                state <= DONE;
              else
                case data_i_r is
                  when X"F5" =>
										if is_crc_preset = '0' then
											type_iii_wr_crc_preset <= '1';
											is_crc_preset := '1';
										end if;
                    trk_dat_o <= X"A1";
                  when X"F6" =>
                    trk_dat_o <= X"C2";
                  when X"F7" =>
                    -- generates 2 bytes!
										if is_crc = '0' then
											wr_crc_latched := wr_crc;
										end if;
										is_crc := not is_crc;
										trk_dat_o <= wr_crc_latched(15 downto 8);
                  	wr_crc_latched := wr_crc_latched(7 downto 0) & X"00";
                  when others =>
                    trk_dat_o <= data_i_r;
                end case;
								if data_i_r /= X"F5" then
									is_crc_preset := '0';
								end if;
								if data_i_r /= X"F7" then
                  is_crc := '0';
                end if;
                -- don't assert DRQ mid-CRC
                type_iii_drq <= not is_crc;
                state <= WRITE_BYTE;
              end if;
            when WRITE_BYTE =>
              if ip_r = '0' and ip_n = '0' then
                state <= DONE;
              elsif wdw_r = '0' and write_data_written = '1' then
                state <= WRITE_TRACK;
              end if;
            when DONE =>
              type_iii_wg <= '0';
              type_iii_ack <= '1';
              state <= IDLE;
            when others =>
              state <= DONE;
          end case;
        end if;
        ip_r := not ip_n;
        wdw_r := write_data_written;
      end if;
    end process PROC_TYPE_III;
    
  end block BLK_TYPE_III;

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
		signal crc						: std_logic_vector(15 downto 0) := (others => '0');
    signal crc_preset     : std_logic := '0';
    signal crc_latch      : std_logic := '0';

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
        crc <= (others => '1');
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				raw_data_rdy <= '0'; -- default
				-- leading edge RCLK
				if rclk_r = '0' and rclk = '1' then
					data_v := data_v(data_v'left-1 downto 0) & '0';
				-- trailing edge rclk
				elsif rclk_r = '1' and rclk = '0' then
          crc <= crc16(data_v(0), crc);
					if count = "111" then
						-- finished a byte
						read_data_r <= data_v;
						--read_data_r <= data_v(0) & data_v(1) & data_v(2) & data_v(3) & data_v(4) & data_v(5) & data_v(6) & data_v(7);
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
        -- this should never happen on trailing edge CLK
        if crc_preset = '1' then
          crc <= (others => '1');
        elsif crc_latch = '1' then
          rd_crc <= crc;
        end if;
				rclk_r := rclk;
			end if;
		end process PROC_RAW_READ;

		-- reads address mark and flags start of sector
		PROC_I_DAM: process (clk, clk_20M_ena, reset)
      constant MIN_GAP2_4E  : integer := 15;
      constant MIN_GAP2_00  : integer := 8;
      variable am_crc       : std_logic_vector(15 downto 0) := (others => '1');
			variable count        : integer range 0 to 511 := 0;
		begin
			if reset = '1' then
				idam_track <= (others => '0');
				idam_side <= (others => '0');
				idam_sector <= (others => '0');
				idam_seclen <= (others => '0');
				idam_dam <= (others => '0');
        crc_preset <= '0';
        crc_latch <= '0';
				state <= UNKNOWN;
			elsif rising_edge(clk) and clk_20M_ena = '1' then
				id_addr_mark_rdy <= '0'; 		-- default
				data_addr_mark_rdy <= '0';	-- default
				data_addr_mark_nxt <= '0';	-- default
				addr_data_rdy <= '0';       -- default
				user_data_rdy <= '0'; 		  -- default
				user_crc_rdy <= '0'; 		    -- default
        crc_preset <= '0';          -- default
        crc_latch <= '0';           -- default
        if state = UNKNOWN then
          count := 0;
          state <= GAP2_4E;
        elsif raw_data_rdy = '1' then
          -- transfer to data register
          data_o_r <= raw_data_r;
					case state is
						when GAP2_4E =>
							-- at least 22? bytes of $4E
							if raw_data_r = X"4E" then
								if count < MIN_GAP2_4E then
									count := count + 1;
								end if;
							elsif raw_data_r = X"00" and count = MIN_GAP2_4E then
								count := 1;
								state <= GAP2_00;
							else
								state <= UNKNOWN;
							end if;
						when GAP2_00 =>
							-- exactly 12 bytes of $00
							-- - actually changed to MINIMUM of xx bytes
							if raw_data_r = X"00" then
                if count < MIN_GAP2_00 then
                  count := count + 1;
                end if;
                crc_preset <= '1';
							elsif raw_data_r = X"A1" and count = MIN_GAP2_00 then
                count := 1;
                state <= GAP2_A1;
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
							addr_data_rdy <= '1';
							state <= SIDE;
						when SIDE =>
							idam_side <= raw_data_r;
							addr_data_rdy <= '1';
							state <= SECTOR;
						when SECTOR =>
							idam_sector <= raw_data_r;
							addr_data_rdy <= '1';
							state <= SEC_LEN;
						when SEC_LEN =>
							idam_seclen <= raw_data_r;
							addr_data_rdy <= '1';
              crc_latch <= '1';
              crc_error <= '0';
							count := 0;
							state <= CRC_1;
						when CRC_1 =>
							am_crc := am_crc(7 downto 0) & raw_data_r;
							addr_data_rdy <= '1';
							count := count + 1;
							if count = 2 then
								if ENABLE_CRC and am_crc /= rd_crc then
                  crc_error <= '1';
                  state <= UNKNOWN;
                else
                  id_addr_mark_rdy <= '1';
                  count := 0;
                  state <= GAP3_4E;
                end if;
							end if;
						when GAP3_4E =>
							if raw_data_r = X"4E" then
								if count < 22 then
									count := count + 1;
								end if;
							elsif raw_data_r = X"00" and count = 22 then		-- 24?
								count := 1;
								state <= GAP3_00;
							else
								state <= UNKNOWN;
							end if;
						when GAP3_00 =>
							if raw_data_r = X"00" then
								if count < 8 then
									count := count + 1;
								end if;
							elsif raw_data_r = X"A1" and count = 8 then
								count := 1;
								state <= GAP3_A1;
							else
								state <= UNKNOWN;
							end if;
						when GAP3_A1 =>
							if raw_data_r = X"A1" then
								count := count + 1;
								if count = 3 then
                  data_addr_mark_nxt <= '1';
									state <= DAM;
								end if;
							else
								state <= UNKNOWN;
							end if;
						when DAM =>
							idam_dam <= raw_data_r;
							data_addr_mark_rdy <= '1';
							count := 0;
							state <= USER_DATA;
						when USER_DATA =>
							-- reading user sector data
							count := count + 1;
              user_data_rdy <= '1';
							if count = 256 then
                crc_latch <= '1';
                crc_error <= '0';
								count := 0;
								state <= CRC_2;
							end if;
						when CRC_2 =>
							am_crc := am_crc(7 downto 0) & raw_data_r;
							count := count + 1;
							if count = 2 then
                if ENABLE_CRC and am_crc /= rd_crc then
                  crc_error <= '1';
                end if;
								user_crc_rdy <= '1';
                state <= UNKNOWN;
							end if;
						when others =>
							state <= UNKNOWN;
					end case;
				end if;
			end if;
		end process PROC_I_DAM;

	end block BLK_READ;

  BLK_WRITE : block

    signal clk_1M_ena   : std_logic := '0';
    signal wclk         : std_logic := '0';

  begin
  
    -- 1MHz clock (enable) generate
    process (clk, clk_20M_ena, reset)
      subtype count_t is integer range 0 to 19;
      variable count_v : count_t := 0;
    begin
      if reset = '1' then
        count_v := 0;
      elsif rising_edge(clk) and clk_20M_ena = '1' then
        clk_1M_ena <= '0';
        if count_v = count_t'high then
          clk_1M_ena <= '1';
          count_v := 0;
        else
          count_v := count_v + 1;
        end if;
      end if;
    end process;
  
    -- we'll start with 4us per bit, 6272 bytes/track = 200ms per track
    PROC_WR: process (clk, clk_20M_ena, clk_1M_ena, reset)
      variable count : std_logic_vector(17 downto 0) := (others => '0');
      alias phase : std_logic_vector(1 downto 0) is count(1 downto 0);
      alias bbit  : std_logic_vector(2 downto 0) is count(4 downto 2);
      alias byte  : std_logic_vector(12 downto 0) is count (17 downto 5);
      variable write_data_r : std_logic_vector(7 downto 0) := (others => '0');
    begin
      if reset = '1' then
        count := (others => '0');
				wr_crc <= (others => '1');
				wclk <= '0';
				--rd <= '0';
				--raw_read_n <= '1';
				write_data_written <= '0';
      elsif rising_edge(clk) then
				if clk_1M_ena = '1' then
	        --rd <= '0';          				-- default
	        --raw_read_n <= '1';  				-- default
					write_data_written <= '0';	-- default
	        -- memory address
	        if phase = "00" and bbit = "000" then
	          --offset_s <= byte;
	        end if;
	        -- wclk
	        if phase = "01" then
	          wclk <= '1';
	        elsif phase = "11" then
	          wclk <= '0';
	        end if;
	        -- data latch (1us memory assumed)
	        if phase = "01" and bbit = "000" then
	          write_data_r := wr_dat_s;
	        end if;
	        if phase = "10" then
	          --raw_read_n <= ena and not read_data_r(read_data_r'left);
	          --read_data_r := read_data_r(read_data_r'left-1 downto 0) & '0';
	          wr_crc <= crc16(write_data_r(write_data_r'left), wr_crc);
	          write_data_r := write_data_r(write_data_r'left-1 downto 0) & '0';
	        end if;
	        if phase = "11" and bbit = "111" then
	          write_data_written <= type_ii_wg or type_iii_wg;
	        end if;
	        if count = 6272*8*4-1 then
	          count := (others => '0');
	        else
	          count := count + 1;
	        end if;
				end if;
				if clk_20M_ena = '1' then
					if (type_ii_wr_crc_preset or type_iii_wr_crc_preset) = '1' then
						wr_crc <= (others => '1');
					end if;
				end if;
      end if;
    end process PROC_WR;

		wd <= wclk;
  
  end block BLK_WRITE;

  BLK_STATUS : block

    signal sts_type1          : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdaddr         : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdsect         : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_rdtrk          : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_wrsect         : std_logic_vector(7 downto 0) := (others => '0');
    signal sts_wrtrk          : std_logic_vector(7 downto 0) := (others => '0');

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
    s7_not_ready <= not (ready or mr_n);
    s6_protected <= not wprt_n;
    s5_head_loaded <= '1'; --hld_s and hlt;
    s2_track_00 <= not tr00_n;
    s1_index <= not ip_n;
    
    -- type II/III commands
    s1_data_request <= drq_s;
    
		s0_busy <= cmd_busy;

    -- some status needs to be latched at the completion of the command
    process (clk, clk_20M_ena, reset)
    begin
      if reset = '1' then
        null;
      elsif rising_edge(clk) and clk_20M_ena = '1' then
        if latch_status = '1' then
          -- Data address mark
          -- - $FB = data, $F8 = deleted
          -- - bit set in status = DELETED
          s5_record_type <= not (idam_dam(1) or idam_dam(0));
          s4_seek_error <= seek_error;
          s4_rnf <= rnf_error;
          s3_crc_error <= crc_error;
        end if;
      end if;
    end process;

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

  status_r <= sts_rdsect when STD_MATCH(cmd, CMD_READ_SECTOR) else
              sts_wrsect when STD_MATCH(cmd, CMD_WRITE_SECTOR) else
              sts_rdaddr when STD_MATCH(cmd, CMD_READ_ADDRESS) else
              sts_rdtrk when STD_MATCH(cmd, CMD_READ_TRACK) else
              sts_wrtrk when STD_MATCH(cmd, CMD_WRITE_TRACK) else
              sts_type1;

  end block BLK_STATUS;
  
  -- assign outputs
  hld <= hld_s;
  wg <= type_ii_wg or type_iii_wg;

  -- 1 bit is enough to differentiate between write track and write sector
  wr_dat_s <= trk_dat_o when command_r(6) = '1' else 
              sec_dat_o;
	wr_dat_o <= wr_dat_s;
              
  -- extend step pulse
  -- - min 2/4 us
  process (clk, clk_20M_ena, reset)
    subtype count_t is integer range 0 to 7; -- 4us
    variable count : count_t := 0;
  begin
    if reset = '1' then
      count := 0;
      step <= '0';
    elsif rising_edge(clk) and clk_20M_ena = '1' then
      if step_s = '1' then
        count := count_t'high;
        step <= '1';
      elsif count = 0 then
        step <= '0';
      else
        count := count - 1;
      end if;
    end if;
  end process;
  
  debug <= idam_track & idam_sector & track_r & sector_r;
  --debug <= command_r & status_r & command_r & status_r;
  
end architecture SYN;
