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

extern void knight_lore (GFX_E gfx_);
extern uint8_t *flip_sprite (POBJ32 p_obj);

static unsigned mask_colour = 0;

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

void osd_set_palette (uint8_t attr)
{
  // could support CPC here
  fprintf (stderr, "%s(%d)\n", __FUNCTION__, attr);
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t attr, uint8_t code)
{
  unsigned l, b;

  if (gfx == GFX_CPC && IS_ROOM_ATTR(attr))
    attr = 8+(attr&3)*4+3;
  else
    attr &= 7;
      
  for (l=0; l<8; l++)
  {
    uint8_t d = gfxbase_8x8[code*8+l];
    if (d == (uint8_t)-1)
      break;
    
    for (b=0; b<8; b++)
    {
      putpixel (scrn_buf, x+b, 191-y+l, (d&(1<<7)?attr:0));
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

  // references p_obj
  psprite = flip_sprite (p_obj);

  uint8_t w = *(psprite++) & 0x3f;
  uint8_t h = *(psprite++);
  uint8_t f;

  if (gfx == GFX_CPC)
    f = *(psprite++);
    
  unsigned x, y, b;
  
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      if (gfx == GFX_ZX)
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
      else
      {
        // assume GFX_CPC
        uint8_t d = *(psprite++);
        for (b=0; b<4; b++)
        {
          unsigned c = ((d&0x80)>>6)|((d&0x08)>>3);
          if (c != 0)
          {
            if (f == 1)
              c += 2;
            else if (c == 3)
              c = 0;
            putpixel (scrn_buf, p_obj->pixel_x+x*4+b, 191-(p_obj->pixel_y+y), 
                      8+(attr&3)*4+c);
          }
          d <<= 1;
        }
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

// for debugging only
void osd_print_border (void)
{
}

// for debugging only
void osd_display_panel (uint8_t attr)
{
}

void osd_debug_hook (void *context)
{
#if 1
  static unsigned count = 0;
  
  unsigned state = (unsigned)context;
  
  unsigned c, t, l, b;
  unsigned x, y;

  return;
  
  switch (state)
  {
#if 1
    case 0 :
	    clear_bitmap (scrn_buf);
	    return;
      break;

    case 1 :
      //mask_colour = 12;
      return;
      break;
      
    case 2 :
      //mask_colour = 0;
      // attempt to mark out the panel data
      //for (x=0; x<256; x++)
      //  putpixel (scrn_buf, x, 128, 2);
      osd_update_screen ();
#if 0      
      line (screen, 160, 191, 160, 187, 2);
      floodfill (screen, 240, 180, 2);      
      floodfill (screen, 180, 180, 2);      
      floodfill (screen, 210, 190, 2);      
#endif      
      while (!key[KEY_ESC]);
      while (key[KEY_ESC]);
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
            fprintf (fpPanel, "0x%02X, ", data&3);
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
#endif      

    default :
      return;
      break;
  }
  
  while (!osd_key (KEY_ESC));
  while (osd_key (KEY_ESC));
#endif  
}

void show_title (void)
{
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
}

void usage (char *argv0)
{
  printf ("usage: kl {-cpc|-zx}\n");
  printf ("  -cpc    use Amstrad CPC graphics\n");
  printf ("  -zx     use ZX Spectrum graphics\n");
  exit (0);
}

static void make_zx_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  *r = (c&(1<<1) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
  *g = (c&(1<<2) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
  *b = (c&(1<<0) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
}

static void make_cpc_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  uint8_t lu[] = { 0, 128, 255 };
  
  *r = lu[(c/3) % 3];
  *g = lu[(c/9) % 3];
  *b = lu[c % 3];
}

void main (int argc, char *argv[])
{
  GFX_E gfx = GFX_ZX;
  int c;

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '-' :
      case '/' :
        if (!stricmp (&argv[argc][1], "cpc"))
          gfx = GFX_CPC;
        else if (!stricmp (&argv[argc][1], "zx"))
          gfx = GFX_ZX;
        else
          usage (argv[0]);
        break;
      default :
        usage (argv[0]);
        break;
    }
  }
    
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 256, 192, 0, 0);

  scrn_buf = create_bitmap (256, 192);
  
  PALETTE pal;
  
  // spectrum palette
  for (c=0; c<8; c++)
  {
    uint8_t r, g, b;
    
    make_zx_colour (8+c, &r, &g, &b);
    pal[0+c].r = r>>2;
    pal[0+c].g = g>>2;
    pal[0+c].b = b>>2;
  }
	//set_palette_range (pal, 0, 0+8-1, 1);

  if (gfx == GFX_ZX)
  {
    for (c=0; c<8; c++)
    {
      uint8_t r, g, b;
      
      make_zx_colour (8+c, &r, &g, &b);
      pal[8+c].r = r>>2;
      pal[8+c].g = g>>2;
      pal[8+c].b = b>>2;
    }
	  //set_palette_range (pal, 8, 8+8-1, 1);
  }
  else
  if (gfx == GFX_CPC)
  {
    const uint8_t room_pal[][4] =
    {    
      // orange, yellow, white
      { 0, 15, 24, 26 },
      // green, cyan, magenta
      { 0, 18, 20, 8 },
      // blue, cyan, yellow
      { 0, 2, 20, 24 },
      // red, yellow, white
      { 0, 6, 24, 26 }
    };
    
    for (c=0; c<4*4; c++)
    {
      uint8_t r, g, b;
      
      make_cpc_colour (room_pal[c/4][c%4], &r, &g, &b);
      pal[8+c].r = r>>2;
      pal[8+c].g = g>>2;
      pal[8+c].b = b>>2;
    }
	  //set_palette_range (pal, 8, 8+16-1, 1);
  }

  set_palette_range (pal, 0, 8+16-1, 1);
  
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
  show_title ();
#endif //BUILD_OPT_DISABLE_LOADER

	clear_bitmap (scrn_buf);
	clear_bitmap (screen);
  knight_lore (gfx);

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
