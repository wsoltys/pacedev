#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

#define SHOW_PALETTE
#define SHOW_CLUTS
#define SHOW_CHARS
#define SHOW_TILES
#define SHOW_SPRITES

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#define WIDTH_PIXELS	(40*8)
#define HEIGHT_PIXELS	(28*8)
#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

#define CHR0_BASE  0xB400

BYTE mem[64*1024];
BYTE *chr0 = &mem[CHR0_BASE];

void main (int argc, char *argv[])
{
	FILE *fp;

	// read cpu memory dump	
	fp = fopen ("basic10.rom", "rb");
	if (!fp) exit (0);
	fread (&mem[0x0000], 16*1024, 1, fp);
	fclose (fp);

  // read chr data
  // dumped from MESS $B400-$B7FF after BASIC prompt
  // (gets copied from BASIC ROM)
  fp = fopen ("chr10.bin", "rb");
  fread (&mem[CHR0_BASE], 0x400, 1, fp);
  fclose (fp);

  //
  //  CHANGE INTO ALLEGRO MODE
  //
	
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

  // display the chars
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int tile_addr = t*8;
    int y = t / WIDTH_BYTES;
    int x = t % WIDTH_BYTES;
    
		for (int ty=0; ty<8; ty++)
		{
			for (int tx=0; tx<8; tx++)
			{
				BYTE pel = chr0[tile_addr+ty+(tx>>3)];
				pel = pel >> (7-tx);
				putpixel (screen, x*8+tx, y*8+ty, pel & 0x01);
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
}

END_OF_MAIN();

