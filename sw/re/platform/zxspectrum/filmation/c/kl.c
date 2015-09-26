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
//          g++ kl.cpp -o kl -lallegro-4.4.2-md

#include "kldat.c"

uint8_t from_ascii (char ch)
{
  const char *chrset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
  for (uint8_t i=0; chrset[i]; i++)
    if (chrset[i] == ch)
      return (i);
      
    return ((uint8_t)-1);
}

// start of variables
typedef struct
{
  uint8_t index;
  uint8_t flags;
  uint8_t x;
  uint8_t y;

} SPRITE_SCRATCHPAD_T, *PSPRITE_SCRATCHPAD_T;
static SPRITE_SCRATCHPAD_T sprite_scratchpad;

// start of prototypes

static void print_text (uint8_t x, uint8_t y, char *str);
static void do_menu_selection (void);
static void flash_menu (void);
static void display_menu (void);
static void display_text_list (uint8_t *xy, char *text_list[], uint8_t n);
static void multiple_print_sprite (uint8_t dx, uint8_t dy, uint8_t n);
static uint8_t *transfer_sprite (uint8_t *psprite);
static uint8_t *transfer_sprite_and_print (uint8_t *psprite);
static void print_border (void);
static void clear_scrn (void);
static void clr_screen_buffer (void);
static uint8_t *flip_sprite (void);
static void print_sprite (void);

// end of prototypes

void print_text_single_colour (uint8_t x, uint8_t y, char *str)
{
  print_text (x, y, str);
}

void print_text_std_font (uint8_t x, uint8_t y, char *str)
{
  print_text (x, y, str);
}

void print_text (uint8_t x, uint8_t y, char *str)
{
  for (unsigned c=0; *str; c++)
  {
    uint8_t ascii = (uint8_t)*(str++);
    uint8_t code = from_ascii (ascii);
    
    for (unsigned l=0; l<8; l++)
    {
      uint8_t d = kl_font[code][l];
      if (d == (uint8_t)-1)
        break;
      
      for (unsigned b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (screen, x+c*8+b, y+l, 15);
        d <<= 1;
      }
    }  
  }
}

uint8_t lives;

void knight_lore (void)
{
START_AF6C:

MAIN_AF88:

  lives = 5;

  clear_scrn ();
  do_menu_selection ();
}

// $BD0C
void do_menu_selection (void)
{
  clr_screen_buffer ();
  display_menu ();
  flash_menu ();
menu_loop:
  display_menu ();
  flash_menu ();
  //goto menu_loop;
}

// $BD89
void flash_menu (void)
{
}

// $BEB3
void display_menu (void)
{
  display_text_list (menu_xy, (char **)menu_text, 8);
  print_border ();
}

// $BEBF
void display_text_list (uint8_t *xy, char *text_list[], uint8_t n)
{
  for (unsigned i=0; i<n; i++, xy+=2)
    print_text_single_colour (*xy, 191-*(xy+1), text_list[i]);
}

// $BEE4
void multiple_print_sprite (uint8_t dx, uint8_t dy, uint8_t n)
{
  for (unsigned i=0; i<n; i++)
  {
    print_sprite ();
    sprite_scratchpad.x += dx;
    sprite_scratchpad.y += dy;
  }
}

// $D237
uint8_t *transfer_sprite (uint8_t *psprite)
{
  sprite_scratchpad.index = *(psprite++);
  sprite_scratchpad.flags = *(psprite++);
  sprite_scratchpad.x = *(psprite++);
  sprite_scratchpad.y = *(psprite++);

  return (psprite);
}

// $D24C
uint8_t *transfer_sprite_and_print (uint8_t *psprite)
{
  uint8_t *p = transfer_sprite (psprite);
  print_sprite ();

  return (p);
}

// $D296
void print_border (void)
{
  uint8_t *p = (uint8_t *)border_data;
  p = transfer_sprite_and_print (p);
  p = transfer_sprite_and_print (p);
  p = transfer_sprite_and_print (p);
  p = transfer_sprite_and_print (p);
  p = transfer_sprite (p);
  multiple_print_sprite (8, 0, 24);
  p = transfer_sprite (p);
  multiple_print_sprite (8, 0, 24);
  p = transfer_sprite (p);
  multiple_print_sprite (0, 1, 128);
  p = transfer_sprite (p);
  multiple_print_sprite (0, 1, 128);
}

// $D55F
void clear_scrn (void)
{
	clear_bitmap (screen);
}

// $D567
void clr_screen_buffer (void)
{
}

#define REV(d) (((d&1)<<7)|((d&2)<<5)|((d&4)<<3)|((d&8)<<1)|((d&16)>>1)|((d&32)>>3)|((d&64)>>5)|((d&128)>>7))
//#define REV(d) d

// $D6EF
uint8_t *flip_sprite (void)
{
  uint8_t *psprite = sprite_tbl[sprite_scratchpad.index];
  
  uint8_t vflip = (sprite_scratchpad.flags ^ (*psprite)) & 0x80;
  uint8_t hflip = (sprite_scratchpad.flags ^ (*psprite)) & 0x40;

  uint8_t w = psprite[0] & 0x3f;
  uint8_t h = psprite[1];

  if (vflip)
  {
    for (unsigned x=0; x<w; x++)
      for (unsigned y=0; y<h/2; y++)
      {
        uint8_t t = psprite[3+2*(y*w+x)];
        psprite[3+2*(y*w+x)] = psprite[3+2*((h-1-y)*w+x)];
        psprite[3+2*((h-1-y)*w+x)] = t;
      }
    *psprite ^= 0x80;
  }

  if (hflip)
  {
    for (unsigned y=0; y<h; y++)
      for (unsigned x=0; x<w/2; x++)
      {
        uint8_t t = psprite[3+2*(y*w+x)];
        psprite[3+2*(y*w+x)] = REV(psprite[3+2*(y*w+w-1-x)]);
        psprite[3+2*(y*w+w-1-x)] = REV(t);
      }
    *psprite ^= 0x40;
  }

  return (psprite);
}

// $D718
void print_sprite (void)
{
  uint8_t *psprite;

  // references sprite_scratchpad
  psprite = flip_sprite ();

  uint8_t w = *(psprite++) & 0x3f;
  uint8_t h = *(psprite++);

  for (unsigned y=0; y<h; y++)
  {
    for (unsigned x=0; x<w; x++)
    {
      // skip mask
      psprite++;

      uint8_t d = *(psprite++);
      for (unsigned b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (screen, sprite_scratchpad.x+x*8+b, sprite_scratchpad.y+y, 15);
        d <<= 1;
      }
    }
  }
}

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 256, 192, 0, 0);

  // spectrum palette
  PALETTE pal;
  for (int c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 15, 1);

	clear_bitmap (screen);
  knight_lore ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
