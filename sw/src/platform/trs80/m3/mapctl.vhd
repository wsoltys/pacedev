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

entity tilemapCtl_1 is          
port               
(
    clk         : in std_logic;
		reset				: in std_logic;

		-- video control signals		
		stb         : in std_logic;
    hblank      : in std_logic;
    vblank      : in std_logic;
    x           : in std_logic_vector(10 downto 0);
    y           : in std_logic_vector(10 downto 0);

		scroll_data		: in std_logic_vector(7 downto 0);
		palette_data	: in ByteArrayType(15 downto 0);

    -- tilemap interface
    tilemap_d   : in std_logic_vector(15 downto 0);
    tilemap_a   : out std_logic_vector(15 downto 0);
    tile_d      : in std_logic_vector(7 downto 0);
    tile_a      : out std_logic_vector(15 downto 0);
    attr_d      : in std_logic_vector(15 downto 0);
    attr_a      : out std_logic_vector(9 downto 0);

		-- RGB output (10-bits each)
		rgb					: out RGB_t;
		tilemap_on	: out std_logic
);
end tilemapCtl_1;

architecture SYN of tilemapCtl_1 is

begin

	-- these are constant for a whole line
  tile_a(12) <= '0';

  -- generate attribute RAM address
  attr_a <= (others => '0');

  -- generate pixel
  process (clk, reset)

		variable hblank_r		: std_logic;
		variable vcount			: std_logic_vector(8 downto 0);
		variable x_r		    : std_logic_vector((PACE_VIDEO_PIPELINE_DELAY-1)*3-1 downto 0);
		variable pel 				: std_logic;
		
  begin
		if reset = '1' then
			hblank_r := '1';
  	elsif rising_edge(clk) then

			-- each tile is 12 rows high, rather than 16
			if vblank = '1' then
				vcount := (others => '0');

      -- update vcount at the end of each line
			elsif hblank = '1' and hblank_r = '0' then
          
				if vcount(2+PACE_VIDEO_V_SCALE downto 0) = X"B" & 
						std_logic_vector(conv_signed(-1,PACE_VIDEO_V_SCALE-1)) then
					vcount := vcount + 4 * PACE_VIDEO_V_SCALE + 1;
				else
					vcount := vcount + 1;
				end if;

        -- fixed for the line
        tilemap_a(tilemap_a'left downto 6) <= 
          EXT(vcount(6+PACE_VIDEO_V_SCALE downto 3+PACE_VIDEO_V_SCALE), tilemap_a'left-6+1);
  			tile_a(3 downto 0) <=  vcount(2+PACE_VIDEO_V_SCALE downto PACE_VIDEO_V_SCALE-1);
          
			else
						
				-- 1st stage of pipeline
				-- - read tile from tilemap
				if stb = '1' then
          tilemap_a(5 downto 0) <= x(8 downto 3);
        end if;

				-- 2nd stage of pipeline
				-- - read tile data from tile ROM
			  tile_a(11 downto 4) <= tilemap_d(7 downto 0);

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
				rgb.r <= (others => '0');
				rgb.g <= (others => pel);
				rgb.b <= (others => '0');
				
			end if;
		
			-- pipelined because of tile data loopkup
      x_r := x_r(x_r'left-3 downto 0) & x(2 downto 0);

      -- for edge-detect
			hblank_r := hblank;		
		
		end if; -- rising_edge(clk)

  end process;

	tilemap_on <= '1';

end SYN;

