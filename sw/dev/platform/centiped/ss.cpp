#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

#define CENTIPED

#ifdef CENTIPED
#define MEM_NAME		"CENTDUMP.BIN"
#define ROM1_NAME		"centiped.211"
#define ROM2_NAME		"centiped.212"
#define GFX_ROM_SIZE    0x0800
#define NUM_TILES       256
#define NUM_SPRITES     128
#define PROM_NAME		""
#define VRAM_BASE		0x0400
#define ATTR_BASE		0x0000
#define SPRITE_BASE		0x07C0
#define HW_SPRITES      16
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
#endif

#define SPRITE_SIZE_X	16
#define SPRITE_SIZE_Y	8

#define ROT90

#ifndef ROT90
#define WIDTH_PIXELS	256
#define HEIGHT_PIXELS	240
#else
#define WIDTH_PIXELS	240
#define HEIGHT_PIXELS	256
#endif
#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE mem[64*1024];
BYTE gfx_rom[2*GFX_ROM_SIZE];
BYTE gfx_prom[32];
BYTE snd_rom[2*1024*3];

BYTE chr_rot90[NUM_TILES*16];
BYTE spr_rot90[NUM_SPRITES*64];

char *int2bin (int value, int bits)
{
  static char bin[32];
  int i;

  for (i=0; i<bits; i++)
    bin[i] = ((value & (1<<(bits-1-i))) ? '1' : '0');
  bin[i] = '\0';

  return (bin);
}

void main (int argc, char *argv[])
{
	FILE *fp;

	// read cpu memory dump	
	fp = fopen (MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

    // write vram, attr, sprite & bullet ram
    fp = fopen ("vram.bin", "wb");
    fwrite (&mem[VRAM_BASE], 1024, 1, fp);
    fclose (fp);

	// read graphics roms
	fp = fopen (ROM1_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[0], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
	fp = fopen (ROM2_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[GFX_ROM_SIZE], GFX_ROM_SIZE, 1, fp);
	fclose (fp);


	// convert the char graphics (8x8)
	static int chr_poff[] = { 16384, 0 };
	static int chr_xoff[] = { 0, 8, 16, 24, 32, 40, 48, 56 };
	static int chr_yoff[] = { 7, 6, 5, 4, 3, 2, 1, 0 };
	for (int t=0; t<NUM_TILES; t++)
	{
		for (int y=0; y<8; y++)
		{
			BYTE tdat = 0;
			
			for (int x=0; x<8; x++)
			{
				BYTE pel = 0;
                for (int p=0; p<2; p++)
                {
                    int bit = chr_poff[p]+chr_xoff[x]+chr_yoff[7-y];
                    pel |= ((gfx_rom[t*8+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
                }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) chr_rot90[t*16+y*2+(x>>2)] = tdat;
			}
		}
	}
	fp = fopen ("tile0.bin", "wb");
	if (!fp) exit (0);
	fwrite (chr_rot90, NUM_TILES*16, 1, fp);
	fclose (fp);
		
	FILE *fpSpr[4];
	for (int i=0; i<4; i++)
	{
		char sprFile[64];
		sprintf (sprFile, "sprite0_%d.bin", i);
		fpSpr[i] = fopen (sprFile, "wb");
	}

	// convert the sprite graphics (16x8)
	static int spr_poff[] = { 16384, 0 };
	static int spr_xoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8, 
							  8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 };
	static int spr_yoff[] = { 7, 6, 5, 4, 3, 2, 1, 0 };
	for (int t=0; t<NUM_SPRITES; t++)
	{
		for (int y=0; y<SPRITE_SIZE_Y; y++)
		{
			BYTE tdat = 0;
			
			for (int x=0; x<SPRITE_SIZE_X; x++)
			{
				BYTE pel = 0;
                for (int p=0; p<2; p++)
                {
                    int bit = spr_poff[p]+spr_xoff[x]+spr_yoff[y^(SPRITE_SIZE_Y-1)];
                    pel |= ((gfx_rom[t*16+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
                }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3)
                {
                    fwrite (&tdat, 1, 1, fpSpr[x/4]);
                    spr_rot90[t*32+y*4+(x>>2)] = tdat;
                }
			}
		}
	}
	for (int i=0; i<4; i++)
		fclose (fpSpr[i]);

	fp = fopen ("sprite0.bin", "wb");
	if (!fp) exit (0);
	fwrite (spr_rot90, NUM_SPRITES*32, 1, fp);
	fclose (fp);
	
  	allegro_init ();
  	install_keyboard ();
  
  	set_color_depth (8);
  	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

	gfx_prom[0] = 0;
	gfx_prom[1] = (1<<5);
	gfx_prom[2] = (1<<2);
	gfx_prom[3] = (1<<2)|(1<<5)|(1<<7);
	gfx_prom[4] = (1<<7);
	gfx_prom[5] = (1<<2)|(1<<5)|(1<<7);
	gfx_prom[6] = (1<<2);
	gfx_prom[7] = (1<<5);
	  	
	// set the palette
	PALETTE pal;
  FILE *fppal = fopen ("pal.txt", "wt");
	for (int c=0; c<32; c++)
	{
    pal[c].r = ((gfx_prom[c] & (1<<0) ? 0x21 : 0x00) + 
    			  (gfx_prom[c] & (1<<1) ? 0x47 : 0x00) +
    			  (gfx_prom[c] & (1<<2) ? 0x97 : 0x00)) >> 2;
    pal[c].g = ((gfx_prom[c] & (1<<3) ? 0x21 : 0x00) + 
    			  (gfx_prom[c] & (1<<4) ? 0x47 : 0x00) +
    			  (gfx_prom[c] & (1<<5) ? 0x97 : 0x00)) >> 2;
    pal[c].b = ((gfx_prom[c] & (1<<6) ? 0x4f : 0x00) + 
    			  (gfx_prom[c] & (1<<7) ? 0xa8 : 0x00)) >> 2;

    if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
    {
      char r[32], g[32], b[32];
      //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
      strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
      fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
    }
  }
  fclose (fppal);

	set_palette_range (pal, 0, 34, 1);

	for (int y=0; y<HEIGHT_BYTES; y++)
	{
		for (int x=0; x<WIDTH_BYTES; x++)
		{

#ifndef ROT90			
			int vram_addr = (y*32) + x;
			int c = mem[VRAM_BASE+vram_addr];
			// each rom has 1 bitplane
			int tile_addr = c*8;
#else
			int vram_addr = (x*32) + (HEIGHT_BYTES-1-y);
			int c = (mem[VRAM_BASE+vram_addr] & 0x3f) + 0x40;
			//SET_TILE_INFO(0, (data & 0x3f) + 0x40, 0, TILE_FLIPYX(data >> 6));
			//int c = y*WIDTH_BYTES+x;
			// 16 bytes per tile
			int tile_addr = c*16;
#endif

			int bg_colour = -1;

			// only 1 attribute byte per row!!!
			int flip = mem[VRAM_BASE+vram_addr] >> 6;

			for (int ty=0; ty<8; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
#ifndef ROT90
					int p0 = (gfx_rom[tile_addr+ty] >> (7-tx)) & 0x01; 
					int p1 = (gfx_rom[2*1024+tile_addr+ty] >> (7-tx)) & 0x01;
					int pel = (p1 << 1) | p0;
#else
					BYTE pel = chr_rot90[tile_addr+ty*2+(tx>>2)];
					pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
#endif
					if (bg_colour != -1)
						putpixel (screen, x*8+tx, y*8+ty, bg_colour);
					//putpixel (screen, (x*8+tx-scroll+256)%256, y*8+ty, COLOUR(attr)*4+pel);
					putpixel (screen, x*8+tx, y*8+ty, pel);
				}
			}
		}
	}

	// now show some sprites
	for (int s=0; s<HW_SPRITES; s++)
	{
		// sprites priority encoding
		int n = s;
		int code = ((mem[SPRITE_BASE+n] & 0x3e) >> 1) | ((mem[SPRITE_BASE+n] & 0x01) << 6);
		int clr = mem[SPRITE_BASE+n+0x30];
		int flipy = mem[SPRITE_BASE+n] & 0x80;
		int sy = 256 - 6 - mem[SPRITE_BASE+n+0x20];
		int sx = 240 - 4 - mem[SPRITE_BASE+n+0x10];

		for (int ty=0; ty<SPRITE_SIZE_Y; ty++)
		{
			for (int tx=0; tx<SPRITE_SIZE_X; tx++)
			{
				BYTE pel = spr_rot90[code*32+ty*4+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x06) & 0x03;
				if (pel)
					//putpixel (screen, sx+tx, YPOS(sy)+ty, COLOUR(clr)*4+pel);
					if (!flipy)
						putpixel (screen, sx+tx, YPOS(sy)+ty, pel);
					else
						putpixel (screen, sx+15-tx, YPOS(sy)+ty, pel);
			}
		}
	}

    while (!key[KEY_ESC])
    	;	  
}

END_OF_MAIN();

