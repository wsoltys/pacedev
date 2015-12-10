#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#define NOT_TESTED      fprintf (stderr, "*** %s(): NOT TESTED ***\n", __FUNCTION__)

#pragma pack(1)

#define ENABLE_MASK

// byte offset 7 flags
#define FLAG_VFLIP      (1<<7)
#define FLAG_HFLIP      (1<<6)
#define FLAG_WIPE       (1<<5)
#define FLAG_DRAW       (1<<4)

// byte offset 12 flags
#define FLAG_Z_OOB      (1<<2)
#define FLAG_Y_OOB      (1<<1)
#define FLAG_X_OOB      (1<<0)

// byte offset 13 flags
#define FLAG_TRIGGERED  (1<<3)    // dropping block
#define FLAG_UP         (1<<2)    // bouncing ball
#define FLAG_DROPPING   (1<<2)    // spiked ball
#define FLAG_EAST       (1<<0)    // EW fire
#define FLAG_NORTH      (1<<1)    // NS fire

#include "kldat.h"
#include "kl_osd.h"

typedef void (*adjfn_t)(POBJ32 p_obj);

// start of variables

static uint8_t seed_1;                                // $5BA0
static uint16_t seed_2;                               // $5BA2
static uint8_t seed_3;                                // $5BA5

// cleared each game ($5BA8-$6107)
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
static uint8_t objects_put_in_cauldron;               // $5BBB
static uint8_t fire_seed;                             // $5BBC
static uint8_t ball_bounce_height;                    // $5BBD
static uint8_t is_spike_ball_dropping;                // $5BBF
static uint8_t disable_spike_ball_drop;               // $5BC0
static uint8_t byte_5BC3;                             // $5BC3
static uint8_t byte_5BC4;                             // $5BC4
static uint8_t *gfxbase_8x8;                          // $5BC7
static uint8_t objects_carried[3][4];                 // $5BDC
static uint8_t room_visited[32];                      // $5BE8
static OBJ32 graphic_objs_tbl[40];                    // $5C08
static POBJ32 special_objs_here = 
              &graphic_objs_tbl[2];                   // $5C48
static POBJ32 other_objs_here =
              &graphic_objs_tbl[4];                   // $5C88
              
static OBJ32 sprite_scratchpad;                       // $BFDB
static uint8_t objects_required[] =                   // $C27D
{
  0, 1, 2, 3, 4, 5, 6, 3, 5, 0, 6, 1, 2, 4
};
static OBJ32 sun_moon_scratchpad;                     // $C44D
static uint8_t objects_to_draw[48];                   // $CE8B
static OBJ32 plyr_spr_1_scratchpad;                   // $D161
static OBJ32 plyr_spr_2_scratchpad;                   // $D181

// end of variables

// start of prototypes

static void play_audio_wait_key (uint8_t *audio_data);
static void play_audio (uint8_t *audio_data);
static void shuffle_objects_required (void);
static void upd_131_to_133 (POBJ32 p_obj);
static void dec_dZ_wipe_and_draw (POBJ32 p_obj);
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
static void upd_176_177 (POBJ32 p_obj);
static void sub_B85C (POBJ32 p_obj);
static void upd_178_179 (POBJ32 p_obj);
static void upd_160_to_163 (POBJ32 p_obj);
static void upd_168_to_175 (POBJ32 p_obj);
static void upd_164_to_167 (POBJ32 p_obj);
static void upd_111 (POBJ32 p_obj);
static void toggle_next_prev_sprite (POBJ32 p_obj);
static void next_graphic_no_mod_4 (POBJ32 p_obj);
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
static void multiple_print_sprite (POBJ32 p_obj, uint8_t dx, uint8_t dy, uint8_t n);
static void init_sparkles (POBJ32 p_obj);
static void upd_112_to_118_184 (POBJ32 p_obj);
static void upd_185_187 (POBJ32 p_obj);
static void upd_119 (POBJ32 p_obj);
static void display_objects (void);
static void upd_120_to_126 (POBJ32 p_obj);
static void adj_m8_m12 (POBJ32 p_obj);
static void upd_127 (POBJ32 p_obj);
static uint8_t is_obj_moving (POBJ32 p_obj);
static void upd_103 (POBJ32 p_obj);
static void upd_104_to_110 (POBJ32 p_obj);
static uint8_t ret_next_obj_required (void);
static void gen_audio_XYZ_wipe_and_draw (POBJ32 p_obj);
static void upd_96_to_102 (POBJ32 p_obj);
static void no_update (POBJ32 p_obj);
static void prepare_final_animation (void);
static void upd_92_to_95 (POBJ32 p_obj);
static void display_sun_moon_frame (POBJ32 p_obj);
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
static void adj_m4_m12 (POBJ32 p_obj);
static void adj_m7_m12 (POBJ32 p_obj);
static void adj_m12_m12 (POBJ32 p_obj);
static void upd_88_to_90 (POBJ32 p_obj);
static void find_special_objs_here (void);
static void update_special_objs (void);
static void upd_80_to_83 (POBJ32 p_obj);
static void calc_ghost_sprite (POBJ32 p_obj);
static int8_t get_delta_from_tbl (unsigned i);
static void upd_8 (POBJ32 p_obj);
static void set_wipe_and_draw_flags (POBJ32 p_obj);
static void upd_9 (POBJ32 p_obj);
static void dec_dZ_and_update_XYZ (POBJ32 p_obj);
static void add_dXYZ (POBJ32 p_obj);
static void upd_3_5 (POBJ32 p_obj);
static void set_pixel_adj (POBJ32 p_obj, int8_t h, int8_t l);
static void upd_2_4 (POBJ32 p_obj);
static void upd_16_to_21_24_to_29 (POBJ32 p_obj);
static void upd_48_to_53_56_to_61 (POBJ32 p_obj);
static void upd_player_legs (POBJ32 p_obj);
static void clear_dX_dY (POBJ32 p_obj);
static int8_t adj_dZ_for_out_of_bounds (POBJ32 p_obj, int8_t d_z);
static int8_t adj_d_for_out_of_bounds (int8_t d);
static void adj_for_out_of_bounds (POBJ32 p_obj);
static int8_t adj_dX_for_out_of_bounds (POBJ32 p_obj, int8_t d_x);
static int8_t adj_dY_for_out_of_bounds (POBJ32 p_obj, int8_t d_y);
static void upd_32_to_47 (POBJ32 p_obj);
static void upd_64_to_79 (POBJ32 p_obj);
static void upd_player_top (POBJ32 p_obj);
static void save_2d_info (POBJ32 p_obj);
static void list_objects_to_draw (void);
static void calc_display_order_and_render (void);
static int lose_life (void);
static void init_start_location (void);
static void build_screen_objects (void);
static void flag_room_visited (void);
static uint8_t *transfer_sprite (POBJ32 p_obj, uint8_t *psprite);
static uint8_t *transfer_sprite_and_print (POBJ32 p_obj, uint8_t *psprite);
static void display_panel (void);
static void retrieve_screen (void);
static void print_border (void);
static void clear_scrn (void);
static void clr_screen_buffer (void);
static void render_dynamic_objects (void);
static void loc_D653 (void);
static void calc_pixel_XY (POBJ32 p_obj);
uint8_t *flip_sprite (POBJ32 p_obj);
static void calc_pixel_XY_and_render (POBJ32 p_obj);
static void print_sprite (POBJ32 p_obj);

// end of prototypes

void dump_graphic_objs_tbl (int start, int end)
{
  unsigned i = (start == -1 ? 0 : start);
  
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (; i<end && i<40; i++)
  {
    fprintf (stderr, "%02d: graphic_no=%02d, (%3d,%3d,%3d) %02dx%02dx%02d, f=$%02X @(%02d,%02d)\n",
              i,
              graphic_objs_tbl[i].graphic_no,
              graphic_objs_tbl[i].x,
              graphic_objs_tbl[i].y,
              graphic_objs_tbl[i].z,
              graphic_objs_tbl[i].width,
              graphic_objs_tbl[i].depth,
              graphic_objs_tbl[i].height,
              graphic_objs_tbl[i].flags,
              graphic_objs_tbl[i].pixel_x,
              graphic_objs_tbl[i].pixel_y);
  }
}

void dump_special_objs_tbl (void)
{
  unsigned i;
  
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (i=0; i<32; i++)
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

  static uint8_t printed[256];
  static uint8_t inited = 0;
  
  if (!inited)
  {
    memset (printed, 0, 256);
    inited = 1;
  }
      
  if (!printed[obj->graphic_no])
  {
    fprintf (stderr, "%s(%d=$%02X) @$%04X\n",
              __FUNCTION__,
              obj->graphic_no, 
              obj->graphic_no,
              0xB096+2*obj->graphic_no);
    printed[obj->graphic_no] = 1;
  }
}

void knight_lore (void)
{
START_AF6C:

MAIN_AF88:

  {
    // fudge fudge fudge
    // clear variables $5BA8-$6107
    uint8_t *p = (uint8_t *)&objs_wiped_cnt;
    while (p < (uint8_t *)&sprite_scratchpad)
      *(p++) = 0;
  }
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
	osd_cls ();

onscreen_loop:

  fire_seed = seed_2;
  
  POBJ32 p_obj = graphic_objs_tbl;
  unsigned i;
    
  for (i=0; i<40; i++, p_obj++)
  {
    update_sprite_loop:

    fire_seed++;      
    save_2d_info (p_obj);

    #ifndef arraylen
      #define arraylen(n) (sizeof(n) / sizeof((n)[0]))
    #endif
    extern adjfn_t upd_sprite_jump_tbl[];
    
    if (p_obj->graphic_no > 187)
      upd_not_implemented (p_obj);
    else
    {
      // debug only - 7 only
      //if (p_obj->graphic_no == 7)
        upd_sprite_jump_tbl[p_obj->graphic_no] (p_obj);
    }

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
  osd_delay (100);

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
    
    //while (!(key[KEY_ESC]||key[KEY_SPACE]));
    //while (key[KEY_SPACE]);
  }

  if (graphic_objs_tbl[0].graphic_no == 0 &&
      graphic_objs_tbl[1].graphic_no == 0)
    goto player_dies;

/////////////////////////////////
// start of development hook
/////////////////////////////////

  if (osd_key(OSD_KEY_ESC))
    return;

  if (osd_key(OSD_KEY_N))
  {
    graphic_objs_tbl[0].scrn += 16;
    goto exit_screen;
  }
  
  if (osd_key(OSD_KEY_S))
  {
    graphic_objs_tbl[0].scrn -= 16;
    goto exit_screen;
  }
  
  if (osd_key(OSD_KEY_E))
  {
    graphic_objs_tbl[0].scrn += 1;
    goto exit_screen;
  }
  
  if (osd_key(OSD_KEY_W))
  {
    graphic_objs_tbl[0].scrn -= 1;
    goto exit_screen;
  }

  if (osd_key(OSD_KEY_G))
  {
    uint8_t scrn = 0;
    unsigned i;
        
    while (osd_keypressed ())
      osd_readkey ();
    fprintf (stderr, "GOTO: ");
    for (i=0; i<3; i++)
    {
      int c;
      do
      {
        c = osd_readkey () & 0xff;
      } while (!isdigit(c));
      
      fprintf (stderr, "%c", c);
      scrn = (scrn * 10) + c - '0';
    }
    fprintf (stderr, "\n");
    graphic_objs_tbl[0].scrn = scrn;
    goto exit_screen;
  }

  if (osd_key(OSD_KEY_P))
  {
    static unsigned s_no = 0;
    
    fprintf (stderr, "s_no=%d, start_scrn=%d\n", 
              s_no, special_objs_tbl[s_no].start_scrn);
    graphic_objs_tbl[0].scrn = special_objs_tbl[s_no].start_scrn;
    s_no = (s_no + 1) % 32;
    goto exit_screen;
  }
    
  if (osd_key(OSD_KEY_D))
  {
    dump_graphic_objs_tbl (-1, -1);
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
  no_update,                    // (unused)
  no_update,                    // (unused)
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
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_22,                       // gargoyle
  upd_23,                       // spikes
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_16_to_21_24_to_29,        // human legs
  upd_30_31_158_159,            // guard (top half)
  upd_30_31_158_159,            // guard (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_32_to_47,                 // player (top half)
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_54,                       // block (moving EW)
  upd_55,                       // block (moving NS)
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_48_to_53_56_to_61,        // wulf legs
  upd_62,                       // another block
  upd_63,                       // spiked ball
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_64_to_79,                 // player (wulf top half)
  upd_80_to_83,                 // ghost
  upd_80_to_83,                 // ghost
  upd_80_to_83,                 // ghost
  upd_80_to_83,                 // ghost
  upd_84,                       // table
  upd_85,                       // chest
  upd_86_87,                    // fire (EW)
  upd_86_87,                    // fire (EW)
  upd_88_to_90,                 // sun
  upd_88_to_90,                 // moon
  upd_88_to_90,                 // frame
  upd_91,                       // block (high?)
  upd_92_to_95,                 // human/wulf transform
  upd_92_to_95,                 // human/wulf transform
  upd_92_to_95,                 // human/wulf transform
  upd_92_to_95,                 // human/wulf transform
  upd_96_to_102,                // diamond
  upd_96_to_102,                // poison
  upd_96_to_102,                // boot
  upd_96_to_102,                // chalice
  upd_96_to_102,                // cup
  upd_96_to_102,                // bottle
  upd_96_to_102,                // crystal ball
  upd_103,                      // extra life
  upd_104_to_110,               // diamond
  upd_104_to_110,               // poison
  upd_104_to_110,               // boot
  upd_104_to_110,               // chalice
  upd_104_to_110,               // cup
  upd_104_to_110,               // bottle
  upd_104_to_110,               // crystal ball
  upd_111,                      // sparkles
  upd_112_to_118_184,           // sparkles
  upd_112_to_118_184,           // sparkles
  upd_112_to_118_184,           // sparkles
  upd_112_to_118_184,           // sparkles
  upd_112_to_118_184,           // sparkles
  upd_112_to_118_184,           // sparkles
  upd_112_to_118_184,           // sparkles
  upd_119,                      // sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // player appear sparkles
  upd_127,                      // last player appears sparkle
  upd_128_to_130,               // tree wall
  upd_128_to_130,               // tree wall
  upd_128_to_130,               // tree wall
  upd_131_to_133,               // more sparkles
  upd_131_to_133,               // more sparkles
  upd_131_to_133,               // more sparkles
  no_update,
  no_update,
  no_update,
  no_update,
  no_update,
  no_update,
  no_update,
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
  upd_160_to_163,               // even more sparkles
  upd_160_to_163,               // even more sparkles
  upd_160_to_163,               // even more sparkles
  upd_160_to_163,               // even more sparkles
  upd_164_to_167,               // twinkles
  upd_164_to_167,               // twinkles
  upd_164_to_167,               // twinkles
  upd_164_to_167,               // twinkles
  upd_168_to_175,               // diamond
  upd_168_to_175,               // poison
  upd_168_to_175,               // boot
  upd_168_to_175,               // chalice
  upd_168_to_175,               // cup
  upd_168_to_175,               // bottle
  upd_168_to_175,               // crystal ball
  upd_168_to_175,               // extra life
  upd_176_177,                  // fire (stationary) (not used)
  upd_176_177,                  // fire (stationary) (not used)
  upd_178_179,                  // ball up/down
  upd_178_179,                  // ball up/down
  upd_180_181,                  // fire (NS)
  upd_180_181,                  // fire (NS)
  upd_182_183,                  // ball (bouncing around)
  upd_182_183,                  // ball (bouncing around)
  upd_112_to_118_184,           // sparkles
  upd_185_187,                  // sparkles
  no_update,
  upd_185_187                   // sparkles
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

// $B566
void upd_131_to_133 (POBJ32 p_obj)
{
  NOT_TESTED;
  
  adj_m4_m12 (p_obj);
  // complicated stuff
}

// $B5AF
void dec_dZ_wipe_and_draw (POBJ32 p_obj)
{
  dec_dZ_and_update_XYZ (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B5F7
uint8_t read_key (uint8_t row)
{
  int8_t val = 0;

  switch (row)
  {
    case 0 :
      return (osd_keypressed ());
      break;
    case 0xEF :
      // 6,7,8,9,0
      if (osd_key(OSD_KEY_0)) val |= (1<<0);
      if (osd_key(OSD_KEY_9)) val |= (1<<1);
      if (osd_key(OSD_KEY_8)) val |= (1<<2);
      if (osd_key(OSD_KEY_7)) val |= (1<<3);
      if (osd_key(OSD_KEY_6)) val |= (1<<4);
      break;
    case 0xF7 :
      // 5,4,3,2,1
      if (osd_key(OSD_KEY_1)) val |= (1<<0);
      if (osd_key(OSD_KEY_2)) val |= (1<<1);
      if (osd_key(OSD_KEY_3)) val |= (1<<2);
      if (osd_key(OSD_KEY_4)) val |= (1<<3);
      if (osd_key(OSD_KEY_5)) val |= (1<<4);
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
// block (dropping) (eg. room 0)
// *** UNTESTED
void upd_91 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  if ((p_obj->flags13 & FLAG_TRIGGERED) == 0)
    return;
  p_obj->flags13 &= ~FLAG_TRIGGERED;
  p_obj->d_z = 0;
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags12 & FLAG_Z_OOB) == 0)
    /*gen_audio_Z (p_obj)*/;
  set_wipe_and_draw_flags (p_obj);
}

// $B6A2
// another block
void upd_143 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  // other stuff
}

// $B6B1
// block (moving NS) (eg. room 29)
void upd_55 (POBJ32 p_obj)
{
  uint8_t r;
  uint8_t x_y;
  
  if (p_obj->graphic_no == 54)
    /*gen_audio_X (p_obj)*/;
  else
    /*gen_audio_Y (p_obj)*/;
    
  upd_6_7 (p_obj);
  
  // generate random movement dependant on IX
  // - the memory address of the object in the
  // graphic_objs_tbl: base=$5C08
  // PUSH IX; POP BC -> use C
  r = (0x5C08 + (p_obj - graphic_objs_tbl) * sizeof(OBJ32)) & 0xFF;
  r = seed_2 + ((r >> 1) & 0x10);
  if (r & (1<<4))
    r = ~r;
  r &= 0x0F;
  x_y = (p_obj->graphic_no == 54 ? p_obj->x : p_obj->y);
  x_y = (x_y + 8) & 0x0F;
  if (x_y == r)
    set_wipe_and_draw_flags (p_obj);
  else
  {
    int8_t d;
    
    if (x_y < r)
      d = 1;
    else
      d = -1;
    if (p_obj->graphic_no == 54)
      p_obj->d_x = d;
    else
      p_obj->d_y = d;
    p_obj->d_z = 1;
    dec_dZ_wipe_and_draw (p_obj);      
  }
}

// $B6B9
// block (moving EW) (eg. room 45)
void upd_54 (POBJ32 p_obj)
{
  // original code generates appropriate audio,
  // and then jumps to a routine for 54/55
  // that uses self-modifying code
  // - we'll just jump and handle in-line
  upd_55 (p_obj);
}

// $B6F7
// guard & wizard (bottom half)
void upd_144_to_149_152_to_157 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -6, -12); // this is in a sub
  // other stuff
}

// $B7A9
// spiked ball (eg. room 18)
// - randomly drop to the floor (and stay there)
// - drop immediately in even-numbered rooms!
void upd_63 (POBJ32 p_obj)
{
  sub_B85C (p_obj);
  upd_6_7 (p_obj);
  if (disable_spike_ball_drop != 0)
    return;
  if ((p_obj->flags13 & FLAG_DROPPING) == 0)
  {
    if (is_spike_ball_dropping != 0)
      return;
    // 1-in-16 chance of starting to drop
    if (seed_3 >= 16)
      return;
    p_obj->flags13 |= (1<<2);
    is_spike_ball_dropping = 1;
  }
  else
  {
    dec_dZ_and_update_XYZ (p_obj);
    if ((p_obj->flags12 & FLAG_Z_OOB) == 0)
    {
      //gen_audio_Z (p_obj);
    }
    else
    {
      p_obj->flags13 &= ~FLAG_DROPPING;
      is_spike_ball_dropping = 0; 
    }
    set_wipe_and_draw_flags (p_obj);
  }
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
  sub_B85C (p_obj);
  adj_m7_m12 (p_obj);
}

// $B7E7
// spikes
void upd_23 (POBJ32 p_obj)
{
  sub_B85C (p_obj);
  upd_6_7 (p_obj);
}

// $B7ED
// fire (moving EW) (eg. room 147)
void upd_86_87 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  p_obj->d_z = 1;
  if ((p_obj->flags13 & FLAG_EAST) != 0)
    p_obj->d_x = 2;
  else
    p_obj->d_x = -2;
  //gen_audio_X (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags12 & FLAG_X_OOB) != 0)
  {
    p_obj->flags13 ^= FLAG_EAST;
    //gen_audio_rom ();
  }
  toggle_next_prev_sprite (p_obj);
  sub_B85C (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B808
// fire (moving NS) (eg. room 14)
void upd_180_181 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  p_obj->d_z = 1;
  if ((p_obj->flags13 & FLAG_NORTH) != 0)
    p_obj->d_y = 2;
  else
    p_obj->d_y = -2;
  //gen_audio_Y (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags12 & FLAG_Y_OOB) != 0)
  {
    p_obj->flags13 ^= FLAG_NORTH;
    //gen_audio_rom ();
  }
  toggle_next_prev_sprite (p_obj);
  sub_B85C (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B83F
// fire (stationary) (not used)
void upd_176_177 (POBJ32 p_obj)
{
  NOT_TESTED;
  
  upd_12_to_15 (p_obj);
  if ((fire_seed & (1<<0)) == 0)
    return;
  // randomise HFLIP
  p_obj->flags ^= seed_3 & FLAG_HFLIP;
  toggle_next_prev_sprite (p_obj);
  sub_B85C (p_obj);
  set_wipe_and_draw_flags (p_obj);
}
  
// $B85C
void sub_B85C (POBJ32 p_obj)
{
  p_obj->flags13 |= (1<<7)|(1<<5);
}

// $B865
// ball up/down (eg. room 33)
void upd_178_179 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  if (ball_bounce_height == 0)
    ball_bounce_height = p_obj->z + 32;
  toggle_next_prev_sprite (p_obj);
  // sub_B451 // audio
  if ((p_obj->flags13 & FLAG_UP) == 0)
  {
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->flags12 & FLAG_Z_OOB)
    {
      p_obj->flags13 |= FLAG_UP;
      //sub_B42E() // audio
    }
  }
  else
  {
    p_obj->d_z = 3;
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->z >= ball_bounce_height)
      p_obj->flags13 &= ~(FLAG_UP);
  }
  sub_B85C (p_obj);
  set_wipe_and_draw_flags (p_obj);
}


// $B8DA
// more sparkles
void upd_160_to_163 (POBJ32 p_obj)
{
  NOT_TESTED;
  
  adj_m4_m12 (p_obj);
  
  if (special_objs_here != 0)
    upd_111 (p_obj);
  else
  {
    p_obj->flags |= (1<<1);
    dec_dZ_and_update_XYZ (p_obj);
    next_graphic_no_mod_4 (p_obj);
    if (p_obj->z < 160)
      p_obj->d_z = 2;
    else
    {
      p_obj->d_z = 1;
      if ((graphic_objs_tbl[0].graphic_no - 48) < 16)
      {
        // wulf - no hint for next object
        p_obj->graphic_no |= (1<<2);
        p_obj->flags &= ~(1<<1);
      }
      else
      {
        // human - show next object required
        if ((p_obj->graphic_no & 3) == 0)
          p_obj->graphic_no = ret_next_obj_required () | 168;
      }
    }
    set_wipe_and_draw_flags (p_obj);
  }
}

// $B923
// special objects (#2)
// - when they are put into the cauldron???
void upd_168_to_175 (POBJ32 p_obj)
{
  NOT_TESTED;
  
  adj_m4_m12 (p_obj);
  p_obj->graphic_no = 160;  // sparkles
  set_wipe_and_draw_flags (p_obj);
}

// $B92C
// twinkles
void upd_164_to_167 (POBJ32 p_obj)
{
  adj_m4_m12 (p_obj);
  // other stuff
}

// $B95E
// sparkles
void upd_111 (POBJ32 p_obj)
{
  NOT_TESTED;

  p_obj->graphic_no = 1;  // invalid
  gen_audio_XYZ_wipe_and_draw (p_obj);
}

// $B985
void toggle_next_prev_sprite (POBJ32 p_obj)
{
  p_obj->graphic_no ^= (1<<0);
}

// $B98C
void next_graphic_no_mod_4 (POBJ32 p_obj)
{
  p_obj->graphic_no = (p_obj->graphic_no & 0xFC) | 
                      ((p_obj->graphic_no+1) & 3);
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
  unsigned i;
  
  gfxbase_8x8 = (uint8_t *)kl_font;
  for (i=0; i<n; i++, bcd++)
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
  osd_print_text_raw (gfxbase_8x8, x, y, str);
}

// $BE4C
void print_text (uint8_t x, uint8_t y, char *str)
{
  osd_print_text (gfxbase_8x8, x, y, str);
}

// $BE7F
uint8_t print_8x8 (uint8_t x, uint8_t y, uint8_t code)
{
  return (osd_print_8x8 (gfxbase_8x8, x, y, code));
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
  unsigned i;
  
  for (i=0; i<n; i++, xy+=2)
    print_text_single_colour (*xy, *(xy+1), text_list[i]);
}

// $BEE4
void multiple_print_sprite (POBJ32 p_obj, uint8_t dx, uint8_t dy, uint8_t n)
{
  unsigned i;
  
  for (i=0; i<n; i++)
  {
    print_sprite (p_obj);
    p_obj->pixel_x += dx;
    p_obj->pixel_y += dy;
  }
}

// $BF21
void init_sparkles (POBJ32 p_obj)
{
  p_obj->graphic_no = 112;
  p_obj->flags |= (1<<1);   // ???
  //gen_audio_graphic_no_rom (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $BF2B
// sparkles
void upd_112_to_118_184 (POBJ32 p_obj)
{
  NOT_TESTED;

  adj_m4_m12 (p_obj);
  p_obj->graphic_no++;
  //gen_audio_graphic_no_rom (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $BF37
// sparkles (object in cauldron???)
void upd_185_187 (POBJ32 p_obj)
{
  NOT_TESTED;

  // zap the graphic_no so the object no longer appears  
  graphic_objs_tbl[p_obj->ptr_obj_tbl_entry].graphic_no = 0;
  upd_119 (p_obj);
}

// $BF3F
// sparkles
void upd_119 (POBJ32 p_obj)
{
  NOT_TESTED;

  adj_m4_m12 (p_obj);
  upd_111 (p_obj);
}

// $BF4E
void display_objects (void)
{
  unsigned i;
  
  objects_carried[0][0] = 0x60;
  objects_carried[1][0] = 0x61;
  objects_carried[2][0] = 0x62;
  
  for (i=0; i<3; i++)
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
// player appears sparkles
void upd_120_to_126 (POBJ32 p_obj)
{
  adj_m4_m12 (p_obj);
  if ((~seed_2 & 1) != 0)
    return;
  p_obj->graphic_no++;
  //gen_audio_graphic_no (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $BF11
// last player appears sparkle
void upd_127 (POBJ32 p_obj)
{
  adj_m4_m12 (p_obj);
  // no idea what the rest of this does???
  p_obj->flags13 &= ~(1<<6);
  // for player (only), this stores the graphic_no
  p_obj->graphic_no = p_obj->plyr_graphic_no;
  upd_sprite_jump_tbl[p_obj->graphic_no] (p_obj);
}

// $C1A1
uint8_t is_obj_moving (POBJ32 p_obj)
{
  return ((p_obj->d_x | p_obj->d_y | p_obj->d_z) != 0);
}

// $C1AB
// extra life
void upd_103 (POBJ32 p_obj)
{
  upd_128_to_130 (p_obj);
  // more stuff
}

// $C1F1
// special objects (dropped in cauldron room?)
void upd_104_to_110 (POBJ32 p_obj)
{
  NOT_TESTED;
  
  adj_m4_m12 (p_obj);
  
  // move towards centre of room
  if (p_obj->x == 128)
    p_obj->d_x = 0;
  else if (p_obj->x < 128)
    p_obj->d_x = 1;
  else
    p_obj->d_x = -1;
  if (p_obj->y == 128)
    p_obj->d_y = 0;
  else if (p_obj->y < 128)
    p_obj->d_y = 1;
  else
    p_obj->d_y = -1;
    
  if (p_obj->x != 128 ||
      p_obj->y != 128)
  {
    if (p_obj->z < 152)
      p_obj->d_z = 2;
    else
      p_obj->d_z = 1;
  }
  else
  {
  centre_of_room:
    if (p_obj->z <= 128)
    {
    add_obj_to_cauldron:
      p_obj->z = 128;
      if ((p_obj->graphic_no & 7) == ret_next_obj_required ())
      {
        objects_put_in_cauldron++;
        //sub_C2A5 ();
        if (objects_put_in_cauldron == 14)
          prepare_final_animation ();
      }
      byte_5BC4 = 0;
      graphic_objs_tbl[p_obj->ptr_obj_tbl_entry].graphic_no = 0;
      upd_111 (p_obj);
      return;
    }
    else
      p_obj->flags |= (1<<1);
  }
  dec_dZ_and_update_XYZ (p_obj);
  gen_audio_XYZ_wipe_and_draw (p_obj);
}

// $C274
uint8_t ret_next_obj_required (void)
{
  return (objects_required[objects_put_in_cauldron]);
}

// $C232
void gen_audio_XYZ_wipe_and_draw (POBJ32 p_obj)
{
  //gen_audio_XYZ (p_obj);
  set_wipe_and_draw_flags (p_obj);    
}

// $C28B
// special objects
// *** UNTESTED
void upd_96_to_102 (POBJ32 p_obj)
{
  adj_m4_m12 (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  // what does this flag represent?
  if ((p_obj->flags13 & (1<<0)) == 0)
    if (!is_obj_moving (p_obj))
      return;
  p_obj->flags13 &= ~(1<<0);
  clear_dX_dY (p_obj);
  gen_audio_XYZ_wipe_and_draw (p_obj);
}
  
// $C2CB
void no_update (POBJ32 p_obj)
{
  // do nothing
}

// $C2CC
void prepare_final_animation (void)
{
  NOT_TESTED;
}

// $C337
// human/wulf transform
void upd_92_to_95 (POBJ32 p_obj)
{
  NOT_TESTED;
  
  upd_11 (p_obj);
  if ((p_obj->flags13 & (1<<6)) == 1 &&
      byte_5BC3 == 0)
    init_sparkles (p_obj);
  else
  {
  }
}

// $C3A4
void display_sun_moon_frame (POBJ32 p_obj)
{
  uint8_t x;

  // check a byte

  if (p_obj->pixel_x == 225)
    goto toggle_day_night;

  // adjust Y coordinate
  x = p_obj->pixel_x + 16;
  p_obj->y = sun_moon_yoff[(x>>2)&0x0f];
  print_sprite (p_obj);

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
  p_obj->graphic_no ^= 1;
  //colour_sun_moon ();
  p_obj->pixel_x = 176;
  // if just changed to moon, exit
  if (p_obj->graphic_no & 1)
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
void init_special_objects (void)
{
  uint8_t r = seed_1;
  unsigned i;
  
  r += rand() & 0xFF;
  for (i=0; i<32; i++)
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
// another block (eg. room 8)
void upd_62 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  clear_dX_dY (p_obj);
  //sub_B3E9(); // audio
  dec_dZ_wipe_and_draw (p_obj);
}

// $C4B6
// chest (eg. room 33)
void upd_85 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if (!is_obj_moving (p_obj))
    return;
  gen_audio_XYZ_wipe_and_draw (p_obj);    
}

// $C4C3
// table (eg. room 10)
void upd_84 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if (!is_obj_moving (p_obj))
    return;
  clear_dX_dY (p_obj);
  gen_audio_XYZ_wipe_and_draw (p_obj);
}

// $C4D3
// tree wall
void upd_128_to_130 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -2, -8);
}

// $C4D8
void adj_m4_m12 (POBJ32 p_obj)
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

// $C4F7
void adj_m8_m12 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -8, -12);
}

// $C4FC
void adj_m7_m12 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -7, -12);
}

// $C501
void adj_m12_m12 (POBJ32 p_obj)
{
  set_pixel_adj (p_obj, -12, -12);
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
  unsigned i;
   
  fprintf (stderr, "%s(): screen=%d\n", 
            __FUNCTION__,
            graphic_objs_tbl[0].scrn);
  
  for (i=0; i<32; i++)
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
    
    p_special_obj++;
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
  unsigned i;
  
  for (i=0; i<2; i++)
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
// ghost (eg. room 1)
void upd_80_to_83 (POBJ32 p_obj)
{
  adj_m6_m12 (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->d_x == 0 && p_obj->d_y == 0) ||
      ((p_obj->flags12 & (FLAG_Y_OOB|FLAG_X_OOB)) != 0))
  {
    p_obj->d_x = get_delta_from_tbl ((seed_3 & 3) + 4);
    p_obj->d_y = get_delta_from_tbl ((seed_2 & 3) + 4);
    calc_ghost_sprite (p_obj);
    //gen_audio_XYZ ();
  }
  toggle_next_prev_sprite (p_obj);
  // jp loc_B856
  sub_B85C (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $C603
void calc_ghost_sprite (POBJ32 p_obj)
{
  if (abs(p_obj->d_x) < abs(p_obj->d_y))
  {
    if (p_obj->d_y < 0)
      p_obj->graphic_no &= ~(1<<1);   // 80/81
    else
      p_obj->graphic_no |= (1<<1);    // 82/83
    p_obj->flags &= ~FLAG_HFLIP;
  }
  else
  {
    if (p_obj->d_x < 0)
      p_obj->graphic_no |= (1<<1);    // 82/83
    else
      p_obj->graphic_no &= ~(1<<1);   // 80/81
    p_obj->flags |= FLAG_HFLIP;
  }
}

// $C645
int8_t get_delta_from_tbl (unsigned i)
{
  static int8_t delta_tbl[] =
  {
    -1, 1, -2, 2, -3, 3, -4, 4, -5, 5, -6, 6, -7, 7, -8, 8
  };
  
  return (delta_tbl[i]);
}

// $C65E
// portcullis (stationary) (eg. room 9)
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
// portcullis (moving) (eg. room 9)
void upd_9 (POBJ32 p_obj)
{
  //fprintf (stderr, "%s()\n", __FUNCTION__);
  
  adj_m6_m12 (p_obj);
  p_obj->flags13 |= (1<<7);
  if ((graphic_objs_tbl[0].flags12 & 0xF0) != 0)
    return;
  if (p_obj->d_z < 0)
  {
    p_obj->d_z--;
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->flags12 & FLAG_Z_OOB)
    {
      //gen_audio_rnd();
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

// $C823
// human legs
void upd_16_to_21_24_to_29 (POBJ32 p_obj)
{
  adj_m6_m12 (p_obj);
  upd_player_legs (p_obj);  
}

// $C828
// wulf legs
void upd_48_to_53_56_to_61 (POBJ32 p_obj)
{
  adj_m7_m12 (p_obj);
  upd_player_legs (p_obj);
}

// $C82B
// handles human and wulf legs
void upd_player_legs (POBJ32 p_obj)
{
  POBJ32 p_next_obj = p_obj+1;
  
  if ((p_obj->flags13 & (1<<6)) != 0 &&
      byte_5BC3 == 0)
  {
    p_next_obj->flags13 |= (1<<6);
    init_sparkles (p_obj);
  }
  else
  {
    // heaps of shit
    set_wipe_and_draw_flags (p_obj);
  }
}

// $C9F3
void clear_dX_dY (POBJ32 p_obj)
{
  p_obj->d_x = 0;
  p_obj->d_y = 0;
}

// $CA5A
int8_t adj_dZ_for_out_of_bounds (POBJ32 p_obj, int8_t d_z)
{
  do
  {
    if ((uint8_t)(p_obj->z + d_z) >= room_size_Z)
      return (d_z);
    p_obj->flags12 |= FLAG_Z_OOB;
    d_z = adj_d_for_out_of_bounds (d_z);
    
  } while (d_z != 0);
  
  return (d_z);
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

  d_x = p_obj->d_x;
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
  if ((p_obj->flags12 & 0xF0) != 0)
    return (d_x);
  if ((p_obj->flags & (1<<0)) != 0)
    return (d_x);
  do
  {
    if (abs(p_obj->x + d_x - 128) + p_obj->width < room_size_X)
      return (d_x);
    p_obj->flags12 |= FLAG_X_OOB;
    d_x = adj_d_for_out_of_bounds (d_x);
    
  } while (d_x != 0);
    
  return (d_x);
}

// $CD08
int8_t adj_dY_for_out_of_bounds (POBJ32 p_obj, int8_t d_y)
{
  if ((p_obj->flags12 & 0xF0) != 0)
    return (d_y);
  if ((p_obj->flags & (1<<0)) != 0)
    return (d_y);
  do
  {
    if (abs(p_obj->y + d_y - 128) + p_obj->depth < room_size_Y)
      return (d_y);
    p_obj->flags12 |= FLAG_Y_OOB;
    d_y = adj_d_for_out_of_bounds (d_y);
    
  } while (d_y != 0);
    
  return (d_y);
}

// $CDDA
// player (top half)
void upd_32_to_47 (POBJ32 p_obj)
{
  adj_m8_m12 (p_obj);
  upd_player_top (p_obj);
}

// $CDDF
// player (wulf half)
void upd_64_to_79 (POBJ32 p_obj)
{
  adj_m12_m12 (p_obj);
  upd_player_top (p_obj);
}

// $CDDA
void upd_player_top (POBJ32 p_obj)
{
  if (byte_5BC3 == 0 &&
      (p_obj->flags13 & (1<<6)) != 0)
    init_sparkles (p_obj);
  else
  {
    // heaps of shit
    // this is a fudge - remove me!
    set_wipe_and_draw_flags (p_obj);
  }
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
  unsigned i;
  
  //fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (i=0; i<40; i++)
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
  unsigned i;
  
  for (i=0; objects_to_draw[i] != 0xFF; i++)
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
  // set graphic_no for player sprites (after sparkles)
  plyr_spr_1_scratchpad.plyr_graphic_no = 18;   // legs
  plyr_spr_2_scratchpad.plyr_graphic_no = 34;   // top half
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
  ball_bounce_height = 0;
  // stuff
  initial_rendering = 1;
  // spiked balls don't drop immediately in odd-numbered rooms
  disable_spike_ball_drop = graphic_objs_tbl[0].scrn & 1;
  flag_room_visited ();
}

// $D219
void flag_room_visited (void)
{
  uint8_t scrn = graphic_objs_tbl[0].scrn;
  room_visited[scrn>>3] |= 1<<(scrn&7);
}

// $D237
uint8_t *transfer_sprite (POBJ32 p_obj, uint8_t *psprite)
{
  p_obj->graphic_no = *(psprite++);
  p_obj->flags = *(psprite++);
  p_obj->pixel_x = *(psprite++);
  p_obj->pixel_y = *(psprite++);

  return (psprite);
}

// $D24C
uint8_t *transfer_sprite_and_print (POBJ32 p_obj, uint8_t *psprite)
{
  uint8_t *p = transfer_sprite (p_obj, psprite);
  print_sprite (p_obj);

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
  unsigned n_other_objs = 0;
  unsigned p = 0;
  unsigned i;

  uint8_t id;
  uint8_t size;
  uint8_t attr;
    
  fprintf (stderr, "%s():\n", __FUNCTION__);
  
  for (i=0; ; i++)
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
  
  id = location_tbl[p++];
  size = location_tbl[p++];
  attr = location_tbl[p++];

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
    uint8_t *p_bg_obj;

    next_bg_obj:
    
    // get background type
    p_bg_obj = background_type_tbl[location_tbl[p]];

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
      n_other_objs++;
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
      // LOC = |  Z  |   Y   |   X   |
      //       | 7 6 | 5 4 3 | 2 1 0 |
      uint8_t *p_fg_obj = block_type_tbl[block];
      uint8_t loc = location_tbl[p];

      for (; *p_fg_obj!=0; p_fg_obj+=6)
      {
        // OFF = |      Z1     | Y1| X1|
        //       | 7 6 5 4 3 2 | 1 | 0 |
        
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

        // debug: (don't) include 62
        //if (p_other_objs->graphic_no == 23)
        //if (0)
        {
          p_other_objs++;
          n_other_objs++;
        }
      }
    }
  }
  
  fprintf (stderr, "n_other_objs = %d\n", n_other_objs);

  // clear the rest of the table
  for (; n_other_objs<40-4; n_other_objs++)
    memset (p_other_objs++, 0, sizeof(OBJ32));
            
  dump_graphic_objs_tbl(-1, -1);
}

// $D55F
void clear_scrn (void)
{
	osd_cls ();
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
uint8_t *flip_sprite (POBJ32 p_obj)
{
  uint8_t *psprite = sprite_tbl[p_obj->graphic_no];
  
  uint8_t vflip = (p_obj->flags ^ (*psprite)) & FLAG_VFLIP;
  uint8_t hflip = (p_obj->flags ^ (*psprite)) & FLAG_HFLIP;

  uint8_t w = psprite[0] & 0x3f;
  uint8_t h = psprite[1];

  unsigned x, y;

  if (vflip)
  {
    for (x=0; x<w; x++)
      for (y=0; y<h/2; y++)
      {
        uint8_t t = psprite[3+2*(y*w+x)];
        psprite[3+2*(y*w+x)] = psprite[3+2*((h-1-y)*w+x)];
        psprite[3+2*((h-1-y)*w+x)] = t;
      }
    *psprite ^= 0x80;
  }

  if (hflip)
  {
    for (y=0; y<h; y++)
    {
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
  
  // debug only
  //if (p_obj->graphic_no != 2 && p_obj->graphic_no != 3)
  //if (p_obj->graphic_no == 7)
  {
    print_sprite (p_obj);

    //uint8_t i = p_obj - graphic_objs_tbl;
    //dump_graphic_objs_tbl (i, i+1);
    //while (!key[KEY_SPACE]);
    //while (key[KEY_SPACE]);
  }
}

// $D718
void print_sprite (POBJ32 p_obj)
{
  osd_print_sprite (p_obj);
}
