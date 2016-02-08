#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#define DBGPRINTF_FN    DBGPRINTF ("%s():\n", __FUNCTION__)
//#define UNTESTED        DBGPRINTF ("*** %s(): UNTESTED ***\n", __FUNCTION__)
#define UNTESTED        
//#define UNIMPLEMENTED   DBGPRINTF ("*** %s(): UNMIPLEMENTED ***\n", __FUNCTION__)
#define UNIMPLEMENTED   
#define UNIMPLEMENTED_AUDIO

// build options - all disabled for 'production' build
//#define BUILD_OPT_DISABLE_WIPE
//#define BUILD_OPT_DISABLE_Z_ORDER
//#define BUILD_OPT_ENABLE_TELEPORT
//#define BUILD_OPT_ALMOST_INVINCIBLE

#pragma pack(1)

// user input
#define INP_LEFT            (1<<0)
#define INP_RIGHT           (1<<1)
#define INP_FORWARD         (1<<2)
#define INP_JUMP            (1<<3)
#define INP_PICKUP_DROP     (1<<4)
                            
// byte offset 7 flags      
#define FLAG_VFLIP          (1<<7)
#define FLAG_HFLIP          (1<<6)
#define FLAG_WIPE           (1<<5)
#define FLAG_DRAW           (1<<4)
#define FLAG_AUTO_ADJ       (1<<3)    // for arches
#define FLAG_MOVEABLE       (1<<2)    // (sic)
#define FLAG_IGNORE_3D      (1<<1)    // ignore for 3D calcs
#define FLAG_NEAR_ARCH      (1<<0)
                          
// byte offset 12 flags   
#define MASK_ENTERING_SCRN  0xF0
#define FLAG_JUMPING        (1<<3)
#define FLAG_Z_OOB          (1<<2)
#define FLAG_Y_OOB          (1<<1)
#define FLAG_X_OOB          (1<<0)
                            
// byte offset 13 flags     
#define FLAG_FATAL_HIT_YOU  (1<<7)    // deadly if it hits you
#define FLAG_DEAD           (1<<6)    // player
#define FLAG_FATAL_YOU_HIT  (1<<5)    // deadly if you hit it
#define FLAG_TRIGGERED      (1<<3)    // dropping, collapsing block
#define FLAG_UP             (1<<2)    // bouncing ball
#define FLAG_DROPPING       (1<<2)    // spiked ball
#define FLAG_NORTH          (1<<1)    // NS fire
#define FLAG_EAST           (1<<0)    // EW fire, EW guard
#define FLAG_JUST_DROPPED   (1<<0)    // special objects
#define MASK_DIR            0x03      // NSEW guard & wizard
#define MASK_LOOK_CNT       0x0F      // player (top, look around cnt)
#define MASK_TURN_DELAY     0x07      // player (bottom)
                            
#define MAX_OBJS            40                          
#define CAULDRON_SCREEN     136
// standard is 5            
#define NO_LIVES            5

#include "osd_types.h"
#include "kl_osd.h"
#include "kl_dat.h"

#ifdef __HAS_SETJMP__
  #include <setjmp.h>
#endif

typedef void (*adjfn_t)(POBJ32 p_obj);

typedef struct
{
  uint8_t   turbo;
  uint8_t   exit_scrn;
  
} INTERNAL, *PINTERNAL;
static INTERNAL internal = { 0, 0 };

#ifdef __HAS_SETJMP__
  static jmp_buf start_menu_env_buf;
  static jmp_buf game_loop_env_buf;
#endif

// start of variables

static uint8_t seed_1;                                // $5BA0
static uint16_t seed_2;                               // $5BA2
static uint8_t user_input_method;                     // $5BA4
static uint8_t seed_3;                                // $5BA5
static uint8_t tmp_input_method;                      // $5BA6

// cleared each game ($5BA8-$6107)
static uint8_t objs_wiped_cnt;                        // $5BA8
// uint16_t tmp_SP                                    // $5BA9
static uint8_t room_size_X;                           // $5BAB
static uint8_t room_size_Y;                           // $5BAC
static uint8_t curr_room_attrib;                      // $5BAD
static uint8_t room_size_Z;                           // $5BAE
static uint8_t portcullis_moving;                     // $5BAF
static uint8_t portcullis_move_cnt;                   // $5BB0
static uint8_t transform_flag_graphic;                // $5BB1
static uint8_t not_1st_screen;                        // $5BB2
static uint8_t pickup_drop_pressed;                   // $5BB3
static uint8_t objects_carried_changed;               // $5BB4
static uint8_t user_input;                            // $5BB5
static uint8_t tmp_attrib;                            // $5BB6
static uint8_t render_status_info;                    // $5BB7
static uint8_t suppress_border;                       // $5BB8
static uint8_t days;                                  // $5BB9
static int8_t lives;                                  // $5BBA
static uint8_t objects_put_in_cauldron;               // $5BBB
static uint8_t fire_seed;                             // $5BBC
static uint8_t ball_bounce_height;                    // $5BBD
static uint8_t rendered_objs_cnt;                     // $5BBE
static uint8_t is_spike_ball_dropping;                // $5BBF
static uint8_t disable_spike_ball_drop;               // $5BC0
static int8_t tmp_dZ;                                 // $5BC1
static int8_t tmp_bouncing_ball_dZ;                   // $5BC2
static uint8_t all_objs_in_cauldron;                  // $5BC3
static uint8_t obj_dropping_into_cauldron;            // $5BC4
static uint8_t rising_blocks_Z;                       // $5BC5
static uint8_t num_scrns_visited;                     // $5BC6
static uint8_t *gfxbase_8x8;                          // $5BC7
static uint8_t percent_msw;                           // $5BC9
static uint8_t percent_lsw;                           // $5BCA
static uint8_t *tmp_objects_to_draw;                  // $5BCB
static uint16_t render_obj_1;                         // $5BCD
static uint16_t render_obj_2;                         // $5BCF
static uint8_t audio_played;                          // $5BD1
static uint8_t directional;                           // $5BD2
static uint8_t cant_drop;                             // $5BD3
static INVENTORY inventory[4];                        // $5BD8
static PINVENTORY objects_carried =
                &inventory[1];                        // $5BDC
static uint8_t scrn_visited[32];                      // $5BE8
static OBJ32 graphic_objs_tbl[MAX_OBJS];              // $5C08
const POBJ32 special_objs_here = 
              &graphic_objs_tbl[2];                   // $5C48
const POBJ32 other_objs_here =
              &graphic_objs_tbl[4];                   // $5C88
              
static OBJ32 sprite_scratchpad;                       // $BFDB
static OBJ32 sun_moon_scratchpad;                     // $C44D
static uint8_t objects_to_draw[48];                   // $CE8B
static OBJ32 plyr_spr_1_scratchpad;                   // $D161
static OBJ32 plyr_spr_2_scratchpad;                   // $D181

typedef struct
{
  uint8_t   x;              // pixel
  uint8_t   y;              // pixel
  uint8_t   width_bytes;
  uint8_t   height_lines;

} OBJ_WIPED, *POBJ_WIPED;

OBJ_WIPED objs_wiped_stack[MAX_OBJS];

// end of variables

// start of prototypes

static void reset_objs_wipe_flag (void);
static void play_audio_wait_key (const uint8_t *audio_data);
static void play_audio_until_keypress (const uint8_t *audio_data);
static void play_audio (const uint8_t *audio_data);
static void audio_B3E9 (void);
static void audio_B403 (POBJ32 p_obj);
static void audio_B419 (POBJ32 p_obj);
static void audio_B42E (void);
static void audio_B441 (void);
static void audio_B451 (POBJ32 p_obj);
static void audio_B454 (uint8_t a);
static void audio_B45D (POBJ32 p_obj);
static void audio_B462 (POBJ32 p_obj);
static void audio_B467 (POBJ32 p_obj);
static void audio_B472 (POBJ32 p_obj);
static void audio_B489 (void);
static void audio_guard_wizard (POBJ32 p_obj);
static void audio_B4BB (POBJ32 p_obj);
static void audio_B4C1 (POBJ32 p_obj);
static uint8_t do_any_objs_intersect (POBJ32 p_obj);
static uint8_t is_object_not_ignored (POBJ32 p_obj);
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
static void upd_150_151 (POBJ32 p_obj);
static void set_guard_wizard_sprite (POBJ32 p_obj);
static void upd_22 (POBJ32 p_obj);
static void upd_63 (POBJ32 p_obj);
static void upd_23 (POBJ32 p_obj);
static void upd_86_87 (POBJ32 p_obj);
static void upd_180_181 (POBJ32 p_obj);
static void upd_176_177 (POBJ32 p_obj);
static void set_deadly_wipe_and_draw_flags (POBJ32 p_obj);
static void set_both_deadly_flags (POBJ32 p_obj);
static void upd_178_179 (POBJ32 p_obj);
static void init_cauldron_bubbles (void);
static void upd_160_to_163 (POBJ32 p_obj);
static void upd_168_to_175 (POBJ32 p_obj);
static void upd_164_to_167 (POBJ32 p_obj);
static void upd_111 (POBJ32 p_obj);
static void move_towards_plyr (POBJ32 p_obj, int8_t d_x, int8_t d_y);
static void toggle_next_prev_sprite (POBJ32 p_obj);
static void next_graphic_no_mod_4 (POBJ32 p_obj);
static void upd_141 (POBJ32 p_obj);
static void upd_142 (POBJ32 p_obj);
static void upd_30_31_158_159 (POBJ32 p_obj);
static void move_guard_wizard_NSEW (POBJ32 p_obj, int8_t *dx, int8_t *dy);
static void wait_for_key_release (void);
static void game_over (void);
static void calc_and_display_percent (void);
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
static void multiple_print_sprite (uint8_t type, POBJ32 p_obj, uint8_t dx, uint8_t dy, uint8_t n);
static void upd_120_to_126 (POBJ32 p_obj);
static void upd_127 (POBJ32 p_obj);
static void init_death_sparkles (POBJ32 p_obj);
static void upd_112_to_118_184 (POBJ32 p_obj);
static void upd_185_187 (POBJ32 p_obj);
static void upd_119 (POBJ32 p_obj);
static void display_objects_carried (void);
static void display_objects (void);
static void adj_m8_m12 (POBJ32 p_obj);
static uint8_t chk_pickup_drop (void);
static void handle_pickup_drop (POBJ32 p_obj);
static uint8_t can_pickup_spec_obj (POBJ32 p_obj, POBJ32 p_other);
static uint8_t is_on_or_near_obj (POBJ32 p_obj, POBJ32 p_other);
static uint8_t is_obj_moving (POBJ32 p_obj);
static void upd_103 (POBJ32 p_obj);
static void upd_104_to_110 (POBJ32 p_obj);
static void audio_B467_wipe_and_draw (POBJ32 p_obj);
static uint8_t ret_next_obj_required (void);
static void upd_96_to_102 (POBJ32 p_obj);
static void cycle_colours_with_sound (POBJ32 p_obj);
static void no_update (POBJ32 p_obj);
static void prepare_final_animation (void);
static int chk_and_init_transform (POBJ32 p_obj);
static void upd_92_to_95 (POBJ32 p_obj);
static void rand_legs_sprite (POBJ32 p_obj);
static void print_sun_moon (void);
static void display_sun_moon_frame (POBJ32 p_obj);
static void blit_2x8 (uint8_t x, uint8_t y);
static void init_sun (void);
static void init_special_objects (void);
static void upd_62 (POBJ32 p_obj);
static void upd_85 (POBJ32 p_obj);
static void upd_84 (POBJ32 p_obj);
static void dec_dZ_upd_XYZ_wipe_if_moving (POBJ32 p_obj);
static void upd_128_to_130 (POBJ32 p_obj);
static void adj_m6_m12 (POBJ32 p_obj);
static void upd_6_7 (POBJ32 p_obj);
static void upd_10 (POBJ32 p_obj);
static void upd_11 (POBJ32 p_obj);
static void upd_12_to_15 (POBJ32 p_obj);
static void adj_m4_m12 (POBJ32 p_obj);
static void adj_m7_m12 (POBJ32 p_obj);
static void adj_m12_m12 (POBJ32 p_obj);
static void upd_88_to_90 (POBJ32 p_obj);
static void fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c);
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
static void chk_plyr_spec_near_arch (POBJ32 p_obj, uint8_t near_x, uint8_t near_y);
static uint8_t is_near_to (POBJ32 p_obj, POBJ32 p_other, uint8_t near_x, uint8_t near_y);
static void upd_16_to_21_24_to_29 (POBJ32 p_obj);
static void upd_48_to_53_56_to_61 (POBJ32 p_obj);
static void upd_player_bottom (POBJ32 p_obj);
static uint8_t chk_plyr_OOB (POBJ32 p_obj);
static void handle_left_right (POBJ32 p_obj, uint8_t inp);
static void handle_jump (POBJ32 p_obj, uint8_t inp);
static void handle_forward (POBJ32 p_obj, uint8_t inp);
static void animate_guard_wizard_legs (POBJ32 p_obj);
static uint8_t move_player (POBJ32 p_obj, uint8_t c);
static void clear_dX_dY (POBJ32 p_obj);
static void calc_plyr_dXY (POBJ32 p_obj);
static uint8_t get_sprite_dir (POBJ32 p_obj);
static int8_t adj_dZ_for_out_of_bounds (POBJ32 p_obj, int8_t d_z);
static uint8_t handle_exit_screen (POBJ32 p_obj);
static int8_t adj_d_for_out_of_bounds (int8_t d);
static void adj_for_out_of_bounds (POBJ32 p_obj);
static int8_t adj_dX_for_obj_intersect (POBJ32 p_obj, int8_t d_x, int8_t d_y, int8_t d_z);
static int8_t adj_dY_for_obj_intersect (POBJ32 p_obj, int8_t d_x, int8_t d_y, int8_t d_z);
static int8_t adj_dZ_for_obj_intersect (POBJ32 p_obj, int8_t d_x, int8_t d_y, int8_t d_z);
static uint8_t do_objs_intersect_on_x (POBJ32 p_obj, POBJ32 p_other, int8_t d_x);
static uint8_t do_objs_intersect_on_y (POBJ32 p_obj, POBJ32 p_other, int8_t d_y);
static uint8_t do_objs_intersect_on_z (POBJ32 p_obj, POBJ32 p_other, int8_t d_z);
static int8_t adj_dX_for_out_of_bounds (POBJ32 p_obj, int8_t d_x);
static int8_t adj_dY_for_out_of_bounds (POBJ32 p_obj, int8_t d_y);
static void calc_2d_info (POBJ32 p_obj);
static void set_draw_objs_overlapped (POBJ32 p_obj);
static void upd_32_to_47 (POBJ32 p_obj);
static void upd_64_to_79 (POBJ32 p_obj);
static void upd_player_top (POBJ32 p_obj);
static void save_2d_info (POBJ32 p_obj);
static void list_objects_to_draw (void);
static void calc_display_order_and_render (void);
static uint8_t check_user_input (void);
static int lose_life (void);
static void init_start_location (void);
static void build_screen_objects (void);
static void flag_scrn_visited (void);
static uint8_t *transfer_sprite (POBJ32 p_obj, uint8_t *psprite);
static uint8_t *transfer_sprite_and_print (uint8_t type, POBJ32 p_obj, uint8_t *psprite);
static void display_panel (void);
static void print_border (void);
static void colour_panel (void);
static void colour_sun_moon (void);
static void adjust_plyr_xyz_for_room_size (POBJ32 p_obj);
static void adjust_plyr_Z_for_arch (POBJ32 p_obj, uint8_t xy);
static void retrieve_screen (void);
static void audio_D50E (void);
static void fill_attr (uint8_t attr);
static void clear_scrn (void);
static void clear_scrn_buffer (void);
static void update_screen (void);
static void render_dynamic_objects (void);
static void blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines);
static uint8_t calc_pixel_XY (POBJ32 p_obj);
uint8_t *flip_sprite (POBJ32 p_obj);
static void calc_pixel_XY_and_render (POBJ32 p_obj);
static void print_sprite (uint8_t type, POBJ32 p_obj);

// end of prototypes

void dump_graphic_objs_tbl (int start, int end)
{
  unsigned i = (start == -1 ? 0 : start);
  
  DBGPRINTF_FN;
  
  for (; i<end && i<MAX_OBJS; i++)
  {
    DBGPRINTF ("%02d: graphic_no=%03d, s=%d, (%3d,%3d,%3d) %02dx%02dx%02d, f=$%02X @(%02d,%02d)\n",
              i,
              graphic_objs_tbl[i].graphic_no,
              graphic_objs_tbl[i].unused[0],
              graphic_objs_tbl[i].x,
              graphic_objs_tbl[i].y,
              graphic_objs_tbl[i].z,
              graphic_objs_tbl[i].width,
              graphic_objs_tbl[i].depth,
              graphic_objs_tbl[i].height,
              graphic_objs_tbl[i].flags7,
              graphic_objs_tbl[i].pixel_x,
              graphic_objs_tbl[i].pixel_y);
  }
}

void dump_special_objs_tbl (void)
{
  unsigned i;
  
  DBGPRINTF_FN;
  
  for (i=0; i<32; i++)
  {
    DBGPRINTF ("%02d: graphic_no=%02d, x=%d, y=%d, z=%d, start_scrn=$%02X\n",
              i,
              special_objs_tbl[i].graphic_no,
              special_objs_tbl[i].start_x,
              special_objs_tbl[i].start_y,
              special_objs_tbl[i].start_z,
              special_objs_tbl[i].start_scrn);
  }
}

void dump_objects_to_draw (void)
{
  unsigned i;

  DBGPRINTF ("objects_to_draw[] =\n");
  for (i=0; objects_to_draw[i] != 0xff; i++)
    DBGPRINTF ("$%02X, ", objects_to_draw[i]);
  DBGPRINTF ("\n");
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
    DBGPRINTF ("%s(%d=$%02X) @$%04X\n",
              __FUNCTION__,
              obj->graphic_no, 
              obj->graphic_no,
              0xB096+2*obj->graphic_no);
    printed[obj->graphic_no] = 1;
  }
}

extern adjfn_t const upd_sprite_jump_tbl[];

void knight_lore (void)
{
  POBJ32 p_obj;
  unsigned i;

  DBGPRINTF_FN;

START_AF6C:

  // the original code initialises seed_1
  // with [$5C78] (uninitialised RAM)
  // - under MESS using knightlore.sna
  //   that value is $00
    
  {
    // fudge fudge fudge
    // clear variables $5BA0-$6107
    uint8_t *p = (uint8_t *)&seed_1;
    while (p < (uint8_t *)&sprite_scratchpad)
      *(p++) = 0;
      
    seed_1 = 0x00;    // to match MESS emulation
    goto MAIN_AF88;
  }

START_MENU_AF7F:

#ifdef __HAS_SETJMP__
  setjmp (start_menu_env_buf);
#endif
  {
    // fudge fudge fudge
    // clear variables $5BA8-$6107
    uint8_t *p = (uint8_t *)&objs_wiped_cnt;
    while (p < (uint8_t *)&sprite_scratchpad)
      *(p++) = 0;
  }

MAIN_AF88:

  //build_lookup_tbls ();
  not_1st_screen = 0;
  plyr_spr_1_scratchpad.flags12 = 0;
  lives = NO_LIVES;
  // update seed
  seed_1 += seed_2;
  clear_scrn ();
  do_menu_selection ();
  play_audio (start_game_tune);
  shuffle_objects_required ();
  // randomise
  init_start_location ();
  init_sun ();
  // randomise
  init_special_objects ();

player_dies:
  // call lose_life()->jp game_over()->jp start_menu
  // leaves a return address on the stack
  // - but update_sprite_loop re-init's the stack ptr
  //   each operation, so doesn't matter
  // * now uses longjmp
  if (lose_life () < 0)
    goto START_MENU_AF7F;

game_loop:

#ifdef __HAS_SETJMP__
  setjmp (game_loop_env_buf);
#endif

  // required for C implementation
  internal.exit_scrn = 0;
  
  build_screen_objects ();

onscreen_loop:

  fire_seed = seed_2;
    
  p_obj = graphic_objs_tbl;
  for (i=0; i<MAX_OBJS; i++, p_obj++)
  {
    uint8_t r;

  update_sprite_loop:

    // the Z80 code re-init'd SP here!
    
    fire_seed++;      
    save_2d_info (p_obj);

    // added sanity-checking
    if (p_obj->graphic_no > 187)
      upd_not_implemented (p_obj);
    else
    {
      upd_sprite_jump_tbl[p_obj->graphic_no] (p_obj);

      // required for C implementation
      if (internal.exit_scrn == 1)
        goto game_loop;
    }

    // update seed_3
    // original code uses the Z80 refresh (R) register
    r = rand ();
    seed_3 += r;
  }

  // update seed_2, 3
  seed_2++;
  // this was originally [HL] where HL=seed2
  seed_3 += rand ();
  seed_3 += seed_2;           // add a,l
  seed_3 += (seed_2 >> 8);    // add a,h

  not_1st_screen |= (1<<0);
  audio_D50E ();
  init_cauldron_bubbles ();
  list_objects_to_draw ();
  render_dynamic_objects ();
  if (rising_blocks_Z != 0)
    audio_B454 (0);   // *** FIXME

  // calc game delay loop
  // using rendered_objs_cnt

game_delay:
  // last to-do  
  osd_delay (internal.turbo ? 5 : 50);

  if (render_status_info)
  {
    render_status_info = 0;
    fill_attr (curr_room_attrib);
    display_objects ();
    colour_panel ();
    colour_sun_moon ();
    display_panel ();
    display_sun_moon_frame (&sun_moon_scratchpad);
    display_day ();
    print_days ();
    print_lives_gfx ();
    print_lives ();
    update_screen ();
    reset_objs_wipe_flag ();
  }

  rising_blocks_Z = 0;
  if (graphic_objs_tbl[0].graphic_no == 0 &&
      graphic_objs_tbl[1].graphic_no == 0)
    goto player_dies;

/////////////////////////////////
// start of development hook
/////////////////////////////////

  if (osd_key(OSD_KEY_ESC))
    return;

  if (osd_key(OSD_KEY_F))
  {
    // wait until release
    while (osd_key(OSD_KEY_F));
    // wait until press
    while (!osd_key(OSD_KEY_F));
    // wait until release
    while (osd_key(OSD_KEY_F));
  }

#ifdef BUILD_OPT_ENABLE_TELEPORT
    
  if (osd_key(OSD_KEY_N))
  {
    handle_exit_screen (&graphic_objs_tbl[0]);
    goto game_loop;
  }
  
  if (osd_key(OSD_KEY_S))
  {
    handle_exit_screen (&graphic_objs_tbl[0]);
    goto game_loop;
  }
  
  if (osd_key(OSD_KEY_E))
  {
    handle_exit_screen (&graphic_objs_tbl[0]);
    goto game_loop;
  }
  
  if (osd_key(OSD_KEY_W))
  {
    handle_exit_screen (&graphic_objs_tbl[0]);
    goto game_loop;
  }

  if (osd_key(OSD_KEY_G))
  {
    uint8_t scrn = 0;
    unsigned i;
        
    while (osd_keypressed ())
      osd_readkey ();
    DBGPRINTF ("GOTO: ");
    for (i=0; i<3; i++)
    {
      int c;
      do
      {
        c = osd_readkey () & 0xff;
      } while (!isdigit(c));
      
      DBGPRINTF ("%c", c);
      scrn = (scrn * 10) + c - '0';
    }
    DBGPRINTF ("\n");
    graphic_objs_tbl[0].scrn = scrn;

    handle_exit_screen (&graphic_objs_tbl[0]);
    goto game_loop;
  }

  if (osd_key(OSD_KEY_P))
  {
    static unsigned s_no = 0;
    
    DBGPRINTF ("s_no=%d, start_scrn=%d\n", 
              s_no, special_objs_tbl[s_no].start_scrn);
    graphic_objs_tbl[0].scrn = special_objs_tbl[s_no].start_scrn;
    s_no = (s_no + 1) % 32;

    handle_exit_screen (&graphic_objs_tbl[0]);
    goto game_loop;
  }

#endif //BUILD_OPT_ENABLE_TELEPORT
    
  if (osd_key(OSD_KEY_T))
  {
    internal.turbo = !internal.turbo;
    while (osd_key(OSD_KEY_T));
  }
    
  if (osd_key(OSD_KEY_D))
  {
    dump_graphic_objs_tbl (-1, -1);
  }

/////////////////////////////////
// end of development hook
/////////////////////////////////
    
  goto onscreen_loop;
}

// $B088
void reset_objs_wipe_flag (void)
{
  unsigned i;
  
  for (i=0; i<MAX_OBJS; i++)
    graphic_objs_tbl[i].flags7 &= ~FLAG_WIPE;
}

// $B096
adjfn_t const upd_sprite_jump_tbl[] =
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
  upd_112_to_118_184,           // death sparkles
  upd_112_to_118_184,           // "
  upd_112_to_118_184,           // "
  upd_112_to_118_184,           // "
  upd_112_to_118_184,           // "
  upd_112_to_118_184,           // "
  upd_112_to_118_184,           // "
  upd_119,                      // last death sparkle
  upd_120_to_126,               // player appear sparkles
  upd_120_to_126,               // "
  upd_120_to_126,               // "
  upd_120_to_126,               // "
  upd_120_to_126,               // "
  upd_120_to_126,               // "
  upd_120_to_126,               // "
  upd_127,                      // last player appears sparkle
  upd_128_to_130,               // tree wall
  upd_128_to_130,               // tree wall
  upd_128_to_130,               // tree wall
  upd_131_to_133,               // sparkles in cauldron room end of game
  upd_131_to_133,               // "
  upd_131_to_133,               // "
  no_update,
  no_update,
  no_update,
  no_update,
  no_update,
  no_update,
  no_update,
  upd_141,                      // cauldron (bottom)
  upd_142,                      // cauldron (top)
  upd_143,                      // block (collapsing)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_144_to_149_152_to_157,    // guard & wizard (bottom half)
  upd_150_151,                  // guard (EW)
  upd_150_151,                  // guard (EW)
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
void play_audio_wait_key (const uint8_t *audio_data)
{
  UNTESTED;
  
  if (audio_played != 0)
    return;
  audio_played |= (1<<0);

  play_audio_until_keypress (audio_data);  
}

// $B2BE
void play_audio_until_keypress (const uint8_t *audio_data)
{
  UNIMPLEMENTED_AUDIO;

  while (1)
  {
    //if (read_key (0))
      return;
    // keep playing audio
  }
}

// $B2CF
void play_audio (const uint8_t *audio_data)
{
  UNIMPLEMENTED_AUDIO;
}

// $B3E9
void audio_B3E9 (void)
{
  UNIMPLEMENTED_AUDIO;
}

// $B403
void audio_B403 (POBJ32 p_obj)
{
  UNIMPLEMENTED_AUDIO;
}

// $B419
void audio_B419 (POBJ32 p_obj)
{
  UNIMPLEMENTED_AUDIO;
}

// $B42E
void audio_B42E (void)
{
  UNIMPLEMENTED_AUDIO;
}

// $B441
void audio_B441 (void)
{
  UNIMPLEMENTED_AUDIO;
}

// $B451
void audio_B451 (POBJ32 p_obj)
{
  UNIMPLEMENTED_AUDIO;
}

// $B454
void audio_B454 (uint8_t a)
{
  UNIMPLEMENTED_AUDIO;
}

// $B45D
void audio_B45D (POBJ32 p_obj)
{
  UNTESTED;
  
  audio_B454 (p_obj->x);
}

// $B462
void audio_B462 (POBJ32 p_obj)
{
  UNTESTED;
  
  audio_B454 (p_obj->y);
}

// $B467
void audio_B467 (POBJ32 p_obj)
{
  UNTESTED;
  
  audio_B454 (p_obj->x + p_obj->y + p_obj->z);
}

// $B472
void audio_B472 (POBJ32 p_obj)
{
}

// $B489
void audio_B489 (void)
{
}

// $B4AD
void audio_guard_wizard (POBJ32 p_obj)
{
}

// $B4BB
void audio_B4BB (POBJ32 p_obj)
{
}

// $B4C1
void audio_B4C1 (POBJ32 p_obj)
{
}

// $B4FD
uint8_t do_any_objs_intersect (POBJ32 p_obj)
{
  POBJ32    p_other;
  uint8_t   carry = 0;
  unsigned  i;
  
  UNTESTED;
  
  // don't test this object
  p_obj->flags7 |= FLAG_IGNORE_3D;

  p_other = graphic_objs_tbl;
  for (i=0; i<MAX_OBJS; i++, p_other++)
  {
    if (is_object_not_ignored (p_other) == 0)
      continue;
    if (do_objs_intersect_on_x (p_obj, p_other, 0) == 0)
      continue;
    if (do_objs_intersect_on_y (p_obj, p_other, 0) == 0)
      continue;
    if (do_objs_intersect_on_z (p_obj, p_other, 0) == 0)
      continue;
    carry = 1;
    break;
  }
  
  p_obj->flags7 &= ~FLAG_IGNORE_3D;
  return (carry);
}

// $B538
uint8_t is_object_not_ignored (POBJ32 p_obj)
{
  if (p_obj->graphic_no == 0)
    return (0);
  return ((p_obj->flags7 & FLAG_IGNORE_3D) ? 0 : 1);
}

// $B544
void shuffle_objects_required (void)
{
  uint8_t r = (seed_3 & 3) | 4;
    
  UNTESTED;
  
  for (; r; r--)
  {
    uint8_t e = objects_required[0];
    unsigned i;
    
    for (i=0; i<13; i++)
      objects_required[i] = objects_required[i+1];
    objects_required[i] = e;
  }  
}

// $B566
// sparkles from the blocks in the cauldron room
// at the end of the game
void upd_131_to_133 (POBJ32 p_obj)
{
  uint8_t a;

  UNTESTED;
  
  adj_m4_m12 (p_obj);
  if (p_obj->z < 164)
  {
    uint8_t r;
    
    p_obj->d_z = 3;
    a = ((p_obj->x >> 6) & (1<<1)) | ((p_obj->y >> 7) & (1<<0));
    switch (a)
    {
      case 0 :
        p_obj->d_x = -4;
        p_obj->d_y = 4;
        break;
      case 1 :
        p_obj->d_x = 4;
        p_obj->d_y = 4;
        break;
      case 2 :
        p_obj->d_x = -4;
        p_obj->d_y = -4;
        break;
      case 3 :
      default :
        p_obj->d_x = 4;
        p_obj->d_y = -4;
        break;
    }
    r = seed_3 & 3;
    if (r == 0) r++;
    p_obj->graphic_no = 130 + r;
  }
  else
  {
    if (abs(graphic_objs_tbl[0].x - p_obj->x) < 6 &&
        abs(graphic_objs_tbl[0].y - p_obj->y) < 6)
    {
      game_over ();
      // longjmp to start_menu
    }
    // only fatal if it hits you
    p_obj->flags13 |= FLAG_FATAL_HIT_YOU;
    p_obj->flags7 |= FLAG_IGNORE_3D;
    p_obj->d_z = 1;
    move_towards_plyr (p_obj, 4, 4);
  }
  rising_blocks_Z = p_obj->z;
  dec_dZ_wipe_and_draw (p_obj);
  set_wipe_and_draw_flags (p_obj);
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
// ball (bouncing around) (eg. room 8)
// - bounces towards human
// - bounces away from wulf
void upd_182_183 (POBJ32 p_obj)
{
  int8_t  d_x, d_y, d_z;
  uint8_t away = 1;
  
  UNTESTED;
  
  upd_12_to_15 (p_obj);
  d_x = p_obj->d_x;
  d_y = p_obj->d_y;
  tmp_bouncing_ball_dZ = p_obj->d_z;
  dec_dZ_and_update_XYZ (p_obj);
  // preserve old dX,dY
  p_obj->d_x = d_x;
  p_obj->d_y = d_y;
  // this was originally self-modifying code,
  // alternating between jr c & jr nc
  // in two (2) locations...
  // just use a boolean variable instead
  if ((graphic_objs_tbl[0].graphic_no - 0x10) < 0x20)
    away = 0;
  // bouncing height depends on screen ID
  if ((graphic_objs_tbl[0].scrn & 1) == 0)
    d_z = 4;
  else
    d_z = (seed_3 & 3) + 4;
  if ((p_obj->flags12 & FLAG_Z_OOB) != 0)
  {
    p_obj->d_z = d_z;
    if (tmp_bouncing_ball_dZ < 0)
      audio_B42E ();
    if ((rand () & 1) == 0)
    {
      int8_t s = ((graphic_objs_tbl[0].x - p_obj->x < 0) ? -1 : 1);
      p_obj->d_x = (away ? -2*s : 2*s);
      p_obj->d_y = 0;
    }
    else
    {
      int8_t s = ((graphic_objs_tbl[0].y - p_obj->y < 0) ? -1 : 1);
      p_obj->d_x = 0;
      p_obj->d_y = (away ? -2*s : 2*s);
    }
  }
  toggle_next_prev_sprite (p_obj);
  set_deadly_wipe_and_draw_flags (p_obj);
}

// $B683
// block (dropping) (eg. room 0)
void upd_91 (POBJ32 p_obj)
{
  UNTESTED;
  
  upd_6_7 (p_obj);
  if ((p_obj->flags13 & FLAG_TRIGGERED) == 0)
    return;
  p_obj->flags13 &= ~FLAG_TRIGGERED;
  p_obj->d_z = 0;
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags12 & FLAG_Z_OOB) == 0)
    audio_B451 (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B6A2
// block (collapsing)
void upd_143 (POBJ32 p_obj)
{
  UNTESTED;
  
  upd_6_7 (p_obj);
  if ((p_obj->flags13 & FLAG_TRIGGERED) == 0)
    return;
  p_obj->graphic_no = 184;
  upd_112_to_118_184 (p_obj);
}

// $B6B1
// block (moving NS) (eg. room 29)
void upd_55 (POBJ32 p_obj)
{
  uint8_t r;
  uint8_t x_y;
  
  if (p_obj->graphic_no == 54)
    audio_B45D (p_obj);
  else
    audio_B462 (p_obj);
    
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
  set_pixel_adj (p_obj, -6, -12);
  if (p_obj->d_x == 0 && p_obj->d_y == 0)
    return;
  audio_guard_wizard (p_obj);
  if ((uint8_t)p_obj->d_x < (uint8_t)p_obj->d_y)
  {
    if (p_obj->d_y < 0)
      p_obj->graphic_no |= (1<<3);
    else
      p_obj->graphic_no &= ~(1<<3);
    p_obj->flags7 |= FLAG_HFLIP;
  }
  else
  {
    if (p_obj->d_x < 0)
      p_obj->graphic_no &= ~(1<<3);
    else
      p_obj->graphic_no |= (1<<3);
    p_obj->flags7 &= ~FLAG_HFLIP;
  }
  animate_guard_wizard_legs (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B73C
// guard (EW) (eg. room 1)
void upd_150_151 (POBJ32 p_obj)
{
  POBJ32 p_next_obj = p_obj+1;
  
  set_pixel_adj (p_obj, 7, -12);
  p_obj->d_x = 2;
  if ((p_obj->flags13 & FLAG_EAST) == 0)
    p_obj->d_x = -p_obj->d_x;
  p_next_obj->d_x = p_obj->d_x;
  set_guard_wizard_sprite (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if (p_obj->flags12 & FLAG_X_OOB)
    p_obj->flags13 ^= FLAG_EAST;
  p_next_obj->x = p_obj->x;
  set_deadly_wipe_and_draw_flags (p_obj);
}

// $B76C
void set_guard_wizard_sprite (POBJ32 p_obj)
{
  if (p_obj->d_x == 0 && p_obj->d_y == 0)
    return;
  if ((uint8_t)p_obj->d_x < (uint8_t)p_obj->d_y)
  {
    if (p_obj->d_y < 0)
      p_obj->graphic_no |= (1<<0);
    else
      p_obj->graphic_no &= ~(1<<0);
    p_obj->flags7 |= FLAG_HFLIP;
  }
  else 
  {
    if (p_obj->d_x < 0)
      p_obj->graphic_no &= ~(1<<0);
    else
      p_obj->graphic_no |= (1<<0);
    p_obj->flags7 &= ~FLAG_HFLIP;
  }
}

// $B7A3
// gargoyle
void upd_22 (POBJ32 p_obj)
{
  set_both_deadly_flags (p_obj);
  adj_m7_m12 (p_obj);
}

// $B7A9
// spiked ball (eg. room 18)
// - randomly drop to the floor (and stay there)
// - drop immediately in even-numbered rooms!
void upd_63 (POBJ32 p_obj)
{
  set_both_deadly_flags (p_obj);
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
    p_obj->flags13 |= FLAG_DROPPING;
    is_spike_ball_dropping = 1;
  }
  else
  {
    dec_dZ_and_update_XYZ (p_obj);
    if ((p_obj->flags12 & FLAG_Z_OOB) == 0)
      audio_B451 (p_obj);
    else
    {
      p_obj->flags13 &= ~FLAG_DROPPING;
      is_spike_ball_dropping = 0; 
    }
    set_wipe_and_draw_flags (p_obj);
  }
}

// $B7E7
// spikes
void upd_23 (POBJ32 p_obj)
{
  set_both_deadly_flags (p_obj);
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
  audio_B45D (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags12 & FLAG_X_OOB) != 0)
  {
    p_obj->flags13 ^= FLAG_EAST;
    audio_B42E ();
  }
  toggle_next_prev_sprite (p_obj);
  set_both_deadly_flags (p_obj);
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
  audio_B462 (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags12 & FLAG_Y_OOB) != 0)
  {
    p_obj->flags13 ^= FLAG_NORTH;
    audio_B42E ();
  }
  toggle_next_prev_sprite (p_obj);
  set_both_deadly_flags (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B83F
// fire (stationary) (not used)
void upd_176_177 (POBJ32 p_obj)
{
  UNTESTED;
  
  upd_12_to_15 (p_obj);
  if ((fire_seed & (1<<0)) == 0)
    return;
  // randomise HFLIP
  p_obj->flags7 ^= seed_3 & FLAG_HFLIP;
  toggle_next_prev_sprite (p_obj);
  set_both_deadly_flags (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B856
void set_deadly_wipe_and_draw_flags (POBJ32 p_obj)
{
  set_both_deadly_flags (p_obj);
  set_wipe_and_draw_flags (p_obj);
}
  
// $B85C
void set_both_deadly_flags (POBJ32 p_obj)
{
  // flags an object to be deadly if
  // - you hit it
  // - it hits you
#ifndef BUILD_OPT_ALMOST_INVINCIBLE
  p_obj->flags13 |= FLAG_FATAL_HIT_YOU|FLAG_FATAL_YOU_HIT;
#endif  
}

// $B865
// ball up/down (eg. room 33)
void upd_178_179 (POBJ32 p_obj)
{
  upd_12_to_15 (p_obj);
  if (ball_bounce_height == 0)
    ball_bounce_height = p_obj->z + 32;
  toggle_next_prev_sprite (p_obj);
  audio_B451 (p_obj);
  if ((p_obj->flags13 & FLAG_UP) == 0)
  {
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->flags12 & FLAG_Z_OOB)
    {
      p_obj->flags13 |= FLAG_UP;
      audio_B42E();
    }
  }
  else
  {
    p_obj->d_z = 3;
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->z >= ball_bounce_height)
      p_obj->flags13 &= ~(FLAG_UP);
  }
  set_both_deadly_flags (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $B8A9
void init_cauldron_bubbles (void)
{
  UNTESTED;
  
  // cauldron room only
  if (graphic_objs_tbl[0].scrn != CAULDRON_SCREEN)
    return;
  // already initialised?
  if (special_objs_here[1].graphic_no != 0)
    return;
  if (all_objs_in_cauldron != 0)
    return;
  memcpy (&special_objs_here[1], cauldron_bubbles, 18);
  adj_m4_m12 (&special_objs_here[1]);
}

// $B8DA
// cauldron bubbles
void upd_160_to_163 (POBJ32 p_obj)
{
  UNTESTED;
  
  adj_m4_m12 (p_obj);
  
  if (special_objs_here != 0)
    upd_111 (p_obj);
  else
  {
    p_obj->flags7 |= FLAG_IGNORE_3D;
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
        p_obj->flags7 &= ~FLAG_IGNORE_3D;
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
  UNTESTED;
  
  adj_m4_m12 (p_obj);
  p_obj->graphic_no = 160;  // sparkles
  set_wipe_and_draw_flags (p_obj);
}

// $B92C
// repel spell (eg. room 94)
void upd_164_to_167 (POBJ32 p_obj)
{
  int8_t  d_x, d_y;
  
  adj_m4_m12 (p_obj);
  if (p_obj->scrn != CAULDRON_SCREEN && 
      (graphic_objs_tbl[0].flags7 & FLAG_NEAR_ARCH) != 0)
    d_x = d_y = 1;
  else
    d_x = d_y = 4;
  move_towards_plyr (p_obj, d_x, d_y);
  dec_dZ_and_update_XYZ (p_obj);
  next_graphic_no_mod_4 (p_obj);
  if (p_obj->scrn == CAULDRON_SCREEN)
  {
    if ((graphic_objs_tbl[0].graphic_no - 0x10) >= 0x40)
      p_obj->graphic_no = 1;  // invalid
  }
  audio_B467_wipe_and_draw (p_obj);
}

// $B95E
// sparkles
void upd_111 (POBJ32 p_obj)
{
  UNTESTED;

  p_obj->graphic_no = 1;  // invalid
  audio_B467_wipe_and_draw (p_obj);
}

// $B965
void move_towards_plyr (POBJ32 p_obj, int8_t d_x, int8_t d_y)
{
  if (p_obj->x >= graphic_objs_tbl[0].x)
    d_x = -d_x;
  p_obj->d_x = d_x;
  if (p_obj->y >= graphic_objs_tbl[0].y)
    d_y = -d_y;
  p_obj->d_y = d_y;
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
// guard (moving NSEW) & wizard (top half) (eg. room 46)
void upd_30_31_158_159 (POBJ32 p_obj)
{
  POBJ32  p_next_obj = p_obj + 1;
  int8_t  d_x, d_y;
  
  set_pixel_adj (p_obj, 3, -12);
  dec_dZ_and_update_XYZ (p_obj);
  move_guard_wizard_NSEW (p_obj, &d_x, &d_y);
  p_obj->d_x = d_x;
  p_next_obj->d_x = d_x;
  p_obj->d_y = d_y;
  p_next_obj->d_y = d_y;
  p_next_obj->x = p_obj->x;
  p_next_obj->y = p_obj->y;
  set_guard_wizard_sprite (p_obj);
  set_deadly_wipe_and_draw_flags (p_obj);
}

// $B9CC
void move_guard_wizard_NSEW (POBJ32 p_obj, int8_t *dx, int8_t *dy)
{
  uint8_t dir = p_obj->flags13 & MASK_DIR;
  
  switch (dir)
  {
    case 0 :
      // W
      *dx = -2;
      *dy = 0;
      if ((p_obj->flags12 & FLAG_X_OOB) == 0)
        return;
      *dx = 0;
      *dy = 2;
      break;
    case 1 :
      // N
      *dx = 0;
      *dy = 2;
      if ((p_obj->flags12 & FLAG_Y_OOB) == 0)
        return;
      *dx = 2;
      *dy = 0;
      break;
    case 2 :
      // E
      *dx = 2;
      *dy = 0;
      if ((p_obj->flags12 & FLAG_X_OOB) == 0)
        return;
      *dx = 0;
      *dy = -2;
      break;
    default :
      // S
      *dx = 0;
      *dy = -2;
      if ((p_obj->flags12 & FLAG_Y_OOB) == 0)
        return;
      *dx = -2;
      *dy = 0;
      break;
  }
  
  next_guard_dir:
  p_obj->flags13 = ((p_obj->flags13 & ~MASK_DIR) |
                    ((p_obj->flags13+1) & MASK_DIR));
}

// $BA9B
void wait_for_key_release (void)
{
  // fixme
  while (!osd_key(OSD_KEY_ESC));
  while (osd_key(OSD_KEY_ESC));
}

// $BA22
void game_over (void)
{
  uint8_t   rating;
  
  UNTESTED;
  
  if (all_objs_in_cauldron != 0)
  {
  game_complete_msg:
    clear_scrn_buffer ();
    clear_scrn ();
    suppress_border = 0;
    display_text_list ((uint8_t *)complete_colours, (uint8_t *)complete_xy, (char **)complete_text, 6);
    play_audio (game_complete_tune);
    wait_for_key_release ();
  }
  clear_scrn_buffer ();
  clear_scrn ();
  display_text_list ((uint8_t *)gameover_colours, (uint8_t *)gameover_xy, (char **)gameover_text, 6);
  print_bcd_number (120, 127, &days, 1);
  calc_and_display_percent ();
  rating = ((all_objs_in_cauldron & 1) << 2) | ((num_scrns_visited & 0x60) >> 5);
  print_text_std_font (88, 39, (char *)rating_tbl[rating].text);
  // convert to BCD
  if (objects_put_in_cauldron >= 10)
    objects_put_in_cauldron += 6;
  print_bcd_number (184, 79, &objects_put_in_cauldron, 1);
  print_border ();
  update_screen ();
  play_audio_until_keypress (NULL);
  wait_for_key_release ();

#ifdef __HAS_SETJMP__  
  longjmp (start_menu_env_buf, 1);
#endif
}

// $BC10
void calc_and_display_percent (void)
{
  unsigned  byte, bit, pc;
  unsigned  score;
  
  score = 0;
  for (byte=0; byte<32; byte++)
    for (bit=0; bit<8; bit++)
      if (scrn_visited[byte] & (1<<bit))
        score++;
  num_scrns_visited = score - 1;
  score += objects_put_in_cauldron * 2;
  
  // 128 locations + 14*2 objects = 156 maximum score
  pc = score * 100 / 156;
  percent_msw = pc/100;
  pc %= 100;
  percent_lsw = ((pc/10)<<4)+(pc%10);
  
  if (percent_msw != 0)
    print_bcd_number (152, 95, &percent_msw, 2);   // *** FIXME
  else
    print_bcd_number (160, 95, &percent_lsw, 1);   // *** FIXME
}

// $BC66
void print_days (void)
{
  print_bcd_number (120, 7, &days, 1);
}

// $BC7A
void print_lives_gfx (void)
{
  POBJ32 p_obj = &sprite_scratchpad;
  
  UNTESTED;

  p_obj->graphic_no = 0x8c;
  p_obj->flags7 = 0;
  p_obj->pixel_x = 16;
  p_obj->pixel_y = 32;
  print_sprite (PANEL_DYNAMIC, p_obj);
  // attributes
  // fill_de (47h,5a42h,2);
  // fill_de (47h,5a62h,4);
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
    // slightly modified!!!
    // - always called with n=1
    // - except one place that jumps into the middle
    //   so only 3 digits are printed
    if (i>0 || n==1)
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
  print_text_raw (112, 15, (char *)(days_txt+1));
}

// $BD0C
void do_menu_selection (void)
{
  uint8_t key;

  clear_scrn_buffer ();
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
  unsigned i;
  
  UNTESTED;

  // keyboard, joystick...
  for (i=1; i<=4; i++)
  {
    if (i == ((user_input_method >> 1) & 3))
      menu_colours[i] |= (1<<7);
    else
      menu_colours[i] &= ~(1<<7);
  }
  // directional
  menu_colours[i] &= ~(1<<7);
  if ((user_input_method & (1<<3)) != 0)
    menu_colours[i] |= (1<<7);
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
  display_text_list ((uint8_t *)menu_colours, (uint8_t *)menu_xy, (char **)menu_text, 8);
  print_border ();
  update_screen ();
}

// $BEBF
void display_text_list (uint8_t *colours, uint8_t *xy, char *text_list[], uint8_t n)
{
  unsigned i;
  
  for (i=0; i<n; i++, xy+=2)
  {
    tmp_attrib = colours[i];
    print_text_single_colour (*xy, *(xy+1), text_list[i]);
  }
  if (suppress_border != 0)
    return;
  suppress_border++;
  print_border ();
  update_screen ();
}

// $BEE4
void multiple_print_sprite (uint8_t type, POBJ32 p_obj, uint8_t dx, uint8_t dy, uint8_t n)
{
  unsigned i;
  
  for (i=0; i<n; i++)
  {
    print_sprite (type, p_obj);
    p_obj->pixel_x += dx;
    p_obj->pixel_y += dy;
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
  audio_B419 (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $BF11
// last player appears sparkle
void upd_127 (POBJ32 p_obj)
{
  adj_m4_m12 (p_obj);
  p_obj->flags13 &= ~FLAG_DEAD;
  // for player (only), this stores the graphic_no
  p_obj->graphic_no = p_obj->u.plyr_graphic_no;
  upd_sprite_jump_tbl[p_obj->graphic_no] (p_obj);
}

// $BF21
void init_death_sparkles (POBJ32 p_obj)
{
  p_obj->graphic_no = 112;
  p_obj->flags7 |= FLAG_IGNORE_3D;
  audio_B403 (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $BF2B
// sparkles
void upd_112_to_118_184 (POBJ32 p_obj)
{
  UNTESTED;

  adj_m4_m12 (p_obj);
  p_obj->graphic_no++;
  audio_B403 (p_obj);
  set_wipe_and_draw_flags (p_obj);
}

// $BF37
// sparkles
void upd_185_187 (POBJ32 p_obj)
{
  UNTESTED;

  // zap the graphic_no so the object no longer appears  
  graphic_objs_tbl[p_obj->u.ptr_obj_tbl_entry].graphic_no = 0;
  upd_119 (p_obj);
}

// $BF3F
// sparkles
void upd_119 (POBJ32 p_obj)
{
  UNTESTED;

  adj_m4_m12 (p_obj);
  upd_111 (p_obj);
}

// $BF45
void display_objects_carried (void)
{
  if (objects_carried_changed == 0)
    return;
  objects_carried_changed = 0;
  display_objects ();
}

// $BF4E
void display_objects (void)
{
  POBJ32 p_obj = &sprite_scratchpad;
  
  unsigned i;
  
  for (i=0; i<3; i++)
  {
    uint8_t x = ((255-(3-i))+3)*24+16  +24;

    p_obj->pixel_x = x;
    p_obj->pixel_y = 0;
    fill_window (p_obj->pixel_x, p_obj->pixel_y, 3, 24, 0);

    if (objects_carried[i].graphic_no != 0)
    {
      p_obj->graphic_no = objects_carried[i].graphic_no;
      print_sprite (PANEL_DYNAMIC, p_obj);
    }
    blit_to_screen (p_obj->pixel_x, p_obj->pixel_y, 3, 24);
    // do attributes
  }
}

// $BFFB
uint8_t chk_pickup_drop (void)
{
  return (user_input & INP_PICKUP_DROP);
}

// $C00E
void handle_pickup_drop (POBJ32 p_obj)
{
  POBJ32    p_next_obj = p_obj+1;
  POBJ32    p_other;
  uint8_t   z;
  uint8_t   width, depth, height;
  unsigned  i;
  
  UNTESTED;

  // registered as pressed?  
  if (pickup_drop_pressed != 0)
  {
    // yes, still pressed?
    if (chk_pickup_drop() != 0)
      return;
    // flag as no longer pressed
    pickup_drop_pressed = 0;
    return;
  }

  // actually pressed?
  if (chk_pickup_drop () == 0)
    return;
  // out-of-bounds?
  if (chk_plyr_OOB (p_obj) == 0)
    return;
  if ((p_obj->flags12 & FLAG_JUMPING) != 0)
    return;
  if ((p_obj->flags12 & FLAG_Z_OOB) == 0)
    return;
  cant_drop = 0;
  z = p_obj->z;     // save
  p_obj->z += 12;
  if (do_any_objs_intersect (p_obj) != 0)
    cant_drop = 1;
  p_obj->z = z;     // restore

  // audio - toggles FE directly
  
  pickup_drop_pressed = 1;
  objects_carried_changed = 1;
  width = p_obj->width;
  p_obj->width += 4;
  depth = p_obj->depth;
  p_obj->depth += 4;
  height = p_obj->height;
  p_obj->height += 4;

  p_other = special_objs_here;  
  for (i=0; i<2; i++, p_other++)
  {
    if (can_pickup_spec_obj (p_obj, p_other) != 0)
      goto pickup_object;
  }
  if (chk_pickup_drop () != 0)
  {
    uint8_t b = (p_obj->scrn == CAULDRON_SCREEN ? 1 : 2);
    p_other = special_objs_here;
    for (; b; b--)
      if (p_other->graphic_no == 0)
        goto loc_C0B2;
  }
  
done_pickup_drop:
  // restore original dimensions
  p_obj->height = height;
  p_obj->depth = depth;
  p_obj->width = width;
  return;
  
loc_C0B2:
  if (objects_carried[2].graphic_no == 0)
    goto adjust_carried;
  if (cant_drop != 0)
    goto done_pickup_drop;
  p_other->graphic_no = objects_carried[2].graphic_no;
  if (p_obj->scrn == CAULDRON_SCREEN)
    if (p_obj->z >= 152)
    {
      // convert to sprite being dropped into cauldron
      p_other->graphic_no |= (1<<3);
      obj_dropping_into_cauldron = 1;
    }
  // copy x,y,z
  memcpy (&p_other->x, &p_obj->x, 3);
  p_obj->z += 12;
  p_next_obj += 12;
  calc_pixel_XY (p_other);
  
drop_object:
  p_other->width = 5;
  p_other->depth = 5;
  p_other->height = 12;
  p_other->flags7 = objects_carried[2].flags7;
  p_other->scrn = p_obj->scrn;
  p_other->u.ptr_obj_tbl_entry = objects_carried[2].ptr_obj_tbl_entry;
  p_other->flags13 |= FLAG_JUST_DROPPED;
  
adjust_carried:
  // careful, the memory overlaps!
  memmove (objects_carried, inventory, 3*sizeof(INVENTORY));
  memset (inventory, 0, 4);
  goto done_pickup_drop;
      
pickup_object:
  disable_spike_ball_drop = 0;
  inventory[0].graphic_no = p_other->graphic_no;
  inventory[0].flags7 = p_other->flags7;
  inventory[0].ptr_obj_tbl_entry = p_other->u.ptr_obj_tbl_entry;
  special_objs_tbl[p_other->u.ptr_obj_tbl_entry].graphic_no = 0;
  set_wipe_and_draw_flags (p_other);
  p_other->graphic_no = 1;  // invalid
  // empty slot to pickup, KO
  if (objects_carried[2].graphic_no == 0)
    goto adjust_carried;
  // need to drop 3rd object
  p_other->graphic_no = objects_carried[2].graphic_no;
  goto drop_object;
}

// $C172
uint8_t can_pickup_spec_obj (POBJ32 p_obj, POBJ32 p_other)
{
  // special object?
  if ((p_other->graphic_no - 0x60) >= 7)
    return (0);
  return is_on_or_near_obj (p_obj, p_other);
}

// $C17A
uint8_t is_on_or_near_obj (POBJ32 p_obj, POBJ32 p_other)
{    
  uint8_t f;
  
  if (do_objs_intersect_on_x (p_obj, p_other, 0) == 0)
    return (0);
  if (do_objs_intersect_on_y (p_obj, p_other, 0) == 0)
    return (0);
  p_obj->z -= 4;
  f = do_objs_intersect_on_z (p_obj, p_other, 0);
  p_obj->z += 4;
  return (f);
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
  POBJ32  p_other;
  uint8_t f;
  
  UNTESTED;

  upd_128_to_130 (p_obj);
  
  p_other = graphic_objs_tbl;
  p_other->width++;
  p_other->depth++;
  f = is_on_or_near_obj (p_other, p_obj);
  p_other->width--;
  p_other->depth--;
  if (f != 0)
  {
    p_obj->graphic_no |= (1<<3);
    adj_m4_m12 (p_obj);
    p_obj->u.ptr_obj_tbl_entry = 0;
    lives++;
    disable_spike_ball_drop = 0;
    // audio - toggles FE directly
    print_lives ();
    blit_2x8 (32, 32);
  }
  dec_dZ_upd_XYZ_wipe_if_moving (p_obj);    
}

// $C1F1
// special objects (dropped in cauldron room?)
void upd_104_to_110 (POBJ32 p_obj)
{
  UNTESTED;
  
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
        cycle_colours_with_sound (p_obj);
        if (objects_put_in_cauldron == 14)
          prepare_final_animation ();
      }
      obj_dropping_into_cauldron = 0;
      graphic_objs_tbl[p_obj->u.ptr_obj_tbl_entry].graphic_no = 0;
      upd_111 (p_obj);
      return;
    }
    else
      p_obj->flags7 |= FLAG_IGNORE_3D;
  }
  dec_dZ_and_update_XYZ (p_obj);
  audio_B467_wipe_and_draw (p_obj);
}

// $C232
void audio_B467_wipe_and_draw (POBJ32 p_obj)
{
  audio_B467 (p_obj);
  set_wipe_and_draw_flags (p_obj);    
}

// $C274
uint8_t ret_next_obj_required (void)
{
  return (objects_required[objects_put_in_cauldron]);
}

// $C28B
// special objects
void upd_96_to_102 (POBJ32 p_obj)
{
  UNTESTED;
  
  adj_m4_m12 (p_obj);
  dec_dZ_and_update_XYZ (p_obj);
  if ((p_obj->flags13 & FLAG_JUST_DROPPED) == 0)
    if (!is_obj_moving (p_obj))
      return;
  p_obj->flags13 &= ~FLAG_JUST_DROPPED;
  clear_dX_dY (p_obj);
  audio_B467_wipe_and_draw (p_obj);
}

// $C2A5
// audio/video effects?
void cycle_colours_with_sound (POBJ32 p_obj)
{
  UNIMPLEMENTED_AUDIO;
  
  audio_B403 (p_obj);
}
  
// $C2CB
void no_update (POBJ32 p_obj)
{
  // do nothing
}

// $C2CC
void prepare_final_animation (void)
{
  POBJ32    p_obj;
  unsigned  i;
    
  UNTESTED;
  
  all_objs_in_cauldron = 1;
  p_obj = &special_objs_here[1];
  // wipe 11 objects in the room
  // - 1 special, 7 bg, 3 fg
  for (i=0; i<11; i++, p_obj++)
  {
    set_wipe_and_draw_flags (p_obj);
    p_obj->graphic_no = 1;  // invalid
  }
  for (; i<MAX_OBJS-(3+11); i++)
  {
    // turn blocks to twinkly sprites
    if (p_obj->graphic_no == 7)
      p_obj->graphic_no = 131;
  }
}

// $C306
int chk_and_init_transform (POBJ32 p_obj)
{
  POBJ32 p_next_obj = p_obj+1;
  
  if (transform_flag_graphic == 0)
    return (0);
  if ((p_obj->flags12 & MASK_ENTERING_SCRN) != 0)
    return (0);
  if ((p_obj->flags12 & FLAG_JUMPING) != 0)
    return (0);

  // the original Z80 code incremented the stack twice
  // so we didn't return to the caller
  // - but here we return 1 instead

  transform_flag_graphic = p_obj->graphic_no;
  p_obj->u.plyr_graphic_no = 8;
  p_next_obj->graphic_no = 1;
  set_wipe_and_draw_flags (p_next_obj);
  upd_11 (p_obj);
  rand_legs_sprite (p_obj);
  
  return (1);
}

// $C337
// human/wulf transform
void upd_92_to_95 (POBJ32 p_obj)
{
  UNTESTED;
  
  upd_11 (p_obj);
  if ((p_obj->flags13 & FLAG_DEAD) != 0 &&
      all_objs_in_cauldron == 0)
    init_death_sparkles (p_obj);
  else
  {
    if ((seed_2 & 3) != 0)
      return;
    audio_B472 (p_obj);
    if (--p_obj->u.plyr_graphic_no == 0)
    {
      POBJ32 p_next_obj = p_obj+1;
      uint8_t graphic_no = transform_flag_graphic ^ 0x20;
      
      p_obj->graphic_no = graphic_no;
      p_next_obj->graphic_no = graphic_no + 16;
      transform_flag_graphic = 0;
      adj_m6_m12 (p_obj);
      if ((p_obj->graphic_no & (1<<5)) != 0)
        p_obj->pixel_y_adj--;
      set_wipe_and_draw_flags (p_obj);
    }
    else
      rand_legs_sprite (p_obj);
  }
}

// $C357
void rand_legs_sprite (POBJ32 p_obj)
{
  uint8_t r = rand ();    // was Z80 R register
  r = ((r + seed_3) & 3) | 92;
  if (r == p_obj->graphic_no)
    r ^= (1<<0);
  p_obj->graphic_no = r;
  p_obj->flags7 ^= FLAG_HFLIP;
  set_wipe_and_draw_flags (p_obj);
}

// $C397
void print_sun_moon (void)
{
  POBJ32 p_obj = &sun_moon_scratchpad;
  
  if ((seed_2 & 7) != 0)
    return;
  p_obj->pixel_x++;
  display_sun_moon_frame (p_obj);
}

// $C3A4
void display_sun_moon_frame (POBJ32 p_obj)
{
  POBJ32 p_frm = &sprite_scratchpad;
  uint8_t x;

  if (all_objs_in_cauldron != 0)
    return;

  if (p_obj->pixel_x == 225)
    goto toggle_day_night;

  // adjust Y coordinate
  x = p_obj->pixel_x + 16;
  p_obj->pixel_y = sun_moon_yoff[(x>>2)&0x0f];

display_frame:
  // display sun/moon
  fill_window (184, 0, 6, 31, 0);
  print_sprite (PANEL_DYNAMIC, p_obj);
  
  p_frm->flags7 = 0;
  p_frm->graphic_no = 0x5a;
  p_frm->pixel_x = 184;
  p_frm->pixel_y = 0;
  print_sprite (PANEL_STATIC, p_frm);
  p_frm->pixel_x = 208;
  p_frm->graphic_no = 0xba;
  print_sprite (PANEL_STATIC, p_frm);
  blit_to_screen (184, 0, 6, 31);
  return;

toggle_day_night:
  p_obj->graphic_no ^= 1;
  colour_sun_moon ();
  p_obj->pixel_x = 176;
  transform_flag_graphic = 1;
  // if just changed to moon, exit
  if (p_obj->graphic_no & 1)
    return;

inc_days:
  // BCD arithmetic
  days++;
  if ((days & 0x0f) == 10)
    days += 6;
  if (days == 0x40)
  {
    game_over ();
    // longjmp to start_menu
  }
  print_days ();
  blit_2x8 (120, 0);
  goto display_frame;  
}

// $C432
void blit_2x8 (uint8_t x, uint8_t y)
{
  blit_to_screen (x, y, 2, 8);
}

// $C46D
void init_sun (void)
{
  POBJ32 p_obj = &sun_moon_scratchpad;
  
  p_obj->graphic_no = 0x58;
  p_obj->pixel_x = 176;
  p_obj->pixel_y = 9;
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
  audio_B3E9 ();
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
  audio_B467_wipe_and_draw (p_obj);    
}

// $C4C3
// table (eg. room 10)
void upd_84 (POBJ32 p_obj)
{
  upd_6_7 (p_obj);
  dec_dZ_upd_XYZ_wipe_if_moving (p_obj);
}

// $C4C6
void dec_dZ_upd_XYZ_wipe_if_moving (POBJ32 p_obj)
{
  dec_dZ_and_update_XYZ (p_obj);
  if (!is_obj_moving (p_obj))
    return;
  clear_dX_dY (p_obj);
  audio_B467_wipe_and_draw (p_obj);
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

// $C515
// the original used screen buffer address
// instead of x_byte & y_line
void fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c)
{
  // x starts on a byte boundary
  x &= 0xF8;
  if (height_lines > 0)
    osd_fill_window (x, y, width_bytes, height_lines, c);
}

// $C525
void find_special_objs_here (void)
{
  POBJ32 p_special_obj = special_objs_here;
  uint8_t n_special_objs_here = 0;
  unsigned i;
   
  DBGPRINTF ("%s(): screen=%d\n", 
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
    p_special_obj->height = 12;
    p_special_obj->flags7 = FLAG_DRAW | FLAG_MOVEABLE;
    p_special_obj->scrn = special_objs_tbl[i].curr_scrn;
    memset (&p_special_obj->d_x, 0, 7);
    p_special_obj->u.ptr_obj_tbl_entry = i;
    memset (&p_special_obj->unused, 0, 32-20);

    p_special_obj->unused[0] = 2+n_special_objs_here;
        
    p_special_obj++;
    n_special_objs_here++;
  }

  DBGPRINTF ("  n_special_objs_here=%d\n", n_special_objs_here);

  // wipe rest of the special_objs_here table  
  for (; n_special_objs_here<2; n_special_objs_here++)
  {
    memset (p_special_obj, 0, sizeof(OBJ32));
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
      uint8_t index = special_objs_here[i].u.ptr_obj_tbl_entry;
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
    audio_B467 (p_obj);
  }
  toggle_next_prev_sprite (p_obj);
  set_deadly_wipe_and_draw_flags (p_obj);
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
    p_obj->flags7 &= ~FLAG_HFLIP;
  }
  else
  {
    if (p_obj->d_x < 0)
      p_obj->graphic_no |= (1<<1);    // 82/83
    else
      p_obj->graphic_no &= ~(1<<1);   // 80/81
    p_obj->flags7 |= FLAG_HFLIP;
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
  p_obj->flags7 |= (FLAG_WIPE|FLAG_DRAW);
  set_draw_objs_overlapped (p_obj);
}

// $C6BD
// portcullis (moving) (eg. room 9)
void upd_9 (POBJ32 p_obj)
{
  //DBGPRINTF_FN;
  
  adj_m6_m12 (p_obj);
  // only fatal if it hits you
  // - ie. you can walk into it without dying
  p_obj->flags13 |= FLAG_FATAL_HIT_YOU;
  if ((graphic_objs_tbl[0].flags12 & MASK_ENTERING_SCRN) != 0)
    return;
  if (p_obj->d_z < 0)
  {
    p_obj->d_z--;
    dec_dZ_and_update_XYZ (p_obj);
    if (p_obj->flags12 & FLAG_Z_OOB)
    {
      audio_B489 ();
    stop_portcullis:
      portcullis_moving = 0;
      // set graphic_no to 8
      p_obj->graphic_no &= ~(1<<0);
    }
  }
  else
  {
    p_obj->d_z = 2;
    audio_B467 (p_obj);
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
  if ((p_obj->flags7 & FLAG_HFLIP) == 0)
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

// $C73C
// stone/tree arch (near side)
void upd_2_4 (POBJ32 p_obj)
{
  POBJ32 p_other;
  unsigned i;
  
  UNTESTED;

  if ((p_obj->flags7 & FLAG_HFLIP) == 0)
  {
    // tree arch
    if (p_obj->graphic_no == 4)
      set_pixel_adj (p_obj, -3, 1);
    else
      set_pixel_adj (p_obj, -3, -7);
    // set centre points for player adjustment
    p_obj->d_y = p_obj->y + 13;
    p_obj->d_x = p_obj->x;
    p_obj->d_z = p_obj->z;
    chk_plyr_spec_near_arch (p_obj, 15, 6);
  }
  else
  {
    set_pixel_adj (p_obj, -2, -17);
    // set centre points for player adjustment
    p_obj->d_x = p_obj->x - 13;
    p_obj->d_y = p_obj->y;
    p_obj->d_z = p_obj->z;
    chk_plyr_spec_near_arch (p_obj, 6, 15);
  }

  // player and special objects only
  p_other = graphic_objs_tbl;  
  for (i=0; i<4; i++, p_other++)
  {
    if (p_other->graphic_no == 0)
      continue;
    if ((p_other->flags7 & FLAG_AUTO_ADJ) == 0)
      continue;
    if (is_near_to (p_obj, p_other, 15, 15) == 0)
      continue;
    switch (get_sprite_dir (p_obj))
    {
      case 0 :  // W
      case 1 :  // E
        if (p_obj->d_y == p_other->y)
          continue;
        p_other->d_y_adj = ((uint8_t)p_obj->d_y < p_other->y ? -1 : 1);
        break;
      case 2 :  // N
      case 3 :  // S
      default :
        if (p_obj->d_x == p_other->x)
          continue;
        p_other->d_x_adj = ((uint8_t)p_obj->d_x < p_other->x ? -1 : 1);
        break;
    }
  }
}

// $C7DB
void chk_plyr_spec_near_arch (POBJ32 p_obj, uint8_t near_x, uint8_t near_y)
{
  POBJ32    p_other;
  unsigned  i;
  
  // player and special objects only
  p_other = graphic_objs_tbl;
  for (i=0; i<4; i++, p_other++)
  {
    if (p_other->graphic_no == 0)
      continue;
    if ((p_other->flags7 & FLAG_AUTO_ADJ) == 0)
      continue;
    if (is_near_to (p_obj, p_other, near_x, near_y) == 0)
      continue;
    p_other->flags7 |= FLAG_NEAR_ARCH;
  }
}

// $C7FE
// returns C(1) if 'near (enough) to'
uint8_t is_near_to (POBJ32 p_obj, POBJ32 p_other, uint8_t near_x, uint8_t near_y)
{
  uint8_t a;
  
  a = abs((uint8_t)(p_obj->d_x) - p_other->x);
  if (a >= near_x)
    return (0);  
  a = abs((uint8_t)(p_obj->d_y) - p_other->y);
  if (a >= near_y)
    return (0);
  a = abs((uint8_t)(p_obj->d_z) - p_other->z);
  return (a < 4 ? 1 : 0);
}

// $C823
// human legs
void upd_16_to_21_24_to_29 (POBJ32 p_obj)
{
  adj_m6_m12 (p_obj);
  upd_player_bottom (p_obj);  
}

// $C828
// wulf legs
void upd_48_to_53_56_to_61 (POBJ32 p_obj)
{
  adj_m7_m12 (p_obj);
  upd_player_bottom (p_obj);
}

// $C82B
// handles human and wulf legs
void upd_player_bottom (POBJ32 p_obj)
{
  POBJ32    p_next_obj = p_obj+1;
  uint8_t   inp;
    
  UNTESTED;

  if ((p_obj->flags13 & FLAG_DEAD) != 0 &&
      all_objs_in_cauldron == 0)
  {
    p_next_obj->flags13 |= FLAG_DEAD;
    init_death_sparkles (p_obj);
  }
  else
  {
    // the original Z80 code popped the return address
    if (chk_and_init_transform (p_obj))
      return;
    inp = check_user_input ();
    handle_pickup_drop (p_obj);
    handle_left_right (p_obj, inp);
    handle_jump (p_obj, inp);
    handle_forward (p_obj, inp);
    if (chk_plyr_OOB (p_obj) == 0)
      if (p_obj->d_z >= 0)
        p_obj->d_z = 0;
    p_next_obj->flags7 |= FLAG_IGNORE_3D;
    // the original Z80 code returned to game_loop
    // we'll set a flag internally and simply return
    if (move_player (p_obj, inp) == 1)
      return;
    p_next_obj->flags7 &= ~FLAG_IGNORE_3D;
    // decrement count of shuffling forward 
    // when first entering screen
    if (p_obj->flags12 >= 0x10)
      p_obj->flags12 -= 0x10;
    set_wipe_and_draw_flags (p_obj);
  }
}

// $C87A
// returns 0 (NC) if OOB
uint8_t chk_plyr_OOB (POBJ32 p_obj)
{
  UNTESTED;
  
  // original Z80 code returns NC, C
  if (abs(p_obj->x - 128) > (room_size_X - p_obj->width))
    return (0);
  if (abs(p_obj->y - 128) > (room_size_Y - p_obj->depth))
    return (0);

  // OK
  return (1);
}

// $C89F
void handle_left_right (POBJ32 p_obj, uint8_t inp)
{
  POBJ32  p_next_obj = p_obj+1;
  
  UNTESTED;
  
  // checks user input method

  // delay before allowing turning again  
  if ((p_obj->flags13 & MASK_TURN_DELAY) != 0)
  {
    p_obj->flags13--;
    return;
  }
  // left or right?
  if ((inp & (INP_LEFT|INP_RIGHT)) == 0)
    return;
  if ((p_obj->flags12 & MASK_ENTERING_SCRN) != 0)
    return;
  if ((p_obj->flags12 & FLAG_JUMPING) != 0)
    return;
  if ((inp & INP_FORWARD) == 0)
    audio_B4C1 (p_obj);
  // init delay for allowing turning again
  p_obj->flags13 |= 2;
  if (((inp & INP_RIGHT) != 0 &&
      (p_obj->flags7 & FLAG_HFLIP) != 0) ||
      ((inp & INP_RIGHT) == 0 &&
      (p_obj->flags7 & FLAG_HFLIP) == 0))
    p_obj->graphic_no ^= 8;
  p_obj->flags7 ^= FLAG_HFLIP;
  // set sprite for top half
  p_next_obj->graphic_no = p_obj->graphic_no + 16;
}

// $C948
void handle_jump (POBJ32 p_obj, uint8_t inp)
{
  UNTESTED;
  
  if ((inp & INP_JUMP) == 0)
    return;
  if ((p_obj->flags12 & MASK_ENTERING_SCRN) != 0)
    return;
  if ((p_obj->flags12 & FLAG_JUMPING) != 0)
    return;
  if (p_obj->d_z < -1)
    return;
  p_obj->flags12 |= FLAG_JUMPING;
  p_obj->d_z = 8;
  audio_B441 ();
}

// $C969
void handle_forward (POBJ32 p_obj, uint8_t inp)
{
  UNTESTED;
  
  if ((p_obj->flags12 & MASK_ENTERING_SCRN) == 0 &&
      (p_obj->flags12 & FLAG_JUMPING) == 0 &&
      (inp & INP_FORWARD) == 0)
  {
    uint8_t n = p_obj->graphic_no & 7;
    if (n == 2 || n == 4)
      return;
  }
  else
    audio_B4BB (p_obj);

  animate_guard_wizard_legs (p_obj);
}

// $C97F
void animate_guard_wizard_legs (POBJ32 p_obj)
{
  uint8_t cel = (p_obj->graphic_no + 1) & 7;

  if (cel == 6)
    cel = 0;
  p_obj->graphic_no = (p_obj->graphic_no & 0xF8) | cel;
}

// $C9A1
// returns 1 if screen is exited
uint8_t move_player (POBJ32 p_obj, uint8_t inp)
{
  UNTESTED;
  
  if (obj_dropping_into_cauldron != 0)
    p_obj->d_z = 2;
  if ((p_obj->flags12 & FLAG_JUMPING) != 0 ||
      (p_obj->flags12 & MASK_ENTERING_SCRN) != 0 ||
      (inp & INP_FORWARD) != 0)
    calc_plyr_dXY (p_obj);
  if (p_obj->d_z < 0 || (inp & INP_JUMP) == 0)
    p_obj->d_z--;
  p_obj->d_z--;
  tmp_dZ = p_obj->d_z;
  if (p_obj->d_z < -2)
    audio_B451 (p_obj);
  adj_for_out_of_bounds (p_obj);
  if (handle_exit_screen (p_obj) == 1)
    return (1);
  add_dXYZ (p_obj);
  if ((p_obj->flags12 & FLAG_Z_OOB) != 0)
    if (tmp_dZ < 0)
      p_obj->flags12 &= ~FLAG_JUMPING;
  clear_dX_dY (p_obj);
  
  return (0);
}

// $C9F3
void clear_dX_dY (POBJ32 p_obj)
{
  p_obj->d_x = 0;
  p_obj->d_y = 0;
}

// $C9FB
void calc_plyr_dXY (POBJ32 p_obj)
{
  //DBGPRINTF_FN;
  
  UNTESTED;
  
  p_obj->d_x += p_obj->d_x_adj;
  p_obj->d_y += p_obj->d_y_adj;
  p_obj->d_x_adj = 0;
  p_obj->d_y_adj = 0;
  
  switch (get_sprite_dir (p_obj))
  {
    case 0 :  // W
      p_obj->d_x -= 3;
      break;
    case 1 :  // E
      p_obj->d_x += 3;
      break;
    case 2 :  // N
      p_obj->d_y += 3;
      break;
    case 3:   // S
      p_obj->d_y -= 3;
    default :
      break;
  }
}

// $CA1E
// returns 0-3 (WENS)
uint8_t get_sprite_dir (POBJ32 p_obj)
{
  uint8_t l = (p_obj->flags7>>2) & 0x10;    // HFLIP
  uint8_t a = (p_obj->graphic_no & 8) | l;
  
  return ((a>>3) & 3);
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

// $CA70
// returns 1 if screen was exited
uint8_t handle_exit_screen (POBJ32 p_obj)
{
  UNTESTED;

  if ((p_obj->flags12 & MASK_ENTERING_SCRN) != 0)
    return (0);
  if ((p_obj->flags7 & FLAG_NEAR_ARCH) == 0)
    return (0);
  p_obj->flags7 &= ~FLAG_NEAR_ARCH;
  
  switch (get_sprite_dir (p_obj))
  {
    case 0 :  // W
      if ((p_obj->x + p_obj->d_x + p_obj->width) >= (128 - room_size_X))
        return (0);
      p_obj->x = 0;
      p_obj->scrn = (p_obj->scrn & 0xF0) | ((p_obj->scrn - 1) & 0x0F);
      break;
    case 1 :  // E
      if ((p_obj->x + p_obj->d_x - p_obj->width) < (room_size_X + 128))
        return (0);
      p_obj->x = (uint8_t)-1;
      p_obj->scrn = (p_obj->scrn & 0xF0) | ((p_obj->scrn + 1) & 0x0F);
      break;
    case 2 :  // N
      if ((p_obj->y + p_obj->d_y - p_obj->depth) < (room_size_Y + 128))
        return (0);
      p_obj->y = (uint8_t)-1;
      p_obj->scrn += 16;
      break;
    case 3 :  // S
    default :
      if ((p_obj->y + p_obj->d_y + p_obj->depth) >= (128 - room_size_Y))
        return (0);
      p_obj->y = 0;
      p_obj->scrn -= 16;
      break;
  }
  
exit_screen:
  internal.exit_scrn = 1;
  // init count to shuffle forward 3 steps 
  // when first entering screen
  p_obj->flags12 |= 0x30;
  if ((p_obj->graphic_no - 16) >= 64)
    return (0);

  // the original Z80 code popped 2 return addresses
  // from the stack and then JP game_loop:
  // CALL handle_exit_screen(), and
  // CALL move_player()
  // however, by my calculations, the return address
  // from the object handler routine is STILL ON THE STACK!
  // - fortunately SP is reset a few instructions later
  //   but that begs the question, why bother popping at all?

  memcpy (&plyr_spr_1_scratchpad, &graphic_objs_tbl[0], sizeof(OBJ32));
  plyr_spr_1_scratchpad.u.plyr_graphic_no = plyr_spr_1_scratchpad.graphic_no;
  memcpy (&plyr_spr_2_scratchpad, &graphic_objs_tbl[1], sizeof(OBJ32));
  plyr_spr_2_scratchpad.u.plyr_graphic_no = plyr_spr_2_scratchpad.graphic_no;
  // sparkles
  plyr_spr_1_scratchpad.graphic_no = 120;
  plyr_spr_2_scratchpad.graphic_no = 120;

  DBGPRINTF ("%s() got=%d,ps1s=%d\n", __FUNCTION__, 
              graphic_objs_tbl[0].scrn,
              plyr_spr_1_scratchpad.scrn);

#ifdef __HAS_SETJMP__  
  longjmp (game_loop_env_buf, 1);
#endif
  return (1);
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

  if ((p_obj->flags7 & FLAG_IGNORE_3D) != 0)
    return;
    
  p_obj->flags7 |= FLAG_IGNORE_3D;
  p_obj->flags12 &= ~(FLAG_Z_OOB|FLAG_Y_OOB|FLAG_X_OOB);
  d_y = 0;
  d_x = 0;

  d_z = p_obj->d_z;  
  if (p_obj->d_z != 0)
  {
    d_z = adj_dZ_for_out_of_bounds (p_obj, d_z);
    if (d_z != 0)
      d_z = adj_dZ_for_obj_intersect (p_obj, d_x, d_y, d_z);
  }

  d_x = p_obj->d_x;
  if (p_obj->d_x != 0)
  {
    d_x = adj_dX_for_out_of_bounds (p_obj, d_x);
    if (d_x != 0)
      d_x = adj_dX_for_obj_intersect (p_obj, d_x, d_y, d_z);
  }

  d_y = p_obj->d_y;  
  if (p_obj->d_y != 0)
  {
    d_y = adj_dY_for_out_of_bounds (p_obj, d_y);
    if (d_y != 0)
      d_y = adj_dY_for_obj_intersect (p_obj, d_x, d_y, d_z);
  }

  p_obj->d_x = d_x;
  p_obj->d_y = d_y;
  p_obj->d_z = d_z;
  p_obj->flags7 &= ~FLAG_IGNORE_3D;
}

// $CB9A
int8_t adj_dX_for_obj_intersect (POBJ32 p_obj, int8_t d_x, int8_t d_y, int8_t d_z)
{
  POBJ32    p_other;
  unsigned  i;
  
  UNTESTED;
  
  p_other = graphic_objs_tbl;
  for (i=0; i<MAX_OBJS; i++, p_other++)
  {
    if (is_object_not_ignored (p_other) == 0)
      continue;
    if (do_objs_intersect_on_y (p_obj, p_other, d_y) == 0)
      continue;
    if (do_objs_intersect_on_z (p_obj, p_other, d_z) == 0)
      continue;
      
    while (1)
    {
      if (do_objs_intersect_on_x (p_obj, p_other, d_x) == 0)
        break;
      p_obj->flags12 |= FLAG_X_OOB;
      // obj bit 7 -> other bit 6
      p_other->flags13 |= (p_obj->flags13 >> 1) & FLAG_DEAD;
      // other bit 5 -> obj bit 6
      p_obj->flags13 |= (p_other->flags13 << 1) & FLAG_DEAD;
      if ((p_other->flags7 & FLAG_MOVEABLE) != 0)
        p_other->d_x = p_obj->d_x;
      if ((d_x = adj_d_for_out_of_bounds (d_x)) == 0)
        return (d_x);
    }
  }
  return (d_x);
}

// $CBE9
int8_t adj_dY_for_obj_intersect (POBJ32 p_obj, int8_t d_x, int8_t d_y, int8_t d_z)
{
  POBJ32    p_other;
  unsigned  i;
  
  UNTESTED;
  
  p_other = graphic_objs_tbl;
  for (i=0; i<MAX_OBJS; i++, p_other++)
  {
    if (is_object_not_ignored (p_other) == 0)
      continue;
    if (do_objs_intersect_on_x (p_obj, p_other, d_x) == 0)
      continue;
    if (do_objs_intersect_on_z (p_obj, p_other, d_z) == 0)
      continue;
      
    while (1)
    {
      if (do_objs_intersect_on_y (p_obj, p_other, d_y) == 0)
        break;
      p_obj->flags12 |= FLAG_Y_OOB;
      // obj bit 7 -> other bit 6
      p_other->flags13 |= (p_obj->flags13 >> 1) & FLAG_DEAD;
      // other bit 5 -> obj bit 6
      p_obj->flags13 |= (p_other->flags13 << 1) & FLAG_DEAD;
      if ((p_other->flags7 & FLAG_MOVEABLE) != 0)
        p_other->d_y = p_obj->d_y;
      if ((d_y = adj_d_for_out_of_bounds (d_y)) == 0)
        return (d_y);
    }
  }
  return (d_y);
}

// $CC38
int8_t adj_dZ_for_obj_intersect (POBJ32 p_obj, int8_t d_x, int8_t d_y, int8_t d_z)
{
  POBJ32    p_other;
  unsigned  i;
  
  UNTESTED;
  
  p_other = graphic_objs_tbl;
  for (i=0; i<MAX_OBJS; i++, p_other++)
  {
    if (is_object_not_ignored (p_other) == 0)
      continue;
    if (do_objs_intersect_on_x (p_obj, p_other, d_x) == 0)
      continue;
    if (do_objs_intersect_on_y (p_obj, p_other, d_y) == 0)
      continue;
      
    while (1)
    {
      if (do_objs_intersect_on_z (p_obj, p_other, d_z) == 0)
        break;
      p_obj->flags12 |= FLAG_Z_OOB;
      // obj bit 7 -> other bit 6
      p_other->flags13 |= (p_obj->flags13 >> 1) & FLAG_DEAD;
      // other bit 5 -> obj bit 6
      p_obj->flags13 |= (p_other->flags13 << 1) & FLAG_DEAD;
      // used by dropping, collapsing blocks
      p_other->flags13 |= FLAG_TRIGGERED;
      if ((p_obj->flags7 & FLAG_MOVEABLE) != 0)
      {
        if (p_obj->d_x == 0)
          p_obj->d_x = p_other->d_x;
        if (p_obj->d_y == 0)
          p_obj->d_y = p_other->d_y;
      }
      if ((d_z = adj_d_for_out_of_bounds (d_z)) == 0)
        return (d_z);
    }
  }
  return (d_z);
}

// $CC9D
// return (state of carry flag)
uint8_t do_objs_intersect_on_x (POBJ32 p_obj, POBJ32 p_other, int8_t d_x)
{
  int8_t d, a;
  
  UNTESTED;

  d = p_obj->width + p_other->width;
  a = abs((int8_t)(p_obj->x + d_x - p_other->x));
    
  return (a < d ? 1 : 0);
}

// $CCB2
uint8_t do_objs_intersect_on_y (POBJ32 p_obj, POBJ32 p_other, int8_t d_y)
{
  int8_t d, a;

  UNTESTED;
  
  d = p_obj->depth + p_other->depth;
  a = abs((int8_t)(p_obj->y + d_y - p_other->y));
  
  return (a < d ? 1 : 0);
}

// $CCC7
uint8_t do_objs_intersect_on_z (POBJ32 p_obj, POBJ32 p_other, int8_t d_z)
{
  int8_t d, a;

  UNTESTED;
  
  a = p_obj->z + d_z - p_other->z;
  if (a < 0)
  {
    a = -a;
    d = p_obj->height;
  }    
  else
    d = p_other->height;
  
  return (a < d ? 1 : 0);
}

// $CCDD
int8_t adj_dX_for_out_of_bounds (POBJ32 p_obj, int8_t d_x)
{
  if ((p_obj->flags12 & MASK_ENTERING_SCRN) != 0)
    return (d_x);
  if ((p_obj->flags7 & FLAG_NEAR_ARCH) != 0)
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
  if ((p_obj->flags12 & MASK_ENTERING_SCRN) != 0)
    return (d_y);
  if ((p_obj->flags7 & FLAG_NEAR_ARCH) != 0)
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

// $CD33
void calc_2d_info (POBJ32 p_obj)
{
  uint8_t *psprite;

  calc_pixel_XY (p_obj);

  psprite = flip_sprite (p_obj);
  p_obj->data_width_bytes = *(psprite++) & 0x0F;
  if ((p_obj->pixel_x & 7) != 0)
    p_obj->data_width_bytes++;
  p_obj->data_height_lines = *psprite;
}

// $CD4D
void set_draw_objs_overlapped (POBJ32 p_obj)
{
  POBJ32    p_other;
  unsigned  i;
  uint8_t   a,d,e,h,l;
  
  calc_2d_info (p_obj);
  
  l = p_obj->pixel_x >> 3;
  h = p_obj->old_pixel_x >> 3;
  e = (h < l ? h : l);          // left extremity
  l += p_obj->data_width_bytes;
  h += p_obj->old_data_width_bytes; 
  a = (h < l ? l : h);          // right extremity
  d = a - e;                    // combined width
  
  l = (p_obj->pixel_y < p_obj->old_pixel_y 
        ? p_obj->pixel_y 
        : p_obj->old_pixel_y);  // lowest Y
  h = p_obj->pixel_y + p_obj->data_height_lines;
  a = p_obj->old_pixel_y + p_obj->old_data_height_lines;
  if (a < h) a = h;             // highest Y
  h = a - l;                    // combined height

  p_other = graphic_objs_tbl;  
  for (i=0; i<MAX_OBJS; i++, p_other++)
  {
    if (p_other->graphic_no == 0)
      continue;
    if ((p_other->flags7 & FLAG_DRAW) != 0)
      continue;

    a = p_other->pixel_x >> 3;
    if (a < e)
    {
      if ((a + p_other->data_width_bytes) < e)
        continue;
    }
    else if (a >= (e+d))
      continue;
    if (p_other->pixel_y < l)
    {
      if ((p_other->pixel_y + p_other->data_height_lines) < l)
        continue;
    }
    else if (p_other->pixel_y >= (l+h))
      continue;
    p_other->flags7 |= FLAG_DRAW;        
  }
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
  // bottom half
  POBJ32 p_prev_obj = p_obj-1;

  UNTESTED;
  
  if (all_objs_in_cauldron == 0 &&
      (p_obj->flags13 & FLAG_DEAD) != 0)
    init_death_sparkles (p_obj);
  else
  {
    // copy x,y,z,w,d,h,flags7 from bottom half
    memcpy (&(p_obj->x), &(p_prev_obj->x), 7);
    p_obj->height = 0;
    p_obj->flags7 |= FLAG_IGNORE_3D;
    if ((p_obj->flags13 & MASK_LOOK_CNT) == 0)
    {
      if (seed_3 < 2)
      {
        // look one way
        p_obj->graphic_no = (p_prev_obj->graphic_no & 0xF8) | 6;
        p_obj->flags13 = 8;   // look for 8 iterations
      }
      else if (seed_3 >= 0xFE)
      {
        // look another way
        p_obj->graphic_no = (p_prev_obj->graphic_no & 0xF8) | 7;
        p_obj->flags13 = 8;   // look for 8 iterations
      }
      else
        // look straight ahead
        p_obj->graphic_no = p_prev_obj->graphic_no;
      p_obj->graphic_no += 16;
    }
    else
      p_obj->flags13--;

    // directly above bottom half    
    p_obj->z = p_prev_obj->z + 12;
    set_draw_objs_overlapped (p_obj);
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
  
  //DBGPRINTF_FN;
  
  for (i=0; i<MAX_OBJS; i++)
  {
    if ((graphic_objs_tbl[i].graphic_no != 0) &&
        (graphic_objs_tbl[i].flags7 & FLAG_DRAW))
    {
      //DBGPRINTF ("[%02d]=%02d(graphic_no=$%02X,flags7=$%02X)\n",
      //          n, i, graphic_objs_tbl[i].graphic_no, graphic_objs_tbl[i].flags7);
      objects_to_draw[n++] = i;
    }
  }
  objects_to_draw[n] = 0xff;

  //DBGPRINTF ("  n=%d\n", n);
}

// $CEBB
void calc_display_order_and_render (void)
{
  unsigned obj_i, other_i;
  unsigned c;
  unsigned s;
    
  static uint8_t render_list[8] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
  
  UNTESTED;

  //dump_objects_to_draw ();
  
  rendered_objs_cnt = 0;

process_remaining_objs:
  obj_i = 0;  
  other_i = obj_i + 1;
  
  while (objects_to_draw[obj_i] != 0xFF)
  {
    POBJ32 p_obj;
    
    // already rendered?
    if ((objects_to_draw[obj_i] & (1<<7)) != 0)
    {
      obj_i++;
      continue;
    }
    render_obj_1 = obj_i+1;
      
    p_obj = &graphic_objs_tbl[objects_to_draw[obj_i]];
    
  #ifndef BUILD_OPT_DISABLE_Z_ORDER
    while (objects_to_draw[other_i] != 0xFF)
    {
      POBJ32 p_other;

      // already rendered?      
      if ((objects_to_draw[other_i] & (1<<7)) != 0)
      {
        other_i++;
        continue;
      }
        
      p_other = &graphic_objs_tbl[objects_to_draw[other_i]];
      render_obj_2 = other_i+1;
      
      // same object?
      if (objects_to_draw[obj_i] == objects_to_draw[other_i])
      {
        other_i++;
        continue;
      }

      c = 0;
      if ((p_other->z + p_other->height) > p_obj->z)
      {
        if ((p_obj->z + p_obj->height) > p_other->z)
          c += 1;
        else
          c += 2;
      }
      if ((p_other->y + p_other->depth) > (p_obj->y - p_obj->depth))
      {
        if ((p_obj->y + p_obj->depth) > (p_other->y - p_other->depth))
          c += 3;
        else
          c += 6;
      }
      if ((p_other->x + p_other->width) > (p_obj->x - p_obj->width))
      {
        if ((p_obj->x + p_obj->width) > (p_other->x - p_other->width))
          c += 9;
        else
          c += 18;
      }
      
      switch (c)
      {
        // original code distinguishes between these two sets of cases
        // but the end result is the same - so follow suit
        case 0 : case 1 : case 2 : case 5 : case 8 : case 9 : 
        case 17 : case 18 : case 21 : case 24 : case 25 : case 26 :
          //break;
        case 10 : case 11 : case 14 : case 19 : case 20 : 
        case 22 : case 23 :
          other_i++;
          continue;
          break;
        case 3 : case 4 : case 6 : case 7 :
        case 12 : case 15 : case 16 :
          for (s=0; render_list[s]!=0xff; s++)
          {
            if (render_list[s] == render_obj_2-1)
            {
              for (obj_i=0; objects_to_draw[obj_i] != 0xff; obj_i++)
                if (objects_to_draw[obj_i] == objects_to_draw[render_obj_2-1])
                  goto render_obj;
              goto process_remaining_objs;
            }
          }
          render_list[s] = render_obj_2-1;
          render_list[++s] = 0xff;
          obj_i = other_i;
          p_obj = p_other;
          other_i = 0;
          render_obj_1 = render_obj_2;
          continue;
          break;
        case 13 :
          //DBGPRINTF ("case 13\n");
        default :
          // X,Y,Z all overlap
          // - set special objects to twinkle sprites
          if ((uint8_t)(p_obj->graphic_no - 0x60) <= 7)
            p_obj->graphic_no = 187;
          else if ((uint8_t)(p_other->graphic_no - 0x60) <= 7)
            p_other->graphic_no = 187;
          other_i++;
          continue;
          break;
      }
    }
    
render_obj:
    //DBGPRINTF ("rendering #%d=%d\n", obj_i, objects_to_draw[obj_i]);
    // we may have modified obj_i    
    p_obj = &graphic_objs_tbl[objects_to_draw[obj_i]];
    // flag as rendered
    objects_to_draw[obj_i] |= (1<<7);
    // clear render_list
    render_list[0] = 0xff;
    rendered_objs_cnt++;
    calc_pixel_XY_and_render (p_obj);
    // and start from the beginning again
    goto process_remaining_objs;
  #else
    //DBGPRINTF ("rendering #%d=%d\n", obj_i, objects_to_draw[obj_i]);
    calc_pixel_XY_and_render (p_obj);
    obj_i++;
  #endif // BUILD_OPT_DISABLE_Z_ORDER
  }
  
  //DBGPRINTF ("rendered_objs_cnt = %d\n", rendered_objs_cnt);
}

// $D022
uint8_t check_user_input (void)
{
  if (all_objs_in_cauldron != 0 || obj_dropping_into_cauldron != 0)
  {
    user_input = 0;
    goto finished_input;
  }
  
  // handle various input methods here
  goto keyboard;
  
keyboard:
  user_input = 0;
  if (osd_key(OSD_KEY_Z) || osd_key(OSD_KEY_C) || osd_key(OSD_KEY_B) || osd_key(OSD_KEY_M))
    user_input |= INP_LEFT;
  if (osd_key(OSD_KEY_X) || osd_key(OSD_KEY_V) || osd_key(OSD_KEY_N))
    user_input |= INP_RIGHT;
  if (osd_key(OSD_KEY_A) || osd_key(OSD_KEY_S) || osd_key(OSD_KEY_D) || osd_key(OSD_KEY_F) ||
      osd_key(OSD_KEY_G) || osd_key(OSD_KEY_H) || osd_key(OSD_KEY_J) || osd_key(OSD_KEY_K) ||
      osd_key(OSD_KEY_L))
    user_input |= INP_FORWARD;
  if (osd_key(OSD_KEY_Q) || osd_key(OSD_KEY_W) || osd_key(OSD_KEY_E) || osd_key(OSD_KEY_R) ||
      osd_key(OSD_KEY_T) || osd_key(OSD_KEY_Y) || osd_key(OSD_KEY_U) || osd_key(OSD_KEY_I) ||
      osd_key(OSD_KEY_O) || osd_key(OSD_KEY_P))
    user_input |= INP_JUMP;
  if (osd_key(OSD_KEY_1) || osd_key(OSD_KEY_2) || osd_key(OSD_KEY_3) || osd_key(OSD_KEY_4) ||
      osd_key(OSD_KEY_5) || osd_key(OSD_KEY_6) || osd_key(OSD_KEY_7) || osd_key(OSD_KEY_8) ||
      osd_key(OSD_KEY_9) || osd_key(OSD_KEY_0))
    user_input |= INP_PICKUP_DROP;

finished_input:
  // something sets bit 5 here?!?
  ;
  
  return (user_input);
}

// $D12A
int lose_life (void)
{
  POBJ32  p_obj = graphic_objs_tbl;
  POBJ32  p_next_obj = p_obj+1;
  uint8_t c;
  
  UNTESTED;

  memcpy ((void *)&graphic_objs_tbl[0], (void *)&plyr_spr_1_scratchpad, sizeof(OBJ32));
  memcpy ((void *)&graphic_objs_tbl[1], (void *)&plyr_spr_2_scratchpad, sizeof(OBJ32));
  transform_flag_graphic = 0;
  if (--lives < 0)
  {
    game_over ();
    // longjmp to start_menu
  }

  c = (sun_moon_scratchpad.graphic_no << 5) & 0x20;
  p_obj->u.plyr_graphic_no = (p_obj->u.plyr_graphic_no & 0x1F) + c;
  p_next_obj->u.plyr_graphic_no = (p_next_obj->u.plyr_graphic_no & 0x0F) + c + 32;
  
  DBGPRINTF ("%s() got=%d,ps1s=%d\n", __FUNCTION__, 
              graphic_objs_tbl[0].scrn,
              plyr_spr_1_scratchpad.scrn);
              
  // caller needs this value
  return (lives);  
}

// $D1B1
void init_start_location (void)
{
  uint8_t s;

  memcpy ((uint8_t *)&plyr_spr_1_scratchpad, plyr_spr_init_data+0, 8);
  memcpy ((uint8_t *)&plyr_spr_2_scratchpad, plyr_spr_init_data+8, 8);
  // set graphic_no for player sprites (after sparkles)
  plyr_spr_1_scratchpad.u.plyr_graphic_no = 18;   // legs
  plyr_spr_2_scratchpad.u.plyr_graphic_no = 34;   // top half
  s = start_locations[seed_1 & 3];
  s = 31;
  // start_loc_1
  plyr_spr_1_scratchpad.scrn = s;
  // start_loc_2
  plyr_spr_2_scratchpad.scrn = s;
  
  // for hardware sprites
  plyr_spr_1_scratchpad.unused[0] = 0;
  plyr_spr_2_scratchpad.unused[0] = 1;
  
  DBGPRINTF ("%s(): start_location=%d\n", __FUNCTION__, s);
}

// $D1E6
void build_screen_objects (void)
{
  if (not_1st_screen != 0)
    update_special_objs ();
    
  clear_scrn_buffer ();
  retrieve_screen ();
  find_special_objs_here ();
  adjust_plyr_xyz_for_room_size (graphic_objs_tbl);
  portcullis_moving = 0;
  portcullis_move_cnt = 0;
  ball_bounce_height = 0;
  is_spike_ball_dropping = 0;
  render_status_info = 1;
  // spiked balls don't drop immediately in odd-numbered rooms
  disable_spike_ball_drop = graphic_objs_tbl[0].scrn & 1;
  flag_scrn_visited ();
}

// $D219
void flag_scrn_visited (void)
{
  uint8_t scrn = graphic_objs_tbl[0].scrn;
  scrn_visited[scrn>>3] |= 1<<(scrn&7);
}

// $D237
uint8_t *transfer_sprite (POBJ32 p_obj, uint8_t *psprite)
{
  p_obj->graphic_no = *(psprite++);
  p_obj->flags7 = *(psprite++);
  p_obj->pixel_x = *(psprite++);
  p_obj->pixel_y = *(psprite++);

  return (psprite);
}

// $D24C
uint8_t *transfer_sprite_and_print (uint8_t type, POBJ32 p_obj, uint8_t *psprite)
{
  uint8_t *p = transfer_sprite (p_obj, psprite);
  print_sprite (type, p_obj);

  return (p);
}

// $D255
void display_panel (void)
{
  uint8_t *p = (uint8_t *)panel_data;
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (PANEL_STATIC, &sprite_scratchpad, 16, (uint8_t)-8, 5);
  p = transfer_sprite_and_print (PANEL_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite_and_print (PANEL_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (PANEL_STATIC, &sprite_scratchpad, 16, 8, 5);
  p = transfer_sprite_and_print (PANEL_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite_and_print (PANEL_STATIC, &sprite_scratchpad, p);
}

// $D296
void print_border (void)
{
  uint8_t *p = (uint8_t *)border_data;
  p = transfer_sprite_and_print (MENU_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite_and_print (MENU_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite_and_print (MENU_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite_and_print (MENU_STATIC, &sprite_scratchpad, p);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (MENU_STATIC, &sprite_scratchpad, 8, 0, 24);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (MENU_STATIC, &sprite_scratchpad, 8, 0, 24);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (MENU_STATIC, &sprite_scratchpad, 0, 1, 128);
  p = transfer_sprite (&sprite_scratchpad, p);
  multiple_print_sprite (MENU_STATIC, &sprite_scratchpad, 0, 1, 128);
}

// $D2EF
void colour_panel (void)
{
  // this effectively wipes the sun from
  // the left of the frame
  
  // A=$00, HL=$5AB6, BC=$0103, jp fill_window
  // A=$00, HL=$5ABD, BC=$0103, jp fill_window
  // A=$42, HL=$5A97, BC=$0604, jp fill_window
}

// $D30D
void colour_sun_moon (void)
{
  // fills frame attr memory with
  // $46 for sun
  // $47 for moon
  uint8_t attr = 0x46;
  if ((sun_moon_scratchpad.graphic_no & 1) != 0)
    attr++;
  // HL=$5AB8, BC=$0402, jp fill_window
}

// $D320
void adjust_plyr_xyz_for_room_size (POBJ32 p_obj)
{
  POBJ32 p_next_obj = p_obj+1;
  
  if (p_obj->x == 0)
  {
    adjust_plyr_Z_for_arch (p_obj, 55);
    p_obj->x = (room_size_X-2) + 128 + p_obj->width;
  }
  else
  if (p_obj->x == (uint8_t)-1)
  {
    adjust_plyr_Z_for_arch (p_obj, 174);
    p_obj->x = 128 - (room_size_X-2) - p_obj->width;
    
  }
  else
  if (p_obj->y == 0)
  {
    adjust_plyr_Z_for_arch (p_obj, 81);
    p_obj->y = (room_size_Y-2) + 128 + p_obj->depth;
  }
  else
  if (p_obj->y == (uint8_t)-1)
  {
    adjust_plyr_Z_for_arch (p_obj, 200);
    p_obj->y = 128 - (room_size_Y-2) - p_obj->depth;
  }
  else
    return;
    
  p_obj->flags7 |= FLAG_DRAW;
  p_next_obj->flags7 |= FLAG_DRAW;
  p_next_obj->x = p_obj->x;
  p_next_obj->y = p_obj->y;    
}

// $D38C
void adjust_plyr_Z_for_arch (POBJ32 p_obj, uint8_t xy)
{
  POBJ32    p_next_obj = p_obj+1;
  POBJ32    p_other;
  unsigned  i;

  // max 4 arches, must be first 4 objects in room  
  p_other = other_objs_here;
  for (i=0; i<4; i++, p_other++)
  {
    // no more arches?
    if (p_other->graphic_no >= 6)
      return;
    if ((p_other->x + p_other->y) == xy)
    {
      p_obj->z = p_other->z;
      p_next_obj->z = p_other->z + 12;
      return;
    }
  }
}

// $D3C6
void retrieve_screen (void)
{
  POBJ32 p_other_objs = other_objs_here;
  unsigned n_other_objs = 0;
  uint8_t room_size;
  unsigned p = 0;
  unsigned i;

  uint8_t id;
  uint8_t size;
  uint8_t attr;

  uint8_t obj_no = 4;
      
  DBGPRINTF_FN;
  
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
  //DBGPRINTF ("%s(): location=%d\n", __FUNCTION__, location_tbl[p]);
  
  id = location_tbl[p++];
  size = location_tbl[p++];
  attr = location_tbl[p++];

  DBGPRINTF ("id=%d, size=%d, attr=$%02X\n", id, size, attr);
  
  // get attribute, set BRIGHT  
  curr_room_attrib = (attr & 7) | 0x40;

  room_size = (attr >> 3) & 0x1F;
  room_size_X = room_size_tbl[room_size].x;
  room_size_Y = room_size_tbl[room_size].y;
  room_size_Z = room_size_tbl[room_size].z;

  DBGPRINTF ("room size = (%d,%d,%d)\n",
            room_size_X, room_size_Y, room_size_Z);

  // bytes remaining in location table
  size -= 2;
  
  // do the background objects
  for (; size && location_tbl[p] != 0xFF; size--, p++)
  {
    uint8_t *p_bg_obj;

    next_bg_obj:
    
    // get background type
    p_bg_obj = (uint8_t *)background_type_tbl[location_tbl[p]];

    DBGPRINTF ("BG:%d\n", location_tbl[p]);

    for (; *p_bg_obj!=0; p_bg_obj+=8)
    {    
      next_bg_obj_sprite:
        
      // copy sprite,x,y,z,w,d,h,flags7
      memcpy ((uint8_t *)p_other_objs, p_bg_obj, 8);
      // set screen (location)
      p_other_objs->scrn = plyr_spr_1_scratchpad.scrn;
      // zero everything else
      memset (&p_other_objs->d_x, 0, 23);

      // added for hardware sprites
      p_other_objs->unused[0] = obj_no++;
            
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
      uint8_t *p_fg_obj = (uint8_t *)block_type_tbl[block];
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
        p_other_objs->flags7 = p_fg_obj[4];
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

        // added for hardware sprites
        p_other_objs->unused[0] = obj_no++;

        // debug ONLY
        //if (p_other_objs->graphic_no == 182)
        //if (0)
        {
          p_other_objs++;
          n_other_objs++;
        }
      }
    }
  }
  
  DBGPRINTF ("n_other_objs = %d\n", n_other_objs);

  // clear the rest of the table
  for (; n_other_objs<MAX_OBJS-4; n_other_objs++)
    memset (p_other_objs++, 0, sizeof(OBJ32));
            
  dump_graphic_objs_tbl(-1, -1);
}

// $D50E
void audio_D50E (void)
{
}

// $D556
void fill_attr (uint8_t attr)
{
  // fills the entire attribute memory
  // with the 'attr' parameter
}

// $D55F
void clear_scrn (void)
{
	osd_clear_scrn ();
}

// $D567
void clear_scrn_buffer (void)
{
  osd_clear_scrn_buffer ();
}

// $D56F
void update_screen (void)
{
  // HL=$0D8F3, DE-$57E0, BC=$20C0
  // copies screen buffer to Spectrum video memory
  osd_update_screen ();
}

// $D59F 
void render_dynamic_objects (void)
{
  UNTESTED;
  
  objs_wiped_cnt = 0;
  if (render_status_info == 0)
  {
    uint8_t i;
    
    tmp_objects_to_draw = objects_to_draw;
    
    while ((i = *(tmp_objects_to_draw++)) != 0xFF)
    {
      POBJ32 p_obj = &graphic_objs_tbl[i];
      int a,b,c,e,h,l;
            
      if ((p_obj->flags7 & FLAG_WIPE) == 0)
        continue;
      p_obj->flags7 &= ~FLAG_WIPE;

      c = (p_obj->pixel_x < p_obj->old_pixel_x 
            ? p_obj->pixel_x 
            : p_obj->old_pixel_x);    // left extremity
      e = (p_obj->old_pixel_x >> 3) + p_obj->old_data_width_bytes;
      a = (p_obj->pixel_x >> 3) + p_obj->data_width_bytes;
      e = (a < e ? e : a);            // right extremity
      b = (c >> 3);                   // left extremity byte address
      h = e - b;                      // number of bytes to wipe/line

      b = (p_obj->pixel_y < p_obj->old_pixel_y
            ? p_obj->pixel_y
            : p_obj->old_pixel_y);    // lowest point
      e = p_obj->old_pixel_y + p_obj->old_data_height_lines;
      a = p_obj->pixel_y + p_obj->data_height_lines;
      a = (a < e ? e : a);            // highest point
      l = a - b;                      // number of lines to wipe
      if (b >= 192)                   // completely off-screen
        continue;
      a = b + l - 192;                // lowest + lines - 192
      if (a >= 0)                     // half off screen
        l -= a;                       // adjust number of lines to wipe

      // this was done on the Z80 CPU stack
      objs_wiped_stack[objs_wiped_cnt].x = c;
      objs_wiped_stack[objs_wiped_cnt].y = b;
      objs_wiped_stack[objs_wiped_cnt].width_bytes = h;
      objs_wiped_stack[objs_wiped_cnt].height_lines = l;
      objs_wiped_cnt++;
      
      #ifndef BUILD_OPT_DISABLE_WIPE
        fill_window (c, b, h, l, 0);
      #endif
    }
  }

loc_D653:
  calc_display_order_and_render ();
  print_sun_moon ();
  display_objects_carried ();
  rendered_objs_cnt += objs_wiped_cnt;

  while (objs_wiped_cnt)
  {
    objs_wiped_cnt--;
    blit_to_screen (objs_wiped_stack[objs_wiped_cnt].x,
                    objs_wiped_stack[objs_wiped_cnt].y,
                    objs_wiped_stack[objs_wiped_cnt].width_bytes,
                    objs_wiped_stack[objs_wiped_cnt].height_lines);
  }
}

// $D67C
void blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines)
{
  // x starts on a byte boundary
  x &= 0xF8;
  if (height_lines > 0)
    osd_blit_to_screen (x, y, width_bytes, height_lines);
}

// $D6C9
// returns (NC) (0) if off-screen
uint8_t calc_pixel_XY (POBJ32 p_obj)
{
  p_obj->pixel_x = p_obj->x + p_obj->y - 128 + p_obj->pixel_x_adj;
  p_obj->pixel_y = ((p_obj->y - p_obj->x + 128) >> 1) + p_obj->z - 104 + p_obj->pixel_y_adj;
  return (p_obj->pixel_y < 192);
}

#define REV(d) (((d&1)<<7)|((d&2)<<5)|((d&4)<<3)|((d&8)<<1)|((d&16)>>1)|((d&32)>>3)|((d&64)>>5)|((d&128)>>7))
//#define REV(d) d

// $D6EF
uint8_t *flip_sprite (POBJ32 p_obj)
{
  uint8_t *psprite = (uint8_t *)sprite_tbl[p_obj->graphic_no];
  
  uint8_t vflip = (p_obj->flags7 ^ (*psprite)) & FLAG_VFLIP;
  uint8_t hflip = (p_obj->flags7 ^ (*psprite)) & FLAG_HFLIP;

  uint8_t w = psprite[0] & 0x3f;
  uint8_t h = psprite[1];

  unsigned x, y;

  if (vflip)
  {
    for (x=0; x<w; x++)
      for (y=0; y<h/2; y++)
      {
        uint8_t m = psprite[2+2*(y*w+x)];
        uint8_t d = psprite[3+2*(y*w+x)];
        psprite[2+2*(y*w+x)] = psprite[2+2*((h-1-y)*w+x)];
        psprite[3+2*(y*w+x)] = psprite[3+2*((h-1-y)*w+x)];
        psprite[2+2*((h-1-y)*w+x)] = m;
        psprite[3+2*((h-1-y)*w+x)] = d;
      }
    *psprite ^= FLAG_VFLIP;
  }

  if (hflip)
  {
    for (y=0; y<h; y++)
    {
      for (x=0; x<w/2; x++)
      {
        uint8_t m = psprite[2+2*(y*w+x)];
        uint8_t d = psprite[3+2*(y*w+x)];
        psprite[2+2*(y*w+x)] = REV(psprite[2+2*(y*w+w-1-x)]);
        psprite[3+2*(y*w+x)] = REV(psprite[3+2*(y*w+w-1-x)]);
        psprite[2+2*(y*w+w-1-x)] = REV(m);
        psprite[3+2*(y*w+w-1-x)] = REV(d);
      }
      if (w & 1)
      {
        psprite[2+2*(y*w+x)] = REV(psprite[2+2*(y*w+x)]);
        psprite[3+2*(y*w+x)] = REV(psprite[3+2*(y*w+x)]);
      }
    }
    *psprite ^= FLAG_HFLIP;
  }

  return (psprite);
}

// $D704
void calc_pixel_XY_and_render (POBJ32 p_obj)
{
  // flagged as invalid?
  if (p_obj->graphic_no == 1)
  {
    p_obj->graphic_no = 0;
    return;
  }
    
  // flag don't draw
  p_obj->flags7 &= ~FLAG_DRAW;
  
  if (calc_pixel_XY (p_obj) == 0)
    return;
  
  // debug only
  //if (p_obj->graphic_no != 2 && p_obj->graphic_no != 3)
  //if (p_obj->graphic_no == 7)
  {
    print_sprite (DYNAMIC, p_obj);
  }
}

// $D718
void print_sprite (uint8_t type, POBJ32 p_obj)
{
  uint8_t *psprite = flip_sprite (p_obj);
  
  if ((p_obj->pixel_x & 7) == 0)
    p_obj->data_width_bytes = *psprite & 0x0f;
  else
    p_obj->data_width_bytes = (*psprite & 0x07) + 1;
  psprite++;
  p_obj->data_height_lines = *psprite;
    
  osd_print_sprite (type, p_obj);
}
