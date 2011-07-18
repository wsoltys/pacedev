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
--	TRS-80 Model I Lowe Electronics LE18 Hires Graphics Bitmap Controller
--

architecture BITMAP_1 of bitmapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  alias le18_en     : std_logic is graphics_i.bit8(0)(6);
  alias pcg80_en_hi : std_logic is graphics_i.bit8(0)(5);
  alias pcg80_en_lo : std_logic is graphics_i.bit8(0)(4);
  alias alt_char    : std_logic is graphics_i.bit8(0)(3);
  alias dbl_width   : std_logic is graphics_i.bit8(0)(2);

  signal hblank_r : std_logic_vector(DELAY-1 downto 0) := (others => '0');
  
begin

  -- generate pixel
  process (clk, clk_ena, reset)

		--variable hblank_r		: std_logic_vector(DELAY-1 downto 0);
		alias hblank_prev		  : std_logic is hblank_r(hblank_r'left);
		alias hblank_v			  : std_logic is hblank_r(hblank_r'left-1);
		variable hcount       : std_logic_vector(8 downto 0);
		variable vcount			  : std_logic_vector(8 downto 0);
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
          vcount := (others => '0');
        elsif hblank_v = '1' and hblank_prev = '0' then
          vcount := vcount + 1;
          -- fixed for the line
          ctl_o.a(13 downto 6) <= 
            vcount(6+PACE_VIDEO_V_SCALE downto -1+PACE_VIDEO_V_SCALE);
        end if;

        -- handle horiztonal count (part 1)
        if hblank = '1' then
          hcount := (others => '0');
        end if;
      
        -- 1st stage of pipeline
        -- - read tile from tilemap
        if stb = '1' then
          ctl_o.a(5 downto 0) <= hcount(8 downto 3);
        end if;

        -- 2nd stage of pipeline
        -- - latch bitmap data
        -- (each byte contains information for 8 pixels)
        if hcount(2 downto 0) = "101" then
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
          if hcount(2 downto 0) = "101" then
            hcount := hcount + 3;
          else
            hcount := hcount + 1;
          end if;
        end if;
        
        -- for end-of-line detection
        hblank_r <= hblank_r(hblank_r'left-1 downto 0) & hblank;
      
      end if; -- clk_ena='1'
		end if; -- rising_edge(clk)
  end process;
  
end architecture BITMAP_1;
