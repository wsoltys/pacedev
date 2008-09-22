library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Apple II Tilemap Controller
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

architecture SYN of mapCtl_1 is

  alias texty 			: std_logic_vector(5 downto 0) is pix_y(8 downto 3);

  signal col0_addr 	: std_logic_vector(9 downto 3);

begin

	tilemap_a(12 downto 10) <= (others => '0');
  tile_a(12 downto 11) <= (others => '0');

	-- these are constant for a whole line
  tile_a(2 downto 0) <=  pix_y(2 downto 0);

   -- the apple video screen is interlaced
   -- the following line gives the start address of each text row
   col0_addr(9 downto 3) <= textY(2 downto 0) & textY(4) & textY(3) & textY(4) & textY(3);

  -- generate pixel
  process (clk, clk_ena, reset)

		variable pix_x_r		: std_logic_vector(5 downto 0);
		variable pel 				: std_logic;
		variable x_count		: std_logic_vector(8 downto 0);
		
  begin
		if reset = '1' then
			null;
			
  	elsif rising_edge(clk) and clk_ena = '1' then

			if vblank = '1' then
				null;

			elsif hblank = '1' then
				x_count := (others => '0');
				
			elsif hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
				tilemap_a(9 downto 0) <= (col0_addr & "000") + ("0000" & x_count(8 downto 3));

				-- 2nd stage of pipeline
				-- - read tile data from tile ROM
			  tile_a(10 downto 3) <= tilemap_d(7 downto 0);

		    -- we don't implement a separate attribute memory
		    -- instead we need to 'feed back' bits 7:6 of the ascii code to the next pipelined stage
		    -- so we know as we're rendering the pixels whether or not the video should be
		    -- inverted or flashing etc
		    attr_a <= EXT(tilemap_d(7 downto 6), attr_a'length);

				-- we need to know if the characters are flashing and/or inverted
        -- to this this we 'feed back' bits 7:6 of the ascii code via attrA
        -- back to attrD 9:8. We also get the flash timer in attrD 10.

				-- if (inverse) or (flashing and flash_on)
        if (attr_d(9 downto 8) = "00") or ((attr_d(9 downto 8) = "01") and (attr_d(10) = '1')) then
          --fg <= attrD(7 downto 4);
          --bg <= attrD(3 downto 0);
        else
          --fg <= attrD(3 downto 0);
        	--bg <= attrD(7 downto 4);
				end if;

				case pix_x_r(pix_x_r'left downto pix_x_r'left-2) is
					when "000" =>
						pel := '0';
					when "001" =>
						pel := tile_d(6);
					when "010" =>
						pel := tile_d(5);
					when "011" =>
						pel := tile_d(4);
					when "100" =>
						pel := tile_d(3);
					when "101" =>
						pel := tile_d(2);
					when "110" =>
						pel := tile_d(1);
					when others =>
						pel := tile_d(0);
				end case;
									
	      -- green-screen display
				rgb.r <= (others => '0');
				rgb.g <= (others => pel);
				rgb.b <= (others => '0');
				
			end if; -- hblank = '0'
		
			-- pipelined because of tile data loopkup
			pix_x_r := pix_x_r(pix_x_r'left-3 downto 0) & x_count(2 downto 0);
			if x_count(2 downto 0) = "110" then
				x_count := x_count + 2;
			else
				x_count := x_count + 1;
			end if;
		end if;				

	tilemap_on <= pel;

  end process;

end SYN;

