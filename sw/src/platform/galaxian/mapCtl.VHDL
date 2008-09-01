library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Galaxian Tilemap Controller
--
--	Tile data is 2 BPP.
--

entity mapCtl_1 is          
port               
(
    clk         : in std_logic;
		clk_ena			: in std_logic;
		reset				: in std_logic;

		-- video control signals		
    hblank      : in std_logic;
    vblank      : in std_logic;
    pix_x       : in std_logic_vector(9 downto 0);
    pix_y       : in std_logic_vector(9 downto 0);

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
end mapCtl_1;

architecture beh of mapCtl_1 is
begin

	-- these are constant for a whole line
	tilemap_a(15 downto 6) <= "0000" & pix_y(8 downto 3);
  tile_a(15 downto 12) <= (others => '0');
  tile_a(3 downto 1) <=  pix_y(2 downto 0);   	-- each row is 2 bytes
  -- generate attribute RAM address
  attr_a <= "0000" & pix_y(7 downto 3) & '0';

  -- generate pixel
  process (clk, clk_ena)

		variable pel : std_logic_vector(1 downto 0);
		variable pal_entry : pal_entry_typ;

		variable scroll_pix_x : std_logic_vector(8 downto 0);
		-- pipelined pixel X location
		variable pix_x_r	: std_logic_vector(5 downto 0);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

			if hblank = '1' then
				-- video is clipped left and right (only 224 wide)
				scroll_pix_x := ('0' & not(attr_d(7 downto 0))) + (256-PACE_VIDEO_H_SIZE)/2;
			else
						
				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
				tilemap_a(5 downto 0) <= scroll_pix_x(8 downto 3);

				-- 2nd stage of pipeline
				-- - read tile data from tile ROM
			  tile_a(11 downto 4) <= tilemap_d(7 downto 0); -- each tile is 16 bytes
				tile_a(0) <= pix_x_r(2);
				
				-- each byte contains information for 4 pixels
				case pix_x_r(4 downto 3) is
					when "00" =>
	          pel := tile_d(6) & tile_d(7);
					when "01" =>
	          pel := tile_d(4) & tile_d(5);
					when "10" =>
	          pel := tile_d(2) & tile_d(3);
					when others =>
	        	pel := tile_d(0) & tile_d(1);
				end case;

				-- extract R,G,B from colour palette
				pal_entry := pal(conv_integer(attr_d(10 downto 8) & pel(0) & pel(1)));
				rgb.r <= pal_entry(0) & "0000";
				rgb.g <= pal_entry(1) & "0000";
				rgb.b <= pal_entry(2) & "0000";

				if 	pal_entry(0)(5 downto 4) /= "00" or
						pal_entry(1)(5 downto 4) /= "00" or
						pal_entry(2)(5 downto 4) /= "00" then
					tilemap_on <= '1';
				else
					tilemap_on <= '0';
				end if;

			end if; -- hblank = '1'
				
			-- pipelined because of tile data look-up
			pix_x_r := pix_x_r(2 downto 0) & scroll_pix_x(2 downto 0);
			scroll_pix_x := scroll_pix_x + 1;
			
		end if;				

  end process;

end beh;

