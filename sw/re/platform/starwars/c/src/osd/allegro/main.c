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

extern void starwars (void);

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

#define VEC_RANGE 8192
#define HRES 1024
#define VRES 1024
#define SF 4

#define ADJ(x) ((x-VEC_RANGE/2)/SF+(HRES/2))

void osd_line (int16_t x1, int16_t y1, int16_t x2, int16_t y2, unsigned color)
{
	if (x1<0 || y1<0 || x2<0 || y2<0)
		return;
		
	//fprintf (stderr, "line(%d,%d)-(%d,%d)\n", x1, y1, x2, y2);
	// this is going to be an issue when a less-bright vector overwrites a brighter one
	// the intensities should add, but in this case they won't
	x1=ADJ(x1); y1=ADJ(y1); x2=ADJ(x2); y2=ADJ(y2);
	if (color)
		line (screen, x1, VRES-1-y1, x2, VRES-1-y2, color);
}

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (24);
	//set_gfx_mode (GFX_AUTODETECT_WINDOWED, 1024, 1024, 0, 0);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, HRES, VRES, 0, 0);
	//set_gfx_mode (GFX_AUTODETECT_WINDOWED, 256, 192, 0, 0);

#if 0
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
#endif

	clear_bitmap (screen);
  starwars ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}
END_OF_MAIN();
