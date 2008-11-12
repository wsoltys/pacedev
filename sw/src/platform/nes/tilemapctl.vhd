library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	NES Tilemap Controller
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
  
  alias scroll_data : std_logic_vector(7 downto 0) is graphics_i.bit8_1;
  
	signal attr		: std_logic_vector(1 downto 0);

	-- support for vertical scroll only
	signal adj_y	: std_logic_vector(video_ctl.y'range);
	signal adj_y1	: std_logic_vector(video_ctl.y'range);

	-- support for horizontal scrolling only
	signal adj_x	: std_logic_vector(video_ctl.y'range);
		
	-- extra bits for scrolling
	alias tile_x	: std_logic_vector(5 downto 0) is adj_x(8 downto 3);
	alias tile_y	: std_logic_vector(5 downto 0) is adj_y(8 downto 3); 
	
begin

	GEN_Y_VSCROLL : if NES_MIRROR_HORIZONTAL generate
		adj_x <= video_ctl.x;
		-- need to skip the attribute RAM
		-- this is probably better done counting rows...
		adj_y1 <=	video_ctl.y + scroll_data;
		adj_y <= 	adj_y1 when (adj_y1(8) = '0' and adj_y1(7 downto 4) /= "1111") else
							adj_y1 + (2*8);
		ctl_o.map_a(10) <= tile_y(5);
		ctl_o.attr_a(6) <= tile_y(5);
	end generate GEN_Y_VSCROLL;

	GEN_Y_HSCROLL : if NES_MIRROR_VERTICAL generate
		-- this might be too slow...
		adj_x <= video_ctl.x + scroll_data;
		adj_y <= video_ctl.y;
	end generate GEN_Y_HSCROLL;
		
	ctl_o.tile_a(15 downto 13) <= (others => '0');
	
	-- these are constant for a whole line
	ctl_o.map_a(ctl_o.map_a'left downto 11) <= (others => '0');
	ctl_o.map_a(9 downto 5) <= tile_y(4 downto 0);
  ctl_o.tile_a(12) <= '1'; -- actually set by $2000.4
  ctl_o.tile_a(3 downto 1) <=  adj_y(2 downto 0);   	-- each row is 2 bytes

	ctl_o.attr_a(ctl_o.attr_a'left downto 7) <= (others => '0');
	
  -- generate pixel
  process (clk, clk_ena)

		variable pel 					: std_logic_vector(1 downto 0);
		variable pal_entry 		: pal_entry_typ;
		variable attr_b   		: std_logic_vector(1 downto 0);
		variable clut_entry		: std_logic_vector(7 downto 0);
		
		-- pipelined pixel X location
		type pix_x_pipe is array (natural range <>) of std_logic_vector(4 downto 0);
		variable pix_x_r	: pix_x_pipe(1 downto 0);
				
  begin
  	if rising_edge(clk) and clk_ena = '1' then

			if hblank = '1' then
				null;
			else

				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
				if NES_MIRROR_VERTICAL then
					-- fudge - $2000 passed in via attr_d(15..8)
					-- - $2004.(1..0) selects name table address
					ctl_o.map_a(10) <= tile_x(5) xor ctl_i.attr_d(8);
					ctl_o.attr_a(6) <= tile_x(5) xor ctl_i.attr_d(8);
				end if;
				ctl_o.map_a(4 downto 0) <= tile_x(4 downto 0);
			  -- generate attribute RAM address
				-- each attribute controls a 4x4 tile square
				-- addr = (y/4)*8 + (x/4)
			  ctl_o.attr_a(5 downto 0) <= tile_y(4 downto 2) & tile_x(4 downto 2);

				-- 2nd stage of pipeline
				-- - read tile data from tile ROM
			  ctl_o.tile_a(11 downto 4) <= ctl_i.map_d(7 downto 0); -- each tile is 16 bytes
				ctl_o.tile_a(0) <= pix_x_r(0)(2);
				
				-- calculate which bits of the attribute bytes we need
				-- each pair of bits controls a 2x2 quadrant of the square
				attr_b := tile_y(1) & pix_x_r(0)(4);
				case attr_b is
					when "00" =>
						attr <= ctl_i.attr_d(1 downto 0);
					when "01" =>
						attr <= ctl_i.attr_d(3 downto 2);					
					when "10" =>
						attr <= ctl_i.attr_d(5 downto 4);
					when others =>
						attr <= ctl_i.attr_d(7 downto 6);
				end case;
							
				-- each byte contains information for 4 pixels
				case pix_x_r(1)(1 downto 0) is
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
				clut_entry := graphics_i.pal(conv_integer(attr & pel(1) & pel(0)));
				pal_entry := pal(conv_integer(clut_entry(5 downto 0)));
				ctl_o.rgb.r <= pal_entry(0) & "0000";
				ctl_o.rgb.g <= pal_entry(1) & "0000";
				ctl_o.rgb.b <= pal_entry(2) & "0000";

				--if not (attr = "00" and pel = "00") then
				if pel /= "00" then
					ctl_o.set <= '1';
				else
					ctl_o.set <= '0';
				end if;

			end if; -- hblank = '1'
				
			-- pipelined because of tile data look-up
			pix_x_r(1) := pix_x_r(0);
			pix_x_r(0) := adj_x(pix_x_r(0)'range);
			
		end if;				

  end process;

end SYN;

