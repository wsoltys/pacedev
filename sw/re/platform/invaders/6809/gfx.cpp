#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#define __USE_ALLEGRO__

#ifdef __USE_ALLEGRO__
#include <allegro.h>
#endif

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

// pandora: run msys.bat and cd to this directory
//          g++ kl.cpp -o kl -lallegro-4.4.2-md

// neogeo:  d:\mingw_something\setenv.bat
//          g++ gfx.cpp -o xgf -lalleg

//#define SHOW_ORIGINAL_BITMAP
#define SHOW_ROTATED_BITMAP

uint8_t ram[64*1024];
FILE *fpdbg;

#ifdef __USE_ALLEGRO__

void show_original_bitmap()
{
  // $2400-$3FFF ($1C00) / (256/8) = $E0 = 224
	clear_bitmap (screen);

  for (unsigned y=0; y<224; y++)
  {
    for (unsigned x=0; x<256/8; x++)
    {
      uint8_t d = ram[0x2400+y*(256/8)+x];
      
      for (unsigned b=0; b<8; b++)
      {
        if (d&(1<<7))
          putpixel (screen, x*8+(7-b), y, 15);
        d <<= 1;
      }
    }
  }

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
}

uint8_t get_rotated_pixel(unsigned x, unsigned y)
{
  uint8_t d = ram[0x2400+x*(256/8)+(255-y)/8];
  
  return (d&(1<<(7-(y&7))) ? 1 : 0);
}

void show_rotated_bitmap()
{
  // $2400-$3FFF ($1C00) / (256/8) = $E0 = 224
	clear_bitmap (screen);

  for (unsigned y=0; y<256; y++)
  {
    for (unsigned x=0; x<224; x++)
      if (get_rotated_pixel (x,y))
        putpixel (screen, x, y, 15);
  }

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  #define TOP 32
  //line (screen, 0, TOP, 223, TOP, 2);
  //line (screen, 0, TOP+223, 223, TOP+223, 2);

#if 0
  for (unsigned r=0; r<4; r++)
    for (unsigned c=0; c<224/8; c++)
    {
      for (unsigned y=0; y<8; y++)
        for (unsigned x=0; x<8; x++)
        {
          if (get_rotated_pixel (c*8+x, r*8+y))
            putpixel (screen, 224+r*8+x, c*8+y, 15);
        }
    }
#endif

  #define SCORES_Y    96

  for (unsigned m=0; m<3; m++)
  {  
    for (unsigned r=0; r<4; r++)
      for (unsigned c=0; c<10; c++)
        for (unsigned y=0; y<8; y++)
          for (unsigned x=0; x<8; x++)
          {
            if (get_rotated_pixel ((9*m+c)*8+x, r*8+y))
              putpixel (screen, 224+8+c*8+x, SCORES_Y+m*48+r*8+y, 15);
          }
  }

  #define WIDTH 8
  
  // create some data for the Coco3
  FILE *fp2 = fopen ("vram_dat.asm", "wt");
  for (unsigned y=0; y<224; y++)
    for (unsigned x=0; x<320/8; x++)
    {
      uint8_t d=0;
      for (unsigned b=0; b<8; b++)
      {
        d <<= 1;
        if (getpixel (screen, x*8+b, y))
          d |= (1<<0);
      }
      if ((x%WIDTH)==0)
        fprintf (fp2, "    .db ");
      fprintf (fp2, "0x%02X", d);
      if ((x%WIDTH)==(WIDTH-1))
        fprintf (fp2, "\n");
      else
        fprintf (fp2, ", ");
    }
  fclose (fp2);
    
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
}

#endif

int main (int argc, char *argv[])
{
  fpdbg = fopen ("debug.txt", "wt");

  FILE        *fp = fopen ("invaders.bin", "rb");
	struct stat	fs;
	int					fd;
  if (!fp)
    exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (ram, sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);
  
#ifdef __USE_ALLEGRO__
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 320, 256, 0, 0);

  PALETTE pal;
  for (int c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 7, 1);
	
	#ifdef SHOW_ORIGINAL_BITMAP
	  show_original_bitmap ();
	#endif
	#ifdef SHOW_ROTATED_BITMAP
    show_rotated_bitmap();
	#endif
	
#endif

  fclose (fpdbg);
  
#ifdef __USE_ALLEGRO__
  allegro_exit ();
#endif
}

#ifdef __USE_ALLEGRO__
END_OF_MAIN();
#endif
