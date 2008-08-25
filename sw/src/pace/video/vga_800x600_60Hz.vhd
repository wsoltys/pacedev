library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

architecture VGA_800X600_60HZ of pace_video_controller is

	-- user-defined constants	
	constant H_SIZE							: integer := PACE_VIDEO_H_SIZE * PACE_VIDEO_H_SCALE;
	constant V_SIZE							: integer := PACE_VIDEO_V_SIZE * PACE_VIDEO_V_SCALE;

	constant TEST_PATTERN				: boolean := false;

	-- derived constants
	constant H_BORDER						: integer := (800-H_SIZE)/2;
	constant V_BORDER						: integer := (600-V_SIZE)/2;
			
	-- 40MHz : 800 X 600 60Hz
  constant H_FRONT_PORCH      : integer := 40;
  constant H_HORIZ_SYNC       : integer := H_FRONT_PORCH + 128;
  constant H_BACK_PORCH       : integer := H_HORIZ_SYNC + 88;
  constant H_LEFT_BORDER      : integer := H_BACK_PORCH + H_BORDER;
  constant H_VIDEO            : integer := H_LEFT_BORDER + H_SIZE;
  constant H_RIGHT_BORDER     : integer := H_VIDEO + H_BORDER;
  constant H_TOTAL_PER_LINE   : integer := H_RIGHT_BORDER;

  constant V_FRONT_PORCH      : integer := 1;
  constant V_VERTICAL_SYNC    : integer := V_FRONT_PORCH + 4;
  constant V_BACK_PORCH       : integer := V_VERTICAL_SYNC + 23;
  constant V_TOP_BORDER       : integer := V_BACK_PORCH + V_BORDER;
  constant V_VIDEO            : integer := V_TOP_BORDER + V_SIZE;
  constant V_BOTTOM_BORDER    : integer := V_VIDEO + V_BORDER;
  constant V_TOTAL_PER_FIELD  : integer := V_BOTTOM_BORDER;

  -- signals

	alias clk_40M							  : std_logic is clk;
	signal strobe_s							: std_logic;
  signal hsync_s           		: std_logic;
  signal vsync_s           		: std_logic;
  signal hblank_s          		: std_logic_vector(5 downto 0);
  signal vblank_s          		: std_logic;

	signal test_pixel						: RGB_t;

  --signal active_v_s           : std_logic_vector(8 downto 0);
  --signal count_v_s            : integer;
	
begin

  process (clk_40M, reset)
  	variable count_v : integer range 0 to V_TOTAL_PER_FIELD;
    variable count_h : integer range 0 to H_TOTAL_PER_LINE;
    variable active_h : std_logic_vector(9 downto 0);
    variable active_v : std_logic_vector(9 downto 0);
		variable strobe_cnt : std_logic_vector(3 downto 0);
		variable strobe_r : std_logic;
		variable field		: std_logic;
  begin
    if reset = '1' then

      count_h := H_TOTAL_PER_LINE;
      count_v := V_TOTAL_PER_FIELD;
      active_h := (others => '0');
      active_v := (others => '0');
      hsync_s <= '1';
      vsync_s <= '1';
      hblank_s <= (others => '0');
      vblank_s <= '1';
			strobe_cnt := (others => '0');
			strobe_r := '0';
			strobe_s <= '0';
			field := '1';
			
    elsif rising_edge (clk_40M) then

      if count_h = H_TOTAL_PER_LINE then
        count_h := 0;
        test_pixel.r <= (others => '0');
        test_pixel.b <= (others => '0');
        if count_v = V_TOTAL_PER_FIELD then
          count_v := 0;
          test_pixel.g <= (others => '0');
          vblank_s <= '1';  -- in case V_BORDER=0
					field := not field;
        else
          test_pixel.g <= test_pixel.g + 1;
          if count_v = V_FRONT_PORCH then
            vsync_s <= '0';
          elsif count_v = V_VERTICAL_SYNC then
            vsync_s <= '1';
          elsif (V_BORDER /= 0) and (count_v = V_BACK_PORCH) then
          elsif count_v = V_TOP_BORDER then
            test_pixel.g <= (others => '0');
            vblank_s <= '0';
            active_v :=  (others => '0');
          elsif count_v = V_VIDEO then
            vblank_s <= '1';
					else
          	active_v := active_v + 1;
          end if;
       		count_v := count_v + 1;
        end if;
      else
        test_pixel.r <= test_pixel.r + 1;
				test_pixel.b <= test_pixel.b + 1;
        if count_h = H_FRONT_PORCH then
          hsync_s <= '0';
        elsif count_h = H_HORIZ_SYNC then
          hsync_s <= '1';
        elsif count_h = H_BACK_PORCH then
        elsif count_h = H_LEFT_BORDER then
          test_pixel.r <= (others => '0');
					test_pixel.b <= test_pixel.g;
          hblank_s(0) <= '0';
					-- re-synch strobe at start of active display
					--strobe_cnt := ext("1", strobe_cnt'length);
          active_h := (others => '0');
        elsif count_h = H_VIDEO then
          hblank_s(0) <= '1';
        elsif count_h = H_RIGHT_BORDER then
        else
        	active_h := active_h + 1;
        end if;
        count_h := count_h + 1;
      end if;

			-- generate strobe for graphics controllers
			strobe_cnt := strobe_cnt + 2;
			if PACE_VIDEO_H_SCALE = 1 then
				strobe_s <= '1';
			else
				if strobe_r = '0' then
					strobe_s <= strobe_cnt(PACE_VIDEO_H_SCALE-1);
				else
					strobe_s <= '0';
				end if;
				strobe_r := strobe_cnt(PACE_VIDEO_H_SCALE-1);
			end if;
			
			-- propogate hblank through pipeline
			hblank_s(hblank_s'left downto 1) <= hblank_s(hblank_s'left-1 downto 0);

    end if;

		-- generate graphics controller pixel coordinates
		-- - enable pixel-doubling on horizontal & vertical
		pixel_x <= EXT(active_h(active_h'left downto PACE_VIDEO_H_SCALE-1), pixel_x'length);
		pixel_y <= EXT(active_v(active_v'left downto PACE_VIDEO_V_SCALE-1), pixel_y'length);

    --active_v_s <= active_v;		
    --count_v_s <= count_v;

  end process;

	-- assign colcour data to pixels
  process (clk_40M)
  begin
    if rising_edge(clk_40M) then
      if (hblank_s(hblank_s'left) = '0' and vblank_s = '0') then
				if TEST_PATTERN then
	        red <= test_pixel.r;
	        green <= test_pixel.g;
	        blue <= test_pixel.b;
				else
	        red <= r_i;
	        green <= g_i;
	        blue <= b_i;
				end if;
      else
        red <= (others => '0');
        green <= (others => '0');
        blue <= (others => '0');
      end if;
    end if;
  end process;

	-- assign strobe and sync signals
	strobe <= strobe_s;
  hsync <= not hsync_s;
  vsync <= not vsync_s;
	hblank <= hblank_s(0);
	vblank <= vblank_s;

	lcm_data <= (others => '0');
		
end VGA_800X600_60HZ;

