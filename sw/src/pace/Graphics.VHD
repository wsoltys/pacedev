library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity Graphics is
  port
  (
		reset						: in std_logic;

    sprite_reg_i    : to_SPRITE_REG_t;
    
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
		spr0_hit				: out std_logic;

		to_osd          : in to_OSD_t; 
		from_osd        : out from_OSD_t;

		video_i					: in from_VIDEO_t;
		video_o					: out to_VIDEO_t
  );

end Graphics;

architecture SYN of Graphics is

	-- don't really want this here,
	-- but prevents having dummy components
	-- *** some other way to fix???
	
	component bitmapCtl_1 is          
	port               
	(
			reset					: in std_logic;
			
			-- video control signals		
			video_ctl     : in from_VIDEO_CTL_t;

			scroll_data		: in std_logic_vector(7 downto 0);
			palette_data	: in ByteArrayType(15 downto 0);
			
	    -- bitmap interface
	    bitmap_d   		: in std_logic_vector(7 downto 0);
	    bitmap_a   		: out std_logic_vector(15 downto 0);

			-- RGB output (10-bits each)
			rgb						: out RGB_t;
			bitmap_on			: out std_logic
	) ;
	end component;

	component tilemapCtl_1 is          
	port               
	(
			reset				: in std_logic;
			
			-- video control signals		
			video_ctl     : in from_VIDEO_CTL_t;

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
			rgb					: out RGB_t;
			tilemap_on	: out std_logic
	) ;
	end component;

	component tilemapCtl_2 is          
	port               
	(
			reset				: in std_logic;
			
			-- video control signals		
			video_ctl     : in from_VIDEO_CTL_t;

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
			rgb					: out RGB_t;
			tilemap_on	: out std_logic
	) ;
	end component;

	component sptArray is
		port
		(
      reg_i       : to_SPRITE_REG_t;
      
			clk					: in std_logic;
			clk_ena			: in std_logic;
			reset				: in std_logic;

      bank_data   : in std_logic_vector(7 downto 0);
			
			hblank			: in std_logic;
			xAddr				: in std_logic_vector(7 downto 0);
			yAddr				: in std_logic_vector(8 downto 0);
			spriteAddr	: out std_logic_vector(15 downto 0);
			spriteData	: in std_logic_vector(31 downto 0);
			
			rgb					: out RGB_t;
			spr_on			: out std_logic;
			spr_pri			: out std_logic;
			spr0_on			: out std_logic
		);
	end component;

	alias clk 					    : std_logic is video_i.clk;

  signal from_video_ctl   : from_VIDEO_CTL_t;
  
	signal bitmap_rgb		: RGBArrayType(1 to 1);
	signal bitmap_on		: std_logic_vector(1 to 1);
	
	signal tilemap_rgb	: RGBArrayType(1 to 1);
	signal tilemap_on		: std_logic_vector(1 to 1);
	
	signal sprite_rgb		: RGB_t;
	signal sprite_on		: std_logic;
	signal sprite_pri		: std_logic;
	signal sprite0_on		: std_logic;

  signal osd_active   : std_logic;
  signal osd_colour   : std_logic_vector(7 downto 0);

	signal rgb_data			: RGB_t;
  -- before OSD is mixed in
  signal video_o_s    : to_VIDEO_t;
  
begin

	-- generate final RGB signal
	rgb_data <= sprite_rgb when sprite_on = '1' and sprite_pri = '1' else
							tilemap_rgb(1) when tilemap_on(1) = '1' else
							sprite_rgb when sprite_on = '1' else
							bitmap_rgb(1);

  -- dodgy OSD transparency...
	video_o.clk <= video_o_s.clk;
  video_o.rgb.r <= 	video_o_s.rgb.r when (to_osd.en and osd_active) = '0' else 
            				osd_colour(2 downto 0) & video_o_s.rgb.r(9 downto 6) & "000";
  video_o.rgb.g <=  video_o_s.rgb.g when (to_osd.en and osd_active) = '0' else 
            				osd_colour(5 downto 3) & video_o_s.rgb.g(9 downto 6) & "000";
  video_o.rgb.b <= 	video_o_s.rgb.b when (to_osd.en and osd_active) = '0' else 
            				osd_colour(7 downto 6) & '0' & video_o_s.rgb.b(9 downto 6) & "000";
	video_o.hsync <= video_o_s.hsync;
	video_o.vsync <= video_o_s.vsync;
	video_o.hblank <= video_o_s.hblank;
	video_o.vblank <= video_o_s.vblank;

	-- it's actually more complicated than this on the NES
	-- but it'll do for now...
	spr0_hit <= sprite0_on;
	
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
      -- clocking etc
      video_i         => video_i,
      
			-- register interface
			reg_i.h_scale		=> (others => '0'),
			reg_i.v_scale 	=> (others => '0'),

      -- video data signals (in)
      rgb_i		    		=> rgb_data,

      -- video control signals (out)
      video_ctl_o     => from_video_ctl,

      -- VGA signals (out)
      video_o     		=> video_o_s
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
				reset					=> reset,
				
				video_ctl     => from_video_ctl,

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
	
	  foreground_mapctl_inst : tilemapCtl_1
	    port map
	    (
				reset					=> reset,
				
				video_ctl     => from_video_ctl,

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
    sprite_pri <= '0';
		sprite0_on <= '0';

	end generate GEN_NO_SPRITES;
	
	GEN_SPRITES : if PACE_VIDEO_NUM_SPRITES > 0 generate
	
		sprites_inst : sptArray
			port map
			(
        reg_i         => sprite_reg_i,
        
        clk           => video_i.clk,
        clk_ena       => video_i.clk_ena,
				reset				  => reset,
				
        bank_data   => extra_data,

				hblank			=> from_video_ctl.hblank,
				xAddr				=> from_video_ctl.x(7 downto 0),
				yAddr				=> from_video_ctl.y(8 downto 0),
				spriteAddr	=> spriteAddr,
				spriteData	=> spriteData,
				
				rgb					=> sprite_rgb,
				spr_on			=> sprite_on,
				spr_pri			=> sprite_pri,
				spr0_on			=> sprite0_on
			);

	end generate GEN_SPRITES;

  GEN_OSD : if PACE_HAS_OSD generate

    OSD_BLOCK : block

      component textmode is
        port
        (
          clk           : in std_logic;
          ce            : in std_logic;
          vsync         : in std_logic;
          hsync         : in std_logic;
          pixel         : out std_logic;
          background    : out std_logic;
          address       : in std_logic_vector(7 downto 0);
          data          : in std_logic_vector(7 downto 0);
          wren          : in std_logic;
          q             : out std_logic_vector(7 downto 0)
        );
      end component textmode;

      component oneshot is
        generic
        (
          CLOCKS    : natural := 16
        );
        port
        (
          clk       : in std_logic;
          ce        : in std_logic;
          trigger   : in std_logic;
          q         : out std_logic
        );
      end component oneshot;

      signal hsync_p        : std_logic;
      signal osd_vsync      : std_logic;
      signal osd_hsync      : std_logic;
      signal osd_fg         : std_logic;
      signal osd_bg         : std_logic;
      signal osd_xdelay     : std_logic;

    begin

      -- oneshot triggers on rising_egde
      hsync_p <= not video_o_s.hsync;

      lineos0 : oneshot
        generic map
        (
          CLOCKS          => PACE_OSD_XPOS
        )
        port map
        (
          clk             => clk,
          ce              => '1',
          trigger         => hsync_p, 
          q               => osd_xdelay
        );

      -- active low line 128
      osd_vsync <= '0' when conv_integer(from_video_ctl.y) = PACE_OSD_YPOS else '1';

      process (clk)
        variable osd_xdelaybuf : std_logic;
      begin
        if rising_edge(clk) then
          if osd_xdelaybuf = '1' and osd_xdelay = '0' then
            osd_hsync <= '0';
          else
            osd_hsync <= '1';
          end if;
          osd_xdelaybuf := osd_xdelay;
        end if;
      end process;

      osd_inst : textmode
        port map
        (
          clk             => clk,
          ce              => '1',
          vsync           => osd_vsync,
          hsync           => osd_hsync,
          pixel           => osd_fg,
          background      => osd_bg,
          address         => to_osd.a,
          data            => to_osd.d,
          wren            => to_osd.we,
          q               => from_osd.d
        );

      process (clk)
      begin
        if rising_edge(clk) then
          if osd_bg = '1' then
            osd_active <= '1';
            if osd_fg = '1' then
              osd_colour <= X"FE";
            else
              osd_colour <= X"59";
            end if;
          else
            osd_active <= '0';
          end if;
        end if;
      end process;

    end block OSD_BLOCK;

  end generate GEN_OSD;

  GEN_NO_OSD : if not PACE_HAS_OSD generate

    osd_active <= '0';

  end generate GEN_NO_OSD;

end SYN;
