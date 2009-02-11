library IEEE;
use IEEE.std_logic_1164.all;

package mce6809_pack is

	constant Flag_C : integer := 0;		-- Carry
	constant Flag_V : integer := 1;		-- Overflow
	constant Flag_Z : integer := 2;		-- Zero
	constant Flag_N : integer := 3;		-- Negative
	constant Flag_I : integer := 4;		-- IRQ Mask
	constant Flag_H : integer := 5;		-- Half Carry
	constant Flag_F : integer := 6;		-- FIRQ Mask
	constant Flag_E : integer := 7;		-- Entire Flag

	-- Microcode state (address)
	type mc_state_type is (mc_fetch0, mc_fetch1, mc_exec0, mc_exec1, mc_exec2, mc_exec3, mc_exec4, mc_exec5);

	-- Bus mux select types
	type dbus_type is (dbus_mem, dbus_a, dbus_b, dbus_pcl, dbus_pch, dbus_ul, dbus_uh,
		dbus_sl, dbus_sh, dbus_yl, dbus_yh, dbus_xl, dbus_xh, 
		dbus_eal, dbus_eah, dbus_cc, dbus_dp, --dbus_post, 
		dbus_alu);
	type abus_type is (abus_d, abus_pc, abus_u, abus_s, abus_y, abus_x, abus_ea);
	type left_type is (left_a, left_b, left_eal, left_eah);
	type right_type is (right_dbus, right_c0, right_c1, right_c2);
	
	-- Register mux select types
	type alu_type is (alu_idle, alu_add, alu_sub, alu_or, alu_and, alu_eor, alu_rol, alu_ror);
	type pc_type is (incr_pc, loadhi_pc, loadlo_pc, load_a_pc, latch_pc);
	type ir_type is (load_1st_ir, load_2nd_ir, latch_ir);
	type s_type is (loadhi_s, loadlo_s, load_a_s, latch_s);

	-- Instruction register page
	type ir_page_type is (ir_page0, ir_page1, ir_page2);

	-- Main CPU component
	component mce6809 
		port (
			clk:        in  std_logic;
			clken:      in  std_logic;
			reset:      in  std_logic;
			rw:         out std_logic;
			vma:        out std_logic;
			address:    out std_logic_vector(15 downto 0);
			data_i: 	  in  std_logic_vector(7 downto 0);
			data_o:		 	out std_logic_vector(7 downto 0);
			halt:     	in  std_logic;
			hold:     	in  std_logic;
			irq:      	in  std_logic;
			firq:     	in  std_logic;
			nmi:      	in  std_logic
		);
	end component;

	-- Microcode - do not instantiate directly
	component mce6809_mcode 
		port (
			-- Inputs
			clk						: in  std_logic;
			clken					: in  std_logic;
			ir						: in std_logic_vector(7 downto 0);
			ir_page				: in ir_page_type;
			mc_addr				: in mc_state_type;
			dbus					: in std_logic_vector(7 downto 0);
			rpost					: in std_logic_vector(7 downto 0);
	
			-- Microcode controls
			mc_jump				: out std_logic;
			mc_jump_addr	: out mc_state_type;
		
			-- Operational controls
			alu_ctrl			:	out alu_type;
			mem_read			: out std_logic;
			drive_vma			: out std_logic;
		
			-- Register controls
			pc_ctrl				: out pc_type;
			ir_ctrl				: out ir_type;
			s_ctrl				: out s_type;
			ld						: out std_logic_vector(0 to 12);
--			lda						: out std_logic;
--			ldb						: out std_logic;
--			ldxl					: out std_logic;
--			ldxh					: out std_logic;
--			ldyl					: out std_logic;
--			ldyh					: out std_logic;
--			ldul					: out std_logic;
--			lduh					: out std_logic;
--			ldeal					: out std_logic;
--			ldeah					: out std_logic;
--			lddp					: out std_logic;
--			ldpost				: out std_logic;
--			ldcc					: out std_logic;
		
			-- Mux controls
			dbus_ctrl			: out dbus_type;
			abus_ctrl			: out abus_type;
			--abusl_ctrl		: out abus_type;
			left_ctrl			: out left_type;
			right_ctrl		: out right_type
		);
	end component;

end;

