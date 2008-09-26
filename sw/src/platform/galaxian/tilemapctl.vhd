library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Galaxian Tilemap Controller
--
--	Tile data is 2 BPP.
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
  alias vblank    : std_logic is video_ctl.hblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
begin

	-- these are constant for a whole line
	ctl_o.map_a(15 downto 6) <= "0000" & y(8 downto 3);
  ctl_o.tile_a(15 downto 12) <= (others => '0');
  ctl_o.tile_a(3 downto 1) <=  y(2 downto 0);   	-- each row is 2 bytes
  -- generate attribute RAM address
  ctl_o.attr_a <= "0000" & y(7 downto 3) & '0';

  -- generate pixel
  process (clk, clk_ena)

		variable pel : std_logic_vector(1 downto 0);
		variable pal_entry : pal_entry_typ;

		variable scroll_x : std_logic_vector(8 downto 0);
		-- pipelined pixel X location
		variable x_r	: std_logic_vector((DELAY-1)*3-1 downto 0);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read tile from tilemap
			if hblank = '1' then
				-- video is clipped left and right (only 224 wide)
				scroll_x := ('0' & not(ctl_i.attr_d(7 downto 0))) + (256-PACE_VIDEO_H_SIZE)/2;
      elsif stb = '1' then
				scroll_x := scroll_x + 1;
        ctl_o.map_a(5 downto 0) <= scroll_x(8 downto 3);
      end if;

      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      ctl_o.tile_a(11 downto 4) <= ctl_i.map_d(7 downto 0); -- each tile is 16 bytes
      ctl_o.tile_a(0) <= x_r(3*1+2);
      
      -- 3rd stage of pipeline
      -- - assign pixel colour based on tile data
      -- (each byte contains information for 4 pixels)
      case x_r(x_r'left-1 downto x_r'left-2) is
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
      pal_entry := pal(conv_integer(ctl_i.attr_d(10 downto 8) & pel(0) & pel(1)));
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

      -- pipelined because of tile data look-up
      x_r := x_r(x_r'left-3 downto 0) & scroll_x(2 downto 0);

		end if;				

  end process;

end architecture SYN;
