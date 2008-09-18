library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_SIGNED;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

architecture TRS80_M3 of tilemapCtl_1 is

begin

	-- these are constant for a whole line
  tile_a(15 downto 12) <= (others => '0');

  -- generate attribute RAM address
  attr_a <= (others => '0');

  -- generate pixel
  tilemapproc: process (clk, reset)

		variable hblank_r		: std_logic_vector(PACE_VIDEO_PIPELINE_DELAY-1 downto 0);
		alias hblank_prev		: std_logic is hblank_r(hblank_r'left);
		alias hblank_v			: std_logic is hblank_r(hblank_r'left-1);
		variable vcount			: std_logic_vector(8 downto 0) := (others => '0');
		variable x_r		    : std_logic_vector((PACE_VIDEO_PIPELINE_DELAY-1)*3-1 downto 0);
		variable pel 				: std_logic;
		
  begin
		if reset = '1' then
			hblank_r := (others => '1');
  	elsif rising_edge(clk) then

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
        tilemap_a(tilemap_a'left downto 6) <= 
          EXT(vcount(6+PACE_VIDEO_V_SCALE downto 3+PACE_VIDEO_V_SCALE), tilemap_a'left-6+1) after 2 ns;
  			tile_a(11 downto 8) <=  vcount(2+PACE_VIDEO_V_SCALE downto PACE_VIDEO_V_SCALE-1);

			end if;
          
			-- 1st stage of pipeline
			-- - read tile from tilemap
			if stb = '1' then
        tilemap_a(5 downto 0) <= x(8 downto 3) after 2 ns;
      end if;

			-- 2nd stage of pipeline
			-- - read tile data from tile ROM
		  tile_a(7 downto 0) <= tilemap_d(7 downto 0) after 2 ns;

      -- 3rd stage of pipeline
      -- - assign pixel colour based on tile data
			-- (each byte contains information for 8 pixels)
			case x_r(x_r'left downto x_r'left-2) is
        when "000" =>
          pel := tile_d(0);
        when "001" =>
          pel := tile_d(1);
        when "010" =>
          pel := tile_d(2);
        when "011" =>
          pel := tile_d(3);
        when "100" =>
          pel := tile_d(4);
        when "101" =>
          pel := tile_d(5);
        when "110" =>
          pel := tile_d(6);
        when others =>
          pel := tile_d(7);
			end case;

      -- green-screen display
			rgb.r <= EXT(tile_d, rgb.r'length) after 2 ns;
			rgb.g <= EXT(x_r(x_r'left downto x_r'left-2), rgb.g'length) after 2 ns;
			rgb.b <= (others => '0');
				
			-- pipelined because of tile data loopkup
      x_r := x_r(x_r'left-3 downto 0) & x(2 downto 0);

      -- for end-of-line detection
			hblank_r := hblank_r(hblank_r'left-1 downto 0) & hblank;
		
		end if; -- rising_edge(clk)

  end process tilemapproc;

	tilemap_on <= '1';


end TRS80_M3;
