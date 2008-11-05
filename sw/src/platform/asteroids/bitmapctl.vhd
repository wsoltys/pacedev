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
  
  alias rgb       : RGB_t is ctl_o.rgb;
  
begin

	-- these are constant for a whole line
	ctl_o.a(15) <= '0';
	ctl_o.a(14 downto 6) <= y(8 downto 0);

  -- generate pixel
  process (clk)

		variable pel : std_logic;
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

			if hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read bitmap data
				ctl_o.a(5 downto 0) <= x(8 downto 3);

				-- each byte contains information for 8 pixels
				case x(2 downto 0) is
	        when "000" =>
	          pel := ctl_i.d(6);
	        when "001" =>
	          pel := ctl_i.d(7);
	        when "010" =>
	          pel := ctl_i.d(0);
	        when "011" =>
	          pel := ctl_i.d(1);
	        when "100" =>
	          pel := ctl_i.d(2);
	        when "101" =>
	          pel := ctl_i.d(3);
	        when "110" =>
	          pel := ctl_i.d(4);
	        when others =>
	          pel := ctl_i.d(5);
				end case;

				-- slight blue tinge
				rgb.r <= (rgb.r'left-2 => '0', others => pel);
				rgb.g <= (rgb.g'left-2 => '0', others => pel);
				rgb.b <= (others => pel);
				
			end if; -- hblank = '0'
				
		end if;				

  end process;

	ctl_o.set <= '1';

end SYN;

