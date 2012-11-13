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
--static const gfx_layout tilelayout =
--{
--	16,16,
--	RGN_FRAC(1,3),
--	3,
--	{ RGN_FRAC(0,3), RGN_FRAC(1,3), RGN_FRAC(2,3) },
--	{ 0, 1, 2, 3, 4, 5, 6, 7,
--			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7 },
--	{ 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
--			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 },
--	32*8
--};
--

architecture TILEMAP_2 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias scroll    : std_logic_vector(15 downto 0) is graphics_i.bit16(0);

  signal y_adj    : std_logic_vector(y'range);
  
begin

  -- scroll register
  y_adj <= std_logic_vector(to_unsigned(256,y'length) + unsigned(y) - unsigned(scroll(y'range)));
  --y_adj <= std_logic_vector(unsigned(y) + unsigned(scroll(y'range)));
    
	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 10) <= (others => '0');
  ctl_o.map_a(9 downto 4) <= not y_adj(8 downto 4) & '0';
  ctl_o.tile_a(ctl_o.tile_a'left downto 14) <= (others => '0');

  -- generate attribute RAM address (next 16 bytes)
  ctl_o.attr_a(ctl_o.map_a'left downto 10) <= (others => '0');
  ctl_o.attr_a(9 downto 4) <= not y_adj(8 downto 4) & '1';
  
  -- generate pixel
  process (clk)

		variable x_adj		  : unsigned(x'range);
  
    variable tile_d_r   : std_logic_vector(23 downto 0);
		variable attr_d_r	  : std_logic_vector(7 downto 0);
    variable pel        : std_logic_vector(2 downto 0);

    variable clut_i     : integer range 0 to 63;
    variable clut_entry : bg_clut_entry_t;
    variable pel_i      : integer range 0 to 7;
    variable pal_i      : integer range 0 to 255;
    variable pal_entry  : palette_entry_t;

  begin

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
        ctl_o.tile_a(13) <= ctl_i.attr_d(7);
        ctl_o.tile_a(12 downto 5) <= ctl_i.map_d(7 downto 0);
        if stb = '1' then
          if x_adj(3 downto 0) = "0010" then
            attr_d_r := ctl_i.attr_d(7 downto 0);
          end if;
        end if;
        -- attr_d(6) = Y FLIP
        if attr_d_r(6) = '0' then
          ctl_o.tile_a(3 downto 0) <= y_adj(3 downto 0);
        else
          ctl_o.tile_a(3 downto 0) <= not y_adj(3 downto 0);
        end if;
        -- attr_d(5) = X FLIP
        if attr_d_r(5) = '0' then
          ctl_o.tile_a(4) <= x_adj(3);
        else
          ctl_o.tile_a(4) <= not x_adj(3);
        end if;
        
        if stb = '1' then
          -- latch every 8 pixels
          if x_adj(2 downto 0) = "010" then
            -- select tile bank
            -- attr_d(5) = X FLIP
            if attr_d_r(5) = '0' then
              tile_d_r := ctl_i.tile_d(23 downto 0);
            else
              -- fixme
              tile_d_r := ctl_i.tile_d(23 downto 0);
            end if;
          else
            tile_d_r := ctl_i.tile_d(ctl_i.tile_d'left-1 downto 0) & '0';
          end if;
        end if;
        pel := tile_d_r(23) & tile_d_r(15) & tile_d_r(7);
        
        clut_i := to_integer(unsigned(attr_d_r(4 downto 0)));
        clut_entry := bg_clut(clut_i);
        pel_i := to_integer(unsigned(pel));
        pal_i := to_integer(unsigned(clut_entry(pel_i)));
        pal_entry := pal(pal_i);
        ctl_o.rgb.r <= pal_entry(0) & "0000";
        ctl_o.rgb.g <= pal_entry(1) & "0000";
        ctl_o.rgb.b <= pal_entry(2) & "0000";
      end if; -- clk_ena
		end if;				

    ctl_o.set <= '1';

  end process;

end TILEMAP_2;
