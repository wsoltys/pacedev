library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Xevious Background Character Tilemap Controller
--
--	Tile data is 2 BPP.
--	Attribute data encodes 
--	- CLUT entry for tile in 5 bits.
--

architecture TILEMAP_2 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias palette_bank  : std_logic is graphics_i.bit8_1(1);
  alias clut_bank     : std_logic is graphics_i.bit8_1(0);

  constant PIPELINED_BITS   : integer := 3;
  
begin

	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 11) <= (others => '0');
  ctl_o.map_a(10 downto 5) <= y(8 downto 3);
  ctl_o.tile_a(ctl_o.tile_a'left downto 13) <= (others => '0');
  ctl_o.tile_a(3 downto 1) <= y(2 downto 0);

  -- generate attribute RAM address
  -- not used, the game routes the mangled VRAMMapper output
  ctl_o.attr_a <= (others => '0');

  -- generate pixel
  process (clk, clk_ena)

		variable pel        : std_logic_vector(1 downto 0);
		variable pal_i      : std_logic_vector(3 downto 0);
		variable clut_entry : clut_entry_typ;
		variable pal_entry  : pal_entry_typ;

		-- pipelined pixel X location
		variable x_r	      : std_logic_vector((DELAY-1)*PIPELINED_BITS-1 downto 0);
    alias x_r_n         : std_logic_vector(1 downto 0) is x_r(x_r'left-1 downto x_r'left-2);

		variable attr_d_r	  : std_logic_vector(2*5-1 downto 0);

		variable x_adj		  : unsigned(x'range);
    variable tile_d_r   : std_logic_vector(ctl_i.tile_d'range);
    
  begin

  	if rising_edge(clk) and clk_ena = '1' then

			-- video is clipped left and right (only 224 wide)
			x_adj := unsigned(x) + (256-PACE_VIDEO_H_SIZE)/2;
				
      -- 1st stage of pipeline
      -- - read tile from tilemap
      -- - read attribute data
      if stb = '1' then
        ctl_o.map_a(4 downto 0) <= std_logic_vector(x_adj(7 downto 3));
      end if;
      
      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      ctl_o.tile_a(12) <= '0';
      ctl_o.tile_a(11 downto 4) <= ctl_i.map_d(7 downto 0); -- each tile is 16 bytes
      ctl_o.tile_a(0) <= x_adj(2);
      
      if stb = '1' then
        if x_adj(1 downto 0) = "01" then
          tile_d_r := ctl_i.tile_d(7 downto 0);
        else
          tile_d_r := tile_d_r(tile_d_r'left-2 downto 0) & "00";
        end if;
      end if;
      pel := tile_d_r(tile_d_r'left downto tile_d_r'left-1);
      
--      -- extract R,G,B from colour palette
--      -- bit 5 of the attribute is the clut bank (pengo)
--      clut_entry := clut(to_integer(unsigned(clut_bank & attr_d_r(attr_d_r'left downto attr_d_r'left-4))));
--      pal_i := clut_entry(to_integer(unsigned(pel)));
--      -- bit 6 of the attribute is the palette bank (pengo)
--      pal_entry := pal(to_integer(unsigned(palette_bank & pal_i)));
--      ctl_o.rgb.r <= pal_entry(0) & "0000";
--      ctl_o.rgb.g <= pal_entry(1) & "0000";
--      ctl_o.rgb.b <= pal_entry(2) & "0000";

      ctl_o.rgb.r <= pel & "00000000";
      ctl_o.rgb.g <= pel & "00000000";
      ctl_o.rgb.b <= pel & "00000000";

			-- pipelined because of tile data look-up
      x_r := x_r(x_r'left-PIPELINED_BITS downto 0) & x(PIPELINED_BITS-1 downto 0);
			attr_d_r := attr_d_r(attr_d_r'left-5 downto 0) & ctl_i.attr_d(4 downto 0);
			
		end if;				

  end process;

	ctl_o.set <= '1';
	
end TILEMAP_2;
