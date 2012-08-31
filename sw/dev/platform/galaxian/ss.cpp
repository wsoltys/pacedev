#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

//#define GALAXIAN
#define MOONCRST
//#define ZIGZAG
//#define JUMPBUG
//#define FROGGER

#ifdef GALAXIAN
#define SET_NAME    "galaxian"
#define MEM_NAME		"GALDUMP.BIN"
#define ROM1_NAME		"1h.bin"
#define ROM2_NAME		"1k.bin"
#define GFX_ROM_SIZE    (2*1024)
#define NUM_TILES       256
#define NUM_SPRITES     64
#define PROM_NAME		"6l.bpr"
#define VRAM_BASE		0x5400
#define ATTR_BASE		0x5800
#define SPRITE_BASE		0x5840
#define HW_SPRITES      7
#define BULLET_BASE		0x5860
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
#endif
#ifdef MOONCRST
#define SET_NAME    "mooncrst"
#define MEM_NAME		"MOONDUMP.BIN"
#define ROM1_NAME		"mcs_b"
#define ROM2_NAME		"mcs_d"
#define ROM3_NAME		"mcs_a"
#define ROM4_NAME		"mcs_c"
#define GFX_ROM_SIZE    (2*1024)
#define NUM_TILES       512
#define NUM_SPRITES     128
#define PROM_NAME		"l06_prom.bin"
#define VRAM_BASE		0x9400
#define ATTR_BASE		0x9800
#define SPRITE_BASE		0x9840
#define HW_SPRITES      7
#define BULLET_BASE		0x9860
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
#endif
#ifdef ZIGZAG
#define SET_NAME    "zigzag"
#define MEM_NAME		"ZIGDUMP.BIN"
#define ROM1_NAME		"zz_6_h1.bin"
#define ROM2_NAME		"zz_5.bin"
#define GFX_ROM_SIZE    (4*1024)
#define NUM_TILES       256
#define NUM_SPRITES     64
#define PROM_NAME		"zzbp_e9.bin"
#define VRAM_BASE		0x5000
#define ATTR_BASE		0x5800
#define SPRITE_BASE		0x5840
#define HW_SPRITES     16
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
#endif
#ifdef JUMPBUG
#define SET_NAME    "jumpbug"
#define MEM_NAME		"JBUGDUMP.BIN"
#define ROM1_NAME		"jbl"
#define ROM2_NAME		"jbm"
#define ROM3_NAME		"jbn"
#define ROM4_NAME		"jbi"
#define ROM5_NAME		"jbj"
#define ROM6_NAME		"jbk"
#define GFX_ROM_SIZE    (0x800)
#define NUM_TILES       768
#define NUM_SPRITES     192
#define PROM_NAME		"l06_prom.bin"
// vram is mirrored at $4800 for writes 
#define VRAM_BASE		0x4C00
#define ATTR_BASE		0x5000
#define SPRITE_BASE		0x5040
#define HW_SPRITES     16
#define BULLET_BASE		0x5060
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
#endif
#ifdef FROGGER
#define SET_NAME    "frogger"
#define MEM_NAME		"FRGDUMP.BIN"
#define ROM1_NAME		"frogger.607"
#define ROM2_NAME		"frogger.606"
#define GFX_ROM_SIZE    (2*1024)
#define NUM_TILES       256
#define NUM_SPRITES     64
#define PROM_NAME		"pr-91.6l"
#define VRAM_BASE		0xa800
#define ATTR_BASE		0xb000
#define SPRITE_BASE		0xb040
#define HW_SPRITES     7
#define COLOUR(i)       ((((i)>>1)&0x03)|(((i)<<2)&0x04))
#define YPOS(i)         (((i)<<4)|((i)>>4))
#define SND_ROM_0		"frogger.608"
#define SND_ROM_1		"frogger.609"
#define SND_ROM_2		"frogger.610"
#endif

#define SUBDIR        SET_NAME "/"

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
BYTE gfx_rom[6*GFX_ROM_SIZE];
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

  printf ("Running SS...\n");
	
	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) 
  {
    printf ("unable to open \"%s\"!\n", SUBDIR MEM_NAME);
    //exit (0);
  }
	//fread (mem, 64*1024, 1, fp);
	//fclose (fp);

  // write vram, attr, sprite & bullet ram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 1024, 1, fp);
  fclose (fp);

#ifdef FROGGER
	// read snd roms
	fp = fopen (SUBDIR SND_ROM_0, "rb");
	if (!fp) exit (0);
	fread (&snd_rom[2*1024*0], 2*1024, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SND_ROM_1, "rb");
	if (!fp) exit (0);
	fread (&snd_rom[2*1024*1], 2*1024, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR SND_ROM_2, "rb");
	if (!fp) exit (0);
	fread (&snd_rom[2*1024*2], 2*1024, 1, fp);
	fclose (fp);
	// decode the first rom
	for (int i=0; i<0x800; i++)
      snd_rom[i] = (snd_rom[i]&0xFC) | ((snd_rom[i]<<1)&0x02) | ((snd_rom[i]>>1)&0x01);
  // write the combined decoded rom
  fp = fopen (SUBDIR "frogsnd0.bin", "wb");
  fwrite (snd_rom, 2*1024*2, 1, fp);
  fclose (fp);
  fp = fopen (SUBDIR "frogsnd1.bin", "wb");
  fwrite (&snd_rom[2*1024*2], 2*1024*1, 1, fp);
  fclose (fp);
#endif

	// read graphics roms
	fp = fopen (SUBDIR ROM1_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[0], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR ROM2_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[GFX_ROM_SIZE], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
    // decode frogger gfs rom #2
#ifdef FROGGER
  for (int i=0x800; i<0x1000; i++)
    gfx_rom[i] = (gfx_rom[i]&0xFC) | ((gfx_rom[i]<<1)&0x02) | ((gfx_rom[i]>>1)&0x01);
#endif
#if defined(MOONCRST) or defined(JUMPBUG)
	fp = fopen (SUBDIR ROM3_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[2*GFX_ROM_SIZE], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR ROM4_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[3*GFX_ROM_SIZE], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
#ifdef JUMPBUG
	fp = fopen (SUBDIR ROM5_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[4*GFX_ROM_SIZE], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR ROM6_NAME, "rb");
	if (!fp) exit (0);
	fread (&gfx_rom[5*GFX_ROM_SIZE], GFX_ROM_SIZE, 1, fp);
	fclose (fp);
#endif
#endif

    //now the PROM
	fp = fopen (SUBDIR PROM_NAME, "rb");
	if (!fp) exit (0);
	fread (gfx_prom, 32, 1, fp);
	fclose (fp);

	// convert the char graphics (8x8)
#ifndef ZIGZAG
#ifdef JUMPBUG
    // 768 chars
    static int chr_poff[] = { 0, 49152 };
    static int chr_xoff[] = { 56, 48, 40, 32, 24, 16, 8, 0 };
    static int chr_yoff[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
#else
  #ifdef MOONCRST
	  static int chr_poff[] = { 0, 32768 };
  #else
	  static int chr_poff[] = { 0, 16384 };
  #endif
	static int chr_xoff[] = { 56, 48, 40, 32, 24, 16, 8, 0 }; 
	static int chr_yoff[] = { 0, 1, 2, 3, 4, 5, 6, 7 }; 
#endif
#else
	static int chr_poff[] = { 0, 32768 };
	static int chr_yoff[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
	//static int chr_xoff[] = { 0, 8, 16, 24, 32, 40, 48, 56 };
	static int chr_xoff[] = { 56, 48, 40, 32, 24, 16, 8, 0 };
#endif
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
	fp = fopen (SUBDIR "chrrot90_0.bin", "wb");
	if (!fp) exit (0);
#ifndef JUMPBUG
	fwrite (chr_rot90, NUM_TILES*16, 1, fp);
#else
	fwrite (chr_rot90, 512*16, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR "chrrot90_1.bin", "wb");
	fwrite (&chr_rot90[512*16], 256*16, 1, fp);
#endif
	fclose (fp);
		
	FILE *fpSpr[4];
	for (int i=0; i<4; i++)
	{
		char sprFile[64];
		sprintf (sprFile, SUBDIR "sprite%d.bin", i);
		fpSpr[i] = fopen (sprFile, "wb");
	}

	// convert the sprite graphics (16x16)
#ifndef ZIGZAG
#ifdef JUMPBUG
    // 192 sprites
    static int spr_poff[] = { 0, 49152 };
    static int spr_xoff[] = { 184, 176, 168, 160, 152, 144, 136, 128, 56, 48, 40, 32, 24, 16, 8, 0 };
    static int spr_yoff[] = { 0, 1, 2, 3, 4, 5, 6, 7, 64, 65, 66, 67, 68, 69, 70, 71 };
#else
  #ifdef MOONCRST
	  static int spr_poff[] = { 0, 32768 };
  #else
	  static int spr_poff[] = { 0, 16384 };
  #endif
	static int spr_xoff[] = { 184, 176, 168, 160, 152, 144, 136, 128, 56, 48, 40, 32, 24, 16, 8, 0 };
	static int spr_yoff[] = { 0, 1, 2, 3, 4, 5, 6, 7, 64, 65, 66, 67, 68, 69, 70, 71 }; 
#endif
#else
	//static int spr_poff[] = { 0, 32768 };
	static int spr_poff[] = { 2*1024*8, 2*1024*8+32768 };
	static int spr_yoff[] = { 0, 1, 2, 3, 4, 5, 6, 7, 64, 65, 66, 67, 68, 69, 70, 71 };
	//static int spr_xoff[] = { 0, 8, 16, 24, 32, 40, 48, 56, 128, 136, 144, 152, 160, 168, 176, 184 };
	static int spr_xoff[] = { 184, 176, 168, 160, 152, 144, 136, 128, 56, 48, 40, 32, 24, 16, 8, 0 };
#endif
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
                    int bit = spr_poff[p]+spr_xoff[x]+spr_yoff[y^0x07];
                    pel |= ((gfx_rom[t*32+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
                }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3)
                {
                    fwrite (&tdat, 1, 1, fpSpr[x/4]);
                    spr_rot90[t*64+y*4+(x>>2)] = tdat;
                }
			}
		}
	}
	for (int i=0; i<4; i++)
		fclose (fpSpr[i]);

	fp = fopen (SUBDIR "sprrot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (spr_rot90, NUM_SPRITES*64, 1, fp);
	fclose (fp);

  printf ("Switching into Allegro...\n");
	
  	allegro_init ();
  	install_keyboard ();
  
  	set_color_depth (8);
  	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);
  	
  	// set the palette
    FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
  	PALETTE pal;
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

	// bullets have their own circuitry/palette
	pal[32].r = 0xef >> 2;
	pal[32].g = 0xef >> 2;
	pal[32].b = 0x00 >> 2;
	pal[33].r = 0xef >> 2;
	pal[33].g = 0xef >> 2;
	pal[33].b = 0xef >> 2;
	
    // frogger b/g colour
    pal[33].r = 0;
    pal[33].g = 0;
    pal[33].b = 0x47 >> 2;

  	set_palette_range (pal, 0, 34, 1);

  // show tiles
  for (int t=0; t<NUM_TILES; t++)
  {
    int x = t % 32;
    int y = t / 32;
    
		for (int ty=0; ty<8; ty++)
		{
  		for (int tx=0; tx<8; tx++)
  		{
#ifndef ROT90
				int p0 = (gfx_rom[t*16+ty] >> (7-tx)) & 0x01; 
				int p1 = (gfx_rom[2*1024+t*16+ty] >> (7-tx)) & 0x01;
				int pel = (p1 << 1) | p0;
#else
				BYTE pel = chr_rot90[t*16+ty*2+(tx>>2)];
				pel = pel >> (((7-tx)<<1)&0x6) & 0x03;
#endif
				putpixel (screen, x*8+tx, y*8+ty, COLOUR(0)*4+pel);
			}
		}
  }
  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
  
  	
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
#ifdef ZIGZAG
			int vram_addr = ((29-x)*32) + y;
#else
			int vram_addr = ((31-x)*32) + y;
#endif
			int c = mem[VRAM_BASE+vram_addr];
			// 16 bytes per tile
			int tile_addr = c*16;
#endif

#ifdef FROGGER
			int bg_colour = (y < 128 ? 33 : -1);
#else
			int bg_colour = -1;
#endif

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

#if 1
	
	// now show some sprites
	for (int s=0; s<HW_SPRITES; s++)
	{
		// sprites priority encoding
#if defined(ZIGZAG) or defined(JUMPBUG)
		int n = (HW_SPRITES-1-s);
		int sy = mem[SPRITE_BASE+(n*4)+3] + 1;
		int sx = mem[SPRITE_BASE+(n*4)+0] - 17;
#else
		int n = (HW_SPRITES-s);
		int sx = mem[SPRITE_BASE+(n*4)+3] + 1;
		int sy = mem[SPRITE_BASE+(n*4)+0];
#endif
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

#if 1

#if defined(GALAXIAN) or defined(MOONCRST) or defined(JUMPBUG)
	// draw some bullets
	for (int b=0; b<8; b++)
	{
		int by = 255 - mem[BULLET_BASE+(b*4)+1];
		int bx = 255 - mem[BULLET_BASE+(b*4)+3];
		
		if (by < 0 || by >= HEIGHT_PIXELS)
			continue;
			
		for (int p=0; p<4; p++)
			putpixel (screen, by, bx-p-1, COLOUR((b==7 ? 33 : 32)));
	}
#endif

#endif
	
    while (!key[KEY_ESC])
    	;	  
}

END_OF_MAIN();

