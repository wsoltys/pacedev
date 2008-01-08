library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

--
--	Frogger Background Generator
--

entity bitmapCtl_1 is          
	port               
	(
	    clk         	: in std_logic;
			clk_ena				: in std_logic;
			reset					: in std_logic;

			-- video control signals		
	    hblank      	: in std_logic;
			vblank				: in std_logic;
	    pix_x       	: in std_logic_vector(9 downto 0);
	    pix_y       	: in std_logic_vector(9 downto 0);

	    -- tilemap interface
			scroll_data		: in std_logic_vector(7 downto 0);
			palette_data	: in ByteArrayType(15 downto 0);
	    bitmap_d    	: in std_logic_vector(7 downto 0);
	    bitmap_a    	: out std_logic_vector(15 downto 0);

			-- RGB output (10-bits each)
			rgb						: out RGBType;
			bitmap_on	  	: out std_logic
	);
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

	signal clk_ena_s : std_logic;
	
begin

  process (clk)

		variable pix_x_adj : std_logic_vector(pix_x'range);
		
  begin

		pix_x_adj := pix_x + (256-PACE_VIDEO_H_SIZE)/2;
		
    if rising_edge (clk) then
      if reset = '0' then

        rgb.r <= (others => '0'); rgb.g <= (others => '0'); rgb.b <= (others => '0');

        if (vblank = '1') or (hblank = '1') then
            null;
        else
					if (pix_y(7) = '0') then
          	rgb.b(rgb.b'left downto rgb.b'left-1) <= "01";
          end if;
        end if; -- hblank = '1'
      end if; -- reset = '0'
    end if; -- rising_edge(clk)

  end process;

	bitmap_a <= (others => '0');
	bitmap_on <= '1';
	
end SYN;

