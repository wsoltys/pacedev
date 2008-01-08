#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#define INV_SCALE     2
#define WIDTH_PIXELS	1024
#define HEIGHT_PIXELS	1024
#define WIDTH_BYTES		(WIDTH_PIXELS>>(2+INV_SCALE))
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>(2+INV_SCALE))

typedef unsigned char BYTE;

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS/INV_SCALE, HEIGHT_PIXELS/INV_SCALE, 0, 0);

	PALETTE pal;
	for (int c=0; c<64; c++)
	{
		pal[c].r = (int)(c/1.5);
		pal[c].g = (int)(c/1.5);
		pal[c].b = c;
  }
	set_palette_range (pal, 0, 64, 1);

  FILE *fp = fopen ("ast.dat", "rt");

  clear_bitmap (screen);

  int lines = 0;
  while (!feof (fp))
  {
    int x, y, z, r;
    int n = fscanf (fp, "%d,%d,%d,%d\n", &x, &y, &z, &r);
    if (n == 0) break;

    // add a few to show beam route
    int c = (z+2)*4;
    int p = getpixel (screen, x/INV_SCALE, (1023-y)/INV_SCALE);

    if (c > p)
      putpixel (screen, x/INV_SCALE, (1023-y)/INV_SCALE, c);
    
    lines++;
  }  

  fclose (fp);

  char buf[80];
  sprintf (buf, "VECTORS = %d", lines);
  SS_TEXTOUT_CENTRE(screen, font, buf, SCREEN_W/2, SCREEN_H-8, 63);

  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
}

END_OF_MAIN();

