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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_asteroids_xilinx_prims.all;
use work.pkg_asteroids.all;
    --
    -- Notes :
    --
    -- Button shorts input to ground when pressed
    -- external pull ups of 1k are recommended.
    --
    -- Audio out :
    -- Use the following resistors for audio out DAC
    -- audio_out(7) 510   (MSB)
    -- audio_out(6) 1K
    -- audio_out(5) 2K2
    -- audio_out(4) 4K7
    -- audio_out(3) 10K
    -- audio_out(2) 22K
    -- audio_out(1) 47K
    -- audio_out(0) 100K  (LSB) -- common to amplifier
    --
    -- Video out DAC's. Values here give 0.7 Volt peek video output
    -- reduce resistor values for old arcade monitors
    --
    -- Use the following resistors for Video DACs
    --
    -- video_out(3) 510
    -- video_out(2) 1k
    -- video_out(1) 2k2
    -- video_out(0) 4k7
    --

entity ASTEROIDS_TOP is
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

    RAM_CONFIG        : out   std_logic; -- specific to my implementation
    RAM_ADDR_A        : out   std_logic_vector(18 downto 0);
    RAM_ADDR_B        : out   std_logic_vector(15 downto 0); -- same as above
    RAM_WE_L          : out   std_logic;
    RAM_ADV_L         : out   std_logic;
    RAM_OE_L          : out   std_logic;
    RAM_DIO           : inout std_logic_vector(31 downto 0);
    --

    RESET_L           : in    std_logic;
    -- clocks to ram
    CLK_RAM_FB        : in    std_logic;
    CLK_RAM_OPA       : out   std_logic;
    CLK_RAM_OPB       : out   std_logic;

    -- ref clock in
    CLK_40            : in    std_logic
    );
end;

architecture RTL of ASTEROIDS_TOP is

  signal reset_dll_h          : std_logic;
  signal clk_40_ibuf          : std_logic;
  signal clk_ram_fb_ibuf      : std_logic;

  signal clk_dlla_op0         : std_logic;
  signal clk_dlla_div         : std_logic;
  signal clk_dlla_2x          : std_logic;

  signal clk_dllb_2x          : std_logic;

  signal clk_40_int           : std_logic;
  signal clk_80_int           : std_logic;
  signal clk_6                : std_logic := '0';

  signal delay_count          : std_logic_vector(7 downto 0) := (others => '0');
  signal reset_6_l            : std_logic;

  signal reset_80_cnt         : std_logic_vector(2 downto 0) := (others => '0');
  signal reset_80             : std_logic;
  signal reset_80_short       : std_logic;

  signal clk_cnt              : std_logic_vector(2 downto 0) := "000";

  signal x_vector             : std_logic_vector(9 downto 0);
  signal y_vector             : std_logic_vector(9 downto 0);
  signal z_vector             : std_logic_vector(3 downto 0);
  signal beam_on              : std_logic;
  signal beam_ena             : std_logic;

  signal ram_addr_int         : std_logic_vector(18 downto 0);
  signal ram_we_l_int         : std_logic;
  signal ram_adv_l_int        : std_logic;
  signal ram_oe_l_int         : std_logic;
  signal ram_dout_oe_l        : std_logic;
  signal ram_dout_oe_l_reg    : std_logic;
  signal ram_dout             : std_logic_vector(31 downto 0);
  signal ram_dout_reg         : std_logic_vector(31 downto 0);
  signal ram_din              : std_logic_vector(31 downto 0);

  attribute CLKDV_DIVIDE : string;
  attribute CLKDV_DIVIDE of CLKDLLA : label is "6.5";
  --attribute CLKDV_DIVIDE of CLKDLLA : label is "6";
begin

  --
  -- Note about clocks
  --
  -- The following code is specific to Xilinx devices, and
  -- simply generates a 6 MHz clock from a 40 Mhz input.
  -- (the original uses a 6.048 MHz clock, so 40 / 6.5 = 6.15 Mhz - slightly fast)
  --

  reset_dll_h <= not RESET_L;
  IBUFG0 : IBUFG port map (I=> CLK_40,  O => clk_40_ibuf);

  CLKDLLA : CLKDLL port map (
    CLKIN  => clk_40_ibuf,
    RST    => reset_dll_h,
    CLKFB  => clk_dlla_op0,
    CLKDV  => clk_dlla_div,
    CLK2x  => clk_dlla_2x,
    CLK0   => clk_dlla_op0
    );

  BUFG0 : BUFG port map (I=> clk_dlla_op0,O => clk_40_int);
  BUFG1 : BUFG port map (I=> clk_dlla_2x,O => clk_80_int);

  -- make phase locked clocks for external ram
  IBUFG1 : IBUFG port map (I=> CLK_RAM_FB,  O => clk_ram_fb_ibuf);

  CLKDLLB : CLKDLL port map (
    CLKIN  => clk_40_ibuf,
    RST    => reset_dll_h,
    CLKFB  => clk_ram_fb_ibuf,
    CLK2x  => clk_dllb_2x
    );

  OBUF0 : OBUF port map (I=> clk_dllb_2x, O => CLK_RAM_OPA);
  OBUF1 : OBUF port map (I=> clk_dllb_2x, O => CLK_RAM_OPB);

  -- comment the following line out for simulation
  -- if dll model does not do divide by 6
  -- and replace with p_clkdiv process

  BUFG2 : BUFG port map (I=> clk_dlla_div,O => clk_6);
  --p_clkdiv : process
  --begin
    --wait until rising_edge(clk_40_int);
    --if (clk_cnt = "010") then
      --clk_cnt <= "000";
      --clk_6 <= not clk_6;
    --else
      --clk_cnt <= clk_cnt + '1';
    --end if;
  --end process;

  p_delay : process(RESET_L, clk_6)
  begin
    if (RESET_L = '0') then
      delay_count <= x"00"; -- longer delay for cpu
      reset_6_l <= '0';
    elsif rising_edge(clk_6) then
      if (delay_count(7 downto 0) = (x"FF")) then
        delay_count <= (x"FF");
        reset_6_l <= '1';
      else
        delay_count <= delay_count + "1";
        reset_6_l <= '0';
      end if;
    end if;
  end process;

  p_reset_80  : process(RESET_L,clk_80_int)
  begin
    -- note active high reset
    if (RESET_L = '0') then
      reset_80_cnt <= "000";
      reset_80 <= '1';
      reset_80_short <= '1';
    elsif rising_edge(clk_80_int) then
      if (reset_80_cnt = "111") then
        reset_80_cnt <= "111";
        reset_80 <= '0';
      else
        reset_80_cnt <= reset_80_cnt + "1";
        reset_80 <= '1';
      end if;
      reset_80_short <= not reset_80_cnt(2);
    end if;
  end process;

  u_asteroids : ASTEROIDS
    port map (
      BUTTON            => BUTTON,
      --
      AUDIO_OUT         => AUDIO_OUT,

      X_VECTOR          => x_vector,
      Y_VECTOR          => y_vector,
      Z_VECTOR          => z_vector,
      BEAM_ON           => beam_on,
      BEAM_ENA          => beam_ena,
      --
      RESET_6_L         => reset_6_l,
      CLK_6             => clk_6
      );

  u_vtg : ASTEROIDS_VTG
    port map (
      RESET            => reset_80,
      PCLK             => clk_80_int,

      X_VECTOR         => x_vector,
      Y_VECTOR         => y_vector,
      Z_VECTOR         => z_vector,

      BEAM_ON          => beam_on,
      BEAM_ENA         => beam_ena,

      VIDEO_R_OUT      => VIDEO_R_OUT,
      VIDEO_G_OUT      => VIDEO_G_OUT,
      VIDEO_B_OUT      => VIDEO_B_OUT,
      HSYNC_OUT        => HSYNC_OUT,
      VSYNC_OUT        => VSYNC_OUT,

      RAM_ADDR         => ram_addr_int,
      RAM_WE_L         => ram_we_l_int,
      RAM_ADV_L        => ram_adv_l_int,
      RAM_OE_L         => ram_oe_l_int,
      RAM_DOUT_OE_L    => ram_dout_oe_l,
      RAM_DOUT         => ram_dout,
      RAM_DIN          => ram_din

      );

  p_ram_oe_l_reg : process(RESET_L, clk_80_int)
  begin
    if (RESET_L = '0') then
      RAM_WE_L <= '1';
      RAM_OE_L <= '1';
      RAM_ADV_L  <= '1';
    elsif rising_edge(clk_80_int) then
      RAM_WE_L <= ram_we_l_int;
      RAM_OE_L <= ram_oe_l_int;
      RAM_ADV_L  <= ram_adv_l_int;
    end if;
  end process;

  -- this address mux and ram_config are necessary to set the mode pins
  -- on the SRAM on my particular board.
  p_ram_addr_reg : process(reset_80, clk_80_int)
  begin
    if (reset_80 = '1') then
      RAM_ADDR_A <= "0000000000000000100";
    elsif rising_edge(clk_80_int) then
      RAM_ADDR_A <= ram_addr_int;
    end if;
  end process;
  RAM_CONFIG <= not reset_80_short;

  p_ram_io_reg : process
  begin
    wait until rising_edge(clk_80_int);
    RAM_ADDR_B <= ram_addr_int(15 downto 0);
    ram_dout_reg <= ram_dout;
    ram_din <= RAM_DIO;
    ram_dout_oe_l_reg <= ram_dout_oe_l;
  end process;
  RAM_DIO <= ram_dout_reg after 1 ns when (ram_dout_oe_l_reg = '0') else (others => 'Z') after 1 ns;

  -- optional pullups, not needed if external
  BUTTON <= (others => 'Z');
  p7 : PULLUP port map( O => BUTTON(7));
  p6 : PULLUP port map( O => BUTTON(6));
  p5 : PULLUP port map( O => BUTTON(5));
  p4 : PULLUP port map( O => BUTTON(4));
  p3 : PULLUP port map( O => BUTTON(3));
  p2 : PULLUP port map( O => BUTTON(2));
  p1 : PULLUP port map( O => BUTTON(1));
  p0 : PULLUP port map( O => BUTTON(0));

end RTL;
