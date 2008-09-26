library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_SIGNED;
use ieee.std_logic_arith.EXT;

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
  alias vblank    : std_logic is video_ctl.hblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
begin

	-- these are constant for a whole line
  ctl_o.tile_a(ctl_o.tile_a'left downto 12) <= (others => '0');

  -- generate attribute RAM address (not used)
  ctl_o.attr_a <= (others => '0');

  -- generate pixel
  process (clk, clk_ena, reset)

		variable hblank_r		: std_logic_vector(DELAY-1 downto 0);
		alias hblank_prev		: std_logic is hblank_r(hblank_r'left);
		alias hblank_v			: std_logic is hblank_r(hblank_r'left-1);
		variable vcount			: std_logic_vector(8 downto 0);
		variable x_r		    : std_logic_vector((DELAY-1)*3-1 downto 0);
		variable pel 				: std_logic;
		
  begin
		if reset = '1' then
			hblank_r := (others => '1');
  	elsif rising_edge(clk) and clk_ena = '1' then

			-- each tile is 12 rows high, rather than 16
			if vblank = '1' then
				vcount := (others => '0');

      -- update vcount at the end of each line
			elsif hblank_v = '1' and hblank_prev = '0' then
          
				if vcount(2+PACE_VIDEO_V_SCALE downto 0) = X"B" & 
						std_logic_vector(conv_signed(-1,PACE_VIDEO_V_SCALE-1)) then
					vcount := vcount + 4 * PACE_VIDEO_V_SCALE + 1;
				else
					vcount := vcount + 1;
				end if;

        -- fixed for the line
        ctl_o.map_a(ctl_o.map_a'left downto 6) <= 
          EXT(vcount(6+PACE_VIDEO_V_SCALE downto 3+PACE_VIDEO_V_SCALE), ctl_o.map_a'left-6+1);
  			ctl_o.tile_a(3 downto 0) <=  vcount(2+PACE_VIDEO_V_SCALE downto PACE_VIDEO_V_SCALE-1);
          
			end if;
						
      -- 1st stage of pipeline
      -- - read tile from tilemap
      if stb = '1' then
        ctl_o.map_a(5 downto 0) <= x(8 downto 3);
      end if;

      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      ctl_o.tile_a(11 downto 4) <= ctl_i.map_d(7 downto 0);

      -- 3rd stage of pipeline
      -- - assign pixel colour based on tile data
      -- (each byte contains information for 8 pixels)
      case x_r(x_r'left downto x_r'left-2) is
        when "000" =>
          pel := ctl_i.tile_d(0);
        when "001" =>
          pel := ctl_i.tile_d(1);
        when "010" =>
          pel := ctl_i.tile_d(2);
        when "011" =>
          pel := ctl_i.tile_d(3);
        when "100" =>
          pel := ctl_i.tile_d(4);
        when "101" =>
          pel := ctl_i.tile_d(5);
        when "110" =>
          pel := ctl_i.tile_d(6);
        when others =>
          pel := ctl_i.tile_d(7);
      end case;

      -- green-screen display
      ctl_o.rgb.r <= (others => '0');
      ctl_o.rgb.g <= (others => pel);
      ctl_o.rgb.b <= (others => '0');
      
			-- pipelined because of tile data loopkup
      x_r := x_r(x_r'left-3 downto 0) & x(2 downto 0);

      -- for end-of-line detection
			hblank_r := hblank_r(hblank_r'left-1 downto 0) & hblank;
		
		end if; -- rising_edge(clk)

  end process;

	ctl_o.set <= '1';

end SYN;

