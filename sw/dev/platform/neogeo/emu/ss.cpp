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

#define SET_NAME              "JOYJOY"
#define MEM_NAME		          "JOYJOY.BIN"
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
#define SPRITE_ROM_1_NAME     "021-c1.bin"
#define SPRITE_ROM_2_NAME     "021-c2.bin"
#define SPRITE_ROM_SIZE       0x100000
#define NUM_SPRITES           8192

#define CHAR_COLOUR(i)        (128+i)
#define TILE_COLOUR(b,i)      ((b)*16+i)
#define SPRITE_COLOUR(i)      (i)

#define SUBDIR                SET_NAME "/"

#define WIDTH_PIXELS	304
#define HEIGHT_PIXELS	224
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

BYTE sprite_decoded[NUM_SPRITES*8*16];

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

#if 0
	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram, bgram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x400, 1, fp);
  fclose (fp);
  fp = fopen (SUBDIR "bgram.bin", "wb");
  fwrite (&mem[BGRAM_BASE], 0x400, 1, fp);
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
#endif

  // read sprite rom(s)
	fp = fopen (SUBDIR SPRITE_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	for (int i=0; i<0x100000; i+=2)
  	fread (&sprite_rom[i], 1, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_2_NAME, "rb");
	if (!fp) exit (0);
	for (int i=1; i<0x100000; i+=2)
  	fread (&sprite_rom[i], 1, 1, fp);
	fclose (fp);

#if 0
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
#endif

#if 0
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
#endif

#if 1
  {
    BYTE *src = sprite_rom;
    BYTE *dest = sprite_decoded;
    
    BYTE code;
    
  	for (int i=0; i<SPRITE_ROM_SIZE; i += 0x80, src += 0x80)
  	{
  		int y;
  
  		for (y = 0; y < 0x10; y++)
  		{
  			int x;

  			for (x = 0; x < 8; x++)
  			{
  			  code <<= 4;
  				code |= (((src[0x43 | (y << 2)] >> x) & 0x01) << 3) |
  						    (((src[0x41 | (y << 2)] >> x) & 0x01) << 2) |
  							(((src[0x42 | (y << 2)] >> x) & 0x01) << 1) |
  							(((src[0x40 | (y << 2)] >> x) & 0x01) << 0);
  			  if (x%2==1) *(dest++) = code;
  			}
  
  			for (x = 0; x < 8; x++)
  			{
  			  code <<= 4;
  				code |= (((src[0x03 | (y << 2)] >> x) & 0x01) << 3) |
  						    (((src[0x01 | (y << 2)] >> x) & 0x01) << 2) |
  							(((src[0x02 | (y << 2)] >> x) & 0x01) << 1) |
  							(((src[0x00 | (y << 2)] >> x) & 0x01) << 0);
  			  if (x%2==1) *(dest++) = code;
  			}
  		}
  	}
  }
  
	fp = fopen (SUBDIR "sprite_decoded.bin", "wb");
	if (!fp) exit (0);
	fwrite (sprite_decoded, NUM_SPRITES*8*16, 1, fp);
	fclose (fp);
#endif

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

#if 0
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
	set_palette_range (pal, 0, 256, 1);
#endif

#if 0
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

#if 0
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

#if 0
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

#if 0
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

#if 1
  #define SPL (WIDTH_PIXELS/16)
  #define LPS (HEIGHT_PIXELS/16)  
  // display the sprites
  clear_bitmap (screen);
  for (int t=0; t<NUM_SPRITES; t++)
  {
    int sprite_addr = t*16/2*16;
    int x = t % SPL;
    int y = t / SPL % (SPL*LPS);
    
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
			  BYTE pel = sprite_decoded[sprite_addr+ty*16/2+tx/2];
				pel = (pel >> (((tx^1)&1)<<2)) & 0x0f;
				putpixel (screen, x*16+tx, y*16+ty, SPRITE_COLOUR(pel));
			}
		}
		if (t == SPL*LPS-1)
		  break;
  }
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
