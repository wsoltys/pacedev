#include <stdio.h>
#include <stdlib.h>

#include <allegro.h>

// build options
#define BUILD_SHOW_TEXT
//#define BUILD_SHOW_HIRES

#define MEM_NAME		"mbee.bin"

#define VRAM_BASE		0xF000

#define WIDTH_PIXELS	(64*8)
#define HEIGHT_PIXELS	(16*16)

#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE charrom[4*1024];

BYTE mem[64*1024];

BYTE tile_data[256*16*2];

void main (int argc, char *argv[])
{
	FILE *fp;

	// read cpu memory dump	
	fp = fopen (MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

	fp = fopen ("charrom.bin", "rb");
	if (!fp) exit (0);
	fread (charrom, 4*1024, 1, fp);
    fclose (fp);

	fp = fopen ("mbeevram.bin", "wb");
	fwrite (&mem[VRAM_BASE], 1024, 1, fp);
	fclose (fp);
	
	// build the pace character set
	BYTE *t1 = charrom;
	BYTE *t2 = tile_data;
	for (int i=0; i<256; i++)
	{
		for (int y=0; y<16; y++)
		{
			BYTE pel = 0;
			for (int x=0; x<8; x++)
			{
				// 2 bits/pixel (use same value)
				pel = (pel << 1) | ((*t1 >> (7-x)) & 0x01);
				pel = (pel << 1) | ((*t1 >> (7-x)) & 0x01);
				if (x%4 == 3) *(t2++) = pel;
			}
			t1++;
		}
	}
	
    // write the tile data
    fp = fopen ("tile0.bin", "wb");
    fwrite (tile_data, 256*16*2, 1, fp);
    fclose (fp);

  	allegro_init ();
  	if (install_keyboard () != 0)
  	{
  		printf ("install_keyboard() failed!\n");
  		exit (0);
  	}
  
  	set_color_depth (8);
  	if (set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0) != 0)
  	{
  		printf ("set_gfx_mode() failed!\n");
  		exit (0);
  	}

  	// set the palette
  	PALETTE pal;
  	for (int c=0; c<4; c++)
	{
      pal[c].r = 0;
      pal[c].g = (c ? (1<<6) - 1 : 0);
      pal[c].b = 0;
    }
  	set_palette_range (pal, 0, 4, 1);

#ifdef BUILD_SHOW_TEXT
	for (int y=0; y<HEIGHT_BYTES; y++)
	{
		for (int x=0; x<WIDTH_BYTES; x++)
		{
			int vram_addr = y*64+x;
			int c = mem[VRAM_BASE+vram_addr];
			// 32 bytes per tile
			int tile_addr = c*16*2;

			for (int ty=0; ty<16; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
					BYTE pel = tile_data[tile_addr+ty*2+(tx>>2)];
					pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
					
					putpixel (screen, x*8+tx, y*16+ty, pel);
				}
			}
		}
	}
	
    while (!key[KEY_ESC])
    	;	  
#endif
}

END_OF_MAIN();

