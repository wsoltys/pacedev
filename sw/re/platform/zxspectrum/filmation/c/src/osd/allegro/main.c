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

#define BUILD_OPT_DISABLE_LOADER
//#define BUILD_OPT_DISABLE_MASK

static BITMAP *scrn_buf;

extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

static uint8_t osd_room_attr = 7; // white
static unsigned mask_colour = 0;

void osd_room_attrib (uint8_t attr)
{
  // save it for sprites
  osd_room_attr = attr;
}

void osd_delay (unsigned ms)
{
  rest (ms);
}

void osd_clear_scrn (void)
{
	clear_bitmap (screen);
}

void osd_clear_scrn_buffer (void)
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

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t attr, uint8_t code)
{
  unsigned l, b;
  
  for (l=0; l<8; l++)
  {
    uint8_t d = gfxbase_8x8[code*8+l];
    if (d == (uint8_t)-1)
      break;
    
    for (b=0; b<8; b++)
    {
      putpixel (scrn_buf, x+b, 191-y+l, (d&(1<<7)?(attr&7):0));
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
        x, 191-(y+height_lines-1), 
        x, 191-(y+height_lines-1), 
        width_bytes<<3, height_lines);
}

void osd_print_sprite (uint8_t attr, POBJ32 p_obj)
{
  uint8_t *psprite;

  attr &= 7;
    
  //DBGPRINTF("(%d,%d)\n", p_obj->x, p_obj->y);

  // this is needed to create panel font
  //if (type != MENU_STATIC && type != PANEL_STATIC)
  //  return;

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
#ifndef BUILD_OPT_DISABLE_MASK
        if (m & (1<<7))
          putpixel (scrn_buf, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y), mask_colour);
#endif
        if (d & (1<<7))
          putpixel (scrn_buf, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y), attr);
        m <<= 1;
        d <<= 1;
      }
    }
  }
}

#if 0
static void grab_fix_tile (BITMAP *bm, int x, int y, FILE *fp)
{
  unsigned l, b;
  
  fprintf (fp, "  { ");
  for (l=0; l<8; l++)
  {
    uint8_t data = 0;
    for (b=0; b<8; b++)
    {
      data <<= 1;
      data |= (getpixel (bm, x+b, y+l) ? 1 : 0);
    }
    fprintf (fp, "0x%02X, ", data);
  }
  fprintf (fp, "},\n");
}
#endif

void osd_debug_hook (void *context)
{
#if 0
  static unsigned count = 0;
  
  unsigned state = (unsigned)context;
  
  unsigned c, t, l, b;
  unsigned x, y;

  switch (state)
  {
#if 0
    case 0 :
	    clear_bitmap (scrn_buf);
	    return;
      break;

    case 1 :
      mask_colour = 2;
      return;
      break;
      
    case 2 :
      mask_colour = 0;
      // attempt to mark out the panel data
      //for (x=0; x<256; x++)
      //  putpixel (scrn_buf, x, 128, 2);
      osd_update_screen ();
      line (screen, 160, 191, 160, 187, 2);
      floodfill (screen, 240, 180, 2);      
      floodfill (screen, 180, 180, 2);      
      floodfill (screen, 210, 190, 2);      
      // now extract data for panel font
      FILE *fpPanel = fopen ("panel_font.c", "wt");
      fprintf (fpPanel, "uint8_t panel_font[][8] = \n{\n");
      for (c=0; c<256; c++)
      {
        unsigned x = (c%32)*8;
        unsigned y = (c/32)*8;
        
        for (l=0; l<8; l++)
        {
          uint8_t data = 0;
          fprintf (fpPanel, "  { ");
          for (b=0; b<8; b++)
          {
            data = getpixel (screen, x+b, 128+y+l);
            fprintf (fpPanel, "0x%02X, ", data);
          }
          fprintf (fpPanel, "},\n");
        }
        fprintf (fpPanel, "\n");
      }
      fprintf (fpPanel, "};\n\n");
      fclose (fpPanel);
      break;
#endif      
#if 0
    case 10 :
      if (count) 
        return;
      count++;
      osd_update_screen ();
      FILE *fpBorder = fopen ("border_font.c", "wt");
      fprintf (fpBorder, "uint8_t border_font[][8] = \n{\n");
      // 4 corners
      for (c=0; c<4; c++)
      {
        static uint8_t cx[] = { 0, 32-4, 0, 32-4 };
        static uint8_t cy[] = { 0, 0, 24-4, 24-4 };

        for (t=0; t<16; t++)
        {
          grab_fix_tile (screen, (cx[c]+(t/4))*8, (cy[c]+(t%4))*8, fpBorder);
        }
      }
      // now top, then side
      for (t=0; t<4; t++)
        grab_fix_tile (screen, 32, t*8, fpBorder);
      for (t=0; t<4; t++)
        grab_fix_tile (screen, t*8, 32, fpBorder);
      fprintf (fpBorder, "};\n");
      fclose (fpBorder);
      break;
#endif      
    case 20 :
      {
        // now extract data for title font
        FILE *fpTitle = fopen ("title_font.c", "wt");
        fprintf (fpTitle, "uint8_t title_font[][8] = \n{\n");
        for (c=0; c<672; c++)
        {
          unsigned x = (c%32)*8;
          unsigned y = (c/32)*8;
          
          for (l=0; l<8; l++)
          {
            uint8_t data = 0;
            fprintf (fpTitle, "  { ");
            for (b=0; b<8; b++)
            {
              data = getpixel (screen, x+b, y+l);
              fprintf (fpTitle, "0x%02X, ", data);
            }
            fprintf (fpTitle, "},\n");
          }
          fprintf (fpTitle, "\n");
        }
        fprintf (fpTitle, "};\n\n");
        fclose (fpTitle);
      }
      break;

    default :
      return;
      break;
  }
  
  while (!osd_key (KEY_ESC));
  while (osd_key (KEY_ESC));
#endif  
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

#ifndef BUILD_OPT_DISABLE_LOADER
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
    osd_debug_hook ((void *)20);
    while (!keypressed ());
  }
#endif //BUILD_OPT_DISABLE_LOADER

	clear_bitmap (scrn_buf);
	clear_bitmap (screen);
  knight_lore ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
