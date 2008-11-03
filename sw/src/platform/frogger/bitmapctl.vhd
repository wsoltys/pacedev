library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Frogger Background Generator
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

  alias rgb       : RGB_t is ctl_o.rgb;
  
	signal clk_ena_s : std_logic;
	
begin

  process (clk, reset)
  begin

    if reset = '1' then
      null;
    elsif rising_edge (clk) then
      rgb.r <= (others => '0'); rgb.g <= (others => '0'); rgb.b <= (others => '0');

      if (vblank /= '1') and (hblank /= '1') then
        if (video_ctl.y(7) = '0') then
          rgb.b(rgb.b'left downto rgb.b'left-1) <= "01";
        end if;
      end if; -- hblank = '1'
    end if; -- rising_edge(clk)

  end process;

	ctl_o.a <= (others => '0');
	ctl_o.set <= '1';
	
end SYN;

