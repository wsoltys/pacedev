--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


--Legal Notice: (C)2011 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_0_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_debugaccess : IN STD_LOGIC;
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_write : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_0_jtag_debug_module_end_xfer : OUT STD_LOGIC
              );
end entity cpu_0_jtag_debug_module_arbitrator;


architecture europa of cpu_0_jtag_debug_module_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_allgrants :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_cpu_0_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT cpu_0_jtag_debug_module_end_xfer;
    end if;

  end process;

  cpu_0_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module));
  --assign cpu_0_jtag_debug_module_readdata_from_sa = cpu_0_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_0_jtag_debug_module_readdata_from_sa <= cpu_0_jtag_debug_module_readdata;
  internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000100000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --cpu_0_jtag_debug_module_arb_share_counter set values, which is an e_mux
  cpu_0_jtag_debug_module_arb_share_set_values <= std_logic_vector'("001");
  --cpu_0_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  cpu_0_jtag_debug_module_non_bursting_master_requests <= ((internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module OR internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module) OR internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module) OR internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  --cpu_0_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  cpu_0_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --cpu_0_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  cpu_0_jtag_debug_module_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(cpu_0_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (cpu_0_jtag_debug_module_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(cpu_0_jtag_debug_module_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (cpu_0_jtag_debug_module_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --cpu_0_jtag_debug_module_allgrants all slave grants, which is an e_mux
  cpu_0_jtag_debug_module_allgrants <= (((or_reduce(cpu_0_jtag_debug_module_grant_vector)) OR (or_reduce(cpu_0_jtag_debug_module_grant_vector))) OR (or_reduce(cpu_0_jtag_debug_module_grant_vector))) OR (or_reduce(cpu_0_jtag_debug_module_grant_vector));
  --cpu_0_jtag_debug_module_end_xfer assignment, which is an e_assign
  cpu_0_jtag_debug_module_end_xfer <= NOT ((cpu_0_jtag_debug_module_waits_for_read OR cpu_0_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_end_xfer AND (((NOT cpu_0_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --cpu_0_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  cpu_0_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module AND cpu_0_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module AND NOT cpu_0_jtag_debug_module_non_bursting_master_requests));
  --cpu_0_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_0_jtag_debug_module_arb_counter_enable) = '1' then 
        cpu_0_jtag_debug_module_arb_share_counter <= cpu_0_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(cpu_0_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module AND NOT cpu_0_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        cpu_0_jtag_debug_module_slavearbiterlockenable <= or_reduce(cpu_0_jtag_debug_module_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master cpu_0/jtag_debug_module arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= cpu_0_jtag_debug_module_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --cpu_0_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  cpu_0_jtag_debug_module_slavearbiterlockenable2 <= or_reduce(cpu_0_jtag_debug_module_arb_share_counter_next_value);
  --cpu_0/data_master cpu_0/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= cpu_0_jtag_debug_module_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --cpu_0/instruction_master cpu_0/jtag_debug_module arbiterlock, which is an e_assign
  cpu_0_instruction_master_arbiterlock <= cpu_0_jtag_debug_module_slavearbiterlockenable AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master cpu_0/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_0_instruction_master_arbiterlock2 <= cpu_0_jtag_debug_module_slavearbiterlockenable2 AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master granted cpu_0/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_0_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module))))));
    end if;

  end process;

  --cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  cpu_0_instruction_master_continuerequest <= last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module AND internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  --cpu_0_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  cpu_0_jtag_debug_module_any_continuerequest <= cpu_0_instruction_master_continuerequest OR cpu_0_data_master_continuerequest;
  internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module AND NOT ((((cpu_0_data_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR cpu_0_instruction_master_arbiterlock));
  --local readdatavalid cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module, which is an e_mux
  cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module <= (internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_read) AND NOT cpu_0_jtag_debug_module_waits_for_read;
  --cpu_0_jtag_debug_module_writedata mux, which is an e_mux
  cpu_0_jtag_debug_module_writedata <= cpu_0_data_master_writedata;
  internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_instruction_master_address_to_slave(15 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000100000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
  --cpu_0/data_master granted cpu_0/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_0_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module))))));
    end if;

  end process;

  --cpu_0_data_master_continuerequest continued request, which is an e_mux
  cpu_0_data_master_continuerequest <= last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module AND internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module AND NOT ((((cpu_0_instruction_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR cpu_0_data_master_arbiterlock));
  --local readdatavalid cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module, which is an e_mux
  cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module <= (internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module AND cpu_0_instruction_master_read) AND NOT cpu_0_jtag_debug_module_waits_for_read;
  --allow new arb cycle for cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_jtag_debug_module_allow_new_arb_cycle <= NOT cpu_0_data_master_arbiterlock AND NOT cpu_0_instruction_master_arbiterlock;
  --cpu_0/instruction_master assignment into master qualified-requests vector for cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_jtag_debug_module_master_qreq_vector(0) <= internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  --cpu_0/instruction_master grant cpu_0/jtag_debug_module, which is an e_assign
  internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_grant_vector(0);
  --cpu_0/instruction_master saved-grant cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_arb_winner(0) AND internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  --cpu_0/data_master assignment into master qualified-requests vector for cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_jtag_debug_module_master_qreq_vector(1) <= internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  --cpu_0/data_master grant cpu_0/jtag_debug_module, which is an e_assign
  internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_grant_vector(1);
  --cpu_0/data_master saved-grant cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_arb_winner(1) AND internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  --cpu_0/jtag_debug_module chosen-master double-vector, which is an e_assign
  cpu_0_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((cpu_0_jtag_debug_module_master_qreq_vector & cpu_0_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT cpu_0_jtag_debug_module_master_qreq_vector & NOT cpu_0_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (cpu_0_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  cpu_0_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((cpu_0_jtag_debug_module_allow_new_arb_cycle AND or_reduce(cpu_0_jtag_debug_module_grant_vector)))) = '1'), cpu_0_jtag_debug_module_grant_vector, cpu_0_jtag_debug_module_saved_chosen_master_vector);
  --saved cpu_0_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_0_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        cpu_0_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(cpu_0_jtag_debug_module_grant_vector)) = '1'), cpu_0_jtag_debug_module_grant_vector, cpu_0_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  cpu_0_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((cpu_0_jtag_debug_module_chosen_master_double_vector(1) OR cpu_0_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((cpu_0_jtag_debug_module_chosen_master_double_vector(0) OR cpu_0_jtag_debug_module_chosen_master_double_vector(2)))));
  --cpu_0/jtag_debug_module chosen master rotated left, which is an e_assign
  cpu_0_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(cpu_0_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(cpu_0_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --cpu_0/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(cpu_0_jtag_debug_module_grant_vector)) = '1' then 
        cpu_0_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(cpu_0_jtag_debug_module_end_xfer) = '1'), cpu_0_jtag_debug_module_chosen_master_rot_left, cpu_0_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  cpu_0_jtag_debug_module_begintransfer <= cpu_0_jtag_debug_module_begins_xfer;
  --cpu_0_jtag_debug_module_reset_n assignment, which is an e_assign
  cpu_0_jtag_debug_module_reset_n <= reset_n;
  --assign cpu_0_jtag_debug_module_resetrequest_from_sa = cpu_0_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_0_jtag_debug_module_resetrequest_from_sa <= cpu_0_jtag_debug_module_resetrequest;
  cpu_0_jtag_debug_module_chipselect <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module OR internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  --cpu_0_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  cpu_0_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(cpu_0_jtag_debug_module_begins_xfer) = '1'), cpu_0_jtag_debug_module_unreg_firsttransfer, cpu_0_jtag_debug_module_reg_firsttransfer);
  --cpu_0_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  cpu_0_jtag_debug_module_unreg_firsttransfer <= NOT ((cpu_0_jtag_debug_module_slavearbiterlockenable AND cpu_0_jtag_debug_module_any_continuerequest));
  --cpu_0_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_0_jtag_debug_module_begins_xfer) = '1' then 
        cpu_0_jtag_debug_module_reg_firsttransfer <= cpu_0_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --cpu_0_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  cpu_0_jtag_debug_module_beginbursttransfer_internal <= cpu_0_jtag_debug_module_begins_xfer;
  --cpu_0_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  cpu_0_jtag_debug_module_arbitration_holdoff_internal <= cpu_0_jtag_debug_module_begins_xfer AND cpu_0_jtag_debug_module_firsttransfer;
  --cpu_0_jtag_debug_module_write assignment, which is an e_mux
  cpu_0_jtag_debug_module_write <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_write;
  shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --cpu_0_jtag_debug_module_address mux, which is an e_mux
  cpu_0_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
  shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master <= cpu_0_instruction_master_address_to_slave;
  --d1_cpu_0_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_cpu_0_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_cpu_0_jtag_debug_module_end_xfer <= cpu_0_jtag_debug_module_end_xfer;
    end if;

  end process;

  --cpu_0_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  cpu_0_jtag_debug_module_waits_for_read <= cpu_0_jtag_debug_module_in_a_read_cycle AND cpu_0_jtag_debug_module_begins_xfer;
  --cpu_0_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  cpu_0_jtag_debug_module_in_a_read_cycle <= ((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module AND cpu_0_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= cpu_0_jtag_debug_module_in_a_read_cycle;
  --cpu_0_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  cpu_0_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --cpu_0_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  cpu_0_jtag_debug_module_in_a_write_cycle <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= cpu_0_jtag_debug_module_in_a_write_cycle;
  wait_for_cpu_0_jtag_debug_module_counter <= std_logic'('0');
  --cpu_0_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  cpu_0_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  cpu_0_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_granted_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_requests_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
--synthesis translate_off
    --cpu_0/jtag_debug_module enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_0_data_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_pio_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_vai_i2c_master_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_pio_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_pio_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_pio_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_vai_i2c_master_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_timer_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_vai_i2c_master_0_s1_end_xfer : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_0_s1_irq_from_sa : IN STD_LOGIC;
                 signal pio_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal timer_0_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal vai_i2c_master_0_s1_irq_from_sa : IN STD_LOGIC;
                 signal vai_i2c_master_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal vai_i2c_master_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_0_data_master_dbs_write_8 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_0_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : OUT STD_LOGIC;
                 signal cpu_0_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_readdatavalid : OUT STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_0_data_master_arbitrator;


architecture europa of cpu_0_data_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_0_data_master_address_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_data_master_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_data_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_data_master_is_granted_some_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_but_no_slave_selected :  STD_LOGIC;
                signal cpu_0_data_master_read_last_time :  STD_LOGIC;
                signal cpu_0_data_master_run :  STD_LOGIC;
                signal cpu_0_data_master_write_last_time :  STD_LOGIC;
                signal cpu_0_data_master_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal dbs_8_reg_segment_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal dbs_8_reg_segment_1 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal dbs_8_reg_segment_2 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_cpu_0_data_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_cpu_0_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_cpu_0_data_master_latency_counter :  STD_LOGIC;
                signal internal_cpu_0_data_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_cpu_0_data_master_latency_counter :  STD_LOGIC;
                signal p1_dbs_8_reg_segment_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal p1_dbs_8_reg_segment_1 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal p1_dbs_8_reg_segment_2 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal pre_flush_cpu_0_data_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_requests_cpu_0_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_0_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR NOT cpu_0_data_master_requests_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_onchip_memory2_0_s1 OR NOT cpu_0_data_master_qualified_request_onchip_memory2_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_pio_0_s1 OR NOT cpu_0_data_master_requests_pio_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_pio_0_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_pio_0_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_pio_0_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_sysid_control_slave OR NOT cpu_0_data_master_requests_sysid_control_slave)))))));
  --cascaded wait assignment, which is an e_assign
  cpu_0_data_master_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_sysid_control_slave OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_sysid_control_slave_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_sysid_control_slave OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_requests_timer_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_timer_0_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 OR ((((cpu_0_data_master_write AND NOT(cpu_0_data_master_byteenable_vai_i2c_master_0_s1)) AND internal_cpu_0_data_master_dbs_address(1)) AND internal_cpu_0_data_master_dbs_address(0)))) OR NOT cpu_0_data_master_requests_vai_i2c_master_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 OR NOT cpu_0_data_master_read)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vai_i2c_master_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((internal_cpu_0_data_master_dbs_address(1) AND internal_cpu_0_data_master_dbs_address(0))))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 OR NOT cpu_0_data_master_write)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vai_i2c_master_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((internal_cpu_0_data_master_dbs_address(1) AND internal_cpu_0_data_master_dbs_address(0))))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_0_data_master_address_to_slave <= cpu_0_data_master_address(15 DOWNTO 0);
  --cpu_0_data_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_data_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_data_master_read_but_no_slave_selected <= (cpu_0_data_master_read AND cpu_0_data_master_run) AND NOT cpu_0_data_master_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  cpu_0_data_master_is_granted_some_slave <= (((((cpu_0_data_master_granted_cpu_0_jtag_debug_module OR cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave) OR cpu_0_data_master_granted_onchip_memory2_0_s1) OR cpu_0_data_master_granted_pio_0_s1) OR cpu_0_data_master_granted_sysid_control_slave) OR cpu_0_data_master_granted_timer_0_s1) OR cpu_0_data_master_granted_vai_i2c_master_0_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_cpu_0_data_master_readdatavalid <= cpu_0_data_master_read_data_valid_onchip_memory2_0_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  cpu_0_data_master_readdatavalid <= ((((((((((((((((((cpu_0_data_master_read_but_no_slave_selected OR pre_flush_cpu_0_data_master_readdatavalid) OR cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module) OR cpu_0_data_master_read_but_no_slave_selected) OR pre_flush_cpu_0_data_master_readdatavalid) OR cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave) OR cpu_0_data_master_read_but_no_slave_selected) OR pre_flush_cpu_0_data_master_readdatavalid) OR cpu_0_data_master_read_but_no_slave_selected) OR pre_flush_cpu_0_data_master_readdatavalid) OR cpu_0_data_master_read_data_valid_pio_0_s1) OR cpu_0_data_master_read_but_no_slave_selected) OR pre_flush_cpu_0_data_master_readdatavalid) OR cpu_0_data_master_read_data_valid_sysid_control_slave) OR cpu_0_data_master_read_but_no_slave_selected) OR pre_flush_cpu_0_data_master_readdatavalid) OR cpu_0_data_master_read_data_valid_timer_0_s1) OR cpu_0_data_master_read_but_no_slave_selected) OR pre_flush_cpu_0_data_master_readdatavalid) OR ((cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 AND dbs_counter_overflow));
  --cpu_0/data_master readdata mux, which is an e_mux
  cpu_0_data_master_readdata <= (((((((A_REP(NOT ((cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module AND cpu_0_data_master_read)) , 32) OR cpu_0_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT ((cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave AND cpu_0_data_master_read)) , 32) OR jtag_uart_0_avalon_jtag_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_read_data_valid_onchip_memory2_0_s1, 32) OR onchip_memory2_0_s1_readdata_from_sa))) AND ((A_REP(NOT ((cpu_0_data_master_qualified_request_pio_0_s1 AND cpu_0_data_master_read)) , 32) OR pio_0_s1_readdata_from_sa))) AND ((A_REP(NOT ((cpu_0_data_master_qualified_request_sysid_control_slave AND cpu_0_data_master_read)) , 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT ((cpu_0_data_master_qualified_request_timer_0_s1 AND cpu_0_data_master_read)) , 32) OR (std_logic_vector'("0000000000000000") & (timer_0_s1_readdata_from_sa))))) AND ((A_REP(NOT ((cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 AND cpu_0_data_master_read)) , 32) OR Std_Logic_Vector'(vai_i2c_master_0_s1_readdata_from_sa(7 DOWNTO 0) & dbs_8_reg_segment_2 & dbs_8_reg_segment_1 & dbs_8_reg_segment_0)));
  --actual waitrequest port, which is an e_assign
  internal_cpu_0_data_master_waitrequest <= NOT cpu_0_data_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_0_data_master_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_cpu_0_data_master_latency_counter <= p1_cpu_0_data_master_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_cpu_0_data_master_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((cpu_0_data_master_run AND cpu_0_data_master_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_requests_onchip_memory2_0_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  --irq assign, which is an e_assign
  cpu_0_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(jtag_uart_0_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(pio_0_s1_irq_from_sa) & A_ToStdLogicVector(vai_i2c_master_0_s1_irq_from_sa) & A_ToStdLogicVector(timer_0_s1_irq_from_sa));
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic((((((((NOT std_logic_vector'("00000000000000000000000000000000")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_requests_vai_i2c_master_0_s1)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT(cpu_0_data_master_byteenable_vai_i2c_master_0_s1)))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_0_data_master_granted_vai_i2c_master_0_s1 AND cpu_0_data_master_read)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vai_i2c_master_0_s1_waitrequest_n_from_sa)))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_0_data_master_granted_vai_i2c_master_0_s1 AND cpu_0_data_master_write)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vai_i2c_master_0_s1_waitrequest_n_from_sa)))))));
  --input to dbs-8 stored 0, which is an e_mux
  p1_dbs_8_reg_segment_0 <= vai_i2c_master_0_s1_readdata_from_sa;
  --dbs register for dbs-8 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_8_reg_segment_0 <= std_logic_vector'("00000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & ((internal_cpu_0_data_master_dbs_address(1 DOWNTO 0)))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_8_reg_segment_0 <= p1_dbs_8_reg_segment_0;
      end if;
    end if;

  end process;

  --input to dbs-8 stored 1, which is an e_mux
  p1_dbs_8_reg_segment_1 <= vai_i2c_master_0_s1_readdata_from_sa;
  --dbs register for dbs-8 segment 1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_8_reg_segment_1 <= std_logic_vector'("00000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & ((internal_cpu_0_data_master_dbs_address(1 DOWNTO 0)))) = std_logic_vector'("00000000000000000000000000000001")))))) = '1' then 
        dbs_8_reg_segment_1 <= p1_dbs_8_reg_segment_1;
      end if;
    end if;

  end process;

  --input to dbs-8 stored 2, which is an e_mux
  p1_dbs_8_reg_segment_2 <= vai_i2c_master_0_s1_readdata_from_sa;
  --dbs register for dbs-8 segment 2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_8_reg_segment_2 <= std_logic_vector'("00000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & ((internal_cpu_0_data_master_dbs_address(1 DOWNTO 0)))) = std_logic_vector'("00000000000000000000000000000010")))))) = '1' then 
        dbs_8_reg_segment_2 <= p1_dbs_8_reg_segment_2;
      end if;
    end if;

  end process;

  --mux write dbs 2, which is an e_mux
  cpu_0_data_master_dbs_write_8 <= A_WE_StdLogicVector((((std_logic_vector'("000000000000000000000000000000") & (internal_cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000000"))), cpu_0_data_master_writedata(7 DOWNTO 0), A_WE_StdLogicVector((((std_logic_vector'("000000000000000000000000000000") & (internal_cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000001"))), cpu_0_data_master_writedata(15 DOWNTO 8), A_WE_StdLogicVector((((std_logic_vector'("000000000000000000000000000000") & (internal_cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000010"))), cpu_0_data_master_writedata(23 DOWNTO 16), cpu_0_data_master_writedata(31 DOWNTO 24))));
  --dbs count increment, which is an e_mux
  cpu_0_data_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((cpu_0_data_master_requests_vai_i2c_master_0_s1)) = '1'), std_logic_vector'("00000000000000000000000000000001"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_cpu_0_data_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_cpu_0_data_master_dbs_address)) + (std_logic_vector'("0") & (cpu_0_data_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable;
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_0_data_master_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_cpu_0_data_master_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  cpu_0_data_master_address_to_slave <= internal_cpu_0_data_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_dbs_address <= internal_cpu_0_data_master_dbs_address;
  --vhdl renameroo for output signals
  cpu_0_data_master_latency_counter <= internal_cpu_0_data_master_latency_counter;
  --vhdl renameroo for output signals
  cpu_0_data_master_waitrequest <= internal_cpu_0_data_master_waitrequest;
--synthesis translate_off
    --cpu_0_data_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_data_master_address_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        cpu_0_data_master_address_last_time <= cpu_0_data_master_address;
      end if;

    end process;

    --cpu_0/data_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_cpu_0_data_master_waitrequest AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
      end if;

    end process;

    --cpu_0_data_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_0_data_master_address /= cpu_0_data_master_address_last_time))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("cpu_0_data_master_address did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_0_data_master_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_data_master_byteenable_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        cpu_0_data_master_byteenable_last_time <= cpu_0_data_master_byteenable;
      end if;

    end process;

    --cpu_0_data_master_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_0_data_master_byteenable /= cpu_0_data_master_byteenable_last_time))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("cpu_0_data_master_byteenable did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_0_data_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_data_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        cpu_0_data_master_read_last_time <= cpu_0_data_master_read;
      end if;

    end process;

    --cpu_0_data_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_0_data_master_read) /= std_logic'(cpu_0_data_master_read_last_time)))))) = '1' then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("cpu_0_data_master_read did not heed wait!!!"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_0_data_master_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_data_master_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        cpu_0_data_master_write_last_time <= cpu_0_data_master_write;
      end if;

    end process;

    --cpu_0_data_master_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_0_data_master_write) /= std_logic'(cpu_0_data_master_write_last_time)))))) = '1' then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("cpu_0_data_master_write did not heed wait!!!"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_0_data_master_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_data_master_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        cpu_0_data_master_writedata_last_time <= cpu_0_data_master_writedata;
      end if;

    end process;

    --cpu_0_data_master_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((cpu_0_data_master_writedata /= cpu_0_data_master_writedata_last_time)))) AND cpu_0_data_master_write)) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("cpu_0_data_master_writedata did not heed wait!!!"));
          write(output, write_line6.all);
          deallocate (write_line6);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_0_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_instruction_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_0_instruction_master_arbitrator;


architecture europa of cpu_0_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_0_instruction_master_address_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal cpu_0_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal cpu_0_instruction_master_read_last_time :  STD_LOGIC;
                signal cpu_0_instruction_master_run :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_cpu_0_instruction_master_latency_counter :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_cpu_0_instruction_master_latency_counter :  STD_LOGIC;
                signal pre_flush_cpu_0_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_requests_cpu_0_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_0_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 OR NOT cpu_0_instruction_master_requests_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_onchip_memory2_0_s1 OR NOT cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 OR NOT (cpu_0_instruction_master_read))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_0_instruction_master_read))))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_0_instruction_master_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_0_instruction_master_address_to_slave <= cpu_0_instruction_master_address(15 DOWNTO 0);
  --cpu_0_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_instruction_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_instruction_master_read_but_no_slave_selected <= (cpu_0_instruction_master_read AND cpu_0_instruction_master_run) AND NOT cpu_0_instruction_master_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  cpu_0_instruction_master_is_granted_some_slave <= cpu_0_instruction_master_granted_cpu_0_jtag_debug_module OR cpu_0_instruction_master_granted_onchip_memory2_0_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_cpu_0_instruction_master_readdatavalid <= cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  cpu_0_instruction_master_readdatavalid <= (((cpu_0_instruction_master_read_but_no_slave_selected OR pre_flush_cpu_0_instruction_master_readdatavalid) OR cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module) OR cpu_0_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_0_instruction_master_readdatavalid;
  --cpu_0/instruction_master readdata mux, which is an e_mux
  cpu_0_instruction_master_readdata <= ((A_REP(NOT ((cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module AND cpu_0_instruction_master_read)) , 32) OR cpu_0_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1, 32) OR onchip_memory2_0_s1_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_cpu_0_instruction_master_waitrequest <= NOT cpu_0_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_0_instruction_master_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_cpu_0_instruction_master_latency_counter <= p1_cpu_0_instruction_master_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_cpu_0_instruction_master_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((cpu_0_instruction_master_run AND cpu_0_instruction_master_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_cpu_0_instruction_master_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_requests_onchip_memory2_0_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  --vhdl renameroo for output signals
  cpu_0_instruction_master_address_to_slave <= internal_cpu_0_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_latency_counter <= internal_cpu_0_instruction_master_latency_counter;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_waitrequest <= internal_cpu_0_instruction_master_waitrequest;
--synthesis translate_off
    --cpu_0_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_instruction_master_address_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        cpu_0_instruction_master_address_last_time <= cpu_0_instruction_master_address;
      end if;

    end process;

    --cpu_0/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_cpu_0_instruction_master_waitrequest AND (cpu_0_instruction_master_read);
      end if;

    end process;

    --cpu_0_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_0_instruction_master_address /= cpu_0_instruction_master_address_last_time))))) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("cpu_0_instruction_master_address did not heed wait!!!"));
          write(output, write_line7.all);
          deallocate (write_line7);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_0_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        cpu_0_instruction_master_read_last_time <= cpu_0_instruction_master_read;
      end if;

    end process;

    --cpu_0_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_0_instruction_master_read) /= std_logic'(cpu_0_instruction_master_read_last_time)))))) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("cpu_0_instruction_master_read did not heed wait!!!"));
          write(output, write_line8.all);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jtag_uart_0_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_address : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jtag_uart_0_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_0_avalon_jtag_slave_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_begins_xfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_firsttransfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_grant_vector :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_in_a_read_cycle :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_in_a_write_cycle :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_master_qreq_vector :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_reg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waits_for_read :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_jtag_uart_0_avalon_jtag_slave_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_jtag_uart_0_avalon_jtag_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT jtag_uart_0_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  jtag_uart_0_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave);
  --assign jtag_uart_0_avalon_jtag_slave_readdata_from_sa = jtag_uart_0_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_readdata_from_sa <= jtag_uart_0_avalon_jtag_slave_readdata;
  internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000001000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_0_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_0_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_0_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_0_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_0_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_0_avalon_jtag_slave_waitrequest;
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_arb_share_set_values <= std_logic_vector'("001");
  --jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests <= internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave;
  --jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(jtag_uart_0_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (jtag_uart_0_avalon_jtag_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(jtag_uart_0_avalon_jtag_slave_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (jtag_uart_0_avalon_jtag_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --jtag_uart_0_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_allgrants <= jtag_uart_0_avalon_jtag_slave_grant_vector;
  --jtag_uart_0_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_end_xfer <= NOT ((jtag_uart_0_avalon_jtag_slave_waits_for_read OR jtag_uart_0_avalon_jtag_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave <= jtag_uart_0_avalon_jtag_slave_end_xfer AND (((NOT jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave AND jtag_uart_0_avalon_jtag_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave AND NOT jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests));
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_0_avalon_jtag_slave_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_0_avalon_jtag_slave_arb_counter_enable) = '1' then 
        jtag_uart_0_avalon_jtag_slave_arb_share_counter <= jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jtag_uart_0_avalon_jtag_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave)) OR ((end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave AND NOT jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests)))) = '1' then 
        jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable <= or_reduce(jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master jtag_uart_0/avalon_jtag_slave arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 <= or_reduce(jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value);
  --cpu_0/data_master jtag_uart_0/avalon_jtag_slave arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --jtag_uart_0_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave AND NOT ((cpu_0_data_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave, which is an e_mux
  cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave <= (internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave AND cpu_0_data_master_read) AND NOT jtag_uart_0_avalon_jtag_slave_waits_for_read;
  --jtag_uart_0_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave;
  --cpu_0/data_master saved-grant jtag_uart_0/avalon_jtag_slave, which is an e_assign
  cpu_0_data_master_saved_grant_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart_0/avalon_jtag_slave, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_0_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_0_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_0_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_0_avalon_jtag_slave_chipselect <= internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave;
  --jtag_uart_0_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_firsttransfer <= A_WE_StdLogic((std_logic'(jtag_uart_0_avalon_jtag_slave_begins_xfer) = '1'), jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer, jtag_uart_0_avalon_jtag_slave_reg_firsttransfer);
  --jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer <= NOT ((jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable AND jtag_uart_0_avalon_jtag_slave_any_continuerequest));
  --jtag_uart_0_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_0_avalon_jtag_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_0_avalon_jtag_slave_begins_xfer) = '1' then 
        jtag_uart_0_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jtag_uart_0_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_beginbursttransfer_internal <= jtag_uart_0_avalon_jtag_slave_begins_xfer;
  --~jtag_uart_0_avalon_jtag_slave_read_n assignment, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_read_n <= NOT ((internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave AND cpu_0_data_master_read));
  --~jtag_uart_0_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_write_n <= NOT ((internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave AND cpu_0_data_master_write));
  shifted_address_to_jtag_uart_0_avalon_jtag_slave_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --jtag_uart_0_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_jtag_uart_0_avalon_jtag_slave_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_jtag_uart_0_avalon_jtag_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer <= jtag_uart_0_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  --jtag_uart_0_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_waits_for_read <= jtag_uart_0_avalon_jtag_slave_in_a_read_cycle AND internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_0_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_in_a_read_cycle <= internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_0_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_0_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_waits_for_write <= jtag_uart_0_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_0_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_in_a_write_cycle <= internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_0_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_0_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_0_avalon_jtag_slave_irq_from_sa = jtag_uart_0_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_irq_from_sa <= jtag_uart_0_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave;
  --vhdl renameroo for output signals
  jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa;
--synthesis translate_off
    --jtag_uart_0/avalon_jtag_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity onchip_memory2_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_address : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal onchip_memory2_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_memory2_0_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_clken : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_memory2_0_s1_reset : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_write : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity onchip_memory2_0_s1_arbitrator;


architecture europa of onchip_memory2_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in :  STD_LOGIC;
                signal cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_memory2_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 :  STD_LOGIC;
                signal onchip_memory2_0_s1_allgrants :  STD_LOGIC;
                signal onchip_memory2_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_memory2_0_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal onchip_memory2_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal onchip_memory2_0_s1_begins_xfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory2_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_end_xfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal onchip_memory2_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal onchip_memory2_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal onchip_memory2_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_waits_for_read :  STD_LOGIC;
                signal onchip_memory2_0_s1_waits_for_write :  STD_LOGIC;
                signal p1_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal p1_cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_onchip_memory2_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal shifted_address_to_onchip_memory2_0_s1_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_onchip_memory2_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT onchip_memory2_0_s1_end_xfer;
    end if;

  end process;

  onchip_memory2_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1));
  --assign onchip_memory2_0_s1_readdata_from_sa = onchip_memory2_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_memory2_0_s1_readdata_from_sa <= onchip_memory2_0_s1_readdata;
  internal_cpu_0_data_master_requests_onchip_memory2_0_s1 <= to_std_logic(((Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_data_master_address_to_slave(15)) & std_logic_vector'("000000000000000")) = std_logic_vector'("1000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --onchip_memory2_0_s1_arb_share_counter set values, which is an e_mux
  onchip_memory2_0_s1_arb_share_set_values <= std_logic_vector'("001");
  --onchip_memory2_0_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_memory2_0_s1_non_bursting_master_requests <= ((internal_cpu_0_data_master_requests_onchip_memory2_0_s1 OR internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1) OR internal_cpu_0_data_master_requests_onchip_memory2_0_s1) OR internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_memory2_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_memory2_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_memory2_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (onchip_memory2_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory2_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (onchip_memory2_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --onchip_memory2_0_s1_allgrants all slave grants, which is an e_mux
  onchip_memory2_0_s1_allgrants <= (((or_reduce(onchip_memory2_0_s1_grant_vector)) OR (or_reduce(onchip_memory2_0_s1_grant_vector))) OR (or_reduce(onchip_memory2_0_s1_grant_vector))) OR (or_reduce(onchip_memory2_0_s1_grant_vector));
  --onchip_memory2_0_s1_end_xfer assignment, which is an e_assign
  onchip_memory2_0_s1_end_xfer <= NOT ((onchip_memory2_0_s1_waits_for_read OR onchip_memory2_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_onchip_memory2_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_onchip_memory2_0_s1 <= onchip_memory2_0_s1_end_xfer AND (((NOT onchip_memory2_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --onchip_memory2_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  onchip_memory2_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND onchip_memory2_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND NOT onchip_memory2_0_s1_non_bursting_master_requests));
  --onchip_memory2_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_arb_counter_enable) = '1' then 
        onchip_memory2_0_s1_arb_share_counter <= onchip_memory2_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --onchip_memory2_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(onchip_memory2_0_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_onchip_memory2_0_s1)) OR ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND NOT onchip_memory2_0_s1_non_bursting_master_requests)))) = '1' then 
        onchip_memory2_0_s1_slavearbiterlockenable <= or_reduce(onchip_memory2_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master onchip_memory2_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= onchip_memory2_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --onchip_memory2_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_memory2_0_s1_slavearbiterlockenable2 <= or_reduce(onchip_memory2_0_s1_arb_share_counter_next_value);
  --cpu_0/data_master onchip_memory2_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= onchip_memory2_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --cpu_0/instruction_master onchip_memory2_0/s1 arbiterlock, which is an e_assign
  cpu_0_instruction_master_arbiterlock <= onchip_memory2_0_s1_slavearbiterlockenable AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master onchip_memory2_0/s1 arbiterlock2, which is an e_assign
  cpu_0_instruction_master_arbiterlock2 <= onchip_memory2_0_s1_slavearbiterlockenable2 AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master granted onchip_memory2_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1))))));
    end if;

  end process;

  --cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  cpu_0_instruction_master_continuerequest <= last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 AND internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_memory2_0_s1_any_continuerequest <= cpu_0_instruction_master_continuerequest OR cpu_0_data_master_continuerequest;
  internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_data_master_requests_onchip_memory2_0_s1 AND NOT ((((cpu_0_data_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter)))))))) OR cpu_0_instruction_master_arbiterlock));
  --cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in <= (internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_read) AND NOT onchip_memory2_0_s1_waits_for_read;
  --shift register p1 cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register) & A_ToStdLogicVector(cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in)));
  --cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= p1_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_0_data_master_read_data_valid_onchip_memory2_0_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 <= cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register;
  --onchip_memory2_0_s1_writedata mux, which is an e_mux
  onchip_memory2_0_s1_writedata <= cpu_0_data_master_writedata;
  --mux onchip_memory2_0_s1_clken, which is an e_mux
  onchip_memory2_0_s1_clken <= std_logic'('1');
  internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1 <= ((to_std_logic(((Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_instruction_master_address_to_slave(15)) & std_logic_vector'("000000000000000")) = std_logic_vector'("1000000000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
  --cpu_0/data_master granted onchip_memory2_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_data_master_saved_grant_onchip_memory2_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_data_master_requests_onchip_memory2_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1))))));
    end if;

  end process;

  --cpu_0_data_master_continuerequest continued request, which is an e_mux
  cpu_0_data_master_continuerequest <= last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 AND internal_cpu_0_data_master_requests_onchip_memory2_0_s1;
  internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1 AND NOT ((((cpu_0_instruction_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_latency_counter)))))))) OR cpu_0_data_master_arbiterlock));
  --cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in <= (internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 AND cpu_0_instruction_master_read) AND NOT onchip_memory2_0_s1_waits_for_read;
  --shift register p1 cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register) & A_ToStdLogicVector(cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in)));
  --cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= p1_cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1, which is an e_mux
  cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 <= cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register;
  --allow new arb cycle for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_allow_new_arb_cycle <= NOT cpu_0_data_master_arbiterlock AND NOT cpu_0_instruction_master_arbiterlock;
  --cpu_0/instruction_master assignment into master qualified-requests vector for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_master_qreq_vector(0) <= internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1;
  --cpu_0/instruction_master grant onchip_memory2_0/s1, which is an e_assign
  internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 <= onchip_memory2_0_s1_grant_vector(0);
  --cpu_0/instruction_master saved-grant onchip_memory2_0/s1, which is an e_assign
  cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1 <= onchip_memory2_0_s1_arb_winner(0) AND internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
  --cpu_0/data_master assignment into master qualified-requests vector for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_master_qreq_vector(1) <= internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1;
  --cpu_0/data_master grant onchip_memory2_0/s1, which is an e_assign
  internal_cpu_0_data_master_granted_onchip_memory2_0_s1 <= onchip_memory2_0_s1_grant_vector(1);
  --cpu_0/data_master saved-grant onchip_memory2_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_onchip_memory2_0_s1 <= onchip_memory2_0_s1_arb_winner(1) AND internal_cpu_0_data_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0/s1 chosen-master double-vector, which is an e_assign
  onchip_memory2_0_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((onchip_memory2_0_s1_master_qreq_vector & onchip_memory2_0_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT onchip_memory2_0_s1_master_qreq_vector & NOT onchip_memory2_0_s1_master_qreq_vector))) + (std_logic_vector'("000") & (onchip_memory2_0_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  onchip_memory2_0_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_allow_new_arb_cycle AND or_reduce(onchip_memory2_0_s1_grant_vector)))) = '1'), onchip_memory2_0_s1_grant_vector, onchip_memory2_0_s1_saved_chosen_master_vector);
  --saved onchip_memory2_0_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_allow_new_arb_cycle) = '1' then 
        onchip_memory2_0_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory2_0_s1_grant_vector)) = '1'), onchip_memory2_0_s1_grant_vector, onchip_memory2_0_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  onchip_memory2_0_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((onchip_memory2_0_s1_chosen_master_double_vector(1) OR onchip_memory2_0_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((onchip_memory2_0_s1_chosen_master_double_vector(0) OR onchip_memory2_0_s1_chosen_master_double_vector(2)))));
  --onchip_memory2_0/s1 chosen master rotated left, which is an e_assign
  onchip_memory2_0_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(onchip_memory2_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(onchip_memory2_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --onchip_memory2_0/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(onchip_memory2_0_s1_grant_vector)) = '1' then 
        onchip_memory2_0_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_end_xfer) = '1'), onchip_memory2_0_s1_chosen_master_rot_left, onchip_memory2_0_s1_grant_vector);
      end if;
    end if;

  end process;

  --~onchip_memory2_0_s1_reset assignment, which is an e_assign
  onchip_memory2_0_s1_reset <= NOT reset_n;
  onchip_memory2_0_s1_chipselect <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1 OR internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_firsttransfer first transaction, which is an e_assign
  onchip_memory2_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(onchip_memory2_0_s1_begins_xfer) = '1'), onchip_memory2_0_s1_unreg_firsttransfer, onchip_memory2_0_s1_reg_firsttransfer);
  --onchip_memory2_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  onchip_memory2_0_s1_unreg_firsttransfer <= NOT ((onchip_memory2_0_s1_slavearbiterlockenable AND onchip_memory2_0_s1_any_continuerequest));
  --onchip_memory2_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_begins_xfer) = '1' then 
        onchip_memory2_0_s1_reg_firsttransfer <= onchip_memory2_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --onchip_memory2_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  onchip_memory2_0_s1_beginbursttransfer_internal <= onchip_memory2_0_s1_begins_xfer;
  --onchip_memory2_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  onchip_memory2_0_s1_arbitration_holdoff_internal <= onchip_memory2_0_s1_begins_xfer AND onchip_memory2_0_s1_firsttransfer;
  --onchip_memory2_0_s1_write assignment, which is an e_mux
  onchip_memory2_0_s1_write <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_write;
  shifted_address_to_onchip_memory2_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --onchip_memory2_0_s1_address mux, which is an e_mux
  onchip_memory2_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_onchip_memory2_0_s1)) = '1'), (A_SRL(shifted_address_to_onchip_memory2_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_onchip_memory2_0_s1_from_cpu_0_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 13);
  shifted_address_to_onchip_memory2_0_s1_from_cpu_0_instruction_master <= cpu_0_instruction_master_address_to_slave;
  --d1_onchip_memory2_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_onchip_memory2_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_onchip_memory2_0_s1_end_xfer <= onchip_memory2_0_s1_end_xfer;
    end if;

  end process;

  --onchip_memory2_0_s1_waits_for_read in a cycle, which is an e_mux
  onchip_memory2_0_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory2_0_s1_in_a_read_cycle assignment, which is an e_assign
  onchip_memory2_0_s1_in_a_read_cycle <= ((internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 AND cpu_0_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_memory2_0_s1_in_a_read_cycle;
  --onchip_memory2_0_s1_waits_for_write in a cycle, which is an e_mux
  onchip_memory2_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory2_0_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_memory2_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_memory2_0_s1_in_a_write_cycle;
  wait_for_onchip_memory2_0_s1_counter <= std_logic'('0');
  --onchip_memory2_0_s1_byteenable byte enable port mux, which is an e_mux
  onchip_memory2_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_onchip_memory2_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_onchip_memory2_0_s1 <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_onchip_memory2_0_s1 <= internal_cpu_0_data_master_requests_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_granted_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_requests_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
--synthesis translate_off
    --onchip_memory2_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_onchip_memory2_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line9.all);
          deallocate (write_line9);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_onchip_memory2_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line10.all);
          deallocate (write_line10);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pio_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_0_s1_irq : IN STD_LOGIC;
                 signal pio_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_pio_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_pio_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_pio_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_pio_0_s1 : OUT STD_LOGIC;
                 signal d1_pio_0_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_0_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_0_s1_chipselect : OUT STD_LOGIC;
                 signal pio_0_s1_irq_from_sa : OUT STD_LOGIC;
                 signal pio_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_0_s1_reset_n : OUT STD_LOGIC;
                 signal pio_0_s1_write_n : OUT STD_LOGIC;
                 signal pio_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_0_s1_arbitrator;


architecture europa of pio_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_pio_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_pio_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_pio_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_pio_0_s1 :  STD_LOGIC;
                signal pio_0_s1_allgrants :  STD_LOGIC;
                signal pio_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_0_s1_any_continuerequest :  STD_LOGIC;
                signal pio_0_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal pio_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal pio_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal pio_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_0_s1_begins_xfer :  STD_LOGIC;
                signal pio_0_s1_end_xfer :  STD_LOGIC;
                signal pio_0_s1_firsttransfer :  STD_LOGIC;
                signal pio_0_s1_grant_vector :  STD_LOGIC;
                signal pio_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_0_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_0_s1_waits_for_read :  STD_LOGIC;
                signal pio_0_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_pio_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_0_s1_end_xfer;
    end if;

  end process;

  pio_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_pio_0_s1);
  --assign pio_0_s1_readdata_from_sa = pio_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_0_s1_readdata_from_sa <= pio_0_s1_readdata;
  internal_cpu_0_data_master_requests_pio_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000010000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --pio_0_s1_arb_share_counter set values, which is an e_mux
  pio_0_s1_arb_share_set_values <= std_logic_vector'("001");
  --pio_0_s1_non_bursting_master_requests mux, which is an e_mux
  pio_0_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_pio_0_s1;
  --pio_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_0_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (pio_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (pio_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --pio_0_s1_allgrants all slave grants, which is an e_mux
  pio_0_s1_allgrants <= pio_0_s1_grant_vector;
  --pio_0_s1_end_xfer assignment, which is an e_assign
  pio_0_s1_end_xfer <= NOT ((pio_0_s1_waits_for_read OR pio_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_0_s1 <= pio_0_s1_end_xfer AND (((NOT pio_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_0_s1 AND pio_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_0_s1 AND NOT pio_0_s1_non_bursting_master_requests));
  --pio_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_0_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_0_s1_arb_counter_enable) = '1' then 
        pio_0_s1_arb_share_counter <= pio_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_0_s1)) OR ((end_xfer_arb_share_counter_term_pio_0_s1 AND NOT pio_0_s1_non_bursting_master_requests)))) = '1' then 
        pio_0_s1_slavearbiterlockenable <= or_reduce(pio_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master pio_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= pio_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --pio_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_0_s1_slavearbiterlockenable2 <= or_reduce(pio_0_s1_arb_share_counter_next_value);
  --cpu_0/data_master pio_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= pio_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --pio_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_0_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_pio_0_s1 <= internal_cpu_0_data_master_requests_pio_0_s1 AND NOT ((cpu_0_data_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid cpu_0_data_master_read_data_valid_pio_0_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_pio_0_s1 <= (internal_cpu_0_data_master_granted_pio_0_s1 AND cpu_0_data_master_read) AND NOT pio_0_s1_waits_for_read;
  --pio_0_s1_writedata mux, which is an e_mux
  pio_0_s1_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_pio_0_s1 <= internal_cpu_0_data_master_qualified_request_pio_0_s1;
  --cpu_0/data_master saved-grant pio_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_pio_0_s1 <= internal_cpu_0_data_master_requests_pio_0_s1;
  --allow new arb cycle for pio_0/s1, which is an e_assign
  pio_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_0_s1_master_qreq_vector <= std_logic'('1');
  --pio_0_s1_reset_n assignment, which is an e_assign
  pio_0_s1_reset_n <= reset_n;
  pio_0_s1_chipselect <= internal_cpu_0_data_master_granted_pio_0_s1;
  --pio_0_s1_firsttransfer first transaction, which is an e_assign
  pio_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_0_s1_begins_xfer) = '1'), pio_0_s1_unreg_firsttransfer, pio_0_s1_reg_firsttransfer);
  --pio_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_0_s1_unreg_firsttransfer <= NOT ((pio_0_s1_slavearbiterlockenable AND pio_0_s1_any_continuerequest));
  --pio_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_0_s1_begins_xfer) = '1' then 
        pio_0_s1_reg_firsttransfer <= pio_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_0_s1_beginbursttransfer_internal <= pio_0_s1_begins_xfer;
  --~pio_0_s1_write_n assignment, which is an e_mux
  pio_0_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_pio_0_s1 AND cpu_0_data_master_write));
  shifted_address_to_pio_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --pio_0_s1_address mux, which is an e_mux
  pio_0_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_0_s1_end_xfer <= pio_0_s1_end_xfer;
    end if;

  end process;

  --pio_0_s1_waits_for_read in a cycle, which is an e_mux
  pio_0_s1_waits_for_read <= pio_0_s1_in_a_read_cycle AND pio_0_s1_begins_xfer;
  --pio_0_s1_in_a_read_cycle assignment, which is an e_assign
  pio_0_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_pio_0_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_0_s1_in_a_read_cycle;
  --pio_0_s1_waits_for_write in a cycle, which is an e_mux
  pio_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_0_s1_in_a_write_cycle assignment, which is an e_assign
  pio_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_pio_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_0_s1_in_a_write_cycle;
  wait_for_pio_0_s1_counter <= std_logic'('0');
  --assign pio_0_s1_irq_from_sa = pio_0_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_0_s1_irq_from_sa <= pio_0_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_pio_0_s1 <= internal_cpu_0_data_master_granted_pio_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_pio_0_s1 <= internal_cpu_0_data_master_qualified_request_pio_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_pio_0_s1 <= internal_cpu_0_data_master_requests_pio_0_s1;
--synthesis translate_off
    --pio_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sysid_control_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sysid_control_slave_reset_n : OUT STD_LOGIC
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal shifted_address_to_sysid_control_slave_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal sysid_control_slave_allgrants :  STD_LOGIC;
                signal sysid_control_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal sysid_control_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sysid_control_slave_any_continuerequest :  STD_LOGIC;
                signal sysid_control_slave_arb_counter_enable :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal sysid_control_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal sysid_control_slave_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal sysid_control_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal sysid_control_slave_begins_xfer :  STD_LOGIC;
                signal sysid_control_slave_end_xfer :  STD_LOGIC;
                signal sysid_control_slave_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_grant_vector :  STD_LOGIC;
                signal sysid_control_slave_in_a_read_cycle :  STD_LOGIC;
                signal sysid_control_slave_in_a_write_cycle :  STD_LOGIC;
                signal sysid_control_slave_master_qreq_vector :  STD_LOGIC;
                signal sysid_control_slave_non_bursting_master_requests :  STD_LOGIC;
                signal sysid_control_slave_reg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal sysid_control_slave_unreg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_waits_for_read :  STD_LOGIC;
                signal sysid_control_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_sysid_control_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT sysid_control_slave_end_xfer;
    end if;

  end process;

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_cpu_0_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic_vector'("001");
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_cpu_0_data_master_requests_sysid_control_slave;
  --sysid_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  sysid_control_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --sysid_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  sysid_control_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(sysid_control_slave_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (sysid_control_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(sysid_control_slave_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (sysid_control_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --sysid_control_slave_allgrants all slave grants, which is an e_mux
  sysid_control_slave_allgrants <= sysid_control_slave_grant_vector;
  --sysid_control_slave_end_xfer assignment, which is an e_assign
  sysid_control_slave_end_xfer <= NOT ((sysid_control_slave_waits_for_read OR sysid_control_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_sysid_control_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sysid_control_slave <= sysid_control_slave_end_xfer AND (((NOT sysid_control_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sysid_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  sysid_control_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sysid_control_slave AND sysid_control_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests));
  --sysid_control_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_arb_counter_enable) = '1' then 
        sysid_control_slave_arb_share_counter <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sysid_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((sysid_control_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_sysid_control_slave)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests)))) = '1' then 
        sysid_control_slave_slavearbiterlockenable <= or_reduce(sysid_control_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master sysid/control_slave arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= or_reduce(sysid_control_slave_arb_share_counter_next_value);
  --cpu_0/data_master sysid/control_slave arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_sysid_control_slave <= internal_cpu_0_data_master_requests_sysid_control_slave AND NOT ((cpu_0_data_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid cpu_0_data_master_read_data_valid_sysid_control_slave, which is an e_mux
  cpu_0_data_master_read_data_valid_sysid_control_slave <= (internal_cpu_0_data_master_granted_sysid_control_slave AND cpu_0_data_master_read) AND NOT sysid_control_slave_waits_for_read;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_sysid_control_slave <= internal_cpu_0_data_master_qualified_request_sysid_control_slave;
  --cpu_0/data_master saved-grant sysid/control_slave, which is an e_assign
  cpu_0_data_master_saved_grant_sysid_control_slave <= internal_cpu_0_data_master_requests_sysid_control_slave;
  --allow new arb cycle for sysid/control_slave, which is an e_assign
  sysid_control_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sysid_control_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sysid_control_slave_master_qreq_vector <= std_logic'('1');
  --sysid_control_slave_reset_n assignment, which is an e_assign
  sysid_control_slave_reset_n <= reset_n;
  --sysid_control_slave_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_firsttransfer <= A_WE_StdLogic((std_logic'(sysid_control_slave_begins_xfer) = '1'), sysid_control_slave_unreg_firsttransfer, sysid_control_slave_reg_firsttransfer);
  --sysid_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_unreg_firsttransfer <= NOT ((sysid_control_slave_slavearbiterlockenable AND sysid_control_slave_any_continuerequest));
  --sysid_control_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_begins_xfer) = '1' then 
        sysid_control_slave_reg_firsttransfer <= sysid_control_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sysid_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sysid_control_slave_beginbursttransfer_internal <= sysid_control_slave_begins_xfer;
  shifted_address_to_sysid_control_slave_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_sysid_control_slave_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_sysid_control_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sysid_control_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_sysid_control_slave_end_xfer <= sysid_control_slave_end_xfer;
    end if;

  end process;

  --sysid_control_slave_waits_for_read in a cycle, which is an e_mux
  sysid_control_slave_waits_for_read <= sysid_control_slave_in_a_read_cycle AND sysid_control_slave_begins_xfer;
  --sysid_control_slave_in_a_read_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_read_cycle <= internal_cpu_0_data_master_granted_sysid_control_slave AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_cpu_0_data_master_granted_sysid_control_slave AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_sysid_control_slave <= internal_cpu_0_data_master_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_sysid_control_slave <= internal_cpu_0_data_master_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_sysid_control_slave <= internal_cpu_0_data_master_requests_sysid_control_slave;
--synthesis translate_off
    --sysid/control_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity timer_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal timer_0_s1_irq : IN STD_LOGIC;
                 signal timer_0_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_timer_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_0_s1 : OUT STD_LOGIC;
                 signal d1_timer_0_s1_end_xfer : OUT STD_LOGIC;
                 signal timer_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal timer_0_s1_chipselect : OUT STD_LOGIC;
                 signal timer_0_s1_irq_from_sa : OUT STD_LOGIC;
                 signal timer_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_0_s1_reset_n : OUT STD_LOGIC;
                 signal timer_0_s1_write_n : OUT STD_LOGIC;
                 signal timer_0_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity timer_0_s1_arbitrator;


architecture europa of timer_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_timer_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_timer_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_timer_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_timer_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_timer_0_s1 :  STD_LOGIC;
                signal shifted_address_to_timer_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_allgrants :  STD_LOGIC;
                signal timer_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal timer_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal timer_0_s1_any_continuerequest :  STD_LOGIC;
                signal timer_0_s1_arb_counter_enable :  STD_LOGIC;
                signal timer_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal timer_0_s1_begins_xfer :  STD_LOGIC;
                signal timer_0_s1_end_xfer :  STD_LOGIC;
                signal timer_0_s1_firsttransfer :  STD_LOGIC;
                signal timer_0_s1_grant_vector :  STD_LOGIC;
                signal timer_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal timer_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal timer_0_s1_master_qreq_vector :  STD_LOGIC;
                signal timer_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal timer_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal timer_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal timer_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal timer_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal timer_0_s1_waits_for_read :  STD_LOGIC;
                signal timer_0_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_timer_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT timer_0_s1_end_xfer;
    end if;

  end process;

  timer_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_timer_0_s1);
  --assign timer_0_s1_readdata_from_sa = timer_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_0_s1_readdata_from_sa <= timer_0_s1_readdata;
  internal_cpu_0_data_master_requests_timer_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000100000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --timer_0_s1_arb_share_counter set values, which is an e_mux
  timer_0_s1_arb_share_set_values <= std_logic_vector'("001");
  --timer_0_s1_non_bursting_master_requests mux, which is an e_mux
  timer_0_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_timer_0_s1;
  --timer_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  timer_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --timer_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  timer_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(timer_0_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (timer_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(timer_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (timer_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --timer_0_s1_allgrants all slave grants, which is an e_mux
  timer_0_s1_allgrants <= timer_0_s1_grant_vector;
  --timer_0_s1_end_xfer assignment, which is an e_assign
  timer_0_s1_end_xfer <= NOT ((timer_0_s1_waits_for_read OR timer_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_timer_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_timer_0_s1 <= timer_0_s1_end_xfer AND (((NOT timer_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --timer_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  timer_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_timer_0_s1 AND timer_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_timer_0_s1 AND NOT timer_0_s1_non_bursting_master_requests));
  --timer_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_0_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(timer_0_s1_arb_counter_enable) = '1' then 
        timer_0_s1_arb_share_counter <= timer_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --timer_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((timer_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_timer_0_s1)) OR ((end_xfer_arb_share_counter_term_timer_0_s1 AND NOT timer_0_s1_non_bursting_master_requests)))) = '1' then 
        timer_0_s1_slavearbiterlockenable <= or_reduce(timer_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master timer_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= timer_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --timer_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  timer_0_s1_slavearbiterlockenable2 <= or_reduce(timer_0_s1_arb_share_counter_next_value);
  --cpu_0/data_master timer_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= timer_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --timer_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  timer_0_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1 AND NOT ((cpu_0_data_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid cpu_0_data_master_read_data_valid_timer_0_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_timer_0_s1 <= (internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_read) AND NOT timer_0_s1_waits_for_read;
  --timer_0_s1_writedata mux, which is an e_mux
  timer_0_s1_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_timer_0_s1 <= internal_cpu_0_data_master_qualified_request_timer_0_s1;
  --cpu_0/data_master saved-grant timer_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1;
  --allow new arb cycle for timer_0/s1, which is an e_assign
  timer_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  timer_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  timer_0_s1_master_qreq_vector <= std_logic'('1');
  --timer_0_s1_reset_n assignment, which is an e_assign
  timer_0_s1_reset_n <= reset_n;
  timer_0_s1_chipselect <= internal_cpu_0_data_master_granted_timer_0_s1;
  --timer_0_s1_firsttransfer first transaction, which is an e_assign
  timer_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(timer_0_s1_begins_xfer) = '1'), timer_0_s1_unreg_firsttransfer, timer_0_s1_reg_firsttransfer);
  --timer_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  timer_0_s1_unreg_firsttransfer <= NOT ((timer_0_s1_slavearbiterlockenable AND timer_0_s1_any_continuerequest));
  --timer_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_0_s1_begins_xfer) = '1' then 
        timer_0_s1_reg_firsttransfer <= timer_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --timer_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  timer_0_s1_beginbursttransfer_internal <= timer_0_s1_begins_xfer;
  --~timer_0_s1_write_n assignment, which is an e_mux
  timer_0_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_write));
  shifted_address_to_timer_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --timer_0_s1_address mux, which is an e_mux
  timer_0_s1_address <= A_EXT (A_SRL(shifted_address_to_timer_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_timer_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_timer_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_timer_0_s1_end_xfer <= timer_0_s1_end_xfer;
    end if;

  end process;

  --timer_0_s1_waits_for_read in a cycle, which is an e_mux
  timer_0_s1_waits_for_read <= timer_0_s1_in_a_read_cycle AND timer_0_s1_begins_xfer;
  --timer_0_s1_in_a_read_cycle assignment, which is an e_assign
  timer_0_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= timer_0_s1_in_a_read_cycle;
  --timer_0_s1_waits_for_write in a cycle, which is an e_mux
  timer_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --timer_0_s1_in_a_write_cycle assignment, which is an e_assign
  timer_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= timer_0_s1_in_a_write_cycle;
  wait_for_timer_0_s1_counter <= std_logic'('0');
  --assign timer_0_s1_irq_from_sa = timer_0_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_0_s1_irq_from_sa <= timer_0_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_timer_0_s1 <= internal_cpu_0_data_master_granted_timer_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_timer_0_s1 <= internal_cpu_0_data_master_qualified_request_timer_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1;
--synthesis translate_off
    --timer_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vai_i2c_master_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_0_data_master_dbs_write_8 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vai_i2c_master_0_s1_irq : IN STD_LOGIC;
                 signal vai_i2c_master_0_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal vai_i2c_master_0_s1_waitrequest_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                 signal d1_vai_i2c_master_0_s1_end_xfer : OUT STD_LOGIC;
                 signal vai_i2c_master_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal vai_i2c_master_0_s1_chipselect : OUT STD_LOGIC;
                 signal vai_i2c_master_0_s1_irq_from_sa : OUT STD_LOGIC;
                 signal vai_i2c_master_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal vai_i2c_master_0_s1_reset : OUT STD_LOGIC;
                 signal vai_i2c_master_0_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal vai_i2c_master_0_s1_write : OUT STD_LOGIC;
                 signal vai_i2c_master_0_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
              );
end entity vai_i2c_master_0_s1_arbitrator;


architecture europa of vai_i2c_master_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_0 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_1 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_2 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_3 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_byteenable_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal internal_vai_i2c_master_0_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal vai_i2c_master_0_s1_allgrants :  STD_LOGIC;
                signal vai_i2c_master_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal vai_i2c_master_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal vai_i2c_master_0_s1_any_continuerequest :  STD_LOGIC;
                signal vai_i2c_master_0_s1_arb_counter_enable :  STD_LOGIC;
                signal vai_i2c_master_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vai_i2c_master_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vai_i2c_master_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vai_i2c_master_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal vai_i2c_master_0_s1_begins_xfer :  STD_LOGIC;
                signal vai_i2c_master_0_s1_end_xfer :  STD_LOGIC;
                signal vai_i2c_master_0_s1_firsttransfer :  STD_LOGIC;
                signal vai_i2c_master_0_s1_grant_vector :  STD_LOGIC;
                signal vai_i2c_master_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal vai_i2c_master_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal vai_i2c_master_0_s1_master_qreq_vector :  STD_LOGIC;
                signal vai_i2c_master_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal vai_i2c_master_0_s1_pretend_byte_enable :  STD_LOGIC;
                signal vai_i2c_master_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal vai_i2c_master_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal vai_i2c_master_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal vai_i2c_master_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal vai_i2c_master_0_s1_waits_for_read :  STD_LOGIC;
                signal vai_i2c_master_0_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_vai_i2c_master_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT vai_i2c_master_0_s1_end_xfer;
    end if;

  end process;

  vai_i2c_master_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_vai_i2c_master_0_s1);
  --assign vai_i2c_master_0_s1_readdata_from_sa = vai_i2c_master_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  vai_i2c_master_0_s1_readdata_from_sa <= vai_i2c_master_0_s1_readdata;
  internal_cpu_0_data_master_requests_vai_i2c_master_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000001000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign vai_i2c_master_0_s1_waitrequest_n_from_sa = vai_i2c_master_0_s1_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_vai_i2c_master_0_s1_waitrequest_n_from_sa <= vai_i2c_master_0_s1_waitrequest_n;
  --vai_i2c_master_0_s1_arb_share_counter set values, which is an e_mux
  vai_i2c_master_0_s1_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_vai_i2c_master_0_s1)) = '1'), std_logic_vector'("00000000000000000000000000000100"), std_logic_vector'("00000000000000000000000000000001")), 3);
  --vai_i2c_master_0_s1_non_bursting_master_requests mux, which is an e_mux
  vai_i2c_master_0_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_vai_i2c_master_0_s1;
  --vai_i2c_master_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  vai_i2c_master_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --vai_i2c_master_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  vai_i2c_master_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(vai_i2c_master_0_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (vai_i2c_master_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(vai_i2c_master_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (vai_i2c_master_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --vai_i2c_master_0_s1_allgrants all slave grants, which is an e_mux
  vai_i2c_master_0_s1_allgrants <= vai_i2c_master_0_s1_grant_vector;
  --vai_i2c_master_0_s1_end_xfer assignment, which is an e_assign
  vai_i2c_master_0_s1_end_xfer <= NOT ((vai_i2c_master_0_s1_waits_for_read OR vai_i2c_master_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_vai_i2c_master_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_vai_i2c_master_0_s1 <= vai_i2c_master_0_s1_end_xfer AND (((NOT vai_i2c_master_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --vai_i2c_master_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  vai_i2c_master_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_vai_i2c_master_0_s1 AND vai_i2c_master_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_vai_i2c_master_0_s1 AND NOT vai_i2c_master_0_s1_non_bursting_master_requests));
  --vai_i2c_master_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vai_i2c_master_0_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(vai_i2c_master_0_s1_arb_counter_enable) = '1' then 
        vai_i2c_master_0_s1_arb_share_counter <= vai_i2c_master_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --vai_i2c_master_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vai_i2c_master_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((vai_i2c_master_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_vai_i2c_master_0_s1)) OR ((end_xfer_arb_share_counter_term_vai_i2c_master_0_s1 AND NOT vai_i2c_master_0_s1_non_bursting_master_requests)))) = '1' then 
        vai_i2c_master_0_s1_slavearbiterlockenable <= or_reduce(vai_i2c_master_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master vai_i2c_master_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= vai_i2c_master_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --vai_i2c_master_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  vai_i2c_master_0_s1_slavearbiterlockenable2 <= or_reduce(vai_i2c_master_0_s1_arb_share_counter_next_value);
  --cpu_0/data_master vai_i2c_master_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= vai_i2c_master_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --vai_i2c_master_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  vai_i2c_master_0_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_requests_vai_i2c_master_0_s1 AND NOT ((((cpu_0_data_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR (((NOT(internal_cpu_0_data_master_byteenable_vai_i2c_master_0_s1)) AND cpu_0_data_master_write))));
  --local readdatavalid cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 <= (internal_cpu_0_data_master_granted_vai_i2c_master_0_s1 AND cpu_0_data_master_read) AND NOT vai_i2c_master_0_s1_waits_for_read;
  --vai_i2c_master_0_s1_writedata mux, which is an e_mux
  vai_i2c_master_0_s1_writedata <= cpu_0_data_master_dbs_write_8;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_qualified_request_vai_i2c_master_0_s1;
  --cpu_0/data_master saved-grant vai_i2c_master_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_requests_vai_i2c_master_0_s1;
  --allow new arb cycle for vai_i2c_master_0/s1, which is an e_assign
  vai_i2c_master_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  vai_i2c_master_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  vai_i2c_master_0_s1_master_qreq_vector <= std_logic'('1');
  --~vai_i2c_master_0_s1_reset assignment, which is an e_assign
  vai_i2c_master_0_s1_reset <= NOT reset_n;
  vai_i2c_master_0_s1_chipselect <= internal_cpu_0_data_master_granted_vai_i2c_master_0_s1;
  --vai_i2c_master_0_s1_firsttransfer first transaction, which is an e_assign
  vai_i2c_master_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(vai_i2c_master_0_s1_begins_xfer) = '1'), vai_i2c_master_0_s1_unreg_firsttransfer, vai_i2c_master_0_s1_reg_firsttransfer);
  --vai_i2c_master_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  vai_i2c_master_0_s1_unreg_firsttransfer <= NOT ((vai_i2c_master_0_s1_slavearbiterlockenable AND vai_i2c_master_0_s1_any_continuerequest));
  --vai_i2c_master_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vai_i2c_master_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(vai_i2c_master_0_s1_begins_xfer) = '1' then 
        vai_i2c_master_0_s1_reg_firsttransfer <= vai_i2c_master_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --vai_i2c_master_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  vai_i2c_master_0_s1_beginbursttransfer_internal <= vai_i2c_master_0_s1_begins_xfer;
  --vai_i2c_master_0_s1_write assignment, which is an e_mux
  vai_i2c_master_0_s1_write <= ((internal_cpu_0_data_master_granted_vai_i2c_master_0_s1 AND cpu_0_data_master_write)) AND vai_i2c_master_0_s1_pretend_byte_enable;
  --vai_i2c_master_0_s1_address mux, which is an e_mux
  vai_i2c_master_0_s1_address <= A_EXT (Std_Logic_Vector'(A_SRL(cpu_0_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & cpu_0_data_master_dbs_address(1 DOWNTO 0)), 3);
  --d1_vai_i2c_master_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_vai_i2c_master_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_vai_i2c_master_0_s1_end_xfer <= vai_i2c_master_0_s1_end_xfer;
    end if;

  end process;

  --vai_i2c_master_0_s1_waits_for_read in a cycle, which is an e_mux
  vai_i2c_master_0_s1_waits_for_read <= vai_i2c_master_0_s1_in_a_read_cycle AND NOT internal_vai_i2c_master_0_s1_waitrequest_n_from_sa;
  --vai_i2c_master_0_s1_in_a_read_cycle assignment, which is an e_assign
  vai_i2c_master_0_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_vai_i2c_master_0_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= vai_i2c_master_0_s1_in_a_read_cycle;
  --vai_i2c_master_0_s1_waits_for_write in a cycle, which is an e_mux
  vai_i2c_master_0_s1_waits_for_write <= vai_i2c_master_0_s1_in_a_write_cycle AND NOT internal_vai_i2c_master_0_s1_waitrequest_n_from_sa;
  --vai_i2c_master_0_s1_in_a_write_cycle assignment, which is an e_assign
  vai_i2c_master_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_vai_i2c_master_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= vai_i2c_master_0_s1_in_a_write_cycle;
  wait_for_vai_i2c_master_0_s1_counter <= std_logic'('0');
  --vai_i2c_master_0_s1_pretend_byte_enable byte enable port mux, which is an e_mux
  vai_i2c_master_0_s1_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_vai_i2c_master_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_byteenable_vai_i2c_master_0_s1))), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  (cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_3, cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_2, cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_1, cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_0) <= cpu_0_data_master_byteenable;
  internal_cpu_0_data_master_byteenable_vai_i2c_master_0_s1 <= A_WE_StdLogic((((std_logic_vector'("000000000000000000000000000000") & (cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000000"))), cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_0, A_WE_StdLogic((((std_logic_vector'("000000000000000000000000000000") & (cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000001"))), cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_1, A_WE_StdLogic((((std_logic_vector'("000000000000000000000000000000") & (cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000010"))), cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_2, cpu_0_data_master_byteenable_vai_i2c_master_0_s1_segment_3)));
  --assign vai_i2c_master_0_s1_irq_from_sa = vai_i2c_master_0_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  vai_i2c_master_0_s1_irq_from_sa <= vai_i2c_master_0_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_byteenable_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_byteenable_vai_i2c_master_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_granted_vai_i2c_master_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_qualified_request_vai_i2c_master_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_vai_i2c_master_0_s1 <= internal_cpu_0_data_master_requests_vai_i2c_master_0_s1;
  --vhdl renameroo for output signals
  vai_i2c_master_0_s1_waitrequest_n_from_sa <= internal_vai_i2c_master_0_s1_waitrequest_n_from_sa;
--synthesis translate_off
    --vai_i2c_master_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ep4c_nios_system_reset_clk_24_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ep4c_nios_system_reset_clk_24_domain_synch_module;


architecture europa of ep4c_nios_system_reset_clk_24_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ep4c_nios_system is 
        port (
              -- 1) global signals:
                 signal clk_24 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_pio_0
                 signal in_port_to_the_pio_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal out_port_from_the_pio_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_vai_i2c_master_0
                 signal coe_arst_arst_i_to_the_vai_i2c_master_0 : IN STD_LOGIC;
                 signal coe_i2c_scl_pad_i_to_the_vai_i2c_master_0 : IN STD_LOGIC;
                 signal coe_i2c_scl_pad_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC;
                 signal coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC;
                 signal coe_i2c_sda_pad_i_to_the_vai_i2c_master_0 : IN STD_LOGIC;
                 signal coe_i2c_sda_pad_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC;
                 signal coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC
              );
end entity ep4c_nios_system;


architecture europa of ep4c_nios_system is
component cpu_0_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_debugaccess : IN STD_LOGIC;
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_write : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_0_jtag_debug_module_end_xfer : OUT STD_LOGIC
                 );
end component cpu_0_jtag_debug_module_arbitrator;

component cpu_0_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_pio_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_vai_i2c_master_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_pio_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_pio_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_pio_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_vai_i2c_master_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_timer_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_vai_i2c_master_0_s1_end_xfer : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_0_s1_irq_from_sa : IN STD_LOGIC;
                    signal pio_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal timer_0_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal vai_i2c_master_0_s1_irq_from_sa : IN STD_LOGIC;
                    signal vai_i2c_master_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal vai_i2c_master_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_0_data_master_dbs_write_8 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_0_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : OUT STD_LOGIC;
                    signal cpu_0_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_readdatavalid : OUT STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_0_data_master_arbitrator;

component cpu_0_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_instruction_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_latency_counter : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_readdatavalid : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_0_instruction_master_arbitrator;

component cpu_0 is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d_irq : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdatavalid : IN STD_LOGIC;
                    signal d_waitrequest : IN STD_LOGIC;
                    signal i_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_readdatavalid : IN STD_LOGIC;
                    signal i_waitrequest : IN STD_LOGIC;
                    signal jtag_debug_module_address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal jtag_debug_module_begintransfer : IN STD_LOGIC;
                    signal jtag_debug_module_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal jtag_debug_module_debugaccess : IN STD_LOGIC;
                    signal jtag_debug_module_select : IN STD_LOGIC;
                    signal jtag_debug_module_write : IN STD_LOGIC;
                    signal jtag_debug_module_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component cpu_0;

component jtag_uart_0_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_address : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jtag_uart_0_avalon_jtag_slave_arbitrator;

component jtag_uart_0 is 
           port (
                 -- inputs:
                    signal av_address : IN STD_LOGIC;
                    signal av_chipselect : IN STD_LOGIC;
                    signal av_read_n : IN STD_LOGIC;
                    signal av_write_n : IN STD_LOGIC;
                    signal av_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal rst_n : IN STD_LOGIC;

                 -- outputs:
                    signal av_irq : OUT STD_LOGIC;
                    signal av_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal av_waitrequest : OUT STD_LOGIC;
                    signal dataavailable : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component jtag_uart_0;

component onchip_memory2_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_address : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal onchip_memory2_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_memory2_0_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_clken : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_memory2_0_s1_reset : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_write : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_memory2_0_s1_arbitrator;

component onchip_memory2_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal clken : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_memory2_0;

component pio_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_0_s1_irq : IN STD_LOGIC;
                    signal pio_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_pio_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_pio_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_pio_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_pio_0_s1 : OUT STD_LOGIC;
                    signal d1_pio_0_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_0_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_0_s1_chipselect : OUT STD_LOGIC;
                    signal pio_0_s1_irq_from_sa : OUT STD_LOGIC;
                    signal pio_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_0_s1_reset_n : OUT STD_LOGIC;
                    signal pio_0_s1_write_n : OUT STD_LOGIC;
                    signal pio_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_0_s1_arbitrator;

component pio_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal out_port : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_0;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                    signal sysid_control_slave_address : OUT STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sysid_control_slave_reset_n : OUT STD_LOGIC
                 );
end component sysid_control_slave_arbitrator;

component sysid is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC;
                    signal clock : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sysid;

component timer_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal timer_0_s1_irq : IN STD_LOGIC;
                    signal timer_0_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_timer_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_0_s1 : OUT STD_LOGIC;
                    signal d1_timer_0_s1_end_xfer : OUT STD_LOGIC;
                    signal timer_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal timer_0_s1_chipselect : OUT STD_LOGIC;
                    signal timer_0_s1_irq_from_sa : OUT STD_LOGIC;
                    signal timer_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_0_s1_reset_n : OUT STD_LOGIC;
                    signal timer_0_s1_write_n : OUT STD_LOGIC;
                    signal timer_0_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_0_s1_arbitrator;

component timer_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_0;

component vai_i2c_master_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_0_data_master_dbs_write_8 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_0_data_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vai_i2c_master_0_s1_irq : IN STD_LOGIC;
                    signal vai_i2c_master_0_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal vai_i2c_master_0_s1_waitrequest_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_vai_i2c_master_0_s1 : OUT STD_LOGIC;
                    signal d1_vai_i2c_master_0_s1_end_xfer : OUT STD_LOGIC;
                    signal vai_i2c_master_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal vai_i2c_master_0_s1_chipselect : OUT STD_LOGIC;
                    signal vai_i2c_master_0_s1_irq_from_sa : OUT STD_LOGIC;
                    signal vai_i2c_master_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal vai_i2c_master_0_s1_reset : OUT STD_LOGIC;
                    signal vai_i2c_master_0_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal vai_i2c_master_0_s1_write : OUT STD_LOGIC;
                    signal vai_i2c_master_0_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component vai_i2c_master_0_s1_arbitrator;

component vai_i2c_master_0 is 
           port (
                 -- inputs:
                    signal avs_s1_address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal avs_s1_chipselect : IN STD_LOGIC;
                    signal avs_s1_write : IN STD_LOGIC;
                    signal avs_s1_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal coe_arst_arst_i : IN STD_LOGIC;
                    signal coe_i2c_scl_pad_i : IN STD_LOGIC;
                    signal coe_i2c_sda_pad_i : IN STD_LOGIC;
                    signal csi_clockreset_clk : IN STD_LOGIC;
                    signal csi_clockreset_reset : IN STD_LOGIC;

                 -- outputs:
                    signal avs_s1_readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal avs_s1_waitrequest_n : OUT STD_LOGIC;
                    signal coe_i2c_scl_pad_o : OUT STD_LOGIC;
                    signal coe_i2c_scl_padoen_o : OUT STD_LOGIC;
                    signal coe_i2c_sda_pad_o : OUT STD_LOGIC;
                    signal coe_i2c_sda_padoen_o : OUT STD_LOGIC;
                    signal ins_irq1_irq : OUT STD_LOGIC
                 );
end component vai_i2c_master_0;

component ep4c_nios_system_reset_clk_24_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ep4c_nios_system_reset_clk_24_domain_synch_module;

                signal clk_24_reset_n :  STD_LOGIC;
                signal cpu_0_data_master_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_data_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_data_master_byteenable_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_data_master_dbs_write_8 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal cpu_0_data_master_debugaccess :  STD_LOGIC;
                signal cpu_0_data_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_pio_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_granted_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_latency_counter :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_pio_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_pio_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_readdatavalid :  STD_LOGIC;
                signal cpu_0_data_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_pio_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_requests_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_vai_i2c_master_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_waitrequest :  STD_LOGIC;
                signal cpu_0_data_master_write :  STD_LOGIC;
                signal cpu_0_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_latency_counter :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_read :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_readdatavalid :  STD_LOGIC;
                signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_waitrequest :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal cpu_0_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_jtag_debug_module_chipselect :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_jtag_debug_module_reset_n :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_write :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_cpu_0_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_onchip_memory2_0_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_0_s1_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal d1_timer_0_s1_end_xfer :  STD_LOGIC;
                signal d1_vai_i2c_master_0_s1_end_xfer :  STD_LOGIC;
                signal internal_coe_i2c_scl_pad_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal internal_coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal internal_coe_i2c_sda_pad_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal internal_coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal internal_out_port_from_the_pio_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_address :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_chipselect :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_dataavailable :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_irq :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_read_n :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_readyfordata :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_reset_n :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waitrequest :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_write_n :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal module_input :  STD_LOGIC;
                signal onchip_memory2_0_s1_address :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal onchip_memory2_0_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory2_0_s1_chipselect :  STD_LOGIC;
                signal onchip_memory2_0_s1_clken :  STD_LOGIC;
                signal onchip_memory2_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_reset :  STD_LOGIC;
                signal onchip_memory2_0_s1_write :  STD_LOGIC;
                signal onchip_memory2_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_0_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_0_s1_chipselect :  STD_LOGIC;
                signal pio_0_s1_irq :  STD_LOGIC;
                signal pio_0_s1_irq_from_sa :  STD_LOGIC;
                signal pio_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_0_s1_reset_n :  STD_LOGIC;
                signal pio_0_s1_write_n :  STD_LOGIC;
                signal pio_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal reset_n_sources :  STD_LOGIC;
                signal sysid_control_slave_address :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal sysid_control_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_reset_n :  STD_LOGIC;
                signal timer_0_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_0_s1_chipselect :  STD_LOGIC;
                signal timer_0_s1_irq :  STD_LOGIC;
                signal timer_0_s1_irq_from_sa :  STD_LOGIC;
                signal timer_0_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_reset_n :  STD_LOGIC;
                signal timer_0_s1_write_n :  STD_LOGIC;
                signal timer_0_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal vai_i2c_master_0_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vai_i2c_master_0_s1_chipselect :  STD_LOGIC;
                signal vai_i2c_master_0_s1_irq :  STD_LOGIC;
                signal vai_i2c_master_0_s1_irq_from_sa :  STD_LOGIC;
                signal vai_i2c_master_0_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal vai_i2c_master_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal vai_i2c_master_0_s1_reset :  STD_LOGIC;
                signal vai_i2c_master_0_s1_waitrequest_n :  STD_LOGIC;
                signal vai_i2c_master_0_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal vai_i2c_master_0_s1_write :  STD_LOGIC;
                signal vai_i2c_master_0_s1_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);

begin

  --the_cpu_0_jtag_debug_module, which is an e_instance
  the_cpu_0_jtag_debug_module : cpu_0_jtag_debug_module_arbitrator
    port map(
      cpu_0_data_master_granted_cpu_0_jtag_debug_module => cpu_0_data_master_granted_cpu_0_jtag_debug_module,
      cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_data_master_requests_cpu_0_jtag_debug_module => cpu_0_data_master_requests_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_granted_cpu_0_jtag_debug_module => cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_requests_cpu_0_jtag_debug_module => cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
      cpu_0_jtag_debug_module_address => cpu_0_jtag_debug_module_address,
      cpu_0_jtag_debug_module_begintransfer => cpu_0_jtag_debug_module_begintransfer,
      cpu_0_jtag_debug_module_byteenable => cpu_0_jtag_debug_module_byteenable,
      cpu_0_jtag_debug_module_chipselect => cpu_0_jtag_debug_module_chipselect,
      cpu_0_jtag_debug_module_debugaccess => cpu_0_jtag_debug_module_debugaccess,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      cpu_0_jtag_debug_module_reset_n => cpu_0_jtag_debug_module_reset_n,
      cpu_0_jtag_debug_module_resetrequest_from_sa => cpu_0_jtag_debug_module_resetrequest_from_sa,
      cpu_0_jtag_debug_module_write => cpu_0_jtag_debug_module_write,
      cpu_0_jtag_debug_module_writedata => cpu_0_jtag_debug_module_writedata,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_debugaccess => cpu_0_data_master_debugaccess,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_jtag_debug_module_readdata => cpu_0_jtag_debug_module_readdata,
      cpu_0_jtag_debug_module_resetrequest => cpu_0_jtag_debug_module_resetrequest,
      reset_n => clk_24_reset_n
    );


  --the_cpu_0_data_master, which is an e_instance
  the_cpu_0_data_master : cpu_0_data_master_arbitrator
    port map(
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_dbs_address => cpu_0_data_master_dbs_address,
      cpu_0_data_master_dbs_write_8 => cpu_0_data_master_dbs_write_8,
      cpu_0_data_master_irq => cpu_0_data_master_irq,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_readdata => cpu_0_data_master_readdata,
      cpu_0_data_master_readdatavalid => cpu_0_data_master_readdatavalid,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      clk => clk_24,
      cpu_0_data_master_address => cpu_0_data_master_address,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_byteenable_vai_i2c_master_0_s1 => cpu_0_data_master_byteenable_vai_i2c_master_0_s1,
      cpu_0_data_master_granted_cpu_0_jtag_debug_module => cpu_0_data_master_granted_cpu_0_jtag_debug_module,
      cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_granted_onchip_memory2_0_s1 => cpu_0_data_master_granted_onchip_memory2_0_s1,
      cpu_0_data_master_granted_pio_0_s1 => cpu_0_data_master_granted_pio_0_s1,
      cpu_0_data_master_granted_sysid_control_slave => cpu_0_data_master_granted_sysid_control_slave,
      cpu_0_data_master_granted_timer_0_s1 => cpu_0_data_master_granted_timer_0_s1,
      cpu_0_data_master_granted_vai_i2c_master_0_s1 => cpu_0_data_master_granted_vai_i2c_master_0_s1,
      cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_qualified_request_onchip_memory2_0_s1 => cpu_0_data_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_data_master_qualified_request_pio_0_s1 => cpu_0_data_master_qualified_request_pio_0_s1,
      cpu_0_data_master_qualified_request_sysid_control_slave => cpu_0_data_master_qualified_request_sysid_control_slave,
      cpu_0_data_master_qualified_request_timer_0_s1 => cpu_0_data_master_qualified_request_timer_0_s1,
      cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 => cpu_0_data_master_qualified_request_vai_i2c_master_0_s1,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_data_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_data_master_read_data_valid_pio_0_s1 => cpu_0_data_master_read_data_valid_pio_0_s1,
      cpu_0_data_master_read_data_valid_sysid_control_slave => cpu_0_data_master_read_data_valid_sysid_control_slave,
      cpu_0_data_master_read_data_valid_timer_0_s1 => cpu_0_data_master_read_data_valid_timer_0_s1,
      cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 => cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1,
      cpu_0_data_master_requests_cpu_0_jtag_debug_module => cpu_0_data_master_requests_cpu_0_jtag_debug_module,
      cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_requests_onchip_memory2_0_s1 => cpu_0_data_master_requests_onchip_memory2_0_s1,
      cpu_0_data_master_requests_pio_0_s1 => cpu_0_data_master_requests_pio_0_s1,
      cpu_0_data_master_requests_sysid_control_slave => cpu_0_data_master_requests_sysid_control_slave,
      cpu_0_data_master_requests_timer_0_s1 => cpu_0_data_master_requests_timer_0_s1,
      cpu_0_data_master_requests_vai_i2c_master_0_s1 => cpu_0_data_master_requests_vai_i2c_master_0_s1,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer => d1_jtag_uart_0_avalon_jtag_slave_end_xfer,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      d1_pio_0_s1_end_xfer => d1_pio_0_s1_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_timer_0_s1_end_xfer => d1_timer_0_s1_end_xfer,
      d1_vai_i2c_master_0_s1_end_xfer => d1_vai_i2c_master_0_s1_end_xfer,
      jtag_uart_0_avalon_jtag_slave_irq_from_sa => jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      jtag_uart_0_avalon_jtag_slave_readdata_from_sa => jtag_uart_0_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      pio_0_s1_irq_from_sa => pio_0_s1_irq_from_sa,
      pio_0_s1_readdata_from_sa => pio_0_s1_readdata_from_sa,
      reset_n => clk_24_reset_n,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      timer_0_s1_irq_from_sa => timer_0_s1_irq_from_sa,
      timer_0_s1_readdata_from_sa => timer_0_s1_readdata_from_sa,
      vai_i2c_master_0_s1_irq_from_sa => vai_i2c_master_0_s1_irq_from_sa,
      vai_i2c_master_0_s1_readdata_from_sa => vai_i2c_master_0_s1_readdata_from_sa,
      vai_i2c_master_0_s1_waitrequest_n_from_sa => vai_i2c_master_0_s1_waitrequest_n_from_sa
    );


  --the_cpu_0_instruction_master, which is an e_instance
  the_cpu_0_instruction_master : cpu_0_instruction_master_arbitrator
    port map(
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_readdata => cpu_0_instruction_master_readdata,
      cpu_0_instruction_master_readdatavalid => cpu_0_instruction_master_readdatavalid,
      cpu_0_instruction_master_waitrequest => cpu_0_instruction_master_waitrequest,
      clk => clk_24,
      cpu_0_instruction_master_address => cpu_0_instruction_master_address,
      cpu_0_instruction_master_granted_cpu_0_jtag_debug_module => cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_granted_onchip_memory2_0_s1 => cpu_0_instruction_master_granted_onchip_memory2_0_s1,
      cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 => cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_instruction_master_requests_cpu_0_jtag_debug_module => cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_requests_onchip_memory2_0_s1 => cpu_0_instruction_master_requests_onchip_memory2_0_s1,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      reset_n => clk_24_reset_n
    );


  --the_cpu_0, which is an e_ptf_instance
  the_cpu_0 : cpu_0
    port map(
      d_address => cpu_0_data_master_address,
      d_byteenable => cpu_0_data_master_byteenable,
      d_read => cpu_0_data_master_read,
      d_write => cpu_0_data_master_write,
      d_writedata => cpu_0_data_master_writedata,
      i_address => cpu_0_instruction_master_address,
      i_read => cpu_0_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => cpu_0_data_master_debugaccess,
      jtag_debug_module_readdata => cpu_0_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => cpu_0_jtag_debug_module_resetrequest,
      clk => clk_24,
      d_irq => cpu_0_data_master_irq,
      d_readdata => cpu_0_data_master_readdata,
      d_readdatavalid => cpu_0_data_master_readdatavalid,
      d_waitrequest => cpu_0_data_master_waitrequest,
      i_readdata => cpu_0_instruction_master_readdata,
      i_readdatavalid => cpu_0_instruction_master_readdatavalid,
      i_waitrequest => cpu_0_instruction_master_waitrequest,
      jtag_debug_module_address => cpu_0_jtag_debug_module_address,
      jtag_debug_module_begintransfer => cpu_0_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => cpu_0_jtag_debug_module_byteenable,
      jtag_debug_module_debugaccess => cpu_0_jtag_debug_module_debugaccess,
      jtag_debug_module_select => cpu_0_jtag_debug_module_chipselect,
      jtag_debug_module_write => cpu_0_jtag_debug_module_write,
      jtag_debug_module_writedata => cpu_0_jtag_debug_module_writedata,
      reset_n => cpu_0_jtag_debug_module_reset_n
    );


  --the_jtag_uart_0_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_0_avalon_jtag_slave : jtag_uart_0_avalon_jtag_slave_arbitrator
    port map(
      cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave,
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer => d1_jtag_uart_0_avalon_jtag_slave_end_xfer,
      jtag_uart_0_avalon_jtag_slave_address => jtag_uart_0_avalon_jtag_slave_address,
      jtag_uart_0_avalon_jtag_slave_chipselect => jtag_uart_0_avalon_jtag_slave_chipselect,
      jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa => jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa,
      jtag_uart_0_avalon_jtag_slave_irq_from_sa => jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      jtag_uart_0_avalon_jtag_slave_read_n => jtag_uart_0_avalon_jtag_slave_read_n,
      jtag_uart_0_avalon_jtag_slave_readdata_from_sa => jtag_uart_0_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa => jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa,
      jtag_uart_0_avalon_jtag_slave_reset_n => jtag_uart_0_avalon_jtag_slave_reset_n,
      jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa,
      jtag_uart_0_avalon_jtag_slave_write_n => jtag_uart_0_avalon_jtag_slave_write_n,
      jtag_uart_0_avalon_jtag_slave_writedata => jtag_uart_0_avalon_jtag_slave_writedata,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      jtag_uart_0_avalon_jtag_slave_dataavailable => jtag_uart_0_avalon_jtag_slave_dataavailable,
      jtag_uart_0_avalon_jtag_slave_irq => jtag_uart_0_avalon_jtag_slave_irq,
      jtag_uart_0_avalon_jtag_slave_readdata => jtag_uart_0_avalon_jtag_slave_readdata,
      jtag_uart_0_avalon_jtag_slave_readyfordata => jtag_uart_0_avalon_jtag_slave_readyfordata,
      jtag_uart_0_avalon_jtag_slave_waitrequest => jtag_uart_0_avalon_jtag_slave_waitrequest,
      reset_n => clk_24_reset_n
    );


  --the_jtag_uart_0, which is an e_ptf_instance
  the_jtag_uart_0 : jtag_uart_0
    port map(
      av_irq => jtag_uart_0_avalon_jtag_slave_irq,
      av_readdata => jtag_uart_0_avalon_jtag_slave_readdata,
      av_waitrequest => jtag_uart_0_avalon_jtag_slave_waitrequest,
      dataavailable => jtag_uart_0_avalon_jtag_slave_dataavailable,
      readyfordata => jtag_uart_0_avalon_jtag_slave_readyfordata,
      av_address => jtag_uart_0_avalon_jtag_slave_address,
      av_chipselect => jtag_uart_0_avalon_jtag_slave_chipselect,
      av_read_n => jtag_uart_0_avalon_jtag_slave_read_n,
      av_write_n => jtag_uart_0_avalon_jtag_slave_write_n,
      av_writedata => jtag_uart_0_avalon_jtag_slave_writedata,
      clk => clk_24,
      rst_n => jtag_uart_0_avalon_jtag_slave_reset_n
    );


  --the_onchip_memory2_0_s1, which is an e_instance
  the_onchip_memory2_0_s1 : onchip_memory2_0_s1_arbitrator
    port map(
      cpu_0_data_master_granted_onchip_memory2_0_s1 => cpu_0_data_master_granted_onchip_memory2_0_s1,
      cpu_0_data_master_qualified_request_onchip_memory2_0_s1 => cpu_0_data_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_data_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_data_master_requests_onchip_memory2_0_s1 => cpu_0_data_master_requests_onchip_memory2_0_s1,
      cpu_0_instruction_master_granted_onchip_memory2_0_s1 => cpu_0_instruction_master_granted_onchip_memory2_0_s1,
      cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 => cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_instruction_master_requests_onchip_memory2_0_s1 => cpu_0_instruction_master_requests_onchip_memory2_0_s1,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      onchip_memory2_0_s1_address => onchip_memory2_0_s1_address,
      onchip_memory2_0_s1_byteenable => onchip_memory2_0_s1_byteenable,
      onchip_memory2_0_s1_chipselect => onchip_memory2_0_s1_chipselect,
      onchip_memory2_0_s1_clken => onchip_memory2_0_s1_clken,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      onchip_memory2_0_s1_reset => onchip_memory2_0_s1_reset,
      onchip_memory2_0_s1_write => onchip_memory2_0_s1_write,
      onchip_memory2_0_s1_writedata => onchip_memory2_0_s1_writedata,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      onchip_memory2_0_s1_readdata => onchip_memory2_0_s1_readdata,
      reset_n => clk_24_reset_n
    );


  --the_onchip_memory2_0, which is an e_ptf_instance
  the_onchip_memory2_0 : onchip_memory2_0
    port map(
      readdata => onchip_memory2_0_s1_readdata,
      address => onchip_memory2_0_s1_address,
      byteenable => onchip_memory2_0_s1_byteenable,
      chipselect => onchip_memory2_0_s1_chipselect,
      clk => clk_24,
      clken => onchip_memory2_0_s1_clken,
      reset => onchip_memory2_0_s1_reset,
      write => onchip_memory2_0_s1_write,
      writedata => onchip_memory2_0_s1_writedata
    );


  --the_pio_0_s1, which is an e_instance
  the_pio_0_s1 : pio_0_s1_arbitrator
    port map(
      cpu_0_data_master_granted_pio_0_s1 => cpu_0_data_master_granted_pio_0_s1,
      cpu_0_data_master_qualified_request_pio_0_s1 => cpu_0_data_master_qualified_request_pio_0_s1,
      cpu_0_data_master_read_data_valid_pio_0_s1 => cpu_0_data_master_read_data_valid_pio_0_s1,
      cpu_0_data_master_requests_pio_0_s1 => cpu_0_data_master_requests_pio_0_s1,
      d1_pio_0_s1_end_xfer => d1_pio_0_s1_end_xfer,
      pio_0_s1_address => pio_0_s1_address,
      pio_0_s1_chipselect => pio_0_s1_chipselect,
      pio_0_s1_irq_from_sa => pio_0_s1_irq_from_sa,
      pio_0_s1_readdata_from_sa => pio_0_s1_readdata_from_sa,
      pio_0_s1_reset_n => pio_0_s1_reset_n,
      pio_0_s1_write_n => pio_0_s1_write_n,
      pio_0_s1_writedata => pio_0_s1_writedata,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      pio_0_s1_irq => pio_0_s1_irq,
      pio_0_s1_readdata => pio_0_s1_readdata,
      reset_n => clk_24_reset_n
    );


  --the_pio_0, which is an e_ptf_instance
  the_pio_0 : pio_0
    port map(
      irq => pio_0_s1_irq,
      out_port => internal_out_port_from_the_pio_0,
      readdata => pio_0_s1_readdata,
      address => pio_0_s1_address,
      chipselect => pio_0_s1_chipselect,
      clk => clk_24,
      in_port => in_port_to_the_pio_0,
      reset_n => pio_0_s1_reset_n,
      write_n => pio_0_s1_write_n,
      writedata => pio_0_s1_writedata
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      cpu_0_data_master_granted_sysid_control_slave => cpu_0_data_master_granted_sysid_control_slave,
      cpu_0_data_master_qualified_request_sysid_control_slave => cpu_0_data_master_qualified_request_sysid_control_slave,
      cpu_0_data_master_read_data_valid_sysid_control_slave => cpu_0_data_master_read_data_valid_sysid_control_slave,
      cpu_0_data_master_requests_sysid_control_slave => cpu_0_data_master_requests_sysid_control_slave,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      sysid_control_slave_reset_n => sysid_control_slave_reset_n,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_24_reset_n,
      sysid_control_slave_readdata => sysid_control_slave_readdata
    );


  --the_sysid, which is an e_ptf_instance
  the_sysid : sysid
    port map(
      readdata => sysid_control_slave_readdata,
      address => sysid_control_slave_address,
      clock => sysid_control_slave_clock,
      reset_n => sysid_control_slave_reset_n
    );


  --the_timer_0_s1, which is an e_instance
  the_timer_0_s1 : timer_0_s1_arbitrator
    port map(
      cpu_0_data_master_granted_timer_0_s1 => cpu_0_data_master_granted_timer_0_s1,
      cpu_0_data_master_qualified_request_timer_0_s1 => cpu_0_data_master_qualified_request_timer_0_s1,
      cpu_0_data_master_read_data_valid_timer_0_s1 => cpu_0_data_master_read_data_valid_timer_0_s1,
      cpu_0_data_master_requests_timer_0_s1 => cpu_0_data_master_requests_timer_0_s1,
      d1_timer_0_s1_end_xfer => d1_timer_0_s1_end_xfer,
      timer_0_s1_address => timer_0_s1_address,
      timer_0_s1_chipselect => timer_0_s1_chipselect,
      timer_0_s1_irq_from_sa => timer_0_s1_irq_from_sa,
      timer_0_s1_readdata_from_sa => timer_0_s1_readdata_from_sa,
      timer_0_s1_reset_n => timer_0_s1_reset_n,
      timer_0_s1_write_n => timer_0_s1_write_n,
      timer_0_s1_writedata => timer_0_s1_writedata,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => clk_24_reset_n,
      timer_0_s1_irq => timer_0_s1_irq,
      timer_0_s1_readdata => timer_0_s1_readdata
    );


  --the_timer_0, which is an e_ptf_instance
  the_timer_0 : timer_0
    port map(
      irq => timer_0_s1_irq,
      readdata => timer_0_s1_readdata,
      address => timer_0_s1_address,
      chipselect => timer_0_s1_chipselect,
      clk => clk_24,
      reset_n => timer_0_s1_reset_n,
      write_n => timer_0_s1_write_n,
      writedata => timer_0_s1_writedata
    );


  --the_vai_i2c_master_0_s1, which is an e_instance
  the_vai_i2c_master_0_s1 : vai_i2c_master_0_s1_arbitrator
    port map(
      cpu_0_data_master_byteenable_vai_i2c_master_0_s1 => cpu_0_data_master_byteenable_vai_i2c_master_0_s1,
      cpu_0_data_master_granted_vai_i2c_master_0_s1 => cpu_0_data_master_granted_vai_i2c_master_0_s1,
      cpu_0_data_master_qualified_request_vai_i2c_master_0_s1 => cpu_0_data_master_qualified_request_vai_i2c_master_0_s1,
      cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1 => cpu_0_data_master_read_data_valid_vai_i2c_master_0_s1,
      cpu_0_data_master_requests_vai_i2c_master_0_s1 => cpu_0_data_master_requests_vai_i2c_master_0_s1,
      d1_vai_i2c_master_0_s1_end_xfer => d1_vai_i2c_master_0_s1_end_xfer,
      vai_i2c_master_0_s1_address => vai_i2c_master_0_s1_address,
      vai_i2c_master_0_s1_chipselect => vai_i2c_master_0_s1_chipselect,
      vai_i2c_master_0_s1_irq_from_sa => vai_i2c_master_0_s1_irq_from_sa,
      vai_i2c_master_0_s1_readdata_from_sa => vai_i2c_master_0_s1_readdata_from_sa,
      vai_i2c_master_0_s1_reset => vai_i2c_master_0_s1_reset,
      vai_i2c_master_0_s1_waitrequest_n_from_sa => vai_i2c_master_0_s1_waitrequest_n_from_sa,
      vai_i2c_master_0_s1_write => vai_i2c_master_0_s1_write,
      vai_i2c_master_0_s1_writedata => vai_i2c_master_0_s1_writedata,
      clk => clk_24,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_dbs_address => cpu_0_data_master_dbs_address,
      cpu_0_data_master_dbs_write_8 => cpu_0_data_master_dbs_write_8,
      cpu_0_data_master_latency_counter => cpu_0_data_master_latency_counter,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_24_reset_n,
      vai_i2c_master_0_s1_irq => vai_i2c_master_0_s1_irq,
      vai_i2c_master_0_s1_readdata => vai_i2c_master_0_s1_readdata,
      vai_i2c_master_0_s1_waitrequest_n => vai_i2c_master_0_s1_waitrequest_n
    );


  --the_vai_i2c_master_0, which is an e_ptf_instance
  the_vai_i2c_master_0 : vai_i2c_master_0
    port map(
      avs_s1_readdata => vai_i2c_master_0_s1_readdata,
      avs_s1_waitrequest_n => vai_i2c_master_0_s1_waitrequest_n,
      coe_i2c_scl_pad_o => internal_coe_i2c_scl_pad_o_from_the_vai_i2c_master_0,
      coe_i2c_scl_padoen_o => internal_coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0,
      coe_i2c_sda_pad_o => internal_coe_i2c_sda_pad_o_from_the_vai_i2c_master_0,
      coe_i2c_sda_padoen_o => internal_coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0,
      ins_irq1_irq => vai_i2c_master_0_s1_irq,
      avs_s1_address => vai_i2c_master_0_s1_address,
      avs_s1_chipselect => vai_i2c_master_0_s1_chipselect,
      avs_s1_write => vai_i2c_master_0_s1_write,
      avs_s1_writedata => vai_i2c_master_0_s1_writedata,
      coe_arst_arst_i => coe_arst_arst_i_to_the_vai_i2c_master_0,
      coe_i2c_scl_pad_i => coe_i2c_scl_pad_i_to_the_vai_i2c_master_0,
      coe_i2c_sda_pad_i => coe_i2c_sda_pad_i_to_the_vai_i2c_master_0,
      csi_clockreset_clk => clk_24,
      csi_clockreset_reset => vai_i2c_master_0_s1_reset
    );


  --reset is asserted asynchronously and deasserted synchronously
  ep4c_nios_system_reset_clk_24_domain_synch : ep4c_nios_system_reset_clk_24_domain_synch_module
    port map(
      data_out => clk_24_reset_n,
      clk => clk_24,
      data_in => module_input,
      reset_n => reset_n_sources
    );

  module_input <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_resetrequest_from_sa))))));
  --sysid_control_slave_clock of type clock does not connect to anything so wire it to default (0)
  sysid_control_slave_clock <= std_logic'('0');
  --vhdl renameroo for output signals
  coe_i2c_scl_pad_o_from_the_vai_i2c_master_0 <= internal_coe_i2c_scl_pad_o_from_the_vai_i2c_master_0;
  --vhdl renameroo for output signals
  coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0 <= internal_coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0;
  --vhdl renameroo for output signals
  coe_i2c_sda_pad_o_from_the_vai_i2c_master_0 <= internal_coe_i2c_sda_pad_o_from_the_vai_i2c_master_0;
  --vhdl renameroo for output signals
  coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0 <= internal_coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0;
  --vhdl renameroo for output signals
  out_port_from_the_pio_0 <= internal_out_port_from_the_pio_0;

end europa;


--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is
component ep4c_nios_system is 
           port (
                 -- 1) global signals:
                    signal clk_24 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_pio_0
                    signal in_port_to_the_pio_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal out_port_from_the_pio_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_vai_i2c_master_0
                    signal coe_arst_arst_i_to_the_vai_i2c_master_0 : IN STD_LOGIC;
                    signal coe_i2c_scl_pad_i_to_the_vai_i2c_master_0 : IN STD_LOGIC;
                    signal coe_i2c_scl_pad_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC;
                    signal coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC;
                    signal coe_i2c_sda_pad_i_to_the_vai_i2c_master_0 : IN STD_LOGIC;
                    signal coe_i2c_sda_pad_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC;
                    signal coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0 : OUT STD_LOGIC
                 );
end component ep4c_nios_system;

                signal clk :  STD_LOGIC;
                signal clk_24 :  STD_LOGIC;
                signal coe_arst_arst_i_to_the_vai_i2c_master_0 :  STD_LOGIC;
                signal coe_i2c_scl_pad_i_to_the_vai_i2c_master_0 :  STD_LOGIC;
                signal coe_i2c_scl_pad_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal coe_i2c_sda_pad_i_to_the_vai_i2c_master_0 :  STD_LOGIC;
                signal coe_i2c_sda_pad_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0 :  STD_LOGIC;
                signal in_port_to_the_pio_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal out_port_from_the_pio_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal reset_n :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : ep4c_nios_system
    port map(
      coe_i2c_scl_pad_o_from_the_vai_i2c_master_0 => coe_i2c_scl_pad_o_from_the_vai_i2c_master_0,
      coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0 => coe_i2c_scl_padoen_o_from_the_vai_i2c_master_0,
      coe_i2c_sda_pad_o_from_the_vai_i2c_master_0 => coe_i2c_sda_pad_o_from_the_vai_i2c_master_0,
      coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0 => coe_i2c_sda_padoen_o_from_the_vai_i2c_master_0,
      out_port_from_the_pio_0 => out_port_from_the_pio_0,
      clk_24 => clk_24,
      coe_arst_arst_i_to_the_vai_i2c_master_0 => coe_arst_arst_i_to_the_vai_i2c_master_0,
      coe_i2c_scl_pad_i_to_the_vai_i2c_master_0 => coe_i2c_scl_pad_i_to_the_vai_i2c_master_0,
      coe_i2c_sda_pad_i_to_the_vai_i2c_master_0 => coe_i2c_sda_pad_i_to_the_vai_i2c_master_0,
      in_port_to_the_pio_0 => in_port_to_the_pio_0,
      reset_n => reset_n
    );


  process
  begin
    clk_24 <= '0';
    loop
       wait for 21 ns;
       clk_24 <= not clk_24;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 420 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
