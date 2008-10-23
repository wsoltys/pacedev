--
--	This file is a *derivative* work of the source cited below.
--	The original source can be downloaded from <http://www.fpgaarcade.com>
--

-------------------------------------------------------------------------------
--
-- FPGA Adventure Vision
--
-- $Id: jop_av.vhd,v 1.4 2006/05/13 14:55:45 arnim Exp $
--
-- Toplevel of the Cyclone port for JOP.design's cycore board.
--   http://jopdesign.com/
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2006, Arnim Laeuger (arnim.laeuger@gmx.net)
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
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.av_comp_pack.all;
use work.av_machine_comp_pack.all;
use work.av_video_comp_pack.all;
use work.board_misc_comp_pack.all;

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
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
architecture SYN of PACE is

-- Component Declarations

  component av_pll
    PORT (
      inclk0 : in  STD_LOGIC  := '0';
      c0     : OUT STD_LOGIC 
    );
  end component;

  component altsyncram
    generic (
      operation_mode : string;
      width_a        : natural;
      widthad_a      : natural;
      outdata_reg_a  : string;
      init_file      : string := "UNUSED"
    );
    port (
      wren_a         : in  std_logic;
      address_a      : in  std_logic_vector(widthad_a-1 downto 0);
      clock0         : in  std_logic;
      data_a         : in  std_logic_vector(width_a-1 downto 0);
      q_a            : out std_logic_vector(width_a-1 downto 0)
    );
  end component;

	component avKeyboard
	  port
	  (
	    clk       	: in     std_logic;
	    reset     	: in     std_logic;

			-- inputs from PS/2 port
	    ps2_clk  		: inout  std_logic;                            
	    ps2_data 		: inout  std_logic;                            

	    -- user outputs
			inputs			: out    std_logic_vector(7 downto 0)
	  );
	end component;


  -- Signal Declarations

  signal clk32			: std_logic;
  signal vid				: std_logic_vector(15 downto 0);
  signal video_out	: std_logic_vector(15 downto 0);
  signal pixclkena	: std_logic;
  signal vga_hsync	: std_logic;
  signal vga_vsync	: std_logic;
  signal cvbs				: unsigned(4 downto 0);

  signal clk_22m_s        : std_logic;
  signal clk_11m_s        : std_logic;

  signal reset_n_s        : std_logic;
  signal por_n_s          : std_logic;

  signal cart_a_s         : std_logic_vector(11 downto 0);
  signal cart_d_s         : std_logic_vector( 7 downto 0);

  signal led_n_s          : std_logic_vector(39 downto 0);
  signal disp_photo_int_s : std_logic;

	signal inputs_n_s				: std_logic_vector(7 downto 0);
	
  signal av_audio_s       : std_logic_vector( 1 downto 0);
  signal dac_audio_s      : std_logic_vector( 7 downto 0);
  signal audio_s          : std_logic;

  signal vdd8_s           : std_logic_vector( 7 downto 0);
  signal gnd8_s           : std_logic_vector( 7 downto 0);

	-- changes for PACE
  alias ext_clk_i            : std_logic is clk(2);
	alias clk_20M								: std_logic is clk(0);
  signal clk_cnt_q           : unsigned(1 downto 0);
	signal clk_en_5m37_q			 : std_logic;
	
  signal rgb_r_s             : std_logic_vector( 2 downto 0);
  signal rgb_hsync_n_s,
         rgb_hsync_s         : std_logic;
  signal rgb_vsync_n_s,
         rgb_vsync_s         : std_logic;

  signal vga_r_s             : std_logic_vector( 2 downto 0);
  signal vga_hsync_s,
         vga_vsync_s         : std_logic;

  signal cnt_rgb_q,
         cnt_vga_q           : unsigned(1 downto 0);
  signal clk_en_rgb_q,
         clk_en_vga_q        : std_logic;

	alias vid_hsync						 : std_logic is hsync;
	alias vid_vsync						 : std_logic is vsync;
	
	signal vid_r,
				 vid_g,
				 vid_b							 : std_logic_vector(7 downto 0);
	
	alias audio_o							 : std_logic_vector(7 downto 0) is snd_data_l(15 downto 8);
				
	signal ps2_keys_s				   : std_logic_vector(15 downto 0);
	signal ps2_joy_s				   : std_logic_vector(15 downto 0);
	
begin

  -- assign PACE outputs
  red <= vid_r & "00";
  green <= (others => '0'); --vid_g(7 downto 6);
  blue <= (others => '0'); --vid_b(7 downto 6);

	-- unused PACE outputs
	snd_data_l(7 downto 0) <= (others => '0');
  snd_data_r(15 downto 8) <= dac_audio_s;
	snd_data_r(7 downto 0) <= (others => '0');
	sram_o.a <= (others => '0');
	sram_o.d <= (others => '0');
	sram_o.be <= (others => '0');
	sram_o.cs <= '0';
	sram_o.oe <= '0';
	sram_o.we <= '0';
	vga_clk <= '0';
	lcm_data <= (others => '0');
	BW_CVBS <= (others => '0');
  GS_CVBS <= (others => '0');
  spi_clk <= '0';
  spi_mode <= '0';
  spi_sel <= '0';
  spi_dout <= '0';
  ser_tx <= '0';
	leds <= (others => 'Z');

	-- produce a 5MHz clock for the audio DAC
	process (clk_20M)
		variable count : std_logic_vector(1 downto 0);
	begin
		if rising_edge(clk_20M) then
			count := count + 1;
			snd_clk <= count(1);
		end if;
	end process;

  vdd8_s <= (others => '1');
  gnd8_s <= (others => '0');

	reset_n_s <= not reset;

  -----------------------------------------------------------------------------
  -- The PLL
  -----------------------------------------------------------------------------
  pll_b : av_pll
    port map (
      inclk0 => ext_clk_i,
      c0     => clk_22m_s
    );

  -----------------------------------------------------------------------------
  -- Process clk_div
  --
  -- Purpose:
  --   Divides the PLL output clock by two to generate the main 11 MHz clock.
  --
  clk_div: process (clk_22m_s)
  begin
    if clk_22m_s'event and clk_22m_s = '1' then
      clk_11m_s <= not clk_11m_s;
    end if;
  end process clk_div;
  --
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Process rgb_clk
  --
  -- Purpose:
  --   Generates the clock enable for the RGB pixel clock.
  --
  rgb_clk: process (clk_11m_s, reset)
  begin
    if reset = '1' then
      cnt_rgb_q    <= "10";
      clk_en_rgb_q <= '0';

    elsif clk_11m_s'event and clk_11m_s = '1' then
      if cnt_rgb_q = 0 then
        cnt_rgb_q    <= "10";
        clk_en_rgb_q <= '1';
      else
        cnt_rgb_q    <= cnt_rgb_q - 1;
        clk_en_rgb_q <= '0';
      end if;

    end if;
  end process rgb_clk;
  --
  -- Process vga_clk
  --
  -- Purpose:
  --   Generates the clock enable for the VGA pixel clock.
  --
  vga_clk_p: process (clk_22m_s, reset)
  begin
    if reset = '1' then
      cnt_vga_q    <= "10";
      clk_en_vga_q <= '0';

    elsif clk_22m_s'event and clk_22m_s = '1' then
      if cnt_vga_q = 0 then
        cnt_vga_q    <= "10";
        clk_en_vga_q <= '1';
      else
        cnt_vga_q    <= cnt_vga_q - 1;
        clk_en_vga_q <= '0';
      end if;

    end if;
  end process vga_clk_p;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- The AdventureVision console
  -----------------------------------------------------------------------------
  av_machine_b : av_machine
    port map (
      clk_11m_i         => clk_11m_s,
      reset_n_i         => reset_n_s,
      por_n_o           => por_n_s,
      cart_a_o          => cart_a_s,
      cart_oe_n_o       => open,
      cart_d_i          => cart_d_s,
      but_1_n_i         => inputs_n_s(0),
      but_2_n_i         => inputs_n_s(1),
      but_3_n_i         => inputs_n_s(2),
      but_4_n_i         => inputs_n_s(3),
      stick_l_n_i       => inputs_n_s(4),
      stick_r_n_i       => inputs_n_s(5),
      stick_u_n_i       => inputs_n_s(6),
      stick_d_n_i       => inputs_n_s(7),
      audio_o           => av_audio_s,
      led_n_o           => led_n_s,
      disp_p24_n_o      => open,
      disp_photo_int_o  => disp_photo_int_s,
      exp_t0_i          => vdd8_s(0),
      exp_t0_o          => open,
      exp_t0_dir_o      => open,
      exp_rd_n_o        => open,
      exp_psen_n_o      => open,
      exp_wr_n_o        => open,
      exp_ale_o         => open,
      exp_d_i           => vdd8_s,
      exp_d_o           => open,
      exp_p1_i          => vdd8_s(7 downto 3),
      exp_p1_o          => open,
      exp_p1_low_imp_o  => open,
      exp_p2_i          => vdd8_s(3 downto 0),
      exp_p2_o          => open,
      exp_p2l_low_imp_o => open,
      exp_p2h_low_imp_o => open,
      exp_prog_n_o      => open
    );

  -----------------------------------------------------------------------------
  -- Video supplement
  -----------------------------------------------------------------------------
  video_b : av_video
    generic map (
      is_pal_g         => 0
    )
    port map (
      clk_11m_i        => clk_11m_s,
      por_n_i          => por_n_s,
      disp_photo_int_i => disp_photo_int_s,
      led_n_i          => led_n_s,
      rgb_r_o          => rgb_r_s,
      rgb_hsync_n_o    => rgb_hsync_n_s,
      rgb_vsync_n_o    => rgb_vsync_n_s,
      rgb_csync_n_o    => open
    );
  --rgb_g_o <= (others => '0');
  --rgb_b_o <= (others => '0');

  -----------------------------------------------------------------------------
  -- CART ROM (4K)
  -----------------------------------------------------------------------------
  cart_rom : entity work.sprom
    generic map 
		(
			numwords_a		=> 4096,
      widthad_a     => 12,
      init_file     => "../../../../src/platform/adventurevision/roms/carts/" & AV_CART_NAME
    )
    port map 
		(
      clock    			=> clk_11m_s,
      address 			=> cart_a_s(11 downto 0),
      q       			=> cart_d_s
    );
  --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Digital-analog audio converter
  -----------------------------------------------------------------------------
  -- av_audio_s(1) : volume 0 = high, 1 = low
  -- av_audio_s(0) : digital sound waveform
  dac_audio_s <=   (7 => av_audio_s(0), others => '0')
                 when av_audio_s(1) = '0' else
                   (6 => av_audio_s(0), others => '0');

  audio_o   <= dac_audio_s;
  --
  -----------------------------------------------------------------------------

	-- PS/2 keyboard interface
	ps2if_inst : avKeyboard
	port map
	(
    clk       	=> clk_20M,
    reset     	=> reset,

		-- inputs from PS/2 port
    ps2_clk  		=> ps2clk,
    ps2_data 		=> ps2data,

    -- user outputs
		inputs			=> inputs_n_s
	);

  -----------------------------------------------------------------------------
  -- VGA Scan Doubler
  -----------------------------------------------------------------------------
  rgb_hsync_s <= not rgb_hsync_n_s;
  rgb_vsync_s <= not rgb_vsync_n_s;
  --
  dblscan_b : dblscan
    port map (
      RGB_R_IN   => rgb_r_s,
      HSYNC_IN   => rgb_hsync_s,
      VSYNC_IN   => rgb_vsync_s,
      VGA_R_OUT  => vga_r_s,
      HSYNC_OUT  => vga_hsync_s,
      VSYNC_OUT  => vga_vsync_s,
      BLANK_OUT  => open,
      CLK_RGB    => clk_11m_s,
      CLK_EN_RGB => clk_en_rgb_q,
      CLK_VGA    => clk_22m_s,
      CLK_EN_VGA => clk_en_vga_q
    );
  --
  --vid_clk           <= clk_en_vga_q;
  vid_r(7 downto 5) <= vga_r_s;
  vid_r(4 downto 0) <= (others => '0');
  vid_hsync         <= not vga_hsync_s;
  vid_vsync         <= not vga_vsync_s;

end SYN;
