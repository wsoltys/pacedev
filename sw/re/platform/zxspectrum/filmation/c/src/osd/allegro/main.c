#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

// pandora: run msys.bat and cd to this directory
//          g++ kl.c -o kl -lallegro-4.4.2-md

// neogeo:  d:\mingw_something\setenv.bat
//          g++ kl.c -o kl -lalleg

#include "kl_osd.h"
#include "kl_dat.h"

#define ENABLE_MASK

static BITMAP *scrn_buf;

extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

void osd_delay (unsigned ms)
{
  rest (ms);
}

void osd_clear_scrn (void)
{
	clear_bitmap (screen);
}

void osd_clr_screen_buffer (void)
{
  clear_bitmap (scrn_buf);
}

int osd_readkey (void)
{
  return (readkey ());
}

int osd_key (int _key)
{
  return (key[_key]);
}

int osd_keypressed (void)
{
  return (keypressed ());
}

void osd_print_text_raw (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t *str)
{
  unsigned c, l, b;
  
  for (c=0; ; c++, str++)
  {
    uint8_t code = *str & 0x7f;

    for (l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      
      for (b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (scrn_buf, x+c*8+b, 191-y+l, 15);
        d <<= 1;
      }
    }  
    if (*str & (1<<7))
      break;
  }
}

static uint8_t from_ascii (char ch)
{
  const char *chrset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
  uint8_t i;
  
  for (i=0; chrset[i]; i++)
    if (chrset[i] == ch)
      return (i);
      
    return ((uint8_t)-1);
}

void osd_print_text (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, char *str)
{
  unsigned c, l, b;
  
  for (c=0; *str; c++)
  {
    uint8_t ascii = (uint8_t)*(str++);
    uint8_t code = from_ascii (ascii);
    
    for (l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      if (d == (uint8_t)-1)
        break;
      
      for (b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (scrn_buf, x+c*8+b, 191-y+l, 15);
        d <<= 1;
      }
    }  
  }
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t code)
{
  unsigned l, b;
  
  for (l=0; l<8; l++)
  {
    uint8_t d = gfxbase_8x8[code*8+l];
    if (d == (uint8_t)-1)
      break;
    
    for (b=0; b<8; b++)
    {
      putpixel (scrn_buf, x+b, 191-y+l, (d&(1<<7)?15:0));
      d <<= 1;
    }
  }  
  return (x+8);
}

void osd_fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c)
{
  //DBGPRINTF ("%s(%d,%d-%dx%d,%d):\n", __FUNCTION__,
  //            x, y, width_bytes<<3, height_lines, c);
  
  rectfill (scrn_buf, x, 191-y, 
            x + (width_bytes<<3) - 1, 
            191 - (y + height_lines - 1), 
            c);
}

void osd_update_screen (void)
{
  blit (scrn_buf, screen, 0, 0, 0, 0, 256, 192);
  clear_bitmap (scrn_buf);
}

void osd_blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines)
{
  blit (scrn_buf, screen, 
        x, 192-(y+height_lines), 
        x, 192-(y+height_lines), 
        width_bytes<<3, height_lines);
}

void osd_print_sprite (POBJ32 p_obj)
{
  uint8_t *psprite;

  //DBGPRINTF("(%d,%d)\n", p_obj->x, p_obj->y);

  // references p_obj
  psprite = flip_sprite (p_obj);

  uint8_t w = *(psprite++) & 0x3f;
  uint8_t h = *(psprite++);

  unsigned x, y, b;
  
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      uint8_t m = *(psprite++);
      uint8_t d = *(psprite++);
      for (b=0; b<8; b++)
      {
#ifdef ENABLE_MASK
        if (m & (1<<7))
          putpixel (scrn_buf, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y), 0);
#endif
        if (d & (1<<7))
          putpixel (scrn_buf, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y), 15);
        m <<= 1;
        d <<= 1;
      }
    }
  }
}

void main (int argc, char *argv[])
{
  int c;
  
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 256, 192, 0, 0);

  scrn_buf = create_bitmap (256, 192);
  
  // spectrum palette
  PALETTE pal;
  for (c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 15, 1);

#if 0
	clear_bitmap (screen);
	unsigned x, y;
  for (y=0; y<192; y++)
    for (x=0; x<256; x++)
    {
	    c = x/128*8+y/(192/8);
      putpixel (screen, x, y, c);
    }
  while (!keypressed ());
#endif

	clear_bitmap (screen);
  FILE *fp = fopen ("src/kl/kl.scr", "rb");
  if (fp)
  {
    unsigned line, byte, bit;
    
    for (line=0; line<192; line++)
    {
      uint8_t l = (line&0xC0) | ((line&0x07) << 3) | ((line &0x38)>>3);
      
      for (byte=0; byte<32; byte++)
      {
        uint8_t data;
        
        fread (&data, 1, 1, fp);
        for (bit=0; bit<8; bit++)
        {
          if (data & (1<<7))
            putpixel (screen, byte*8+bit, l, 15);
          data <<= 1;
        }
      }
    }
    
    // now colour it
    for (line=0; line<192; line+=8)
    {
      //uint8_t line2 = (line&0xC0) | ((line&0x07) << 3) | ((line &0x38)>>3);
      uint8_t line2 = line;

      for (byte=0; byte<32; byte++)
      {
        uint8_t data, l, bright;
        
        fread (&data, 1, 1, fp);
        bright = (data>>3) & 0x08;
        for (l=0; l<8; l++)
        {
          for (bit=0; bit<8; bit++)
            if (getpixel (screen, byte*8+bit, line2+l) != 0)
              putpixel (screen, byte*8+bit, line2+l, bright|(data&0x07));
            else
              putpixel (screen, byte*8+bit, line2+l, bright|((data>>3)&0x07));
        }
      }
    }
    
    fclose (fp);
    while (!keypressed ());
  }

	clear_bitmap (scrn_buf);
	clear_bitmap (screen);
  knight_lore ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
