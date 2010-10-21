library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Oric-1/Atmos Tilemap Controller
--

entity tilemapCtl_1 is          
  generic
  (
    DELAY         : integer
  );
  port               
  (
    reset				: in std_logic;

    -- video control signals		
    video_ctl   : in from_VIDEO_CTL_t;

    -- tilemap controller signals
    ctl_i       : in to_TILEMAP_CTL_t;
    ctl_o       : out from_TILEMAP_CTL_t;

    graphics_i  : in to_GRAPHICS_t
  );
end tilemapCtl_1;

architecture SYN of tilemapCtl_1 is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias texty 			: std_logic_vector(5 downto 0) is y(8 downto 3);

  signal col0_addr 	: std_logic_vector(9 downto 3);

begin

  ctl_o.tile_a(ctl_o.tile_a'left downto 10) <= (others => '0');

	-- these are constant for a whole line
  ctl_o.tile_a(2 downto 0) <=  y(2 downto 0);

  -- generate pixel
  process (clk, clk_ena, reset)

		-- pipelined pixel X location
    variable map_a    : std_logic_vector(ctl_o.map_a'range);
    variable map_a_r  : std_logic_vector(ctl_o.map_a'range);
		variable x_count	: std_logic_vector(8 downto 0);
		variable tile_d_r : std_logic_vector(7 downto 0);
		alias pel         : std_logic is tile_d_r(tile_d_r'left-2);
    variable hblank_r : std_logic;
    variable y_r      : std_logic_vector(2 downto 0);
  begin

		if rising_edge(clk) and clk_ena = '1' and stb = '1' then

      if vblank = '1' then
        -- start of text RAM ($BB80)
        -- - use the 'bit' address so we can increment each clock
        map_a_r := X"BB80";
        y_r := (others => '0');
      else
      
        if hblank = '1' then
          if hblank_r = '0' then
            -- need to handle the doubled y's due to 2x V-scaling
            if y(2 downto 0) = "111" and y_r(2 downto 0) = "111" then
              map_a_r := std_logic_vector(unsigned(map_a_r) + 40);
            end if;
            y_r := y(y_r'range);
          else
            map_a := map_a_r;
          end if;
          x_count := (others => '0');
        else
        
          -- 2nd stage of pipeline
          -- - read tile data from tile ROM
          -- - only 128 chars atm
          ctl_o.tile_a(9 downto 3) <= ctl_i.map_d(6 downto 0);

          -- 3rd stage of pipeline
          -- - assign pixel colour based on tile data
          -- (each byte contains information for 6 pixels)
          -- - and a pipeline delay of 3
          if x_count(2 downto 0) = "011" then
            tile_d_r := ctl_i.tile_d;
          else
            tile_d_r := tile_d_r(tile_d_r'left-1 downto 0) & '0';
          end if;
                      
          -- b/w display
          ctl_o.rgb.r <= (others => pel);
          ctl_o.rgb.g <= (others => pel);
          ctl_o.rgb.b <= (others => pel);
            
          -- characters are only 6 pixels wide
          if x_count(2 downto 0) = "101" then
            x_count := x_count + 3;
            -- next video address
            map_a := std_logic_vector(unsigned(map_a) + 1);
          else
            x_count := x_count + 1;
          end if;

        end if; -- hblank = '1'
        
      end if; -- vblank='1'
      
      hblank_r := hblank;
      
		end if;				

    ctl_o.set <= pel;
    ctl_o.map_a <= map_a;

  end process;

end SYN;

