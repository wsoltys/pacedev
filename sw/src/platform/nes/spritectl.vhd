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

	alias flipx		: std_logic is flags(0);
	alias flipy		: std_logic is flags(1);
	alias bg			: std_logic is flags(2);
	
  signal flipData : std_logic_vector(31 downto 0);   -- flipped row data

begin

  -- call up the flipper
  FLA : entity work.flipRow 
		generic map (16)
		port map (rowIn => rowData(31 downto 16), flip => flipx, rowOut => flipData(31 downto 16));

	process (clk, clk_ena)

   	variable rowStore : std_logic_vector(31 downto 0);  -- saved row of spt to show during visibile period
		alias pel : std_logic_vector(1 downto 0) is rowStore(31 downto 30);
    variable yMat  : boolean;                         	-- raster is between first and last line of sprite
    variable xMat  : boolean;                         	-- raster in between left edge and end of line
    variable xLocAdj : std_logic_vector(7 downto 0);
    variable yLocAdj : std_logic_vector(8 downto 0);

		-- nes sprites are only 8x8/16 pixels
		-- the width of rowCount determines the scanline multipler
		-- - eg.	(3 downto 0) is 1:1
		-- 				(4 downto 0) is 2:1 (scan-doubling)
  	variable rowCount : std_logic_vector(2+PACE_VIDEO_V_SCALE downto 0);

		variable pal_i : std_logic_vector(3 downto 0);
		variable pal_entry 	: pal_entry_typ;
		variable clut_entry	: std_logic_vector(7 downto 0);
		
  begin

		if rising_edge(clk) and clk_ena = '1' then

			xLocAdj := xLoc;
  		yLocAdj := yLoc;
			
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
				-- rowCount is not pixel-doubled, so 16==8 pixels high
				elsif rowCount(rowCount'left downto rowCount'left-3) = "1000" then
					yMat := false;				
				end if;

				if ena = '1' then
					if yMat then
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
					xMat := true;
				end if;
				
				-- extract R,G,B from colour palette
				-- normally the CLUT is read from palette RAM
				-- - but too hard to shoe-horn into PACE architecture
				--   so we'll cheat and used a fixed CLUT dumped from a running game
				clut_entry := clut(conv_integer('1' & colour(1 downto 0) & pel(0) & pel(1)));
				pal_entry := pal(conv_integer(clut_entry(5 downto 0)));
				rgb.r <= pal_entry(0) & "0000";
				rgb.g <= pal_entry(1) & "0000";
				rgb.b <= pal_entry(2) & "0000";

			  -- set pixel transparency based on match
				--if xMat and yMat and not (colour(1 downto 0) = "00" and pel = "00") then 
				if xMat and yMat and not (pel = "00") then 
			  	pixOn <= '1';
				else
					pixOn <= '0';
				end if;

				if xMat then
					-- shift in next pixel
					rowStore := rowStore(29 downto 0) & "00";
				end if;

			end if;

		end if;

		-- NES sprites only 8x8 (16 bytes) and 16-bits wide
		-- - the sprite port is also 16-bits wide (not 32)
		-- - rowAddr(12) is actually set by $2004.3
	  rowAddr(15 downto 3) <= '0' & num;
	  if flipy = '1' then
	  	rowAddr(2 downto 0) <= not rowCount(rowCount'left-1 downto rowCount'left-3);
	  else
	  	rowAddr(2 downto 0) <= rowCount(rowCount'left-1 downto rowCount'left-3);
	  end if;

  end process;

end beh;


