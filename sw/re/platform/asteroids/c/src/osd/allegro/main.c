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

// pandora: run msys.bat and cd to this directory
//          g++ kl.c -o kl -lallegro-4.4.2-md

// neogeo:  d:\mingw_something\setenv.bat
//          g++ kl.c -o kl -lalleg

extern void asteroids2 (void);

unsigned int osd_quit (void)
{
	if (key[KEY_ESC])
		return (1);
	return (0);
}

int osd_key (int _key)
{
  return (key[_key]);
}

void osd_cls (void)
{
	clear_bitmap (screen);
}

//#define VRES 1024
#define VRES 788

void osd_line (unsigned x1, unsigned y1, unsigned x2, unsigned y2, unsigned brightness)
{
	//printf ("line(%d,%d)-(%d,%d)\n", x1, y1, x2, y2);
	// this is going to be an issue when a less-bright vector overwrites a brighter one
	// the intensities should add, but in this case they won't
	y1 = y1-(1024-VRES)/2;
	y2 = y2-(1024-VRES)/2;
	if (brightness)
		line (screen, x1, VRES-1-y1, x2, VRES-1-y2, brightness);
}

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	//set_gfx_mode (GFX_AUTODETECT_WINDOWED, 1024, 1024, 0, 0);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 1024, VRES, 0, 0);
	//set_gfx_mode (GFX_AUTODETECT_WINDOWED, 256, 192, 0, 0);

  PALETTE   pal;
  unsigned c;
  for (c=0; c<16; c++)
  {
    uint8_t rgb;

		rgb = (c == 0 ? 0 : c*16-1);    
    pal[c].r = rgb>>2;
    pal[c].g = rgb>>2;
    pal[c].b = rgb>>2;
  }
	set_palette_range (pal, 0, 15, 1);

	clear_bitmap (screen);
  asteroids2 ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}
END_OF_MAIN();
