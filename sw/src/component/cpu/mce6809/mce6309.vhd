library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
use work.mce6309_pack.all;

entity mce6309 is
  generic
  (
    MODE            : mode_t := M6809;
    CYCLE_ACCURATE  : boolean := true;
    HAS_BDM         : boolean := true
  );
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
		bdm_rst         : in std_logic;
    bdm_mosi        : in std_logic;
    bdm_miso        : out std_logic;
		bdm_i           : in std_logic;
		bdm_o           : out std_logic;
		bdm_oe          : out std_logic;
		
		-- misc signals
		op_fetch        : out std_logic
	);
end entity mce6309;

architecture SYN of mce6309 is

	-- Internal buses
	signal		dbus					: std_logic_vector(7 downto 0);
	--signal		abush					: std_logic_vector(7 downto 0);
	--signal		abusl					: std_logic_vector(7 downto 0);
	signal		abus					: std_logic_vector(15 downto 0);
	signal		eabus					: std_logic_vector(15 downto 0);

	-- CPU registers
	signal		ir						: std_logic_vector(11 downto 0);
	signal		pc						: std_logic_vector(15 downto 0);
	signal		u							: std_logic_vector(15 downto 0);
	signal		s							: std_logic_vector(15 downto 0);
	signal		y							: std_logic_vector(15 downto 0);
	signal		x							: std_logic_vector(15 downto 0);
	signal		acca					: std_logic_vector(7 downto 0);
	signal		accb					: std_logic_vector(7 downto 0);
	signal		dp						: std_logic_vector(7 downto 0);
	signal		cc						: std_logic_vector(7 downto 0);
	signal		ea						: std_logic_vector(15 downto 0);
	signal		post					: std_logic_vector(7 downto 0);

	-- ALU signals
	signal		left					: std_logic_vector(7 downto 0);		-- ALU left
	signal		right					: std_logic_vector(7 downto 0);		-- ALU right
	signal		alu_out				: std_logic_vector(7 downto 0);
	signal		cc_out				: std_logic_vector(7 downto 0);

	-- Microcode controls
	signal		mc_addr				: mc_state_type := mc_fetch0;
	signal		mc_jump				: std_logic;
	signal		mc_jump_addr	: mc_state_type;

	-- Operational controls
	signal		alu_ctrl			:	alu_type;
	signal		alu_igncarry	: std_logic;
	signal		drive_vma			: std_logic;
	signal		drive_data		: std_logic;

	-- Register controls
	signal		pc_ctrl				: pc_type;
	signal		ir_ctrl				: ir_type;
	signal		s_ctrl				: s_type;
	signal		ld						: ld_type;
	signal		lea						: lea_type;
	alias			lda						: std_logic is ld(IA);
	alias			ldb						: std_logic is ld(IB);
	alias			ldxl					: std_logic is ld(IXl);
	alias			ldxh					: std_logic is ld(IXh);
	alias			ldyl					: std_logic is ld(IYl);
	alias			ldyh					: std_logic is ld(IYh);
	alias			ldul					: std_logic is ld(IUl);
	alias			lduh					: std_logic is ld(IUh);
	alias			ldeal					: std_logic is ld(IEAl);
	alias			ldeah					: std_logic is ld(IEAh);
	alias			lddp					: std_logic is ld(IDP);
	alias			ldpost				: std_logic is ld(IPOST);
	alias			ldcc					: std_logic is ld(ICC);
	signal		acc_fromalu		: std_logic;		-- Use ALU as input to A,B and CC regs

	-- Mux controls
	signal		dbus_ctrl			: dbus_type;
	signal		abus_ctrl			: abus_type;
	signal		eabus_ctrl		: eabus_type;
	--signal		abusl_ctrl		: abus_type;
	signal		left_ctrl			: left_type;
	signal		right_ctrl		: right_type;

	-- BDM signals
	signal 		bdm_rdy				: std_logic;
	signal 		bdm_ir				: std_logic_vector(23 downto 0);

	signal 		bdm_cr				: std_logic_vector(15 downto 0);
	signal 		bdm_sr				: std_logic_vector(15 downto 0);
	signal 		bdm_ap				: std_logic_vector(15 downto 0);

	signal 		bdm_r_d_o   	: std_logic_vector(15 downto 0);
	signal 		bdm_wr				: std_logic;
  
begin
	--abus		<= abush & abusl;

	address <= abus when drive_vma = '1' else (others => 'X');
	vma			<= drive_vma;

	data_o	<= dbus when drive_data = '1' else (others => 'X');
	data_oe	<= drive_data;

	ir(11 downto 10) <= "00";

	mcode : entity work.mce6309_mcode 
	  generic map
	  (
	    HAS_BDM       => HAS_BDM
	  )
	  port map 
	  (
  		-- Inputs
  		clk						=> clk,
  		clken					=> clken,
  		ir						=> ir,
  		mc_addr				=> mc_addr,
  		dbus					=> dbus,
  		rpost					=> post,
  
  		-- Microcode controls
  		mc_jump				=> mc_jump,
  		mc_jump_addr	=> mc_jump_addr,
  	
  		-- Operational controls
  		alu_ctrl			=> alu_ctrl,
  		alu_igncarry	=> alu_igncarry,
  		mem_read			=> rw,
  		drive_vma			=> drive_vma,
  		drive_data		=> drive_data,
  	
  		-- Register controls
  		pc_ctrl				=> pc_ctrl,
  		ir_ctrl				=> ir_ctrl,
  		s_ctrl				=> s_ctrl,
  		ld						=> ld,
  		lea						=> lea,
  		acc_fromalu		=> acc_fromalu,
  	
  		-- Mux controls
  		dbus_ctrl			=> dbus_ctrl,
  		abus_ctrl			=> abus_ctrl,
  		eabus_ctrl		=> eabus_ctrl,
  		--abusl_ctrl		=> abusl_ctrl,
  		left_ctrl			=> left_ctrl,
  		right_ctrl		=> right_ctrl,
  		
  		-- bdm controls
  		
  		bdm_rdy       => bdm_rdy,
  		bdm_ir        => bdm_ir,

			bdm_cr_i			=> bdm_cr,
			bdm_sr_i			=> bdm_sr,
			bdm_ap_i			=> bdm_ap,
  		
			bdm_r_d_o   	=> bdm_r_d_o,
			bdm_wr				=> bdm_wr
  	);

	-- Microcode address
	ma_reg: process(clk, clken, reset)
	begin
		if reset = '1' then
			mc_addr <= mc_fetch0;
		elsif rising_edge(clk) and clken = '1' then
			if hold = '0' then
				if mc_jump = '1' then
					mc_addr <= mc_jump_addr;
				else
					-- Normal progression of microcode address
					case mc_addr is
					when mc_fetch0 => mc_addr <= mc_fetch1;
					when mc_fetch1 => mc_addr <= mc_exec0;
					when mc_exec0	 => mc_addr <= mc_exec1;
					when mc_exec1	 => mc_addr <= mc_exec2;
					when mc_exec2	 => mc_addr <= mc_exec3;
					when mc_exec3	 => mc_addr <= mc_exec4;
					when mc_exec4	 => mc_addr <= mc_exec5;
					when mc_exec5	 => mc_addr <= mc_fetch0;

					when mc_index0 => mc_addr <= mc_index1;
					when mc_index1 => mc_addr <= mc_index2;
					when mc_index2 => mc_addr <= mc_index3;
					when mc_index3 => mc_addr <= mc_index4;
					when mc_index4 => mc_addr <= mc_index5;
					when mc_index5 => mc_addr <= mc_index6;
					when mc_index6 => mc_addr <= mc_index7;
					when mc_index7 => mc_addr <= mc_exec0;
					when others =>
						mc_addr <= mc_fetch0;
					end case;
				end if;
			end if;
		end if;
	end process;

	-- Generate last instruction cycle signal
	-- - BDM mode breaks this!!!
	lic <= '1' when mc_jump = '1' and mc_jump_addr = mc_fetch0 else '0';

	-- Registers
	regs: process(clk, clken, reset)
	begin
		if reset = '1' then
			pc			<= (others => '0');
			ir			<= (others => '0');
			u				<= (others => '0');
			s				<= (others => '0');
			y				<= (others => '0');
			x				<= (others => '0');
			acca 		<= (others => '0');
			accb		<= (others => '0');
			dp			<= (others => '0');
			cc			<= (others => '0');
			ea			<= (others => '0');
			post		<= (others => '0');
		elsif rising_edge(clk) and clken = '1' then
		
			if hold = '0' then
				-- PC
				case pc_ctrl is
					--when incr_pc		=> pc <= std_logic_vector(unsigned(pc) + 1);
					when incr_pc		=> pc <= pc + 1;
					when loadhi_pc	=> pc(15 downto 8) <= dbus;
					when loadlo_pc	=> pc(7 downto 0) <= dbus;
					when load_a_pc	=> pc <= abus;
					when others			=> pc <= pc;
				end case;

				-- IR and IR_page
				case ir_ctrl is
					when load_1st_ir =>
						ir(7 downto 0) <= dbus;
						if dbus = X"10" then
							ir(9 downto 8) <= "10";
						elsif dbus = X"11" then
							ir(9 downto 8) <= "11";
						else
							ir(9 downto 8) <= "00";
						end if;
					when load_2nd_ir =>
						if ir(9 downto 8) /= "00" then
							ir <= "00" & ir(9 downto 8) & dbus;
						else
							ir <= ir;
						end if;
					when latch_ir =>
						ir <= ir;
				end case;

				-- S
				case s_ctrl is
				when loadhi_s		=> s(15 downto 8) <= dbus;
				when loadlo_s		=> s(7 downto 0) <= dbus;
				when load_a_s		=> s <= abus;
				when others			=> s <= s;
				end case;

				-- A
				if lda = '1' then
					if acc_fromalu = '1' then
						acca <= alu_out;
					else
						acca <= dbus;
					end if;
				end if;

				-- B
				if ldb = '1' then
					if acc_fromalu = '1' then
						accb <= alu_out;
					else
						accb <= dbus;
					end if;
				end if;

				-- X
				if ldxh = '1' then
					x(15 downto 8) <= dbus;
				end if;
				if ldxl = '1' then
					x(7 downto 0) <= dbus;
				end if;

				-- Y
				if ldyh = '1' then
					y(15 downto 8) <= dbus;
				end if;
				if ldyl = '1' then
					y(7 downto 0) <= dbus;
				end if;

				-- U
				if lduh = '1' then
					u(15 downto 8) <= dbus;
				end if;
				if ldul = '1' then
					u(7 downto 0) <= dbus;
				end if;

				-- DP
				if lddp = '1' then
					dp <= dbus;
				end if;

				-- CC
				if ldcc = '1' then
					--if acc_fromalu = '1' then
						cc <= cc_out;
					--else
					--	cc <= dbus;
					--end if;
				end if;

				-- EA
				if lea(EAEA) = '1' then
					ea <= eabus;
				else
					if ldeah = '1' then
						if acc_fromalu = '1' then
							ea(15 downto 8) <= alu_out;
						else
							ea(15 downto 8) <= dbus;
						end if;
					end if;
					if ldeal = '1' then
						if acc_fromalu = '1' then
							ea(7 downto 0) <= alu_out;
						else
							ea(7 downto 0) <= dbus;
						end if;
					end if;
				end if;

				-- POST
				if ldpost = '1' then
					post <= data_i;
				end if;
			end if;
		end if;
	end process;

	-- D bus mux
	dbus_pr: process(dbus_ctrl, data_i, alu_out, acca, accb, pc, u, s, y, x, ea, cc, dp)
	begin
		case dbus_ctrl is
		when dbus_mem 	=>		dbus <= data_i;
		when dbus_a			=>		dbus <= acca;
		when dbus_b			=>		dbus <= accb;		
		when dbus_pch		=>		dbus <= pc(15 downto 8);		
		when dbus_pcl		=>		dbus <= pc(7 downto 0);		
		when dbus_uh		=>		dbus <= u(15 downto 8);		
		when dbus_ul		=>		dbus <= u(7 downto 0);		
		when dbus_sh		=>		dbus <= s(15 downto 8);		
		when dbus_sl		=>		dbus <= s(7 downto 0);		
		when dbus_yh		=>		dbus <= y(15 downto 8);		
		when dbus_yl		=>		dbus <= y(7 downto 0);		
		when dbus_xh		=>		dbus <= x(15 downto 8);		
		when dbus_xl		=>		dbus <= x(7 downto 0);		
		when dbus_eah		=>		dbus <= ea(15 downto 8);		
		when dbus_eal		=>		dbus <= ea(7 downto 0);		
		when dbus_cc		=>		dbus <= cc;		
		when dbus_dp		=>		dbus <= dp;
		when dbus_post	=>		dbus <= post;
		when dbus_alu 	=>		dbus <= alu_out;
		end case;
	end process;

	-- A bus mux
	abus_pr : process(abus_ctrl, pc, ea)
	begin
		case abus_ctrl is
		when abus_ea =>
			abus <= ea;
		when abus_d =>
			abus <= acca & accb;
		when abus_u =>
			abus <= u;
		when abus_s =>
			abus <= s;
		when abus_y =>
			abus <= y;
		when abus_x =>
			abus <= x;
		when others =>	-- abus_pc
			abus <= pc;
		end case;
	end process;

	-- EA bus mux
	eabus_pr : process(eabus_ctrl, ea)
	begin
		case eabus_ctrl is
		when eabus_u =>
			eabus <= u;
		when eabus_s =>
			eabus <= s;
		when eabus_y =>
			eabus <= y;
		when eabus_x =>
			eabus <= x;
		when eabus_pc =>
			eabus <= pc;
		when others =>	-- abus_ea
			eabus <= ea;
		end case;
	end process;


	-- ALU left mux
	aluleft_pr : process(left_ctrl, acca, accb, ea)
	begin
		case left_ctrl is
		when left_a			=> left <= acca;
		when left_b			=> left <= accb;
		when left_eal		=> left <= ea(7 downto 0);
		when left_eah		=> left <= ea(15 downto 8);
		end case;
	end process;

	-- ALU right mux
	aluright_pr : process(right_ctrl, dbus)
	begin
		case right_ctrl is
		when right_dbus	=> right <= dbus;
		when right_dbus5=> right <= "000" & dbus(4 downto 0);
		when right_c0		=> right <= X"00";
		when right_c1		=> right <= X"01";
		when right_c2		=> right <= X"02";
		end case;
	end process;

	-- ALU
	alu_pr: process(alu_ctrl, alu_igncarry, cc, left, right)
		variable alu_res	: std_logic_vector(8 downto 0);
		variable C_in			: std_logic;
		variable C_out		: std_logic;
	begin
		C_in := '0';
		if alu_igncarry = '0' then
			C_in := cc(0);
		end if;

		C_out := '0';
		case alu_ctrl is
		when alu_add	=>		
			alu_res := ('0' & left) + ('0' & right) + C_in;
			C_out := alu_res(8);

		when alu_sub	=>		
			alu_res := ('0' & left) - ('0' & right) - C_in;
			C_out := alu_res(8);

		when alu_and	=>		
			alu_res := '0' & (left and right);

		when alu_or		=>		
			alu_res := '0' & (left or right);

		when alu_eor	=>		
			alu_res := '0' & (left xor right);

		when alu_rol	=>		
			alu_res := left(7 downto 0) & C_in;
			C_out := alu_res(8);

		when alu_ror	=>		
			alu_res := C_in & left(7 downto 0);
			C_out := alu_res(0);
			alu_res := '0' & alu_res(8 downto 1);	-- Normalise so result is in (7 downto 0)

		when alu_idle =>
			alu_res := '0' & right;

		when others =>		
			alu_res := (others => '0');

		end case;

		alu_out <= alu_res(7 downto 0);

		-- Calculate flags
		cc_out <= (others => '0');
		if alu_res(7 downto 0) = X"00" then
			cc_out(Flag_Z) <= '1';
		else
			cc_out(Flag_Z) <= '0';
		end if;
		cc_out(Flag_C) <= C_out;
		cc_out(Flag_N) <= alu_res(7);
		cc_out(Flag_V) <= '0';	-- LATER
--		cc_out(Flag_H) 
	end process;

  GEN_BDM : if HAS_BDM generate
  begin
    bdm_inst : entity work.mce6309_bdmio
      port map
      (
        clk         => clk,
        clk_en      => clken,
        rst         => reset,
        
				-- external signals
        bdm_clk   	=> bdm_clk,
        bdm_mosi    => bdm_mosi,
        bdm_miso    => bdm_miso,
        bdm_i     	=> bdm_i,
        bdm_o     	=> bdm_o,
        bdm_oe    	=> bdm_oe,
  
				-- internal signals
				
        -- cpu registers
        x           => x,
        y           => y,
        u           => u,
        s           => s,
        pc          => pc,
        v           => (others => '0'),
        a           => acca,
        b           => accb,
        cc          => cc,
        dp          => dp,
        e           => (others => '0'),
        f           => (others => '0'),
        md          => "00000000",
    
				-- command
				bdm_rdy			=> bdm_rdy,
				bdm_ir			=> bdm_ir,

				bdm_cr_o		=> bdm_cr,
				bdm_sr_o		=> bdm_sr,
				bdm_ap_o		=> bdm_ap,
				bdm_bp_o		=> open,

				-- register io
		    bdm_r_d_i		=> bdm_r_d_o,
				bdm_wr			=> bdm_wr
      );
  end generate GEN_BDM;

	GEN_NO_BDM : if not HAS_BDM generate
	begin
		bdm_rdy <= '0';
	end generate GEN_NO_BDM;
	      
end architecture SYN;
