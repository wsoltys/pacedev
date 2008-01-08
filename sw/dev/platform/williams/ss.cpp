#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

#define SET_NAME        "defender"
#define MEM_NAME		    "defdump.BIN"
#define ROM1_NAME		    "defend.1"
#define ROM2_NAME		    "defend.4"
#define ROM3_NAME		    "defend.2"
#define ROM4_NAME		    "defend.3"
// Banked ROMS          
#define ROM5_NAME		    "defend.9"
#define ROM6_NAME		    "defend.12"
#define ROM7_NAME		    "defend.8"
#define ROM8_NAME		    "defend.11"
#define ROM9_NAME		    "defend.7"
#define ROM10_NAME	    "defend.10"
#define ROM11_NAME	    "defend.6"
// sound CPU ROM        
#define SROM1_NAME	    "defend.snd"
// PROMS                
#define PROM1_NAME	    "decoder.2"
#define PROM2_NAME	    "decoder.3"
                        
#define VRAM_BASE		    0x0000
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
                        
#define SUBDIR          SET_NAME "/"

#define WIDTH_PIXELS	  304
#define HEIGHT_PIXELS	  256
#define WIDTH_BYTES		  (WIDTH_PIXELS>>1)
#define HEIGHT_BYTES	  (HEIGHT_PIXELS)

typedef unsigned char BYTE;

BYTE mem[64*1024];
BYTE prom[2*0x200];

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
  fwrite (&mem[VRAM_BASE], 0x9800, 1, fp);
  fclose (fp);

  //now the PROM
	fp = fopen (SUBDIR PROM1_NAME, "rb");
	if (!fp) exit (0);
	fread (prom, 0x200, 1, fp);
	fclose (fp);
	fp = fopen (SUBDIR PROM2_NAME, "rb");
	if (!fp) exit (0);
	fread (prom+0x200, 0x200, 1, fp);
	fclose (fp);

	allegro_init ();
	install_keyboard ();
  
	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

	// set the palette
	PALETTE pal;
  //BYTE *pal_ram = &mem[0xC000];
  FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
  BYTE pal_ram[] = {0x00, 0x3C, 0x07, 0x28, 0x2F, 0x81, 0xA4, 0x15, 0xC7, 0xFF, 0xC6, 0x00, 0xC6, 0x81, 0x81, 0x2F};
	for (int c=0; c<16; c++)
	{
    pal[c].r = ((pal_ram[c] & (1<<0) ? 0x21 : 0x00) + 
    			      (pal_ram[c] & (1<<1) ? 0x47 : 0x00) +
    			      (pal_ram[c] & (1<<2) ? 0x97 : 0x00)) >> 2;
    pal[c].g = ((pal_ram[c] & (1<<3) ? 0x21 : 0x00) + 
    			      (pal_ram[c] & (1<<4) ? 0x47 : 0x00) +
    			      (pal_ram[c] & (1<<5) ? 0x97 : 0x00)) >> 2;
    pal[c].b = ((pal_ram[c] & (1<<6) ? 0x4f : 0x00) + 
    			      (pal_ram[c] & (1<<7) ? 0xa8 : 0x00)) >> 2;

      if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
      {
        char r[32], g[32], b[32];
        //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
        strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
        fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
      }
  }
  fclose (fppal);
  set_palette_range (pal, 0, 16, 1);

	for (int y=0; y<HEIGHT_PIXELS; y++)
	{
		for (int x=0; x<WIDTH_PIXELS; x++)
		{
      int addr = y + (x>>1)*256;
      int pel = mem[addr];

      if ((x&1)==0) pel >>= 4;
      pel &= 0x0F;

  		putpixel (screen, x, y, pel);
		}
	}

  while (!key[KEY_ESC])
  	;	  
}

END_OF_MAIN();

