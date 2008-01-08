#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MODEL_1

#include "trs_chars.c"

#include <allegro.h>

#define MEM_NAME		"mem.dump"
#define VRAM_BASE		0x3C00

#ifdef MODEL_1
  #define CHARSET			2
#else
  #define CHARSET			5
#endif

#define WIDTH_PIXELS	512
#define HEIGHT_PIXELS	192

#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS/12)

typedef unsigned char BYTE;

BYTE mem[64*1024];
BYTE trs_gfx_data[64][TRS_CHAR_HEIGHT];

BYTE pace_tile_data[256][16];

void main (int argc, char *argv[])
{
	FILE *fp;

	// read cpu memory dump	
	fp = fopen (MEM_NAME, "rb");
	if (fp)
  {
  	fread (mem, 64*1024, 1, fp);
  	fclose (fp);
  }
  else
  {
    memset (&mem[0x3C00], 0x20, 1024);
    for (int i=0; i<256; i++)
      mem[0x3c00+i] = i;
  }

  // write the vram contents
  fp = fopen ("trsvram.bin", "wb");
  fwrite (&mem[0x3C00], 1024, 1, fp);
  fclose (fp);

	// build the gfx_chars data
	for (int c=0; c<64; c++)
	{
		for (int y=0; y<TRS_CHAR_HEIGHT; y++)
		{
			BYTE d = 0;
			
			if (c & (1<<((y>>2)<<1))) d |= 0x0F;
			if (c & (1<<(((y>>2)<<1)+1))) d |= 0xF0;
			
			trs_gfx_data[c][y] = d;
		}
	}

  // write tile data
  for (int i=0; i<256; i++)
  {
    for (int j=0; j<16; j++)
    {
      if (j < 12)
      {
        // model 1 ONLY
        #ifdef MODEL_1
        if (i<32)
          pace_tile_data[i][j] = trs_char_data[CHARSET][i+64][j];
        else
        #endif
  			if (i < 128)
  				pace_tile_data[i][j] = trs_char_data[CHARSET][i][j];
  			else if (i < 128+64)
  				pace_tile_data[i][j] = trs_gfx_data[i-128][j];
        else
        #ifdef MODEL_1
  				pace_tile_data[i][j] = trs_gfx_data[i-128-64][j];
        #else
  				pace_tile_data[i][j] = trs_char_data[CHARSET][i-64][j];
        #endif
      }
      else
        pace_tile_data[i][j] = 0;
    }
  }
  fp = fopen ("trstile.bin", "wb");
  fwrite (pace_tile_data, 1, 256*16, fp);
  fclose (fp);

#if 0
	for (int c=0; c<128; c++)
	{
		for (int y=0; y<TRS_CHAR_HEIGHT; y++)
			printf ("%02X ", trs_gfx_data[c][y]);
		printf ("\n");
	}
#endif
		
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
  	for (int c=0; c<2; c++)
	{
      pal[c].r = 0;
      pal[c].g = (c ? (1<<6) - 1 : 0);
      pal[c].b = 0;
    }
  	set_palette_range (pal, 0, 2, 1);
  	
	for (int y=0; y<HEIGHT_BYTES; y++)
	{
		for (int x=0; x<WIDTH_BYTES; x++)
		{
			int vram_addr = VRAM_BASE + (y*WIDTH_BYTES) + x;
			int c = mem[vram_addr];

			// get a pointer to the character data
			char *pTile_data;
			if (c < 128)
				pTile_data = trs_char_data[CHARSET][c];
			else if (c < 128+64)
				pTile_data = (char *)(trs_gfx_data[c-128]);
            else
				pTile_data = trs_char_data[CHARSET][c-64];

			for (int ty=0; ty<TRS_CHAR_HEIGHT; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
#if 0
					int pel = (pTile_data[ty] >> tx) & 0x01;
#else
                    int pel = (pace_tile_data[c][ty] >> tx) & 0x01;
#endif
					putpixel (screen, x*8+tx, y*TRS_CHAR_HEIGHT+ty, pel);
				}
			}
		}
	}
	
    while (!key[KEY_ESC])
    	;	  
}

END_OF_MAIN();

