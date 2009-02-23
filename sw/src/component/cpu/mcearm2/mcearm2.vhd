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
  constant INSTR_DATA_PROC_SI       : std_logic_vector(27 downto 0) := "00---------------------0----";
  constant INSTR_DATA_PROC_SR       : std_logic_vector(27 downto 0) := "00------------------0--1----";
  constant INSTR_MULTIPLY           : std_logic_vector(27 downto 0) := "000000--------------1001----";
  constant INSTR_SINGLE_DATA_XFER   : std_logic_vector(27 downto 0) := "01--------------------------";
  constant INSTR_BLOCK_XFER         : std_logic_vector(27 downto 0) := "100-------------------------";
  constant INSTR_BRANCH             : std_logic_vector(27 downto 0) := "101-------------------------";
  constant INSTR_COPROC_DATA_XFER   : std_logic_vector(27 downto 0) := "110-------------------------";
  constant INSTR_COPROC_DATA_OP     : std_logic_vector(27 downto 0) := "1110-------------------0----";
  constant INSTR_COPROC_REG_XFER    : std_logic_vector(27 downto 0) := "1110-------------------1----";
  constant INSTR_SW_INT             : std_logic_vector(27 downto 0) := "1111------------------------";

  -- ALU operations
  constant ALU_OP_AND               : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OP_XOR               : std_logic_vector(3 downto 0) := "0001";
  constant ALU_OP_SUB               : std_logic_vector(3 downto 0) := "0010";
  constant ALU_OP_RSB               : std_logic_vector(3 downto 0) := "0011";
  constant ALU_OP_ADD               : std_logic_vector(3 downto 0) := "0100";
  constant ALU_OP_ADC               : std_logic_vector(3 downto 0) := "0101";
  constant ALU_OP_SBC               : std_logic_vector(3 downto 0) := "0110";
  constant ALU_OP_RSC               : std_logic_vector(3 downto 0) := "0111";
  constant ALU_OP_TST               : std_logic_vector(3 downto 0) := "1000";
  constant ALU_OP_TEQ               : std_logic_vector(3 downto 0) := "1001";
  constant ALU_OP_CMP               : std_logic_vector(3 downto 0) := "1010";
  constant ALU_OP_CMN               : std_logic_vector(3 downto 0) := "1011";
  constant ALU_OP_ORR               : std_logic_vector(3 downto 0) := "1100";
  constant ALU_OP_MOV               : std_logic_vector(3 downto 0) := "1101";
  constant ALU_OP_BIC               : std_logic_vector(3 downto 0) := "1110";
  constant ALU_OP_MVN               : std_logic_vector(3 downto 0) := "1111";

  -- shift types
  constant SHIFT_TYPE_LL            : std_logic_vector(1 downto 0) := "00";
  constant SHIFT_TYPE_LR            : std_logic_vector(1 downto 0) := "01";
  constant SHIFT_TYPE_AR            : std_logic_vector(1 downto 0) := "10";
  constant SHIFT_TYPE_RR            : std_logic_vector(1 downto 0) := "01";

  -- internal logic
  signal din        : std_logic_vector(31 downto 0) := (others => '0');
  signal ar         : std_logic_vector(25 downto 0) := (others => '0');

	type ExecuteMode_t is 
	( 
		first_step, refill1, refill2, store, load_write_register, multi_load_loop, multi_store_init, alu_shift,
		load_read_memory 
	);
	signal ExecuteMode 	: ExecuteMode_t := refill2;

	signal PrevFetchedInstr 	: std_logic_vector(31 downto 0) := (others => '0');
	signal FetchedInstr 			: std_logic_vector(31 downto 0) := (others => '0');
	signal ExecuteInstr				: std_logic_vector(31 downto 0) := (others => '0');
	signal DestReg						: integer := 0;
	signal aop								: std_logic_vector(31 downto 0) := (others => '0');
	signal Bop								: std_logic_vector(31 downto 0) := (others => '0');
	signal ShiftCarryOp				: std_logic := '0';
	signal Status							: std_logic_vector(5 downto 0) := (others => '0');
	signal DataIn							: std_logic_vector(31 downto 0) := (others => '0');

	function Nop (instr : std_logic_vector(31 downto 0)) return boolean is
	begin
		-- quick fudge
		return instr(31 downto 28) = COND_NV;
	end function Nop;

	function Satisfies (Status : std_logic_vector(5 downto 0); CondCode : std_logic_vector(3 downto 0)) return boolean is
		alias N : std_logic is Status(5);
		alias Z : std_logic is Status(4);
		alias C : std_logic is Status(3);
		alias V : std_logic is Status(2);
		alias I : std_logic is Status(1);
		alias F : std_logic is Status(0);
	begin
		-- NZCVIF
		return
			(CondCode = COND_EQ and Z = '1') or
			(CondCode = COND_NE and Z = '0') or
			(CondCode = COND_CS and C = '1') or
			(CondCode = COND_CC and C = '0') or
			(CondCode = COND_MI and N = '1') or
			(CondCode = COND_PL and N = '0') or
			(CondCode = COND_VS and V = '1') or
			(CondCode = COND_VC and V = '0') or
			(CondCode = COND_HI and C = '1' and Z = '0') or
			(CondCode = COND_LS and C = '0' and Z = '1') or
			(CondCode = COND_GE and ((N = '1' and V = '1') or (N = '1' and V = '0'))) or
			(CondCode = COND_LT and ((N = '1' and V = '0') or (N = '0' and V = '1'))) or
			(CondCode = COND_GT and Z = '0' and ((N = '1' and V = '1') or (N = '0' and V = '0'))) or
			(CondCode = COND_LE and Z = '1' and ((N = '1' and V = '0') or (N = '0' and V = '1'))) or
			CondCode = COND_AL;
	end function Satisfies;

	function CondCode (instr : std_logic_vector(31 downto 0)) return std_logic_vector is
	begin
		return instr(31 downto 28);
	end function CondCode;

	function LastStep (instr : std_logic_vector(31 downto 0); ExecuteMode : ExecuteMode_t) return boolean is
	begin
		-- quick fudge
		return (ExecuteMode = first_step) or (ExecuteMode = refill1) or (ExecuteMode = refill2);
	end function LastStep;

	function DestOp (cc_instr : std_logic_vector(31 downto 0)) return integer is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		if STD_MATCH(instr, INSTR_DATA_PROC_SI) or STD_MATCH(instr, INSTR_DATA_PROC_SR) then
			return to_integer(unsigned(instr(15 downto 12)));
		elsif STD_MATCH(instr, INSTR_MULTIPLY) then
			return to_integer(unsigned(instr(19 downto 16)));
		elsif STD_MATCH(instr, INSTR_SINGLE_DATA_XFER) and instr(20) = '1' then
			return to_integer(unsigned(instr(15 downto 12)));
		else
			return 0;
		end if;
	end function DestOp;

	function AluRegShift (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return 
			(STD_MATCH(instr, INSTR_DATA_PROC_SI) and false) or
			(STD_MATCH(instr, INSTR_DATA_PROC_SR) and false) or
			(STD_MATCH(instr, INSTR_SINGLE_DATA_XFER) and false);
	end function AluRegShift;

	function AopReg (cc_instr : std_logic_vector(31 downto 0)) return integer is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		if STD_MATCH(instr, INSTR_DATA_PROC_SI) or STD_MATCH(instr, INSTR_DATA_PROC_SR) then
			return to_integer(unsigned(instr(19 downto 16)));
		elsif false then
			-- how to handle MULT???
		else
			return 0;
		end if;
	end function AopReg;

	function BopReg (cc_instr : std_logic_vector(31 downto 0)) return integer is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		if STD_MATCH(instr, INSTR_DATA_PROC_SI) or STD_MATCH(instr, INSTR_DATA_PROC_SR) then
			return to_integer(unsigned(instr(15 downto 12)));
		elsif false then
			-- how to handle MULT???
		else
			return 0;
		end if;
	end function BopReg;

	function AluInstr (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return 
			STD_MATCH(instr, INSTR_DATA_PROC_SI) or
			STD_MATCH(instr, INSTR_DATA_PROC_SR) or
			STD_MATCH(instr, INSTR_MULTIPLY);
	end function AluInstr;

	function WriteResult (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return 
			(STD_MATCH(instr, INSTR_DATA_PROC_SI) or STD_MATCH(instr, INSTR_DATA_PROC_SR)) and
				-- TST, TEQ, CMP & CMN discard result
				not STD_MATCH(instr(24 downto 21), "10--");
	end function WriteResult;

	function SetCondCode (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return 
			(STD_MATCH(instr, INSTR_DATA_PROC_SI) and instr(20) = '1') or
			(STD_MATCH(instr, INSTR_DATA_PROC_SR) and instr(20) = '1') or
			(STD_MATCH(instr, INSTR_MULTIPLY) and instr(20) = '1');
	end function SetCondCode;

	function WritesPC (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return 
			-- fixme
			(STD_MATCH(instr, INSTR_BRANCH));
	end function WritesPC;

	function SingleLoadInstr (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return STD_MATCH(instr, INSTR_SINGLE_DATA_XFER) and instr(20) = '1';
	end function SingleLoadInstr;

	function FinalOffset (instr : std_logic_vector(31 downto 0)) return std_logic_vector is
	begin
		return X"00000000";
	end function FinalOffset;

	function ByteTransferInstr (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return STD_MATCH(instr, INSTR_SINGLE_DATA_XFER) and instr(22) = '1';
	end function ByteTransferInstr;

	function WriteBack (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return 
			(STD_MATCH(instr, INSTR_SINGLE_DATA_XFER) and instr(21) = '1') or
			(STD_MATCH(instr, INSTR_BLOCK_XFER) and instr(21) = '1');
	end function WriteBack;

	function Op (cc_instr : std_logic_vector(31 downto 0)) return std_logic_vector is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return instr(24 downto 21); 
	end function Op;

	function Carry (Status : std_logic_vector(5 downto 0)) return std_logic is
	begin
		return (Status(3));
	end function Carry;
	function ALU 
	(
		Op 			: std_logic_vector(3 downto 0);
		Aop 		: std_logic_vector(31 downto 0);
		Bop			: std_logic_vector(31 downto 0);
		Carry		: std_logic
	) return std_logic_vector is
	begin
		if Op = ALU_OP_AND or Op = ALU_OP_TST then 
      return Aop and Bop;
		elsif Op = ALU_OP_XOR or Op = ALU_OP_TEQ then 
      return Aop xor Bop;
		elsif Op = ALU_OP_SUB or Op = ALU_OP_CMP then 
      return std_logic_vector(unsigned(Aop) - unsigned(Bop));
		elsif Op = ALU_OP_RSB or Op =ALU_OP_CMN then 
      return std_logic_vector(unsigned(Bop) - unsigned(Aop));
		elsif Op = ALU_OP_ADD then 
      return std_logic_vector(unsigned(Aop) + unsigned(Bop));
		elsif Op = ALU_OP_ADC then 
      return std_logic_vector(unsigned(Aop) + unsigned(Bop));		-- + carry
		elsif Op = ALU_OP_SBC then 
      return std_logic_vector(unsigned(Aop) - unsigned(Bop));		-- + carry
		elsif Op = ALU_OP_RSC then 
      return std_logic_vector(unsigned(Bop) - unsigned(Aop));		-- + carry
		elsif Op = ALU_OP_ORR then 
      return Aop or Bop;
		elsif Op = ALU_OP_MOV then 
      return Bop;	-- ??? MOV
		elsif Op = ALU_OP_BIC then 
      return Aop and not Bop;
		elsif Op = ALU_OP_MVN then 
      return not Bop; -- ??? MVN
		end if;
	end function ALU;

	function UpdateStatus 
	(
		Status	: std_logic_vector(5 downto 0);
		Op 			: std_logic_vector(3 downto 0);
		Aop 		: std_logic_vector(31 downto 0);
		Bop			: std_logic_vector(31 downto 0);
		Carry		: std_logic
	) return std_logic_vector is
	begin
		if Op = ALU_OP_AND or Op = ALU_OP_TST then 
      return Status;
		elsif Op = ALU_OP_XOR or Op = ALU_OP_TEQ then 
      return Status;
		elsif Op = ALU_OP_SUB or Op = ALU_OP_CMP then 
      return Status;
		elsif Op = ALU_OP_RSB or Op =ALU_OP_CMN then 
      return Status;
		elsif Op = ALU_OP_ADD then 
      return Status;
		elsif Op = ALU_OP_ADC then 
      return Status;
		elsif Op = ALU_OP_SBC then 
      return Status;
		elsif Op = ALU_OP_RSC then 
      return Status;
		elsif Op = ALU_OP_ORR then 
      return Status;
		elsif Op = ALU_OP_MOV then 
      return Status;
		elsif Op = ALU_OP_BIC then 
      return Status;
		elsif Op = ALU_OP_MVN then 
      return Status;
		end if;
	end function UpdateStatus;

	function ImmBop (cc_instr : std_logic_vector(31 downto 0)) return boolean is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return STD_MATCH(instr, INSTR_DATA_PROC_SI);
	end function ImmBop;

	function ImmediateVal (cc_instr : std_logic_vector(31 downto 0)) return std_logic_vector is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return instr(7 downto 0);
	end function ImmediateVal;

	function ShiftType (cc_instr : std_logic_vector(31 downto 0)) return std_logic_vector is
		alias instr : std_logic_vector(27 downto 0) is cc_instr(27 downto 0);
	begin
		return instr(6 downto 5);
	end function ShiftType;

	function Shift 
	(
		SourceVal		: std_logic_vector(31 downto 0);
		ShiftType		: std_logic_vector(1 downto 0);
		ShiftAmt		: integer;
		Carry				: std_logic
	) return std_logic_vector is
	begin
    if ShiftType = SHIFT_TYPE_LL then
		  return SourceVal;
    elsif ShiftType = SHIFT_TYPE_LR then
		  return SourceVal;
    elsif ShiftType = SHIFT_TYPE_AR then
		  return SourceVal;
    elsif ShiftType = SHIFT_TYPE_RR then
		  return SourceVal;
		end if;
	end function Shift;

begin

  PROC_DELETEME : process (clk_i, reset_i)
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
      elsif ph1_ena = '1' then
      elsif ph2_ena = '1' then
        null;
      end if;
      reset_r := reset;
    end if;
  end process PROC_DELETEME;

  --
  -- FETCH
  --

	BLK_FETCH : block
	begin

	  PROC_FETCH : process (clk_i, reset_i)

			variable FetchOK				: boolean := false;
			variable FetchInstr 		: std_logic_vector(31 downto 0) := (others => '0');

	  begin

			FetchOK := (ExecuteMode = first_step) or (ExecuteMode = refill1) or (ExecuteMode = refill2);
			FetchInstr := d_i; -- hack??

	    if reset_i = '1' then
	    elsif reset = '1' then
        FetchedInstr <= X"FFFFFFFF";      -- NOP
        PrevFetchedInstr <= X"FFFFFFFF";  -- NOP
	    elsif rising_edge(clk_i) and ph1_ena = '1' then

        --
        --  Rule: Fetch
        --
	      if FetchOK then
					FetchedInstr <= FetchInstr;
					PrevFetchedInstr <= FetchedInstr;
				end if;

	    end if;
	  end process PROC_FETCH;

    rn_w <= '0';
    a <= pc & "00";

	end block BLK_FETCH;

  --
  -- DECODE
  --

	BLK_DECODE : block

	begin

	  PROC_DECODE : process (clk_i, reset_i)

			variable DecodeOK 			: boolean := false;
			variable DecodeInstr		: std_logic_vector(31 downto 0) := (others => '0');
			variable SourceVal			: std_logic_vector(31 downto 0) := (others => '0');
			variable ShiftAmt				: integer := 0;

	  begin

			DecodeOK := not Satisfies (Status, CondCode (ExecuteInstr)) or LastStep (ExecuteInstr, ExecuteMode);
			if ExecuteMode = first_step or ExecuteMode = refill2 then
				DecodeInstr := FetchedInstr;
			else
				DecodeInstr := PrevFetchedInstr;
			end if;
			if ImmBop (DecodeInstr) then
				SourceVal := ImmediateVal (DecodeInstr);
			else
				SourceVal := r(BopReg (DecodeInstr));
			end if;

	    if reset_i = '1' then
	    elsif reset = '1' then
        ExecuteInstr <= X"FFFFFFFF";  -- NOP
	    elsif rising_edge(clk_i) and ph1_ena = '1' then

        --
        --  Rule: Decode
        --
				if DecodeOK then
					ExecuteInstr <= DecodeInstr;
					if not Nop (DecodeInstr) then
						DestReg <= DestOp (DecodeInstr);
						if not AluRegShift (DecodeInstr) then
							aop <= r(AopReg (DecodeInstr));
						end if;
						Bop <= Shift (SourceVal, ShiftType (DecodeInstr), ShiftAmt, Carry (Status));
						ShiftCarryOp <= '0';    -- hack
					end if;
				end if;

			end if;

	  end process PROC_DECODE;

	end block BLK_DECODE;

  --
  -- EXECUTE
  --

	BLK_EXECUTE : block

	begin

	  PROC_EXECUTE : process (clk_i, reset_i)

			variable ExecuteOK		: boolean := false;

	  begin

			ExecuteOK := ExecuteMode = first_step;

	    if reset_i = '1' then
	    elsif reset = '1' then
        pc <= VEC_RESET;
				ExecuteMode <= refill2;
	    elsif rising_edge(clk_i) and ph1_ena = '1' then

				--
				-- Rule: ExecutePC
				--

				if ExecuteOK then
					if not Satisfies (Status, CondCode(ExecuteInstr)) or not WritesPC (ExecuteInstr) then
						pc <= std_logic_vector(unsigned(pc) + 1);
					end if;
				end if;

				--
				-- Rule: ExecuteALU
				--

				if ExecuteMode = first_step and AluInstr(ExecuteInstr) and not AluRegShift(ExecuteInstr) then
					if Satisfies (Status, CondCode(ExecuteInstr)) then
						if WriteResult (ExecuteInstr) then
							r(DestReg) <= ALU (Op (ExecuteInstr), Aop, Bop, Carry (Status));
						end if;
						if SetCondCode (ExecuteInstr) then
							Status <= UpdateStatus (Status, Op (ExecuteInstr), Aop, Bop, '0');
						end if;
					end if;
					if WritesPC (ExecuteInstr) then
						ExecuteMode <= refill1;
					else
						ExecuteMode <= first_step;
					end if;
				end if;

				--
				-- Rule: ALU-RegisterShift
				--

				if ExecuteMode = first_step and AluRegShift (ExecuteInstr) then
					if Satisfies (Status, CondCode (ExecuteInstr)) then
						aop <= r(AopReg (ExecuteInstr));
						ExecuteMode <= alu_shift;
					end if;
				end if;

				if ExecuteMode = alu_shift then
					if WriteResult (ExecuteInstr) then
						r(DestReg) <= ALU (Op (ExecuteInstr), Aop, Bop, '0');
					end if;
					if SetCondCode (ExecuteInstr) then
						Status <= UpdateStatus (Status, Op (ExecuteInstr), Aop, Bop, '0');
					end if;
					if WritesPC (ExecuteInstr) then
						ExecuteMode <= refill1;
					else
						ExecuteMode <= first_step;
					end if;
				end if;

				--
				-- Rule: SingleLoad
				--

				if SingleLoadInstr (ExecuteInstr) then
					if ExecuteMode = first_step and Satisfies (Status, CondCode(ExecuteInstr)) then
						--
						ExecuteMode <= load_read_memory;
						Bop <= FinalOffset(ExecuteInstr);
					elsif ExecuteMode = load_read_memory then
						if ByteTransferInstr (ExecuteInstr) then
							DataIn <= (others => '1');
						else
							DataIn <= (others => '1');
						end if;
						if WriteBack (ExecuteInstr) then
						end if;
						ExecuteMode <= load_write_register;
					elsif ExecuteMode = load_write_register then
						r(DestReg) <= DataIn;
						if WritesPC (ExecuteInstr) then
							ExecuteMode <= refill1;
						else
							ExecuteMode <= first_step;
						end if;
					end if;
				end if;

				-- I made this up...
				if ExecuteMode = refill2 then
					ExecuteMode <= refill1;
				elsif ExecuteMode = refill1 then
					ExecuteMode <= first_step;
				end if;

	    end if; -- rising_edge()

	  end process PROC_EXECUTE;

	end block BLK_EXECUTE;

end architecture SYN;
