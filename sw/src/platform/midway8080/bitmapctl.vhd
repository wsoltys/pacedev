library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Midway 8080 Bitmap Controller
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
	ctl_o.a(15 downto 13) <= (others => '0');
  ctl_o.a(12 downto 8) <= y(7 downto 3);

  -- generate pixel
  process (clk)

		variable pel : std_logic;
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read tile from tilemap
      -- - read attribute data
      if stb = '1' then
        ctl_o.a(7 downto 0) <= x(7 downto 0);
      end if;

      -- each byte contains information for 8 pixels
      case y(2 downto 0) is
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

      -- emulate the coloured cellophane overlays
      rgb.r <= (others => '0');
      rgb.g <= (others => '0');
      rgb.b <= (others => '0');
      if pel = '1' then
        if y(7 downto 3) < "00100" then
          -- white
          rgb.r(9 downto 8) <= "11";
          rgb.g(9 downto 8) <= "11";
          rgb.b(9 downto 8) <= "11";
        elsif y(7 downto 3) < "01000" then
          rgb.r(9 downto 8) <= "11";	-- red
        elsif y(7 downto 3) < "10111" then
          -- white
          rgb.r(9 downto 8) <= "11";
          rgb.g(9 downto 8) <= "11";
          rgb.b(9 downto 8) <= "11";
        elsif y(7 downto 3) < "11110" then
          rgb.g(9 downto 8) <= "11";	-- green
        else
          -- pix_count(7..3) is the character X position
          if x(7 downto 3) < 2 then
            -- white
            rgb.r(9 downto 8) <= "11";
            rgb.g(9 downto 8) <= "11";
            rgb.b(9 downto 8) <= "11";
          elsif x(7 downto 3) < 17 then
            rgb.g(9 downto 8) <= "11";	-- green
          else
            -- white
            rgb.r(9 downto 8) <= "11";
            rgb.g(9 downto 8) <= "11";
            rgb.b(9 downto 8) <= "11";
          end if;
        end if;
      else
        null; -- black
      end if;
      
		end if; -- rising_edge(clk)

  end process;

	ctl_o.set <= '1';

end architecture SYN;

