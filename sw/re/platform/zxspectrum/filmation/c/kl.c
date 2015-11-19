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

#pragma pack(1)

typedef struct
{
  uint8_t   x;
  uint8_t   y;
  uint8_t   z;
  
} ROOM_SIZE_T, *PROOM_SIZE_T;
  
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
  uint8_t   width;
  uint8_t   depth;
  uint8_t   height;
  uint8_t   flags;
  uint8_t   scrn;
  uint8_t   pad1[7];
  // original a pointer, now an index
  uint16_t  ptr_obj_tbl_entry;
  uint8_t   pad2[6];
  uint8_t   off24;
  uint8_t   off25;
  uint8_t   off26;
  uint8_t   off27;
  uint8_t   off28;
  uint8_t   off29;
  uint8_t   off30;
  uint8_t   off31;

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
static uint16_t seed_2;                               // $5BA2
static uint8_t seed_3;                                // $5BA5
static uint8_t room_size_X;                           // $5BAB
static uint8_t room_size_Y;                           // $5BAC
static uint8_t curr_room_attrib;                      // $5BAD
static uint8_t room_size_Z;                           // $5BAE
static uint8_t days;                                  // $5BB9
static uint8_t lives;                                 // $5BBA
static uint8_t *gfxbase_8x8;                          // $5BC7
static uint8_t objects_carried[3][4];                 // $5BDC
static OBJ32 graphic_objs_tbl[40];                    // $5C08
static OBJ32 *special_objs_here = 
              &graphic_objs_tbl[2];                   // $5C48
static OBJ32 *other_objs_here =
              &graphic_objs_tbl[4];                   // $5C88
static SPRITE_SCRATCHPAD sprite_scratchpad;           // $BFDB
static SPRITE_SCRATCHPAD sun_moon_scratchpad;         // $C44D
static uint8_t objects_to_draw[48];                   // $CE8B
static OBJ32 plyr_spr_1_scratchpad;                   // $D161
static OBJ32 plyr_spr_2_scratchpad;                   // $D181

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
static void init_special_objects (void);
static void update_special_objs (void);
static void find_special_objs_here (void);
static void save_sprite_somethings (POBJ32 p_obj);
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
static void render_dynamic_objects (void);
static uint8_t *flip_sprite (PSPRITE_SCRATCHPAD scratchpad);
static void print_sprite (PSPRITE_SCRATCHPAD scratchpad);

// end of prototypes

void dump_graphic_objs_tbl (void)
{
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (unsigned i=0; i<40; i++)
  {
    fprintf (stderr, "%02d: graphic_no=%02d, x=%d, y=%d, z=%d, width=%d, depth=%d, height=%d, flags=$%02X\n",
              i,
              graphic_objs_tbl[i].graphic_no,
              graphic_objs_tbl[i].x,
              graphic_objs_tbl[i].y,
              graphic_objs_tbl[i].z,
              graphic_objs_tbl[i].width,
              graphic_objs_tbl[i].depth,
              graphic_objs_tbl[i].height,
              graphic_objs_tbl[i].flags);
  }
}

void knight_lore (void)
{
START_AF6C:

MAIN_AF88:

  lives = 5;

  clear_scrn ();
  do_menu_selection ();
  play_audio (start_game_tune);
  // randomise order of required objects
  shuffle_objects_required ();
  // randomise player start location
  init_start_location ();
  init_sun ();
  // randomise special object locations
  init_special_objects ();

player_dies:
  //lose_life ();

game_loop:
  // populate graphic_objs_tbl[]
  build_screen_objects ();

  // *** REMOVE ME
	clear_bitmap (screen);

onscreen_loop:

  POBJ32 p_obj = graphic_objs_tbl;
  for (unsigned i=0; i<40; i++, p_obj++)
  {
    adj_sprite_loop:
      
    save_sprite_somethings (p_obj);

    //p_obj->graphic_no;
    // *** call per-sprite routine
        
    // update seed_3
    uint8_t r = rand ();
    seed_3 += r;
  }

  // update seed_2, 3
  seed_2++;
  // this was originally [HL] where HL=seed2
  seed_3 += rand ();
  seed_3 += seed_2;           // add a,l
  seed_3 += (seed_2 >> 8);    // add a,h

  // some other stuff
    
  // populate objects_to_draw[]
  list_objects_to_draw ();
  render_dynamic_objects ();
  
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
// places special objects into fixed list of rooms
// - starting object is random
#define NUM_OBJS (sizeof(special_objs_here)/sizeof(OBJ9))
void init_special_objects (void)
{
  uint8_t r = seed_1;
  r += rand() & 255;
  for (unsigned i=0; i<NUM_OBJS; i++)
  {
    // special objects $60-$67
    // diamond, poison, boot, chalice, cup, bottle, crystal ball, extra life
    special_objs_tbl[i].graphic_no = (r & 7) | 0x60;
    special_objs_tbl[i].curr_x = special_objs_tbl[i].start_x;
    special_objs_tbl[i].curr_y = special_objs_tbl[i].start_y;
    special_objs_tbl[i].curr_z = special_objs_tbl[i].start_z;
    special_objs_tbl[i].curr_scrn = special_objs_tbl[i].start_scrn;
    r++;
  }
}

// $C525
void find_special_objs_here (void)
{
  POBJ32 p_special_obj = special_objs_here;
  uint8_t n_special_objs_here = 0;
 
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (unsigned i=0; i<32; i++)
  {
    if (special_objs_tbl[i].graphic_no == 0)
      continue;
    if (special_objs_tbl[i].curr_scrn != plyr_spr_1_scratchpad.scrn)
      continue;
      
    p_special_obj->graphic_no = special_objs_tbl[i].graphic_no;
    p_special_obj->x = special_objs_tbl[i].curr_x;
    p_special_obj->y = special_objs_tbl[i].curr_y;
    p_special_obj->z = special_objs_tbl[i].curr_z;
    p_special_obj->width = 5;
    p_special_obj->depth = 5;
    p_special_obj->height = 20;
    p_special_obj->flags = 0x14;
    p_special_obj->scrn = special_objs_tbl[i].curr_scrn;
    memset (&p_special_obj->pad1, 0, 7);
    p_special_obj->ptr_obj_tbl_entry = i;
    memset (&p_special_obj->pad2, 0, 14);
    
    n_special_objs_here++;
  }

  fprintf (stderr, "  n_special_objs_here=%d\n", n_special_objs_here);

  // wipe rest of the special_objs_here table  
  for (; n_special_objs_here<2; n_special_objs_here++)
  {
    memset (p_special_obj, 0, 32);
    p_special_obj++;
  }
}

// $C591
// updates special_objs_tbl with current data (coords etc)
// - traverses special_objs_here table
// - writes to special_objs_tbl

void update_special_objs (void)
{
  for (unsigned i=0; i<2; i++)
  {
    if (special_objs_here[i].graphic_no != 0)
    {
      // set data in object table
      uint8_t index = special_objs_here[i].ptr_obj_tbl_entry;
      special_objs_tbl[index].graphic_no = special_objs_here[i].graphic_no;
      special_objs_tbl[index].curr_x = special_objs_here[i].x;
      special_objs_tbl[index].curr_y = special_objs_here[i].y;
      special_objs_tbl[index].curr_z = special_objs_here[i].z;
      special_objs_tbl[index].curr_scrn = special_objs_here[i].scrn;
    }
  }
}

// $CE49
void save_sprite_somethings (POBJ32 p_obj)
{
  p_obj->off28 = p_obj->off24;
  p_obj->off29 = p_obj->off25;
  p_obj->off30 = p_obj->off26;
  p_obj->off31 = p_obj->off27;
}

// $CE62
void list_objects_to_draw (void)
{
  unsigned n = 0;

  //fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (unsigned i=0; i<40; i++)
  {
    if ((graphic_objs_tbl[i].graphic_no != 0) &&
        (graphic_objs_tbl[i].flags & (1<<4)))
      objects_to_draw[n++] = i;
  }
  objects_to_draw[n] = 0xff;
  
  //fprintf (stderr, "  n=%d\n", n);
}

// $D1B1
void init_start_location (void)
{
  memcpy ((uint8_t *)&plyr_spr_1_scratchpad, plyr_spr_init_data+0, 8);
  memcpy ((uint8_t *)&plyr_spr_2_scratchpad, plyr_spr_init_data+8, 8);
  plyr_spr_1_scratchpad.pad1[1] = 0x12;
  plyr_spr_2_scratchpad.pad1[1] = 0x22;
  uint8_t s = start_locations[seed_1 & 3];
  // start_loc_1
  plyr_spr_1_scratchpad.scrn = s;
  // start_loc_2
  plyr_spr_2_scratchpad.scrn = s;
  
  fprintf (stderr, "%s(): start_location=%d\n", __FUNCTION__, s);
}

// $D1E6
void build_screen_objects (void)
{
  // save state in special_objs_tbl
  update_special_objs ();
  clr_screen_buffer ();
  retrieve_screen ();
  // find special objects in new room
  find_special_objs_here ();
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
  POBJ32 p_other_objs = other_objs_here;
  unsigned p = 0;
  
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (unsigned i=0; ; i++)
  {
    if (location_tbl[p] == plyr_spr_1_scratchpad.scrn)
      break;
    if (i == 255)
    {
      // bad_player_location
      // - can't really happen with 255 locations
      exit (-1);
    }
    p += 1 + location_tbl[p+1];
  }
  
found_screen:
  //fprintf (stderr, "%s(): location=%d\n", __FUNCTION__, location_tbl[p]);
  
  uint8_t id = location_tbl[p++];
  uint8_t size = location_tbl[p++];
  uint8_t attr = location_tbl[p++];

  fprintf (stderr, "id=%d, size=%d, attr=$%02X\n", id, size, attr);
  
  // get attribute, set BRIGHT  
  curr_room_attrib = (attr & 7) | 0x40;

  uint8_t room_size = (attr >> 3) & 0x1F;
  room_size_X = room_size_tbl[room_size].x;
  room_size_Y = room_size_tbl[room_size].y;
  room_size_Z = room_size_tbl[room_size].z;

  fprintf (stderr, "room size = (%d,%d,%d)\n",
            room_size_X, room_size_Y, room_size_Z);

  // bytes remaining in location table
  size -= 2;
  
  // do the background objects
  for (; size && location_tbl[p] != 0xFF; size--, p++)
  {
    next_bg_obj:
    
    // get background type
    uint8_t *p_bg_obj = background_type_tbl[location_tbl[p]];

    fprintf (stderr, "BG:%d\n", location_tbl[p]);

    for (; *p_bg_obj != 0; p_bg_obj+=8)
    {    
      next_bj_obj_sprite:
        
      // copy sprite,x,y,z,w,d,h,flags
      memcpy ((uint8_t *)p_other_objs, p_bg_obj, 8);
      // set screen (location)
      p_other_objs->scrn = plyr_spr_1_scratchpad.scrn;
      // zero everything else
      memset (&p_other_objs->pad1, 0, 23);
      
      p_other_objs++;
    };
  }

  // skip 0xFF
  if (size)
    size--;
      
  // do the foreground objects
  for (; size; )
  {
    uint8_t count = (location_tbl[p] & 7) + 1;
    uint8_t block = location_tbl[p] >> 3;
    uint8_t loc = location_tbl[p+1];
    size--;
    p += 2;
        
    for (; count; count--)
    {
      uint8_t *p_fg_obj = block_type_tbl[block];

      for (; p_fg_obj[0]!=0; p_fg_obj+=8)
      {
        p_other_objs->graphic_no = p_fg_obj[0];
        p_other_objs->width = p_fg_obj[1];
        p_other_objs->depth = p_fg_obj[2];
        p_other_objs->height = p_fg_obj[3];
        p_other_objs->flags = p_fg_obj[4];
        p_other_objs->scrn = plyr_spr_1_scratchpad.scrn;
        // more copying here, including offsets
        //??? = p_fg_obj[5];
        
        // zero everything else        
        memset (&p_other_objs->pad1, 0, 23);
        
        p_other_objs++;
      }
    }
  }
  
  fprintf (stderr, "n_other_objs = %d\n",
            p_other_objs - other_objs_here);
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

// $D59F 
void render_dynamic_objects (void)
{
  for (unsigned i=0; objects_to_draw[i] != 0xFF; i++)
  {
    POBJ32 p_obj = &graphic_objs_tbl[objects_to_draw[i]];
    
    #if 0
    // check ??? flag
    if ((p_obj->flags & (1<<5)) == 0)
      continue;
    p_obj->flags &= ~(1<<5);
    #endif
              
    // fudge - just render the bloody thing!
    transfer_sprite_and_print (&sprite_scratchpad, (uint8_t *)p_obj);
  }
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
