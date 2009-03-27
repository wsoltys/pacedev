#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALLEGRO_USE_CONSOLE
#include <allegro.h>

//#define SHOW_PALETTE
#define SHOW_TILES

#define SET_NAME        "tutankhm"
#define MEM_NAME		    "tutdump.BIN"
                        
#define VRAM_BASE		    0x0000
#define COLOUR(i)       (i)
#define YPOS(i)         (i)
                        
#define SUBDIR          ""

#define WIDTH_PIXELS	  256
#define HEIGHT_PIXELS	  256
#define WIDTH_BYTES		  (WIDTH_PIXELS>>1)
#define HEIGHT_BYTES	  (HEIGHT_PIXELS)

typedef unsigned char BYTE;

BYTE mem[64*1024];

char *int2bin (int value, int bits)
{
  static char bin[32];
  int i;

  for (i=0; i<bits; i++)
    bin[i] = ((value & (1<<(bits-1-i))) ? '1' : '0');
  bin[i] = '\0';

  return (bin);
}

int main (int argc, char *argv[])
{
	FILE *fp;

#if 0
	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x8000, 1, fp);
  fclose (fp);
#endif

	allegro_init ();
	install_keyboard ();
  
	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

#if 0
	// set the palette
	PALETTE pal;
  //BYTE *pal_ram = &mem[0xC000];
  FILE *fppal = fopen (SUBDIR "pal.txt", "wt");
  BYTE pal_ram[] = 
  {
    0,0x80,0x38,0xA4,0xAF,0xC5,7,0xA4,0x3F,0xD,0x27,0x87,0xC0,0xF2,0xFF,0,
    0,0x80,0x38,0xC5,0xAF,0xC5,7,0xA4,0x3F,0x25,0x27,0x87,0xC0,0xF2,0xFF,0,
    0,0x53,0x38,0x25,0xAF,0xC5,7,0xA4,0x3F,0xD,0xF2,0x87,0xC0,0xF2,0xFF,0,
    0,0,0x38,0xC0,0xAF,0xC5,7,0xA4,0x3F,0xD,0x27,0x87,0xC0,0xF2,0xFF,0,
    0,0,0x38,0xA4,0xAF,0xC5,7,0xA4,0x3F,0xD,0x27,0x87,0xC0,0xF2,0xFF,0,
    0,0x80,0x38,0xA4,0xAF,0xC5,7,0xA4,0x3F,0xD,0x27,0x87,0xC0,0xF2,0xFF,0,
    0,0x80,0x38,0xA4,0xAF,0xC5,7,0xA4,0x3F,0xD,0x27,0x87,0xC0,0xF2,0xFF,0
  };

  BYTE coco_pal_ram[7*16];

	for (int c=0; c<7*16; c++)
	{
    // tutankhm colours
    pal[c].r = ((pal_ram[c] & (1<<0) ? 0x21 : 0x00) + 
    			      (pal_ram[c] & (1<<1) ? 0x47 : 0x00) +
    			      (pal_ram[c] & (1<<2) ? 0x97 : 0x00)) >> 2;
    pal[c].g = ((pal_ram[c] & (1<<3) ? 0x21 : 0x00) + 
    			      (pal_ram[c] & (1<<4) ? 0x47 : 0x00) +
    			      (pal_ram[c] & (1<<5) ? 0x97 : 0x00)) >> 2;
    pal[c].b = ((pal_ram[c] & (1<<6) ? 0x4f : 0x00) + 
    			      (pal_ram[c] & (1<<7) ? 0xa8 : 0x00)) >> 2;

    // convert original palette
    static int bit[] = { 0, 0x04, 0x20, 0, 0x02, 0x10, 0x01, 0x08 };
    coco_pal_ram[c] = 0;
    for (int i=0; i<8; i++)
      if (pal_ram[c] & (1<<i))
        coco_pal_ram[c] |= bit[i];
  
    fprintf (fppal, "%02X ", coco_pal_ram[c]);
    if (c%16 == 15) fprintf (fppal, "\n");

  /*
	return	(((color >> 4) & 2) | ((color >> 2) & 1)) * 0x550000
		|	(((color >> 3) & 2) | ((color >> 1) & 1)) * 0x005500
		|	(((color >> 2) & 2) | ((color >> 0) & 1)) * 0x000055;
  */

    // coco3 colours
    pal[c+128].r = ((((coco_pal_ram[c]>>4)&2)|((coco_pal_ram[c]>>2)&1)) * 0x55) >> 2;
    pal[c+128].g = ((((coco_pal_ram[c]>>3)&2)|((coco_pal_ram[c]>>1)&1)) * 0x55) >> 2;
    pal[c+128].b = ((((coco_pal_ram[c]>>2)&2)|((coco_pal_ram[c]>>0)&1)) * 0x55) >> 2;

  }
  pal[255].r = 0x3f; pal[255].g = 0x3f; pal[255].b = 0x3f;
  fclose (fppal);
  set_palette_range (pal, 0, 255, 1);
#endif

#ifdef SHOW_PALETTE

  clear_bitmap (screen);

  for (int t=0; t<7; t++)
  {
    for (int c=0; c<16; c++)
    {
      rectfill (screen, c*16, t*2*16, c*16+11, t*2*16+11, t*16+c);
      rectfill (screen, c*16, (t*2+1)*16, c*16+11, (t*2+1)*16+11, 128+t*16+c);
    }
  }

  while (!key[KEY_ESC]);
  while (key[KEY_ESC]);	  

#endif

#ifdef SHOW_TILES

  #define TILE_HEIGHT   8
  #define TILE_WIDTH    8

  while (1)
  {
    unsigned char tile_rom[2048];
  
    clear_bitmap (screen);
  
    char buf[32];
    sprintf (buf, "coco3gen.bin");
    fp = fopen (buf, "rb");
    if (!fp) break;
    fread (tile_rom, 1, 2048, fp);
    fclose (fp);
  
    clear_bitmap (screen);
  
    for (int j=0; j<2048/(TILE_HEIGHT*TILE_WIDTH/8)/2; j++)
    {
      for (int y=0; y<TILE_HEIGHT; y++)
        for (int x=0; x<TILE_WIDTH; x++)
        {
          unsigned char d = tile_rom[j*TILE_HEIGHT*TILE_WIDTH/8*2+y];

          putpixel (screen, j%16*10+7-x, j/16*10+y, (d&(1<<x) ? 1 : 0));
        }
    }
  
    while (!key[KEY_ESC]);
    while (key[KEY_ESC]);	  

    break;
  }

#endif

  allegro_exit ();
}

END_OF_MAIN();

