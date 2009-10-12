--
-- A simulation model of Asteroids Deluxe hardware
-- Copyright (c) MikeJ - May 2004
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
-- Email support@fpgaarcade.com
--
-- Revision list
--
-- version 001 initial release
--
use std.textio.ALL;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_asteroids_xilinx_prims.all;
use work.pkg_asteroids.all;

entity ASTEROIDS_TOP_TB is
end;

architecture Sim of ASTEROIDS_TOP_TB is

  signal clk_40               : std_logic;
  signal clk_ram              : std_logic;
  signal reset_l              : std_logic;
  signal reset_h              : std_logic;
  --
  signal ram_addr             : std_logic_vector(18 downto 0);
  signal ram_addr_del         : std_logic_vector(18 downto 0);
  signal ram_addr_int         : std_logic_vector(18 downto 0);
  signal ram_data             : std_logic_vector(31 downto 0);
  signal ram_oe_l             : std_logic;
  signal ram_oe_l_del         : std_logic;
  signal ram_dio              : std_logic_vector(31 downto 0);
  signal ram_we_l             : std_logic;
  signal ram_we_l_del         : std_logic;
  signal ram_adv_l            : std_logic;
  signal ram_adv_l_del        : std_logic;

  signal button               : std_logic_vector(7 downto 0);
  constant CLKPERIOD_40 : time := 25 ns;

  component CY7C1356B
    GENERIC(
      Tcyc:       TIME    :=      0 ns;
      Tch:        TIME    :=      0 ns;
      Tcl:        TIME    :=      0 ns;
      Tco:        TIME    :=      0 ns;
      Tdoh:       TIME    :=      0 ns;
      Tas:        TIME    :=      2 ns;
      Tah:        TIME    :=      0.5 ns;
      Tcens:      TIME    :=      0 ns;
      Tcenh:      TIME    :=      0 ns;
      Twes:       TIME    :=      0 ns;
      Tweh:       TIME    :=      0 ns;
      Tals:       TIME    :=      0 ns;
      Talh:       TIME    :=      0 ns;
      Tds:        TIME    :=      0 ns;
      Tdh:        TIME    :=      0 ns;
      Tces:       TIME    :=      2 ns;
      Tceh:       TIME    :=      0.5 ns;
      Tchz:       TIME    :=      3.8 ns
         );

    PORT (
          CE1_n, CE2, CE3_n, OE_n, WE_n, CEN_n, Clk, ADV_LD_n, Mode : in std_logic;
          BWS_n : in std_logic_vector(1 downto 0);
          A: in    std_logic_vector(18 downto 0);
          DQ: inout std_logic_vector(15 downto 0);
          DP: inout std_logic_vector(1 downto 0)
          );
  end component;

  component ASTEROIDS_TOP
    port (
      BUTTON            : inout std_logic_vector(7 downto 0); -- active low
      --
      AUDIO_OUT         : out   std_logic_vector(7 downto 0);
      --
      VIDEO_R_OUT       : out   std_logic_vector(3 downto 0);
      VIDEO_G_OUT       : out   std_logic_vector(3 downto 0);
      VIDEO_B_OUT       : out   std_logic_vector(3 downto 0);

      HSYNC_OUT         : out   std_logic;
      VSYNC_OUT         : out   std_logic;

      RAM_CONFIG        : out   std_logic;
      RAM_ADDR_A        : out   std_logic_vector(18 downto 0);
      RAM_ADDR_B        : out   std_logic_vector(15 downto 0);
      RAM_WE_L          : out   std_logic;
      RAM_ADV_L         : out   std_logic;
      RAM_OE_L          : out   std_logic;
      RAM_DIO           : inout std_logic_vector(31 downto 0);

      RESET_L           : in    std_logic;
      -- clocks to ram
      CLK_RAM_FB        : in    std_logic;
      CLK_RAM_OPA       : out   std_logic;
      CLK_RAM_OPB       : out   std_logic;

      CLK_40            : in    std_logic

      );
  end component;

begin
  u0 : ASTEROIDS_TOP
    port map (
      BUTTON            => button,
      AUDIO_OUT         => open,
      --
      VIDEO_R_OUT       => open,
      VIDEO_G_OUT       => open,
      VIDEO_B_OUT       => open,

      HSYNC_OUT         => open,
      VSYNC_OUT         => open,

      RAM_CONFIG        => open,
      RAM_ADDR_A        => ram_addr,
      RAM_ADDR_B        => open,
      RAM_WE_L          => ram_we_l,
      RAM_ADV_L         => ram_adv_l,
      RAM_OE_L          => ram_oe_l,
      RAM_DIO           => ram_dio,

      RESET_L           => reset_l,
      CLK_RAM_FB        => clk_ram,
      CLK_RAM_OPA       => clk_ram,
      CLK_RAM_OPB       => open,
      CLK_40            => clk_40
      );

  p_clk_40  : process
  begin
    CLK_40 <= '0';
    wait for CLKPERIOD_40 / 2;
    CLK_40 <= '1';
    wait for CLKPERIOD_40 - (CLKPERIOD_40 / 2);
  end process;

  ram_oe_l_del  <= transport ram_oe_l after 2 ns;
  ram_we_l_del  <= transport ram_we_l after 2 ns;
  ram_adv_l_del <= transport ram_adv_l after 2 ns;
  ram_addr_del  <= transport ram_addr after 2 ns;

   u_ram1 : CY7C1356B
   Port map
   ( CE1_n => '0',
     CE2   => '1',
     CE3_n => '0',
     OE_n => ram_oe_l_del,
     WE_n => ram_we_l_del,
     CEN_n => '0',
     CLK => clk_ram,
     ADV_LD_n  => ram_adv_l_del,
     Mode => '0',
     BWS_n => "00",
     A => ram_addr_del,
     DQ => ram_dio(15 downto 0),
     DP => "HH"
     );

   u_ram2 : CY7C1356B
   Port map
   ( CE1_n => '0',
     CE2   => '1',
     CE3_n => '0',
     OE_n => ram_oe_l_del,
     WE_n => ram_we_l_del,
     CEN_n => '0',
     CLK => clk_ram,
     ADV_LD_n  => ram_adv_l_del,
     Mode => '0',
     BWS_n => "00",
     A => ram_addr_del,
     DQ => ram_dio(31 downto 16),
     DP => "HH"
     );

  button <= "00000000";
  p_rst : process
  begin
    reset_l <= '0';
    reset_h <= '1';
    wait for 100 ns;
    reset_l <= '1';
    reset_h <= '0';
    wait;
  end process;

end Sim;

