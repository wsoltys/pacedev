library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Frogger (Blue) Background Generator
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

	process (clk, reset)
	begin
		if reset = '1' then
    	null;
		elsif rising_edge(clk) then
    	rgb <= ((others => '0'), (others => '0'), (others => '0'));
      if hblank = '0' then
        if x < 128+8+PACE_VIDEO_PIPELINE_DELAY then
          rgb.b <= X"47" & "00";
        end if;
      end if;
		end if;
	end process;

	ctl_o.a <= (others => '0');
	ctl_o.set <= '1';
	
end architecture BITMAP_1;
