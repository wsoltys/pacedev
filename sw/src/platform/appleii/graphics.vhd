library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity Graphics is
  port
  (
		reset						: in std_logic;

		xcentre					: in std_logic_vector(9 downto 0);
		ycentre					: in std_logic_vector(9 downto 0);
		
    extra_data      : in std_logic_vector(7 downto 0);
		palette_data		: in ByteArrayType(15 downto 0);
						
    bitmapa        	: out std_logic_vector(15 downto 0);   
    bitmapd        	: in std_logic_vector(7 downto 0);    
    tilemapa        : out std_logic_vector(15 downto 0);   
    tilemapd        : in std_logic_vector(15 downto 0);    
    tilea           : out std_logic_vector(15 downto 0);   
    tiled           : in std_logic_vector(7 downto 0);    
    attra           : out std_logic_vector(9 downto 0);    
    attrd           : in std_logic_vector(15 downto 0);   

    spriteaddr      : out std_logic_vector(15 downto 0);   
    spritedata      : in std_logic_vector(31 downto 0);   
    sprite_reg_addr : in std_logic_vector(7 downto 0);    
    updata          : in std_logic_vector(7 downto 0);    
    sprite_wr       : in std_logic;
		spr0_hit				: out std_logic;

		to_osd          : in to_OSD_t; 
		from_osd        : out from_OSD_t;

		video_i					: in from_VIDEO_t;
		video_o					: out to_VIDEO_t;
		
    bw_cvbs         : out std_logic_vector(1 downto 0);    
    gs_cvbs         : out std_logic_vector(7 downto 0)    
  );

end Graphics;

architecture SYN of Graphics is

	signal pix_clk_ena	: std_logic;
  signal strobe       : std_logic;
	signal pix_x				: std_logic_vector(10 downto 0);
	signal pix_y				: std_logic_vector(10 downto 0);
  signal hblank_s     : std_logic;
  signal vblank_s     : std_logic;

	signal bitmap_rgb		: RGB_t;
	--signal bitmap_on		: std_logic;
	signal tilemap_rgb	: RGB_t;
	--signal tilemap_on		: std_logic;
	
	signal rgb_data			: RGB_t;

	alias a2var					: std_logic_vector(15 downto 0) is spritedata(15 downto 0);
	alias gfxmode				: std_logic_vector(3 downto 0) is a2var(11 downto 8);
					
begin

  -- assign top-level output ports
  bw_cvbs <= (others => '0');
  gs_cvbs <= (others => '0');

	-- mux the graphics layers
	--rgb_data.r <= tilemap_rgb.r or bitmap_rgb.r;
	--rgb_data.g <= tilemap_rgb.g or bitmap_rgb.g;
	--rgb_data.b <= tilemap_rgb.b or bitmap_rgb.b;
	
	rgb_data <= -- text mode
							--tilemap_rgb when STD_MATCH(gfxmode, "---0") else
							-- mixed-mode graphics & text
							bitmap_rgb 	when STD_MATCH(gfxmode, "1-10") and pix_y < 160 else
							--tilemap_rgb when STD_MATCH(gfxmode, "1-10") and pix_y >=160 else
							-- full-screen graphics
							bitmap_rgb 	when STD_MATCH(gfxmode, "1-00") else
							-- everything else
							tilemap_rgb;

	-- because some video controllers only strobe during active video
  pix_clk_ena <= strobe or hblank_s;

	-- not used
	spriteaddr <= (others => '0');
	spr0_hit <= '0';
				
  pace_video_controller_inst : entity work.pace_video_controller
    generic map
    (
      CONFIG		  => PACE_VIDEO_CONTROLLER_TYPE,
      DELAY       => PACE_VIDEO_PIPELINE_DELAY,
      H_SIZE      => PACE_VIDEO_H_SIZE,
      V_SIZE      => PACE_VIDEO_V_SIZE,
      H_SCALE     => PACE_VIDEO_H_SCALE,
      V_SCALE     => PACE_VIDEO_V_SCALE,
      BORDER_RGB  => PACE_VIDEO_BORDER_RGB
    )
    port map
    (
      clk         		=> video_i.clk,
      clk_ena     		=> video_i.clk_ena,
      reset						=> reset,

			-- register interface
			reg_i.h_scale		=> (others => '0'),
			reg_i.v_scale 	=> (others => '0'),

      -- video data signals (in)
      rgb_i		    		=> rgb_data,

      -- video control signals (out)
      stb         		=> strobe,
      hblank     			=> hblank_s,
      vblank					=> vblank_s,
      x								=> pix_x,
      y 							=> pix_y,

      -- VGA signals (out)
      video_o     		=> video_o
    );

  bitmapctl_inst : entity work.bitmapCtl_1
    port map
    (
      clk      			=> video_i.clk,
      clk_ena       => video_i.clk_ena,
      reset					=> reset,
      
      stb           => pix_clk_ena,
      hblank   			=> hblank_s,
      vblank   			=> vblank_s,
      x     		    => pix_x,
      y     		    => pix_y,

      bitmap_a 			=> bitmapa,
      bitmap_d 			=> bitmapd,

      rgb						=> bitmap_rgb,
      bitmap_on			=> open
    );

  text_mapctl_inst : entity work.tilemapCtl_1
    port map
    (
      clk      			=> video_i.clk,
      clk_ena     	=> video_i.clk_ena,
      reset					=> reset,
      
      stb				    => pix_clk_ena,
      hblank   			=> hblank_s,
      vblank   			=> vblank_s,
      x     		    => pix_x,
      y     		    => pix_y,

      tilemap_a 		=> tilemapa,
      tilemap_d 		=> tilemapd,
      tile_a    		=> tilea,
      tile_d    		=> tiled,
      attr_a    		=> attra,
      attr_d    		=> attrd,

      rgb						=> tilemap_rgb,
      tilemap_on		=> open
    );

end SYN;

