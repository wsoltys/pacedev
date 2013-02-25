--
-- BDM commands
--
--  $0R       RD BDM register
--  $1R <nn>  WR BDM register with data <nn>
--    BDM registers
--    - $0 - CR/SR
--      -- bit 0 RD=enabled                 WR=enable
--      -- bit 1 RD=halted                  WR=halt next instruction
--      -- bit 2 RD=breakpoint enabled      WR=enable
--      -- bit 3 RD=pc=breakpoint           WR=(don't care)
--      -- bit 4 RD/WR=auto-increment address pointer on rd
--      -- bit 5 RD/WR=auto-increment address pointer on wr
--      -- bit 6 RD/WR=auto-decrement address pointer on rd
--      -- bit 7 RD/WR=auto-decrement address pointer on wr
--    - $1 - Internal Address Pointer
--    - $2 - Breakpoint Register
--  $2R       RD register <R>
--  $2R <nn>  WR register <R> with data <nn>
--  $80       break
--  $81       single step
--  $82       go
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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

    -- cpu registers
    x           : in std_logic_vector(15 downto 0);
    y           : in std_logic_vector(15 downto 0);
    u           : in std_logic_vector(15 downto 0);
    s           : in std_logic_vector(15 downto 0);
    pc          : in std_logic_vector(15 downto 0);
    v           : in std_logic_vector(15 downto 0);
    a           : in std_logic_vector(7 downto 0);
    b           : in std_logic_vector(7 downto 0);
    cc          : in std_logic_vector(7 downto 0);
    dp          : in std_logic_vector(7 downto 0);
    e           : in std_logic_vector(7 downto 0);
    f           : in std_logic_vector(7 downto 0);
    md          : in std_logic_vector(7 downto 0);
        
		-- command
		bdm_rdy			: out std_logic;
		bdm_ir			: out std_logic_vector(23 downto 0);

    -- registers
		bdm_cr_o		: out std_logic_vector(15 downto 0);
		bdm_sr_o		: out std_logic_vector(15 downto 0);
    bdm_ap_o    : out std_logic_vector(15 downto 0);
    bdm_bp_o    : out std_logic_vector(15 downto 0);
    
		-- register io
    bdm_r_d_i		: in std_logic_vector(15 downto 0);
		bdm_wr			: in std_logic
	);
end entity mce6309_bdmio;

architecture SYN of mce6309_bdmio is

  type state_t is ( S_IDLE, S_READING, S_BUSY, S_WAIT, S_WRITING );
  signal state  : state_t;

	type bdm_r_a is array (natural range <>) of std_logic_vector(15 downto 0);
	signal bdm_r				: bdm_r_a(0 to 3);
	signal bdm_sr				: std_logic_vector(15 downto 0);
	
	-- BDM registers
	alias bdm_cr       	: std_logic_vector(bdm_r(BDM_R_CR)'range) is bdm_r(BDM_R_CR);
	alias bdm_ap       	: std_logic_vector(bdm_r(BDM_R_AP)'range) is bdm_r(BDM_R_AP);
	alias bdm_bp       	: std_logic_vector(bdm_r(BDM_R_BP)'range) is bdm_r(BDM_R_BP);
    
begin

  BDM: process (clk, rst)
    variable bdm_clk_r    : std_logic := '0';
    variable bdm_isr     	: std_logic_vector(bdm_ir'range);
    variable bdm_osr			: std_logic_vector(bdm_ir'range);
    variable count        : integer range 0 to 31;
    variable sel					: integer range 0 to 3;
  begin
    if rst = '1' then
      bdm_clk_r := '0';
      state <= S_IDLE;
      bdm_cr <= "0000000000000111";
      bdm_ap <= X"3C00";
      bdm_bp <= (others => '0');
      bdm_rdy <= '0';
      bdm_ir <= (others => '0');
      bdm_miso <= '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        bdm_rdy <= '0';       -- default
        bdm_oe <= '0';        -- default
        case state is
          when S_IDLE =>
            bdm_miso <= '0';  -- paranoid
            if bdm_mosi = '1' then
              if bdm_clk = '1' and bdm_clk_r = '0' then
                bdm_isr := bdm_isr(bdm_isr'left-1 downto 0) & bdm_i;
                count := 1;
                state <= S_READING;
              end if;
            end if;
          when S_READING =>
            -- check bdm_mosi?
            if bdm_clk = '1' and bdm_clk_r = '0' then
              bdm_isr := bdm_isr(bdm_isr'left-1 downto 0) & bdm_i;
              count := count + 1;
              if count = 24 then
                bdm_ir <= bdm_isr;
                state <= S_BUSY;
              end if;                            
            end if;
          when S_BUSY =>
          	count := 0;
            state <= S_WRITING;                                   -- default
            -- only 4 registers for now
            sel := to_integer(unsigned(bdm_isr(17 downto 16)));   -- default
            bdm_osr(23 downto 16) := bdm_isr(23 downto 16);				-- default
            case bdm_isr(23 downto 20) is
              when X"0" =>
                -- read BDM register
                if sel = 0 then
	                bdm_osr(bdm_sr'range) := bdm_sr;
                else
	                bdm_osr(bdm_r(sel)'range) := bdm_r(sel);
                end if;
              when X"1" =>
                -- write BDM register
                bdm_r(sel) <= bdm_isr(bdm_r(sel)'range);
              when X"2" =>
                -- read CPU registers
                case bdm_isr(19 downto 16) is
                  when X"0" =>
                    bdm_osr(15 downto 0) := a & b;
                  when X"1" =>
                    bdm_osr(15 downto 0) := x;
                  when X"2" =>
                    bdm_osr(15 downto 0) := y;
                  when X"3" =>
                    bdm_osr(15 downto 0) := u;
                  when X"4" =>
                    bdm_osr(15 downto 0) := s;
                  when X"5" =>
                    bdm_osr(15 downto 0) := pc;
                  when X"6" =>
                    bdm_osr(15 downto 0) := e & f;
                  when X"7" =>
                    bdm_osr(15 downto 0) := v;
                  when X"8" =>
                    bdm_osr(15 downto 0) := X"00" & a;
                  when X"9" =>
                    bdm_osr(15 downto 0) := X"00" & b;
                  when X"A" =>
                    bdm_osr(15 downto 0) := X"00" & cc;
                  when X"B" =>
                    bdm_osr(15 downto 0) := X"00" & dp;
                  when X"E" =>
                    bdm_osr(15 downto 0) := X"00" & e;
                  when X"F" =>
                    bdm_osr(15 downto 0) := X"00" & f;
                  when others =>
                    bdm_osr(15 downto 0) := (others => '0');
                end case;
              when X"8" =>
                -- execution instructions
                case bdm_isr(19 downto 16) is
                  when X"0" =>
                    -- break
                    bdm_cr(BDM_CR_HALT_NEXT) <= '1';
                  when X"2" =>
                    -- go
                    bdm_cr(BDM_CR_HALT_NEXT) <= '0';
                  when others =>
                    null;
                end case; -- execution instructions
              when others =>
                null;
            end case;
          when S_WAIT =>
            bdm_rdy <= '1';
            state <= S_IDLE;  -- *** FUDGE
            if bdm_wr = '1' then
              -- latch write data
              bdm_osr := X"00" & bdm_r_d_i;
              count := 0;
              state <= S_WRITING;
            end if;
          when S_WRITING =>
            if bdm_clk = '0' and bdm_clk_r = '1' then
              -- write BIT and shift
              bdm_o <= bdm_osr(bdm_osr'left);
              bdm_oe <= '1';
              bdm_osr := bdm_osr(bdm_osr'left-1 downto 0) & '0';
              bdm_miso <= '1';
              count := count + 1;
              if count = 24 then
                -- dropping bdm_miso too early?
                state <= S_IDLE;
              end if;
            end if;
        end case;
        -- clock edge-detect
        bdm_clk_r := bdm_clk;
      end if; -- clk_en=1
    end if;

  end process BDM;

  -- SR
  bdm_sr(bdm_sr'left downto 4) <= bdm_cr(bdm_cr'left downto 4);
  bdm_sr(BDM_SR_PC_EQ_BP) <= '1' when pc = bdm_bp else '0';
  bdm_sr(2 downto 0) <= bdm_cr(2 downto 0);

	-- output CR
	bdm_cr_o <= bdm_cr(bdm_cr_o'range);
	bdm_sr_o <= bdm_sr(bdm_sr_o'range);
	bdm_ap_o <= bdm_ap(bdm_ap_o'range);
	bdm_bp_o <= bdm_bp(bdm_bp_o'range);
    
end architecture SYN;
