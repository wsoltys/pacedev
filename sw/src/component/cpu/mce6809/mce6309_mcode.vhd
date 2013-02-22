--           addressing modes                                                        flags
-- mnem      immed     direct     index    extend   inheren   explan        h i n z v c
-- ------------------------------------------------------------------------------------
-- abx       -- - -    -- - -    -- - -    -- - -    3a 1 1   x+=(uc)b      - - - - - -
-- adca      89 2 2    99 3 2    a9 4 2    b9 4 3    -- - -   a+=m+c        x - x x x x
-- adcb      c9 2 2    d9 3 2    e9 4 2    f9 4 3    -- - -   b+=m+c        x - x x x x
-- adda      8b 2 2    9b 3 2    ab 4 2    bb 4 3    -- - -   a+=m          x - x x x x
-- addb      cb 2 2    db 3 2    eb 4 2    fb 4 3    -- - -   b+=m          x - x x x x
-- addd      c3 3 3    d3 4 2    e3 5 2    f3 5 3    -- - -   d+=m          - - x x x x
-- anda      84 2 2    94 3 2    a4 4 2    b4 4 3    -- - -   a&=m          - - x x 0 -
-- andb      c4 2 2    d4 3 2    e4 4 2    f4 4 3    -- - -   b&=m          - - x x 0 -
-- andcc     1c 3 2    -- - -    -- - -    -- - -    -- - -   cc&=im        6 6 6 6 6 6
-- asl       -- - -    -- - -    68 6 2    78 6 3    -- - -   m<<=1         - - x x x x
-- asla      -- - -    -- - -    -- - -    -- - -    48 1 1   a<<=1         - - x x x x
-- aslb      -- - -    -- - -    -- - -    -- - -    58 1 1   b<<=1         - - x x x x
-- asr       -- - -    -- - -    67 6 2    77 6 3    -- - -   (i)m>>=1      - - x x x x
-- asra      -- - -    -- - -    -- - -    -- - -    47 1 1   (i)a>>=1      - - x x x x
-- asrb      -- - -    -- - -    -- - -    -- - -    57 1 1   (i)b>>=1      - - x x x x
-- bcc       24 3 2    -- - -    -- - -    -- - -    -- - -   bra(cc)       - - - - - -
-- bcs       25 3 2    -- - -    -- - -    -- - -    -- - -   bra(cs)       - - - - - -
-- beq       27 3 2    -- - -    -- - -    -- - -    -- - -   bra(eq)       - - - - - -
-- bge       2c 3 2    -- - -    -- - -    -- - -    -- - -   bra(ge)       - - - - - -
-- bgt       2e 3 2    -- - -    -- - -    -- - -    -- - -   bra(gt)       - - - - - -
-- bhi       22 3 2    -- - -    -- - -    -- - -    -- - -   bra(hi)       - - - - - -
-- bhs       24 3 2    -- - -    -- - -    -- - -    -- - -   bra(hs)       - - - - - -
-- bita      85 2 2    95 3 2    a5 4 2    b5 4 3    -- - -   a&m           - - x x 0 -
-- bitb      c5 2 2    d5 3 2    e5 4 2    f5 4 3    -- - -   b&m           - - x x 0 -
-- ble       2f 3 2    -- - -    -- - -    -- - -    -- - -   bra(le)       - - - - - -
-- blo       25 3 2    -- - -    -- - -    -- - -    -- - -   bra(lo)       - - - - - -
-- bls       23 3 2    -- - -    -- - -    -- - -    -- - -   bra(ls)       - - - - - -
-- blt       2d 3 2    -- - -    -- - -    -- - -    -- - -   bra(lt)       - - - - - -
-- bmi       2b 3 2    -- - -    -- - -    -- - -    -- - -   bra(mi)       - - - - - -
-- bne       26 3 2    -- - -    -- - -    -- - -    -- - -   bra(ne)       - - - - - -
-- bpl       2a 3 2    -- - -    -- - -    -- - -    -- - -   bra(pl)       - - - - - -
-- bra       20 3 2    -- - -    -- - -    -- - -    -- - -   bra           - - - - - -
-- brn       21 3 2    -- - -    -- - -    -- - -    -- - -   bra( 0)       - - - - - -
-- bsr       8d 5 2    -- - -    -- - -    -- - -    -- - -   bsr           - - - - - -
-- bvc       28 3 2    -- - -    -- - -    -- - -    -- - -   bra(vc)       - - - - - -
-- bvs       29 3 2    -- - -    -- - -    -- - -    -- - -   bra(vs)       - - - - - -
-- clr       -- - -    -- - -    6f 5 2    7f 5 3    -- - -   m=0           - - x x 0 0
-- clra      -- - -    -- - -    -- - -    -- - -    4f 1 1   a=0           - - x x 0 0
-- clrb      -- - -    -- - -    -- - -    -- - -    5f 1 1   b=0           - - x x 0 0
-- cmpa      81 2 2    91 3 2    a1 4 2    b1 4 3    -- - -   a-m           - - x x x x
-- cmpb      c1 2 2    d1 3 2    e1 4 2    f1 4 3    -- - -   b-m           - - x x x x
-- cmpd    1083 5 4  1093 7 3  10a3 7 3  10b3 8 4    -- - -   d-m           - x x x x x
-- cmps    118c 3 3  119c 4 2  11ac 5 2  11bc 5 3    -- - -   d-m           - - x x x x
-- cmpu    1183 5 4  1193 7 3  11a3 7 3  11b3 8 4    -- - -   u-m           - x x x x x
-- cmpx      8c 3 3    9c 4 2    ac 5 2    bc 5 3    -- - -   x-m           - - x x x x
-- cmpy    108c 3 3  109c 4 2  10ac 5 2  10bc 5 3    -- - -   y-m           - - x x x x
-- com       -- - -    -- - -    63 6 2    73 6 3    -- - -   m=~m          - - x x 0 1
-- coma      -- - -    -- - -    -- - -    -- - -    43 1 1   a=~a          - - x x 0 1
-- comb      -- - -    -- - -    -- - -    -- - -    53 1 1   b=~b          - - x x 0 1
-- cwai      3c ? 2    -- - -    -- - -    -- - -    -- - -   cc&=im;wait   7 6 6 6 6 6
-- daa       -- - -    -- - -    -- - -    -- - -    19 2 1   a=da(a)       - - x x x 3
-- dec       -- - -    -- - -    6a 6 2    7a 6 3    -- - -   m-=1          - - x x x -
-- deca      -- - -    -- - -    -- - -    -- - -    4a 1 1   a-=1          - - x x x -
-- decb      -- - -    -- - -    -- - -    -- - -    5a 1 1   b-=1          - - x x x -
-- eora      88 2 2    98 3 2    a8 4 2    b8 4 3    -- - -   a^=m          - - x x 0 -
-- eorb      c8 2 2    d8 3 2    e8 4 2    f8 4 3    -- - -   b^=m          - - x x 0 -
-- exg       1e 8 2    -- - -    -- - -    -- - -    -- - -   r(n)<->r(n)   - - - - - -
-- inc       -- - -    -- - -    6c 6 2    7c 6 3    -- - -   m+=1          - - x x x -
-- inca      -- - -    -- - -    -- - -    -- - -    4c 1 1   a+=1          - - x x x -
-- incb      -- - -    -- - -    -- - -    -- - -    5c 1 1   b+=1          - - x x x -
-- jmp       -- - -    0e 3 2    6e 3 2    7e 3 3    -- - -   jmp           - - - - - -
-- jsr       -- - -    9d 5 2    ad 5 2    bd 6 3    -- - -   jsr           - - - - - -
-- lda       86 2 2    96 3 2    a6 4 2    b6 4 3    -- - -   a=m           - - x x 0 -
-- ldb       c6 2 2    d6 3 2    e6 4 2    f6 4 3    -- - -   b=m           - - x x 0 -
-- ldd       cc 3 3    dc 4 2    ec 5 2    fc 5 3    -- - -   d=m           - - x x 0 -
-- lds     10ce 3 3  10de 4 2  10ee 5 2  10fe 5 3    -- - -   s=m           - - x x 0 -
-- ldu       ce 3 3    de 4 2    ee 5 2    fe 5 3    -- - -   u=m           - - x x 0 -
-- ldx       8e 3 3    9e 4 2    ae 5 2    be 5 3    -- - -   x=m           - - x x 0 -
-- ldy     108e 3 3  109e 4 2  10ae 5 2  10be 5 3    -- - -   y=m           - - x x 0 -
-- leas      -- - -    -- - -    32 4 2    -- - -    -- - -   s=&m          - - - - - -
-- leau      -- - -    -- - -    33 4 2    -- - -    -- - -   s=&m          - - - - - -
-- leax      -- - -    -- - -    30 4 2    -- - -    -- - -   s=&m          - - - x - -
-- leay      -- - -    -- - -    31 4 2    -- - -    -- - -   s=&m          - - - x - -
-- lsr       -- - -    -- - -    64 6 2    74 6 3    -- - -   (u)m>>=1      - - x x x x
-- lsra      -- - -    -- - -    -- - -    -- - -    44 1 1   (u)a>>=1      - - x x x x
-- lsrb      -- - -    -- - -    -- - -    -- - -    54 1 1   (u)b>>=1      - - x x x x
-- mul       -- - -    -- - -    -- - -    -- - -    3d ? 1   d=a*b         - - - x - 4
-- neg       -- - -    -- - -    60 6 2    70 6 3    -- - -   m=-m          - - x x x x
-- nega      -- - -    -- - -    -- - -    -- - -    40 1 1   a=-a          - - x x x x
-- negb      -- - -    -- - -    -- - -    -- - -    50 1 1   b=-b          - - x x x x
-- nop       -- - -    -- - -    -- - -    -- - -    01 1 1   nop           - - - - - -
-- ora       8a 2 2    9a 3 2    aa 4 2    ba 4 3    -- - -   a|=m          - - x x 0 -
-- orb       ca 2 2    da 3 2    ea 4 2    fa 4 3    -- - -   b|=m          - - x x 0 -
-- orcc      1a 3 2    -- - -    -- - -    -- - -    -- - -   cc|=im        6 6 6 6 6 6
-- pshs      34 ? 2    -- - -    -- - -    -- - -    -- - -   push rf       - - - - - -
-- pshu      36 ? 2    -- - -    -- - -    -- - -    -- - -   push rf       - - - - - -
-- puls      35 ? 2    -- - -    -- - -    -- - -    -- - -   pull rf       - - - - - -
-- pulu      37 ? 2    -- - -    -- - -    -- - -    -- - -   pull rf       - - - - - -
-- rol       -- - -    -- - -    69 6 2    79 6 3    -- - -   m=rol(m)      - - x x x x
-- rola      -- - -    -- - -    -- - -    -- - -    49 1 1   a=rol(a)      - - x x x x
-- rolb      -- - -    -- - -    -- - -    -- - -    59 1 1   b=rol(b)      - - x x x x
-- ror       -- - -    -- - -    66 6 2    76 6 3    -- - -   m=ror(m)      - - x x x x
-- rora      -- - -    -- - -    -- - -    -- - -    46 1 1   a=ror(a)      - - x x x x
-- rorb      -- - -    -- - -    -- - -    -- - -    56 1 1   b=ror(b)      - - x x x x
-- rti       -- - -    -- - -    -- - -    -- - -    3b a 1   rti           x x x x x x
-- rts       -- - -    -- - -    -- - -    -- - -    39 5 1   rts           - - - - - -
-- sbca      82 2 2    92 3 2    a2 4 2    b2 4 3    -- - -   a-=m+c        - - x x x x
-- sbcb      c2 2 2    d2 3 2    e2 4 2    f2 4 3    -- - -   b-=m+c        - - x x x x
-- sex       -- - -    -- - -    -- - -    -- - -    1d 2 1   d=(sc)b       - - x x 0 -
-- sta       -- - -    97 3 2    a7 4 2    b7 4 3    -- - -   m=a           - - x x 0 -
-- stb       -- - -    d7 3 2    e7 4 2    f7 4 3    -- - -   m=b           - - x x 0 -
-- std       -- - -    dd 4 2    ed 5 2    fd 5 3    -- - -   m=d           - - x x 0 -
-- sts       -- - -  10df 4 2  10ef 5 2  10ff 5 3    -- - -   s=m           - - x x 0 -
-- stu       -- - -    df 4 2    ef 5 2    ff 5 3    -- - -   u=m           - - x x 0 -
-- stx       -- - -    9f 4 2    af 5 2    bf 5 3    -- - -   x=m           - - x x 0 -
-- sty       -- - -  109f 4 2  10af 5 2  10bf 5 3    -- - -   y=m           - - x x 0 -
-- suba      80 2 2    90 3 2    a0 4 2    b0 4 3    -- - -   a-=m          - - x x x x
-- subb      c0 2 2    d0 3 2    e0 4 2    f0 4 3    -- - -   b-=m          - - x x x x
-- subd      83 3 3    93 4 2    a3 5 2    b3 5 3    -- - -   d-=m          - - x x x x
-- swi       -- - -    -- - -    -- - -    -- - -    3f ? 1   swi           - 1 - - - -
-- swi2      -- - -    -- - -    -- - -    -- - -  103f ? 2   swi           - 1 - - - -
-- swi3      -- - -    -- - -    -- - -    -- - -  113f ? 2   swi           - 1 - - - -
-- sync      -- - -    -- - -    -- - -    -- - -    13 ? 1   sync to int   - - - - - -
-- tfr       1f 6 2    -- - -    -- - -    -- - -    -- - -   r(n)=r(n)     - - - - - -
-- tst       -- - -    -- - -    6d 4 2    7d 4 3    -- - -   m-0           - - x x 0 0
-- tsta      -- - -    -- - -    -- - -    -- - -    4d 1 1   a-0           - - x x 0 0
-- tstb      -- - -    -- - -    -- - -    -- - -    5d 1 1   b-0           - - x x 0 0
-- 
-- cc notes:
-- -  not changed
-- x  updated according to data
-- 0  set to 0
-- 1  set to 1
-- 3  c|=(msn>9)
-- 4  Most significant bit of b.
-- 5  Set when interrupt occurs. If previously set,
--    a Non-Maskable interrupt is required to exit the wait state.
-- 


library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.mce6309_pack.all;

entity mce6309_mcode is
  generic
  (
    HAS_BDM       : boolean := true
  );
	port 
	(
		-- Inputs
		clk						: in std_logic;
		clken					: in std_logic;
		ir						: in std_logic_vector(11 downto 0);
		mc_addr				: in mc_state_type;
		dbus					: in std_logic_vector(7 downto 0);
		rpost					: in std_logic_vector(7 downto 0);

		-- Microcode controls
		mc_jump				: out std_logic;
		mc_jump_addr	: out mc_state_type;
	
		-- Operational controls
		alu_ctrl			:	out alu_type;
		alu_igncarry	:	out std_logic;
		mem_read			: out std_logic;
		drive_vma			: out std_logic;
		drive_data		: out std_logic;
	
		-- Register controls
		pc_ctrl				: out pc_type;
		ir_ctrl				: out ir_type;
		s_ctrl				: out s_type;
		ld						: out ld_type;
		lea						: out lea_type;
		acc_fromalu		: out std_logic;
	
		-- Mux controls
		dbus_ctrl			: out dbus_type;
		abus_ctrl			: out abus_type;
		eabus_ctrl		: out eabus_type;
		--abusl_ctrl		: out abus_type;
		left_ctrl			: out left_type;
		right_ctrl		: out right_type;
		
		-- bdm controls
		bdm_rdy       : in std_logic;
		bdm_ir        : in std_logic_vector(23 downto 0);

		-- register io
		bdm_r_sel		: in std_logic_vector(3 downto 0);
    bdm_r_d_i		: in std_logic_vector(15 downto 0);
		bdm_r_d_o   : out std_logic_vector(15 downto 0);
		bdm_wr			: in std_logic;
		bdm_cr_i		: in std_logic_vector(7 downto 0);
		bdm_cr_set  : out std_logic_vector(7 downto 0);
		bdm_cr_clr  : out std_logic_vector(7 downto 0)
	);
end entity mce6309_mcode;

architecture SYN of mce6309_mcode is

	type Exg_Ld_Type is array(0 to 15) of Ld_idx;
	type Exg_Dbus_Type is array(0 to 15) of dbus_type;

	constant dbus_def : dbus_type := dbus_mem;
	constant exg_dbus_hi : Exg_Dbus_Type := (dbus_a, dbus_xh, dbus_yh, dbus_uh, dbus_sh, dbus_pch, dbus_def, dbus_def, 
		dbus_a, dbus_b, dbus_cc, dbus_dp, dbus_def, dbus_def, dbus_def, dbus_def );
	constant exg_dbus_lo : Exg_Dbus_type := (dbus_b, dbus_xl, dbus_yl, dbus_ul, dbus_sl, dbus_pcl, dbus_def, dbus_def, 
		dbus_def, dbus_def, dbus_def, dbus_def, dbus_def, dbus_def, dbus_def, dbus_def );
	constant exg_ld_hi : Exg_Ld_Type := (IA, IXh, IYh, IUh, ISh, IPCh, INOREG, INOREG, IA, IB, ICC, 
		IDP, INOREG, INOREG, INOREG, INOREG);
	constant exg_ld_lo : Exg_Ld_Type := (IB, IXl, IYl, IUl, ISl, IPCl, INOREG, INOREG, INOREG, INOREG,
 		INOREG, INOREG, INOREG, INOREG, INOREG, INOREG);

	alias index_indirect : std_logic is rpost(4);
	alias index_reg		: std_logic_vector(1 downto 0) is rpost(6 downto 5);

	signal idxsel			: eabus_type;
	signal alu_op			:	alu_type;
	
begin

	-- CPU microcode
	mc_table: process(ir, mc_addr, alu_op, dbus, rpost, bdm_ir, bdm_cr_i, bdm_rdy)
		variable rpost_hi_nib : integer;
		variable rpost_lo_nib : integer;
	begin
		-- Defaults
		mc_jump				<= '0';
		mc_jump_addr	<= mc_fetch0;
		alu_ctrl			<= alu_idle;
		alu_igncarry	<= '0';
		mem_read			<= '1';
		drive_vma			<= '1';
		drive_data		<= '1';
		pc_ctrl				<= latch_pc;
		ir_ctrl				<= latch_ir;
		s_ctrl				<= latch_s;
		ld						<= (others => '0');
		lea						<= (others => '0');
		acc_fromalu		<= '1';
		dbus_ctrl			<= dbus_def;
		abus_ctrl			<= abus_pc;
		eabus_ctrl		<= eabus_ea;
		--abusl_ctrl		<= abus_pc;

		bdm_cr_set		<= (others => '0');
		bdm_cr_clr		<= (others => '0');
		
		rpost_hi_nib := to_integer(unsigned(rpost(7 downto 4)));
		rpost_lo_nib := to_integer(unsigned(rpost(3 downto 0)));

		-- Default ALU left input
		case ir(7 downto 4) is
  		when X"8" | X"9" | X"A" | X"B" | X"4"		=> left_ctrl <= left_a;
  		when X"C" | X"D" | X"E" | X"F" | X"5"		=> left_ctrl <= left_b;
  		when others => left_ctrl <= left_a;
		end case;

		-- Default ALU right input
		case ir(7 downto 4) is
  		when X"4" | X"5" | X"6" | X"7" => right_ctrl <= right_c1;
  		when others => right_ctrl <= right_dbus;
		end case;

		-- Instruction fetch
		if mc_addr = mc_fetch0 then
		  if HAS_BDM and bdm_cr_i(BDM_CR_ENABLE) = '1' then
	      mc_jump_addr <= mc_fetch0;  -- default
	      mc_jump <= '1';             -- default
		    if false then -- breakpoint address?
		    elsif bdm_cr_i(BDM_CR_HALT_NEXT) = '1' then
		      if bdm_rdy = '1' then
		        case bdm_ir(23 downto 20) is
  		        when X"3" =>
      		      case bdm_ir(19 downto 16) is
    		          -- single step
      		        when X"1" =>
              			pc_ctrl <= incr_pc;
              			ir_ctrl <= load_1st_ir;
              			dbus_ctrl <= dbus_mem;
      		          mc_jump <= '0';
      		          bdm_cr_set(1) <= '1';
      		        -- go
      		        when X"2" =>
              			pc_ctrl <= incr_pc;
              			ir_ctrl <= load_1st_ir;
              			dbus_ctrl <= dbus_mem;
      		          mc_jump <= '0';
      		          bdm_cr_clr(1) <= '1';
      		        when others =>
      		      end case; -- ir(19..16)
      		    when others =>
      		      null;
      		  end case; -- ir(23..20)
  		    end if;
  		  else
    			pc_ctrl <= incr_pc;
    			ir_ctrl <= load_1st_ir;
    			dbus_ctrl <= dbus_mem;
    			mc_jump <= '0';
		    end if;
		  else
  			pc_ctrl <= incr_pc;
  			ir_ctrl <= load_1st_ir;
  			dbus_ctrl <= dbus_mem;
      end if;
      
		elsif mc_addr = mc_fetch1 then
			ir_ctrl <= load_2nd_ir;
			dbus_ctrl <= dbus_mem;
			ld(IPOST) <= '1';

			case dbus(7 downto 4) is
  			when X"6" | X"A" | X"E" =>
  				mc_jump <= '1';
  				mc_jump_addr <= mc_index0;
  			when others =>
			end case;

			if (ir(9 downto 8) /= "00") or (ir(7 downto 4) >= X"6" or ir = X"01E") then
				pc_ctrl <= incr_pc;
			else
				pc_ctrl <= latch_pc;
			end if;

			if ir(9 downto 8) /= "00" and (dbus = X"10" or dbus = X"11") then
				mc_jump <= '1';
				mc_jump_addr <= mc_fetch1;
			end if;
		end if;

		-- Indexed addressing (TODO PC offset)
		case index_reg is 
  		when "00" => idxsel <= eabus_x;
  		when "01" => idxsel <= eabus_y;
  		when "10" => idxsel <= eabus_u;
  		when "11" => idxsel <= eabus_s;
  		when others =>
		end case;

--		if std_match(rpost, "1---0100") then	-- No offset
--			idxabus <= idxsel;
--		else
--			idxabus <= abus_ea;
--		end if;

		ld(ICC) <= '1';

		case mc_addr is
  		when mc_index0 =>
  			alu_igncarry	<= '1';
  			alu_ctrl <= alu_add;
  			left_ctrl <= left_eal;
  			if std_match(rpost, "1---0100") then	-- No offset
  				mc_jump <= '1';
  				mc_jump_addr <= mc_exec0;	
  			else
  				ld(IEAl) <= '1';
  				if std_match(rpost, "0-------") then	-- 5-bit offset
  					right_ctrl <= right_dbus5;
  					dbus_ctrl <= dbus_post;
  				elsif std_match(rpost, "1---1-00") 			-- 8-bit offset
  				   or std_match(rpost, "1---1-01") then	-- 16-bit offset
  					pc_ctrl <= incr_pc;
  					right_ctrl <= right_dbus;
  					dbus_ctrl <= dbus_mem;
  				elsif std_match(rpost, "1---0110") then	-- A offset
  					right_ctrl <= right_dbus;
  					dbus_ctrl <= dbus_a;
  				elsif std_match(rpost, "1---0101") 			-- B offset
  					 or std_match(rpost, "1---1011") then	-- D offset
  					right_ctrl <= right_dbus;
  					dbus_ctrl <= dbus_b;
  				elsif std_match(rpost, "1--00000") 			-- Post inc +1 
  				   or std_match(rpost, "1--00001") 			-- Post inc +2
  				   or std_match(rpost, "1--00010") 			-- Post dec -1
  				   or std_match(rpost, "1--00011") then	-- Post dec -2
  					right_ctrl <= right_c0;
  				else
  					right_ctrl <= right_dbus;
  					dbus_ctrl <= dbus_mem;
  				end if;
  			end if;
  		when mc_index1 =>
  			alu_ctrl <= alu_add;
  			left_ctrl <= left_eah;
  			if std_match(rpost, "0-------") then	-- 5-bit offset
  				drive_vma	<= '0';
  				right_ctrl <= right_c0;
  			elsif std_match(rpost, "1---1-01") then	-- 16-bit offset
  				pc_ctrl <= incr_pc;
  				right_ctrl <= right_dbus;
  				dbus_ctrl <= dbus_mem;
  			elsif std_match(rpost, "1---1011") then	-- D offset
  				right_ctrl <= right_dbus;
  				dbus_ctrl <= dbus_a;
  			else
  				right_ctrl <= right_c0;
  			end if;
  			ld(IEAh) <= '1';
--			  if std_match(rpost, "0-------") then	-- 5-bit offset
				  mc_jump <= '1';
				  mc_jump_addr <= mc_exec0;	
--			  elsif std_match(rpost, "1---1000") then	-- 8-bit offset
--			  elsif std_match(rpost, "1---1001") then	-- 16-bit offset
--			  elsif std_match(rpost, "1---0110") then	-- A offset
--			  elsif std_match(rpost, "1---0101") then	-- B offset
--			  elsif std_match(rpost, "1---1011") then	-- D offset
--			  elsif std_match(rpost, "1--00000") then	-- Post inc +1 
--			  elsif std_match(rpost, "1--00001") then	-- Post inc +2
--			  elsif std_match(rpost, "1--00010") then	-- Post dec -1
--			  elsif std_match(rpost, "1--00011") then	-- Post dec -2
--			  elsif std_match(rpost, "1---1100") then	-- PC 8-bit offset
--			  elsif std_match(rpost, "1---1101") then	-- PC 16-bit offset
--			  elsif std_match(rpost, "1--11111") then	-- Extended indirect
--			  end if;
		  when others =>
		end case;

		-- Instruction decode
		if mc_addr /= mc_fetch0 then
			case ir(11 downto 4) is
			
  			when X"01" =>
  				case ir(3 downto 0) is
  				when X"2" =>		-- NOP
  					mc_jump <= '1';
  					mc_jump_addr <= mc_fetch0;	
  
  				when X"0" | X"1" =>			-- IR Page 1, Page 2
  															
  				when X"3" =>		-- SYNC
  												 
  				when X"9" =>		-- DAA
  
  				when X"D" =>		-- SEX
  
  				when X"E" =>		-- EXG
  					acc_fromalu <= '0';	-- XXX - Optimise later!
  
  					case mc_addr is
    					when mc_fetch1 =>
    						ld(IPOST) <= '1';
    					when mc_exec0 =>	-- Copy high byte R0 -> EA
    						dbus_ctrl <= exg_dbus_hi(rpost_lo_nib);
    						ld(IEAh) <= '1';
    						drive_vma	<= '0';
    					when mc_exec1 =>	-- Copy low byte R0 -> EA
    						dbus_ctrl <= exg_dbus_lo(rpost_lo_nib);
    						ld(IEAl) <= '1';
    						drive_vma	<= '0';
    					when mc_exec2 =>	-- Copy high byte R1 -> R0
    						dbus_ctrl <= exg_dbus_hi(rpost_hi_nib);
    						case exg_ld_hi(rpost_lo_nib) is
    						when INOREG | ISl | IPCl =>
    						when ISh =>
    							s_ctrl <= loadhi_s;
    						when IPCh =>
    							pc_ctrl <= loadhi_pc;
    						when others =>
    							ld(exg_ld_hi(rpost_lo_nib)) <= '1';
  						end case;
  						drive_vma	<= '0';
  					when mc_exec3 =>	-- Copy low byte R1 -> R0
  						dbus_ctrl <= exg_dbus_lo(rpost_hi_nib);
  						case exg_ld_lo(rpost_lo_nib) is
    						when INOREG | ISh | IPCh =>
    						when ISl =>
    							s_ctrl <= loadlo_s;
    						when IPCl =>
    							pc_ctrl <= loadlo_pc;
    						when others =>
    							ld(exg_ld_lo(rpost_lo_nib)) <= '1';
  						end case;
  						drive_vma	<= '0';
  					when mc_exec4 =>	-- Copy high byte EA -> R1
  						case exg_ld_hi(rpost_hi_nib) is
    						when INOREG | ISl | IPCl =>
    						when ISh =>
    							s_ctrl <= loadhi_s;
    						when IPCh =>
    							pc_ctrl <= loadhi_pc;
    						when others =>
    							ld(exg_ld_hi(rpost_hi_nib)) <= '1';
  						end case;
  						dbus_ctrl <= dbus_eah;
  						drive_vma	<= '0';
  					when mc_exec5 =>	-- Copy low byte EA -> R1
  						case exg_ld_lo(rpost_hi_nib) is
    						when INOREG | ISh | IPCh =>
    						when ISl =>
    							s_ctrl <= loadlo_s;
    						when IPCl =>
    							pc_ctrl <= loadlo_pc;
    						when others =>
    							ld(exg_ld_lo(rpost_hi_nib)) <= '1';
  						end case;
  						dbus_ctrl <= dbus_eal;
  						drive_vma	<= '0';
  						mc_jump				<= '1';
  						mc_jump_addr	<= mc_fetch0;
  					when others =>
  					end case;
  
  				when X"F" =>		-- TFR
  
  				when others =>
  					mc_jump <= '1';
  					mc_jump_addr <= mc_fetch0;	
				end case;

      when X"03" =>
        case ir(3 downto 0) is
          when X"A" =>                -- ABX
          when others =>
        end case;
        
			when X"04" | X"05" =>
				case ir(3 downto 0) is
  				when X"3" | X"A" | X"C" =>	-- A,B inheren
  					mc_jump <= '1';
  					mc_jump_addr <= mc_fetch0;
  					--pc_ctrl <= latch_pc;
  					alu_ctrl <= alu_op;
  					dbus_ctrl <= dbus_alu;
  					if ir(7 downto 4) = X"4" then
  						ld(IA) <= '1';
  					else
  						ld(IB) <= '1';
  					end if;
  				when others =>
				end case;
				
			when X"08" | X"0C" | X"28" | X"2C" | X"38"  =>
				case ir(3 downto 0) is 
  				when X"0" | X"1" | X"2" | X"4" | X"6" | X"8" | X"9" | X"A" | X"B" =>	-- ALUOP A,B immed
  					--if mc_addr = mc_fetch1 then
  						pc_ctrl <= incr_pc;
  						mc_jump <= '1';
  						mc_jump_addr <= mc_fetch0;
  						--pc_ctrl <= latch_pc;
  						alu_ctrl <= alu_op;
  						dbus_ctrl <= dbus_mem;
  						if ir(7 downto 4) = X"8" then
  							ld(IA) <= '1';
  						else
  							ld(IB) <= '1';
  						end if;
  					--end if;
  				when others =>
				end case;

			when X"09" | X"0D" | X"29" | X"2D" | X"39" =>
				case ir(3 downto 0) is 
  				when X"0" | X"1" | X"2" | X"4" | X"6" | X"8" | X"9" | X"A" | X"B" =>	-- ALUOP A,B direct
  					case mc_addr is
    					when mc_fetch1 =>
    						--pc_ctrl <= incr_pc;
    						ld(IEAl) <= '1';
    					when mc_exec0 =>
    						dbus_ctrl <= dbus_dp;
    						ld(IEAh) <= '1';
    						drive_vma	<= '0';
    					when mc_exec1 =>
    						mc_jump				<= '1';
    						mc_jump_addr	<= mc_fetch0;
    						alu_ctrl			<= alu_op;
    						dbus_ctrl			<= dbus_mem;
    						abus_ctrl			<= abus_ea;
    						if ir(7 downto 4) = X"9" then
    							ld(IA) <= '1';
    						else
    							ld(IB) <= '1';
    						end if;
    					when others =>
  					end case;
  
  				when X"7" =>																													-- ST A,B direct
  					case mc_addr is
    					when mc_fetch1 =>
    						--pc_ctrl <= incr_pc;
    						ld(IEAl) <= '1';
    					when mc_exec0 =>
    						dbus_ctrl <= dbus_dp;
    						ld(IEAh) <= '1';
    						drive_vma	<= '0';
    					when mc_exec1 =>
    						mc_jump				<= '1';
    						mc_jump_addr	<= mc_fetch0;
    						drive_vma			<= '1';
    						if ir(7 downto 4) = X"9" then
    							dbus_ctrl		<= dbus_a;
    						else
    							dbus_ctrl		<= dbus_b;
    						end if;
    						abus_ctrl			<= abus_ea;
    					when others =>
  					end case;

				  when others =>
				end case;

			when X"0A" | X"0E" | X"2A" | X"2E" | X"3A" =>
				case ir(3 downto 0) is 
  				when X"0" | X"1" | X"2" | X"4" | X"6" | X"8" | X"9" | X"A" | X"B" =>	-- ALUOP A,B index
  					case mc_addr is
    					when mc_fetch1 =>
    						mc_jump				<= '1';
    						mc_jump_addr	<= mc_index0;
    						lea(EAEA)			<= '1';
    						if not std_match(rpost, "1---110-") then	-- PC offset
    							case dbus(6 downto 5) is 
    							when "00" => eabus_ctrl <= eabus_x;
    							when "01" => eabus_ctrl <= eabus_y;
    							when "10" => eabus_ctrl <= eabus_u;
    							when others => eabus_ctrl <= eabus_s; -- "11"
    							end case;
    						else
    							eabus_ctrl <= eabus_pc;
    						end if;
    					when mc_exec0 =>
    						mc_jump				<= '1';
    						mc_jump_addr	<= mc_fetch0;
    						alu_ctrl			<= alu_op;
    						dbus_ctrl			<= dbus_mem;
    						abus_ctrl			<= abus_ea;
    						if ir(7 downto 4) = X"A" then
    							ld(IA) <= '1';
    						else
    							ld(IB) <= '1';
    						end if;
    					when others =>
  					end case;
  				when others =>
				end case;

			when X"0B" | X"0F" | X"2B" | X"2F" | X"3B" =>
				case ir(3 downto 0) is 
  				when X"0" | X"1" | X"2" | X"4" | X"6" | X"8" | X"9" | X"A" | X"B" =>	-- ALUOP A,B extended
  					case mc_addr is
    					when mc_fetch1 =>
    						ld(IEAh) <= '1';
    					when mc_exec0 =>
    						pc_ctrl <= incr_pc;
    						ld(IEAl) <= '1';
    					when mc_exec1 =>
    						drive_vma	<= '0';
    					when mc_exec2 =>
    						mc_jump				<= '1';
    						mc_jump_addr	<= mc_fetch0;
    						alu_ctrl			<= alu_op;
    						dbus_ctrl			<= dbus_mem;
    						abus_ctrl			<= abus_ea;
    						if ir(7 downto 4) = X"B" then
    							ld(IA) <= '1';
    						else
    							ld(IB)	<= '1';
    						end if;
    					when others =>
  					end case;
  				when others =>
				end case;

			when others =>
			end case;
			
		end if;
	end process;

	-- ALU control
	alu_in: process(ir)
	begin
		-- ALU_ADD <== "1---10-1" || "11--0011" || "01--1100" || "00001100"
		--ALU_SUB <== "1---0001" || $10 & "10--0011" || $11 & "10--1100" || $11 & "10--0011" || "1---1100" || 
		--						$10 & "10--1100" ||"01--1010" || "1---00-0" || "10--0011"
		--ALU_OR <== "00011010" || "1---1010"
		--ALU_AND <== "00011100" || "1---010-"
		--ALU_EOR <== "1---1000"
		--ALU_ROL <== "01--100-"
		--ALU_ROR <== "01--011-" || "01--0100"

		alu_op <= alu_idle;
		-- Addition 
		if std_match(ir, "----1---10-1") or std_match(ir, "----11--0011") or std_match(ir, "----01--1100") or std_match(ir, "----00001100") then
			alu_op <= alu_add;
		end if;
		if     std_match(ir, "----1---0001") or std_match(ir, "--1010--0011") or std_match(ir, "--1110--1100") 
				or std_match(ir, "--1110--0011") or std_match(ir, "----1---1100") or std_match(ir, "--1010--1100") 
				or std_match(ir, "----01--1010") or std_match(ir, "----1---00-0") or std_match(ir, "----10--0011") then
			alu_op <= alu_sub;
		end if;
	end process;
end architecture SYN;
