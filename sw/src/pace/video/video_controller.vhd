library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.RGB_t;
use work.pace_pkg.to_VIDEO_t;
use work.video_controller_pkg.all;
entity pace_video_controller is
  generic
  (
		CONFIG		: PACEVideoController_t := PACE_VIDEO_NONE;
		H_SIZE    : integer;
		V_SIZE    : integer;
		H_SCALE   : integer;
		V_SCALE   : integer;
    DELAY			: integer := 0   		-- Number of clocks to delay sync and blank signals
  );
  port
  (
    clk     	: in std_logic;
    clk_ena   : in std_logic;
    reset   	: in std_logic;
    
    -- video input data
    rgb_i     : in RGB_t;

		-- control signals (out)
    stb  	    : out std_logic;
    x 	      : out std_logic_vector(10 downto 0);
    y 	      : out std_logic_vector(10 downto 0);

    -- video output control & data
    video_o   : out to_VIDEO_t
  );
end pace_video_controller;

architecture SYN of pace_video_controller is

	constant VIDEO_H_SIZE				: integer := H_SIZE * H_SCALE;
	constant VIDEO_V_SIZE				: integer := V_SIZE * V_SCALE;

  subtype reg_t is integer range 0 to 2047;

  -- registers
  signal h_front_porch_r        : reg_t := 0;
  signal h_sync_r               : reg_t := 0;
  signal h_back_porch_r         : reg_t := 0;
  signal h_border_r             : reg_t := 0;
  signal h_video_r              : reg_t := 0;
  signal v_front_porch_r        : reg_t := 0;
  signal v_sync_r               : reg_t := 0;
  signal v_back_porch_r         : reg_t := 0;
  signal v_border_r             : reg_t := 0;
  signal v_video_r              : reg_t := 0;

  -- derived values
  alias h_sync_start            : reg_t is h_front_porch_r;
  signal h_back_porch_start     : reg_t := 0;
  signal h_left_border_start    : reg_t := 0;
  signal h_video_start          : reg_t := 0;
  signal h_right_border_start   : reg_t := 0;
  signal h_line_end             : reg_t := 0;
  alias v_sync_start            : reg_t is v_front_porch_r;
  signal v_back_porch_start     : reg_t := 0;
  signal v_top_border_start     : reg_t := 0;
  signal v_video_start          : reg_t := 0;
  signal v_bottom_border_start  : reg_t := 0;
  signal v_screen_end           : reg_t := 0;

  signal hsync_s                : std_logic := '0';
  signal vsync_s                : std_logic := '0';
  signal hactive_s              : std_logic := '0';
  signal vactive_s              : std_logic := '0';
  signal hblank_s               : std_logic := '0';
  signal vblank_s               : std_logic := '0';
  
  subtype count_t is integer range 0 to 2047;
  signal x_count                : count_t := 0;
  signal y_count                : count_t := 0;
  
  signal x_active               : std_logic_vector(10 downto 0) := (others => '0');
  signal y_active               : std_logic_vector(10 downto 0) := (others => '0');
  
begin

  -- registers
	process (reset, clk)
	begin
		if reset = '1' then
			case CONFIG is

        when PACE_VIDEO_VGA_800x600_60Hz =>
          -- generic VGA
          h_front_porch_r <= 40;
          h_sync_r <= 128;
          h_back_porch_r <= 88;
          h_border_r <= (800-VIDEO_H_SIZE)/2;
          v_front_porch_r <= 1;
          v_sync_r <= 4;
          v_back_porch_r <= 23;
          v_border_r <= (600-VIDEO_V_SIZE)/2;

        when PACE_VIDEO_VGA_240x320_60Hz =>
          -- P3M
        when PACE_VIDEO_LCM_320x240_60Hz =>
          -- DE1/2
        when PACE_VIDEO_CVBS_720x288p_50Hz =>
          -- generic composite
				when others =>
					null;
			end case;

      h_video_r <= VIDEO_H_SIZE;
      v_video_r <= VIDEO_V_SIZE;

		end if;
	end process;

  -- register some arithmetic
  process (reset, clk)
  begin
    if reset = '1' then
      null;
    elsif rising_edge(clk) and clk_ena = '1' then
      h_back_porch_start <= h_sync_start + h_sync_r;
      h_left_border_start <= h_back_porch_start + h_back_porch_r;
      h_video_start <= h_left_border_start + h_border_r;
      h_right_border_start <= h_video_start + h_video_r;
      h_line_end <= h_right_border_start + h_border_r;
      v_back_porch_start <= v_sync_start + v_sync_r;
      v_top_border_start <= v_back_porch_start + v_back_porch_r;
      v_video_start <= v_top_border_start + v_border_r;
      v_bottom_border_start <= v_video_start + v_video_r;
      v_screen_end <= v_bottom_border_start + v_border_r;
    end if;
  end process;
  
  -- video control outputs
  process (reset, clk, clk_ena)
  begin
    if reset = '1' then
      hsync_s <= '0';
      x_count <= 0;
      y_count <= 0;
    elsif rising_edge(clk) and clk_ena = '1' then
      if x_count = h_line_end then
        hblank_s <= '1';
        if y_count = v_screen_end then
          vblank_s <= '1';
          y_count <= 0;
        else
          y_active <= x_active + 1;
          if y_count = v_sync_start then
            vsync_s <= '1';
          elsif y_count = v_back_porch_start then
            vsync_s <= '0';
          elsif y_count = v_top_border_start then
            vblank_s <= '0';
          elsif y_count = v_video_start then
            vactive_s <= '1';
            y_active <= (others => '0');
          elsif y_count = v_bottom_border_start then
            vactive_s <= '0';
          end if;
          y_count <= y_count + 1;
        end if;
        x_count <= 0;
      else
        x_active <= x_active + 1;
        if x_count = h_sync_start then
          hsync_s <= '1';
        elsif x_count = h_back_porch_start then
          hsync_s <= '0';
        elsif x_count = h_left_border_start then
          hblank_s <= '0';
        elsif x_count= h_video_start then
          hactive_s <= '1';
          x_active <= (others => '0');
        elsif x_count = h_right_border_start then
          hactive_s <= '0';
        end if;
        x_count <= x_count + 1;
      end if; -- rising_edge(clk) and clk_ena = '1'
    end if;
  end process;
  
  process (reset, clk, clk_ena)
  begin
    if reset = '1' then
      null;
    elsif rising_edge(clk) and clk_ena = '1' then
      -- register control signals
      stb <= '1';
      x <= x_active;
      y <= y_active;
      -- register video outpus
      video_o.hsync <= hsync_s;
      video_o.vsync <= vsync_s;
      video_o.hblank <= hactive_s;
      video_o.vblank <= vactive_s;
    end if;
  end process;
  
end SYN;
