--
--	This file is a *derivative* work of the source cited below.
--	The original source can be downloaded from <http://www.fpgaarcade.com>
--

-------------------------------------------------------------------------------
--
-- FPGA Lady Bug
--
-- $Id: ladybug_machine.vhd,v 1.23 2006/02/07 00:44:21 arnim Exp $
--
-- Toplevel of the Lady Bug machine.
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2005, Arnim Laeuger (arnim.laeuger@gmx.net)
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;

use work.ladybug_dip_pack.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- external ROM/RAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_flash_t;
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- video
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;

    -- audio
    audio_i         : in from_AUDIO_t;
    audio_o         : out to_AUDIO_t;
    
    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;
    
    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
  );
end entity PACE;

architecture SYN of PACE is

	signal reset_n					: std_logic;
	
	signal inputs						: in8(0 to 3);
		
	signal cpu_rom0_data		: std_logic_vector(7 downto 0);
	signal cpu_rom1_data		: std_logic_vector(7 downto 0);
	signal cpu_data_o				: std_logic_vector(7 downto 0);
	
  signal clk_20mhz_s     	: std_logic;
	signal clk_en_5mhz_s		: std_logic;
	signal clk_en_10mhz_s		: std_logic;
  signal por_n_s         	: std_logic;
  signal ext_res_n_s     	: std_logic;
		
  signal rom_cpu_a_s     	: std_logic_vector(14 downto 0);
  signal rom_cpu_d_s     	: std_logic_vector( 7 downto 0);
  signal rom_char_a_s    	: std_logic_vector(11 downto 0);
  signal rom_char_d_s    	: std_logic_vector(15 downto 0);
  signal rom_sprite_a_s  	: std_logic_vector(11 downto 0);
  signal rom_sprite_d_s  	: std_logic_vector(15 downto 0);

	signal rgb_r_s					: std_logic_vector(2 downto 0);
	signal rgb_g_s					: std_logic_vector(2 downto 0);
	signal rgb_b_s					: std_logic_vector(1 downto 0);
	signal rgb_hsync_n_s		: std_logic;
	signal rgb_vsync_n_s		: std_logic;
	signal rgb_hsync_s			: std_logic;
	signal rgb_vsync_s			: std_logic;
	signal vga_r_s					: std_logic_vector(2 downto 0);
	signal vga_g_s					: std_logic_vector(2 downto 0);
	signal vga_b_s					: std_logic_vector(1 downto 0);
	signal blank_s					: std_logic;
	
  signal dip_block_1_s,
         dip_block_2_s   	: std_logic_vector( 7 downto 0);

  signal signed_audio_s  	: signed(7 downto 0);
  signal dac_audio_s     	: std_logic_vector( 7 downto 0);
  signal audio_s         	: std_logic;

	signal sram_cs_n				: std_logic;
	signal sram_oe_n				: std_logic;
	signal sram_we_n				: std_logic;
	
	signal coin_left_s			: std_logic;
	signal coin_right_s			: std_logic;
	
begin

	reset_n <= not reset_i;

	-- SRAM interface	
	sram_oe_n <= '0' when (sram_cs_n = '0' and sram_we_n = '1') else '1';
	sram_o.d <= std_logic_vector(resize(unsigned(cpu_data_o), sram_o.d'length)) 
                when (sram_cs_n = '0' and sram_we_n = '0') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	sram_o.cs <= not sram_cs_n;
	sram_o.oe <= not sram_oe_n;
	sram_o.we <= not sram_we_n;
		
	-- map inputs
	
	clk_20mhz_s <= clk_i(0);
	video_o.clk <= clk_i(1);	-- by convention

	-- all inputs are achtive LOW except coin chutes
	coin_left_s <= not inputs(2)(2);
	coin_right_s <= not inputs(2)(3);

	leds_o <= std_logic_vector(resize(unsigned(inputs(0) or inputs(1) or inputs(2)), leds_o'length));

	inputs_inst : entity work.Inputs
		generic map
		(
			NUM_INPUTS 			=> 4,
			CLK_1US_DIV			=> 20
		)
	  port map
	  (
	    clk     				=> clk_20mhz_s,
	    reset   				=> reset_i,
	    ps2clk  				=> inputs_i.ps2_kclk,
	    ps2data 				=> inputs_i.ps2_kdat,
			jamma						=> inputs_i.jamma_n,
			
			dips						=> (others => '0'),
			inputs					=> inputs
	  );

  GEN_CAVENGER_DIPS : if GAME_NAME = "CAVENGER" generate
    dip_block_1_s <= ca_dip_block_1_c;
    dip_block_2_s <= ca_dip_block_2_c;
  end generate GEN_CAVENGER_DIPS;

  GEN_DORODON_DIPS : if GAME_NAME = "DORODON" generate
    dip_block_1_s <= do_dip_block_1_c;
    dip_block_2_s <= do_dip_block_2_c;
  end generate GEN_DORODON_DIPS;

  GEN_LADYBUG_DIPS : if GAME_NAME = "LADYBUG" generate
    dip_block_1_s <= lb_dip_block_1_c;
    dip_block_2_s <= lb_dip_block_2_c;
  end generate GEN_LADYBUG_DIPS;

  -----------------------------------------------------------------------------
  -- Ladybug Machine
  -----------------------------------------------------------------------------
  machine_b : entity work.ladybug_machine
    generic map (
      external_ram_g    => LADYBUG_EXTERNAL_RAM,	-- use internal RAM?
      flip_screen_g     => 0            					-- don't flip, please
    )
    port map (
      ext_res_n_i       => reset_n,
      clk_20mhz_i       => clk_20mhz_s,
      clk_en_10mhz_o    => clk_en_10mhz_s,
      clk_en_5mhz_o     => clk_en_5mhz_s,
      por_n_o           => por_n_s,
      tilt_n_i          => '1',
      player_select_n_i(0) => inputs(2)(0),
      player_select_n_i(1) => inputs(2)(1),
      player_fire_n_i(0)   => inputs(0)(4),
      player_fire_n_i(1)   => inputs(1)(4),
      player_up_n_i(0)     => inputs(0)(0),
      player_up_n_i(1)     => inputs(1)(0),
      player_right_n_i(0)  => inputs(0)(3),
      player_right_n_i(1)  => inputs(1)(3),
      player_down_n_i(0)   => inputs(0)(1),
      player_down_n_i(1)   => inputs(1)(1),
      player_left_n_i(0)   => inputs(0)(2),
      player_left_n_i(1)   => inputs(1)(2),
      player_bomb_n_i(0)   => inputs(0)(5),
      player_bomb_n_i(1)   => inputs(1)(5),
      right_chute_i     => coin_right_s,
      left_chute_i      => coin_left_s,
      dip_block_1_i     => dip_block_1_s,
      dip_block_2_i     => dip_block_2_s,
      rgb_r_o           => rgb_r_s(2 downto 1),
      rgb_g_o           => rgb_g_s(2 downto 1),
      rgb_b_o           => rgb_b_s,
      hsync_n_o         => rgb_hsync_n_s,
      vsync_n_o         => rgb_vsync_n_s,
      comp_sync_n_o     => open, --comp_sync_n_o,
      audio_o           => signed_audio_s,
      rom_cpu_a_o       => rom_cpu_a_s,
      rom_cpu_d_i       => rom_cpu_d_s,
      rom_char_a_o      => rom_char_a_s,
      rom_char_d_i      => rom_char_d_s,
      rom_sprite_a_o    => rom_sprite_a_s,
      rom_sprite_d_i    => rom_sprite_d_s,
      ram_cpu_a_o       => sram_o.a(11 downto 0),
      ram_cpu_d_i       => sram_i.d(7 downto 0),
      ram_cpu_d_o       => cpu_data_o,
      ram_cpu_we_n_o    => sram_we_n,
      ram_cpu_cs_n_o    => sram_cs_n
    );

		rgb_r_s(0) <= '0';
		rgb_g_s(0) <= '0';
		rgb_hsync_s <= not rgb_hsync_n_s;
		rgb_vsync_s <= not rgb_vsync_n_s;

    -----------------------------------------------------------------------------
    -- Convert signed audio data of Lady Bug Machine (range 127 to -128) to
    -- simple unsigned value.
    -----------------------------------------------------------------------------
    audio_o.ldata(15 downto 8) <= std_logic_vector(unsigned(signed_audio_s + 128));
    audio_o.ldata(7 downto 0) <= (others => '0');
    audio_o.rdata(15 downto 8) <= std_logic_vector(unsigned(signed_audio_s + 128));
    audio_o.rdata(7 downto 0) <= (others => '0');
      
		-- mapped to $0000-$5FFF (24K)
		cpu_rom0_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../../src/platform/ladybug/" & GAME_NAME & "/roms/cpu_rom0.hex",
				numwords_a				=> 16384,
				widthad_a					=> 14
			)
			port map
			(
				clock							=> clk_20mhz_s,
				address						=> rom_cpu_a_s(13 downto 0),
				q									=> cpu_rom0_data
			);
		cpu_rom1_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../../src/platform/ladybug/" & GAME_NAME & "/roms/cpu_rom1.hex",
				numwords_a				=> 8192,
				widthad_a					=> 13
			)
			port map
			(
				clock							=> clk_20mhz_s,
				address						=> rom_cpu_a_s(12 downto 0),
				q									=> cpu_rom1_data
			);

		rom_cpu_d_s <=	cpu_rom0_data when rom_cpu_a_s(14) = '0' else
										cpu_rom1_data;
											
		char_rom_u_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../../src/platform/ladybug/" & GAME_NAME & "/roms/char_u.hex",
				numwords_a				=> 4096,
				widthad_a					=> 12
			)
			port map
			(
				clock							=> clk_20mhz_s,
				address						=> rom_char_a_s,
				q									=> rom_char_d_s(15 downto 8)
			);

		char_rom_l_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../../src/platform/ladybug/" & GAME_NAME & "/roms/char_l.hex",
				numwords_a				=> 4096,
				widthad_a					=> 12
			)
			port map
			(
				clock							=> clk_20mhz_s,
				address						=> rom_char_a_s,
				q									=> rom_char_d_s(7 downto 0)
			);

		sprite_rom_u_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../../src/platform/ladybug/" & GAME_NAME & "/roms/sprite_u.hex",
				numwords_a				=> 4096,
				widthad_a					=> 12
			)
			port map
			(
				clock							=> clk_20mhz_s,
				address						=> rom_sprite_a_s,
				q									=> rom_sprite_d_s(15 downto 8)
			);

		sprite_rom_l_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../../src/platform/ladybug/" & GAME_NAME & "/roms/sprite_l.hex",
				numwords_a				=> 4096,
				widthad_a					=> 12
			)
			port map
			(
				clock							=> clk_20mhz_s,
				address						=> rom_sprite_a_s,
				q									=> rom_sprite_d_s(7 downto 0)
			);

	GEN_CVBS : if LADYBUG_VIDEO_CVBS = '1' generate
		video_o.rgb.r(9 downto 7) <= rgb_r_s;
		video_o.rgb.g(9 downto 7) <= rgb_g_s;
		video_o.rgb.b(9 downto 8) <= rgb_b_s;
		video_o.hsync <= rgb_hsync_n_s;
		video_o.vsync <= rgb_vsync_n_s;
	end generate GEN_CVBS;
	
	GEN_VGA : if LADYBUG_VIDEO_VGA = '1' generate
	
	  -----------------------------------------------------------------------------
	  -- VGA Scan Doubler
	  -----------------------------------------------------------------------------
	  dblscan_b : entity work.dblscan
	    port map (
	      R_IN       => rgb_r_s,
	      G_IN       => rgb_g_s,
	      B_IN       => rgb_b_s,
	      HSYNC_IN   => rgb_hsync_s,
	      VSYNC_IN   => rgb_vsync_s,
	      R_OUT      => vga_r_s,
	      G_OUT      => vga_g_s,
	      B_OUT      => vga_b_s,
	      HSYNC_OUT  => video_o.hsync,
	      VSYNC_OUT  => video_o.vsync,
	      BLANK_OUT  => blank_s,
	      CLK_6      => clk_20mhz_s,
	      CLK_EN_6M  => clk_en_5mhz_s,
	      CLK_12     => clk_20mhz_s,
	      CLK_EN_12M => clk_en_10mhz_s
	    );

		-- wire the vga signals - gated with hblank
		video_o.rgb.r(9 downto 7) <= vga_r_s when blank_s = '0' else (others => '0');
		video_o.rgb.g(9 downto 7) <= vga_g_s when blank_s = '0' else (others => '0');
		video_o.rgb.b(9 downto 8) <= vga_b_s when blank_s = '0' else (others => '0');
	
	end generate GEN_VGA;

	-- unused video colour resolution
	video_o.rgb.r(6 downto 0) <= (others => '0');
	video_o.rgb.g(6 downto 0) <= (others => '0');
	video_o.rgb.b(7 downto 0) <= (others => '0');
	
	-- unused SRAM signals
	sram_o.a(23 downto 12) <= (others => '0');
	
end SYN;
