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

void osd_line (unsigned x1, unsigned y1, unsigned x2, unsigned y2, unsigned brightness)
{
	//printf ("line(%d,%d)-(%d,%d)\n", x1, y1, x2, y2);
	if (brightness)
		line (screen, x1, 1023-y1, x2, 1023-y2, 15);
}

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 1024, 1024, 0, 0);
	//set_gfx_mode (GFX_AUTODETECT_WINDOWED, 256, 192, 0, 0);

	clear_bitmap (screen);
  asteroids2 ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}
END_OF_MAIN();
