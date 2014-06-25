#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#define ALLEGRO_STATICLINK

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

// osd stuff

RLE_SPRITE *tile[0x68];
BITMAP *pg[2];
#define HGR1 scroll_screen (0, 0)
#define HGR2 scroll_screen (0, 192)

#include "lr_osd.h"

extern uint8_t title_data[];
extern uint8_t tile_data_c2bpp[];

extern void lode_runner (void);

void osd_gcls (uint8_t page)
{
	clear_bitmap (pg[page-1]);
}

void osd_display_char_pg (uint8_t page, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
  uint16_t  x = x_div_2 * 2;
  
	// fudge: fixme
	rectfill (pg[page-1], x, y, x+9, y+10, 0);
	draw_rle_sprite (pg[page-1], tile[chr], x, y);
}

void osd_draw_separator (uint8_t page, uint8_t byte, uint8_t y)
{  	
	for (int c=0; c<2*35; c++)
		for (int n=0; n<4; n++)
		{
			putpixel (pg[page-1], c*4+n, y+0, byte>>((3-n)*2)&3);
			putpixel (pg[page-1], c*4+n, y+1, byte>>((3-n)*2)&3);
			putpixel (pg[page-1], c*4+n, y+2, byte>>((3-n)*2)&3);
			putpixel (pg[page-1], c*4+n, y+3, byte>>((3-n)*2)&3);
		}
}		

void osd_wipe_circle (void)
{
  // fixme
  rectfill (pg[0], 0, 0, 279, 175, 0);
}

void osd_draw_circle (void)
{
  // fixme
	blit (pg[1], pg[0], 0, 0, 0, 0, 280, 176);
}

int osd_keypressed (void)
{
  return (keypressed ());
}

void osd_delay (unsigned ms)
{
  rest (ms);
}

int osd_readkey (void)
{
  return (readkey ());
}

int osd_key (int _key)
{
  return (key[_key]);
}

void osd_wipe_char (uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	// quick hack for now
	blit (pg[1], pg[0], x_div_2*2, y, x_div_2*2, y, 10, 11);
}

void osd_display_transparent_char (uint8_t chr, uint8_t x_div_2, uint8_t y)
{
  // always page HGR1
	draw_rle_sprite (pg[0], tile[chr], x_div_2*2, y);
}

void osd_hgr (uint8_t page)
{
  if (page == 0)
    HGR1;
  else
    HGR2;
}

void osd_flush_keybd (void)
{
	clear_keybuf ();
}

void osd_display_title_screen (uint8_t page)
{
  uint8_t *ptitle_data = title_data;

	uint8_t row = 192;
	uint8_t col = 2*35;
	while (row > 0)
	{
		uint8_t count = *(ptitle_data++);
		uint8_t	byte = *(ptitle_data++);
		
		while (count--)
		{
			// put byte - fixme
			for (int n=0; n<4; n++)
				putpixel (pg[page-1], (2*35-col)*4+n, (192-row), byte>>((3-n)*2)&3);
				//pg[page-1]->line[(192-row)][(2*35-col)*4+n] = byte>>((3-n)*2)&3;
			if (--col == 0)
			{
				col = 2*35;
				row--;
			}
		}
	}
}

int main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	if (set_gfx_mode (GFX_AUTODETECT_WINDOWED, 280, 16+2*192, 0, 0) < 0)
	//if (set_gfx_mode (GFX_AUTODETECT_WINDOWED, 320, 200, 1024, 768) < 0)
  {
		fprintf (stderr, "set_gfx_mode() failed!\n");
		exit (0);
  }
	fprintf (stderr, "w=%d, h=%d, v_w=%d, v_h=%d\n",
						SCREEN_W, SCREEN_H, VIRTUAL_W, VIRTUAL_H);

	pg[0] = create_sub_bitmap (screen, 0, 0, 280, 192);
	pg[1] = create_sub_bitmap (screen, 0, 16+192, 280, 192);
	if (pg[0] == NULL || pg[1] == NULL)
	{
		fprintf (stderr, "create_sub_bitmap (screen) failed!\n");
		exit (0);
	}
	
  PALETTE pal;
  uint8_t r[] = { 0x00, 255>>2,  20>>2, 255>>2 };
  uint8_t g[] = { 0x00, 106>>2, 208>>2, 255>>2 };
  uint8_t b[] = { 0x00,  60>>2, 254>>2, 255>>2 };
  for (unsigned c=0; c<sizeof(r); c++)
  {
    pal[c].r = r[c];
    pal[c].g = g[c];
    pal[c].b = b[c];
  }
	set_palette_range (pal, 0, 3, 1);

	// setup sprites
	BITMAP *bm = create_bitmap (10, 11);
	for (int s=0; s<0x68; s++)
	{
		for (unsigned y=0; y<11; y++)
		{
			for (unsigned x=0; x<10; x++)
			{
				uint8_t data = tile_data_c2bpp[s*33+y*3+x/4];
				data >>= (3-(x%4))*2;
				data &= 3;
				putpixel (bm, x, y, data);
			}
		}
		tile[s] = get_rle_sprite (bm);
	}
	destroy_bitmap (bm);

	lode_runner ();

  //while (!key[KEY_ESC]);	  
	//while (key[KEY_ESC]);	  

	if (pg[0]) destroy_bitmap (pg[0]);
	if (pg[1]) destroy_bitmap (pg[1]);
	
  allegro_exit ();
  
  return (0);
}

END_OF_MAIN()
