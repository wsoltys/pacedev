library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

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

	type pal_entry_typ is array (0 to 2) of std_logic_vector(5 downto 0);
	type pal_typ is array (0 to 31) of pal_entry_typ;

	constant pal : pal_typ :=
	(
		3 => (0=>"110111", 1=>"110111", 2=>"111101"),
		5 => (0=>"110111", 1=>"010001", 2=>"000000"),
		6 => (0=>"000000", 1=>"000000", 2=>"111101"),
		7 => (0=>"111111", 1=>"111111", 2=>"000000"),
		9 => (0=>"000000", 1=>"011010", 2=>"111101"),
		10 => (0=>"111111", 1=>"000000", 2=>"000000"),
		11 => (0=>"111111", 1=>"111111", 2=>"000000"),
		13 => (0=>"000000", 1=>"000000", 2=>"111101"),
		14 => (0=>"100101", 1=>"000000", 2=>"111101"),
		15 => (0=>"111111", 1=>"000000", 2=>"000000"),
		17 => (0=>"000000", 1=>"000000", 2=>"111101"),
		18 => (0=>"000000", 1=>"100101", 2=>"101010"),
		19 => (0=>"111111", 1=>"000000", 2=>"000000"),
		23 => (0=>"111111", 1=>"000000", 2=>"000000"),
		25 => (0=>"110111", 1=>"110111", 2=>"111101"),
		26 => (0=>"111111", 1=>"000000", 2=>"000000"),
		27 => (0=>"000000", 1=>"110111", 2=>"111101"),
		29 => (0=>"110111", 1=>"110111", 2=>"010011"),
		30 => (0=>"111111", 1=>"000000", 2=>"000000"),
		31 => (0=>"110111", 1=>"000000", 2=>"111101"),
		others => (others => (others => '0'))
	);

begin

	-- these are constant for a whole line
	tilemap_a(15 downto 6) <= (others => '0'); --"0000" & y(8 downto 3);
  tile_a(15 downto 12) <= (others => '0');
  --tile_a(3 downto 1) <=  y(2 downto 0);   	-- each row is 2 bytes
  -- generate attribute RAM address
  attr_a <= "0000" & y(7 downto 3) & '0';

  -- generate pixel
  tilemapproc: process (clk)

		variable pel : std_logic_vector(1 downto 0);
		variable pal_entry : pal_entry_typ;

		variable scroll_x : std_logic_vector(8 downto 0);
		-- pipelined pixel X location
		variable x_r	: std_logic_vector((PACE_VIDEO_PIPELINE_DELAY-1)*3-1 downto 0);
		
  begin
  	if rising_edge(clk) then

			if hblank = '1' then
				-- video is clipped left and right (only 224 wide)
				scroll_x := (others => '1'); --('0' & not(attr_d(7 downto 0))) + (256-PACE_VIDEO_H_SIZE)/2;
			end if;
						
      -- 1st stage of pipeline
      -- - read tile from tilemap
      -- - read attribute data
      if stb = '1' then
				scroll_x := scroll_x + 1;
        tilemap_a(5 downto 0) <= scroll_x(5 downto 0) after 2 ns; --(8 downto 3);
      end if;

      -- 2nd stage of pipeline
      -- - read tile data from tile ROM
      --tile_a(11 downto 4) <= tilemap_d(7 downto 0); -- each tile is 16 bytes
      --tile_a(0) <= x_r(2*3+2);
			tile_a(3 downto 0) <= tilemap_d(3 downto 0) after 2 ns;
			tile_a(11 downto 4) <= EXT('0' & x_r(3+2), 8) after 2 ns;
      
      -- 3rd stage of pipeline
      -- - assign pixel colour based on tile data
      -- (each byte contains information for 4 pixels)
      case x_r(x_r'left-1 downto x_r'left-2) is
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
      --rgb.r <= pal_entry(0) & "0000";
      --rgb.g <= pal_entry(1) & "0000";
      --rgb.b <= pal_entry(2) & "0000";

      rgb.r <= not EXT(tile_d, rgb.r'length) after 2 ns;
			rgb.b <= (others => '0');
			rgb.g <= (others => '0');

      --if 	pal_entry(0)(5 downto 4) /= "00" or
      --    pal_entry(1)(5 downto 4) /= "00" or
      --    pal_entry(2)(5 downto 4) /= "00" then
        tilemap_on <= '1';
      --else
      --  tilemap_on <= '0';
      --end if;

      -- pipelined because of tile data look-up
      x_r := x_r(x_r'left-3 downto 0) & scroll_x(2 downto 0);

		end if;				

  end process tilemapproc;

end SYN;
