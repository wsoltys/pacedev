--
-- BDM commands
--
--  $00       RD BDM status register
--      -- bit 0 RD=enabled                 WR=enable
--      -- bit 1 RD=halted                  WR=halt next instruction
--      -- bit 2 RD=breakpoint enabled      WR=enable
--      -- bit 3 RD=halted on breakpoint    WR=(don't care)
--      -- bit 4 RD/WR=auto-increment address pointer on rd
--      -- bit 5 RD/WR=auto-increment address pointer on wr
--      -- bit 6 RD/WR=auto-decrement address pointer on rd
--      -- bit 7 RD/WR=auto-decrement address pointer on wr
--  $01 <nn>  WR BDM status register with data <nn>
--  $02       RD internal address pointer
--  $03 <nn>  WR internal address pointer with <nn>
--  $04       RD breakpoint register
--  $05 <nn>  WR breakpoint register
--  $1R       RD register <R>
--  $1R <nn>  WR register <R> with data <nn>
--  $20       RD data from internal address
--  $21 <n>   WR data to internal address
--  $30       break
--  $31       single step
--  $32       go
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
use work.mce6309_pack.all;

entity mce6309_bdmio is
	port
	(
	  clk         : in std_logic;
	  clk_en      : in std_logic;
    rst         : in std_logic;
    	  
		-- external signals
    bdm_clk   	: in std_logic;
    bdm_mosi    : in std_logic;
    bdm_miso    : out std_logic;
    bdm_i     	: in std_logic;
    bdm_o     	: out std_logic;
    bdm_oe    	: out std_logic;

		-- internal signals
		
		-- in
		bdm_enabled	: out std_logic;
		bdm_rdy			: out std_logic;
		bdm_ir			: out std_logic_vector(23 downto 0);

    bdm_cr_o    : out std_logic_vector(7 downto 0);
    		
		-- out
		bdm_wr			: in std_logic;
		bdm_data		: in std_logic_vector(23 downto 0);
		
		bdm_cr_set  : in std_logic_vector(7 downto 0);
		bdm_cr_clr  : in std_logic_vector(7 downto 0)
	);
end entity mce6309_bdmio;

architecture SYN of mce6309_bdmio is

  type state_t is ( S_IDLE, S_READING, S_BUSY, S_WRITING );
  signal state  : state_t;

	-- BDM registers
	signal bdm_cr       : std_logic_vector(7 downto 0);
	alias bdm_enable    : std_logic is bdm_cr(0);
	alias bdm_halt_next : std_logic is bdm_cr(1);
	alias bp_enable     : std_logic is bdm_cr(2);
	signal bdm_sr       : std_logic_vector(7 downto 0);
	--alias bdm_enabled   : std_logic is bdm_sr(0);
	alias bdm_halted    : std_logic is bdm_sr(1);
	alias bp_enabled    : std_logic is bdm_sr(2);
	alias bp_halted     : std_logic is bdm_sr(3);
    
begin

  process (clk, rst)
    variable bdm_clk_r    : std_logic := '0';
    variable bdm_d_r      : std_logic_vector(bdm_ir'range);
    variable count        : integer range 0 to 31;
  begin
    if rst = '1' then
      bdm_cr <= "00000011";
      bdm_clk_r := '0';
      state <= S_IDLE;
      bdm_rdy <= '0';
      bdm_ir <= (others => '0');
      bdm_miso <= '0';
      -- default BDM to DISABLED
      bdm_enabled <= '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        bdm_rdy <= '0';       -- default
        bdm_oe <= '0';        -- default
        case state is
          when S_IDLE =>
            bdm_miso <= '0';  -- paranoid
            if bdm_mosi = '1' then
              if bdm_clk = '1' and bdm_clk_r = '0' then
                bdm_d_r := bdm_d_r(bdm_d_r'left-1 downto 0) & bdm_i;
                count := 1;
                state <= S_READING;
              end if;
            end if;
          when S_READING =>
            -- check bdm_mosi?
            if bdm_clk = '1' and bdm_clk_r = '0' then
              bdm_d_r := bdm_d_r(bdm_d_r'left-1 downto 0) & bdm_i;
              count := count + 1;
              if count = 24 then
                bdm_ir <= bdm_d_r;
                bdm_rdy <= '1';
                state <= S_BUSY;
              end if;                            
            end if;
          when S_BUSY =>
            state <= S_IDLE;  -- *** FUDGE
            if bdm_wr = '1' then
              -- latch write data
              bdm_d_r := bdm_data;
              count := 0;
              state <= S_WRITING;
            end if;
          when S_WRITING =>
            if bdm_clk = '0' and bdm_clk_r = '1' then
              -- write BIT and shift
              bdm_o <= bdm_d_r(bdm_d_r'left);
              bdm_oe <= '1';
              bdm_d_r := bdm_d_r(bdm_d_r'left-1 downto 0) & '0';
              bdm_miso <= '1';
              count := count + 1;
              if count = 24 then
                -- dropping bdm_miso too early?
                state <= S_IDLE;
              end if;
            end if;
        end case;
        bdm_clk_r := bdm_clk;
      end if; -- clk_en=1
    end if;
  end process;

  bdm_cr_o <= bdm_cr;
    
end architecture SYN;
