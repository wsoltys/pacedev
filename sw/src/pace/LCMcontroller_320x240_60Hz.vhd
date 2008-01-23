library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

architecture LCM_320X240_60HZ of pace_video_controller is

	-- derived constants

  constant VIDEO_H_SIZE       : integer := PACE_VIDEO_H_SIZE * PACE_VIDEO_H_SCALE;
  constant VIDEO_V_SIZE       : integer := PACE_VIDEO_V_SIZE * PACE_VIDEO_V_SCALE;

	constant H_BORDER						: integer := ((320-VIDEO_H_SIZE)*3+2)/(2*3);
	constant V_BORDER						: integer := 0; --(240-VIDEO_V_SIZE)/2;

  constant V_SCROLL           : integer := 80;

  -- Horizontal Parameter	( Pixel )
  constant H_SYNC_CYC	: integer :=	1;
  constant H_SYNC_BACK : integer :=	152 + H_BORDER*3;
  constant H_SYNC_ACT : integer 	:=	960;
  constant H_SYNC_FRONT : integer :=	59 + H_BORDER*3;
  constant H_SYNC_TOTAL : integer :=	1171;
  -- Vertical Parameter		( Line )
  constant V_SYNC_CYC : integer 	:=	1;
  constant V_SYNC_BACK : integer 	:=	14 + V_BORDER;
  constant V_SYNC_ACT : integer 	:=	240;
  constant V_SYNC_FRONT : integer :=	8 + V_BORDER;
  constant V_SYNC_TOTAL : integer :=	262;

  signal tdat       : std_logic_vector(9 downto 0);
  signal mod_3      : std_logic_vector(1 downto 0);
  signal init       : std_logic;
  signal h, v       : integer;
  signal hdraw      : std_logic;
  signal vdraw      : std_logic;
begin

  tdat <= r_i when mod_3 = "00" else
          g_i when mod_3 = "01" else
          b_i;
  lcm_data <= tdat when hdraw = '1' and vdraw = '1' else (others => '0');
	red <= r_i when hdraw = '1' and vdraw = '1' else (others => '0');
	green <= g_i when hdraw = '1' and vdraw = '1' else (others => '0');
	blue <= b_i when hdraw = '1' and vdraw = '1' else (others => '0');

  -- Calculate H and V draw area
  hdraw <= '1' when (h >= H_SYNC_BACK and h < (H_SYNC_TOTAL-H_SYNC_FRONT)) else '0';
  vdraw <= '1' when (v >= V_SYNC_BACK and v < (V_SYNC_TOTAL-V_SYNC_FRONT)) else '0';

  -- Generate reset
  grst_proc : process(clk, reset)
    variable grst_cnt     : integer;
    variable grst_done    : std_logic;
    variable grst_r       : std_logic;
    constant CLOCK_RATE   : integer := 27;         -- 27MHz clocks per us (worst case)
    constant DELAY_RESET  : integer := 10000;      -- 10ms delay
    constant GRST_TIME    : integer := 1;          -- 1us assert grst
  begin
    init <= not grst_done;
    --grst <= grst_r;

    if reset = '1' then
      grst_cnt := 0;
      grst_done := '0';
      grst_r := '0';

    elsif rising_edge(clk) then
      if grst_done = '0' then
        grst_cnt := grst_cnt + 1;
      end if;

      grst_r := '0';
      if (grst_done = '0') and (grst_cnt >= CLOCK_RATE*DELAY_RESET) then
        grst_r := '1';
      end if;
      grst_done := '1';
      if grst_cnt < CLOCK_RATE*(DELAY_RESET+GRST_TIME) then
        grst_done := '0';
      end if;
    end if;
  end process;

  -- VSYNC and HSYNC timings
  process(clk, init)
    variable mod_3_r      : std_logic_vector(1 downto 0);
    variable pre_mod_3_r  : std_logic_vector(1 downto 0);
		variable data_r				: std_logic_vector(7 downto 0);
    variable strobe_r     : std_logic;
    variable hsync_r      : std_logic_vector(delay downto 0);
    variable vsync_r      : std_logic_vector(delay downto 0);
    variable hblank_r     : std_logic;
    variable vblank_r     : std_logic;
    variable grst_cnt     : integer;
    variable h_cnt        : integer;
    variable v_cnt        : integer;
    variable x_cnt        : integer;
    variable y_cnt        : integer;
    variable yoffs        : integer;
  begin
    h <= h_cnt;
    v <= v_cnt;

    hsync <= hsync_r(delay);
    vsync <= vsync_r(delay);
    hblank <= hblank_r;
    vblank <= vblank_r;

    mod_3 <= mod_3_r;
    strobe <= strobe_r;

    pixel_x <= std_logic_vector(conv_unsigned(x_cnt, pixel_x'length));
    pixel_y <= std_logic_vector(conv_unsigned(y_cnt, pixel_y'length));

    if init = '1' then
      mod_3_r  := "00";
      h_cnt    := 0;
      v_cnt    := 0;
      hsync_r  := (others => '0');
      vsync_r  := (others => '0');
      hblank_r := '0';
      vblank_r := '0';
      yoffs    := 0;

    elsif rising_edge(clk) then
      -- Sync pipeline delays
      if delay > 0 then
        hsync_r(delay downto 1) := hsync_r(delay-1 downto 0);
        vsync_r(delay downto 1) := vsync_r(delay-1 downto 0);
      end if;

      -- Blanking signals come from hdraw and vdraw
      hblank_r := not hdraw;
      vblank_r := not vdraw;

      -- Calculate colour select, X offset and data strobe
      if hdraw = '1' and vdraw = '1' then
        -- Data strobe
        if mod_3 = "01" and pre_mod_3_r = "00" then
          strobe_r := '1';
        else
          strobe_r := '0';
        end if;

        -- X counter
        if mod_3 = "10" and pre_mod_3_r = "01" then
          x_cnt := x_cnt + 1;
        end if;

        -- Colour select
        if mod_3_r < "10" then
          mod_3_r := mod_3_r + 1;
        else
          mod_3_r := "00";
        end if;
      else
        -- During non-drawing time, zero everything
        mod_3_r := "00";
        strobe_r := '0';
        x_cnt := 0;
      end if;

			-- Calculate y offset directly from v_cnt
      if v_cnt > V_SYNC_BACK+1 and v_cnt < (V_SYNC_TOTAL-V_SYNC_FRONT+1) then
        y_cnt := v_cnt-(V_SYNC_BACK)+yoffs;
      else
        y_cnt := v_cnt-(V_SYNC_BACK)+yoffs;
      end if;

      -- Generate vsync
  		if h_cnt = 0 then
        -- Line counter
  			if v_cnt < V_SYNC_TOTAL then
  			  v_cnt	:=	v_cnt+1;
  			else
  			  v_cnt	:=	0;
        end if;

        -- Vsync
  			if v_cnt < V_SYNC_CYC then
  			  vsync_r(0)	:=	'0';
  			else
  			  vsync_r(0)	:=	'1';
        end if;

        -- Vblank
        --if v_cnt < V_SYNC_ACT then
        --  vblank_r := '0';
        --else
        --  vblank_r := '1';
        --end if;
  		end if;

      -- Pixel counter
  		if h_cnt < H_SYNC_TOTAL then
  		  h_cnt	:=	h_cnt+1;
  		else
  		  h_cnt	:=	0;
      end if;

      -- Hsync
  		if h_cnt < H_SYNC_CYC then
  		  hsync_r(0)	:=	'0';
  		else
  		  hsync_r(0)	:=	'1';
      end if;

      -- Hblank
      --if h_cnt < H_SYNC_ACT then
      --  hblank_r := '0';
      --else
      --  hblank_r := '1';
      --end if;

      -- Calculate y draw offset
      if (ycentre > yoffs + V_SYNC_ACT-V_SCROLL) 
					and (yoffs < PACE_VIDEO_V_SIZE-V_SYNC_ACT) then
        yoffs := yoffs + 1;
      elsif (ycentre < yoffs + V_SCROLL)
					and (yoffs > 0) then
        yoffs := yoffs - 1;
      end if;

      -- Save previous mod_3
   		pre_mod_3_r	:=	mod_3;
    end if;
  end process;

end LCM_320X240_60HZ;
