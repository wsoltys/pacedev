#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

#define MEM_NAME		"cocomem.bin"
#define VRAM_BASE		0x0400
#define TRS_CHAR_HEIGHT 12

#define WIDTH_PIXELS	(32*8)
#define HEIGHT_PIXELS	(16*(TRS_CHAR_HEIGHT))

#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS/12)

typedef unsigned char BYTE;

BYTE mem[64*1024];
BYTE coco_font_data[256][TRS_CHAR_HEIGHT];

BYTE tiledata[256][16];

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

  // read font data
  fp = fopen ("coco_font.bin", "rb");
  if (!fp) exit (0);
  fread (coco_font_data, 256*TRS_CHAR_HEIGHT, 1, fp);
  fclose (fp);

  // for now, let's re-arrange the font data
  for (int i=0; i<256; i++)
  {
    int index;
    int mask;

    if (i < 0x40)
      index = i;
    else
    if (i < 0x60)
      index = i - 0x40;
    else
    if (i < 0x80)
      index = i - 0x40; // - 0x20;
    else
      index = 0xA0 + (i&0x0F);

    mask = (i < 0x40 ? 0xff : 0);

    memcpy (tiledata[i], &coco_font_data[index], TRS_CHAR_HEIGHT);
    memset (&tiledata[i][TRS_CHAR_HEIGHT], 0, 16-TRS_CHAR_HEIGHT);

    for (int j=0; j<16; j++)
      tiledata[i][j] ^= mask;
  }

  fp = fopen ("tiledata.bin", "wb");
  if (!fp) exit (0);
  fwrite (tiledata, 256*16, 1, fp);
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
	for (int c=0; c<2; c++)
	{
    pal[c].r = 0;
    pal[c].g = (c ? (1<<6) - 1 : 0);
    pal[c].b = 0;
  }
	set_palette_range (pal, 0, 2, 1);

  // show the entire character set
  for (int i=0; i<256; i++)
    mem[VRAM_BASE+i+256] = i;

  // write the vram contents
  fp = fopen ("vram.bin", "wb");
  if (!fp) exit (0);
  fwrite (&mem[VRAM_BASE], WIDTH_BYTES*HEIGHT_BYTES, 1, fp);
  fclose (fp);
  	
	for (int y=0; y<HEIGHT_BYTES; y++)
	{
		for (int x=0; x<WIDTH_BYTES; x++)
		{
			int vram_addr = VRAM_BASE + (y*WIDTH_BYTES) + x;
			int c = mem[vram_addr];

			// get a pointer to the character data
			//BYTE *pTile_data = coco_font_data[c&0x7f];
			BYTE *pTile_data = tiledata[c];

			for (int ty=0; ty<TRS_CHAR_HEIGHT; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
					int pel = (pTile_data[ty] >> (7-tx)) & 0x01;
					putpixel (screen, x*8+tx, y*TRS_CHAR_HEIGHT+ty, pel);
				}
			}
		}
	}
	
    while (!key[KEY_ESC])
    	;	  
}

END_OF_MAIN();

