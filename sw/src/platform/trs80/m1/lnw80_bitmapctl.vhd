library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

--
--	LNW80 Hires Graphics Bitmap Controller
--  - modes 1-3
--

architecture BITMAP_2 of bitmapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  -- LNW80
  alias gfxram_ena  : std_logic is graphics_i.bit8(1)(3);
  alias gfxmode     : std_logic_vector(1 downto 0) is graphics_i.bit8(1)(2 downto 1);
  alias inverse_ena : std_logic is graphics_i.bit8(1)(0);

  signal hblank_r : std_logic_vector(DELAY-1 downto 0) := (others => '0');
  
begin

  -- generate pixel
  process (clk, clk_ena, reset)

		--variable hblank_r		: std_logic_vector(DELAY-1 downto 0);
		alias hblank_prev		  : std_logic is hblank_r(hblank_r'left);
		alias hblank_v			  : std_logic is hblank_r(hblank_r'left-1);
    variable chr_v        : integer range 0 to 79;
		variable pixel_v      : integer range 0 to 5;
		variable row_v			  : integer range 0 to 11;
		variable line_v			  : integer range 0 to 15;
		variable bitmap_d_v   : std_logic_vector(7 downto 0) := (others => '0');
		
  begin
  
    -- not used
    ctl_o.a(ctl_o.a'left downto 14) <= (others => '0');

		if reset = '1' then
			hblank_r <= (others => '1');
  	elsif rising_edge(clk) then
      if clk_ena = '1' then

        -- handle vertical count
        if vblank = '1' then
          row_v := 0;
          line_v := 0;
        elsif hblank_v = '1' and hblank_prev = '0' then
          if row_v = 11 then
            line_v := line_v + 1;
            row_v := 0;
          else
            row_v := row_v + 1;
          end if;
          -- fixed for the line
          ctl_o.a(11 downto 10) <= std_logic_vector(to_unsigned(row_v,4))(1 downto 0);
          ctl_o.a(9 downto 6) <= std_logic_vector(to_unsigned(line_v,4));
          --vcount(6+PACE_VIDEO_V_SCALE downto -1+PACE_VIDEO_V_SCALE);
        end if;

        -- handle horiztonal count (part 1)
        if hblank = '1' then
          chr_v := 0;
          pixel_v := 0;
        end if;
      
        -- 1st stage of pipeline
        -- - read tile from tilemap
        if stb = '1' then
          if chr_v < 64 then
            -- "inner" region
            ctl_o.a(13 downto 12) <= std_logic_vector(to_unsigned(row_v,4))(3 downto 2);
            ctl_o.a(5 downto 0) <= std_logic_vector(to_unsigned(chr_v,7))(5 downto 0);
          else
            -- "outer" region
            ctl_o.a(13 downto 12) <= "11";
            ctl_o.a(5 downto 4) <= std_logic_vector(to_unsigned(row_v,4))(3 downto 2);
            ctl_o.a(3 downto 0) <= std_logic_vector(to_unsigned(chr_v,7))(3 downto 0);
          end if;
        end if;

        -- 2nd stage of pipeline
        -- - latch bitmap data
        -- (each byte contains information for 8 pixels)
        if pixel_v = 5 then
          bitmap_d_v := ctl_i.d;
        end if;

        -- green-screen display
        ctl_o.rgb.r <= (others => '0');
        ctl_o.rgb.g <= (others => bitmap_d_v(0));
        ctl_o.rgb.b <= (others => '0');
        ctl_o.set <= bitmap_d_v(0);

        if stb = '1' then
          bitmap_d_v := '0' & bitmap_d_v(bitmap_d_v'left downto 1);
          -- handle horiztonal count (part 2)
          if pixel_v = 5 then
            pixel_v := 0;
          else
            pixel_v := pixel_v + 1;
          end if;
        end if;
        
        -- for end-of-line detection
        hblank_r <= hblank_r(hblank_r'left-1 downto 0) & hblank;
      
      end if; -- clk_ena='1'
		end if; -- rising_edge(clk)
  end process;
  
end architecture BITMAP_2;
