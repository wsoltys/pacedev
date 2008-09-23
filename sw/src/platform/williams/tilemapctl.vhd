library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Defender Tilemap Controller
--
--	Used ONLY for video counter
--

entity tilemapCtl_1 is          
port               
(
    clk         : in std_logic;
		clk_ena			: in std_logic;
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
) ;
end tilemapCtl_1;

architecture FOREGROUND of tilemapCtl_1 is

begin

	-- output the scanline to the game via attr_a
	attr_a <= y(attr_a'range);

	-- not used
	tilemap_a <= (others => '0');
	tile_a <= (others => '0');

	-- no video output	
	rgb.r <= (others => '0');	
	rgb.g <= (others => '0');	
	rgb.b <= (others => '0');	
	tilemap_on <= '0';
	
end architecture FOREGROUND;
