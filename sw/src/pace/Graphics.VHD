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
    bitmap_ctl_i    : in to_BITMAP_CTL_t;
    bitmap_ctl_o    : out from_BITMAP_CTL_t;
    tilemap_ctl_i   : in to_TILEMAP_CTL_t;
    tilemap_ctl_o   : out from_TILEMAP_CTL_t;

    sprite_reg_i    : in to_SPRITE_REG_t;
    sprite_ctl_i    : in to_SPRITE_CTL_t;
    sprite_ctl_o    : out from_SPRITE_CTL_t;
		spr0_hit				: out std_logic;
    
    graphics_i      : in to_GRAPHICS_t;
    graphics_o      : out from_GRAPHICS_t;
    
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
    generic
    (
      DELAY         : integer
    );          
    port               
    (
      reset					: in std_logic;
        
      -- video control signals		
      video_ctl     : in from_VIDEO_CTL_t;

      -- bitmap controller signals
      ctl_i         : in to_BITMAP_CTL_t;
      ctl_o         : out from_BITMAP_CTL_t;
      
      graphics_i    : in to_GRAPHICS_t
    );
	end component;

	component tilemapCtl_1 is          
    generic
    (
      DELAY         : integer
    );          
    port               
    (
      reset				  : in std_logic;
        
      -- video control signals		
      video_ctl     : in from_VIDEO_CTL_t;

      -- tilemap controller signals
      ctl_i         : in to_TILEMAP_CTL_t;
      ctl_o         : out from_TILEMAP_CTL_t;
      
      graphics_i    : in to_GRAPHICS_t
    );
	end component;

	component tilemapCtl_2 is          
    generic
    (
      DELAY         : integer
    );
    port               
    (
      reset				  : in std_logic;
        
      -- video control signals		
      video_ctl     : in from_VIDEO_CTL_t;

      -- tilemap controller signals
      ctl_i         : in to_TILEMAP_CTL_t;
      ctl_o         : out from_TILEMAP_CTL_t;
      
      graphics_i    : in to_GRAPHICS_t
    );
	end component;

	alias clk 					    : std_logic is video_i.clk;

  signal from_video_ctl   : from_VIDEO_CTL_t;
  signal bitmap_ctl_o_s   : from_BITMAP_CTL_t;
  signal tilemap_ctl_o_s  : from_TILEMAP_CTL_t;
  signal sprite_ctl_o_s   : from_SPRITE_CTL_t;
  signal sprite_pri       : std_logic;
  
  signal osd_active       : std_logic;
  signal osd_colour       : std_logic_vector(7 downto 0);

	signal rgb_data			    : RGB_t;
  -- before OSD is mixed in
  signal video_o_s        : to_VIDEO_t;
  
begin

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

  graphics_o.y <= from_video_ctl.y;
  -- should this be the 'real' vblank or the 'active' vblank?
  -- - use the real for now
  graphics_o.vblank <= video_o_s.vblank;
  --graphics_o.vblank <= from_video_ctl.vblank;
    
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
			reg_i.h_scale	=> (others => '0'),
			reg_i.v_scale 	=> (others => '0'),
			
			-- If using Q10.x , replace the above two lines with these to avoid error(10427) "VHDL Aggregate error"
			--reg_i.h_scale	=> "000",
			--reg_i.v_scale 	=> "000",
      -- video data signals (in)
      rgb_i		    		=> rgb_data,

      -- video control signals (out)
      video_ctl_o     => from_video_ctl,

      -- VGA signals (out)
      video_o     		=> video_o_s
    );

  pace_video_mixer_inst : entity work.pace_video_mixer
    port map
    (
        bitmap_rgb    => bitmap_ctl_o_s.rgb,
        bitmap_set    => bitmap_ctl_o_s.set,
        tilemap_rgb   => tilemap_ctl_o_s.rgb,
        tilemap_set   => tilemap_ctl_o_s.set,
        sprite_rgb    => sprite_ctl_o_s.rgb,
        sprite_set    => sprite_ctl_o_s.set,
        sprite_pri    => sprite_pri,
        
        video_ctl_i   => from_video_ctl,
        graphics_i    => graphics_i,
        rgb_o         => rgb_data
    );
    
	GEN_NO_BITMAPS : if PACE_VIDEO_NUM_BITMAPS = 0 generate
    bitmap_ctl_o_s <= ((others => '0'), (others => (others => '0')), '0');
	end generate GEN_NO_BITMAPS;
	
	GEN_BITMAP_1 : if PACE_VIDEO_NUM_BITMAPS > 0 generate
	
	  bitmapctl_inst : bitmapCtl_1
      generic map
      (
        DELAY         => PACE_VIDEO_PIPELINE_DELAY
      )
	    port map
	    (
				reset					=> video_i.reset,
				
				video_ctl     => from_video_ctl,

	      ctl_i         => bitmap_ctl_i,
	      ctl_o         => bitmap_ctl_o_s,

        graphics_i    => graphics_i
	    );
		end generate GEN_BITMAP_1;

  bitmap_ctl_o <= bitmap_ctl_o_s;
    
	GEN_NO_TILEMAPS : if PACE_VIDEO_NUM_TILEMAPS = 0 generate
    tilemap_ctl_o_s <= ((others => '0'), (others => '0'), (others => '0'), 
                        (others => (others => '0')), '0');
	end generate GEN_NO_TILEMAPS;
	
	GEN_TILEMAP_1 : if PACE_VIDEO_NUM_TILEMAPS > 0 generate
	
	  foreground_mapctl_inst : tilemapCtl_1
      generic map
      (
        DELAY         => PACE_VIDEO_PIPELINE_DELAY
      )
	    port map
	    (
				reset					=> video_i.reset,
				
				video_ctl     => from_video_ctl,

				ctl_i         => tilemap_ctl_i,
				ctl_o         => tilemap_ctl_o_s,

        graphics_i    => graphics_i
	    );

		end generate GEN_TILEMAP_1;

  tilemap_ctl_o <= tilemap_ctl_o_s;

	GEN_NO_SPRITES : if PACE_VIDEO_NUM_SPRITES = 0 generate
    sprite_ctl_o_s <= ((others => '0'), (others => (others => '0')), '0');
    sprite_pri <= '0';
    spr0_hit <= '0';
	end generate GEN_NO_SPRITES;
	
	GEN_SPRITES : if PACE_VIDEO_NUM_SPRITES > 0 generate
	
		sprites_inst : sprite_array
      generic map
      (
        N_SPRITES     => PACE_VIDEO_NUM_SPRITES,
        DELAY         => PACE_VIDEO_PIPELINE_DELAY
      )
			port map
			(
				reset				  => video_i.reset,
  
        -- register interface
        reg_i         => sprite_reg_i,

        -- video control signals
        video_ctl     => from_video_ctl,

        graphics_i    => graphics_i,

				row_a         => sprite_ctl_o_s.a,
				row_d         => sprite_ctl_i.d,
				
				rgb					  => sprite_ctl_o_s.rgb,
				set           => sprite_ctl_o_s.set,
				pri           => sprite_pri,
				spr0_set	    => spr0_hit
			);

	end generate GEN_SPRITES;

  sprite_ctl_o <= sprite_ctl_o_s;

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
    from_osd <= NULL_FROM_OSD;
  end generate GEN_NO_OSD;

end SYN;
