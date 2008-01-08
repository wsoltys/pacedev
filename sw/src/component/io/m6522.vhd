--
-- A simulation model of VIC20 hardware
-- Copyright (c) MikeJ - March 2003
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email vic20@fpgaarcade.com
--
--
-- Revision list
--
-- version 001 initial release
-- not very sure about the shift register, documentation is a bit light.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity M6522 is
  port (

    RS              : in    std_logic_vector(3 downto 0);
    DATA_IN         : in    std_logic_vector(7 downto 0);
    DATA_OUT        : out   std_logic_vector(7 downto 0);
    DATA_OUT_OE_L   : out   std_logic;

    RW_L            : in    std_logic;
    CS1             : in    std_logic;
    CS2_L           : in    std_logic;

    IRQ_L           : out   std_logic; -- note, not open drain
    -- port a
    CA1_IN          : in    std_logic;
    CA2_IN          : in    std_logic;
    CA2_OUT         : out   std_logic;
    CA2_OUT_OE_L    : out   std_logic;

    PA_IN           : in    std_logic_vector(7 downto 0);
    PA_OUT          : out   std_logic_vector(7 downto 0);
    PA_OUT_OE_L     : out   std_logic_vector(7 downto 0);

    -- port b
    CB1_IN          : in    std_logic;
    CB1_OUT         : out   std_logic;
    CB1_OUT_OE_L    : out   std_logic;

    CB2_IN          : in    std_logic;
    CB2_OUT         : out   std_logic;
    CB2_OUT_OE_L    : out   std_logic;

    PB_IN           : in    std_logic_vector(7 downto 0);
    PB_OUT          : out   std_logic_vector(7 downto 0);
    PB_OUT_OE_L     : out   std_logic_vector(7 downto 0);

    RESET_L         : in    std_logic;
    P2_H            : in    std_logic; -- high for phase 2 clock  ____----__
    CLK_4           : in    std_logic  -- 4x system clock (4HZ)   _-_-_-_-_-
    );
end;

architecture RTL of M6522 is

  signal phase             : std_logic_vector(1 downto 0);
  signal p2_h_t1           : std_logic;
  signal cs                : std_logic;

  -- registers
  signal r_ddra            : std_logic_vector(7 downto 0);
  signal r_ora             : std_logic_vector(7 downto 0);
  signal r_ira             : std_logic_vector(7 downto 0);

  signal r_ddrb            : std_logic_vector(7 downto 0);
  signal r_orb             : std_logic_vector(7 downto 0);
  signal r_irb             : std_logic_vector(7 downto 0);

  signal r_t1l_l           : std_logic_vector(7 downto 0);
  signal r_t1l_h           : std_logic_vector(7 downto 0);
  signal r_t2l_l           : std_logic_vector(7 downto 0);
  signal r_t2l_h           : std_logic_vector(7 downto 0); -- not in real chip
  signal r_sr              : std_logic_vector(7 downto 0);
  signal r_acr             : std_logic_vector(7 downto 0);
  signal r_pcr             : std_logic_vector(7 downto 0);
  signal r_ifr             : std_logic_vector(7 downto 0);
  signal r_ier             : std_logic_vector(6 downto 0);

  signal sr_write_ena      : boolean;
  signal sr_read_ena       : boolean;
  signal ifr_write_ena     : boolean;
  signal ier_write_ena     : boolean;
  signal clear_irq         : std_logic_vector(7 downto 0);
  signal load_data         : std_logic_vector(7 downto 0);

  -- timer 1
  signal t1c               : std_logic_vector(15 downto 0);
  signal t1c_active        : boolean;
  signal t1c_done          : boolean;
  signal t1_w_reset_int    : boolean;
  signal t1_r_reset_int    : boolean;
  signal t1_load_counter   : boolean;
  signal t1_reload_counter : boolean;
  signal t1_toggle         : std_logic;
  signal t1_irq            : std_logic := '0';

  -- timer 2
  signal t2c               : std_logic_vector(15 downto 0);
  signal t2c_active        : boolean;
  signal t2c_done          : boolean;
  signal t2_pb6            : std_logic;
  signal t2_pb6_t1         : std_logic;
  signal t2_w_reset_int    : boolean;
  signal t2_r_reset_int    : boolean;
  signal t2_load_counter   : boolean;
  signal t2_reload_counter : boolean;
  signal t2_irq            : std_logic := '0';
  signal t2_sr_ena         : boolean;

  -- shift reg
  signal sr_cnt            : std_logic_vector(3 downto 0);
  signal sr_cb1_oe_l       : std_logic;
  signal sr_cb1_out        : std_logic;
  signal sr_drive_cb2      : std_logic;
  signal sr_strobe         : std_logic;
  signal sr_strobe_t1      : std_logic;
  signal sr_strobe_falling : boolean;
  signal sr_strobe_rising  : boolean;
  signal sr_irq            : std_logic;
  signal sr_out            : std_logic;
  signal sr_off_delay      : std_logic;

  -- io
  signal w_orb_hs          : std_logic;
  signal w_ora_hs          : std_logic;
  signal r_irb_hs          : std_logic;
  signal r_ira_hs          : std_logic;

  signal ca_hs_sr          : std_logic;
  signal ca_hs_pulse       : std_logic;
  signal cb_hs_sr          : std_logic;
  signal cb_hs_pulse       : std_logic;

  signal cb1_in_mux        : std_logic;
  signal ca1_ip_reg        : std_logic;
  signal cb1_ip_reg        : std_logic;
  signal ca1_int           : boolean;
  signal cb1_int           : boolean;
  signal ca1_irq           : std_logic;
  signal cb1_irq           : std_logic;

  signal ca2_ip_reg        : std_logic;
  signal cb2_ip_reg        : std_logic;
  signal ca2_int           : boolean;
  signal cb2_int           : boolean;
  signal ca2_irq           : std_logic;
  signal cb2_irq           : std_logic;

  signal final_irq         : std_logic;
begin

  p_phase : process
  begin
    -- internal clock phase
    wait until rising_edge(CLK_4);
    p2_h_t1 <= p2_h;
    if (p2_h_t1 = '0') and (p2_h = '1') then
      phase <= "11";
    else
      phase <= phase + "1";
    end if;
  end process;

  p_cs : process(CS1, CS2_L, P2_H)
  begin
    cs <= '0';
    if (CS1 = '1') and (CS2_L = '0') and (P2_H = '1') then
      cs <= '1';
    end if;
  end process;

  -- peripheral control reg (pcr)
  -- 0      ca1 interrupt control (0 +ve edge, 1 -ve edge)
  -- 3..1   ca2 operation
  --        000 input -ve edge
  --        001 independend interrupt input -ve edge
  --        010 input +ve edge
  --        011 independend interrupt input +ve edge
  --        100 handshake output
  --        101 pulse output
  --        110 low output
  --        111 high output
  -- 7..4   as 3..0 for cb1,cb2

  -- auxiliary control reg (acr)
  -- 0      input latch PA (0 disable, 1 enable)
  -- 1      input latch PB (0 disable, 1 enable)
  -- 4..2   shift reg control
  --        000 disable
  --        001 shift in using t2
  --        010 shift in using o2
  --        011 shift in using ext clk
  --        100 shift out free running t2 rate
  --        101 shift out using t2
  --        101 shift out using o2
  --        101 shift out using ext clk
  -- 5      t2 timer control (0 timed interrupt, 1 count down with pulses on pb6)
  -- 7..6   t1 timer control
  --        00 timed interrupt each time t1 is loaded   pb7 disable
  --        01 continuous interrupts                    pb7 disable
  --        00 timed interrupt each time t1 is loaded   pb7 one shot output
  --        01 continuous interrupts                    pb7 square wave output
  --

  p_write_reg_reset : process(RESET_L, CLK_4)
  begin
    if (RESET_L = '0') then
      r_ora   <= x"00";    r_orb   <= x"00";
      r_ddra  <= x"00";    r_ddrb  <= x"00";
      r_acr   <= x"00";    r_pcr   <= x"00";

      w_orb_hs <= '0';
      w_ora_hs <= '0';
    elsif rising_edge(CLK_4) then
      w_orb_hs <= '0';
      w_ora_hs <= '0';
      if (cs = '1') and (RW_L = '0') then
        case RS is
          when x"0" => r_orb     <= DATA_IN; w_orb_hs <= '1';
          when x"1" => r_ora     <= DATA_IN; w_ora_hs <= '1';
          when x"2" => r_ddrb    <= DATA_IN;
          when x"3" => r_ddra    <= DATA_IN;

          when x"B" => r_acr     <= DATA_IN;
          when x"C" => r_pcr     <= DATA_IN;
          when x"F" => r_ora     <= DATA_IN;

          when others => null;
        end case;
      end if;

      if (r_acr(7) = '1') and (t1_toggle = '1') then
        r_orb(7) <= not r_orb(7); -- toggle
      end if;
    end if;
  end process;

  p_write_reg : process
  begin
    wait until rising_edge(CLK_4);
      t1_w_reset_int  <= false;
      t1_load_counter <= false;

      t2_w_reset_int  <= false;
      t2_load_counter <= false;

      load_data <= x"00";
      sr_write_ena <= false;
      ifr_write_ena <= false;
      ier_write_ena <= false;

      if (cs = '1') and (RW_L = '0') then
        load_data <= DATA_IN;
        case RS is
          when x"4" => r_t1l_l   <= DATA_IN;
          when x"5" => r_t1l_h   <= DATA_IN; t1_w_reset_int  <= true;
                                             t1_load_counter <= true;

          when x"6" => r_t1l_l   <= DATA_IN;
          when x"7" => r_t1l_h   <= DATA_IN; t1_w_reset_int  <= true;

          when x"8" => r_t2l_l   <= DATA_IN;
          when x"9" => r_t2l_h   <= DATA_IN; t2_w_reset_int  <= true;
                                             t2_load_counter <= true;

          when x"A" => sr_write_ena  <= true;
          when x"D" => ifr_write_ena <= true;
          when x"E" => ier_write_ena <= true;

          when others => null;
        end case;
      end if;
  end process;

  p_oe : process(cs, RW_L)
  begin
    DATA_OUT_OE_L <= '1';
    if (cs = '1') and (RW_L = '1') then
      DATA_OUT_OE_L <= '0';
    end if;
  end process;

  p_read : process(cs, RW_L, RS, r_irb, r_ira, r_ddrb, r_ddra, t1c, r_t1l_l,
                   r_t1l_h, t2c, r_sr, r_acr, r_pcr, r_ifr, r_ier, r_ira)
  begin
    DATA_OUT <= x"00"; -- debug really
    t1_r_reset_int <= false;
    t2_r_reset_int <= false;
    sr_read_ena <= false;
    r_irb_hs <= '0';
    r_ira_hs <= '0';
    if (cs = '1') and (RW_L = '1') then
      case RS is
        when x"0" => DATA_OUT <= (r_irb and not r_ddrb) or (r_orb and r_ddrb); r_irb_hs <= '1';
        when x"1" => DATA_OUT <= r_ira; r_ira_hs <= '1';
        when x"2" => DATA_OUT <= r_ddrb;
        when x"3" => DATA_OUT <= r_ddra;
        when x"4" => DATA_OUT <= t1c( 7 downto 0);  t1_r_reset_int <= true;
        when x"5" => DATA_OUT <= t1c(15 downto 8);
        when x"6" => DATA_OUT <= r_t1l_l;
        when x"7" => DATA_OUT <= r_t1l_h;
        when x"8" => DATA_OUT <= t2c( 7 downto 0);  t2_r_reset_int <= true;
        when x"9" => DATA_OUT <= t2c(15 downto 8);
        when x"A" => DATA_OUT <= r_sr;              sr_read_ena <= true;
        when x"B" => DATA_OUT <= r_acr;
        when x"C" => DATA_OUT <= r_pcr;
        when x"D" => DATA_OUT <= r_ifr;
        when x"E" => DATA_OUT <= ('0' & r_ier);
        when x"F" => DATA_OUT <= r_ira;
        when others => null;
      end case;
    end if;

  end process;
  --
  -- IO
  --
  p_ca1_cb1_sel : process(sr_cb1_oe_l, sr_cb1_out, CB1_IN)
  begin
    -- if the shift register is enabled, cb1 may be an output
    -- in this case, we should listen to the CB1_OUT for the interrupt
    if (sr_cb1_oe_l = '1') then
      cb1_in_mux <= CB1_IN;
    else
      cb1_in_mux <= sr_cb1_out;
    end if;
  end process;

  p_ca1_cb1_int : process(r_pcr, ca1_ip_reg, CA1_IN, cb1_ip_reg, cb1_in_mux)
  begin
    if (r_pcr(0) = '0') then -- ca1 control
      -- negative edge
      ca1_int <= (ca1_ip_reg = '1') and (CA1_IN = '0');
    else
      -- positive edge
      ca1_int <= (ca1_ip_reg = '0') and (CA1_IN = '1');
    end if;

    if (r_pcr(4) = '0') then -- cb1 control
      -- negative edge
      cb1_int <= (cb1_ip_reg = '1') and (cb1_in_mux = '0');
    else
      -- positive edge
      cb1_int <= (cb1_ip_reg = '0') and (cb1_in_mux = '1');
    end if;
  end process;

  p_ca2_cb2_int : process(r_pcr, ca2_ip_reg, CA2_IN, cb2_ip_reg, CB2_IN)
  begin
    ca2_int <= false;
    if (r_pcr(3) = '0') then -- ca2 input
      if (r_pcr(2) = '0') then -- ca2 edge
        -- negative edge
        ca2_int <= (ca2_ip_reg = '1') and (CA2_IN = '0');
      else
        -- positive edge
        ca2_int <= (ca2_ip_reg = '0') and (CA2_IN = '1');
      end if;
    end if;

    cb2_int <= false;
    if (r_pcr(7) = '0') then -- cb2 input
      if (r_pcr(6) = '0') then -- cb2 edge
        -- negative edge
        cb2_int <= (cb2_ip_reg = '1') and (CB2_IN = '0');
      else
        -- positive edge
        cb2_int <= (cb2_ip_reg = '0') and (CB2_IN = '1');
      end if;
    end if;
  end process;

  p_ca2_cb2 : process(RESET_L, CLK_4)
  begin
    if (RESET_L = '0') then
      CA2_OUT       <= '0';
      CA2_OUT_OE_L  <= '1';
      CB2_OUT       <= '0';
      CB2_OUT_OE_L  <= '1';

      ca_hs_sr <= '0';
      ca_hs_pulse <= '0';
      cb_hs_sr <= '0';
      cb_hs_pulse <= '0';
    elsif rising_edge(CLK_4) then
      -- ca
      if (phase = "00") and ((w_ora_hs = '1') or (r_ira_hs = '1')) then
        ca_hs_sr <= '1';
      elsif ca1_int then
        ca_hs_sr <= '0';
      end if;

      if (phase = "00") then
        ca_hs_pulse <= w_ora_hs or r_ira_hs;
      end if;

      CA2_OUT_OE_L <= not r_pcr(3); -- ca2 output
      case r_pcr(3 downto 1) is
        when "000" => CA2_OUT <= '0'; -- input
        when "001" => CA2_OUT <= '0'; -- input
        when "010" => CA2_OUT <= '0'; -- input
        when "011" => CA2_OUT <= '0'; -- input
        when "100" => CA2_OUT <= not (ca_hs_sr); -- handshake
        when "101" => CA2_OUT <= not (ca_hs_pulse); -- pulse
        when "110" => CA2_OUT <= '0'; -- low
        when "111" => CA2_OUT <= '1'; -- high
        when others => null;
      end case;

      -- cb
      if (phase = "00") and (w_orb_hs = '1') then
        cb_hs_sr <= '1';
      elsif cb1_int then
        cb_hs_sr <= '0';
      end if;

      if (phase = "00") then
        cb_hs_pulse <= w_orb_hs;
      end if;

      CB2_OUT_OE_L <= not (r_pcr(7) or sr_drive_cb2); -- cb2 output or serial
      if (sr_drive_cb2 = '1') then -- serial output
        CB2_OUT <= sr_out;
      else
        case r_pcr(7 downto 5) is
          when "000" => CB2_OUT <= '0'; -- input
          when "001" => CB2_OUT <= '0'; -- input
          when "010" => CB2_OUT <= '0'; -- input
          when "011" => CB2_OUT <= '0'; -- input
          when "100" => CB2_OUT <= not (cb_hs_sr); -- handshake
          when "101" => CB2_OUT <= not (cb_hs_pulse); -- pulse
          when "110" => CB2_OUT <= '0'; -- low
          when "111" => CB2_OUT <= '1'; -- high
          when others => null;
        end case;
      end if;
    end if;
  end process;
  CB1_OUT      <= sr_cb1_out;
  CB1_OUT_OE_L <= sr_cb1_oe_l;

  p_ca_cb_irq : process(RESET_L, CLK_4)
  begin
    if (RESET_L = '0') then
      ca1_irq <= '0';
      ca2_irq <= '0';
      cb1_irq <= '0';
      cb2_irq <= '0';
    elsif rising_edge(CLK_4) then
      -- not pretty
      if ca1_int then
        ca1_irq <= '1';
      elsif (r_ira_hs = '1') or (w_ora_hs = '1') or (clear_irq(1) = '1') then
        ca1_irq <= '0';
      end if;

      if ca2_int then
        ca2_irq <= '1';
      else
        if (((r_ira_hs = '1') or (w_ora_hs = '1')) and (r_pcr(1) = '0')) or
           (clear_irq(0) = '1') then
          ca2_irq <= '0';
        end if;
      end if;

      if cb1_int then
        cb1_irq <= '1';
      elsif (r_irb_hs = '1') or (w_orb_hs = '1') or (clear_irq(4) = '1') then
        cb1_irq <= '0';
      end if;

      if cb2_int then
        cb2_irq <= '1';
      else
        if (((r_irb_hs = '1') or (w_orb_hs = '1')) and (r_pcr(5) = '0')) or
           (clear_irq(3) = '1') then
          cb2_irq <= '0';
        end if;
      end if;

    end if;
  end process;

  p_input_reg : process(RESET_L, CLK_4)
  begin
    if (RESET_L = '0') then
      ca1_ip_reg <= '0';
      cb1_ip_reg <= '0';

      ca2_ip_reg <= '0';
      cb2_ip_reg <= '0';

      r_ira <= x"00";
      r_irb <= x"00";

    elsif rising_edge(CLK_4) then
      -- we have a fast clock, so we can have input registers
      ca1_ip_reg <= CA1_IN;
      cb1_ip_reg <= cb1_in_mux;

      ca2_ip_reg <= CA2_IN;
      cb2_ip_reg <= CB2_IN;

      if (r_acr(0) = '0') then
        r_ira <= PA_IN;
      else -- enable latching
        if ca1_int then
          r_ira <= PA_IN;
        end if;
      end if;

      if (r_acr(1) = '0') then
        r_irb <= PB_IN;
      else -- enable latching
        if cb1_int then
          r_irb <= PB_IN;
        end if;
      end if;
    end if;
  end process;


  p_buffers : process(r_ddra, r_ora, r_ddrb, r_acr, r_orb)
  begin
    -- data direction reg (ddr) 0 = input, 1 = output
    PA_OUT      <= r_ora;
    PA_OUT_OE_L <= not r_ddra;

    if (r_acr(7) = '1') then -- not clear if r_ddrb(7) must be 1 as well
      PB_OUT_OE_L(7) <= '0'; -- an output if under t1 control
    else
      PB_OUT_OE_L(7) <= not (r_ddrb(7));
    end if;

    PB_OUT_OE_L(6 downto 0) <= not r_ddrb(6 downto 0);
    PB_OUT(7 downto 0)      <= r_orb(7 downto 0);

  end process;
  --
  -- Timer 1
  --
  p_timer1_done : process
    variable done : boolean;
  begin
    wait until rising_edge(CLK_4);
    done := (t1c = x"0000");
    t1c_done <= done and (phase = "11");
    if (phase = "11") then
      t1_reload_counter <= done and (r_acr(6) = '1');
    end if;
  end process;

  p_timer1 : process
  begin
    wait until rising_edge(CLK_4);
    if t1_load_counter or (t1_reload_counter and phase = "11") then
      t1c( 7 downto 0) <= r_t1l_l;
      t1c(15 downto 8) <= r_t1l_h;
    elsif (phase="11") then
      t1c <= t1c - "1";
    end if;

    if t1_load_counter or t1_reload_counter then
      t1c_active <= true;
    elsif t1c_done then
      t1c_active <= false;
    end if;

    t1_toggle <= '0';
    if t1c_active and t1c_done then
      t1_toggle <= '1';
      t1_irq <= '1';
    elsif t1_w_reset_int or t1_r_reset_int or (clear_irq(6) = '1') then
      t1_irq <= '0';
    end if;

  end process;
  --
  -- Timer2
  --
  p_timer2_pb6_input : process
  begin
    wait until rising_edge(CLK_4);
    if (phase = "01") then -- leading edge p2_h
      t2_pb6 <= PB_IN(6);
      t2_pb6_t1 <= t2_pb6;
    end if;
  end process;

  p_timer2_done : process
    variable done : boolean;
  begin
    wait until rising_edge(CLK_4);
    done := (t2c = x"0000");
    t2c_done <= done and (phase = "11");
    if (phase = "11") then
      t2_reload_counter <= done;
    end if;
  end process;

  p_timer2 : process
    variable ena : boolean;
  begin
    wait until rising_edge(CLK_4);

    if (r_acr(5) = '0') then
      ena := true;
    else
      ena := (t2_pb6_t1 = '1') and (t2_pb6 = '0'); -- falling edge
    end if;

    if t2_load_counter or (t2_reload_counter and phase = "11") then
    -- not sure if t2c_reload should be here. Does timer2 just continue to
    -- count down, or is it reloaded ? Reloaded makes more sense if using
    -- it to generate a clock for the shift register.
      t2c( 7 downto 0) <= r_t2l_l;
      t2c(15 downto 8) <= r_t2l_h;
    else
      if (phase="11") and ena then -- or count mode
          t2c <= t2c - "1";
      end if;
    end if;

    t2_sr_ena <= (t2c(7 downto 0) = x"00") and (phase = "11");

    if t2_load_counter then
      t2c_active <= true;
    elsif t2c_done then
      t2c_active <= false;
    end if;


    if t2c_active and t2c_done then
      t2_irq <= '1';
    elsif t2_w_reset_int or t2_r_reset_int or (clear_irq(5) = '1') then
      t2_irq <= '0';
    end if;

  end process;
  --
  -- Shift Register
  --
  p_sr : process(RESET_L, CLK_4)
    variable dir_out      : std_logic;
    variable ena          : std_logic;
    variable cb1_op       : std_logic;
    variable cb1_ip       : std_logic;
    variable use_t2       : std_logic;
    variable free_run     : std_logic;
    variable sr_count_ena : boolean;
  begin
    if (RESET_L = '0') then
      r_sr <= x"00";
      sr_drive_cb2 <= '0';
      sr_cb1_oe_l <= '1';
      sr_cb1_out <= '0';
      sr_strobe <= '1';
      sr_cnt <= "0000";
      sr_irq <= '0';
      sr_out <= '1';
      sr_off_delay <= '0';
    elsif rising_edge(CLK_4) then
      -- decode mode
      dir_out  := r_acr(4); -- output on cb2
      cb1_op   := '0';
      cb1_ip   := '0';
      use_t2   := '0';
      free_run := '0';

      case r_acr(4 downto 2) is
        when "000" => ena := '0';
        when "001" => ena := '1'; cb1_op := '1'; use_t2 := '1';
        when "010" => ena := '1'; cb1_op := '1';
        when "011" => ena := '1'; cb1_ip := '1';
        when "100" => ena := '1';                use_t2 := '1'; free_run := '1';
        when "101" => ena := '1'; cb1_op := '1'; use_t2 := '1';
        when "110" => ena := '1';
        when "111" => ena := '1'; cb1_ip := '1';
        when others => null;
      end case;

      -- clock select
      if (ena = '0') then
        sr_strobe <= '1';
      else
        if (cb1_ip = '1') then
          sr_strobe <= CB1_IN;
        else
          if (sr_cnt(3) = '0') and (free_run = '0') then
            sr_strobe <= '1';
          else
            if ((use_t2 = '1') and t2_sr_ena) or
               ((use_t2 = '0') and (phase = "00")) then
                sr_strobe <= not sr_strobe;
            end if;
          end if;
        end if;
      end if;

      -- latch on rising edge, shift on falling edge
      if sr_write_ena then
        r_sr <= load_data;
      elsif (ena = '1') then -- use shift reg

        if (dir_out = '0') then
          -- input
          if (sr_cnt(3) = '1') or (cb1_ip = '1') then
            if sr_strobe_rising then
              r_sr(0) <= CB2_IN;
            elsif sr_strobe_falling then
              r_sr(7 downto 1) <= r_sr(6 downto 0);
            end if;
          end if;
          sr_out <= '1';
        else
          -- output
          if (sr_cnt(3) = '1') or (sr_off_delay = '1') or (cb1_ip = '1') or (free_run = '1') then
            if sr_strobe_falling then
              r_sr(7 downto 1) <= r_sr(6 downto 0);
              r_sr(0) <= r_sr(7);
              sr_out <= r_sr(7);
            end if;
          else
            sr_out <= '1';
          end if;
        end if;
      end if;

      sr_count_ena := sr_strobe_rising;

      if sr_write_ena or sr_read_ena then
      -- some documentation says sr bit in IFR must be set as well ?
        sr_cnt <= "1000";
      elsif sr_count_ena and (sr_cnt(3) = '1') then
        sr_cnt <= sr_cnt + "1";
      end if;

      if (phase = "00") then
        sr_off_delay <= sr_cnt(3); -- give some hold time when shifting out
      end if;

      if sr_count_ena and (sr_cnt = "1111") and (ena = '1') and (free_run = '0') then
        sr_irq <= '1';
      elsif sr_write_ena or sr_read_ena or (clear_irq(2) = '1') then
        sr_irq <= '0';
      end if;

      -- assign ops
      sr_drive_cb2 <= dir_out;
      sr_cb1_oe_l  <= not cb1_op;
      sr_cb1_out   <= sr_strobe;

    end if;
  end process;

  p_sr_strobe_rise_fall : process
  begin
    wait until rising_edge(CLK_4);
    sr_strobe_t1 <= sr_strobe;
    sr_strobe_rising  <= (sr_strobe_t1 = '0') and (sr_strobe = '1');
    sr_strobe_falling <= (sr_strobe_t1 = '1') and (sr_strobe = '0');
  end process;
  --
  -- Interrupts
  --
  p_ier : process(RESET_L, CLK_4)
  begin
    if (RESET_L = '0') then
      r_ier <= "0000000";
    elsif rising_edge(CLK_4) then
      if ier_write_ena then
        if (load_data(7) = '1') then
          -- set
          r_ier <= r_ier or load_data(6 downto 0);
        else
          -- clear
          r_ier <= r_ier and not load_data(6 downto 0);
        end if;
      end if;
    end if;
  end process;

  p_ifr : process(t1_irq, t2_irq, final_irq, ca1_irq, ca2_irq, sr_irq,
                  cb1_irq, cb2_irq)
  begin
    r_ifr(7) <= final_irq;
    r_ifr(6) <= t1_irq;
    r_ifr(5) <= t2_irq;
    r_ifr(4) <= cb1_irq;
    r_ifr(3) <= cb2_irq;
    r_ifr(2) <= sr_irq;
    r_ifr(1) <= ca1_irq;
    r_ifr(0) <= ca2_irq;

    IRQ_L <= not final_irq;
  end process;

  p_irq : process(RESET_L, CLK_4)
  begin
    if (RESET_L = '0') then
      final_irq <= '0';
    elsif rising_edge(CLK_4) then
      if ((r_ifr(6 downto 0) and r_ier(6 downto 0)) = "0000000") then
        final_irq <= '0'; -- no interrupts
      else
        final_irq <= '1';
      end if;
    end if;
  end process;

  p_clear_irq : process(ifr_write_ena, load_data)
  begin
    clear_irq <= x"00";
    if ifr_write_ena then
      clear_irq <= load_data;
    end if;
  end process;

end architecture RTL;
