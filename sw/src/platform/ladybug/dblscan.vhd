--
--	This file is a *derivative* work of the source cited below.
--	The original source can be downloaded from <http://www.fpgaarcade.com>
--

--
-- Adapted for Lady Bug by A. Laeuger, 08-Feb-2006
--
-- Based on
--
-- A simulation model of Pacman hardware
-- VHDL conversion by MikeJ - October 2002
--
-- FPGA PACMAN video scan doubler
--
-- based on a design by Tatsuyuki Satoh
--
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
-- Email pacman@fpgaarcade.com
--
-- Revision list
--
-- version 002 initial release
--
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

library unisim;
--use unisim.vcomponents.all;

entity DBLSCAN is
  port (
    R_IN          : in    std_logic_vector( 2 downto 0);
    G_IN          : in    std_logic_vector( 2 downto 0);
    B_IN          : in    std_logic_vector( 1 downto 0);

    HSYNC_IN      : in    std_logic;
    VSYNC_IN      : in    std_logic;

    R_OUT         : out   std_logic_vector( 2 downto 0);
    G_OUT         : out   std_logic_vector( 2 downto 0);
    B_OUT         : out   std_logic_vector( 1 downto 0);

    HSYNC_OUT     : out   std_logic;
    VSYNC_OUT     : out   std_logic;
    BLANK_OUT     : out   std_logic;
    --  NOTE CLOCKS MUST BE PHASE LOCKED !!
    CLK_6         : in    std_logic; -- input pixel clock (6MHz)
    CLK_EN_6M     : in    std_logic;
    CLK_12        : in    std_logic; -- output clock      (12MHz)
    CLK_EN_12M    : in    std_logic
  );
end;

architecture RTL of DBLSCAN is
  --
  -- input timing
  --
  signal hsync_in_t1 : std_logic;
  signal vsync_in_t1 : std_logic;
  signal hpos_i : std_logic_vector(8 downto 0) := (others => '0');    -- input capture postion
  signal ibank : std_logic;
  signal we_a : std_logic;
  signal we_b : std_logic;
  signal rgb_in  : std_logic_vector(7 downto 0);
  --
  -- output timing
  --
  signal hpos_o : std_logic_vector(8 downto 0) := (others => '0');
  signal ohs : std_logic;
  signal ohs_t1 : std_logic;
  signal ovs : std_logic;
  signal ovs_t1 : std_logic;
  signal obank : std_logic;
  signal obank_t1 : std_logic;
  --
  signal vs_cnt : std_logic_vector(2 downto 0);
  signal rgb_out_a : std_logic_vector(7 downto 0);
  signal rgb_out_b : std_logic_vector(7 downto 0);
begin

  p_input_timing : process
    variable rising_h : boolean;
    variable rising_v : boolean;
  begin
    wait until rising_edge (CLK_6);
    if CLK_EN_6M = '1' then
      hsync_in_t1 <= HSYNC_IN;
      vsync_in_t1 <= VSYNC_IN;

      rising_h := (HSYNC_IN = '1') and (hsync_in_t1 = '0');
      rising_v := (VSYNC_IN = '1') and (vsync_in_t1 = '0');

      if rising_v then
        ibank <= '0';
      elsif rising_h then
        ibank <= not ibank;
      end if;

      if rising_h then
        hpos_i <= (others => '0');
      else
        hpos_i <= hpos_i + "1";
      end if;
    end if;

  end process;

  we_a <=     ibank;
  we_b <= not ibank;
  rgb_in <= B_IN & G_IN & R_IN;

  u_ram_a : entity work.dperam_1r1w
		generic map
		(
			numwords_a 	=> 512,
			widthad_a		=> 9
		)
    port map 
		(
      -- output
      q						=> rgb_out_a,
      --DIB   		=> x"00",
      rdaddress		=> hpos_o,
      rdclocken 	=> CLK_EN_12M,
      --RSTB  		=> '0',
      rdclock 		=> CLK_12,

      -- input
      --DOA   =>
      data				=> rgb_in,
      wraddress		=> hpos_i,
      wren				=> we_a,
      wrclocken		=> CLK_EN_6M,
      --RSTA  		=> '0',
      wrclock			=> CLK_6
      );

  u_ram_b : entity work.dperam_1r1w
		generic map
		(
			numwords_a 	=> 512,
			widthad_a		=> 9
		)
    port map 
		(
      -- output
      q						=> rgb_out_b,
      --DIB   		=> x"00",
      rdaddress		=> hpos_o,
      rdclocken		=> CLK_EN_12M,
      --RSTB  		=> '0',
      rdclock			=> CLK_12,

      -- input
      --DOA   =>
      data				=> RGB_IN,
      wraddress		=> hpos_i,
      wren				=> we_b,
      wrclocken		=> CLK_EN_6M,
      --RSTA  => '0',
      wrclock			=> CLK_6
      );

  p_output_timing : process
    variable rising_h : boolean;
  begin
    wait until rising_edge (CLK_12);
    if CLK_EN_12M = '1' then
      rising_h := ((ohs = '1') and (ohs_t1 = '0'));

      if rising_h or (hpos_o = "100110111") then
        hpos_o <= (others => '0');
      else
        hpos_o <= hpos_o + "1";
      end if;

      if (ovs = '1') and (ovs_t1 = '0') then -- rising_v
        obank <= '0';
        vs_cnt <= "000";
      elsif rising_h then
        obank <= not obank;
        if (vs_cnt(2) = '0') then
          vs_cnt <= vs_cnt + "1";
        end if;
      end if;

      ohs <= HSYNC_IN; -- reg on clk_12
      ohs_t1 <= ohs;

      ovs <= VSYNC_IN; -- reg on clk_12
      ovs_t1 <= ovs;
    end if;
  end process;

  p_op : process
  begin
    wait until rising_edge (CLK_12);
    if CLK_EN_12M = '1' then

      HSYNC_OUT <= '0';
      if (hpos_o < 8) then
        HSYNC_OUT <= '1';
      end if;

      BLANK_OUT <= '0';
      if hpos_o < 56 or hpos_o > 295 then
        BLANK_OUT <= '1';
      end if;

      obank_t1 <= obank;
      if (obank_t1 = '1') then
        B_OUT <= rgb_out_b(7 downto 6);
        G_OUT <= rgb_out_b(5 downto 3);
        R_OUT <= rgb_out_b(2 downto 0);
      else
        B_OUT <= rgb_out_a(7 downto 6);
        G_OUT <= rgb_out_a(5 downto 3);
        R_OUT <= rgb_out_a(2 downto 0);
      end if;

      VSYNC_OUT <= not vs_cnt(2);
    end if;
  end process;

end architecture RTL;
