library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;    

--
-- Gameboy Sprite Controller
--
--  Sprite data is 16 bits wide:
--  <bitplane1><bitplane0> x8
--

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

  signal flipData : std_logic_vector(15 downto 0);   -- flipped row data
   
begin

  -- handle xflip
  flipData(15 downto 0) <= flip_row (ctl_i.d(15 downto 0), reg_i.xflip);
  
	process (clk)

   	variable rowStore : std_logic_vector(15 downto 0);  -- saved row of spt to show during visibile period
		variable pel      : std_logic_vector(1 downto 0);
    variable x        : unsigned(video_ctl.x'range);
    variable y        : unsigned(video_ctl.y'range);
    variable yMat     : boolean;    -- raster is between first and last line of sprite
    variable xMat     : boolean;    -- raster in between left edge and end of line

		-- the width of rowCount determines the scanline multipler
		-- - eg.	(4 downto 0) is 1:1
		-- 				(5 downto 0) is 2:1 (scan-doubling)
  	variable rowCount : std_logic_vector(3+PACE_VIDEO_V_SCALE downto 0);

    variable pel_i      : integer range 0 to 3;
		variable pal_entry  : palette_entry_t;

  begin

		if rising_edge(clk) then
      if clk_ena = '1' then

        x := unsigned(reg_i.x);
        y := unsigned(reg_i.y);
        
        if video_ctl.hblank = '1' then

          xMat := false;
          -- stop sprites wrapping from bottom of screen
          if unsigned(video_ctl.y) = 0 then
            yMat := false;
          end if;
          
          if y = unsigned(video_ctl.y) then
            -- start counting sprite row
            rowCount := (others => '0');
            yMat := true;
          elsif rowCount(rowCount'left downto rowCount'left-4) = "10000" then
            yMat := false;				
          end if;

          if ctl_i.ld = '1' then
            if yMat then
              rowStore := flipData;			-- load sprite data
            else
              rowStore := (others => '0');
            end if;
          end if;
              
        elsif video_ctl.stb = '1' then
        
          if unsigned(video_ctl.x) = x then
            -- count up at left edge of sprite
            rowCount := std_logic_vector(unsigned(rowCount) + 1);
            xMat := true;
          end if;
          
          if xMat then
            -- shift in next pixel
            pel := rowStore(15) & rowStore(14);
            --rowStore(15 downto 0) := "00" & rowStore(15 downto 2);
            rowStore(15 downto 0) := rowStore(13 downto 0) & "00";
          end if;

        end if;

        -- extract R,G,B from colour palette
        pel_i := to_integer(unsigned(pel));
        pal_entry := pal(pel_i);
        ctl_o.rgb.r <= pal_entry(0) & "00";
        ctl_o.rgb.g <= pal_entry(1) & "00";
        ctl_o.rgb.b <= pal_entry(2) & "00";

        -- set pixel transparency based on match
        ctl_o.set <= '0';
        if xMat and yMat and (pel_i /= 0) then
          ctl_o.set <= '1';
        end if;

      end if; -- clk_ena='1'

      -- generate sprite data address
      ctl_o.a(ctl_o.a'left downto 12) <= (others => '0');
      ctl_o.a(11 downto 4) <= reg_i.n(7 downto 0);
      if reg_i.yflip = '1' then
        ctl_o.a(3 downto 0) <= not rowCount(rowCount'left-1 downto rowCount'left-4);
      else
        ctl_o.a(3 downto 0) <= rowCount(rowCount'left-1 downto rowCount'left-4);
      end if;
      
    end if; -- rising_edge(clk)
  end process;

end SYN;
