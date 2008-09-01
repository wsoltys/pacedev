library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.video_controller_pkg.all;

entity pace_video_controller is
  generic
  (
		CONFIG		  : PACEVideoController_t := PACE_VIDEO_NONE;
		DELAY       : integer := 1;
		H_SIZE      : integer;
		V_SIZE      : integer;
		H_SCALE     : integer;
		V_SCALE     : integer;
		BORDER_RGB  : RGB_t := RGB_BLACK
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
    hblank		: out std_logic;
    vblank		: out std_logic;
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

  signal border_rgb_r           : RGB_t := ((others=>'0'), (others=>'0'), (others=>'0'));
  
  -- derived values
  signal h_sync_start           : reg_t := 0;
  signal h_back_porch_start     : reg_t := 0;
  signal h_left_border_start    : reg_t := 0;
  signal h_video_start          : reg_t := 0;
  signal h_right_border_start   : reg_t := 0;
  signal h_line_end             : reg_t := 0;
  signal v_sync_start           : reg_t := 0;
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
  
  signal x_s                    : std_logic_vector(10 downto 0) := (others => '0');
  signal y_s                    : std_logic_vector(10 downto 0) := (others => '0');
  
  signal extended_reset         : std_logic := '1';

begin

  -- registers
	process (reset, clk)
	begin
		if reset = '1' then
			case CONFIG is

        when PACE_VIDEO_VGA_240x320_60Hz =>
          -- P3M

        when PACE_VIDEO_VGA_640x480_60Hz =>
          -- VGA, clk=25.175MHz
          h_front_porch_r <= 16;
          h_sync_r <= 96;
          h_back_porch_r <= 48;
          h_border_r <= (640-VIDEO_H_SIZE)/2;
          v_front_porch_r <= 10;
          v_sync_r <= 2;
          v_back_porch_r <= 33;
          v_border_r <= (480-VIDEO_V_SIZE)/2;

        when PACE_VIDEO_VGA_800x600_60Hz =>
          -- SVGA, clk=40MHz
          h_front_porch_r <= 40;
          h_sync_r <= 128;
          h_back_porch_r <= 88;
          h_border_r <= (800-VIDEO_H_SIZE)/2;
          v_front_porch_r <= 1;
          v_sync_r <= 4;
          v_back_porch_r <= 23;
          v_border_r <= (600-VIDEO_V_SIZE)/2;

        when PACE_VIDEO_VGA_1024x768_60Hz =>
          -- XVGA, clk=65MHz
          h_front_porch_r <= 24;
          h_sync_r <= 136;
          h_back_porch_r <= 160;
          h_border_r <= (1024-VIDEO_H_SIZE)/2;
          v_front_porch_r <= 3;
          v_sync_r <= 6;
          v_back_porch_r <= 29;
          v_border_r <= (768-VIDEO_V_SIZE)/2;

        when PACE_VIDEO_LCM_320x240_60Hz =>
          -- DE1/2
        when PACE_VIDEO_CVBS_720x288p_50Hz =>
          -- generic composite
				when others =>
					null;
			end case;

      h_video_r <= VIDEO_H_SIZE;
      v_video_r <= VIDEO_V_SIZE;
      border_rgb_r <= BORDER_RGB;
      
		end if;
	end process;

  -- register some arithmetic
  process (reset, clk, clk_ena)
  begin
    if reset = '1' then
      null;
    elsif rising_edge(clk) and clk_ena = '1' then
      h_sync_start <= h_front_porch_r - 1;
      h_back_porch_start <= h_sync_start + h_sync_r;
      h_left_border_start <= h_back_porch_start + h_back_porch_r;
      h_video_start <= h_left_border_start + h_border_r;
      h_right_border_start <= h_video_start + h_video_r;
      h_line_end <= h_right_border_start + h_border_r;
      v_sync_start <= v_front_porch_r - 1;
      v_back_porch_start <= v_sync_start + v_sync_r;
      v_top_border_start <= v_back_porch_start + v_back_porch_r;
      v_video_start <= v_top_border_start + v_border_r;
      v_bottom_border_start <= v_video_start + v_video_r;
      v_screen_end <= v_bottom_border_start + v_border_r;
    end if;
  end process;
  
  process (reset, clk)
    variable count_v : integer;
  begin
    if reset = '1' then
      extended_reset <= '1';
      count_v := 7;
    elsif rising_edge(clk) then
      if count_v = 0 then
        extended_reset <= '0';
      else
        count_v := count_v - 1;
      end if;
    end if;
  end process;

  -- video control outputs
  process (extended_reset, clk, clk_ena)
  begin
    if extended_reset = '1' then
      hblank_s <= '1';
      vblank_s <= '1';
      hactive_s <= '0';
      vactive_s <= '0';
      hsync_s <= '0';
      x_count <= 0;
      y_count <= 0;
    elsif rising_edge(clk) and clk_ena = '1' then
      if x_count = h_line_end then
        hblank_s <= '1';
        hactive_s <= '0';     -- for 0 borders
        if y_count = v_screen_end then
          vblank_s <= '1';
          vactive_s <= '0';   -- for 0 borders
          y_count <= 0;
        else
          y_s <= y_s + 1;
          if y_count = v_sync_start then
            vsync_s <= '1';
          elsif y_count = v_back_porch_start then
            vsync_s <= '0';
          elsif y_count = v_video_start then
            vblank_s <= '0';  -- for 0 borders
            vactive_s <= '1';
            y_s <= (others => '0');
          -- check the borders last in case they're 0
          elsif y_count = v_top_border_start then
            vblank_s <= '0';
          elsif y_count = v_bottom_border_start then
            vactive_s <= '0';
          end if;
          y_count <= y_count + 1;
        end if;
        x_count <= 0;
      else
        x_s <= x_s + 1;
        if x_count = h_sync_start then
          hsync_s <= '1';
        elsif x_count = h_back_porch_start then
          hsync_s <= '0';
        elsif x_count= h_video_start then
          hblank_s <= '0'; -- for 0 borders
          hactive_s <= '1';
          x_s <= (others => '0');
          -- check the borders last in case they're 0
        elsif x_count = h_left_border_start then
          hblank_s <= '0';
        elsif x_count = h_right_border_start then
          hactive_s <= '0';
        end if;
        x_count <= x_count + 1;
      end if; -- rising_edge(clk) and clk_ena = '1'
    end if;
  end process;

  -- for video DACs and TFT output
  video_o.clk <= clk;
  
  process (extended_reset, clk, clk_ena)
    constant PIPELINE_DELAY : natural := DELAY+1;
    variable hsync_v_r    : std_logic_vector(PIPELINE_DELAY downto 0) := (others => '0');
    variable vsync_v_r    : std_logic_vector(PIPELINE_DELAY downto 0) := (others => '0');
    variable hactive_v_r  : std_logic_vector(PIPELINE_DELAY downto 0) := (others => '0');
    variable vactive_v_r  : std_logic_vector(PIPELINE_DELAY downto 0) := (others => '0');
    variable hblank_v_r   : std_logic_vector(PIPELINE_DELAY downto 0) := (others => '0');
    variable vblank_v_r   : std_logic_vector(PIPELINE_DELAY downto 0) := (others => '0');
    alias hsync_v         : std_logic is hsync_v_r(PIPELINE_DELAY);
    alias vsync_v         : std_logic is vsync_v_r(PIPELINE_DELAY);
    alias hactive_v       : std_logic is hactive_v_r(PIPELINE_DELAY);
    alias vactive_v       : std_logic is vactive_v_r(PIPELINE_DELAY);
    alias hblank_v        : std_logic is hblank_v_r(PIPELINE_DELAY);
    alias vblank_v        : std_logic is vblank_v_r(PIPELINE_DELAY);
    variable stb_cnt_v    : std_logic_vector(3 downto 0); -- up to 16x scaling
  begin
    if extended_reset = '1' then
      hsync_v_r := (others => '0');
      vsync_v_r := (others => '0');
      hactive_v_r := (others => '0');
      vactive_v_r := (others => '0');
      hblank_v_r := (others => '0');
      vblank_v_r := (others => '0');
      stb_cnt_v := EXT("1", stb_cnt_v'length);
    elsif rising_edge(clk) and clk_ena = '1' then
      -- register control signals and handle scaling
			hblank <= not hactive_s;	-- used only by the bitmap/tilemap/sprite controllers
			vblank <= not vactive_s;	-- used only by the bitmap/tilemap/sprite controllers
			-- handle scaling
			stb <= stb_cnt_v(H_SCALE-1);
      if hactive_s = '1' and vactive_s = '1' then
        stb_cnt_v := stb_cnt_v + 2;
      elsif hblank_s = '0' and vblank_s = '0' then    
        --stb_cnt_v := EXT("1", stb_cnt_v'length);
        stb_cnt_v := (others => '1');
      end if;
      x <= EXT(x_s(x_s'left downto H_SCALE-1), x'length);
      y <= EXT(y_s(y_s'left downto V_SCALE-1), y'length);
      -- register video outputs
      if hactive_v = '1' and vactive_v = '1' then
        -- active video
        video_o.rgb <= rgb_i;
      elsif hblank_v = '0' and vblank_v = '0' then
        -- border
        video_o.rgb <= border_rgb_r;
      else
        video_o.rgb.r <= (others => '0');
        video_o.rgb.g <= (others => '0');
        video_o.rgb.b <= (others => '0');
      end if;
      video_o.hsync <= not hsync_v;
      video_o.vsync <= not vsync_v;
      video_o.hblank <= hblank_v;
      video_o.vblank <= vblank_v;
      -- pipelined signals
      hsync_v_r := hsync_v_r(hsync_v_r'left-1 downto 0) & hsync_s;
      vsync_v_r := vsync_v_r(vsync_v_r'left-1 downto 0) & vsync_s;
      hactive_v_r := hactive_v_r(hactive_v_r'left-1 downto 0) & hactive_s;
      vactive_v_r := vactive_v_r(vactive_v_r'left-1 downto 0) & vactive_s;
      hblank_v_r := hblank_v_r(hblank_v_r'left-1 downto 0) & hblank_s;
      vblank_v_r := vblank_v_r(vblank_v_r'left-1 downto 0) & vblank_s;
    end if;
  end process;
  
end SYN;
