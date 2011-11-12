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

#define _1942
//#define VULGUS

#ifdef _1942
#define SET_NAME              "1942"
#define MEM_NAME		          "1942DUMP.BIN"
#define CHAR_ROM_1_NAME       "1-f2.bin"
#define CHAR_ROM_SIZE         0x2000
#define NUM_CHARS             512
#define TILE_ROM_1_NAME       "2-a1.bin"
#define TILE_ROM_2_NAME       "2-a2.bin"
#define TILE_ROM_3_NAME       "2-a3.bin"
#define TILE_ROM_4_NAME       "2-a4.bin"
#define TILE_ROM_5_NAME       "2-a5.bin"
#define TILE_ROM_6_NAME       "2-a6.bin"
#define TILE_ROM_SIZE         0xC000
#define NUM_TILES             512
#define SPRITE_ROM_1_NAME     "2-l1.bin"
#define SPRITE_ROM_2_NAME     "2-l2.bin"
#define SPRITE_ROM_3_NAME     "2-n1.bin"
#define SPRITE_ROM_4_NAME     "2-n2.bin"
#define SPRITE_ROM_SIZE       0x10000
#define NUM_SPRITES           512
#define R_PROM_NAME           "08e_sb-5.bin"
#define G_PROM_NAME           "09e_sb-6.bin"
#define B_PROM_NAME           "10e_sb-7.bin"
#define CHAR_CLUT_PROM_NAME   "f01_sb-0.bin"
#define TILE_CLUT_PROM_NAME   "06d_sb-4.bin"
#define SPRITE_CLUT_PROM_NAME "03k_sb-8.bin"
//"01d_sb-2.bin", 0x0600, 0x0100, /* tile palette selector? (not used) */
//"02d_sb-3.bin", 0x0700, 0x0100, /* tile palette selector? (not used) */
//"k06_sb-1.bin", 0x0800, 0x0100, /* interrupt timing (not used) */
//"01m_sb-9.bin", 0x0900, 0x0100, /* video timing? (not used) */
#endif

#ifdef VULGUS
#define SET_NAME              "VULGUS"
#define MEM_NAME		          "VULGDUMP.BIN"
#define CHAR_ROM_1_NAME       "1-3d.bin"
#define CHAR_ROM_SIZE         0x2000
#define NUM_CHARS             512
#define TILE_ROM_1_NAME       "2-2a.bin"
#define TILE_ROM_2_NAME       "2-3a.bin"
#define TILE_ROM_3_NAME       "2-4a.bin"
#define TILE_ROM_4_NAME       "2-5a.bin"
#define TILE_ROM_5_NAME       "2-6a.bin"
#define TILE_ROM_6_NAME       "2-7a.bin"
#define TILE_ROM_SIZE         0xC000
#define NUM_TILES             512
#define SPRITE_ROM_1_NAME     "2-2n.bin"
#define SPRITE_ROM_2_NAME     "2-3n.bin"
#define SPRITE_ROM_3_NAME     "2-4n.bin"
#define SPRITE_ROM_4_NAME     "2-5n.bin"
#define SPRITE_ROM_SIZE       0x08000
#define NUM_SPRITES           256
#define R_PROM_NAME           "e8.bin"
#define G_PROM_NAME           "e9.bin"
#define B_PROM_NAME           "e10.bin"
#define CHAR_CLUT_PROM_NAME   "d1.bin"
#define TILE_CLUT_PROM_NAME   "c9.bin"
#define SPRITE_CLUT_PROM_NAME "j2.bin"
#endif

// common defines
#define SPRITE_BASE		        0xCC00
#define VRAM_BASE		          0xD000
#define CRAM_BASE             0xD400
#define BGRAM_BASE            0xD800

#define CHAR_COLOUR(i)        (128+i)
#define TILE_COLOUR(b,i)      ((b)*16+i)
#define SPRITE_COLOUR(i)      (64+i)

// don't know if these are right???
#define HW_SPRITES            8
#define YPOS(i)               (i)


#define SUBDIR                SET_NAME "/"

#define ROT90

#ifndef ROT90
#define WIDTH_PIXELS	256
#define HEIGHT_PIXELS	224
#else
#define WIDTH_PIXELS	224
#define HEIGHT_PIXELS	256
#endif
#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE mem[64*1024];

BYTE char_rom[CHAR_ROM_SIZE];
BYTE tile_rom[TILE_ROM_SIZE];
BYTE sprite_rom[SPRITE_ROM_SIZE];
BYTE rgb_prom[256*3];
BYTE char_clut_prom[256];
BYTE tile_clut_prom[256];
BYTE sprite_clut_prom[256];

BYTE chr_rot90[NUM_CHARS*16];
BYTE tile_rot90[NUM_TILES*128];
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

//#define SHOW_PALETTE
//#define SHOW_CLUTS
//#define SHOW_CHARS
//#define SHOW_TILES
//#define SHOW_SPRITES
#define SHOW_VRAM
#define SHOW_BGRAM

void main (int argc, char *argv[])
{
	FILE 	*fp;
	int		i;
	
	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram, bgram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x400, 1, fp);
  fclose (fp);
  fp = fopen (SUBDIR "cram.bin", "wb");
  fwrite (&mem[VRAM_BASE+0x400], 0x400, 1, fp);
  fclose (fp);
  fp = fopen (SUBDIR "bgram_t.bin", "wb");
  for (i=0; i<1024; i+=32)
  	fwrite (&mem[BGRAM_BASE+i], 1, 16, fp);
  fclose (fp);
  fp = fopen (SUBDIR "bgram_a.bin", "wb");
  for (i=0; i<1024; i+=32)
  	fwrite (&mem[BGRAM_BASE+16+i], 1, 16, fp);
  fclose (fp);

	// read char rom(s)
	fp = fopen (SUBDIR CHAR_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (char_rom, CHAR_ROM_SIZE, 1, fp);
	fclose (fp);

  // read tile rom(s)
	fp = fopen (SUBDIR TILE_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom, 0x2000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_ROM_2_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom+0x2000, 0x2000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_ROM_3_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom+0x4000, 0x2000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_ROM_4_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom+0x6000, 0x2000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_ROM_5_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom+0x8000, 0x2000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_ROM_6_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_rom+0xA000, 0x2000, 1, fp);
	fclose (fp);

  // read sprite rom(s)
	fp = fopen (SUBDIR SPRITE_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom, 0x4000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_2_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0x4000, 0x4000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_3_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0x8000, 0x4000, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_4_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0xC000, 0x4000, 1, fp);
	fclose (fp);

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

  // read clut proms
	fp = fopen (SUBDIR CHAR_CLUT_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (char_clut_prom, 256, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR TILE_CLUT_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (tile_clut_prom, 256, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_CLUT_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_clut_prom, 256, 1, fp);
	fclose (fp);

	// convert the char graphics (8x8)
  // - straight from MAME
  static int chr_poff[] = { 4, 0 };
	static int chr_xoff[] = { 0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3 }; 
	static int chr_yoff[] = { 0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16 }; 
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
          // note we've switch x,y to rotate and used y^4 (?)
          int bit = chr_poff[p]+chr_yoff[x]+chr_xoff[y^4];
          pel |= ((char_rom[t*chr_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
        }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) chr_rot90[t*16+y*2+(x>>2)] = tdat;
			}
		}
	}
	fp = fopen (SUBDIR "chrrot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (chr_rot90, NUM_TILES*16, 1, fp);
	fclose (fp);

	// convert the tile graphics (16x16)
  // - straight from MAME
  static int tile_poff[] = { 0, 0x4000*8, 0x8000*8 };
	static int tile_xoff[] = { 0, 1, 2, 3, 4, 5, 6, 7,
			                        16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7 };
	static int tile_yoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			                        8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 };
  static int tile_aoff = 32;

	for (int t=0; t<NUM_TILES; t++)
	{
		for (int y=0; y<16; y++)
		{
			BYTE tdat = 0;
			for (int x=0; x<16; x++)
			{
				BYTE pel = 0;
        for (int p=0; p<3; p++)
        {
          //int bit = tile_poff[p]+tile_yoff[y]+tile_xoff[x^8];
          int bit = tile_poff[p]+tile_yoff[x]+tile_xoff[y^8];
          pel |= ((tile_rom[t*tile_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (2-p);
        }

        // convert to 4 bpp (not 3)			
				tdat = (tdat << 4) | pel;
				if ((x % 2) == 1) tile_rot90[t*128+y*8+(x>>1)] = tdat;
			}
		}
	}

	fp = fopen (SUBDIR "tilerot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (tile_rot90, NUM_TILES*128, 1, fp);
	fclose (fp);

	// convert the sprite graphics (16x16)
  // - straight from MAME
  static int sprite_poff[] = { 0x8000*8+4, 0x8000*8, 4, 0 };
	static int sprite_xoff[] = {  0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			                          16*16+0, 16*16+1, 16*16+2, 16*16+3, 16*16+8+0, 16*16+8+1, 16*16+8+2, 16*16+8+3 };
	static int sprite_yoff[] = {  0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			                          8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16 };
  static int sprite_aoff = 64;

	for (int t=0; t<NUM_SPRITES; t++)
	{
		for (int y=0; y<16; y++)
		{
			BYTE tdat = 0;
			for (int x=0; x<16; x++)
			{
				BYTE pel = 0;
        for (int p=0; p<4; p++)
        {
          int bit = sprite_poff[p]+sprite_yoff[x]+sprite_xoff[y^(8|4)];
          pel |= ((sprite_rom[(t)*sprite_aoff+(bit>>3)] >> (bit & 0x07)) & 0x01) << (3-p);
        }

				tdat = (tdat << 4) | pel;
				if ((x % 2) == 1) sprite_rot90[t*128+y*8+(x>>1)] = tdat;
			}
		}
	}

	fp = fopen (SUBDIR "spriterot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (sprite_rot90, NUM_SPRITES*128, 1, fp);
	fclose (fp);

	
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, 2*HEIGHT_PIXELS, 0, 0);

	// set the palette
  FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
	PALETTE pal;
	for (int c=0; c<256; c++)
	{
    int bit0,bit1,bit2,bit3;

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

    if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
    {
      char r[32], g[32], b[32];
      //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
      strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
      fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
    }
  }
  fclose (fppal);
	set_palette_range (pal, 0, 255, 1);

#ifdef SHOW_PALETTE
  // display palette
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, t);
  }
  SS_TEXTOUT_CENTRE(screen, font, "PALETTE", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_CLUTS
  // display char clut
  // chars use colours 128-143
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, CHAR_COLOUR(char_clut_prom[t]));
  }
  SS_TEXTOUT_CENTRE(screen, font, "CHAR CLUT", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  

  // display tile clut
  // tile use colours 0-63 in 4 banks
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, TILE_COLOUR(0,tile_clut_prom[t]));
  }
  SS_TEXTOUT_CENTRE(screen, font, "TILE CLUT", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  

  // display sprite clut
  // tile use colours 64-79
  clear_bitmap (screen);
  for (int t=0; t<256; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<8; ty++)
      for (int tx=0; tx<8; tx++)
        putpixel (screen, x*8+tx, y*8+ty, SPRITE_COLOUR(sprite_clut_prom[t]));
  }
  SS_TEXTOUT_CENTRE(screen, font, "SPRITE CLUT", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_CHARS
  // display the chars
  clear_bitmap (screen);
  for (int t=0; t<NUM_CHARS; t++)
  {
    int tile_addr = t*16;
    int y = t / 28;
    int x = t % 28;
    
		for (int ty=0; ty<8; ty++)
		{
			for (int tx=0; tx<8; tx++)
			{
				BYTE pel = chr_rot90[tile_addr+ty*2+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
				putpixel (screen, x*8+tx, y*8+ty, CHAR_COLOUR(char_clut_prom[pel]));
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_TILES
  // display the tiles
  clear_bitmap (screen);
  //for (int t=0; t<NUM_TILES; t++)
  for (int t=0; t<14*16; t++)
  {
    int tile_addr = t*128;
    int y = (t % 224) / 14;
    int x = t % 14;
    
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				BYTE pel = tile_rot90[tile_addr+ty*8+(tx>>1)];
				pel = (pel >> (((tx^1)&1)<<2)) & 0x07;
				putpixel (screen, x*16+tx, y*16+ty, TILE_COLOUR(0,tile_clut_prom[pel]));
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#if SHOW_SPRITES
  // display the sprites
  clear_bitmap (screen);
  //for (int t=0; t<NUM_SPRITES; t++)
  for (int t=0; t<14*16; t++)
  {
    int sprite_addr = t*128;
    int y = (t % 224) / 14;
    int x = t % 14;
    
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				BYTE pel = sprite_rot90[sprite_addr+ty*8+(tx>>1)];
				pel = ((pel >> (((tx^1)&1)<<2)) & 0x0f);
        pel = (((pel&8)>>1) | ((pel&4)<<1) | ((pel&2)>>1) | ((pel&1)<<1)) & 0x0f;
				putpixel (screen, x*16+tx, y*16+ty, SPRITE_COLOUR(sprite_clut_prom[pel]));
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_VRAM
  clear_bitmap (screen);
	for (int y=0; y<32; y++)
	{
		for (int x=0; x<28; x++)
		{
			int addr = (x+2)*32+(31-y);
			int t = mem[VRAM_BASE+addr];
    	int tile_addr = t*16;
    	for (int ty=0; ty<8; ty++)
    		for (int tx=0; tx<8; tx++)
    		{
					BYTE pel = chr_rot90[tile_addr+ty*2+(tx>>2)];
					pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
					putpixel (screen, x*8+tx, y*8+ty, CHAR_COLOUR(char_clut_prom[pel]));
    		}
		}
	}
  //SS_TEXTOUT_CENTRE(screen, font, "CHAR RAM", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_BGRAM
  clear_bitmap (screen);
  while (!key[KEY_ESC])
  {
  	for (int h=0; h<32; h+=16)
  	{
			for (int y=0; y<16; y++)
			{
				for (int x=0; x<14; x++)
				{
					int addr = (15-y)*16+(h*16+x+1);
						addr = (addr & 0x0f) | ((addr & 0x01f0) << 1);
					int t = mem[BGRAM_BASE+addr];
					int a = mem[BGRAM_BASE+addr+0x10];
					t += (a&0x80) << 1;
			  	int tile_addr = t*128;
			  	for (int ty=0; ty<16; ty++)
			  		for (int tx=0; tx<16; tx++)
			  		{
							BYTE pel;
							switch (a & (0x60))
							{
								case 0x00:
									pel = tile_rot90[tile_addr+ty*8+(tx>>1)];
									break;
								case 0x20:
									pel = tile_rot90[tile_addr+ty*8+((15-tx)>>1)];
									break;
								case 0x40:
									pel = tile_rot90[tile_addr+(15-ty)*8+(tx>>1)];
									break;
								default:
									pel = tile_rot90[tile_addr+(15-ty)*8+((15-tx)>>1)];
									break;
							}
							pel = (pel >> (((tx^1)&1)<<2)) & 0x07;
							putpixel (screen, x*16+tx, h*16+y*16+ty, TILE_COLOUR(0,tile_clut_prom[pel]));
			  		}
				}
			}
		}
	}
  //SS_TEXTOUT_CENTRE(screen, font, "CHAR RAM", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
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

