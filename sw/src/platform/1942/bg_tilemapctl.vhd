library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	1942 Background Character Tilemap Controller
--
--	Tile data is 4 BPP.
--	Attribute data 7:1 is palette entry
--  Attribute data 0 denotes transparency
--

architecture TILEMAP_2 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
begin

  -- technically, this is actually scroll x
  --y_adj <= std_logic_vector(unsigned(y) + unsigned(graphics_i.bit16(0)(10 downto 0)));
  --y_adj <= std_logic_vector(unsigned(y) + 128+32);
  
	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 9) <= (others => '0');
  ctl_o.map_a(8 downto 4) <= not y(7 downto 4) & '0';
  ctl_o.tile_a(ctl_o.tile_a'left downto 16) <= (others => '0');

  -- generate attribute RAM address (next 16 bytes)
  ctl_o.attr_a(ctl_o.map_a'left downto 9) <= (others => '0');
  ctl_o.attr_a(8 downto 4) <= not y(7 downto 4) & '1';
  
  -- generate pixel
  process (clk)

    variable attr_i     : integer;
		variable pal_i      : integer range 0 to 127;
		variable pel        : std_logic_vector(2 downto 0);
		variable pal_entry  : pal_entry_typ;

		variable x_adj		  : unsigned(x'range);
    variable y_adj      : std_logic_vector(y'range);
  
    variable tile_d_r   : std_logic_vector(ctl_i.tile_d'range);
		variable attr_d_r	  : std_logic_vector(7 downto 0);

  begin

    y_adj := y;
    
  	if rising_edge(clk) then
      if clk_ena = '1' then

        -- video is clipped left and right (only 224 wide)
        x_adj := unsigned(x); -- + (256-PACE_VIDEO_H_SIZE)/2;
          
        -- 1st stage of pipeline
        -- - read tile from tilemap
        -- - read attribute data
        if stb = '1' then
          ctl_o.map_a(3 downto 0) <= std_logic_vector(x_adj(7 downto 4));
          ctl_o.attr_a(3 downto 0) <= std_logic_vector(x_adj(7 downto 4));
        end if;
        
        -- 2nd stage of pipeline
        -- - read tile data from tile ROM
        ctl_o.tile_a(15) <= ctl_i.attr_d(7);
        ctl_o.tile_a(14 downto 7) <= ctl_i.map_d(7 downto 0); -- each tile is 128 bytes
        if stb = '1' then
          if x_adj(3 downto 0) = "0010" then
            attr_d_r := ctl_i.attr_d(7 downto 0);
          end if;
        end if;
        -- attr_d(6) = Y FLIP
        if attr_d_r(6) = '0' then
          ctl_o.tile_a(6 downto 3) <= y_adj(3 downto 0);
        else
          ctl_o.tile_a(6 downto 3) <= not y_adj(3 downto 0);
        end if;
        -- attr_d(5) = X FLIP
        if attr_d_r(5) = '0' then
          ctl_o.tile_a(2 downto 0) <= std_logic_vector(x_adj(3 downto 1));
        else
          ctl_o.tile_a(2 downto 0) <= not std_logic_vector(x_adj(3 downto 1));
        end if;
        
        if stb = '1' then
          -- latch every 2nd pixel
          if x_adj(0) = '0' then
            -- select tile bank
            -- attr_d(5) = X FLIP
            if attr_d_r(5) = '0' then
              tile_d_r := ctl_i.tile_d(7 downto 0);
            else
              tile_d_r := ctl_i.tile_d(3 downto 0) & ctl_i.tile_d(7 downto 4);
            end if;
          else
            tile_d_r := "0000" & tile_d_r(7 downto 4);
          end if;
        end if;
        -- tile_d_r(3) is not used
        -- we expanded 3BPP data
        pel := tile_d_r(2 downto 0);
        
        -- extract R,G,B from colour palette
        --attr_i := attr_d_r(1 downto 0) & tile_d_r(7) & attr_d_r(5 downto 2);
        --attr_i := attr_d_r(1 downto 0) & tile_d_r(7) & attr_d_r(5 downto 4) & pel;
        attr_i := to_integer(unsigned(pel));
        pal_i := attr_i;
        pal_entry := pal(pal_i);
        ctl_o.rgb.r <= pal_entry(0) & "0000";
        ctl_o.rgb.g <= pal_entry(1) & "0000";
        ctl_o.rgb.b <= pal_entry(2) & "0000";
      end if; -- clk_ena
		end if;				

    ctl_o.set <= '1';

  end process;

end TILEMAP_2;
