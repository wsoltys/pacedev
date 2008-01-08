#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALLEGRO_USE_CONSOLE
#include <allegro.h>

//#define SHOW_PALETTE
#define SHOW_FONT
//#define SHOW_TILES

#define SET_NAME        "tutankhm"
#define MEM_NAME		    "tutdump.BIN"
#define ROM1_NAME		    "h1.bin"
// Banked graphics ROMS          
#define ROM5_NAME		    "j1.bin"
                        
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

	// read cpu memory dump	
	fp = fopen (SUBDIR MEM_NAME, "rb");
	if (!fp) exit (0);
	fread (mem, 64*1024, 1, fp);
	fclose (fp);

  // write vram
  fp = fopen (SUBDIR "vram.bin", "wb");
  fwrite (&mem[VRAM_BASE], 0x8000, 1, fp);
  fclose (fp);

	allegro_init ();
	install_keyboard ();
  
	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

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

  //FILE *fpDebug = fopen("debug.txt","wt");
  int c, x, y;

  // rotate the font data
  BYTE FontData[0x1000];
  memset (FontData, 0, 0x1000);
  for (c=0; c<0x1000/32; c++)
  {
    for (y=0; y<8; y++)
      for (x=0; x<8/2; x++)
      {
        BYTE b = mem[0xF000+32*c+y*4+x];
        int dest;

        if (c > 42 && c != 45)
        {
          dest = 32*c+y*4+x;
          //FontData[dest] = b;
        }
        else
        {
          dest = 32*c+(7-2*x)*4+y/2;
          if ((y&1) == 1)
          {
            FontData[dest] |= ((b<<4)&0xF0);
            FontData[dest-4] |= b&0xF0;
            //fprintf (fpDebug, "0: %d($%02X) -> %d($%02X),%d($%02X)\n", 
            //          32*c+y*4+x, b, dest-4, FontData[dest-4], dest, FontData[dest]);
          }
          else
          {
            FontData[dest] |= (b&0x0F);
            FontData[dest-4] |= ((b>>4)&0x0F);
            //fprintf (fpDebug, "1: %d($%02X) -> %d($%02X),%d($%02X)\n", 
            //          32*c+y*4+x, b, dest-4, FontData[dest-4], dest, FontData[dest]);
          }
        }
      }
  }

  // copyright message $F5C0-$F8EF
  int dest = 0x05C0;
  for (x=0; x<102/2; x++)
  {
    for (y=0; y<16; y++)
    {
      int src = 0xF5C0+x*8+7-y;
      if ((y&1)==0)
      {
        FontData[dest] |= (mem[src]<<4) & 0xF0;
        FontData[dest] |= (mem[src+8]) & 0x0F;
      }
      else
      {
        FontData[dest] |= (mem[src]) & 0xF0;
        FontData[dest] |= (mem[src+8]>>4) & 0x0F;
      }
      dest++;
    }
  }

  //fclose (fpDebug);

  unsigned char preamble[6] = "\x00\x00\x00\x00\x00";
  unsigned char postamble[6] = "\xFF\x00\x00\x00\x00";

  // write font .BIN file
  FILE *fpBIN = fopen ("ROMF-R.BIN", "wb");

  // write pre-amble to load bank register
  preamble[1] = 0;
  preamble[2] = 1;
  preamble[3] = 0xFF;
  preamble[4] = 0xA2;             // bank for $4000
  fwrite (preamble, 1, 5, fp);
  unsigned char bank = 0x17;
  fwrite (&bank, 1, 1, fp);
      
  // write data block
  preamble[1] = 0x0E;
  preamble[2] = 0x40;             // $F000-$FE3F
  preamble[3] = 0x50;
  preamble[4] = 0x00;             // load at $5000
  fwrite (preamble, 1, 5, fp);
  fwrite (FontData, 1, 0x0E40, fp);

  // write pre-amble to restore bank register
  preamble[1] = 0;
  preamble[2] = 1;
  preamble[3] = 0xFF;
  preamble[4] = 0xA2;             // bank for $4000
  fwrite (preamble, 1, 5, fp);
  bank = 0x3A;
  fwrite (&bank, 1, 1, fp);

  fwrite (postamble, 1, 5, fp);

  fclose (fpBIN);

#ifdef SHOW_FONT

#define COLOUR_MASK     0x07
#define FONT_COLOUR(i)  ((i)&COLOUR_MASK)

  clear_bitmap (screen);

  // show some font data
  BYTE *pFontData = (BYTE *)FontData;
  for (int c=0; c<128; c++)
  {
    for (int l=0; l<8; l++)
    {
      unsigned char d;

      int x = (c%16)*16;
      int y = (c/16)*16;

      d = *pFontData++;
      putpixel (screen, x+l, y+7, FONT_COLOUR(d&0x0f));
      putpixel (screen, x+l, y+6, FONT_COLOUR((d>>4)&0x0f));
      d = *pFontData++;
      putpixel (screen, x+l, y+5, FONT_COLOUR(d&0x0f));
      putpixel (screen, x+l, y+4, FONT_COLOUR((d>>4)&0x0f));
      d = *pFontData++;
      putpixel (screen, x+l, y+3, FONT_COLOUR(d&0x0f));
      putpixel (screen, x+l, y+2, FONT_COLOUR((d>>4)&0x0f));
      d = *pFontData++;
      putpixel (screen, x+l, y+1, FONT_COLOUR(d&0x0f));
      putpixel (screen, x+l, y+0, FONT_COLOUR((d>>4)&0x0f));
    }
  }

  while (!key[KEY_ESC]);
  while (key[KEY_ESC]);	  

#endif

#ifdef SHOW_TILES

  #define TILE_HEIGHT   16
  #define TILE_WIDTH    16

  unsigned char tile_rom[4096];

  clear_bitmap (screen);

  // show some tile data
  for (int i=1; i<=9; i++)
  {
    char buf[32];
    sprintf (buf, "j%d.bin", i);
    FILE *fp = fopen (buf, "rb");
    if (!fp) continue;
    fread (tile_rom, 1, 4096, fp);
    fclose (fp);

    clear_bitmap (screen);

    for (int j=0; j<4096/(TILE_HEIGHT*TILE_WIDTH/2); j++)
    {
      for (int y=0; y<TILE_HEIGHT; y++)
        for (int x=0; x<TILE_WIDTH/2; x++)
        {
          putpixel (screen, j%8*20+y, j/8*20+15-x*2, tile_rom[j*TILE_HEIGHT*TILE_WIDTH/2+y*TILE_WIDTH/2+x] >> 4);
          putpixel (screen, j%8*20+y, j/8*20+15-x*2+1, tile_rom[j*TILE_HEIGHT*TILE_WIDTH/2+y*TILE_WIDTH/2+x] & 0x0F);
        }
    }

    while (!key[KEY_ESC]);
    while (key[KEY_ESC]);	  
  }

#endif

#ifdef SHOW_BITMAP

  clear_bitmap (screen);

	for (int y=0; y<HEIGHT_PIXELS; y++)
	{
		for (int x=0; x<WIDTH_PIXELS; x++)
		{
      int addr = x*(256/2)+(HEIGHT_PIXELS-y)/2;
      int pel = mem[addr];

      if ((y&1)==1) pel >>= 4;
      pel &= 0x0F;

  		putpixel (screen, x, y, pel);
		}
	}

  while (!key[KEY_ESC]);
  while (key[KEY_ESC]);	  

#endif

  allegro_exit ();
}

END_OF_MAIN();

