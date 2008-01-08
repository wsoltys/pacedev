#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

//#define SHOW_PALETTE
//#define SHOW_TILES
//#define SHOW_SPRITES
#define SHOW_SCREEN

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#define SCRAMBLE

#ifdef SCRAMBLE
#define SET_NAME              "SCRAMBLE"
#define MEM_NAME		          "SCRDUMP.BIN"
#define TILE_ROM_1_NAME       "c2.5f"
#define TILE_ROM_2_NAME       "c1.5h"
#define TILE_ROM_SIZE         0x1000
#define NUM_TILES             256
#define NUM_SPRITES           64
#define PALETTE_PROM_NAME     "c01s.6e"
#define PALETTE_PROM_SIZE     0x20
#endif

// common defines
#define VRAM_BASE		          0x4800
#define CRAM_BASE             0x5000
#define SPRITE_BASE		        0x5040

#define TILE_COLOUR(i)        (i)
#define SPRITE_COLOUR(i)      (i)

// don't know if these are right???
#define HW_SPRITES            8
#define YPOS(i)               (i)


#define SUBDIR                SET_NAME "/"

#define ROT90

#ifndef ROT90
#define WIDTH_PIXELS	256
#define HEIGHT_PIXELS	224
#else
#define WIDTH_PIXELS	256 //224
#define HEIGHT_PIXELS	256
#endif
#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE mem[64*1024];

BYTE tile_rom[TILE_ROM_SIZE];
BYTE *sprite_rom = tile_rom;
BYTE palette_prom[PALETTE_PROM_SIZE];

BYTE tile_rot90[NUM_TILES*16];
BYTE sprite_rot90[NUM_SPRITES*64];

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
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x400, 1, fp);
  fclose (fp);

  // read tile rom(s)
	fp = fopen (SUBDIR TILE_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom, 0x0800, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_ROM_2_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom+0x0800, 0x0800, 1, fp);
	fclose (fp);

  // read palette proms
	fp = fopen (SUBDIR PALETTE_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (palette_prom, PALETTE_PROM_SIZE, 1, fp);
	fclose (fp);

#if 1

	// convert the char graphics (8x8)
  // - straight from MAME
  static int tile_poff[] = { 0, 0x0800*8 };
	static int tile_xoff[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
	static int tile_yoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 };
  static int tile_aoff = 8;

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
          int bit = tile_poff[p]+tile_yoff[7-x]+tile_xoff[7-y];
          pel |= ((tile_rom[t*tile_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
        }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) tile_rot90[t*16+y*2+(x>>2)] = tdat;
			}
		}
	}
	fp = fopen (SUBDIR "tilerot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (tile_rot90, NUM_TILES*16, 1, fp);
	fclose (fp);

#endif

#if 1

	// convert the sprite graphics (16x16)
  // - straight from MAME
  static int sprite_poff[] = { 0, 0x0800*8 };
	static int sprite_xoff[] = { 0, 1, 2, 3, 4, 5, 6, 7,
			                          8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7 };
	static int sprite_yoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			                          16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8 };
  static int sprite_aoff = 32;

	for (int t=0; t<NUM_SPRITES; t++)
	{
		for (int y=0; y<16; y++)
		{
			BYTE tdat = 0;
			for (int x=0; x<16; x++)
			{
				BYTE pel = 0;
        for (int p=0; p<2; p++)
        {
          int bit = sprite_poff[p]+sprite_yoff[15-x]+sprite_xoff[15-(y^8)];
          pel |= ((sprite_rom[(t)*sprite_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
        }

				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) sprite_rot90[t*64+y*4+(x>>2)] = tdat;
			}
		}
	}

	fp = fopen (SUBDIR "spriterot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (sprite_rot90, NUM_SPRITES*64, 1, fp);
	fclose (fp);
#endif

	
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

	// set the palette
  FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
	PALETTE pal;
	for (int c=0; c<32; c++)
	{
    pal[c].r = ((palette_prom[c] & (1<<0) ? 0x21 : 0x00) + 
    			  (palette_prom[c] & (1<<1) ? 0x47 : 0x00) +
    			  (palette_prom[c] & (1<<2) ? 0x97 : 0x00)) >> 2;
    pal[c].g = ((palette_prom[c] & (1<<3) ? 0x21 : 0x00) + 
    			  (palette_prom[c] & (1<<4) ? 0x47 : 0x00) +
    			  (palette_prom[c] & (1<<5) ? 0x97 : 0x00)) >> 2;
    pal[c].b = ((palette_prom[c] & (1<<6) ? 0x4f : 0x00) + 
    			  (palette_prom[c] & (1<<7) ? 0xa8 : 0x00)) >> 2;

	//palette_set_color(BULLETS_COLOR_BASE+0,0xef,0xef,0x00);
	//palette_set_color(BULLETS_COLOR_BASE+1,0xef,0xef,0xef);

    if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
    {
      char r[32], g[32], b[32];
      //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
      strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
      fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
    }
  }
  fclose (fppal);
	set_palette_range (pal, 0, 32, 1);

#ifdef SHOW_PALETTE
  // display palette
  clear_bitmap (screen);
  for (int t=0; t<32; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, t);
  }
  textout_centre_ex(screen, font, "PALETTE", SCREEN_W/2, SCREEN_H-8, 1, 0);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_TILES
  // display the tiles
  clear_bitmap (screen);
  for (int t=0; t<NUM_TILES; t++)
  {
    int tile_addr = t*16;
    int y = (t % 256) / 28;
    int x = t % 28;
    
		for (int ty=0; ty<8; ty++)
		{
			for (int tx=0; tx<8; tx++)
			{
				BYTE pel = tile_rot90[tile_addr+ty*2+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
				putpixel (screen, x*8+tx, y*8+ty, TILE_COLOUR(pel));
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_SPRITES
  // display the sprites
  clear_bitmap (screen);
  for (int t=0; t<NUM_SPRITES; t++)
  {
    int sprite_addr = t*64;
    int y = (t % 256) / 14;
    int x = t % 14;
    
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				BYTE pel = sprite_rot90[sprite_addr+ty*4+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
				putpixel (screen, x*16+tx, y*16+ty, SPRITE_COLOUR(pel));
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_SCREEN
  clear_bitmap (screen);
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
			int vram_addr = ((31-x)*32) + y;
			int c = mem[VRAM_BASE+vram_addr];
			// 16 bytes per tile
			int tile_addr = c*16;
#endif

			int bg_colour = -1;

			// only 1 attribute byte per row!!!
			int scroll = mem[CRAM_BASE+((vram_addr&0x1f)<<1)+0];
			int attr = mem[CRAM_BASE+((vram_addr&0x1f)<<1)+1] & 0x07;

			for (int ty=0; ty<8; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
#ifndef ROT90
					int p0 = (gfx_rom[tile_addr+ty] >> (7-tx)) & 0x01; 
					int p1 = (gfx_rom[2*1024+tile_addr+ty] >> (7-tx)) & 0x01;
					int pel = (p1 << 1) | p0;
#else
					BYTE pel = tile_rot90[tile_addr+ty*2+(tx>>2)];
					pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
#endif
					if (bg_colour != -1)
						putpixel (screen, x*8+tx, y*8+ty, bg_colour);
					//putpixel (screen, (x*8+tx-scroll+256)%256, y*8+ty, TILE_COLOUR(attr*4+pel));
					putpixel (screen, (x*8+tx+scroll)%256, y*8+ty, TILE_COLOUR(attr*4+pel));
				}
			}
		}
	}

#if 1
	// now show some sprites
	for (int s=0; s<HW_SPRITES; s++)
	{
		// sprites priority encoding
		int n = (HW_SPRITES-1-s);
    // swap x,y
		int sy = mem[SPRITE_BASE+(n*4)+3] + 1;
		int sx = mem[SPRITE_BASE+(n*4)+0];
		int code = mem[SPRITE_BASE+(n*4)+1] & 0x3f;
		int clr = mem[SPRITE_BASE+(n*4)+2] & 0x07;
		
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				int sprite_addr = (0 + code) * 64;
				BYTE pel = sprite_rot90[sprite_addr+ty*4+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x06) & 0x03;
				if (pel)
					putpixel (screen, sx+tx, YPOS(sy)+ty, SPRITE_COLOUR(clr*4+pel));
			}
		}
	}
#endif

  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif
}

END_OF_MAIN();
