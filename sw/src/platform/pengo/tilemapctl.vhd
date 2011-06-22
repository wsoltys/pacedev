library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Pacman/Pengo Tilemap Controller
--
--	Tile data is 2 BPP.
--	Attribute data encodes 
--	- CLUT entry for tile in 5 bits.
--	(Pacman has no banking)
--

architecture TILEMAP_1 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias palette_bank  : std_logic is graphics_i.bit8(0)(1);
  alias clut_bank     : std_logic is graphics_i.bit8(0)(0);

  constant PIPELINED_BITS   : integer := 3;
  
begin

	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 12) <= (others => '0');
  ctl_o.map_a(11 downto 6) <= y(8 downto 3);
  ctl_o.tile_a(ctl_o.tile_a'left downto 12) <= (others => '0');
  ctl_o.tile_a(3 downto 1) <=  y(2 downto 0);   	-- each row is 2 bytes

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

  begin

  	if rising_edge(clk) and clk_ena = '1' then

			-- video is clipped left and right (only 224 wide)
			x_adj := unsigned(x) + (256-PACE_VIDEO_H_SIZE)/2;
				
      -- 1st stage of pipeline
      -- - read tile from tilemap
      -- - read attribute data
      if stb = '1' then
        ctl_o.map_a(5 downto 0) <= std_logic_vector(x_adj(8 downto 3));
      end if;
      
      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      ctl_o.tile_a(11 downto 4) <= ctl_i.map_d(7 downto 0); -- each tile is 16 bytes
      ctl_o.tile_a(0) <= x_r(PIPELINED_BITS*1+2);

      -- each byte contains information for 4 pixels
      --case x_r(x_r'left-1 downto x_r'left-2) is
      case x_r_n is
      --case x_r(10 downto 9) is
        when "00" =>
          pel := ctl_i.tile_d(6) & ctl_i.tile_d(7);
        when "01" =>
          pel := ctl_i.tile_d(4) & ctl_i.tile_d(5);
        when "10" =>
          pel := ctl_i.tile_d(2) & ctl_i.tile_d(3);
        when others =>
          pel := ctl_i.tile_d(0) & ctl_i.tile_d(1);
      end case;

      -- extract R,G,B from colour palette
      -- bit 5 of the attribute is the clut bank (pengo)
      clut_entry := clut(to_integer(unsigned(clut_bank & attr_d_r(attr_d_r'left downto attr_d_r'left-4))));
      pal_i := clut_entry(to_integer(unsigned(pel)));
      -- bit 6 of the attribute is the palette bank (pengo)
      pal_entry := pal(to_integer(unsigned(palette_bank & pal_i)));
      ctl_o.rgb.r <= pal_entry(0) & "0000";
      ctl_o.rgb.g <= pal_entry(1) & "0000";
      ctl_o.rgb.b <= pal_entry(2) & "0000";

			-- pipelined because of tile data look-up
      x_r := x_r(x_r'left-PIPELINED_BITS downto 0) & x(PIPELINED_BITS-1 downto 0);
			attr_d_r := attr_d_r(attr_d_r'left-5 downto 0) & ctl_i.attr_d(4 downto 0);
			
		end if;				

  end process;

	ctl_o.set <= '1';
	
end TILEMAP_1;
