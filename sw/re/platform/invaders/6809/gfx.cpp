#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

//#define __USE_ALLEGRO__

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
//#define SHOW_ROTATED_BITMAP
#define DO_ASM_DATA

uint8_t ram[64*1024];
FILE *fpdbg;

#define REV(d) \
 (((d&0x80)>>7)|((d&0x40)>>5)|((d&0x20)>>3)|((d&0x10)>>1)| \
 ((d&8)<<1)|((d&4)<<3)|((d&2)<<5)|((d&1)<<7))

FILE  *fp1;

unsigned do_n_bytes (char *label, unsigned a, unsigned n)
{
  fprintf (fp1, "; $%04X\n", a);
  if (label)
    fprintf (fp1, "%s:\n", label);
  for (unsigned b=0; b<n; b++)
  {
    uint8_t d = ram[a++];
    if ((b%8) == 0)
      fprintf (fp1, "        .db ");
    d = REV(d);
    fprintf (fp1, "0x%02X", d);
    if ((b%8)!=7 && b<(n-1)) fprintf (fp1, ", ");
    else
      fprintf (fp1, "\n");
  }
  fprintf (fp1, "\n");
  return (a);
}

void do_asm_data (void)
{
  fp1 = fopen ("si_dat.asm", "wt");
  static char ascii[] = 
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<> =*Ý      Y     Y ?      -";

  do_n_bytes (NULL, 0x1ba0, 16);
  do_n_bytes (NULL, 0x1bd0, 16);
    
  unsigned a = 0x1c00;
  for (unsigned c=0; c<9; c++)
    a = do_n_bytes (NULL, a, 16);
  fprintf (fp1, "\n");

  do_n_bytes ("alien_explode", 0x1cc0, 16);


  a = 0x1c90;
  a = do_n_bytes ("player_shot_spr", a, 1);
  a = do_n_bytes ("shot_exploding", a, 8);

  a = 0x1cd0;
  for (unsigned i=0; i<4; i++)
    a = do_n_bytes (NULL, a, 3);

  do_n_bytes (NULL, 0x1cdc, 6);

  a = 0x1ce2;
  for (unsigned i=0; i<4; i++)
    a = do_n_bytes (NULL, a, 3);

  a = 0x1cee;
  for (unsigned i=0; i<4; i++)
    a = do_n_bytes (NULL, a, 3);

  do_n_bytes (NULL, 0x1d20, 44);

  do_n_bytes (NULL, 0x1d68, 16);
  fprintf (fp1, "\n");
        
  a = 0x1e00;
  for (unsigned c=0; c<0x40; c++)
  {
    fprintf (fp1, "        .db ");
    for (unsigned b=0; b<8; b++)
    {
      uint8_t d = ram[a++];
      d = REV(d);
      fprintf (fp1, "0x%02X", d);
      if (b<7) fprintf (fp1, ", ");
    }
    fprintf (fp1, "  ; \"%c\"\n", ascii[c]);
  }

  fclose (fp1);
}

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

uint8_t get_rotated_pixel_ex (unsigned base, unsigned x, unsigned y)
{
  uint8_t d = ram[base+x*(256/8)+(255-y)/8];
  
  return (d&(1<<(7-(y&7))) ? 1 : 0);
}

uint8_t get_rotated_pixel (unsigned x, unsigned y)
{
  return (get_rotated_pixel_ex (0x2400, x, y));
}

void show_rotated_bitmap()
{
  uint8_t coco_vram[320*224/8];
  
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

  // add some letters
  uint8_t title[][16] = 
  { 
    { " SPACE  " }, 
    { "INVADERS" }
  };
  
  for (unsigned l=0; l<2; l++)
    for (unsigned c=0; title[l][c]; c++)
    {
      //fprintf (stderr, "%c\n", title[l][c]);
      unsigned a = 0x1E00 + (title[l][c] - 'A') * 8;
      
      if (title[l][c] == ' ')
        continue;
        
      for (unsigned y=0; y<8; y++)
        for (unsigned b=0; b<8; b++)
        {
          uint8_t d = ram[a+b];
          if (d & (1<<(7-y)))
            putpixel (screen, 224+16+c*8+b, 48+l*16+y, 15);
        }
    }

  #define WIDTH 8
  
  // create some data for the Coco3
  FILE *fp2 = fopen ("vram_dat.asm", "wt");
  unsigned a = 0;
  for (unsigned y=0; y<224; y++)
    for (unsigned x=0; x<320/8; x++)
    {
      uint8_t d=0;
      for (unsigned b=0; b<8; b++)
      {
        d <<= 1;
        if (getpixel (screen, x*8+b, 32+y))
          d |= (1<<0);
      }
      coco_vram[a++] = d;
      
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

	clear_bitmap (screen);

  a = 0;
  for (unsigned y=0; y<224; y++)
    for (unsigned x=0; x<320/8; x++)
    {
      uint8_t d = coco_vram[a++];
      for (unsigned b=0; b<8; b++)
        if (d & (1<<(7-b)))
          putpixel (screen, x*8+b, y, 15);      
    }
    
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

  #ifdef DO_ASM_DATA
    do_asm_data ();
  #endif
    
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
