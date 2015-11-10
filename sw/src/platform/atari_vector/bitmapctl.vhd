library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Asteroids Bitmap Controller
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
	ctl_o.a(15) <= '0';
	ctl_o.a(14 downto 6) <= y(8 downto 0);

  -- generate pixel
  process (clk)

		variable pel : std_logic_vector(2 downto 0);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

			if hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read bitmap data
				ctl_o.a(5 downto 0) <= x(8 downto 3);

				-- each 24-bit word contains information for 8 pixels, 3bpp
				case x(2 downto 0) is
	        when "000" =>
	          pel := ctl_i.d(20 downto 18);
	        when "001" =>
	          pel := ctl_i.d(23 downto 21);
	        when "010" =>
	          pel := ctl_i.d(2 downto 0);
	        when "011" =>
	          pel := ctl_i.d(5 downto 3);
	        when "100" =>
	          pel := ctl_i.d(8 downto 6);
	        when "101" =>
	          pel := ctl_i.d(11 downto 9);
	        when "110" =>
	          pel := ctl_i.d(14 downto 12);
	        when others =>
	          pel := ctl_i.d(17 downto 15);
				end case;

				-- slight blue tinge
				rgb.r <= (others => pel(2));
				rgb.g <= (others => pel(1));
				rgb.b <= (others => pel(0));
				
			end if; -- hblank = '0'
				
		end if;				

  end process;

	ctl_o.set <= '1';

end architecture BITMAP_1;

