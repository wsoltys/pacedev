#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

//#define SHOW_PALETTE
//#define SHOW_CLUTS
//#define SHOW_CHARS
//#define SHOW_SPRITES
#define SHOW_VRAM
#define SHOW_SPRITERAM

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#define SONSON

#ifdef SONSON
#define SET_NAME              "sonson"
#define MEM_NAME		          "sonson.bin"
#define CHAR_ROM_1_NAME       "ss_7.b6"
#define CHAR_ROM_2_NAME       "ss_8.b5"
#define CHAR_ROM_SIZE         0x4000
#define NUM_CHARS             1024
#define SPRITE_ROM_1_NAME     "ss_9.m5"
#define SPRITE_ROM_2_NAME     "ss_10.m6"
#define SPRITE_ROM_3_NAME     "ss_11.m3"
#define SPRITE_ROM_4_NAME     "ss_12.m4"
#define SPRITE_ROM_5_NAME     "ss_13.m1"
#define SPRITE_ROM_6_NAME     "ss_14.m2"
#define SPRITE_ROM_SIZE       0xC000
#define NUM_SPRITES           512
#define GB_PROM_NAME          "ssb4.b2"
#define R_PROM_NAME           "ssb5.b1"
#define CHAR_CLUT_PROM_NAME   "ssb2.c4"
#define SPRITE_CLUT_PROM_NAME "ssb3.h7"
#endif

// common defines
#define SPRITE_BASE		        0x2020
#define VRAM_BASE		          0x1000
#define CRAM_BASE             0x1400

#define CHAR_COLOUR(c)      	(c)
#define SPRITE_COLOUR(c)      (0x10+c)

#define SUBDIR                SET_NAME "/"

#define WIDTH_PIXELS	256
#define HEIGHT_PIXELS	256
#define WIDTH_BYTES		(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES	(HEIGHT_PIXELS>>3)

typedef unsigned char BYTE;

BYTE mem[64*1024];

BYTE char_rom[CHAR_ROM_SIZE];
BYTE sprite_rom[SPRITE_ROM_SIZE];
BYTE color_prom[2*32];
BYTE char_clut_prom[256];
BYTE sprite_clut_prom[256];

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
	FILE 	*fp;
	int		i;

	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) { printf ("can't open \"%s\"!\n", SUBDIR MEM_NAME); exit (0); }
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x400, 1, fp);
  fclose (fp);
  fp = fopen (SUBDIR "cram.bin", "wb");
  fwrite (&mem[CRAM_BASE], 0x400, 1, fp);
  fclose (fp);

	// read char rom(s)
	fp = fopen (SUBDIR CHAR_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (char_rom, CHAR_ROM_SIZE, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR CHAR_ROM_2_NAME, "rb");
	if (!fp) exit (0);
	fread (char_rom+0x2000, CHAR_ROM_SIZE, 1, fp);
	fclose (fp);

  // read sprite rom(s)
	fp = fopen (SUBDIR SPRITE_ROM_1_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom, 1, 0x2000, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_2_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0x2000, 1, 0x2000, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_3_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0x4000, 1, 0x2000, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_4_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0x6000, 1, 0x2000, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_5_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0x8000, 1, 0x2000, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_ROM_6_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_rom+0xA000, 1, 0x2000, fp);
	fclose (fp);

  // read palette proms
	fp = fopen (SUBDIR GB_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (color_prom, 1, 32, fp);
	fclose (fp);
	fp = fopen (SUBDIR R_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (color_prom+32, 1, 32, fp);
	fclose (fp);

  // read clut proms
	fp = fopen (SUBDIR CHAR_CLUT_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (char_clut_prom, 1, 256, fp);
	fclose (fp);
	fp = fopen (SUBDIR SPRITE_CLUT_PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (sprite_clut_prom, 1, 256, fp);
	fclose (fp);

#if 1
  FILE *fpclut = fopen (SUBDIR "clut.txt", "wt");
	for (i=0; i<256; i+=4)
	{
		if (char_clut_prom[i+0] != 0x00 ||
				char_clut_prom[i+1] != 0x00 ||
				char_clut_prom[i+2] != 0x00 ||
				char_clut_prom[i+3] != 0x00)
		{
				fprintf (fpclut, "%2d => (", i/4);
				for (int j=0; j<4; j++)
					fprintf (fpclut, "%d=>X\"%01X\"%s", 
										j, char_clut_prom[i+j], 
										(j<3 ? ", " : ""));
			fprintf (fpclut, "),\n");
		}
	}  
	fprintf (fpclut, "others => (others => X\"0\")\n");
	for (i=0; i<256; i+=8)
	{
		if (sprite_clut_prom[i+0] != 0x00 ||
				sprite_clut_prom[i+1] != 0x00 ||
				sprite_clut_prom[i+2] != 0x00 ||
				sprite_clut_prom[i+3] != 0x00 ||
				sprite_clut_prom[i+4] != 0x00 ||
				sprite_clut_prom[i+5] != 0x00 ||
				sprite_clut_prom[i+6] != 0x00 ||
				sprite_clut_prom[i+7] != 0x00)
		{
				fprintf (fpclut, "%2d => (", i/8);
				for (int j=0; j<8; j++)
					fprintf (fpclut, "%d=>X\"%01X\"%s", 
										j, sprite_clut_prom[i+j], 
										(j<7 ? ", " : ""));
			fprintf (fpclut, "),\n");
		}
	}  
	fprintf (fpclut, "others => (others => X\"0\")\n");
  fclose (fpclut);
#endif
  
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

	// set the palette
  FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
	PALETTE pal;
	for (int i=0; i<32; i++)
	{
    int bit0,bit1,bit2,bit3;
		int r, g, b;

		/* red component */
		bit0 = (color_prom[i + 0x20] >> 0) & 0x01;
		bit1 = (color_prom[i + 0x20] >> 1) & 0x01;
		bit2 = (color_prom[i + 0x20] >> 2) & 0x01;
		bit3 = (color_prom[i + 0x20] >> 3) & 0x01;
		r = 0x0e * bit0 + 0x1f * bit1 + 0x43 * bit2 + 0x8f * bit3;

		/* green component */
		bit0 = (color_prom[i + 0x00] >> 4) & 0x01;
		bit1 = (color_prom[i + 0x00] >> 5) & 0x01;
		bit2 = (color_prom[i + 0x00] >> 6) & 0x01;
		bit3 = (color_prom[i + 0x00] >> 7) & 0x01;
		g = 0x0e * bit0 + 0x1f * bit1 + 0x43 * bit2 + 0x8f * bit3;

		/* blue component */
		bit0 = (color_prom[i + 0x00] >> 0) & 0x01;
		bit1 = (color_prom[i + 0x00] >> 1) & 0x01;
		bit2 = (color_prom[i + 0x00] >> 2) & 0x01;
		bit3 = (color_prom[i + 0x00] >> 3) & 0x01;
		b = 0x0e * bit0 + 0x1f * bit1 + 0x43 * bit2 + 0x8f * bit3;

		pal[i].r = r>>2; pal[i].g = g>>2; pal[i].b = b>>2;
		
    if (!(pal[i].r == 0 && pal[i].g == 0 && pal[i].b == 0))
    {
      char r[32], g[32], b[32];
      //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
      strcpy (r, int2bin(pal[i].r,6)); strcpy (g, int2bin(pal[i].g,6)); strcpy (b, int2bin(pal[i].b,6));
      fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", i, r, g, b);
    }
  }
  fclose (fppal);
	set_palette_range (pal, 0, 31, 1);

#ifdef SHOW_PALETTE
  // display palette
  clear_bitmap (screen);
  for (int t=0; t<32; t++)
  {
    int y = t/16;
    int x = t%16;
    for (int ty=0; ty<16; ty++)
      for (int tx=0; tx<16; tx++)
        putpixel (screen, x*16+tx, y*16+ty, t);
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

#define RGN_FRAC(r,s) r*8/s

  // - straight from MAME
  static int chr_poff[] = { CHAR_ROM_SIZE*RGN_FRAC(1,2), CHAR_ROM_SIZE*RGN_FRAC(0,2) };
	static int chr_xoff[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
	static int chr_yoff[] = { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 }; 
  static int chr_aoff = 8*8;

#ifdef SHOW_CHARS

  // display the chars
  clear_bitmap (screen);
  for (int t=0; t<NUM_CHARS; t++)
  {
    int y = t / (256/8);
    int x = t % (256/8);
    
		for (int ty=0; ty<8; ty++)
		{
			for (int tx=0; tx<8; tx++)
			{
				int pel = 0;
				
        for (int p=0; p<2; p++)
        {
          int bit = chr_poff[p]+chr_yoff[ty]+chr_xoff[7-tx];
          pel |= ((char_rom[t*chr_aoff/8+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
        }
				//putpixel (screen, x*8+tx, y*8+ty, CHAR_COLOUR(0,char_clut_prom[pel]));
				putpixel (screen, x*8+tx, y*8+ty, pel);
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif

  // - straight from MAME
  static int sprite_poff[] = { 	SPRITE_ROM_SIZE*RGN_FRAC(2,3), 
  															SPRITE_ROM_SIZE*RGN_FRAC(1,3), 
  															SPRITE_ROM_SIZE*RGN_FRAC(0,3) };
	static int sprite_xoff[] =  { 8*16+7, 8*16+6, 8*16+5, 8*16+4, 8*16+3, 8*16+2, 8*16+1, 8*16+0,
																7, 6, 5, 4, 3, 2, 1, 0 };
	static int sprite_yoff[] = { 	0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
																8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 };
  static int sprite_aoff = 32*8;

#ifdef SHOW_SPRITES

	FILE *fpl = fopen("log.txt", "wt");
	fprintf (fpl, "%X:%X,%X,%X\n",
						SPRITE_ROM_SIZE, RGN_FRAC(2,3), RGN_FRAC(1,3), RGN_FRAC(0,3));
	fprintf (fpl, "%X,%X,%X\n",
						sprite_poff[0]>>3, sprite_poff[1]>>3, sprite_poff[2]>>3);
	fclose (fpl);
	
  // display the sprites
  clear_bitmap (screen);
  //for (int t=0; t<NUM_SPRITES; t++)
  for (int t=0; t<256; t++)
  {
    int y = t / (256/16);
    int x = t % (256/16);
    
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				int pel = 0;
				
        for (int p=0; p<3; p++)
        {
          int bit = sprite_poff[p]+sprite_yoff[ty]+sprite_xoff[tx/8*8+(7-(tx%8))];
          pel |= ((sprite_rom[t*sprite_aoff/8+(bit>>3)] >> (bit & 0x07)) & 0x01) << (2-p);
        }
        
				//putpixel (screen, x*16+tx, y*16+ty, SPRITE_COLOUR(sprite_clut_prom[pel]));
				putpixel (screen, x*16+tx, y*16+ty, pel);
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
		for (int x=0; x<32; x++)
		{
			int addr = y*32+x;
			int t = mem[VRAM_BASE+addr];
			int a = mem[CRAM_BASE+addr];

			t += 256 * (a&0x03);
			a >>= 2;
			
			for (int ty=0; ty<8; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
					int pel = 0;
					
	        for (int p=0; p<2; p++)
	        {
	          int bit = chr_poff[p]+chr_yoff[ty]+chr_xoff[7-tx];
	          pel |= ((char_rom[t*chr_aoff/8+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
	        }
					putpixel (screen, x*8+tx, y*8+ty, char_clut_prom[a*4+pel]);
				}
			}
		}
	}
  //SS_TEXTOUT_CENTRE(screen, font, "CHAR RAM", SCREEN_W/2, SCREEN_H-8, 1);
  //while (!key[KEY_ESC]);	  
  //while (key[KEY_ESC]);	  
#endif

#ifdef SHOW_SPRITERAM
	FILE *fpl = fopen("log.txt", "wt");
  //clear_bitmap (screen);
  //while (!key[KEY_ESC])
  {
  	int offs;
  	
		for (offs = 0x60 - 4; offs >= 0; offs -= 4)
  	{
  		BYTE *spriteram = &mem[SPRITE_BASE];
  		
			int code = spriteram[offs + 2] + ((spriteram[offs + 1] & 0x20) << 3);
			int color = spriteram[offs + 1] & 0x1f;
			int flipx = ~spriteram[offs + 1] & 0x40;
			int flipy = ~spriteram[offs + 1] & 0x80;
			int sx = spriteram[offs + 3];
			int sy = spriteram[offs + 0];

			for (int ty=0; ty<16; ty++)
			{
				for (int tx=0; tx<16; tx++)
				{
					int pel = 0;
					
	        for (int p=0; p<3; p++)
	        {
	          int bit = sprite_poff[p];
	          bit += (flipy ? sprite_yoff[15-ty] : sprite_yoff[ty]);
	          bit += (flipx ? sprite_xoff[(15-tx)/8*8+(tx%8)] : sprite_xoff[tx/8*8+(7-(tx%8))]);
	          pel |= ((sprite_rom[code*sprite_aoff/8+(bit>>3)] >> (bit & 0x07)) & 0x01) << (2-p);
	        }

					if (pel != 0)	        
						putpixel (screen, sx+tx, sy+ty, 0x10+sprite_clut_prom[color*8+pel]);
				}
			}
		}
	}
	fclose(fpl);
  //SS_TEXTOUT_CENTRE(screen, font, "CHAR RAM", SCREEN_W/2, SCREEN_H-8, 1);
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
#endif
	
}

END_OF_MAIN();

