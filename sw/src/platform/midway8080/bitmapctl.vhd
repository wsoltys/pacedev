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
	ctl_o.a(15 downto 13) <= (others => '0');
  ctl_o.a(12 downto 8) <= y(7 downto 3);

  -- generate pixel
  process (clk)

		variable pel : std_logic;
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read tile from tilemap
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
          rgb.r(9 downto 0) <= (others => '1');
          rgb.g(9 downto 0) <= (others => '1');
          rgb.b(9 downto 0) <= (others => '1');
        elsif y(7 downto 3) < "01000" then
          rgb.r(9 downto 0) <= (others => '1');	-- red
        elsif y(7 downto 3) < "10111" then
          -- white
          rgb.r(9 downto 0) <= (others => '1');
          rgb.g(9 downto 0) <= (others => '1');
          rgb.b(9 downto 0) <= (others => '1');
        elsif y(7 downto 3) < "11110" then
          rgb.g(9 downto 0) <= (others => '1');	-- green
        else
          -- pix_count(7..3) is the character X position
          if x(7 downto 3) < 2 then
            -- white
            rgb.r(9 downto 0) <= (others => '1');
            rgb.g(9 downto 0) <= (others => '1');
            rgb.b(9 downto 0) <= (others => '1');
          elsif x(7 downto 3) < 17 then
            rgb.g(9 downto 0) <= (others => '1');	-- green
          else
            -- white
            rgb.r(9 downto 0) <= (others => '1');
            rgb.g(9 downto 0) <= (others => '1');
            rgb.b(9 downto 0) <= (others => '1');
          end if;
        end if;
      else
        null; -- black
      end if;
      
		end if; -- rising_edge(clk)

  end process;

	ctl_o.set <= '1';

end architecture BITMAP_1;

