Library IEEE;
Use     IEEE.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

entity Graphics is
  port
  (
    clk             : in std_logic;                       
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

    red             : out std_logic_vector(9 downto 0);    
    green           : out std_logic_vector(9 downto 0);    
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				: out std_logic_vector(9 downto 0);
		hblank					: out std_logic;
		vblank					: out std_logic;
    hsync           : out std_logic;                       
    vsync           : out std_logic;

    bw_cvbs         : out std_logic_vector(1 downto 0);    
    gs_cvbs         : out std_logic_vector(7 downto 0)    
  );

end Graphics;

architecture SYN of Graphics is

	-- don't really want this here,
	-- but prevents having dummy components
	-- *** some other way to fix???
	
	component bitmapCtl_1 is          
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

			scroll_data		: in std_logic_vector(7 downto 0);
			palette_data	: in ByteArrayType(15 downto 0);
			
	    -- bitmap interface
	    bitmap_d   		: in std_logic_vector(7 downto 0);
	    bitmap_a   		: out std_logic_vector(15 downto 0);

			-- RGB output (10-bits each)
			rgb						: out RGBType;
			bitmap_on			: out std_logic
	) ;
	end component;

	component mapCtl_1 is          
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

			scroll_data		: in std_logic_vector(7 downto 0);
			palette_data	: in ByteArrayType(15 downto 0);

	    -- tilemap interface
	    tilemap_d   : in std_logic_vector(15 downto 0);
	    tilemap_a   : out std_logic_vector(15 downto 0);
	    tile_d      : in std_logic_vector(7 downto 0);
	    tile_a      : out std_logic_vector(15 downto 0);
	    attr_d      : in std_logic_vector(15 downto 0);
	    attr_a      : out std_logic_vector(9 downto 0);

			-- RGB output (10-bits each)
			rgb					: out RGBType;
			tilemap_on	: out std_logic
	) ;
	end component;

	component mapCtl_2 is          
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
			rgb					: out RGBType;
			tilemap_on	: out std_logic
	) ;
	end component;

	component sptArray is
		port
		(
			clk					: in std_logic;
			clk_ena			: in std_logic;
			reset				: in std_logic;

      bank_data   : in std_logic_vector(7 downto 0);
			
			hblank			: in std_logic;
			xAddr				: in std_logic_vector(7 downto 0);
			yAddr				: in std_logic_vector(8 downto 0);
			dIn					: in std_logic_vector(7 downto 0);
			spriteAddr	: out std_logic_vector(15 downto 0);
			spriteData	: in std_logic_vector(31 downto 0);
			sprite_wr		: in std_logic;
			sprRegAddr	: in std_logic_vector(7 downto 0);
			
			rgb					: out RGBType;
			spr_on			: out std_logic;
			spr_pri			: out std_logic;
			spr0_on			: out std_logic
		);
	end component;

	signal pix_clk_ena	: std_logic;
  signal strobe       : std_logic;
	signal pix_x				: std_logic_vector(9 downto 0);
	signal pix_y				: std_logic_vector(9 downto 0);
  signal hblank_s     : std_logic;
  signal vblank_s     : std_logic;

	signal bitmap_rgb		: RGBArrayType(1 to 1);
	signal bitmap_on		: std_logic_vector(1 to 1);
	
	signal tilemap_rgb	: RGBArrayType(1 to 1);
	signal tilemap_on		: std_logic_vector(1 to 1);
	
	signal sprite_rgb		: RGBType;
	signal sprite_on		: std_logic;
	signal sprite_pri		: std_logic;
	signal sprite0_on		: std_logic;

	signal rgb_data			: RGBType;
			
begin

	-- generate final RGB signal
	rgb_data <= sprite_rgb when sprite_on = '1' and sprite_pri = '1' else
							tilemap_rgb(1) when tilemap_on(1) = '1' else
							sprite_rgb when sprite_on = '1' else
							bitmap_rgb(1);
	
	-- it's actually more complicated than this on the NES
	-- but it'll do for now...
	spr0_hit <= sprite0_on;
	
	-- needed in a lot of games
	hblank <= hblank_s;
	vblank <= vblank_s;
	
  -- assign top-level output ports
  bw_cvbs <= (others => '0');
  gs_cvbs <= (others => '0');

	-- because some video controllers only strobe during active video
  pix_clk_ena <= strobe or hblank_s;
		
  vgacontroller_inst : entity work.VGAController
    port map
    (
      clk         => clk,
			reset				=> reset,

			xcentre			=> xcentre,
			ycentre			=> ycentre,
			
			-- video control signals (out)
      strobe      => strobe,
			pixel_x			=> pix_x,
			pixel_y			=> pix_y,
      hblank      => hblank_s,
      vblank      => vblank_s,

			-- video data signals (in)
			r_i					=> rgb_data.r,
			g_i					=> rgb_data.g,
			b_i					=> rgb_data.b,

			-- VGA signals (out)
      red         => red,
      green       => green,
      blue        => blue,
			lcm_data		=> lcm_data,
      hsync       => hsync,
      vsync       => vsync
    );

	GEN_NO_BITMAPS : if PACE_VIDEO_NUM_BITMAPS = 0 generate
	
		bitmapa <= (others => '0');

		bitmap_rgb(1).r <= (others => '0');
		bitmap_rgb(1).g <= (others => '0');
		bitmap_rgb(1).b <= (others => '0');
		bitmap_on(1) <= '0';
	
	end generate GEN_NO_BITMAPS;
	
	GEN_BITMAP_1 : if PACE_VIDEO_NUM_BITMAPS > 0 generate
	
	  bitmapctl_inst : bitmapCtl_1
	    port map
	    (
	      clk      			=> clk,
				clk_ena				=> pix_clk_ena,
				reset					=> reset,
				
	      hblank   			=> hblank_s,
	      vblank   			=> vblank_s,
	      pix_x     		=> pix_x,
	      pix_y     		=> pix_y,

				scroll_data		=> extra_data,
				palette_data	=> palette_data,
	      bitmap_a 			=> bitmapa,
	      bitmap_d 			=> bitmapd,

				rgb						=> bitmap_rgb(1),
				bitmap_on			=> bitmap_on(1)
	    );

		end generate GEN_BITMAP_1;

	GEN_NO_TILEMAPS : if PACE_VIDEO_NUM_TILEMAPS = 0 generate
	
		tilemapa <= (others => '0');
		tilea <= (others => '0');
		attra <= (others => '0');

		tilemap_rgb(1).r <= (others => '0');
		tilemap_rgb(1).g <= (others => '0');
		tilemap_rgb(1).b <= (others => '0');
		tilemap_on(1) <= '0';
	
	end generate GEN_NO_TILEMAPS;
	
	GEN_TILEMAP_1 : if PACE_VIDEO_NUM_TILEMAPS > 0 generate
	
	  foreground_mapctl_inst : mapCtl_1
	    port map
	    (
	      clk      			=> clk,
				clk_ena				=> pix_clk_ena,
				reset					=> reset,
				
	      hblank   			=> hblank_s,
	      vblank   			=> vblank_s,
	      pix_x     		=> pix_x,
	      pix_y     		=> pix_y,

				scroll_data		=> extra_data,
				palette_data	=> palette_data,
				
	      tilemap_a 		=> tilemapa,
	      tilemap_d 		=> tilemapd,
	      tile_a    		=> tilea,
	      tile_d    		=> tiled,
	      attr_a    		=> attra,
	      attr_d    		=> attrd,

				rgb						=> tilemap_rgb(1),
				tilemap_on		=> tilemap_on(1)
	    );

		end generate GEN_TILEMAP_1;

	GEN_NO_SPRITES : if PACE_VIDEO_NUM_SPRITES = 0 generate

		spriteaddr <= (others => '0');
		sprite_rgb.r <= (others => '0');
		sprite_rgb.g <= (others => '0');
		sprite_rgb.b <= (others => '0');
		sprite_on <= '0';
		
		sprite_rgb.r <= (others => '0');
		sprite_rgb.g <= (others => '0');
		sprite_rgb.b <= (others => '0');
		sprite_on <= '0';
		sprite0_on <= '0';

	end generate GEN_NO_SPRITES;
	
	GEN_SPRITES : if PACE_VIDEO_NUM_SPRITES > 0 generate
	
		sprites_inst : sptArray
			port map
			(
				clk					=> clk,
				clk_ena			=> pix_clk_ena,
				reset				=> reset,
				
        bank_data   => extra_data,

				hblank			=> hblank_s,
				xAddr				=> pix_x(7 downto 0),
				yAddr				=> pix_y(8 downto 0),
				dIn					=> uPdata,
				spriteAddr	=> spriteAddr,
				spriteData	=> spriteData,
				sprite_wr		=> sprite_wr,
				sprRegAddr	=> sprite_reg_addr,
				
				rgb					=> sprite_rgb,
				spr_on			=> sprite_on,
				spr_pri			=> sprite_pri,
				spr0_on			=> sprite0_on
			);

	end generate GEN_SPRITES;
	
end SYN;

