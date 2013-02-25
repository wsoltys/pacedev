library IEEE;
use IEEE.std_logic_1164.all;

package mce6309_pack is

  type mode_t is ( M6809, M6803 );

	subtype ld_idx is integer range 0 to 17;
	subtype ld_type is std_logic_vector(12 downto 0);

	subtype lea_idx is integer range 0 to 5;
	subtype lea_type is std_logic_vector(4 downto 0);

	constant Flag_C : integer := 0;		-- Carry
	constant Flag_V : integer := 1;		-- Overflow
	constant Flag_Z : integer := 2;		-- Zero
	constant Flag_N : integer := 3;		-- Negative
	constant Flag_I : integer := 4;		-- IRQ Mask
	constant Flag_H : integer := 5;		-- Half Carry
	constant Flag_F : integer := 6;		-- FIRQ Mask
	constant Flag_E : integer := 7;		-- Entire Flag

	-- Index into ld vector
	constant IA			: ld_idx := 0;
	constant IB			: ld_idx := 1;
	constant IXl		: ld_idx := 2;
	constant IXh		: ld_idx := 3;
	constant IYl		: ld_idx := 4;
	constant IYh		: ld_idx := 5;
	constant IUl		: ld_idx := 6;
	constant IUh		: ld_idx := 7;
	constant IEAl		: ld_idx := 8;
	constant IEAh		: ld_idx := 9;
	constant IDP		: ld_idx := 10;
	constant IPOST	: ld_idx := 11;
	constant ICC		: ld_idx := 12;
	-- Past this point is for mcode-internal use only
	constant ISl		: ld_idx := 13;
	constant ISh		: ld_idx := 14;
	constant IPCl		: ld_idx := 15;
	constant IPCh		: ld_idx := 16;
	constant INOREG	: ld_idx := 17;

	-- Index into lea vector
	constant EAEA		: lea_idx := 0;
	constant EAX		: lea_idx := 1;
	constant EAY		: lea_idx := 2;
	constant EAU		: lea_idx := 3;
	constant EAS		: lea_idx := 4;

	-- Microcode state (address)
	type mc_state_type is (mc_fetch0, mc_fetch1, 
		mc_index0, mc_index1, mc_index2, mc_index3, mc_index4, mc_index5, mc_index6, mc_index7,
		mc_exec0, mc_exec1, mc_exec2, mc_exec3, mc_exec4, mc_exec5);

	-- Bus mux select types
	type dbus_type is (dbus_mem, dbus_a, dbus_b, dbus_pcl, dbus_pch, dbus_ul, dbus_uh,
		dbus_sl, dbus_sh, dbus_yl, dbus_yh, dbus_xl, dbus_xh, 
		dbus_eal, dbus_eah, dbus_cc, dbus_dp, dbus_post, 
		dbus_alu);
	type abus_type is (abus_d, abus_pc, abus_u, abus_s, abus_y, abus_x, abus_ea);
	type eabus_type is (eabus_u, eabus_s, eabus_y, eabus_x, eabus_pc, eabus_ea);
	type left_type is (left_a, left_b, left_eal, left_eah);
	type right_type is (right_dbus, right_dbus5, right_c0, right_c1, right_c2);
	
	-- Register mux select types
	type alu_type is (alu_idle, alu_add, alu_sub, alu_or, alu_and, alu_eor, alu_rol, alu_ror);
	type pc_type is (incr_pc, loadhi_pc, loadlo_pc, load_a_pc, latch_pc);
	type ir_type is (load_1st_ir, load_2nd_ir, latch_ir);
	type s_type is (loadhi_s, loadlo_s, load_a_s, latch_s);

	type ir_page_type is (ir_page0, ir_page1, ir_page2);

	-- Main CPU component
	component mce6309 
		port 
		(
  	  -- clocking, reset
  		clk             : in  std_logic;
  		clken           : in  std_logic;
  		reset           : in  std_logic;
  		
  		-- bus signals
  		rw              : out std_logic;
  		vma             : out std_logic;
  		address         : out std_logic_vector(15 downto 0);
  		data_i  	      : in  std_logic_vector(7 downto 0);
  		data_o 		 	    : out std_logic_vector(7 downto 0);
  		data_oe 		    : out std_logic;
  		lic 				    : out std_logic;
  		halt      	    : in  std_logic;
  		hold      	    : in  std_logic;
  		irq       	    : in  std_logic;
  		firq      	    : in  std_logic;
  		nmi       	    : in  std_logic;
  		
  		-- bdm signals
  		bdm_clk         : in std_logic;
  		bdm_i           : in std_logic;
  		bdm_o           : out std_logic;
  		bdm_oe          : out std_logic;
  		
  		-- misc signals
  		op_fetch        : out std_logic
		);
	end component mce6309;

--	-- Microcode - do not instantiate directly
--	component mce6309_mcode 
--		port (
--			-- Inputs
--			clk						: in  std_logic;
--			clken					: in  std_logic;
--			ir						: in std_logic_vector(11 downto 0);
--			mc_addr				: in mc_state_type;
--			dbus					: in std_logic_vector(7 downto 0);
--			rpost					: in std_logic_vector(7 downto 0);
--	
--			-- Microcode controls
--			mc_jump				: out std_logic;
--			mc_jump_addr	: out mc_state_type;
--		
--			-- Operational controls
--			alu_ctrl			:	out alu_type;
--			alu_igncarry	: out std_logic;
--			mem_read			: out std_logic;
--			drive_vma			: out std_logic;
--			drive_data		: out std_logic;
--		
--			-- Register controls
--			pc_ctrl				: out pc_type;
--			ir_ctrl				: out ir_type;
--			s_ctrl				: out s_type;
--			ld						: out ld_type;
--			lea						: out lea_type;
--			acc_fromalu		: out std_logic;
--		
--			-- Mux controls
--			dbus_ctrl			: out dbus_type;
--			abus_ctrl			: out abus_type;
--			eabus_ctrl		: out eabus_type;
--			--abusl_ctrl		: out abus_type;
--			left_ctrl			: out left_type;
--			right_ctrl		: out right_type
--		);
--	end component mce6309_mcode;

	-- BDM registers
	constant BDM_R_CR						: integer := 0;
	constant BDM_R_SR						: integer := 1;
	constant BDM_R_AP						: integer := 2;
	constant BDM_R_BP						: integer := 3;
	
	-- BDM control register bits
	constant BDM_CR_ENABLE			: integer := 0;
	constant BDM_CR_HALT_NEXT		: integer := 1;
	constant BDM_CR_BP_ENABLE		: integer := 2;
	-- BDM status register bits
	constant BDM_SR_ENABLED			: integer := 0;
	constant BDM_SR_HALTED			: integer := 1;
	constant BDM_SR_BP_ENABLED	: integer := 2;
	constant BDM_SR_PC_EQ_BP    : integer := 3;

end package mce6309_pack;

