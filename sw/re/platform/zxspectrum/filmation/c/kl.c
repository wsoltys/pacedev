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

typedef struct
{
  // object size = 32 bytes
  uint8_t   graphic_no;
  uint8_t   filler1[6];
  uint8_t   flags;

} OBJ8, *POBJ8;

typedef struct
{
  uint8_t   graphic_no;
  uint8_t   start_x;
  uint8_t   start_y;
  uint8_t   start_z;
  uint8_t   start_scrn;
  uint8_t   curr_x;
  uint8_t   curr_y;
  uint8_t   curr_z;
  uint8_t   curr_scrn;

} OBJ9, *POBJ9;

typedef struct
{
  uint8_t   graphic_no;
  uint8_t   x;
  uint8_t   y;
  uint8_t   z;
  uint8_t   zzz1;
  uint8_t   zzz2;
  uint8_t   zzz3;
  uint8_t   flags;
  uint8_t   scrn;
  uint8_t   pad1[7];
  // original a pointer, now an index
  uint16_t  ptr_obj_tbl_entry;
  uint8_t   pad2[14];

} OBJ32, *POBJ32;

typedef struct
{
  uint8_t index;
  uint8_t flags;
  uint8_t x;
  uint8_t y;

} SPRITE_SCRATCHPAD, *PSPRITE_SCRATCHPAD;

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

static uint8_t seed_1;                                // $5BA0
static uint8_t days;                                  // $5BB9
static uint8_t lives;                                 // $5BBA
static uint8_t *gfxbase_8x8;                          // $5BC7
static uint8_t objects_carried[3][4];                 // $5BDC
static OBJ32 graphics_object_tbl[40];                 // $5C08
static OBJ32 *objs_here = &graphics_object_tbl[2];    // $5C48
static SPRITE_SCRATCHPAD sprite_scratchpad;           // $BFDB
static SPRITE_SCRATCHPAD sun_moon_scratchpad;         // $C44D
static uint8_t objects_to_draw[48];                   // $CE8B
static uint8_t start_loc_1;                           // $D169
static uint8_t start_loc_2;                           // $D189

// end of variables

// start of prototypes

static void play_audio_wait_key (uint8_t *audio_data);
static void play_audio (uint8_t *audio_data);
static void shuffle_objects_required (void);
static uint8_t read_key (uint8_t row);
static void print_days (void);
static void print_lives_gfx (void);
static void print_lives (void);
static void print_bcd_number (uint8_t x, uint8_t y, uint8_t *bcd, uint8_t n);
static void display_day (void);
static void do_menu_selection (void);
static void flash_menu (void);
static void print_text_single_colour (uint8_t x, uint8_t y, char *str);
static void print_text_std_font (uint8_t x, uint8_t y, char *str);
static void print_text_raw (uint8_t x, uint8_t y, uint8_t *str);
static void print_text (uint8_t x, uint8_t y, char *str);
static uint8_t print_8x8 (uint8_t x, uint8_t y, uint8_t code);
static void display_menu (void);
static void display_text_list (uint8_t *clours, uint8_t *xy, char *text_list[], uint8_t n);
static void multiple_print_sprite (PSPRITE_SCRATCHPAD scratchpad, uint8_t dx, uint8_t dy, uint8_t n);
static void display_objects (void);
static void display_sun_moon_frame (PSPRITE_SCRATCHPAD scratchpad);
static void init_sun (void);
static void init_objects (void);
static void find_objects_here (void);
static void find_objs_in_location (void);
static void list_objects_to_draw (void);
static void init_start_location (void);
static void build_screen_objects (void);
static uint8_t *transfer_sprite (PSPRITE_SCRATCHPAD scratchpad, uint8_t *psprite);
static uint8_t *transfer_sprite_and_print (PSPRITE_SCRATCHPAD scratchpad, uint8_t *psprite);
static void display_panel (void);
static void retrieve_screen (void);
static void print_border (void);
static void clear_scrn (void);
static void clr_screen_buffer (void);
static uint8_t *flip_sprite (PSPRITE_SCRATCHPAD scratchpad);
static void print_sprite (PSPRITE_SCRATCHPAD scratchpad);

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
  init_sun ();
  init_objects ();

player_dies:
  //lose_life ();

game_loop:
  build_screen_objects ();

  // *** REMOVE ME
	clear_bitmap (screen);

onscreen_loop:

  list_objects_to_draw ();
  //render_dynamic_objects ();
  
  display_objects ();
  //colour_panel ();
  //colour_sun_moon ();
  display_panel ();
  display_sun_moon_frame (&sun_moon_scratchpad);
  display_day ();
  print_days ();
  print_lives_gfx ();
  print_lives ();
  //update_screen ();

  if (key[KEY_ESC])
    return;

  goto onscreen_loop;
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

// $BC66
void print_days (void)
{
  print_bcd_number (122, 7, &days, 1);
}

// $BC7A
void print_lives_gfx (void)
{
  sprite_scratchpad.index = 0x8c;
  sprite_scratchpad.flags = 0;
  sprite_scratchpad.x = 16;
  sprite_scratchpad.y = 32;
  print_sprite (&sprite_scratchpad);
  // fill_de ();
  // fill_de ();
}

// $BCA3
void print_lives (void)
{
  print_bcd_number (32, 39, &lives, 1);
}

// $BCAE
void print_bcd_number (uint8_t x, uint8_t y, uint8_t *bcd, uint8_t n)
{
  gfxbase_8x8 = (uint8_t *)kl_font;
  for (unsigned i=0; i<n; i++, bcd++)
  {
    uint8_t code = (*bcd) >> 4;
    x = print_8x8 (x, y, code);
    code = (*bcd) & 0x0f;
    x = print_8x8 (x, y, code);
  }
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

// $BE4C
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

// $BE7F
uint8_t print_8x8 (uint8_t x, uint8_t y, uint8_t code)
{
  for (unsigned l=0; l<8; l++)
  {
    uint8_t d = gfxbase_8x8[code*8+l];
    if (d == (uint8_t)-1)
      break;
    
    for (unsigned b=0; b<8; b++)
    {
      if (d & (1<<7))
        putpixel (screen, x+b, 191-y+l, 15);
      d <<= 1;
    }
  }  
  return (x+8);
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
void multiple_print_sprite (PSPRITE_SCRATCHPAD scratchpad, uint8_t dx, uint8_t dy, uint8_t n)
{
  for (unsigned i=0; i<n; i++)
  {
    print_sprite (scratchpad);
    scratchpad->x += dx;
    scratchpad->y += dy;
  }
}

// $BF4E
void display_objects (void)
{
  objects_carried[0][0] = 0x60;
  objects_carried[1][0] = 0x61;
  objects_carried[2][0] = 0x62;
  
  for (unsigned i=0; i<3; i++)
  {
    uint8_t x = ((255-(3-i))+3)*24+16  +24;
    
    sprite_scratchpad.x = x;
    sprite_scratchpad.y = 0;

    if (objects_carried[i][0] != 0)
    {
      sprite_scratchpad.index = objects_carried[i][0];
      print_sprite (&sprite_scratchpad);
    }
  }
}

// $C3A4
void display_sun_moon_frame (PSPRITE_SCRATCHPAD scratchpad)
{
  uint8_t x;

  // check a byte

  if (scratchpad->x == 225)
    goto toggle_day_night;

  // adjust Y coordinate
  x = scratchpad->x + 16;
  scratchpad->y = sun_moon_yoff[(x>>2)&0x0f];
  print_sprite (scratchpad);

display_frame:
  sprite_scratchpad.index = 0x5a;
  sprite_scratchpad.flags = 0;
  sprite_scratchpad.x = 184;
  sprite_scratchpad.y = 0;
  print_sprite (&sprite_scratchpad);
  sprite_scratchpad.x = 208;
  sprite_scratchpad.index = 0xba;
  print_sprite (&sprite_scratchpad);
  // wipe something
  return;

toggle_day_night:
  scratchpad->index ^= 1;
  //colour_sun_moon ();
  scratchpad->x = 176;
  // if just changed to moon, exit
  if (scratchpad->index & 1)
    return;

inc_days:
  // BCD arithmetic
  days++;
  if ((days & 0x0f) == 10)
    days += 6;
  if (days == 64)
    //game_over ();
    ;
  print_days ();
  // something
  goto display_frame;  
}

// $C46D
void init_sun (void)
{
  sun_moon_scratchpad.index = 0x58;
  sun_moon_scratchpad.x = 176;
  sun_moon_scratchpad.y = 9;
}

// $C47E
#define NUM_OBJS (sizeof(object_tbl)/sizeof(OBJ9))
void init_objects (void)
{
  uint8_t r = seed_1;
  r += rand() & 255;
  for (unsigned i=0; i<NUM_OBJS; i++)
  {
    object_tbl[i].graphic_no = (r & 7) | 0x60;
    object_tbl[i].curr_x = object_tbl[i].start_x;
    object_tbl[i].curr_y = object_tbl[i].start_y;
    object_tbl[i].curr_z = object_tbl[i].start_z;
    object_tbl[i].curr_scrn = object_tbl[i].start_scrn;
    r++;
  }
}

// $C525
void find_objs_in_location (void)
{
}

// $C591
void find_objects_here (void)
{
  for (unsigned i=0; i<2; i++)
  {
    if (objs_here[i].graphic_no != 0)
    {
      // set data in object table
      uint8_t index = objs_here[i].ptr_obj_tbl_entry;
      object_tbl[index].graphic_no = objs_here[i].graphic_no;
      object_tbl[index].curr_x = objs_here[i].x;
      object_tbl[index].curr_y = objs_here[i].y;
      object_tbl[index].curr_z = objs_here[i].z;
      object_tbl[index].curr_scrn = objs_here[i].scrn;
    }
  }
}

// $CE62
void list_objects_to_draw (void)
{
  unsigned n = 0;

  for (unsigned i=0; i<40; i++)
  {
    if ((graphics_object_tbl[i].graphic_no != 0) &&
        (graphics_object_tbl[i].flags & (1<<4)))
      objects_to_draw[n++] = i;
  }
  objects_to_draw[n] = 0xff;
}

// $D1B1
void init_start_location (void)
{
  // stuff
  uint8_t s = start_locations[seed_1 & 3];

  start_loc_1 = s;
  start_loc_2 = s;
}

// $D1E6
void build_screen_objects (void)
{
  find_objects_here ();
  clr_screen_buffer ();
  retrieve_screen ();
  find_objs_in_location ();
}

// $D237
uint8_t *transfer_sprite (PSPRITE_SCRATCHPAD scratchpad, uint8_t *psprite)
{
  scratchpad->index = *(psprite++);
  scratchpad->flags = *(psprite++);
  scratchpad->x = *(psprite++);
  scratchpad->y = *(psprite++);

  return (psprite);
}

// $D24C
uint8_t *transfer_sprite_and_print (PSPRITE_SCRATCHPAD scratchpad, uint8_t *psprite)
{
  uint8_t *p = transfer_sprite (scratchpad, psprite);
  print_sprite (scratchpad);

  return (p);
}

// $D255
void display_panel (void)
{
  uint8_t *p = (uint8_t *)panel_data;
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (&sprite_scratchpad, 16, (uint8_t)-8, 5);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (&sprite_scratchpad, 16, 8, 5);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
}

// $D296
void print_border (void)
{
  uint8_t *p = (uint8_t *)border_data;
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite_and_print (&sprite_scratchpad, p);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (&sprite_scratchpad, 8, 0, 24);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (&sprite_scratchpad, 8, 0, 24);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (&sprite_scratchpad, 0, 1, 128);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (&sprite_scratchpad, 0, 1, 128);
}

// $D3C6
void retrieve_screen (void)
{
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
uint8_t *flip_sprite (PSPRITE_SCRATCHPAD scratchpad)
{
  uint8_t *psprite = sprite_tbl[scratchpad->index];
  
  uint8_t vflip = (scratchpad->flags ^ (*psprite)) & 0x80;
  uint8_t hflip = (scratchpad->flags ^ (*psprite)) & 0x40;

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
void print_sprite (PSPRITE_SCRATCHPAD scratchpad)
{
  uint8_t *psprite;

  // references sprite_scratchpad
  psprite = flip_sprite (scratchpad);

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
          putpixel (screen, scratchpad->x+x*8+b, 191-(scratchpad->y+y), 15);
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
