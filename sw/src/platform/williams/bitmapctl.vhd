library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Williams Defender Bitmap Controller
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
	ctl_o.a(7 downto 0) <= y(7 downto 0);	

  -- generate pixel
  process (clk, reset)

    variable d          : std_logic_vector(7 downto 0);
		alias pel 				  : std_logic_vector(3 downto 0) is d(7 downto 4);
		variable pal_entry 	: std_logic_vector(7 downto 0);
		
  begin
  	if rising_edge(clk) then
      if clk_ena = '1' then

        if video_ctl.stb = '1' then
          -- set the bitmap address
          ctl_o.a(15 downto 8) <= x(8 downto 1);
          -- read/shift bitmap data
          if x(0) = '1' then
            d := ctl_i.d(7 downto 0);
          else
            d := d(3 downto 0) & X"0";
          end if;
        end if;
        
        -- extract R,G,B from colour palette
        pal_entry := graphics_i.pal(conv_integer(pel))(pal_entry'range);
        rgb.r <= pal_entry(2 downto 0) & "0000000";
        rgb.g <= pal_entry(5 downto 3) & "0000000";
        rgb.b <= pal_entry(7 downto 6) & "00000000";
        
      end if; -- clk_ena
		end if; -- rising_edge(clk)

    ctl_o.set <= '1';

  end process;

end BITMAP_1;
