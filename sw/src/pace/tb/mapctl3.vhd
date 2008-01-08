library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

--
--	TRS-80 Tilemap Controller
--
--	Tile data is 1 BPP.
--

entity mapCtl_3 is          
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

    -- tilemap interface
    tilemap_d   : in std_logic_vector(7 downto 0);
    tilemap_a   : out std_logic_vector(12 downto 0);
    tile_d      : in std_logic_vector(7 downto 0);
    tile_a      : out std_logic_vector(12 downto 0);
    attr_d      : in std_logic_vector(15 downto 0);
    attr_a      : out std_logic_vector(9 downto 0);

		-- RGB output (10-bits each)
		rgb					: out RGBType;
		tilemap_on	: out std_logic
);
end mapCtl_3;

architecture SYN of mapCtl_3 is

  signal sausages : std_logic_vector(5 downto 0);

begin

	-- these are constant for a whole line
  tile_a(12) <= '0';

  -- generate attribute RAM address
  attr_a <= (others => '0');

  -- generate pixel
  process (clk, clk_ena)

		variable hblank_r		: std_logic;
		variable vcount			: std_logic_vector(8 downto 0);
		variable pix_x_r		: std_logic_vector(5 downto 0);
    variable tile_d_r   : std_logic_vector(7 downto 0);
		variable pel 				: std_logic;
		
  begin
		if reset = '1' then
			hblank_r := '0';
  	elsif rising_edge(clk) and clk_ena = '1' then

			-- each tile is 12 rows high, rather than 16
			if vblank = '1' then
				vcount := (others => '0');

			elsif hblank = '1' and hblank_r = '0' then
				if vcount(4 downto 0) = "10111" then
					vcount := vcount + 9;
				else
					vcount := vcount + 1;
				end if;

			elsif hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
				tilemap_a(tilemap_a'left downto 6) <= "000" & vcount(8 downto 5);
				tilemap_a(5 downto 0) <= pix_x(8 downto 3);

				-- 2nd stage of pipeline
				-- - read tile data from tile ROM
			  tile_a(11 downto 4) <= tilemap_d(7 downto 0);
  			tile_a(3 downto 0) <=  vcount(4 downto 1);

				-- each byte contains information for 8 pixels
				case pix_x_r(pix_x_r'left downto pix_x_r'left-2) is
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
				
			end if; -- hblank = '0'
		
			-- pipelined because of tile data loopkup
			pix_x_r := pix_x_r(pix_x_r'left-3 downto 0) & pix_x(2 downto 0);
			--tile_d_r := tile_d;

			hblank_r := hblank;		
		end if;				

    sausages <= pix_x_r;

  end process;

	tilemap_on <= '1';

end SYN;

