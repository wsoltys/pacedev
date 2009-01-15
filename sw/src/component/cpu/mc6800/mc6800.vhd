--
-- MC6800 CPU
--
-- 22 September 2002
-- John Kent
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
-- use work.micro8_def.all;

entity mc6800 is
	port (	
	   data_in:	 in  std_logic_vector(7 downto 0);
	   data_out: out std_logic_vector(7 downto 0);
		address:	 out std_logic_vector(15 downto 0);
		vma:	    out std_logic;
		rw:	    out std_logic;
		rst:	    in  std_logic;
		clk:	    in  std_logic;
		irq:      in  std_logic;
		nmi:      in  std_logic
		);
end;

architecture CPU_ARCH of mc6800 is

  constant SBIT : integer := 7;
  constant XBIT : integer := 6;
  constant HBIT : integer := 5;
  constant IBIT : integer := 4;
  constant NBIT : integer := 3;
  constant ZBIT : integer := 2;
  constant VBIT : integer := 1;
  constant CBIT : integer := 0;

	type state_type is (reset_state, fetch_state, decode_state,
                       extended_state, indexed_state, direct_state, direct16_state, immediate16_state,
	                    write8_state, write16_state,
						     execute_state, halt_state, mul_state,
							  jmp_state, jsr_state, jsr1_state,
						     branch_state, bsr_state, bsr1_state, 
							  rts_hi_state, rts_lo_state,
							  int_pcl_state, int_pch_state, int_cc_state, int_acca_state, int_accb_state, int_ixl_state, int_ixh_state, int_mask_state,
							  wai_pcl_state, wai_pch_state, wai_cc_state, wai_acca_state, wai_accb_state, wai_ixl_state, wai_ixh_state, wai_mask_state,
						     rti_pcl_state, rti_pch_state, rti_cc_state, rti_acca_state, rti_accb_state, rti_ixl_state, rti_ixh_state,
							  pula_state, psha_state, pulb_state, pshb_state,
						     pulx_lo_state, pulx_hi_state, pshx_lo_state, pshx_hi_state,
							  vect_lo_state, vect_hi_state );
	type addr_type is (idle_ad, fetch_ad, read_ad, write_ad, push_ad, pull_ad, int_hi_ad, int_lo_ad );
	type dout_type is (do_dout, acca_dout, accb_dout, ix_lo_dout, ix_hi_dout, cc_dout, pc_lo_dout, pc_hi_dout, do_lo_dout, do_hi_dout );
	type pc_type is (reset_pc, latch_pc, load_pc, pull_lo_pc, pull_hi_pc );
   type ea_type is (reset_ea, latch_ea, fetch_first_ea, fetch_next_ea, load_ea );
   type op_type is (reset_op, fetch_op, latch_op );
   type di_type is (reset_di, fetch_first_di, fetch_next_di, latch_di );
   type do_type is (reset_do, load_do, latch_do );
   type acca_type is (reset_acca, load_acca, load_hi_acca, pull_acca, latch_acca );
   type accb_type is (reset_accb, load_accb, pull_accb, latch_accb );
	type ix_type is (reset_ix, load_ix, pull_lo_ix, pull_hi_ix, latch_ix );
   type cc_type is (reset_cc, load_cc, pull_cc, latch_cc );
	type iv_type is (latch_iv, reset_iv, swi_iv, nmi_iv, irq_iv );
	type sp_type is (reset_sp, latch_sp, load_sp );
	type left_type is (acca_left, accb_left, accd_left, di_left, ix_left, pc_left, sp_left, ea_left );
	type right_type is (di_right, zero_right, plus_one_right, accb_right, ea_right, sexea_right );
   type alu_type   is (alu_add8, alu_sub8, alu_add16, alu_sub16, alu_adc, alu_sbc, 
                       alu_and, alu_ora, alu_eor, alu_bit,
                       alu_tst, alu_inc, alu_dec, alu_clr, alu_neg, alu_com,
							  alu_inx, alu_dex,
						     alu_lsr16, alu_lsl16, alu_ror8, alu_rol8, alu_asr8, alu_asl8, alu_lsr8,
						     alu_sei, alu_cli, alu_sec, alu_clc, alu_sev, alu_clv, alu_tpa, alu_tap,
						     alu_ld8, alu_st8, alu_ld16, alu_st16, alu_nop, alu_daa );

	signal xreg:        std_logic_vector(15 downto 0);
  	signal acca:        std_logic_vector(7 downto 0);
  	signal accb:        std_logic_vector(7 downto 0);
   signal cc:          std_logic_vector(7 downto 0);
	signal cc_out:      std_logic_vector(7 downto 0);
	signal sp:          std_logic_vector(15 downto 0);
	signal ea:          std_logic_vector(15 downto 0);
	signal pc:	        std_logic_vector(15 downto 0);
	signal iv:          std_logic_vector(1 downto 0);
	signal op_code:     std_logic_vector(7 downto 0);
	signal di:          std_logic_vector(15 downto 0);
	signal do:          std_logic_vector(15 downto 0);
   signal left:        std_logic_vector(15 downto 0);
   signal right:       std_logic_vector(15 downto 0);
	signal out_alu:     std_logic_vector(15 downto 0);

	signal state:       state_type;
	signal next_state:  state_type;
   signal pc_ctrl:     pc_type;
   signal ea_ctrl:     ea_type; 
   signal op_ctrl:     op_type;
	signal di_ctrl:     di_type;
	signal do_ctrl:     do_type;
	signal acca_ctrl:   acca_type;
	signal accb_ctrl:   accb_type;
	signal ix_ctrl:     ix_type;
	signal cc_ctrl:     cc_type;
	signal sp_ctrl:     sp_type;
	signal iv_ctrl:     iv_type;
	signal left_ctrl:   left_type;
	signal right_ctrl:  right_type;
   signal alu_ctrl:    alu_type;
   signal addr_ctrl:   addr_type;
   signal dout_ctrl:   dout_type;
begin

----------------------------------
--
-- Address output multiplexer
--
----------------------------------

addr_mux: process( clk, addr_ctrl, pc, ea, sp, iv )
begin
  case addr_ctrl is
    when idle_ad =>
	   address <= "1111111111111111";
		vma     <= '0';
		rw      <= '1';
    when fetch_ad =>
	   address <= pc;
		vma     <= '1';
		rw      <= '1';
	 when read_ad =>
	   address <= ea;
		vma     <= '1';
		rw      <= '1';
    when write_ad =>
	   address <= ea;
		vma     <= '1';
		rw      <= '0';
	 when push_ad =>
	   address <= sp;
		vma     <= '1';
		rw      <= '0';
    when pull_ad =>
	   address <= sp;
		vma     <= '1';
		rw      <= '1';
	 when int_hi_ad =>
	   address <= "1111111111111" & iv & "0";
		vma     <= '1';
		rw      <= '1';
    when int_lo_ad =>
	   address <= "1111111111111" & iv & "1";
		vma     <= '1';
		rw      <= '1';
	 when others =>
	   address <= "1111111111111111";
		vma     <= '0';
		rw      <= '1';
  end case;
end process;

----------------------------------
--
-- Program Counter Control
--
----------------------------------

pc_mux: process( clk, pc_ctrl, pc, out_alu, data_in )
begin

  if clk'event and clk = '1' then
    case pc_ctrl is
	 when latch_pc =>
      pc <= pc;
	 when load_pc =>
	   pc <= out_alu(15 downto 0);
	 when pull_lo_pc =>
	   pc(7 downto 0) <= data_in;
	 when pull_hi_pc =>
	   pc(15 downto 8) <= data_in;
	 when others =>
--	 when reset_pc =>
	   pc <= "0000000000000000";
    end case;
  end if;
end process;

----------------------------------
--
-- Effective Address  Control
--
----------------------------------

ea_mux: process( clk, ea_ctrl, ea, out_alu, data_in )
begin

  if clk'event and clk = '1' then
    case ea_ctrl is
  	 when latch_ea =>
      ea <= ea;
	 when fetch_first_ea =>
	   ea(7 downto 0) <= data_in;
      ea(15 downto 8) <= "00000000";
  	 when fetch_next_ea =>
	   ea(15 downto 8) <= ea(7 downto 0);
      ea(7 downto 0)  <= data_in;
	 when load_ea =>
	   ea <= out_alu(15 downto 0);
	 when others =>
--	 when reset_ea =>
	   ea <= "0000000000000000";
    end case;
  end if;
end process;

--------------------------------
--
-- Accumulator A
--
--------------------------------
acca_mux : process( clk, acca_ctrl, out_alu, acca, data_in )
begin
  if clk'event and clk = '1' then
    case acca_ctrl is
	 when load_acca =>
	   acca <= out_alu(7 downto 0);
	 when load_hi_acca =>
	   acca <= out_alu(15 downto 8);
	 when pull_acca =>
	   acca <= data_in;
	 when latch_acca =>
	   acca <= acca;
	 when others =>
--    when reset_acca =>
	   acca <= "00000000";
    end case;
  end if;
end process;

--------------------------------
--
-- Accumulator B
--
--------------------------------
accb_mux : process( clk, accb_ctrl, out_alu, accb, data_in )
begin
  if clk'event and clk = '1' then
    case accb_ctrl is
	 when load_accb =>
	   accb <= out_alu(7 downto 0);
	 when pull_accb =>
	   accb <= data_in;
	 when latch_accb =>
	   accb <= accb;
	 when others =>
--    when reset_accb =>
	   accb <= "00000000";
    end case;
  end if;
end process;

--------------------------------
--
-- X Index register
--
--------------------------------
ix_mux : process( clk, ix_ctrl, out_alu, xreg, data_in )
begin
  if clk'event and clk = '1' then
    case ix_ctrl is
	 when load_ix =>
	   xreg <= out_alu(15 downto 0);
	 when pull_hi_ix =>
	   xreg(15 downto 8) <= data_in;
	 when pull_lo_ix =>
	   xreg(7 downto 0) <= data_in;
	 when latch_ix =>
	   xreg <= xreg;
	 when others =>
--    when reset_ix =>
	   xreg <= "0000000000000000";
    end case;
  end if;
end process;

--------------------------------
--
-- stack pointer
--
--------------------------------
sp_mux : process( clk, sp_ctrl )
begin
  if clk'event and clk = '1' then
    case sp_ctrl is
	 when latch_sp =>
	   sp <= sp;
	 when load_sp =>
	   sp <= out_alu(15 downto 0);
	 when others =>
--    when reset_sp =>
	   sp <= "0000000000000000";
    end case;
  end if;
end process;


----------------------------------
--
-- Condition Codes
--
----------------------------------

cc_mux: process( clk, cc_ctrl, cc_out, cc, data_in )
begin
  if clk'event and clk = '1' then
    case cc_ctrl is
  	 when latch_cc =>
      cc <= cc;
  	 when pull_cc =>
      cc <= data_in;
	 when load_cc =>
	   cc <= cc_out;
	 when others =>
--	 when reset_cc =>
	   cc <= "11000000";
    end case;
  end if;
end process;

----------------------------------
--
-- interrupt vector
--
----------------------------------

iv_mux: process( clk, iv_ctrl )
begin
  if clk'event and clk = '1' then
    case iv_ctrl is
	 when reset_iv =>
	   iv <= "11";
	 when nmi_iv =>
      iv <= "10";
  	 when swi_iv =>
      iv <= "01";
	 when irq_iv =>
      iv <= "00";
	 when others =>
	   iv <= iv;
    end case;
  end if;
end process;


--------------------------------
--
-- Data In
--
--------------------------------
di_mux : process( clk, di_ctrl, data_in, di )
begin
  if clk'event and clk = '1' then
    case di_ctrl is
	 when fetch_first_di =>
	   di(15 downto 8) <= "00000000";
	   di(7 downto 0) <= data_in;
	 when fetch_next_di =>
	   di(15 downto 8) <= di(7 downto 0);
		di(7 downto 0) <= data_in;
	 when latch_di =>
	   di <= di;
	 when others =>
--    when reset_di =>
	   di <= "0000000000000000";
    end case;
  end if;
end process;

--------------------------------
--
-- alu data output
--
--------------------------------
do_mux : process( clk, do_ctrl, out_alu, do )
begin

  if clk'event and clk = '1' then
    case do_ctrl is
	 when load_do =>
	   do <= out_alu(15 downto 0);
	 when latch_do =>
	   do <= do;
	 when others =>
--    when reset_do =>
	   do <= "0000000000000000";
    end case;
  end if;
end process;


--------------------------------
--
-- Data Bus output
--
--------------------------------
dout_mux : process( clk, dout_ctrl, do, acca, accb, xreg, pc, cc )
begin
    case dout_ctrl is
	 when do_hi_dout => -- alu output
	   data_out <= do(15 downto 8);
	 when acca_dout => -- accumulator a
	   data_out <= acca;
	 when accb_dout => -- accumulator b
	   data_out <= accb;
	 when ix_lo_dout => -- index reg
	   data_out <= xreg(7 downto 0);
	 when ix_hi_dout => -- index reg
	   data_out <= xreg(15 downto 8);
	 when cc_dout => -- condition codes
	   data_out <= cc;
	 when pc_lo_dout => -- low order pc
	   data_out <= pc(7 downto 0);
	 when pc_hi_dout => -- high order pc
	   data_out <= pc(15 downto 8);
	 when others =>
--	 when do_lo_dout => -- alu output
	   data_out <= do(7 downto 0);
    end case;
end process;


----------------------------------
--
-- op code fetch
--
----------------------------------

op_fetch: process( clk, data_in, op_code )
begin
  if clk'event and clk = '1' then
    case op_ctrl is
  	 when fetch_op =>
      op_code <= data_in;
	 when latch_op =>
	   op_code <= op_code;
	 when others =>
--	 when reset_op =>
	   op_code <= "00000000";
    end case;
  end if;
end process;
----------------------------------
--
-- Left Mux
--
-- sign extend accumulator
--
----------------------------------

left_mux: process( left_ctrl, acca, accb, xreg, sp, pc, ea, di )
begin
  case left_ctrl is
	 when acca_left =>
	   left <= "00000000" & acca;
	 when accb_left =>
	   left <= "00000000" & accb;
	 when accd_left =>
	   left <= acca & accb;
	 when di_left =>
	   left <= di;
	 when ix_left =>
	   left <= xreg;
	 when sp_left =>
	   left <= sp;
	 when pc_left =>
	   left <= pc;
	 when others =>
--	 when ea_left =>
	   left <= ea;
    end case;
end process;
----------------------------------
--
-- Right Mux
--
----------------------------------

right_mux: process( right_ctrl, data_in, di, accb, ea )
begin
  case right_ctrl is
	 when zero_right =>
	   right <= "0000000000000000";
	 when plus_one_right =>
	   right <= "0000000000000001";
	 when accb_right =>
	   right <= "00000000" & accb;
	 when ea_right =>
	   right <= ea;
	 when sexea_right =>
	   if ea(7) = '0' then
	     right <= "00000000" & ea(7 downto 0);
		else
		  right <= "11111111" & ea(7 downto 0);
		end if;
	 when others =>
--	 when di_right =>
	   right <= di;
    end case;
end process;

----------------------------------
--
-- Arithmetic Logic Unit
--
----------------------------------

mux_alu: process( alu_ctrl, cc, left, right )
variable alu_v   : std_logic_vector(15 downto 0);
variable cc_v    : std_logic_vector(7 downto 0);
variable valid_lo, valid_hi, half_carry : boolean;
variable carry_in : std_logic;
begin
  valid_lo := left(3 downto 0) <= 9;
  valid_hi := left(7 downto 4) <= 9;
  half_carry := cc(HBIT) = '1';

  case alu_ctrl is
  	 when alu_adc | alu_sbc |
  	      alu_rol8 | alu_ror8 |
			alu_daa =>
	   carry_in := cc(CBIT);
  	 when others =>
	   carry_in := '0';
  end case;

  case alu_ctrl is
  	 when alu_add8 | alu_inc |
  	      alu_add16 | alu_inx |
  	      alu_adc =>
		alu_v := left + right + ("000000000000000" & carry_in);
  	 when alu_sub8 | alu_dec |
  	      alu_sub16 | alu_dex |
  	      alu_sbc =>
	   alu_v := left - right - ("000000000000000" & carry_in);
  	 when alu_and | alu_bit =>
	   alu_v   := left and right; 	-- and/bit
  	 when alu_ora =>
	   alu_v   := left or right; 	-- or
  	 when alu_eor =>
	   alu_v   := left xor right; 	-- eor/xor
  	 when alu_lsl16 | alu_asl8 =>
	   alu_v   := left(14 downto 0) & "0"; 	-- lsl
  	 when alu_lsr16 | alu_lsr8 =>
	   alu_v   := "0" & left(15 downto 1); 	-- lsr
  	 when alu_asr8 =>
	   alu_v   := "00000000" & left(7) & left(7 downto 1); 	-- asr
  	 when alu_rol8 =>
	   alu_v   := "00000000" & left(6 downto 0) & carry_in; 	-- rol
  	 when alu_ror8 =>
	   alu_v   := "00000000" & carry_in & left(7 downto 1); 	-- ror
  	 when alu_neg =>
	   alu_v   := right - left; 	-- neg (right=0)
  	 when alu_com =>
	   alu_v   := not left;
  	 when alu_clr | alu_ld8 | alu_ld16 =>
	   alu_v   := right; 	         -- clr, ld
	 when alu_st8 | alu_st16 =>
	   alu_v   := left;
	 when alu_daa =>
      if ( carry_in = '1') then
        if (half_carry or not valid_lo) then
          alu_v := "0000000001100110";
        else
          alu_v := "0000000001100000";
        end if;
      else
        if (valid_lo and valid_hi and not half_carry) then
          alu_v := "0000000000000000";
        elsif (valid_hi and half_carry) then
          alu_v := "0000000000000110";
        elsif (not valid_lo and not half_carry) then
          if (not valid_hi or left(7 downto 4) = 9) then
            alu_v := "0000000001100110";
          else
            alu_v := "0000000000000110";
          end if;
        elsif (half_carry) then
          alu_v := "0000000001100110";
        else
          alu_v := "0000000001100000";
        end if;
      end if;
	 when alu_tpa =>
	   alu_v := "00000000" & cc;
  	 when others =>
	   alu_v   := left; -- nop
    end case;

	 --
	 -- carry bit
	 --
    case alu_ctrl is
  	 when alu_add8 | alu_adc  =>
      cc_v(CBIT) := (left(7) and right(7)) or
		              (left(7) and not alu_v(7)) or
						  (right(7) and not alu_v(7));
  	 when alu_sub8 | alu_sbc =>
      cc_v(CBIT) := ((not left(7)) and right(7)) or
		              ((not left(7)) and alu_v(7)) or
						  (right(7) and alu_v(7));
	 when alu_ror8 | alu_lsr16 | alu_lsr8 | alu_asr8 =>
	   cc_v(CBIT) := left(0);
	 when alu_rol8 | alu_asl8 =>
	   cc_v(CBIT) := left(7);
	 when alu_lsl16 =>
	   cc_v(CBIT) := left(15);
	 when alu_com =>
	   cc_v(CBIT) := '1';
	 when alu_neg | alu_clr =>
	   cc_v(CBIT) := alu_v(7) or alu_v(6) or alu_v(5) or alu_v(4) or
		              alu_v(3) or alu_v(2) or alu_v(1) or alu_v(0); 
    when alu_daa =>
      if ( carry_in = '1') then
        cc_v(CBIT) := '1';
      else
        if (valid_lo and valid_hi and not half_carry) then
          cc_v(CBIT) := '0';
        elsif (valid_hi and half_carry) then
          cc_v(CBIT) := '0';
        elsif (not valid_lo and not half_carry) then
          if (not valid_hi or left(7 downto 4) = 9) then
            cc_v(CBIT) := '1';
          else
            cc_v(CBIT) := '0';
          end if;
        elsif (half_carry) then
          cc_v(CBIT) := '1';
        else
          cc_v(CBIT) := '1';
        end if;
      end if;
  	 when alu_sec =>
      cc_v(CBIT) := '1';
  	 when alu_clc =>
      cc_v(CBIT) := '0';
    when alu_tap =>
      cc_v(CBIT) := left(CBIT);
  	 when others =>
      cc_v(CBIT) := cc(CBIT);
    end case;
	 --
	 -- Zero flag
	 --
    case alu_ctrl is
  	 when alu_add8 | alu_sub8 |
	      alu_adc | alu_sbc |
  	      alu_and | alu_ora | alu_eor |
  	      alu_inc | alu_dec | 
			alu_neg | alu_com | alu_clr |
			alu_rol8 | alu_ror8 | alu_asr8 | alu_asl8 | alu_lsr8 |
		   alu_ld8  | alu_st8 =>
      cc_v(ZBIT) := not( alu_v(7)  or alu_v(6)  or alu_v(5)  or alu_v(4)  or
	                      alu_v(3)  or alu_v(2)  or alu_v(1)  or alu_v(0) );
  	 when alu_add16 | alu_sub16 |
  	      alu_lsl16 | alu_lsr16 |
  	      alu_inx | alu_dex |
		   alu_ld16  | alu_st16 =>
      cc_v(ZBIT) := not( alu_v(15) or alu_v(14) or alu_v(13) or alu_v(12) or
	                      alu_v(11) or alu_v(10) or alu_v(9)  or alu_v(8)  or
	                      alu_v(7)  or alu_v(6)  or alu_v(5)  or alu_v(4)  or
	                      alu_v(3)  or alu_v(2)  or alu_v(1)  or alu_v(0) );
    when alu_tap =>
      cc_v(ZBIT) := left(ZBIT);
  	 when others =>
      cc_v(ZBIT) := cc(ZBIT);
    end case;

    --
	 -- negative flag
	 --
    case alu_ctrl is
  	 when alu_add8 | alu_sub8 |
	      alu_adc | alu_sbc |
	      alu_and | alu_ora | alu_eor |
  	      alu_rol8 | alu_ror8 | alu_asr8 | alu_asl8 | alu_lsr8 |
  	      alu_inc | alu_dec | alu_neg | alu_com | alu_clr |
			alu_ld8  | alu_st8 =>
      cc_v(NBIT) := alu_v(7);
	 when alu_add16 | alu_sub16 |
	      alu_lsl16 | alu_lsr16 |
			alu_ld16 | alu_st16 =>
		cc_v(NBIT) := alu_v(15);
    when alu_tap =>
      cc_v(NBIT) := left(NBIT);
  	 when others =>
      cc_v(NBIT) := cc(NBIT);
    end case;

    --
	 -- Interrupt mask flag
    --
    case alu_ctrl is
  	 when alu_sei =>
		cc_v(IBIT) := '1';               -- set interrupt mask
  	 when alu_cli =>
		cc_v(IBIT) := '0';               -- clear interrupt mask
	 when alu_tap =>
      cc_v(IBIT) := left(IBIT);
  	 when others =>
		cc_v(IBIT) := cc(IBIT);             -- interrupt mask
    end case;

    --
    -- Half Carry flag
	 --
    case alu_ctrl is
  	 when alu_add8 | alu_adc =>
      cc_v(HBIT) := (left(3) and right(3)) or
                    (right(3) and not alu_v(3)) or 
                    (not alu_v(3) and left(3));
    when alu_tap =>
      cc_v(HBIT) := left(HBIT);
  	 when others =>
		cc_v(HBIT) := cc(HBIT);
    end case;

    --
    -- Overflow flag
	 --
    case alu_ctrl is
  	 when alu_add8 | alu_adc =>
      cc_v(VBIT) := (left(7) and right(7) and not alu_v(7)) or
                    (not left(7) and not right(7) and alu_v(7));
	 when alu_sub8 | alu_sbc =>
      cc_v(VBIT) := (left(7) and not right(7) and not alu_v(7)) or
                    (not left(7) and right(7) and alu_v(7));
  	 when alu_add16 =>
      cc_v(VBIT) := (left(15) and right(15) and not alu_v(15)) or
                    (not left(15) and not right(15) and alu_v(15));
	 when alu_sub16 =>
      cc_v(VBIT) := (left(15) and not right(15) and not alu_v(15)) or
                    (not left(15) and right(15) and alu_v(15));
	 when alu_and | alu_ora | alu_eor | alu_com |
	      alu_st8 | alu_st16 | alu_ld8 | alu_ld16 =>
      cc_v(VBIT) := '0';
	 when alu_neg | alu_inc =>
	   cc_v(VBIT) := (alu_v(7)  and (not alu_v(6)) and (not alu_v(5)) and (not alu_v(4)) and
		          (not alu_v(3)) and (not alu_v(2)) and (not alu_v(1)) and (not alu_v(0)));
	 when alu_dec =>
	   cc_v(VBIT) := ((not alu_v(7)) and alu_v(6) and alu_v(5) and alu_v(4) and
		                    alu_v(3)  and alu_v(2) and alu_v(1) and alu_v(0));
	 when alu_lsr16 | alu_lsl16 |
	      alu_ror8 | alu_rol8 | alu_asr8 | alu_asl8 | alu_lsr8 =>
      cc_v(VBIT) := cc_v(NBIT) xor cc_v(CBIT);
    when alu_tap =>
      cc_v(VBIT) := left(VBIT);
  	 when others =>
		cc_v(VBIT) := cc(VBIT);
    end case;

	 case alu_ctrl is
	 when alu_tap =>
      cc_v(XBIT) := cc(XBIT) and left(XBIT);
      cc_v(SBIT) := left(SBIT);
	 when others =>
      cc_v(XBIT) := cc(XBIT) and left(XBIT);
	   cc_v(SBIT) := cc(SBIT);
	 end case;

    out_alu   <= alu_v;               -- asyncronous output for register transfer
    cc_out    <= cc_v;
end process;

------------------------------------
--
-- state sequencer
--
------------------------------------
process( rst, data_in, acca, accb, xreg, ea, pc, state, op_code, cc, irq, nmi )

  	begin
		  case state is
          when reset_state =>        --  released from reset
			    -- reset the registers
             op_ctrl    <= reset_op;
				 acca_ctrl  <= reset_acca;
				 accb_ctrl  <= reset_accb;
				 ix_ctrl    <= reset_ix;
		       sp_ctrl    <= reset_sp;
		       pc_ctrl    <= reset_pc;
	 		    ea_ctrl    <= reset_ea;
				 di_ctrl    <= reset_di;
				 do_ctrl    <= reset_do;
				 iv_ctrl    <= reset_iv;
				 sp_ctrl    <= reset_sp;
				 -- idle the ALU
             left_ctrl  <= pc_left;
				 right_ctrl <= zero_right;
				 alu_ctrl   <= alu_nop;
             cc_ctrl    <= reset_cc;
				 -- idle the bus
				 dout_ctrl  <= do_dout;
             addr_ctrl  <= idle_ad;
	 	       next_state <= vect_hi_state;

			 --
			 -- Jump via interrupt vector
			 -- iv holds interrupt type
			 -- fetch PC hi from vector location
			 --
          when vect_hi_state =>
			    -- default the registers
             op_ctrl    <= latch_op;
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             ea_ctrl    <= latch_ea;
             iv_ctrl    <= latch_iv;
				 -- idle the ALU
             left_ctrl  <= pc_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
				 -- fetch pc low interrupt vector
		       pc_ctrl    <= pull_hi_pc;
             addr_ctrl  <= int_hi_ad;
             dout_ctrl  <= pc_hi_dout;
	 	       next_state <= vect_lo_state;
			 --
			 -- jump via interrupt vector
			 -- iv holds vector type
			 -- fetch PC lo from vector location
			 --
          when vect_lo_state =>
			    -- default the registers
             op_ctrl    <= latch_op;
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             ea_ctrl    <= latch_ea;
             iv_ctrl    <= latch_iv;
				 -- idle the ALU
             left_ctrl  <= pc_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
				 -- fetch the vector low byte
		       pc_ctrl    <= pull_lo_pc;
             addr_ctrl  <= int_lo_ad;
             dout_ctrl  <= pc_lo_dout;
	 	       next_state <= fetch_state;

			 --
			 -- Here to fetch an instruction
			 -- PC points to opcode
			 -- Should service interrupt requests at this point
			 -- either from the timer
			 -- or from the external input.
			 --
          when fetch_state =>
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
				 -- fetch the op code
			    op_ctrl    <= fetch_op;
             ea_ctrl    <= reset_ea;
             addr_ctrl  <= fetch_ad;
             dout_ctrl  <= do_dout;
				 -- service non maskable interrupts
			    if nmi = '1' then
               left_ctrl  <= acca_left;
               right_ctrl <= zero_right;
               alu_ctrl   <= alu_nop;
               cc_ctrl    <= latch_cc;
               pc_ctrl    <= latch_pc;
		  			iv_ctrl    <= nmi_iv;
			      next_state <= int_pcl_state;
				 -- service maskable interrupts
			    elsif (irq = '1') and (cc(IBIT) = '0') then
               left_ctrl  <= acca_left;
               right_ctrl <= zero_right;
               alu_ctrl   <= alu_nop;
               cc_ctrl    <= latch_cc;
               pc_ctrl    <= latch_pc;
		  			iv_ctrl    <= irq_iv;
			      next_state <= int_pcl_state;
             else
				   -- Advance the PC to fetch next instruction byte
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
               cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
               iv_ctrl    <= latch_iv;
			      next_state <= decode_state;
             end if;
			 --
			 -- Here to decode instruction
			 -- and fetch next byte of intruction
			 -- whether it be necessary or not
			 --
          when decode_state =>
				 -- fetch first byte of address or immediate data
				 di_ctrl    <= fetch_first_di;
             ea_ctrl    <= fetch_first_ea;
             addr_ctrl  <= fetch_ad;
             dout_ctrl  <= do_dout;
			    case op_code(7 downto 4) is
				 when "0000" =>
               sp_ctrl    <= latch_sp;
               pc_ctrl    <= latch_pc;
               do_ctrl    <= latch_do;
               iv_ctrl    <= latch_iv;
			      op_ctrl    <= latch_op;
  	            case op_code(3 downto 0) is
		         when "0001" => -- nop
					  left_ctrl  <= accd_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
                 cc_ctrl    <= latch_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "0100" => -- lsrd
					  left_ctrl  <= accd_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsr16;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= load_hi_acca;
					  accb_ctrl  <= load_accb;
					  ix_ctrl    <= latch_ix;
		         when "0101" => -- lsld
					  left_ctrl  <= accd_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsl16;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= load_hi_acca;
					  accb_ctrl  <= load_accb;
					  ix_ctrl    <= latch_ix;
		         when "0110" => -- tap
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_tap;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "0111" => -- tpa
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_tpa;
                 cc_ctrl    <= latch_cc;
					  acca_ctrl  <= load_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "1000" => -- inx
					  left_ctrl  <= ix_left;
	              right_ctrl <= plus_one_right;
					  alu_ctrl   <= alu_inx;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= load_ix;
		         when "1001" => -- dex
					  left_ctrl  <= ix_left;
	              right_ctrl <= plus_one_right;
					  alu_ctrl   <= alu_dex;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= load_ix;
		         when "1010" => -- clv
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_clv;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "1011" => -- sev
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_sev;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "1100" => -- clc
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_clc;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "1101" => -- sec
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_sec;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "1110" => -- cli
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_cli;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         when "1111" => -- sei
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_sei;
                 cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
               when others =>
					  left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
                 cc_ctrl    <= latch_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= latch_accb;
					  ix_ctrl    <= latch_ix;
		         end case;
					next_state <= fetch_state;
				 -- acca / accb inherent instructions
	          when "0001" =>
               ix_ctrl    <= latch_ix;
               sp_ctrl    <= latch_sp;
               pc_ctrl    <= latch_pc;
               do_ctrl    <= latch_do;
               iv_ctrl    <= latch_iv;
			      op_ctrl    <= latch_op;
					left_ctrl  <= acca_left;
	            right_ctrl <= accb_right;
	            case op_code(3 downto 0) is
		         when "0000" => -- sba
					  alu_ctrl   <= alu_sub8;
					  cc_ctrl    <= load_cc;
					  acca_ctrl  <= load_acca;
                 accb_ctrl  <= latch_accb;
		         when "0001" => -- cba
					  alu_ctrl   <= alu_sub8;
					  cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
		         when "0110" => -- tab
					  alu_ctrl   <= alu_st8;
					  cc_ctrl    <= load_cc;
					  acca_ctrl  <= latch_acca;
					  accb_ctrl  <= load_accb;
		         when "0111" => -- tba
					  alu_ctrl   <= alu_ld8;
					  cc_ctrl    <= load_cc;
					  acca_ctrl  <= load_acca;
                 accb_ctrl  <= latch_accb;
		         when "1001" => -- daa
					  alu_ctrl   <= alu_daa;
					  cc_ctrl    <= load_cc;
					  acca_ctrl  <= load_acca;
                 accb_ctrl  <= latch_accb;
		         when "1011" => -- aba
					  alu_ctrl   <= alu_add8;
					  cc_ctrl    <= load_cc;
					  acca_ctrl  <= load_acca;
                 accb_ctrl  <= latch_accb;
		         when others =>
					  alu_ctrl   <= alu_nop;
					  cc_ctrl    <= latch_cc;
					  acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
		         end case;
					next_state <= fetch_state;
	          when "0010" => -- branch conditional
					acca_ctrl  <= latch_acca;
               accb_ctrl  <= latch_accb;
               ix_ctrl    <= latch_ix;
               sp_ctrl    <= latch_sp;
               do_ctrl    <= latch_do;
               iv_ctrl    <= latch_iv;
			      op_ctrl    <= latch_op;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
               case op_code(3 downto 0) is
		         when "0000" => -- bra
                 next_state <= branch_state;
		         when "0001" => -- brn
					  next_state <= fetch_state;
		         when "0010" => -- bhi
					  if (cc(CBIT) or cc(ZBIT)) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "0011" => -- bls
					  if (cc(CBIT) or cc(ZBIT)) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "0100" => -- bcc
					  if cc(CBIT) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "0101" => -- bcs
					  if cc(CBIT) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "0110" => -- bne
					  if cc(ZBIT) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "0111" => -- beq
					  if cc(ZBIT) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1000" => -- bvc
					  if cc(VBIT) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1001" => -- bvs
					  if cc(VBIT) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1010" => -- bpl
					  if cc(NBIT) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1011" => -- bmi
					  if cc(NBIT) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1100" => -- bge
					  if (cc(NBIT) xor cc(VBIT)) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1101" => -- blt
					  if (cc(NBIT) xor cc(VBIT)) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1110" => -- bgt
					  if (cc(ZBIT) or (cc(NBIT) xor cc(VBIT))) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when "1111" => -- ble
					  if (cc(ZBIT) or (cc(NBIT) xor cc(VBIT))) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
		         when others =>
		         end case;
				 --
				 -- Single byte stack operators
				 -- Do not advance PC
				 --
	          when "0011" =>
					acca_ctrl  <= latch_acca;
               accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
	            case op_code(3 downto 0) is
		         when "0000" => -- tsx
		            left_ctrl  <= sp_left;
		            right_ctrl <= plus_one_right;
						alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= load_ix;
                  sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= fetch_state;
		         when "0001" => -- ins
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= fetch_state;
		         when "0010" => -- pula
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= pula_state;
		         when "0011" => -- pulb
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= pulb_state;
		         when "0100" => -- des
                  -- decrement sp
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_sub16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= fetch_state;
		         when "0101" => -- txs
		            left_ctrl  <= ix_left;
		            right_ctrl <= plus_one_right;
						alu_ctrl   <= alu_sub16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= fetch_state;
		         when "0110" => -- psha
		            left_ctrl  <= sp_left;
		            right_ctrl <= zero_right;
						alu_ctrl   <= alu_nop;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= psha_state;
		         when "0111" => -- pshb
		            left_ctrl  <= sp_left;
		            right_ctrl <= zero_right;
						alu_ctrl   <= alu_nop;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= pshb_state;
		         when "1000" => -- pulx
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= pulx_hi_state;
		         when "1001" => -- rts
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= rts_hi_state;
		         when "1010" => -- abx
		            left_ctrl  <= ix_left;
		            right_ctrl <= accb_right;
						alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= load_ix;
                  sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= fetch_state;
		         when "1011" => -- rti
                  left_ctrl  <= sp_left;
                  right_ctrl <= plus_one_right;
                  alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
                  sp_ctrl    <= load_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= rti_cc_state;
		         when "1100" => -- pshx
		            left_ctrl  <= sp_left;
		            right_ctrl <= zero_right;
						alu_ctrl   <= alu_nop;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= pshx_lo_state;
		         when "1101" => -- mul
		            left_ctrl  <= acca_left;
		            right_ctrl <= accb_right;
						alu_ctrl   <= alu_add16;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= mul_state;
		         when "1110" => -- wai
		            left_ctrl  <= sp_left;
		            right_ctrl <= zero_right;
						alu_ctrl   <= alu_nop;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
                  iv_ctrl    <= latch_iv;
						next_state <= wai_pcl_state;
		         when "1111" => -- swi
		            left_ctrl  <= sp_left;
		            right_ctrl <= zero_right;
						alu_ctrl   <= alu_nop;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
					   iv_ctrl    <= swi_iv;
						next_state <= int_pcl_state;
		         when others =>
		            left_ctrl  <= sp_left;
		            right_ctrl <= zero_right;
						alu_ctrl   <= alu_nop;
					   cc_ctrl    <= latch_cc;
						ix_ctrl    <= latch_ix;
						sp_ctrl    <= latch_sp;
					   iv_ctrl    <= latch_iv;
						next_state <= fetch_state;
		         end case;
				 --
				 -- Accumulator A Single operand
				 -- source = Acc A dest = Acc A
				 -- Do not advance PC
				 --
	          when "0100" => -- acca single op
               accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
		         left_ctrl  <= acca_left;
	            case op_code(3 downto 0) is
		         when "0000" => -- neg
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_neg;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
 	            when "0011" => -- com
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_com;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "0100" => -- lsr
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsr8;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "0110" => -- ror
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ror8;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "0111" => -- asr
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asr8;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "1000" => -- asl
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asl8;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "1001" => -- rol
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_rol8;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "1010" => -- dec
		           right_ctrl <= plus_one_right;
					  alu_ctrl   <= alu_dec;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "1011" => -- undefined
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  acca_ctrl  <= latch_acca;
					  cc_ctrl    <= latch_cc;
		         when "1100" => -- inc
		           right_ctrl <= plus_one_right;
					  alu_ctrl   <= alu_inc;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when "1101" => -- tst
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_st8;
					  acca_ctrl  <= latch_acca;
					  cc_ctrl    <= load_cc;
		         when "1110" => -- jmp
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  acca_ctrl  <= latch_acca;
					  cc_ctrl    <= latch_cc;
		         when "1111" => -- clr
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ld8;
					  acca_ctrl  <= load_acca;
					  cc_ctrl    <= load_cc;
		         when others =>
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  acca_ctrl  <= latch_acca;
					  cc_ctrl    <= latch_cc;
		         end case;
				   next_state <= fetch_state;
				 --
				 -- single operand acc b
				 -- Do not advance PC
				 --
	          when "0101" =>
               acca_ctrl  <= latch_acca;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
		         left_ctrl  <= accb_left;
	            case op_code(3 downto 0) is
		         when "0000" => -- neg
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_neg;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
 	            when "0011" => -- com
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_com;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "0100" => -- lsr
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsr8;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "0110" => -- ror
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ror8;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "0111" => -- asr
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asr8;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "1000" => -- asl
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asl8;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "1001" => -- rol
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_rol8;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "1010" => -- dec
		           right_ctrl <= plus_one_right;
					  alu_ctrl   <= alu_dec;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "1011" => -- undefined
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  accb_ctrl  <= latch_accb;
					  cc_ctrl    <= latch_cc;
		         when "1100" => -- inc
		           right_ctrl <= plus_one_right;
					  alu_ctrl   <= alu_inc;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when "1101" => -- tst
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_st8;
					  accb_ctrl  <= latch_accb;
					  cc_ctrl    <= load_cc;
		         when "1110" => -- jmp
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  accb_ctrl  <= latch_accb;
					  cc_ctrl    <= latch_cc;
		         when "1111" => -- clr
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ld8;
					  accb_ctrl  <= load_accb;
					  cc_ctrl    <= load_cc;
		         when others =>
		           right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  accb_ctrl  <= latch_accb;
					  cc_ctrl    <= latch_cc;
		         end case;
				   next_state <= fetch_state;
				 --
				 -- Single operand indexed
				 -- Two byte instruction so advance PC
				 -- EA should hold index offset
				 --
	          when "0110" => -- indexed single op
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc 
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
				   next_state <= indexed_state;
             --
				 -- Single operand extended addressing
				 -- three byte instruction so advance the PC
				 -- Low order EA holds high order address
				 --
	          when "0111" => -- extended single op
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
				   next_state <= extended_state;

	          when "1000" => -- acca immediate
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
				   -- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
					case op_code(3 downto 0) is
               when "0011" | -- subdd #
					     "1100" | -- cpx #
					     "1110" => -- lds #
					  next_state <= immediate16_state;
					when "1101" => -- bsr
					  next_state <= bsr_state;
					when others =>
				     next_state <= execute_state;
               end case;

	          when "1001" => -- acca direct
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
					case op_code(3 downto 0) is
					when "0111" |  -- staa direct
					     "1111" => -- sts direct
				     next_state <= execute_state;
					when "1101" => -- jsr direct
					  next_state <= jsr_state;
					when others =>
				     next_state <= direct_state;
               end case;

	          when "1010" => -- acca indexed
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
				   next_state <= indexed_state;

             when "1011" => -- acca extended
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
				   next_state <= extended_state;

	          when "1100" => -- accb immediate
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
					case op_code(3 downto 0) is
               when "0011" | -- addd #
					     "1100" | -- ldd #
					     "1110" => -- ldx #
					  next_state <= immediate16_state;
					when others =>
				     next_state <= execute_state;
               end case;

	          when "1101" => -- accb direct
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
					case op_code(3 downto 0) is
					when "0111" |  -- stab direct
					     "1101" |  -- std direct
					     "1111" => -- stx direct
				     next_state <= execute_state;
					when others =>
				     next_state <= direct_state;
               end case;

	          when "1110" => -- accb indexed
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
				   next_state <= indexed_state;

             when "1111" => -- accb extended
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- increment the pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
				   next_state <= extended_state;

	          when others =>
               acca_ctrl  <= latch_acca;
					accb_ctrl  <= latch_accb;
               do_ctrl    <= latch_do;
			      op_ctrl    <= latch_op;
               pc_ctrl    <= latch_pc;
				   ix_ctrl    <= latch_ix;
				   sp_ctrl    <= latch_sp;
					iv_ctrl    <= latch_iv;
					-- idle the pc
               left_ctrl  <= pc_left;
               right_ctrl <= zero_right;
               alu_ctrl   <= alu_nop;
					cc_ctrl    <= latch_cc;
               pc_ctrl    <= latch_pc;
		         next_state <= fetch_state;
             end case;

			  when immediate16_state =>
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- increment pc
             left_ctrl  <= pc_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             pc_ctrl    <= load_pc;
				 -- fetch next immediate byte
			    di_ctrl    <= fetch_next_di;
             addr_ctrl  <= fetch_ad;
             dout_ctrl  <= do_dout;
				 next_state <= execute_state;
           --
			  -- ea holds 8 bit index offet
			  -- calculate the effective memory address
			  -- using the alu
			  --
           when indexed_state =>
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
				 -- calculate effective address from index reg
             -- index offest is not sign extended
			    left_ctrl  <= ix_left;
				 right_ctrl <= ea_right;
				 alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             ea_ctrl    <= load_ea;
				 -- idle the bus
             addr_ctrl  <= idle_ad;
             dout_ctrl  <= do_dout;
				 -- work out next state
				 case op_code(7 downto 4) is
				 when "0110" => -- single op indexed
	            case op_code(3 downto 0) is
		         when "1011" => -- undefined
					  next_state <= fetch_state;
		         when "1110" => -- jmp
					  next_state <= jmp_state;
		         when others =>
					  next_state <= direct_state;
		         end case;
	          when "1010" => -- acca indexed
				   case op_code(3 downto 0) is
					when "0111" |  -- staa
					     "1111" => -- sts
					  next_state <= execute_state;
					when "1101" => -- jsr
					  next_state <= jsr_state;
					when others =>
					  next_state <= direct_state;
					end case;
	          when "1110" => -- accb indexed
				   case op_code(3 downto 0) is
					when "0111" |  -- stab
					     "1101" |  -- std
					     "1111" => -- stx
					  next_state <= execute_state;
					when others =>
					  next_state <= direct_state;
					end case;
			    when others =>
					next_state <= fetch_state;
			    end case;
           --
			  -- ea holds the low byte of the absolute address
			  -- Move ea low byte into ea high byte
			  -- load new ea low byte to for absolute 16 bit address
			  -- advance the program counter
			  --
			  when extended_state => -- fetch ea low byte
               acca_ctrl  <= latch_acca;
               accb_ctrl  <= latch_accb;
               ix_ctrl    <= latch_ix;
               sp_ctrl    <= latch_sp;
               di_ctrl    <= latch_di;
               do_ctrl    <= latch_do;
               iv_ctrl    <= latch_iv;
			      op_ctrl    <= latch_op;
					-- increment pc
               left_ctrl  <= pc_left;
               right_ctrl <= plus_one_right;
               alu_ctrl   <= alu_add16;
               cc_ctrl    <= latch_cc;
               pc_ctrl    <= load_pc;
					-- fetch next effective address bytes
					ea_ctrl    <= fetch_next_ea;
               addr_ctrl  <= fetch_ad;
					dout_ctrl  <= do_dout;
					-- work out the next state
					case op_code(7 downto 4) is
					  when "0111" => -- single op extended
	                case op_code(3 downto 0) is
		             when "1011" => -- undefined
					      next_state <= fetch_state;
		             when "1110" => -- jmp
					      next_state <= jmp_state;
		             when others =>
					      next_state <= direct_state;
		             end case;
	              when "1011" => -- acca extended
				       case op_code(3 downto 0) is
						 when "0111" |  -- staa extended
					         "1111" => -- sts
						   next_state <= execute_state;
					    when "1101" => -- jsr
					      next_state <= jsr_state;
					    when others =>
					      next_state <= direct_state;
					    end case;
	              when "1111" => -- accb extended
				       case op_code(3 downto 0) is
						 when "0111" |  -- stab extended
					         "1101" |  -- std
					         "1111" => -- stx
					      next_state <= execute_state;
					    when others =>
					      next_state <= direct_state;
					    end case;
					  when others =>
					    next_state <= fetch_state;
					  end case;
           --
			  -- here if ea holds low byte (direct page)
			  -- can enter here from extended addressing
			  -- read memory location
			  -- note that reads may be 8 or 16 bits
			  --
			  when direct_state => -- read data
               acca_ctrl  <= latch_acca;
               accb_ctrl  <= latch_accb;
               ix_ctrl    <= latch_ix;
               sp_ctrl    <= latch_sp;
               pc_ctrl    <= latch_pc;
               do_ctrl    <= latch_do;
               iv_ctrl    <= latch_iv;
			      op_ctrl    <= latch_op;
				   -- read first data byte from ea
				   di_ctrl    <= fetch_first_di;
               addr_ctrl  <= read_ad;
					dout_ctrl  <= do_dout;
					case op_code(7 downto 4) is
					  when "0110" | "0111" => -- single operand
 					      left_ctrl  <= ea_left;
					      right_ctrl <= zero_right;
					      alu_ctrl   <= alu_nop;
                     cc_ctrl    <= latch_cc;
					      ea_ctrl    <= latch_ea;
					      next_state <= execute_state;
	              when "1001" | "1010" | "1011" => -- acca
				       case op_code(3 downto 0) is
					    when "0011" |  -- subd
					         "1110" |  -- lds
					         "1100" => -- cpx
				         -- increment the effective address in case of 16 bit load
 					      left_ctrl  <= ea_left;
					      right_ctrl <= plus_one_right;
					      alu_ctrl   <= alu_add16;
                     cc_ctrl    <= latch_cc;
					      ea_ctrl    <= load_ea;
					      next_state <= direct16_state;
					    when others =>
 					      left_ctrl  <= ea_left;
					      right_ctrl <= zero_right;
					      alu_ctrl   <= alu_nop;
                     cc_ctrl    <= latch_cc;
					      ea_ctrl    <= latch_ea;
					      next_state <= execute_state;
					    end case;
	              when "1101" | "1110" | "1111" => -- accb
				       case op_code(3 downto 0) is
					    when "0011" |  -- addd
					         "1100" |  -- ldd
					         "1110" => -- ldx
				         -- increment the effective address in case of 16 bit load
 					      left_ctrl  <= ea_left;
					      right_ctrl <= plus_one_right;
					      alu_ctrl   <= alu_add16;
                     cc_ctrl    <= latch_cc;
					      ea_ctrl    <= load_ea;
					      next_state <= direct16_state;
					    when others =>
 					      left_ctrl  <= ea_left;
					      right_ctrl <= zero_right;
					      alu_ctrl   <= alu_nop;
                     cc_ctrl    <= latch_cc;
					      ea_ctrl    <= latch_ea;
					      next_state <= execute_state;
					    end case;
					  when others =>
 					    left_ctrl  <= ea_left;
					    right_ctrl <= zero_right;
					    alu_ctrl   <= alu_nop;
                   cc_ctrl    <= latch_cc;
					    ea_ctrl    <= latch_ea;
					    next_state <= fetch_state;
					  end case;

			   when direct16_state => -- read second data byte from ea
                 -- default
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 pc_ctrl    <= latch_pc;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
					  -- idle the effective address
                 left_ctrl  <= ea_left;
                 right_ctrl <= plus_one_right;
                 alu_ctrl   <= alu_nop;
                 cc_ctrl    <= latch_cc;
                 ea_ctrl    <= latch_ea;
					  -- read the low byte of the 16 bit data
				     di_ctrl    <= fetch_next_di;
                 addr_ctrl  <= read_ad;
                 dout_ctrl  <= do_dout;
					  next_state <= execute_state;

				when jmp_state =>
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- load PC with effective address
                 left_ctrl  <= pc_left;
					  right_ctrl <= ea_right;
				     alu_ctrl   <= alu_ld16;
                 cc_ctrl    <= latch_cc;
					  pc_ctrl    <= load_pc;
					  -- idle the bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
                 next_state <= fetch_state;

				when jsr_state => -- JSR
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
                 -- decrement sp
                 left_ctrl  <= sp_left;
                 right_ctrl <= plus_one_right;
                 alu_ctrl   <= alu_sub16;
                 cc_ctrl    <= latch_cc;
                 sp_ctrl    <= load_sp;
					  -- write pc low
                 addr_ctrl  <= push_ad;
					  dout_ctrl  <= pc_lo_dout; 
                 next_state <= jsr1_state;

				when jsr1_state => -- JSR
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
                 -- decrement sp
                 left_ctrl  <= sp_left;
                 right_ctrl <= plus_one_right;
                 alu_ctrl   <= alu_sub16;
                 cc_ctrl    <= latch_cc;
                 sp_ctrl    <= load_sp;
					  -- write pc hi
                 addr_ctrl  <= push_ad;
					  dout_ctrl  <= pc_hi_dout; 
                 next_state <= jmp_state;

				when branch_state => -- Bcc
				     -- default registers
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- calculate signed branch
					  left_ctrl  <= pc_left;
					  right_ctrl <= sexea_right; -- right must be sign extended effective address
				     alu_ctrl   <= alu_add16;
                 cc_ctrl    <= latch_cc;
					  pc_ctrl    <= load_pc;
					  -- idle the bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
                 next_state <= fetch_state;

				when bsr_state => -- BSR
				     -- default
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
                 -- decrement sp
                 left_ctrl  <= sp_left;
                 right_ctrl <= plus_one_right;
                 alu_ctrl   <= alu_sub16;
                 cc_ctrl    <= latch_cc;
                 sp_ctrl    <= load_sp;
					  -- write pc low
                 addr_ctrl  <= push_ad;
					  dout_ctrl  <= pc_lo_dout; 
                 next_state <= bsr1_state;

				when bsr1_state => -- BSR
				     -- default registers
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
                 -- decrement sp
                 left_ctrl  <= sp_left;
                 right_ctrl <= plus_one_right;
                 alu_ctrl   <= alu_sub16;
                 cc_ctrl    <= latch_cc;
                 sp_ctrl    <= load_sp;
					  -- write pc hi
                 addr_ctrl  <= push_ad;
					  dout_ctrl  <= pc_hi_dout; 
                 next_state <= branch_state;

				 when rts_hi_state => -- RTS
				     -- default
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- increment the sp
                 left_ctrl  <= sp_left;
                 right_ctrl <= plus_one_right;
                 alu_ctrl   <= alu_add16;
                 cc_ctrl    <= latch_cc;
                 sp_ctrl    <= load_sp;
                 -- read pc hi
					  pc_ctrl    <= pull_hi_pc;
                 addr_ctrl  <= pull_ad;
                 dout_ctrl  <= pc_hi_dout;
                 next_state <= rts_lo_state;

				when rts_lo_state => -- RTS1
				     -- default
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle the ALU
                 left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
                 alu_ctrl   <= alu_nop;
                 cc_ctrl    <= latch_cc;
					  -- read pc low
					  pc_ctrl    <= pull_lo_pc;
                 addr_ctrl  <= pull_ad;
                 dout_ctrl  <= pc_lo_dout;
                 next_state <= fetch_state;

				 when mul_state =>
				     -- default
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle ALU
                 left_ctrl  <= acca_left;
                 right_ctrl <= zero_right;
                 alu_ctrl   <= alu_nop;
                 cc_ctrl    <= latch_cc;
					  -- idle bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
				     next_state <= fetch_state;

			    when execute_state => -- execute
				   -- default
			      case op_code(7 downto 4) is
				   when "0000" |
	                 "0001" |
	                 "0010" | -- branch conditional
	                 "0011" |
	                 "0100" | -- acca single op
	                 "0101" => -- accb single op
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle ALU
                 left_ctrl  <= acca_left;
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					  cc_ctrl    <= latch_cc;
				     do_ctrl    <= latch_do;
					  -- idle bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
				     next_state <= fetch_state;

	            when "0110" | -- indexed single op
	                 "0111" => -- extended single op
                 acca_ctrl  <= latch_acca;
                 accb_ctrl  <= latch_accb;
                 ix_ctrl    <= latch_ix;
                 sp_ctrl    <= latch_sp;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle the bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
	              case op_code(3 downto 0) is
		           when "0000" => -- neg
                   left_ctrl  <= di_left;
					    right_ctrl <= zero_right;
					    alu_ctrl   <= alu_neg;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
 	              when "0011" => -- com
                   left_ctrl  <= di_left;
		             right_ctrl <= zero_right;
					    alu_ctrl   <= alu_com;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "0100" => -- lsr
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_lsr8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "0110" => -- ror
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_ror8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "0111" => -- asr
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_asr8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "1000" => -- asl
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_asl8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "1001" => -- rol
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_rol8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "1010" => -- dec
                   left_ctrl  <= di_left;
		             right_ctrl <= plus_one_right;
					    alu_ctrl   <= alu_dec;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "1011" => -- undefined
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_nop;
					    cc_ctrl    <= latch_cc;
				       do_ctrl    <= latch_do;
				       next_state <= fetch_state;
		           when "1100" => -- inc
                   left_ctrl  <= di_left;
		             right_ctrl <= plus_one_right;
					    alu_ctrl   <= alu_inc;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when "1101" => -- tst
                   left_ctrl  <= di_left;
		             right_ctrl <= zero_right;
					    alu_ctrl   <= alu_st8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= latch_do;
				       next_state <= fetch_state;
		           when "1110" => -- jmp
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_nop;
					    cc_ctrl    <= latch_cc;
				       do_ctrl    <= latch_do;
				       next_state <= fetch_state;
		           when "1111" => -- clr
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_ld8;
					    cc_ctrl    <= load_cc;
				       do_ctrl    <= load_do;
				       next_state <= write8_state;
		           when others =>
                   left_ctrl  <= di_left;
						 right_ctrl <= zero_right;
					    alu_ctrl   <= alu_nop;
					    cc_ctrl    <= latch_cc;
				       do_ctrl    <= latch_do;
				       next_state <= fetch_state;
		           end case;

	            when "1000" | -- acca immediate
	                 "1001" | -- acca direct
	                 "1010" | -- acca indexed
                    "1011" => -- acca extended
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
					  do_ctrl    <= load_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle the bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
				     case op_code(3 downto 0) is
					  when "0000" => -- suba
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sub8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state  <= fetch_state;
					  when "0001" => -- cmpa
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sub8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state  <= fetch_state;
					  when "0010" => -- sbca
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sbc;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0011" => -- subd
					    left_ctrl   <= accd_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sub16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_hi_acca;
						 accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0100" => -- anda
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_and;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0101" => -- bita
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_and;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0110" => -- ldaa
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ld8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0111" => -- staa
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_st8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= write8_state;
					  when "1000" => -- eora
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_eor;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1001" => -- adca
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_adc;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1010" => -- oraa
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ora;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1011" => -- adda
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_add8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1100" => -- cpx
					    left_ctrl   <= ix_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sub16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1101" => -- bsr / jsr
					    left_ctrl   <= pc_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_nop;
						 cc_ctrl     <= latch_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1110" => -- lds
					    left_ctrl   <= sp_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ld16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
						 sp_ctrl     <= load_sp;
				       next_state <= fetch_state;
					  when "1111" => -- sts
					    left_ctrl   <= sp_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_st16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= write16_state;
					  when others =>
					    left_ctrl   <= acca_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_nop;
						 cc_ctrl     <= latch_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
		  				 next_state <= fetch_state;
					  end case;
	            when "1100" | -- accb immediate
	                 "1101" | -- accb direct
	                 "1110" | -- accb indexed
                    "1111" => -- accb extended
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
					  do_ctrl    <= load_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle the bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
				     case op_code(3 downto 0) is
					  when "0000" => -- subb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sub8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state  <= fetch_state;
					  when "0001" => -- cmpb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sub8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state  <= fetch_state;
					  when "0010" => -- sbcb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_sbc;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0011" => -- addd
					    left_ctrl   <= accd_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_add16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_hi_acca;
						 accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0100" => -- andb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_and;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0101" => -- bitb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_and;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0110" => -- ldab
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ld8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "0111" => -- stab
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_st8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= write8_state;
					  when "1000" => -- eorb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_eor;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1001" => -- adcb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_adc;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1010" => -- orab
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ora;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1011" => -- addb
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_add8;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1100" => -- ldd
					    left_ctrl   <= accd_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ld16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= load_hi_acca;
                   accb_ctrl   <= load_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1101" => -- std
					    left_ctrl   <= accd_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_st16;
						 cc_ctrl     <= latch_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= write16_state;
					  when "1110" => -- ldx
					    left_ctrl   <= ix_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_ld16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= load_ix;
						 sp_ctrl     <= latch_sp;
				       next_state <= fetch_state;
					  when "1111" => -- stx
					    left_ctrl   <= ix_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_st16;
						 cc_ctrl     <= load_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
				       next_state <= write16_state;
					  when others =>
					    left_ctrl   <= accb_left;
					    right_ctrl  <= di_right;
					    alu_ctrl    <= alu_nop;
						 cc_ctrl     <= latch_cc;
					    acca_ctrl   <= latch_acca;
                   accb_ctrl   <= latch_accb;
                   ix_ctrl     <= latch_ix;
                   sp_ctrl     <= latch_sp;
		  				 next_state <= fetch_state;
					  end case;
	            when others =>
					  left_ctrl   <= accd_left;
					  right_ctrl  <= di_right;
					  alu_ctrl    <= alu_nop;
					  cc_ctrl     <= latch_cc;
					  acca_ctrl   <= latch_acca;
                 accb_ctrl   <= latch_accb;
                 ix_ctrl     <= latch_ix;
                 sp_ctrl     <= latch_sp;
                 pc_ctrl    <= latch_pc;
                 di_ctrl    <= latch_di;
					  do_ctrl    <= latch_do;
                 iv_ctrl    <= latch_iv;
			        op_ctrl    <= latch_op;
                 ea_ctrl    <= latch_ea;
					  -- idle the bus
                 addr_ctrl  <= idle_ad;
                 dout_ctrl  <= do_dout;
		           next_state <= fetch_state;
              end case;
           --
			  -- 16 bit Write state
			  -- write high byte of ALU output.
			  -- EA hold address of memory to write to
			  -- Advance the effective address in ALU
			  --
			  when write16_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
				 -- increment the effective address
				 left_ctrl  <= ea_left;
				 right_ctrl <= plus_one_right;
				 alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
			    ea_ctrl    <= load_ea;
 				 -- write the ALU hi byte to ea
             addr_ctrl  <= write_ad;
             dout_ctrl  <= do_hi_dout;
				 next_state <= write8_state;
           --
			  -- 8 bit write
			  -- Write low 8 bits of ALU output
			  --
			  when write8_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- idle the ALU
             left_ctrl  <= acca_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
				 -- write ALU low byte output
             addr_ctrl  <= write_ad;
             dout_ctrl  <= do_lo_dout;
				 next_state <= fetch_state;

			  when psha_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write acca
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= acca_dout; 
             next_state <= fetch_state;

			  when pula_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- idle sp
             left_ctrl  <= sp_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= latch_sp;
				 -- read acca
				 acca_ctrl  <= pull_acca;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= acca_dout;
             next_state <= fetch_state;

			  when pshb_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write accb
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= accb_dout; 
             next_state <= fetch_state;

			  when pulb_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- idle sp
             left_ctrl  <= sp_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= latch_sp;
				 -- read accb
				 accb_ctrl  <= pull_accb;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= accb_dout;
             next_state <= fetch_state;

			  when pshx_lo_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write ix low
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= ix_lo_dout; 
             next_state <= pshx_hi_state;

			  when pshx_hi_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write ix hi
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= ix_hi_dout; 
             next_state <= fetch_state;

		  	  when pulx_hi_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- pull ix hi
				 ix_ctrl    <= pull_hi_ix;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= ix_hi_dout;
             next_state <= pulx_lo_state;

		  	  when pulx_lo_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- idle sp
             left_ctrl  <= sp_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= latch_sp;
				 -- read ix low
				 ix_ctrl    <= pull_lo_ix;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= ix_lo_dout;
             next_state <= fetch_state;

			  when rti_cc_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             sp_ctrl    <= load_sp;
				 -- read cc
             cc_ctrl    <= pull_cc;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= cc_dout;
             next_state <= rti_accb_state;

			  when rti_accb_state =>
				 -- default registers
             acca_ctrl  <= latch_acca;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- read accb
				 accb_ctrl  <= pull_accb;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= accb_dout;
             next_state <= rti_acca_state;

			  when rti_acca_state =>
				 -- default registers
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- read acca
				 acca_ctrl  <= pull_acca;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= acca_dout;
             next_state <= rti_ixh_state;

			  when rti_ixh_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- read ix hi
				 ix_ctrl    <= pull_hi_ix;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= ix_hi_dout;
             next_state <= rti_ixl_state;

			  when rti_ixl_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- read ix low
				 ix_ctrl    <= pull_lo_ix;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= ix_lo_dout;
             next_state <= rti_pch_state;

			  when rti_pch_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
	          -- increment sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_add16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- pull pc hi
				 pc_ctrl    <= pull_hi_pc;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= pc_hi_dout;
             next_state <= rti_pcl_state;

			  when rti_pcl_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- idle sp
             left_ctrl  <= sp_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= latch_sp;
	          -- pull pc low
				 pc_ctrl    <= pull_lo_pc;
             addr_ctrl  <= pull_ad;
             dout_ctrl  <= pc_lo_dout;
             next_state <= fetch_state;

			  --
			  -- here on interrupt
			  -- iv register hold interrupt type
			  --
			  when int_pcl_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write pc low
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= pc_lo_dout; 
             next_state <= int_pch_state;

			  when int_pch_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write pc hi
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= pc_hi_dout; 
             next_state <= int_ixl_state;

			  when int_ixl_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write ix low
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= ix_lo_dout; 
             next_state <= int_ixh_state;

			  when int_ixh_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write ix hi
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= ix_hi_dout; 
             next_state <= int_acca_state;

			  when int_acca_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write acca
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= acca_dout; 
             next_state <= int_accb_state;


			  when int_accb_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write accb
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= accb_dout; 
             next_state <= int_cc_state;

			  when int_cc_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write cc
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= cc_dout; 
             next_state <= int_mask_state;

			  when int_mask_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- Mask IRQ
             left_ctrl  <= sp_left;
             right_ctrl <= zero_right;
			    alu_ctrl   <= alu_sei;
				 cc_ctrl    <= load_cc;
             sp_ctrl    <= latch_sp;
				 -- idle bus cycle
             addr_ctrl  <= idle_ad;
             dout_ctrl  <= do_dout;
             next_state <= vect_hi_state;
			  --
			  -- here on wait for interrupt
			  --
			  when wai_pcl_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write pc low
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= pc_lo_dout; 
             next_state <= wai_pch_state;

			  when wai_pch_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write pc hi
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= pc_hi_dout; 
             next_state <= wai_ixl_state;

			  when wai_ixl_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write ix low
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= ix_lo_dout; 
             next_state <= wai_ixh_state;

			  when wai_ixh_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write ix hi
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= ix_hi_dout; 
             next_state <= wai_acca_state;

			  when wai_acca_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write acca
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= acca_dout; 
             next_state <= wai_accb_state;

			  when wai_accb_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- write accb
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= accb_dout; 
             next_state <= wai_cc_state;

			  when wai_cc_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
             -- decrement sp
             left_ctrl  <= sp_left;
             right_ctrl <= plus_one_right;
             alu_ctrl   <= alu_sub16;
             cc_ctrl    <= latch_cc;
             sp_ctrl    <= load_sp;
				 -- push cc
             addr_ctrl  <= push_ad;
			    dout_ctrl  <= cc_dout; 
			    if nmi = '1' then
		  			iv_ctrl    <= nmi_iv;
			      next_state <= vect_hi_state;
			    elsif (irq = '1') and (cc(IBIT) = '0') then
		  			iv_ctrl    <= irq_iv;
			      next_state <= wai_mask_state;
             else
               iv_ctrl    <= latch_iv;
	            next_state <= wai_cc_state;
				 end if;

			  when wai_mask_state =>
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             dout_ctrl  <= do_dout;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
		  	    iv_ctrl    <= latch_iv;
				 -- mask interrupt
             left_ctrl  <= sp_left;
             right_ctrl <= zero_right;
			    alu_ctrl   <= alu_sei;
			    cc_ctrl    <= load_cc;
             sp_ctrl    <= latch_sp;
				 -- idle bus cycle
             addr_ctrl  <= idle_ad;
			    dout_ctrl  <= cc_dout; 
             next_state <= vect_hi_state;
 

			  when others => -- halt on undefine states
				 -- default
             acca_ctrl  <= latch_acca;
             accb_ctrl  <= latch_accb;
             ix_ctrl    <= latch_ix;
             sp_ctrl    <= latch_sp;
             pc_ctrl    <= latch_pc;
             di_ctrl    <= latch_di;
             do_ctrl    <= latch_do;
             iv_ctrl    <= latch_iv;
			    op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea;
				 -- do nothing in ALU
             left_ctrl  <= acca_left;
             right_ctrl <= zero_right;
             alu_ctrl   <= alu_nop;
             cc_ctrl    <= latch_cc;
				 -- idle bus cycle
             addr_ctrl  <= idle_ad;
             dout_ctrl  <= do_dout;
			    next_state <= halt_state;
		  end case;
end process;

--------------------------------
--
-- state machine
--
--------------------------------

change_state: process( clk, rst, state )
begin
  if clk'event and clk = '1' then
    if rst = '1' then
 	   state <= reset_state;
    else
      state <= next_state;
	 end if;
  end if;
end process;
	-- output
	
end CPU_ARCH;
	
