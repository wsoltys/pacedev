library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Midway 8080 Bitmap Controller
--

entity bitmapCtl_1 is          
port               
(
    clk         	: in std_logic;
		clk_ena				: in std_logic;
		reset					: in std_logic;

		-- video control signals		
    hblank      	: in std_logic;
    vblank      	: in std_logic;
    pix_x       	: in std_logic_vector(9 downto 0);
    pix_y       	: in std_logic_vector(9 downto 0);

    -- tilemap interface
		scroll_data		: in std_logic_vector(7 downto 0);
		palette_data	: in ByteArrayType(15 downto 0);
    bitmap_d   		: in std_logic_vector(7 downto 0);
    bitmap_a   		: out std_logic_vector(15 downto 0);

		-- RGB output (10-bits each)
		rgb						: out RGB_t;
		bitmap_on			: out std_logic
);
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

begin

	-- these are constant for a whole line
	bitmap_a(15 downto 13) <= (others => '0');
  bitmap_a(12 downto 8) <= pix_y(7 downto 3);

  -- generate pixel
  process (clk, clk_ena)

		variable pel : std_logic;
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

			if hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
				bitmap_a(7 downto 0) <= pix_x(7 downto 0);

				-- each byte contains information for 8 pixels
				case pix_y(2 downto 0) is
	        when "000" =>
	          pel := bitmap_d(7);
	        when "001" =>
	          pel := bitmap_d(6);
	        when "010" =>
	          pel := bitmap_d(5);
	        when "011" =>
	          pel := bitmap_d(4);
	        when "100" =>
	          pel := bitmap_d(3);
	        when "101" =>
	          pel := bitmap_d(2);
	        when "110" =>
	          pel := bitmap_d(1);
	        when others =>
	          pel := bitmap_d(0);
				end case;

	      -- emulate the coloured cellophane overlays
				rgb.r <= (others => '0');
				rgb.g <= (others => '0');
				rgb.b <= (others => '0');
	      if pel = '1' then
	        if pix_y(7 downto 3) < "00100" then
						-- white
						rgb.r(9 downto 8) <= "11";
						rgb.g(9 downto 8) <= "11";
						rgb.b(9 downto 8) <= "11";
	        elsif pix_y(7 downto 3) < "01000" then
						rgb.r(9 downto 8) <= "11";	-- red
	        elsif pix_y(7 downto 3) < "10111" then
						-- white
						rgb.r(9 downto 8) <= "11";
						rgb.g(9 downto 8) <= "11";
						rgb.b(9 downto 8) <= "11";
	        elsif pix_y(7 downto 3) < "11110" then
						rgb.g(9 downto 8) <= "11";	-- green
	        else
	          -- pix_count(7..3) is the character X position
	          if pix_x(7 downto 3) < 2 then
							-- white
							rgb.r(9 downto 8) <= "11";
							rgb.g(9 downto 8) <= "11";
							rgb.b(9 downto 8) <= "11";
	          elsif pix_x(7 downto 3) < 17 then
							rgb.g(9 downto 8) <= "11";	-- green
	          else
							-- white
							rgb.r(9 downto 8) <= "11";
							rgb.g(9 downto 8) <= "11";
							rgb.b(9 downto 8) <= "11";
	          end if;
	        end if;
	      else
	        null; -- black
	      end if;
				
			end if; -- hblank = '0'
				
		end if;				

  end process;

	bitmap_on <= '1';

end SYN;

