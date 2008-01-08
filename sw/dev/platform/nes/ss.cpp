#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALLEGRO_USE_CONSOLE
#include <allegro.h>

#define SHOW_PALETTE
#define SHOW_TILES
#define SHOW_TILEMAP

#define MEM_NAME		    "ppu.mem"
#define MEM_SIZE            12576

//#define CHR_NAME        "wreckcrw.chr"
#define CHR_NAME        "smbe.chr"
                        
#define VRAM_BASE		    0x0000
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
                        
#define SUBDIR          ""

#define WIDTH_PIXELS	  256
#define HEIGHT_PIXELS	  240
#define WIDTH_BYTES		  (WIDTH_PIXELS>>1)
#define HEIGHT_BYTES	  (HEIGHT_PIXELS)

#define TILE_HEIGHT   8
#define TILE_WIDTH    8

typedef unsigned char BYTE;

BYTE mem[MEM_SIZE];
BYTE chr_rom[8192];

char *int2bin (int value, int bits)
{
  static char bin[32];
  int i;

  for (i=0; i<bits; i++)
    bin[i] = ((value & (1<<(bits-1-i))) ? '1' : '0');
  bin[i] = '\0';

  return (bin);
}

void show_tile (int xx, int yy, int t, int a)
{
  unsigned char *chr = mem;
  BYTE *pal_ram = mem + 8192 + 4096 + 256;

  for (int y=0; y<TILE_HEIGHT; y++)
    for (int x=0; x<TILE_WIDTH; x++)
    {
      int b0 = (chr_rom[t*16+y*2+x/4] >> (7-(x%4)*2)) & 0x01;
      int b1 = (chr_rom[t*16+y*2+x/4] >> (6-(x%4)*2)) & 0x01;
      int p = (b1<<1) | b0;
      putpixel (screen, xx+x, yy+y, pal_ram[(a<<2)|p]);
    }
}

int main (int argc, char *argv[])
{
  FILE *fp;

  // read cpu memory dump	
  fp = fopen (SUBDIR MEM_NAME, "rb");
  if (!fp) exit (0);
  fread (mem, 1, MEM_SIZE, fp);
  fclose (fp);

  // read CHR rom over the top (for now)
  fp = fopen (SUBDIR CHR_NAME, "rb");
  if (!fp) exit (0);
  fread (mem, 1, 8192, fp);
  fclose (fp);

  // re-arrange the CHR rom
  for (int t=0; t<512; t++)
    for (int w=0; w<8; w++)
    {
      int w2 = 0;
      for (int b=0; b<8; b++)
      {
        w2 |= (int)(mem[t*16+w] & (1<<b)) << (b+1);
        w2 |= (int)(mem[t*16+w+8] & (1<<b)) << b;
      }
      chr_rom[t*16+w*2] = w2 >> 8;
      chr_rom[t*16+w*2+1] = w2 & 0xff;
    }
  fp = fopen ("chr.bin", "wb");
  fwrite (chr_rom, 1, 8192, fp);
  fclose (fp);

  // write the 2K vram
  fp = fopen (SUBDIR "vram.bin", "wb");
  if (!fp) exit (0);
  fwrite (mem+8192, 1, 2048, fp);
  fclose (fp);

  // write the 64-byte aram
  fp = fopen (SUBDIR "aram.bin", "wb");
  if (!fp) exit (0);
  fwrite (mem+8192+0x3C0, 1, 64, fp);
  fclose (fp);

  BYTE *pal_ram = mem + 8192 + 4096 + 256;
  // write the 32-byte palram
  fp = fopen (SUBDIR "palram.txt", "wt");
  if (!fp) exit (0);
	for (int i=0; i<32; i++)
		fprintf (fp, "X\"%02X\", ", pal_ram[i]);
  fclose (fp);

  allegro_init ();
  install_keyboard ();
  
  set_color_depth (8);
  set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

	// set the palette
	PALETTE pal;
  FILE *fppal = fopen ("pal.txt", "wt");

  static unsigned char cPalette[64][3] =
	{	/* PAL (hardcoded) */
		{0x80,0x80,0x80},{0x00,0x3D,0xA6},{0x00,0x12,0xB0},{0x44,0x00,0x96},{0xA1,0x00,0x5E},{0xC7,0x00,0x28},{0xBA,0x06,0x00},{0x8C,0x17,0x00},
		{0x5C,0x2F,0x00},{0x10,0x45,0x00},{0x05,0x4A,0x00},{0x00,0x47,0x2E},{0x00,0x41,0x66},{0x00,0x00,0x00},{0x05,0x05,0x05},{0x05,0x05,0x05},
		{0xC7,0xC7,0xC7},{0x00,0x77,0xFF},{0x21,0x55,0xFF},{0x82,0x37,0xFA},{0xEB,0x2F,0xB5},{0xFF,0x29,0x50},{0xFF,0x22,0x00},{0xD6,0x32,0x00},
		{0xC4,0x62,0x00},{0x35,0x80,0x00},{0x05,0x8F,0x00},{0x00,0x8A,0x55},{0x00,0x99,0xCC},{0x21,0x21,0x21},{0x09,0x09,0x09},{0x09,0x09,0x09},
		{0xFF,0xFF,0xFF},{0x0F,0xD7,0xFF},{0x69,0xA2,0xFF},{0xD4,0x80,0xFF},{0xFF,0x45,0xF3},{0xFF,0x61,0x8B},{0xFF,0x88,0x33},{0xFF,0x9C,0x12},
		{0xFA,0xBC,0x20},{0x9F,0xE3,0x0E},{0x2B,0xF0,0x35},{0x0C,0xF0,0xA4},{0x05,0xFB,0xFF},{0x5E,0x5E,0x5E},{0x0D,0x0D,0x0D},{0x0D,0x0D,0x0D},
		{0xFF,0xFF,0xFF},{0xA6,0xFC,0xFF},{0xB3,0xEC,0xFF},{0xDA,0xAB,0xEB},{0xFF,0xA8,0xF9},{0xFF,0xAB,0xB3},{0xFF,0xD2,0xB0},{0xFF,0xEF,0xA6},
		{0xFF,0xF7,0x9C},{0xD7,0xE8,0x95},{0xA6,0xED,0xAF},{0xA2,0xF2,0xDA},{0x99,0xFF,0xFC},{0xDD,0xDD,0xDD},{0x11,0x11,0x11},{0x11,0x11,0x11}
	};

	for (int c=0; c<64; c++)
	{
    pal[c].r = cPalette[c][0] >> 2;
    pal[c].g = cPalette[c][1] >> 2;
    pal[c].b = cPalette[c][2] >> 2;

    if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
    {
      char r[32], g[32], b[32];
      //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
      strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
      fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
    }
  }
  set_palette_range (pal, 0, 63, 1);
  fclose (fppal);

#ifdef SHOW_PALETTE

  clear_bitmap (screen);

  for (int t=0; t<4; t++)
    for (int c=0; c<16; c++)
      rectfill (screen, c*16, t*16, c*16+11, t*16+11, t*16+c);

  for (int t=0; t<2; t++)
    for (int c=0; c<16; c++)
    {
      rectfill (screen, c*16, 128+t*16, c*16+11, 128+t*16+11, pal_ram[t*16+c]);
    }

  while (!key[KEY_ESC]);
  while (key[KEY_ESC]);	  

#endif

#ifdef SHOW_TILES

  clear_bitmap (screen);

  // show some tile data
  for (int i=0; i<512; i++)
    show_tile ((i%32)*8, (i/32)*8, i, 0);

  while (!key[KEY_ESC]);
  while (key[KEY_ESC]);	  

#endif

#ifdef SHOW_TILEMAP

  #define HEIGHT_TILES (HEIGHT_PIXELS/TILE_HEIGHT)

  clear_bitmap (screen);

  FILE *fpdebug = fopen ("debug.txt", "wt");

  for (int m=0; m<2; m++)
  {
    //unsigned char *tm = mem + 8192 + m*0x800;
    unsigned char *tm = mem + 8192 + m*0x400;
    unsigned char *am = tm + 0x3c0;

  	for (int y=0; y<HEIGHT_TILES; y++)
    {
  		for (int x=0; x<WIDTH_PIXELS/TILE_WIDTH; x++)
      {
        //int attr = am[(y/4)*8 + (x/4)];
  			int attr = am[((y>>2)<<3)+(x>>2)];
  			int attr_b = (y&(1<<1))|((x&(1<<1))>>1);
        int shift = 0;
  			switch (attr_b)
  			{
  				case 0 : shift = 0; break;
  				case 1 : shift = 2; break;
  				case 2 : shift = 4; break;
  				default : shift = 6; break;
  			}
  
        fprintf (fpdebug, "%02d,%1d ", (y/4)*8+(x/4), shift);
        if (x%4 == 3) fprintf (fpdebug, "| ");
  
        show_tile (x*TILE_WIDTH, y*TILE_HEIGHT, 256+tm[y*32+x], (attr>>shift)&0x03);
      }
      fprintf (fpdebug, "\n");
      if (y%4 == 3) fprintf (fpdebug, "\n");
    }
  
    while (!key[KEY_ESC]);
    while (key[KEY_ESC]);	  
  }

  fclose (fpdebug);

#endif

  allegro_exit ();
}

END_OF_MAIN();

