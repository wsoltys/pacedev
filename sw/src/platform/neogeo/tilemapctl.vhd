library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	NeoGeo Tilemap Controller
--
--	Tile data is 4 BPP.
--

entity tilemapCtl_1 is          
  generic
  (
    DELAY       : integer
  );
  port               
  (
    reset				: in std_logic;

    -- video control signals		
    video_ctl   : in from_VIDEO_CTL_t;

    -- tilemap controller signals
    ctl_i       : in to_TILEMAP_CTL_t;
    ctl_o       : out from_TILEMAP_CTL_t;

    graphics_i  : in to_GRAPHICS_t
  );
end entity tilemapCtl_1;

architecture SYN of tilemapCtl_1 is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
begin

	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 11) <= (others => '0');
  ctl_o.map_a(4 downto 0) <= y(7 downto 3);
  ctl_o.tile_a(2 downto 0) <= y(2 downto 0);
  -- generate attribute RAM address
  ctl_o.attr_a(ctl_o.attr_a'left downto 4) <= (others => '0');

  -- generate pixel
  process (clk, clk_ena)

		variable pel : std_logic_vector(3 downto 0);
		variable pal_entry : PAL_ENTRY_t;

		-- pipelined pixel X location
		constant PIPELINE_BITS  : natural := 3;
		variable x_r	: std_logic_vector((DELAY-1)*PIPELINE_BITS-1 downto 0);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read tile from tilemap
      if stb = '1' then
        ctl_o.map_a(10 downto 5) <= x(8 downto 3);
      end if;
      
      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      ctl_o.tile_a(16 downto 5) <= ctl_i.map_d(11 downto 0); -- each tile is 32 bytes
      ctl_o.tile_a(4) <= not x_r(PIPELINE_BITS*1+2);
      ctl_o.tile_a(3) <= x_r(PIPELINE_BITS*1+1);
      -- - set palette index
      ctl_o.attr_a(3 downto 0) <= ctl_i.map_d(15 downto 12);
      
      -- 3rd stage of pipeline
      -- - assign pixel colour based on tile data
      -- (each byte contains information for 2 pixels)
      case x_r(x_r'left-(PIPELINE_BITS-1)) is
        when '0' =>
          pel := ctl_i.tile_d(3 downto 0);
        when others =>
          pel := ctl_i.tile_d(7 downto 4);
      end case;

      -- extract R,G,B from colour palette
      pal_entry := graphics_i.pal(conv_integer(pel));
      ctl_o.rgb.r <= pal_entry(11 downto 8) & pal_entry(14) & pal_entry(15) & "0000";
      ctl_o.rgb.g <= pal_entry(7 downto 4) & pal_entry(13) & pal_entry(15) & "0000";
      ctl_o.rgb.b <= pal_entry(3 downto 0) & pal_entry(12) & pal_entry(15) & "0000";

      -- pipelined because of tile data look-up
      x_r := x_r(x_r'left-PIPELINE_BITS downto 0) & x(PIPELINE_BITS-1 downto 0);

		end if;				

  end process;

  ctl_o.set <= '1';

end architecture SYN;
