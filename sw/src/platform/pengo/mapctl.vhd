library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

--
--	Pacman/Pengo Tilemap Controller
--
--	Tile data is 2 BPP.
--	Attribute data encodes 
--	- CLUT entry for tile in 5 bits.
--	- CLUT bank in bit 5
-- 	- Palette bank in bit 6
--	(Pacman has no banking)
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
		rgb					: out RGBType;
		tilemap_on	: out std_logic
) ;
end mapCtl_1;

architecture SYN of mapCtl_1 is

begin

	-- these are constant for a whole line
  tilemap_a(15 downto 6) <= "0000" & pix_y(8 downto 3);
  tile_a(15 downto 12) <= "0000";
  tile_a(3 downto 1) <=  pix_y(2 downto 0);   	-- each row is 2 bytes

  -- generate attribute RAM address
  -- not used, the game routes the mangled VRAMMapper output
  attr_a(9 downto 0) <= "0000000000";

  -- generate pixel
  process (clk, clk_ena)

		variable pel : std_logic_vector(1 downto 0);
		variable pal_i : std_logic_vector(3 downto 0);
		variable clut_entry : clut_entry_typ;
		variable pal_entry : pal_entry_typ;

		-- pipelined pixel X location
		variable pix_x_r	: std_logic_vector(5 downto 0);
		variable attr_d_r	: std_logic_vector(6 downto 0);

		variable x_adj		: std_logic_vector(pix_x'range);
				
  begin

  	if rising_edge(clk) and clk_ena = '1' then

			-- video is clipped left and right (only 224 wide)
			x_adj := pix_x + (256-PACE_VIDEO_H_SIZE)/2;
				
			if hblank /= '1' then

				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
				tilemap_a(5 downto 0) <= x_adj(8 downto 3);
				
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
				-- bit 5 of the attribute is the clut bank (pengo)
				clut_entry := clut(conv_integer(attr_d_r(5 downto 0)));
				pal_i := clut_entry(conv_integer(pel));
				-- bit 6 of the attribute is the palette bank (pengo)
				pal_entry := pal(conv_integer(attr_d_r(6) & pal_i));
				rgb.r <= pal_entry(0) & "0000";
				rgb.g <= pal_entry(1) & "0000";
				rgb.b <= pal_entry(2) & "0000";

			end if; -- hblank
			
			-- pipelined because of tile data look-up
			pix_x_r := pix_x_r(2 downto 0) & x_adj(2 downto 0);
			attr_d_r := attr_d(attr_d_r'range);
			
		end if;				

  end process;

	tilemap_on <= '1';
	
end SYN;
