library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;    

entity spritectl is
	generic
	(
		INDEX		: natural;
		DELAY   : integer
	);
	port               
	(
    -- sprite registers
    reg_i       : in from_SPRITE_REG_t;
    
    -- video control signals
    video_ctl   : in from_VIDEO_CTL_t;

    -- sprite control signals
    ctl_i       : in to_SPRITE_CTL_t;
    ctl_o       : out from_SPRITE_CTL_t;
    
		graphics_i  : in to_GRAPHICS_t
	);
end entity spritectl;

architecture SYN of spritectl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  
  signal flipData : std_logic_vector(31 downto 0);   -- flipped row data
   
  alias rgb       : RGB_t is ctl_o.rgb;
  
	--alias flipx		: std_logic is flags(0);
	--alias flipy		: std_logic is flags(1);
	--alias bg			: std_logic is flags(2);
	
begin

  flipData <= flip_row (ctl_i.d(31 downto 16) & ctl_i.d(31 downto 16), reg_i.xflip);

	process (clk, clk_ena)

   	variable rowStore : std_logic_vector(31 downto 0);  -- saved row of spt to show during visibile period
		alias pel : std_logic_vector(1 downto 0) is rowStore(31 downto 30);
    variable yMat : boolean;                         	-- raster is between first and last line of sprite
    variable xMat : boolean;                         	-- raster in between left edge and end of line
    variable x    : std_logic_vector(video_ctl.x'range);
    variable y    : std_logic_vector(video_ctl.y'range);

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

			x := reg_i.x;
  		y := reg_i.y;
			
			if video_ctl.hblank = '1' then

				xMat := false;
				-- stop sprites wrapping from bottom of screen
				if video_ctl.y = 0 then
					yMat := false;
				end if;
				
				if y = video_ctl.y then
					-- start counting sprite row
					rowCount := (others => '0');
					yMat := true;
				-- rowCount is not pixel-doubled, so 16==8 pixels high
				elsif rowCount(rowCount'left downto rowCount'left-3) = "1000" then
					yMat := false;				
				end if;

				if ctl_i.ld = '1' then
					if yMat then
						rowStore := flipData(31 downto 16) & X"0000";			-- load sprite data
					else
						rowStore := (others => '0');
					end if;
				end if;
						
			end if;
			
			if video_ctl.stb = '1' then
			
				if video_ctl.x = x then
					-- count up at left edge of sprite
					rowCount := rowCount + 1;
					-- start of sprite
					xMat := true;
				end if;
				
				-- extract R,G,B from colour palette
				-- normally the CLUT is read from palette RAM
				-- - but too hard to shoe-horn into PACE architecture
				--   so we'll cheat and used a fixed CLUT dumped from a running game
				clut_entry := clut(conv_integer('1' & reg_i.colour(1 downto 0) & pel(0) & pel(1)));
				pal_entry := pal(conv_integer(clut_entry(5 downto 0)));
				rgb.r <= pal_entry(0) & "0000";
				rgb.g <= pal_entry(1) & "0000";
				rgb.b <= pal_entry(2) & "0000";

				if xMat then
					-- shift in next pixel
					rowStore := rowStore(29 downto 0) & "00";
				end if;

			  -- set pixel transparency based on match
				--if xMat and yMat and not (colour(1 downto 0) = "00" and pel = "00") then 
        ctl_o.set <= '0';
				if xMat and yMat and not (pel = "00") then 
			  	ctl_o.set <= '1';
				end if;

			end if;

		end if;

		-- NES sprites only 8x8 (16 bytes) and 16-bits wide
		-- - the sprite port is also 16-bits wide (not 32)
		-- - rowAddr(12) is actually set by $2004.3
	  ctl_o.a(15 downto 3) <= '0' & reg_i.n;
	  if reg_i.yflip = '1' then
	  	ctl_o.a(2 downto 0) <= not rowCount(rowCount'left-1 downto rowCount'left-3);
	  else
	  	ctl_o.a(2 downto 0) <= rowCount(rowCount'left-1 downto rowCount'left-3);
	  end if;

  end process;

end SYN;


