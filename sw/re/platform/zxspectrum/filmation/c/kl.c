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

uint8_t seed_1;
uint8_t lives;
uint8_t *gfxbase_8x8;

typedef struct
{
  uint8_t index;
  uint8_t flags;
  uint8_t x;
  uint8_t y;

} SPRITE_SCRATCHPAD_T, *PSPRITE_SCRATCHPAD_T;
static SPRITE_SCRATCHPAD_T sprite_scratchpad;

// end of variables

// start of prototypes

static void play_audio_wait_key (uint8_t *audio_data);
static void play_audio (uint8_t *audio_data);
static void shuffle_objects_required (void);
static uint8_t read_key (uint8_t row);
static void display_day (void);
static void do_menu_selection (void);
static void flash_menu (void);
static void print_text_single_colour (uint8_t x, uint8_t y, char *str);
static void print_text_std_font (uint8_t x, uint8_t y, char *str);
static void print_text_raw (uint8_t x, uint8_t y, uint8_t *str);
static void print_text (uint8_t x, uint8_t y, char *str);
static void display_menu (void);
static void display_text_list (uint8_t *clours, uint8_t *xy, char *text_list[], uint8_t n);
static void multiple_print_sprite (uint8_t dx, uint8_t dy, uint8_t n);
static void init_start_location (void);
static uint8_t *transfer_sprite (uint8_t *psprite);
static uint8_t *transfer_sprite_and_print (uint8_t *psprite);
static void display_panel (void);
static void print_border (void);
static void clear_scrn (void);
static void clr_screen_buffer (void);
static uint8_t *flip_sprite (void);
static void print_sprite (void);

// end of prototypes

void knight_lore (void)
{
START_AF6C:

MAIN_AF88:

  lives = 5;

  clear_scrn ();
  do_menu_selection ();
  play_audio (start_game_tune);
  shuffle_objects_required ();
  init_start_location ();
  //init_sun ();
  //init_objects ();
  //lose_life ();
  //update_objects ();

  // *** REMOVE ME
	clear_bitmap (screen);

game_loop:
  
  //display_objects ();
  //colour_panel ();
  //colour_sun_moon ();
  display_panel ();
  //display_frame ();
  display_day ();
  //print_days ();
  //print_lives_gfx ();
  //print_lives ();
  //update_screen ();

  //goto game_loop;
  ;
}

// $B2B6
void play_audio_wait_key (uint8_t *audio_data)
{
  // check somethin here
  while (1)
  {
    if (read_key (0))
      return;
    // keep playing audio
  }
}

// $B2CF
void play_audio (uint8_t *audio_data)
{
}

// $B544
void shuffle_objects_required (void)
{
}

// $B5F7
uint8_t read_key (uint8_t row)
{
  int8_t val = 0;

  switch (row)
  {
    case 0 :
      return (keypressed ());
      break;
    case 0xEF :
      // 6,7,8,9,0
      if (key[KEY_0]) val |= (1<<0);
      if (key[KEY_9]) val |= (1<<1);
      if (key[KEY_8]) val |= (1<<2);
      if (key[KEY_7]) val |= (1<<3);
      if (key[KEY_6]) val |= (1<<4);
      break;
    case 0xF7 :
      // 5,4,3,2,1
      if (key[KEY_1]) val |= (1<<0);
      if (key[KEY_2]) val |= (1<<1);
      if (key[KEY_3]) val |= (1<<2);
      if (key[KEY_4]) val |= (1<<3);
      if (key[KEY_5]) val |= (1<<4);
    default :
      break;
  }
  return (val);
}

// $BCCA
void display_day (void)
{
  // stick attribute at front
  gfxbase_8x8 = (uint8_t *)days_font;
  // fudge to skip attribute for now
  print_text_raw (114, 15, (days_txt+1));
}

// $BD0C
void do_menu_selection (void)
{
  uint8_t key;

  clr_screen_buffer ();
  display_menu ();
  flash_menu ();
menu_loop:
  display_menu ();
  play_audio_wait_key (menu_tune);
  // 5,4,3,2,1
  key = read_key (0xF7);
  // do input method stuff here
  // 6,7,8,9,0
  key = read_key (0xEF);
  // start game?
  if (key & (1<<0))
    return;
  seed_1++;
  flash_menu ();
  goto menu_loop;
}

// $BD89
void flash_menu (void)
{
}

// $BE31
void print_text_single_colour (uint8_t x, uint8_t y, char *str)
{
  gfxbase_8x8 = (uint8_t *)kl_font;
  print_text (x, y, str);
}

// $BE45
void print_text_std_font (uint8_t x, uint8_t y, char *str)
{
  gfxbase_8x8 = (uint8_t *)kl_font;
  print_text (x, y, str);
}

void print_text_raw (uint8_t x, uint8_t y, uint8_t *str)
{
  for (unsigned c=0; ; c++, str++)
  {
    uint8_t code = *str & 0x7f;

    for (unsigned l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      
      for (unsigned b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (screen, x+c*8+b, 191-y+l, 15);
        d <<= 1;
      }
    }  
    if (*str & (1<<7))
      break;
  }
}

// $BE4C
void print_text (uint8_t x, uint8_t y, char *str)
{
  for (unsigned c=0; *str; c++)
  {
    uint8_t ascii = (uint8_t)*(str++);
    uint8_t code = from_ascii (ascii);
    
    for (unsigned l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      if (d == (uint8_t)-1)
        break;
      
      for (unsigned b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (screen, x+c*8+b, 191-y+l, 15);
        d <<= 1;
      }
    }  
  }
}

// $BEB3
void display_menu (void)
{
  display_text_list (menu_colours, menu_xy, (char **)menu_text, 8);
  print_border ();
}

// $BEBF
void display_text_list (uint8_t *colours, uint8_t *xy, char *text_list[], uint8_t n)
{
  for (unsigned i=0; i<n; i++, xy+=2)
    print_text_single_colour (*xy, *(xy+1), text_list[i]);
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

// $D1B1
void init_start_location (void)
{
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

// $D255
void display_panel (void)
{
  uint8_t *p = (uint8_t *)panel_data;
  p = transfer_sprite (p);
  multiple_print_sprite (16, (uint8_t)-8, 5);
  p = transfer_sprite_and_print (p);
  p = transfer_sprite_and_print (p);
  p = transfer_sprite (p);
  multiple_print_sprite (16, 8, 5);
  p = transfer_sprite_and_print (p);
  p = transfer_sprite_and_print (p);
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
          putpixel (screen, sprite_scratchpad.x+x*8+b, 191-(sprite_scratchpad.y+y), 15);
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
