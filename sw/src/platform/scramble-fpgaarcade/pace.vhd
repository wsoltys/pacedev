--
--	This file is a *derivative* work of the source cited below.
--	The original source can be downloaded from <http://www.fpgaarcade.com>
--

--
-- A simulation model of Scramble hardware
-- Copyright (c) MikeJ - Feb 2007
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
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clkrst_i        : in from_CLKRST_t;

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
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;

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
    
    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );
end entity PACE;

architecture SYN of PACE is

  constant I_HWSEL_FROGGER  : boolean := SCRAMBLE_BUILD_FROGGER;

  signal I_RESET_L        : std_logic;
  signal reset_s          : std_logic;
  signal clk_ref          : std_logic;
  signal clk_s            : std_logic;
  signal ena_12           : std_logic;
  signal ena_6            : std_logic;
  signal ena_6b           : std_logic;
  signal ena_1_79         : std_logic;
  -- ip registers
  signal button_in        : std_logic_vector(7 downto 0);
  signal button_debounced : std_logic_vector(7 downto 0);
  signal ip_1p            : std_logic_vector(6 downto 0);
  signal ip_2p            : std_logic_vector(6 downto 0);
  signal ip_service       : std_logic;
  signal ip_coin1         : std_logic;
  signal ip_coin2         : std_logic;
  signal ip_dip_switch    : std_logic_vector(5 downto 1);


  -- scan doubler signals
  signal video_r          : std_logic_vector(3 downto 0);
  signal video_g          : std_logic_vector(3 downto 0);
  signal video_b          : std_logic_vector(3 downto 0);
  signal hsync_s          : std_logic;
  signal vsync_s          : std_logic;
  --
  signal video_r_x2       : std_logic_vector(3 downto 0);
  signal video_g_x2       : std_logic_vector(3 downto 0);
  signal video_b_x2       : std_logic_vector(3 downto 0);
  signal hsync_x2         : std_logic;
  signal vsync_x2         : std_logic;
  -- ties to audio board
  signal audio_addr       : std_logic_vector(15 downto 0);
  signal audio_data_out   : std_logic_vector(7 downto 0);
  signal audio_data_in    : std_logic_vector(7 downto 0);
  signal audio_data_oe_l  : std_logic;
  signal audio_rd_l       : std_logic;
  signal audio_wr_l       : std_logic;
  signal audio_iopc7      : std_logic;
  signal audio_reset_l    : std_logic;

  -- audio
  signal audio            : std_logic_vector(9 downto 0);
  signal audio_pwm        : std_logic;

	-- aliases for PACE
	alias I_RESET						: std_logic is clkrst_i.rst(0);
	alias I_CLK_REF					: std_logic is clkrst_i.clk(0);
	alias O_VIDEO_R					: std_logic_vector(3 downto 0) is video_o.rgb.r(9 downto 6);
	alias O_VIDEO_G					: std_logic_vector(3 downto 0) is video_o.rgb.g(9 downto 6);
	alias O_VIDEO_B					: std_logic_vector(3 downto 0) is video_o.rgb.b(9 downto 6);
	alias O_HSYNC						: std_logic is video_o.hsync;
	alias O_VSYNC						: std_logic is video_o.vsync;
	
	signal O_AUDIO_L				: std_logic;
	signal O_AUDIO_R				: std_logic;
	signal I_SW							: std_logic_vector(3 downto 0);
	signal I_BUTTON					: std_logic_vector(3 downto 0);
	
begin

  I_RESET_L <= not I_RESET;
  --
  -- clocks
  --
  u_clocks : entity work.SCRAMBLE_CLOCKS
    port map (
      I_CLK_REF  => I_CLK_REF,
      I_RESET_L  => I_RESET_L,
      --
      O_CLK_REF  => clk_ref,  -- 50
      --
      O_ENA_12   => ena_12,   -- 6.25 x 2
      O_ENA_6B   => ena_6b,   -- 6.25 (inverted)
      O_ENA_6    => ena_6,    -- 6.25
      O_ENA_1_79 => ena_1_79, -- 1.786
      O_CLK      => clk_s,
      O_RESET    => reset_s
      );

  u_scramble : entity work.SCRAMBLE
    port map (
      I_HWSEL_FROGGER       => I_HWSEL_FROGGER,
      --
      O_VIDEO_R             => video_r,
      O_VIDEO_G             => video_g,
      O_VIDEO_B             => video_b,
      O_HSYNC               => hsync_s,
      O_VSYNC               => vsync_s,
      --
      -- to audio board
      --
      O_ADDR                => audio_addr,
      O_DATA                => audio_data_out,
      I_DATA                => audio_data_in,
      I_DATA_OE_L           => audio_data_oe_l,
      O_RD_L                => audio_rd_l,
      O_WR_L                => audio_wr_l,
      O_IOPC7               => audio_iopc7,
      O_RESET_WD_L          => audio_reset_l,
      --
      ENA                   => ena_6,
      ENAB                  => ena_6b,
      ENA_12                => ena_12,
      --
      RESET                 => reset_s,
      CLK                   => clk_s
      );

	video_o.clk <= clkrst_i.clk(1);	-- by convention
  
  u_scan_doubler : entity work.SCRAMBLE_DBLSCAN
    port map (
      I_R          => video_r,
      I_G          => video_g,
      I_B          => video_b,
      I_HSYNC      => hsync_s,
      I_VSYNC      => vsync_s,
      --
      O_R          => video_r_x2,
      O_G          => video_g_x2,
      O_B          => video_b_x2,
      O_HSYNC      => hsync_x2,
      O_VSYNC      => vsync_x2,
      --
      ENA_X2       => ena_12,
      ENA          => ena_6,
      CLK          => clk_s
      );

  p_video_ouput : process
  begin
    wait until rising_edge(clk_s);
    -- switch is on (up) use scan converter and light led
    --O_LED(3 downto 1) <= "000";

    --if (button_debounced(4) = '1') then
    if SCRAMBLE_VIDEO_VGA = '1' then
      --O_LED(0) <= '1';
      O_VIDEO_R(3 downto 0) <= video_r_x2;
      O_VIDEO_G(3 downto 0) <= video_g_x2;
      O_VIDEO_B(3 downto 0) <= video_b_x2;
      O_HSYNC   <= hsync_x2;
      O_VSYNC   <= vsync_x2;
    else
      --O_LED(0) <= '0';
      O_VIDEO_R(3 downto 0) <= video_r;
      O_VIDEO_G(3 downto 0) <= video_g;
      O_VIDEO_B(3 downto 0) <= video_b;
      O_HSYNC   <= hsync_s;
      O_VSYNC   <= vsync_s;
    end if;
  end process;

  --
  --
  -- audio subsystem
  --
  u_audio : entity work.SCRAMBLE_AUDIO
    port map (
      I_HWSEL_FROGGER    => I_HWSEL_FROGGER,
      --
      I_ADDR             => audio_addr,
      I_DATA             => audio_data_out,
      O_DATA             => audio_data_in,
      O_DATA_OE_L        => audio_data_oe_l,
      --
      I_RD_L             => audio_rd_l,
      I_WR_L             => audio_wr_l,
      I_IOPC7            => audio_iopc7,
      --
      O_AUDIO            => audio,
      --
      I_1P_CTRL          => ip_1p, -- start, shoot1, shoot2, left,right,up,down
      I_2P_CTRL          => ip_2p, -- start, shoot1, shoot2, left,right,up,down
      I_SERVICE          => ip_service,
      I_COIN1            => ip_coin1,
      I_COIN2            => ip_coin2,
      O_COIN_COUNTER     => open,
      --
      I_DIP              => ip_dip_switch,
      --
      I_RESET_L          => audio_reset_l,
      ENA                => ena_6,
      ENA_1_79           => ena_1_79,
      CLK                => clk_s
      );

  GEN_SOUND : if PLATFORM_HAS_SOUND generate

    audio_o.clk <= clk_s;
    audio_o.ldata(audio_o.ldata'left downto audio_o.ldata'left+1-audio'length) <= audio;
    audio_o.ldata(audio_o.ldata'left-audio'length downto 0) <= (others => '0');
    audio_o.rdata(audio_o.rdata'left downto audio_o.rdata'left+1-audio'length) <= audio;
    audio_o.rdata(audio_o.rdata'left-audio'length downto 0) <= (others => '0');

  end generate GEN_SOUND;
  
  --
  -- Audio DAC
  --
  --u_dac : entity work.dac
  --  generic map(
  --    msbi_g => 9
  --  )
  --  port  map(
  --    clk_i   => clk_ref,
  --    res_n_i => I_RESET_L,
  --    dac_i   => audio,
  --    dac_o   => audio_pwm
  --  );
  --O_AUDIO_L <= audio_pwm;
  --O_AUDIO_R <= audio_pwm;

  button_in(7 downto 4) <= I_SW(3 downto 0);
  button_in(3 downto 0) <= I_BUTTON(3 downto 0);

  --u_debounce : entity work.SCRAMBLE_DEBOUNCE
  --generic map (
  --  G_WIDTH => 8
  --  )
  --port map (
  --  I_BUTTON => button_in,
  --  O_BUTTON => button_debounced,
  --  CLK      => clk_s
  --  );

  BLK_INPUTS : block
    signal mapped_inputs		: from_MAPPED_INPUTS_t(0 to 0);
  begin

    inputs_inst : entity work.inputs
      generic map
      (
        NUM_INPUTS	    => 1,
        CLK_1US_DIV	    => 50
      )
      port map
      (
        clk     	      => clkrst_i.clk(0),
        reset   	      => clkrst_i.rst(0),
        ps2clk  	      => inputs_i.ps2_kclk,
        ps2data 	      => inputs_i.ps2_kdat,
        jamma			      => inputs_i.jamma_n,
    
        dips     	      => (others => '0'),
        inputs		      => mapped_inputs
      );

    button_debounced <= mapped_inputs(0).d;
    
  end block BLK_INPUTS;
  
  -- assign inputs
  -- start, shoot1, shoot2, left,right,up,down
  ip_1p(6) <= not button_debounced(6); -- start
  ip_1p(5) <= not button_debounced(5); -- shoot1
  ip_1p(4) <= not button_debounced(4); -- shoot2
  ip_1p(3) <= not button_debounced(2); -- p1 left
  ip_1p(2) <= not button_debounced(3); -- p1 right
  ip_1p(1) <= not button_debounced(0); -- p1 up
  ip_1p(0) <= not button_debounced(1); -- p1 down
  --
  ip_2p(6) <= not '0';
  ip_2p(5) <= not '0';
  ip_2p(4) <= not '0';
  ip_2p(3) <= not button_debounced(2); -- p2 left
  ip_2p(2) <= not button_debounced(3); -- p2 right
  ip_2p(1) <= not button_debounced(0); -- p2 up
  ip_2p(0) <= not button_debounced(1); -- p2 down
  --
  ip_service <= not '0';
  ip_coin1   <= not button_debounced(7); -- credit
  ip_coin2   <= not '0';

  -- dip switch settings
  scramble_dips : if (not I_HWSEL_FROGGER) generate
  begin
    --SW #1   SW #2       Rockets              SW #3       Cabinet
    -------   -----      ---------             -----       --------
     --OFF     OFF       Unlimited              OFF        Table
     --OFF     ON            5                  ON         Up Right
     --ON      OFF           4
     --ON      ON            3


    --SW #4   SW #5      Coins/Play
    -------   -----      ----------
     --OFF     OFF           4
     --OFF     ON            3
     --ON      OFF           2
     --ON      ON            1

    ip_dip_switch(5 downto 4)  <= not "11"; -- 1 play/coin.
    ip_dip_switch(3)           <= not '1';
    ip_dip_switch(2 downto 1)  <= not "10";
  end generate;

  frogger_dips : if (    I_HWSEL_FROGGER) generate
  begin
  --1   2   3   4   5       Meaning
  -------------------------------------------------------
  --On  On                  3 Frogs
  --On  Off                 5 Frogs
  --Off On                  7 Frogs
  --Off Off                 256 Frogs (!)
  --
  --        On              Upright unit
  --        Off             Cocktail unit
  --
  --            On  On      1 coin 1 play
  --            On  Off     2 coins 1 play
  --            Off On      3 coins 1 play
  --            Off Off     1 coin 2 plays

    ip_dip_switch(5 downto 4)  <= not "11";
    ip_dip_switch(3)           <= not '1';
    ip_dip_switch(2 downto 1)  <= not "01";
  end generate;

  --p_flash : process
  --begin
  --  wait until rising_edge(clk_s);
  --  O_STRATAFLASH_CE_L <= '1';
  --  O_STRATAFLASH_OE_L <= '1';
  --  O_STRATAFLASH_WE_L <= '1';
  --  O_STRATAFLASH_BYTE <= '0';
	--
  --  O_STRATAFLASH_ADDR(23 downto  0) <= (others => '0');
  --  B_STRATAFLASH_DATA <= (others => 'Z');
  --end process;

	-- TBD
	I_SW <= (others => '0');
	I_BUTTON <= (others => '0');
	
  -- not used

	video_o.rgb.r(5 downto 0) <= (others => '0');
	video_o.rgb.g(5 downto 0) <= (others => '0');
	video_o.rgb.b(5 downto 0) <= (others => '0');

  flash_o <= NULL_TO_FLASH;
  sram_o <= NULL_TO_SRAM;
  spi_o <= NULL_TO_SPI;		
  ser_o <= NULL_TO_SERIAL;  
	leds_o <= (others => '0');

end SYN;

