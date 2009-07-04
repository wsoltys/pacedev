library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Williams Defender Bitmap Controller
--

entity bitmapCtl_1 is          
  generic
  (
    DELAY         : integer
  );
  port               
  (
    reset					: in std_logic;

    -- video control signals		
    video_ctl     : in from_VIDEO_CTL_t;

    -- bitmap controller signals
    ctl_i         : in to_BITMAP_CTL_t;
    ctl_o         : out from_BITMAP_CTL_t;

    graphics_i    : in to_GRAPHICS_t
  );
end entity bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  alias scroll    : std_logic_vector(7 downto 0) is graphics_i.bit8_1;
  
  alias rgb       : RGB_t is ctl_o.rgb;
  
begin

	-- constant for a whole line
	ctl_o.a(6 downto 0) <= not y(7 downto 1);

  -- generate pixel
  process (clk, reset)

		variable pel 				: std_logic_vector(3 downto 0);
		variable pal_entry 	: std_logic_vector(15 downto 0);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read data from bitmap
      if video_ctl.stb = '1' then
        if (y < 64) then
          ctl_o.a(14 downto 7) <= x(7 downto 0) + 16;
        else
          ctl_o.a(14 downto 7) <= x(7 downto 0) + 16 + scroll;
        end if;
      end if;
      
      case y(0) is
        when '0' =>
          pel := ctl_i.d(7 downto 4);
        when others =>
          pel := ctl_i.d(3 downto 0);
      end case;
                
      -- extract R,G,B from colour palette
      pal_entry := graphics_i.pal(conv_integer(pel));
      rgb.r <= pal_entry(2 downto 0) & "0000000";
      rgb.g <= pal_entry(5 downto 3) & "0000000";
      rgb.b <= pal_entry(7 downto 6) & "00000000";
				
		end if;				

    ctl_o.set <= '1';

  end process;

end SYN;
