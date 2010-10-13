library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	TPG Bitmap Controller
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

  process (clk)
    variable x_i : integer range 0 to 2047;
    variable y_i : integer range 0 to 2047;
  begin
    x_i := to_integer(unsigned(x));
    y_i := to_integer(unsigned(y));
  	if rising_edge(clk) then
      if clk_ena = '1' then
        if y(5 downto 2) = "1111" then
          ctl_o.rgb.r <= (others => '0');
          ctl_o.rgb.g <= (others => '0');
          ctl_o.rgb.b <= (others => '0');
        elsif y_i < 64 then
          ctl_o.rgb.r <= not x(8 downto 0) & '0';
          ctl_o.rgb.g <= not x(8 downto 0) & '0';
          ctl_o.rgb.b <= not x(8 downto 0) & '0';
        elsif y_i < 128 then
          ctl_o.rgb.r <= not x(8 downto 0) & '0';
          ctl_o.rgb.g <= (others => '0');
          ctl_o.rgb.b <= (others => '0');
        elsif y_i < 192 then
          ctl_o.rgb.r <= (others => '0');
          ctl_o.rgb.g <= not x(8 downto 0) & '0';
          ctl_o.rgb.b <= (others => '0');
        elsif y_i < 256 then
          ctl_o.rgb.r <= (others => '0');
          ctl_o.rgb.g <= (others => '0');
          ctl_o.rgb.b <= not x(8 downto 0) & '0';
        else
          if x(6 downto 2) = "11111" then
            ctl_o.rgb.r <= (others => '0');
            ctl_o.rgb.g <= (others => '0');
            ctl_o.rgb.b <= (others => '0');
          elsif x_i < 128 then
            ctl_o.rgb.r <= y(7 downto 6) & "00000000";
            ctl_o.rgb.g <= y(7 downto 6) & "00000000";
            ctl_o.rgb.b <= y(7 downto 6) & "00000000";
          elsif x_i < 256 then
            ctl_o.rgb.r <= y(7 downto 6) & "00000000";
            ctl_o.rgb.g <= (others => '0');
            ctl_o.rgb.b <= (others => '0');
          elsif x_i < 384 then
            ctl_o.rgb.r <= (others => '0');
            ctl_o.rgb.g <= y(7 downto 6) & "00000000";
            ctl_o.rgb.b <= (others => '0');
          else
            ctl_o.rgb.r <= (others => '0');
            ctl_o.rgb.g <= (others => '0');
            ctl_o.rgb.b <= y(7 downto 6) & "00000000";
          end if;
        end if;
      end if; -- clk_ena='1'
		end if; -- rising_edge(clk)
  end process;

	ctl_o.set <= '1';

end architecture SYN;

