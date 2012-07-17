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
--	Super-80 Tilemap Controller
--
--	Tile data is 8x10(16) 1 BPP.
--

-- NOTE: this is currently broken when borders = 0
-- - eg. 1024x768 x2 
--   because the controller comes out of hblank (pipelined) when vblank is not asserted
--   and then vcount is incremented before the 1st line starts displaying
--

architecture TILEMAP_1 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;

  alias le18_en     : std_logic is graphics_i.bit8(0)(6);
  alias pcg80_en_hi : std_logic is graphics_i.bit8(0)(5);
  alias pcg80_en_lo : std_logic is graphics_i.bit8(0)(4);
  alias alt_char    : std_logic is graphics_i.bit8(0)(3);
  alias dbl_width   : std_logic is graphics_i.bit8(0)(2);

  -- LNW80
  alias gfxram_ena  : std_logic is graphics_i.bit8(1)(3);
  alias gfxmode     : std_logic_vector(1 downto 0) is graphics_i.bit8(1)(2 downto 1);
  alias inverse_ena : std_logic is graphics_i.bit8(1)(0);
  signal hblank_r : std_logic_vector(DELAY-1 downto 0) := (others => '0');
  
begin

	-- these are constant for a whole line
  ctl_o.tile_a(ctl_o.tile_a'left downto 10) <= (others => '0');
  ctl_o.attr_a(ctl_o.attr_a'left downto 12) <= (others => '0');

  -- generate pixel
  process (clk, clk_ena, reset)

		--variable hblank_r		: std_logic_vector(DELAY-1 downto 0);
		alias hblank_prev		: std_logic is hblank_r(hblank_r'left);
		alias hblank_v			: std_logic is hblank_r(hblank_r'left-1);
		variable hcount     : std_logic_vector(7 downto 0);
		variable vcount			: std_logic_vector(8 downto 0);
		variable tile_d_v   : std_logic_vector(7 downto 0) := (others => '0');
		variable line_v     : std_logic_vector(3 downto 0);
    
  begin
  
    -- not used
    ctl_o.map_a(ctl_o.map_a'left downto 9) <= (others => '0');

		if reset = '1' then
			hblank_r <= (others => '1');
  	elsif rising_edge(clk) then
      if clk_ena = '1' then

        -- handle vertical count
        if vblank = '1' then
          vcount := (others => '0');
        elsif hblank_v = '1' and hblank_prev = '0' then
          if vcount(2+PACE_VIDEO_V_SCALE downto 0) = X"9" & 
              std_logic_vector(to_signed(-1,PACE_VIDEO_V_SCALE-1)) then
            vcount := vcount + 6 * PACE_VIDEO_V_SCALE + 1;
          else
            vcount := vcount + 1;
          end if;

          -- fixed for the line
          ctl_o.map_a(8 downto 5) <= 
            vcount(6+PACE_VIDEO_V_SCALE downto 3+PACE_VIDEO_V_SCALE);
          -- line offsets in char rom are 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
          line_v := vcount(2+PACE_VIDEO_V_SCALE downto -1+PACE_VIDEO_V_SCALE);
          ctl_o.tile_a(3 downto 0) <= line_v(2 downto 0) & line_v(3);
          -- for programmable character generators
          ctl_o.attr_a(3 downto 0) <=  vcount(2+PACE_VIDEO_V_SCALE downto -1+PACE_VIDEO_V_SCALE);
        end if;

        -- handle horiztonal count (part 1)
        if hblank = '1' then
          hcount := (others => '0');
        end if;
      
        -- 1st stage of pipeline
        -- - read tile from tilemap
        if stb = '1' then
          ctl_o.map_a(4 downto 1) <= hcount(7 downto 4);
          ctl_o.map_a(0) <= hcount(3) and not dbl_width;
        end if;

        -- 2nd stage of pipeline
        -- - read tile data from tile ROM
        ctl_o.tile_a(9 downto 4) <= ctl_i.map_d(5 downto 0);
        -- for programmable character generators
        ctl_o.attr_a(11 downto 4) <= ctl_i.map_d(7 downto 0);

        -- 3rd stage of pipeline
        -- - latch tile data
        -- (each byte contains information for 8 pixels)
        if hcount(2 downto 0) = "101" then
          if TRS80_M1_HAS_PCG80 and 
              ((ctl_i.map_d(7) = '0' and pcg80_en_lo = '1') or
               (ctl_i.map_d(7) = '1' and pcg80_en_hi = '1')) then
            -- latch character data from PCG-80 RAM
            tile_d_v := "00" & ctl_i.attr_d(1) & ctl_i.attr_d(2) & ctl_i.attr_d(3) & 
                               ctl_i.attr_d(4) & ctl_i.attr_d(5) & ctl_i.attr_d(6);
          else --if ctl_i.map_d(7) = '0' then
            -- latch alpha character rom data
            tile_d_v := ctl_i.tile_d(7 downto 0);
--          else
--            -- generate graphics character
--            case vcount(2+PACE_VIDEO_V_SCALE downto 1+PACE_VIDEO_V_SCALE) is
--              when "00" =>
--                tile_d_v := "00" & ctl_i.map_d(1) & ctl_i.map_d(1) & ctl_i.map_d(1) & 
--                            ctl_i.map_d(0) & ctl_i.map_d(0) & ctl_i.map_d(0);
--              when "01" =>
--                tile_d_v := "00" & ctl_i.map_d(3) & ctl_i.map_d(3) & ctl_i.map_d(3) & 
--                            ctl_i.map_d(2) & ctl_i.map_d(2) & ctl_i.map_d(2);
--              when others =>
--                tile_d_v := "00" & ctl_i.map_d(5) & ctl_i.map_d(5) & ctl_i.map_d(5) & 
--                            ctl_i.map_d(4) & ctl_i.map_d(4) & ctl_i.map_d(4);
--            end case;
          end if;
          if dbl_width /= '0' then
            if hcount(3) = '0' then
              tile_d_v := "00" & tile_d_v(2) & tile_d_v(2) &
                          tile_d_v(1) & tile_d_v(1) & tile_d_v(0) & tile_d_v(0);
            else
              tile_d_v := "00" & tile_d_v(5) & tile_d_v(5) &
                          tile_d_v(4) & tile_d_v(4) & tile_d_v(3) & tile_d_v(3);
            end if; -- hcount(3)='0'
          end if; -- dlb_width/='0'
        end if;

        -- green-screen display
        ctl_o.rgb.r <= (others => '0');
        ctl_o.rgb.g <= (others => inverse_ena xor tile_d_v(7));
        ctl_o.rgb.b <= (others => '0');
        ctl_o.set <= inverse_ena xor tile_d_v(0);

        if stb = '1' then
          tile_d_v := tile_d_v(tile_d_v'left-1 downto 0) & '0';
          -- handle horiztonal count (part 2)
          hcount := hcount + 1;
        end if;
        
        -- for end-of-line detection
        hblank_r <= hblank_r(hblank_r'left-1 downto 0) & hblank;
      
      end if; -- clk_ena='1'
		end if; -- rising_edge(clk)
  end process;

end TILEMAP_1;

