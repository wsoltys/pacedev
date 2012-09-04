library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;
use work.video_controller_pkg.all;

--
--	Moon Patrol Cityscape Renderer
--

architecture BITMAP_1 of bitmapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_en    : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  alias rgb       : RGB_t is ctl_o.rgb;
  
begin

  process (clk, reset)
    variable bitmap_d_r   : std_logic_vector(7 downto 0);
		variable pel          : std_logic_vector(1 downto 0);
    variable pal_i        : std_logic_vector(4 downto 0);
		variable pal_entry    : pal_entry_typ;
  begin
		if reset = '1' then
		elsif rising_edge (clk) then
      -- default
      ctl_o.set <= '0';
      -- same for a whole line
      ctl_o.a(11 downto 6) <= y(5 downto 0);
      if clk_en = '1' then
        if y > 63 and y < 64+64 then
          ctl_o.a(5 downto 0) <= x(7 downto 2);
          if hblank = '0' then
            if x(1 downto 0) = "01" then
              bitmap_d_r := ctl_i.d(7 downto 0);
            else
              bitmap_d_r := bitmap_d_r(6 downto 0) & '0';
            end if;
            pel := bitmap_d_r(7) & bitmap_d_r(3);
            pal_i := "001" & pel;
            pal_entry := pal(to_integer(unsigned(pal_i)));
            ctl_o.rgb.r <= pal_entry(0) & "0000";
            ctl_o.rgb.g <= pal_entry(1) & "0000";
            ctl_o.rgb.b <= pal_entry(2) & "0000";
            if 	pel /= "00" then
              ctl_o.set <= '1';
            end if;
          end if; -- hblank='0'
        end if; -- y<64
      end if; -- clk_en='1'
    end if; -- rising_edge(clk)
  end process;

  -- unused
  ctl_o.a(ctl_o.a'left downto 12) <= (others => '0');
	
end architecture BITMAP_1;
