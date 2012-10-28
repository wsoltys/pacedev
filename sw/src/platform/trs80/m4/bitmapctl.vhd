library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	TRS-80 Microlabs Model III Hires Graphics Bitmap Controller
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

	-- these are constant for a whole line
	ctl_o.a(ctl_o.a'left downto 14) <= (others => '0');
  ctl_o.a(13 downto 6) <= y(7 downto 0);

  -- generate pixel
  process (clk)

		variable x_r	  : std_logic_vector(2*3-1 downto 0);
		variable pel_r  : std_logic_vector(DELAY-1-2 downto 0); -- 2 from above
		alias pel       : std_logic is pel_r(pel_r'right);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read tile from tilemap
      if stb = '1' then
        ctl_o.a(5 downto 0) <= x(8 downto 3);
      end if;

      -- pipeline pel by 2 clocks
      pel_r(pel_r'left downto 1) := pel_r(pel_r'left-1 downto 0);

      -- each byte contains information for 8 pixels
      case x_r(x_r'left downto x_r'left-2) is
        when "000" =>
          pel := ctl_i.d(7);
        when "001" =>
          pel := ctl_i.d(6);
        when "010" =>
          pel := ctl_i.d(5);
        when "011" =>
          pel := ctl_i.d(4);
        when "100" =>
          pel := ctl_i.d(3);
        when "101" =>
          pel := ctl_i.d(2);
        when "110" =>
          pel := ctl_i.d(1);
        when others =>
          pel := ctl_i.d(0);
      end case;

      -- green-screen display
      ctl_o.rgb.r <= (others => '0');
      ctl_o.rgb.g <= (others => pel_r(pel_r'left));
      ctl_o.rgb.b <= (others => '0');
      
			-- pipelined because of tile data loopkup
      x_r := x_r(x_r'left-3 downto 0) & x(2 downto 0);

      ctl_o.set <= pel_r(pel_r'left);

		end if; -- rising_edge(clk)

  end process;

  -- may need to pipeline video to match tilemap
  
end architecture BITMAP_1;

