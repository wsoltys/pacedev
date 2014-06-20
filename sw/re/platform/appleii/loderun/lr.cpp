#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#include "vars.h"
#include "title_data_c2bpp.cpp"

ZEROPAGE	zp;

void gcls (uint8_t page)
{
	fprintf (stderr, "%s(%d)\n", __FUNCTION__, page);
	
	if (page == 1)
		clear_bitmap (screen);
}

void check_start_new_game (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void display_message (char *msg)
{
	fprintf (stderr, "%s(\"%s\")\n", __FUNCTION__, msg);
}

void display_no_lives (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void update_and_display_score (uint16_t pts)
{
	fprintf (stderr, "%s(%d)\n", __FUNCTION__, pts);
}

void cls_and_display_game_status (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	gcls (1);
	gcls (2);
	
	// draw separator
	//uint8_t byte = 0xcc; // mono
	uint8_t byte = 0xaa;
	for (int c=0; c<2*35; c++)
		for (int n=0; n<4; n++)
		{
			putpixel (screen, c*4+n, 176, byte>>((3-n)*2)&3);
			putpixel (screen, c*4+n, 177, byte>>((3-n)*2)&3);
			putpixel (screen, c*4+n, 178, byte>>((3-n)*2)&3);
			putpixel (screen, c*4+n, 179, byte>>((3-n)*2)&3);
		}
		
	display_message ("SCORE        MEN    LEVEL   ");
	display_no_lives ();
	update_and_display_score (0);
}
	
void main_game_loop (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void zero_score_and_init_game (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	zp.score = 0;
	zp.unused_97 = 0;
	zp.wipe_next_time = 0;
	zp.guard_respawn_col = 0;
	zp.demo_inp_cnt = 0;
	zp.demo_inp_ptr = 0;
	zp.no_lives = 5;
	zp.attract_mode >>= 1;
	
	cls_and_display_game_status ();
	// HGR1
	
	main_game_loop ();
}

void high_score_screen (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void title_wait_for_key (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	uint16_t  timeout = 5000/10;
	
	clear_keybuf ();
	while (timeout)
	{
		if (keypressed ())
			break;
		rest (10);
		timeout--;
	}
	
	if (timeout != 0)
	{
		check_start_new_game ();
	}
	else
	{
		if (zp.attract_mode == 0)
		{
			// init attract mode
			zp.attract_mode = 1;
			zp.level = 1;
			zp.byte_ac = 1;
			zp.no_cheat = 1;
			zp.sound_setting = zp.sound_enabled;
			zp.sound_enabled = 0;
			zero_score_and_init_game ();
		}
		else
		{
			if (zp.attract_mode == 1)
				high_score_screen ();
		}
	}
}

void display_title_screen (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	gcls (1);
	zp.attract_mode = 0;
	zp.level_0_based = 0;
	//zp.hires_page_msb1
	zp.display_char_page = 1;
	
	// this part needs abstracting (later)
	uint8_t *ptitle_data = title_data;
	zp.row = 192;
	zp.col = 2*35;
	while (zp.row > 0)
	{
		uint8_t count = *(ptitle_data++);
		uint8_t	byte = *(ptitle_data++);
		
		while (count--)
		{
			// put byte - fixme
			for (int n=0; n<4; n++)
				putpixel (screen, (2*35-zp.col)*4+n, (192-zp.row), byte>>((3-n)*2)&3);
			if (--zp.col == 0)
			{
				zp.col = 2*35;
				zp.row--;
			}
		}
	}
	// HGR1
	title_wait_for_key ();
}

void lode_runner (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	zp.game_speed = 6;
	zp.byte_64 = 0;
	zp.sound_enabled = (uint8_t)-1;
	
	display_title_screen ();
}

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 280, 192, 0, 0);

  PALETTE pal;
  uint8_t r[] = { 0x00, 255>>2,  20>>2, 255>>2 };
  uint8_t g[] = { 0x00, 106>>2, 208>>2, 255>>2 };
  uint8_t b[] = { 0x00,  60>>2, 254>>2, 255>>2 };
  for (int c=0; c<sizeof(r); c++)
  {
    pal[c].r = r[c];
    pal[c].g = g[c];
    pal[c].b = b[c];
  }
	set_palette_range (pal, 0, 3, 1);

	lode_runner ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
