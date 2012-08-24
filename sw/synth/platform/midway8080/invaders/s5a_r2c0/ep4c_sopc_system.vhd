--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


--Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
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

entity rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1_module;


architecture europa of rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
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

entity rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1_module;


architecture europa of rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
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

library std;
use std.textio.all;

entity altmemddr_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal altmemddr_0_s1_readdata : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal altmemddr_0_s1_readdatavalid : IN STD_LOGIC;
                 signal altmemddr_0_s1_resetrequest_n : IN STD_LOGIC;
                 signal altmemddr_0_s1_waitrequest_n : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal altmemddr_0_s1_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal altmemddr_0_s1_beginbursttransfer : OUT STD_LOGIC;
                 signal altmemddr_0_s1_burstcount : OUT STD_LOGIC;
                 signal altmemddr_0_s1_byteenable : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal altmemddr_0_s1_read : OUT STD_LOGIC;
                 signal altmemddr_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal altmemddr_0_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                 signal altmemddr_0_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal altmemddr_0_s1_write : OUT STD_LOGIC;
                 signal altmemddr_0_s1_writedata : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal cpu_0_data_master_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_requests_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal d1_altmemddr_0_s1_end_xfer : OUT STD_LOGIC
              );
end entity altmemddr_0_s1_arbitrator;


architecture europa of altmemddr_0_s1_arbitrator is
component rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1_module;

component rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1_module;

                signal altmemddr_0_s1_allgrants :  STD_LOGIC;
                signal altmemddr_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal altmemddr_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal altmemddr_0_s1_any_continuerequest :  STD_LOGIC;
                signal altmemddr_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_arb_counter_enable :  STD_LOGIC;
                signal altmemddr_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal altmemddr_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal altmemddr_0_s1_begins_xfer :  STD_LOGIC;
                signal altmemddr_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal altmemddr_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_end_xfer :  STD_LOGIC;
                signal altmemddr_0_s1_firsttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal altmemddr_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal altmemddr_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal altmemddr_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal altmemddr_0_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal altmemddr_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal altmemddr_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal altmemddr_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_waits_for_read :  STD_LOGIC;
                signal altmemddr_0_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_altmemddr_0_s1 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_rdv_fifo_empty_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_rdv_fifo_output_from_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_writedata_replicated :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal cpu_0_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_0_instruction_master_rdv_fifo_empty_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_rdv_fifo_output_from_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_saved_grant_altmemddr_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_altmemddr_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_altmemddr_0_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_data_master_granted_slave_altmemddr_0_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_instruction_master_granted_slave_altmemddr_0_s1 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
                signal shifted_address_to_altmemddr_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal shifted_address_to_altmemddr_0_s1_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_altmemddr_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT altmemddr_0_s1_end_xfer;
    end if;

  end process;

  altmemddr_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_0_data_master_qualified_request_altmemddr_0_s1 OR internal_cpu_0_instruction_master_qualified_request_altmemddr_0_s1));
  --assign altmemddr_0_s1_readdata_from_sa = altmemddr_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  altmemddr_0_s1_readdata_from_sa <= altmemddr_0_s1_readdata;
  internal_cpu_0_data_master_requests_altmemddr_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 26) & std_logic_vector'("00000000000000000000000000")) = std_logic_vector'("1000000000000000000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign altmemddr_0_s1_waitrequest_n_from_sa = altmemddr_0_s1_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_altmemddr_0_s1_waitrequest_n_from_sa <= altmemddr_0_s1_waitrequest_n;
  --assign altmemddr_0_s1_readdatavalid_from_sa = altmemddr_0_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  altmemddr_0_s1_readdatavalid_from_sa <= altmemddr_0_s1_readdatavalid;
  --altmemddr_0_s1_arb_share_counter set values, which is an e_mux
  altmemddr_0_s1_arb_share_set_values <= std_logic_vector'("001");
  --altmemddr_0_s1_non_bursting_master_requests mux, which is an e_mux
  altmemddr_0_s1_non_bursting_master_requests <= ((internal_cpu_0_data_master_requests_altmemddr_0_s1 OR internal_cpu_0_instruction_master_requests_altmemddr_0_s1) OR internal_cpu_0_data_master_requests_altmemddr_0_s1) OR internal_cpu_0_instruction_master_requests_altmemddr_0_s1;
  --altmemddr_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  altmemddr_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --altmemddr_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  altmemddr_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(altmemddr_0_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (altmemddr_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(altmemddr_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (altmemddr_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --altmemddr_0_s1_allgrants all slave grants, which is an e_mux
  altmemddr_0_s1_allgrants <= (((or_reduce(altmemddr_0_s1_grant_vector)) OR (or_reduce(altmemddr_0_s1_grant_vector))) OR (or_reduce(altmemddr_0_s1_grant_vector))) OR (or_reduce(altmemddr_0_s1_grant_vector));
  --altmemddr_0_s1_end_xfer assignment, which is an e_assign
  altmemddr_0_s1_end_xfer <= NOT ((altmemddr_0_s1_waits_for_read OR altmemddr_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_altmemddr_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_altmemddr_0_s1 <= altmemddr_0_s1_end_xfer AND (((NOT altmemddr_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --altmemddr_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  altmemddr_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_altmemddr_0_s1 AND altmemddr_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_altmemddr_0_s1 AND NOT altmemddr_0_s1_non_bursting_master_requests));
  --altmemddr_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(altmemddr_0_s1_arb_counter_enable) = '1' then 
        altmemddr_0_s1_arb_share_counter <= altmemddr_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --altmemddr_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(altmemddr_0_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_altmemddr_0_s1)) OR ((end_xfer_arb_share_counter_term_altmemddr_0_s1 AND NOT altmemddr_0_s1_non_bursting_master_requests)))) = '1' then 
        altmemddr_0_s1_slavearbiterlockenable <= or_reduce(altmemddr_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master altmemddr_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= altmemddr_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --altmemddr_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  altmemddr_0_s1_slavearbiterlockenable2 <= or_reduce(altmemddr_0_s1_arb_share_counter_next_value);
  --cpu_0/data_master altmemddr_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= altmemddr_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --cpu_0/instruction_master altmemddr_0/s1 arbiterlock, which is an e_assign
  cpu_0_instruction_master_arbiterlock <= altmemddr_0_s1_slavearbiterlockenable AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master altmemddr_0/s1 arbiterlock2, which is an e_assign
  cpu_0_instruction_master_arbiterlock2 <= altmemddr_0_s1_slavearbiterlockenable2 AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master granted altmemddr_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_instruction_master_granted_slave_altmemddr_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_instruction_master_granted_slave_altmemddr_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_instruction_master_saved_grant_altmemddr_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((altmemddr_0_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_instruction_master_requests_altmemddr_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_instruction_master_granted_slave_altmemddr_0_s1))))));
    end if;

  end process;

  --cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  cpu_0_instruction_master_continuerequest <= last_cycle_cpu_0_instruction_master_granted_slave_altmemddr_0_s1 AND internal_cpu_0_instruction_master_requests_altmemddr_0_s1;
  --altmemddr_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  altmemddr_0_s1_any_continuerequest <= cpu_0_instruction_master_continuerequest OR cpu_0_data_master_continuerequest;
  internal_cpu_0_data_master_qualified_request_altmemddr_0_s1 <= internal_cpu_0_data_master_requests_altmemddr_0_s1 AND NOT (((((cpu_0_data_master_read AND ((NOT cpu_0_data_master_waitrequest OR (internal_cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register))))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))) OR cpu_0_instruction_master_arbiterlock));
  --unique name for altmemddr_0_s1_move_on_to_next_transaction, which is an e_assign
  altmemddr_0_s1_move_on_to_next_transaction <= altmemddr_0_s1_readdatavalid_from_sa;
  --rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1 : rdv_fifo_for_cpu_0_data_master_to_altmemddr_0_s1_module
    port map(
      data_out => cpu_0_data_master_rdv_fifo_output_from_altmemddr_0_s1,
      empty => open,
      fifo_contains_ones_n => cpu_0_data_master_rdv_fifo_empty_altmemddr_0_s1,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => internal_cpu_0_data_master_granted_altmemddr_0_s1,
      read => altmemddr_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read;

  internal_cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register <= NOT cpu_0_data_master_rdv_fifo_empty_altmemddr_0_s1;
  --local readdatavalid cpu_0_data_master_read_data_valid_altmemddr_0_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_altmemddr_0_s1 <= ((altmemddr_0_s1_readdatavalid_from_sa AND cpu_0_data_master_rdv_fifo_output_from_altmemddr_0_s1)) AND NOT cpu_0_data_master_rdv_fifo_empty_altmemddr_0_s1;
  --replicate narrow data for wide slave
  cpu_0_data_master_writedata_replicated <= cpu_0_data_master_writedata & cpu_0_data_master_writedata;
  --altmemddr_0_s1_writedata mux, which is an e_mux
  altmemddr_0_s1_writedata <= cpu_0_data_master_writedata_replicated;
  internal_cpu_0_instruction_master_requests_altmemddr_0_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_instruction_master_address_to_slave(30 DOWNTO 26) & std_logic_vector'("00000000000000000000000000")) = std_logic_vector'("1000000000000000000000000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
  --cpu_0/data_master granted altmemddr_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_data_master_granted_slave_altmemddr_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_data_master_granted_slave_altmemddr_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_data_master_saved_grant_altmemddr_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((altmemddr_0_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_data_master_requests_altmemddr_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_data_master_granted_slave_altmemddr_0_s1))))));
    end if;

  end process;

  --cpu_0_data_master_continuerequest continued request, which is an e_mux
  cpu_0_data_master_continuerequest <= last_cycle_cpu_0_data_master_granted_slave_altmemddr_0_s1 AND internal_cpu_0_data_master_requests_altmemddr_0_s1;
  internal_cpu_0_instruction_master_qualified_request_altmemddr_0_s1 <= internal_cpu_0_instruction_master_requests_altmemddr_0_s1 AND NOT ((((cpu_0_instruction_master_read AND to_std_logic((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))) OR ((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_latency_counter)))))))))) OR cpu_0_data_master_arbiterlock));
  --rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1 : rdv_fifo_for_cpu_0_instruction_master_to_altmemddr_0_s1_module
    port map(
      data_out => cpu_0_instruction_master_rdv_fifo_output_from_altmemddr_0_s1,
      empty => open,
      fifo_contains_ones_n => cpu_0_instruction_master_rdv_fifo_empty_altmemddr_0_s1,
      full => open,
      clear_fifo => module_input3,
      clk => clk,
      data_in => internal_cpu_0_instruction_master_granted_altmemddr_0_s1,
      read => altmemddr_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input4,
      write => module_input5
    );

  module_input3 <= std_logic'('0');
  module_input4 <= std_logic'('0');
  module_input5 <= in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read;

  cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register <= NOT cpu_0_instruction_master_rdv_fifo_empty_altmemddr_0_s1;
  --local readdatavalid cpu_0_instruction_master_read_data_valid_altmemddr_0_s1, which is an e_mux
  cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 <= ((altmemddr_0_s1_readdatavalid_from_sa AND cpu_0_instruction_master_rdv_fifo_output_from_altmemddr_0_s1)) AND NOT cpu_0_instruction_master_rdv_fifo_empty_altmemddr_0_s1;
  --allow new arb cycle for altmemddr_0/s1, which is an e_assign
  altmemddr_0_s1_allow_new_arb_cycle <= NOT cpu_0_data_master_arbiterlock AND NOT cpu_0_instruction_master_arbiterlock;
  --cpu_0/instruction_master assignment into master qualified-requests vector for altmemddr_0/s1, which is an e_assign
  altmemddr_0_s1_master_qreq_vector(0) <= internal_cpu_0_instruction_master_qualified_request_altmemddr_0_s1;
  --cpu_0/instruction_master grant altmemddr_0/s1, which is an e_assign
  internal_cpu_0_instruction_master_granted_altmemddr_0_s1 <= altmemddr_0_s1_grant_vector(0);
  --cpu_0/instruction_master saved-grant altmemddr_0/s1, which is an e_assign
  cpu_0_instruction_master_saved_grant_altmemddr_0_s1 <= altmemddr_0_s1_arb_winner(0) AND internal_cpu_0_instruction_master_requests_altmemddr_0_s1;
  --cpu_0/data_master assignment into master qualified-requests vector for altmemddr_0/s1, which is an e_assign
  altmemddr_0_s1_master_qreq_vector(1) <= internal_cpu_0_data_master_qualified_request_altmemddr_0_s1;
  --cpu_0/data_master grant altmemddr_0/s1, which is an e_assign
  internal_cpu_0_data_master_granted_altmemddr_0_s1 <= altmemddr_0_s1_grant_vector(1);
  --cpu_0/data_master saved-grant altmemddr_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_altmemddr_0_s1 <= altmemddr_0_s1_arb_winner(1) AND internal_cpu_0_data_master_requests_altmemddr_0_s1;
  --altmemddr_0/s1 chosen-master double-vector, which is an e_assign
  altmemddr_0_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((altmemddr_0_s1_master_qreq_vector & altmemddr_0_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT altmemddr_0_s1_master_qreq_vector & NOT altmemddr_0_s1_master_qreq_vector))) + (std_logic_vector'("000") & (altmemddr_0_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  altmemddr_0_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((altmemddr_0_s1_allow_new_arb_cycle AND or_reduce(altmemddr_0_s1_grant_vector)))) = '1'), altmemddr_0_s1_grant_vector, altmemddr_0_s1_saved_chosen_master_vector);
  --saved altmemddr_0_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(altmemddr_0_s1_allow_new_arb_cycle) = '1' then 
        altmemddr_0_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(altmemddr_0_s1_grant_vector)) = '1'), altmemddr_0_s1_grant_vector, altmemddr_0_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  altmemddr_0_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((altmemddr_0_s1_chosen_master_double_vector(1) OR altmemddr_0_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((altmemddr_0_s1_chosen_master_double_vector(0) OR altmemddr_0_s1_chosen_master_double_vector(2)))));
  --altmemddr_0/s1 chosen master rotated left, which is an e_assign
  altmemddr_0_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(altmemddr_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(altmemddr_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --altmemddr_0/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(altmemddr_0_s1_grant_vector)) = '1' then 
        altmemddr_0_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(altmemddr_0_s1_end_xfer) = '1'), altmemddr_0_s1_chosen_master_rot_left, altmemddr_0_s1_grant_vector);
      end if;
    end if;

  end process;

  --assign altmemddr_0_s1_resetrequest_n_from_sa = altmemddr_0_s1_resetrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  altmemddr_0_s1_resetrequest_n_from_sa <= altmemddr_0_s1_resetrequest_n;
  --altmemddr_0_s1_firsttransfer first transaction, which is an e_assign
  altmemddr_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(altmemddr_0_s1_begins_xfer) = '1'), altmemddr_0_s1_unreg_firsttransfer, altmemddr_0_s1_reg_firsttransfer);
  --altmemddr_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  altmemddr_0_s1_unreg_firsttransfer <= NOT ((altmemddr_0_s1_slavearbiterlockenable AND altmemddr_0_s1_any_continuerequest));
  --altmemddr_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(altmemddr_0_s1_begins_xfer) = '1' then 
        altmemddr_0_s1_reg_firsttransfer <= altmemddr_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --altmemddr_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  altmemddr_0_s1_beginbursttransfer_internal <= altmemddr_0_s1_begins_xfer;
  --altmemddr_0/s1 begin burst transfer to slave, which is an e_assign
  altmemddr_0_s1_beginbursttransfer <= altmemddr_0_s1_beginbursttransfer_internal;
  --altmemddr_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  altmemddr_0_s1_arbitration_holdoff_internal <= altmemddr_0_s1_begins_xfer AND altmemddr_0_s1_firsttransfer;
  --altmemddr_0_s1_read assignment, which is an e_mux
  altmemddr_0_s1_read <= ((internal_cpu_0_data_master_granted_altmemddr_0_s1 AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_altmemddr_0_s1 AND cpu_0_instruction_master_read));
  --altmemddr_0_s1_write assignment, which is an e_mux
  altmemddr_0_s1_write <= internal_cpu_0_data_master_granted_altmemddr_0_s1 AND cpu_0_data_master_write;
  shifted_address_to_altmemddr_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --altmemddr_0_s1_address mux, which is an e_mux
  altmemddr_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_altmemddr_0_s1)) = '1'), (A_SRL(shifted_address_to_altmemddr_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000011"))), (A_SRL(shifted_address_to_altmemddr_0_s1_from_cpu_0_instruction_master,std_logic_vector'("00000000000000000000000000000011")))), 23);
  shifted_address_to_altmemddr_0_s1_from_cpu_0_instruction_master <= cpu_0_instruction_master_address_to_slave;
  --d1_altmemddr_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_altmemddr_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_altmemddr_0_s1_end_xfer <= altmemddr_0_s1_end_xfer;
    end if;

  end process;

  --altmemddr_0_s1_waits_for_read in a cycle, which is an e_mux
  altmemddr_0_s1_waits_for_read <= altmemddr_0_s1_in_a_read_cycle AND NOT internal_altmemddr_0_s1_waitrequest_n_from_sa;
  --altmemddr_0_s1_in_a_read_cycle assignment, which is an e_assign
  altmemddr_0_s1_in_a_read_cycle <= ((internal_cpu_0_data_master_granted_altmemddr_0_s1 AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_altmemddr_0_s1 AND cpu_0_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= altmemddr_0_s1_in_a_read_cycle;
  --altmemddr_0_s1_waits_for_write in a cycle, which is an e_mux
  altmemddr_0_s1_waits_for_write <= altmemddr_0_s1_in_a_write_cycle AND NOT internal_altmemddr_0_s1_waitrequest_n_from_sa;
  --altmemddr_0_s1_in_a_write_cycle assignment, which is an e_assign
  altmemddr_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_altmemddr_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= altmemddr_0_s1_in_a_write_cycle;
  wait_for_altmemddr_0_s1_counter <= std_logic'('0');
  --altmemddr_0_s1_byteenable byte enable port mux, which is an e_mux
  altmemddr_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("000000000000000000000000") & (cpu_0_data_master_byteenable_altmemddr_0_s1)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 8);
  --byte_enable_mux for cpu_0/data_master and altmemddr_0/s1, which is an e_mux
  cpu_0_data_master_byteenable_altmemddr_0_s1 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_address_to_slave(2)))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000") & (cpu_0_data_master_byteenable)), (cpu_0_data_master_byteenable & std_logic_vector'("0000")));
  --burstcount mux, which is an e_mux
  altmemddr_0_s1_burstcount <= std_logic'('1');
  --vhdl renameroo for output signals
  altmemddr_0_s1_waitrequest_n_from_sa <= internal_altmemddr_0_s1_waitrequest_n_from_sa;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_altmemddr_0_s1 <= internal_cpu_0_data_master_granted_altmemddr_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_altmemddr_0_s1 <= internal_cpu_0_data_master_qualified_request_altmemddr_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register <= internal_cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_altmemddr_0_s1 <= internal_cpu_0_data_master_requests_altmemddr_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_granted_altmemddr_0_s1 <= internal_cpu_0_instruction_master_granted_altmemddr_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_qualified_request_altmemddr_0_s1 <= internal_cpu_0_instruction_master_qualified_request_altmemddr_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_requests_altmemddr_0_s1 <= internal_cpu_0_instruction_master_requests_altmemddr_0_s1;
--synthesis translate_off
    --altmemddr_0/s1 enable non-zero assertions, which is an e_register
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
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_altmemddr_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_altmemddr_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
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
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_altmemddr_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_altmemddr_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
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

entity ep4c_sopc_system_reset_clk_24M_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ep4c_sopc_system_reset_clk_24M_domain_synch_module;


architecture europa of ep4c_sopc_system_reset_clk_24M_domain_synch_module is
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

entity audio_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal audio_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal audio_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal audio_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal audio_pio_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_audio_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_audio_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_audio_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_audio_pio_s1 : OUT STD_LOGIC;
                 signal d1_audio_pio_s1_end_xfer : OUT STD_LOGIC
              );
end entity audio_pio_s1_arbitrator;


architecture europa of audio_pio_s1_arbitrator is
                signal audio_pio_s1_allgrants :  STD_LOGIC;
                signal audio_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal audio_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal audio_pio_s1_any_continuerequest :  STD_LOGIC;
                signal audio_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal audio_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal audio_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal audio_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal audio_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal audio_pio_s1_begins_xfer :  STD_LOGIC;
                signal audio_pio_s1_end_xfer :  STD_LOGIC;
                signal audio_pio_s1_firsttransfer :  STD_LOGIC;
                signal audio_pio_s1_grant_vector :  STD_LOGIC;
                signal audio_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal audio_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal audio_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal audio_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal audio_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal audio_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal audio_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal audio_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal audio_pio_s1_waits_for_read :  STD_LOGIC;
                signal audio_pio_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_audio_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_audio_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_audio_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_audio_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_audio_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_audio_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_audio_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT audio_pio_s1_end_xfer;
    end if;

  end process;

  audio_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_audio_pio_s1);
  --assign audio_pio_s1_readdata_from_sa = audio_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  audio_pio_s1_readdata_from_sa <= audio_pio_s1_readdata;
  internal_cpu_0_data_master_requests_audio_pio_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000000011000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --audio_pio_s1_arb_share_counter set values, which is an e_mux
  audio_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --audio_pio_s1_non_bursting_master_requests mux, which is an e_mux
  audio_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_audio_pio_s1;
  --audio_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  audio_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --audio_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  audio_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(audio_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (audio_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(audio_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (audio_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --audio_pio_s1_allgrants all slave grants, which is an e_mux
  audio_pio_s1_allgrants <= audio_pio_s1_grant_vector;
  --audio_pio_s1_end_xfer assignment, which is an e_assign
  audio_pio_s1_end_xfer <= NOT ((audio_pio_s1_waits_for_read OR audio_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_audio_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_audio_pio_s1 <= audio_pio_s1_end_xfer AND (((NOT audio_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --audio_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  audio_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_audio_pio_s1 AND audio_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_audio_pio_s1 AND NOT audio_pio_s1_non_bursting_master_requests));
  --audio_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      audio_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(audio_pio_s1_arb_counter_enable) = '1' then 
        audio_pio_s1_arb_share_counter <= audio_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --audio_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      audio_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((audio_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_audio_pio_s1)) OR ((end_xfer_arb_share_counter_term_audio_pio_s1 AND NOT audio_pio_s1_non_bursting_master_requests)))) = '1' then 
        audio_pio_s1_slavearbiterlockenable <= or_reduce(audio_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master audio_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= audio_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --audio_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  audio_pio_s1_slavearbiterlockenable2 <= or_reduce(audio_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master audio_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= audio_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --audio_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  audio_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_audio_pio_s1 <= internal_cpu_0_data_master_requests_audio_pio_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_audio_pio_s1 <= internal_cpu_0_data_master_qualified_request_audio_pio_s1;
  --cpu_0/data_master saved-grant audio_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_audio_pio_s1 <= internal_cpu_0_data_master_requests_audio_pio_s1;
  --allow new arb cycle for audio_pio/s1, which is an e_assign
  audio_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  audio_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  audio_pio_s1_master_qreq_vector <= std_logic'('1');
  --audio_pio_s1_reset_n assignment, which is an e_assign
  audio_pio_s1_reset_n <= reset_n;
  --audio_pio_s1_firsttransfer first transaction, which is an e_assign
  audio_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(audio_pio_s1_begins_xfer) = '1'), audio_pio_s1_unreg_firsttransfer, audio_pio_s1_reg_firsttransfer);
  --audio_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  audio_pio_s1_unreg_firsttransfer <= NOT ((audio_pio_s1_slavearbiterlockenable AND audio_pio_s1_any_continuerequest));
  --audio_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      audio_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(audio_pio_s1_begins_xfer) = '1' then 
        audio_pio_s1_reg_firsttransfer <= audio_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --audio_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  audio_pio_s1_beginbursttransfer_internal <= audio_pio_s1_begins_xfer;
  shifted_address_to_audio_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --audio_pio_s1_address mux, which is an e_mux
  audio_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_audio_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_audio_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_audio_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_audio_pio_s1_end_xfer <= audio_pio_s1_end_xfer;
    end if;

  end process;

  --audio_pio_s1_waits_for_read in a cycle, which is an e_mux
  audio_pio_s1_waits_for_read <= audio_pio_s1_in_a_read_cycle AND audio_pio_s1_begins_xfer;
  --audio_pio_s1_in_a_read_cycle assignment, which is an e_assign
  audio_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_audio_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= audio_pio_s1_in_a_read_cycle;
  --audio_pio_s1_waits_for_write in a cycle, which is an e_mux
  audio_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(audio_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --audio_pio_s1_in_a_write_cycle assignment, which is an e_assign
  audio_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_audio_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= audio_pio_s1_in_a_write_cycle;
  wait_for_audio_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_audio_pio_s1 <= internal_cpu_0_data_master_granted_audio_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_audio_pio_s1 <= internal_cpu_0_data_master_qualified_request_audio_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_audio_pio_s1 <= internal_cpu_0_data_master_requests_audio_pio_s1;
--synthesis translate_off
    --audio_pio/s1 enable non-zero assertions, which is an e_register
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

entity bootloader_s1_arbitrator is 
        port (
              -- inputs:
                 signal bootloader_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal bootloader_s1_address : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
                 signal bootloader_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal bootloader_s1_chipselect : OUT STD_LOGIC;
                 signal bootloader_s1_clken : OUT STD_LOGIC;
                 signal bootloader_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal bootloader_s1_reset : OUT STD_LOGIC;
                 signal bootloader_s1_write : OUT STD_LOGIC;
                 signal bootloader_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_granted_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_granted_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_bootloader_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_requests_bootloader_s1 : OUT STD_LOGIC;
                 signal d1_bootloader_s1_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_0_data_master_read_data_valid_bootloader_s1 : OUT STD_LOGIC
              );
end entity bootloader_s1_arbitrator;


architecture europa of bootloader_s1_arbitrator is
                signal bootloader_s1_allgrants :  STD_LOGIC;
                signal bootloader_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal bootloader_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal bootloader_s1_any_continuerequest :  STD_LOGIC;
                signal bootloader_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal bootloader_s1_arb_counter_enable :  STD_LOGIC;
                signal bootloader_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal bootloader_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal bootloader_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal bootloader_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal bootloader_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal bootloader_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal bootloader_s1_begins_xfer :  STD_LOGIC;
                signal bootloader_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal bootloader_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal bootloader_s1_end_xfer :  STD_LOGIC;
                signal bootloader_s1_firsttransfer :  STD_LOGIC;
                signal bootloader_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal bootloader_s1_in_a_read_cycle :  STD_LOGIC;
                signal bootloader_s1_in_a_write_cycle :  STD_LOGIC;
                signal bootloader_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal bootloader_s1_non_bursting_master_requests :  STD_LOGIC;
                signal bootloader_s1_reg_firsttransfer :  STD_LOGIC;
                signal bootloader_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal bootloader_s1_slavearbiterlockenable :  STD_LOGIC;
                signal bootloader_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal bootloader_s1_unreg_firsttransfer :  STD_LOGIC;
                signal bootloader_s1_waits_for_read :  STD_LOGIC;
                signal bootloader_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_bootloader_s1_shift_register :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_bootloader_s1_shift_register_in :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register_in :  STD_LOGIC;
                signal cpu_0_instruction_master_saved_grant_bootloader_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_bootloader_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_bootloader_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_bootloader_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_bootloader_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_granted_bootloader_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_qualified_request_bootloader_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_requests_bootloader_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_data_master_granted_slave_bootloader_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_instruction_master_granted_slave_bootloader_s1 :  STD_LOGIC;
                signal p1_cpu_0_data_master_read_data_valid_bootloader_s1_shift_register :  STD_LOGIC;
                signal p1_cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_bootloader_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal shifted_address_to_bootloader_s1_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_bootloader_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT bootloader_s1_end_xfer;
    end if;

  end process;

  bootloader_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_0_data_master_qualified_request_bootloader_s1 OR internal_cpu_0_instruction_master_qualified_request_bootloader_s1));
  --assign bootloader_s1_readdata_from_sa = bootloader_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  bootloader_s1_readdata_from_sa <= bootloader_s1_readdata;
  internal_cpu_0_data_master_requests_bootloader_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 13) & std_logic_vector'("0000000000000")) = std_logic_vector'("0100000000000000000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --registered rdv signal_name registered_cpu_0_data_master_read_data_valid_bootloader_s1 assignment, which is an e_assign
  registered_cpu_0_data_master_read_data_valid_bootloader_s1 <= cpu_0_data_master_read_data_valid_bootloader_s1_shift_register_in;
  --bootloader_s1_arb_share_counter set values, which is an e_mux
  bootloader_s1_arb_share_set_values <= std_logic_vector'("001");
  --bootloader_s1_non_bursting_master_requests mux, which is an e_mux
  bootloader_s1_non_bursting_master_requests <= ((internal_cpu_0_data_master_requests_bootloader_s1 OR internal_cpu_0_instruction_master_requests_bootloader_s1) OR internal_cpu_0_data_master_requests_bootloader_s1) OR internal_cpu_0_instruction_master_requests_bootloader_s1;
  --bootloader_s1_any_bursting_master_saved_grant mux, which is an e_mux
  bootloader_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --bootloader_s1_arb_share_counter_next_value assignment, which is an e_assign
  bootloader_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(bootloader_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (bootloader_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(bootloader_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (bootloader_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --bootloader_s1_allgrants all slave grants, which is an e_mux
  bootloader_s1_allgrants <= (((or_reduce(bootloader_s1_grant_vector)) OR (or_reduce(bootloader_s1_grant_vector))) OR (or_reduce(bootloader_s1_grant_vector))) OR (or_reduce(bootloader_s1_grant_vector));
  --bootloader_s1_end_xfer assignment, which is an e_assign
  bootloader_s1_end_xfer <= NOT ((bootloader_s1_waits_for_read OR bootloader_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_bootloader_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_bootloader_s1 <= bootloader_s1_end_xfer AND (((NOT bootloader_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --bootloader_s1_arb_share_counter arbitration counter enable, which is an e_assign
  bootloader_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_bootloader_s1 AND bootloader_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_bootloader_s1 AND NOT bootloader_s1_non_bursting_master_requests));
  --bootloader_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      bootloader_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(bootloader_s1_arb_counter_enable) = '1' then 
        bootloader_s1_arb_share_counter <= bootloader_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --bootloader_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      bootloader_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(bootloader_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_bootloader_s1)) OR ((end_xfer_arb_share_counter_term_bootloader_s1 AND NOT bootloader_s1_non_bursting_master_requests)))) = '1' then 
        bootloader_s1_slavearbiterlockenable <= or_reduce(bootloader_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master bootloader/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= bootloader_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --bootloader_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  bootloader_s1_slavearbiterlockenable2 <= or_reduce(bootloader_s1_arb_share_counter_next_value);
  --cpu_0/data_master bootloader/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= bootloader_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --cpu_0/instruction_master bootloader/s1 arbiterlock, which is an e_assign
  cpu_0_instruction_master_arbiterlock <= bootloader_s1_slavearbiterlockenable AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master bootloader/s1 arbiterlock2, which is an e_assign
  cpu_0_instruction_master_arbiterlock2 <= bootloader_s1_slavearbiterlockenable2 AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master granted bootloader/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_instruction_master_granted_slave_bootloader_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_instruction_master_granted_slave_bootloader_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_instruction_master_saved_grant_bootloader_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((bootloader_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_instruction_master_requests_bootloader_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_instruction_master_granted_slave_bootloader_s1))))));
    end if;

  end process;

  --cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  cpu_0_instruction_master_continuerequest <= last_cycle_cpu_0_instruction_master_granted_slave_bootloader_s1 AND internal_cpu_0_instruction_master_requests_bootloader_s1;
  --bootloader_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  bootloader_s1_any_continuerequest <= cpu_0_instruction_master_continuerequest OR cpu_0_data_master_continuerequest;
  internal_cpu_0_data_master_qualified_request_bootloader_s1 <= internal_cpu_0_data_master_requests_bootloader_s1 AND NOT (((((cpu_0_data_master_read AND (cpu_0_data_master_read_data_valid_bootloader_s1_shift_register))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))) OR cpu_0_instruction_master_arbiterlock));
  --cpu_0_data_master_read_data_valid_bootloader_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_0_data_master_read_data_valid_bootloader_s1_shift_register_in <= ((internal_cpu_0_data_master_granted_bootloader_s1 AND cpu_0_data_master_read) AND NOT bootloader_s1_waits_for_read) AND NOT (cpu_0_data_master_read_data_valid_bootloader_s1_shift_register);
  --shift register p1 cpu_0_data_master_read_data_valid_bootloader_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_0_data_master_read_data_valid_bootloader_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_data_master_read_data_valid_bootloader_s1_shift_register) & A_ToStdLogicVector(cpu_0_data_master_read_data_valid_bootloader_s1_shift_register_in)));
  --cpu_0_data_master_read_data_valid_bootloader_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_data_master_read_data_valid_bootloader_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_data_master_read_data_valid_bootloader_s1_shift_register <= p1_cpu_0_data_master_read_data_valid_bootloader_s1_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_0_data_master_read_data_valid_bootloader_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_bootloader_s1 <= cpu_0_data_master_read_data_valid_bootloader_s1_shift_register;
  --bootloader_s1_writedata mux, which is an e_mux
  bootloader_s1_writedata <= cpu_0_data_master_writedata;
  --mux bootloader_s1_clken, which is an e_mux
  bootloader_s1_clken <= std_logic'('1');
  internal_cpu_0_instruction_master_requests_bootloader_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_instruction_master_address_to_slave(30 DOWNTO 13) & std_logic_vector'("0000000000000")) = std_logic_vector'("0100000000000000000000000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
  --cpu_0/data_master granted bootloader/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_data_master_granted_slave_bootloader_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_data_master_granted_slave_bootloader_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_data_master_saved_grant_bootloader_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((bootloader_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_data_master_requests_bootloader_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_data_master_granted_slave_bootloader_s1))))));
    end if;

  end process;

  --cpu_0_data_master_continuerequest continued request, which is an e_mux
  cpu_0_data_master_continuerequest <= last_cycle_cpu_0_data_master_granted_slave_bootloader_s1 AND internal_cpu_0_data_master_requests_bootloader_s1;
  internal_cpu_0_instruction_master_qualified_request_bootloader_s1 <= internal_cpu_0_instruction_master_requests_bootloader_s1 AND NOT ((((cpu_0_instruction_master_read AND ((to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_latency_counter)))))) OR (cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register))))) OR cpu_0_data_master_arbiterlock));
  --cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register_in <= (internal_cpu_0_instruction_master_granted_bootloader_s1 AND cpu_0_instruction_master_read) AND NOT bootloader_s1_waits_for_read;
  --shift register p1 cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register) & A_ToStdLogicVector(cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register_in)));
  --cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register <= p1_cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_0_instruction_master_read_data_valid_bootloader_s1, which is an e_mux
  cpu_0_instruction_master_read_data_valid_bootloader_s1 <= cpu_0_instruction_master_read_data_valid_bootloader_s1_shift_register;
  --allow new arb cycle for bootloader/s1, which is an e_assign
  bootloader_s1_allow_new_arb_cycle <= NOT cpu_0_data_master_arbiterlock AND NOT cpu_0_instruction_master_arbiterlock;
  --cpu_0/instruction_master assignment into master qualified-requests vector for bootloader/s1, which is an e_assign
  bootloader_s1_master_qreq_vector(0) <= internal_cpu_0_instruction_master_qualified_request_bootloader_s1;
  --cpu_0/instruction_master grant bootloader/s1, which is an e_assign
  internal_cpu_0_instruction_master_granted_bootloader_s1 <= bootloader_s1_grant_vector(0);
  --cpu_0/instruction_master saved-grant bootloader/s1, which is an e_assign
  cpu_0_instruction_master_saved_grant_bootloader_s1 <= bootloader_s1_arb_winner(0) AND internal_cpu_0_instruction_master_requests_bootloader_s1;
  --cpu_0/data_master assignment into master qualified-requests vector for bootloader/s1, which is an e_assign
  bootloader_s1_master_qreq_vector(1) <= internal_cpu_0_data_master_qualified_request_bootloader_s1;
  --cpu_0/data_master grant bootloader/s1, which is an e_assign
  internal_cpu_0_data_master_granted_bootloader_s1 <= bootloader_s1_grant_vector(1);
  --cpu_0/data_master saved-grant bootloader/s1, which is an e_assign
  cpu_0_data_master_saved_grant_bootloader_s1 <= bootloader_s1_arb_winner(1) AND internal_cpu_0_data_master_requests_bootloader_s1;
  --bootloader/s1 chosen-master double-vector, which is an e_assign
  bootloader_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((bootloader_s1_master_qreq_vector & bootloader_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT bootloader_s1_master_qreq_vector & NOT bootloader_s1_master_qreq_vector))) + (std_logic_vector'("000") & (bootloader_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  bootloader_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((bootloader_s1_allow_new_arb_cycle AND or_reduce(bootloader_s1_grant_vector)))) = '1'), bootloader_s1_grant_vector, bootloader_s1_saved_chosen_master_vector);
  --saved bootloader_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      bootloader_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(bootloader_s1_allow_new_arb_cycle) = '1' then 
        bootloader_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(bootloader_s1_grant_vector)) = '1'), bootloader_s1_grant_vector, bootloader_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  bootloader_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((bootloader_s1_chosen_master_double_vector(1) OR bootloader_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((bootloader_s1_chosen_master_double_vector(0) OR bootloader_s1_chosen_master_double_vector(2)))));
  --bootloader/s1 chosen master rotated left, which is an e_assign
  bootloader_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(bootloader_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(bootloader_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --bootloader/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      bootloader_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(bootloader_s1_grant_vector)) = '1' then 
        bootloader_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(bootloader_s1_end_xfer) = '1'), bootloader_s1_chosen_master_rot_left, bootloader_s1_grant_vector);
      end if;
    end if;

  end process;

  --~bootloader_s1_reset assignment, which is an e_assign
  bootloader_s1_reset <= NOT reset_n;
  bootloader_s1_chipselect <= internal_cpu_0_data_master_granted_bootloader_s1 OR internal_cpu_0_instruction_master_granted_bootloader_s1;
  --bootloader_s1_firsttransfer first transaction, which is an e_assign
  bootloader_s1_firsttransfer <= A_WE_StdLogic((std_logic'(bootloader_s1_begins_xfer) = '1'), bootloader_s1_unreg_firsttransfer, bootloader_s1_reg_firsttransfer);
  --bootloader_s1_unreg_firsttransfer first transaction, which is an e_assign
  bootloader_s1_unreg_firsttransfer <= NOT ((bootloader_s1_slavearbiterlockenable AND bootloader_s1_any_continuerequest));
  --bootloader_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      bootloader_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(bootloader_s1_begins_xfer) = '1' then 
        bootloader_s1_reg_firsttransfer <= bootloader_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --bootloader_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  bootloader_s1_beginbursttransfer_internal <= bootloader_s1_begins_xfer;
  --bootloader_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  bootloader_s1_arbitration_holdoff_internal <= bootloader_s1_begins_xfer AND bootloader_s1_firsttransfer;
  --bootloader_s1_write assignment, which is an e_mux
  bootloader_s1_write <= internal_cpu_0_data_master_granted_bootloader_s1 AND cpu_0_data_master_write;
  shifted_address_to_bootloader_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --bootloader_s1_address mux, which is an e_mux
  bootloader_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_bootloader_s1)) = '1'), (A_SRL(shifted_address_to_bootloader_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_bootloader_s1_from_cpu_0_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 11);
  shifted_address_to_bootloader_s1_from_cpu_0_instruction_master <= cpu_0_instruction_master_address_to_slave;
  --d1_bootloader_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_bootloader_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_bootloader_s1_end_xfer <= bootloader_s1_end_xfer;
    end if;

  end process;

  --bootloader_s1_waits_for_read in a cycle, which is an e_mux
  bootloader_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(bootloader_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --bootloader_s1_in_a_read_cycle assignment, which is an e_assign
  bootloader_s1_in_a_read_cycle <= ((internal_cpu_0_data_master_granted_bootloader_s1 AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_bootloader_s1 AND cpu_0_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= bootloader_s1_in_a_read_cycle;
  --bootloader_s1_waits_for_write in a cycle, which is an e_mux
  bootloader_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(bootloader_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --bootloader_s1_in_a_write_cycle assignment, which is an e_assign
  bootloader_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_bootloader_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= bootloader_s1_in_a_write_cycle;
  wait_for_bootloader_s1_counter <= std_logic'('0');
  --bootloader_s1_byteenable byte enable port mux, which is an e_mux
  bootloader_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_bootloader_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_bootloader_s1 <= internal_cpu_0_data_master_granted_bootloader_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_bootloader_s1 <= internal_cpu_0_data_master_qualified_request_bootloader_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_bootloader_s1 <= internal_cpu_0_data_master_requests_bootloader_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_granted_bootloader_s1 <= internal_cpu_0_instruction_master_granted_bootloader_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_qualified_request_bootloader_s1 <= internal_cpu_0_instruction_master_qualified_request_bootloader_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_requests_bootloader_s1 <= internal_cpu_0_instruction_master_requests_bootloader_s1;
--synthesis translate_off
    --bootloader/s1 enable non-zero assertions, which is an e_register
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
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_bootloader_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_bootloader_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_bootloader_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_bootloader_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line3.all);
          deallocate (write_line3);
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

entity cpu_0_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_debugaccess : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
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
                signal shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
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
  internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0100001000000000000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
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
  internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module AND NOT (((((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write)) OR cpu_0_instruction_master_arbiterlock));
  --cpu_0_jtag_debug_module_writedata mux, which is an e_mux
  cpu_0_jtag_debug_module_writedata <= cpu_0_data_master_writedata;
  internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_instruction_master_address_to_slave(30 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0100001000000000000000000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
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
  internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module AND NOT ((((cpu_0_instruction_master_read AND ((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))) OR (cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register))))) OR cpu_0_data_master_arbiterlock));
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
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line5.all);
          deallocate (write_line5);
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

entity cpu_0_data_master_arbitrator is 
        port (
              -- inputs:
                 signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal audio_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal bootloader_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_audio_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_debug_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_epcs_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_jamma_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_keybd_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_m95320_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_oxu210hp_if_0_s0 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_oxu210hp_int_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_spi_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_tfp410_i2c_master_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_timer_60Hz_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_uart_pc_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_uart_ts_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_usb_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_version_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_vo_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_audio_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_debug_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_epcs_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_jamma_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_keybd_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_m95320_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_oxu210hp_int_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_spi_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_60Hz_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_uart_pc_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_uart_ts_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_usb_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_version_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_vo_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_audio_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_debug_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_jamma_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_keybd_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_m95320_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_oxu210hp_int_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_spi_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_60Hz_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_uart_pc_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_uart_ts_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_usb_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_version_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_vo_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_audio_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_debug_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_epcs_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_jamma_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_keybd_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_m95320_spi_control_port : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_oxu210hp_if_0_s0 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_oxu210hp_int_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_spi_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_tfp410_i2c_master_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_60Hz_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_uart_pc_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_uart_ts_avalon_slave : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_usb_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_version_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_vo_pio_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_audio_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_bootloader_s1_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_debug_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_epcs_spi_spi_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_jamma_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_keybd_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_m95320_spi_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_one_wire_interface_0_avalon_slave_0_end_xfer : IN STD_LOGIC;
                 signal d1_oxu210hp_if_0_s0_end_xfer : IN STD_LOGIC;
                 signal d1_oxu210hp_int_s1_end_xfer : IN STD_LOGIC;
                 signal d1_spi_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_tfp410_i2c_master_s1_end_xfer : IN STD_LOGIC;
                 signal d1_timer_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_timer_60Hz_s1_end_xfer : IN STD_LOGIC;
                 signal d1_uart_pc_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_uart_ts_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_usb_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_version_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_vo_pio_s1_end_xfer : IN STD_LOGIC;
                 signal debug_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal epcs_spi_spi_control_port_irq_from_sa : IN STD_LOGIC;
                 signal epcs_spi_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal jamma_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal keybd_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal m95320_spi_control_port_irq_from_sa : IN STD_LOGIC;
                 signal m95320_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal one_wire_interface_0_avalon_slave_0_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal one_wire_interface_0_avalon_slave_0_waitrequest_from_sa : IN STD_LOGIC;
                 signal oxu210hp_if_0_s0_irq_from_sa : IN STD_LOGIC;
                 signal oxu210hp_if_0_s0_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal oxu210hp_if_0_s0_waitrequest_from_sa : IN STD_LOGIC;
                 signal oxu210hp_int_s1_irq_from_sa : IN STD_LOGIC;
                 signal oxu210hp_int_s1_readdata_from_sa : IN STD_LOGIC;
                 signal registered_cpu_0_data_master_read_data_valid_bootloader_s1 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal spi_pio_s1_irq_from_sa : IN STD_LOGIC;
                 signal spi_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal tfp410_i2c_master_s1_irq_from_sa : IN STD_LOGIC;
                 signal tfp410_i2c_master_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal tfp410_i2c_master_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal timer_0_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_60Hz_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_60Hz_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_pc_avalon_slave_irq_from_sa : IN STD_LOGIC;
                 signal uart_pc_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_pc_avalon_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal uart_ts_avalon_slave_irq_from_sa : IN STD_LOGIC;
                 signal uart_ts_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_ts_avalon_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal usb_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal version_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vo_pio_s1_irq_from_sa : IN STD_LOGIC;
                 signal vo_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_0_data_master_dbs_write_8 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_0_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                 signal cpu_0_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_0_data_master_arbitrator;


architecture europa of cpu_0_data_master_arbitrator is
                signal altmemddr_0_s1_readdata_from_sa_part_selected_by_negative_dbs :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_data_master_run :  STD_LOGIC;
                signal dbs_8_reg_segment_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal dbs_8_reg_segment_1 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal dbs_8_reg_segment_2 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_cpu_0_data_master_address_to_slave :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal internal_cpu_0_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_cpu_0_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal internal_cpu_0_data_master_waitrequest :  STD_LOGIC;
                signal last_dbs_term_and_run :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_dbs_8_reg_segment_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal p1_dbs_8_reg_segment_1 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal p1_dbs_8_reg_segment_2 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal p1_registered_cpu_0_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal r_3 :  STD_LOGIC;
                signal r_4 :  STD_LOGIC;
                signal registered_cpu_0_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_0_data_master_qualified_request_altmemddr_0_s1 OR cpu_0_data_master_read_data_valid_altmemddr_0_s1) OR NOT cpu_0_data_master_requests_altmemddr_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_altmemddr_0_s1 OR NOT cpu_0_data_master_qualified_request_altmemddr_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_0_data_master_qualified_request_altmemddr_0_s1 OR NOT cpu_0_data_master_read) OR ((cpu_0_data_master_read_data_valid_altmemddr_0_s1 AND cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_altmemddr_0_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_audio_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_audio_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_0_data_master_qualified_request_bootloader_s1 OR registered_cpu_0_data_master_read_data_valid_bootloader_s1) OR NOT cpu_0_data_master_requests_bootloader_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_bootloader_s1 OR NOT cpu_0_data_master_qualified_request_bootloader_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_0_data_master_qualified_request_bootloader_s1 OR NOT cpu_0_data_master_read) OR ((registered_cpu_0_data_master_read_data_valid_bootloader_s1 AND cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_bootloader_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_requests_cpu_0_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_debug_pio_s1 OR NOT cpu_0_data_master_requests_debug_pio_s1)))))));
  --cascaded wait assignment, which is an e_assign
  cpu_0_data_master_run <= (((r_0 AND r_1) AND r_2) AND r_3) AND r_4;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_debug_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_debug_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_epcs_spi_spi_control_port OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_epcs_spi_spi_control_port OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_jamma_pio_s1 OR NOT cpu_0_data_master_requests_jamma_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_jamma_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_jamma_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_keybd_pio_s1 OR NOT cpu_0_data_master_requests_keybd_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_keybd_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_keybd_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_m95320_spi_control_port OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_m95320_spi_control_port OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 OR NOT cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT one_wire_interface_0_avalon_slave_0_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT one_wire_interface_0_avalon_slave_0_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 OR NOT cpu_0_data_master_requests_oxu210hp_if_0_s0)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT oxu210hp_if_0_s0_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT oxu210hp_if_0_s0_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_oxu210hp_int_s1 OR NOT cpu_0_data_master_requests_oxu210hp_int_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_oxu210hp_int_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_oxu210hp_int_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_spi_pio_s1 OR NOT cpu_0_data_master_requests_spi_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_spi_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_spi_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_sysid_control_slave OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_sysid_control_slave OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")));
  --r_3 master_run cascaded wait assignment, which is an e_assign
  r_3 <= Vector_To_Std_Logic(((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 OR ((((cpu_0_data_master_write AND NOT(cpu_0_data_master_byteenable_tfp410_i2c_master_s1)) AND internal_cpu_0_data_master_dbs_address(1)) AND internal_cpu_0_data_master_dbs_address(0)))) OR NOT cpu_0_data_master_requests_tfp410_i2c_master_s1))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 OR NOT cpu_0_data_master_read)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(tfp410_i2c_master_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((internal_cpu_0_data_master_dbs_address(1) AND internal_cpu_0_data_master_dbs_address(0))))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 OR NOT cpu_0_data_master_write)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(tfp410_i2c_master_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((internal_cpu_0_data_master_dbs_address(1) AND internal_cpu_0_data_master_dbs_address(0))))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_requests_timer_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_timer_60Hz_s1 OR NOT cpu_0_data_master_requests_timer_60Hz_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_60Hz_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_60Hz_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_uart_pc_avalon_slave OR NOT cpu_0_data_master_requests_uart_pc_avalon_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_uart_pc_avalon_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT uart_pc_avalon_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_uart_pc_avalon_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT uart_pc_avalon_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_uart_ts_avalon_slave OR NOT cpu_0_data_master_requests_uart_ts_avalon_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_uart_ts_avalon_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT uart_ts_avalon_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_uart_ts_avalon_slave OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT uart_ts_avalon_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")));
  --r_4 master_run cascaded wait assignment, which is an e_assign
  r_4 <= Vector_To_Std_Logic((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_usb_pio_s1 OR NOT cpu_0_data_master_requests_usb_pio_s1))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_usb_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_usb_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_version_pio_s1 OR NOT cpu_0_data_master_requests_version_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_version_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_version_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_vo_pio_s1 OR NOT cpu_0_data_master_requests_vo_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_vo_pio_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_vo_pio_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_0_data_master_address_to_slave <= Std_Logic_Vector'(cpu_0_data_master_address(30 DOWNTO 29) & std_logic_vector'("000") & cpu_0_data_master_address(25 DOWNTO 0));
  --Negative Dynamic Bus-sizing mux.
  --this mux selects the correct half of the 
  --wide data coming from the slave altmemddr_0/s1 
  altmemddr_0_s1_readdata_from_sa_part_selected_by_negative_dbs <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_address_to_slave(2)))) = std_logic_vector'("00000000000000000000000000000000"))), altmemddr_0_s1_readdata_from_sa(31 DOWNTO 0), altmemddr_0_s1_readdata_from_sa(63 DOWNTO 32));
  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_cpu_0_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      registered_cpu_0_data_master_readdata <= p1_registered_cpu_0_data_master_readdata;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_cpu_0_data_master_readdata <= (((((((A_REP(NOT cpu_0_data_master_requests_altmemddr_0_s1, 32) OR altmemddr_0_s1_readdata_from_sa_part_selected_by_negative_dbs)) AND ((A_REP(NOT cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave, 32) OR jtag_uart_0_avalon_jtag_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0, 32) OR (std_logic_vector'("000000000000000000000000") & (one_wire_interface_0_avalon_slave_0_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_oxu210hp_if_0_s0, 32) OR oxu210hp_if_0_s0_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_tfp410_i2c_master_s1, 32) OR Std_Logic_Vector'(tfp410_i2c_master_s1_readdata_from_sa(7 DOWNTO 0) & dbs_8_reg_segment_2 & dbs_8_reg_segment_1 & dbs_8_reg_segment_0)))) AND ((A_REP(NOT cpu_0_data_master_requests_uart_pc_avalon_slave, 32) OR (std_logic_vector'("0000000000000000") & (uart_pc_avalon_slave_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_uart_ts_avalon_slave, 32) OR (std_logic_vector'("0000000000000000") & (uart_ts_avalon_slave_readdata_from_sa))));
  --cpu_0/data_master readdata mux, which is an e_mux
  cpu_0_data_master_readdata <= (((((((((((((((((((((((A_REP(NOT cpu_0_data_master_requests_altmemddr_0_s1, 32) OR registered_cpu_0_data_master_readdata)) AND ((A_REP(NOT cpu_0_data_master_requests_audio_pio_s1, 32) OR audio_pio_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_bootloader_s1, 32) OR bootloader_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_cpu_0_jtag_debug_module, 32) OR cpu_0_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_debug_pio_s1, 32) OR debug_pio_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_epcs_spi_spi_control_port, 32) OR (std_logic_vector'("0000000000000000") & (epcs_spi_spi_control_port_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_jamma_pio_s1, 32) OR jamma_pio_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave, 32) OR registered_cpu_0_data_master_readdata))) AND ((A_REP(NOT cpu_0_data_master_requests_keybd_pio_s1, 32) OR keybd_pio_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_m95320_spi_control_port, 32) OR (std_logic_vector'("0000000000000000") & (m95320_spi_control_port_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0, 32) OR registered_cpu_0_data_master_readdata))) AND ((A_REP(NOT cpu_0_data_master_requests_oxu210hp_if_0_s0, 32) OR registered_cpu_0_data_master_readdata))) AND ((A_REP(NOT cpu_0_data_master_requests_oxu210hp_int_s1, 32) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(oxu210hp_int_s1_readdata_from_sa)))))) AND ((A_REP(NOT cpu_0_data_master_requests_spi_pio_s1, 32) OR spi_pio_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_sysid_control_slave, 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_tfp410_i2c_master_s1, 32) OR registered_cpu_0_data_master_readdata))) AND ((A_REP(NOT cpu_0_data_master_requests_timer_0_s1, 32) OR (std_logic_vector'("0000000000000000") & (timer_0_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_timer_60Hz_s1, 32) OR (std_logic_vector'("0000000000000000") & (timer_60Hz_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_uart_pc_avalon_slave, 32) OR registered_cpu_0_data_master_readdata))) AND ((A_REP(NOT cpu_0_data_master_requests_uart_ts_avalon_slave, 32) OR registered_cpu_0_data_master_readdata))) AND ((A_REP(NOT cpu_0_data_master_requests_usb_pio_s1, 32) OR (std_logic_vector'("0000000000000000000000000000") & (usb_pio_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_version_pio_s1, 32) OR version_pio_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_vo_pio_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (vo_pio_s1_readdata_from_sa))));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_0_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      internal_cpu_0_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_run AND internal_cpu_0_data_master_waitrequest))))))));
    end if;

  end process;

  --irq assign, which is an e_assign
  cpu_0_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(vo_pio_s1_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(epcs_spi_spi_control_port_irq_from_sa) & A_ToStdLogicVector(tfp410_i2c_master_s1_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(m95320_spi_control_port_irq_from_sa) & A_ToStdLogicVector(oxu210hp_int_s1_irq_from_sa) & A_ToStdLogicVector(oxu210hp_if_0_s0_irq_from_sa) & A_ToStdLogicVector(uart_pc_avalon_slave_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(uart_ts_avalon_slave_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(timer_60Hz_s1_irq_from_sa) & A_ToStdLogicVector(spi_pio_s1_irq_from_sa) & A_ToStdLogicVector(jtag_uart_0_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(timer_0_s1_irq_from_sa));
  --no_byte_enables_and_last_term, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_0_data_master_no_byte_enables_and_last_term <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_cpu_0_data_master_no_byte_enables_and_last_term <= last_dbs_term_and_run;
    end if;

  end process;

  --compute the last dbs term, which is an e_mux
  last_dbs_term_and_run <= (to_std_logic(((internal_cpu_0_data_master_dbs_address = std_logic_vector'("11")))) AND cpu_0_data_master_write) AND NOT(cpu_0_data_master_byteenable_tfp410_i2c_master_s1);
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((((NOT internal_cpu_0_data_master_no_byte_enables_and_last_term) AND cpu_0_data_master_requests_tfp410_i2c_master_s1) AND cpu_0_data_master_write) AND NOT(cpu_0_data_master_byteenable_tfp410_i2c_master_s1)))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_0_data_master_granted_tfp410_i2c_master_s1 AND cpu_0_data_master_read)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(tfp410_i2c_master_s1_waitrequest_n_from_sa)))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_0_data_master_granted_tfp410_i2c_master_s1 AND cpu_0_data_master_write)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(tfp410_i2c_master_s1_waitrequest_n_from_sa)))))));
  --input to dbs-8 stored 0, which is an e_mux
  p1_dbs_8_reg_segment_0 <= tfp410_i2c_master_s1_readdata_from_sa;
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
  p1_dbs_8_reg_segment_1 <= tfp410_i2c_master_s1_readdata_from_sa;
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
  p1_dbs_8_reg_segment_2 <= tfp410_i2c_master_s1_readdata_from_sa;
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
  cpu_0_data_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((cpu_0_data_master_requests_tfp410_i2c_master_s1)) = '1'), std_logic_vector'("00000000000000000000000000000001"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_cpu_0_data_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_cpu_0_data_master_dbs_address)) + (std_logic_vector'("0") & (cpu_0_data_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable AND (NOT ((cpu_0_data_master_requests_tfp410_i2c_master_s1 AND NOT internal_cpu_0_data_master_waitrequest)));
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
  cpu_0_data_master_no_byte_enables_and_last_term <= internal_cpu_0_data_master_no_byte_enables_and_last_term;
  --vhdl renameroo for output signals
  cpu_0_data_master_waitrequest <= internal_cpu_0_data_master_waitrequest;

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

entity selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_module;


architecture europa of selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
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

library std;
use std.textio.all;

entity cpu_0_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal bootloader_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_instruction_master_address : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_instruction_master_granted_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_granted_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_altmemddr_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_bootloader_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_bootloader_s1_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_instruction_master_latency_counter : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_0_instruction_master_arbitrator;


architecture europa of cpu_0_instruction_master_arbitrator is
component selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_module;

                signal active_and_waiting_last_time :  STD_LOGIC;
                signal altmemddr_0_s1_readdata_from_sa_part_selected_by_negative_dbs :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_address_last_time :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal cpu_0_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal cpu_0_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal cpu_0_instruction_master_read_last_time :  STD_LOGIC;
                signal cpu_0_instruction_master_run :  STD_LOGIC;
                signal empty_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo :  STD_LOGIC;
                signal full_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal internal_cpu_0_instruction_master_latency_counter :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal module_input7 :  STD_LOGIC;
                signal module_input8 :  STD_LOGIC;
                signal module_input9 :  STD_LOGIC;
                signal p1_cpu_0_instruction_master_latency_counter :  STD_LOGIC;
                signal pre_flush_cpu_0_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal read_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo :  STD_LOGIC;
                signal selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_output :  STD_LOGIC;
                signal selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_output_altmemddr_0_s1 :  STD_LOGIC;
                signal write_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_qualified_request_altmemddr_0_s1 OR NOT cpu_0_instruction_master_requests_altmemddr_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_altmemddr_0_s1 OR NOT cpu_0_instruction_master_qualified_request_altmemddr_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_instruction_master_qualified_request_altmemddr_0_s1 OR NOT cpu_0_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_qualified_request_bootloader_s1 OR NOT cpu_0_instruction_master_requests_bootloader_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_bootloader_s1 OR NOT cpu_0_instruction_master_qualified_request_bootloader_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_instruction_master_qualified_request_bootloader_s1 OR NOT cpu_0_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_requests_cpu_0_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_0_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_0_instruction_master_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_0_instruction_master_address_to_slave <= Std_Logic_Vector'(cpu_0_instruction_master_address(30 DOWNTO 29) & std_logic_vector'("000") & cpu_0_instruction_master_address(25 DOWNTO 0));
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
  cpu_0_instruction_master_is_granted_some_slave <= (cpu_0_instruction_master_granted_altmemddr_0_s1 OR cpu_0_instruction_master_granted_bootloader_s1) OR cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_cpu_0_instruction_master_readdatavalid <= cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 OR cpu_0_instruction_master_read_data_valid_bootloader_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  cpu_0_instruction_master_readdatavalid <= (((((cpu_0_instruction_master_read_but_no_slave_selected OR pre_flush_cpu_0_instruction_master_readdatavalid) OR cpu_0_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_0_instruction_master_readdatavalid) OR cpu_0_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_0_instruction_master_readdatavalid) OR cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module;
  --Negative Dynamic Bus-sizing mux.
  --this mux selects the correct half of the 
  --wide data coming from the slave altmemddr_0/s1 
  altmemddr_0_s1_readdata_from_sa_part_selected_by_negative_dbs <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_output_altmemddr_0_s1))) = std_logic_vector'("00000000000000000000000000000000"))), altmemddr_0_s1_readdata_from_sa(31 DOWNTO 0), altmemddr_0_s1_readdata_from_sa(63 DOWNTO 32));
  --read_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo fifo read, which is an e_mux
  read_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo <= cpu_0_instruction_master_read_data_valid_altmemddr_0_s1;
  --write_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo fifo write, which is an e_mux
  write_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo <= (cpu_0_instruction_master_read AND cpu_0_instruction_master_run) AND cpu_0_instruction_master_requests_altmemddr_0_s1;
  selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_output_altmemddr_0_s1 <= selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_output;
  --selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo, which is an e_fifo_with_registered_outputs
  selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo : selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_module
    port map(
      data_out => selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo_output,
      empty => empty_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo,
      fifo_contains_ones_n => open,
      full => full_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo,
      clear_fifo => module_input7,
      clk => clk,
      data_in => module_input8,
      read => read_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo,
      reset_n => reset_n,
      sync_reset => module_input9,
      write => write_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo
    );

  module_input7 <= std_logic'('0');
  module_input8 <= internal_cpu_0_instruction_master_address_to_slave(2);
  module_input9 <= std_logic'('0');

  --cpu_0/instruction_master readdata mux, which is an e_mux
  cpu_0_instruction_master_readdata <= (((A_REP(NOT cpu_0_instruction_master_read_data_valid_altmemddr_0_s1, 32) OR altmemddr_0_s1_readdata_from_sa_part_selected_by_negative_dbs)) AND ((A_REP(NOT cpu_0_instruction_master_read_data_valid_bootloader_s1, 32) OR bootloader_s1_readdata_from_sa))) AND ((A_REP(NOT ((cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module AND cpu_0_instruction_master_read)) , 32) OR cpu_0_jtag_debug_module_readdata_from_sa));
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
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_requests_bootloader_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
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
        cpu_0_instruction_master_address_last_time <= std_logic_vector'("0000000000000000000000000000000");
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
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_0_instruction_master_address /= cpu_0_instruction_master_address_last_time))))) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("cpu_0_instruction_master_address did not heed wait!!!"));
          write(output, write_line6.all);
          deallocate (write_line6);
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
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_0_instruction_master_read) /= std_logic'(cpu_0_instruction_master_read_last_time)))))) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("cpu_0_instruction_master_read did not heed wait!!!"));
          write(output, write_line7.all);
          deallocate (write_line7);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo read when empty, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((empty_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo AND read_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo)) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("cpu_0/instruction_master negative rdv fifo selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo: read AND empty."));
          write(output, write_line8.all & CR);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo write when full, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((full_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo AND write_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo) AND NOT read_selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo)) = '1' then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("cpu_0/instruction_master negative rdv fifo selecto_nrdv_cpu_0_instruction_master_1_altmemddr_0_s1_fifo: write AND full."));
          write(output, write_line9.all & CR);
          deallocate (write_line9);
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

entity debug_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal debug_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_debug_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_debug_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_debug_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_debug_pio_s1 : OUT STD_LOGIC;
                 signal d1_debug_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal debug_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal debug_pio_s1_chipselect : OUT STD_LOGIC;
                 signal debug_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal debug_pio_s1_reset_n : OUT STD_LOGIC;
                 signal debug_pio_s1_write_n : OUT STD_LOGIC;
                 signal debug_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity debug_pio_s1_arbitrator;


architecture europa of debug_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_debug_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal debug_pio_s1_allgrants :  STD_LOGIC;
                signal debug_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal debug_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal debug_pio_s1_any_continuerequest :  STD_LOGIC;
                signal debug_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal debug_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal debug_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal debug_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal debug_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal debug_pio_s1_begins_xfer :  STD_LOGIC;
                signal debug_pio_s1_end_xfer :  STD_LOGIC;
                signal debug_pio_s1_firsttransfer :  STD_LOGIC;
                signal debug_pio_s1_grant_vector :  STD_LOGIC;
                signal debug_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal debug_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal debug_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal debug_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal debug_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal debug_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal debug_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal debug_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal debug_pio_s1_waits_for_read :  STD_LOGIC;
                signal debug_pio_s1_waits_for_write :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_debug_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_debug_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_debug_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_debug_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_debug_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_debug_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT debug_pio_s1_end_xfer;
    end if;

  end process;

  debug_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_debug_pio_s1);
  --assign debug_pio_s1_readdata_from_sa = debug_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  debug_pio_s1_readdata_from_sa <= debug_pio_s1_readdata;
  internal_cpu_0_data_master_requests_debug_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000011000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --debug_pio_s1_arb_share_counter set values, which is an e_mux
  debug_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --debug_pio_s1_non_bursting_master_requests mux, which is an e_mux
  debug_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_debug_pio_s1;
  --debug_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  debug_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --debug_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  debug_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(debug_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (debug_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(debug_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (debug_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --debug_pio_s1_allgrants all slave grants, which is an e_mux
  debug_pio_s1_allgrants <= debug_pio_s1_grant_vector;
  --debug_pio_s1_end_xfer assignment, which is an e_assign
  debug_pio_s1_end_xfer <= NOT ((debug_pio_s1_waits_for_read OR debug_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_debug_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_debug_pio_s1 <= debug_pio_s1_end_xfer AND (((NOT debug_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --debug_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  debug_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_debug_pio_s1 AND debug_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_debug_pio_s1 AND NOT debug_pio_s1_non_bursting_master_requests));
  --debug_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      debug_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(debug_pio_s1_arb_counter_enable) = '1' then 
        debug_pio_s1_arb_share_counter <= debug_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --debug_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      debug_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((debug_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_debug_pio_s1)) OR ((end_xfer_arb_share_counter_term_debug_pio_s1 AND NOT debug_pio_s1_non_bursting_master_requests)))) = '1' then 
        debug_pio_s1_slavearbiterlockenable <= or_reduce(debug_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master debug_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= debug_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --debug_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  debug_pio_s1_slavearbiterlockenable2 <= or_reduce(debug_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master debug_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= debug_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --debug_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  debug_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_debug_pio_s1 <= internal_cpu_0_data_master_requests_debug_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --debug_pio_s1_writedata mux, which is an e_mux
  debug_pio_s1_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_debug_pio_s1 <= internal_cpu_0_data_master_qualified_request_debug_pio_s1;
  --cpu_0/data_master saved-grant debug_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_debug_pio_s1 <= internal_cpu_0_data_master_requests_debug_pio_s1;
  --allow new arb cycle for debug_pio/s1, which is an e_assign
  debug_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  debug_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  debug_pio_s1_master_qreq_vector <= std_logic'('1');
  --debug_pio_s1_reset_n assignment, which is an e_assign
  debug_pio_s1_reset_n <= reset_n;
  debug_pio_s1_chipselect <= internal_cpu_0_data_master_granted_debug_pio_s1;
  --debug_pio_s1_firsttransfer first transaction, which is an e_assign
  debug_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(debug_pio_s1_begins_xfer) = '1'), debug_pio_s1_unreg_firsttransfer, debug_pio_s1_reg_firsttransfer);
  --debug_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  debug_pio_s1_unreg_firsttransfer <= NOT ((debug_pio_s1_slavearbiterlockenable AND debug_pio_s1_any_continuerequest));
  --debug_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      debug_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(debug_pio_s1_begins_xfer) = '1' then 
        debug_pio_s1_reg_firsttransfer <= debug_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --debug_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  debug_pio_s1_beginbursttransfer_internal <= debug_pio_s1_begins_xfer;
  --~debug_pio_s1_write_n assignment, which is an e_mux
  debug_pio_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_debug_pio_s1 AND cpu_0_data_master_write));
  shifted_address_to_debug_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --debug_pio_s1_address mux, which is an e_mux
  debug_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_debug_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_debug_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_debug_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_debug_pio_s1_end_xfer <= debug_pio_s1_end_xfer;
    end if;

  end process;

  --debug_pio_s1_waits_for_read in a cycle, which is an e_mux
  debug_pio_s1_waits_for_read <= debug_pio_s1_in_a_read_cycle AND debug_pio_s1_begins_xfer;
  --debug_pio_s1_in_a_read_cycle assignment, which is an e_assign
  debug_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_debug_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= debug_pio_s1_in_a_read_cycle;
  --debug_pio_s1_waits_for_write in a cycle, which is an e_mux
  debug_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(debug_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --debug_pio_s1_in_a_write_cycle assignment, which is an e_assign
  debug_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_debug_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= debug_pio_s1_in_a_write_cycle;
  wait_for_debug_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_debug_pio_s1 <= internal_cpu_0_data_master_granted_debug_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_debug_pio_s1 <= internal_cpu_0_data_master_qualified_request_debug_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_debug_pio_s1 <= internal_cpu_0_data_master_requests_debug_pio_s1;
--synthesis translate_off
    --debug_pio/s1 enable non-zero assertions, which is an e_register
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

entity epcs_spi_spi_control_port_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal epcs_spi_spi_control_port_dataavailable : IN STD_LOGIC;
                 signal epcs_spi_spi_control_port_endofpacket : IN STD_LOGIC;
                 signal epcs_spi_spi_control_port_irq : IN STD_LOGIC;
                 signal epcs_spi_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal epcs_spi_spi_control_port_readyfordata : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_epcs_spi_spi_control_port : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_epcs_spi_spi_control_port : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_epcs_spi_spi_control_port : OUT STD_LOGIC;
                 signal d1_epcs_spi_spi_control_port_end_xfer : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal epcs_spi_spi_control_port_chipselect : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_read_n : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal epcs_spi_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_reset_n : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_write_n : OUT STD_LOGIC;
                 signal epcs_spi_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity epcs_spi_spi_control_port_arbitrator;


architecture europa of epcs_spi_spi_control_port_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_epcs_spi_spi_control_port :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_epcs_spi_spi_control_port :  STD_LOGIC;
                signal epcs_spi_spi_control_port_allgrants :  STD_LOGIC;
                signal epcs_spi_spi_control_port_allow_new_arb_cycle :  STD_LOGIC;
                signal epcs_spi_spi_control_port_any_bursting_master_saved_grant :  STD_LOGIC;
                signal epcs_spi_spi_control_port_any_continuerequest :  STD_LOGIC;
                signal epcs_spi_spi_control_port_arb_counter_enable :  STD_LOGIC;
                signal epcs_spi_spi_control_port_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal epcs_spi_spi_control_port_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal epcs_spi_spi_control_port_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal epcs_spi_spi_control_port_beginbursttransfer_internal :  STD_LOGIC;
                signal epcs_spi_spi_control_port_begins_xfer :  STD_LOGIC;
                signal epcs_spi_spi_control_port_end_xfer :  STD_LOGIC;
                signal epcs_spi_spi_control_port_firsttransfer :  STD_LOGIC;
                signal epcs_spi_spi_control_port_grant_vector :  STD_LOGIC;
                signal epcs_spi_spi_control_port_in_a_read_cycle :  STD_LOGIC;
                signal epcs_spi_spi_control_port_in_a_write_cycle :  STD_LOGIC;
                signal epcs_spi_spi_control_port_master_qreq_vector :  STD_LOGIC;
                signal epcs_spi_spi_control_port_non_bursting_master_requests :  STD_LOGIC;
                signal epcs_spi_spi_control_port_reg_firsttransfer :  STD_LOGIC;
                signal epcs_spi_spi_control_port_slavearbiterlockenable :  STD_LOGIC;
                signal epcs_spi_spi_control_port_slavearbiterlockenable2 :  STD_LOGIC;
                signal epcs_spi_spi_control_port_unreg_firsttransfer :  STD_LOGIC;
                signal epcs_spi_spi_control_port_waits_for_read :  STD_LOGIC;
                signal epcs_spi_spi_control_port_waits_for_write :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_epcs_spi_spi_control_port :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_epcs_spi_spi_control_port :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_epcs_spi_spi_control_port :  STD_LOGIC;
                signal shifted_address_to_epcs_spi_spi_control_port_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_epcs_spi_spi_control_port_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT epcs_spi_spi_control_port_end_xfer;
    end if;

  end process;

  epcs_spi_spi_control_port_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_epcs_spi_spi_control_port);
  --assign epcs_spi_spi_control_port_readdata_from_sa = epcs_spi_spi_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_spi_spi_control_port_readdata_from_sa <= epcs_spi_spi_control_port_readdata;
  internal_cpu_0_data_master_requests_epcs_spi_spi_control_port <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000100000000000100000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign epcs_spi_spi_control_port_dataavailable_from_sa = epcs_spi_spi_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_spi_spi_control_port_dataavailable_from_sa <= epcs_spi_spi_control_port_dataavailable;
  --assign epcs_spi_spi_control_port_readyfordata_from_sa = epcs_spi_spi_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_spi_spi_control_port_readyfordata_from_sa <= epcs_spi_spi_control_port_readyfordata;
  --epcs_spi_spi_control_port_arb_share_counter set values, which is an e_mux
  epcs_spi_spi_control_port_arb_share_set_values <= std_logic_vector'("001");
  --epcs_spi_spi_control_port_non_bursting_master_requests mux, which is an e_mux
  epcs_spi_spi_control_port_non_bursting_master_requests <= internal_cpu_0_data_master_requests_epcs_spi_spi_control_port;
  --epcs_spi_spi_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  epcs_spi_spi_control_port_any_bursting_master_saved_grant <= std_logic'('0');
  --epcs_spi_spi_control_port_arb_share_counter_next_value assignment, which is an e_assign
  epcs_spi_spi_control_port_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(epcs_spi_spi_control_port_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (epcs_spi_spi_control_port_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(epcs_spi_spi_control_port_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (epcs_spi_spi_control_port_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --epcs_spi_spi_control_port_allgrants all slave grants, which is an e_mux
  epcs_spi_spi_control_port_allgrants <= epcs_spi_spi_control_port_grant_vector;
  --epcs_spi_spi_control_port_end_xfer assignment, which is an e_assign
  epcs_spi_spi_control_port_end_xfer <= NOT ((epcs_spi_spi_control_port_waits_for_read OR epcs_spi_spi_control_port_waits_for_write));
  --end_xfer_arb_share_counter_term_epcs_spi_spi_control_port arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_epcs_spi_spi_control_port <= epcs_spi_spi_control_port_end_xfer AND (((NOT epcs_spi_spi_control_port_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --epcs_spi_spi_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  epcs_spi_spi_control_port_arb_counter_enable <= ((end_xfer_arb_share_counter_term_epcs_spi_spi_control_port AND epcs_spi_spi_control_port_allgrants)) OR ((end_xfer_arb_share_counter_term_epcs_spi_spi_control_port AND NOT epcs_spi_spi_control_port_non_bursting_master_requests));
  --epcs_spi_spi_control_port_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_spi_spi_control_port_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(epcs_spi_spi_control_port_arb_counter_enable) = '1' then 
        epcs_spi_spi_control_port_arb_share_counter <= epcs_spi_spi_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --epcs_spi_spi_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_spi_spi_control_port_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((epcs_spi_spi_control_port_master_qreq_vector AND end_xfer_arb_share_counter_term_epcs_spi_spi_control_port)) OR ((end_xfer_arb_share_counter_term_epcs_spi_spi_control_port AND NOT epcs_spi_spi_control_port_non_bursting_master_requests)))) = '1' then 
        epcs_spi_spi_control_port_slavearbiterlockenable <= or_reduce(epcs_spi_spi_control_port_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master epcs_spi/spi_control_port arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= epcs_spi_spi_control_port_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --epcs_spi_spi_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  epcs_spi_spi_control_port_slavearbiterlockenable2 <= or_reduce(epcs_spi_spi_control_port_arb_share_counter_next_value);
  --cpu_0/data_master epcs_spi/spi_control_port arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= epcs_spi_spi_control_port_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --epcs_spi_spi_control_port_any_continuerequest at least one master continues requesting, which is an e_assign
  epcs_spi_spi_control_port_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_epcs_spi_spi_control_port <= internal_cpu_0_data_master_requests_epcs_spi_spi_control_port;
  --epcs_spi_spi_control_port_writedata mux, which is an e_mux
  epcs_spi_spi_control_port_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --assign epcs_spi_spi_control_port_endofpacket_from_sa = epcs_spi_spi_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_spi_spi_control_port_endofpacket_from_sa <= epcs_spi_spi_control_port_endofpacket;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_epcs_spi_spi_control_port <= internal_cpu_0_data_master_qualified_request_epcs_spi_spi_control_port;
  --cpu_0/data_master saved-grant epcs_spi/spi_control_port, which is an e_assign
  cpu_0_data_master_saved_grant_epcs_spi_spi_control_port <= internal_cpu_0_data_master_requests_epcs_spi_spi_control_port;
  --allow new arb cycle for epcs_spi/spi_control_port, which is an e_assign
  epcs_spi_spi_control_port_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  epcs_spi_spi_control_port_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  epcs_spi_spi_control_port_master_qreq_vector <= std_logic'('1');
  --epcs_spi_spi_control_port_reset_n assignment, which is an e_assign
  epcs_spi_spi_control_port_reset_n <= reset_n;
  epcs_spi_spi_control_port_chipselect <= internal_cpu_0_data_master_granted_epcs_spi_spi_control_port;
  --epcs_spi_spi_control_port_firsttransfer first transaction, which is an e_assign
  epcs_spi_spi_control_port_firsttransfer <= A_WE_StdLogic((std_logic'(epcs_spi_spi_control_port_begins_xfer) = '1'), epcs_spi_spi_control_port_unreg_firsttransfer, epcs_spi_spi_control_port_reg_firsttransfer);
  --epcs_spi_spi_control_port_unreg_firsttransfer first transaction, which is an e_assign
  epcs_spi_spi_control_port_unreg_firsttransfer <= NOT ((epcs_spi_spi_control_port_slavearbiterlockenable AND epcs_spi_spi_control_port_any_continuerequest));
  --epcs_spi_spi_control_port_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_spi_spi_control_port_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(epcs_spi_spi_control_port_begins_xfer) = '1' then 
        epcs_spi_spi_control_port_reg_firsttransfer <= epcs_spi_spi_control_port_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --epcs_spi_spi_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  epcs_spi_spi_control_port_beginbursttransfer_internal <= epcs_spi_spi_control_port_begins_xfer;
  --~epcs_spi_spi_control_port_read_n assignment, which is an e_mux
  epcs_spi_spi_control_port_read_n <= NOT ((internal_cpu_0_data_master_granted_epcs_spi_spi_control_port AND cpu_0_data_master_read));
  --~epcs_spi_spi_control_port_write_n assignment, which is an e_mux
  epcs_spi_spi_control_port_write_n <= NOT ((internal_cpu_0_data_master_granted_epcs_spi_spi_control_port AND cpu_0_data_master_write));
  shifted_address_to_epcs_spi_spi_control_port_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --epcs_spi_spi_control_port_address mux, which is an e_mux
  epcs_spi_spi_control_port_address <= A_EXT (A_SRL(shifted_address_to_epcs_spi_spi_control_port_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_epcs_spi_spi_control_port_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_epcs_spi_spi_control_port_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_epcs_spi_spi_control_port_end_xfer <= epcs_spi_spi_control_port_end_xfer;
    end if;

  end process;

  --epcs_spi_spi_control_port_waits_for_read in a cycle, which is an e_mux
  epcs_spi_spi_control_port_waits_for_read <= epcs_spi_spi_control_port_in_a_read_cycle AND epcs_spi_spi_control_port_begins_xfer;
  --epcs_spi_spi_control_port_in_a_read_cycle assignment, which is an e_assign
  epcs_spi_spi_control_port_in_a_read_cycle <= internal_cpu_0_data_master_granted_epcs_spi_spi_control_port AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= epcs_spi_spi_control_port_in_a_read_cycle;
  --epcs_spi_spi_control_port_waits_for_write in a cycle, which is an e_mux
  epcs_spi_spi_control_port_waits_for_write <= epcs_spi_spi_control_port_in_a_write_cycle AND epcs_spi_spi_control_port_begins_xfer;
  --epcs_spi_spi_control_port_in_a_write_cycle assignment, which is an e_assign
  epcs_spi_spi_control_port_in_a_write_cycle <= internal_cpu_0_data_master_granted_epcs_spi_spi_control_port AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= epcs_spi_spi_control_port_in_a_write_cycle;
  wait_for_epcs_spi_spi_control_port_counter <= std_logic'('0');
  --assign epcs_spi_spi_control_port_irq_from_sa = epcs_spi_spi_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_spi_spi_control_port_irq_from_sa <= epcs_spi_spi_control_port_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_epcs_spi_spi_control_port <= internal_cpu_0_data_master_granted_epcs_spi_spi_control_port;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_epcs_spi_spi_control_port <= internal_cpu_0_data_master_qualified_request_epcs_spi_spi_control_port;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_epcs_spi_spi_control_port <= internal_cpu_0_data_master_requests_epcs_spi_spi_control_port;
--synthesis translate_off
    --epcs_spi/spi_control_port enable non-zero assertions, which is an e_register
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

entity jamma_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jamma_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_jamma_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_jamma_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_jamma_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_jamma_pio_s1 : OUT STD_LOGIC;
                 signal d1_jamma_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal jamma_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal jamma_pio_s1_chipselect : OUT STD_LOGIC;
                 signal jamma_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jamma_pio_s1_reset_n : OUT STD_LOGIC;
                 signal jamma_pio_s1_write_n : OUT STD_LOGIC;
                 signal jamma_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jamma_pio_s1_arbitrator;


architecture europa of jamma_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_jamma_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jamma_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_jamma_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_jamma_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_jamma_pio_s1 :  STD_LOGIC;
                signal jamma_pio_s1_allgrants :  STD_LOGIC;
                signal jamma_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal jamma_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jamma_pio_s1_any_continuerequest :  STD_LOGIC;
                signal jamma_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal jamma_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal jamma_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal jamma_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal jamma_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal jamma_pio_s1_begins_xfer :  STD_LOGIC;
                signal jamma_pio_s1_end_xfer :  STD_LOGIC;
                signal jamma_pio_s1_firsttransfer :  STD_LOGIC;
                signal jamma_pio_s1_grant_vector :  STD_LOGIC;
                signal jamma_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal jamma_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal jamma_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal jamma_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal jamma_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal jamma_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal jamma_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal jamma_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal jamma_pio_s1_waits_for_read :  STD_LOGIC;
                signal jamma_pio_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_jamma_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_jamma_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT jamma_pio_s1_end_xfer;
    end if;

  end process;

  jamma_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_jamma_pio_s1);
  --assign jamma_pio_s1_readdata_from_sa = jamma_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jamma_pio_s1_readdata_from_sa <= jamma_pio_s1_readdata;
  internal_cpu_0_data_master_requests_jamma_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000000010010000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --jamma_pio_s1_arb_share_counter set values, which is an e_mux
  jamma_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --jamma_pio_s1_non_bursting_master_requests mux, which is an e_mux
  jamma_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_jamma_pio_s1;
  --jamma_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  jamma_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --jamma_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  jamma_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(jamma_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (jamma_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(jamma_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (jamma_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --jamma_pio_s1_allgrants all slave grants, which is an e_mux
  jamma_pio_s1_allgrants <= jamma_pio_s1_grant_vector;
  --jamma_pio_s1_end_xfer assignment, which is an e_assign
  jamma_pio_s1_end_xfer <= NOT ((jamma_pio_s1_waits_for_read OR jamma_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_jamma_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jamma_pio_s1 <= jamma_pio_s1_end_xfer AND (((NOT jamma_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jamma_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  jamma_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jamma_pio_s1 AND jamma_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_jamma_pio_s1 AND NOT jamma_pio_s1_non_bursting_master_requests));
  --jamma_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jamma_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(jamma_pio_s1_arb_counter_enable) = '1' then 
        jamma_pio_s1_arb_share_counter <= jamma_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jamma_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jamma_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jamma_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_jamma_pio_s1)) OR ((end_xfer_arb_share_counter_term_jamma_pio_s1 AND NOT jamma_pio_s1_non_bursting_master_requests)))) = '1' then 
        jamma_pio_s1_slavearbiterlockenable <= or_reduce(jamma_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master jamma_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= jamma_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --jamma_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jamma_pio_s1_slavearbiterlockenable2 <= or_reduce(jamma_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master jamma_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= jamma_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --jamma_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  jamma_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_jamma_pio_s1 <= internal_cpu_0_data_master_requests_jamma_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --jamma_pio_s1_writedata mux, which is an e_mux
  jamma_pio_s1_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_jamma_pio_s1 <= internal_cpu_0_data_master_qualified_request_jamma_pio_s1;
  --cpu_0/data_master saved-grant jamma_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_jamma_pio_s1 <= internal_cpu_0_data_master_requests_jamma_pio_s1;
  --allow new arb cycle for jamma_pio/s1, which is an e_assign
  jamma_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jamma_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jamma_pio_s1_master_qreq_vector <= std_logic'('1');
  --jamma_pio_s1_reset_n assignment, which is an e_assign
  jamma_pio_s1_reset_n <= reset_n;
  jamma_pio_s1_chipselect <= internal_cpu_0_data_master_granted_jamma_pio_s1;
  --jamma_pio_s1_firsttransfer first transaction, which is an e_assign
  jamma_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(jamma_pio_s1_begins_xfer) = '1'), jamma_pio_s1_unreg_firsttransfer, jamma_pio_s1_reg_firsttransfer);
  --jamma_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  jamma_pio_s1_unreg_firsttransfer <= NOT ((jamma_pio_s1_slavearbiterlockenable AND jamma_pio_s1_any_continuerequest));
  --jamma_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jamma_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jamma_pio_s1_begins_xfer) = '1' then 
        jamma_pio_s1_reg_firsttransfer <= jamma_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jamma_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jamma_pio_s1_beginbursttransfer_internal <= jamma_pio_s1_begins_xfer;
  --~jamma_pio_s1_write_n assignment, which is an e_mux
  jamma_pio_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_jamma_pio_s1 AND cpu_0_data_master_write));
  shifted_address_to_jamma_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --jamma_pio_s1_address mux, which is an e_mux
  jamma_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_jamma_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_jamma_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jamma_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_jamma_pio_s1_end_xfer <= jamma_pio_s1_end_xfer;
    end if;

  end process;

  --jamma_pio_s1_waits_for_read in a cycle, which is an e_mux
  jamma_pio_s1_waits_for_read <= jamma_pio_s1_in_a_read_cycle AND jamma_pio_s1_begins_xfer;
  --jamma_pio_s1_in_a_read_cycle assignment, which is an e_assign
  jamma_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_jamma_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jamma_pio_s1_in_a_read_cycle;
  --jamma_pio_s1_waits_for_write in a cycle, which is an e_mux
  jamma_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jamma_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --jamma_pio_s1_in_a_write_cycle assignment, which is an e_assign
  jamma_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_jamma_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jamma_pio_s1_in_a_write_cycle;
  wait_for_jamma_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_jamma_pio_s1 <= internal_cpu_0_data_master_granted_jamma_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_jamma_pio_s1 <= internal_cpu_0_data_master_qualified_request_jamma_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_jamma_pio_s1 <= internal_cpu_0_data_master_requests_jamma_pio_s1;
--synthesis translate_off
    --jamma_pio/s1 enable non-zero assertions, which is an e_register
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

entity jtag_uart_0_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
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
                signal shifted_address_to_jtag_uart_0_avalon_jtag_slave_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
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
  internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000100000000100000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
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
  internal_cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave <= internal_cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave AND NOT ((((cpu_0_data_master_read AND (NOT cpu_0_data_master_waitrequest))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))));
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

entity keybd_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal keybd_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_keybd_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_keybd_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_keybd_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_keybd_pio_s1 : OUT STD_LOGIC;
                 signal d1_keybd_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal keybd_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal keybd_pio_s1_chipselect : OUT STD_LOGIC;
                 signal keybd_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal keybd_pio_s1_reset_n : OUT STD_LOGIC;
                 signal keybd_pio_s1_write_n : OUT STD_LOGIC;
                 signal keybd_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity keybd_pio_s1_arbitrator;


architecture europa of keybd_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_keybd_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_keybd_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_keybd_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_keybd_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_keybd_pio_s1 :  STD_LOGIC;
                signal keybd_pio_s1_allgrants :  STD_LOGIC;
                signal keybd_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal keybd_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal keybd_pio_s1_any_continuerequest :  STD_LOGIC;
                signal keybd_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal keybd_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal keybd_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal keybd_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal keybd_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal keybd_pio_s1_begins_xfer :  STD_LOGIC;
                signal keybd_pio_s1_end_xfer :  STD_LOGIC;
                signal keybd_pio_s1_firsttransfer :  STD_LOGIC;
                signal keybd_pio_s1_grant_vector :  STD_LOGIC;
                signal keybd_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal keybd_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal keybd_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal keybd_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal keybd_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal keybd_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal keybd_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal keybd_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal keybd_pio_s1_waits_for_read :  STD_LOGIC;
                signal keybd_pio_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_keybd_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_keybd_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT keybd_pio_s1_end_xfer;
    end if;

  end process;

  keybd_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_keybd_pio_s1);
  --assign keybd_pio_s1_readdata_from_sa = keybd_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  keybd_pio_s1_readdata_from_sa <= keybd_pio_s1_readdata;
  internal_cpu_0_data_master_requests_keybd_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000000010100000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --keybd_pio_s1_arb_share_counter set values, which is an e_mux
  keybd_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --keybd_pio_s1_non_bursting_master_requests mux, which is an e_mux
  keybd_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_keybd_pio_s1;
  --keybd_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  keybd_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --keybd_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  keybd_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(keybd_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (keybd_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(keybd_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (keybd_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --keybd_pio_s1_allgrants all slave grants, which is an e_mux
  keybd_pio_s1_allgrants <= keybd_pio_s1_grant_vector;
  --keybd_pio_s1_end_xfer assignment, which is an e_assign
  keybd_pio_s1_end_xfer <= NOT ((keybd_pio_s1_waits_for_read OR keybd_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_keybd_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_keybd_pio_s1 <= keybd_pio_s1_end_xfer AND (((NOT keybd_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --keybd_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  keybd_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_keybd_pio_s1 AND keybd_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_keybd_pio_s1 AND NOT keybd_pio_s1_non_bursting_master_requests));
  --keybd_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      keybd_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(keybd_pio_s1_arb_counter_enable) = '1' then 
        keybd_pio_s1_arb_share_counter <= keybd_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --keybd_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      keybd_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((keybd_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_keybd_pio_s1)) OR ((end_xfer_arb_share_counter_term_keybd_pio_s1 AND NOT keybd_pio_s1_non_bursting_master_requests)))) = '1' then 
        keybd_pio_s1_slavearbiterlockenable <= or_reduce(keybd_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master keybd_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= keybd_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --keybd_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  keybd_pio_s1_slavearbiterlockenable2 <= or_reduce(keybd_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master keybd_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= keybd_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --keybd_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  keybd_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_keybd_pio_s1 <= internal_cpu_0_data_master_requests_keybd_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --keybd_pio_s1_writedata mux, which is an e_mux
  keybd_pio_s1_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_keybd_pio_s1 <= internal_cpu_0_data_master_qualified_request_keybd_pio_s1;
  --cpu_0/data_master saved-grant keybd_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_keybd_pio_s1 <= internal_cpu_0_data_master_requests_keybd_pio_s1;
  --allow new arb cycle for keybd_pio/s1, which is an e_assign
  keybd_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  keybd_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  keybd_pio_s1_master_qreq_vector <= std_logic'('1');
  --keybd_pio_s1_reset_n assignment, which is an e_assign
  keybd_pio_s1_reset_n <= reset_n;
  keybd_pio_s1_chipselect <= internal_cpu_0_data_master_granted_keybd_pio_s1;
  --keybd_pio_s1_firsttransfer first transaction, which is an e_assign
  keybd_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(keybd_pio_s1_begins_xfer) = '1'), keybd_pio_s1_unreg_firsttransfer, keybd_pio_s1_reg_firsttransfer);
  --keybd_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  keybd_pio_s1_unreg_firsttransfer <= NOT ((keybd_pio_s1_slavearbiterlockenable AND keybd_pio_s1_any_continuerequest));
  --keybd_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      keybd_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(keybd_pio_s1_begins_xfer) = '1' then 
        keybd_pio_s1_reg_firsttransfer <= keybd_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --keybd_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  keybd_pio_s1_beginbursttransfer_internal <= keybd_pio_s1_begins_xfer;
  --~keybd_pio_s1_write_n assignment, which is an e_mux
  keybd_pio_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_keybd_pio_s1 AND cpu_0_data_master_write));
  shifted_address_to_keybd_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --keybd_pio_s1_address mux, which is an e_mux
  keybd_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_keybd_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_keybd_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_keybd_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_keybd_pio_s1_end_xfer <= keybd_pio_s1_end_xfer;
    end if;

  end process;

  --keybd_pio_s1_waits_for_read in a cycle, which is an e_mux
  keybd_pio_s1_waits_for_read <= keybd_pio_s1_in_a_read_cycle AND keybd_pio_s1_begins_xfer;
  --keybd_pio_s1_in_a_read_cycle assignment, which is an e_assign
  keybd_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_keybd_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= keybd_pio_s1_in_a_read_cycle;
  --keybd_pio_s1_waits_for_write in a cycle, which is an e_mux
  keybd_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(keybd_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --keybd_pio_s1_in_a_write_cycle assignment, which is an e_assign
  keybd_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_keybd_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= keybd_pio_s1_in_a_write_cycle;
  wait_for_keybd_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_keybd_pio_s1 <= internal_cpu_0_data_master_granted_keybd_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_keybd_pio_s1 <= internal_cpu_0_data_master_qualified_request_keybd_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_keybd_pio_s1 <= internal_cpu_0_data_master_requests_keybd_pio_s1;
--synthesis translate_off
    --keybd_pio/s1 enable non-zero assertions, which is an e_register
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

entity m95320_spi_control_port_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal m95320_spi_control_port_dataavailable : IN STD_LOGIC;
                 signal m95320_spi_control_port_endofpacket : IN STD_LOGIC;
                 signal m95320_spi_control_port_irq : IN STD_LOGIC;
                 signal m95320_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal m95320_spi_control_port_readyfordata : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_m95320_spi_control_port : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_m95320_spi_control_port : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_m95320_spi_control_port : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_m95320_spi_control_port : OUT STD_LOGIC;
                 signal d1_m95320_spi_control_port_end_xfer : OUT STD_LOGIC;
                 signal m95320_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal m95320_spi_control_port_chipselect : OUT STD_LOGIC;
                 signal m95320_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                 signal m95320_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                 signal m95320_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                 signal m95320_spi_control_port_read_n : OUT STD_LOGIC;
                 signal m95320_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal m95320_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                 signal m95320_spi_control_port_reset_n : OUT STD_LOGIC;
                 signal m95320_spi_control_port_write_n : OUT STD_LOGIC;
                 signal m95320_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity m95320_spi_control_port_arbitrator;


architecture europa of m95320_spi_control_port_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_m95320_spi_control_port :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_m95320_spi_control_port :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_m95320_spi_control_port :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_m95320_spi_control_port :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_m95320_spi_control_port :  STD_LOGIC;
                signal m95320_spi_control_port_allgrants :  STD_LOGIC;
                signal m95320_spi_control_port_allow_new_arb_cycle :  STD_LOGIC;
                signal m95320_spi_control_port_any_bursting_master_saved_grant :  STD_LOGIC;
                signal m95320_spi_control_port_any_continuerequest :  STD_LOGIC;
                signal m95320_spi_control_port_arb_counter_enable :  STD_LOGIC;
                signal m95320_spi_control_port_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal m95320_spi_control_port_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal m95320_spi_control_port_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal m95320_spi_control_port_beginbursttransfer_internal :  STD_LOGIC;
                signal m95320_spi_control_port_begins_xfer :  STD_LOGIC;
                signal m95320_spi_control_port_end_xfer :  STD_LOGIC;
                signal m95320_spi_control_port_firsttransfer :  STD_LOGIC;
                signal m95320_spi_control_port_grant_vector :  STD_LOGIC;
                signal m95320_spi_control_port_in_a_read_cycle :  STD_LOGIC;
                signal m95320_spi_control_port_in_a_write_cycle :  STD_LOGIC;
                signal m95320_spi_control_port_master_qreq_vector :  STD_LOGIC;
                signal m95320_spi_control_port_non_bursting_master_requests :  STD_LOGIC;
                signal m95320_spi_control_port_reg_firsttransfer :  STD_LOGIC;
                signal m95320_spi_control_port_slavearbiterlockenable :  STD_LOGIC;
                signal m95320_spi_control_port_slavearbiterlockenable2 :  STD_LOGIC;
                signal m95320_spi_control_port_unreg_firsttransfer :  STD_LOGIC;
                signal m95320_spi_control_port_waits_for_read :  STD_LOGIC;
                signal m95320_spi_control_port_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_m95320_spi_control_port_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_m95320_spi_control_port_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT m95320_spi_control_port_end_xfer;
    end if;

  end process;

  m95320_spi_control_port_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_m95320_spi_control_port);
  --assign m95320_spi_control_port_readdata_from_sa = m95320_spi_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  m95320_spi_control_port_readdata_from_sa <= m95320_spi_control_port_readdata;
  internal_cpu_0_data_master_requests_m95320_spi_control_port <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000100000110100000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign m95320_spi_control_port_dataavailable_from_sa = m95320_spi_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  m95320_spi_control_port_dataavailable_from_sa <= m95320_spi_control_port_dataavailable;
  --assign m95320_spi_control_port_readyfordata_from_sa = m95320_spi_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  m95320_spi_control_port_readyfordata_from_sa <= m95320_spi_control_port_readyfordata;
  --m95320_spi_control_port_arb_share_counter set values, which is an e_mux
  m95320_spi_control_port_arb_share_set_values <= std_logic_vector'("001");
  --m95320_spi_control_port_non_bursting_master_requests mux, which is an e_mux
  m95320_spi_control_port_non_bursting_master_requests <= internal_cpu_0_data_master_requests_m95320_spi_control_port;
  --m95320_spi_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  m95320_spi_control_port_any_bursting_master_saved_grant <= std_logic'('0');
  --m95320_spi_control_port_arb_share_counter_next_value assignment, which is an e_assign
  m95320_spi_control_port_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(m95320_spi_control_port_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (m95320_spi_control_port_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(m95320_spi_control_port_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (m95320_spi_control_port_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --m95320_spi_control_port_allgrants all slave grants, which is an e_mux
  m95320_spi_control_port_allgrants <= m95320_spi_control_port_grant_vector;
  --m95320_spi_control_port_end_xfer assignment, which is an e_assign
  m95320_spi_control_port_end_xfer <= NOT ((m95320_spi_control_port_waits_for_read OR m95320_spi_control_port_waits_for_write));
  --end_xfer_arb_share_counter_term_m95320_spi_control_port arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_m95320_spi_control_port <= m95320_spi_control_port_end_xfer AND (((NOT m95320_spi_control_port_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --m95320_spi_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  m95320_spi_control_port_arb_counter_enable <= ((end_xfer_arb_share_counter_term_m95320_spi_control_port AND m95320_spi_control_port_allgrants)) OR ((end_xfer_arb_share_counter_term_m95320_spi_control_port AND NOT m95320_spi_control_port_non_bursting_master_requests));
  --m95320_spi_control_port_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      m95320_spi_control_port_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(m95320_spi_control_port_arb_counter_enable) = '1' then 
        m95320_spi_control_port_arb_share_counter <= m95320_spi_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --m95320_spi_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      m95320_spi_control_port_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((m95320_spi_control_port_master_qreq_vector AND end_xfer_arb_share_counter_term_m95320_spi_control_port)) OR ((end_xfer_arb_share_counter_term_m95320_spi_control_port AND NOT m95320_spi_control_port_non_bursting_master_requests)))) = '1' then 
        m95320_spi_control_port_slavearbiterlockenable <= or_reduce(m95320_spi_control_port_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master m95320/spi_control_port arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= m95320_spi_control_port_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --m95320_spi_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  m95320_spi_control_port_slavearbiterlockenable2 <= or_reduce(m95320_spi_control_port_arb_share_counter_next_value);
  --cpu_0/data_master m95320/spi_control_port arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= m95320_spi_control_port_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --m95320_spi_control_port_any_continuerequest at least one master continues requesting, which is an e_assign
  m95320_spi_control_port_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_m95320_spi_control_port <= internal_cpu_0_data_master_requests_m95320_spi_control_port;
  --m95320_spi_control_port_writedata mux, which is an e_mux
  m95320_spi_control_port_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --assign m95320_spi_control_port_endofpacket_from_sa = m95320_spi_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  m95320_spi_control_port_endofpacket_from_sa <= m95320_spi_control_port_endofpacket;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_m95320_spi_control_port <= internal_cpu_0_data_master_qualified_request_m95320_spi_control_port;
  --cpu_0/data_master saved-grant m95320/spi_control_port, which is an e_assign
  cpu_0_data_master_saved_grant_m95320_spi_control_port <= internal_cpu_0_data_master_requests_m95320_spi_control_port;
  --allow new arb cycle for m95320/spi_control_port, which is an e_assign
  m95320_spi_control_port_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  m95320_spi_control_port_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  m95320_spi_control_port_master_qreq_vector <= std_logic'('1');
  --m95320_spi_control_port_reset_n assignment, which is an e_assign
  m95320_spi_control_port_reset_n <= reset_n;
  m95320_spi_control_port_chipselect <= internal_cpu_0_data_master_granted_m95320_spi_control_port;
  --m95320_spi_control_port_firsttransfer first transaction, which is an e_assign
  m95320_spi_control_port_firsttransfer <= A_WE_StdLogic((std_logic'(m95320_spi_control_port_begins_xfer) = '1'), m95320_spi_control_port_unreg_firsttransfer, m95320_spi_control_port_reg_firsttransfer);
  --m95320_spi_control_port_unreg_firsttransfer first transaction, which is an e_assign
  m95320_spi_control_port_unreg_firsttransfer <= NOT ((m95320_spi_control_port_slavearbiterlockenable AND m95320_spi_control_port_any_continuerequest));
  --m95320_spi_control_port_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      m95320_spi_control_port_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(m95320_spi_control_port_begins_xfer) = '1' then 
        m95320_spi_control_port_reg_firsttransfer <= m95320_spi_control_port_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --m95320_spi_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  m95320_spi_control_port_beginbursttransfer_internal <= m95320_spi_control_port_begins_xfer;
  --~m95320_spi_control_port_read_n assignment, which is an e_mux
  m95320_spi_control_port_read_n <= NOT ((internal_cpu_0_data_master_granted_m95320_spi_control_port AND cpu_0_data_master_read));
  --~m95320_spi_control_port_write_n assignment, which is an e_mux
  m95320_spi_control_port_write_n <= NOT ((internal_cpu_0_data_master_granted_m95320_spi_control_port AND cpu_0_data_master_write));
  shifted_address_to_m95320_spi_control_port_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --m95320_spi_control_port_address mux, which is an e_mux
  m95320_spi_control_port_address <= A_EXT (A_SRL(shifted_address_to_m95320_spi_control_port_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_m95320_spi_control_port_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_m95320_spi_control_port_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_m95320_spi_control_port_end_xfer <= m95320_spi_control_port_end_xfer;
    end if;

  end process;

  --m95320_spi_control_port_waits_for_read in a cycle, which is an e_mux
  m95320_spi_control_port_waits_for_read <= m95320_spi_control_port_in_a_read_cycle AND m95320_spi_control_port_begins_xfer;
  --m95320_spi_control_port_in_a_read_cycle assignment, which is an e_assign
  m95320_spi_control_port_in_a_read_cycle <= internal_cpu_0_data_master_granted_m95320_spi_control_port AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= m95320_spi_control_port_in_a_read_cycle;
  --m95320_spi_control_port_waits_for_write in a cycle, which is an e_mux
  m95320_spi_control_port_waits_for_write <= m95320_spi_control_port_in_a_write_cycle AND m95320_spi_control_port_begins_xfer;
  --m95320_spi_control_port_in_a_write_cycle assignment, which is an e_assign
  m95320_spi_control_port_in_a_write_cycle <= internal_cpu_0_data_master_granted_m95320_spi_control_port AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= m95320_spi_control_port_in_a_write_cycle;
  wait_for_m95320_spi_control_port_counter <= std_logic'('0');
  --assign m95320_spi_control_port_irq_from_sa = m95320_spi_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  m95320_spi_control_port_irq_from_sa <= m95320_spi_control_port_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_m95320_spi_control_port <= internal_cpu_0_data_master_granted_m95320_spi_control_port;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_m95320_spi_control_port <= internal_cpu_0_data_master_qualified_request_m95320_spi_control_port;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_m95320_spi_control_port <= internal_cpu_0_data_master_requests_m95320_spi_control_port;
--synthesis translate_off
    --m95320/spi_control_port enable non-zero assertions, which is an e_register
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

entity one_wire_interface_0_avalon_slave_0_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal one_wire_interface_0_avalon_slave_0_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal one_wire_interface_0_avalon_slave_0_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                 signal d1_one_wire_interface_0_avalon_slave_0_end_xfer : OUT STD_LOGIC;
                 signal one_wire_interface_0_avalon_slave_0_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal one_wire_interface_0_avalon_slave_0_chipselect : OUT STD_LOGIC;
                 signal one_wire_interface_0_avalon_slave_0_read : OUT STD_LOGIC;
                 signal one_wire_interface_0_avalon_slave_0_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal one_wire_interface_0_avalon_slave_0_reset : OUT STD_LOGIC;
                 signal one_wire_interface_0_avalon_slave_0_waitrequest_from_sa : OUT STD_LOGIC;
                 signal one_wire_interface_0_avalon_slave_0_write : OUT STD_LOGIC;
                 signal one_wire_interface_0_avalon_slave_0_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
              );
end entity one_wire_interface_0_avalon_slave_0_arbitrator;


architecture europa of one_wire_interface_0_avalon_slave_0_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal internal_one_wire_interface_0_avalon_slave_0_waitrequest_from_sa :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_allgrants :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_allow_new_arb_cycle :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_any_bursting_master_saved_grant :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_any_continuerequest :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_arb_counter_enable :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal one_wire_interface_0_avalon_slave_0_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal one_wire_interface_0_avalon_slave_0_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal one_wire_interface_0_avalon_slave_0_beginbursttransfer_internal :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_begins_xfer :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_end_xfer :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_firsttransfer :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_grant_vector :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_in_a_read_cycle :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_in_a_write_cycle :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_master_qreq_vector :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_non_bursting_master_requests :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_pretend_byte_enable :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_reg_firsttransfer :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_slavearbiterlockenable :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_slavearbiterlockenable2 :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_unreg_firsttransfer :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_waits_for_read :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_one_wire_interface_0_avalon_slave_0_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_one_wire_interface_0_avalon_slave_0_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT one_wire_interface_0_avalon_slave_0_end_xfer;
    end if;

  end process;

  one_wire_interface_0_avalon_slave_0_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0);
  --assign one_wire_interface_0_avalon_slave_0_readdata_from_sa = one_wire_interface_0_avalon_slave_0_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  one_wire_interface_0_avalon_slave_0_readdata_from_sa <= one_wire_interface_0_avalon_slave_0_readdata;
  internal_cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 6) & std_logic_vector'("000000")) = std_logic_vector'("0000000000000100000000001000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign one_wire_interface_0_avalon_slave_0_waitrequest_from_sa = one_wire_interface_0_avalon_slave_0_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_one_wire_interface_0_avalon_slave_0_waitrequest_from_sa <= one_wire_interface_0_avalon_slave_0_waitrequest;
  --one_wire_interface_0_avalon_slave_0_arb_share_counter set values, which is an e_mux
  one_wire_interface_0_avalon_slave_0_arb_share_set_values <= std_logic_vector'("001");
  --one_wire_interface_0_avalon_slave_0_non_bursting_master_requests mux, which is an e_mux
  one_wire_interface_0_avalon_slave_0_non_bursting_master_requests <= internal_cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0;
  --one_wire_interface_0_avalon_slave_0_any_bursting_master_saved_grant mux, which is an e_mux
  one_wire_interface_0_avalon_slave_0_any_bursting_master_saved_grant <= std_logic'('0');
  --one_wire_interface_0_avalon_slave_0_arb_share_counter_next_value assignment, which is an e_assign
  one_wire_interface_0_avalon_slave_0_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(one_wire_interface_0_avalon_slave_0_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (one_wire_interface_0_avalon_slave_0_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(one_wire_interface_0_avalon_slave_0_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (one_wire_interface_0_avalon_slave_0_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --one_wire_interface_0_avalon_slave_0_allgrants all slave grants, which is an e_mux
  one_wire_interface_0_avalon_slave_0_allgrants <= one_wire_interface_0_avalon_slave_0_grant_vector;
  --one_wire_interface_0_avalon_slave_0_end_xfer assignment, which is an e_assign
  one_wire_interface_0_avalon_slave_0_end_xfer <= NOT ((one_wire_interface_0_avalon_slave_0_waits_for_read OR one_wire_interface_0_avalon_slave_0_waits_for_write));
  --end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0 <= one_wire_interface_0_avalon_slave_0_end_xfer AND (((NOT one_wire_interface_0_avalon_slave_0_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --one_wire_interface_0_avalon_slave_0_arb_share_counter arbitration counter enable, which is an e_assign
  one_wire_interface_0_avalon_slave_0_arb_counter_enable <= ((end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0 AND one_wire_interface_0_avalon_slave_0_allgrants)) OR ((end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0 AND NOT one_wire_interface_0_avalon_slave_0_non_bursting_master_requests));
  --one_wire_interface_0_avalon_slave_0_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      one_wire_interface_0_avalon_slave_0_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(one_wire_interface_0_avalon_slave_0_arb_counter_enable) = '1' then 
        one_wire_interface_0_avalon_slave_0_arb_share_counter <= one_wire_interface_0_avalon_slave_0_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --one_wire_interface_0_avalon_slave_0_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      one_wire_interface_0_avalon_slave_0_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((one_wire_interface_0_avalon_slave_0_master_qreq_vector AND end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0)) OR ((end_xfer_arb_share_counter_term_one_wire_interface_0_avalon_slave_0 AND NOT one_wire_interface_0_avalon_slave_0_non_bursting_master_requests)))) = '1' then 
        one_wire_interface_0_avalon_slave_0_slavearbiterlockenable <= or_reduce(one_wire_interface_0_avalon_slave_0_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master one_wire_interface_0/avalon_slave_0 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= one_wire_interface_0_avalon_slave_0_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --one_wire_interface_0_avalon_slave_0_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  one_wire_interface_0_avalon_slave_0_slavearbiterlockenable2 <= or_reduce(one_wire_interface_0_avalon_slave_0_arb_share_counter_next_value);
  --cpu_0/data_master one_wire_interface_0/avalon_slave_0 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= one_wire_interface_0_avalon_slave_0_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --one_wire_interface_0_avalon_slave_0_any_continuerequest at least one master continues requesting, which is an e_assign
  one_wire_interface_0_avalon_slave_0_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 <= internal_cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 AND NOT ((((cpu_0_data_master_read AND (NOT cpu_0_data_master_waitrequest))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))));
  --one_wire_interface_0_avalon_slave_0_writedata mux, which is an e_mux
  one_wire_interface_0_avalon_slave_0_writedata <= cpu_0_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 <= internal_cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0;
  --cpu_0/data_master saved-grant one_wire_interface_0/avalon_slave_0, which is an e_assign
  cpu_0_data_master_saved_grant_one_wire_interface_0_avalon_slave_0 <= internal_cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0;
  --allow new arb cycle for one_wire_interface_0/avalon_slave_0, which is an e_assign
  one_wire_interface_0_avalon_slave_0_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  one_wire_interface_0_avalon_slave_0_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  one_wire_interface_0_avalon_slave_0_master_qreq_vector <= std_logic'('1');
  --~one_wire_interface_0_avalon_slave_0_reset assignment, which is an e_assign
  one_wire_interface_0_avalon_slave_0_reset <= NOT reset_n;
  one_wire_interface_0_avalon_slave_0_chipselect <= internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0;
  --one_wire_interface_0_avalon_slave_0_firsttransfer first transaction, which is an e_assign
  one_wire_interface_0_avalon_slave_0_firsttransfer <= A_WE_StdLogic((std_logic'(one_wire_interface_0_avalon_slave_0_begins_xfer) = '1'), one_wire_interface_0_avalon_slave_0_unreg_firsttransfer, one_wire_interface_0_avalon_slave_0_reg_firsttransfer);
  --one_wire_interface_0_avalon_slave_0_unreg_firsttransfer first transaction, which is an e_assign
  one_wire_interface_0_avalon_slave_0_unreg_firsttransfer <= NOT ((one_wire_interface_0_avalon_slave_0_slavearbiterlockenable AND one_wire_interface_0_avalon_slave_0_any_continuerequest));
  --one_wire_interface_0_avalon_slave_0_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      one_wire_interface_0_avalon_slave_0_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(one_wire_interface_0_avalon_slave_0_begins_xfer) = '1' then 
        one_wire_interface_0_avalon_slave_0_reg_firsttransfer <= one_wire_interface_0_avalon_slave_0_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --one_wire_interface_0_avalon_slave_0_beginbursttransfer_internal begin burst transfer, which is an e_assign
  one_wire_interface_0_avalon_slave_0_beginbursttransfer_internal <= one_wire_interface_0_avalon_slave_0_begins_xfer;
  --one_wire_interface_0_avalon_slave_0_read assignment, which is an e_mux
  one_wire_interface_0_avalon_slave_0_read <= internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 AND cpu_0_data_master_read;
  --one_wire_interface_0_avalon_slave_0_write assignment, which is an e_mux
  one_wire_interface_0_avalon_slave_0_write <= ((internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 AND cpu_0_data_master_write)) AND one_wire_interface_0_avalon_slave_0_pretend_byte_enable;
  shifted_address_to_one_wire_interface_0_avalon_slave_0_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --one_wire_interface_0_avalon_slave_0_address mux, which is an e_mux
  one_wire_interface_0_avalon_slave_0_address <= A_EXT (A_SRL(shifted_address_to_one_wire_interface_0_avalon_slave_0_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 4);
  --d1_one_wire_interface_0_avalon_slave_0_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_one_wire_interface_0_avalon_slave_0_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_one_wire_interface_0_avalon_slave_0_end_xfer <= one_wire_interface_0_avalon_slave_0_end_xfer;
    end if;

  end process;

  --one_wire_interface_0_avalon_slave_0_waits_for_read in a cycle, which is an e_mux
  one_wire_interface_0_avalon_slave_0_waits_for_read <= one_wire_interface_0_avalon_slave_0_in_a_read_cycle AND internal_one_wire_interface_0_avalon_slave_0_waitrequest_from_sa;
  --one_wire_interface_0_avalon_slave_0_in_a_read_cycle assignment, which is an e_assign
  one_wire_interface_0_avalon_slave_0_in_a_read_cycle <= internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= one_wire_interface_0_avalon_slave_0_in_a_read_cycle;
  --one_wire_interface_0_avalon_slave_0_waits_for_write in a cycle, which is an e_mux
  one_wire_interface_0_avalon_slave_0_waits_for_write <= one_wire_interface_0_avalon_slave_0_in_a_write_cycle AND internal_one_wire_interface_0_avalon_slave_0_waitrequest_from_sa;
  --one_wire_interface_0_avalon_slave_0_in_a_write_cycle assignment, which is an e_assign
  one_wire_interface_0_avalon_slave_0_in_a_write_cycle <= internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= one_wire_interface_0_avalon_slave_0_in_a_write_cycle;
  wait_for_one_wire_interface_0_avalon_slave_0_counter <= std_logic'('0');
  --one_wire_interface_0_avalon_slave_0_pretend_byte_enable byte enable port mux, which is an e_mux
  one_wire_interface_0_avalon_slave_0_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 <= internal_cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 <= internal_cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 <= internal_cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0;
  --vhdl renameroo for output signals
  one_wire_interface_0_avalon_slave_0_waitrequest_from_sa <= internal_one_wire_interface_0_avalon_slave_0_waitrequest_from_sa;
--synthesis translate_off
    --one_wire_interface_0/avalon_slave_0 enable non-zero assertions, which is an e_register
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

entity oxu210hp_if_0_s0_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal oxu210hp_if_0_s0_irq : IN STD_LOGIC;
                 signal oxu210hp_if_0_s0_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal oxu210hp_if_0_s0_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                 signal d1_oxu210hp_if_0_s0_end_xfer : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_address : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
                 signal oxu210hp_if_0_s0_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal oxu210hp_if_0_s0_chipselect : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_irq_from_sa : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_read : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal oxu210hp_if_0_s0_reset : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_waitrequest_from_sa : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_write : OUT STD_LOGIC;
                 signal oxu210hp_if_0_s0_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity oxu210hp_if_0_s0_arbitrator;


architecture europa of oxu210hp_if_0_s0_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal internal_oxu210hp_if_0_s0_waitrequest_from_sa :  STD_LOGIC;
                signal oxu210hp_if_0_s0_allgrants :  STD_LOGIC;
                signal oxu210hp_if_0_s0_allow_new_arb_cycle :  STD_LOGIC;
                signal oxu210hp_if_0_s0_any_bursting_master_saved_grant :  STD_LOGIC;
                signal oxu210hp_if_0_s0_any_continuerequest :  STD_LOGIC;
                signal oxu210hp_if_0_s0_arb_counter_enable :  STD_LOGIC;
                signal oxu210hp_if_0_s0_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal oxu210hp_if_0_s0_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal oxu210hp_if_0_s0_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal oxu210hp_if_0_s0_beginbursttransfer_internal :  STD_LOGIC;
                signal oxu210hp_if_0_s0_begins_xfer :  STD_LOGIC;
                signal oxu210hp_if_0_s0_end_xfer :  STD_LOGIC;
                signal oxu210hp_if_0_s0_firsttransfer :  STD_LOGIC;
                signal oxu210hp_if_0_s0_grant_vector :  STD_LOGIC;
                signal oxu210hp_if_0_s0_in_a_read_cycle :  STD_LOGIC;
                signal oxu210hp_if_0_s0_in_a_write_cycle :  STD_LOGIC;
                signal oxu210hp_if_0_s0_master_qreq_vector :  STD_LOGIC;
                signal oxu210hp_if_0_s0_non_bursting_master_requests :  STD_LOGIC;
                signal oxu210hp_if_0_s0_reg_firsttransfer :  STD_LOGIC;
                signal oxu210hp_if_0_s0_slavearbiterlockenable :  STD_LOGIC;
                signal oxu210hp_if_0_s0_slavearbiterlockenable2 :  STD_LOGIC;
                signal oxu210hp_if_0_s0_unreg_firsttransfer :  STD_LOGIC;
                signal oxu210hp_if_0_s0_waits_for_read :  STD_LOGIC;
                signal oxu210hp_if_0_s0_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_oxu210hp_if_0_s0_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_oxu210hp_if_0_s0_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT oxu210hp_if_0_s0_end_xfer;
    end if;

  end process;

  oxu210hp_if_0_s0_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_oxu210hp_if_0_s0);
  --assign oxu210hp_if_0_s0_readdata_from_sa = oxu210hp_if_0_s0_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  oxu210hp_if_0_s0_readdata_from_sa <= oxu210hp_if_0_s0_readdata;
  internal_cpu_0_data_master_requests_oxu210hp_if_0_s0 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 17) & std_logic_vector'("00000000000000000")) = std_logic_vector'("0000000000000000000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign oxu210hp_if_0_s0_waitrequest_from_sa = oxu210hp_if_0_s0_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_oxu210hp_if_0_s0_waitrequest_from_sa <= oxu210hp_if_0_s0_waitrequest;
  --oxu210hp_if_0_s0_arb_share_counter set values, which is an e_mux
  oxu210hp_if_0_s0_arb_share_set_values <= std_logic_vector'("001");
  --oxu210hp_if_0_s0_non_bursting_master_requests mux, which is an e_mux
  oxu210hp_if_0_s0_non_bursting_master_requests <= internal_cpu_0_data_master_requests_oxu210hp_if_0_s0;
  --oxu210hp_if_0_s0_any_bursting_master_saved_grant mux, which is an e_mux
  oxu210hp_if_0_s0_any_bursting_master_saved_grant <= std_logic'('0');
  --oxu210hp_if_0_s0_arb_share_counter_next_value assignment, which is an e_assign
  oxu210hp_if_0_s0_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(oxu210hp_if_0_s0_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (oxu210hp_if_0_s0_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(oxu210hp_if_0_s0_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (oxu210hp_if_0_s0_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --oxu210hp_if_0_s0_allgrants all slave grants, which is an e_mux
  oxu210hp_if_0_s0_allgrants <= oxu210hp_if_0_s0_grant_vector;
  --oxu210hp_if_0_s0_end_xfer assignment, which is an e_assign
  oxu210hp_if_0_s0_end_xfer <= NOT ((oxu210hp_if_0_s0_waits_for_read OR oxu210hp_if_0_s0_waits_for_write));
  --end_xfer_arb_share_counter_term_oxu210hp_if_0_s0 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_oxu210hp_if_0_s0 <= oxu210hp_if_0_s0_end_xfer AND (((NOT oxu210hp_if_0_s0_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --oxu210hp_if_0_s0_arb_share_counter arbitration counter enable, which is an e_assign
  oxu210hp_if_0_s0_arb_counter_enable <= ((end_xfer_arb_share_counter_term_oxu210hp_if_0_s0 AND oxu210hp_if_0_s0_allgrants)) OR ((end_xfer_arb_share_counter_term_oxu210hp_if_0_s0 AND NOT oxu210hp_if_0_s0_non_bursting_master_requests));
  --oxu210hp_if_0_s0_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      oxu210hp_if_0_s0_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(oxu210hp_if_0_s0_arb_counter_enable) = '1' then 
        oxu210hp_if_0_s0_arb_share_counter <= oxu210hp_if_0_s0_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --oxu210hp_if_0_s0_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      oxu210hp_if_0_s0_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((oxu210hp_if_0_s0_master_qreq_vector AND end_xfer_arb_share_counter_term_oxu210hp_if_0_s0)) OR ((end_xfer_arb_share_counter_term_oxu210hp_if_0_s0 AND NOT oxu210hp_if_0_s0_non_bursting_master_requests)))) = '1' then 
        oxu210hp_if_0_s0_slavearbiterlockenable <= or_reduce(oxu210hp_if_0_s0_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master oxu210hp_if_0/s0 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= oxu210hp_if_0_s0_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --oxu210hp_if_0_s0_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  oxu210hp_if_0_s0_slavearbiterlockenable2 <= or_reduce(oxu210hp_if_0_s0_arb_share_counter_next_value);
  --cpu_0/data_master oxu210hp_if_0/s0 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= oxu210hp_if_0_s0_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --oxu210hp_if_0_s0_any_continuerequest at least one master continues requesting, which is an e_assign
  oxu210hp_if_0_s0_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 <= internal_cpu_0_data_master_requests_oxu210hp_if_0_s0 AND NOT ((((cpu_0_data_master_read AND (NOT cpu_0_data_master_waitrequest))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))));
  --oxu210hp_if_0_s0_writedata mux, which is an e_mux
  oxu210hp_if_0_s0_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_oxu210hp_if_0_s0 <= internal_cpu_0_data_master_qualified_request_oxu210hp_if_0_s0;
  --cpu_0/data_master saved-grant oxu210hp_if_0/s0, which is an e_assign
  cpu_0_data_master_saved_grant_oxu210hp_if_0_s0 <= internal_cpu_0_data_master_requests_oxu210hp_if_0_s0;
  --allow new arb cycle for oxu210hp_if_0/s0, which is an e_assign
  oxu210hp_if_0_s0_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  oxu210hp_if_0_s0_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  oxu210hp_if_0_s0_master_qreq_vector <= std_logic'('1');
  --~oxu210hp_if_0_s0_reset assignment, which is an e_assign
  oxu210hp_if_0_s0_reset <= NOT reset_n;
  oxu210hp_if_0_s0_chipselect <= internal_cpu_0_data_master_granted_oxu210hp_if_0_s0;
  --oxu210hp_if_0_s0_firsttransfer first transaction, which is an e_assign
  oxu210hp_if_0_s0_firsttransfer <= A_WE_StdLogic((std_logic'(oxu210hp_if_0_s0_begins_xfer) = '1'), oxu210hp_if_0_s0_unreg_firsttransfer, oxu210hp_if_0_s0_reg_firsttransfer);
  --oxu210hp_if_0_s0_unreg_firsttransfer first transaction, which is an e_assign
  oxu210hp_if_0_s0_unreg_firsttransfer <= NOT ((oxu210hp_if_0_s0_slavearbiterlockenable AND oxu210hp_if_0_s0_any_continuerequest));
  --oxu210hp_if_0_s0_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      oxu210hp_if_0_s0_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(oxu210hp_if_0_s0_begins_xfer) = '1' then 
        oxu210hp_if_0_s0_reg_firsttransfer <= oxu210hp_if_0_s0_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --oxu210hp_if_0_s0_beginbursttransfer_internal begin burst transfer, which is an e_assign
  oxu210hp_if_0_s0_beginbursttransfer_internal <= oxu210hp_if_0_s0_begins_xfer;
  --oxu210hp_if_0_s0_read assignment, which is an e_mux
  oxu210hp_if_0_s0_read <= internal_cpu_0_data_master_granted_oxu210hp_if_0_s0 AND cpu_0_data_master_read;
  --oxu210hp_if_0_s0_write assignment, which is an e_mux
  oxu210hp_if_0_s0_write <= internal_cpu_0_data_master_granted_oxu210hp_if_0_s0 AND cpu_0_data_master_write;
  shifted_address_to_oxu210hp_if_0_s0_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --oxu210hp_if_0_s0_address mux, which is an e_mux
  oxu210hp_if_0_s0_address <= A_EXT (A_SRL(shifted_address_to_oxu210hp_if_0_s0_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 15);
  --d1_oxu210hp_if_0_s0_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_oxu210hp_if_0_s0_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_oxu210hp_if_0_s0_end_xfer <= oxu210hp_if_0_s0_end_xfer;
    end if;

  end process;

  --oxu210hp_if_0_s0_waits_for_read in a cycle, which is an e_mux
  oxu210hp_if_0_s0_waits_for_read <= oxu210hp_if_0_s0_in_a_read_cycle AND internal_oxu210hp_if_0_s0_waitrequest_from_sa;
  --oxu210hp_if_0_s0_in_a_read_cycle assignment, which is an e_assign
  oxu210hp_if_0_s0_in_a_read_cycle <= internal_cpu_0_data_master_granted_oxu210hp_if_0_s0 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= oxu210hp_if_0_s0_in_a_read_cycle;
  --oxu210hp_if_0_s0_waits_for_write in a cycle, which is an e_mux
  oxu210hp_if_0_s0_waits_for_write <= oxu210hp_if_0_s0_in_a_write_cycle AND internal_oxu210hp_if_0_s0_waitrequest_from_sa;
  --oxu210hp_if_0_s0_in_a_write_cycle assignment, which is an e_assign
  oxu210hp_if_0_s0_in_a_write_cycle <= internal_cpu_0_data_master_granted_oxu210hp_if_0_s0 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= oxu210hp_if_0_s0_in_a_write_cycle;
  wait_for_oxu210hp_if_0_s0_counter <= std_logic'('0');
  --oxu210hp_if_0_s0_byteenable byte enable port mux, which is an e_mux
  oxu210hp_if_0_s0_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_oxu210hp_if_0_s0)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --assign oxu210hp_if_0_s0_irq_from_sa = oxu210hp_if_0_s0_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  oxu210hp_if_0_s0_irq_from_sa <= oxu210hp_if_0_s0_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_oxu210hp_if_0_s0 <= internal_cpu_0_data_master_granted_oxu210hp_if_0_s0;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 <= internal_cpu_0_data_master_qualified_request_oxu210hp_if_0_s0;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_oxu210hp_if_0_s0 <= internal_cpu_0_data_master_requests_oxu210hp_if_0_s0;
  --vhdl renameroo for output signals
  oxu210hp_if_0_s0_waitrequest_from_sa <= internal_oxu210hp_if_0_s0_waitrequest_from_sa;
--synthesis translate_off
    --oxu210hp_if_0/s0 enable non-zero assertions, which is an e_register
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

entity oxu210hp_int_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal oxu210hp_int_s1_irq : IN STD_LOGIC;
                 signal oxu210hp_int_s1_readdata : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_oxu210hp_int_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_oxu210hp_int_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_oxu210hp_int_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_oxu210hp_int_s1 : OUT STD_LOGIC;
                 signal d1_oxu210hp_int_s1_end_xfer : OUT STD_LOGIC;
                 signal oxu210hp_int_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal oxu210hp_int_s1_chipselect : OUT STD_LOGIC;
                 signal oxu210hp_int_s1_irq_from_sa : OUT STD_LOGIC;
                 signal oxu210hp_int_s1_readdata_from_sa : OUT STD_LOGIC;
                 signal oxu210hp_int_s1_reset_n : OUT STD_LOGIC;
                 signal oxu210hp_int_s1_write_n : OUT STD_LOGIC;
                 signal oxu210hp_int_s1_writedata : OUT STD_LOGIC
              );
end entity oxu210hp_int_s1_arbitrator;


architecture europa of oxu210hp_int_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_oxu210hp_int_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_oxu210hp_int_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_oxu210hp_int_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_oxu210hp_int_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_oxu210hp_int_s1 :  STD_LOGIC;
                signal oxu210hp_int_s1_allgrants :  STD_LOGIC;
                signal oxu210hp_int_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal oxu210hp_int_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal oxu210hp_int_s1_any_continuerequest :  STD_LOGIC;
                signal oxu210hp_int_s1_arb_counter_enable :  STD_LOGIC;
                signal oxu210hp_int_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal oxu210hp_int_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal oxu210hp_int_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal oxu210hp_int_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal oxu210hp_int_s1_begins_xfer :  STD_LOGIC;
                signal oxu210hp_int_s1_end_xfer :  STD_LOGIC;
                signal oxu210hp_int_s1_firsttransfer :  STD_LOGIC;
                signal oxu210hp_int_s1_grant_vector :  STD_LOGIC;
                signal oxu210hp_int_s1_in_a_read_cycle :  STD_LOGIC;
                signal oxu210hp_int_s1_in_a_write_cycle :  STD_LOGIC;
                signal oxu210hp_int_s1_master_qreq_vector :  STD_LOGIC;
                signal oxu210hp_int_s1_non_bursting_master_requests :  STD_LOGIC;
                signal oxu210hp_int_s1_reg_firsttransfer :  STD_LOGIC;
                signal oxu210hp_int_s1_slavearbiterlockenable :  STD_LOGIC;
                signal oxu210hp_int_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal oxu210hp_int_s1_unreg_firsttransfer :  STD_LOGIC;
                signal oxu210hp_int_s1_waits_for_read :  STD_LOGIC;
                signal oxu210hp_int_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_oxu210hp_int_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal wait_for_oxu210hp_int_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT oxu210hp_int_s1_end_xfer;
    end if;

  end process;

  oxu210hp_int_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_oxu210hp_int_s1);
  --assign oxu210hp_int_s1_readdata_from_sa = oxu210hp_int_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  oxu210hp_int_s1_readdata_from_sa <= oxu210hp_int_s1_readdata;
  internal_cpu_0_data_master_requests_oxu210hp_int_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100001000100000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --oxu210hp_int_s1_arb_share_counter set values, which is an e_mux
  oxu210hp_int_s1_arb_share_set_values <= std_logic_vector'("001");
  --oxu210hp_int_s1_non_bursting_master_requests mux, which is an e_mux
  oxu210hp_int_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_oxu210hp_int_s1;
  --oxu210hp_int_s1_any_bursting_master_saved_grant mux, which is an e_mux
  oxu210hp_int_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --oxu210hp_int_s1_arb_share_counter_next_value assignment, which is an e_assign
  oxu210hp_int_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(oxu210hp_int_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (oxu210hp_int_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(oxu210hp_int_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (oxu210hp_int_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --oxu210hp_int_s1_allgrants all slave grants, which is an e_mux
  oxu210hp_int_s1_allgrants <= oxu210hp_int_s1_grant_vector;
  --oxu210hp_int_s1_end_xfer assignment, which is an e_assign
  oxu210hp_int_s1_end_xfer <= NOT ((oxu210hp_int_s1_waits_for_read OR oxu210hp_int_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_oxu210hp_int_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_oxu210hp_int_s1 <= oxu210hp_int_s1_end_xfer AND (((NOT oxu210hp_int_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --oxu210hp_int_s1_arb_share_counter arbitration counter enable, which is an e_assign
  oxu210hp_int_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_oxu210hp_int_s1 AND oxu210hp_int_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_oxu210hp_int_s1 AND NOT oxu210hp_int_s1_non_bursting_master_requests));
  --oxu210hp_int_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      oxu210hp_int_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(oxu210hp_int_s1_arb_counter_enable) = '1' then 
        oxu210hp_int_s1_arb_share_counter <= oxu210hp_int_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --oxu210hp_int_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      oxu210hp_int_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((oxu210hp_int_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_oxu210hp_int_s1)) OR ((end_xfer_arb_share_counter_term_oxu210hp_int_s1 AND NOT oxu210hp_int_s1_non_bursting_master_requests)))) = '1' then 
        oxu210hp_int_s1_slavearbiterlockenable <= or_reduce(oxu210hp_int_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master oxu210hp_int/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= oxu210hp_int_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --oxu210hp_int_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  oxu210hp_int_s1_slavearbiterlockenable2 <= or_reduce(oxu210hp_int_s1_arb_share_counter_next_value);
  --cpu_0/data_master oxu210hp_int/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= oxu210hp_int_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --oxu210hp_int_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  oxu210hp_int_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_oxu210hp_int_s1 <= internal_cpu_0_data_master_requests_oxu210hp_int_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --oxu210hp_int_s1_writedata mux, which is an e_mux
  oxu210hp_int_s1_writedata <= cpu_0_data_master_writedata(0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_oxu210hp_int_s1 <= internal_cpu_0_data_master_qualified_request_oxu210hp_int_s1;
  --cpu_0/data_master saved-grant oxu210hp_int/s1, which is an e_assign
  cpu_0_data_master_saved_grant_oxu210hp_int_s1 <= internal_cpu_0_data_master_requests_oxu210hp_int_s1;
  --allow new arb cycle for oxu210hp_int/s1, which is an e_assign
  oxu210hp_int_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  oxu210hp_int_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  oxu210hp_int_s1_master_qreq_vector <= std_logic'('1');
  --oxu210hp_int_s1_reset_n assignment, which is an e_assign
  oxu210hp_int_s1_reset_n <= reset_n;
  oxu210hp_int_s1_chipselect <= internal_cpu_0_data_master_granted_oxu210hp_int_s1;
  --oxu210hp_int_s1_firsttransfer first transaction, which is an e_assign
  oxu210hp_int_s1_firsttransfer <= A_WE_StdLogic((std_logic'(oxu210hp_int_s1_begins_xfer) = '1'), oxu210hp_int_s1_unreg_firsttransfer, oxu210hp_int_s1_reg_firsttransfer);
  --oxu210hp_int_s1_unreg_firsttransfer first transaction, which is an e_assign
  oxu210hp_int_s1_unreg_firsttransfer <= NOT ((oxu210hp_int_s1_slavearbiterlockenable AND oxu210hp_int_s1_any_continuerequest));
  --oxu210hp_int_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      oxu210hp_int_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(oxu210hp_int_s1_begins_xfer) = '1' then 
        oxu210hp_int_s1_reg_firsttransfer <= oxu210hp_int_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --oxu210hp_int_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  oxu210hp_int_s1_beginbursttransfer_internal <= oxu210hp_int_s1_begins_xfer;
  --~oxu210hp_int_s1_write_n assignment, which is an e_mux
  oxu210hp_int_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_oxu210hp_int_s1 AND cpu_0_data_master_write));
  shifted_address_to_oxu210hp_int_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --oxu210hp_int_s1_address mux, which is an e_mux
  oxu210hp_int_s1_address <= A_EXT (A_SRL(shifted_address_to_oxu210hp_int_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_oxu210hp_int_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_oxu210hp_int_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_oxu210hp_int_s1_end_xfer <= oxu210hp_int_s1_end_xfer;
    end if;

  end process;

  --oxu210hp_int_s1_waits_for_read in a cycle, which is an e_mux
  oxu210hp_int_s1_waits_for_read <= oxu210hp_int_s1_in_a_read_cycle AND oxu210hp_int_s1_begins_xfer;
  --oxu210hp_int_s1_in_a_read_cycle assignment, which is an e_assign
  oxu210hp_int_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_oxu210hp_int_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= oxu210hp_int_s1_in_a_read_cycle;
  --oxu210hp_int_s1_waits_for_write in a cycle, which is an e_mux
  oxu210hp_int_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(oxu210hp_int_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --oxu210hp_int_s1_in_a_write_cycle assignment, which is an e_assign
  oxu210hp_int_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_oxu210hp_int_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= oxu210hp_int_s1_in_a_write_cycle;
  wait_for_oxu210hp_int_s1_counter <= std_logic'('0');
  --assign oxu210hp_int_s1_irq_from_sa = oxu210hp_int_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  oxu210hp_int_s1_irq_from_sa <= oxu210hp_int_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_oxu210hp_int_s1 <= internal_cpu_0_data_master_granted_oxu210hp_int_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_oxu210hp_int_s1 <= internal_cpu_0_data_master_qualified_request_oxu210hp_int_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_oxu210hp_int_s1 <= internal_cpu_0_data_master_requests_oxu210hp_int_s1;
--synthesis translate_off
    --oxu210hp_int/s1 enable non-zero assertions, which is an e_register
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

entity spi_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal spi_pio_s1_irq : IN STD_LOGIC;
                 signal spi_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_spi_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_spi_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_spi_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_spi_pio_s1 : OUT STD_LOGIC;
                 signal d1_spi_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal spi_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal spi_pio_s1_chipselect : OUT STD_LOGIC;
                 signal spi_pio_s1_irq_from_sa : OUT STD_LOGIC;
                 signal spi_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal spi_pio_s1_reset_n : OUT STD_LOGIC;
                 signal spi_pio_s1_write_n : OUT STD_LOGIC;
                 signal spi_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity spi_pio_s1_arbitrator;


architecture europa of spi_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_spi_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_spi_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_spi_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_spi_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_spi_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_spi_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal spi_pio_s1_allgrants :  STD_LOGIC;
                signal spi_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal spi_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal spi_pio_s1_any_continuerequest :  STD_LOGIC;
                signal spi_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal spi_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal spi_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal spi_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal spi_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal spi_pio_s1_begins_xfer :  STD_LOGIC;
                signal spi_pio_s1_end_xfer :  STD_LOGIC;
                signal spi_pio_s1_firsttransfer :  STD_LOGIC;
                signal spi_pio_s1_grant_vector :  STD_LOGIC;
                signal spi_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal spi_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal spi_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal spi_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal spi_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal spi_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal spi_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal spi_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal spi_pio_s1_waits_for_read :  STD_LOGIC;
                signal spi_pio_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_spi_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT spi_pio_s1_end_xfer;
    end if;

  end process;

  spi_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_spi_pio_s1);
  --assign spi_pio_s1_readdata_from_sa = spi_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_pio_s1_readdata_from_sa <= spi_pio_s1_readdata;
  internal_cpu_0_data_master_requests_spi_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000000010110000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --spi_pio_s1_arb_share_counter set values, which is an e_mux
  spi_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --spi_pio_s1_non_bursting_master_requests mux, which is an e_mux
  spi_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_spi_pio_s1;
  --spi_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  spi_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --spi_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  spi_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(spi_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (spi_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(spi_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (spi_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --spi_pio_s1_allgrants all slave grants, which is an e_mux
  spi_pio_s1_allgrants <= spi_pio_s1_grant_vector;
  --spi_pio_s1_end_xfer assignment, which is an e_assign
  spi_pio_s1_end_xfer <= NOT ((spi_pio_s1_waits_for_read OR spi_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_spi_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_spi_pio_s1 <= spi_pio_s1_end_xfer AND (((NOT spi_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --spi_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  spi_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_spi_pio_s1 AND spi_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_spi_pio_s1 AND NOT spi_pio_s1_non_bursting_master_requests));
  --spi_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(spi_pio_s1_arb_counter_enable) = '1' then 
        spi_pio_s1_arb_share_counter <= spi_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --spi_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((spi_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_spi_pio_s1)) OR ((end_xfer_arb_share_counter_term_spi_pio_s1 AND NOT spi_pio_s1_non_bursting_master_requests)))) = '1' then 
        spi_pio_s1_slavearbiterlockenable <= or_reduce(spi_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master spi_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= spi_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --spi_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  spi_pio_s1_slavearbiterlockenable2 <= or_reduce(spi_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master spi_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= spi_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --spi_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  spi_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_spi_pio_s1 <= internal_cpu_0_data_master_requests_spi_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --spi_pio_s1_writedata mux, which is an e_mux
  spi_pio_s1_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_spi_pio_s1 <= internal_cpu_0_data_master_qualified_request_spi_pio_s1;
  --cpu_0/data_master saved-grant spi_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_spi_pio_s1 <= internal_cpu_0_data_master_requests_spi_pio_s1;
  --allow new arb cycle for spi_pio/s1, which is an e_assign
  spi_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  spi_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  spi_pio_s1_master_qreq_vector <= std_logic'('1');
  --spi_pio_s1_reset_n assignment, which is an e_assign
  spi_pio_s1_reset_n <= reset_n;
  spi_pio_s1_chipselect <= internal_cpu_0_data_master_granted_spi_pio_s1;
  --spi_pio_s1_firsttransfer first transaction, which is an e_assign
  spi_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(spi_pio_s1_begins_xfer) = '1'), spi_pio_s1_unreg_firsttransfer, spi_pio_s1_reg_firsttransfer);
  --spi_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  spi_pio_s1_unreg_firsttransfer <= NOT ((spi_pio_s1_slavearbiterlockenable AND spi_pio_s1_any_continuerequest));
  --spi_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(spi_pio_s1_begins_xfer) = '1' then 
        spi_pio_s1_reg_firsttransfer <= spi_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --spi_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  spi_pio_s1_beginbursttransfer_internal <= spi_pio_s1_begins_xfer;
  --~spi_pio_s1_write_n assignment, which is an e_mux
  spi_pio_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_spi_pio_s1 AND cpu_0_data_master_write));
  shifted_address_to_spi_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --spi_pio_s1_address mux, which is an e_mux
  spi_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_spi_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_spi_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_spi_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_spi_pio_s1_end_xfer <= spi_pio_s1_end_xfer;
    end if;

  end process;

  --spi_pio_s1_waits_for_read in a cycle, which is an e_mux
  spi_pio_s1_waits_for_read <= spi_pio_s1_in_a_read_cycle AND spi_pio_s1_begins_xfer;
  --spi_pio_s1_in_a_read_cycle assignment, which is an e_assign
  spi_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_spi_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= spi_pio_s1_in_a_read_cycle;
  --spi_pio_s1_waits_for_write in a cycle, which is an e_mux
  spi_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(spi_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --spi_pio_s1_in_a_write_cycle assignment, which is an e_assign
  spi_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_spi_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= spi_pio_s1_in_a_write_cycle;
  wait_for_spi_pio_s1_counter <= std_logic'('0');
  --assign spi_pio_s1_irq_from_sa = spi_pio_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_pio_s1_irq_from_sa <= spi_pio_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_spi_pio_s1 <= internal_cpu_0_data_master_granted_spi_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_spi_pio_s1 <= internal_cpu_0_data_master_qualified_request_spi_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_spi_pio_s1 <= internal_cpu_0_data_master_requests_spi_pio_s1;
--synthesis translate_off
    --spi_pio/s1 enable non-zero assertions, which is an e_register
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
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
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
                signal shifted_address_to_sysid_control_slave_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
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
  internal_cpu_0_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000100000000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
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
  internal_cpu_0_data_master_qualified_request_sysid_control_slave <= internal_cpu_0_data_master_requests_sysid_control_slave;
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

entity tfp410_i2c_master_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_0_data_master_dbs_write_8 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_0_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal tfp410_i2c_master_s1_irq : IN STD_LOGIC;
                 signal tfp410_i2c_master_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal tfp410_i2c_master_s1_waitrequest_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                 signal d1_tfp410_i2c_master_s1_end_xfer : OUT STD_LOGIC;
                 signal tfp410_i2c_master_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal tfp410_i2c_master_s1_chipselect : OUT STD_LOGIC;
                 signal tfp410_i2c_master_s1_irq_from_sa : OUT STD_LOGIC;
                 signal tfp410_i2c_master_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal tfp410_i2c_master_s1_reset : OUT STD_LOGIC;
                 signal tfp410_i2c_master_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal tfp410_i2c_master_s1_write : OUT STD_LOGIC;
                 signal tfp410_i2c_master_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
              );
end entity tfp410_i2c_master_s1_arbitrator;


architecture europa of tfp410_i2c_master_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_0 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_1 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_2 :  STD_LOGIC;
                signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_3 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_byteenable_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal internal_tfp410_i2c_master_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal tfp410_i2c_master_s1_allgrants :  STD_LOGIC;
                signal tfp410_i2c_master_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal tfp410_i2c_master_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal tfp410_i2c_master_s1_any_continuerequest :  STD_LOGIC;
                signal tfp410_i2c_master_s1_arb_counter_enable :  STD_LOGIC;
                signal tfp410_i2c_master_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal tfp410_i2c_master_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal tfp410_i2c_master_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal tfp410_i2c_master_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal tfp410_i2c_master_s1_begins_xfer :  STD_LOGIC;
                signal tfp410_i2c_master_s1_end_xfer :  STD_LOGIC;
                signal tfp410_i2c_master_s1_firsttransfer :  STD_LOGIC;
                signal tfp410_i2c_master_s1_grant_vector :  STD_LOGIC;
                signal tfp410_i2c_master_s1_in_a_read_cycle :  STD_LOGIC;
                signal tfp410_i2c_master_s1_in_a_write_cycle :  STD_LOGIC;
                signal tfp410_i2c_master_s1_master_qreq_vector :  STD_LOGIC;
                signal tfp410_i2c_master_s1_non_bursting_master_requests :  STD_LOGIC;
                signal tfp410_i2c_master_s1_pretend_byte_enable :  STD_LOGIC;
                signal tfp410_i2c_master_s1_reg_firsttransfer :  STD_LOGIC;
                signal tfp410_i2c_master_s1_slavearbiterlockenable :  STD_LOGIC;
                signal tfp410_i2c_master_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal tfp410_i2c_master_s1_unreg_firsttransfer :  STD_LOGIC;
                signal tfp410_i2c_master_s1_waits_for_read :  STD_LOGIC;
                signal tfp410_i2c_master_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_tfp410_i2c_master_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT tfp410_i2c_master_s1_end_xfer;
    end if;

  end process;

  tfp410_i2c_master_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_tfp410_i2c_master_s1);
  --assign tfp410_i2c_master_s1_readdata_from_sa = tfp410_i2c_master_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  tfp410_i2c_master_s1_readdata_from_sa <= tfp410_i2c_master_s1_readdata;
  internal_cpu_0_data_master_requests_tfp410_i2c_master_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000100000000000001000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign tfp410_i2c_master_s1_waitrequest_n_from_sa = tfp410_i2c_master_s1_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_tfp410_i2c_master_s1_waitrequest_n_from_sa <= tfp410_i2c_master_s1_waitrequest_n;
  --tfp410_i2c_master_s1_arb_share_counter set values, which is an e_mux
  tfp410_i2c_master_s1_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_tfp410_i2c_master_s1)) = '1'), std_logic_vector'("00000000000000000000000000000100"), std_logic_vector'("00000000000000000000000000000001")), 3);
  --tfp410_i2c_master_s1_non_bursting_master_requests mux, which is an e_mux
  tfp410_i2c_master_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_tfp410_i2c_master_s1;
  --tfp410_i2c_master_s1_any_bursting_master_saved_grant mux, which is an e_mux
  tfp410_i2c_master_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --tfp410_i2c_master_s1_arb_share_counter_next_value assignment, which is an e_assign
  tfp410_i2c_master_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(tfp410_i2c_master_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (tfp410_i2c_master_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(tfp410_i2c_master_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (tfp410_i2c_master_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --tfp410_i2c_master_s1_allgrants all slave grants, which is an e_mux
  tfp410_i2c_master_s1_allgrants <= tfp410_i2c_master_s1_grant_vector;
  --tfp410_i2c_master_s1_end_xfer assignment, which is an e_assign
  tfp410_i2c_master_s1_end_xfer <= NOT ((tfp410_i2c_master_s1_waits_for_read OR tfp410_i2c_master_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_tfp410_i2c_master_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_tfp410_i2c_master_s1 <= tfp410_i2c_master_s1_end_xfer AND (((NOT tfp410_i2c_master_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --tfp410_i2c_master_s1_arb_share_counter arbitration counter enable, which is an e_assign
  tfp410_i2c_master_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_tfp410_i2c_master_s1 AND tfp410_i2c_master_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_tfp410_i2c_master_s1 AND NOT tfp410_i2c_master_s1_non_bursting_master_requests));
  --tfp410_i2c_master_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tfp410_i2c_master_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(tfp410_i2c_master_s1_arb_counter_enable) = '1' then 
        tfp410_i2c_master_s1_arb_share_counter <= tfp410_i2c_master_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --tfp410_i2c_master_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tfp410_i2c_master_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((tfp410_i2c_master_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_tfp410_i2c_master_s1)) OR ((end_xfer_arb_share_counter_term_tfp410_i2c_master_s1 AND NOT tfp410_i2c_master_s1_non_bursting_master_requests)))) = '1' then 
        tfp410_i2c_master_s1_slavearbiterlockenable <= or_reduce(tfp410_i2c_master_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master tfp410_i2c_master/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= tfp410_i2c_master_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --tfp410_i2c_master_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  tfp410_i2c_master_s1_slavearbiterlockenable2 <= or_reduce(tfp410_i2c_master_s1_arb_share_counter_next_value);
  --cpu_0/data_master tfp410_i2c_master/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= tfp410_i2c_master_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --tfp410_i2c_master_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  tfp410_i2c_master_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_requests_tfp410_i2c_master_s1 AND NOT ((((cpu_0_data_master_read AND (NOT cpu_0_data_master_waitrequest))) OR (((((NOT cpu_0_data_master_waitrequest OR cpu_0_data_master_no_byte_enables_and_last_term) OR NOT(internal_cpu_0_data_master_byteenable_tfp410_i2c_master_s1))) AND cpu_0_data_master_write))));
  --tfp410_i2c_master_s1_writedata mux, which is an e_mux
  tfp410_i2c_master_s1_writedata <= cpu_0_data_master_dbs_write_8;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_qualified_request_tfp410_i2c_master_s1;
  --cpu_0/data_master saved-grant tfp410_i2c_master/s1, which is an e_assign
  cpu_0_data_master_saved_grant_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_requests_tfp410_i2c_master_s1;
  --allow new arb cycle for tfp410_i2c_master/s1, which is an e_assign
  tfp410_i2c_master_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  tfp410_i2c_master_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  tfp410_i2c_master_s1_master_qreq_vector <= std_logic'('1');
  --~tfp410_i2c_master_s1_reset assignment, which is an e_assign
  tfp410_i2c_master_s1_reset <= NOT reset_n;
  tfp410_i2c_master_s1_chipselect <= internal_cpu_0_data_master_granted_tfp410_i2c_master_s1;
  --tfp410_i2c_master_s1_firsttransfer first transaction, which is an e_assign
  tfp410_i2c_master_s1_firsttransfer <= A_WE_StdLogic((std_logic'(tfp410_i2c_master_s1_begins_xfer) = '1'), tfp410_i2c_master_s1_unreg_firsttransfer, tfp410_i2c_master_s1_reg_firsttransfer);
  --tfp410_i2c_master_s1_unreg_firsttransfer first transaction, which is an e_assign
  tfp410_i2c_master_s1_unreg_firsttransfer <= NOT ((tfp410_i2c_master_s1_slavearbiterlockenable AND tfp410_i2c_master_s1_any_continuerequest));
  --tfp410_i2c_master_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tfp410_i2c_master_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(tfp410_i2c_master_s1_begins_xfer) = '1' then 
        tfp410_i2c_master_s1_reg_firsttransfer <= tfp410_i2c_master_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --tfp410_i2c_master_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  tfp410_i2c_master_s1_beginbursttransfer_internal <= tfp410_i2c_master_s1_begins_xfer;
  --tfp410_i2c_master_s1_write assignment, which is an e_mux
  tfp410_i2c_master_s1_write <= ((internal_cpu_0_data_master_granted_tfp410_i2c_master_s1 AND cpu_0_data_master_write)) AND tfp410_i2c_master_s1_pretend_byte_enable;
  --tfp410_i2c_master_s1_address mux, which is an e_mux
  tfp410_i2c_master_s1_address <= A_EXT (Std_Logic_Vector'(A_SRL(cpu_0_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & cpu_0_data_master_dbs_address(1 DOWNTO 0)), 3);
  --d1_tfp410_i2c_master_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_tfp410_i2c_master_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_tfp410_i2c_master_s1_end_xfer <= tfp410_i2c_master_s1_end_xfer;
    end if;

  end process;

  --tfp410_i2c_master_s1_waits_for_read in a cycle, which is an e_mux
  tfp410_i2c_master_s1_waits_for_read <= tfp410_i2c_master_s1_in_a_read_cycle AND NOT internal_tfp410_i2c_master_s1_waitrequest_n_from_sa;
  --tfp410_i2c_master_s1_in_a_read_cycle assignment, which is an e_assign
  tfp410_i2c_master_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_tfp410_i2c_master_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= tfp410_i2c_master_s1_in_a_read_cycle;
  --tfp410_i2c_master_s1_waits_for_write in a cycle, which is an e_mux
  tfp410_i2c_master_s1_waits_for_write <= tfp410_i2c_master_s1_in_a_write_cycle AND NOT internal_tfp410_i2c_master_s1_waitrequest_n_from_sa;
  --tfp410_i2c_master_s1_in_a_write_cycle assignment, which is an e_assign
  tfp410_i2c_master_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_tfp410_i2c_master_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= tfp410_i2c_master_s1_in_a_write_cycle;
  wait_for_tfp410_i2c_master_s1_counter <= std_logic'('0');
  --tfp410_i2c_master_s1_pretend_byte_enable byte enable port mux, which is an e_mux
  tfp410_i2c_master_s1_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_tfp410_i2c_master_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_byteenable_tfp410_i2c_master_s1))), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  (cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_3, cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_2, cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_1, cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_0) <= cpu_0_data_master_byteenable;
  internal_cpu_0_data_master_byteenable_tfp410_i2c_master_s1 <= A_WE_StdLogic((((std_logic_vector'("000000000000000000000000000000") & (cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000000"))), cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_0, A_WE_StdLogic((((std_logic_vector'("000000000000000000000000000000") & (cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000001"))), cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_1, A_WE_StdLogic((((std_logic_vector'("000000000000000000000000000000") & (cpu_0_data_master_dbs_address(1 DOWNTO 0))) = std_logic_vector'("00000000000000000000000000000010"))), cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_2, cpu_0_data_master_byteenable_tfp410_i2c_master_s1_segment_3)));
  --assign tfp410_i2c_master_s1_irq_from_sa = tfp410_i2c_master_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  tfp410_i2c_master_s1_irq_from_sa <= tfp410_i2c_master_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_byteenable_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_byteenable_tfp410_i2c_master_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_granted_tfp410_i2c_master_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_qualified_request_tfp410_i2c_master_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_tfp410_i2c_master_s1 <= internal_cpu_0_data_master_requests_tfp410_i2c_master_s1;
  --vhdl renameroo for output signals
  tfp410_i2c_master_s1_waitrequest_n_from_sa <= internal_tfp410_i2c_master_s1_waitrequest_n_from_sa;
--synthesis translate_off
    --tfp410_i2c_master/s1 enable non-zero assertions, which is an e_register
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
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
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
                signal shifted_address_to_timer_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
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
  internal_cpu_0_data_master_requests_timer_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000100000001000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
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
  internal_cpu_0_data_master_qualified_request_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
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

entity timer_60Hz_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal timer_60Hz_s1_irq : IN STD_LOGIC;
                 signal timer_60Hz_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_timer_60Hz_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_60Hz_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_60Hz_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_60Hz_s1 : OUT STD_LOGIC;
                 signal d1_timer_60Hz_s1_end_xfer : OUT STD_LOGIC;
                 signal timer_60Hz_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal timer_60Hz_s1_chipselect : OUT STD_LOGIC;
                 signal timer_60Hz_s1_irq_from_sa : OUT STD_LOGIC;
                 signal timer_60Hz_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_60Hz_s1_reset_n : OUT STD_LOGIC;
                 signal timer_60Hz_s1_write_n : OUT STD_LOGIC;
                 signal timer_60Hz_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity timer_60Hz_s1_arbitrator;


architecture europa of timer_60Hz_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_timer_60Hz_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_timer_60Hz_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_timer_60Hz_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_timer_60Hz_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_timer_60Hz_s1 :  STD_LOGIC;
                signal shifted_address_to_timer_60Hz_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal timer_60Hz_s1_allgrants :  STD_LOGIC;
                signal timer_60Hz_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal timer_60Hz_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal timer_60Hz_s1_any_continuerequest :  STD_LOGIC;
                signal timer_60Hz_s1_arb_counter_enable :  STD_LOGIC;
                signal timer_60Hz_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_60Hz_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_60Hz_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_60Hz_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal timer_60Hz_s1_begins_xfer :  STD_LOGIC;
                signal timer_60Hz_s1_end_xfer :  STD_LOGIC;
                signal timer_60Hz_s1_firsttransfer :  STD_LOGIC;
                signal timer_60Hz_s1_grant_vector :  STD_LOGIC;
                signal timer_60Hz_s1_in_a_read_cycle :  STD_LOGIC;
                signal timer_60Hz_s1_in_a_write_cycle :  STD_LOGIC;
                signal timer_60Hz_s1_master_qreq_vector :  STD_LOGIC;
                signal timer_60Hz_s1_non_bursting_master_requests :  STD_LOGIC;
                signal timer_60Hz_s1_reg_firsttransfer :  STD_LOGIC;
                signal timer_60Hz_s1_slavearbiterlockenable :  STD_LOGIC;
                signal timer_60Hz_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal timer_60Hz_s1_unreg_firsttransfer :  STD_LOGIC;
                signal timer_60Hz_s1_waits_for_read :  STD_LOGIC;
                signal timer_60Hz_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_timer_60Hz_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT timer_60Hz_s1_end_xfer;
    end if;

  end process;

  timer_60Hz_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_timer_60Hz_s1);
  --assign timer_60Hz_s1_readdata_from_sa = timer_60Hz_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_60Hz_s1_readdata_from_sa <= timer_60Hz_s1_readdata;
  internal_cpu_0_data_master_requests_timer_60Hz_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000100000001100000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --timer_60Hz_s1_arb_share_counter set values, which is an e_mux
  timer_60Hz_s1_arb_share_set_values <= std_logic_vector'("001");
  --timer_60Hz_s1_non_bursting_master_requests mux, which is an e_mux
  timer_60Hz_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_timer_60Hz_s1;
  --timer_60Hz_s1_any_bursting_master_saved_grant mux, which is an e_mux
  timer_60Hz_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --timer_60Hz_s1_arb_share_counter_next_value assignment, which is an e_assign
  timer_60Hz_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(timer_60Hz_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (timer_60Hz_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(timer_60Hz_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (timer_60Hz_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --timer_60Hz_s1_allgrants all slave grants, which is an e_mux
  timer_60Hz_s1_allgrants <= timer_60Hz_s1_grant_vector;
  --timer_60Hz_s1_end_xfer assignment, which is an e_assign
  timer_60Hz_s1_end_xfer <= NOT ((timer_60Hz_s1_waits_for_read OR timer_60Hz_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_timer_60Hz_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_timer_60Hz_s1 <= timer_60Hz_s1_end_xfer AND (((NOT timer_60Hz_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --timer_60Hz_s1_arb_share_counter arbitration counter enable, which is an e_assign
  timer_60Hz_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_timer_60Hz_s1 AND timer_60Hz_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_timer_60Hz_s1 AND NOT timer_60Hz_s1_non_bursting_master_requests));
  --timer_60Hz_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_60Hz_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(timer_60Hz_s1_arb_counter_enable) = '1' then 
        timer_60Hz_s1_arb_share_counter <= timer_60Hz_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --timer_60Hz_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_60Hz_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((timer_60Hz_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_timer_60Hz_s1)) OR ((end_xfer_arb_share_counter_term_timer_60Hz_s1 AND NOT timer_60Hz_s1_non_bursting_master_requests)))) = '1' then 
        timer_60Hz_s1_slavearbiterlockenable <= or_reduce(timer_60Hz_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master timer_60Hz/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= timer_60Hz_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --timer_60Hz_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  timer_60Hz_s1_slavearbiterlockenable2 <= or_reduce(timer_60Hz_s1_arb_share_counter_next_value);
  --cpu_0/data_master timer_60Hz/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= timer_60Hz_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --timer_60Hz_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  timer_60Hz_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_timer_60Hz_s1 <= internal_cpu_0_data_master_requests_timer_60Hz_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --timer_60Hz_s1_writedata mux, which is an e_mux
  timer_60Hz_s1_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_timer_60Hz_s1 <= internal_cpu_0_data_master_qualified_request_timer_60Hz_s1;
  --cpu_0/data_master saved-grant timer_60Hz/s1, which is an e_assign
  cpu_0_data_master_saved_grant_timer_60Hz_s1 <= internal_cpu_0_data_master_requests_timer_60Hz_s1;
  --allow new arb cycle for timer_60Hz/s1, which is an e_assign
  timer_60Hz_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  timer_60Hz_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  timer_60Hz_s1_master_qreq_vector <= std_logic'('1');
  --timer_60Hz_s1_reset_n assignment, which is an e_assign
  timer_60Hz_s1_reset_n <= reset_n;
  timer_60Hz_s1_chipselect <= internal_cpu_0_data_master_granted_timer_60Hz_s1;
  --timer_60Hz_s1_firsttransfer first transaction, which is an e_assign
  timer_60Hz_s1_firsttransfer <= A_WE_StdLogic((std_logic'(timer_60Hz_s1_begins_xfer) = '1'), timer_60Hz_s1_unreg_firsttransfer, timer_60Hz_s1_reg_firsttransfer);
  --timer_60Hz_s1_unreg_firsttransfer first transaction, which is an e_assign
  timer_60Hz_s1_unreg_firsttransfer <= NOT ((timer_60Hz_s1_slavearbiterlockenable AND timer_60Hz_s1_any_continuerequest));
  --timer_60Hz_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_60Hz_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_60Hz_s1_begins_xfer) = '1' then 
        timer_60Hz_s1_reg_firsttransfer <= timer_60Hz_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --timer_60Hz_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  timer_60Hz_s1_beginbursttransfer_internal <= timer_60Hz_s1_begins_xfer;
  --~timer_60Hz_s1_write_n assignment, which is an e_mux
  timer_60Hz_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_timer_60Hz_s1 AND cpu_0_data_master_write));
  shifted_address_to_timer_60Hz_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --timer_60Hz_s1_address mux, which is an e_mux
  timer_60Hz_s1_address <= A_EXT (A_SRL(shifted_address_to_timer_60Hz_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_timer_60Hz_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_timer_60Hz_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_timer_60Hz_s1_end_xfer <= timer_60Hz_s1_end_xfer;
    end if;

  end process;

  --timer_60Hz_s1_waits_for_read in a cycle, which is an e_mux
  timer_60Hz_s1_waits_for_read <= timer_60Hz_s1_in_a_read_cycle AND timer_60Hz_s1_begins_xfer;
  --timer_60Hz_s1_in_a_read_cycle assignment, which is an e_assign
  timer_60Hz_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_timer_60Hz_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= timer_60Hz_s1_in_a_read_cycle;
  --timer_60Hz_s1_waits_for_write in a cycle, which is an e_mux
  timer_60Hz_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_60Hz_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --timer_60Hz_s1_in_a_write_cycle assignment, which is an e_assign
  timer_60Hz_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_timer_60Hz_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= timer_60Hz_s1_in_a_write_cycle;
  wait_for_timer_60Hz_s1_counter <= std_logic'('0');
  --assign timer_60Hz_s1_irq_from_sa = timer_60Hz_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_60Hz_s1_irq_from_sa <= timer_60Hz_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_timer_60Hz_s1 <= internal_cpu_0_data_master_granted_timer_60Hz_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_timer_60Hz_s1 <= internal_cpu_0_data_master_qualified_request_timer_60Hz_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_timer_60Hz_s1 <= internal_cpu_0_data_master_requests_timer_60Hz_s1;
--synthesis translate_off
    --timer_60Hz/s1 enable non-zero assertions, which is an e_register
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

entity uart_pc_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal uart_pc_avalon_slave_irq : IN STD_LOGIC;
                 signal uart_pc_avalon_slave_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_pc_avalon_slave_waitrequest : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_uart_pc_avalon_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_uart_pc_avalon_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_uart_pc_avalon_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_uart_pc_avalon_slave : OUT STD_LOGIC;
                 signal d1_uart_pc_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal uart_pc_avalon_slave_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal uart_pc_avalon_slave_irq_from_sa : OUT STD_LOGIC;
                 signal uart_pc_avalon_slave_read : OUT STD_LOGIC;
                 signal uart_pc_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_pc_avalon_slave_reset : OUT STD_LOGIC;
                 signal uart_pc_avalon_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal uart_pc_avalon_slave_write : OUT STD_LOGIC;
                 signal uart_pc_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity uart_pc_avalon_slave_arbitrator;


architecture europa of uart_pc_avalon_slave_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_uart_pc_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_uart_pc_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_uart_pc_avalon_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_uart_pc_avalon_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_uart_pc_avalon_slave :  STD_LOGIC;
                signal internal_uart_pc_avalon_slave_waitrequest_from_sa :  STD_LOGIC;
                signal shifted_address_to_uart_pc_avalon_slave_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal uart_pc_avalon_slave_allgrants :  STD_LOGIC;
                signal uart_pc_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal uart_pc_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal uart_pc_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal uart_pc_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal uart_pc_avalon_slave_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_pc_avalon_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_pc_avalon_slave_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_pc_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal uart_pc_avalon_slave_begins_xfer :  STD_LOGIC;
                signal uart_pc_avalon_slave_end_xfer :  STD_LOGIC;
                signal uart_pc_avalon_slave_firsttransfer :  STD_LOGIC;
                signal uart_pc_avalon_slave_grant_vector :  STD_LOGIC;
                signal uart_pc_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal uart_pc_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal uart_pc_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal uart_pc_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal uart_pc_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal uart_pc_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal uart_pc_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal uart_pc_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal uart_pc_avalon_slave_waits_for_read :  STD_LOGIC;
                signal uart_pc_avalon_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_uart_pc_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT uart_pc_avalon_slave_end_xfer;
    end if;

  end process;

  uart_pc_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_uart_pc_avalon_slave);
  --assign uart_pc_avalon_slave_readdata_from_sa = uart_pc_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_pc_avalon_slave_readdata_from_sa <= uart_pc_avalon_slave_readdata;
  internal_cpu_0_data_master_requests_uart_pc_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000100001000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign uart_pc_avalon_slave_waitrequest_from_sa = uart_pc_avalon_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_uart_pc_avalon_slave_waitrequest_from_sa <= uart_pc_avalon_slave_waitrequest;
  --uart_pc_avalon_slave_arb_share_counter set values, which is an e_mux
  uart_pc_avalon_slave_arb_share_set_values <= std_logic_vector'("001");
  --uart_pc_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  uart_pc_avalon_slave_non_bursting_master_requests <= internal_cpu_0_data_master_requests_uart_pc_avalon_slave;
  --uart_pc_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  uart_pc_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --uart_pc_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  uart_pc_avalon_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(uart_pc_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (uart_pc_avalon_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(uart_pc_avalon_slave_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (uart_pc_avalon_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --uart_pc_avalon_slave_allgrants all slave grants, which is an e_mux
  uart_pc_avalon_slave_allgrants <= uart_pc_avalon_slave_grant_vector;
  --uart_pc_avalon_slave_end_xfer assignment, which is an e_assign
  uart_pc_avalon_slave_end_xfer <= NOT ((uart_pc_avalon_slave_waits_for_read OR uart_pc_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_uart_pc_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_uart_pc_avalon_slave <= uart_pc_avalon_slave_end_xfer AND (((NOT uart_pc_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --uart_pc_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  uart_pc_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_uart_pc_avalon_slave AND uart_pc_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_uart_pc_avalon_slave AND NOT uart_pc_avalon_slave_non_bursting_master_requests));
  --uart_pc_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_pc_avalon_slave_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(uart_pc_avalon_slave_arb_counter_enable) = '1' then 
        uart_pc_avalon_slave_arb_share_counter <= uart_pc_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --uart_pc_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_pc_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((uart_pc_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_uart_pc_avalon_slave)) OR ((end_xfer_arb_share_counter_term_uart_pc_avalon_slave AND NOT uart_pc_avalon_slave_non_bursting_master_requests)))) = '1' then 
        uart_pc_avalon_slave_slavearbiterlockenable <= or_reduce(uart_pc_avalon_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master uart_pc/avalon_slave arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= uart_pc_avalon_slave_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --uart_pc_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  uart_pc_avalon_slave_slavearbiterlockenable2 <= or_reduce(uart_pc_avalon_slave_arb_share_counter_next_value);
  --cpu_0/data_master uart_pc/avalon_slave arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= uart_pc_avalon_slave_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --uart_pc_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  uart_pc_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_uart_pc_avalon_slave <= internal_cpu_0_data_master_requests_uart_pc_avalon_slave AND NOT ((((cpu_0_data_master_read AND (NOT cpu_0_data_master_waitrequest))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))));
  --uart_pc_avalon_slave_writedata mux, which is an e_mux
  uart_pc_avalon_slave_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_uart_pc_avalon_slave <= internal_cpu_0_data_master_qualified_request_uart_pc_avalon_slave;
  --cpu_0/data_master saved-grant uart_pc/avalon_slave, which is an e_assign
  cpu_0_data_master_saved_grant_uart_pc_avalon_slave <= internal_cpu_0_data_master_requests_uart_pc_avalon_slave;
  --allow new arb cycle for uart_pc/avalon_slave, which is an e_assign
  uart_pc_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  uart_pc_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  uart_pc_avalon_slave_master_qreq_vector <= std_logic'('1');
  --~uart_pc_avalon_slave_reset assignment, which is an e_assign
  uart_pc_avalon_slave_reset <= NOT reset_n;
  --uart_pc_avalon_slave_firsttransfer first transaction, which is an e_assign
  uart_pc_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(uart_pc_avalon_slave_begins_xfer) = '1'), uart_pc_avalon_slave_unreg_firsttransfer, uart_pc_avalon_slave_reg_firsttransfer);
  --uart_pc_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  uart_pc_avalon_slave_unreg_firsttransfer <= NOT ((uart_pc_avalon_slave_slavearbiterlockenable AND uart_pc_avalon_slave_any_continuerequest));
  --uart_pc_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_pc_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(uart_pc_avalon_slave_begins_xfer) = '1' then 
        uart_pc_avalon_slave_reg_firsttransfer <= uart_pc_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --uart_pc_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  uart_pc_avalon_slave_beginbursttransfer_internal <= uart_pc_avalon_slave_begins_xfer;
  --uart_pc_avalon_slave_read assignment, which is an e_mux
  uart_pc_avalon_slave_read <= internal_cpu_0_data_master_granted_uart_pc_avalon_slave AND cpu_0_data_master_read;
  --uart_pc_avalon_slave_write assignment, which is an e_mux
  uart_pc_avalon_slave_write <= internal_cpu_0_data_master_granted_uart_pc_avalon_slave AND cpu_0_data_master_write;
  shifted_address_to_uart_pc_avalon_slave_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --uart_pc_avalon_slave_address mux, which is an e_mux
  uart_pc_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_uart_pc_avalon_slave_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_uart_pc_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_uart_pc_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_uart_pc_avalon_slave_end_xfer <= uart_pc_avalon_slave_end_xfer;
    end if;

  end process;

  --uart_pc_avalon_slave_waits_for_read in a cycle, which is an e_mux
  uart_pc_avalon_slave_waits_for_read <= uart_pc_avalon_slave_in_a_read_cycle AND internal_uart_pc_avalon_slave_waitrequest_from_sa;
  --uart_pc_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  uart_pc_avalon_slave_in_a_read_cycle <= internal_cpu_0_data_master_granted_uart_pc_avalon_slave AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= uart_pc_avalon_slave_in_a_read_cycle;
  --uart_pc_avalon_slave_waits_for_write in a cycle, which is an e_mux
  uart_pc_avalon_slave_waits_for_write <= uart_pc_avalon_slave_in_a_write_cycle AND internal_uart_pc_avalon_slave_waitrequest_from_sa;
  --uart_pc_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  uart_pc_avalon_slave_in_a_write_cycle <= internal_cpu_0_data_master_granted_uart_pc_avalon_slave AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= uart_pc_avalon_slave_in_a_write_cycle;
  wait_for_uart_pc_avalon_slave_counter <= std_logic'('0');
  --assign uart_pc_avalon_slave_irq_from_sa = uart_pc_avalon_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_pc_avalon_slave_irq_from_sa <= uart_pc_avalon_slave_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_uart_pc_avalon_slave <= internal_cpu_0_data_master_granted_uart_pc_avalon_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_uart_pc_avalon_slave <= internal_cpu_0_data_master_qualified_request_uart_pc_avalon_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_uart_pc_avalon_slave <= internal_cpu_0_data_master_requests_uart_pc_avalon_slave;
  --vhdl renameroo for output signals
  uart_pc_avalon_slave_waitrequest_from_sa <= internal_uart_pc_avalon_slave_waitrequest_from_sa;
--synthesis translate_off
    --uart_pc/avalon_slave enable non-zero assertions, which is an e_register
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

entity uart_ts_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal uart_ts_avalon_slave_irq : IN STD_LOGIC;
                 signal uart_ts_avalon_slave_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_ts_avalon_slave_waitrequest : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_uart_ts_avalon_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_uart_ts_avalon_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_uart_ts_avalon_slave : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_uart_ts_avalon_slave : OUT STD_LOGIC;
                 signal d1_uart_ts_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal uart_ts_avalon_slave_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal uart_ts_avalon_slave_irq_from_sa : OUT STD_LOGIC;
                 signal uart_ts_avalon_slave_read : OUT STD_LOGIC;
                 signal uart_ts_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_ts_avalon_slave_reset : OUT STD_LOGIC;
                 signal uart_ts_avalon_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal uart_ts_avalon_slave_write : OUT STD_LOGIC;
                 signal uart_ts_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity uart_ts_avalon_slave_arbitrator;


architecture europa of uart_ts_avalon_slave_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_uart_ts_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_uart_ts_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_uart_ts_avalon_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_uart_ts_avalon_slave :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_uart_ts_avalon_slave :  STD_LOGIC;
                signal internal_uart_ts_avalon_slave_waitrequest_from_sa :  STD_LOGIC;
                signal shifted_address_to_uart_ts_avalon_slave_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal uart_ts_avalon_slave_allgrants :  STD_LOGIC;
                signal uart_ts_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal uart_ts_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal uart_ts_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal uart_ts_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal uart_ts_avalon_slave_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_ts_avalon_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_ts_avalon_slave_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_ts_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal uart_ts_avalon_slave_begins_xfer :  STD_LOGIC;
                signal uart_ts_avalon_slave_end_xfer :  STD_LOGIC;
                signal uart_ts_avalon_slave_firsttransfer :  STD_LOGIC;
                signal uart_ts_avalon_slave_grant_vector :  STD_LOGIC;
                signal uart_ts_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal uart_ts_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal uart_ts_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal uart_ts_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal uart_ts_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal uart_ts_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal uart_ts_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal uart_ts_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal uart_ts_avalon_slave_waits_for_read :  STD_LOGIC;
                signal uart_ts_avalon_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_uart_ts_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT uart_ts_avalon_slave_end_xfer;
    end if;

  end process;

  uart_ts_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_uart_ts_avalon_slave);
  --assign uart_ts_avalon_slave_readdata_from_sa = uart_ts_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_ts_avalon_slave_readdata_from_sa <= uart_ts_avalon_slave_readdata;
  internal_cpu_0_data_master_requests_uart_ts_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000100000111100000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign uart_ts_avalon_slave_waitrequest_from_sa = uart_ts_avalon_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_uart_ts_avalon_slave_waitrequest_from_sa <= uart_ts_avalon_slave_waitrequest;
  --uart_ts_avalon_slave_arb_share_counter set values, which is an e_mux
  uart_ts_avalon_slave_arb_share_set_values <= std_logic_vector'("001");
  --uart_ts_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  uart_ts_avalon_slave_non_bursting_master_requests <= internal_cpu_0_data_master_requests_uart_ts_avalon_slave;
  --uart_ts_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  uart_ts_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --uart_ts_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  uart_ts_avalon_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(uart_ts_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (uart_ts_avalon_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(uart_ts_avalon_slave_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (uart_ts_avalon_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --uart_ts_avalon_slave_allgrants all slave grants, which is an e_mux
  uart_ts_avalon_slave_allgrants <= uart_ts_avalon_slave_grant_vector;
  --uart_ts_avalon_slave_end_xfer assignment, which is an e_assign
  uart_ts_avalon_slave_end_xfer <= NOT ((uart_ts_avalon_slave_waits_for_read OR uart_ts_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_uart_ts_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_uart_ts_avalon_slave <= uart_ts_avalon_slave_end_xfer AND (((NOT uart_ts_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --uart_ts_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  uart_ts_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_uart_ts_avalon_slave AND uart_ts_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_uart_ts_avalon_slave AND NOT uart_ts_avalon_slave_non_bursting_master_requests));
  --uart_ts_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_ts_avalon_slave_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(uart_ts_avalon_slave_arb_counter_enable) = '1' then 
        uart_ts_avalon_slave_arb_share_counter <= uart_ts_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --uart_ts_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_ts_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((uart_ts_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_uart_ts_avalon_slave)) OR ((end_xfer_arb_share_counter_term_uart_ts_avalon_slave AND NOT uart_ts_avalon_slave_non_bursting_master_requests)))) = '1' then 
        uart_ts_avalon_slave_slavearbiterlockenable <= or_reduce(uart_ts_avalon_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master uart_ts/avalon_slave arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= uart_ts_avalon_slave_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --uart_ts_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  uart_ts_avalon_slave_slavearbiterlockenable2 <= or_reduce(uart_ts_avalon_slave_arb_share_counter_next_value);
  --cpu_0/data_master uart_ts/avalon_slave arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= uart_ts_avalon_slave_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --uart_ts_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  uart_ts_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_uart_ts_avalon_slave <= internal_cpu_0_data_master_requests_uart_ts_avalon_slave AND NOT ((((cpu_0_data_master_read AND (NOT cpu_0_data_master_waitrequest))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))));
  --uart_ts_avalon_slave_writedata mux, which is an e_mux
  uart_ts_avalon_slave_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_uart_ts_avalon_slave <= internal_cpu_0_data_master_qualified_request_uart_ts_avalon_slave;
  --cpu_0/data_master saved-grant uart_ts/avalon_slave, which is an e_assign
  cpu_0_data_master_saved_grant_uart_ts_avalon_slave <= internal_cpu_0_data_master_requests_uart_ts_avalon_slave;
  --allow new arb cycle for uart_ts/avalon_slave, which is an e_assign
  uart_ts_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  uart_ts_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  uart_ts_avalon_slave_master_qreq_vector <= std_logic'('1');
  --~uart_ts_avalon_slave_reset assignment, which is an e_assign
  uart_ts_avalon_slave_reset <= NOT reset_n;
  --uart_ts_avalon_slave_firsttransfer first transaction, which is an e_assign
  uart_ts_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(uart_ts_avalon_slave_begins_xfer) = '1'), uart_ts_avalon_slave_unreg_firsttransfer, uart_ts_avalon_slave_reg_firsttransfer);
  --uart_ts_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  uart_ts_avalon_slave_unreg_firsttransfer <= NOT ((uart_ts_avalon_slave_slavearbiterlockenable AND uart_ts_avalon_slave_any_continuerequest));
  --uart_ts_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_ts_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(uart_ts_avalon_slave_begins_xfer) = '1' then 
        uart_ts_avalon_slave_reg_firsttransfer <= uart_ts_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --uart_ts_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  uart_ts_avalon_slave_beginbursttransfer_internal <= uart_ts_avalon_slave_begins_xfer;
  --uart_ts_avalon_slave_read assignment, which is an e_mux
  uart_ts_avalon_slave_read <= internal_cpu_0_data_master_granted_uart_ts_avalon_slave AND cpu_0_data_master_read;
  --uart_ts_avalon_slave_write assignment, which is an e_mux
  uart_ts_avalon_slave_write <= internal_cpu_0_data_master_granted_uart_ts_avalon_slave AND cpu_0_data_master_write;
  shifted_address_to_uart_ts_avalon_slave_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --uart_ts_avalon_slave_address mux, which is an e_mux
  uart_ts_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_uart_ts_avalon_slave_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_uart_ts_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_uart_ts_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_uart_ts_avalon_slave_end_xfer <= uart_ts_avalon_slave_end_xfer;
    end if;

  end process;

  --uart_ts_avalon_slave_waits_for_read in a cycle, which is an e_mux
  uart_ts_avalon_slave_waits_for_read <= uart_ts_avalon_slave_in_a_read_cycle AND internal_uart_ts_avalon_slave_waitrequest_from_sa;
  --uart_ts_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  uart_ts_avalon_slave_in_a_read_cycle <= internal_cpu_0_data_master_granted_uart_ts_avalon_slave AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= uart_ts_avalon_slave_in_a_read_cycle;
  --uart_ts_avalon_slave_waits_for_write in a cycle, which is an e_mux
  uart_ts_avalon_slave_waits_for_write <= uart_ts_avalon_slave_in_a_write_cycle AND internal_uart_ts_avalon_slave_waitrequest_from_sa;
  --uart_ts_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  uart_ts_avalon_slave_in_a_write_cycle <= internal_cpu_0_data_master_granted_uart_ts_avalon_slave AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= uart_ts_avalon_slave_in_a_write_cycle;
  wait_for_uart_ts_avalon_slave_counter <= std_logic'('0');
  --assign uart_ts_avalon_slave_irq_from_sa = uart_ts_avalon_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_ts_avalon_slave_irq_from_sa <= uart_ts_avalon_slave_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_uart_ts_avalon_slave <= internal_cpu_0_data_master_granted_uart_ts_avalon_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_uart_ts_avalon_slave <= internal_cpu_0_data_master_qualified_request_uart_ts_avalon_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_uart_ts_avalon_slave <= internal_cpu_0_data_master_requests_uart_ts_avalon_slave;
  --vhdl renameroo for output signals
  uart_ts_avalon_slave_waitrequest_from_sa <= internal_uart_ts_avalon_slave_waitrequest_from_sa;
--synthesis translate_off
    --uart_ts/avalon_slave enable non-zero assertions, which is an e_register
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

entity usb_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal usb_pio_s1_readdata : IN STD_LOGIC_VECTOR (3 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_usb_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_usb_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_usb_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_usb_pio_s1 : OUT STD_LOGIC;
                 signal d1_usb_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal usb_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal usb_pio_s1_chipselect : OUT STD_LOGIC;
                 signal usb_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal usb_pio_s1_reset_n : OUT STD_LOGIC;
                 signal usb_pio_s1_write_n : OUT STD_LOGIC;
                 signal usb_pio_s1_writedata : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
              );
end entity usb_pio_s1_arbitrator;


architecture europa of usb_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_usb_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_usb_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_usb_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_usb_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_usb_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_usb_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal usb_pio_s1_allgrants :  STD_LOGIC;
                signal usb_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal usb_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal usb_pio_s1_any_continuerequest :  STD_LOGIC;
                signal usb_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal usb_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal usb_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal usb_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal usb_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal usb_pio_s1_begins_xfer :  STD_LOGIC;
                signal usb_pio_s1_end_xfer :  STD_LOGIC;
                signal usb_pio_s1_firsttransfer :  STD_LOGIC;
                signal usb_pio_s1_grant_vector :  STD_LOGIC;
                signal usb_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal usb_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal usb_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal usb_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal usb_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal usb_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal usb_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal usb_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal usb_pio_s1_waits_for_read :  STD_LOGIC;
                signal usb_pio_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_usb_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT usb_pio_s1_end_xfer;
    end if;

  end process;

  usb_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_usb_pio_s1);
  --assign usb_pio_s1_readdata_from_sa = usb_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  usb_pio_s1_readdata_from_sa <= usb_pio_s1_readdata;
  internal_cpu_0_data_master_requests_usb_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000000010000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --usb_pio_s1_arb_share_counter set values, which is an e_mux
  usb_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --usb_pio_s1_non_bursting_master_requests mux, which is an e_mux
  usb_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_usb_pio_s1;
  --usb_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  usb_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --usb_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  usb_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(usb_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (usb_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(usb_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (usb_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --usb_pio_s1_allgrants all slave grants, which is an e_mux
  usb_pio_s1_allgrants <= usb_pio_s1_grant_vector;
  --usb_pio_s1_end_xfer assignment, which is an e_assign
  usb_pio_s1_end_xfer <= NOT ((usb_pio_s1_waits_for_read OR usb_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_usb_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_usb_pio_s1 <= usb_pio_s1_end_xfer AND (((NOT usb_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --usb_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  usb_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_usb_pio_s1 AND usb_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_usb_pio_s1 AND NOT usb_pio_s1_non_bursting_master_requests));
  --usb_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      usb_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(usb_pio_s1_arb_counter_enable) = '1' then 
        usb_pio_s1_arb_share_counter <= usb_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --usb_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      usb_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((usb_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_usb_pio_s1)) OR ((end_xfer_arb_share_counter_term_usb_pio_s1 AND NOT usb_pio_s1_non_bursting_master_requests)))) = '1' then 
        usb_pio_s1_slavearbiterlockenable <= or_reduce(usb_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master usb_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= usb_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --usb_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  usb_pio_s1_slavearbiterlockenable2 <= or_reduce(usb_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master usb_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= usb_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --usb_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  usb_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_usb_pio_s1 <= internal_cpu_0_data_master_requests_usb_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --usb_pio_s1_writedata mux, which is an e_mux
  usb_pio_s1_writedata <= cpu_0_data_master_writedata (3 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_usb_pio_s1 <= internal_cpu_0_data_master_qualified_request_usb_pio_s1;
  --cpu_0/data_master saved-grant usb_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_usb_pio_s1 <= internal_cpu_0_data_master_requests_usb_pio_s1;
  --allow new arb cycle for usb_pio/s1, which is an e_assign
  usb_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  usb_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  usb_pio_s1_master_qreq_vector <= std_logic'('1');
  --usb_pio_s1_reset_n assignment, which is an e_assign
  usb_pio_s1_reset_n <= reset_n;
  usb_pio_s1_chipselect <= internal_cpu_0_data_master_granted_usb_pio_s1;
  --usb_pio_s1_firsttransfer first transaction, which is an e_assign
  usb_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(usb_pio_s1_begins_xfer) = '1'), usb_pio_s1_unreg_firsttransfer, usb_pio_s1_reg_firsttransfer);
  --usb_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  usb_pio_s1_unreg_firsttransfer <= NOT ((usb_pio_s1_slavearbiterlockenable AND usb_pio_s1_any_continuerequest));
  --usb_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      usb_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(usb_pio_s1_begins_xfer) = '1' then 
        usb_pio_s1_reg_firsttransfer <= usb_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --usb_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  usb_pio_s1_beginbursttransfer_internal <= usb_pio_s1_begins_xfer;
  --~usb_pio_s1_write_n assignment, which is an e_mux
  usb_pio_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_usb_pio_s1 AND cpu_0_data_master_write));
  shifted_address_to_usb_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --usb_pio_s1_address mux, which is an e_mux
  usb_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_usb_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_usb_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_usb_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_usb_pio_s1_end_xfer <= usb_pio_s1_end_xfer;
    end if;

  end process;

  --usb_pio_s1_waits_for_read in a cycle, which is an e_mux
  usb_pio_s1_waits_for_read <= usb_pio_s1_in_a_read_cycle AND usb_pio_s1_begins_xfer;
  --usb_pio_s1_in_a_read_cycle assignment, which is an e_assign
  usb_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_usb_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= usb_pio_s1_in_a_read_cycle;
  --usb_pio_s1_waits_for_write in a cycle, which is an e_mux
  usb_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(usb_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --usb_pio_s1_in_a_write_cycle assignment, which is an e_assign
  usb_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_usb_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= usb_pio_s1_in_a_write_cycle;
  wait_for_usb_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_usb_pio_s1 <= internal_cpu_0_data_master_granted_usb_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_usb_pio_s1 <= internal_cpu_0_data_master_qualified_request_usb_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_usb_pio_s1 <= internal_cpu_0_data_master_requests_usb_pio_s1;
--synthesis translate_off
    --usb_pio/s1 enable non-zero assertions, which is an e_register
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

entity version_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal version_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_version_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_version_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_version_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_version_pio_s1 : OUT STD_LOGIC;
                 signal d1_version_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal version_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal version_pio_s1_chipselect : OUT STD_LOGIC;
                 signal version_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal version_pio_s1_reset_n : OUT STD_LOGIC;
                 signal version_pio_s1_write_n : OUT STD_LOGIC;
                 signal version_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity version_pio_s1_arbitrator;


architecture europa of version_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_version_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_version_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_version_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_version_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_version_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_version_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal version_pio_s1_allgrants :  STD_LOGIC;
                signal version_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal version_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal version_pio_s1_any_continuerequest :  STD_LOGIC;
                signal version_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal version_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal version_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal version_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal version_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal version_pio_s1_begins_xfer :  STD_LOGIC;
                signal version_pio_s1_end_xfer :  STD_LOGIC;
                signal version_pio_s1_firsttransfer :  STD_LOGIC;
                signal version_pio_s1_grant_vector :  STD_LOGIC;
                signal version_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal version_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal version_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal version_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal version_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal version_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal version_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal version_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal version_pio_s1_waits_for_read :  STD_LOGIC;
                signal version_pio_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_version_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT version_pio_s1_end_xfer;
    end if;

  end process;

  version_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_version_pio_s1);
  --assign version_pio_s1_readdata_from_sa = version_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  version_pio_s1_readdata_from_sa <= version_pio_s1_readdata;
  internal_cpu_0_data_master_requests_version_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000100100000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --version_pio_s1_arb_share_counter set values, which is an e_mux
  version_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --version_pio_s1_non_bursting_master_requests mux, which is an e_mux
  version_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_version_pio_s1;
  --version_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  version_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --version_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  version_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(version_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (version_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(version_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (version_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --version_pio_s1_allgrants all slave grants, which is an e_mux
  version_pio_s1_allgrants <= version_pio_s1_grant_vector;
  --version_pio_s1_end_xfer assignment, which is an e_assign
  version_pio_s1_end_xfer <= NOT ((version_pio_s1_waits_for_read OR version_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_version_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_version_pio_s1 <= version_pio_s1_end_xfer AND (((NOT version_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --version_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  version_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_version_pio_s1 AND version_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_version_pio_s1 AND NOT version_pio_s1_non_bursting_master_requests));
  --version_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      version_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(version_pio_s1_arb_counter_enable) = '1' then 
        version_pio_s1_arb_share_counter <= version_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --version_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      version_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((version_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_version_pio_s1)) OR ((end_xfer_arb_share_counter_term_version_pio_s1 AND NOT version_pio_s1_non_bursting_master_requests)))) = '1' then 
        version_pio_s1_slavearbiterlockenable <= or_reduce(version_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master version_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= version_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --version_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  version_pio_s1_slavearbiterlockenable2 <= or_reduce(version_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master version_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= version_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --version_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  version_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_version_pio_s1 <= internal_cpu_0_data_master_requests_version_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --version_pio_s1_writedata mux, which is an e_mux
  version_pio_s1_writedata <= cpu_0_data_master_writedata;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_version_pio_s1 <= internal_cpu_0_data_master_qualified_request_version_pio_s1;
  --cpu_0/data_master saved-grant version_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_version_pio_s1 <= internal_cpu_0_data_master_requests_version_pio_s1;
  --allow new arb cycle for version_pio/s1, which is an e_assign
  version_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  version_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  version_pio_s1_master_qreq_vector <= std_logic'('1');
  --version_pio_s1_reset_n assignment, which is an e_assign
  version_pio_s1_reset_n <= reset_n;
  version_pio_s1_chipselect <= internal_cpu_0_data_master_granted_version_pio_s1;
  --version_pio_s1_firsttransfer first transaction, which is an e_assign
  version_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(version_pio_s1_begins_xfer) = '1'), version_pio_s1_unreg_firsttransfer, version_pio_s1_reg_firsttransfer);
  --version_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  version_pio_s1_unreg_firsttransfer <= NOT ((version_pio_s1_slavearbiterlockenable AND version_pio_s1_any_continuerequest));
  --version_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      version_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(version_pio_s1_begins_xfer) = '1' then 
        version_pio_s1_reg_firsttransfer <= version_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --version_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  version_pio_s1_beginbursttransfer_internal <= version_pio_s1_begins_xfer;
  --~version_pio_s1_write_n assignment, which is an e_mux
  version_pio_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_version_pio_s1 AND cpu_0_data_master_write));
  shifted_address_to_version_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --version_pio_s1_address mux, which is an e_mux
  version_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_version_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_version_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_version_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_version_pio_s1_end_xfer <= version_pio_s1_end_xfer;
    end if;

  end process;

  --version_pio_s1_waits_for_read in a cycle, which is an e_mux
  version_pio_s1_waits_for_read <= version_pio_s1_in_a_read_cycle AND version_pio_s1_begins_xfer;
  --version_pio_s1_in_a_read_cycle assignment, which is an e_assign
  version_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_version_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= version_pio_s1_in_a_read_cycle;
  --version_pio_s1_waits_for_write in a cycle, which is an e_mux
  version_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(version_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --version_pio_s1_in_a_write_cycle assignment, which is an e_assign
  version_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_version_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= version_pio_s1_in_a_write_cycle;
  wait_for_version_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_version_pio_s1 <= internal_cpu_0_data_master_granted_version_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_version_pio_s1 <= internal_cpu_0_data_master_qualified_request_version_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_version_pio_s1 <= internal_cpu_0_data_master_requests_version_pio_s1;
--synthesis translate_off
    --version_pio/s1 enable non-zero assertions, which is an e_register
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

entity vo_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal vo_pio_s1_irq : IN STD_LOGIC;
                 signal vo_pio_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_vo_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_vo_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_vo_pio_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_vo_pio_s1 : OUT STD_LOGIC;
                 signal d1_vo_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal vo_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal vo_pio_s1_chipselect : OUT STD_LOGIC;
                 signal vo_pio_s1_irq_from_sa : OUT STD_LOGIC;
                 signal vo_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal vo_pio_s1_reset_n : OUT STD_LOGIC;
                 signal vo_pio_s1_write_n : OUT STD_LOGIC;
                 signal vo_pio_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
              );
end entity vo_pio_s1_arbitrator;


architecture europa of vo_pio_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_vo_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_vo_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_vo_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_vo_pio_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_vo_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_vo_pio_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal vo_pio_s1_allgrants :  STD_LOGIC;
                signal vo_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal vo_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal vo_pio_s1_any_continuerequest :  STD_LOGIC;
                signal vo_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal vo_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vo_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vo_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vo_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal vo_pio_s1_begins_xfer :  STD_LOGIC;
                signal vo_pio_s1_end_xfer :  STD_LOGIC;
                signal vo_pio_s1_firsttransfer :  STD_LOGIC;
                signal vo_pio_s1_grant_vector :  STD_LOGIC;
                signal vo_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal vo_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal vo_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal vo_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal vo_pio_s1_pretend_byte_enable :  STD_LOGIC;
                signal vo_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal vo_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal vo_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal vo_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal vo_pio_s1_waits_for_read :  STD_LOGIC;
                signal vo_pio_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_vo_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT vo_pio_s1_end_xfer;
    end if;

  end process;

  vo_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_vo_pio_s1);
  --assign vo_pio_s1_readdata_from_sa = vo_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  vo_pio_s1_readdata_from_sa <= vo_pio_s1_readdata;
  internal_cpu_0_data_master_requests_vo_pio_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(30 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100000000000010000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --vo_pio_s1_arb_share_counter set values, which is an e_mux
  vo_pio_s1_arb_share_set_values <= std_logic_vector'("001");
  --vo_pio_s1_non_bursting_master_requests mux, which is an e_mux
  vo_pio_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_vo_pio_s1;
  --vo_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  vo_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --vo_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  vo_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(vo_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (vo_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(vo_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (vo_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 3);
  --vo_pio_s1_allgrants all slave grants, which is an e_mux
  vo_pio_s1_allgrants <= vo_pio_s1_grant_vector;
  --vo_pio_s1_end_xfer assignment, which is an e_assign
  vo_pio_s1_end_xfer <= NOT ((vo_pio_s1_waits_for_read OR vo_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_vo_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_vo_pio_s1 <= vo_pio_s1_end_xfer AND (((NOT vo_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --vo_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  vo_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_vo_pio_s1 AND vo_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_vo_pio_s1 AND NOT vo_pio_s1_non_bursting_master_requests));
  --vo_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vo_pio_s1_arb_share_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'(vo_pio_s1_arb_counter_enable) = '1' then 
        vo_pio_s1_arb_share_counter <= vo_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --vo_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vo_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((vo_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_vo_pio_s1)) OR ((end_xfer_arb_share_counter_term_vo_pio_s1 AND NOT vo_pio_s1_non_bursting_master_requests)))) = '1' then 
        vo_pio_s1_slavearbiterlockenable <= or_reduce(vo_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu_0/data_master vo_pio/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= vo_pio_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --vo_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  vo_pio_s1_slavearbiterlockenable2 <= or_reduce(vo_pio_s1_arb_share_counter_next_value);
  --cpu_0/data_master vo_pio/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= vo_pio_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --vo_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  vo_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_vo_pio_s1 <= internal_cpu_0_data_master_requests_vo_pio_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --vo_pio_s1_writedata mux, which is an e_mux
  vo_pio_s1_writedata <= cpu_0_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_vo_pio_s1 <= internal_cpu_0_data_master_qualified_request_vo_pio_s1;
  --cpu_0/data_master saved-grant vo_pio/s1, which is an e_assign
  cpu_0_data_master_saved_grant_vo_pio_s1 <= internal_cpu_0_data_master_requests_vo_pio_s1;
  --allow new arb cycle for vo_pio/s1, which is an e_assign
  vo_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  vo_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  vo_pio_s1_master_qreq_vector <= std_logic'('1');
  --vo_pio_s1_reset_n assignment, which is an e_assign
  vo_pio_s1_reset_n <= reset_n;
  vo_pio_s1_chipselect <= internal_cpu_0_data_master_granted_vo_pio_s1;
  --vo_pio_s1_firsttransfer first transaction, which is an e_assign
  vo_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(vo_pio_s1_begins_xfer) = '1'), vo_pio_s1_unreg_firsttransfer, vo_pio_s1_reg_firsttransfer);
  --vo_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  vo_pio_s1_unreg_firsttransfer <= NOT ((vo_pio_s1_slavearbiterlockenable AND vo_pio_s1_any_continuerequest));
  --vo_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vo_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(vo_pio_s1_begins_xfer) = '1' then 
        vo_pio_s1_reg_firsttransfer <= vo_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --vo_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  vo_pio_s1_beginbursttransfer_internal <= vo_pio_s1_begins_xfer;
  --~vo_pio_s1_write_n assignment, which is an e_mux
  vo_pio_s1_write_n <= NOT ((((internal_cpu_0_data_master_granted_vo_pio_s1 AND cpu_0_data_master_write)) AND vo_pio_s1_pretend_byte_enable));
  shifted_address_to_vo_pio_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --vo_pio_s1_address mux, which is an e_mux
  vo_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_vo_pio_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_vo_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_vo_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_vo_pio_s1_end_xfer <= vo_pio_s1_end_xfer;
    end if;

  end process;

  --vo_pio_s1_waits_for_read in a cycle, which is an e_mux
  vo_pio_s1_waits_for_read <= vo_pio_s1_in_a_read_cycle AND vo_pio_s1_begins_xfer;
  --vo_pio_s1_in_a_read_cycle assignment, which is an e_assign
  vo_pio_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_vo_pio_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= vo_pio_s1_in_a_read_cycle;
  --vo_pio_s1_waits_for_write in a cycle, which is an e_mux
  vo_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vo_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --vo_pio_s1_in_a_write_cycle assignment, which is an e_assign
  vo_pio_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_vo_pio_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= vo_pio_s1_in_a_write_cycle;
  wait_for_vo_pio_s1_counter <= std_logic'('0');
  --vo_pio_s1_pretend_byte_enable byte enable port mux, which is an e_mux
  vo_pio_s1_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_vo_pio_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --assign vo_pio_s1_irq_from_sa = vo_pio_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  vo_pio_s1_irq_from_sa <= vo_pio_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_vo_pio_s1 <= internal_cpu_0_data_master_granted_vo_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_vo_pio_s1 <= internal_cpu_0_data_master_qualified_request_vo_pio_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_vo_pio_s1 <= internal_cpu_0_data_master_requests_vo_pio_s1;
--synthesis translate_off
    --vo_pio/s1 enable non-zero assertions, which is an e_register
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

entity ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch_module;


architecture europa of ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch_module is
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

entity ep4c_sopc_system is 
        port (
              -- 1) global signals:
                 signal altmemddr_0_aux_full_rate_clk_out : OUT STD_LOGIC;
                 signal altmemddr_0_aux_half_rate_clk_out : OUT STD_LOGIC;
                 signal altmemddr_0_phy_clk_out : OUT STD_LOGIC;
                 signal clk_24M : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_altmemddr_0
                 signal global_reset_n_to_the_altmemddr_0 : IN STD_LOGIC;
                 signal local_init_done_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal local_refresh_ack_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal local_wdata_req_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_addr_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal mem_ba_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_cas_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_cke_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_clk_n_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                 signal mem_clk_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                 signal mem_cs_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_dm_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_dq_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal mem_dqs_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_odt_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_ras_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_we_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal reset_phy_clk_n_from_the_altmemddr_0 : OUT STD_LOGIC;

              -- the_audio_pio
                 signal in_port_to_the_audio_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_debug_pio
                 signal in_port_to_the_debug_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal out_port_from_the_debug_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_epcs_spi
                 signal MISO_to_the_epcs_spi : IN STD_LOGIC;
                 signal MOSI_from_the_epcs_spi : OUT STD_LOGIC;
                 signal SCLK_from_the_epcs_spi : OUT STD_LOGIC;
                 signal SS_n_from_the_epcs_spi : OUT STD_LOGIC;

              -- the_jamma_pio
                 signal out_port_from_the_jamma_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_keybd_pio
                 signal out_port_from_the_keybd_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_m95320
                 signal MISO_to_the_m95320 : IN STD_LOGIC;
                 signal MOSI_from_the_m95320 : OUT STD_LOGIC;
                 signal SCLK_from_the_m95320 : OUT STD_LOGIC;
                 signal SS_n_from_the_m95320 : OUT STD_LOGIC;

              -- the_one_wire_interface_0
                 signal data_to_and_from_the_one_wire_interface_0 : INOUT STD_LOGIC;

              -- the_oxu210hp_if_0
                 signal coe_uh_a_from_the_oxu210hp_if_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal coe_uh_be_from_the_oxu210hp_if_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal coe_uh_cs_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;
                 signal coe_uh_d_to_and_from_the_oxu210hp_if_0 : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal coe_uh_dack_from_the_oxu210hp_if_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal coe_uh_dreq_to_the_oxu210hp_if_0 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal coe_uh_int_n_to_the_oxu210hp_if_0 : IN STD_LOGIC;
                 signal coe_uh_rd_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;
                 signal coe_uh_reset_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;
                 signal coe_uh_wr_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;

              -- the_oxu210hp_int
                 signal in_port_to_the_oxu210hp_int : IN STD_LOGIC;
                 signal out_port_from_the_oxu210hp_int : OUT STD_LOGIC;

              -- the_spi_pio
                 signal in_port_to_the_spi_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal out_port_from_the_spi_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_tfp410_i2c_master
                 signal coe_arst_arst_i_to_the_tfp410_i2c_master : IN STD_LOGIC;
                 signal coe_i2c_scl_pad_i_to_the_tfp410_i2c_master : IN STD_LOGIC;
                 signal coe_i2c_scl_pad_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;
                 signal coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;
                 signal coe_i2c_sda_pad_i_to_the_tfp410_i2c_master : IN STD_LOGIC;
                 signal coe_i2c_sda_pad_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;
                 signal coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;

              -- the_uart_pc
                 signal cts_to_the_uart_pc : IN STD_LOGIC;
                 signal rts_from_the_uart_pc : OUT STD_LOGIC;
                 signal rxd_led_from_the_uart_pc : OUT STD_LOGIC;
                 signal rxd_to_the_uart_pc : IN STD_LOGIC;
                 signal txd_active_from_the_uart_pc : OUT STD_LOGIC;
                 signal txd_from_the_uart_pc : OUT STD_LOGIC;
                 signal txd_led_from_the_uart_pc : OUT STD_LOGIC;

              -- the_uart_ts
                 signal cts_to_the_uart_ts : IN STD_LOGIC;
                 signal rts_from_the_uart_ts : OUT STD_LOGIC;
                 signal rxd_led_from_the_uart_ts : OUT STD_LOGIC;
                 signal rxd_to_the_uart_ts : IN STD_LOGIC;
                 signal txd_active_from_the_uart_ts : OUT STD_LOGIC;
                 signal txd_from_the_uart_ts : OUT STD_LOGIC;
                 signal txd_led_from_the_uart_ts : OUT STD_LOGIC;

              -- the_usb_pio
                 signal out_port_from_the_usb_pio : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

              -- the_version_pio
                 signal in_port_to_the_version_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal out_port_from_the_version_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- the_vo_pio
                 signal in_port_to_the_vo_pio : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal out_port_from_the_vo_pio : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
              );
end entity ep4c_sopc_system;


architecture europa of ep4c_sopc_system is
component altmemddr_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal altmemddr_0_s1_readdata : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal altmemddr_0_s1_readdatavalid : IN STD_LOGIC;
                    signal altmemddr_0_s1_resetrequest_n : IN STD_LOGIC;
                    signal altmemddr_0_s1_waitrequest_n : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal altmemddr_0_s1_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal altmemddr_0_s1_beginbursttransfer : OUT STD_LOGIC;
                    signal altmemddr_0_s1_burstcount : OUT STD_LOGIC;
                    signal altmemddr_0_s1_byteenable : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal altmemddr_0_s1_read : OUT STD_LOGIC;
                    signal altmemddr_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal altmemddr_0_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                    signal altmemddr_0_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal altmemddr_0_s1_write : OUT STD_LOGIC;
                    signal altmemddr_0_s1_writedata : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal cpu_0_data_master_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_requests_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal d1_altmemddr_0_s1_end_xfer : OUT STD_LOGIC
                 );
end component altmemddr_0_s1_arbitrator;

component ep4c_sopc_system_reset_clk_24M_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ep4c_sopc_system_reset_clk_24M_domain_synch_module;

component altmemddr_0 is 
           port (
                 -- inputs:
                    signal global_reset_n : IN STD_LOGIC;
                    signal local_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal local_be : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal local_burstbegin : IN STD_LOGIC;
                    signal local_read_req : IN STD_LOGIC;
                    signal local_size : IN STD_LOGIC;
                    signal local_wdata : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal local_write_req : IN STD_LOGIC;
                    signal pll_ref_clk : IN STD_LOGIC;
                    signal soft_reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal aux_full_rate_clk : OUT STD_LOGIC;
                    signal aux_half_rate_clk : OUT STD_LOGIC;
                    signal local_init_done : OUT STD_LOGIC;
                    signal local_rdata : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal local_rdata_valid : OUT STD_LOGIC;
                    signal local_ready : OUT STD_LOGIC;
                    signal local_refresh_ack : OUT STD_LOGIC;
                    signal local_wdata_req : OUT STD_LOGIC;
                    signal mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_cas_n : OUT STD_LOGIC;
                    signal mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mem_dqs : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_ras_n : OUT STD_LOGIC;
                    signal mem_we_n : OUT STD_LOGIC;
                    signal phy_clk : OUT STD_LOGIC;
                    signal reset_phy_clk_n : OUT STD_LOGIC;
                    signal reset_request_n : OUT STD_LOGIC
                 );
end component altmemddr_0;

component audio_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal audio_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal audio_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal audio_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal audio_pio_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_audio_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_audio_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_audio_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_audio_pio_s1 : OUT STD_LOGIC;
                    signal d1_audio_pio_s1_end_xfer : OUT STD_LOGIC
                 );
end component audio_pio_s1_arbitrator;

component audio_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component audio_pio;

component bootloader_s1_arbitrator is 
           port (
                 -- inputs:
                    signal bootloader_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal bootloader_s1_address : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
                    signal bootloader_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal bootloader_s1_chipselect : OUT STD_LOGIC;
                    signal bootloader_s1_clken : OUT STD_LOGIC;
                    signal bootloader_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal bootloader_s1_reset : OUT STD_LOGIC;
                    signal bootloader_s1_write : OUT STD_LOGIC;
                    signal bootloader_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_granted_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_granted_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_bootloader_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_requests_bootloader_s1 : OUT STD_LOGIC;
                    signal d1_bootloader_s1_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_0_data_master_read_data_valid_bootloader_s1 : OUT STD_LOGIC
                 );
end component bootloader_s1_arbitrator;

component bootloader is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
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
end component bootloader;

component cpu_0_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_debugaccess : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
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
                    signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal audio_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal bootloader_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_audio_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_debug_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_epcs_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_jamma_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_keybd_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_m95320_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_oxu210hp_if_0_s0 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_oxu210hp_int_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_spi_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_tfp410_i2c_master_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_timer_60Hz_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_uart_pc_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_uart_ts_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_usb_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_version_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_vo_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_audio_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_debug_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_epcs_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_jamma_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_keybd_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_m95320_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_oxu210hp_int_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_spi_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_60Hz_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_uart_pc_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_uart_ts_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_usb_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_version_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_vo_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_audio_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_debug_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_jamma_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_keybd_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_m95320_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_oxu210hp_int_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_spi_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_60Hz_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_uart_pc_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_uart_ts_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_usb_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_version_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_vo_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_audio_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_debug_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_epcs_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_jamma_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_keybd_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_m95320_spi_control_port : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_oxu210hp_if_0_s0 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_oxu210hp_int_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_spi_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_tfp410_i2c_master_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_60Hz_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_uart_pc_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_uart_ts_avalon_slave : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_usb_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_version_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_vo_pio_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_audio_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_bootloader_s1_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_debug_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_epcs_spi_spi_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_jamma_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_keybd_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_m95320_spi_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_one_wire_interface_0_avalon_slave_0_end_xfer : IN STD_LOGIC;
                    signal d1_oxu210hp_if_0_s0_end_xfer : IN STD_LOGIC;
                    signal d1_oxu210hp_int_s1_end_xfer : IN STD_LOGIC;
                    signal d1_spi_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_tfp410_i2c_master_s1_end_xfer : IN STD_LOGIC;
                    signal d1_timer_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_timer_60Hz_s1_end_xfer : IN STD_LOGIC;
                    signal d1_uart_pc_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_uart_ts_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_usb_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_version_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_vo_pio_s1_end_xfer : IN STD_LOGIC;
                    signal debug_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal epcs_spi_spi_control_port_irq_from_sa : IN STD_LOGIC;
                    signal epcs_spi_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal jamma_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal keybd_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal m95320_spi_control_port_irq_from_sa : IN STD_LOGIC;
                    signal m95320_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal one_wire_interface_0_avalon_slave_0_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal one_wire_interface_0_avalon_slave_0_waitrequest_from_sa : IN STD_LOGIC;
                    signal oxu210hp_if_0_s0_irq_from_sa : IN STD_LOGIC;
                    signal oxu210hp_if_0_s0_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal oxu210hp_if_0_s0_waitrequest_from_sa : IN STD_LOGIC;
                    signal oxu210hp_int_s1_irq_from_sa : IN STD_LOGIC;
                    signal oxu210hp_int_s1_readdata_from_sa : IN STD_LOGIC;
                    signal registered_cpu_0_data_master_read_data_valid_bootloader_s1 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_pio_s1_irq_from_sa : IN STD_LOGIC;
                    signal spi_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal tfp410_i2c_master_s1_irq_from_sa : IN STD_LOGIC;
                    signal tfp410_i2c_master_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal tfp410_i2c_master_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal timer_0_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_60Hz_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_60Hz_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_pc_avalon_slave_irq_from_sa : IN STD_LOGIC;
                    signal uart_pc_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_pc_avalon_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal uart_ts_avalon_slave_irq_from_sa : IN STD_LOGIC;
                    signal uart_ts_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_ts_avalon_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal usb_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal version_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vo_pio_s1_irq_from_sa : IN STD_LOGIC;
                    signal vo_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_0_data_master_dbs_write_8 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_0_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                    signal cpu_0_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_0_data_master_arbitrator;

component cpu_0_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal bootloader_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_instruction_master_address : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_instruction_master_granted_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_granted_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_altmemddr_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_bootloader_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_bootloader_s1_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (30 DOWNTO 0);
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
                    signal d_address : OUT STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component cpu_0;

component debug_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal debug_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_debug_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_debug_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_debug_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_debug_pio_s1 : OUT STD_LOGIC;
                    signal d1_debug_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal debug_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal debug_pio_s1_chipselect : OUT STD_LOGIC;
                    signal debug_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal debug_pio_s1_reset_n : OUT STD_LOGIC;
                    signal debug_pio_s1_write_n : OUT STD_LOGIC;
                    signal debug_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component debug_pio_s1_arbitrator;

component debug_pio is 
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
                    signal out_port : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component debug_pio;

component epcs_spi_spi_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal epcs_spi_spi_control_port_dataavailable : IN STD_LOGIC;
                    signal epcs_spi_spi_control_port_endofpacket : IN STD_LOGIC;
                    signal epcs_spi_spi_control_port_irq : IN STD_LOGIC;
                    signal epcs_spi_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal epcs_spi_spi_control_port_readyfordata : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_epcs_spi_spi_control_port : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_epcs_spi_spi_control_port : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_epcs_spi_spi_control_port : OUT STD_LOGIC;
                    signal d1_epcs_spi_spi_control_port_end_xfer : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal epcs_spi_spi_control_port_chipselect : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_read_n : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal epcs_spi_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_reset_n : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_write_n : OUT STD_LOGIC;
                    signal epcs_spi_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component epcs_spi_spi_control_port_arbitrator;

component epcs_spi is 
           port (
                 -- inputs:
                    signal MISO : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_from_cpu : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mem_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_select : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;

                 -- outputs:
                    signal MOSI : OUT STD_LOGIC;
                    signal SCLK : OUT STD_LOGIC;
                    signal SS_n : OUT STD_LOGIC;
                    signal data_to_cpu : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal dataavailable : OUT STD_LOGIC;
                    signal endofpacket : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component epcs_spi;

component jamma_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jamma_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_jamma_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_jamma_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_jamma_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_jamma_pio_s1 : OUT STD_LOGIC;
                    signal d1_jamma_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal jamma_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal jamma_pio_s1_chipselect : OUT STD_LOGIC;
                    signal jamma_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jamma_pio_s1_reset_n : OUT STD_LOGIC;
                    signal jamma_pio_s1_write_n : OUT STD_LOGIC;
                    signal jamma_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jamma_pio_s1_arbitrator;

component jamma_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jamma_pio;

component jtag_uart_0_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
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

component keybd_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal keybd_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_keybd_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_keybd_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_keybd_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_keybd_pio_s1 : OUT STD_LOGIC;
                    signal d1_keybd_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal keybd_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal keybd_pio_s1_chipselect : OUT STD_LOGIC;
                    signal keybd_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal keybd_pio_s1_reset_n : OUT STD_LOGIC;
                    signal keybd_pio_s1_write_n : OUT STD_LOGIC;
                    signal keybd_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component keybd_pio_s1_arbitrator;

component keybd_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component keybd_pio;

component m95320_spi_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal m95320_spi_control_port_dataavailable : IN STD_LOGIC;
                    signal m95320_spi_control_port_endofpacket : IN STD_LOGIC;
                    signal m95320_spi_control_port_irq : IN STD_LOGIC;
                    signal m95320_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal m95320_spi_control_port_readyfordata : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_m95320_spi_control_port : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_m95320_spi_control_port : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_m95320_spi_control_port : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_m95320_spi_control_port : OUT STD_LOGIC;
                    signal d1_m95320_spi_control_port_end_xfer : OUT STD_LOGIC;
                    signal m95320_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal m95320_spi_control_port_chipselect : OUT STD_LOGIC;
                    signal m95320_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                    signal m95320_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                    signal m95320_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                    signal m95320_spi_control_port_read_n : OUT STD_LOGIC;
                    signal m95320_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal m95320_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                    signal m95320_spi_control_port_reset_n : OUT STD_LOGIC;
                    signal m95320_spi_control_port_write_n : OUT STD_LOGIC;
                    signal m95320_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component m95320_spi_control_port_arbitrator;

component m95320 is 
           port (
                 -- inputs:
                    signal MISO : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_from_cpu : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mem_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_select : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;

                 -- outputs:
                    signal MOSI : OUT STD_LOGIC;
                    signal SCLK : OUT STD_LOGIC;
                    signal SS_n : OUT STD_LOGIC;
                    signal data_to_cpu : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal dataavailable : OUT STD_LOGIC;
                    signal endofpacket : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component m95320;

component one_wire_interface_0_avalon_slave_0_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal one_wire_interface_0_avalon_slave_0_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal one_wire_interface_0_avalon_slave_0_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 : OUT STD_LOGIC;
                    signal d1_one_wire_interface_0_avalon_slave_0_end_xfer : OUT STD_LOGIC;
                    signal one_wire_interface_0_avalon_slave_0_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal one_wire_interface_0_avalon_slave_0_chipselect : OUT STD_LOGIC;
                    signal one_wire_interface_0_avalon_slave_0_read : OUT STD_LOGIC;
                    signal one_wire_interface_0_avalon_slave_0_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal one_wire_interface_0_avalon_slave_0_reset : OUT STD_LOGIC;
                    signal one_wire_interface_0_avalon_slave_0_waitrequest_from_sa : OUT STD_LOGIC;
                    signal one_wire_interface_0_avalon_slave_0_write : OUT STD_LOGIC;
                    signal one_wire_interface_0_avalon_slave_0_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component one_wire_interface_0_avalon_slave_0_arbitrator;

component one_wire_interface_0 is 
           port (
                 -- inputs:
                    signal s_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal s_chipselect : IN STD_LOGIC;
                    signal s_clock : IN STD_LOGIC;
                    signal s_datain : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal s_read : IN STD_LOGIC;
                    signal s_reset : IN STD_LOGIC;
                    signal s_write : IN STD_LOGIC;

                 -- outputs:
                    signal data : INOUT STD_LOGIC;
                    signal s_dataout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal s_waitrequest : OUT STD_LOGIC
                 );
end component one_wire_interface_0;

component oxu210hp_if_0_s0_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal oxu210hp_if_0_s0_irq : IN STD_LOGIC;
                    signal oxu210hp_if_0_s0_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal oxu210hp_if_0_s0_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_oxu210hp_if_0_s0 : OUT STD_LOGIC;
                    signal d1_oxu210hp_if_0_s0_end_xfer : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_address : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal oxu210hp_if_0_s0_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal oxu210hp_if_0_s0_chipselect : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_irq_from_sa : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_read : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal oxu210hp_if_0_s0_reset : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_waitrequest_from_sa : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_write : OUT STD_LOGIC;
                    signal oxu210hp_if_0_s0_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component oxu210hp_if_0_s0_arbitrator;

component oxu210hp_if_0 is 
           port (
                 -- inputs:
                    signal avs_s0_address : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal avs_s0_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal avs_s0_chipselect : IN STD_LOGIC;
                    signal avs_s0_read : IN STD_LOGIC;
                    signal avs_s0_write : IN STD_LOGIC;
                    signal avs_s0_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal coe_uh_dreq : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal coe_uh_int_n : IN STD_LOGIC;
                    signal nios_clk : IN STD_LOGIC;
                    signal nios_rst : IN STD_LOGIC;

                 -- outputs:
                    signal avs_s0_irq : OUT STD_LOGIC;
                    signal avs_s0_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal avs_s0_waitrequest : OUT STD_LOGIC;
                    signal coe_uh_a : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal coe_uh_be : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal coe_uh_cs_n : OUT STD_LOGIC;
                    signal coe_uh_d : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal coe_uh_dack : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal coe_uh_rd_n : OUT STD_LOGIC;
                    signal coe_uh_reset_n : OUT STD_LOGIC;
                    signal coe_uh_wr_n : OUT STD_LOGIC
                 );
end component oxu210hp_if_0;

component oxu210hp_int_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal oxu210hp_int_s1_irq : IN STD_LOGIC;
                    signal oxu210hp_int_s1_readdata : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_oxu210hp_int_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_oxu210hp_int_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_oxu210hp_int_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_oxu210hp_int_s1 : OUT STD_LOGIC;
                    signal d1_oxu210hp_int_s1_end_xfer : OUT STD_LOGIC;
                    signal oxu210hp_int_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal oxu210hp_int_s1_chipselect : OUT STD_LOGIC;
                    signal oxu210hp_int_s1_irq_from_sa : OUT STD_LOGIC;
                    signal oxu210hp_int_s1_readdata_from_sa : OUT STD_LOGIC;
                    signal oxu210hp_int_s1_reset_n : OUT STD_LOGIC;
                    signal oxu210hp_int_s1_write_n : OUT STD_LOGIC;
                    signal oxu210hp_int_s1_writedata : OUT STD_LOGIC
                 );
end component oxu210hp_int_s1_arbitrator;

component oxu210hp_int is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC;

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal out_port : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC
                 );
end component oxu210hp_int;

component spi_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal spi_pio_s1_irq : IN STD_LOGIC;
                    signal spi_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_spi_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_spi_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_spi_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_spi_pio_s1 : OUT STD_LOGIC;
                    signal d1_spi_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal spi_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal spi_pio_s1_chipselect : OUT STD_LOGIC;
                    signal spi_pio_s1_irq_from_sa : OUT STD_LOGIC;
                    signal spi_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal spi_pio_s1_reset_n : OUT STD_LOGIC;
                    signal spi_pio_s1_write_n : OUT STD_LOGIC;
                    signal spi_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component spi_pio_s1_arbitrator;

component spi_pio is 
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
end component spi_pio;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
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

component tfp410_i2c_master_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_0_data_master_dbs_write_8 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_0_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal tfp410_i2c_master_s1_irq : IN STD_LOGIC;
                    signal tfp410_i2c_master_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal tfp410_i2c_master_s1_waitrequest_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_tfp410_i2c_master_s1 : OUT STD_LOGIC;
                    signal d1_tfp410_i2c_master_s1_end_xfer : OUT STD_LOGIC;
                    signal tfp410_i2c_master_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal tfp410_i2c_master_s1_chipselect : OUT STD_LOGIC;
                    signal tfp410_i2c_master_s1_irq_from_sa : OUT STD_LOGIC;
                    signal tfp410_i2c_master_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal tfp410_i2c_master_s1_reset : OUT STD_LOGIC;
                    signal tfp410_i2c_master_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal tfp410_i2c_master_s1_write : OUT STD_LOGIC;
                    signal tfp410_i2c_master_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component tfp410_i2c_master_s1_arbitrator;

component tfp410_i2c_master is 
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
end component tfp410_i2c_master;

component timer_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
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

component timer_60Hz_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal timer_60Hz_s1_irq : IN STD_LOGIC;
                    signal timer_60Hz_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_timer_60Hz_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_60Hz_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_60Hz_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_60Hz_s1 : OUT STD_LOGIC;
                    signal d1_timer_60Hz_s1_end_xfer : OUT STD_LOGIC;
                    signal timer_60Hz_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal timer_60Hz_s1_chipselect : OUT STD_LOGIC;
                    signal timer_60Hz_s1_irq_from_sa : OUT STD_LOGIC;
                    signal timer_60Hz_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_60Hz_s1_reset_n : OUT STD_LOGIC;
                    signal timer_60Hz_s1_write_n : OUT STD_LOGIC;
                    signal timer_60Hz_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_60Hz_s1_arbitrator;

component timer_60Hz is 
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
end component timer_60Hz;

component uart_pc_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal uart_pc_avalon_slave_irq : IN STD_LOGIC;
                    signal uart_pc_avalon_slave_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_pc_avalon_slave_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_uart_pc_avalon_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_uart_pc_avalon_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_uart_pc_avalon_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_uart_pc_avalon_slave : OUT STD_LOGIC;
                    signal d1_uart_pc_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal uart_pc_avalon_slave_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal uart_pc_avalon_slave_irq_from_sa : OUT STD_LOGIC;
                    signal uart_pc_avalon_slave_read : OUT STD_LOGIC;
                    signal uart_pc_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_pc_avalon_slave_reset : OUT STD_LOGIC;
                    signal uart_pc_avalon_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal uart_pc_avalon_slave_write : OUT STD_LOGIC;
                    signal uart_pc_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component uart_pc_avalon_slave_arbitrator;

component uart_pc is 
           port (
                 -- inputs:
                    signal cts : IN STD_LOGIC;
                    signal rxd : IN STD_LOGIC;
                    signal s_address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal s_clock : IN STD_LOGIC;
                    signal s_read : IN STD_LOGIC;
                    signal s_reset : IN STD_LOGIC;
                    signal s_write : IN STD_LOGIC;
                    signal s_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal rts : OUT STD_LOGIC;
                    signal rxd_led : OUT STD_LOGIC;
                    signal s_irq : OUT STD_LOGIC;
                    signal s_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal s_waitrequest : OUT STD_LOGIC;
                    signal txd : OUT STD_LOGIC;
                    signal txd_active : OUT STD_LOGIC;
                    signal txd_led : OUT STD_LOGIC
                 );
end component uart_pc;

component uart_ts_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal uart_ts_avalon_slave_irq : IN STD_LOGIC;
                    signal uart_ts_avalon_slave_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_ts_avalon_slave_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_uart_ts_avalon_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_uart_ts_avalon_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_uart_ts_avalon_slave : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_uart_ts_avalon_slave : OUT STD_LOGIC;
                    signal d1_uart_ts_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal uart_ts_avalon_slave_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal uart_ts_avalon_slave_irq_from_sa : OUT STD_LOGIC;
                    signal uart_ts_avalon_slave_read : OUT STD_LOGIC;
                    signal uart_ts_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_ts_avalon_slave_reset : OUT STD_LOGIC;
                    signal uart_ts_avalon_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal uart_ts_avalon_slave_write : OUT STD_LOGIC;
                    signal uart_ts_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component uart_ts_avalon_slave_arbitrator;

component uart_ts is 
           port (
                 -- inputs:
                    signal cts : IN STD_LOGIC;
                    signal rxd : IN STD_LOGIC;
                    signal s_address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal s_clock : IN STD_LOGIC;
                    signal s_read : IN STD_LOGIC;
                    signal s_reset : IN STD_LOGIC;
                    signal s_write : IN STD_LOGIC;
                    signal s_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal rts : OUT STD_LOGIC;
                    signal rxd_led : OUT STD_LOGIC;
                    signal s_irq : OUT STD_LOGIC;
                    signal s_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal s_waitrequest : OUT STD_LOGIC;
                    signal txd : OUT STD_LOGIC;
                    signal txd_active : OUT STD_LOGIC;
                    signal txd_led : OUT STD_LOGIC
                 );
end component uart_ts;

component usb_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal usb_pio_s1_readdata : IN STD_LOGIC_VECTOR (3 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_usb_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_usb_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_usb_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_usb_pio_s1 : OUT STD_LOGIC;
                    signal d1_usb_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal usb_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal usb_pio_s1_chipselect : OUT STD_LOGIC;
                    signal usb_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal usb_pio_s1_reset_n : OUT STD_LOGIC;
                    signal usb_pio_s1_write_n : OUT STD_LOGIC;
                    signal usb_pio_s1_writedata : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
                 );
end component usb_pio_s1_arbitrator;

component usb_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (3 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
                 );
end component usb_pio;

component version_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal version_pio_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_version_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_version_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_version_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_version_pio_s1 : OUT STD_LOGIC;
                    signal d1_version_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal version_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal version_pio_s1_chipselect : OUT STD_LOGIC;
                    signal version_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal version_pio_s1_reset_n : OUT STD_LOGIC;
                    signal version_pio_s1_write_n : OUT STD_LOGIC;
                    signal version_pio_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component version_pio_s1_arbitrator;

component version_pio is 
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
                    signal out_port : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component version_pio;

component vo_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal vo_pio_s1_irq : IN STD_LOGIC;
                    signal vo_pio_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_vo_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_vo_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_vo_pio_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_vo_pio_s1 : OUT STD_LOGIC;
                    signal d1_vo_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal vo_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal vo_pio_s1_chipselect : OUT STD_LOGIC;
                    signal vo_pio_s1_irq_from_sa : OUT STD_LOGIC;
                    signal vo_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal vo_pio_s1_reset_n : OUT STD_LOGIC;
                    signal vo_pio_s1_write_n : OUT STD_LOGIC;
                    signal vo_pio_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component vo_pio_s1_arbitrator;

component vo_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal out_port : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component vo_pio;

component ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch_module;

                signal altmemddr_0_phy_clk_out_reset_n :  STD_LOGIC;
                signal altmemddr_0_s1_address :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal altmemddr_0_s1_beginbursttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_burstcount :  STD_LOGIC;
                signal altmemddr_0_s1_byteenable :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal altmemddr_0_s1_read :  STD_LOGIC;
                signal altmemddr_0_s1_readdata :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal altmemddr_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal altmemddr_0_s1_readdatavalid :  STD_LOGIC;
                signal altmemddr_0_s1_resetrequest_n :  STD_LOGIC;
                signal altmemddr_0_s1_resetrequest_n_from_sa :  STD_LOGIC;
                signal altmemddr_0_s1_waitrequest_n :  STD_LOGIC;
                signal altmemddr_0_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal altmemddr_0_s1_write :  STD_LOGIC;
                signal altmemddr_0_s1_writedata :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal audio_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal audio_pio_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal audio_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal audio_pio_s1_reset_n :  STD_LOGIC;
                signal bootloader_s1_address :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal bootloader_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal bootloader_s1_chipselect :  STD_LOGIC;
                signal bootloader_s1_clken :  STD_LOGIC;
                signal bootloader_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal bootloader_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal bootloader_s1_reset :  STD_LOGIC;
                signal bootloader_s1_write :  STD_LOGIC;
                signal bootloader_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clk_24M_reset_n :  STD_LOGIC;
                signal cpu_0_data_master_address :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal cpu_0_data_master_address_to_slave :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal cpu_0_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_data_master_byteenable_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal cpu_0_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_data_master_dbs_write_8 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal cpu_0_data_master_debugaccess :  STD_LOGIC;
                signal cpu_0_data_master_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_audio_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_granted_debug_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_epcs_spi_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_granted_jamma_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_granted_keybd_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_m95320_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal cpu_0_data_master_granted_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal cpu_0_data_master_granted_oxu210hp_int_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_spi_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_granted_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_timer_60Hz_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_uart_pc_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_granted_uart_ts_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_granted_usb_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_version_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_vo_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_audio_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_debug_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_epcs_spi_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_jamma_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_keybd_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_m95320_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_oxu210hp_int_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_spi_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_timer_60Hz_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_uart_pc_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_uart_ts_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_usb_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_version_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_vo_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_audio_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_debug_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_jamma_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_keybd_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_m95320_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_oxu210hp_int_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_spi_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_timer_60Hz_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_uart_pc_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_uart_ts_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_usb_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_version_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_vo_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_audio_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_requests_debug_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_epcs_spi_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_requests_jamma_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_0_data_master_requests_keybd_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_m95320_spi_control_port :  STD_LOGIC;
                signal cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 :  STD_LOGIC;
                signal cpu_0_data_master_requests_oxu210hp_if_0_s0 :  STD_LOGIC;
                signal cpu_0_data_master_requests_oxu210hp_int_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_spi_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal cpu_0_data_master_requests_tfp410_i2c_master_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_timer_60Hz_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_uart_pc_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_requests_uart_ts_avalon_slave :  STD_LOGIC;
                signal cpu_0_data_master_requests_usb_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_version_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_vo_pio_s1 :  STD_LOGIC;
                signal cpu_0_data_master_waitrequest :  STD_LOGIC;
                signal cpu_0_data_master_write :  STD_LOGIC;
                signal cpu_0_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_address :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal cpu_0_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (30 DOWNTO 0);
                signal cpu_0_instruction_master_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_granted_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_latency_counter :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_read :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_readdatavalid :  STD_LOGIC;
                signal cpu_0_instruction_master_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_requests_bootloader_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
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
                signal d1_altmemddr_0_s1_end_xfer :  STD_LOGIC;
                signal d1_audio_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_bootloader_s1_end_xfer :  STD_LOGIC;
                signal d1_cpu_0_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_debug_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_epcs_spi_spi_control_port_end_xfer :  STD_LOGIC;
                signal d1_jamma_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_keybd_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_m95320_spi_control_port_end_xfer :  STD_LOGIC;
                signal d1_one_wire_interface_0_avalon_slave_0_end_xfer :  STD_LOGIC;
                signal d1_oxu210hp_if_0_s0_end_xfer :  STD_LOGIC;
                signal d1_oxu210hp_int_s1_end_xfer :  STD_LOGIC;
                signal d1_spi_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal d1_tfp410_i2c_master_s1_end_xfer :  STD_LOGIC;
                signal d1_timer_0_s1_end_xfer :  STD_LOGIC;
                signal d1_timer_60Hz_s1_end_xfer :  STD_LOGIC;
                signal d1_uart_pc_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_uart_ts_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_usb_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_version_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_vo_pio_s1_end_xfer :  STD_LOGIC;
                signal debug_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal debug_pio_s1_chipselect :  STD_LOGIC;
                signal debug_pio_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal debug_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal debug_pio_s1_reset_n :  STD_LOGIC;
                signal debug_pio_s1_write_n :  STD_LOGIC;
                signal debug_pio_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal epcs_spi_spi_control_port_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal epcs_spi_spi_control_port_chipselect :  STD_LOGIC;
                signal epcs_spi_spi_control_port_dataavailable :  STD_LOGIC;
                signal epcs_spi_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal epcs_spi_spi_control_port_endofpacket :  STD_LOGIC;
                signal epcs_spi_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal epcs_spi_spi_control_port_irq :  STD_LOGIC;
                signal epcs_spi_spi_control_port_irq_from_sa :  STD_LOGIC;
                signal epcs_spi_spi_control_port_read_n :  STD_LOGIC;
                signal epcs_spi_spi_control_port_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal epcs_spi_spi_control_port_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal epcs_spi_spi_control_port_readyfordata :  STD_LOGIC;
                signal epcs_spi_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal epcs_spi_spi_control_port_reset_n :  STD_LOGIC;
                signal epcs_spi_spi_control_port_write_n :  STD_LOGIC;
                signal epcs_spi_spi_control_port_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_MOSI_from_the_epcs_spi :  STD_LOGIC;
                signal internal_MOSI_from_the_m95320 :  STD_LOGIC;
                signal internal_SCLK_from_the_epcs_spi :  STD_LOGIC;
                signal internal_SCLK_from_the_m95320 :  STD_LOGIC;
                signal internal_SS_n_from_the_epcs_spi :  STD_LOGIC;
                signal internal_SS_n_from_the_m95320 :  STD_LOGIC;
                signal internal_altmemddr_0_phy_clk_out :  STD_LOGIC;
                signal internal_coe_i2c_scl_pad_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal internal_coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal internal_coe_i2c_sda_pad_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal internal_coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal internal_coe_uh_a_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_coe_uh_be_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_coe_uh_cs_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal internal_coe_uh_dack_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_coe_uh_rd_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal internal_coe_uh_reset_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal internal_coe_uh_wr_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal internal_local_init_done_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_local_refresh_ack_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_local_wdata_req_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_addr_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_mem_ba_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_mem_cas_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_cke_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_cs_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_dm_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_mem_odt_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_ras_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_we_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_out_port_from_the_debug_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_out_port_from_the_jamma_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_out_port_from_the_keybd_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_out_port_from_the_oxu210hp_int :  STD_LOGIC;
                signal internal_out_port_from_the_spi_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_out_port_from_the_usb_pio :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_out_port_from_the_version_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_out_port_from_the_vo_pio :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_reset_phy_clk_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_rts_from_the_uart_pc :  STD_LOGIC;
                signal internal_rts_from_the_uart_ts :  STD_LOGIC;
                signal internal_rxd_led_from_the_uart_pc :  STD_LOGIC;
                signal internal_rxd_led_from_the_uart_ts :  STD_LOGIC;
                signal internal_txd_active_from_the_uart_pc :  STD_LOGIC;
                signal internal_txd_active_from_the_uart_ts :  STD_LOGIC;
                signal internal_txd_from_the_uart_pc :  STD_LOGIC;
                signal internal_txd_from_the_uart_ts :  STD_LOGIC;
                signal internal_txd_led_from_the_uart_pc :  STD_LOGIC;
                signal internal_txd_led_from_the_uart_ts :  STD_LOGIC;
                signal jamma_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jamma_pio_s1_chipselect :  STD_LOGIC;
                signal jamma_pio_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jamma_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jamma_pio_s1_reset_n :  STD_LOGIC;
                signal jamma_pio_s1_write_n :  STD_LOGIC;
                signal jamma_pio_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
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
                signal keybd_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal keybd_pio_s1_chipselect :  STD_LOGIC;
                signal keybd_pio_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal keybd_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal keybd_pio_s1_reset_n :  STD_LOGIC;
                signal keybd_pio_s1_write_n :  STD_LOGIC;
                signal keybd_pio_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal m95320_spi_control_port_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal m95320_spi_control_port_chipselect :  STD_LOGIC;
                signal m95320_spi_control_port_dataavailable :  STD_LOGIC;
                signal m95320_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal m95320_spi_control_port_endofpacket :  STD_LOGIC;
                signal m95320_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal m95320_spi_control_port_irq :  STD_LOGIC;
                signal m95320_spi_control_port_irq_from_sa :  STD_LOGIC;
                signal m95320_spi_control_port_read_n :  STD_LOGIC;
                signal m95320_spi_control_port_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal m95320_spi_control_port_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal m95320_spi_control_port_readyfordata :  STD_LOGIC;
                signal m95320_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal m95320_spi_control_port_reset_n :  STD_LOGIC;
                signal m95320_spi_control_port_write_n :  STD_LOGIC;
                signal m95320_spi_control_port_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal module_input10 :  STD_LOGIC;
                signal module_input6 :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_wire_interface_0_avalon_slave_0_chipselect :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_read :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal one_wire_interface_0_avalon_slave_0_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal one_wire_interface_0_avalon_slave_0_reset :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_waitrequest :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_waitrequest_from_sa :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_write :  STD_LOGIC;
                signal one_wire_interface_0_avalon_slave_0_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal out_clk_altmemddr_0_aux_full_rate_clk :  STD_LOGIC;
                signal out_clk_altmemddr_0_aux_half_rate_clk :  STD_LOGIC;
                signal out_clk_altmemddr_0_phy_clk :  STD_LOGIC;
                signal oxu210hp_if_0_s0_address :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal oxu210hp_if_0_s0_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal oxu210hp_if_0_s0_chipselect :  STD_LOGIC;
                signal oxu210hp_if_0_s0_irq :  STD_LOGIC;
                signal oxu210hp_if_0_s0_irq_from_sa :  STD_LOGIC;
                signal oxu210hp_if_0_s0_read :  STD_LOGIC;
                signal oxu210hp_if_0_s0_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal oxu210hp_if_0_s0_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal oxu210hp_if_0_s0_reset :  STD_LOGIC;
                signal oxu210hp_if_0_s0_waitrequest :  STD_LOGIC;
                signal oxu210hp_if_0_s0_waitrequest_from_sa :  STD_LOGIC;
                signal oxu210hp_if_0_s0_write :  STD_LOGIC;
                signal oxu210hp_if_0_s0_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal oxu210hp_int_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal oxu210hp_int_s1_chipselect :  STD_LOGIC;
                signal oxu210hp_int_s1_irq :  STD_LOGIC;
                signal oxu210hp_int_s1_irq_from_sa :  STD_LOGIC;
                signal oxu210hp_int_s1_readdata :  STD_LOGIC;
                signal oxu210hp_int_s1_readdata_from_sa :  STD_LOGIC;
                signal oxu210hp_int_s1_reset_n :  STD_LOGIC;
                signal oxu210hp_int_s1_write_n :  STD_LOGIC;
                signal oxu210hp_int_s1_writedata :  STD_LOGIC;
                signal registered_cpu_0_data_master_read_data_valid_bootloader_s1 :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal spi_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal spi_pio_s1_chipselect :  STD_LOGIC;
                signal spi_pio_s1_irq :  STD_LOGIC;
                signal spi_pio_s1_irq_from_sa :  STD_LOGIC;
                signal spi_pio_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal spi_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal spi_pio_s1_reset_n :  STD_LOGIC;
                signal spi_pio_s1_write_n :  STD_LOGIC;
                signal spi_pio_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_address :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal sysid_control_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_reset_n :  STD_LOGIC;
                signal tfp410_i2c_master_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal tfp410_i2c_master_s1_chipselect :  STD_LOGIC;
                signal tfp410_i2c_master_s1_irq :  STD_LOGIC;
                signal tfp410_i2c_master_s1_irq_from_sa :  STD_LOGIC;
                signal tfp410_i2c_master_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal tfp410_i2c_master_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal tfp410_i2c_master_s1_reset :  STD_LOGIC;
                signal tfp410_i2c_master_s1_waitrequest_n :  STD_LOGIC;
                signal tfp410_i2c_master_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal tfp410_i2c_master_s1_write :  STD_LOGIC;
                signal tfp410_i2c_master_s1_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal timer_0_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_0_s1_chipselect :  STD_LOGIC;
                signal timer_0_s1_irq :  STD_LOGIC;
                signal timer_0_s1_irq_from_sa :  STD_LOGIC;
                signal timer_0_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_reset_n :  STD_LOGIC;
                signal timer_0_s1_write_n :  STD_LOGIC;
                signal timer_0_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_60Hz_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_60Hz_s1_chipselect :  STD_LOGIC;
                signal timer_60Hz_s1_irq :  STD_LOGIC;
                signal timer_60Hz_s1_irq_from_sa :  STD_LOGIC;
                signal timer_60Hz_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_60Hz_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_60Hz_s1_reset_n :  STD_LOGIC;
                signal timer_60Hz_s1_write_n :  STD_LOGIC;
                signal timer_60Hz_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_pc_avalon_slave_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_pc_avalon_slave_irq :  STD_LOGIC;
                signal uart_pc_avalon_slave_irq_from_sa :  STD_LOGIC;
                signal uart_pc_avalon_slave_read :  STD_LOGIC;
                signal uart_pc_avalon_slave_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_pc_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_pc_avalon_slave_reset :  STD_LOGIC;
                signal uart_pc_avalon_slave_waitrequest :  STD_LOGIC;
                signal uart_pc_avalon_slave_waitrequest_from_sa :  STD_LOGIC;
                signal uart_pc_avalon_slave_write :  STD_LOGIC;
                signal uart_pc_avalon_slave_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_ts_avalon_slave_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_ts_avalon_slave_irq :  STD_LOGIC;
                signal uart_ts_avalon_slave_irq_from_sa :  STD_LOGIC;
                signal uart_ts_avalon_slave_read :  STD_LOGIC;
                signal uart_ts_avalon_slave_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_ts_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_ts_avalon_slave_reset :  STD_LOGIC;
                signal uart_ts_avalon_slave_waitrequest :  STD_LOGIC;
                signal uart_ts_avalon_slave_waitrequest_from_sa :  STD_LOGIC;
                signal uart_ts_avalon_slave_write :  STD_LOGIC;
                signal uart_ts_avalon_slave_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal usb_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal usb_pio_s1_chipselect :  STD_LOGIC;
                signal usb_pio_s1_readdata :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal usb_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal usb_pio_s1_reset_n :  STD_LOGIC;
                signal usb_pio_s1_write_n :  STD_LOGIC;
                signal usb_pio_s1_writedata :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal version_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal version_pio_s1_chipselect :  STD_LOGIC;
                signal version_pio_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal version_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal version_pio_s1_reset_n :  STD_LOGIC;
                signal version_pio_s1_write_n :  STD_LOGIC;
                signal version_pio_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vo_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal vo_pio_s1_chipselect :  STD_LOGIC;
                signal vo_pio_s1_irq :  STD_LOGIC;
                signal vo_pio_s1_irq_from_sa :  STD_LOGIC;
                signal vo_pio_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal vo_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal vo_pio_s1_reset_n :  STD_LOGIC;
                signal vo_pio_s1_write_n :  STD_LOGIC;
                signal vo_pio_s1_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);

begin

  --the_altmemddr_0_s1, which is an e_instance
  the_altmemddr_0_s1 : altmemddr_0_s1_arbitrator
    port map(
      altmemddr_0_s1_address => altmemddr_0_s1_address,
      altmemddr_0_s1_beginbursttransfer => altmemddr_0_s1_beginbursttransfer,
      altmemddr_0_s1_burstcount => altmemddr_0_s1_burstcount,
      altmemddr_0_s1_byteenable => altmemddr_0_s1_byteenable,
      altmemddr_0_s1_read => altmemddr_0_s1_read,
      altmemddr_0_s1_readdata_from_sa => altmemddr_0_s1_readdata_from_sa,
      altmemddr_0_s1_resetrequest_n_from_sa => altmemddr_0_s1_resetrequest_n_from_sa,
      altmemddr_0_s1_waitrequest_n_from_sa => altmemddr_0_s1_waitrequest_n_from_sa,
      altmemddr_0_s1_write => altmemddr_0_s1_write,
      altmemddr_0_s1_writedata => altmemddr_0_s1_writedata,
      cpu_0_data_master_granted_altmemddr_0_s1 => cpu_0_data_master_granted_altmemddr_0_s1,
      cpu_0_data_master_qualified_request_altmemddr_0_s1 => cpu_0_data_master_qualified_request_altmemddr_0_s1,
      cpu_0_data_master_read_data_valid_altmemddr_0_s1 => cpu_0_data_master_read_data_valid_altmemddr_0_s1,
      cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register => cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register,
      cpu_0_data_master_requests_altmemddr_0_s1 => cpu_0_data_master_requests_altmemddr_0_s1,
      cpu_0_instruction_master_granted_altmemddr_0_s1 => cpu_0_instruction_master_granted_altmemddr_0_s1,
      cpu_0_instruction_master_qualified_request_altmemddr_0_s1 => cpu_0_instruction_master_qualified_request_altmemddr_0_s1,
      cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 => cpu_0_instruction_master_read_data_valid_altmemddr_0_s1,
      cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register => cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register,
      cpu_0_instruction_master_requests_altmemddr_0_s1 => cpu_0_instruction_master_requests_altmemddr_0_s1,
      d1_altmemddr_0_s1_end_xfer => d1_altmemddr_0_s1_end_xfer,
      altmemddr_0_s1_readdata => altmemddr_0_s1_readdata,
      altmemddr_0_s1_readdatavalid => altmemddr_0_s1_readdatavalid,
      altmemddr_0_s1_resetrequest_n => altmemddr_0_s1_resetrequest_n,
      altmemddr_0_s1_waitrequest_n => altmemddr_0_s1_waitrequest_n,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --altmemddr_0_aux_full_rate_clk_out out_clk assignment, which is an e_assign
  altmemddr_0_aux_full_rate_clk_out <= out_clk_altmemddr_0_aux_full_rate_clk;
  --altmemddr_0_aux_half_rate_clk_out out_clk assignment, which is an e_assign
  altmemddr_0_aux_half_rate_clk_out <= out_clk_altmemddr_0_aux_half_rate_clk;
  --altmemddr_0_phy_clk_out out_clk assignment, which is an e_assign
  internal_altmemddr_0_phy_clk_out <= out_clk_altmemddr_0_phy_clk;
  --reset is asserted asynchronously and deasserted synchronously
  ep4c_sopc_system_reset_clk_24M_domain_synch : ep4c_sopc_system_reset_clk_24M_domain_synch_module
    port map(
      data_out => clk_24M_reset_n,
      clk => clk_24M,
      data_in => module_input6,
      reset_n => reset_n_sources
    );

  module_input6 <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT ((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT altmemddr_0_s1_resetrequest_n_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT altmemddr_0_s1_resetrequest_n_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_resetrequest_from_sa))))));
  --the_altmemddr_0, which is an e_ptf_instance
  the_altmemddr_0 : altmemddr_0
    port map(
      aux_full_rate_clk => out_clk_altmemddr_0_aux_full_rate_clk,
      aux_half_rate_clk => out_clk_altmemddr_0_aux_half_rate_clk,
      local_init_done => internal_local_init_done_from_the_altmemddr_0,
      local_rdata => altmemddr_0_s1_readdata,
      local_rdata_valid => altmemddr_0_s1_readdatavalid,
      local_ready => altmemddr_0_s1_waitrequest_n,
      local_refresh_ack => internal_local_refresh_ack_from_the_altmemddr_0,
      local_wdata_req => internal_local_wdata_req_from_the_altmemddr_0,
      mem_addr => internal_mem_addr_from_the_altmemddr_0,
      mem_ba => internal_mem_ba_from_the_altmemddr_0,
      mem_cas_n => internal_mem_cas_n_from_the_altmemddr_0,
      mem_cke(0) => internal_mem_cke_from_the_altmemddr_0,
      mem_clk(0) => mem_clk_to_and_from_the_altmemddr_0,
      mem_clk_n(0) => mem_clk_n_to_and_from_the_altmemddr_0,
      mem_cs_n(0) => internal_mem_cs_n_from_the_altmemddr_0,
      mem_dm => internal_mem_dm_from_the_altmemddr_0,
      mem_dq => mem_dq_to_and_from_the_altmemddr_0,
      mem_dqs => mem_dqs_to_and_from_the_altmemddr_0,
      mem_odt(0) => internal_mem_odt_from_the_altmemddr_0,
      mem_ras_n => internal_mem_ras_n_from_the_altmemddr_0,
      mem_we_n => internal_mem_we_n_from_the_altmemddr_0,
      phy_clk => out_clk_altmemddr_0_phy_clk,
      reset_phy_clk_n => internal_reset_phy_clk_n_from_the_altmemddr_0,
      reset_request_n => altmemddr_0_s1_resetrequest_n,
      global_reset_n => global_reset_n_to_the_altmemddr_0,
      local_address => altmemddr_0_s1_address,
      local_be => altmemddr_0_s1_byteenable,
      local_burstbegin => altmemddr_0_s1_beginbursttransfer,
      local_read_req => altmemddr_0_s1_read,
      local_size => altmemddr_0_s1_burstcount,
      local_wdata => altmemddr_0_s1_writedata,
      local_write_req => altmemddr_0_s1_write,
      pll_ref_clk => clk_24M,
      soft_reset_n => clk_24M_reset_n
    );


  --the_audio_pio_s1, which is an e_instance
  the_audio_pio_s1 : audio_pio_s1_arbitrator
    port map(
      audio_pio_s1_address => audio_pio_s1_address,
      audio_pio_s1_readdata_from_sa => audio_pio_s1_readdata_from_sa,
      audio_pio_s1_reset_n => audio_pio_s1_reset_n,
      cpu_0_data_master_granted_audio_pio_s1 => cpu_0_data_master_granted_audio_pio_s1,
      cpu_0_data_master_qualified_request_audio_pio_s1 => cpu_0_data_master_qualified_request_audio_pio_s1,
      cpu_0_data_master_read_data_valid_audio_pio_s1 => cpu_0_data_master_read_data_valid_audio_pio_s1,
      cpu_0_data_master_requests_audio_pio_s1 => cpu_0_data_master_requests_audio_pio_s1,
      d1_audio_pio_s1_end_xfer => d1_audio_pio_s1_end_xfer,
      audio_pio_s1_readdata => audio_pio_s1_readdata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_audio_pio, which is an e_ptf_instance
  the_audio_pio : audio_pio
    port map(
      readdata => audio_pio_s1_readdata,
      address => audio_pio_s1_address,
      clk => internal_altmemddr_0_phy_clk_out,
      in_port => in_port_to_the_audio_pio,
      reset_n => audio_pio_s1_reset_n
    );


  --the_bootloader_s1, which is an e_instance
  the_bootloader_s1 : bootloader_s1_arbitrator
    port map(
      bootloader_s1_address => bootloader_s1_address,
      bootloader_s1_byteenable => bootloader_s1_byteenable,
      bootloader_s1_chipselect => bootloader_s1_chipselect,
      bootloader_s1_clken => bootloader_s1_clken,
      bootloader_s1_readdata_from_sa => bootloader_s1_readdata_from_sa,
      bootloader_s1_reset => bootloader_s1_reset,
      bootloader_s1_write => bootloader_s1_write,
      bootloader_s1_writedata => bootloader_s1_writedata,
      cpu_0_data_master_granted_bootloader_s1 => cpu_0_data_master_granted_bootloader_s1,
      cpu_0_data_master_qualified_request_bootloader_s1 => cpu_0_data_master_qualified_request_bootloader_s1,
      cpu_0_data_master_read_data_valid_bootloader_s1 => cpu_0_data_master_read_data_valid_bootloader_s1,
      cpu_0_data_master_requests_bootloader_s1 => cpu_0_data_master_requests_bootloader_s1,
      cpu_0_instruction_master_granted_bootloader_s1 => cpu_0_instruction_master_granted_bootloader_s1,
      cpu_0_instruction_master_qualified_request_bootloader_s1 => cpu_0_instruction_master_qualified_request_bootloader_s1,
      cpu_0_instruction_master_read_data_valid_bootloader_s1 => cpu_0_instruction_master_read_data_valid_bootloader_s1,
      cpu_0_instruction_master_requests_bootloader_s1 => cpu_0_instruction_master_requests_bootloader_s1,
      d1_bootloader_s1_end_xfer => d1_bootloader_s1_end_xfer,
      registered_cpu_0_data_master_read_data_valid_bootloader_s1 => registered_cpu_0_data_master_read_data_valid_bootloader_s1,
      bootloader_s1_readdata => bootloader_s1_readdata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register => cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_bootloader, which is an e_ptf_instance
  the_bootloader : bootloader
    port map(
      readdata => bootloader_s1_readdata,
      address => bootloader_s1_address,
      byteenable => bootloader_s1_byteenable,
      chipselect => bootloader_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      clken => bootloader_s1_clken,
      reset => bootloader_s1_reset,
      write => bootloader_s1_write,
      writedata => bootloader_s1_writedata
    );


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
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_debugaccess => cpu_0_data_master_debugaccess,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register => cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register,
      cpu_0_jtag_debug_module_readdata => cpu_0_jtag_debug_module_readdata,
      cpu_0_jtag_debug_module_resetrequest => cpu_0_jtag_debug_module_resetrequest,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_cpu_0_data_master, which is an e_instance
  the_cpu_0_data_master : cpu_0_data_master_arbitrator
    port map(
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_dbs_address => cpu_0_data_master_dbs_address,
      cpu_0_data_master_dbs_write_8 => cpu_0_data_master_dbs_write_8,
      cpu_0_data_master_irq => cpu_0_data_master_irq,
      cpu_0_data_master_no_byte_enables_and_last_term => cpu_0_data_master_no_byte_enables_and_last_term,
      cpu_0_data_master_readdata => cpu_0_data_master_readdata,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      altmemddr_0_s1_readdata_from_sa => altmemddr_0_s1_readdata_from_sa,
      altmemddr_0_s1_waitrequest_n_from_sa => altmemddr_0_s1_waitrequest_n_from_sa,
      audio_pio_s1_readdata_from_sa => audio_pio_s1_readdata_from_sa,
      bootloader_s1_readdata_from_sa => bootloader_s1_readdata_from_sa,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address => cpu_0_data_master_address,
      cpu_0_data_master_byteenable_tfp410_i2c_master_s1 => cpu_0_data_master_byteenable_tfp410_i2c_master_s1,
      cpu_0_data_master_granted_altmemddr_0_s1 => cpu_0_data_master_granted_altmemddr_0_s1,
      cpu_0_data_master_granted_audio_pio_s1 => cpu_0_data_master_granted_audio_pio_s1,
      cpu_0_data_master_granted_bootloader_s1 => cpu_0_data_master_granted_bootloader_s1,
      cpu_0_data_master_granted_cpu_0_jtag_debug_module => cpu_0_data_master_granted_cpu_0_jtag_debug_module,
      cpu_0_data_master_granted_debug_pio_s1 => cpu_0_data_master_granted_debug_pio_s1,
      cpu_0_data_master_granted_epcs_spi_spi_control_port => cpu_0_data_master_granted_epcs_spi_spi_control_port,
      cpu_0_data_master_granted_jamma_pio_s1 => cpu_0_data_master_granted_jamma_pio_s1,
      cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_granted_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_granted_keybd_pio_s1 => cpu_0_data_master_granted_keybd_pio_s1,
      cpu_0_data_master_granted_m95320_spi_control_port => cpu_0_data_master_granted_m95320_spi_control_port,
      cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_granted_oxu210hp_if_0_s0 => cpu_0_data_master_granted_oxu210hp_if_0_s0,
      cpu_0_data_master_granted_oxu210hp_int_s1 => cpu_0_data_master_granted_oxu210hp_int_s1,
      cpu_0_data_master_granted_spi_pio_s1 => cpu_0_data_master_granted_spi_pio_s1,
      cpu_0_data_master_granted_sysid_control_slave => cpu_0_data_master_granted_sysid_control_slave,
      cpu_0_data_master_granted_tfp410_i2c_master_s1 => cpu_0_data_master_granted_tfp410_i2c_master_s1,
      cpu_0_data_master_granted_timer_0_s1 => cpu_0_data_master_granted_timer_0_s1,
      cpu_0_data_master_granted_timer_60Hz_s1 => cpu_0_data_master_granted_timer_60Hz_s1,
      cpu_0_data_master_granted_uart_pc_avalon_slave => cpu_0_data_master_granted_uart_pc_avalon_slave,
      cpu_0_data_master_granted_uart_ts_avalon_slave => cpu_0_data_master_granted_uart_ts_avalon_slave,
      cpu_0_data_master_granted_usb_pio_s1 => cpu_0_data_master_granted_usb_pio_s1,
      cpu_0_data_master_granted_version_pio_s1 => cpu_0_data_master_granted_version_pio_s1,
      cpu_0_data_master_granted_vo_pio_s1 => cpu_0_data_master_granted_vo_pio_s1,
      cpu_0_data_master_qualified_request_altmemddr_0_s1 => cpu_0_data_master_qualified_request_altmemddr_0_s1,
      cpu_0_data_master_qualified_request_audio_pio_s1 => cpu_0_data_master_qualified_request_audio_pio_s1,
      cpu_0_data_master_qualified_request_bootloader_s1 => cpu_0_data_master_qualified_request_bootloader_s1,
      cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_data_master_qualified_request_debug_pio_s1 => cpu_0_data_master_qualified_request_debug_pio_s1,
      cpu_0_data_master_qualified_request_epcs_spi_spi_control_port => cpu_0_data_master_qualified_request_epcs_spi_spi_control_port,
      cpu_0_data_master_qualified_request_jamma_pio_s1 => cpu_0_data_master_qualified_request_jamma_pio_s1,
      cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_qualified_request_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_qualified_request_keybd_pio_s1 => cpu_0_data_master_qualified_request_keybd_pio_s1,
      cpu_0_data_master_qualified_request_m95320_spi_control_port => cpu_0_data_master_qualified_request_m95320_spi_control_port,
      cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 => cpu_0_data_master_qualified_request_oxu210hp_if_0_s0,
      cpu_0_data_master_qualified_request_oxu210hp_int_s1 => cpu_0_data_master_qualified_request_oxu210hp_int_s1,
      cpu_0_data_master_qualified_request_spi_pio_s1 => cpu_0_data_master_qualified_request_spi_pio_s1,
      cpu_0_data_master_qualified_request_sysid_control_slave => cpu_0_data_master_qualified_request_sysid_control_slave,
      cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 => cpu_0_data_master_qualified_request_tfp410_i2c_master_s1,
      cpu_0_data_master_qualified_request_timer_0_s1 => cpu_0_data_master_qualified_request_timer_0_s1,
      cpu_0_data_master_qualified_request_timer_60Hz_s1 => cpu_0_data_master_qualified_request_timer_60Hz_s1,
      cpu_0_data_master_qualified_request_uart_pc_avalon_slave => cpu_0_data_master_qualified_request_uart_pc_avalon_slave,
      cpu_0_data_master_qualified_request_uart_ts_avalon_slave => cpu_0_data_master_qualified_request_uart_ts_avalon_slave,
      cpu_0_data_master_qualified_request_usb_pio_s1 => cpu_0_data_master_qualified_request_usb_pio_s1,
      cpu_0_data_master_qualified_request_version_pio_s1 => cpu_0_data_master_qualified_request_version_pio_s1,
      cpu_0_data_master_qualified_request_vo_pio_s1 => cpu_0_data_master_qualified_request_vo_pio_s1,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_read_data_valid_altmemddr_0_s1 => cpu_0_data_master_read_data_valid_altmemddr_0_s1,
      cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register => cpu_0_data_master_read_data_valid_altmemddr_0_s1_shift_register,
      cpu_0_data_master_read_data_valid_audio_pio_s1 => cpu_0_data_master_read_data_valid_audio_pio_s1,
      cpu_0_data_master_read_data_valid_bootloader_s1 => cpu_0_data_master_read_data_valid_bootloader_s1,
      cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_data_master_read_data_valid_debug_pio_s1 => cpu_0_data_master_read_data_valid_debug_pio_s1,
      cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port => cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port,
      cpu_0_data_master_read_data_valid_jamma_pio_s1 => cpu_0_data_master_read_data_valid_jamma_pio_s1,
      cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_read_data_valid_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_read_data_valid_keybd_pio_s1 => cpu_0_data_master_read_data_valid_keybd_pio_s1,
      cpu_0_data_master_read_data_valid_m95320_spi_control_port => cpu_0_data_master_read_data_valid_m95320_spi_control_port,
      cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 => cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0,
      cpu_0_data_master_read_data_valid_oxu210hp_int_s1 => cpu_0_data_master_read_data_valid_oxu210hp_int_s1,
      cpu_0_data_master_read_data_valid_spi_pio_s1 => cpu_0_data_master_read_data_valid_spi_pio_s1,
      cpu_0_data_master_read_data_valid_sysid_control_slave => cpu_0_data_master_read_data_valid_sysid_control_slave,
      cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 => cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1,
      cpu_0_data_master_read_data_valid_timer_0_s1 => cpu_0_data_master_read_data_valid_timer_0_s1,
      cpu_0_data_master_read_data_valid_timer_60Hz_s1 => cpu_0_data_master_read_data_valid_timer_60Hz_s1,
      cpu_0_data_master_read_data_valid_uart_pc_avalon_slave => cpu_0_data_master_read_data_valid_uart_pc_avalon_slave,
      cpu_0_data_master_read_data_valid_uart_ts_avalon_slave => cpu_0_data_master_read_data_valid_uart_ts_avalon_slave,
      cpu_0_data_master_read_data_valid_usb_pio_s1 => cpu_0_data_master_read_data_valid_usb_pio_s1,
      cpu_0_data_master_read_data_valid_version_pio_s1 => cpu_0_data_master_read_data_valid_version_pio_s1,
      cpu_0_data_master_read_data_valid_vo_pio_s1 => cpu_0_data_master_read_data_valid_vo_pio_s1,
      cpu_0_data_master_requests_altmemddr_0_s1 => cpu_0_data_master_requests_altmemddr_0_s1,
      cpu_0_data_master_requests_audio_pio_s1 => cpu_0_data_master_requests_audio_pio_s1,
      cpu_0_data_master_requests_bootloader_s1 => cpu_0_data_master_requests_bootloader_s1,
      cpu_0_data_master_requests_cpu_0_jtag_debug_module => cpu_0_data_master_requests_cpu_0_jtag_debug_module,
      cpu_0_data_master_requests_debug_pio_s1 => cpu_0_data_master_requests_debug_pio_s1,
      cpu_0_data_master_requests_epcs_spi_spi_control_port => cpu_0_data_master_requests_epcs_spi_spi_control_port,
      cpu_0_data_master_requests_jamma_pio_s1 => cpu_0_data_master_requests_jamma_pio_s1,
      cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave => cpu_0_data_master_requests_jtag_uart_0_avalon_jtag_slave,
      cpu_0_data_master_requests_keybd_pio_s1 => cpu_0_data_master_requests_keybd_pio_s1,
      cpu_0_data_master_requests_m95320_spi_control_port => cpu_0_data_master_requests_m95320_spi_control_port,
      cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_requests_oxu210hp_if_0_s0 => cpu_0_data_master_requests_oxu210hp_if_0_s0,
      cpu_0_data_master_requests_oxu210hp_int_s1 => cpu_0_data_master_requests_oxu210hp_int_s1,
      cpu_0_data_master_requests_spi_pio_s1 => cpu_0_data_master_requests_spi_pio_s1,
      cpu_0_data_master_requests_sysid_control_slave => cpu_0_data_master_requests_sysid_control_slave,
      cpu_0_data_master_requests_tfp410_i2c_master_s1 => cpu_0_data_master_requests_tfp410_i2c_master_s1,
      cpu_0_data_master_requests_timer_0_s1 => cpu_0_data_master_requests_timer_0_s1,
      cpu_0_data_master_requests_timer_60Hz_s1 => cpu_0_data_master_requests_timer_60Hz_s1,
      cpu_0_data_master_requests_uart_pc_avalon_slave => cpu_0_data_master_requests_uart_pc_avalon_slave,
      cpu_0_data_master_requests_uart_ts_avalon_slave => cpu_0_data_master_requests_uart_ts_avalon_slave,
      cpu_0_data_master_requests_usb_pio_s1 => cpu_0_data_master_requests_usb_pio_s1,
      cpu_0_data_master_requests_version_pio_s1 => cpu_0_data_master_requests_version_pio_s1,
      cpu_0_data_master_requests_vo_pio_s1 => cpu_0_data_master_requests_vo_pio_s1,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      d1_altmemddr_0_s1_end_xfer => d1_altmemddr_0_s1_end_xfer,
      d1_audio_pio_s1_end_xfer => d1_audio_pio_s1_end_xfer,
      d1_bootloader_s1_end_xfer => d1_bootloader_s1_end_xfer,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      d1_debug_pio_s1_end_xfer => d1_debug_pio_s1_end_xfer,
      d1_epcs_spi_spi_control_port_end_xfer => d1_epcs_spi_spi_control_port_end_xfer,
      d1_jamma_pio_s1_end_xfer => d1_jamma_pio_s1_end_xfer,
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer => d1_jtag_uart_0_avalon_jtag_slave_end_xfer,
      d1_keybd_pio_s1_end_xfer => d1_keybd_pio_s1_end_xfer,
      d1_m95320_spi_control_port_end_xfer => d1_m95320_spi_control_port_end_xfer,
      d1_one_wire_interface_0_avalon_slave_0_end_xfer => d1_one_wire_interface_0_avalon_slave_0_end_xfer,
      d1_oxu210hp_if_0_s0_end_xfer => d1_oxu210hp_if_0_s0_end_xfer,
      d1_oxu210hp_int_s1_end_xfer => d1_oxu210hp_int_s1_end_xfer,
      d1_spi_pio_s1_end_xfer => d1_spi_pio_s1_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_tfp410_i2c_master_s1_end_xfer => d1_tfp410_i2c_master_s1_end_xfer,
      d1_timer_0_s1_end_xfer => d1_timer_0_s1_end_xfer,
      d1_timer_60Hz_s1_end_xfer => d1_timer_60Hz_s1_end_xfer,
      d1_uart_pc_avalon_slave_end_xfer => d1_uart_pc_avalon_slave_end_xfer,
      d1_uart_ts_avalon_slave_end_xfer => d1_uart_ts_avalon_slave_end_xfer,
      d1_usb_pio_s1_end_xfer => d1_usb_pio_s1_end_xfer,
      d1_version_pio_s1_end_xfer => d1_version_pio_s1_end_xfer,
      d1_vo_pio_s1_end_xfer => d1_vo_pio_s1_end_xfer,
      debug_pio_s1_readdata_from_sa => debug_pio_s1_readdata_from_sa,
      epcs_spi_spi_control_port_irq_from_sa => epcs_spi_spi_control_port_irq_from_sa,
      epcs_spi_spi_control_port_readdata_from_sa => epcs_spi_spi_control_port_readdata_from_sa,
      jamma_pio_s1_readdata_from_sa => jamma_pio_s1_readdata_from_sa,
      jtag_uart_0_avalon_jtag_slave_irq_from_sa => jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      jtag_uart_0_avalon_jtag_slave_readdata_from_sa => jtag_uart_0_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa,
      keybd_pio_s1_readdata_from_sa => keybd_pio_s1_readdata_from_sa,
      m95320_spi_control_port_irq_from_sa => m95320_spi_control_port_irq_from_sa,
      m95320_spi_control_port_readdata_from_sa => m95320_spi_control_port_readdata_from_sa,
      one_wire_interface_0_avalon_slave_0_readdata_from_sa => one_wire_interface_0_avalon_slave_0_readdata_from_sa,
      one_wire_interface_0_avalon_slave_0_waitrequest_from_sa => one_wire_interface_0_avalon_slave_0_waitrequest_from_sa,
      oxu210hp_if_0_s0_irq_from_sa => oxu210hp_if_0_s0_irq_from_sa,
      oxu210hp_if_0_s0_readdata_from_sa => oxu210hp_if_0_s0_readdata_from_sa,
      oxu210hp_if_0_s0_waitrequest_from_sa => oxu210hp_if_0_s0_waitrequest_from_sa,
      oxu210hp_int_s1_irq_from_sa => oxu210hp_int_s1_irq_from_sa,
      oxu210hp_int_s1_readdata_from_sa => oxu210hp_int_s1_readdata_from_sa,
      registered_cpu_0_data_master_read_data_valid_bootloader_s1 => registered_cpu_0_data_master_read_data_valid_bootloader_s1,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      spi_pio_s1_irq_from_sa => spi_pio_s1_irq_from_sa,
      spi_pio_s1_readdata_from_sa => spi_pio_s1_readdata_from_sa,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      tfp410_i2c_master_s1_irq_from_sa => tfp410_i2c_master_s1_irq_from_sa,
      tfp410_i2c_master_s1_readdata_from_sa => tfp410_i2c_master_s1_readdata_from_sa,
      tfp410_i2c_master_s1_waitrequest_n_from_sa => tfp410_i2c_master_s1_waitrequest_n_from_sa,
      timer_0_s1_irq_from_sa => timer_0_s1_irq_from_sa,
      timer_0_s1_readdata_from_sa => timer_0_s1_readdata_from_sa,
      timer_60Hz_s1_irq_from_sa => timer_60Hz_s1_irq_from_sa,
      timer_60Hz_s1_readdata_from_sa => timer_60Hz_s1_readdata_from_sa,
      uart_pc_avalon_slave_irq_from_sa => uart_pc_avalon_slave_irq_from_sa,
      uart_pc_avalon_slave_readdata_from_sa => uart_pc_avalon_slave_readdata_from_sa,
      uart_pc_avalon_slave_waitrequest_from_sa => uart_pc_avalon_slave_waitrequest_from_sa,
      uart_ts_avalon_slave_irq_from_sa => uart_ts_avalon_slave_irq_from_sa,
      uart_ts_avalon_slave_readdata_from_sa => uart_ts_avalon_slave_readdata_from_sa,
      uart_ts_avalon_slave_waitrequest_from_sa => uart_ts_avalon_slave_waitrequest_from_sa,
      usb_pio_s1_readdata_from_sa => usb_pio_s1_readdata_from_sa,
      version_pio_s1_readdata_from_sa => version_pio_s1_readdata_from_sa,
      vo_pio_s1_irq_from_sa => vo_pio_s1_irq_from_sa,
      vo_pio_s1_readdata_from_sa => vo_pio_s1_readdata_from_sa
    );


  --the_cpu_0_instruction_master, which is an e_instance
  the_cpu_0_instruction_master : cpu_0_instruction_master_arbitrator
    port map(
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_latency_counter => cpu_0_instruction_master_latency_counter,
      cpu_0_instruction_master_readdata => cpu_0_instruction_master_readdata,
      cpu_0_instruction_master_readdatavalid => cpu_0_instruction_master_readdatavalid,
      cpu_0_instruction_master_waitrequest => cpu_0_instruction_master_waitrequest,
      altmemddr_0_s1_readdata_from_sa => altmemddr_0_s1_readdata_from_sa,
      altmemddr_0_s1_waitrequest_n_from_sa => altmemddr_0_s1_waitrequest_n_from_sa,
      bootloader_s1_readdata_from_sa => bootloader_s1_readdata_from_sa,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_instruction_master_address => cpu_0_instruction_master_address,
      cpu_0_instruction_master_granted_altmemddr_0_s1 => cpu_0_instruction_master_granted_altmemddr_0_s1,
      cpu_0_instruction_master_granted_bootloader_s1 => cpu_0_instruction_master_granted_bootloader_s1,
      cpu_0_instruction_master_granted_cpu_0_jtag_debug_module => cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_qualified_request_altmemddr_0_s1 => cpu_0_instruction_master_qualified_request_altmemddr_0_s1,
      cpu_0_instruction_master_qualified_request_bootloader_s1 => cpu_0_instruction_master_qualified_request_bootloader_s1,
      cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_instruction_master_read_data_valid_altmemddr_0_s1 => cpu_0_instruction_master_read_data_valid_altmemddr_0_s1,
      cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register => cpu_0_instruction_master_read_data_valid_altmemddr_0_s1_shift_register,
      cpu_0_instruction_master_read_data_valid_bootloader_s1 => cpu_0_instruction_master_read_data_valid_bootloader_s1,
      cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_requests_altmemddr_0_s1 => cpu_0_instruction_master_requests_altmemddr_0_s1,
      cpu_0_instruction_master_requests_bootloader_s1 => cpu_0_instruction_master_requests_bootloader_s1,
      cpu_0_instruction_master_requests_cpu_0_jtag_debug_module => cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      d1_altmemddr_0_s1_end_xfer => d1_altmemddr_0_s1_end_xfer,
      d1_bootloader_s1_end_xfer => d1_bootloader_s1_end_xfer,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      reset_n => altmemddr_0_phy_clk_out_reset_n
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
      clk => internal_altmemddr_0_phy_clk_out,
      d_irq => cpu_0_data_master_irq,
      d_readdata => cpu_0_data_master_readdata,
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


  --the_debug_pio_s1, which is an e_instance
  the_debug_pio_s1 : debug_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_debug_pio_s1 => cpu_0_data_master_granted_debug_pio_s1,
      cpu_0_data_master_qualified_request_debug_pio_s1 => cpu_0_data_master_qualified_request_debug_pio_s1,
      cpu_0_data_master_read_data_valid_debug_pio_s1 => cpu_0_data_master_read_data_valid_debug_pio_s1,
      cpu_0_data_master_requests_debug_pio_s1 => cpu_0_data_master_requests_debug_pio_s1,
      d1_debug_pio_s1_end_xfer => d1_debug_pio_s1_end_xfer,
      debug_pio_s1_address => debug_pio_s1_address,
      debug_pio_s1_chipselect => debug_pio_s1_chipselect,
      debug_pio_s1_readdata_from_sa => debug_pio_s1_readdata_from_sa,
      debug_pio_s1_reset_n => debug_pio_s1_reset_n,
      debug_pio_s1_write_n => debug_pio_s1_write_n,
      debug_pio_s1_writedata => debug_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      debug_pio_s1_readdata => debug_pio_s1_readdata,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_debug_pio, which is an e_ptf_instance
  the_debug_pio : debug_pio
    port map(
      out_port => internal_out_port_from_the_debug_pio,
      readdata => debug_pio_s1_readdata,
      address => debug_pio_s1_address,
      chipselect => debug_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      in_port => in_port_to_the_debug_pio,
      reset_n => debug_pio_s1_reset_n,
      write_n => debug_pio_s1_write_n,
      writedata => debug_pio_s1_writedata
    );


  --the_epcs_spi_spi_control_port, which is an e_instance
  the_epcs_spi_spi_control_port : epcs_spi_spi_control_port_arbitrator
    port map(
      cpu_0_data_master_granted_epcs_spi_spi_control_port => cpu_0_data_master_granted_epcs_spi_spi_control_port,
      cpu_0_data_master_qualified_request_epcs_spi_spi_control_port => cpu_0_data_master_qualified_request_epcs_spi_spi_control_port,
      cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port => cpu_0_data_master_read_data_valid_epcs_spi_spi_control_port,
      cpu_0_data_master_requests_epcs_spi_spi_control_port => cpu_0_data_master_requests_epcs_spi_spi_control_port,
      d1_epcs_spi_spi_control_port_end_xfer => d1_epcs_spi_spi_control_port_end_xfer,
      epcs_spi_spi_control_port_address => epcs_spi_spi_control_port_address,
      epcs_spi_spi_control_port_chipselect => epcs_spi_spi_control_port_chipselect,
      epcs_spi_spi_control_port_dataavailable_from_sa => epcs_spi_spi_control_port_dataavailable_from_sa,
      epcs_spi_spi_control_port_endofpacket_from_sa => epcs_spi_spi_control_port_endofpacket_from_sa,
      epcs_spi_spi_control_port_irq_from_sa => epcs_spi_spi_control_port_irq_from_sa,
      epcs_spi_spi_control_port_read_n => epcs_spi_spi_control_port_read_n,
      epcs_spi_spi_control_port_readdata_from_sa => epcs_spi_spi_control_port_readdata_from_sa,
      epcs_spi_spi_control_port_readyfordata_from_sa => epcs_spi_spi_control_port_readyfordata_from_sa,
      epcs_spi_spi_control_port_reset_n => epcs_spi_spi_control_port_reset_n,
      epcs_spi_spi_control_port_write_n => epcs_spi_spi_control_port_write_n,
      epcs_spi_spi_control_port_writedata => epcs_spi_spi_control_port_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      epcs_spi_spi_control_port_dataavailable => epcs_spi_spi_control_port_dataavailable,
      epcs_spi_spi_control_port_endofpacket => epcs_spi_spi_control_port_endofpacket,
      epcs_spi_spi_control_port_irq => epcs_spi_spi_control_port_irq,
      epcs_spi_spi_control_port_readdata => epcs_spi_spi_control_port_readdata,
      epcs_spi_spi_control_port_readyfordata => epcs_spi_spi_control_port_readyfordata,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_epcs_spi, which is an e_ptf_instance
  the_epcs_spi : epcs_spi
    port map(
      MOSI => internal_MOSI_from_the_epcs_spi,
      SCLK => internal_SCLK_from_the_epcs_spi,
      SS_n => internal_SS_n_from_the_epcs_spi,
      data_to_cpu => epcs_spi_spi_control_port_readdata,
      dataavailable => epcs_spi_spi_control_port_dataavailable,
      endofpacket => epcs_spi_spi_control_port_endofpacket,
      irq => epcs_spi_spi_control_port_irq,
      readyfordata => epcs_spi_spi_control_port_readyfordata,
      MISO => MISO_to_the_epcs_spi,
      clk => internal_altmemddr_0_phy_clk_out,
      data_from_cpu => epcs_spi_spi_control_port_writedata,
      mem_addr => epcs_spi_spi_control_port_address,
      read_n => epcs_spi_spi_control_port_read_n,
      reset_n => epcs_spi_spi_control_port_reset_n,
      spi_select => epcs_spi_spi_control_port_chipselect,
      write_n => epcs_spi_spi_control_port_write_n
    );


  --the_jamma_pio_s1, which is an e_instance
  the_jamma_pio_s1 : jamma_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_jamma_pio_s1 => cpu_0_data_master_granted_jamma_pio_s1,
      cpu_0_data_master_qualified_request_jamma_pio_s1 => cpu_0_data_master_qualified_request_jamma_pio_s1,
      cpu_0_data_master_read_data_valid_jamma_pio_s1 => cpu_0_data_master_read_data_valid_jamma_pio_s1,
      cpu_0_data_master_requests_jamma_pio_s1 => cpu_0_data_master_requests_jamma_pio_s1,
      d1_jamma_pio_s1_end_xfer => d1_jamma_pio_s1_end_xfer,
      jamma_pio_s1_address => jamma_pio_s1_address,
      jamma_pio_s1_chipselect => jamma_pio_s1_chipselect,
      jamma_pio_s1_readdata_from_sa => jamma_pio_s1_readdata_from_sa,
      jamma_pio_s1_reset_n => jamma_pio_s1_reset_n,
      jamma_pio_s1_write_n => jamma_pio_s1_write_n,
      jamma_pio_s1_writedata => jamma_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      jamma_pio_s1_readdata => jamma_pio_s1_readdata,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_jamma_pio, which is an e_ptf_instance
  the_jamma_pio : jamma_pio
    port map(
      out_port => internal_out_port_from_the_jamma_pio,
      readdata => jamma_pio_s1_readdata,
      address => jamma_pio_s1_address,
      chipselect => jamma_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => jamma_pio_s1_reset_n,
      write_n => jamma_pio_s1_write_n,
      writedata => jamma_pio_s1_writedata
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
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      jtag_uart_0_avalon_jtag_slave_dataavailable => jtag_uart_0_avalon_jtag_slave_dataavailable,
      jtag_uart_0_avalon_jtag_slave_irq => jtag_uart_0_avalon_jtag_slave_irq,
      jtag_uart_0_avalon_jtag_slave_readdata => jtag_uart_0_avalon_jtag_slave_readdata,
      jtag_uart_0_avalon_jtag_slave_readyfordata => jtag_uart_0_avalon_jtag_slave_readyfordata,
      jtag_uart_0_avalon_jtag_slave_waitrequest => jtag_uart_0_avalon_jtag_slave_waitrequest,
      reset_n => altmemddr_0_phy_clk_out_reset_n
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
      clk => internal_altmemddr_0_phy_clk_out,
      rst_n => jtag_uart_0_avalon_jtag_slave_reset_n
    );


  --the_keybd_pio_s1, which is an e_instance
  the_keybd_pio_s1 : keybd_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_keybd_pio_s1 => cpu_0_data_master_granted_keybd_pio_s1,
      cpu_0_data_master_qualified_request_keybd_pio_s1 => cpu_0_data_master_qualified_request_keybd_pio_s1,
      cpu_0_data_master_read_data_valid_keybd_pio_s1 => cpu_0_data_master_read_data_valid_keybd_pio_s1,
      cpu_0_data_master_requests_keybd_pio_s1 => cpu_0_data_master_requests_keybd_pio_s1,
      d1_keybd_pio_s1_end_xfer => d1_keybd_pio_s1_end_xfer,
      keybd_pio_s1_address => keybd_pio_s1_address,
      keybd_pio_s1_chipselect => keybd_pio_s1_chipselect,
      keybd_pio_s1_readdata_from_sa => keybd_pio_s1_readdata_from_sa,
      keybd_pio_s1_reset_n => keybd_pio_s1_reset_n,
      keybd_pio_s1_write_n => keybd_pio_s1_write_n,
      keybd_pio_s1_writedata => keybd_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      keybd_pio_s1_readdata => keybd_pio_s1_readdata,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_keybd_pio, which is an e_ptf_instance
  the_keybd_pio : keybd_pio
    port map(
      out_port => internal_out_port_from_the_keybd_pio,
      readdata => keybd_pio_s1_readdata,
      address => keybd_pio_s1_address,
      chipselect => keybd_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => keybd_pio_s1_reset_n,
      write_n => keybd_pio_s1_write_n,
      writedata => keybd_pio_s1_writedata
    );


  --the_m95320_spi_control_port, which is an e_instance
  the_m95320_spi_control_port : m95320_spi_control_port_arbitrator
    port map(
      cpu_0_data_master_granted_m95320_spi_control_port => cpu_0_data_master_granted_m95320_spi_control_port,
      cpu_0_data_master_qualified_request_m95320_spi_control_port => cpu_0_data_master_qualified_request_m95320_spi_control_port,
      cpu_0_data_master_read_data_valid_m95320_spi_control_port => cpu_0_data_master_read_data_valid_m95320_spi_control_port,
      cpu_0_data_master_requests_m95320_spi_control_port => cpu_0_data_master_requests_m95320_spi_control_port,
      d1_m95320_spi_control_port_end_xfer => d1_m95320_spi_control_port_end_xfer,
      m95320_spi_control_port_address => m95320_spi_control_port_address,
      m95320_spi_control_port_chipselect => m95320_spi_control_port_chipselect,
      m95320_spi_control_port_dataavailable_from_sa => m95320_spi_control_port_dataavailable_from_sa,
      m95320_spi_control_port_endofpacket_from_sa => m95320_spi_control_port_endofpacket_from_sa,
      m95320_spi_control_port_irq_from_sa => m95320_spi_control_port_irq_from_sa,
      m95320_spi_control_port_read_n => m95320_spi_control_port_read_n,
      m95320_spi_control_port_readdata_from_sa => m95320_spi_control_port_readdata_from_sa,
      m95320_spi_control_port_readyfordata_from_sa => m95320_spi_control_port_readyfordata_from_sa,
      m95320_spi_control_port_reset_n => m95320_spi_control_port_reset_n,
      m95320_spi_control_port_write_n => m95320_spi_control_port_write_n,
      m95320_spi_control_port_writedata => m95320_spi_control_port_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      m95320_spi_control_port_dataavailable => m95320_spi_control_port_dataavailable,
      m95320_spi_control_port_endofpacket => m95320_spi_control_port_endofpacket,
      m95320_spi_control_port_irq => m95320_spi_control_port_irq,
      m95320_spi_control_port_readdata => m95320_spi_control_port_readdata,
      m95320_spi_control_port_readyfordata => m95320_spi_control_port_readyfordata,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_m95320, which is an e_ptf_instance
  the_m95320 : m95320
    port map(
      MOSI => internal_MOSI_from_the_m95320,
      SCLK => internal_SCLK_from_the_m95320,
      SS_n => internal_SS_n_from_the_m95320,
      data_to_cpu => m95320_spi_control_port_readdata,
      dataavailable => m95320_spi_control_port_dataavailable,
      endofpacket => m95320_spi_control_port_endofpacket,
      irq => m95320_spi_control_port_irq,
      readyfordata => m95320_spi_control_port_readyfordata,
      MISO => MISO_to_the_m95320,
      clk => internal_altmemddr_0_phy_clk_out,
      data_from_cpu => m95320_spi_control_port_writedata,
      mem_addr => m95320_spi_control_port_address,
      read_n => m95320_spi_control_port_read_n,
      reset_n => m95320_spi_control_port_reset_n,
      spi_select => m95320_spi_control_port_chipselect,
      write_n => m95320_spi_control_port_write_n
    );


  --the_one_wire_interface_0_avalon_slave_0, which is an e_instance
  the_one_wire_interface_0_avalon_slave_0 : one_wire_interface_0_avalon_slave_0_arbitrator
    port map(
      cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_granted_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_qualified_request_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_read_data_valid_one_wire_interface_0_avalon_slave_0,
      cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0 => cpu_0_data_master_requests_one_wire_interface_0_avalon_slave_0,
      d1_one_wire_interface_0_avalon_slave_0_end_xfer => d1_one_wire_interface_0_avalon_slave_0_end_xfer,
      one_wire_interface_0_avalon_slave_0_address => one_wire_interface_0_avalon_slave_0_address,
      one_wire_interface_0_avalon_slave_0_chipselect => one_wire_interface_0_avalon_slave_0_chipselect,
      one_wire_interface_0_avalon_slave_0_read => one_wire_interface_0_avalon_slave_0_read,
      one_wire_interface_0_avalon_slave_0_readdata_from_sa => one_wire_interface_0_avalon_slave_0_readdata_from_sa,
      one_wire_interface_0_avalon_slave_0_reset => one_wire_interface_0_avalon_slave_0_reset,
      one_wire_interface_0_avalon_slave_0_waitrequest_from_sa => one_wire_interface_0_avalon_slave_0_waitrequest_from_sa,
      one_wire_interface_0_avalon_slave_0_write => one_wire_interface_0_avalon_slave_0_write,
      one_wire_interface_0_avalon_slave_0_writedata => one_wire_interface_0_avalon_slave_0_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      one_wire_interface_0_avalon_slave_0_readdata => one_wire_interface_0_avalon_slave_0_readdata,
      one_wire_interface_0_avalon_slave_0_waitrequest => one_wire_interface_0_avalon_slave_0_waitrequest,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_one_wire_interface_0, which is an e_ptf_instance
  the_one_wire_interface_0 : one_wire_interface_0
    port map(
      data => data_to_and_from_the_one_wire_interface_0,
      s_dataout => one_wire_interface_0_avalon_slave_0_readdata,
      s_waitrequest => one_wire_interface_0_avalon_slave_0_waitrequest,
      s_address => one_wire_interface_0_avalon_slave_0_address,
      s_chipselect => one_wire_interface_0_avalon_slave_0_chipselect,
      s_clock => internal_altmemddr_0_phy_clk_out,
      s_datain => one_wire_interface_0_avalon_slave_0_writedata,
      s_read => one_wire_interface_0_avalon_slave_0_read,
      s_reset => one_wire_interface_0_avalon_slave_0_reset,
      s_write => one_wire_interface_0_avalon_slave_0_write
    );


  --the_oxu210hp_if_0_s0, which is an e_instance
  the_oxu210hp_if_0_s0 : oxu210hp_if_0_s0_arbitrator
    port map(
      cpu_0_data_master_granted_oxu210hp_if_0_s0 => cpu_0_data_master_granted_oxu210hp_if_0_s0,
      cpu_0_data_master_qualified_request_oxu210hp_if_0_s0 => cpu_0_data_master_qualified_request_oxu210hp_if_0_s0,
      cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0 => cpu_0_data_master_read_data_valid_oxu210hp_if_0_s0,
      cpu_0_data_master_requests_oxu210hp_if_0_s0 => cpu_0_data_master_requests_oxu210hp_if_0_s0,
      d1_oxu210hp_if_0_s0_end_xfer => d1_oxu210hp_if_0_s0_end_xfer,
      oxu210hp_if_0_s0_address => oxu210hp_if_0_s0_address,
      oxu210hp_if_0_s0_byteenable => oxu210hp_if_0_s0_byteenable,
      oxu210hp_if_0_s0_chipselect => oxu210hp_if_0_s0_chipselect,
      oxu210hp_if_0_s0_irq_from_sa => oxu210hp_if_0_s0_irq_from_sa,
      oxu210hp_if_0_s0_read => oxu210hp_if_0_s0_read,
      oxu210hp_if_0_s0_readdata_from_sa => oxu210hp_if_0_s0_readdata_from_sa,
      oxu210hp_if_0_s0_reset => oxu210hp_if_0_s0_reset,
      oxu210hp_if_0_s0_waitrequest_from_sa => oxu210hp_if_0_s0_waitrequest_from_sa,
      oxu210hp_if_0_s0_write => oxu210hp_if_0_s0_write,
      oxu210hp_if_0_s0_writedata => oxu210hp_if_0_s0_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      oxu210hp_if_0_s0_irq => oxu210hp_if_0_s0_irq,
      oxu210hp_if_0_s0_readdata => oxu210hp_if_0_s0_readdata,
      oxu210hp_if_0_s0_waitrequest => oxu210hp_if_0_s0_waitrequest,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_oxu210hp_if_0, which is an e_ptf_instance
  the_oxu210hp_if_0 : oxu210hp_if_0
    port map(
      avs_s0_irq => oxu210hp_if_0_s0_irq,
      avs_s0_readdata => oxu210hp_if_0_s0_readdata,
      avs_s0_waitrequest => oxu210hp_if_0_s0_waitrequest,
      coe_uh_a => internal_coe_uh_a_from_the_oxu210hp_if_0,
      coe_uh_be => internal_coe_uh_be_from_the_oxu210hp_if_0,
      coe_uh_cs_n => internal_coe_uh_cs_n_from_the_oxu210hp_if_0,
      coe_uh_d => coe_uh_d_to_and_from_the_oxu210hp_if_0,
      coe_uh_dack => internal_coe_uh_dack_from_the_oxu210hp_if_0,
      coe_uh_rd_n => internal_coe_uh_rd_n_from_the_oxu210hp_if_0,
      coe_uh_reset_n => internal_coe_uh_reset_n_from_the_oxu210hp_if_0,
      coe_uh_wr_n => internal_coe_uh_wr_n_from_the_oxu210hp_if_0,
      avs_s0_address => oxu210hp_if_0_s0_address,
      avs_s0_byteenable => oxu210hp_if_0_s0_byteenable,
      avs_s0_chipselect => oxu210hp_if_0_s0_chipselect,
      avs_s0_read => oxu210hp_if_0_s0_read,
      avs_s0_write => oxu210hp_if_0_s0_write,
      avs_s0_writedata => oxu210hp_if_0_s0_writedata,
      coe_uh_dreq => coe_uh_dreq_to_the_oxu210hp_if_0,
      coe_uh_int_n => coe_uh_int_n_to_the_oxu210hp_if_0,
      nios_clk => internal_altmemddr_0_phy_clk_out,
      nios_rst => oxu210hp_if_0_s0_reset
    );


  --the_oxu210hp_int_s1, which is an e_instance
  the_oxu210hp_int_s1 : oxu210hp_int_s1_arbitrator
    port map(
      cpu_0_data_master_granted_oxu210hp_int_s1 => cpu_0_data_master_granted_oxu210hp_int_s1,
      cpu_0_data_master_qualified_request_oxu210hp_int_s1 => cpu_0_data_master_qualified_request_oxu210hp_int_s1,
      cpu_0_data_master_read_data_valid_oxu210hp_int_s1 => cpu_0_data_master_read_data_valid_oxu210hp_int_s1,
      cpu_0_data_master_requests_oxu210hp_int_s1 => cpu_0_data_master_requests_oxu210hp_int_s1,
      d1_oxu210hp_int_s1_end_xfer => d1_oxu210hp_int_s1_end_xfer,
      oxu210hp_int_s1_address => oxu210hp_int_s1_address,
      oxu210hp_int_s1_chipselect => oxu210hp_int_s1_chipselect,
      oxu210hp_int_s1_irq_from_sa => oxu210hp_int_s1_irq_from_sa,
      oxu210hp_int_s1_readdata_from_sa => oxu210hp_int_s1_readdata_from_sa,
      oxu210hp_int_s1_reset_n => oxu210hp_int_s1_reset_n,
      oxu210hp_int_s1_write_n => oxu210hp_int_s1_write_n,
      oxu210hp_int_s1_writedata => oxu210hp_int_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      oxu210hp_int_s1_irq => oxu210hp_int_s1_irq,
      oxu210hp_int_s1_readdata => oxu210hp_int_s1_readdata,
      reset_n => altmemddr_0_phy_clk_out_reset_n
    );


  --the_oxu210hp_int, which is an e_ptf_instance
  the_oxu210hp_int : oxu210hp_int
    port map(
      irq => oxu210hp_int_s1_irq,
      out_port => internal_out_port_from_the_oxu210hp_int,
      readdata => oxu210hp_int_s1_readdata,
      address => oxu210hp_int_s1_address,
      chipselect => oxu210hp_int_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      in_port => in_port_to_the_oxu210hp_int,
      reset_n => oxu210hp_int_s1_reset_n,
      write_n => oxu210hp_int_s1_write_n,
      writedata => oxu210hp_int_s1_writedata
    );


  --the_spi_pio_s1, which is an e_instance
  the_spi_pio_s1 : spi_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_spi_pio_s1 => cpu_0_data_master_granted_spi_pio_s1,
      cpu_0_data_master_qualified_request_spi_pio_s1 => cpu_0_data_master_qualified_request_spi_pio_s1,
      cpu_0_data_master_read_data_valid_spi_pio_s1 => cpu_0_data_master_read_data_valid_spi_pio_s1,
      cpu_0_data_master_requests_spi_pio_s1 => cpu_0_data_master_requests_spi_pio_s1,
      d1_spi_pio_s1_end_xfer => d1_spi_pio_s1_end_xfer,
      spi_pio_s1_address => spi_pio_s1_address,
      spi_pio_s1_chipselect => spi_pio_s1_chipselect,
      spi_pio_s1_irq_from_sa => spi_pio_s1_irq_from_sa,
      spi_pio_s1_readdata_from_sa => spi_pio_s1_readdata_from_sa,
      spi_pio_s1_reset_n => spi_pio_s1_reset_n,
      spi_pio_s1_write_n => spi_pio_s1_write_n,
      spi_pio_s1_writedata => spi_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      spi_pio_s1_irq => spi_pio_s1_irq,
      spi_pio_s1_readdata => spi_pio_s1_readdata
    );


  --the_spi_pio, which is an e_ptf_instance
  the_spi_pio : spi_pio
    port map(
      irq => spi_pio_s1_irq,
      out_port => internal_out_port_from_the_spi_pio,
      readdata => spi_pio_s1_readdata,
      address => spi_pio_s1_address,
      chipselect => spi_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      in_port => in_port_to_the_spi_pio,
      reset_n => spi_pio_s1_reset_n,
      write_n => spi_pio_s1_write_n,
      writedata => spi_pio_s1_writedata
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
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
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


  --the_tfp410_i2c_master_s1, which is an e_instance
  the_tfp410_i2c_master_s1 : tfp410_i2c_master_s1_arbitrator
    port map(
      cpu_0_data_master_byteenable_tfp410_i2c_master_s1 => cpu_0_data_master_byteenable_tfp410_i2c_master_s1,
      cpu_0_data_master_granted_tfp410_i2c_master_s1 => cpu_0_data_master_granted_tfp410_i2c_master_s1,
      cpu_0_data_master_qualified_request_tfp410_i2c_master_s1 => cpu_0_data_master_qualified_request_tfp410_i2c_master_s1,
      cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1 => cpu_0_data_master_read_data_valid_tfp410_i2c_master_s1,
      cpu_0_data_master_requests_tfp410_i2c_master_s1 => cpu_0_data_master_requests_tfp410_i2c_master_s1,
      d1_tfp410_i2c_master_s1_end_xfer => d1_tfp410_i2c_master_s1_end_xfer,
      tfp410_i2c_master_s1_address => tfp410_i2c_master_s1_address,
      tfp410_i2c_master_s1_chipselect => tfp410_i2c_master_s1_chipselect,
      tfp410_i2c_master_s1_irq_from_sa => tfp410_i2c_master_s1_irq_from_sa,
      tfp410_i2c_master_s1_readdata_from_sa => tfp410_i2c_master_s1_readdata_from_sa,
      tfp410_i2c_master_s1_reset => tfp410_i2c_master_s1_reset,
      tfp410_i2c_master_s1_waitrequest_n_from_sa => tfp410_i2c_master_s1_waitrequest_n_from_sa,
      tfp410_i2c_master_s1_write => tfp410_i2c_master_s1_write,
      tfp410_i2c_master_s1_writedata => tfp410_i2c_master_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_dbs_address => cpu_0_data_master_dbs_address,
      cpu_0_data_master_dbs_write_8 => cpu_0_data_master_dbs_write_8,
      cpu_0_data_master_no_byte_enables_and_last_term => cpu_0_data_master_no_byte_enables_and_last_term,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      tfp410_i2c_master_s1_irq => tfp410_i2c_master_s1_irq,
      tfp410_i2c_master_s1_readdata => tfp410_i2c_master_s1_readdata,
      tfp410_i2c_master_s1_waitrequest_n => tfp410_i2c_master_s1_waitrequest_n
    );


  --the_tfp410_i2c_master, which is an e_ptf_instance
  the_tfp410_i2c_master : tfp410_i2c_master
    port map(
      avs_s1_readdata => tfp410_i2c_master_s1_readdata,
      avs_s1_waitrequest_n => tfp410_i2c_master_s1_waitrequest_n,
      coe_i2c_scl_pad_o => internal_coe_i2c_scl_pad_o_from_the_tfp410_i2c_master,
      coe_i2c_scl_padoen_o => internal_coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master,
      coe_i2c_sda_pad_o => internal_coe_i2c_sda_pad_o_from_the_tfp410_i2c_master,
      coe_i2c_sda_padoen_o => internal_coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master,
      ins_irq1_irq => tfp410_i2c_master_s1_irq,
      avs_s1_address => tfp410_i2c_master_s1_address,
      avs_s1_chipselect => tfp410_i2c_master_s1_chipselect,
      avs_s1_write => tfp410_i2c_master_s1_write,
      avs_s1_writedata => tfp410_i2c_master_s1_writedata,
      coe_arst_arst_i => coe_arst_arst_i_to_the_tfp410_i2c_master,
      coe_i2c_scl_pad_i => coe_i2c_scl_pad_i_to_the_tfp410_i2c_master,
      coe_i2c_sda_pad_i => coe_i2c_sda_pad_i_to_the_tfp410_i2c_master,
      csi_clockreset_clk => internal_altmemddr_0_phy_clk_out,
      csi_clockreset_reset => tfp410_i2c_master_s1_reset
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
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
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
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => timer_0_s1_reset_n,
      write_n => timer_0_s1_write_n,
      writedata => timer_0_s1_writedata
    );


  --the_timer_60Hz_s1, which is an e_instance
  the_timer_60Hz_s1 : timer_60Hz_s1_arbitrator
    port map(
      cpu_0_data_master_granted_timer_60Hz_s1 => cpu_0_data_master_granted_timer_60Hz_s1,
      cpu_0_data_master_qualified_request_timer_60Hz_s1 => cpu_0_data_master_qualified_request_timer_60Hz_s1,
      cpu_0_data_master_read_data_valid_timer_60Hz_s1 => cpu_0_data_master_read_data_valid_timer_60Hz_s1,
      cpu_0_data_master_requests_timer_60Hz_s1 => cpu_0_data_master_requests_timer_60Hz_s1,
      d1_timer_60Hz_s1_end_xfer => d1_timer_60Hz_s1_end_xfer,
      timer_60Hz_s1_address => timer_60Hz_s1_address,
      timer_60Hz_s1_chipselect => timer_60Hz_s1_chipselect,
      timer_60Hz_s1_irq_from_sa => timer_60Hz_s1_irq_from_sa,
      timer_60Hz_s1_readdata_from_sa => timer_60Hz_s1_readdata_from_sa,
      timer_60Hz_s1_reset_n => timer_60Hz_s1_reset_n,
      timer_60Hz_s1_write_n => timer_60Hz_s1_write_n,
      timer_60Hz_s1_writedata => timer_60Hz_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      timer_60Hz_s1_irq => timer_60Hz_s1_irq,
      timer_60Hz_s1_readdata => timer_60Hz_s1_readdata
    );


  --the_timer_60Hz, which is an e_ptf_instance
  the_timer_60Hz : timer_60Hz
    port map(
      irq => timer_60Hz_s1_irq,
      readdata => timer_60Hz_s1_readdata,
      address => timer_60Hz_s1_address,
      chipselect => timer_60Hz_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => timer_60Hz_s1_reset_n,
      write_n => timer_60Hz_s1_write_n,
      writedata => timer_60Hz_s1_writedata
    );


  --the_uart_pc_avalon_slave, which is an e_instance
  the_uart_pc_avalon_slave : uart_pc_avalon_slave_arbitrator
    port map(
      cpu_0_data_master_granted_uart_pc_avalon_slave => cpu_0_data_master_granted_uart_pc_avalon_slave,
      cpu_0_data_master_qualified_request_uart_pc_avalon_slave => cpu_0_data_master_qualified_request_uart_pc_avalon_slave,
      cpu_0_data_master_read_data_valid_uart_pc_avalon_slave => cpu_0_data_master_read_data_valid_uart_pc_avalon_slave,
      cpu_0_data_master_requests_uart_pc_avalon_slave => cpu_0_data_master_requests_uart_pc_avalon_slave,
      d1_uart_pc_avalon_slave_end_xfer => d1_uart_pc_avalon_slave_end_xfer,
      uart_pc_avalon_slave_address => uart_pc_avalon_slave_address,
      uart_pc_avalon_slave_irq_from_sa => uart_pc_avalon_slave_irq_from_sa,
      uart_pc_avalon_slave_read => uart_pc_avalon_slave_read,
      uart_pc_avalon_slave_readdata_from_sa => uart_pc_avalon_slave_readdata_from_sa,
      uart_pc_avalon_slave_reset => uart_pc_avalon_slave_reset,
      uart_pc_avalon_slave_waitrequest_from_sa => uart_pc_avalon_slave_waitrequest_from_sa,
      uart_pc_avalon_slave_write => uart_pc_avalon_slave_write,
      uart_pc_avalon_slave_writedata => uart_pc_avalon_slave_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      uart_pc_avalon_slave_irq => uart_pc_avalon_slave_irq,
      uart_pc_avalon_slave_readdata => uart_pc_avalon_slave_readdata,
      uart_pc_avalon_slave_waitrequest => uart_pc_avalon_slave_waitrequest
    );


  --the_uart_pc, which is an e_ptf_instance
  the_uart_pc : uart_pc
    port map(
      rts => internal_rts_from_the_uart_pc,
      rxd_led => internal_rxd_led_from_the_uart_pc,
      s_irq => uart_pc_avalon_slave_irq,
      s_readdata => uart_pc_avalon_slave_readdata,
      s_waitrequest => uart_pc_avalon_slave_waitrequest,
      txd => internal_txd_from_the_uart_pc,
      txd_active => internal_txd_active_from_the_uart_pc,
      txd_led => internal_txd_led_from_the_uart_pc,
      cts => cts_to_the_uart_pc,
      rxd => rxd_to_the_uart_pc,
      s_address => uart_pc_avalon_slave_address,
      s_clock => internal_altmemddr_0_phy_clk_out,
      s_read => uart_pc_avalon_slave_read,
      s_reset => uart_pc_avalon_slave_reset,
      s_write => uart_pc_avalon_slave_write,
      s_writedata => uart_pc_avalon_slave_writedata
    );


  --the_uart_ts_avalon_slave, which is an e_instance
  the_uart_ts_avalon_slave : uart_ts_avalon_slave_arbitrator
    port map(
      cpu_0_data_master_granted_uart_ts_avalon_slave => cpu_0_data_master_granted_uart_ts_avalon_slave,
      cpu_0_data_master_qualified_request_uart_ts_avalon_slave => cpu_0_data_master_qualified_request_uart_ts_avalon_slave,
      cpu_0_data_master_read_data_valid_uart_ts_avalon_slave => cpu_0_data_master_read_data_valid_uart_ts_avalon_slave,
      cpu_0_data_master_requests_uart_ts_avalon_slave => cpu_0_data_master_requests_uart_ts_avalon_slave,
      d1_uart_ts_avalon_slave_end_xfer => d1_uart_ts_avalon_slave_end_xfer,
      uart_ts_avalon_slave_address => uart_ts_avalon_slave_address,
      uart_ts_avalon_slave_irq_from_sa => uart_ts_avalon_slave_irq_from_sa,
      uart_ts_avalon_slave_read => uart_ts_avalon_slave_read,
      uart_ts_avalon_slave_readdata_from_sa => uart_ts_avalon_slave_readdata_from_sa,
      uart_ts_avalon_slave_reset => uart_ts_avalon_slave_reset,
      uart_ts_avalon_slave_waitrequest_from_sa => uart_ts_avalon_slave_waitrequest_from_sa,
      uart_ts_avalon_slave_write => uart_ts_avalon_slave_write,
      uart_ts_avalon_slave_writedata => uart_ts_avalon_slave_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      uart_ts_avalon_slave_irq => uart_ts_avalon_slave_irq,
      uart_ts_avalon_slave_readdata => uart_ts_avalon_slave_readdata,
      uart_ts_avalon_slave_waitrequest => uart_ts_avalon_slave_waitrequest
    );


  --the_uart_ts, which is an e_ptf_instance
  the_uart_ts : uart_ts
    port map(
      rts => internal_rts_from_the_uart_ts,
      rxd_led => internal_rxd_led_from_the_uart_ts,
      s_irq => uart_ts_avalon_slave_irq,
      s_readdata => uart_ts_avalon_slave_readdata,
      s_waitrequest => uart_ts_avalon_slave_waitrequest,
      txd => internal_txd_from_the_uart_ts,
      txd_active => internal_txd_active_from_the_uart_ts,
      txd_led => internal_txd_led_from_the_uart_ts,
      cts => cts_to_the_uart_ts,
      rxd => rxd_to_the_uart_ts,
      s_address => uart_ts_avalon_slave_address,
      s_clock => internal_altmemddr_0_phy_clk_out,
      s_read => uart_ts_avalon_slave_read,
      s_reset => uart_ts_avalon_slave_reset,
      s_write => uart_ts_avalon_slave_write,
      s_writedata => uart_ts_avalon_slave_writedata
    );


  --the_usb_pio_s1, which is an e_instance
  the_usb_pio_s1 : usb_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_usb_pio_s1 => cpu_0_data_master_granted_usb_pio_s1,
      cpu_0_data_master_qualified_request_usb_pio_s1 => cpu_0_data_master_qualified_request_usb_pio_s1,
      cpu_0_data_master_read_data_valid_usb_pio_s1 => cpu_0_data_master_read_data_valid_usb_pio_s1,
      cpu_0_data_master_requests_usb_pio_s1 => cpu_0_data_master_requests_usb_pio_s1,
      d1_usb_pio_s1_end_xfer => d1_usb_pio_s1_end_xfer,
      usb_pio_s1_address => usb_pio_s1_address,
      usb_pio_s1_chipselect => usb_pio_s1_chipselect,
      usb_pio_s1_readdata_from_sa => usb_pio_s1_readdata_from_sa,
      usb_pio_s1_reset_n => usb_pio_s1_reset_n,
      usb_pio_s1_write_n => usb_pio_s1_write_n,
      usb_pio_s1_writedata => usb_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      usb_pio_s1_readdata => usb_pio_s1_readdata
    );


  --the_usb_pio, which is an e_ptf_instance
  the_usb_pio : usb_pio
    port map(
      out_port => internal_out_port_from_the_usb_pio,
      readdata => usb_pio_s1_readdata,
      address => usb_pio_s1_address,
      chipselect => usb_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => usb_pio_s1_reset_n,
      write_n => usb_pio_s1_write_n,
      writedata => usb_pio_s1_writedata
    );


  --the_version_pio_s1, which is an e_instance
  the_version_pio_s1 : version_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_version_pio_s1 => cpu_0_data_master_granted_version_pio_s1,
      cpu_0_data_master_qualified_request_version_pio_s1 => cpu_0_data_master_qualified_request_version_pio_s1,
      cpu_0_data_master_read_data_valid_version_pio_s1 => cpu_0_data_master_read_data_valid_version_pio_s1,
      cpu_0_data_master_requests_version_pio_s1 => cpu_0_data_master_requests_version_pio_s1,
      d1_version_pio_s1_end_xfer => d1_version_pio_s1_end_xfer,
      version_pio_s1_address => version_pio_s1_address,
      version_pio_s1_chipselect => version_pio_s1_chipselect,
      version_pio_s1_readdata_from_sa => version_pio_s1_readdata_from_sa,
      version_pio_s1_reset_n => version_pio_s1_reset_n,
      version_pio_s1_write_n => version_pio_s1_write_n,
      version_pio_s1_writedata => version_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      version_pio_s1_readdata => version_pio_s1_readdata
    );


  --the_version_pio, which is an e_ptf_instance
  the_version_pio : version_pio
    port map(
      out_port => internal_out_port_from_the_version_pio,
      readdata => version_pio_s1_readdata,
      address => version_pio_s1_address,
      chipselect => version_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      in_port => in_port_to_the_version_pio,
      reset_n => version_pio_s1_reset_n,
      write_n => version_pio_s1_write_n,
      writedata => version_pio_s1_writedata
    );


  --the_vo_pio_s1, which is an e_instance
  the_vo_pio_s1 : vo_pio_s1_arbitrator
    port map(
      cpu_0_data_master_granted_vo_pio_s1 => cpu_0_data_master_granted_vo_pio_s1,
      cpu_0_data_master_qualified_request_vo_pio_s1 => cpu_0_data_master_qualified_request_vo_pio_s1,
      cpu_0_data_master_read_data_valid_vo_pio_s1 => cpu_0_data_master_read_data_valid_vo_pio_s1,
      cpu_0_data_master_requests_vo_pio_s1 => cpu_0_data_master_requests_vo_pio_s1,
      d1_vo_pio_s1_end_xfer => d1_vo_pio_s1_end_xfer,
      vo_pio_s1_address => vo_pio_s1_address,
      vo_pio_s1_chipselect => vo_pio_s1_chipselect,
      vo_pio_s1_irq_from_sa => vo_pio_s1_irq_from_sa,
      vo_pio_s1_readdata_from_sa => vo_pio_s1_readdata_from_sa,
      vo_pio_s1_reset_n => vo_pio_s1_reset_n,
      vo_pio_s1_write_n => vo_pio_s1_write_n,
      vo_pio_s1_writedata => vo_pio_s1_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vo_pio_s1_irq => vo_pio_s1_irq,
      vo_pio_s1_readdata => vo_pio_s1_readdata
    );


  --the_vo_pio, which is an e_ptf_instance
  the_vo_pio : vo_pio
    port map(
      irq => vo_pio_s1_irq,
      out_port => internal_out_port_from_the_vo_pio,
      readdata => vo_pio_s1_readdata,
      address => vo_pio_s1_address,
      chipselect => vo_pio_s1_chipselect,
      clk => internal_altmemddr_0_phy_clk_out,
      in_port => in_port_to_the_vo_pio,
      reset_n => vo_pio_s1_reset_n,
      write_n => vo_pio_s1_write_n,
      writedata => vo_pio_s1_writedata
    );


  --reset is asserted asynchronously and deasserted synchronously
  ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch : ep4c_sopc_system_reset_altmemddr_0_phy_clk_out_domain_synch_module
    port map(
      data_out => altmemddr_0_phy_clk_out_reset_n,
      clk => internal_altmemddr_0_phy_clk_out,
      data_in => module_input10,
      reset_n => reset_n_sources
    );

  module_input10 <= std_logic'('1');

  --sysid_control_slave_clock of type clock does not connect to anything so wire it to default (0)
  sysid_control_slave_clock <= std_logic'('0');
  --vhdl renameroo for output signals
  MOSI_from_the_epcs_spi <= internal_MOSI_from_the_epcs_spi;
  --vhdl renameroo for output signals
  MOSI_from_the_m95320 <= internal_MOSI_from_the_m95320;
  --vhdl renameroo for output signals
  SCLK_from_the_epcs_spi <= internal_SCLK_from_the_epcs_spi;
  --vhdl renameroo for output signals
  SCLK_from_the_m95320 <= internal_SCLK_from_the_m95320;
  --vhdl renameroo for output signals
  SS_n_from_the_epcs_spi <= internal_SS_n_from_the_epcs_spi;
  --vhdl renameroo for output signals
  SS_n_from_the_m95320 <= internal_SS_n_from_the_m95320;
  --vhdl renameroo for output signals
  altmemddr_0_phy_clk_out <= internal_altmemddr_0_phy_clk_out;
  --vhdl renameroo for output signals
  coe_i2c_scl_pad_o_from_the_tfp410_i2c_master <= internal_coe_i2c_scl_pad_o_from_the_tfp410_i2c_master;
  --vhdl renameroo for output signals
  coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master <= internal_coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master;
  --vhdl renameroo for output signals
  coe_i2c_sda_pad_o_from_the_tfp410_i2c_master <= internal_coe_i2c_sda_pad_o_from_the_tfp410_i2c_master;
  --vhdl renameroo for output signals
  coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master <= internal_coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master;
  --vhdl renameroo for output signals
  coe_uh_a_from_the_oxu210hp_if_0 <= internal_coe_uh_a_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  coe_uh_be_from_the_oxu210hp_if_0 <= internal_coe_uh_be_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  coe_uh_cs_n_from_the_oxu210hp_if_0 <= internal_coe_uh_cs_n_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  coe_uh_dack_from_the_oxu210hp_if_0 <= internal_coe_uh_dack_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  coe_uh_rd_n_from_the_oxu210hp_if_0 <= internal_coe_uh_rd_n_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  coe_uh_reset_n_from_the_oxu210hp_if_0 <= internal_coe_uh_reset_n_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  coe_uh_wr_n_from_the_oxu210hp_if_0 <= internal_coe_uh_wr_n_from_the_oxu210hp_if_0;
  --vhdl renameroo for output signals
  local_init_done_from_the_altmemddr_0 <= internal_local_init_done_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  local_refresh_ack_from_the_altmemddr_0 <= internal_local_refresh_ack_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  local_wdata_req_from_the_altmemddr_0 <= internal_local_wdata_req_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_addr_from_the_altmemddr_0 <= internal_mem_addr_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_ba_from_the_altmemddr_0 <= internal_mem_ba_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_cas_n_from_the_altmemddr_0 <= internal_mem_cas_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_cke_from_the_altmemddr_0 <= internal_mem_cke_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_cs_n_from_the_altmemddr_0 <= internal_mem_cs_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_dm_from_the_altmemddr_0 <= internal_mem_dm_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_odt_from_the_altmemddr_0 <= internal_mem_odt_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_ras_n_from_the_altmemddr_0 <= internal_mem_ras_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_we_n_from_the_altmemddr_0 <= internal_mem_we_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  out_port_from_the_debug_pio <= internal_out_port_from_the_debug_pio;
  --vhdl renameroo for output signals
  out_port_from_the_jamma_pio <= internal_out_port_from_the_jamma_pio;
  --vhdl renameroo for output signals
  out_port_from_the_keybd_pio <= internal_out_port_from_the_keybd_pio;
  --vhdl renameroo for output signals
  out_port_from_the_oxu210hp_int <= internal_out_port_from_the_oxu210hp_int;
  --vhdl renameroo for output signals
  out_port_from_the_spi_pio <= internal_out_port_from_the_spi_pio;
  --vhdl renameroo for output signals
  out_port_from_the_usb_pio <= internal_out_port_from_the_usb_pio;
  --vhdl renameroo for output signals
  out_port_from_the_version_pio <= internal_out_port_from_the_version_pio;
  --vhdl renameroo for output signals
  out_port_from_the_vo_pio <= internal_out_port_from_the_vo_pio;
  --vhdl renameroo for output signals
  reset_phy_clk_n_from_the_altmemddr_0 <= internal_reset_phy_clk_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  rts_from_the_uart_pc <= internal_rts_from_the_uart_pc;
  --vhdl renameroo for output signals
  rts_from_the_uart_ts <= internal_rts_from_the_uart_ts;
  --vhdl renameroo for output signals
  rxd_led_from_the_uart_pc <= internal_rxd_led_from_the_uart_pc;
  --vhdl renameroo for output signals
  rxd_led_from_the_uart_ts <= internal_rxd_led_from_the_uart_ts;
  --vhdl renameroo for output signals
  txd_active_from_the_uart_pc <= internal_txd_active_from_the_uart_pc;
  --vhdl renameroo for output signals
  txd_active_from_the_uart_ts <= internal_txd_active_from_the_uart_ts;
  --vhdl renameroo for output signals
  txd_from_the_uart_pc <= internal_txd_from_the_uart_pc;
  --vhdl renameroo for output signals
  txd_from_the_uart_ts <= internal_txd_from_the_uart_ts;
  --vhdl renameroo for output signals
  txd_led_from_the_uart_pc <= internal_txd_led_from_the_uart_pc;
  --vhdl renameroo for output signals
  txd_led_from_the_uart_ts <= internal_txd_led_from_the_uart_ts;

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
component ep4c_sopc_system is 
           port (
                 -- 1) global signals:
                    signal altmemddr_0_aux_full_rate_clk_out : OUT STD_LOGIC;
                    signal altmemddr_0_aux_half_rate_clk_out : OUT STD_LOGIC;
                    signal altmemddr_0_phy_clk_out : OUT STD_LOGIC;
                    signal clk_24M : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_altmemddr_0
                    signal global_reset_n_to_the_altmemddr_0 : IN STD_LOGIC;
                    signal local_init_done_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal local_refresh_ack_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal local_wdata_req_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_addr_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_cas_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_cke_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_clk_n_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                    signal mem_clk_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                    signal mem_cs_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_dm_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_dq_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mem_dqs_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_odt_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_ras_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_we_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal reset_phy_clk_n_from_the_altmemddr_0 : OUT STD_LOGIC;

                 -- the_audio_pio
                    signal in_port_to_the_audio_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_debug_pio
                    signal in_port_to_the_debug_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal out_port_from_the_debug_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_epcs_spi
                    signal MISO_to_the_epcs_spi : IN STD_LOGIC;
                    signal MOSI_from_the_epcs_spi : OUT STD_LOGIC;
                    signal SCLK_from_the_epcs_spi : OUT STD_LOGIC;
                    signal SS_n_from_the_epcs_spi : OUT STD_LOGIC;

                 -- the_jamma_pio
                    signal out_port_from_the_jamma_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_keybd_pio
                    signal out_port_from_the_keybd_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_m95320
                    signal MISO_to_the_m95320 : IN STD_LOGIC;
                    signal MOSI_from_the_m95320 : OUT STD_LOGIC;
                    signal SCLK_from_the_m95320 : OUT STD_LOGIC;
                    signal SS_n_from_the_m95320 : OUT STD_LOGIC;

                 -- the_one_wire_interface_0
                    signal data_to_and_from_the_one_wire_interface_0 : INOUT STD_LOGIC;

                 -- the_oxu210hp_if_0
                    signal coe_uh_a_from_the_oxu210hp_if_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal coe_uh_be_from_the_oxu210hp_if_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal coe_uh_cs_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;
                    signal coe_uh_d_to_and_from_the_oxu210hp_if_0 : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal coe_uh_dack_from_the_oxu210hp_if_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal coe_uh_dreq_to_the_oxu210hp_if_0 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal coe_uh_int_n_to_the_oxu210hp_if_0 : IN STD_LOGIC;
                    signal coe_uh_rd_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;
                    signal coe_uh_reset_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;
                    signal coe_uh_wr_n_from_the_oxu210hp_if_0 : OUT STD_LOGIC;

                 -- the_oxu210hp_int
                    signal in_port_to_the_oxu210hp_int : IN STD_LOGIC;
                    signal out_port_from_the_oxu210hp_int : OUT STD_LOGIC;

                 -- the_spi_pio
                    signal in_port_to_the_spi_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal out_port_from_the_spi_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_tfp410_i2c_master
                    signal coe_arst_arst_i_to_the_tfp410_i2c_master : IN STD_LOGIC;
                    signal coe_i2c_scl_pad_i_to_the_tfp410_i2c_master : IN STD_LOGIC;
                    signal coe_i2c_scl_pad_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;
                    signal coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;
                    signal coe_i2c_sda_pad_i_to_the_tfp410_i2c_master : IN STD_LOGIC;
                    signal coe_i2c_sda_pad_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;
                    signal coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master : OUT STD_LOGIC;

                 -- the_uart_pc
                    signal cts_to_the_uart_pc : IN STD_LOGIC;
                    signal rts_from_the_uart_pc : OUT STD_LOGIC;
                    signal rxd_led_from_the_uart_pc : OUT STD_LOGIC;
                    signal rxd_to_the_uart_pc : IN STD_LOGIC;
                    signal txd_active_from_the_uart_pc : OUT STD_LOGIC;
                    signal txd_from_the_uart_pc : OUT STD_LOGIC;
                    signal txd_led_from_the_uart_pc : OUT STD_LOGIC;

                 -- the_uart_ts
                    signal cts_to_the_uart_ts : IN STD_LOGIC;
                    signal rts_from_the_uart_ts : OUT STD_LOGIC;
                    signal rxd_led_from_the_uart_ts : OUT STD_LOGIC;
                    signal rxd_to_the_uart_ts : IN STD_LOGIC;
                    signal txd_active_from_the_uart_ts : OUT STD_LOGIC;
                    signal txd_from_the_uart_ts : OUT STD_LOGIC;
                    signal txd_led_from_the_uart_ts : OUT STD_LOGIC;

                 -- the_usb_pio
                    signal out_port_from_the_usb_pio : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

                 -- the_version_pio
                    signal in_port_to_the_version_pio : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal out_port_from_the_version_pio : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- the_vo_pio
                    signal in_port_to_the_vo_pio : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal out_port_from_the_vo_pio : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component ep4c_sopc_system;

                signal MISO_to_the_epcs_spi :  STD_LOGIC;
                signal MISO_to_the_m95320 :  STD_LOGIC;
                signal MOSI_from_the_epcs_spi :  STD_LOGIC;
                signal MOSI_from_the_m95320 :  STD_LOGIC;
                signal SCLK_from_the_epcs_spi :  STD_LOGIC;
                signal SCLK_from_the_m95320 :  STD_LOGIC;
                signal SS_n_from_the_epcs_spi :  STD_LOGIC;
                signal SS_n_from_the_m95320 :  STD_LOGIC;
                signal altmemddr_0_aux_full_rate_clk_out :  STD_LOGIC;
                signal altmemddr_0_aux_half_rate_clk_out :  STD_LOGIC;
                signal altmemddr_0_phy_clk_out :  STD_LOGIC;
                signal clk :  STD_LOGIC;
                signal clk_24M :  STD_LOGIC;
                signal coe_arst_arst_i_to_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_i2c_scl_pad_i_to_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_i2c_scl_pad_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_i2c_sda_pad_i_to_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_i2c_sda_pad_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master :  STD_LOGIC;
                signal coe_uh_a_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal coe_uh_be_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal coe_uh_cs_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal coe_uh_d_to_and_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal coe_uh_dack_from_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal coe_uh_dreq_to_the_oxu210hp_if_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal coe_uh_int_n_to_the_oxu210hp_if_0 :  STD_LOGIC;
                signal coe_uh_rd_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal coe_uh_reset_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal coe_uh_wr_n_from_the_oxu210hp_if_0 :  STD_LOGIC;
                signal cts_to_the_uart_pc :  STD_LOGIC;
                signal cts_to_the_uart_ts :  STD_LOGIC;
                signal data_to_and_from_the_one_wire_interface_0 :  STD_LOGIC;
                signal epcs_spi_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal epcs_spi_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal epcs_spi_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal global_reset_n_to_the_altmemddr_0 :  STD_LOGIC;
                signal in_port_to_the_audio_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal in_port_to_the_debug_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal in_port_to_the_oxu210hp_int :  STD_LOGIC;
                signal in_port_to_the_spi_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal in_port_to_the_version_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal in_port_to_the_vo_pio :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal local_init_done_from_the_altmemddr_0 :  STD_LOGIC;
                signal local_refresh_ack_from_the_altmemddr_0 :  STD_LOGIC;
                signal local_wdata_req_from_the_altmemddr_0 :  STD_LOGIC;
                signal m95320_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal m95320_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal m95320_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal mem_addr_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal mem_ba_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal mem_cas_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_cke_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_clk_n_to_and_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_clk_to_and_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_cs_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_dm_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal mem_dq_to_and_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal mem_dqs_to_and_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal mem_odt_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_ras_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_we_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal out_port_from_the_debug_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_port_from_the_jamma_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_port_from_the_keybd_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_port_from_the_oxu210hp_int :  STD_LOGIC;
                signal out_port_from_the_spi_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_port_from_the_usb_pio :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal out_port_from_the_version_pio :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_port_from_the_vo_pio :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal reset_n :  STD_LOGIC;
                signal reset_phy_clk_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal rts_from_the_uart_pc :  STD_LOGIC;
                signal rts_from_the_uart_ts :  STD_LOGIC;
                signal rxd_led_from_the_uart_pc :  STD_LOGIC;
                signal rxd_led_from_the_uart_ts :  STD_LOGIC;
                signal rxd_to_the_uart_pc :  STD_LOGIC;
                signal rxd_to_the_uart_ts :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal txd_active_from_the_uart_pc :  STD_LOGIC;
                signal txd_active_from_the_uart_ts :  STD_LOGIC;
                signal txd_from_the_uart_pc :  STD_LOGIC;
                signal txd_from_the_uart_ts :  STD_LOGIC;
                signal txd_led_from_the_uart_pc :  STD_LOGIC;
                signal txd_led_from_the_uart_ts :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : ep4c_sopc_system
    port map(
      MOSI_from_the_epcs_spi => MOSI_from_the_epcs_spi,
      MOSI_from_the_m95320 => MOSI_from_the_m95320,
      SCLK_from_the_epcs_spi => SCLK_from_the_epcs_spi,
      SCLK_from_the_m95320 => SCLK_from_the_m95320,
      SS_n_from_the_epcs_spi => SS_n_from_the_epcs_spi,
      SS_n_from_the_m95320 => SS_n_from_the_m95320,
      altmemddr_0_aux_full_rate_clk_out => altmemddr_0_aux_full_rate_clk_out,
      altmemddr_0_aux_half_rate_clk_out => altmemddr_0_aux_half_rate_clk_out,
      altmemddr_0_phy_clk_out => altmemddr_0_phy_clk_out,
      coe_i2c_scl_pad_o_from_the_tfp410_i2c_master => coe_i2c_scl_pad_o_from_the_tfp410_i2c_master,
      coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master => coe_i2c_scl_padoen_o_from_the_tfp410_i2c_master,
      coe_i2c_sda_pad_o_from_the_tfp410_i2c_master => coe_i2c_sda_pad_o_from_the_tfp410_i2c_master,
      coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master => coe_i2c_sda_padoen_o_from_the_tfp410_i2c_master,
      coe_uh_a_from_the_oxu210hp_if_0 => coe_uh_a_from_the_oxu210hp_if_0,
      coe_uh_be_from_the_oxu210hp_if_0 => coe_uh_be_from_the_oxu210hp_if_0,
      coe_uh_cs_n_from_the_oxu210hp_if_0 => coe_uh_cs_n_from_the_oxu210hp_if_0,
      coe_uh_d_to_and_from_the_oxu210hp_if_0 => coe_uh_d_to_and_from_the_oxu210hp_if_0,
      coe_uh_dack_from_the_oxu210hp_if_0 => coe_uh_dack_from_the_oxu210hp_if_0,
      coe_uh_rd_n_from_the_oxu210hp_if_0 => coe_uh_rd_n_from_the_oxu210hp_if_0,
      coe_uh_reset_n_from_the_oxu210hp_if_0 => coe_uh_reset_n_from_the_oxu210hp_if_0,
      coe_uh_wr_n_from_the_oxu210hp_if_0 => coe_uh_wr_n_from_the_oxu210hp_if_0,
      data_to_and_from_the_one_wire_interface_0 => data_to_and_from_the_one_wire_interface_0,
      local_init_done_from_the_altmemddr_0 => local_init_done_from_the_altmemddr_0,
      local_refresh_ack_from_the_altmemddr_0 => local_refresh_ack_from_the_altmemddr_0,
      local_wdata_req_from_the_altmemddr_0 => local_wdata_req_from_the_altmemddr_0,
      mem_addr_from_the_altmemddr_0 => mem_addr_from_the_altmemddr_0,
      mem_ba_from_the_altmemddr_0 => mem_ba_from_the_altmemddr_0,
      mem_cas_n_from_the_altmemddr_0 => mem_cas_n_from_the_altmemddr_0,
      mem_cke_from_the_altmemddr_0 => mem_cke_from_the_altmemddr_0,
      mem_clk_n_to_and_from_the_altmemddr_0 => mem_clk_n_to_and_from_the_altmemddr_0,
      mem_clk_to_and_from_the_altmemddr_0 => mem_clk_to_and_from_the_altmemddr_0,
      mem_cs_n_from_the_altmemddr_0 => mem_cs_n_from_the_altmemddr_0,
      mem_dm_from_the_altmemddr_0 => mem_dm_from_the_altmemddr_0,
      mem_dq_to_and_from_the_altmemddr_0 => mem_dq_to_and_from_the_altmemddr_0,
      mem_dqs_to_and_from_the_altmemddr_0 => mem_dqs_to_and_from_the_altmemddr_0,
      mem_odt_from_the_altmemddr_0 => mem_odt_from_the_altmemddr_0,
      mem_ras_n_from_the_altmemddr_0 => mem_ras_n_from_the_altmemddr_0,
      mem_we_n_from_the_altmemddr_0 => mem_we_n_from_the_altmemddr_0,
      out_port_from_the_debug_pio => out_port_from_the_debug_pio,
      out_port_from_the_jamma_pio => out_port_from_the_jamma_pio,
      out_port_from_the_keybd_pio => out_port_from_the_keybd_pio,
      out_port_from_the_oxu210hp_int => out_port_from_the_oxu210hp_int,
      out_port_from_the_spi_pio => out_port_from_the_spi_pio,
      out_port_from_the_usb_pio => out_port_from_the_usb_pio,
      out_port_from_the_version_pio => out_port_from_the_version_pio,
      out_port_from_the_vo_pio => out_port_from_the_vo_pio,
      reset_phy_clk_n_from_the_altmemddr_0 => reset_phy_clk_n_from_the_altmemddr_0,
      rts_from_the_uart_pc => rts_from_the_uart_pc,
      rts_from_the_uart_ts => rts_from_the_uart_ts,
      rxd_led_from_the_uart_pc => rxd_led_from_the_uart_pc,
      rxd_led_from_the_uart_ts => rxd_led_from_the_uart_ts,
      txd_active_from_the_uart_pc => txd_active_from_the_uart_pc,
      txd_active_from_the_uart_ts => txd_active_from_the_uart_ts,
      txd_from_the_uart_pc => txd_from_the_uart_pc,
      txd_from_the_uart_ts => txd_from_the_uart_ts,
      txd_led_from_the_uart_pc => txd_led_from_the_uart_pc,
      txd_led_from_the_uart_ts => txd_led_from_the_uart_ts,
      MISO_to_the_epcs_spi => MISO_to_the_epcs_spi,
      MISO_to_the_m95320 => MISO_to_the_m95320,
      clk_24M => clk_24M,
      coe_arst_arst_i_to_the_tfp410_i2c_master => coe_arst_arst_i_to_the_tfp410_i2c_master,
      coe_i2c_scl_pad_i_to_the_tfp410_i2c_master => coe_i2c_scl_pad_i_to_the_tfp410_i2c_master,
      coe_i2c_sda_pad_i_to_the_tfp410_i2c_master => coe_i2c_sda_pad_i_to_the_tfp410_i2c_master,
      coe_uh_dreq_to_the_oxu210hp_if_0 => coe_uh_dreq_to_the_oxu210hp_if_0,
      coe_uh_int_n_to_the_oxu210hp_if_0 => coe_uh_int_n_to_the_oxu210hp_if_0,
      cts_to_the_uart_pc => cts_to_the_uart_pc,
      cts_to_the_uart_ts => cts_to_the_uart_ts,
      global_reset_n_to_the_altmemddr_0 => global_reset_n_to_the_altmemddr_0,
      in_port_to_the_audio_pio => in_port_to_the_audio_pio,
      in_port_to_the_debug_pio => in_port_to_the_debug_pio,
      in_port_to_the_oxu210hp_int => in_port_to_the_oxu210hp_int,
      in_port_to_the_spi_pio => in_port_to_the_spi_pio,
      in_port_to_the_version_pio => in_port_to_the_version_pio,
      in_port_to_the_vo_pio => in_port_to_the_vo_pio,
      reset_n => reset_n,
      rxd_to_the_uart_pc => rxd_to_the_uart_pc,
      rxd_to_the_uart_ts => rxd_to_the_uart_ts
    );


  process
  begin
    clk_24M <= '0';
    loop
       wait for 21 ns;
       clk_24M <= not clk_24M;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 140 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
