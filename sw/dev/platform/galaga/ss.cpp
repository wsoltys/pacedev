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

//#define GALAGA
#define XEVIOUS

#ifdef GALAGA
#define SET_NAME                  "GALAGA"
#define MEM_NAME		              "GALDUMP0.BIN"
#define CHAR_ROM_1_NAME           "gg1-9.4l"
#define CHAR_ROM_SIZE             0x1000
#define NUM_CHARS                 256
#define SPRITE_ROM_1_NAME         "gg1-11.4d"
#define SPRITE_ROM_2_NAME         "gg1-10.4f"
#define SPRITE_ROM_SIZE           0x2000
#define NUM_SPRITES               128
#define RGB_PROM_NAME             "prom-5.5n"
#define CHAR_CLUT_PROM_NAME       "prom-4.2n"
#define SPRITE_CLUT_PROM_1_NAME   "prom-3.1c"
#define NUM_COLOURS               32
#endif

#ifdef XEVIOUS
#define SET_NAME                  "XEVIOUS"
#define MEM_NAME		              "XEV0DUMP.BIN"
#define CHAR_ROM_1_NAME           "xvi_12.3b"
#define CHAR_ROM_SIZE             0x1000
#define NUM_CHARS                 512
#define TILE_ROM_1_NAME           "xvi_13.3c"
#define TILE_ROM_2_NAME           "xvi_14.3d"
#define TILE_ROM_SIZE             0x2000
#define NUM_TILES                 512
#define SPRITE_ROM_1_NAME         "xvi_15.4m"
#define SPRITE_ROM_2_NAME         "xvi_17.4p"
#define SPRITE_ROM_3_NAME         "xvi_16.4n"
#define SPRITE_ROM_4_NAME         "xvi_18.4r"
#define SPRITE_ROM_SIZE           0x0A000
#define NUM_SPRITES               0x140
#define R_PROM_NAME               "xvi_8bpr.6a"
#define G_PROM_NAME               "xvi_9bpr.6d"
#define B_PROM_NAME               "xvi10bpr.6e"
#define TILE_CLUT_PROM_1_NAME     "xvi_7bpr.4h"   // low bits
#define TILE_CLUT_PROM_2_NAME     "xvi_6bpr.4f"   // high bits
#define SPRITE_CLUT_PROM_1_NAME   "xvi_4bpr.3l"   // low bits
#define SPRITE_CLUT_PROM_2_NAME   "xvi_5bpr.3m"   // high bits
#define NUM_COLOURS               256
#endif

// common defines
#define SPRITE_BASE		        0xCC00
#define VRAM_BASE		          0xD000
#define CRAM_BASE             0xD400
#define BGRAM_BASE            0xD800

#ifdef GALAGA
  #define CHAR_COLOUR(i)        (0x10+char_clut_prom[i]&0x0f)
#else
  #define CHAR_COLOUR(i)        (i)
#endif
#define TILE_COLOUR(i)        ((tile_clut_prom[i]&0x0f)|(tile_clut_prom[512+i]<<4))
// SPRITE_COLOUR is a function declared elsewhere

// don't know if these are right???
#define HW_SPRITES            8
#define YPOS(i)               (i)


#define SUBDIR                SET_NAME "/"

#define ROT90

#ifndef ROT90
#define WIDTH_PIXELS	(36*8)
#define HEIGHT_PIXELS	(28*8)
#else
#define WIDTH_PIXELS	(28*8)
#define HEIGHT_PIXELS	(36*8)
#endif
#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE mem[64*1024];

BYTE char_rom[CHAR_ROM_SIZE];
#ifndef GALAGA
  BYTE tile_rom[TILE_ROM_SIZE];
#endif
BYTE sprite_rom[0xA000+SPRITE_ROM_SIZE];
BYTE rgb_prom[256*3];
BYTE char_clut_prom[0x100];   // galaga
BYTE tile_clut_prom[2*0x200];
BYTE sprite_clut_prom[2*0x200];

int SPRITE_COLOUR(int i)
{
  int c = (sprite_clut_prom[i]&0x0f)|(sprite_clut_prom[512+i]<<4);
  return (c & 0x80 ? (c&0x7f) : 0x80);
}

BYTE chr_rot90[NUM_CHARS*8];
#ifndef GALAGA
  BYTE tile_rot90[NUM_TILES*16];
#endif
BYTE sprite_rot90[NUM_SPRITES*128];

char *int2bin (int value, int bits)
{
  static char bin[32];
  int i;

  for (i=0; i<bits; i++)
    bin[i] = ((value & (1<<(bits-1-i))) ? '1' : '0');
  bin[i] = '\0';

  return (bin);
}

int permutate (int p, int pel)
{
  switch (p)
  {
    case 0 :  pel = (((pel&4>>0)) | ((pel&2)>>0) | ((pel&1)>>0)) & 0x07; break;
    case 1 :  pel = (((pel&4>>0)) | ((pel&2)>>1) | ((pel&1)<<1)) & 0x07; break;
    case 2 :  pel = (((pel&4>>2)) | ((pel&2)>>0) | ((pel&1)<<2)) & 0x07; break;
    case 3 :  pel = (((pel&4>>1)) | ((pel&2)<<1) | ((pel&1)>>0)) & 0x07; break;
    case 4 :  pel = (((pel&4>>1)) | ((pel&2)>>1) | ((pel&1)<<2)) & 0x07; break;
    case 5 :  pel = (((pel&4>>2)) | ((pel&2)<<1) | ((pel&1)<<1)) & 0x07; break;
  }
  return (pel);
}

void main (int argc, char *argv[])
{
	FILE *fp;

	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram, bgram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x400, 1, fp);
  fclose (fp);
  #ifndef GALAGA
    fp = fopen (SUBDIR "bgram.bin", "wb");
    fwrite (&mem[BGRAM_BASE], 0x400, 1, fp);
    fclose (fp);
  #endif

	// read char rom(s)
	fp = fopen (SUBDIR CHAR_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (char_rom, CHAR_ROM_SIZE, 1, fp);
	fclose (fp);

  #ifndef GALAGA
    // read tile rom(s)
  	fp = fopen (SUBDIR TILE_ROM_1_NAME, "rb");
  	if (!fp) exit (0);
  	fread (tile_rom, 0x1000, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR TILE_ROM_2_NAME, "rb");
  	if (!fp) exit (0);
  	fread (tile_rom+0x1000, 0x1000, 1, fp);
  	fclose (fp);
  #endif

  #ifdef GALAGA
    // read sprite rom(s)
  	fp = fopen (SUBDIR SPRITE_ROM_1_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_rom, 0x1000, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR SPRITE_ROM_2_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_rom+0x1000, 0x1000, 1, fp);
  	fclose (fp);
  #else
    // read sprite rom(s)
  	fp = fopen (SUBDIR SPRITE_ROM_1_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_rom, 0x2000, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR SPRITE_ROM_2_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_rom+0x2000, 0x2000, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR SPRITE_ROM_3_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_rom+0x4000, 0x1000, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR SPRITE_ROM_4_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_rom+0x5000, 0x2000, 1, fp);
    // because 3rd plane stored after 0,1
    // need to unpack into equivalent of 2 planes
    for(int i=0; i<0x2000; i++)
      sprite_rom[0x7000+i] = (sprite_rom[0x5000+i] >> 4);
    // sprites $100-$1F are only 2 planes, not 3
    memset (sprite_rom+0x9000, 0, 0x1000);
  	fclose (fp);
  #endif

  #ifdef GALAGA
    // read palette proms
  	fp = fopen (SUBDIR RGB_PROM_NAME, "rb");
  	if (!fp) exit (0);
  	fread (rgb_prom, 32, 1, fp);
  	fclose (fp);
  #else
    // read palette proms
  	fp = fopen (SUBDIR R_PROM_NAME, "rb");
  	if (!fp) exit (0);
  	fread (rgb_prom, 256, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR G_PROM_NAME, "rb");
  	if (!fp) exit (0);
  	fread (rgb_prom+256, 256, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR B_PROM_NAME, "rb");
  	if (!fp) exit (0);
  	fread (rgb_prom+512, 256, 1, fp);
  	fclose (fp);
  #endif

  // read clut proms
  #ifdef GALAGA
  	fp = fopen (SUBDIR CHAR_CLUT_PROM_NAME, "rb");
  	if (!fp) exit (0);
  	fread (char_clut_prom, 0x100, 1, fp);
  	fclose (fp);
  #else
  	fp = fopen (SUBDIR TILE_CLUT_PROM_1_NAME, "rb");
  	if (!fp) exit (0);
  	fread (tile_clut_prom, 0x200, 1, fp);
  	fclose (fp);
  	fp = fopen (SUBDIR TILE_CLUT_PROM_2_NAME, "rb");
  	if (!fp) exit (0);
  	fread (tile_clut_prom+0x200, 0x200, 1, fp);
  	fclose (fp);
  #endif
	fp = fopen (SUBDIR SPRITE_CLUT_PROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_clut_prom, 0x200, 1, fp);
	fclose (fp);
  #ifndef GALAGA
  	fp = fopen (SUBDIR SPRITE_CLUT_PROM_2_NAME, "rb");
  	if (!fp) exit (0);
  	fread (sprite_clut_prom+0x200, 0x200, 1, fp);
  	fclose (fp);
  #endif

	// convert the char graphics (8x8)
  // - straight from MAME
#ifdef GALAGA
  static int chr_poff[] = { 0, 4 };
	static int chr_xoff[] = { 8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3 };
	static int chr_yoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 }; 
  static int chr_aoff = 16;

	for (int t=0; t<NUM_CHARS; t++)
	{
		for (int y=0; y<8; y++)
		{
			BYTE tdat = 0;
			for (int x=0; x<8; x++)
			{
				BYTE pel = 0;
        for (int p=0; p<2; p++)
        {
          int bit;

          //bit = chr_poff[p]+chr_yoff[y]+chr_xoff[x];
          if (t<128)
            bit = chr_poff[p]+chr_yoff[x^4]+chr_xoff[y^3];
          else
            bit = chr_poff[p]+chr_yoff[x^4]+chr_xoff[y^7];
          pel |= ((char_rom[t*chr_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
        }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) chr_rot90[t*16+y*2+(x>>2)] = tdat;
			}
		}
	}
#else
  static int chr_poff[] = { 0 };
	static int chr_xoff[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
	static int chr_yoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 }; 
  static int chr_aoff = 8;

	for (int t=0; t<NUM_CHARS; t++)
	{
		for (int y=0; y<8; y++)
		{
			BYTE tdat = 0;
			for (int x=0; x<8; x++)
			{
				BYTE pel = 0;
        for (int p=0; p<1; p++)
        {
          // note we've switched x,y to rotate and used y^7 to flip
          int bit = chr_poff[p]+chr_yoff[x]+chr_xoff[y^7];
          pel |= ((char_rom[t*chr_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (0-p);
        }
			
				tdat = (tdat << 1) | pel;
				if ((x % 8) == 7) chr_rot90[t*8+y] = tdat;
			}
		}
	}
#endif

	fp = fopen (SUBDIR "chrrot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (chr_rot90, NUM_CHARS*8, 1, fp);
	fclose (fp);

#ifndef GALAGA
	// convert the tile graphics (8x8)
  // - straight from MAME
  static int tile_poff[] = { 0, 0x1000*8 };
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
          //int bit = tile_poff[p]+tile_yoff[y]+tile_xoff[x];
          int bit = tile_poff[p]+tile_yoff[x^7]+tile_xoff[y^7];
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

#if 0
	// convert the sprite graphics (16x16)
  // - straight from MAME
  static int sprite_poff[] = { 0x5000*8, 0, 4 };
	static int sprite_xoff[] = {  0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			                          16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3 };
	static int sprite_yoff[] = {  0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			                          32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8 };
  static int sprite_aoff = 64;

	for (int t=0; t<NUM_SPRITES; t++)
	{
		for (int y=0; y<16; y++)
		{
			BYTE tdat = 0;
			for (int x=0; x<16; x++)
			{
				BYTE pel = 0;
        for (int p=0; p<3; p++)
        {
          //int bit = sprite_poff[p]+sprite_yoff[y]+sprite_xoff[x^2];
          int bit = sprite_poff[p]+sprite_yoff[x^(8|4|2)]+sprite_xoff[y^(2|1)];
          pel |= ((sprite_rom[(t)*sprite_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (2-p);
        }

        // convert to 4bpp, not 3
				tdat = (tdat << 4) | pel;
				if ((x % 2) == 1) sprite_rot90[t*128+y*8+(x>>1)] = tdat;
			}
		}
	}

	fp = fopen (SUBDIR "spriterot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (sprite_rot90, NUM_SPRITES*128, 1, fp);
	fclose (fp);
#endif

  //
  //  CHANGE INTO ALLEGRO MODE
  //
	
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

	// set the palette
  FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
	PALETTE pal;
	for (int c=0; c<NUM_COLOURS ;c++)
	{
		int bit0,bit1,bit2,bit3;

#ifdef GALAGA
		bit0 = ((rgb_prom[c]) >> 0) & 0x01;
		bit1 = ((rgb_prom[c]) >> 1) & 0x01;
		bit2 = ((rgb_prom[c]) >> 2) & 0x01;
		pal[c].r = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;
		bit0 = ((rgb_prom[c]) >> 3) & 0x01;
		bit1 = ((rgb_prom[c]) >> 4) & 0x01;
		bit2 = ((rgb_prom[c]) >> 5) & 0x01;
		pal[c].g = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;
		bit0 = 0;
		bit1 = ((rgb_prom[c]) >> 6) & 0x01;
		bit2 = ((rgb_prom[c]) >> 7) & 0x01;
		pal[c].b = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;
#else
		/* red component */
		bit0 = (rgb_prom[c] >> 0) & 0x01;
		bit1 = (rgb_prom[c] >> 1) & 0x01;
		bit2 = (rgb_prom[c] >> 2) & 0x01;
		bit3 = (rgb_prom[c] >> 3) & 0x01;
		pal[c].r = (0x0e * bit0 + 0x1f * bit1 + 0x43 * bit2 + 0x8f * bit3) >> 2;
		/* green component */
		bit0 = (rgb_prom[256+c] >> 0) & 0x01;
		bit1 = (rgb_prom[256+c] >> 1) & 0x01;
		bit2 = (rgb_prom[256+c] >> 2) & 0x01;
		bit3 = (rgb_prom[256+c] >> 3) & 0x01;
		pal[c].g = (0x0e * bit0 + 0x1f * bit1 + 0x43 * bit2 + 0x8f * bit3) >> 2;
		/* blue component */
		bit0 = (rgb_prom[512+c] >> 0) & 0x01;
		bit1 = (rgb_prom[512+c] >> 1) & 0x01;
		bit2 = (rgb_prom[512+c] >> 2) & 0x01;
		bit3 = (rgb_prom[512+c] >> 3) & 0x01;
		pal[c].b = (0x0e * bit0 + 0x1f * bit1 + 0x43 * bit2 + 0x8f * bit3) >> 2;
#endif

    if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
    {
      char r[32], g[32], b[32];
      //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
      strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
      fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
    }
	}
  fclose (fppal);
	set_palette_range (pal, 0, NUM_COLOURS, 1);

#ifdef SHOW_PALETTE
  // display palette
  clear_bitmap (screen);
  for (int t=0; t<NUM_COLOURS; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, t);
  }
  SS_TEXTOUT_CENTRE (screen, font, "PALETTE", SCREEN_W/2, SCREEN_H-8, 3);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_CLUTS

#ifdef SHOW_TILES
#ifndef GALAGA
  // display tile clut
  // tile use colours 0-63 in 4 banks
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, TILE_COLOUR(t));
  }
  SS_TEXTOUT_CENTRE(screen, font, "TILE CLUT", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif
#endif

#ifdef SHOW_SPRITES
  // display sprite clut
  // tile use colours 64-79
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, SPRITE_COLOUR(t));
  }
  SS_TEXTOUT_CENTRE(screen, font, "SPRITE CLUT", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#endif

#ifdef SHOW_CHARS
  // display the chars
  clear_bitmap (screen);
#ifdef GALAGA
  for (int t=0; t<NUM_CHARS; t++)
  {
    int tile_addr = t*16;
    int y = t / WIDTH_BYTES;
    int x = t % WIDTH_BYTES;
    
		for (int ty=0; ty<8; ty++)
		{
			for (int tx=0; tx<8; tx++)
			{
				BYTE pel = chr_rot90[tile_addr+ty*2+(tx>>2)];
				pel = pel >> ((tx<<1)&0x6) & 0x03;
				putpixel (screen, x*8+tx, y*8+ty, CHAR_COLOUR(pel));
			}
		}
  }
#else
  for (int t=0; t<NUM_CHARS; t++)
  {
    int tile_addr = t*8;
    int y = t / WIDTH_BYTES;
    int x = t % WIDTH_BYTES;
    
		for (int ty=0; ty<8; ty++)
		{
			for (int tx=0; tx<8; tx++)
			{
				BYTE pel = chr_rot90[tile_addr+ty];
				pel = pel >> tx & 0x01;
				putpixel (screen, x*8+tx, y*8+ty, CHAR_COLOUR(pel));
			}
		}
  }
#endif
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_TILES
#ifndef GALAGA
  // display the tiles
  clear_bitmap (screen);
  for (int t=0; t<NUM_TILES; t++)
  {
    int tile_addr = t*16;
    int y = t / WIDTH_BYTES;
    int x = t % WIDTH_BYTES;
    
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
#endif

#ifdef SHOW_SPRITES
  for (int p=1; p<2; p++)
  {
    // display the sprites
    clear_bitmap (screen);
    //for (int t=0; t<NUM_SPRITES; t++)
    for (int t=0; t<(WIDTH_PIXELS>>4)*(HEIGHT_PIXELS>>4); t++)
    {
      int sprite_addr = t*128;
      int y = t / (WIDTH_PIXELS>>4);
      int x = t % (WIDTH_PIXELS>>4);
      
  		for (int ty=0; ty<16; ty++)
  		{
  			for (int tx=0; tx<16; tx++)
  			{
  				BYTE pel = sprite_rot90[sprite_addr+ty*8+(tx>>1)];
  				pel = ((pel >> (((tx)&1)<<2)) & 0x07);
          pel = permutate(p, pel);
  				putpixel (screen, x*16+tx, y*16+ty, SPRITE_COLOUR(8+pel));
  			}
  		}
    }
    while (!key[KEY_ESC]);	  
    while (key[KEY_ESC]);	  
  }
#endif

#if 0
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
			int scroll = mem[ATTR_BASE+((vram_addr&0x1f)<<1)+0];
			int attr = mem[ATTR_BASE+((vram_addr&0x1f)<<1)+1] & 0x07;

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
					putpixel (screen, (x*8+tx-scroll+256)%256, y*8+ty, COLOUR(attr)*4+pel);
				}
			}
		}
	}
#endif

#if 0
	// now show some sprites
	for (int s=0; s<HW_SPRITES; s++)
	{
		// sprites priority encoding
		int n = (HW_SPRITES-s);
		int sx = mem[SPRITE_BASE+(n*4)+3] + 1;
		int sy = mem[SPRITE_BASE+(n*4)+0];
		int code = mem[SPRITE_BASE+(n*4)+1] & 0x3f;
		int clr = mem[SPRITE_BASE+(n*4)+2] & 0x07;
		
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				int sprite_addr = (0 + code) * 64;
				BYTE pel = spr_rot90[sprite_addr+ty*4+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x06) & 0x03;
				if (pel)
					putpixel (screen, sx+tx, YPOS(sy)+ty, COLOUR(clr)*4+pel);
			}
		}
	}
#endif

}

END_OF_MAIN();

