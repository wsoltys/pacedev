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

//#define SHOW_CHARSET
#define SHOW_MODE6

#define INV_SCALE     2
#define WIDTH_PIXELS	1024
#define HEIGHT_PIXELS	1024
#define WIDTH_BYTES		(WIDTH_PIXELS>>(2+INV_SCALE))
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>(2+INV_SCALE))

typedef unsigned char BYTE;
BYTE mem[64*1024];

void disp_char(int x, int y, BYTE c)
{
	unsigned char *p = &mem[0xC000+c*8];

	int py;
	for (py=0; py<8; py++)
	{
		BYTE b = *(p++);
		int px;
		for (px=0; px<8; px++)
		{
			if (b & (1<<(7-px)))
    		putpixel (screen, x*8+px, y*8+py, 15);
		}
	}
}

void main (int argc, char *argv[])
{
	FILE *fp = fopen ("bbcadump.bin", "rb");
	fread (mem, 1, 64*1024, fp);
  fclose (fp);

  char buf[80];

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS/INV_SCALE, HEIGHT_PIXELS/INV_SCALE, 0, 0);

#if 0
	PALETTE pal;
	for (int c=0; c<64; c++)
	{
		pal[c].r = (int)(c/1.5);
		pal[c].g = (int)(c/1.5);
		pal[c].b = c;
  }
	set_palette_range (pal, 0, 64, 1);
#endif

	#ifdef SHOW_CHARSET

	  clear_bitmap (screen);
	
		int c;
		for (c=0; c<96; c++)
			disp_char (c%32, c/32, c);
	
	  sprintf (buf, "ROM character set");
	  SS_TEXTOUT_CENTRE(screen, font, buf, SCREEN_W/2, SCREEN_H-8, 63);
	
	  while (!key[KEY_ESC]);	  
	  while (key[KEY_ESC]);	  

	#endif

	#ifdef SHOW_MODE6
	
	  clear_bitmap (screen);
	
		unsigned char *v = &mem[0x2000];
	
	  sprintf (buf, "Mode 6 screen dump");
	  SS_TEXTOUT_CENTRE(screen, font, buf, SCREEN_W/2, SCREEN_H-8, 63);
	
		int y;
		for (y=0; y<25*8; y++)
		{
			int x;
			for (x=0; x<40*8; x++)
			{
				int va = (0x140 * (y>>3)) + (y&7) + (x&~7);

				int pel = ((v[va]) & (1<<(7-(x&7))) ? 15 : 0);
				putpixel (screen, x, y, pel);
			}
		}
	
	  while (!key[KEY_ESC]);	  
	  while (key[KEY_ESC]);	  

	#endif

}

END_OF_MAIN();

