library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;

--
--	TRS-80 Tilemap Controller
--
--	Tile data is 1 BPP.
--

-- NOTE: this is currently broken when borders = 0
-- - eg. 1024x768 x2 
--   because the controller comes out of hblank (pipelined) when vblank is not asserted
--   and then vcount is incremented before the 1st line starts displaying
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
end tilemapCtl_1;

architecture SYN of tilemapCtl_1 is

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
  ctl_o.tile_a(ctl_o.tile_a'left downto 11) <= (others => '0');

	-- these are constant for a whole line
  ctl_o.map_a(9 downto 6) <= y(6 downto 3);
  ctl_o.tile_a(3 downto 0) <= '0' & y(2 downto 0);

  -- generate attribute RAM address (not used)
  ctl_o.attr_a <= (others => '0');

  -- generate pixel
  process (clk, clk_ena, reset)

		constant X_PIPELINE_BITS  : integer := 3;
		variable x_r		    : std_logic_vector((DELAY-1)*X_PIPELINE_BITS-1 downto 0);
		variable pel 				: std_logic;
		
  begin
  
		if reset = '1' then
			null;
  	elsif rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read tile from tilemap
      if stb = '1' then
        ctl_o.map_a(5 downto 0) <= x(8 downto 3);
      end if;

      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      ctl_o.tile_a(10 downto 4) <= ctl_i.map_d(6 downto 0);

      -- 3rd stage of pipeline
      -- - assign pixel colour based on tile data
      -- (each byte contains information for 8 pixels)
      case x_r(x_r'left downto x_r'left-2) is
        when "000" =>
          pel := ctl_i.tile_d(7);
        when "001" =>
          pel := ctl_i.tile_d(6);
        when "010" =>
          pel := ctl_i.tile_d(5);
        when "011" =>
          pel := ctl_i.tile_d(4);
        when "100" =>
          pel := ctl_i.tile_d(3);
        when "101" =>
          pel := ctl_i.tile_d(2);
        when "110" =>
          pel := ctl_i.tile_d(1);
        when others =>
          pel := ctl_i.tile_d(0);
      end case;

      -- green-screen display
      ctl_o.rgb.r <= (others => '0');
      ctl_o.rgb.g <= (others => pel);
      ctl_o.rgb.b <= (others => '0');
      
			-- pipelined because of tile data loopkup
      x_r := x_r(x_r'left-X_PIPELINE_BITS downto 0) & x(X_PIPELINE_BITS-1 downto 0);

      ctl_o.set <= pel;

		end if; -- rising_edge(clk)

  end process;

end SYN;

