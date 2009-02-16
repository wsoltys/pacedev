library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mce_arm2 is
  port
  (
    -- system signals
    clk_i         : in std_logic;
    reset_i       : in std_logic;

    -- clocks
    ph1_ena       : in std_logic;
    ph2_ena       : in std_logic;

    rn_w          : out std_logic;
    opc_n         : out std_logic;
    mreq_n        : out std_logic;
    abort         : in std_logic;
    irq_n         : in std_logic;
    fiq_n         : in std_logic;
    reset         : in std_logic;
    trans_n       : out std_logic;
    m_n           : out std_logic_vector(1 downto 0);
    seq           : out std_logic;
    ale           : in std_logic;
    a             : out std_logic_vector(25 downto 0);
    --a_oe          : out std_logic;
    abe           : in std_logic;
    d_i           : in std_logic_vector(31 downto 0);
    d_o           : out std_logic_vector(31 downto 0);
    dbe           : in std_logic;
    bn_w          : out std_logic;
    cpi_n         : out std_logic;
    cpb           : in std_logic;
    cpa           : in std_logic
  );
end entity mce_arm2;

architecture SYN of mce_arm2 is

  --
  -- registers
  --

  subtype reg_t is std_logic_vector(31 downto 0);
  type reg_a is array(natural range <>) of reg_t;

  signal r        : reg_a(15 downto 0);
  signal r_svc    : reg_a(14 downto 13);
  signal r_irq    : reg_a(14 downto 13);
  signal r_fiq    : reg_a(14 downto 8);

  alias f_n       : std_logic is r(15)(31);
  alias f_z       : std_logic is r(15)(30);
  alias f_c       : std_logic is r(15)(29);
  alias f_v       : std_logic is r(15)(28);
  alias f_i       : std_logic is r(15)(27);
  alias f_f       : std_logic is r(15)(26);
  alias pc        : std_logic_vector(25 downto 2) is r(15)(25 downto 2);
  alias m         : std_logic_vector(1 downto 0) is r(15)(1 downto 0);

  -- mode encodings
  constant USR_MODE   : std_logic_vector(1 downto 0) := "00";
  constant FIQ_MODE   : std_logic_vector(1 downto 0) := "01";
  constant IRQ_MODE   : std_logic_vector(1 downto 0) := "10";
  constant SVC_MODE   : std_logic_vector(1 downto 0) := "11";

  --
  -- vectors
  --

  constant VEC_RESET            : std_logic_vector(pc'range) := X"000000";
  constant VEC_UNDEF_INSTR      : std_logic_vector(pc'range) := X"000001";
  constant VEC_SW_INT           : std_logic_vector(pc'range) := X"000002";
  constant VEC_ABORT_PREFETCH   : std_logic_vector(pc'range) := X"000003";
  constant VEC_ABORT_DATA       : std_logic_vector(pc'range) := X"000004";
  constant VEC_ADDR_EXCEPTION   : std_logic_vector(pc'range) := X"000005";
  constant VEC_IRQ              : std_logic_vector(pc'range) := X"000006";
  constant VEC_FIQ              : std_logic_vector(pc'range) := X"000007";

  --
  -- INSTRUCTIONS
  --

  subtype instr_t is std_logic_vector(31 downto 0);

  -- instruction condition codes
  constant COND_EQ    : std_logic_vector(31 downto 28) := X"0";
  constant COND_NE    : std_logic_vector(31 downto 28) := X"1";
  constant COND_CS    : std_logic_vector(31 downto 28) := X"2";
  constant COND_CC    : std_logic_vector(31 downto 28) := X"3";
  constant COND_MI    : std_logic_vector(31 downto 28) := X"4";
  constant COND_PL    : std_logic_vector(31 downto 28) := X"5";
  constant COND_VS    : std_logic_vector(31 downto 28) := X"6";
  constant COND_VC    : std_logic_vector(31 downto 28) := X"7";
  constant COND_HI    : std_logic_vector(31 downto 28) := X"8";
  constant COND_LS    : std_logic_vector(31 downto 28) := X"9";
  constant COND_GE    : std_logic_vector(31 downto 28) := X"A";
  constant COND_LT    : std_logic_vector(31 downto 28) := X"B";
  constant COND_GT    : std_logic_vector(31 downto 28) := X"C";
  constant COND_LE    : std_logic_vector(31 downto 28) := X"D";
  constant COND_AL    : std_logic_vector(31 downto 28) := X"E";
  constant COND_NV    : std_logic_vector(31 downto 28) := X"F";

  -- types of instructions
  constant INSTR_DATA_PROC          : std_logic_vector(27 downto 26) := "00";
  constant INSTR_MULTIPLY           : std_logic_vector(27 downto 22) := "000000";
  constant INSTR_SINGLE_DATA_XFER   : std_logic_vector(27 downto 26) := "01";
  constant INSTR_BLOCK_XFER         : std_logic_vector(27 downto 25) := "100";
  constant INSTR_BRANCH             : std_logic_vector(27 downto 25) := "101";
  constant INSTR_COPROC_DATA_XFER   : std_logic_vector(27 downto 25) := "110";
  constant INSTR_COPROC_DATA_OP     : std_logic_vector(27 downto 24) := "1110";
  constant INSTR_COPROC_DATA_OP_4   : std_logic_vector(4 downto 4) := "0";
  constant INSTR_COPROC_REG_XFER    : std_logic_vector(27 downto 24) := "1110";
  constant INSTR_COPROC_REG_XFER_4  : std_logic_vector(4 downto 4) := "1";
  constant INSTR_SW_INT             : std_logic_vector(27 downto 24) := "1111";

begin

  process (clk_i, reset_i)
    variable reset_r : std_logic := '0';
  begin
    if reset_i = '1' then
      reset_r := '0';
    elsif rising_edge(clk_i) then
      if reset = '1' then
        -- execute NOPs
        null;
      elsif reset_r = '1' and reset = '0' then
        -- falling edge reset
        r_svc(14) <= r(15);
        m <= SVC_MODE;
        f_i <= '1';       -- disable IRQ
        f_f <= '1';       -- disable FIQ
        pc <= VEC_RESET;
      elsif ph1_ena = '1' then
        null;
      elsif ph2_ena = '1' then
        null;
      end if;
      reset_r := reset;
    end if;
  end process;

end architecture SYN;
