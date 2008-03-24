--
--	This file is a *derivative* work of the source cited below.
--	The original source can be downloaded from <http://www.fpgaarcade.com>
--

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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

use work.pkg_vic20_xilinx_prims.all;
use work.pkg_vic20.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk             : in std_logic_vector(0 to 3);
    test_button     : in std_logic;
    reset           : in std_logic;

    -- game I/O
    ps2clk          : inout std_logic;
    ps2data         : inout std_logic;
    dip             : in std_logic_vector(7 downto 0);
		jamma						: in JAMMAInputsType;

    -- external RAM
    sram_i          : in from_SRAM_t;
    sram_o          : out to_SRAM_t;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
    hsync           : out std_logic;
    vsync           : out std_logic;

    -- composite video
    BW_CVBS         : out std_logic_vector(1 downto 0);
    GS_CVBS         : out std_logic_vector(7 downto 0);

    -- sound
    snd_clk         : out std_logic;
    snd_data_l      : out std_logic_vector(15 downto 0);
    snd_data_r      : out std_logic_vector(15 downto 0);

    -- SPI (flash)
    spi_clk         : out std_logic;
    spi_mode        : out std_logic;
    spi_sel         : out std_logic;
    spi_din         : in std_logic;
    spi_dout        : out std_logic;

    -- serial
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

    signal reset_dll_h        : std_logic;
    signal reset_l_sampled    : std_logic;
    signal clk_40_ibuf        : std_logic;
    signal clk_dlla_op0       : std_logic;
    signal clk_dlla_div       : std_logic;
    signal clk_dllb_op0       : std_logic;
    signal clk_dllb_div       : std_logic;

    signal clk_40_int         : std_logic;
    signal clk_4              : std_logic;

    signal delay_count        : std_logic_vector(7 downto 0) := (others => '0');
    signal clk_cnt            : std_logic_vector(2 downto 0) := "000";
    -- cpu
    signal c_addr             : std_logic_vector(23 downto 0);
    signal c_din              : std_logic_vector(7 downto 0);
    signal c_dout             : std_logic_vector(7 downto 0);
    signal c_rw_l             : std_logic;
    signal c_irq_l            : std_logic;
    signal c_nmi_l            : std_logic;
    --
    signal io_sel_l           : std_logic_vector(3 downto 0);
    signal blk_sel_l          : std_logic_vector(7 downto 0);
    signal ram_sel_l          : std_logic_vector(7 downto 0);

    -- vic
    signal vic_addr           : std_logic_vector(13 downto 0);
    signal vic_oe_l           : std_logic;
    signal vic_dout           : std_logic_vector( 7 downto 0);
    signal vic_din            : std_logic_vector(11 downto 0);
    signal p2_h               : std_logic;
    signal ena_1mhz           : std_logic;
    signal vic_audio          : std_logic_vector( 3 downto 0);

    signal via1_dout          : std_logic_vector( 7 downto 0);
    signal via2_dout          : std_logic_vector( 7 downto 0);
    -- video system
    signal v_addr             : std_logic_vector(13 downto 0);
    signal v_data             : std_logic_vector( 7 downto 0);
    signal v_data_read_mux    : std_logic_vector( 7 downto 0);
    signal v_data_read_muxr   : std_logic_vector( 7 downto 0);
    signal v_rw_l             : std_logic;
    signal col_ram_sel_l      : std_logic;
    --     ram
    signal ram0_dout          : std_logic_vector(7 downto 0);
    signal ram4_dout          : std_logic_vector(7 downto 0);
    signal ram5_dout          : std_logic_vector(7 downto 0);
    signal ram6_dout          : std_logic_vector(7 downto 0);
    signal ram7_dout          : std_logic_vector(7 downto 0);
    --
    signal col_ram_dout       : std_logic_vector(7 downto 0);

    signal char_rom_dout      : std_logic_vector(7 downto 0);
    signal basic_rom_dout     : std_logic_vector(7 downto 0);
    signal kernal_rom_dout    : std_logic_vector(7 downto 0);

    signal ext_rom_din        : std_logic_vector(7 downto 0);
    signal expansion_din      : std_logic_vector(7 downto 0);
    signal expansion_nmi_l    : std_logic;
    signal expansion_irq_l    : std_logic;

    -- VIAs
    signal via1_nmi_l         : std_logic;
    signal via1_pa_in         : std_logic_vector(7 downto 0);
    signal via1_pa_out        : std_logic_vector(7 downto 0);

    signal via2_irq_l         : std_logic;

    signal cass_write         : std_logic;
    signal cass_read          : std_logic;
    signal cass_motor         : std_logic;
    signal cass_sw            : std_logic;

    signal keybd_col_out      : std_logic_vector(7 downto 0);
    signal keybd_col_in       : std_logic_vector(7 downto 0);
    signal keybd_col_oe_l     : std_logic_vector(7 downto 0);
    signal keybd_row_in       : std_logic_vector(7 downto 0);
    signal keybd_restore      : std_logic;

    signal joy                : std_logic_vector(3 downto 0);
    signal light_pen          : std_logic;

    signal serial_srq_in      : std_logic;
    signal serial_atn_out_l   : std_logic; -- the vic does not listen to atn_in
    signal serial_clk_out_l   : std_logic;
    signal serial_clk_in      : std_logic;
    signal serial_data_out_l  : std_logic;
    signal serial_data_in     : std_logic;

    -- user port
    signal user_port_cb1_in   : std_logic;
    signal user_port_cb1_out  : std_logic;
    signal user_port_cb1_oe_l : std_logic;
    signal user_port_cb2_in   : std_logic;
    signal user_port_cb2_out  : std_logic;
    signal user_port_cb2_oe_l : std_logic;
    signal user_port_in       : std_logic_vector(7 downto 0);
    signal user_port_out      : std_logic_vector(7 downto 0);
    signal user_port_oe_l     : std_logic_vector(7 downto 0);

	-- aliases etc for PACE compatibility

	alias CLK_40								: std_logic is clk(0);
	signal RESET_L							: std_logic;
	alias VIDEO_R_OUT						: std_logic_vector(3 downto 0) is red(9 downto 6);
	alias VIDEO_G_OUT						: std_logic_vector(3 downto 0) is green(9 downto 6);
	alias VIDEO_B_OUT						: std_logic_vector(3 downto 0) is blue(9 downto 6);
	alias HSYNC_OUT							: std_logic is hsync;	
	alias VSYNC_OUT							: std_logic is vsync;	
	signal COMP_SYNC_L_OUT			: std_logic;
	alias AUDIO_OUT							: std_logic_vector(3 downto 0) is snd_data_l(15 downto 12);
	alias PS2_CLK								: std_logic is ps2clk;
	alias PS2_DATA							: std_logic is ps2data;
	
begin

	-- PACE compatibility
	RESET_L <= not reset;
	
  --
  -- IO connect these to the outside world if you wish ...
  --

  -- expansion port
  -- <= c_addr;
  expansion_din <= x"FF";
  -- <= c_rw_l;
  -- <= v_rw_l;
  expansion_nmi_l <= '1';
  expansion_irq_l <= '1';
  -- <= ram_sel_l;
  -- <= io_sel_l;
  -- <= reset_l_sampled;

  -- user port
  user_port_cb1_in <= '0';
  user_port_cb2_in <= '0';
  user_port_in <= x"00";
  -- <= user_port_out
  -- <= user_port_out_oe_l

  -- tape
  cass_read <= '0';
  --<= cass_write;
  --<= cass_motor
  cass_sw <= '1'; -- motor off

  -- serial
  serial_srq_in <= '0';
  serial_clk_in <= '0';
  serial_data_in <= '0';
  -- <= serial_atn_out_l;
  -- <= serial_clk_out_l;
  -- <= serial_data_out_l

  -- joy
  joy <= "0000";
  light_pen <= '0';
  --
  --
  --
  --IBUFG0 : IBUFG port map (I=> CLK_40,  O => clk_40_ibuf);
	clk_40_ibuf <= CLK_40;
  reset_dll_h <= not RESET_L;

  --CLKDLLA : CLKDLL port map (
  --  CLKIN  => clk_40_ibuf,
  --  RST    => reset_dll_h,
  --  CLKFB  => clk_dlla_op0,
  --  CLKDV  => clk_dlla_div,
  --  CLK0   => clk_dlla_op0
  --  );

  --BUFG0 : BUFG port map (I=> clk_dlla_op0,O => clk_40_int);
	clk_40_int <= clk_40_ibuf;
	
  -- comment the following line out for simulation
  -- if dll model does not do divide by 9
  -- and replace with p_clkdiv process

  --BUFG1 : BUFG port map (I=> clk_dlla_div,O => clk_4);


  p_clkdiv : process
  begin
    wait until rising_edge(clk_40_int);
    clk_cnt <= clk_cnt + '1';
  end process;
  clk_4 <= clk_cnt(2);

  p_delay : process(RESET_L, clk_4)
  begin
    if (RESET_L = '0') then
      delay_count <= x"00";
      reset_l_sampled <= '0';
    elsif rising_edge(clk_4) then
      if (delay_count(7 downto 0) = (x"FF")) then
        delay_count <= (x"00");
        reset_l_sampled <= RESET_L;
      else
        delay_count <= delay_count + "1";
      end if;
    end if;
  end process;
  --reset_l_sampled <= RESET_L; -- simulation

  cpu : T65
      port map (
          Mode    => "00",
          Res_n   => reset_l_sampled,
          Clk     => clk_4,
          Rdy     => ena_1mhz, -- clk ena
          Abort_n => '1',
          IRQ_n   => c_irq_l,
          NMI_n   => c_nmi_l,
          SO_n    => '1',
          R_W_n   => c_rw_l,
          Sync    => open,
          EF      => open,
          MF      => open,
          XF      => open,
          ML_n    => open,
          VP_n    => open,
          VDA     => open,
          VPA     => open,
          A       => c_addr,
          DI      => c_din,
          DO      => c_dout
      );

  vic : VIC20_VIC
    port map (
      RW_L            => v_rw_l,

      ADDR_IN         => v_addr(13 downto 0),
      ADDR_OUT        => vic_addr(13 downto 0),

      DATA_OE_OUT_L   => vic_oe_l,
      DATA_IN         => vic_din,
      DATA_OUT        => vic_dout,
      --
      AUDIO_OUT       => vic_audio,

      VIDEO_R_OUT     => VIDEO_R_OUT,
      VIDEO_G_OUT     => VIDEO_G_OUT,
      VIDEO_B_OUT     => VIDEO_B_OUT,

      HSYNC_OUT       => HSYNC_OUT,
      VSYNC_OUT       => VSYNC_OUT,
      COMP_SYNC_L_OUT => COMP_SYNC_L_OUT,
      --
      --
      LIGHT_PEN_IN    => light_pen,
      POTX_IN         => '0',
      POTY_IN         => '0',

      ENA_1MHZ        => ena_1mhz,
      P2_H            => p2_h,
      CLK_4           => clk_4
      );
  AUDIO_OUT(3 downto 0) <= vic_audio;
  snd_data_r(15 downto 12) <= vic_audio;

  via1 : M6522
    port map (
      RS              => c_addr(3 downto 0),
      DATA_IN         => v_data(7 downto 0),
      DATA_OUT        => via1_dout,
      DATA_OUT_OE_L   => open,

      RW_L            => c_rw_l,
      CS1             => c_addr(4),
      CS2_L           => io_sel_l(0),

      IRQ_L           => via1_nmi_l, -- note, not open drain

      CA1_IN          => keybd_restore,
      CA2_IN          => cass_motor,
      CA2_OUT         => cass_motor,
      CA2_OUT_OE_L    => open,

      PA_IN           => via1_pa_in,
      PA_OUT          => via1_pa_out,
      PA_OUT_OE_L     => open,

      -- port b
      CB1_IN          => user_port_cb1_in,
      CB1_OUT         => user_port_cb1_out,
      CB1_OUT_OE_L    => user_port_cb1_oe_l,

      CB2_IN          => user_port_cb2_in,
      CB2_OUT         => user_port_cb2_out,
      CB2_OUT_OE_L    => user_port_cb2_oe_l,

      PB_IN           => user_port_in,
      PB_OUT          => user_port_out,
      PB_OUT_OE_L     => user_port_oe_l,

      RESET_L         => reset_l_sampled,
      P2_H            => p2_h,
      CLK_4           => clk_4
      );
  serial_atn_out_l <= via1_pa_out(7);
  via1_pa_in(7) <= via1_pa_out(7);
  via1_pa_in(6) <= cass_sw;
  via1_pa_in(5) <= light_pen;
  via1_pa_in(4) <= joy(2);
  via1_pa_in(3) <= joy(1);
  via1_pa_in(2) <= joy(0);
  via1_pa_in(1) <= serial_data_in;
  via1_pa_in(0) <= serial_clk_in;

  via2 : M6522
    port map (
      RS              => c_addr(3 downto 0),
      DATA_IN         => v_data(7 downto 0),
      DATA_OUT        => via2_dout,
      DATA_OUT_OE_L   => open,

      RW_L            => c_rw_l,
      CS1             => c_addr(5),
      CS2_L           => io_sel_l(0),

      IRQ_L           => via2_irq_l, -- note, not open drain

      CA1_IN          => cass_read,
      CA2_IN          => serial_clk_out_l,
      CA2_OUT         => serial_clk_out_l,
      CA2_OUT_OE_L    => open,

      PA_IN           => keybd_row_in,
      PA_OUT          => open,
      PA_OUT_OE_L     => open,

      -- port b
      CB1_IN          => serial_srq_in,
      CB1_OUT         => open,
      CB1_OUT_OE_L    => open,

      CB2_IN          => serial_data_out_l,
      CB2_OUT         => serial_data_out_l,
      CB2_OUT_OE_L    => open,

      PB_IN           => keybd_col_in,
      PB_OUT          => keybd_col_out,
      PB_OUT_OE_L     => keybd_col_oe_l,

      RESET_L         => reset_l_sampled,
      P2_H            => p2_h,
      CLK_4           => clk_4
      );

  p_keybd_col_in : process(keybd_col_out, keybd_col_oe_l, joy)
  begin
    for i in 0 to 6 loop
      keybd_col_in(i) <= keybd_col_out(i);
    end loop;

    if (keybd_col_oe_l(7) = '0') then
      keybd_col_in(7) <= keybd_col_out(7);
    else
      keybd_col_in(7) <= joy(3);
    end if;
  end process;
  cass_write <= keybd_col_out(3);

  keybd : VIC20_PS2_IF
    port map (

      PS2_CLK         => PS2_CLK,
      PS2_DATA        => PS2_DATA,

      COL_IN          => keybd_col_out,
      ROW_OUT         => keybd_row_in,
      RESTORE         => keybd_restore,

      RESET_L         => reset_l_sampled,
      ENA_1MHZ        => ena_1mhz,
      P2_H            => p2_h,
      CLK_4           => clk_4
      );

  p_irq_resolve : process(expansion_irq_l, expansion_nmi_l,
                          via2_irq_l, via1_nmi_l)
  begin
    c_irq_l <= '1';
    if (expansion_irq_l = '0') or (via2_irq_l = '0') then
      c_irq_l <= '0';
    end if;

    c_nmi_l <= '1';
    if (expansion_nmi_l = '0') or (via1_nmi_l = '0') then
      c_nmi_l <= '0';
    end if;
  end process;

  --
  -- decode
  --
  p_io_addr_decode : process(c_addr)
  begin

    io_sel_l <= "1111";
    if (c_addr(15 downto 13) = "100") then
      case c_addr(12 downto 10) is
        when "000" => io_sel_l <= "1111";
        when "001" => io_sel_l <= "1111";
        when "010" => io_sel_l <= "1111";
        when "011" => io_sel_l <= "1111";
        when "100" => io_sel_l <= "1110";
        when "101" => io_sel_l <= "1101"; -- col
        when "110" => io_sel_l <= "1011";
        when "111" => io_sel_l <= "0111";
        when others => null;
      end case;
    end if;
  end process;

  p_blk_addr_decode : process(c_addr)
  begin
    blk_sel_l <= "11111111";
    case c_addr(15 downto 13) is
      when "000" => blk_sel_l <= "11111110";
      when "001" => blk_sel_l <= "11111101";
      when "010" => blk_sel_l <= "11111011";
      when "011" => blk_sel_l <= "11110111";
      when "100" => blk_sel_l <= "11101111";
      when "101" => blk_sel_l <= "11011111";
      when "110" => blk_sel_l <= "10111111"; -- basic
      when "111" => blk_sel_l <= "01111111"; -- kernal
      when others => null;
    end case;
  end process;

  p_v_mux : process(c_addr, c_dout, c_rw_l, p2_h, vic_addr, v_data_read_mux,
                         blk_sel_l, io_sel_l)
  begin
    -- simplified data source mux
    if (p2_h = '0') then
      v_addr(13 downto 0) <= vic_addr(13 downto 0);
      v_data <= v_data_read_mux(7 downto 0);
      v_rw_l <= '1';
      col_ram_sel_l <= '1'; -- colour ram has dedicated mux for vic, so disable
    else
      v_addr(13 downto 0) <= blk_sel_l(4) & c_addr(12 downto 0);
      v_data <= c_dout;
      v_rw_l <= c_rw_l;
      col_ram_sel_l <= io_sel_l(1);
    end if;

  end process;

  p_ram_addr_decode : process(v_addr, blk_sel_l, p2_h)
  begin
    ram_sel_l <= "11111111";
    if ((p2_h = '1') and (blk_sel_l(0) = '0')) or
       ((p2_h = '0') and (v_addr(13) = '1')) then
      case v_addr(12 downto 10) is
        when "000" => ram_sel_l <= "11111110";
        when "001" => ram_sel_l <= "11111101";
        when "010" => ram_sel_l <= "11111011";
        when "011" => ram_sel_l <= "11110111";
        when "100" => ram_sel_l <= "11101111";
        when "101" => ram_sel_l <= "11011111";
        when "110" => ram_sel_l <= "10111111";
        when "111" => ram_sel_l <= "01111111";
        when others => null;
      end case;
    end if;
  end process;

  p_vic_din_mux : process(p2_h, col_ram_dout, v_data)
  begin
    if (p2_h = '0') then
      vic_din(11 downto 8) <= col_ram_dout(3 downto 0);
    else
      vic_din(11 downto 8) <= v_data(3 downto 0);
    end if;

    vic_din(7 downto 0) <= v_data(7 downto 0);
  end process;

  p_v_read_mux : process(col_ram_sel_l, ram_sel_l, vic_oe_l, v_addr,
                         col_ram_dout, ram0_dout, ram4_dout, ram5_dout,
                         ram6_dout, ram7_dout, vic_dout, char_rom_dout,
                         v_data_read_muxr)
  begin
    -- simplified data read mux
    -- nasty if statement but being lazy
    -- these are exclusive, but the tools may not spot this.

    if (col_ram_sel_l = '0') then
      v_data_read_mux <= "0000" & col_ram_dout(3 downto 0);
    elsif (vic_oe_l = '0') then
      v_data_read_mux <= vic_dout;
    elsif (ram_sel_l(0) = '0') then
      v_data_read_mux <= ram0_dout;
    elsif (ram_sel_l(4) = '0') then
      v_data_read_mux <= ram4_dout;
    elsif (ram_sel_l(5) = '0') then
      v_data_read_mux <= ram5_dout;
    elsif (ram_sel_l(6) = '0') then
      v_data_read_mux <= ram6_dout;
    elsif (ram_sel_l(7) = '0') then
      v_data_read_mux <= ram7_dout;
    elsif (v_addr(13 downto 12) = "00") then
      v_data_read_mux <= char_rom_dout;
    else
      -- emulate floating bus
      --v_data_read_mux <= "XXXXXXXX";
      v_data_read_mux <= v_data_read_muxr;
    end if;

  end process;

  p_v_bus_hold : process
  begin
    wait until rising_edge(clk_4);
    v_data_read_muxr <= v_data_read_mux;
  end process;

  p_cpu_read_mux : process(p2_h, c_addr, io_sel_l, ram_sel_l, blk_sel_l,
                           v_data_read_mux, via1_dout, via2_dout,
                           basic_rom_dout, kernal_rom_dout, expansion_din)
  begin

    if (p2_h = '0') then -- vic is on the bus
      --c_din <= "XXXXXXXX";
      c_din <= "00000000";
    elsif (io_sel_l(0) = '0') and (c_addr(4) = '1') then
      c_din <= via1_dout;
    elsif (io_sel_l(0) = '0') and (c_addr(5) = '1') then
      c_din <= via2_dout;
    elsif (blk_sel_l(6) = '0') then
      c_din <= basic_rom_dout;
    elsif (blk_sel_l(7) = '0') then
      c_din <= kernal_rom_dout;
    elsif (( io_sel_l(1) = '0') or
           (ram_sel_l(0) = '0') or
           (ram_sel_l(4) = '0') or
           (ram_sel_l(5) = '0') or
           (ram_sel_l(6) = '0') or
           (ram_sel_l(7) = '0') or
           (blk_sel_l(0) = '0') or
           (blk_sel_l(4) = '0')) then
      c_din <= v_data_read_mux;
    else
      c_din <= expansion_din;
    end if;
  end process;
  --
  -- main memory
  --
  rams0 : VIC20_RAMS
    port map (
      V_ADDR => v_addr(9 downto 0),
      DIN    => v_data,
      DOUT   => ram0_dout,
      V_RW_L => v_rw_l,
      CS_L   => ram_sel_l(0),
      CLK    => clk_4
      );

  rams4 : VIC20_RAMS
    port map (
      V_ADDR => v_addr(9 downto 0),
      DIN    => v_data,
      DOUT   => ram4_dout,
      V_RW_L => v_rw_l,
      CS_L   => ram_sel_l(4),
      CLK    => clk_4
      );

  rams5 : VIC20_RAMS
    port map (
      V_ADDR => v_addr(9 downto 0),
      DIN    => v_data,
      DOUT   => ram5_dout,
      V_RW_L => v_rw_l,
      CS_L   => ram_sel_l(5),
      CLK    => clk_4
      );

  rams6 : VIC20_RAMS
    port map (
    V_ADDR => v_addr(9 downto 0),
      DIN    => v_data,
      DOUT   => ram6_dout,
      V_RW_L => v_rw_l,
      CS_L   => ram_sel_l(6),
      CLK    => clk_4
      );

  rams7 : VIC20_RAMS
    port map (
      V_ADDR => v_addr(9 downto 0),
      DIN    => v_data,
      DOUT   => ram7_dout,
      V_RW_L => v_rw_l,
      CS_L   => ram_sel_l(7),
      CLK    => clk_4
      );

  col_ram : VIC20_RAMS
    port map (
      V_ADDR => v_addr(9 downto 0),
      DIN    => v_data,
      DOUT   => col_ram_dout,
      V_RW_L => v_rw_l,
      CS_L   => col_ram_sel_l,
      CLK    => clk_4
      );
  --
  -- roms
  --
  char_rom : VIC20_CHAR_ROM
    port map (
      CLK         => clk_4,
      ADDR        => v_addr(11 downto 0),
      DATA        => char_rom_dout
      );

  --  use the following if your have enough space for internal roms
  basic_rom : VIC20_BASIC_ROM
    port map (
      CLK         => clk_4,
      ADDR        => c_addr(12 downto 0),
      DATA        => basic_rom_dout
      );

  kernal_rom : VIC20_KERNAL_ROM
    port map (
      CLK         => clk_4,
      ADDR        => c_addr(12 downto 0),
      DATA        => kernal_rom_dout
      );
  -- end comment

  -- comment out the following if using internal roms
  --basic_rom_dout  <= ext_rom_din;
  --kernal_rom_dout <= ext_rom_din;
  -- end comment

  --p_ext_rom : process(ROM_DATA, c_addr)
  --begin
  --  ROM_DATA(7 downto 0) <= (others => 'Z'); -- d
  --  ext_rom_din <= ROM_DATA(7 downto 0);
	--
  --  ROM_ADDR(18 downto 0) <= "00000" & c_addr(13 downto 0); -- a18..0
  --  ROM_WE_L <= '1'; -- we_l
  --  ROM_OE_L <= '0'; -- oe_l
  --  ROM_CE_L <= '0'; -- ce_l
  --end process;
	
	-- other
	vga_clk <= CLK_40;
	
	-- unused
	red(5 downto 0) <= (others => '0');
	green(5 downto 0) <= (others => '0');
	blue(5 downto 0) <= (others => '0');
	lcm_data <= (others => '0');
	bw_cvbs <= (others => '0');
	gs_cvbs <= (others => '0');
	sram_o.a <= (others => '0');
	sram_o.d <= (others => 'Z');
	sram_o.be <= (others => 'Z');
	sram_o.cs <= '0';
	sram_o.oe <= '0';
	sram_o.we <= '0';
	spi_clk <= '0';
	spi_mode <= '0';
	spi_sel <= '0';
	spi_dout <= '0';
	ser_tx <= '0';

end SYN;

