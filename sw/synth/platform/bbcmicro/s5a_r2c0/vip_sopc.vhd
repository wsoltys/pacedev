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

entity alt_vip_cti_0_dout_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_cti_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_cti_0_dout_endofpacket : IN STD_LOGIC;
                 signal alt_vip_cti_0_dout_startofpacket : IN STD_LOGIC;
                 signal alt_vip_cti_0_dout_valid : IN STD_LOGIC;
                 signal alt_vip_scl_0_din_ready_from_sa : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_cti_0_dout_ready : OUT STD_LOGIC;
                 signal alt_vip_cti_0_dout_reset : OUT STD_LOGIC
              );
end entity alt_vip_cti_0_dout_arbitrator;


architecture europa of alt_vip_cti_0_dout_arbitrator is

begin

  --~alt_vip_cti_0_dout_reset assignment, which is an e_assign
  alt_vip_cti_0_dout_reset <= NOT reset_n;
  --mux alt_vip_cti_0_dout_ready, which is an e_mux
  alt_vip_cti_0_dout_ready <= alt_vip_scl_0_din_ready_from_sa;

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

entity alt_vip_itc_0_din_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_itc_0_din_ready : IN STD_LOGIC;
                 signal alt_vip_vfb_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_vfb_0_dout_endofpacket : IN STD_LOGIC;
                 signal alt_vip_vfb_0_dout_startofpacket : IN STD_LOGIC;
                 signal alt_vip_vfb_0_dout_valid : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_itc_0_din_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_itc_0_din_endofpacket : OUT STD_LOGIC;
                 signal alt_vip_itc_0_din_ready_from_sa : OUT STD_LOGIC;
                 signal alt_vip_itc_0_din_reset : OUT STD_LOGIC;
                 signal alt_vip_itc_0_din_startofpacket : OUT STD_LOGIC;
                 signal alt_vip_itc_0_din_valid : OUT STD_LOGIC
              );
end entity alt_vip_itc_0_din_arbitrator;


architecture europa of alt_vip_itc_0_din_arbitrator is

begin

  --mux alt_vip_itc_0_din_data, which is an e_mux
  alt_vip_itc_0_din_data <= alt_vip_vfb_0_dout_data;
  --mux alt_vip_itc_0_din_endofpacket, which is an e_mux
  alt_vip_itc_0_din_endofpacket <= alt_vip_vfb_0_dout_endofpacket;
  --assign alt_vip_itc_0_din_ready_from_sa = alt_vip_itc_0_din_ready so that symbol knows where to group signals which may go to master only, which is an e_assign
  alt_vip_itc_0_din_ready_from_sa <= alt_vip_itc_0_din_ready;
  --mux alt_vip_itc_0_din_startofpacket, which is an e_mux
  alt_vip_itc_0_din_startofpacket <= alt_vip_vfb_0_dout_startofpacket;
  --mux alt_vip_itc_0_din_valid, which is an e_mux
  alt_vip_itc_0_din_valid <= alt_vip_vfb_0_dout_valid;
  --~alt_vip_itc_0_din_reset assignment, which is an e_assign
  alt_vip_itc_0_din_reset <= NOT reset_n;

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

entity alt_vip_scl_0_din_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_cti_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_cti_0_dout_endofpacket : IN STD_LOGIC;
                 signal alt_vip_cti_0_dout_startofpacket : IN STD_LOGIC;
                 signal alt_vip_cti_0_dout_valid : IN STD_LOGIC;
                 signal alt_vip_scl_0_din_ready : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_scl_0_din_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_scl_0_din_endofpacket : OUT STD_LOGIC;
                 signal alt_vip_scl_0_din_ready_from_sa : OUT STD_LOGIC;
                 signal alt_vip_scl_0_din_reset : OUT STD_LOGIC;
                 signal alt_vip_scl_0_din_startofpacket : OUT STD_LOGIC;
                 signal alt_vip_scl_0_din_valid : OUT STD_LOGIC
              );
end entity alt_vip_scl_0_din_arbitrator;


architecture europa of alt_vip_scl_0_din_arbitrator is

begin

  --mux alt_vip_scl_0_din_data, which is an e_mux
  alt_vip_scl_0_din_data <= alt_vip_cti_0_dout_data;
  --mux alt_vip_scl_0_din_endofpacket, which is an e_mux
  alt_vip_scl_0_din_endofpacket <= alt_vip_cti_0_dout_endofpacket;
  --assign alt_vip_scl_0_din_ready_from_sa = alt_vip_scl_0_din_ready so that symbol knows where to group signals which may go to master only, which is an e_assign
  alt_vip_scl_0_din_ready_from_sa <= alt_vip_scl_0_din_ready;
  --mux alt_vip_scl_0_din_startofpacket, which is an e_mux
  alt_vip_scl_0_din_startofpacket <= alt_vip_cti_0_dout_startofpacket;
  --mux alt_vip_scl_0_din_valid, which is an e_mux
  alt_vip_scl_0_din_valid <= alt_vip_cti_0_dout_valid;
  --~alt_vip_scl_0_din_reset assignment, which is an e_assign
  alt_vip_scl_0_din_reset <= NOT reset_n;

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

entity alt_vip_scl_0_dout_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_scl_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_scl_0_dout_endofpacket : IN STD_LOGIC;
                 signal alt_vip_scl_0_dout_startofpacket : IN STD_LOGIC;
                 signal alt_vip_scl_0_dout_valid : IN STD_LOGIC;
                 signal alt_vip_vfb_0_din_ready_from_sa : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_scl_0_dout_ready : OUT STD_LOGIC
              );
end entity alt_vip_scl_0_dout_arbitrator;


architecture europa of alt_vip_scl_0_dout_arbitrator is

begin

  --mux alt_vip_scl_0_dout_ready, which is an e_mux
  alt_vip_scl_0_dout_ready <= alt_vip_vfb_0_din_ready_from_sa;

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

entity alt_vip_vfb_0_din_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_scl_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_scl_0_dout_endofpacket : IN STD_LOGIC;
                 signal alt_vip_scl_0_dout_startofpacket : IN STD_LOGIC;
                 signal alt_vip_scl_0_dout_valid : IN STD_LOGIC;
                 signal alt_vip_vfb_0_din_ready : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_vfb_0_din_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_vfb_0_din_endofpacket : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_din_ready_from_sa : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_din_reset : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_din_startofpacket : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_din_valid : OUT STD_LOGIC
              );
end entity alt_vip_vfb_0_din_arbitrator;


architecture europa of alt_vip_vfb_0_din_arbitrator is

begin

  --mux alt_vip_vfb_0_din_data, which is an e_mux
  alt_vip_vfb_0_din_data <= alt_vip_scl_0_dout_data;
  --mux alt_vip_vfb_0_din_endofpacket, which is an e_mux
  alt_vip_vfb_0_din_endofpacket <= alt_vip_scl_0_dout_endofpacket;
  --assign alt_vip_vfb_0_din_ready_from_sa = alt_vip_vfb_0_din_ready so that symbol knows where to group signals which may go to master only, which is an e_assign
  alt_vip_vfb_0_din_ready_from_sa <= alt_vip_vfb_0_din_ready;
  --mux alt_vip_vfb_0_din_startofpacket, which is an e_mux
  alt_vip_vfb_0_din_startofpacket <= alt_vip_scl_0_dout_startofpacket;
  --mux alt_vip_vfb_0_din_valid, which is an e_mux
  alt_vip_vfb_0_din_valid <= alt_vip_scl_0_dout_valid;
  --~alt_vip_vfb_0_din_reset assignment, which is an e_assign
  alt_vip_vfb_0_din_reset <= NOT reset_n;

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

entity alt_vip_vfb_0_dout_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_itc_0_din_ready_from_sa : IN STD_LOGIC;
                 signal alt_vip_vfb_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal alt_vip_vfb_0_dout_endofpacket : IN STD_LOGIC;
                 signal alt_vip_vfb_0_dout_startofpacket : IN STD_LOGIC;
                 signal alt_vip_vfb_0_dout_valid : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_vfb_0_dout_ready : OUT STD_LOGIC
              );
end entity alt_vip_vfb_0_dout_arbitrator;


architecture europa of alt_vip_vfb_0_dout_arbitrator is

begin

  --mux alt_vip_vfb_0_dout_ready, which is an e_mux
  alt_vip_vfb_0_dout_ready <= alt_vip_itc_0_din_ready_from_sa;

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

entity alt_vip_vfb_0_read_master_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_vfb_0_read_master_address : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal alt_vip_vfb_0_read_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_read : IN STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register : IN STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal d1_vip_sopc_burst_1_upstream_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_readdata_from_sa : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_waitrequest_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_vfb_0_read_master_address_to_slave : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal alt_vip_vfb_0_read_master_latency_counter : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal alt_vip_vfb_0_read_master_readdatavalid : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_reset : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_waitrequest : OUT STD_LOGIC
              );
end entity alt_vip_vfb_0_read_master_arbitrator;


architecture europa of alt_vip_vfb_0_read_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_address_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal alt_vip_vfb_0_read_master_burstcount_last_time :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal alt_vip_vfb_0_read_master_read_last_time :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_run :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_read_master_address_to_slave :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_alt_vip_vfb_0_read_master_waitrequest :  STD_LOGIC;
                signal pre_flush_alt_vip_vfb_0_read_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream OR NOT alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream OR NOT (alt_vip_vfb_0_read_master_read))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT vip_sopc_burst_1_upstream_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((alt_vip_vfb_0_read_master_read))))))))));
  --cascaded wait assignment, which is an e_assign
  alt_vip_vfb_0_read_master_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_alt_vip_vfb_0_read_master_address_to_slave <= Std_Logic_Vector'(std_logic_vector'("000") & alt_vip_vfb_0_read_master_address(28 DOWNTO 0));
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_alt_vip_vfb_0_read_master_readdatavalid <= alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream;
  --latent slave read data valid which is not flushed, which is an e_mux
  alt_vip_vfb_0_read_master_readdatavalid <= Vector_To_Std_Logic((std_logic_vector'("00000000000000000000000000000000") OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pre_flush_alt_vip_vfb_0_read_master_readdatavalid)))));
  --alt_vip_vfb_0/read_master readdata mux, which is an e_mux
  alt_vip_vfb_0_read_master_readdata <= vip_sopc_burst_1_upstream_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_alt_vip_vfb_0_read_master_waitrequest <= NOT alt_vip_vfb_0_read_master_run;
  --latent max counter, which is an e_assign
  alt_vip_vfb_0_read_master_latency_counter <= std_logic'('0');
  --~alt_vip_vfb_0_read_master_reset assignment, which is an e_assign
  alt_vip_vfb_0_read_master_reset <= NOT reset_n;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_read_master_address_to_slave <= internal_alt_vip_vfb_0_read_master_address_to_slave;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_read_master_waitrequest <= internal_alt_vip_vfb_0_read_master_waitrequest;
--synthesis translate_off
    --alt_vip_vfb_0_read_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_read_master_address_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_read_master_address_last_time <= alt_vip_vfb_0_read_master_address;
      end if;

    end process;

    --alt_vip_vfb_0/read_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_alt_vip_vfb_0_read_master_waitrequest AND (alt_vip_vfb_0_read_master_read);
      end if;

    end process;

    --alt_vip_vfb_0_read_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((alt_vip_vfb_0_read_master_address /= alt_vip_vfb_0_read_master_address_last_time))))) = '1' then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("alt_vip_vfb_0_read_master_address did not heed wait!!!"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --alt_vip_vfb_0_read_master_burstcount check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_read_master_burstcount_last_time <= std_logic_vector'("0000000");
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_read_master_burstcount_last_time <= alt_vip_vfb_0_read_master_burstcount;
      end if;

    end process;

    --alt_vip_vfb_0_read_master_burstcount matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((alt_vip_vfb_0_read_master_burstcount /= alt_vip_vfb_0_read_master_burstcount_last_time))))) = '1' then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("alt_vip_vfb_0_read_master_burstcount did not heed wait!!!"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --alt_vip_vfb_0_read_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_read_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_read_master_read_last_time <= alt_vip_vfb_0_read_master_read;
      end if;

    end process;

    --alt_vip_vfb_0_read_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(alt_vip_vfb_0_read_master_read) /= std_logic'(alt_vip_vfb_0_read_master_read_last_time)))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("alt_vip_vfb_0_read_master_read did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
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

entity alt_vip_vfb_0_write_master_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_vfb_0_write_master_address : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal alt_vip_vfb_0_write_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream : IN STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream : IN STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream : IN STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_write : IN STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_vip_sopc_burst_0_upstream_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_waitrequest_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_vfb_0_write_master_address_to_slave : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal alt_vip_vfb_0_write_master_reset : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_waitrequest : OUT STD_LOGIC
              );
end entity alt_vip_vfb_0_write_master_arbitrator;


architecture europa of alt_vip_vfb_0_write_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_address_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal alt_vip_vfb_0_write_master_burstcount_last_time :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal alt_vip_vfb_0_write_master_run :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_write_last_time :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_writedata_last_time :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal internal_alt_vip_vfb_0_write_master_address_to_slave :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_alt_vip_vfb_0_write_master_waitrequest :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream OR NOT (alt_vip_vfb_0_write_master_write))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT vip_sopc_burst_0_upstream_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((alt_vip_vfb_0_write_master_write))))))))));
  --cascaded wait assignment, which is an e_assign
  alt_vip_vfb_0_write_master_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_alt_vip_vfb_0_write_master_address_to_slave <= Std_Logic_Vector'(std_logic_vector'("000") & alt_vip_vfb_0_write_master_address(28 DOWNTO 0));
  --actual waitrequest port, which is an e_assign
  internal_alt_vip_vfb_0_write_master_waitrequest <= NOT alt_vip_vfb_0_write_master_run;
  --~alt_vip_vfb_0_write_master_reset assignment, which is an e_assign
  alt_vip_vfb_0_write_master_reset <= NOT reset_n;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_write_master_address_to_slave <= internal_alt_vip_vfb_0_write_master_address_to_slave;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_write_master_waitrequest <= internal_alt_vip_vfb_0_write_master_waitrequest;
--synthesis translate_off
    --alt_vip_vfb_0_write_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_write_master_address_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_write_master_address_last_time <= alt_vip_vfb_0_write_master_address;
      end if;

    end process;

    --alt_vip_vfb_0/write_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_alt_vip_vfb_0_write_master_waitrequest AND (alt_vip_vfb_0_write_master_write);
      end if;

    end process;

    --alt_vip_vfb_0_write_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((alt_vip_vfb_0_write_master_address /= alt_vip_vfb_0_write_master_address_last_time))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("alt_vip_vfb_0_write_master_address did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --alt_vip_vfb_0_write_master_burstcount check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_write_master_burstcount_last_time <= std_logic_vector'("0000000");
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_write_master_burstcount_last_time <= alt_vip_vfb_0_write_master_burstcount;
      end if;

    end process;

    --alt_vip_vfb_0_write_master_burstcount matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((alt_vip_vfb_0_write_master_burstcount /= alt_vip_vfb_0_write_master_burstcount_last_time))))) = '1' then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("alt_vip_vfb_0_write_master_burstcount did not heed wait!!!"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --alt_vip_vfb_0_write_master_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_write_master_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_write_master_write_last_time <= alt_vip_vfb_0_write_master_write;
      end if;

    end process;

    --alt_vip_vfb_0_write_master_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(alt_vip_vfb_0_write_master_write) /= std_logic'(alt_vip_vfb_0_write_master_write_last_time)))))) = '1' then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("alt_vip_vfb_0_write_master_write did not heed wait!!!"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --alt_vip_vfb_0_write_master_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        alt_vip_vfb_0_write_master_writedata_last_time <= std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        alt_vip_vfb_0_write_master_writedata_last_time <= alt_vip_vfb_0_write_master_writedata;
      end if;

    end process;

    --alt_vip_vfb_0_write_master_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((alt_vip_vfb_0_write_master_writedata /= alt_vip_vfb_0_write_master_writedata_last_time)))) AND alt_vip_vfb_0_write_master_write)) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("alt_vip_vfb_0_write_master_writedata did not heed wait!!!"));
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

entity burstcount_fifo_for_altmemddr_0_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity burstcount_fifo_for_altmemddr_0_s1_module;


architecture europa of burstcount_fifo_for_altmemddr_0_s1_module is
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
                signal p0_stage_0 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_0 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_1 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_10 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_11 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_12 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_13 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_14 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_15 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_16 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_17 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_18 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_19 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_2 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_20 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_21 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_22 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_23 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_24 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_25 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_26 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_27 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_28 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_29 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_3 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_30 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_31 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_4 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_5 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_6 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_7 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_8 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal stage_9 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic_vector'("000");
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
  p30_stage_30 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic_vector'("000");
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
  p29_stage_29 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic_vector'("000");
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
  p28_stage_28 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic_vector'("000");
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
  p27_stage_27 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic_vector'("000");
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
  p26_stage_26 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic_vector'("000");
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
  p25_stage_25 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic_vector'("000");
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
  p24_stage_24 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic_vector'("000");
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
  p23_stage_23 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic_vector'("000");
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
  p22_stage_22 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic_vector'("000");
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
  p21_stage_21 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic_vector'("000");
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
  p20_stage_20 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic_vector'("000");
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
  p19_stage_19 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic_vector'("000");
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
  p18_stage_18 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic_vector'("000");
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
  p17_stage_17 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic_vector'("000");
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
  p16_stage_16 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic_vector'("000");
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
  p15_stage_15 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic_vector'("000");
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
  p14_stage_14 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic_vector'("000");
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
  p13_stage_13 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic_vector'("000");
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
  p12_stage_12 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic_vector'("000");
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
  p11_stage_11 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic_vector'("000");
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
  p10_stage_10 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic_vector'("000");
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
  p9_stage_9 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic_vector'("000");
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
  p8_stage_8 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic_vector'("000");
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
  p7_stage_7 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic_vector'("000");
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
  p6_stage_6 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic_vector'("000");
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
  p5_stage_5 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic_vector'("000");
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
  p4_stage_4 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic_vector'("000");
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
  p3_stage_3 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic_vector'("000");
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
  p2_stage_2 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic_vector'("000");
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
  p1_stage_1 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic_vector'("000");
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
  p0_stage_0 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic_vector'("000");
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
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(or_reduce(data_in)))), A_WE_StdLogicVector((std_logic'(((((read AND (or_reduce(data_in))) AND write) AND (or_reduce(stage_0))))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (or_reduce(data_in))))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (or_reduce(stage_0))))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
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

entity rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1_module is 
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
end entity rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1_module;


architecture europa of rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1_module is
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

entity rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1_module is 
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
end entity rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1_module;


architecture europa of rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1_module is
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
                 signal altmemddr_0_s1_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal altmemddr_0_s1_readdatavalid : IN STD_LOGIC;
                 signal altmemddr_0_s1_resetrequest_n : IN STD_LOGIC;
                 signal altmemddr_0_s1_waitrequest_n : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_address_to_slave : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_arbitrationshare : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_latency_counter : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_read : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_write : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_address_to_slave : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_arbitrationshare : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_latency_counter : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_read : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_write : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

              -- outputs:
                 signal altmemddr_0_s1_address : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal altmemddr_0_s1_beginbursttransfer : OUT STD_LOGIC;
                 signal altmemddr_0_s1_burstcount : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal altmemddr_0_s1_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal altmemddr_0_s1_read : OUT STD_LOGIC;
                 signal altmemddr_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal altmemddr_0_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                 signal altmemddr_0_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal altmemddr_0_s1_write : OUT STD_LOGIC;
                 signal altmemddr_0_s1_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal d1_altmemddr_0_s1_end_xfer : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 : OUT STD_LOGIC
              );
end entity altmemddr_0_s1_arbitrator;


architecture europa of altmemddr_0_s1_arbitrator is
component burstcount_fifo_for_altmemddr_0_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component burstcount_fifo_for_altmemddr_0_s1_module;

component rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1_module is 
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
end component rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1_module;

component rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1_module is 
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
end component rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1_module;

                signal altmemddr_0_s1_allgrants :  STD_LOGIC;
                signal altmemddr_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal altmemddr_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal altmemddr_0_s1_any_continuerequest :  STD_LOGIC;
                signal altmemddr_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_arb_counter_enable :  STD_LOGIC;
                signal altmemddr_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal altmemddr_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal altmemddr_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal altmemddr_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal altmemddr_0_s1_bbt_burstcounter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal altmemddr_0_s1_begins_xfer :  STD_LOGIC;
                signal altmemddr_0_s1_burstcount_fifo_empty :  STD_LOGIC;
                signal altmemddr_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal altmemddr_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_current_burst :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_current_burst_minus_one :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_end_xfer :  STD_LOGIC;
                signal altmemddr_0_s1_firsttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal altmemddr_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal altmemddr_0_s1_load_fifo :  STD_LOGIC;
                signal altmemddr_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal altmemddr_0_s1_next_bbt_burstcount :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_next_burst_count :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal altmemddr_0_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal altmemddr_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altmemddr_0_s1_selected_burstcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal altmemddr_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal altmemddr_0_s1_this_cycle_is_the_last_burst :  STD_LOGIC;
                signal altmemddr_0_s1_transaction_burst_count :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_waits_for_read :  STD_LOGIC;
                signal altmemddr_0_s1_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_altmemddr_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_altmemddr_0_s1_burstcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal internal_altmemddr_0_s1_read :  STD_LOGIC;
                signal internal_altmemddr_0_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal internal_altmemddr_0_s1_write :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal last_cycle_vip_sopc_burst_0_downstream_granted_slave_altmemddr_0_s1 :  STD_LOGIC;
                signal last_cycle_vip_sopc_burst_1_downstream_granted_slave_altmemddr_0_s1 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
                signal module_input6 :  STD_LOGIC;
                signal module_input7 :  STD_LOGIC;
                signal module_input8 :  STD_LOGIC;
                signal p0_altmemddr_0_s1_load_fifo :  STD_LOGIC;
                signal shifted_address_to_altmemddr_0_s1_from_vip_sopc_burst_0_downstream :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal shifted_address_to_altmemddr_0_s1_from_vip_sopc_burst_1_downstream :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_arbiterlock :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_arbiterlock2 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_continuerequest :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_rdv_fifo_empty_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_rdv_fifo_output_from_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_saved_grant_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_arbiterlock :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_arbiterlock2 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_continuerequest :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_rdv_fifo_empty_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_rdv_fifo_output_from_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_saved_grant_altmemddr_0_s1 :  STD_LOGIC;
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

  altmemddr_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 OR internal_vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1));
  --assign altmemddr_0_s1_readdata_from_sa = altmemddr_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  altmemddr_0_s1_readdata_from_sa <= altmemddr_0_s1_readdata;
  internal_vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_0_downstream_read OR vip_sopc_burst_0_downstream_write)))))));
  --assign altmemddr_0_s1_waitrequest_n_from_sa = altmemddr_0_s1_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_altmemddr_0_s1_waitrequest_n_from_sa <= altmemddr_0_s1_waitrequest_n;
  --assign altmemddr_0_s1_readdatavalid_from_sa = altmemddr_0_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  altmemddr_0_s1_readdatavalid_from_sa <= altmemddr_0_s1_readdatavalid;
  --altmemddr_0_s1_arb_share_counter set values, which is an e_mux
  altmemddr_0_s1_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000") & (vip_sopc_burst_0_downstream_arbitrationshare)), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000") & (vip_sopc_burst_1_downstream_arbitrationshare)), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000") & (vip_sopc_burst_0_downstream_arbitrationshare)), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000") & (vip_sopc_burst_1_downstream_arbitrationshare)), std_logic_vector'("00000000000000000000000000000001"))))), 7);
  --altmemddr_0_s1_non_bursting_master_requests mux, which is an e_mux
  altmemddr_0_s1_non_bursting_master_requests <= std_logic'('0');
  --altmemddr_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  altmemddr_0_s1_any_bursting_master_saved_grant <= ((vip_sopc_burst_0_downstream_saved_grant_altmemddr_0_s1 OR vip_sopc_burst_1_downstream_saved_grant_altmemddr_0_s1) OR vip_sopc_burst_0_downstream_saved_grant_altmemddr_0_s1) OR vip_sopc_burst_1_downstream_saved_grant_altmemddr_0_s1;
  --altmemddr_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  altmemddr_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(altmemddr_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000") & (altmemddr_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(altmemddr_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("00000000000000000000000000") & (altmemddr_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 7);
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
      altmemddr_0_s1_arb_share_counter <= std_logic_vector'("0000000");
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

  --vip_sopc_burst_0/downstream altmemddr_0/s1 arbiterlock, which is an e_assign
  vip_sopc_burst_0_downstream_arbiterlock <= altmemddr_0_s1_slavearbiterlockenable AND vip_sopc_burst_0_downstream_continuerequest;
  --altmemddr_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  altmemddr_0_s1_slavearbiterlockenable2 <= or_reduce(altmemddr_0_s1_arb_share_counter_next_value);
  --vip_sopc_burst_0/downstream altmemddr_0/s1 arbiterlock2, which is an e_assign
  vip_sopc_burst_0_downstream_arbiterlock2 <= altmemddr_0_s1_slavearbiterlockenable2 AND vip_sopc_burst_0_downstream_continuerequest;
  --vip_sopc_burst_1/downstream altmemddr_0/s1 arbiterlock, which is an e_assign
  vip_sopc_burst_1_downstream_arbiterlock <= altmemddr_0_s1_slavearbiterlockenable AND vip_sopc_burst_1_downstream_continuerequest;
  --vip_sopc_burst_1/downstream altmemddr_0/s1 arbiterlock2, which is an e_assign
  vip_sopc_burst_1_downstream_arbiterlock2 <= altmemddr_0_s1_slavearbiterlockenable2 AND vip_sopc_burst_1_downstream_continuerequest;
  --vip_sopc_burst_1/downstream granted altmemddr_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_vip_sopc_burst_1_downstream_granted_slave_altmemddr_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_vip_sopc_burst_1_downstream_granted_slave_altmemddr_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(vip_sopc_burst_1_downstream_saved_grant_altmemddr_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_arbitration_holdoff_internal))) OR std_logic_vector'("00000000000000000000000000000000")))) /= std_logic_vector'("00000000000000000000000000000000")), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_vip_sopc_burst_1_downstream_granted_slave_altmemddr_0_s1))))));
    end if;

  end process;

  --vip_sopc_burst_1_downstream_continuerequest continued request, which is an e_mux
  vip_sopc_burst_1_downstream_continuerequest <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_vip_sopc_burst_1_downstream_granted_slave_altmemddr_0_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  --altmemddr_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  altmemddr_0_s1_any_continuerequest <= vip_sopc_burst_1_downstream_continuerequest OR vip_sopc_burst_0_downstream_continuerequest;
  internal_vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 <= internal_vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 AND NOT ((((vip_sopc_burst_0_downstream_read AND to_std_logic((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vip_sopc_burst_0_downstream_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))) OR ((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vip_sopc_burst_0_downstream_latency_counter)))))))))) OR vip_sopc_burst_1_downstream_arbiterlock));
  --unique name for altmemddr_0_s1_move_on_to_next_transaction, which is an e_assign
  altmemddr_0_s1_move_on_to_next_transaction <= altmemddr_0_s1_this_cycle_is_the_last_burst AND altmemddr_0_s1_load_fifo;
  --the currently selected burstcount for altmemddr_0_s1, which is an e_mux
  altmemddr_0_s1_selected_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("00000000000000000000000000000") & (vip_sopc_burst_0_downstream_burstcount)), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("00000000000000000000000000000") & (vip_sopc_burst_1_downstream_burstcount)), std_logic_vector'("00000000000000000000000000000001"))), 3);
  --burstcount_fifo_for_altmemddr_0_s1, which is an e_fifo_with_registered_outputs
  burstcount_fifo_for_altmemddr_0_s1 : burstcount_fifo_for_altmemddr_0_s1_module
    port map(
      data_out => altmemddr_0_s1_transaction_burst_count,
      empty => altmemddr_0_s1_burstcount_fifo_empty,
      fifo_contains_ones_n => open,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => altmemddr_0_s1_selected_burstcount,
      read => altmemddr_0_s1_this_cycle_is_the_last_burst,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= ((in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read) AND altmemddr_0_s1_load_fifo) AND NOT ((altmemddr_0_s1_this_cycle_is_the_last_burst AND altmemddr_0_s1_burstcount_fifo_empty));

  --altmemddr_0_s1 current burst minus one, which is an e_assign
  altmemddr_0_s1_current_burst_minus_one <= A_EXT (((std_logic_vector'("000000000000000000000000000000") & (altmemddr_0_s1_current_burst)) - std_logic_vector'("000000000000000000000000000000001")), 3);
  --what to load in current_burst, for altmemddr_0_s1, which is an e_mux
  altmemddr_0_s1_next_burst_count <= A_WE_StdLogicVector((std_logic'(((((in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read)) AND NOT altmemddr_0_s1_load_fifo))) = '1'), altmemddr_0_s1_selected_burstcount, A_WE_StdLogicVector((std_logic'(((((in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read) AND altmemddr_0_s1_this_cycle_is_the_last_burst) AND altmemddr_0_s1_burstcount_fifo_empty))) = '1'), altmemddr_0_s1_selected_burstcount, A_WE_StdLogicVector((std_logic'((altmemddr_0_s1_this_cycle_is_the_last_burst)) = '1'), altmemddr_0_s1_transaction_burst_count, altmemddr_0_s1_current_burst_minus_one)));
  --the current burst count for altmemddr_0_s1, to be decremented, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_current_burst <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      if std_logic'((altmemddr_0_s1_readdatavalid_from_sa OR ((NOT altmemddr_0_s1_load_fifo AND ((in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read)))))) = '1' then 
        altmemddr_0_s1_current_burst <= altmemddr_0_s1_next_burst_count;
      end if;
    end if;

  end process;

  --a 1 or burstcount fifo empty, to initialize the counter, which is an e_mux
  p0_altmemddr_0_s1_load_fifo <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((NOT altmemddr_0_s1_load_fifo)) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((((in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read)) AND altmemddr_0_s1_load_fifo))) = '1'), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT altmemddr_0_s1_burstcount_fifo_empty))))));
  --whether to load directly to the counter or to the fifo, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_load_fifo <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((((in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read)) AND NOT altmemddr_0_s1_load_fifo) OR altmemddr_0_s1_this_cycle_is_the_last_burst)) = '1' then 
        altmemddr_0_s1_load_fifo <= p0_altmemddr_0_s1_load_fifo;
      end if;
    end if;

  end process;

  --the last cycle in the burst for altmemddr_0_s1, which is an e_assign
  altmemddr_0_s1_this_cycle_is_the_last_burst <= NOT (or_reduce(altmemddr_0_s1_current_burst_minus_one)) AND altmemddr_0_s1_readdatavalid_from_sa;
  --rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1 : rdv_fifo_for_vip_sopc_burst_0_downstream_to_altmemddr_0_s1_module
    port map(
      data_out => vip_sopc_burst_0_downstream_rdv_fifo_output_from_altmemddr_0_s1,
      empty => open,
      fifo_contains_ones_n => vip_sopc_burst_0_downstream_rdv_fifo_empty_altmemddr_0_s1,
      full => open,
      clear_fifo => module_input3,
      clk => clk,
      data_in => internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1,
      read => altmemddr_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input4,
      write => module_input5
    );

  module_input3 <= std_logic'('0');
  module_input4 <= std_logic'('0');
  module_input5 <= in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read;

  vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register <= NOT vip_sopc_burst_0_downstream_rdv_fifo_empty_altmemddr_0_s1;
  --local readdatavalid vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1, which is an e_mux
  vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 <= ((altmemddr_0_s1_readdatavalid_from_sa AND vip_sopc_burst_0_downstream_rdv_fifo_output_from_altmemddr_0_s1)) AND NOT vip_sopc_burst_0_downstream_rdv_fifo_empty_altmemddr_0_s1;
  --altmemddr_0_s1_writedata mux, which is an e_mux
  altmemddr_0_s1_writedata <= A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), vip_sopc_burst_0_downstream_writedata, vip_sopc_burst_1_downstream_writedata);
  internal_vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_1_downstream_read OR vip_sopc_burst_1_downstream_write)))))));
  --vip_sopc_burst_0/downstream granted altmemddr_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_vip_sopc_burst_0_downstream_granted_slave_altmemddr_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_vip_sopc_burst_0_downstream_granted_slave_altmemddr_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(vip_sopc_burst_0_downstream_saved_grant_altmemddr_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_arbitration_holdoff_internal))) OR std_logic_vector'("00000000000000000000000000000000")))) /= std_logic_vector'("00000000000000000000000000000000")), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_vip_sopc_burst_0_downstream_granted_slave_altmemddr_0_s1))))));
    end if;

  end process;

  --vip_sopc_burst_0_downstream_continuerequest continued request, which is an e_mux
  vip_sopc_burst_0_downstream_continuerequest <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_vip_sopc_burst_0_downstream_granted_slave_altmemddr_0_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  internal_vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 <= internal_vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 AND NOT ((((vip_sopc_burst_1_downstream_read AND to_std_logic((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vip_sopc_burst_1_downstream_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))) OR ((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(vip_sopc_burst_1_downstream_latency_counter)))))))))) OR vip_sopc_burst_0_downstream_arbiterlock));
  --rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1 : rdv_fifo_for_vip_sopc_burst_1_downstream_to_altmemddr_0_s1_module
    port map(
      data_out => vip_sopc_burst_1_downstream_rdv_fifo_output_from_altmemddr_0_s1,
      empty => open,
      fifo_contains_ones_n => vip_sopc_burst_1_downstream_rdv_fifo_empty_altmemddr_0_s1,
      full => open,
      clear_fifo => module_input6,
      clk => clk,
      data_in => internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1,
      read => altmemddr_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input7,
      write => module_input8
    );

  module_input6 <= std_logic'('0');
  module_input7 <= std_logic'('0');
  module_input8 <= in_a_read_cycle AND NOT altmemddr_0_s1_waits_for_read;

  vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register <= NOT vip_sopc_burst_1_downstream_rdv_fifo_empty_altmemddr_0_s1;
  --local readdatavalid vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1, which is an e_mux
  vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 <= ((altmemddr_0_s1_readdatavalid_from_sa AND vip_sopc_burst_1_downstream_rdv_fifo_output_from_altmemddr_0_s1)) AND NOT vip_sopc_burst_1_downstream_rdv_fifo_empty_altmemddr_0_s1;
  --allow new arb cycle for altmemddr_0/s1, which is an e_assign
  altmemddr_0_s1_allow_new_arb_cycle <= NOT vip_sopc_burst_0_downstream_arbiterlock AND NOT vip_sopc_burst_1_downstream_arbiterlock;
  --vip_sopc_burst_1/downstream assignment into master qualified-requests vector for altmemddr_0/s1, which is an e_assign
  altmemddr_0_s1_master_qreq_vector(0) <= internal_vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1;
  --vip_sopc_burst_1/downstream grant altmemddr_0/s1, which is an e_assign
  internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 <= altmemddr_0_s1_grant_vector(0);
  --vip_sopc_burst_1/downstream saved-grant altmemddr_0/s1, which is an e_assign
  vip_sopc_burst_1_downstream_saved_grant_altmemddr_0_s1 <= altmemddr_0_s1_arb_winner(0);
  --vip_sopc_burst_0/downstream assignment into master qualified-requests vector for altmemddr_0/s1, which is an e_assign
  altmemddr_0_s1_master_qreq_vector(1) <= internal_vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1;
  --vip_sopc_burst_0/downstream grant altmemddr_0/s1, which is an e_assign
  internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 <= altmemddr_0_s1_grant_vector(1);
  --vip_sopc_burst_0/downstream saved-grant altmemddr_0/s1, which is an e_assign
  vip_sopc_burst_0_downstream_saved_grant_altmemddr_0_s1 <= altmemddr_0_s1_arb_winner(1);
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

  --altmemddr_0_s1_next_bbt_burstcount next_bbt_burstcount, which is an e_mux
  altmemddr_0_s1_next_bbt_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((((internal_altmemddr_0_s1_write) AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (altmemddr_0_s1_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))))))) = '1'), (((std_logic_vector'("000000000000000000000000000000") & (internal_altmemddr_0_s1_burstcount)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'((((internal_altmemddr_0_s1_read) AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (altmemddr_0_s1_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))))))) = '1'), std_logic_vector'("000000000000000000000000000000000"), (((std_logic_vector'("0000000000000000000000000000000") & (altmemddr_0_s1_bbt_burstcounter)) - std_logic_vector'("000000000000000000000000000000001"))))), 2);
  --altmemddr_0_s1_bbt_burstcounter bbt_burstcounter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altmemddr_0_s1_bbt_burstcounter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(altmemddr_0_s1_begins_xfer) = '1' then 
        altmemddr_0_s1_bbt_burstcounter <= altmemddr_0_s1_next_bbt_burstcount;
      end if;
    end if;

  end process;

  --altmemddr_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  altmemddr_0_s1_beginbursttransfer_internal <= altmemddr_0_s1_begins_xfer AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (altmemddr_0_s1_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))));
  --altmemddr_0/s1 begin burst transfer to slave, which is an e_assign
  altmemddr_0_s1_beginbursttransfer <= altmemddr_0_s1_beginbursttransfer_internal;
  --altmemddr_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  altmemddr_0_s1_arbitration_holdoff_internal <= altmemddr_0_s1_begins_xfer AND altmemddr_0_s1_firsttransfer;
  --altmemddr_0_s1_read assignment, which is an e_mux
  internal_altmemddr_0_s1_read <= ((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_0_downstream_read)) OR ((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_1_downstream_read));
  --altmemddr_0_s1_write assignment, which is an e_mux
  internal_altmemddr_0_s1_write <= ((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_0_downstream_write)) OR ((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_1_downstream_write));
  shifted_address_to_altmemddr_0_s1_from_vip_sopc_burst_0_downstream <= vip_sopc_burst_0_downstream_address_to_slave;
  --altmemddr_0_s1_address mux, which is an e_mux
  altmemddr_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), (A_SRL(shifted_address_to_altmemddr_0_s1_from_vip_sopc_burst_0_downstream,std_logic_vector'("00000000000000000000000000000101"))), (A_SRL(shifted_address_to_altmemddr_0_s1_from_vip_sopc_burst_1_downstream,std_logic_vector'("00000000000000000000000000000101")))), 24);
  shifted_address_to_altmemddr_0_s1_from_vip_sopc_burst_1_downstream <= vip_sopc_burst_1_downstream_address_to_slave;
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
  altmemddr_0_s1_in_a_read_cycle <= ((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_0_downstream_read)) OR ((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_1_downstream_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= altmemddr_0_s1_in_a_read_cycle;
  --altmemddr_0_s1_waits_for_write in a cycle, which is an e_mux
  altmemddr_0_s1_waits_for_write <= altmemddr_0_s1_in_a_write_cycle AND NOT internal_altmemddr_0_s1_waitrequest_n_from_sa;
  --altmemddr_0_s1_in_a_write_cycle assignment, which is an e_assign
  altmemddr_0_s1_in_a_write_cycle <= ((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_0_downstream_write)) OR ((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 AND vip_sopc_burst_1_downstream_write));
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= altmemddr_0_s1_in_a_write_cycle;
  wait_for_altmemddr_0_s1_counter <= std_logic'('0');
  --altmemddr_0_s1_byteenable byte enable port mux, which is an e_mux
  altmemddr_0_s1_byteenable <= A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), vip_sopc_burst_0_downstream_byteenable, A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1)) = '1'), vip_sopc_burst_1_downstream_byteenable, -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --burstcount mux, which is an e_mux
  internal_altmemddr_0_s1_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("00000000000000000000000000000") & (vip_sopc_burst_0_downstream_burstcount)), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1)) = '1'), (std_logic_vector'("00000000000000000000000000000") & (vip_sopc_burst_1_downstream_burstcount)), std_logic_vector'("00000000000000000000000000000001"))), 3);
  --vhdl renameroo for output signals
  altmemddr_0_s1_burstcount <= internal_altmemddr_0_s1_burstcount;
  --vhdl renameroo for output signals
  altmemddr_0_s1_read <= internal_altmemddr_0_s1_read;
  --vhdl renameroo for output signals
  altmemddr_0_s1_waitrequest_n_from_sa <= internal_altmemddr_0_s1_waitrequest_n_from_sa;
  --vhdl renameroo for output signals
  altmemddr_0_s1_write <= internal_altmemddr_0_s1_write;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 <= internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 <= internal_vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 <= internal_vip_sopc_burst_0_downstream_requests_altmemddr_0_s1;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 <= internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 <= internal_vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 <= internal_vip_sopc_burst_1_downstream_requests_altmemddr_0_s1;
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

    --vip_sopc_burst_0/downstream non-zero arbitrationshare assertion, which is an e_process
    process (clk)
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((internal_vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 AND to_std_logic((((std_logic_vector'("0000000000000000000000000") & (vip_sopc_burst_0_downstream_arbitrationshare)) = std_logic_vector'("00000000000000000000000000000000"))))) AND enable_nonzero_assertions)) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("vip_sopc_burst_0/downstream drove 0 on its 'arbitrationshare' port while accessing slave altmemddr_0/s1"));
          write(output, write_line7.all);
          deallocate (write_line7);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_0/downstream non-zero burstcount assertion, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((internal_vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (vip_sopc_burst_0_downstream_burstcount)) = std_logic_vector'("00000000000000000000000000000000"))))) AND enable_nonzero_assertions)) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("vip_sopc_burst_0/downstream drove 0 on its 'burstcount' port while accessing slave altmemddr_0/s1"));
          write(output, write_line8.all);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1/downstream non-zero arbitrationshare assertion, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((internal_vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 AND to_std_logic((((std_logic_vector'("0000000000000000000000000") & (vip_sopc_burst_1_downstream_arbitrationshare)) = std_logic_vector'("00000000000000000000000000000000"))))) AND enable_nonzero_assertions)) = '1' then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("vip_sopc_burst_1/downstream drove 0 on its 'arbitrationshare' port while accessing slave altmemddr_0/s1"));
          write(output, write_line9.all);
          deallocate (write_line9);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1/downstream non-zero burstcount assertion, which is an e_process
    process (clk)
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((internal_vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (vip_sopc_burst_1_downstream_burstcount)) = std_logic_vector'("00000000000000000000000000000000"))))) AND enable_nonzero_assertions)) = '1' then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("vip_sopc_burst_1/downstream drove 0 on its 'burstcount' port while accessing slave altmemddr_0/s1"));
          write(output, write_line10.all);
          deallocate (write_line10);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line11 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_vip_sopc_burst_0_downstream_granted_altmemddr_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_vip_sopc_burst_1_downstream_granted_altmemddr_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line11, now);
          write(write_line11, string'(": "));
          write(write_line11, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line11.all);
          deallocate (write_line11);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line12 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(vip_sopc_burst_0_downstream_saved_grant_altmemddr_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(vip_sopc_burst_1_downstream_saved_grant_altmemddr_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line12, now);
          write(write_line12, string'(": "));
          write(write_line12, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line12.all);
          deallocate (write_line12);
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

entity vip_sopc_reset_clk_24M_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity vip_sopc_reset_clk_24M_domain_synch_module;


architecture europa of vip_sopc_reset_clk_24M_domain_synch_module is
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

library std;
use std.textio.all;

entity vip_sopc_burst_0_upstream_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_vfb_0_write_master_address_to_slave : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal alt_vip_vfb_0_write_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal alt_vip_vfb_0_write_master_write : IN STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_0_upstream_readdatavalid : IN STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_waitrequest : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream : OUT STD_LOGIC;
                 signal d1_vip_sopc_burst_0_upstream_end_xfer : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_address : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_0_upstream_burstcount : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal vip_sopc_burst_0_upstream_byteaddress : OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
                 signal vip_sopc_burst_0_upstream_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vip_sopc_burst_0_upstream_debugaccess : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_read : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_readdata_from_sa : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_0_upstream_readdatavalid_from_sa : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_waitrequest_from_sa : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_write : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_upstream_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0)
              );
end entity vip_sopc_burst_0_upstream_arbitrator;


architecture europa of vip_sopc_burst_0_upstream_arbitrator is
                signal alt_vip_vfb_0_write_master_arbiterlock :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_arbiterlock2 :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_continuerequest :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_saved_grant_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_upstream_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal internal_vip_sopc_burst_0_upstream_read :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_upstream_waitrequest_from_sa :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_upstream_write :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_allgrants :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_allow_new_arb_cycle :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_any_bursting_master_saved_grant :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_any_continuerequest :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_arb_counter_enable :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_arb_share_counter :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_arb_share_counter_next_value :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_arb_share_set_values :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_bbt_burstcounter :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_beginbursttransfer_internal :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_begins_xfer :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_end_xfer :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_firsttransfer :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_grant_vector :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_in_a_read_cycle :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_in_a_write_cycle :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_master_qreq_vector :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_next_bbt_burstcount :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_non_bursting_master_requests :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_reg_firsttransfer :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_slavearbiterlockenable :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_slavearbiterlockenable2 :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_unreg_firsttransfer :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_waits_for_read :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_waits_for_write :  STD_LOGIC;
                signal wait_for_vip_sopc_burst_0_upstream_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT vip_sopc_burst_0_upstream_end_xfer;
    end if;

  end process;

  vip_sopc_burst_0_upstream_begins_xfer <= NOT d1_reasons_to_wait AND (internal_alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream);
  --assign vip_sopc_burst_0_upstream_readdata_from_sa = vip_sopc_burst_0_upstream_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  vip_sopc_burst_0_upstream_readdata_from_sa <= vip_sopc_burst_0_upstream_readdata;
  internal_alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream <= ((to_std_logic(((Std_Logic_Vector'(alt_vip_vfb_0_write_master_address_to_slave(31 DOWNTO 29) & std_logic_vector'("00000000000000000000000000000")) = std_logic_vector'("00000000000000000000000000000000")))) AND (alt_vip_vfb_0_write_master_write))) AND alt_vip_vfb_0_write_master_write;
  --assign vip_sopc_burst_0_upstream_waitrequest_from_sa = vip_sopc_burst_0_upstream_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_vip_sopc_burst_0_upstream_waitrequest_from_sa <= vip_sopc_burst_0_upstream_waitrequest;
  --vip_sopc_burst_0_upstream_arb_share_counter set values, which is an e_mux
  vip_sopc_burst_0_upstream_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream)) = '1'), (std_logic_vector'("0000000000000000000000000") & (alt_vip_vfb_0_write_master_burstcount)), std_logic_vector'("00000000000000000000000000000001")), 7);
  --vip_sopc_burst_0_upstream_non_bursting_master_requests mux, which is an e_mux
  vip_sopc_burst_0_upstream_non_bursting_master_requests <= std_logic'('0');
  --vip_sopc_burst_0_upstream_any_bursting_master_saved_grant mux, which is an e_mux
  vip_sopc_burst_0_upstream_any_bursting_master_saved_grant <= alt_vip_vfb_0_write_master_saved_grant_vip_sopc_burst_0_upstream;
  --vip_sopc_burst_0_upstream_arb_share_counter_next_value assignment, which is an e_assign
  vip_sopc_burst_0_upstream_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(vip_sopc_burst_0_upstream_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_0_upstream_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(vip_sopc_burst_0_upstream_arb_share_counter)) = '1'), (((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_0_upstream_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 7);
  --vip_sopc_burst_0_upstream_allgrants all slave grants, which is an e_mux
  vip_sopc_burst_0_upstream_allgrants <= vip_sopc_burst_0_upstream_grant_vector;
  --vip_sopc_burst_0_upstream_end_xfer assignment, which is an e_assign
  vip_sopc_burst_0_upstream_end_xfer <= NOT ((vip_sopc_burst_0_upstream_waits_for_read OR vip_sopc_burst_0_upstream_waits_for_write));
  --end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream <= vip_sopc_burst_0_upstream_end_xfer AND (((NOT vip_sopc_burst_0_upstream_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --vip_sopc_burst_0_upstream_arb_share_counter arbitration counter enable, which is an e_assign
  vip_sopc_burst_0_upstream_arb_counter_enable <= ((end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream AND vip_sopc_burst_0_upstream_allgrants)) OR ((end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream AND NOT vip_sopc_burst_0_upstream_non_bursting_master_requests));
  --vip_sopc_burst_0_upstream_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_0_upstream_arb_share_counter <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'(vip_sopc_burst_0_upstream_arb_counter_enable) = '1' then 
        vip_sopc_burst_0_upstream_arb_share_counter <= vip_sopc_burst_0_upstream_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --vip_sopc_burst_0_upstream_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_0_upstream_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((vip_sopc_burst_0_upstream_master_qreq_vector AND end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream)) OR ((end_xfer_arb_share_counter_term_vip_sopc_burst_0_upstream AND NOT vip_sopc_burst_0_upstream_non_bursting_master_requests)))) = '1' then 
        vip_sopc_burst_0_upstream_slavearbiterlockenable <= or_reduce(vip_sopc_burst_0_upstream_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --alt_vip_vfb_0/write_master vip_sopc_burst_0/upstream arbiterlock, which is an e_assign
  alt_vip_vfb_0_write_master_arbiterlock <= vip_sopc_burst_0_upstream_slavearbiterlockenable AND alt_vip_vfb_0_write_master_continuerequest;
  --vip_sopc_burst_0_upstream_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  vip_sopc_burst_0_upstream_slavearbiterlockenable2 <= or_reduce(vip_sopc_burst_0_upstream_arb_share_counter_next_value);
  --alt_vip_vfb_0/write_master vip_sopc_burst_0/upstream arbiterlock2, which is an e_assign
  alt_vip_vfb_0_write_master_arbiterlock2 <= vip_sopc_burst_0_upstream_slavearbiterlockenable2 AND alt_vip_vfb_0_write_master_continuerequest;
  --vip_sopc_burst_0_upstream_any_continuerequest at least one master continues requesting, which is an e_assign
  vip_sopc_burst_0_upstream_any_continuerequest <= std_logic'('1');
  --alt_vip_vfb_0_write_master_continuerequest continued request, which is an e_assign
  alt_vip_vfb_0_write_master_continuerequest <= std_logic'('1');
  internal_alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream <= internal_alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream;
  --vip_sopc_burst_0_upstream_writedata mux, which is an e_mux
  vip_sopc_burst_0_upstream_writedata <= alt_vip_vfb_0_write_master_writedata;
  --byteaddress mux for vip_sopc_burst_0/upstream, which is an e_mux
  vip_sopc_burst_0_upstream_byteaddress <= std_logic_vector'("00") & (alt_vip_vfb_0_write_master_address_to_slave);
  --master is always granted when requested
  internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream <= internal_alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream;
  --alt_vip_vfb_0/write_master saved-grant vip_sopc_burst_0/upstream, which is an e_assign
  alt_vip_vfb_0_write_master_saved_grant_vip_sopc_burst_0_upstream <= internal_alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream;
  --allow new arb cycle for vip_sopc_burst_0/upstream, which is an e_assign
  vip_sopc_burst_0_upstream_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  vip_sopc_burst_0_upstream_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  vip_sopc_burst_0_upstream_master_qreq_vector <= std_logic'('1');
  --vip_sopc_burst_0_upstream_firsttransfer first transaction, which is an e_assign
  vip_sopc_burst_0_upstream_firsttransfer <= A_WE_StdLogic((std_logic'(vip_sopc_burst_0_upstream_begins_xfer) = '1'), vip_sopc_burst_0_upstream_unreg_firsttransfer, vip_sopc_burst_0_upstream_reg_firsttransfer);
  --vip_sopc_burst_0_upstream_unreg_firsttransfer first transaction, which is an e_assign
  vip_sopc_burst_0_upstream_unreg_firsttransfer <= NOT ((vip_sopc_burst_0_upstream_slavearbiterlockenable AND vip_sopc_burst_0_upstream_any_continuerequest));
  --vip_sopc_burst_0_upstream_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_0_upstream_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(vip_sopc_burst_0_upstream_begins_xfer) = '1' then 
        vip_sopc_burst_0_upstream_reg_firsttransfer <= vip_sopc_burst_0_upstream_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --vip_sopc_burst_0_upstream_next_bbt_burstcount next_bbt_burstcount, which is an e_mux
  vip_sopc_burst_0_upstream_next_bbt_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((((internal_vip_sopc_burst_0_upstream_write) AND to_std_logic((((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_0_upstream_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))))))) = '1'), (((std_logic_vector'("00000000000000000000000000") & (internal_vip_sopc_burst_0_upstream_burstcount)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'((((internal_vip_sopc_burst_0_upstream_read) AND to_std_logic((((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_0_upstream_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))))))) = '1'), std_logic_vector'("000000000000000000000000000000000"), (((std_logic_vector'("000000000000000000000000000") & (vip_sopc_burst_0_upstream_bbt_burstcounter)) - std_logic_vector'("000000000000000000000000000000001"))))), 6);
  --vip_sopc_burst_0_upstream_bbt_burstcounter bbt_burstcounter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_0_upstream_bbt_burstcounter <= std_logic_vector'("000000");
    elsif clk'event and clk = '1' then
      if std_logic'(vip_sopc_burst_0_upstream_begins_xfer) = '1' then 
        vip_sopc_burst_0_upstream_bbt_burstcounter <= vip_sopc_burst_0_upstream_next_bbt_burstcount;
      end if;
    end if;

  end process;

  --vip_sopc_burst_0_upstream_beginbursttransfer_internal begin burst transfer, which is an e_assign
  vip_sopc_burst_0_upstream_beginbursttransfer_internal <= vip_sopc_burst_0_upstream_begins_xfer AND to_std_logic((((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_0_upstream_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))));
  --vip_sopc_burst_0_upstream_read assignment, which is an e_mux
  internal_vip_sopc_burst_0_upstream_read <= std_logic'('0');
  --vip_sopc_burst_0_upstream_write assignment, which is an e_mux
  internal_vip_sopc_burst_0_upstream_write <= internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream AND alt_vip_vfb_0_write_master_write;
  --vip_sopc_burst_0_upstream_address mux, which is an e_mux
  vip_sopc_burst_0_upstream_address <= alt_vip_vfb_0_write_master_address_to_slave (28 DOWNTO 0);
  --d1_vip_sopc_burst_0_upstream_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_vip_sopc_burst_0_upstream_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_vip_sopc_burst_0_upstream_end_xfer <= vip_sopc_burst_0_upstream_end_xfer;
    end if;

  end process;

  --vip_sopc_burst_0_upstream_waits_for_read in a cycle, which is an e_mux
  vip_sopc_burst_0_upstream_waits_for_read <= vip_sopc_burst_0_upstream_in_a_read_cycle AND internal_vip_sopc_burst_0_upstream_waitrequest_from_sa;
  --vip_sopc_burst_0_upstream_in_a_read_cycle assignment, which is an e_assign
  vip_sopc_burst_0_upstream_in_a_read_cycle <= std_logic'('0');
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= vip_sopc_burst_0_upstream_in_a_read_cycle;
  --vip_sopc_burst_0_upstream_waits_for_write in a cycle, which is an e_mux
  vip_sopc_burst_0_upstream_waits_for_write <= vip_sopc_burst_0_upstream_in_a_write_cycle AND internal_vip_sopc_burst_0_upstream_waitrequest_from_sa;
  --assign vip_sopc_burst_0_upstream_readdatavalid_from_sa = vip_sopc_burst_0_upstream_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  vip_sopc_burst_0_upstream_readdatavalid_from_sa <= vip_sopc_burst_0_upstream_readdatavalid;
  --vip_sopc_burst_0_upstream_in_a_write_cycle assignment, which is an e_assign
  vip_sopc_burst_0_upstream_in_a_write_cycle <= internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream AND alt_vip_vfb_0_write_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= vip_sopc_burst_0_upstream_in_a_write_cycle;
  wait_for_vip_sopc_burst_0_upstream_counter <= std_logic'('0');
  --vip_sopc_burst_0_upstream_byteenable byte enable port mux, which is an e_mux
  vip_sopc_burst_0_upstream_byteenable <= A_WE_StdLogicVector((std_logic'((internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream)) = '1'), A_REP(std_logic'('1'), 32), -SIGNED(std_logic_vector'("00000000000000000000000000000001")));
  --burstcount mux, which is an e_mux
  internal_vip_sopc_burst_0_upstream_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream)) = '1'), (std_logic_vector'("0000000000000000000000000") & (alt_vip_vfb_0_write_master_burstcount)), std_logic_vector'("00000000000000000000000000000001")), 7);
  --debugaccess mux, which is an e_mux
  vip_sopc_burst_0_upstream_debugaccess <= std_logic'('0');
  --vhdl renameroo for output signals
  alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream <= internal_alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream <= internal_alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream <= internal_alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_upstream_burstcount <= internal_vip_sopc_burst_0_upstream_burstcount;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_upstream_read <= internal_vip_sopc_burst_0_upstream_read;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_upstream_waitrequest_from_sa <= internal_vip_sopc_burst_0_upstream_waitrequest_from_sa;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_upstream_write <= internal_vip_sopc_burst_0_upstream_write;
--synthesis translate_off
    --vip_sopc_burst_0/upstream enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --alt_vip_vfb_0/write_master non-zero burstcount assertion, which is an e_process
    process (clk)
    VARIABLE write_line13 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((internal_alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream AND to_std_logic((((std_logic_vector'("0000000000000000000000000") & (alt_vip_vfb_0_write_master_burstcount)) = std_logic_vector'("00000000000000000000000000000000"))))) AND enable_nonzero_assertions)) = '1' then 
          write(write_line13, now);
          write(write_line13, string'(": "));
          write(write_line13, string'("alt_vip_vfb_0/write_master drove 0 on its 'burstcount' port while accessing slave vip_sopc_burst_0/upstream"));
          write(output, write_line13.all);
          deallocate (write_line13);
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

entity vip_sopc_burst_0_downstream_arbitrator is 
        port (
              -- inputs:
                 signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_address : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_read : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_write : IN STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

              -- outputs:
                 signal vip_sopc_burst_0_downstream_address_to_slave : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_latency_counter : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_0_downstream_readdatavalid : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_reset_n : OUT STD_LOGIC;
                 signal vip_sopc_burst_0_downstream_waitrequest : OUT STD_LOGIC
              );
end entity vip_sopc_burst_0_downstream_arbitrator;


architecture europa of vip_sopc_burst_0_downstream_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_downstream_address_to_slave :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal internal_vip_sopc_burst_0_downstream_latency_counter :  STD_LOGIC;
                signal internal_vip_sopc_burst_0_downstream_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_vip_sopc_burst_0_downstream_latency_counter :  STD_LOGIC;
                signal pre_flush_vip_sopc_burst_0_downstream_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_address_last_time :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_burstcount_last_time :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_byteenable_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_is_granted_some_slave :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_read_but_no_slave_selected :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_read_last_time :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_run :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_write_last_time :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_writedata_last_time :  STD_LOGIC_VECTOR (255 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 OR NOT vip_sopc_burst_0_downstream_requests_altmemddr_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 OR NOT vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 OR NOT ((vip_sopc_burst_0_downstream_read OR vip_sopc_burst_0_downstream_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_0_downstream_read OR vip_sopc_burst_0_downstream_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 OR NOT ((vip_sopc_burst_0_downstream_read OR vip_sopc_burst_0_downstream_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_0_downstream_read OR vip_sopc_burst_0_downstream_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  vip_sopc_burst_0_downstream_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_vip_sopc_burst_0_downstream_address_to_slave <= vip_sopc_burst_0_downstream_address;
  --vip_sopc_burst_0_downstream_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_0_downstream_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      vip_sopc_burst_0_downstream_read_but_no_slave_selected <= (vip_sopc_burst_0_downstream_read AND vip_sopc_burst_0_downstream_run) AND NOT vip_sopc_burst_0_downstream_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  vip_sopc_burst_0_downstream_is_granted_some_slave <= vip_sopc_burst_0_downstream_granted_altmemddr_0_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_vip_sopc_burst_0_downstream_readdatavalid <= vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  vip_sopc_burst_0_downstream_readdatavalid <= vip_sopc_burst_0_downstream_read_but_no_slave_selected OR pre_flush_vip_sopc_burst_0_downstream_readdatavalid;
  --vip_sopc_burst_0/downstream readdata mux, which is an e_mux
  vip_sopc_burst_0_downstream_readdata <= altmemddr_0_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_vip_sopc_burst_0_downstream_waitrequest <= NOT vip_sopc_burst_0_downstream_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_vip_sopc_burst_0_downstream_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_vip_sopc_burst_0_downstream_latency_counter <= p1_vip_sopc_burst_0_downstream_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_vip_sopc_burst_0_downstream_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((vip_sopc_burst_0_downstream_run AND vip_sopc_burst_0_downstream_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_0_downstream_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_vip_sopc_burst_0_downstream_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= std_logic'('0');
  --vip_sopc_burst_0_downstream_reset_n assignment, which is an e_assign
  vip_sopc_burst_0_downstream_reset_n <= reset_n;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_downstream_address_to_slave <= internal_vip_sopc_burst_0_downstream_address_to_slave;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_downstream_latency_counter <= internal_vip_sopc_burst_0_downstream_latency_counter;
  --vhdl renameroo for output signals
  vip_sopc_burst_0_downstream_waitrequest <= internal_vip_sopc_burst_0_downstream_waitrequest;
--synthesis translate_off
    --vip_sopc_burst_0_downstream_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_0_downstream_address_last_time <= std_logic_vector'("00000000000000000000000000000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_0_downstream_address_last_time <= vip_sopc_burst_0_downstream_address;
      end if;

    end process;

    --vip_sopc_burst_0/downstream waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_vip_sopc_burst_0_downstream_waitrequest AND ((vip_sopc_burst_0_downstream_read OR vip_sopc_burst_0_downstream_write));
      end if;

    end process;

    --vip_sopc_burst_0_downstream_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line14 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_0_downstream_address /= vip_sopc_burst_0_downstream_address_last_time))))) = '1' then 
          write(write_line14, now);
          write(write_line14, string'(": "));
          write(write_line14, string'("vip_sopc_burst_0_downstream_address did not heed wait!!!"));
          write(output, write_line14.all);
          deallocate (write_line14);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_burstcount check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_0_downstream_burstcount_last_time <= std_logic_vector'("000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_0_downstream_burstcount_last_time <= vip_sopc_burst_0_downstream_burstcount;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_burstcount matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line15 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_0_downstream_burstcount /= vip_sopc_burst_0_downstream_burstcount_last_time))))) = '1' then 
          write(write_line15, now);
          write(write_line15, string'(": "));
          write(write_line15, string'("vip_sopc_burst_0_downstream_burstcount did not heed wait!!!"));
          write(output, write_line15.all);
          deallocate (write_line15);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_0_downstream_byteenable_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_0_downstream_byteenable_last_time <= vip_sopc_burst_0_downstream_byteenable;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line16 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_0_downstream_byteenable /= vip_sopc_burst_0_downstream_byteenable_last_time))))) = '1' then 
          write(write_line16, now);
          write(write_line16, string'(": "));
          write(write_line16, string'("vip_sopc_burst_0_downstream_byteenable did not heed wait!!!"));
          write(output, write_line16.all);
          deallocate (write_line16);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_0_downstream_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        vip_sopc_burst_0_downstream_read_last_time <= vip_sopc_burst_0_downstream_read;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line17 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(vip_sopc_burst_0_downstream_read) /= std_logic'(vip_sopc_burst_0_downstream_read_last_time)))))) = '1' then 
          write(write_line17, now);
          write(write_line17, string'(": "));
          write(write_line17, string'("vip_sopc_burst_0_downstream_read did not heed wait!!!"));
          write(output, write_line17.all);
          deallocate (write_line17);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_0_downstream_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        vip_sopc_burst_0_downstream_write_last_time <= vip_sopc_burst_0_downstream_write;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line18 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(vip_sopc_burst_0_downstream_write) /= std_logic'(vip_sopc_burst_0_downstream_write_last_time)))))) = '1' then 
          write(write_line18, now);
          write(write_line18, string'(": "));
          write(write_line18, string'("vip_sopc_burst_0_downstream_write did not heed wait!!!"));
          write(output, write_line18.all);
          deallocate (write_line18);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_0_downstream_writedata_last_time <= std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_0_downstream_writedata_last_time <= vip_sopc_burst_0_downstream_writedata;
      end if;

    end process;

    --vip_sopc_burst_0_downstream_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line19 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_0_downstream_writedata /= vip_sopc_burst_0_downstream_writedata_last_time)))) AND vip_sopc_burst_0_downstream_write)) = '1' then 
          write(write_line19, now);
          write(write_line19, string'(": "));
          write(write_line19, string'("vip_sopc_burst_0_downstream_writedata did not heed wait!!!"));
          write(output, write_line19.all);
          deallocate (write_line19);
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

entity burstcount_fifo_for_vip_sopc_burst_1_upstream_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity burstcount_fifo_for_vip_sopc_burst_1_upstream_module;


architecture europa of burstcount_fifo_for_vip_sopc_burst_1_upstream_module is
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
                signal full_33 :  STD_LOGIC;
                signal full_34 :  STD_LOGIC;
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
                signal p0_stage_0 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p32_full_32 :  STD_LOGIC;
                signal p32_stage_32 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p33_full_33 :  STD_LOGIC;
                signal p33_stage_33 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_0 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_1 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_10 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_11 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_12 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_13 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_14 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_15 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_16 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_17 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_18 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_19 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_2 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_20 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_21 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_22 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_23 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_24 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_25 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_26 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_27 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_28 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_29 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_3 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_30 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_31 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_32 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_33 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_4 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_5 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_6 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_7 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_8 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal stage_9 :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_33;
  empty <= NOT(full_0);
  full_34 <= std_logic'('0');
  --data_33, which is an e_mux
  p33_stage_33 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_34 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_33, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_33 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_33))))) = '1' then 
        if std_logic'(((sync_reset AND full_33) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_34))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_33 <= std_logic_vector'("0000000");
        else
          stage_33 <= p33_stage_33;
        end if;
      end if;
    end if;

  end process;

  --control_33, which is an e_mux
  p33_full_33 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_33, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_33 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_33 <= std_logic'('0');
        else
          full_33 <= p33_full_33;
        end if;
      end if;
    end if;

  end process;

  --data_32, which is an e_mux
  p32_stage_32 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_33 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_33);
  --data_reg_32, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_32 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_32))))) = '1' then 
        if std_logic'(((sync_reset AND full_32) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_33))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_32 <= std_logic_vector'("0000000");
        else
          stage_32 <= p32_stage_32;
        end if;
      end if;
    end if;

  end process;

  --control_32, which is an e_mux
  p32_full_32 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_31, full_33);
  --control_reg_32, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_32 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_32 <= std_logic'('0');
        else
          full_32 <= p32_full_32;
        end if;
      end if;
    end if;

  end process;

  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_32);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic_vector'("0000000");
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_30, full_32);
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
  p30_stage_30 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic_vector'("0000000");
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
  p29_stage_29 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic_vector'("0000000");
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
  p28_stage_28 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic_vector'("0000000");
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
  p27_stage_27 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic_vector'("0000000");
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
  p26_stage_26 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic_vector'("0000000");
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
  p25_stage_25 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic_vector'("0000000");
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
  p24_stage_24 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic_vector'("0000000");
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
  p23_stage_23 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic_vector'("0000000");
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
  p22_stage_22 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic_vector'("0000000");
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
  p21_stage_21 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic_vector'("0000000");
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
  p20_stage_20 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic_vector'("0000000");
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
  p19_stage_19 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic_vector'("0000000");
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
  p18_stage_18 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic_vector'("0000000");
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
  p17_stage_17 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic_vector'("0000000");
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
  p16_stage_16 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic_vector'("0000000");
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
  p15_stage_15 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic_vector'("0000000");
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
  p14_stage_14 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic_vector'("0000000");
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
  p13_stage_13 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic_vector'("0000000");
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
  p12_stage_12 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic_vector'("0000000");
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
  p11_stage_11 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic_vector'("0000000");
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
  p10_stage_10 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic_vector'("0000000");
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
  p9_stage_9 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic_vector'("0000000");
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
  p8_stage_8 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic_vector'("0000000");
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
  p7_stage_7 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic_vector'("0000000");
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
  p6_stage_6 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic_vector'("0000000");
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
  p5_stage_5 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic_vector'("0000000");
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
  p4_stage_4 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic_vector'("0000000");
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
  p3_stage_3 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic_vector'("0000000");
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
  p2_stage_2 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic_vector'("0000000");
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
  p1_stage_1 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic_vector'("0000000");
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
  p0_stage_0 <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic_vector'("0000000");
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
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(or_reduce(data_in)))), A_WE_StdLogicVector((std_logic'(((((read AND (or_reduce(data_in))) AND write) AND (or_reduce(stage_0))))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (or_reduce(data_in))))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (or_reduce(stage_0))))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
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

entity rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream_module is 
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
end entity rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream_module;


architecture europa of rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream_module is
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
                signal full_33 :  STD_LOGIC;
                signal full_34 :  STD_LOGIC;
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
                signal p32_full_32 :  STD_LOGIC;
                signal p32_stage_32 :  STD_LOGIC;
                signal p33_full_33 :  STD_LOGIC;
                signal p33_stage_33 :  STD_LOGIC;
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
                signal stage_32 :  STD_LOGIC;
                signal stage_33 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_33;
  empty <= NOT(full_0);
  full_34 <= std_logic'('0');
  --data_33, which is an e_mux
  p33_stage_33 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_34 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_33, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_33 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_33))))) = '1' then 
        if std_logic'(((sync_reset AND full_33) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_34))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_33 <= std_logic'('0');
        else
          stage_33 <= p33_stage_33;
        end if;
      end if;
    end if;

  end process;

  --control_33, which is an e_mux
  p33_full_33 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_33, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_33 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_33 <= std_logic'('0');
        else
          full_33 <= p33_full_33;
        end if;
      end if;
    end if;

  end process;

  --data_32, which is an e_mux
  p32_stage_32 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_33 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_33);
  --data_reg_32, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_32 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_32))))) = '1' then 
        if std_logic'(((sync_reset AND full_32) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_33))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_32 <= std_logic'('0');
        else
          stage_32 <= p32_stage_32;
        end if;
      end if;
    end if;

  end process;

  --control_32, which is an e_mux
  p32_full_32 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_31, full_33);
  --control_reg_32, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_32 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_32 <= std_logic'('0');
        else
          full_32 <= p32_full_32;
        end if;
      end if;
    end if;

  end process;

  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_32);
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
  p31_full_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_30, full_32);
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

entity vip_sopc_burst_1_upstream_arbitrator is 
        port (
              -- inputs:
                 signal alt_vip_vfb_0_read_master_address_to_slave : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal alt_vip_vfb_0_read_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal alt_vip_vfb_0_read_master_latency_counter : IN STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_readdatavalid : IN STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_waitrequest : IN STD_LOGIC;

              -- outputs:
                 signal alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register : OUT STD_LOGIC;
                 signal alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                 signal d1_vip_sopc_burst_1_upstream_end_xfer : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_address : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_burstcount : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_byteaddress : OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_debugaccess : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_read : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_readdata_from_sa : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_1_upstream_waitrequest_from_sa : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_upstream_write : OUT STD_LOGIC
              );
end entity vip_sopc_burst_1_upstream_arbitrator;


architecture europa of vip_sopc_burst_1_upstream_arbitrator is
component burstcount_fifo_for_vip_sopc_burst_1_upstream_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component burstcount_fifo_for_vip_sopc_burst_1_upstream_module;

component rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream_module is 
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
end component rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream_module;

                signal alt_vip_vfb_0_read_master_arbiterlock :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_arbiterlock2 :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_continuerequest :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_rdv_fifo_empty_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_rdv_fifo_output_from_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_saved_grant_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal internal_alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_upstream_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal internal_vip_sopc_burst_1_upstream_read :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_upstream_waitrequest_from_sa :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_upstream_write :  STD_LOGIC;
                signal module_input10 :  STD_LOGIC;
                signal module_input11 :  STD_LOGIC;
                signal module_input12 :  STD_LOGIC;
                signal module_input13 :  STD_LOGIC;
                signal module_input14 :  STD_LOGIC;
                signal module_input15 :  STD_LOGIC;
                signal p0_vip_sopc_burst_1_upstream_load_fifo :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_allgrants :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_allow_new_arb_cycle :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_any_bursting_master_saved_grant :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_any_continuerequest :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_arb_counter_enable :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_arb_share_counter :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_arb_share_counter_next_value :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_arb_share_set_values :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_bbt_burstcounter :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_beginbursttransfer_internal :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_begins_xfer :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_burstcount_fifo_empty :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_current_burst :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_current_burst_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_end_xfer :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_firsttransfer :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_grant_vector :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_in_a_read_cycle :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_in_a_write_cycle :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_load_fifo :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_master_qreq_vector :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_move_on_to_next_transaction :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_next_bbt_burstcount :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_next_burst_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_non_bursting_master_requests :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_readdatavalid_from_sa :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_reg_firsttransfer :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_selected_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_slavearbiterlockenable :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_slavearbiterlockenable2 :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_transaction_burst_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_unreg_firsttransfer :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_waits_for_read :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_waits_for_write :  STD_LOGIC;
                signal wait_for_vip_sopc_burst_1_upstream_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT vip_sopc_burst_1_upstream_end_xfer;
    end if;

  end process;

  vip_sopc_burst_1_upstream_begins_xfer <= NOT d1_reasons_to_wait AND (internal_alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream);
  --assign vip_sopc_burst_1_upstream_readdata_from_sa = vip_sopc_burst_1_upstream_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  vip_sopc_burst_1_upstream_readdata_from_sa <= vip_sopc_burst_1_upstream_readdata;
  internal_alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream <= ((to_std_logic(((Std_Logic_Vector'(alt_vip_vfb_0_read_master_address_to_slave(31 DOWNTO 29) & std_logic_vector'("00000000000000000000000000000")) = std_logic_vector'("00000000000000000000000000000000")))) AND (alt_vip_vfb_0_read_master_read))) AND alt_vip_vfb_0_read_master_read;
  --assign vip_sopc_burst_1_upstream_waitrequest_from_sa = vip_sopc_burst_1_upstream_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_vip_sopc_burst_1_upstream_waitrequest_from_sa <= vip_sopc_burst_1_upstream_waitrequest;
  --assign vip_sopc_burst_1_upstream_readdatavalid_from_sa = vip_sopc_burst_1_upstream_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  vip_sopc_burst_1_upstream_readdatavalid_from_sa <= vip_sopc_burst_1_upstream_readdatavalid;
  --vip_sopc_burst_1_upstream_arb_share_counter set values, which is an e_mux
  vip_sopc_burst_1_upstream_arb_share_set_values <= std_logic_vector'("0000001");
  --vip_sopc_burst_1_upstream_non_bursting_master_requests mux, which is an e_mux
  vip_sopc_burst_1_upstream_non_bursting_master_requests <= std_logic'('0');
  --vip_sopc_burst_1_upstream_any_bursting_master_saved_grant mux, which is an e_mux
  vip_sopc_burst_1_upstream_any_bursting_master_saved_grant <= alt_vip_vfb_0_read_master_saved_grant_vip_sopc_burst_1_upstream;
  --vip_sopc_burst_1_upstream_arb_share_counter_next_value assignment, which is an e_assign
  vip_sopc_burst_1_upstream_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(vip_sopc_burst_1_upstream_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_1_upstream_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(vip_sopc_burst_1_upstream_arb_share_counter)) = '1'), (((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_1_upstream_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 7);
  --vip_sopc_burst_1_upstream_allgrants all slave grants, which is an e_mux
  vip_sopc_burst_1_upstream_allgrants <= vip_sopc_burst_1_upstream_grant_vector;
  --vip_sopc_burst_1_upstream_end_xfer assignment, which is an e_assign
  vip_sopc_burst_1_upstream_end_xfer <= NOT ((vip_sopc_burst_1_upstream_waits_for_read OR vip_sopc_burst_1_upstream_waits_for_write));
  --end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream <= vip_sopc_burst_1_upstream_end_xfer AND (((NOT vip_sopc_burst_1_upstream_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --vip_sopc_burst_1_upstream_arb_share_counter arbitration counter enable, which is an e_assign
  vip_sopc_burst_1_upstream_arb_counter_enable <= ((end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream AND vip_sopc_burst_1_upstream_allgrants)) OR ((end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream AND NOT vip_sopc_burst_1_upstream_non_bursting_master_requests));
  --vip_sopc_burst_1_upstream_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_upstream_arb_share_counter <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'(vip_sopc_burst_1_upstream_arb_counter_enable) = '1' then 
        vip_sopc_burst_1_upstream_arb_share_counter <= vip_sopc_burst_1_upstream_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --vip_sopc_burst_1_upstream_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_upstream_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((vip_sopc_burst_1_upstream_master_qreq_vector AND end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream)) OR ((end_xfer_arb_share_counter_term_vip_sopc_burst_1_upstream AND NOT vip_sopc_burst_1_upstream_non_bursting_master_requests)))) = '1' then 
        vip_sopc_burst_1_upstream_slavearbiterlockenable <= or_reduce(vip_sopc_burst_1_upstream_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --alt_vip_vfb_0/read_master vip_sopc_burst_1/upstream arbiterlock, which is an e_assign
  alt_vip_vfb_0_read_master_arbiterlock <= vip_sopc_burst_1_upstream_slavearbiterlockenable AND alt_vip_vfb_0_read_master_continuerequest;
  --vip_sopc_burst_1_upstream_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  vip_sopc_burst_1_upstream_slavearbiterlockenable2 <= or_reduce(vip_sopc_burst_1_upstream_arb_share_counter_next_value);
  --alt_vip_vfb_0/read_master vip_sopc_burst_1/upstream arbiterlock2, which is an e_assign
  alt_vip_vfb_0_read_master_arbiterlock2 <= vip_sopc_burst_1_upstream_slavearbiterlockenable2 AND alt_vip_vfb_0_read_master_continuerequest;
  --vip_sopc_burst_1_upstream_any_continuerequest at least one master continues requesting, which is an e_assign
  vip_sopc_burst_1_upstream_any_continuerequest <= std_logic'('1');
  --alt_vip_vfb_0_read_master_continuerequest continued request, which is an e_assign
  alt_vip_vfb_0_read_master_continuerequest <= std_logic'('1');
  internal_alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream <= internal_alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream AND NOT ((alt_vip_vfb_0_read_master_read AND to_std_logic((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(alt_vip_vfb_0_read_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))) OR ((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(alt_vip_vfb_0_read_master_latency_counter))))))))));
  --unique name for vip_sopc_burst_1_upstream_move_on_to_next_transaction, which is an e_assign
  vip_sopc_burst_1_upstream_move_on_to_next_transaction <= vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst AND vip_sopc_burst_1_upstream_load_fifo;
  --the currently selected burstcount for vip_sopc_burst_1_upstream, which is an e_mux
  vip_sopc_burst_1_upstream_selected_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream)) = '1'), (std_logic_vector'("0000000000000000000000000") & (alt_vip_vfb_0_read_master_burstcount)), std_logic_vector'("00000000000000000000000000000001")), 7);
  --burstcount_fifo_for_vip_sopc_burst_1_upstream, which is an e_fifo_with_registered_outputs
  burstcount_fifo_for_vip_sopc_burst_1_upstream : burstcount_fifo_for_vip_sopc_burst_1_upstream_module
    port map(
      data_out => vip_sopc_burst_1_upstream_transaction_burst_count,
      empty => vip_sopc_burst_1_upstream_burstcount_fifo_empty,
      fifo_contains_ones_n => open,
      full => open,
      clear_fifo => module_input10,
      clk => clk,
      data_in => vip_sopc_burst_1_upstream_selected_burstcount,
      read => vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst,
      reset_n => reset_n,
      sync_reset => module_input11,
      write => module_input12
    );

  module_input10 <= std_logic'('0');
  module_input11 <= std_logic'('0');
  module_input12 <= ((in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read) AND vip_sopc_burst_1_upstream_load_fifo) AND NOT ((vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst AND vip_sopc_burst_1_upstream_burstcount_fifo_empty));

  --vip_sopc_burst_1_upstream current burst minus one, which is an e_assign
  vip_sopc_burst_1_upstream_current_burst_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_1_upstream_current_burst)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --what to load in current_burst, for vip_sopc_burst_1_upstream, which is an e_mux
  vip_sopc_burst_1_upstream_next_burst_count <= A_WE_StdLogicVector((std_logic'(((((in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read)) AND NOT vip_sopc_burst_1_upstream_load_fifo))) = '1'), vip_sopc_burst_1_upstream_selected_burstcount, A_WE_StdLogicVector((std_logic'(((((in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read) AND vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst) AND vip_sopc_burst_1_upstream_burstcount_fifo_empty))) = '1'), vip_sopc_burst_1_upstream_selected_burstcount, A_WE_StdLogicVector((std_logic'((vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst)) = '1'), vip_sopc_burst_1_upstream_transaction_burst_count, vip_sopc_burst_1_upstream_current_burst_minus_one)));
  --the current burst count for vip_sopc_burst_1_upstream, to be decremented, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_upstream_current_burst <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((vip_sopc_burst_1_upstream_readdatavalid_from_sa OR ((NOT vip_sopc_burst_1_upstream_load_fifo AND ((in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read)))))) = '1' then 
        vip_sopc_burst_1_upstream_current_burst <= vip_sopc_burst_1_upstream_next_burst_count;
      end if;
    end if;

  end process;

  --a 1 or burstcount fifo empty, to initialize the counter, which is an e_mux
  p0_vip_sopc_burst_1_upstream_load_fifo <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((NOT vip_sopc_burst_1_upstream_load_fifo)) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((((in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read)) AND vip_sopc_burst_1_upstream_load_fifo))) = '1'), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT vip_sopc_burst_1_upstream_burstcount_fifo_empty))))));
  --whether to load directly to the counter or to the fifo, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_upstream_load_fifo <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((((in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read)) AND NOT vip_sopc_burst_1_upstream_load_fifo) OR vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst)) = '1' then 
        vip_sopc_burst_1_upstream_load_fifo <= p0_vip_sopc_burst_1_upstream_load_fifo;
      end if;
    end if;

  end process;

  --the last cycle in the burst for vip_sopc_burst_1_upstream, which is an e_assign
  vip_sopc_burst_1_upstream_this_cycle_is_the_last_burst <= NOT (or_reduce(vip_sopc_burst_1_upstream_current_burst_minus_one)) AND vip_sopc_burst_1_upstream_readdatavalid_from_sa;
  --rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream : rdv_fifo_for_alt_vip_vfb_0_read_master_to_vip_sopc_burst_1_upstream_module
    port map(
      data_out => alt_vip_vfb_0_read_master_rdv_fifo_output_from_vip_sopc_burst_1_upstream,
      empty => open,
      fifo_contains_ones_n => alt_vip_vfb_0_read_master_rdv_fifo_empty_vip_sopc_burst_1_upstream,
      full => open,
      clear_fifo => module_input13,
      clk => clk,
      data_in => internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream,
      read => vip_sopc_burst_1_upstream_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input14,
      write => module_input15
    );

  module_input13 <= std_logic'('0');
  module_input14 <= std_logic'('0');
  module_input15 <= in_a_read_cycle AND NOT vip_sopc_burst_1_upstream_waits_for_read;

  alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register <= NOT alt_vip_vfb_0_read_master_rdv_fifo_empty_vip_sopc_burst_1_upstream;
  --local readdatavalid alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream, which is an e_mux
  alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream <= vip_sopc_burst_1_upstream_readdatavalid_from_sa;
  --byteaddress mux for vip_sopc_burst_1/upstream, which is an e_mux
  vip_sopc_burst_1_upstream_byteaddress <= std_logic_vector'("00") & (alt_vip_vfb_0_read_master_address_to_slave);
  --master is always granted when requested
  internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream <= internal_alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream;
  --alt_vip_vfb_0/read_master saved-grant vip_sopc_burst_1/upstream, which is an e_assign
  alt_vip_vfb_0_read_master_saved_grant_vip_sopc_burst_1_upstream <= internal_alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream;
  --allow new arb cycle for vip_sopc_burst_1/upstream, which is an e_assign
  vip_sopc_burst_1_upstream_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  vip_sopc_burst_1_upstream_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  vip_sopc_burst_1_upstream_master_qreq_vector <= std_logic'('1');
  --vip_sopc_burst_1_upstream_firsttransfer first transaction, which is an e_assign
  vip_sopc_burst_1_upstream_firsttransfer <= A_WE_StdLogic((std_logic'(vip_sopc_burst_1_upstream_begins_xfer) = '1'), vip_sopc_burst_1_upstream_unreg_firsttransfer, vip_sopc_burst_1_upstream_reg_firsttransfer);
  --vip_sopc_burst_1_upstream_unreg_firsttransfer first transaction, which is an e_assign
  vip_sopc_burst_1_upstream_unreg_firsttransfer <= NOT ((vip_sopc_burst_1_upstream_slavearbiterlockenable AND vip_sopc_burst_1_upstream_any_continuerequest));
  --vip_sopc_burst_1_upstream_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_upstream_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(vip_sopc_burst_1_upstream_begins_xfer) = '1' then 
        vip_sopc_burst_1_upstream_reg_firsttransfer <= vip_sopc_burst_1_upstream_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --vip_sopc_burst_1_upstream_next_bbt_burstcount next_bbt_burstcount, which is an e_mux
  vip_sopc_burst_1_upstream_next_bbt_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((((internal_vip_sopc_burst_1_upstream_write) AND to_std_logic((((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_1_upstream_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))))))) = '1'), (((std_logic_vector'("00000000000000000000000000") & (internal_vip_sopc_burst_1_upstream_burstcount)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'((((internal_vip_sopc_burst_1_upstream_read) AND to_std_logic((((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_1_upstream_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))))))) = '1'), std_logic_vector'("000000000000000000000000000000000"), (((std_logic_vector'("000000000000000000000000000") & (vip_sopc_burst_1_upstream_bbt_burstcounter)) - std_logic_vector'("000000000000000000000000000000001"))))), 6);
  --vip_sopc_burst_1_upstream_bbt_burstcounter bbt_burstcounter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_upstream_bbt_burstcounter <= std_logic_vector'("000000");
    elsif clk'event and clk = '1' then
      if std_logic'(vip_sopc_burst_1_upstream_begins_xfer) = '1' then 
        vip_sopc_burst_1_upstream_bbt_burstcounter <= vip_sopc_burst_1_upstream_next_bbt_burstcount;
      end if;
    end if;

  end process;

  --vip_sopc_burst_1_upstream_beginbursttransfer_internal begin burst transfer, which is an e_assign
  vip_sopc_burst_1_upstream_beginbursttransfer_internal <= vip_sopc_burst_1_upstream_begins_xfer AND to_std_logic((((std_logic_vector'("00000000000000000000000000") & (vip_sopc_burst_1_upstream_bbt_burstcounter)) = std_logic_vector'("00000000000000000000000000000000"))));
  --vip_sopc_burst_1_upstream_read assignment, which is an e_mux
  internal_vip_sopc_burst_1_upstream_read <= internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream AND alt_vip_vfb_0_read_master_read;
  --vip_sopc_burst_1_upstream_write assignment, which is an e_mux
  internal_vip_sopc_burst_1_upstream_write <= std_logic'('0');
  --vip_sopc_burst_1_upstream_address mux, which is an e_mux
  vip_sopc_burst_1_upstream_address <= alt_vip_vfb_0_read_master_address_to_slave (28 DOWNTO 0);
  --d1_vip_sopc_burst_1_upstream_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_vip_sopc_burst_1_upstream_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_vip_sopc_burst_1_upstream_end_xfer <= vip_sopc_burst_1_upstream_end_xfer;
    end if;

  end process;

  --vip_sopc_burst_1_upstream_waits_for_read in a cycle, which is an e_mux
  vip_sopc_burst_1_upstream_waits_for_read <= vip_sopc_burst_1_upstream_in_a_read_cycle AND internal_vip_sopc_burst_1_upstream_waitrequest_from_sa;
  --vip_sopc_burst_1_upstream_in_a_read_cycle assignment, which is an e_assign
  vip_sopc_burst_1_upstream_in_a_read_cycle <= internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream AND alt_vip_vfb_0_read_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= vip_sopc_burst_1_upstream_in_a_read_cycle;
  --vip_sopc_burst_1_upstream_waits_for_write in a cycle, which is an e_mux
  vip_sopc_burst_1_upstream_waits_for_write <= vip_sopc_burst_1_upstream_in_a_write_cycle AND internal_vip_sopc_burst_1_upstream_waitrequest_from_sa;
  --vip_sopc_burst_1_upstream_in_a_write_cycle assignment, which is an e_assign
  vip_sopc_burst_1_upstream_in_a_write_cycle <= std_logic'('0');
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= vip_sopc_burst_1_upstream_in_a_write_cycle;
  wait_for_vip_sopc_burst_1_upstream_counter <= std_logic'('0');
  --vip_sopc_burst_1_upstream_byteenable byte enable port mux, which is an e_mux
  vip_sopc_burst_1_upstream_byteenable <= -SIGNED(std_logic_vector'("00000000000000000000000000000001"));
  --burstcount mux, which is an e_mux
  internal_vip_sopc_burst_1_upstream_burstcount <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream)) = '1'), (std_logic_vector'("0000000000000000000000000") & (alt_vip_vfb_0_read_master_burstcount)), std_logic_vector'("00000000000000000000000000000001")), 7);
  --debugaccess mux, which is an e_mux
  vip_sopc_burst_1_upstream_debugaccess <= std_logic'('0');
  --vhdl renameroo for output signals
  alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream <= internal_alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream <= internal_alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream;
  --vhdl renameroo for output signals
  alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream <= internal_alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_upstream_burstcount <= internal_vip_sopc_burst_1_upstream_burstcount;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_upstream_read <= internal_vip_sopc_burst_1_upstream_read;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_upstream_waitrequest_from_sa <= internal_vip_sopc_burst_1_upstream_waitrequest_from_sa;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_upstream_write <= internal_vip_sopc_burst_1_upstream_write;
--synthesis translate_off
    --vip_sopc_burst_1/upstream enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --alt_vip_vfb_0/read_master non-zero burstcount assertion, which is an e_process
    process (clk)
    VARIABLE write_line20 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((internal_alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream AND to_std_logic((((std_logic_vector'("0000000000000000000000000") & (alt_vip_vfb_0_read_master_burstcount)) = std_logic_vector'("00000000000000000000000000000000"))))) AND enable_nonzero_assertions)) = '1' then 
          write(write_line20, now);
          write(write_line20, string'(": "));
          write(write_line20, string'("alt_vip_vfb_0/read_master drove 0 on its 'burstcount' port while accessing slave vip_sopc_burst_1/upstream"));
          write(output, write_line20.all);
          deallocate (write_line20);
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

entity vip_sopc_burst_1_downstream_arbitrator is 
        port (
              -- inputs:
                 signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_address : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_read : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_write : IN STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

              -- outputs:
                 signal vip_sopc_burst_1_downstream_address_to_slave : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_latency_counter : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                 signal vip_sopc_burst_1_downstream_readdatavalid : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_reset_n : OUT STD_LOGIC;
                 signal vip_sopc_burst_1_downstream_waitrequest : OUT STD_LOGIC
              );
end entity vip_sopc_burst_1_downstream_arbitrator;


architecture europa of vip_sopc_burst_1_downstream_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_downstream_address_to_slave :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal internal_vip_sopc_burst_1_downstream_latency_counter :  STD_LOGIC;
                signal internal_vip_sopc_burst_1_downstream_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_vip_sopc_burst_1_downstream_latency_counter :  STD_LOGIC;
                signal pre_flush_vip_sopc_burst_1_downstream_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_address_last_time :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_burstcount_last_time :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_byteenable_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_is_granted_some_slave :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_read_but_no_slave_selected :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_read_last_time :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_run :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_write_last_time :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_writedata_last_time :  STD_LOGIC_VECTOR (255 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 OR NOT vip_sopc_burst_1_downstream_requests_altmemddr_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 OR NOT vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 OR NOT ((vip_sopc_burst_1_downstream_read OR vip_sopc_burst_1_downstream_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_1_downstream_read OR vip_sopc_burst_1_downstream_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 OR NOT ((vip_sopc_burst_1_downstream_read OR vip_sopc_burst_1_downstream_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altmemddr_0_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((vip_sopc_burst_1_downstream_read OR vip_sopc_burst_1_downstream_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  vip_sopc_burst_1_downstream_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_vip_sopc_burst_1_downstream_address_to_slave <= vip_sopc_burst_1_downstream_address;
  --vip_sopc_burst_1_downstream_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vip_sopc_burst_1_downstream_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      vip_sopc_burst_1_downstream_read_but_no_slave_selected <= (vip_sopc_burst_1_downstream_read AND vip_sopc_burst_1_downstream_run) AND NOT vip_sopc_burst_1_downstream_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  vip_sopc_burst_1_downstream_is_granted_some_slave <= vip_sopc_burst_1_downstream_granted_altmemddr_0_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_vip_sopc_burst_1_downstream_readdatavalid <= vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  vip_sopc_burst_1_downstream_readdatavalid <= vip_sopc_burst_1_downstream_read_but_no_slave_selected OR pre_flush_vip_sopc_burst_1_downstream_readdatavalid;
  --vip_sopc_burst_1/downstream readdata mux, which is an e_mux
  vip_sopc_burst_1_downstream_readdata <= altmemddr_0_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_vip_sopc_burst_1_downstream_waitrequest <= NOT vip_sopc_burst_1_downstream_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_vip_sopc_burst_1_downstream_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_vip_sopc_burst_1_downstream_latency_counter <= p1_vip_sopc_burst_1_downstream_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_vip_sopc_burst_1_downstream_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((vip_sopc_burst_1_downstream_run AND vip_sopc_burst_1_downstream_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_vip_sopc_burst_1_downstream_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_vip_sopc_burst_1_downstream_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= std_logic'('0');
  --vip_sopc_burst_1_downstream_reset_n assignment, which is an e_assign
  vip_sopc_burst_1_downstream_reset_n <= reset_n;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_downstream_address_to_slave <= internal_vip_sopc_burst_1_downstream_address_to_slave;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_downstream_latency_counter <= internal_vip_sopc_burst_1_downstream_latency_counter;
  --vhdl renameroo for output signals
  vip_sopc_burst_1_downstream_waitrequest <= internal_vip_sopc_burst_1_downstream_waitrequest;
--synthesis translate_off
    --vip_sopc_burst_1_downstream_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_1_downstream_address_last_time <= std_logic_vector'("00000000000000000000000000000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_1_downstream_address_last_time <= vip_sopc_burst_1_downstream_address;
      end if;

    end process;

    --vip_sopc_burst_1/downstream waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_vip_sopc_burst_1_downstream_waitrequest AND ((vip_sopc_burst_1_downstream_read OR vip_sopc_burst_1_downstream_write));
      end if;

    end process;

    --vip_sopc_burst_1_downstream_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line21 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_1_downstream_address /= vip_sopc_burst_1_downstream_address_last_time))))) = '1' then 
          write(write_line21, now);
          write(write_line21, string'(": "));
          write(write_line21, string'("vip_sopc_burst_1_downstream_address did not heed wait!!!"));
          write(output, write_line21.all);
          deallocate (write_line21);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_burstcount check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_1_downstream_burstcount_last_time <= std_logic_vector'("000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_1_downstream_burstcount_last_time <= vip_sopc_burst_1_downstream_burstcount;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_burstcount matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line22 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_1_downstream_burstcount /= vip_sopc_burst_1_downstream_burstcount_last_time))))) = '1' then 
          write(write_line22, now);
          write(write_line22, string'(": "));
          write(write_line22, string'("vip_sopc_burst_1_downstream_burstcount did not heed wait!!!"));
          write(output, write_line22.all);
          deallocate (write_line22);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_1_downstream_byteenable_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_1_downstream_byteenable_last_time <= vip_sopc_burst_1_downstream_byteenable;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line23 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_1_downstream_byteenable /= vip_sopc_burst_1_downstream_byteenable_last_time))))) = '1' then 
          write(write_line23, now);
          write(write_line23, string'(": "));
          write(write_line23, string'("vip_sopc_burst_1_downstream_byteenable did not heed wait!!!"));
          write(output, write_line23.all);
          deallocate (write_line23);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_1_downstream_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        vip_sopc_burst_1_downstream_read_last_time <= vip_sopc_burst_1_downstream_read;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line24 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(vip_sopc_burst_1_downstream_read) /= std_logic'(vip_sopc_burst_1_downstream_read_last_time)))))) = '1' then 
          write(write_line24, now);
          write(write_line24, string'(": "));
          write(write_line24, string'("vip_sopc_burst_1_downstream_read did not heed wait!!!"));
          write(output, write_line24.all);
          deallocate (write_line24);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_1_downstream_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        vip_sopc_burst_1_downstream_write_last_time <= vip_sopc_burst_1_downstream_write;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line25 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(vip_sopc_burst_1_downstream_write) /= std_logic'(vip_sopc_burst_1_downstream_write_last_time)))))) = '1' then 
          write(write_line25, now);
          write(write_line25, string'(": "));
          write(write_line25, string'("vip_sopc_burst_1_downstream_write did not heed wait!!!"));
          write(output, write_line25.all);
          deallocate (write_line25);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        vip_sopc_burst_1_downstream_writedata_last_time <= std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        vip_sopc_burst_1_downstream_writedata_last_time <= vip_sopc_burst_1_downstream_writedata;
      end if;

    end process;

    --vip_sopc_burst_1_downstream_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line26 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((vip_sopc_burst_1_downstream_writedata /= vip_sopc_burst_1_downstream_writedata_last_time)))) AND vip_sopc_burst_1_downstream_write)) = '1' then 
          write(write_line26, now);
          write(write_line26, string'(": "));
          write(write_line26, string'("vip_sopc_burst_1_downstream_writedata did not heed wait!!!"));
          write(output, write_line26.all);
          deallocate (write_line26);
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

entity vip_sopc_reset_vip_clk_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity vip_sopc_reset_vip_clk_domain_synch_module;


architecture europa of vip_sopc_reset_vip_clk_domain_synch_module is
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

entity vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch_module;


architecture europa of vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch_module is
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

entity vip_sopc is 
        port (
              -- 1) global signals:
                 signal altmemddr_0_aux_full_rate_clk_out : OUT STD_LOGIC;
                 signal altmemddr_0_aux_half_rate_clk_out : OUT STD_LOGIC;
                 signal altmemddr_0_phy_clk_out : OUT STD_LOGIC;
                 signal clk_24M : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal vip_clk : IN STD_LOGIC;

              -- the_alt_vip_cti_0
                 signal overflow_from_the_alt_vip_cti_0 : OUT STD_LOGIC;
                 signal vid_clk_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                 signal vid_data_to_the_alt_vip_cti_0 : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal vid_datavalid_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                 signal vid_f_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                 signal vid_h_sync_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                 signal vid_locked_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                 signal vid_v_sync_to_the_alt_vip_cti_0 : IN STD_LOGIC;

              -- the_alt_vip_itc_0
                 signal underflow_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                 signal vid_clk_to_the_alt_vip_itc_0 : IN STD_LOGIC;
                 signal vid_data_from_the_alt_vip_itc_0 : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal vid_datavalid_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                 signal vid_f_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                 signal vid_h_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                 signal vid_h_sync_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                 signal vid_v_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                 signal vid_v_sync_from_the_alt_vip_itc_0 : OUT STD_LOGIC;

              -- the_altmemddr_0
                 signal aux_scan_clk_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal aux_scan_clk_reset_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal dll_reference_clk_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal dqs_delay_ctrl_export_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal global_reset_n_to_the_altmemddr_0 : IN STD_LOGIC;
                 signal local_init_done_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal local_refresh_ack_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal local_wdata_req_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_addr_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal mem_ba_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal mem_cas_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_cke_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_clk_n_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                 signal mem_clk_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                 signal mem_cs_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_dm_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal mem_dq_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal mem_dqs_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal mem_dqsn_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal mem_odt_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_ras_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_reset_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal mem_we_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                 signal oct_ctl_rs_value_to_the_altmemddr_0 : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal oct_ctl_rt_value_to_the_altmemddr_0 : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal reset_phy_clk_n_from_the_altmemddr_0 : OUT STD_LOGIC
              );
end entity vip_sopc;


architecture europa of vip_sopc is
component alt_vip_cti_0_dout_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_cti_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_cti_0_dout_endofpacket : IN STD_LOGIC;
                    signal alt_vip_cti_0_dout_startofpacket : IN STD_LOGIC;
                    signal alt_vip_cti_0_dout_valid : IN STD_LOGIC;
                    signal alt_vip_scl_0_din_ready_from_sa : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_cti_0_dout_ready : OUT STD_LOGIC;
                    signal alt_vip_cti_0_dout_reset : OUT STD_LOGIC
                 );
end component alt_vip_cti_0_dout_arbitrator;

component alt_vip_cti_0 is 
           port (
                 -- inputs:
                    signal is_clk : IN STD_LOGIC;
                    signal is_ready : IN STD_LOGIC;
                    signal rst : IN STD_LOGIC;
                    signal vid_clk : IN STD_LOGIC;
                    signal vid_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal vid_datavalid : IN STD_LOGIC;
                    signal vid_f : IN STD_LOGIC;
                    signal vid_h_sync : IN STD_LOGIC;
                    signal vid_locked : IN STD_LOGIC;
                    signal vid_v_sync : IN STD_LOGIC;

                 -- outputs:
                    signal is_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal is_eop : OUT STD_LOGIC;
                    signal is_sop : OUT STD_LOGIC;
                    signal is_valid : OUT STD_LOGIC;
                    signal overflow : OUT STD_LOGIC
                 );
end component alt_vip_cti_0;

component alt_vip_itc_0_din_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_itc_0_din_ready : IN STD_LOGIC;
                    signal alt_vip_vfb_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_vfb_0_dout_endofpacket : IN STD_LOGIC;
                    signal alt_vip_vfb_0_dout_startofpacket : IN STD_LOGIC;
                    signal alt_vip_vfb_0_dout_valid : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_itc_0_din_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_itc_0_din_endofpacket : OUT STD_LOGIC;
                    signal alt_vip_itc_0_din_ready_from_sa : OUT STD_LOGIC;
                    signal alt_vip_itc_0_din_reset : OUT STD_LOGIC;
                    signal alt_vip_itc_0_din_startofpacket : OUT STD_LOGIC;
                    signal alt_vip_itc_0_din_valid : OUT STD_LOGIC
                 );
end component alt_vip_itc_0_din_arbitrator;

component alt_vip_itc_0 is 
           port (
                 -- inputs:
                    signal is_clk : IN STD_LOGIC;
                    signal is_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal is_eop : IN STD_LOGIC;
                    signal is_sop : IN STD_LOGIC;
                    signal is_valid : IN STD_LOGIC;
                    signal rst : IN STD_LOGIC;
                    signal vid_clk : IN STD_LOGIC;

                 -- outputs:
                    signal is_ready : OUT STD_LOGIC;
                    signal underflow : OUT STD_LOGIC;
                    signal vid_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal vid_datavalid : OUT STD_LOGIC;
                    signal vid_f : OUT STD_LOGIC;
                    signal vid_h : OUT STD_LOGIC;
                    signal vid_h_sync : OUT STD_LOGIC;
                    signal vid_v : OUT STD_LOGIC;
                    signal vid_v_sync : OUT STD_LOGIC
                 );
end component alt_vip_itc_0;

component alt_vip_scl_0_din_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_cti_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_cti_0_dout_endofpacket : IN STD_LOGIC;
                    signal alt_vip_cti_0_dout_startofpacket : IN STD_LOGIC;
                    signal alt_vip_cti_0_dout_valid : IN STD_LOGIC;
                    signal alt_vip_scl_0_din_ready : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_scl_0_din_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_scl_0_din_endofpacket : OUT STD_LOGIC;
                    signal alt_vip_scl_0_din_ready_from_sa : OUT STD_LOGIC;
                    signal alt_vip_scl_0_din_reset : OUT STD_LOGIC;
                    signal alt_vip_scl_0_din_startofpacket : OUT STD_LOGIC;
                    signal alt_vip_scl_0_din_valid : OUT STD_LOGIC
                 );
end component alt_vip_scl_0_din_arbitrator;

component alt_vip_scl_0_dout_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_scl_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_scl_0_dout_endofpacket : IN STD_LOGIC;
                    signal alt_vip_scl_0_dout_startofpacket : IN STD_LOGIC;
                    signal alt_vip_scl_0_dout_valid : IN STD_LOGIC;
                    signal alt_vip_vfb_0_din_ready_from_sa : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_scl_0_dout_ready : OUT STD_LOGIC
                 );
end component alt_vip_scl_0_dout_arbitrator;

component alt_vip_scl_0 is 
           port (
                 -- inputs:
                    signal clock : IN STD_LOGIC;
                    signal din_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal din_endofpacket : IN STD_LOGIC;
                    signal din_startofpacket : IN STD_LOGIC;
                    signal din_valid : IN STD_LOGIC;
                    signal dout_ready : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;

                 -- outputs:
                    signal din_ready : OUT STD_LOGIC;
                    signal dout_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal dout_endofpacket : OUT STD_LOGIC;
                    signal dout_startofpacket : OUT STD_LOGIC;
                    signal dout_valid : OUT STD_LOGIC
                 );
end component alt_vip_scl_0;

component alt_vip_vfb_0_din_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_scl_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_scl_0_dout_endofpacket : IN STD_LOGIC;
                    signal alt_vip_scl_0_dout_startofpacket : IN STD_LOGIC;
                    signal alt_vip_scl_0_dout_valid : IN STD_LOGIC;
                    signal alt_vip_vfb_0_din_ready : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_vfb_0_din_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_vfb_0_din_endofpacket : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_din_ready_from_sa : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_din_reset : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_din_startofpacket : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_din_valid : OUT STD_LOGIC
                 );
end component alt_vip_vfb_0_din_arbitrator;

component alt_vip_vfb_0_dout_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_itc_0_din_ready_from_sa : IN STD_LOGIC;
                    signal alt_vip_vfb_0_dout_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal alt_vip_vfb_0_dout_endofpacket : IN STD_LOGIC;
                    signal alt_vip_vfb_0_dout_startofpacket : IN STD_LOGIC;
                    signal alt_vip_vfb_0_dout_valid : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_vfb_0_dout_ready : OUT STD_LOGIC
                 );
end component alt_vip_vfb_0_dout_arbitrator;

component alt_vip_vfb_0_read_master_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_vfb_0_read_master_address : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal alt_vip_vfb_0_read_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_read : IN STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register : IN STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal d1_vip_sopc_burst_1_upstream_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_readdata_from_sa : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_waitrequest_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_vfb_0_read_master_address_to_slave : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal alt_vip_vfb_0_read_master_latency_counter : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal alt_vip_vfb_0_read_master_readdatavalid : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_reset : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_waitrequest : OUT STD_LOGIC
                 );
end component alt_vip_vfb_0_read_master_arbitrator;

component alt_vip_vfb_0_write_master_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_vfb_0_write_master_address : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal alt_vip_vfb_0_write_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream : IN STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream : IN STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream : IN STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_write : IN STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_vip_sopc_burst_0_upstream_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_waitrequest_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_vfb_0_write_master_address_to_slave : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal alt_vip_vfb_0_write_master_reset : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_waitrequest : OUT STD_LOGIC
                 );
end component alt_vip_vfb_0_write_master_arbitrator;

component alt_vip_vfb_0 is 
           port (
                 -- inputs:
                    signal clock : IN STD_LOGIC;
                    signal din_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal din_endofpacket : IN STD_LOGIC;
                    signal din_startofpacket : IN STD_LOGIC;
                    signal din_valid : IN STD_LOGIC;
                    signal dout_ready : IN STD_LOGIC;
                    signal read_master_av_clock : IN STD_LOGIC;
                    signal read_master_av_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal read_master_av_readdatavalid : IN STD_LOGIC;
                    signal read_master_av_reset : IN STD_LOGIC;
                    signal read_master_av_waitrequest : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write_master_av_clock : IN STD_LOGIC;
                    signal write_master_av_reset : IN STD_LOGIC;
                    signal write_master_av_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal din_ready : OUT STD_LOGIC;
                    signal dout_data : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal dout_endofpacket : OUT STD_LOGIC;
                    signal dout_startofpacket : OUT STD_LOGIC;
                    signal dout_valid : OUT STD_LOGIC;
                    signal read_master_av_address : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal read_master_av_burstcount : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal read_master_av_read : OUT STD_LOGIC;
                    signal write_master_av_address : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal write_master_av_burstcount : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal write_master_av_write : OUT STD_LOGIC;
                    signal write_master_av_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0)
                 );
end component alt_vip_vfb_0;

component altmemddr_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal altmemddr_0_s1_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal altmemddr_0_s1_readdatavalid : IN STD_LOGIC;
                    signal altmemddr_0_s1_resetrequest_n : IN STD_LOGIC;
                    signal altmemddr_0_s1_waitrequest_n : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_address_to_slave : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_arbitrationshare : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_latency_counter : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_read : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_write : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_address_to_slave : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_arbitrationshare : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_latency_counter : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_read : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_write : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

                 -- outputs:
                    signal altmemddr_0_s1_address : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal altmemddr_0_s1_beginbursttransfer : OUT STD_LOGIC;
                    signal altmemddr_0_s1_burstcount : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal altmemddr_0_s1_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal altmemddr_0_s1_read : OUT STD_LOGIC;
                    signal altmemddr_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal altmemddr_0_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                    signal altmemddr_0_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal altmemddr_0_s1_write : OUT STD_LOGIC;
                    signal altmemddr_0_s1_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal d1_altmemddr_0_s1_end_xfer : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 : OUT STD_LOGIC
                 );
end component altmemddr_0_s1_arbitrator;

component vip_sopc_reset_clk_24M_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component vip_sopc_reset_clk_24M_domain_synch_module;

component altmemddr_0 is 
           port (
                 -- inputs:
                    signal global_reset_n : IN STD_LOGIC;
                    signal local_address : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal local_be : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal local_burstbegin : IN STD_LOGIC;
                    signal local_read_req : IN STD_LOGIC;
                    signal local_size : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal local_wdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal local_write_req : IN STD_LOGIC;
                    signal oct_ctl_rs_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal oct_ctl_rt_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal pll_ref_clk : IN STD_LOGIC;
                    signal soft_reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal aux_full_rate_clk : OUT STD_LOGIC;
                    signal aux_half_rate_clk : OUT STD_LOGIC;
                    signal aux_scan_clk : OUT STD_LOGIC;
                    signal aux_scan_clk_reset_n : OUT STD_LOGIC;
                    signal dll_reference_clk : OUT STD_LOGIC;
                    signal dqs_delay_ctrl_export : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal local_init_done : OUT STD_LOGIC;
                    signal local_rdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal local_rdata_valid : OUT STD_LOGIC;
                    signal local_ready : OUT STD_LOGIC;
                    signal local_refresh_ack : OUT STD_LOGIC;
                    signal local_wdata_req : OUT STD_LOGIC;
                    signal mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal mem_cas_n : OUT STD_LOGIC;
                    signal mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dm : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dq : INOUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal mem_dqs : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dqsn : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_ras_n : OUT STD_LOGIC;
                    signal mem_reset_n : OUT STD_LOGIC;
                    signal mem_we_n : OUT STD_LOGIC;
                    signal phy_clk : OUT STD_LOGIC;
                    signal reset_phy_clk_n : OUT STD_LOGIC;
                    signal reset_request_n : OUT STD_LOGIC
                 );
end component altmemddr_0;

component vip_sopc_burst_0_upstream_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_vfb_0_write_master_address_to_slave : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal alt_vip_vfb_0_write_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal alt_vip_vfb_0_write_master_write : IN STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_0_upstream_readdatavalid : IN STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream : OUT STD_LOGIC;
                    signal d1_vip_sopc_burst_0_upstream_end_xfer : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_address : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_0_upstream_burstcount : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal vip_sopc_burst_0_upstream_byteaddress : OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
                    signal vip_sopc_burst_0_upstream_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vip_sopc_burst_0_upstream_debugaccess : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_read : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_readdata_from_sa : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_0_upstream_readdatavalid_from_sa : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_waitrequest_from_sa : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_write : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_upstream_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0)
                 );
end component vip_sopc_burst_0_upstream_arbitrator;

component vip_sopc_burst_0_downstream_arbitrator is 
           port (
                 -- inputs:
                    signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_address : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_read : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_write : IN STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

                 -- outputs:
                    signal vip_sopc_burst_0_downstream_address_to_slave : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_latency_counter : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_0_downstream_readdatavalid : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_reset_n : OUT STD_LOGIC;
                    signal vip_sopc_burst_0_downstream_waitrequest : OUT STD_LOGIC
                 );
end component vip_sopc_burst_0_downstream_arbitrator;

component vip_sopc_burst_0 is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal downstream_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal downstream_readdatavalid : IN STD_LOGIC;
                    signal downstream_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal upstream_address : IN STD_LOGIC_VECTOR (33 DOWNTO 0);
                    signal upstream_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal upstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal upstream_debugaccess : IN STD_LOGIC;
                    signal upstream_nativeaddress : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal upstream_read : IN STD_LOGIC;
                    signal upstream_write : IN STD_LOGIC;
                    signal upstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

                 -- outputs:
                    signal downstream_address : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal downstream_arbitrationshare : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal downstream_burstcount : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal downstream_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal downstream_debugaccess : OUT STD_LOGIC;
                    signal downstream_nativeaddress : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal downstream_read : OUT STD_LOGIC;
                    signal downstream_write : OUT STD_LOGIC;
                    signal downstream_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal upstream_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal upstream_readdatavalid : OUT STD_LOGIC;
                    signal upstream_waitrequest : OUT STD_LOGIC
                 );
end component vip_sopc_burst_0;

component vip_sopc_burst_1_upstream_arbitrator is 
           port (
                 -- inputs:
                    signal alt_vip_vfb_0_read_master_address_to_slave : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal alt_vip_vfb_0_read_master_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal alt_vip_vfb_0_read_master_latency_counter : IN STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_readdatavalid : IN STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register : OUT STD_LOGIC;
                    signal alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream : OUT STD_LOGIC;
                    signal d1_vip_sopc_burst_1_upstream_end_xfer : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_address : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_burstcount : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_byteaddress : OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_debugaccess : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_read : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_readdata_from_sa : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_1_upstream_waitrequest_from_sa : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_upstream_write : OUT STD_LOGIC
                 );
end component vip_sopc_burst_1_upstream_arbitrator;

component vip_sopc_burst_1_downstream_arbitrator is 
           port (
                 -- inputs:
                    signal altmemddr_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal altmemddr_0_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal d1_altmemddr_0_s1_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_address : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_burstcount : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_read : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_write : IN STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

                 -- outputs:
                    signal vip_sopc_burst_1_downstream_address_to_slave : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_latency_counter : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal vip_sopc_burst_1_downstream_readdatavalid : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_reset_n : OUT STD_LOGIC;
                    signal vip_sopc_burst_1_downstream_waitrequest : OUT STD_LOGIC
                 );
end component vip_sopc_burst_1_downstream_arbitrator;

component vip_sopc_burst_1 is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal downstream_readdata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal downstream_readdatavalid : IN STD_LOGIC;
                    signal downstream_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal upstream_address : IN STD_LOGIC_VECTOR (33 DOWNTO 0);
                    signal upstream_burstcount : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal upstream_byteenable : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal upstream_debugaccess : IN STD_LOGIC;
                    signal upstream_nativeaddress : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal upstream_read : IN STD_LOGIC;
                    signal upstream_write : IN STD_LOGIC;
                    signal upstream_writedata : IN STD_LOGIC_VECTOR (255 DOWNTO 0);

                 -- outputs:
                    signal downstream_address : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal downstream_arbitrationshare : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                    signal downstream_burstcount : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal downstream_byteenable : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal downstream_debugaccess : OUT STD_LOGIC;
                    signal downstream_nativeaddress : OUT STD_LOGIC_VECTOR (28 DOWNTO 0);
                    signal downstream_read : OUT STD_LOGIC;
                    signal downstream_write : OUT STD_LOGIC;
                    signal downstream_writedata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal upstream_readdata : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
                    signal upstream_readdatavalid : OUT STD_LOGIC;
                    signal upstream_waitrequest : OUT STD_LOGIC
                 );
end component vip_sopc_burst_1;

component vip_sopc_reset_vip_clk_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component vip_sopc_reset_vip_clk_domain_synch_module;

component vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch_module;

                signal alt_vip_cti_0_dout_data :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal alt_vip_cti_0_dout_endofpacket :  STD_LOGIC;
                signal alt_vip_cti_0_dout_ready :  STD_LOGIC;
                signal alt_vip_cti_0_dout_reset :  STD_LOGIC;
                signal alt_vip_cti_0_dout_startofpacket :  STD_LOGIC;
                signal alt_vip_cti_0_dout_valid :  STD_LOGIC;
                signal alt_vip_itc_0_din_data :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal alt_vip_itc_0_din_endofpacket :  STD_LOGIC;
                signal alt_vip_itc_0_din_ready :  STD_LOGIC;
                signal alt_vip_itc_0_din_ready_from_sa :  STD_LOGIC;
                signal alt_vip_itc_0_din_reset :  STD_LOGIC;
                signal alt_vip_itc_0_din_startofpacket :  STD_LOGIC;
                signal alt_vip_itc_0_din_valid :  STD_LOGIC;
                signal alt_vip_scl_0_din_data :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal alt_vip_scl_0_din_endofpacket :  STD_LOGIC;
                signal alt_vip_scl_0_din_ready :  STD_LOGIC;
                signal alt_vip_scl_0_din_ready_from_sa :  STD_LOGIC;
                signal alt_vip_scl_0_din_reset :  STD_LOGIC;
                signal alt_vip_scl_0_din_startofpacket :  STD_LOGIC;
                signal alt_vip_scl_0_din_valid :  STD_LOGIC;
                signal alt_vip_scl_0_dout_data :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal alt_vip_scl_0_dout_endofpacket :  STD_LOGIC;
                signal alt_vip_scl_0_dout_ready :  STD_LOGIC;
                signal alt_vip_scl_0_dout_startofpacket :  STD_LOGIC;
                signal alt_vip_scl_0_dout_valid :  STD_LOGIC;
                signal alt_vip_vfb_0_din_data :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal alt_vip_vfb_0_din_endofpacket :  STD_LOGIC;
                signal alt_vip_vfb_0_din_ready :  STD_LOGIC;
                signal alt_vip_vfb_0_din_ready_from_sa :  STD_LOGIC;
                signal alt_vip_vfb_0_din_reset :  STD_LOGIC;
                signal alt_vip_vfb_0_din_startofpacket :  STD_LOGIC;
                signal alt_vip_vfb_0_din_valid :  STD_LOGIC;
                signal alt_vip_vfb_0_dout_data :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal alt_vip_vfb_0_dout_endofpacket :  STD_LOGIC;
                signal alt_vip_vfb_0_dout_ready :  STD_LOGIC;
                signal alt_vip_vfb_0_dout_startofpacket :  STD_LOGIC;
                signal alt_vip_vfb_0_dout_valid :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_address :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal alt_vip_vfb_0_read_master_address_to_slave :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal alt_vip_vfb_0_read_master_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_latency_counter :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_read :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_readdata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal alt_vip_vfb_0_read_master_readdatavalid :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_reset :  STD_LOGIC;
                signal alt_vip_vfb_0_read_master_waitrequest :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_address :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal alt_vip_vfb_0_write_master_address_to_slave :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal alt_vip_vfb_0_write_master_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_reset :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_waitrequest :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_write :  STD_LOGIC;
                signal alt_vip_vfb_0_write_master_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal altmemddr_0_phy_clk_out_reset_n :  STD_LOGIC;
                signal altmemddr_0_s1_address :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal altmemddr_0_s1_beginbursttransfer :  STD_LOGIC;
                signal altmemddr_0_s1_burstcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal altmemddr_0_s1_byteenable :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altmemddr_0_s1_read :  STD_LOGIC;
                signal altmemddr_0_s1_readdata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal altmemddr_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal altmemddr_0_s1_readdatavalid :  STD_LOGIC;
                signal altmemddr_0_s1_resetrequest_n :  STD_LOGIC;
                signal altmemddr_0_s1_resetrequest_n_from_sa :  STD_LOGIC;
                signal altmemddr_0_s1_waitrequest_n :  STD_LOGIC;
                signal altmemddr_0_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal altmemddr_0_s1_write :  STD_LOGIC;
                signal altmemddr_0_s1_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal clk_24M_reset_n :  STD_LOGIC;
                signal d1_altmemddr_0_s1_end_xfer :  STD_LOGIC;
                signal d1_vip_sopc_burst_0_upstream_end_xfer :  STD_LOGIC;
                signal d1_vip_sopc_burst_1_upstream_end_xfer :  STD_LOGIC;
                signal internal_altmemddr_0_phy_clk_out :  STD_LOGIC;
                signal internal_aux_scan_clk_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_aux_scan_clk_reset_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_dll_reference_clk_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_dqs_delay_ctrl_export_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal internal_local_init_done_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_local_refresh_ack_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_local_wdata_req_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_addr_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_mem_ba_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal internal_mem_cas_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_cke_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_cs_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_dm_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_mem_odt_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_ras_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_reset_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_mem_we_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_overflow_from_the_alt_vip_cti_0 :  STD_LOGIC;
                signal internal_reset_phy_clk_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal internal_underflow_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal internal_vid_data_from_the_alt_vip_itc_0 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal internal_vid_datavalid_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal internal_vid_f_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal internal_vid_h_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal internal_vid_h_sync_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal internal_vid_v_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal internal_vid_v_sync_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal module_input16 :  STD_LOGIC;
                signal module_input17 :  STD_LOGIC;
                signal module_input9 :  STD_LOGIC;
                signal out_clk_altmemddr_0_aux_full_rate_clk :  STD_LOGIC;
                signal out_clk_altmemddr_0_aux_half_rate_clk :  STD_LOGIC;
                signal out_clk_altmemddr_0_phy_clk :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal vip_clk_reset_n :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_address :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_address_to_slave :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_arbitrationshare :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_burstcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_byteenable :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_debugaccess :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_latency_counter :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_nativeaddress :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_read :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_readdata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_0_downstream_readdatavalid :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_reset_n :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_waitrequest :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_write :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_address :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_byteaddress :  STD_LOGIC_VECTOR (33 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_byteenable :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_debugaccess :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_read :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_readdata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_readdata_from_sa :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_readdatavalid :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_readdatavalid_from_sa :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_waitrequest :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_waitrequest_from_sa :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_write :  STD_LOGIC;
                signal vip_sopc_burst_0_upstream_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_address :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_address_to_slave :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_arbitrationshare :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_burstcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_byteenable :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_debugaccess :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_latency_counter :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_nativeaddress :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_read :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_readdata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_1_downstream_readdatavalid :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_reset_n :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_waitrequest :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_write :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_address :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_burstcount :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_byteaddress :  STD_LOGIC_VECTOR (33 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_byteenable :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_debugaccess :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_read :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_readdata :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_readdata_from_sa :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_readdatavalid :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_waitrequest :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_waitrequest_from_sa :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_write :  STD_LOGIC;
                signal vip_sopc_burst_1_upstream_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);

begin

  --the_alt_vip_cti_0_dout, which is an e_instance
  the_alt_vip_cti_0_dout : alt_vip_cti_0_dout_arbitrator
    port map(
      alt_vip_cti_0_dout_ready => alt_vip_cti_0_dout_ready,
      alt_vip_cti_0_dout_reset => alt_vip_cti_0_dout_reset,
      alt_vip_cti_0_dout_data => alt_vip_cti_0_dout_data,
      alt_vip_cti_0_dout_endofpacket => alt_vip_cti_0_dout_endofpacket,
      alt_vip_cti_0_dout_startofpacket => alt_vip_cti_0_dout_startofpacket,
      alt_vip_cti_0_dout_valid => alt_vip_cti_0_dout_valid,
      alt_vip_scl_0_din_ready_from_sa => alt_vip_scl_0_din_ready_from_sa,
      clk => vip_clk,
      reset_n => vip_clk_reset_n
    );


  --the_alt_vip_cti_0, which is an e_ptf_instance
  the_alt_vip_cti_0 : alt_vip_cti_0
    port map(
      is_data => alt_vip_cti_0_dout_data,
      is_eop => alt_vip_cti_0_dout_endofpacket,
      is_sop => alt_vip_cti_0_dout_startofpacket,
      is_valid => alt_vip_cti_0_dout_valid,
      overflow => internal_overflow_from_the_alt_vip_cti_0,
      is_clk => vip_clk,
      is_ready => alt_vip_cti_0_dout_ready,
      rst => alt_vip_cti_0_dout_reset,
      vid_clk => vid_clk_to_the_alt_vip_cti_0,
      vid_data => vid_data_to_the_alt_vip_cti_0,
      vid_datavalid => vid_datavalid_to_the_alt_vip_cti_0,
      vid_f => vid_f_to_the_alt_vip_cti_0,
      vid_h_sync => vid_h_sync_to_the_alt_vip_cti_0,
      vid_locked => vid_locked_to_the_alt_vip_cti_0,
      vid_v_sync => vid_v_sync_to_the_alt_vip_cti_0
    );


  --the_alt_vip_itc_0_din, which is an e_instance
  the_alt_vip_itc_0_din : alt_vip_itc_0_din_arbitrator
    port map(
      alt_vip_itc_0_din_data => alt_vip_itc_0_din_data,
      alt_vip_itc_0_din_endofpacket => alt_vip_itc_0_din_endofpacket,
      alt_vip_itc_0_din_ready_from_sa => alt_vip_itc_0_din_ready_from_sa,
      alt_vip_itc_0_din_reset => alt_vip_itc_0_din_reset,
      alt_vip_itc_0_din_startofpacket => alt_vip_itc_0_din_startofpacket,
      alt_vip_itc_0_din_valid => alt_vip_itc_0_din_valid,
      alt_vip_itc_0_din_ready => alt_vip_itc_0_din_ready,
      alt_vip_vfb_0_dout_data => alt_vip_vfb_0_dout_data,
      alt_vip_vfb_0_dout_endofpacket => alt_vip_vfb_0_dout_endofpacket,
      alt_vip_vfb_0_dout_startofpacket => alt_vip_vfb_0_dout_startofpacket,
      alt_vip_vfb_0_dout_valid => alt_vip_vfb_0_dout_valid,
      clk => vip_clk,
      reset_n => vip_clk_reset_n
    );


  --the_alt_vip_itc_0, which is an e_ptf_instance
  the_alt_vip_itc_0 : alt_vip_itc_0
    port map(
      is_ready => alt_vip_itc_0_din_ready,
      underflow => internal_underflow_from_the_alt_vip_itc_0,
      vid_data => internal_vid_data_from_the_alt_vip_itc_0,
      vid_datavalid => internal_vid_datavalid_from_the_alt_vip_itc_0,
      vid_f => internal_vid_f_from_the_alt_vip_itc_0,
      vid_h => internal_vid_h_from_the_alt_vip_itc_0,
      vid_h_sync => internal_vid_h_sync_from_the_alt_vip_itc_0,
      vid_v => internal_vid_v_from_the_alt_vip_itc_0,
      vid_v_sync => internal_vid_v_sync_from_the_alt_vip_itc_0,
      is_clk => vip_clk,
      is_data => alt_vip_itc_0_din_data,
      is_eop => alt_vip_itc_0_din_endofpacket,
      is_sop => alt_vip_itc_0_din_startofpacket,
      is_valid => alt_vip_itc_0_din_valid,
      rst => alt_vip_itc_0_din_reset,
      vid_clk => vid_clk_to_the_alt_vip_itc_0
    );


  --the_alt_vip_scl_0_din, which is an e_instance
  the_alt_vip_scl_0_din : alt_vip_scl_0_din_arbitrator
    port map(
      alt_vip_scl_0_din_data => alt_vip_scl_0_din_data,
      alt_vip_scl_0_din_endofpacket => alt_vip_scl_0_din_endofpacket,
      alt_vip_scl_0_din_ready_from_sa => alt_vip_scl_0_din_ready_from_sa,
      alt_vip_scl_0_din_reset => alt_vip_scl_0_din_reset,
      alt_vip_scl_0_din_startofpacket => alt_vip_scl_0_din_startofpacket,
      alt_vip_scl_0_din_valid => alt_vip_scl_0_din_valid,
      alt_vip_cti_0_dout_data => alt_vip_cti_0_dout_data,
      alt_vip_cti_0_dout_endofpacket => alt_vip_cti_0_dout_endofpacket,
      alt_vip_cti_0_dout_startofpacket => alt_vip_cti_0_dout_startofpacket,
      alt_vip_cti_0_dout_valid => alt_vip_cti_0_dout_valid,
      alt_vip_scl_0_din_ready => alt_vip_scl_0_din_ready,
      clk => vip_clk,
      reset_n => vip_clk_reset_n
    );


  --the_alt_vip_scl_0_dout, which is an e_instance
  the_alt_vip_scl_0_dout : alt_vip_scl_0_dout_arbitrator
    port map(
      alt_vip_scl_0_dout_ready => alt_vip_scl_0_dout_ready,
      alt_vip_scl_0_dout_data => alt_vip_scl_0_dout_data,
      alt_vip_scl_0_dout_endofpacket => alt_vip_scl_0_dout_endofpacket,
      alt_vip_scl_0_dout_startofpacket => alt_vip_scl_0_dout_startofpacket,
      alt_vip_scl_0_dout_valid => alt_vip_scl_0_dout_valid,
      alt_vip_vfb_0_din_ready_from_sa => alt_vip_vfb_0_din_ready_from_sa,
      clk => vip_clk,
      reset_n => vip_clk_reset_n
    );


  --the_alt_vip_scl_0, which is an e_ptf_instance
  the_alt_vip_scl_0 : alt_vip_scl_0
    port map(
      din_ready => alt_vip_scl_0_din_ready,
      dout_data => alt_vip_scl_0_dout_data,
      dout_endofpacket => alt_vip_scl_0_dout_endofpacket,
      dout_startofpacket => alt_vip_scl_0_dout_startofpacket,
      dout_valid => alt_vip_scl_0_dout_valid,
      clock => vip_clk,
      din_data => alt_vip_scl_0_din_data,
      din_endofpacket => alt_vip_scl_0_din_endofpacket,
      din_startofpacket => alt_vip_scl_0_din_startofpacket,
      din_valid => alt_vip_scl_0_din_valid,
      dout_ready => alt_vip_scl_0_dout_ready,
      reset => alt_vip_scl_0_din_reset
    );


  --the_alt_vip_vfb_0_din, which is an e_instance
  the_alt_vip_vfb_0_din : alt_vip_vfb_0_din_arbitrator
    port map(
      alt_vip_vfb_0_din_data => alt_vip_vfb_0_din_data,
      alt_vip_vfb_0_din_endofpacket => alt_vip_vfb_0_din_endofpacket,
      alt_vip_vfb_0_din_ready_from_sa => alt_vip_vfb_0_din_ready_from_sa,
      alt_vip_vfb_0_din_reset => alt_vip_vfb_0_din_reset,
      alt_vip_vfb_0_din_startofpacket => alt_vip_vfb_0_din_startofpacket,
      alt_vip_vfb_0_din_valid => alt_vip_vfb_0_din_valid,
      alt_vip_scl_0_dout_data => alt_vip_scl_0_dout_data,
      alt_vip_scl_0_dout_endofpacket => alt_vip_scl_0_dout_endofpacket,
      alt_vip_scl_0_dout_startofpacket => alt_vip_scl_0_dout_startofpacket,
      alt_vip_scl_0_dout_valid => alt_vip_scl_0_dout_valid,
      alt_vip_vfb_0_din_ready => alt_vip_vfb_0_din_ready,
      clk => vip_clk,
      reset_n => vip_clk_reset_n
    );


  --the_alt_vip_vfb_0_dout, which is an e_instance
  the_alt_vip_vfb_0_dout : alt_vip_vfb_0_dout_arbitrator
    port map(
      alt_vip_vfb_0_dout_ready => alt_vip_vfb_0_dout_ready,
      alt_vip_itc_0_din_ready_from_sa => alt_vip_itc_0_din_ready_from_sa,
      alt_vip_vfb_0_dout_data => alt_vip_vfb_0_dout_data,
      alt_vip_vfb_0_dout_endofpacket => alt_vip_vfb_0_dout_endofpacket,
      alt_vip_vfb_0_dout_startofpacket => alt_vip_vfb_0_dout_startofpacket,
      alt_vip_vfb_0_dout_valid => alt_vip_vfb_0_dout_valid,
      clk => vip_clk,
      reset_n => vip_clk_reset_n
    );


  --the_alt_vip_vfb_0_read_master, which is an e_instance
  the_alt_vip_vfb_0_read_master : alt_vip_vfb_0_read_master_arbitrator
    port map(
      alt_vip_vfb_0_read_master_address_to_slave => alt_vip_vfb_0_read_master_address_to_slave,
      alt_vip_vfb_0_read_master_latency_counter => alt_vip_vfb_0_read_master_latency_counter,
      alt_vip_vfb_0_read_master_readdata => alt_vip_vfb_0_read_master_readdata,
      alt_vip_vfb_0_read_master_readdatavalid => alt_vip_vfb_0_read_master_readdatavalid,
      alt_vip_vfb_0_read_master_reset => alt_vip_vfb_0_read_master_reset,
      alt_vip_vfb_0_read_master_waitrequest => alt_vip_vfb_0_read_master_waitrequest,
      alt_vip_vfb_0_read_master_address => alt_vip_vfb_0_read_master_address,
      alt_vip_vfb_0_read_master_burstcount => alt_vip_vfb_0_read_master_burstcount,
      alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream,
      alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream,
      alt_vip_vfb_0_read_master_read => alt_vip_vfb_0_read_master_read,
      alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream,
      alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register => alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register,
      alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream,
      clk => internal_altmemddr_0_phy_clk_out,
      d1_vip_sopc_burst_1_upstream_end_xfer => d1_vip_sopc_burst_1_upstream_end_xfer,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_1_upstream_readdata_from_sa => vip_sopc_burst_1_upstream_readdata_from_sa,
      vip_sopc_burst_1_upstream_waitrequest_from_sa => vip_sopc_burst_1_upstream_waitrequest_from_sa
    );


  --the_alt_vip_vfb_0_write_master, which is an e_instance
  the_alt_vip_vfb_0_write_master : alt_vip_vfb_0_write_master_arbitrator
    port map(
      alt_vip_vfb_0_write_master_address_to_slave => alt_vip_vfb_0_write_master_address_to_slave,
      alt_vip_vfb_0_write_master_reset => alt_vip_vfb_0_write_master_reset,
      alt_vip_vfb_0_write_master_waitrequest => alt_vip_vfb_0_write_master_waitrequest,
      alt_vip_vfb_0_write_master_address => alt_vip_vfb_0_write_master_address,
      alt_vip_vfb_0_write_master_burstcount => alt_vip_vfb_0_write_master_burstcount,
      alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream => alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream,
      alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream => alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream,
      alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream => alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream,
      alt_vip_vfb_0_write_master_write => alt_vip_vfb_0_write_master_write,
      alt_vip_vfb_0_write_master_writedata => alt_vip_vfb_0_write_master_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      d1_vip_sopc_burst_0_upstream_end_xfer => d1_vip_sopc_burst_0_upstream_end_xfer,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_0_upstream_waitrequest_from_sa => vip_sopc_burst_0_upstream_waitrequest_from_sa
    );


  --the_alt_vip_vfb_0, which is an e_ptf_instance
  the_alt_vip_vfb_0 : alt_vip_vfb_0
    port map(
      din_ready => alt_vip_vfb_0_din_ready,
      dout_data => alt_vip_vfb_0_dout_data,
      dout_endofpacket => alt_vip_vfb_0_dout_endofpacket,
      dout_startofpacket => alt_vip_vfb_0_dout_startofpacket,
      dout_valid => alt_vip_vfb_0_dout_valid,
      read_master_av_address => alt_vip_vfb_0_read_master_address,
      read_master_av_burstcount => alt_vip_vfb_0_read_master_burstcount,
      read_master_av_read => alt_vip_vfb_0_read_master_read,
      write_master_av_address => alt_vip_vfb_0_write_master_address,
      write_master_av_burstcount => alt_vip_vfb_0_write_master_burstcount,
      write_master_av_write => alt_vip_vfb_0_write_master_write,
      write_master_av_writedata => alt_vip_vfb_0_write_master_writedata,
      clock => vip_clk,
      din_data => alt_vip_vfb_0_din_data,
      din_endofpacket => alt_vip_vfb_0_din_endofpacket,
      din_startofpacket => alt_vip_vfb_0_din_startofpacket,
      din_valid => alt_vip_vfb_0_din_valid,
      dout_ready => alt_vip_vfb_0_dout_ready,
      read_master_av_clock => internal_altmemddr_0_phy_clk_out,
      read_master_av_readdata => alt_vip_vfb_0_read_master_readdata,
      read_master_av_readdatavalid => alt_vip_vfb_0_read_master_readdatavalid,
      read_master_av_reset => alt_vip_vfb_0_read_master_reset,
      read_master_av_waitrequest => alt_vip_vfb_0_read_master_waitrequest,
      reset => alt_vip_vfb_0_din_reset,
      write_master_av_clock => internal_altmemddr_0_phy_clk_out,
      write_master_av_reset => alt_vip_vfb_0_write_master_reset,
      write_master_av_waitrequest => alt_vip_vfb_0_write_master_waitrequest
    );


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
      d1_altmemddr_0_s1_end_xfer => d1_altmemddr_0_s1_end_xfer,
      vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 => vip_sopc_burst_0_downstream_granted_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 => vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 => vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register => vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register,
      vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 => vip_sopc_burst_0_downstream_requests_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 => vip_sopc_burst_1_downstream_granted_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 => vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 => vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register => vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register,
      vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 => vip_sopc_burst_1_downstream_requests_altmemddr_0_s1,
      altmemddr_0_s1_readdata => altmemddr_0_s1_readdata,
      altmemddr_0_s1_readdatavalid => altmemddr_0_s1_readdatavalid,
      altmemddr_0_s1_resetrequest_n => altmemddr_0_s1_resetrequest_n,
      altmemddr_0_s1_waitrequest_n => altmemddr_0_s1_waitrequest_n,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_0_downstream_address_to_slave => vip_sopc_burst_0_downstream_address_to_slave,
      vip_sopc_burst_0_downstream_arbitrationshare => vip_sopc_burst_0_downstream_arbitrationshare,
      vip_sopc_burst_0_downstream_burstcount => vip_sopc_burst_0_downstream_burstcount,
      vip_sopc_burst_0_downstream_byteenable => vip_sopc_burst_0_downstream_byteenable,
      vip_sopc_burst_0_downstream_latency_counter => vip_sopc_burst_0_downstream_latency_counter,
      vip_sopc_burst_0_downstream_read => vip_sopc_burst_0_downstream_read,
      vip_sopc_burst_0_downstream_write => vip_sopc_burst_0_downstream_write,
      vip_sopc_burst_0_downstream_writedata => vip_sopc_burst_0_downstream_writedata,
      vip_sopc_burst_1_downstream_address_to_slave => vip_sopc_burst_1_downstream_address_to_slave,
      vip_sopc_burst_1_downstream_arbitrationshare => vip_sopc_burst_1_downstream_arbitrationshare,
      vip_sopc_burst_1_downstream_burstcount => vip_sopc_burst_1_downstream_burstcount,
      vip_sopc_burst_1_downstream_byteenable => vip_sopc_burst_1_downstream_byteenable,
      vip_sopc_burst_1_downstream_latency_counter => vip_sopc_burst_1_downstream_latency_counter,
      vip_sopc_burst_1_downstream_read => vip_sopc_burst_1_downstream_read,
      vip_sopc_burst_1_downstream_write => vip_sopc_burst_1_downstream_write,
      vip_sopc_burst_1_downstream_writedata => vip_sopc_burst_1_downstream_writedata
    );


  --altmemddr_0_aux_full_rate_clk_out out_clk assignment, which is an e_assign
  altmemddr_0_aux_full_rate_clk_out <= out_clk_altmemddr_0_aux_full_rate_clk;
  --altmemddr_0_aux_half_rate_clk_out out_clk assignment, which is an e_assign
  altmemddr_0_aux_half_rate_clk_out <= out_clk_altmemddr_0_aux_half_rate_clk;
  --altmemddr_0_phy_clk_out out_clk assignment, which is an e_assign
  internal_altmemddr_0_phy_clk_out <= out_clk_altmemddr_0_phy_clk;
  --reset is asserted asynchronously and deasserted synchronously
  vip_sopc_reset_clk_24M_domain_synch : vip_sopc_reset_clk_24M_domain_synch_module
    port map(
      data_out => clk_24M_reset_n,
      clk => clk_24M,
      data_in => module_input9,
      reset_n => reset_n_sources
    );

  module_input9 <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT (((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT altmemddr_0_s1_resetrequest_n_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT altmemddr_0_s1_resetrequest_n_from_sa))))));
  --the_altmemddr_0, which is an e_ptf_instance
  the_altmemddr_0 : altmemddr_0
    port map(
      aux_full_rate_clk => out_clk_altmemddr_0_aux_full_rate_clk,
      aux_half_rate_clk => out_clk_altmemddr_0_aux_half_rate_clk,
      aux_scan_clk => internal_aux_scan_clk_from_the_altmemddr_0,
      aux_scan_clk_reset_n => internal_aux_scan_clk_reset_n_from_the_altmemddr_0,
      dll_reference_clk => internal_dll_reference_clk_from_the_altmemddr_0,
      dqs_delay_ctrl_export => internal_dqs_delay_ctrl_export_from_the_altmemddr_0,
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
      mem_dqsn => mem_dqsn_to_and_from_the_altmemddr_0,
      mem_odt(0) => internal_mem_odt_from_the_altmemddr_0,
      mem_ras_n => internal_mem_ras_n_from_the_altmemddr_0,
      mem_reset_n => internal_mem_reset_n_from_the_altmemddr_0,
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
      oct_ctl_rs_value => oct_ctl_rs_value_to_the_altmemddr_0,
      oct_ctl_rt_value => oct_ctl_rt_value_to_the_altmemddr_0,
      pll_ref_clk => clk_24M,
      soft_reset_n => clk_24M_reset_n
    );


  --the_vip_sopc_burst_0_upstream, which is an e_instance
  the_vip_sopc_burst_0_upstream : vip_sopc_burst_0_upstream_arbitrator
    port map(
      alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream => alt_vip_vfb_0_write_master_granted_vip_sopc_burst_0_upstream,
      alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream => alt_vip_vfb_0_write_master_qualified_request_vip_sopc_burst_0_upstream,
      alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream => alt_vip_vfb_0_write_master_requests_vip_sopc_burst_0_upstream,
      d1_vip_sopc_burst_0_upstream_end_xfer => d1_vip_sopc_burst_0_upstream_end_xfer,
      vip_sopc_burst_0_upstream_address => vip_sopc_burst_0_upstream_address,
      vip_sopc_burst_0_upstream_burstcount => vip_sopc_burst_0_upstream_burstcount,
      vip_sopc_burst_0_upstream_byteaddress => vip_sopc_burst_0_upstream_byteaddress,
      vip_sopc_burst_0_upstream_byteenable => vip_sopc_burst_0_upstream_byteenable,
      vip_sopc_burst_0_upstream_debugaccess => vip_sopc_burst_0_upstream_debugaccess,
      vip_sopc_burst_0_upstream_read => vip_sopc_burst_0_upstream_read,
      vip_sopc_burst_0_upstream_readdata_from_sa => vip_sopc_burst_0_upstream_readdata_from_sa,
      vip_sopc_burst_0_upstream_readdatavalid_from_sa => vip_sopc_burst_0_upstream_readdatavalid_from_sa,
      vip_sopc_burst_0_upstream_waitrequest_from_sa => vip_sopc_burst_0_upstream_waitrequest_from_sa,
      vip_sopc_burst_0_upstream_write => vip_sopc_burst_0_upstream_write,
      vip_sopc_burst_0_upstream_writedata => vip_sopc_burst_0_upstream_writedata,
      alt_vip_vfb_0_write_master_address_to_slave => alt_vip_vfb_0_write_master_address_to_slave,
      alt_vip_vfb_0_write_master_burstcount => alt_vip_vfb_0_write_master_burstcount,
      alt_vip_vfb_0_write_master_write => alt_vip_vfb_0_write_master_write,
      alt_vip_vfb_0_write_master_writedata => alt_vip_vfb_0_write_master_writedata,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_0_upstream_readdata => vip_sopc_burst_0_upstream_readdata,
      vip_sopc_burst_0_upstream_readdatavalid => vip_sopc_burst_0_upstream_readdatavalid,
      vip_sopc_burst_0_upstream_waitrequest => vip_sopc_burst_0_upstream_waitrequest
    );


  --the_vip_sopc_burst_0_downstream, which is an e_instance
  the_vip_sopc_burst_0_downstream : vip_sopc_burst_0_downstream_arbitrator
    port map(
      vip_sopc_burst_0_downstream_address_to_slave => vip_sopc_burst_0_downstream_address_to_slave,
      vip_sopc_burst_0_downstream_latency_counter => vip_sopc_burst_0_downstream_latency_counter,
      vip_sopc_burst_0_downstream_readdata => vip_sopc_burst_0_downstream_readdata,
      vip_sopc_burst_0_downstream_readdatavalid => vip_sopc_burst_0_downstream_readdatavalid,
      vip_sopc_burst_0_downstream_reset_n => vip_sopc_burst_0_downstream_reset_n,
      vip_sopc_burst_0_downstream_waitrequest => vip_sopc_burst_0_downstream_waitrequest,
      altmemddr_0_s1_readdata_from_sa => altmemddr_0_s1_readdata_from_sa,
      altmemddr_0_s1_waitrequest_n_from_sa => altmemddr_0_s1_waitrequest_n_from_sa,
      clk => internal_altmemddr_0_phy_clk_out,
      d1_altmemddr_0_s1_end_xfer => d1_altmemddr_0_s1_end_xfer,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_0_downstream_address => vip_sopc_burst_0_downstream_address,
      vip_sopc_burst_0_downstream_burstcount => vip_sopc_burst_0_downstream_burstcount,
      vip_sopc_burst_0_downstream_byteenable => vip_sopc_burst_0_downstream_byteenable,
      vip_sopc_burst_0_downstream_granted_altmemddr_0_s1 => vip_sopc_burst_0_downstream_granted_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1 => vip_sopc_burst_0_downstream_qualified_request_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_read => vip_sopc_burst_0_downstream_read,
      vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1 => vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register => vip_sopc_burst_0_downstream_read_data_valid_altmemddr_0_s1_shift_register,
      vip_sopc_burst_0_downstream_requests_altmemddr_0_s1 => vip_sopc_burst_0_downstream_requests_altmemddr_0_s1,
      vip_sopc_burst_0_downstream_write => vip_sopc_burst_0_downstream_write,
      vip_sopc_burst_0_downstream_writedata => vip_sopc_burst_0_downstream_writedata
    );


  --the_vip_sopc_burst_0, which is an e_ptf_instance
  the_vip_sopc_burst_0 : vip_sopc_burst_0
    port map(
      downstream_address => vip_sopc_burst_0_downstream_address,
      downstream_arbitrationshare => vip_sopc_burst_0_downstream_arbitrationshare,
      downstream_burstcount => vip_sopc_burst_0_downstream_burstcount,
      downstream_byteenable => vip_sopc_burst_0_downstream_byteenable,
      downstream_debugaccess => vip_sopc_burst_0_downstream_debugaccess,
      downstream_nativeaddress => vip_sopc_burst_0_downstream_nativeaddress,
      downstream_read => vip_sopc_burst_0_downstream_read,
      downstream_write => vip_sopc_burst_0_downstream_write,
      downstream_writedata => vip_sopc_burst_0_downstream_writedata,
      upstream_readdata => vip_sopc_burst_0_upstream_readdata,
      upstream_readdatavalid => vip_sopc_burst_0_upstream_readdatavalid,
      upstream_waitrequest => vip_sopc_burst_0_upstream_waitrequest,
      clk => internal_altmemddr_0_phy_clk_out,
      downstream_readdata => vip_sopc_burst_0_downstream_readdata,
      downstream_readdatavalid => vip_sopc_burst_0_downstream_readdatavalid,
      downstream_waitrequest => vip_sopc_burst_0_downstream_waitrequest,
      reset_n => vip_sopc_burst_0_downstream_reset_n,
      upstream_address => vip_sopc_burst_0_upstream_byteaddress,
      upstream_burstcount => vip_sopc_burst_0_upstream_burstcount,
      upstream_byteenable => vip_sopc_burst_0_upstream_byteenable,
      upstream_debugaccess => vip_sopc_burst_0_upstream_debugaccess,
      upstream_nativeaddress => vip_sopc_burst_0_upstream_address,
      upstream_read => vip_sopc_burst_0_upstream_read,
      upstream_write => vip_sopc_burst_0_upstream_write,
      upstream_writedata => vip_sopc_burst_0_upstream_writedata
    );


  --the_vip_sopc_burst_1_upstream, which is an e_instance
  the_vip_sopc_burst_1_upstream : vip_sopc_burst_1_upstream_arbitrator
    port map(
      alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_granted_vip_sopc_burst_1_upstream,
      alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_qualified_request_vip_sopc_burst_1_upstream,
      alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream,
      alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register => alt_vip_vfb_0_read_master_read_data_valid_vip_sopc_burst_1_upstream_shift_register,
      alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream => alt_vip_vfb_0_read_master_requests_vip_sopc_burst_1_upstream,
      d1_vip_sopc_burst_1_upstream_end_xfer => d1_vip_sopc_burst_1_upstream_end_xfer,
      vip_sopc_burst_1_upstream_address => vip_sopc_burst_1_upstream_address,
      vip_sopc_burst_1_upstream_burstcount => vip_sopc_burst_1_upstream_burstcount,
      vip_sopc_burst_1_upstream_byteaddress => vip_sopc_burst_1_upstream_byteaddress,
      vip_sopc_burst_1_upstream_byteenable => vip_sopc_burst_1_upstream_byteenable,
      vip_sopc_burst_1_upstream_debugaccess => vip_sopc_burst_1_upstream_debugaccess,
      vip_sopc_burst_1_upstream_read => vip_sopc_burst_1_upstream_read,
      vip_sopc_burst_1_upstream_readdata_from_sa => vip_sopc_burst_1_upstream_readdata_from_sa,
      vip_sopc_burst_1_upstream_waitrequest_from_sa => vip_sopc_burst_1_upstream_waitrequest_from_sa,
      vip_sopc_burst_1_upstream_write => vip_sopc_burst_1_upstream_write,
      alt_vip_vfb_0_read_master_address_to_slave => alt_vip_vfb_0_read_master_address_to_slave,
      alt_vip_vfb_0_read_master_burstcount => alt_vip_vfb_0_read_master_burstcount,
      alt_vip_vfb_0_read_master_latency_counter => alt_vip_vfb_0_read_master_latency_counter,
      alt_vip_vfb_0_read_master_read => alt_vip_vfb_0_read_master_read,
      clk => internal_altmemddr_0_phy_clk_out,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_1_upstream_readdata => vip_sopc_burst_1_upstream_readdata,
      vip_sopc_burst_1_upstream_readdatavalid => vip_sopc_burst_1_upstream_readdatavalid,
      vip_sopc_burst_1_upstream_waitrequest => vip_sopc_burst_1_upstream_waitrequest
    );


  --the_vip_sopc_burst_1_downstream, which is an e_instance
  the_vip_sopc_burst_1_downstream : vip_sopc_burst_1_downstream_arbitrator
    port map(
      vip_sopc_burst_1_downstream_address_to_slave => vip_sopc_burst_1_downstream_address_to_slave,
      vip_sopc_burst_1_downstream_latency_counter => vip_sopc_burst_1_downstream_latency_counter,
      vip_sopc_burst_1_downstream_readdata => vip_sopc_burst_1_downstream_readdata,
      vip_sopc_burst_1_downstream_readdatavalid => vip_sopc_burst_1_downstream_readdatavalid,
      vip_sopc_burst_1_downstream_reset_n => vip_sopc_burst_1_downstream_reset_n,
      vip_sopc_burst_1_downstream_waitrequest => vip_sopc_burst_1_downstream_waitrequest,
      altmemddr_0_s1_readdata_from_sa => altmemddr_0_s1_readdata_from_sa,
      altmemddr_0_s1_waitrequest_n_from_sa => altmemddr_0_s1_waitrequest_n_from_sa,
      clk => internal_altmemddr_0_phy_clk_out,
      d1_altmemddr_0_s1_end_xfer => d1_altmemddr_0_s1_end_xfer,
      reset_n => altmemddr_0_phy_clk_out_reset_n,
      vip_sopc_burst_1_downstream_address => vip_sopc_burst_1_downstream_address,
      vip_sopc_burst_1_downstream_burstcount => vip_sopc_burst_1_downstream_burstcount,
      vip_sopc_burst_1_downstream_byteenable => vip_sopc_burst_1_downstream_byteenable,
      vip_sopc_burst_1_downstream_granted_altmemddr_0_s1 => vip_sopc_burst_1_downstream_granted_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1 => vip_sopc_burst_1_downstream_qualified_request_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_read => vip_sopc_burst_1_downstream_read,
      vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1 => vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register => vip_sopc_burst_1_downstream_read_data_valid_altmemddr_0_s1_shift_register,
      vip_sopc_burst_1_downstream_requests_altmemddr_0_s1 => vip_sopc_burst_1_downstream_requests_altmemddr_0_s1,
      vip_sopc_burst_1_downstream_write => vip_sopc_burst_1_downstream_write,
      vip_sopc_burst_1_downstream_writedata => vip_sopc_burst_1_downstream_writedata
    );


  --the_vip_sopc_burst_1, which is an e_ptf_instance
  the_vip_sopc_burst_1 : vip_sopc_burst_1
    port map(
      downstream_address => vip_sopc_burst_1_downstream_address,
      downstream_arbitrationshare => vip_sopc_burst_1_downstream_arbitrationshare,
      downstream_burstcount => vip_sopc_burst_1_downstream_burstcount,
      downstream_byteenable => vip_sopc_burst_1_downstream_byteenable,
      downstream_debugaccess => vip_sopc_burst_1_downstream_debugaccess,
      downstream_nativeaddress => vip_sopc_burst_1_downstream_nativeaddress,
      downstream_read => vip_sopc_burst_1_downstream_read,
      downstream_write => vip_sopc_burst_1_downstream_write,
      downstream_writedata => vip_sopc_burst_1_downstream_writedata,
      upstream_readdata => vip_sopc_burst_1_upstream_readdata,
      upstream_readdatavalid => vip_sopc_burst_1_upstream_readdatavalid,
      upstream_waitrequest => vip_sopc_burst_1_upstream_waitrequest,
      clk => internal_altmemddr_0_phy_clk_out,
      downstream_readdata => vip_sopc_burst_1_downstream_readdata,
      downstream_readdatavalid => vip_sopc_burst_1_downstream_readdatavalid,
      downstream_waitrequest => vip_sopc_burst_1_downstream_waitrequest,
      reset_n => vip_sopc_burst_1_downstream_reset_n,
      upstream_address => vip_sopc_burst_1_upstream_byteaddress,
      upstream_burstcount => vip_sopc_burst_1_upstream_burstcount,
      upstream_byteenable => vip_sopc_burst_1_upstream_byteenable,
      upstream_debugaccess => vip_sopc_burst_1_upstream_debugaccess,
      upstream_nativeaddress => vip_sopc_burst_1_upstream_address,
      upstream_read => vip_sopc_burst_1_upstream_read,
      upstream_write => vip_sopc_burst_1_upstream_write,
      upstream_writedata => vip_sopc_burst_1_upstream_writedata
    );


  --reset is asserted asynchronously and deasserted synchronously
  vip_sopc_reset_vip_clk_domain_synch : vip_sopc_reset_vip_clk_domain_synch_module
    port map(
      data_out => vip_clk_reset_n,
      clk => vip_clk,
      data_in => module_input16,
      reset_n => reset_n_sources
    );

  module_input16 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch : vip_sopc_reset_altmemddr_0_phy_clk_out_domain_synch_module
    port map(
      data_out => altmemddr_0_phy_clk_out_reset_n,
      clk => internal_altmemddr_0_phy_clk_out,
      data_in => module_input17,
      reset_n => reset_n_sources
    );

  module_input17 <= std_logic'('1');

  --vip_sopc_burst_1_upstream_writedata of type writedata does not connect to anything so wire it to default (0)
  vip_sopc_burst_1_upstream_writedata <= std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
  --vhdl renameroo for output signals
  altmemddr_0_phy_clk_out <= internal_altmemddr_0_phy_clk_out;
  --vhdl renameroo for output signals
  aux_scan_clk_from_the_altmemddr_0 <= internal_aux_scan_clk_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  aux_scan_clk_reset_n_from_the_altmemddr_0 <= internal_aux_scan_clk_reset_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  dll_reference_clk_from_the_altmemddr_0 <= internal_dll_reference_clk_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  dqs_delay_ctrl_export_from_the_altmemddr_0 <= internal_dqs_delay_ctrl_export_from_the_altmemddr_0;
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
  mem_reset_n_from_the_altmemddr_0 <= internal_mem_reset_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  mem_we_n_from_the_altmemddr_0 <= internal_mem_we_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  overflow_from_the_alt_vip_cti_0 <= internal_overflow_from_the_alt_vip_cti_0;
  --vhdl renameroo for output signals
  reset_phy_clk_n_from_the_altmemddr_0 <= internal_reset_phy_clk_n_from_the_altmemddr_0;
  --vhdl renameroo for output signals
  underflow_from_the_alt_vip_itc_0 <= internal_underflow_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_data_from_the_alt_vip_itc_0 <= internal_vid_data_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_datavalid_from_the_alt_vip_itc_0 <= internal_vid_datavalid_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_f_from_the_alt_vip_itc_0 <= internal_vid_f_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_h_from_the_alt_vip_itc_0 <= internal_vid_h_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_h_sync_from_the_alt_vip_itc_0 <= internal_vid_h_sync_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_v_from_the_alt_vip_itc_0 <= internal_vid_v_from_the_alt_vip_itc_0;
  --vhdl renameroo for output signals
  vid_v_sync_from_the_alt_vip_itc_0 <= internal_vid_v_sync_from_the_alt_vip_itc_0;

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
component vip_sopc is 
           port (
                 -- 1) global signals:
                    signal altmemddr_0_aux_full_rate_clk_out : OUT STD_LOGIC;
                    signal altmemddr_0_aux_half_rate_clk_out : OUT STD_LOGIC;
                    signal altmemddr_0_phy_clk_out : OUT STD_LOGIC;
                    signal clk_24M : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal vip_clk : IN STD_LOGIC;

                 -- the_alt_vip_cti_0
                    signal overflow_from_the_alt_vip_cti_0 : OUT STD_LOGIC;
                    signal vid_clk_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                    signal vid_data_to_the_alt_vip_cti_0 : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal vid_datavalid_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                    signal vid_f_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                    signal vid_h_sync_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                    signal vid_locked_to_the_alt_vip_cti_0 : IN STD_LOGIC;
                    signal vid_v_sync_to_the_alt_vip_cti_0 : IN STD_LOGIC;

                 -- the_alt_vip_itc_0
                    signal underflow_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                    signal vid_clk_to_the_alt_vip_itc_0 : IN STD_LOGIC;
                    signal vid_data_from_the_alt_vip_itc_0 : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal vid_datavalid_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                    signal vid_f_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                    signal vid_h_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                    signal vid_h_sync_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                    signal vid_v_from_the_alt_vip_itc_0 : OUT STD_LOGIC;
                    signal vid_v_sync_from_the_alt_vip_itc_0 : OUT STD_LOGIC;

                 -- the_altmemddr_0
                    signal aux_scan_clk_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal aux_scan_clk_reset_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal dll_reference_clk_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal dqs_delay_ctrl_export_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal global_reset_n_to_the_altmemddr_0 : IN STD_LOGIC;
                    signal local_init_done_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal local_refresh_ack_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal local_wdata_req_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_addr_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal mem_cas_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_cke_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_clk_n_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                    signal mem_clk_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC;
                    signal mem_cs_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_dm_from_the_altmemddr_0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dq_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                    signal mem_dqs_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dqsn_to_and_from_the_altmemddr_0 : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_odt_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_ras_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_reset_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal mem_we_n_from_the_altmemddr_0 : OUT STD_LOGIC;
                    signal oct_ctl_rs_value_to_the_altmemddr_0 : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal oct_ctl_rt_value_to_the_altmemddr_0 : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal reset_phy_clk_n_from_the_altmemddr_0 : OUT STD_LOGIC
                 );
end component vip_sopc;

                signal altmemddr_0_aux_full_rate_clk_out :  STD_LOGIC;
                signal altmemddr_0_aux_half_rate_clk_out :  STD_LOGIC;
                signal altmemddr_0_phy_clk_out :  STD_LOGIC;
                signal aux_scan_clk_from_the_altmemddr_0 :  STD_LOGIC;
                signal aux_scan_clk_reset_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal clk :  STD_LOGIC;
                signal clk_24M :  STD_LOGIC;
                signal dll_reference_clk_from_the_altmemddr_0 :  STD_LOGIC;
                signal dqs_delay_ctrl_export_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal global_reset_n_to_the_altmemddr_0 :  STD_LOGIC;
                signal local_init_done_from_the_altmemddr_0 :  STD_LOGIC;
                signal local_refresh_ack_from_the_altmemddr_0 :  STD_LOGIC;
                signal local_wdata_req_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_addr_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal mem_ba_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal mem_cas_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_cke_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_clk_n_to_and_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_clk_to_and_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_cs_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_dm_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal mem_dq_to_and_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal mem_dqs_to_and_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal mem_dqsn_to_and_from_the_altmemddr_0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal mem_odt_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_ras_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_reset_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal mem_we_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal oct_ctl_rs_value_to_the_altmemddr_0 :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal oct_ctl_rt_value_to_the_altmemddr_0 :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal overflow_from_the_alt_vip_cti_0 :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;
                signal reset_phy_clk_n_from_the_altmemddr_0 :  STD_LOGIC;
                signal underflow_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_clk_to_the_alt_vip_cti_0 :  STD_LOGIC;
                signal vid_clk_to_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_data_from_the_alt_vip_itc_0 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal vid_data_to_the_alt_vip_cti_0 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal vid_datavalid_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_datavalid_to_the_alt_vip_cti_0 :  STD_LOGIC;
                signal vid_f_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_f_to_the_alt_vip_cti_0 :  STD_LOGIC;
                signal vid_h_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_h_sync_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_h_sync_to_the_alt_vip_cti_0 :  STD_LOGIC;
                signal vid_locked_to_the_alt_vip_cti_0 :  STD_LOGIC;
                signal vid_v_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_v_sync_from_the_alt_vip_itc_0 :  STD_LOGIC;
                signal vid_v_sync_to_the_alt_vip_cti_0 :  STD_LOGIC;
                signal vip_clk :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_debugaccess :  STD_LOGIC;
                signal vip_sopc_burst_0_downstream_nativeaddress :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_readdata_from_sa :  STD_LOGIC_VECTOR (255 DOWNTO 0);
                signal vip_sopc_burst_0_upstream_readdatavalid_from_sa :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_debugaccess :  STD_LOGIC;
                signal vip_sopc_burst_1_downstream_nativeaddress :  STD_LOGIC_VECTOR (28 DOWNTO 0);
                signal vip_sopc_burst_1_upstream_writedata :  STD_LOGIC_VECTOR (255 DOWNTO 0);


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : vip_sopc
    port map(
      altmemddr_0_aux_full_rate_clk_out => altmemddr_0_aux_full_rate_clk_out,
      altmemddr_0_aux_half_rate_clk_out => altmemddr_0_aux_half_rate_clk_out,
      altmemddr_0_phy_clk_out => altmemddr_0_phy_clk_out,
      aux_scan_clk_from_the_altmemddr_0 => aux_scan_clk_from_the_altmemddr_0,
      aux_scan_clk_reset_n_from_the_altmemddr_0 => aux_scan_clk_reset_n_from_the_altmemddr_0,
      dll_reference_clk_from_the_altmemddr_0 => dll_reference_clk_from_the_altmemddr_0,
      dqs_delay_ctrl_export_from_the_altmemddr_0 => dqs_delay_ctrl_export_from_the_altmemddr_0,
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
      mem_dqsn_to_and_from_the_altmemddr_0 => mem_dqsn_to_and_from_the_altmemddr_0,
      mem_odt_from_the_altmemddr_0 => mem_odt_from_the_altmemddr_0,
      mem_ras_n_from_the_altmemddr_0 => mem_ras_n_from_the_altmemddr_0,
      mem_reset_n_from_the_altmemddr_0 => mem_reset_n_from_the_altmemddr_0,
      mem_we_n_from_the_altmemddr_0 => mem_we_n_from_the_altmemddr_0,
      overflow_from_the_alt_vip_cti_0 => overflow_from_the_alt_vip_cti_0,
      reset_phy_clk_n_from_the_altmemddr_0 => reset_phy_clk_n_from_the_altmemddr_0,
      underflow_from_the_alt_vip_itc_0 => underflow_from_the_alt_vip_itc_0,
      vid_data_from_the_alt_vip_itc_0 => vid_data_from_the_alt_vip_itc_0,
      vid_datavalid_from_the_alt_vip_itc_0 => vid_datavalid_from_the_alt_vip_itc_0,
      vid_f_from_the_alt_vip_itc_0 => vid_f_from_the_alt_vip_itc_0,
      vid_h_from_the_alt_vip_itc_0 => vid_h_from_the_alt_vip_itc_0,
      vid_h_sync_from_the_alt_vip_itc_0 => vid_h_sync_from_the_alt_vip_itc_0,
      vid_v_from_the_alt_vip_itc_0 => vid_v_from_the_alt_vip_itc_0,
      vid_v_sync_from_the_alt_vip_itc_0 => vid_v_sync_from_the_alt_vip_itc_0,
      clk_24M => clk_24M,
      global_reset_n_to_the_altmemddr_0 => global_reset_n_to_the_altmemddr_0,
      oct_ctl_rs_value_to_the_altmemddr_0 => oct_ctl_rs_value_to_the_altmemddr_0,
      oct_ctl_rt_value_to_the_altmemddr_0 => oct_ctl_rt_value_to_the_altmemddr_0,
      reset_n => reset_n,
      vid_clk_to_the_alt_vip_cti_0 => vid_clk_to_the_alt_vip_cti_0,
      vid_clk_to_the_alt_vip_itc_0 => vid_clk_to_the_alt_vip_itc_0,
      vid_data_to_the_alt_vip_cti_0 => vid_data_to_the_alt_vip_cti_0,
      vid_datavalid_to_the_alt_vip_cti_0 => vid_datavalid_to_the_alt_vip_cti_0,
      vid_f_to_the_alt_vip_cti_0 => vid_f_to_the_alt_vip_cti_0,
      vid_h_sync_to_the_alt_vip_cti_0 => vid_h_sync_to_the_alt_vip_cti_0,
      vid_locked_to_the_alt_vip_cti_0 => vid_locked_to_the_alt_vip_cti_0,
      vid_v_sync_to_the_alt_vip_cti_0 => vid_v_sync_to_the_alt_vip_cti_0,
      vip_clk => vip_clk
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
       wait for 85 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;
  process
  begin
    vip_clk <= '0';
    loop
       wait for 4 ns;
       vip_clk <= not vip_clk;
    end loop;
  end process;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
