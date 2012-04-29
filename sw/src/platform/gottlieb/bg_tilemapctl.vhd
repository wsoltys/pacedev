library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Gottlieb Tilemap Controller
--
--	Tile data is 2 BPP/ROM = 4BPP
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

	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 10) <= (others => '0');
  ctl_o.map_a(4 downto 0) <= y(7 downto 3);
  ctl_o.tile_a(ctl_o.tile_a'left downto 12) <= (others => '0');

  -- generate attribute RAM address (same, different memory bank)
  ctl_o.attr_a(ctl_o.map_a'left downto 10) <= (others => '0');
  ctl_o.attr_a(4 downto 0) <= y(7 downto 3);
  
  -- generate pixel
  process (clk, clk_ena)

    variable attr_i     : std_logic_vector(6 downto 0);
		variable pal_i      : integer range 0 to 127;
		variable pel        : std_logic_vector(3 downto 0);
		--variable pal_entry  : pal_entry_typ;

		variable x_adj		  : unsigned(x'range);
    variable tile_d_r   : std_logic_vector(15 downto 0);
		variable attr_d_r	  : std_logic_vector(7 downto 0);

  begin

  	if rising_edge(clk) and clk_ena = '1' then

			-- video is clipped left and right (only 224 wide)
			x_adj := unsigned(x); -- + (256-PACE_VIDEO_H_SIZE)/2;
				
      -- 1st stage of pipeline
      -- - read tile from tilemap
      -- - read attribute data
      if stb = '1' then
        ctl_o.map_a(9 downto 5) <= std_logic_vector(x_adj(7 downto 3));
        ctl_o.attr_a(9 downto 5) <= not std_logic_vector(x_adj(7 downto 3));
      end if;
      
      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      if stb = '1' then
        if x_adj(2 downto 0) = "010" then
          attr_d_r := ctl_i.attr_d(7 downto 0);
        end if;
      end if;
      ctl_o.tile_a(11 downto 4) <= ctl_i.map_d(7 downto 0); -- each tile is 16 bytes/rom
      ctl_o.tile_a(3 downto 1) <= y(2 downto 0);
      ctl_o.tile_a(0) <= x_adj(2);
      
      if stb = '1' then
        if x_adj(1 downto 0) = "01" then
          tile_d_r := ctl_i.tile_d(15 downto 0);
        else
          tile_d_r := tile_d_r(13 downto 8) & "00" &
                      tile_d_r(5 downto 0) & "00";
        end if;
      end if;
      pel := tile_d_r(15 downto 14) & tile_d_r(7 downto 6);
      
      -- extract R,G,B from colour palette
      --attr_i := attr_d_r(1 downto 0) & tile_d_r(7) & attr_d_r(5 downto 2);
      attr_i := attr_d_r(1 downto 0) & attr_d_r(4) & pel;
      pal_i := to_integer(unsigned(attr_i));
      --pal_entry := pal(pal_i);
      ctl_o.rgb.r <= pel & "000000";
      ctl_o.rgb.g <= pel & "000000";
      ctl_o.rgb.b <= pel & "000000";
      
		end if;				

    ctl_o.set <= '1';

  end process;

end TILEMAP_1;
