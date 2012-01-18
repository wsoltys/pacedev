library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Apple Macintosh (128K) Bitmap Controller
--

architecture BITMAP_1 of bitmapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  alias rgb       : RGB_t is ctl_o.rgb;
  
begin

	-- constant for a whole line
  ctl_o.a(ctl_o.a'left downto 14) <= (others => '0');
	ctl_o.a(13 downto 5) <= y(8 downto 0);	

  -- generate pixel
  process (clk, reset)

    variable d          : std_logic_vector(to_BITMAP_CTL_t.d'range);
		alias pel 				  : std_logic is d(d'left);
		
  begin
  	if rising_edge(clk) then
      if clk_ena = '1' then

        if video_ctl.stb = '1' then
          -- set the bitmap address
          ctl_o.a(4 downto 0) <= x(8 downto 4);
          -- read/shift bitmap data
          if x(3 downto 0) = "0010" then
            d := ctl_i.d(7 downto 0) & ctl_i.d(15 downto 8);
          else
            d := d(d'left-1 downto 0) & '0';
          end if;
        end if;
        
        -- extract R,G,B from colour palette
        rgb.r <= (others => not pel);
        rgb.g <= (others => not pel);
        rgb.b <= (others => not pel);
        
      end if; -- clk_ena
		end if; -- rising_edge(clk)

    ctl_o.set <= '1';

  end process;

end BITMAP_1;
