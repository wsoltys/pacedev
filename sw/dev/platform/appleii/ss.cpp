#include <stdio.h>
#include <stdlib.h>

#include <allegro.h>

// build options
//#define BUILD_SHOW_TEXT
#define BUILD_SHOW_HIRES

#define MEM_NAME		"vram.bin"
#define HIRES_NAME		"hires.bin"

#define VRAM_BASE		0x0400
#define HIRES_BASE		0x2000

#define WIDTH_PIXELS	(40*8)
#define HEIGHT_PIXELS	(24*8)

#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE a2_chr[2*1024];

BYTE mem[64*1024];

BYTE tile_data[256*2*8];

void main (int argc, char *argv[])
{
	FILE *fp;

	// read cpu memory dump	
	fp = fopen (MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (&mem[VRAM_BASE], 1*1024, 1, fp);
	fclose (fp);

	fp = fopen (HIRES_NAME, "rb");
	if (!fp) exit (0);
	fread (&mem[HIRES_BASE], 16*1024, 1, fp);
	fclose (fp);

	fp = fopen ("a2.chr", "rb");
	if (!fp) exit (0);
	fread (a2_chr, 2*1024, 1, fp);
    fclose (fp);

	// build the pace character set
	BYTE *t1 = a2_chr;
	BYTE *t2 = tile_data;
	for (int i=0; i<256; i++)
	{
		for (int y=0; y<8; y++)
		{
			BYTE pel = 0;
			for (int x=0; x<8; x++)
			{
				// 2 bits/pixel (use same value)
				// apple char set is actually 7 bits wide
				// - since we're displaying 8, strip off 1st pixel
				if (x==0)
					pel <<= 2;
				else
				{
					pel = (pel << 1) | ((*t1 >> (7-x)) & 0x01);
					pel = (pel << 1) | ((*t1 >> (7-x)) & 0x01);
				}
				if (x%4 == 3) *(t2++) = pel;
			}
			t1++;
		}
	}
	
    // write the tile data
    fp = fopen ("tile0.bin", "wb");
    //fwrite (tile_data, 256*2*8, 1, fp);     // 2-bpp
    fwrite (a2_chr, 256*8, 1, fp);            // 1-bpp
    fclose (fp);

	// write the 1st page of hires data
    fp = fopen ("hgr0.bin", "wb");
    fwrite (&mem[HIRES_BASE], 8*1024, 1, fp);
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
			int b4 = (y>>4)&1;
			int b3 = (y>>3)&1;
			int y8 = (y&7);
			int vram_addr = ((y8<<7)|(b4<<6)|(b3<<5)|(b4<<4)|(b3<<3))+x;
			//int c = (y*WIDTH_BYTES+x)&0xff;
			int c = mem[VRAM_BASE+vram_addr];
			// 16 bytes per tile
			//int tile_addr = c*2*8;
			int tile_addr = c*8;

			for (int ty=0; ty<8; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
					//BYTE pel = tile_data[tile_addr+ty*2+(tx>>2)];
					BYTE pel = a2_chr[tile_addr+ty];
					//pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
					pel = (pel >> (7-tx)) & 0x01;
					
          if (tx != 0)
					  putpixel (screen, x*8+tx, y*8+ty, pel);
				}
			}
		}
	}
	
    while (!key[KEY_ESC])
    	;	  
#endif

#ifdef BUILD_SHOW_HIRES
	for (int y=0; y<192; y++)
	{
		for (int x=0; x<40; x++)
		{
			//int a = ((y&7)<<10)|((y&0x38)<<4)|(((y>>3)&0x18)*5+x);
			int a = ((y&7)<<10)|((y&0x38)<<4);
			
			for (int p=0; p<7; p++)
			{
				a |= (((y>>1)&0x60)|((y>>3)&0x18))+x;
				//a |= ((y>>3)&0x18)+x;
				int data = mem[HIRES_BASE+a];
				int pel = (data & (1<<p) ? 1 : 0);				

				putpixel (screen, x*7+p, y, pel);
			}
		}
	}
	
    while (!key[KEY_ESC])
    	;	  
#endif
}

END_OF_MAIN();

