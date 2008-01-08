library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity mapCtl is
port
(
    -- Tile Map controller

    clk         : in     std_logic;
    vsync       : in     std_logic;
    -- VGA I/F
    HBlank       : in     std_logic;
    pix          : out    std_logic_vector(7 downto 0);    -- video data
    pixAddr      : in     std_logic_vector(18 downto 0);
    -- Tile map I/F
    tileMapD    : in     std_logic_vector(7 downto 0);
    tileMapA    : out    std_logic_vector(12 downto 0);
    -- Tile data I/F
    tileD       : in     std_logic_vector(7 downto 0);
    tileA       : out    std_logic_vector(12 downto 0);
    -- attrib I/F
    attrD       : in     std_logic_vector(15 downto 0);
    attrA       : out    std_logic_vector(9 downto 0)
) ;
end mapCtl;

architecture beh of mapCtl is
    signal pixX : std_logic_vector(7 downto 0); -- 512/2 = 256
    signal pixY : std_logic_vector(8 downto 0); -- 192*2 = 384
begin

     -- get X,Y coordinate of pixel (pair)
    pixX <= pixAddr(7 downto 0);
    -- skip pixAddr(8) to pixel-double in Y direction
    pixY <= pixAddr(17 downto 9);

    -- generate tile map address from VGA raster
    -- each line (16 pixels high) is 64 tiles
    --tileMapA(12 downto 6) <=  "00" & pixY(8 downto 4);

    -- generate tile address from tile map data
    tileA(12) <= '0';
    tileA(11 downto 4) <= tileMapD(7 downto 0); -- each tile is 16 bytes
    --tileA(3 downto 0) <=  pixY(3 downto 0);   -- each row is 1 byte

    -- the character number will be looped back
	-- as attrD (to give 1 clock delay)
    attrA(9 downto 0) <="00" & tileMapD;

    -- generate pixel
    process (clk, HBlank, tileD, attrD)
        -- the VGA controller assumes that data is valid on tha same clk the address goes out (i.e. no pipeline)
        -- as we are using synchronous RAM we have an address to data delay.
        -- the delay is 2 clock, one for tileMap and once for tile, however @ 2 bits per pixel there is a
        -- 2 clock delay in the VGA controller anyway
        -- so we need a horizontal count that is 1 ahead of the VGA counter.
        -- this is achieved by sending a 0 address when in blanking and starting the count @ 1 as soon as we are out of blanking.
        -- a better solution would be for the VGA controller to have a pipeline option.

        variable vcount : std_logic_vector(8 downto 0);
        variable hcount : std_logic_vector(8 downto 0); -- counter is one wider than VGA counter to allow counting every clock
                                                        -- VGA counter will count every two clock due to 2 bit per pix
        variable c1 : std_logic;

    begin
        if rising_edge(clk) then
            if vsync = '0' then
                vcount := "111111111";
            end if;
            if HBlank = '1' then
                hcount := "000000010";  -- reset to 1 (shifted up for two clocks)
            else
                if hcount = 511 then
                    if vcount(4 downto 0) = "10111" then
                        vcount := vcount + 9;
                    else
                        vcount := vcount + 1;
                    end if;
                end if;
                hcount := hcount + 1;
            end if;
        end if;

        tileMapA(12 downto 5) <=  "0000" & vcount(8 downto 5);
        tileA(3 downto 0) <=  vcount(4 downto 1);

        if HBlank = '1' then
            tileMapA(4 downto 0) <=  "00000";
        else
            tileMapA(4 downto 0) <=  hcount(8 downto 4);
        end if;

        -- convert the 1 bits/pixel data back to 4 bits/pixel
        case hcount(3 downto 1) is
             when "000" =>
                  c1 := tileD(0);
             when "001" =>
                  c1 := tileD(7);
             when "010" =>
                  c1 := tileD(6);
             when "011" =>
                  c1 := tileD(5);
             when "100" =>
                  c1 := tileD(4);
             when "101" =>
                  c1 := tileD(3);
             when "110" =>
                  c1 := tileD(2);
             when "111" =>
                  c1 := tileD(1);
             when others =>
        end case;

		if attrD (7 downto 6) = "00" then
		  -- inverse video
		  if c1 = '1' then
			pix <= X"22"; -- green
		  else
			pix <= X"AA"; -- dark green
		  end if;
		elsif attrD(7) = '0' then
          -- normal video
		  if c1 = '1' then
			pix <= X"00"; -- black
		  else
			pix <= X"AA"; -- green
		  end if;
		else
	    -- semi-block graphics
	      if c1 = '1' then
			 case attrD (6 downto 4) is
				when "000" => -- green
					pix <= X"AA";
				when "001" => -- yellow
					pix <= X"BB";
				when "010" => -- blue
					pix <= X"CC";
				when "011" => -- red
					pix <= X"99";
				when "100" => -- white
					pix <= X"FF";
				when "101" => -- cyan
					pix <= X"EE";
				when "110" => -- magenta
					pix <= X"DD";
				when others => -- orange (well, light yellow/tan)
					pix <= X"33";
			 end case;
		  else
			  pix <= X"00"; -- black
		  end if;
		end if;
		
    end process;

end beh;

