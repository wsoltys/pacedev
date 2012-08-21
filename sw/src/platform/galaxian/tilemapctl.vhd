library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;
use work.video_controller_pkg.all;

--
--	Galaxian Tilemap Controller
--
--	Tile data is 2 BPP.
--

architecture TILEMAP_1 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
begin

  -- not used
	ctl_o.map_a(ctl_o.map_a'left downto 10) <= (others => '0');
  ctl_o.attr_a(ctl_o.attr_a'left downto 6) <= (others => '0');
  ctl_o.attr_a(0) <= '0'; -- 16-bit side attribute memory
  ctl_o.tile_a(ctl_o.tile_a'left downto 11) <= (others => '0');

	-- these are constant for a whole line
  
  -- generate pixel
  process (clk, clk_ena)

    variable tile_d_r   : std_logic_vector(15 downto 0);
		variable pel        : std_logic_vector(1 downto 0);
    variable pal_i      : std_logic_vector(4 downto 0);
		variable pal_entry  : pal_entry_typ;

    -- attributes, latched at different times
    variable scroll_r   : std_logic_vector(7 downto 0);
    variable colour_r   : std_logic_vector(2 downto 0);

    variable y_adj      : std_logic_vector(7 downto 0);
  
  begin
  	if rising_edge(clk) then
      if clk_ena = '1' then

        -- - set attribute address
        ctl_o.attr_a(5 downto 1) <= x(7 downto 3);

        -- 1st stage of pipeline
        -- - set tilemap address
        if x(2 downto 0) = "010" then
          -- latch attr_d for the 1st time
          scroll_r := ctl_i.attr_d(7 downto 0);  
          y_adj := std_logic_vector(unsigned(y(7 downto 0)) + unsigned(scroll_r));
        end if;
        ctl_o.map_a(9 downto 5) <= y_adj(7 downto 3);
        ctl_o.map_a(4 downto 0) <= x(7 downto 3);
        
        -- 2nd stage of pipeline
        -- - set tile address
        if x(2 downto 0) = "100" then
          ctl_o.tile_a(10 downto 3) <= ctl_i.map_d(7 downto 0);
          ctl_o.tile_a(2 downto 0) <= y_adj(2 downto 0);
        end if;

        -- 3rd stage of pipeline
        -- - read tile data from ROM
        if x(2 downto 0) = "110" then
          -- latch attr_d for the 2nd time
          colour_r := ctl_i.attr_d(10 downto 8);
          tile_d_r := ctl_i.tile_d(tile_d_r'range);
        elsif stb = '1' then
          tile_d_r := tile_d_r(tile_d_r'left-1 downto 0) & '0';
        end if;
        
        -- extract R,G,B from colour palette
        pel := tile_d_r(tile_d_r'left-8) & tile_d_r(tile_d_r'left);
        pal_i := colour_r & pel;
        pal_entry := pal(to_integer(unsigned(pal_i)));
        ctl_o.rgb.r <= pal_entry(0) & "0000";
        ctl_o.rgb.g <= pal_entry(1) & "0000";
        ctl_o.rgb.b <= pal_entry(2) & "0000";

        if 	pal_entry(0)(5 downto 4) /= "00" or
            pal_entry(1)(5 downto 4) /= "00" or
            pal_entry(2)(5 downto 4) /= "00" then
          ctl_o.set <= '1';
        else
          ctl_o.set <= '0';
        end if;

      end if; -- clk_ena
		end if; -- rising_edge_clk

  end process;

end architecture TILEMAP_1;
