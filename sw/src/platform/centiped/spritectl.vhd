library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;    

entity sptCtlVHDL is
	generic
	(
		INDEX		: natural
	);
	port               
	(
    clk     : in std_logic;
    clk_ena : in std_logic;

    -- VGA I/F
    HBlank  : in std_logic;       
    xAddr   : in std_logic_vector(7 downto 0);
    yAddr   : in std_logic_vector(8 downto 0);
    pixOn   : out std_logic;    
		rgb			: out RGBType;
		    
		bank_data	: in std_logic_vector(7 downto 0);
		
    -- Sprite I/F, sprite is 16 x 8 2 bit per pixel
    num     : in    std_logic_vector(11 downto 0);   -- which sprite in table to show for this controller
    xLoc    : in    std_logic_vector(7 downto 0);   -- X location
    yLoc    : in    std_logic_vector(8 downto 0);   -- Y location (line)
    colour	: in    std_logic_vector(7 downto 0);   -- colour base for PEL.
    flags   : in    std_logic_vector(7 downto 0);   -- flags to operate on sprites

    ena     : in    std_logic;                      -- this sprite can load row data
    rowData : in    std_logic_vector(31 downto 0);  -- 8 x 2 bpp row of sprite data
    rowAddr : out   std_logic_vector(15 downto 0)   -- (8 rows of sprite data and 16 sprites ) full vector to allow expansion
	);
end sptCtlVHDL;

architecture beh of sptCtlVHDL is

   signal flipData : std_logic_vector(31 downto 0);   -- flipped row data
begin

  -- call up the flipper
  FLA : entity work.flipRow port map (rowIn => rowData, flip => flags(0), rowOut => flipData);

	process (clk, clk_ena)

   	variable rowStore : std_logic_vector(31 downto 0);  -- saved row of spt to show during visibile period
		alias pel : std_logic_vector(1 downto 0) is rowStore(31 downto 30);
    variable yMat  : boolean;                         	-- raster is between first and last line of sprite
    variable xMat  : boolean;                         	-- raster in between left edge and end of line
    variable xLocAdj : std_logic_vector(7 downto 0);
    variable yLocAdj : std_logic_vector(8 downto 0);

		-- centipede sprites are only 8 pixels high!
		-- the width of rowCount determines the scanline multipler
		-- - eg.	(3 downto 0) is 1:1
		-- 				(4 downto 0) is 2:1 (scan-doubling)
  	variable rowCount : std_logic_vector(2+PACE_VIDEO_V_SCALE downto 0);

		variable pal_i : std_logic_vector(3 downto 0);
		variable pal_entry : pal_entry_typ;

  begin

		if rising_edge(clk) and clk_ena = '1' then

			xLocAdj := xLoc;
  		yLocAdj := yLoc - 17;
			
			if hblank = '1' then

				xMat := false;
				-- stop sprites wrapping from bottom of screen
				if yAddr = 0 then
					yMat := false;
				end if;
				
				if yLocAdj = yAddr then
					-- start counting sprite row
					rowCount := (others => '0');
					yMat := true;
				elsif rowCount(rowCount'left downto rowCount'left-3) = "1000" then
					yMat := false;				
				end if;

				-- sprites not visible before row 16				
				if ena = '1' then
					if yMat and yLocAdj > 16 then
						rowStore := flipData;			-- load sprite data
					else
						rowStore := (others => '0');
					end if;
				end if;
						
			else
			
				if xAddr = xLocAdj then
					-- count up at left edge of sprite
					rowCount := rowCount + 1;
					-- start of sprite
					if xAddr /= 0 and xAddr < 240 then
						xMat := true;
					end if;
				end if;
				
				-- extract R,G,B from colour palette
				-- apparently only 3 bits of colour info (aside from pel)
				--pal_entry := pal(conv_integer(colour(2 downto 0) & pel));
				pal_entry := pal(conv_integer("000" & pel));
				rgb.r <= pal_entry(0) & "0000";
				rgb.g <= pal_entry(1) & "0000";
				rgb.b <= pal_entry(2) & "0000";

			  -- set pixel transparency based on match
				pixOn <= '0';
				--if xMat and pel /= "00" then
				if xMat and yMat and (pal_entry(0)(5 downto 4) /= "00" or
															pal_entry(1)(5 downto 4) /= "00" or
															pal_entry(2)(5 downto 4) /= "00") then
			  	pixOn <= '1';
				end if;

				if xMat then
					-- shift in next pixel
					rowStore := rowStore(29 downto 0) & "00";
				end if;

			end if;

		end if;

		-- again, centipede sprites only 8 pixels high!
	  rowAddr(15 downto 3) <= '0' & num;
	  if flags(1) = '1' then
	  	rowAddr(2 downto 0) <= not rowCount(rowCount'left-1 downto rowCount'left-3);		-- flip Y
	  else
	  	rowAddr(2 downto 0) <= rowCount(rowCount'left-1 downto rowCount'left-3);
	  end if;

  end process;

end beh;


