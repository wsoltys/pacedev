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

#define ENABLE_MASK

// byte offset 7 flags
#define FLAG_VFLIP  (1<<7)
#define FLAG_HFLIP  (1<<6)
#define FLAG_WIPE   (1<<5)
#define FLAG_DRAW   (1<<4)

// byte offset 12 flags
#define FLAG_Z_OOB  (1<<2)
#define FLAG_Y_OOB  (1<<1)
#define FLAG_X_OOB  (1<<0)

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
  int8_t    d_x;
  int8_t    d_y;
  int8_t    d_z;
  uint8_t   flags12;
  uint8_t   flags13;
  uint8_t   off14;
  uint8_t   off15;
  // originally a pointer, now an index
  uint16_t  ptr_obj_tbl_entry;
  int8_t    pixel_x_adj;
  int8_t    pixel_y_adj;
  uint8_t   pad2[4];
  uint8_t   data_width_bytes;
  uint8_t   data_height_lines;
  uint8_t   pixel_x;
  uint8_t   pixel_y;
  // used for wiping the sprite
  uint8_t   old_data_width_bytes;
  uint8_t   old_data_height_lines;
  uint8_t   old_pixel_x;
  uint8_t   old_pixel_y;

} OBJ32, SPRITE_SCRATCHPAD, *POBJ32, *PSPRITE_SCRATCHPAD;

typedef void (*adjfn_t)(POBJ32 p_obj);

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

// cleared each game
static uint8_t objs_wiped_cnt;                        // $5BA8
static uint8_t room_size_X;                           // $5BAB
static uint8_t room_size_Y;                           // $5BAC
static uint8_t curr_room_attrib;                      // $5BAD
static uint8_t room_size_Z;                           // $5BAE
static uint8_t portcullis_moving;                     // $5BAF
static uint8_t portcullis_move_cnt;                   // $5BB0
static uint8_t initial_rendering;                     // $5BB7
static uint8_t days;                                  // $5BB9
static int8_t lives;                                  // $5BBA
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
static void upd_182_183 (POBJ32 p_obj);
static void upd_91 (POBJ32 p_obj);
static void upd_143 (POBJ32 p_obj);
static void upd_55 (POBJ32 p_obj);
static void upd_54 (POBJ32 p_obj);
static void upd_144_to_149_152_to_157 (POBJ32 p_obj);
static void upd_63 (POBJ32 p_obj);
static void upd_150_151 (POBJ32 p_obj);
static void upd_22 (POBJ32 p_obj);
static void upd_23 (POBJ32 p_obj);
static void upd_86_87 (POBJ32 p_obj);
static void upd_180_181 (POBJ32 p_obj);
static void upd_178_179 (POBJ32 p_obj);
static void upd_164_to_167 (POBJ32 p_obj);
static void upd_141 (POBJ32 p_obj);
static void upd_142 (POBJ32 p_obj);
static void upd_30_31_158_159 (POBJ32 p_obj);
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
static void upd_120_to_126 (POBJ32 p_obj);
static void upd_103 (POBJ32 p_obj);
static void upd_96_to_102 (POBJ32 p_obj);
static void no_adjust (POBJ32 p_obj);
static void display_sun_moon_frame (PSPRITE_SCRATCHPAD scratchpad);
static void init_sun (void);
static void init_special_objects (void);
static void upd_62 (POBJ32 p_obj);
static void upd_85 (POBJ32 p_obj);
static void upd_84 (POBJ32 p_obj);
static void upd_128_to_130 (POBJ32 p_obj);
static void upd_6_7 (POBJ32 p_obj);
static void upd_10 (POBJ32 p_obj);
static void upd_11 (POBJ32 p_obj);
static void upd_12_to_15 (POBJ32 p_obj);
static void sub_C4D8 (POBJ32 p_obj);
static void upd_m6_m12 (POBJ32 p_obj);
static void sub_C4FC (POBJ32 p_obj);
static void upd_88_to_90 (POBJ32 p_obj);
static void find_special_objs_here (void);
static void update_special_objs (void);
static void upd_80_to_83 (POBJ32 p_obj);
static void upd_8 (POBJ32 p_obj);
static void set_wipe_and_draw_flags (POBJ32 p_obj);
static void upd_9 (POBJ32 p_obj);
static void dec_dZ_and_update_XYZ (POBJ32 p_obj);
static void add_dXYZ (POBJ32 p_obj);
static void upd_3_5 (POBJ32 p_obj);
static void set_pixel_adj (POBJ32 p_obj, int8_t h, int8_t l);
static void upd_2_4 (POBJ32 p_obj);
static int8_t adj_dZ_for_out_of_bounds (POBJ32 p_obj, int8_t d_z);
static int8_t adj_d_for_out_of_bounds (int8_t d);
static void adj_for_out_of_bounds (POBJ32 p_obj);
static int8_t adj_dX_for_out_of_bounds (POBJ32 p_obj, int8_t d_x);
static int8_t adj_dY_for_out_of_bounds (POBJ32 p_obj, int8_t d_y);
static void save_2d_info (POBJ32 p_obj);
static void list_objects_to_draw (void);
static void calc_display_order_and_render (void);
static int lose_life (void);
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
static void loc_D653 (void);
static void calc_pixel_XY (POBJ32 p_obj);
static uint8_t *flip_sprite (PSPRITE_SCRATCHPAD scratchpad);
static void calc_pixel_XY_and_render (POBJ32 p_obj);
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

void dump_special_objs_tbl (void)
{
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (unsigned i=0; i<32; i++)
  {
    fprintf (stderr, "%02d: graphic_no=%02d, x=%d, y=%d, z=%d, start_scrn=$%02X\n",
              i,
              special_objs_tbl[i].graphic_no,
              special_objs_tbl[i].start_x,
              special_objs_tbl[i].start_y,
              special_objs_tbl[i].start_z,
              special_objs_tbl[i].start_scrn);
  }
}

void upd_not_implemented (POBJ32 obj)
{
  // place-holder

  static bool printed[256];
  static bool inited = false;
  
  if (!inited)
  {
    memset (printed, false, 256);
    inited = true;
  }
      
  if (!printed[obj->graphic_no])
  {
    fprintf (stderr, "%s(%d=$%02X) @$%04X\n",
              __FUNCTION__,
              obj->graphic_no, 
              obj->graphic_no,
              0xB096+2*obj->graphic_no);
    printed[obj->graphic_no] = true;
  }
}

void knight_lore (void)
{
START_AF6C:

MAIN_AF88:

  //build_lookup_tbls ();
  lives = 5;

  // update seed
  seed_1 += seed_2;
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
  lose_life ();

game_loop:
  // populate graphic_objs_tbl[]
  build_screen_objects ();

  // *** REMOVE ME
	clear_bitmap (screen);

onscreen_loop:

  POBJ32 p_obj = graphic_objs_tbl;
  
  for (unsigned i=0; i<40; i++, p_obj++)
  {
    update_sprite_loop:
      
    save_2d_info (p_obj);

    #ifndef arraylen
      #define arraylen(n) (sizeof(n) / sizeof((n)[0]))
    #endif
    extern adjfn_t upd_sprite_jump_tbl[];
    
    if (p_obj->graphic_no > 187)
      upd_not_implemented (p_obj);
    else
      upd_sprite_jump_tbl[p_obj->graphic_no] (p_obj);

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

  //init_cauldron_bubbles ();
  list_objects_to_draw ();
  render_dynamic_objects ();
  
game_delay:
  // last to-do  

  if (initial_rendering)
  {
    initial_rendering = 0;
    //fill_attr();
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
  }

  if (graphic_objs_tbl[0].graphic_no == 0 &&
      graphic_objs_tbl[1].graphic_no == 0)
    goto player_dies;

/////////////////////////////////
// start of development hook
/////////////////////////////////

  if (key[KEY_ESC])
    return;

  if (key[KEY_N])
  {
    graphic_objs_tbl[0].scrn += 16;
    goto exit_screen;
  }
  
  if (key[KEY_S])
  {
    graphic_objs_tbl[0].scrn -= 16;
    goto exit_screen;
  }
  
  if (key[KEY_E])
  {
    graphic_objs_tbl[0].scrn += 1;
    goto exit_screen;
  }
  
  if (key[KEY_W])
  {
    graphic_objs_tbl[0].scrn -= 1;
    goto exit_screen;
  }

  if (key[KEY_G])
  {
    uint8_t scrn = 0;
    
    while (keypressed ())
      readkey ();
    fprintf (stderr, "GOTO: ");
    for (unsigned i=0; i<3; i++)
    {
      int c;
      do
      {
        c = readkey () & 0xff;
      } while (!isdigit(c));
      
      fprintf (stderr, "%c", c);
      scrn = (scrn * 10) + c - '0';
    }
    fprintf (stderr, "\n");
    graphic_objs_tbl[0].scrn = scrn;
    goto exit_screen;
  }

  if (key[KEY_P])
  {
    static unsigned s_no = 0;
    
    fprintf (stderr, "s_no=%d, start_scrn=%d\n", 
              s_no, special_objs_tbl[s_no].start_scrn);
    graphic_objs_tbl[0].scrn = special_objs_tbl[s_no].start_scrn;
    s_no = (s_no + 1) % 32;
    goto exit_screen;
  }
    
  if (key[KEY_D])
  {
    dump_graphic_objs_tbl ();
  }

/////////////////////////////////
// end of development hook
/////////////////////////////////
    
  goto onscreen_loop;

// *** THIS IS A FUDGE  
exit_screen:
  graphic_objs_tbl[1].scrn = graphic_objs_tbl[0].scrn;
  memcpy (&plyr_spr_1_scratchpad, &graphic_objs_tbl[0], sizeof(POBJ32));
  memcpy (&plyr_spr_2_scratchpad, &graphic_objs_tbl[1], sizeof(POBJ32));
  goto game_loop;
  
}

// $B096
adjfn_t upd_sprite_jump_tbl[] =
{
  no_adjust,                    // (unused)
  no_adjust,                    // (unused)
  upd_2_4,                      // stone arch (near side)
  upd_3_5,                      // stone arch (far side)
  upd_2_4,                      // tree arch (near side)
  upd_3_5,                      // tree arch (far side)
  upd_6_7,                      // rock
  upd_6_7,                      // block
  upd_8,                        // portcullis
  upd_9,                        // another portcullis
  upd_10,                       // bricks
  upd_11,                       // more bricks
  upd_12_to_15,                 // even more bricks
  upd_12_to_15,                 // even more bricks
  upd_12_to_15,                 // even more bricks
  upd_12_to_15,                 // even more bricks
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_22,                       // gargoyle
  upd_23,                       // spikes
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_30_31_158_159,            // guard (top half)
  upd_30_31_158_159,            // guard (top half)
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 40
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 50
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_54,                       // yet another block
  upd_55,                       // yet another block
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 60
  upd_not_implemented,
  upd_62,                       // another block
  upd_63,                       // spiked ball
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 70
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_80_to_83,                 // ghost
  upd_80_to_83,                 // ghost
  upd_80_to_83,                 // ghost
  upd_80_to_83,                 // ghost
  upd_84,                       // table
  upd_85,                       // chest
  upd_86_87,                    // another fire
  upd_86_87,                    // another fire
  upd_88_to_90,                 // sun
  upd_88_to_90,                 // moon
  upd_88_to_90,                 // frame
  upd_91,                       // block (high?)
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_96_to_102,                // diamond
  upd_96_to_102,                // poison
  upd_96_to_102,                // boot
  upd_96_to_102,                // chalice
  upd_96_to_102,                // cup
  upd_96_to_102,                // bottle
  upd_96_to_102,                // crystal ball
  upd_103,                      // extra life
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 110
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_not_implemented,
  upd_128_to_130,               // tree wall
  upd_128_to_130,               // tree wall
  upd_128_to_130,               // tree wall
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 140
  upd_141,                      // cauldron (bottom)
  upd_142,                      // cauldron (top)
  upd_143,                      // another block
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_150_151,                  // guard 2 (top half)
  upd_150_151,                  // guard 2 (top half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_30_31_158_159,            // wizard (top half)
  upd_30_31_158_159,            // wizard (top half)
  upd_not_implemented,  // 160
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_164_to_167,               // twinkles
  upd_164_to_167,               // twinkles
  upd_164_to_167,               // twinkles
  upd_164_to_167,               // twinkles
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,  // 170
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_178_179,                  // another ball
  upd_178_179,                  // another ball
  upd_180_181,                  // fire
  upd_180_181,                  // fire
  upd_182_183,                  // ball (high)
  upd_182_183,                  // ball (high)
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented,
  upd_not_implemented
};

// $B2B6
void play_audio_wait_key (uint8_t *audio_data)
{
  // check something here
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

// $B5FF
// ball (high)
void upd_182_183 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  // other stuff
}

// $B683
// block (high?)
void upd_91 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  // other stuff
}

// $B6A2
// another block
void upd_143 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  // other stuff
}

// $B6B1
// yet another block
void upd_55 (POBJ32 p_obj)
{
  // some stuff
  upd_6_7 (p_obj);
  // other stuff (in common with below)
}

// $B6B9
// yet another block
void upd_54 (POBJ32 p_obj)
{
  // some stuff
  upd_6_7 (p_obj);
  // other stuff (in common with above)
}

// $B6F7
// guard & wizard (bottom half)
void upd_144_to_149_152_to_157 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -6, -12); // this is in a sub
  // other stuff
}

// $B7A9
// spiked ball
void upd_63 (POBJ32 p_obj)
{
  // sub_B85C
  upd_6_7 (p_obj);
  // other stuff
}

// $B7C3
// guard 2 top half
void upd_150_151 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, 7, -12);
  // heaps of other stuff  
}

// $B7A3
// gargoyle
void upd_22 (POBJ32 p_obj)
{
  // call sub_B85C
  sub_C4FC (p_obj);
}

// $B7E7
// spikes
void upd_23 (POBJ32 p_obj)
{
  // call sub_B85C
  upd_6_7 (p_obj);
}

// $B7ED
// another fire
void upd_86_87 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  // other stuff
}

// $B808
// fire
void upd_180_181 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  // other stuff
}

// $B865
// another ball
void upd_178_179 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  // other stuff
}

// $B92C
// twinkles
void upd_164_to_167 (POBJ32 p_obj)
{
  sub_C4D8 (p_obj);
  // other stuff
}

// $B99C
// cauldron (bottom)
void upd_141 (POBJ32 p_obj)
{
  // sun, moon, frame
  upd_88_to_90 (p_obj);
}

// $B99F
// cauldron (top)
void upd_142 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, 12, -24);
}

// $B9A5
// guard & wizard (top half)
void upd_30_31_158_159 (POBJ32 p_obj)
{
  POBJ32 p_next_obj = p_obj + 1;
  
  set_pixel_adj (p_obj, 3, -12);
  // call sub_CB45 - move?
  // other stuff
  p_next_obj->d_x = p_obj->d_x;
  p_next_obj->d_y = p_obj->d_y;
  p_next_obj->x = p_obj->x;
  p_next_obj->y = p_obj->y;
  // call sub_b76c
}

// $BC66
void print_days (void)
{
  print_bcd_number (122, 7, &days, 1);
}

// $BC7A
void print_lives_gfx (void)
{
  sprite_scratchpad.graphic_no = 0x8c;
  sprite_scratchpad.flags = 0;
  sprite_scratchpad.pixel_x = 16;
  sprite_scratchpad.pixel_y = 32;
  print_sprite (&sprite_scratchpad);
  // fill_de ();
  // fill_de ();
}

// $BCA3
void print_lives (void)
{
  print_bcd_number (32, 39, (uint8_t *)&lives, 1);
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
    scratchpad->pixel_x += dx;
    scratchpad->pixel_y += dy;
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
    
    sprite_scratchpad.pixel_x = x;
    sprite_scratchpad.pixel_y = 0;
    sprite_scratchpad.flags = (1<<4);

    if (objects_carried[i][0] != 0)
    {
      sprite_scratchpad.graphic_no = objects_carried[i][0];
      print_sprite (&sprite_scratchpad);
    }
  }
}

// $BEFE
void upd_120_to_126 (POBJ32 p_obj)
{
  sub_C4D8 (p_obj);
#if 0  
  if ((~seed_2 & 1) != 0)
    return;
  graphic_objs_tbl[0].graphic_no++;
  // other stuff
#endif  
}

// $C1AB
// extra life
void upd_103 (POBJ32 p_obj)
{
  upd_128_to_130 (p_obj);
  // more stuff
}
  
// $C28B
// special objects
void upd_96_to_102 (POBJ32 p_obj)
{
  sub_C4D8 (p_obj);
  // more stuff
}
  
// $C2CB
void no_adjust (POBJ32 p_obj)
{
  // do nothing
}

// $C3A4
void display_sun_moon_frame (PSPRITE_SCRATCHPAD scratchpad)
{
  uint8_t x;

  // check a byte

  if (scratchpad->pixel_x == 225)
    goto toggle_day_night;

  // adjust Y coordinate
  x = scratchpad->pixel_x + 16;
  scratchpad->y = sun_moon_yoff[(x>>2)&0x0f];
  print_sprite (scratchpad);

display_frame:
  sprite_scratchpad.graphic_no = 0x5a;
  sprite_scratchpad.flags = 0;
  sprite_scratchpad.pixel_x = 184;
  sprite_scratchpad.pixel_y = 0;
  print_sprite (&sprite_scratchpad);
  sprite_scratchpad.pixel_x = 208;
  sprite_scratchpad.graphic_no = 0xba;
  print_sprite (&sprite_scratchpad);
  // wipe something
  return;

toggle_day_night:
  scratchpad->graphic_no ^= 1;
  //colour_sun_moon ();
  scratchpad->pixel_x = 176;
  // if just changed to moon, exit
  if (scratchpad->graphic_no & 1)
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
  sun_moon_scratchpad.graphic_no = 0x58;
  sun_moon_scratchpad.pixel_x = 176;
  sun_moon_scratchpad.pixel_y = 9;
}

// $C47E
// places special objects into fixed list of rooms
// - starting object is random
#define NUM_OBJS (sizeof(special_objs_tbl)/sizeof(OBJ9))
void init_special_objects (void)
{
  uint8_t r = seed_1;
  r += rand() & 0xFF;
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

  //dump_special_objs_tbl ();
}

// $C4AA
// another block
void upd_62 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  // other stuff
}

// $C4B6
// chest
void upd_85 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  // other stuff
}

// $C4C3
// table
void upd_84 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  // other stuff
}

// $C4D3
// tree wall
void upd_128_to_130 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -2, -8);
}

// $C4D8
void sub_C4D8 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -4, -12);
}

// $C4DD
void adj_m6_m12 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -6, -12);
}

// $C4E8
// rock & block
void upd_6_7 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -8, -16);
}

// $C4E8
void upd_10 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -1, -20);
}

// $C4ED
void upd_11 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -2, -12);
}

// $C4F2
void upd_12_to_15 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -4, -8);
}

// $C4FC
void sub_C4FC (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -7, -12);
}

// $C506
// sun, moon, frame
void upd_88_to_90 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -12, -16);
}

// $C525
void find_special_objs_here (void)
{
  POBJ32 p_special_obj = special_objs_here;
  uint8_t n_special_objs_here = 0;
 
  fprintf (stderr, "%s(): screen=%d\n", 
            __FUNCTION__,
            graphic_objs_tbl[0].scrn);
  
  for (unsigned i=0; i<32; i++, p_special_obj++)
  {
    if (special_objs_tbl[i].graphic_no == 0)
      continue;
    if (special_objs_tbl[i].curr_scrn != graphic_objs_tbl[0].scrn)
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
    memset (&p_special_obj->d_x, 0, 7);  // *** FIXME
    p_special_obj->ptr_obj_tbl_entry = i;
    memset (&p_special_obj->pad2, 0, 12); // *** FIXME
    
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

// $C5C8
// ghost
void upd_80_to_83 (POBJ32 p_obj)
{
  adj_m6_m12 (p_obj);
  // heaps of other stuff
}

// $C65E
// portcullis (stationary)
void upd_8 (POBJ32 p_obj)
{
  uint8_t r;

  adj_m6_m12 (p_obj);
  if (portcullis_moving)
    return;
  if (p_obj->z == room_size_Z ||
      p_obj->z <= (room_size_Z+31))
  {
    // 1-in-32 chance of starting to move up
    if ((seed_3 & 0x1F) != 0)
      return;
    p_obj->graphic_no |= (1<<0);
    p_obj->d_z = 1;
  }
  else
  {
    if (portcullis_move_cnt < 4)
      r = portcullis_move_cnt;
    else
    {
      // 1-in-32 chance of moving down
      if ((seed_3 & 0x1F) != 0)
        return;
      r = 0x80;
    }
    portcullis_move_cnt = r + 1;
    p_obj->graphic_no |= (1<<0);
    p_obj->d_z = -1;
  }    

  portcullis_moving++;
  set_wipe_and_draw_flags (p_obj);
}

// $C692
void set_wipe_and_draw_flags (POBJ32 p_obj)
{
  p_obj->flags |= (FLAG_WIPE|FLAG_DRAW);
  // do some other stuff & return
}

// $C6BD
// portcullis (moving)
void upd_9 (POBJ32 p_obj)
{
  //fprintf (stderr, "%s()\n", __FUNCTION__);
  
  adj_m6_m12 (p_obj);
  p_obj->flags13 |= (1<<7);
  // stuff
  if (p_obj->d_z < 0)
  {
    p_obj->d_z--;
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->flags12 & FLAG_Z_OOB)
    {
      //sub_B489 ();
    stop_portcullis:
      portcullis_moving = 0;
      // set graphic_no to 8
      p_obj->graphic_no &= ~(1<<0);
    }
  }
  else
  {
    p_obj->d_z = 2;
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->z > room_size_Z+31)
      goto stop_portcullis;    
  }
  set_wipe_and_draw_flags (p_obj);
}

// $C700
void dec_dZ_and_update_XYZ (POBJ32 p_obj)
{
  p_obj->d_z--;
  adj_for_out_of_bounds (p_obj);
  add_dXYZ (p_obj);  
}

// $C706
void add_dXYZ (POBJ32 p_obj)
{
  p_obj->x += p_obj->d_x;
  p_obj->y += p_obj->d_y;
  p_obj->z += p_obj->d_z;
}

// $C722
// stone/tree arch (far side)
void upd_3_5 (POBJ32 p_obj)
{
  if ((p_obj->flags & FLAG_HFLIP) == 0)
    set_pixel_adj (p_obj, -3, -9);
  else
    set_pixel_adj (p_obj, -2, -7);
}

// $C72B
void set_pixel_adj (POBJ32 p_obj, int8_t h, int8_t l)
{
  p_obj->pixel_x_adj = l;
  p_obj->pixel_y_adj = h;
}

// $C7C3
// stone/tree arch (near side)
void upd_2_4 (POBJ32 p_obj)
{
  if ((p_obj->flags & FLAG_HFLIP) == 0)
  {
    // tree arch
    if (p_obj->graphic_no == 4)
      set_pixel_adj (p_obj, -3, 1);
    else
      set_pixel_adj (p_obj, -3, -7);
    p_obj->d_y = p_obj->y + 13;
    p_obj->d_x = p_obj->x;
    p_obj->d_z = p_obj->z;
    // call sub_c7db
    // call loc_c785
  }
  else
  {
    set_pixel_adj (p_obj, -2, -17);
    p_obj->d_x = p_obj->x + 13;
    p_obj->d_y = p_obj->y;
    // jp loc_c760
  }
}

// $CA5A
int8_t adj_dZ_for_out_of_bounds (POBJ32 p_obj, int8_t d_z)
{
  do
  {
    if ((p_obj->z + d_z) >= room_size_Z)
      return (d_z);
    p_obj->flags12 |= FLAG_Z_OOB;
    d_z = adj_d_for_out_of_bounds (d_z);
    
  } while (d_z != 0);
}

// $CA89
int8_t adj_d_for_out_of_bounds (int8_t d)
{
  if (d == 0)
    return (d);
  if (d < 0)
    return (d+1);
  else
    return (d-1);
}

// $CB45
void adj_for_out_of_bounds (POBJ32 p_obj)
{
  int8_t d_x, d_y, d_z;

  if (p_obj->flags & (1<<1))
    return;
    
  p_obj->flags |= (1<<1);
  p_obj->flags12 &= ~(FLAG_Z_OOB|FLAG_Y_OOB|FLAG_X_OOB);
  d_y = 0;
  d_x = 0;

  d_z = p_obj->d_z;  
  if (p_obj->d_z != 0)
  {
    d_z = adj_dZ_for_out_of_bounds (p_obj, d_z);
    if (d_z != 0)
      ; // do some stuff
  }

  d_y = p_obj->d_y;  
  if (p_obj->d_y != 0)
  {
    d_y = adj_dY_for_out_of_bounds (p_obj, d_y);
    if (d_y != 0)
      ; // do some stuff
  }

  d_z = p_obj->d_z;
  if (p_obj->d_x != 0)
  {
    d_x = adj_dX_for_out_of_bounds (p_obj, d_x);
    if (d_x != 0)
      ; // do some stuff
  }
  
  p_obj->d_x = d_x;
  p_obj->d_y = d_y;
  p_obj->d_z = d_z;
  p_obj->flags &= ~(1<<1);
}

// $CCDD
int8_t adj_dX_for_out_of_bounds (POBJ32 p_obj, int8_t d_x)
{
  return (d_x);
}

// $CD08
int8_t adj_dY_for_out_of_bounds (POBJ32 p_obj, int8_t d_y)
{
  return (d_y);
}

// $CE49
void save_2d_info (POBJ32 p_obj)
{
  p_obj->old_data_width_bytes = p_obj->data_width_bytes;
  p_obj->old_data_height_lines = p_obj->data_height_lines;
  p_obj->old_pixel_x = p_obj->pixel_x;
  p_obj->old_pixel_y = p_obj->pixel_y;
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
    {
      //fprintf (stderr, "[%02d]=%02d(graphic_no=$%02X,flags=$%02X)\n",
      //          n, i, graphic_objs_tbl[i].graphic_no, graphic_objs_tbl[i].flags);
      objects_to_draw[n++] = i;
    }
  }
  objects_to_draw[n] = 0xff;

  //fprintf (stderr, "  n=%d\n", n);
}

// $CEBB
void calc_display_order_and_render (void)
{
  for (unsigned i=0; objects_to_draw[i] != 0xFF; i++)
  {
    POBJ32 p_obj = &graphic_objs_tbl[objects_to_draw[i]];
    #if 0
    if (p_obj->graphic_no == 23)
      p_obj->flags &= ~(1<<4);
    else 
    #endif     
      calc_pixel_XY_and_render (p_obj);
  }
}

// $D12A
int lose_life (void)
{
  memcpy ((void *)&graphic_objs_tbl[0], (void *)&plyr_spr_1_scratchpad, sizeof(OBJ32));
  memcpy ((void *)&graphic_objs_tbl[1], (void *)&plyr_spr_2_scratchpad, sizeof(OBJ32));
  //byte_5BB1 = 0;
  if (--lives < 0)
    return (-1);

  // some stuff with sun/moon scratchpad
      
  // just for the hell of it
  return (lives);  
}

// $D1B1
void init_start_location (void)
{
  memcpy ((uint8_t *)&plyr_spr_1_scratchpad, plyr_spr_init_data+0, 8);
  memcpy ((uint8_t *)&plyr_spr_2_scratchpad, plyr_spr_init_data+8, 8);
  //plyr_spr_1_scratchpad.pad1[1] = 0x12; // *** FIXME
  //plyr_spr_2_scratchpad.pad1[1] = 0x22; // *** FIXME
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
  // stuff
  
  // save state in special_objs_tbl
  update_special_objs ();
  clr_screen_buffer ();
  retrieve_screen ();
  // find special objects in new room
  find_special_objs_here ();
  // adjust_plyr_xyz_for_room_size
  portcullis_moving = 0;
  portcullis_move_cnt = 0;
  // stuff
  initial_rendering = 1;
  // stuff
}

// $D237
uint8_t *transfer_sprite (PSPRITE_SCRATCHPAD scratchpad, uint8_t *psprite)
{
  scratchpad->graphic_no = *(psprite++);
  scratchpad->flags = *(psprite++);
  scratchpad->pixel_x = *(psprite++);
  scratchpad->pixel_y = *(psprite++);

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
    static unsigned p_47 = 0;

    // fudge: save this for invalid screens
    if (location_tbl[p] == 47)
      p_47 = p;    
    if (location_tbl[p] == graphic_objs_tbl[0].scrn)
      break;
    if (location_tbl[p] > graphic_objs_tbl[0].scrn ||
        location_tbl[p] == 255) // *** FIXME
    {
      #if 0
        graphic_objs_tbl[0].scrn = 47;
        graphic_objs_tbl[1].scrn = 47;
      p = p_47;
      #else
        graphic_objs_tbl[0].scrn = location_tbl[p];
        graphic_objs_tbl[1].scrn = location_tbl[p];
      #endif
      break;
      // bad_player_location
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

    for (; *p_bg_obj!=0; p_bg_obj+=8)
    {    
      next_bj_obj_sprite:
        
      // copy sprite,x,y,z,w,d,h,flags
      memcpy ((uint8_t *)p_other_objs, p_bg_obj, 8);
      // set screen (location)
      p_other_objs->scrn = plyr_spr_1_scratchpad.scrn;
      // zero everything else
      memset (&p_other_objs->d_x, 0, 23);
      
      p_other_objs++;
    };
  }

  // skip 0xFF
  if (size)
    size--;
  p++;
  
  // do the foreground objects
  for (; size; )
  {
    uint8_t count = (location_tbl[p] & 7) + 1;
    uint8_t block = location_tbl[p] >> 3;

    size--;
    p++;
              
    for (; count; p++, count--, size--)
    {
      uint8_t *p_fg_obj = block_type_tbl[block];
      uint8_t loc = location_tbl[p];

      for (; *p_fg_obj!=0; p_fg_obj+=6)
      {
        uint8_t x1, y1, z1;
        
        p_other_objs->graphic_no = p_fg_obj[0];
        p_other_objs->width = p_fg_obj[1];
        p_other_objs->depth = p_fg_obj[2];
        p_other_objs->height = p_fg_obj[3];
        p_other_objs->flags = p_fg_obj[4];
        p_other_objs->scrn = plyr_spr_1_scratchpad.scrn;
        
        // X = x*16 + x1*8 + 72
        x1 = (p_fg_obj[5] << 3) & 8;  // x8
        p_other_objs->x = ((loc << 4) & 0x70) + x1 + 72;
        // Y = y*16 + y1*8 + 72
        y1 = (p_fg_obj[5] << 2) & 8;  // x8
        p_other_objs->y = ((loc << 1) & 0x70) + y1 + 72;
        // Z = z*12 + z1*4 + room_size_Z
        z1 = p_fg_obj[5] & 0xFC;      // x4
        p_other_objs->z = ((loc >> 6) & 3) * 12 + z1 + room_size_Z;
        
        // zero everything else        
        memset (&p_other_objs->d_x, 0, 23);

        p_other_objs++;
      }
    }
  }
  
  fprintf (stderr, "n_other_objs = %d\n",
            p_other_objs - other_objs_here);
            
  dump_graphic_objs_tbl();
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
  loc_D653 ();
  #if 0
  for (unsigned i=0; objects_to_draw[i] != 0xFF; i++)
  {
    POBJ32 p_obj = &graphic_objs_tbl[objects_to_draw[i]];
    
    #if 0
    // check ??? flag
    if ((p_obj->flags & (1<<5)) == 0)
      continue;
    p_obj->flags &= ~(1<<5);
    #endif
  }
  #endif
}

// $D653
void loc_D653 (void)
{
  calc_display_order_and_render ();
  // other stuff
}

// $D6C9
void calc_pixel_XY (POBJ32 p_obj)
{
  p_obj->pixel_x = p_obj->x + p_obj->y - 128 + p_obj->pixel_x_adj;
  p_obj->pixel_y = ((p_obj->y - p_obj->x + 128) >> 1) + p_obj->z - 104 + p_obj->pixel_y_adj;
}

#define REV(d) (((d&1)<<7)|((d&2)<<5)|((d&4)<<3)|((d&8)<<1)|((d&16)>>1)|((d&32)>>3)|((d&64)>>5)|((d&128)>>7))
//#define REV(d) d

// $D6EF
uint8_t *flip_sprite (PSPRITE_SCRATCHPAD scratchpad)
{
  uint8_t *psprite = sprite_tbl[scratchpad->graphic_no];
  
  uint8_t vflip = (scratchpad->flags ^ (*psprite)) & FLAG_VFLIP;
  uint8_t hflip = (scratchpad->flags ^ (*psprite)) & FLAG_HFLIP;

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
    {
      unsigned x;
      
      for (x=0; x<w/2; x++)
      {
        uint8_t t = psprite[3+2*(y*w+x)];
        psprite[3+2*(y*w+x)] = REV(psprite[3+2*(y*w+w-1-x)]);
        psprite[3+2*(y*w+w-1-x)] = REV(t);
      }
      if (w & 1)
        psprite[3+2*(y*w+x)] = REV(psprite[3+2*(y*w+x)]);
      }
    *psprite ^= 0x40;
  }

  return (psprite);
}

// $D704
void calc_pixel_XY_and_render (POBJ32 p_obj)
{
  // flag don't draw
  p_obj->flags &= ~(1<<4);
  
  calc_pixel_XY (p_obj);
  
  //if (p_obj->graphic_no == 10)
  {
    //fprintf (stderr, "%s($%02X)\n", __FUNCTION__, p_obj->graphic_no);
    print_sprite (p_obj);
  }
}

// $D718
void print_sprite (PSPRITE_SCRATCHPAD scratchpad)
{
  uint8_t *psprite;

  //fprintf (stderr, "(%d,%d)\n", scratchpad->x, scratchpad->y);

  // references sprite_scratchpad
  psprite = flip_sprite (scratchpad);

  uint8_t w = *(psprite++) & 0x3f;
  uint8_t h = *(psprite++);

  for (unsigned y=0; y<h; y++)
  {
    for (unsigned x=0; x<w; x++)
    {
      uint8_t m = *(psprite++);
      uint8_t d = *(psprite++);
      for (unsigned b=0; b<8; b++)
      {
#ifdef ENABLE_MASK
        if (m & (1<<7))
          putpixel (screen, scratchpad->pixel_x+x*8+b, 191-(scratchpad->pixel_y+y), 0);
#endif
        if (d & (1<<7))
          putpixel (screen, scratchpad->pixel_x+x*8+b, 191-(scratchpad->pixel_y+y), 15);
        m <<= 1;
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
