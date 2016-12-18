#include "osd_types.h"
#include "lr_osd.h"
#include "debug.h"

#include "vars.h"

#define STATIC
//#define STATIC  static

#ifndef __cplusplus
  typedef uint8_t bool;
  #define false   0
  #define true    1
#endif

extern const uint8_t demo_level_data[][256];
extern const uint8_t game_level_data[][256];

typedef enum
{
  TILE_SPACE = 0,
  TILE_BRICK,
  TILE_SOLID,
  TILE_LADDER,
  TILE_ROPE,
  TILE_FALLTHRU,
  TILE_EOS_LADDER,
  TILE_GOLD,
  TILE_GUARD,
  TILE_PLAYER
  
} E_TILE;

//#define DEBUG
//#define DEBUG_DISABLE_DEMO_EXIT
//#define DEBUG_GUARD_COPY
//#define DEBUG_INVINCIBLE
//#define DEBUG_NO_BITWISE_COLLISION_DETECT

#ifndef DEBUG_INVINCIBLE
  #define KILL_PLAYER   zp.level_active >>= 1
#else
  #define KILL_PLAYER  
#endif

// comment out for default values
#define START_LEVEL_0_BASED 0
//#define NO_LIVES						1

// derived - do not edit
// sets default values
#ifndef START_LEVEL_0_BASED
	#define START_LEVEL_0_BASED 	0
#endif
#ifndef NO_LIVES
	#define NO_LIVES							3
#endif

//#define CHAMPIONSHIP

#ifndef CHAMPIONSHIP
  #define SCORE_GOLD				250
  #define SCORE_LEVEL				100
  #define SCORE_LEVEL_MULT	15
  #define SCORE_TRAP				75
  #define SCORE_KILL				75
  //#define NUM_LEVELS			  150
  #define NUM_LEVELS				10
#else
  #define SCORE_GOLD				500
  #define SCORE_LEVEL				100
  #define SCORE_LEVEL_MULT	20
  #define SCORE_TRAP				100
  #define SCORE_KILL				100
  #define NUM_LEVELS				50
#endif

ZEROPAGE	zp;

// RAM

uint8_t eos_ladder_col[0x30];
uint8_t eos_ladder_row[0x30];
uint8_t guard_col[8];
uint8_t guard_row[8];
int8_t  guard_state[8];
int8_t 	guard_x_offset[8];
int8_t 	guard_y_offset[8];
uint8_t guard_sprite[8];
uint8_t guard_dir[8];
uint8_t guard_cnt[8];
uint8_t hole_col[0x20];
uint8_t hole_row[0x20];
uint8_t hole_cnt[0x20];

uint8_t level_data_packed[256];

uint8_t ldu1[16][28];
uint8_t ldu2[16][28];

HS_ENTRY	hs_tbl[10] =
{
	{ { 'M', 'M', 'C' }, 42, 314159 },
};

extern const uint8_t attract_move_tbl[];

// end of RAM

// prototypes

STATIC void display_title_screen (void);
STATIC void zero_score_and_init_game (void);
STATIC void main_game_loop (void);
STATIC bool title_wait_for_key (void);
STATIC void init_read_unpack_display_level (uint8_t editor_n);
STATIC void read_level_data (void);
STATIC void init_and_draw_level (void);
STATIC bool draw_level (void);
STATIC void handle_player (void);
STATIC void draw_player_sprite (void);
STATIC bool move_left (void);
STATIC bool move_right (void);
STATIC bool move_up (void);
STATIC bool move_down (void);
STATIC bool dig_left (void);
STATIC bool digging_left (void);
STATIC bool dig_right (void);
STATIC bool digging_right (void);
STATIC void read_controls (void);
STATIC void calc_char_and_addr (uint8_t *chr, uint8_t *x_div_2, uint8_t *y);
STATIC void check_for_gold (void);
STATIC void update_sprite_index (uint8_t first, uint8_t last);
STATIC void adjust_x_offset_in_tile (void);
STATIC void adjust_y_offset_within_tile (void);
STATIC bool add_hole_entry (uint8_t col);
STATIC void handle_guards (void);
STATIC void update_guards (void);
STATIC void guard_ai_left (void);
STATIC void guard_ai_right (void);
STATIC void guard_ai_up_down (void);
STATIC uint8_t calc_row_col_delta (uint8_t col, uint8_t farthest);
STATIC uint8_t find_farthest_up (uint8_t row, uint8_t col);
STATIC uint8_t find_farthest_down (uint8_t row, uint8_t col);
STATIC void find_farthest_left_right (uint8_t row, uint8_t col);
STATIC void calc_guard_xychar (uint8_t *chr, uint8_t *x_div_2, uint8_t *y);
STATIC void guard_cant_climb (void);
STATIC void guard_move_up (void);
STATIC void guard_move_down (void);
STATIC void update_guard_climber_sprite (void);
STATIC void guard_move_left (void);
STATIC void guard_move_right (void);
STATIC uint8_t guard_ai (uint8_t row, uint8_t col);
STATIC void check_guard_pickup_gold (void);
STATIC void check_guard_drop_gold (void);
STATIC void update_guard_sprite_index (uint8_t first, uint8_t last);
STATIC void adjust_guard_x_offset (void);
STATIC void adjust_guard_y_offset (void);
STATIC void copy_curr_to_guard (void);
STATIC void copy_guard_to_curr (void);
STATIC void respawn_guards_and_update_holes (void);
STATIC void check_and_handle_respawn (void);
STATIC void cls_and_display_high_scores (void);
STATIC void cls_and_display_game_status (void);
STATIC void gcls (uint8_t page);
STATIC void display_no_lives (void);
STATIC void display_byte (uint8_t col, uint8_t byte);
STATIC void display_level (void);
STATIC void update_and_display_score (uint16_t pts);
STATIC void display_digit (uint8_t digit);
STATIC uint8_t remap_character (uint8_t chr);
STATIC void display_character (uint8_t chr);
STATIC void cr (void);
STATIC void display_char_pg (uint8_t page, uint8_t chr);
STATIC void wipe_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y);
STATIC void display_transparent_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y);
STATIC uint8_t check_and_update_high_score_tbl (void);
STATIC uint8_t blink_char_cursor_wait_key (uint8_t chr);
STATIC void draw_end_of_screen_ladder (void);
STATIC void beep (void);
STATIC void display_message (const char *msg);
STATIC uint8_t blink_char_and_wait_for_key (uint8_t chr);
STATIC void play_sound (uint8_t freq, uint8_t duration);
STATIC void throttle_and_update_sound (void);
STATIC void calc_colx5_scanline (uint8_t col, uint8_t row, uint8_t *colx5, uint8_t *scanline);
STATIC void calc_scanline (uint8_t row, uint8_t offset, uint8_t *scanline);
STATIC void calc_x_div_2 (uint8_t col, uint8_t offset, uint8_t *x);
STATIC void wipe_and_draw_level (void);
STATIC uint8_t game_over_animation (void);

// end of prototypes

void lode_runner (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);

	zp.game_speed = 6;
	zp.byte_64 = 0;
	zp.sound_enabled = (uint8_t)-1;

display_title_screen:	
	display_title_screen ();
	OSD_HGR1;
	goto title_wait_for_key;
	
zero_score_and_init_game:
	zero_score_and_init_game ();
	main_game_loop ();

title_wait_for_key:
	if (title_wait_for_key ())
		goto check_start_new_game;

	if (zp.attract_mode != 0)
		goto loc_61de;
		
	// init attract mode
	zp.attract_mode = 1;
	zp.level = 1;
	zp.byte_ac = 1;
	zp.no_cheat = 1;
	zp.sound_setting = zp.sound_enabled;
	zp.sound_enabled = 0;
	goto zero_score_and_init_game;
	
//end_demo:
	zp.sound_enabled = zp.sound_setting;
	goto title_wait_for_key;
	
loc_61de:
	if (zp.attract_mode != 1)
		goto display_title_screen;

read_and_display_scores:
	osd_load_high_scores (hs_tbl);
//high_score_screen:
	cls_and_display_high_scores ();
	zp.attract_mode = 2;
	goto title_wait_for_key;

check_start_new_game:
	// hack for exit
	if (osd_key (LR_KEY_ESC))
		return;
	if ((osd_readkey ()) == LR_KEY_CR)
		goto read_and_display_scores;

//start_new_game:
	zp.level_0_based = START_LEVEL_0_BASED;
	zp.level = zp.level_0_based + 1;
	zp.no_cheat = 1;
	zp.attract_mode = 2;
	goto zero_score_and_init_game;
}

void display_title_screen (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);

	gcls (1);
	zp.attract_mode = 0;
	zp.level_0_based = 0;
	zp.display_char_page = 1;

  #if 1
    osd_display_title_screen (zp.display_char_page);
  #else
    zp.col = 2;
    zp.row = 8;
    display_message ("INSERT TITLE SCREEN HERE");
  #endif
}

void zero_score_and_init_game (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);
	
	zp.score = 0;
	zp.unused_97 = 0;
	zp.wipe_next_time = 0;
	zp.guard_respawn_col = 0;
	zp.demo_inp_cnt = 0;
	zp.demo_inp_ptr = attract_move_tbl;
	zp.no_lives = NO_LIVES;
	if (zp.attract_mode >> 1)
	  ;
	cls_and_display_game_status ();
	OSD_HGR1;
	// main_game_loop ();
}

void main_game_loop (void)
{
  static const uint8_t guard_params[][3] =
  {
		{ 0, 0, 0 },
    { 0, 1, 1 },
    { 1, 1, 1 },
    { 1, 3, 1 },
    { 1, 3, 3 },
    { 3, 3, 3 },
    { 3, 3, 7 },
    { 3, 7, 7 },
    { 7, 7, 7 },
    { 7, 7, 0xF },
    { 7, 0xF, 0xF },
    { 0xF, 0xF, 0xF }
  };

  static const uint8_t guard_trap_cnt_init_tbl[] =
  {
    0x26, 0x26, 0x2E, 0x44, 0x47, 0x49, 0x4A, 0x4B, 0x4C, 
    0x4D, 0x4E, 0x4F, 0x50
  };

	uint8_t   data;
  unsigned  i;
  
	OSD_PRINTF ("%s()\n", __FUNCTION__);

main_game_loop:
  
	init_read_unpack_display_level (1);
	zp.key_1 = 0;
	zp.key_2 = 0;
	if ((zp.attract_mode >> 1) != 0)
	{
		zp.col = zp.current_col;
		zp.row = zp.current_row;
		blink_char_and_wait_for_key (TILE_PLAYER);
	}
	zp.dig_dir = 0;
	zp.sndq_length = 0;
	// unused_97 should be zero
	data = (zp.unused_97 + zp.no_guards);
  zp.byte_60[0] = guard_params[data][0];
	zp.byte_60[1] = guard_params[data][1];
	zp.byte_60[2] = guard_params[data][2];
	// unused_97 should be zero
	zp.guard_trap_cnt_init = guard_trap_cnt_init_tbl[zp.unused_97];

in_level_loop:
  
  // hack for exit
  if (osd_key (LR_KEY_ESC))
    return;
  
  handle_player ();
  if (zp.level_active == 0)
    goto dec_lives;
  throttle_and_update_sound ();
  if (zp.no_gold == 0)
    draw_end_of_screen_ladder ();
  if (zp.current_row == 0)
    if (zp.y_offset_within_tile == 2)
      if (zp.no_gold == 0 || zp.no_gold == (uint8_t)-1)
        goto next_level;
  respawn_guards_and_update_holes ();
  if (zp.level_active == 0)
    goto dec_lives;
  throttle_and_update_sound ();
  handle_guards ();
  if (zp.level_active == 0)
    goto dec_lives;
  goto in_level_loop;

next_level:
  zp.level++;
  zp.level_0_based++;
  if (zp.no_lives != 255)
    zp.no_lives++;
  for (i=0; i<SCORE_LEVEL_MULT; i++)
  {
    update_and_display_score (SCORE_LEVEL);
    //play_score_sound ();
    //play_score_sound ();
    //play_score_sound ();
  }
  goto main_game_loop;
              
dec_lives:
  zp.no_lives--;
  display_no_lives ();
  //queue_sound ();      
  throttle_and_update_sound ();
  if ((zp.attract_mode >> 1) == 0)
    goto end_demo;
  if (zp.no_lives > 0)
    goto main_game_loop;
    
  if (check_and_update_high_score_tbl ())
  	return;
  game_over_animation ();
  return;
  
end_demo:
  zp.sound_enabled = zp.sound_setting;
}

bool title_wait_for_key (void)
{
	uint16_t  timeout;

	OSD_PRINTF ("%s()\n", __FUNCTION__);

	timeout = 5000/10;

  osd_flush_keybd ();	
	while (timeout)
	{
		if (osd_keypressed ())
			return (true);
		osd_delay (10);
		timeout--;
	}
	return (false);
}

void high_score_screen (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);
}

void init_read_unpack_display_level (uint8_t editor_n)
{
  unsigned h, g;
  
	OSD_PRINTF ("%s()\n", __FUNCTION__);
	
	zp.editor_n = editor_n;
	zp.current_col = (uint8_t)-1;
	zp.no_eos_ladder_tiles = 0;
	zp.no_gold = 0;
	zp.no_guards = 0;
	zp.curr_guard = 0;
	zp.dig_sprite = 0;
	zp.packed_byte_cnt = 0;
	zp.nibble_cnt = 0;
	zp.row = 0;
	
	for (h=0; h<=MAX_HOLES; h++)
	  hole_cnt[h] = 0;
  for (g=0; g<=MAX_GUARDS; g++)
    guard_cnt[g] = 0;
  zp.level_active = 1;
  
  read_level_data ();
  for (zp.row=0; zp.row<16; zp.row++)
  {
    for (zp.col=0; zp.col<28; zp.col++)
    {
      uint8_t data = level_data_packed[zp.packed_byte_cnt];
      if (zp.nibble_cnt % 2 == 0)
        data &= 0x0f;
      else
      {
        data >>= 4;
        zp.packed_byte_cnt++;
      }
      // validate 0-9
      if (data > 9)
        data = 0;
      // write to tilemap        
      ldu1[zp.row][zp.col] = data;
      ldu2[zp.row][zp.col] = data;
      zp.nibble_cnt++;
    }
  }
  init_and_draw_level ();
}

void read_level_data (void)
{
  const uint8_t *p;
  
	OSD_PRINTF ("%s() : level_0_based = %d, level = %d, attract_mode=%d\n", 
	          __FUNCTION__, zp.level_0_based, zp.level, zp.attract_mode);
  
  if ((zp.attract_mode >> 1) != 0)
    p = game_level_data[zp.level_0_based];
  else
    p = demo_level_data[zp.level-1];

  memcpy (level_data_packed, p, 256);
  
  //dbg_dump_level_packed ();
}

void init_and_draw_level (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);

  for (zp.row=15; zp.row!=(uint8_t)-1; zp.row--)
  {
    for (zp.col=27; zp.col!=(uint8_t)-1; zp.col--)
    {
      uint8_t tile = ldu1[zp.row][zp.col];
      uint8_t display = tile;
      
      switch (tile)
      {
        case TILE_EOS_LADDER :
          if (zp.no_eos_ladder_tiles < MAX_EOS_LADDERS)
          {
            zp.no_eos_ladder_tiles++;
            eos_ladder_row[zp.no_eos_ladder_tiles] = zp.row;
            eos_ladder_col[zp.no_eos_ladder_tiles] = zp.col;
          }
          // update tilemap with space
          ldu1[zp.row][zp.col] = 0;
          ldu2[zp.row][zp.col] = 0;
          display = TILE_SPACE;
          break;
          
        case TILE_GOLD:         
          zp.no_gold++;
          break;
          
        case TILE_GUARD:
          if (zp.no_guards < MAX_GUARDS)
          {
            zp.no_guards++;
            guard_col[zp.no_guards] = zp.col;
            guard_row[zp.no_guards] = zp.row;
            guard_state[zp.no_guards] = 0;
            guard_sprite[zp.no_guards] = 0;
            guard_x_offset [zp.no_guards] = 2;
            guard_y_offset [zp.no_guards] = 2;
            // wipe from static tilemap
            ldu2[zp.row][zp.col] = 0;
          }
          else
          {
            ldu1[zp.row][zp.col] = 0;
            ldu2[zp.row][zp.col] = 0;
            display = TILE_SPACE;
          }
          break;

        case TILE_PLAYER:
          if (zp.current_col == (uint8_t)-1)          
          {
            zp.current_col = zp.col;
            zp.current_row = zp.row;
            zp.x_offset_within_tile = 2;
            zp.y_offset_within_tile = 2;
            zp.sprite_index = 8;
            // wipe from static tilemap
            ldu2[zp.row][zp.col] = 0;
          }
          else
          {
            ldu1[zp.row][zp.col] = 0;
            ldu2[zp.row][zp.col] = 0;
            display = TILE_SPACE;
          }
          break;

        case TILE_FALLTHRU:
          display = TILE_BRICK;
          break;
                              
        default :
          break;
      }
      
      display_char_pg (2, display);
    }
  }
  // tbd: check zp.curent_col for player
  draw_level ();
}

bool draw_level (void)
{
  unsigned g = 0;
  
	OSD_PRINTF ("%s()\n", __FUNCTION__);

  //dbg_dump_level ();
  
  wipe_and_draw_level ();
  
  // wipe player and enemies from background
  for (zp.row=15; zp.row != (uint8_t)-1; zp.row--)
  {
  	for (zp.col=27; zp.col != (uint8_t)-1; zp.col--)
  	{
  		uint8_t tile = ldu1[zp.row][zp.col];
  		if (tile == TILE_PLAYER || tile == TILE_GUARD)
		  {
  			display_char_pg (2, TILE_SPACE);
  			#ifdef HAS_HWSPRITES
	  			display_char_pg (1, TILE_SPACE);
	  			if (tile == TILE_PLAYER)
	  			  display_transparent_char (0, TILE_PLAYER, zp.col*5, zp.row*11);
	  		  else if (tile == TILE_GUARD)
	  		    display_transparent_char (++g, TILE_GUARD, zp.col*5, zp.row*11);
		    #endif
  		}
  	}
  }
  return (false);
}

void handle_player (void)
{
  uint8_t tile;
  uint8_t chr, x_div_2, y;

  zp.enable_collision_detect = 1;
  if (zp.dig_dir == 0)
    goto not_digging;
  if (zp.dig_dir == -1)
    goto digging_left;
  else
    goto digging_right;

not_digging:    
  tile = ldu2[zp.current_row][zp.current_col];
  if (tile == TILE_LADDER)
    goto cant_fall;
  else 
  if (tile != TILE_ROPE)
    goto check_falling;
  else
  if (zp.y_offset_within_tile == 2)
    goto cant_fall;
    
check_falling:
  if (zp.y_offset_within_tile < 2)
    goto handle_falling;
  if (zp.current_row == 15)
    goto cant_fall;
  tile = ldu1[zp.current_row+1][zp.current_col];
  if (tile == TILE_SPACE)
    goto handle_falling;
  if (tile == TILE_GUARD)
    goto cant_fall;
  tile = ldu2[zp.current_row+1][zp.current_col];
  if (tile == TILE_BRICK || tile == TILE_SOLID)
    goto cant_fall;
  if (tile != TILE_LADDER)
    goto handle_falling;
      
cant_fall:
  goto check_falling_sound;
    
handle_falling:
  zp.not_falling = 0;
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  zp.sprite_index = (zp.dir == (uint8_t)-1 ? 7 : 15);
  adjust_x_offset_in_tile ();
  if (++zp.y_offset_within_tile >= 5)
    goto fall_check_row_below;
  check_for_gold ();
  goto draw_player_sprite;
      
fall_check_row_below:
  zp.y_offset_within_tile = 0;
  tile = ldu2[zp.current_row][zp.current_col];
  if (tile == TILE_BRICK)
    tile = TILE_SPACE;
  ldu1[zp.current_row][zp.current_col] = tile;
  zp.current_row++;
  ldu1[zp.current_row][zp.current_col] = TILE_PLAYER;
  goto draw_player_sprite;

check_falling_sound:
  if (zp.not_falling == 0)
    play_sound (0x64, 8);
    
//check_controls:
  zp.falling_snd_freq = 0x20;
  zp.not_falling = 0x20;
  read_controls ();
  
//check_up_key:  
  if (zp.key_1 == 'I')
  {
    if (!move_up ())
      goto check_left_key;
    goto draw_player_sprite;
  }
  
//check_down_key:
  if (zp.key_1 == 'K')
  {
    if (!move_down ())
      goto check_left_key;
    goto draw_player_sprite;
  }
    
//check_dig_left_key:
  if (zp.key_1 == 'U')
  {
    if (!dig_left ())
      goto check_left_key;      
    goto draw_player_sprite;
  }
    
//check_dig_right_key:
  if (zp.key_1 == 'O')
  {
    if (!dig_right ())
      goto check_left_key;
    goto draw_player_sprite;
  }
    
check_left_key:
  if (zp.key_2 == 'J')
    if (move_left ())
      goto draw_player_sprite;
    
//check_right_key:
  if (zp.key_2 == 'L')
    if (move_right ())
      goto draw_player_sprite;
      
//no_keys:
  return;

digging_left:
  digging_left ();
  return;
      
digging_right:
  digging_right ();
  return;
  
draw_player_sprite:
  draw_player_sprite ();
}

void draw_player_sprite (void)
{
  uint8_t chr, x_div_2, y;
  
  calc_char_and_addr (&chr, &x_div_2, &y);
  display_transparent_char (0, chr, x_div_2, y);
  // collision-detect stuff
}

bool move_left (void)
{
  uint8_t tile;
  uint8_t chr, x_div_2, y;
    
  if (zp.x_offset_within_tile >= 3)
    goto can_move_left;
  if (zp.current_col == 0)
    return (false);
  tile = ldu1[zp.current_row][zp.current_col-1];
  if (tile == TILE_SOLID || tile == TILE_BRICK || tile == TILE_FALLTHRU)
    return (false);
    
can_move_left:
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  zp.dir = (uint8_t)-1;
  adjust_y_offset_within_tile ();
  if (--zp.x_offset_within_tile < 0)
  {
    tile = ldu2[zp.current_row][zp.current_col];
    if (tile == TILE_BRICK)
      tile = TILE_SPACE;
    ldu1[zp.current_row][zp.current_col] = tile;
    zp.current_col--;
    ldu1[zp.current_row][zp.current_col] = TILE_PLAYER;
    zp.x_offset_within_tile = 4;
  }
  else
    check_for_gold ();
  tile = ldu2[zp.current_row][zp.current_col];
  if (tile != TILE_ROPE)
    update_sprite_index (0, 2);
  else
    update_sprite_index (3, 5);
        
  return (true);
}

bool move_right (void)
{
  uint8_t tile;
  uint8_t chr, x_div_2, y;
    
  if (zp.x_offset_within_tile < 2)
    goto can_move_right;
  if (zp.current_col == 27)
    return (false);
  tile = ldu1[zp.current_row][zp.current_col+1];
  if (tile == TILE_SOLID || tile == TILE_BRICK || tile == TILE_FALLTHRU)
    return (false);
    
can_move_right:
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  zp.dir = 1;
  adjust_y_offset_within_tile ();
  if (++zp.x_offset_within_tile >= 5)
  {
    tile = ldu2[zp.current_row][zp.current_col];
    if (tile == TILE_BRICK)
      tile = TILE_SPACE;
    ldu1[zp.current_row][zp.current_col] = tile;
    zp.current_col++;
    ldu1[zp.current_row][zp.current_col] = TILE_PLAYER;
    zp.x_offset_within_tile = 0;
  }
  else
    check_for_gold ();
  tile = ldu2[zp.current_row][zp.current_col];
  if (tile != TILE_ROPE)
    update_sprite_index (8, 10);
  else
    update_sprite_index (11, 13);
        
  return (true);
}

bool move_up (void)
{
  uint8_t chr, x_div_2, y;
  uint8_t tile;
  
  if (ldu2[zp.current_row][zp.current_col] == TILE_LADDER)
    goto check_move_up;
  if (zp.y_offset_within_tile < 3)
    goto cant_move_up;
  if (ldu2[zp.current_row+1][zp.current_col] == TILE_LADDER)
    goto can_move_up;

cant_move_up:
  return (false);
  
check_move_up:
  if (zp.y_offset_within_tile >= 3)
    goto can_move_up;
  if (zp.current_row == 0)
    goto cant_move_up;
  tile = ldu1[zp.current_row-1][zp.current_col];
  if (tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_FALLTHRU)
    goto cant_move_up;
  
can_move_up:
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  adjust_x_offset_in_tile ();
  if (--zp.y_offset_within_tile < 0)
  {
    tile = ldu2[zp.current_row][zp.current_col];
    if (tile == TILE_BRICK)
      tile = TILE_SPACE;
    ldu1[zp.current_row][zp.current_col] = tile;
    zp.current_row--;
    ldu1[zp.current_row][zp.current_col] = TILE_PLAYER;
    zp.y_offset_within_tile = 4;
  }
  else
    check_for_gold ();
  update_sprite_index (16, 17);        
  
  return (true);
}

bool move_down (void)
{
  uint8_t chr, x_div_2, y;
  uint8_t tile;

  if (zp.y_offset_within_tile < 2)
    goto can_move_down;
  if (zp.current_row == 15)
    goto cant_move_down;
  tile = ldu1[zp.current_row+1][zp.current_col];
  if (tile != TILE_SOLID && tile != TILE_BRICK)
    goto can_move_down;

cant_move_down:
  return (false);

can_move_down:
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  adjust_x_offset_in_tile ();
  if (++zp.y_offset_within_tile >= 5)
  {
    tile = ldu2[zp.current_row][zp.current_col];
    if (tile == TILE_BRICK)
      tile = TILE_SPACE;
    ldu1[zp.current_row][zp.current_col] = tile;
    zp.current_row++;
    ldu1[zp.current_row][zp.current_col] = TILE_PLAYER;
    zp.y_offset_within_tile = 0;
  }
  else
    check_for_gold ();
  update_sprite_index (16, 17);        
            
  return (true);
}

bool dig_left (void)
{
  zp.dig_dir = -1;
  zp.key_1 = (uint8_t)-1;
  zp.key_2 = (uint8_t)-1;
  zp.dig_sprite = 0;

  return (digging_left ());
}

static const uint8_t dig_spray_to_char_tbl[] =
{
  // dig spray
  0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1D, 0x1E, 0x1E, 
  0, 0, 0, 0, 
  0x26, 0x26, 0x27, 0x27, 0x1D, 0x1D, 0x1E, 0x1E, 
  0, 0, 0, 0
};

static const uint8_t dig_brick_to_char_tbl[] =
{
  // dig brick
  0x1F, 0x1F, 0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23,
	0x24, 0x24
};

bool digging_left (void)
{
  uint8_t chr, x_div_2, y;
  
  if (zp.current_row == 15)
    goto cant_dig_left;
  if (zp.current_col == 0)
    goto cant_dig_left;
  if (ldu1[zp.current_row+1][zp.current_col-1] != TILE_BRICK)
    goto cant_dig_left;
  if (ldu1[zp.current_row][zp.current_col-1] != TILE_SPACE)
    goto abort_dig_left;
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  adjust_x_offset_in_tile ();
  adjust_y_offset_within_tile ();
  // stuff for sound
  //queue_sound ();  
  if (zp.dig_sprite >= 6)
    zp.sprite_index = 0;
  else
    zp.sprite_index = 6;
  draw_player_sprite ();
  if (zp.dig_sprite == 12)
    return (add_hole_entry (zp.current_col-1));
  if (zp.dig_sprite != 0)
  {
    // wipe the spray
    chr = dig_spray_to_char_tbl[zp.dig_sprite-1];
    calc_colx5_scanline (zp.current_col-1, zp.current_row, &x_div_2, &y);
    wipe_char (-1, chr, x_div_2, y);
  }
  // render new spray
  chr = dig_spray_to_char_tbl[zp.dig_sprite];
  zp.col = zp.current_col-1;
  zp.row = zp.current_row;
  calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
  display_transparent_char (-1, chr, x_div_2, y);
  // render new partially-dug brick
  chr = dig_brick_to_char_tbl[zp.dig_sprite];
  zp.row++;
  display_char_pg (1, chr);  
  zp.dig_sprite++;
  return (true);
  
abort_dig_left:
  // restore the brick
  zp.row = zp.current_row+1;
  zp.col = zp.current_col-1;
  display_char_pg (1, TILE_BRICK);
  if (zp.dig_sprite != 0)
  {
    // wipe the spray
  	chr = dig_spray_to_char_tbl[zp.dig_sprite-1];
  	calc_colx5_scanline (zp.current_col-1, zp.current_row, &x_div_2, &y);
    wipe_char (-1, chr, x_div_2, y);    
  }

cant_dig_left:
//finish_dig_left:
  zp.dig_dir = 0;
  return (false);
}

bool dig_right (void)
{
  zp.dig_dir = 1;
  zp.key_1 = 1;
  zp.key_2 = 1;
  zp.dig_sprite = 12;

  return (digging_right ());
}

bool digging_right (void)
{
  uint8_t chr, x_div_2, y;
  
  if (zp.current_row == 15)
    goto cant_dig_right;
  if (zp.current_col == 27)
    goto cant_dig_right;
  if (ldu1[zp.current_row+1][zp.current_col+1] != TILE_BRICK)
    goto cant_dig_right;
  if (ldu1[zp.current_row][zp.current_col+1] != TILE_SPACE)
    goto abort_dig_right;
  calc_char_and_addr (&chr, &x_div_2, &y);
  wipe_char (0, chr, x_div_2, y);
  adjust_x_offset_in_tile ();
  adjust_y_offset_within_tile ();
  // stuff for sound
  //queue_sound ();  
  if (zp.dig_sprite >= 18)
    zp.sprite_index = 8;
  else
    zp.sprite_index = 14;
  draw_player_sprite ();
  if (zp.dig_sprite == 24)
    return (add_hole_entry (zp.current_col+1));
  if (zp.dig_sprite != 12)
  {
    // wipe the spray
    chr = dig_spray_to_char_tbl[zp.dig_sprite-1];
    calc_colx5_scanline (zp.current_col+1, zp.current_row, &x_div_2, &y);
    wipe_char (-1, chr, x_div_2, y);
  }
  // render new spray
  chr = dig_spray_to_char_tbl[zp.dig_sprite];
  zp.col = zp.current_col+1;
  zp.row = zp.current_row;
  calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
  display_transparent_char (-1, chr, x_div_2, y);
  // render new partially-dug brick
  zp.row++;
  chr = dig_brick_to_char_tbl[zp.dig_sprite-12];
  display_char_pg (1, chr);  
  zp.dig_sprite++;
  return (true);
  
abort_dig_right:
  zp.row = zp.current_row+1;
  zp.col = zp.current_col+1;
  display_char_pg (1, TILE_BRICK);
  if (zp.dig_sprite != 12)
  {
    // wipe the spray
  	chr = dig_spray_to_char_tbl[zp.dig_sprite-1];
  	calc_colx5_scanline (zp.current_col+1, zp.current_row, &x_div_2, &y);
    wipe_char (-1, chr, x_div_2, y);    
  }

cant_dig_right:
//finish_dig_right:
  zp.dig_dir = 0;
  return (false);
}

void read_controls (void)
{
	static const uint8_t demo_inp_remap_tbl[] =
	{
		// I, J, K, L, O, U, <SPACE>
		//0xC9, 0xCA, 0xCB, 0xCC, 0xCF, 0xD5, 0xA0
		'I', 'J', 'K', 'L', 'O', 'U', ' '
	};

	if (zp.attract_mode == 1)
	{
		if (osd_keypressed ())
		{
			// exit_demo
			zp.level_active >>= 1;
			zp.no_lives = 1;
			return;
		}
		
		if (zp.demo_inp_cnt == 0)
		{
			zp.demo_inp_key_1_2 = *(zp.demo_inp_ptr++);
			zp.demo_inp_cnt = *(zp.demo_inp_ptr++);
		}
		zp.key_1 = demo_inp_remap_tbl[zp.demo_inp_key_1_2 & 0x0f];
		zp.key_2 = demo_inp_remap_tbl[zp.demo_inp_key_1_2 >> 4];
		zp.demo_inp_cnt--;		

		return;			
	}
	
  zp.key_1 = 0;
  
  if (osd_key (LR_KEY_I))
    zp.key_1 = 'I';
  if (osd_key (LR_KEY_J))
    zp.key_1 = 'J';
  if (osd_key (LR_KEY_K))
    zp.key_1 = 'K';
  if (osd_key (LR_KEY_L))
    zp.key_1 = 'L';
  if (osd_key (LR_KEY_U) || osd_key (LR_KEY_Z))
    zp.key_1 = 'U';
  if (osd_key (LR_KEY_O) || osd_key (LR_KEY_X))
    zp.key_1 = 'O';
    
  zp.key_2 = zp.key_1;
}

void calc_char_and_addr (uint8_t *chr, uint8_t *x_div_2, uint8_t *y)
{
  static const uint8_t sprite_to_char_tbl[] =
  {
    0xB, 0xC, 0xD, 0x18, 0x19, 0x1A, 0xF, 0x13, 9, 0x10, 0x11, 0x15, 0x16,
		0x17, 0x25, 0x14, 0xE, 0x12
	};
	
	calc_x_div_2 (zp.current_col, zp.x_offset_within_tile, x_div_2);
  calc_scanline (zp.current_row, zp.y_offset_within_tile, y);
  *chr = sprite_to_char_tbl[(int)zp.sprite_index];
}

void check_for_gold (void)
{
  uint8_t x_div_2, y;
  
  if (zp.x_offset_within_tile != 2 ||
      zp.y_offset_within_tile != 2)
    return;
  if (ldu2[zp.current_row][zp.current_col] != TILE_GOLD)
    return;
  zp.enable_collision_detect = 0;
  zp.no_gold--;
  zp.row = zp.current_row;
  zp.col = zp.current_col;
  ldu2[zp.current_row][zp.current_col] = TILE_SPACE;
  display_char_pg (2, TILE_SPACE);
  calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
  wipe_char (-1, TILE_GOLD, x_div_2, y);
  update_and_display_score (SCORE_GOLD);
  //queue_sound ();
}

void update_sprite_index (uint8_t first, uint8_t last)
{
	zp.sprite_index++;
	if (zp.sprite_index < first || zp.sprite_index > last)
		zp.sprite_index = first;
}

void adjust_x_offset_in_tile (void)
{
  if (zp.x_offset_within_tile < 2)
    zp.x_offset_within_tile++;
  else if (zp.x_offset_within_tile != 2)
    zp.x_offset_within_tile--;
    
  check_for_gold ();  
}

void adjust_y_offset_within_tile (void)
{
  if (zp.y_offset_within_tile < 2)
    zp.y_offset_within_tile++;
  else if (zp.y_offset_within_tile != 2)
    zp.y_offset_within_tile--;
    
  check_for_gold ();  
}

bool add_hole_entry (uint8_t col)
{
  unsigned n;
  
  zp.dig_dir = 0;
  zp.col = col;
  zp.row = zp.current_row + 1;
  ldu1[zp.row][zp.col] = TILE_SPACE;
  display_char_pg (1, TILE_SPACE);
  display_char_pg (2, TILE_SPACE);
  zp.row--;
  display_char_pg (1, TILE_SPACE);
  zp.row++;
  
  for (n=0; n<MAX_HOLES; n++)
  {
    if (hole_cnt[n] != 0)
      continue;
    hole_row[n] = zp.row;
    hole_col[n] = zp.col;
    hole_cnt[n] = 180;
    return (true);
  }
  return (false);
}

void handle_guards (void)
{
  if (zp.no_guards == 0)
    return;
  if (++zp.byte_64 >= 3)
    zp.byte_64 = 0;
  zp.byte_63 = zp.byte_60[zp.byte_64];
  do
  {
    uint8_t byte = zp.byte_63;
    zp.byte_63 >>= 1;
    if ((byte & 1) == 1)
    {
      update_guards ();
      if (zp.level_active == 0)
        return;
    }
  } while (zp.byte_63);  
}

void update_guards (void)
{
  uint8_t chr, x_div_2, y;
  uint8_t tile;
	uint8_t	guard_movement;

  if (++zp.curr_guard > zp.no_guards)
    zp.curr_guard = 1;
  copy_guard_to_curr ();
  if (zp.curr_guard_state <= 0)
    goto check_guard_falling;
  if (--zp.curr_guard_state < 13)
  	goto check_wriggle;

//save_guard_and_ret:
  if (guard_cnt[zp.curr_guard] != 0)
  {
    copy_curr_to_guard ();
    return;
  }
  goto render_guard_and_ret;
    
check_guard_falling:
  tile = ldu2[zp.curr_guard_row][zp.curr_guard_col];
  if (tile == TILE_LADDER)
    goto calc_guard_movement;
  if (tile == TILE_ROPE)
    if (zp.curr_guard_y_offset == 2)
      goto calc_guard_movement;
  if (zp.curr_guard_y_offset < 2)
    goto handle_guard_falling;
  if (zp.curr_guard_row == 15)
    goto calc_guard_movement;
  tile = ldu1[zp.curr_guard_row+1][zp.curr_guard_col];
  if (tile == TILE_SPACE || tile == TILE_PLAYER)
    goto handle_guard_falling;
  if (tile == TILE_GUARD)
    goto calc_guard_movement;
  tile = ldu2[zp.curr_guard_row+1][zp.curr_guard_col];
  if (tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_LADDER)
    goto calc_guard_movement;
    
handle_guard_falling:
  calc_guard_xychar (&chr, &x_div_2, &y);
  wipe_char (zp.curr_guard, chr, x_div_2, y);
  adjust_guard_x_offset ();
  if (zp.curr_guard_dir < 0)
  	zp.curr_guard_sprite = 6;
 	else
  	zp.curr_guard_sprite = 13;
 	if (++zp.curr_guard_y_offset >= 5)
 		goto guard_fall_into_next_row;
 	if (zp.curr_guard_y_offset != 2)
 		goto render_guard_and_ret;
 	check_guard_pickup_gold ();
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col] != TILE_BRICK)
 		goto render_guard_and_ret;
	if (zp.curr_guard_state < 0)
		zp.no_gold--;
	zp.curr_guard_state = zp.guard_trap_cnt_init;
	update_and_display_score (SCORE_TRAP);
	//queue_sound();		
		
render_guard_and_ret:
	calc_guard_xychar (&chr, &x_div_2, &y);
	display_transparent_char (zp.curr_guard, chr, x_div_2, y);
	copy_curr_to_guard ();
	return;

guard_fall_into_next_row:
	zp.curr_guard_y_offset = 0;
	tile = ldu2[zp.curr_guard_row][zp.curr_guard_col];
	if (tile == TILE_BRICK)
		tile = TILE_SPACE;
	ldu1[zp.curr_guard_row][zp.curr_guard_col] = tile;
	zp.curr_guard_row++;
	if (ldu1[zp.curr_guard_row][zp.curr_guard_col] == TILE_PLAYER)
		KILL_PLAYER;
	// guard carrying gold?
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col] == TILE_BRICK &&
		zp.curr_guard_state < 0)
	{
		// handle guard's gold
		zp.row = zp.curr_guard_row-1;
		zp.col = zp.curr_guard_col;
		if (ldu2[zp.row][zp.col] != TILE_SPACE)
			zp.no_gold--;
		else
		{
		//guard_drop_gold:
			ldu1[zp.row][zp.col] = TILE_GOLD;
			ldu2[zp.row][zp.col] = TILE_GOLD;
			display_char_pg (2, TILE_GOLD);
			calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
			display_transparent_char (-1, TILE_GOLD, x_div_2, y);
		}
	
	//loc_6e46:
		zp.curr_guard_state = 0;
	}

//loc_6e58:
	// update dynamic playfield and display guard
	ldu1[zp.curr_guard_row][zp.curr_guard_col] = TILE_GUARD;
	calc_guard_xychar (&chr, &x_div_2, &y);
	display_transparent_char (zp.curr_guard, chr, x_div_2, y);
	copy_curr_to_guard ();
	return;
	
check_wriggle:
	if (zp.curr_guard_state >= 7)
	{
		static const uint8_t wriggle_tbl[] =
		{
			2, 1, 2, 3, 2, 1
		};

		calc_guard_xychar (&chr, &x_div_2, &y);
		wipe_char (zp.curr_guard, chr, x_div_2, y);
		zp.curr_guard_x_offset = wriggle_tbl[zp.curr_guard_state-7];
		calc_guard_xychar (&chr, &x_div_2, &y);
		display_transparent_char (zp.curr_guard, chr, x_div_2, y);
		copy_curr_to_guard ();
		return;
	}

#define GUARD_NO_MOVE			0
#define GUARD_MOVE_LEFT		1
#define GUARD_MOVE_RIGHT	2
#define GUARD_MOVE_UP			3
#define GUARD_MOVE_DOWN		4
			
calc_guard_movement:
	guard_movement = guard_ai (zp.curr_guard_row, zp.curr_guard_col);
	switch (guard_movement)
	{
		case GUARD_MOVE_LEFT :
			guard_move_left ();
			break;
		case GUARD_MOVE_RIGHT :
			guard_move_right ();
			break;
		case GUARD_MOVE_UP :
			guard_move_up ();
			break;
		case GUARD_MOVE_DOWN:
			guard_move_down ();
			break;
		case GUARD_NO_MOVE :
		default :
			copy_guard_to_curr ();
			break;
	}
}

void guard_cant_climb (void)
{
	if (zp.curr_guard_state > 0)
		zp.curr_guard_state++;
	copy_curr_to_guard ();
}

void guard_move_up (void)
{
	uint8_t	chr, x_div_2, y;
	uint8_t	tile;
	
	if (zp.curr_guard_y_offset >= 3)
		goto guard_can_move_up;
	if (zp.curr_guard_row == 0)
	{
		guard_cant_climb ();
		return;
	}
	tile = ldu1[zp.curr_guard_row-1][zp.curr_guard_col];
	if (tile == TILE_BRICK || tile == TILE_SOLID || 
			tile == TILE_FALLTHRU || tile == TILE_GUARD)
	{
		guard_cant_climb ();
		return;
	}

guard_can_move_up:
	calc_guard_xychar (&chr, &x_div_2, &y);
	wipe_char (zp.curr_guard, chr, x_div_2, y);
	adjust_guard_x_offset ();
	if (--zp.curr_guard_y_offset >= 0)
		goto guard_climber_check_for_gold;
	check_guard_drop_gold ();
	tile = ldu2[zp.curr_guard_row][zp.curr_guard_col];
	if (tile == TILE_BRICK)
		tile = TILE_SPACE;
	ldu1[zp.curr_guard_row][zp.curr_guard_col] = tile;
	zp.curr_guard_row--;
	if (ldu1[zp.curr_guard_row][zp.curr_guard_col] == TILE_PLAYER)
		KILL_PLAYER;
	ldu1[zp.curr_guard_row][zp.curr_guard_col] = TILE_GUARD;
	zp.curr_guard_y_offset = 4;
	goto update_guard_climber_sprite;
	
guard_climber_check_for_gold:
	check_guard_pickup_gold ();
	
update_guard_climber_sprite:
	update_guard_climber_sprite ();
}

void update_guard_climber_sprite (void)
{
	uint8_t	chr, x_div_2, y;

	update_guard_sprite_index (14, 15);
	calc_guard_xychar (&chr, &x_div_2, &y);
	display_transparent_char (zp.curr_guard, chr, x_div_2, y);
	copy_curr_to_guard ();
}

void guard_move_down (void)
{
	uint8_t	chr, x_div_2, y;
	uint8_t	tile;

	if (zp.curr_guard_y_offset < 2)
		goto guard_can_move_down;
	if (zp.curr_guard_row == 15)
	{
		copy_curr_to_guard ();
		return;
	}
	tile = ldu1[zp.curr_guard_row+1][zp.curr_guard_col];
	if (tile == TILE_SOLID || tile == TILE_GUARD || tile == TILE_BRICK)
	{
		copy_curr_to_guard ();
		return;
	}
	
guard_can_move_down:
	calc_guard_xychar (&chr, &x_div_2, &y);
	wipe_char (zp.curr_guard, chr, x_div_2, y);
	adjust_guard_x_offset ();	
	if (++zp.curr_guard_y_offset < 5)
	{
		// jmp guard_climber_check_for_gold ();
		check_guard_pickup_gold ();
		update_guard_climber_sprite ();
		return;
	}
	check_guard_drop_gold ();
	tile = ldu2[zp.curr_guard_row][zp.curr_guard_col];
	if (tile == TILE_BRICK)
		tile = TILE_SPACE;
	ldu1[zp.curr_guard_row][zp.curr_guard_col] = tile;
	zp.curr_guard_row++;
	if (ldu1[zp.curr_guard_row][zp.curr_guard_col] == TILE_PLAYER)
		KILL_PLAYER;
	ldu1[zp.curr_guard_row][zp.curr_guard_col] = TILE_GUARD;
	zp.curr_guard_y_offset = 0;
	update_guard_climber_sprite ();
}

void guard_move_left (void)
{
	uint8_t	chr, x_div_2, y;
	uint8_t	tile;
	
	if (zp.curr_guard_x_offset >= 3)
		goto guard_can_move_left;
	if (zp.curr_guard_col == 0)
		goto guard_cant_move_left;
	tile = ldu1[zp.curr_guard_row][zp.curr_guard_col-1];
	if (tile == TILE_GUARD || tile == TILE_SOLID || tile == TILE_BRICK)
		goto guard_cant_move_left;
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col-1] != TILE_FALLTHRU)
		goto guard_can_move_left;
		
guard_cant_move_left:
	copy_curr_to_guard ();
	return;
	
guard_can_move_left:
	calc_guard_xychar (&chr, &x_div_2, &y);
	wipe_char (zp.curr_guard, chr, x_div_2, y);
	adjust_guard_y_offset ();
	zp.curr_guard_dir = (uint8_t)-1;
	if (--zp.curr_guard_x_offset < 0)
	{
		check_guard_drop_gold ();
		tile = ldu2[zp.curr_guard_row][zp.curr_guard_col];
		if (tile == TILE_BRICK)
			tile = TILE_SPACE;
		ldu1[zp.curr_guard_row][zp.curr_guard_col] = tile;
		zp.curr_guard_col--;
		if (ldu1[zp.curr_guard_row][zp.curr_guard_col] == TILE_PLAYER)
			KILL_PLAYER;
		ldu1[zp.curr_guard_row][zp.curr_guard_col] = TILE_GUARD;
		zp.curr_guard_x_offset = 4;
	}
	else
		check_guard_pickup_gold ();
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col] != TILE_ROPE)
		update_guard_sprite_index (0, 2);
	else
		update_guard_sprite_index (3, 5);
	calc_guard_xychar (&chr, &x_div_2, &y);
	display_transparent_char (zp.curr_guard, chr, x_div_2, y);
	copy_curr_to_guard ();
}

void guard_move_right (void)
{
	uint8_t	chr, x_div_2, y;
	uint8_t	tile;
	
	if (zp.curr_guard_x_offset < 2)
		goto guard_can_move_right;
	if (zp.curr_guard_col == 27)
		goto guard_cant_move_right;
	tile = ldu1[zp.curr_guard_row][zp.curr_guard_col+1];
	if (tile == TILE_GUARD || tile == TILE_SOLID || tile == TILE_BRICK)
		goto guard_cant_move_right;
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col-1] != TILE_FALLTHRU)
		goto guard_can_move_right;
		
guard_cant_move_right:
	copy_curr_to_guard ();
	return;
	
guard_can_move_right:
	calc_guard_xychar (&chr, &x_div_2, &y);
	wipe_char (zp.curr_guard, chr, x_div_2, y);
	adjust_guard_y_offset ();
	zp.curr_guard_dir = 1;
	if (++zp.curr_guard_x_offset >= 5)
	{
		check_guard_drop_gold ();
		tile = ldu2[zp.curr_guard_row][zp.curr_guard_col];
		if (tile == TILE_BRICK)
			tile = TILE_SPACE;
		ldu1[zp.curr_guard_row][zp.curr_guard_col] = tile;
		zp.curr_guard_col++;
		if (ldu1[zp.curr_guard_row][zp.curr_guard_col] == TILE_PLAYER)
			KILL_PLAYER;
		ldu1[zp.curr_guard_row][zp.curr_guard_col] = TILE_GUARD;
		zp.curr_guard_x_offset = 0;
	}
	else
		check_guard_pickup_gold ();
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col] != TILE_ROPE)
		update_guard_sprite_index (7, 9);
	else
		update_guard_sprite_index (10, 12);
	calc_guard_xychar (&chr, &x_div_2, &y);
	display_transparent_char (zp.curr_guard, chr, x_div_2, y);
	copy_curr_to_guard ();
}

uint8_t guard_ai (uint8_t row, uint8_t col)
{
	#ifdef DEBUG_GUARD_COPY
		if (zp.curr_guard == 2)
		{
			if (osd_key (OSD_KEY_Z))
				OSD_PRINTF ("state=%d, x=%d.%d, y=%d.%d (d=%d,s=%d) +1(d=%d,s=%d)\n",
									zp.curr_guard_state,
									zp.curr_guard_col, zp.curr_guard_x_offset,
									zp.curr_guard_row, zp.curr_guard_y_offset,
									ldu1[zp.curr_guard_row][zp.curr_guard_col],
									ldu2[zp.curr_guard_row][zp.curr_guard_col],
									ldu1[zp.curr_guard_row+1][zp.curr_guard_col],
									ldu2[zp.curr_guard_row+1][zp.curr_guard_col]);
			switch (zp.key_1)
			{
				case 'I' :
					return (GUARD_MOVE_UP);
				case 'J' :
					return (GUARD_MOVE_LEFT);
				case 'K' :
					return (GUARD_MOVE_DOWN);
				case 'L' :
					return (GUARD_MOVE_RIGHT);
				default :
					break;
			}
		}
		return (GUARD_NO_MOVE);
	#else
	
  uint8_t tile;
  
	zp.guard_ai_col = col;
	zp.guard_ai_row = row;
	// if stuck in a hole, move UP
	if (ldu2[zp.guard_ai_row][zp.guard_ai_col] == TILE_BRICK)
	  if (zp.curr_guard_state > 0)
	    return (GUARD_MOVE_UP);

  if (zp.guard_ai_row != zp.current_row)
    goto different_row;
    
//same_row:    
  zp.target_col = zp.guard_ai_col;
  if (zp.target_col >= zp.current_col)
    goto guard_right_of_player;
    
//guard_left_of_player:
  while (zp.target_col != zp.current_col)
  {
    zp.target_col++;
    tile = ldu2[zp.guard_ai_row][zp.target_col];
    if (tile == TILE_LADDER || tile == TILE_ROPE ||
        zp.guard_ai_row == 15)
      continue;
      
    tile = ldu2[zp.guard_ai_row+1][zp.target_col];
    if (tile == TILE_SPACE || tile == TILE_FALLTHRU)
      goto different_row;
  }
  return (GUARD_MOVE_RIGHT);

guard_right_of_player:
  while (zp.target_col != zp.current_col)
  {
    zp.target_col--;
    tile = ldu2[zp.guard_ai_row][zp.target_col];
    if (tile == TILE_LADDER || tile == TILE_ROPE ||
        zp.guard_ai_row == 15)
      continue;
      
    tile = ldu2[zp.guard_ai_row+1][zp.target_col];
    if (tile == TILE_SPACE || tile == TILE_FALLTHRU)
      goto different_row;
  }
  return (GUARD_MOVE_LEFT);
  
different_row:
	zp.guard_ai_dir = GUARD_NO_MOVE;
	zp.guard_ai_best_delta = 0xff;
	find_farthest_left_right (zp.guard_ai_row, zp.guard_ai_col);
	guard_ai_up_down ();
	guard_ai_left ();
	guard_ai_right ();

	return (zp.guard_ai_dir);	
		
	#endif
}

void guard_ai_left (void)
{
	uint8_t	tile;
	uint8_t	farthest, delta;
		
	while (zp.farthest_left != zp.guard_ai_col)
	{
		if (zp.guard_ai_row != 15)
		{
			tile = ldu2[zp.guard_ai_row+1][zp.farthest_left];
			if (!(tile == TILE_BRICK || tile == TILE_SOLID))
			{
				farthest = find_farthest_down (zp.guard_ai_row, zp.farthest_left);
				delta = calc_row_col_delta (zp.farthest_left, farthest);
				if (delta < zp.guard_ai_best_delta)
				{
					zp.guard_ai_best_delta = delta;
					zp.guard_ai_dir = GUARD_MOVE_LEFT;
				}
			}
		}
		if (zp.guard_ai_row != 0)
		{
			if (ldu2[zp.guard_ai_row][zp.farthest_left] == TILE_LADDER)
			{
				farthest = find_farthest_up (zp.guard_ai_row, zp.farthest_left);
				delta = calc_row_col_delta (zp.farthest_left, farthest);
				if (delta < zp.guard_ai_best_delta)
				{
					zp.guard_ai_best_delta = delta;
					zp.guard_ai_dir = GUARD_MOVE_LEFT;
				}
			}
		}
		zp.farthest_left++;
	}	
}

void guard_ai_right (void)
{
	uint8_t	tile;
	uint8_t	farthest, delta;
		
	while (zp.farthest_right != zp.guard_ai_col)
	{
		if (zp.guard_ai_row != 15)
		{
			tile = ldu2[zp.guard_ai_row+1][zp.farthest_right];
			if (!(tile == TILE_BRICK || tile == TILE_SOLID))
			{
				farthest = find_farthest_down (zp.guard_ai_row, zp.farthest_right);
				delta = calc_row_col_delta (zp.farthest_right, farthest);
				if (delta < zp.guard_ai_best_delta)
				{
					zp.guard_ai_best_delta = delta;
					zp.guard_ai_dir = GUARD_MOVE_RIGHT;
				}
			}
		}
		if (zp.guard_ai_row != 0)
		{
			if (ldu2[zp.guard_ai_row][zp.farthest_right] == TILE_LADDER)
			{
				farthest = find_farthest_up (zp.guard_ai_row, zp.farthest_right);
				delta = calc_row_col_delta (zp.farthest_right, farthest);
				if (delta < zp.guard_ai_best_delta)
				{
					zp.guard_ai_best_delta = delta;
					zp.guard_ai_dir = GUARD_MOVE_RIGHT;
				}
			}
		}
		zp.farthest_right--;
	}	
}

void guard_ai_up_down (void)
{
	uint8_t	tile;
	uint8_t	farthest, delta;
	
	if (zp.guard_ai_row == 15)
		goto guard_ai_cant_go_down;
	tile = ldu2[zp.guard_ai_row+1][zp.guard_ai_col];
	if (tile == TILE_BRICK || tile == TILE_SOLID)
		goto guard_ai_cant_go_down;
	farthest = find_farthest_down (zp.guard_ai_row, zp.guard_ai_col);
	delta = calc_row_col_delta (zp.guard_ai_col, farthest);
	if (delta < zp.guard_ai_best_delta)
	{
		zp.guard_ai_best_delta = delta;
		zp.guard_ai_dir = GUARD_MOVE_DOWN;
	}
	
guard_ai_cant_go_down:
	if (zp.guard_ai_row == 0)
		return;
	if (ldu2[zp.guard_ai_row][zp.guard_ai_col] != TILE_LADDER)
		return;
	farthest = find_farthest_up (zp.guard_ai_row, zp.guard_ai_col);
	delta = calc_row_col_delta (zp.guard_ai_col, farthest);
	if (delta < zp.guard_ai_best_delta)
	{
		zp.guard_ai_best_delta = delta;
		zp.guard_ai_dir = GUARD_MOVE_UP;
	}
}

uint8_t calc_row_col_delta (uint8_t col, uint8_t farthest)
{
	if (farthest == zp.current_row)
	{
		if (col >= zp.curr_guard_col)
			return (col - zp.curr_guard_col);
		else
			return (zp.curr_guard_col - col);
	}
	else
	if (farthest > zp.current_row)
		return (farthest - zp.current_row + 200);
	else
		return (zp.current_row - farthest + 100);
}

uint8_t find_farthest_up (uint8_t row, uint8_t col)
{
	uint8_t	tile;

	do
	{	
		if (ldu2[row][col] != TILE_LADDER)
			return (row);
		row--;
		if (col == 0)
			goto up_try_right;
		tile = ldu2[row+1][col-1];
		if (!(tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_LADDER))
			if (ldu2[row][col-1] != TILE_ROPE)
				goto up_try_right;
		if ((zp.farthest_updown_plyr_row = row) <= zp.current_row)
			return (zp.farthest_updown_plyr_row);
			
	up_try_right:
		if (col == 27)
			continue;
		tile = ldu2[row+1][col+1];
		if (!(tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_LADDER))
			if (ldu2[row][col+1] != TILE_ROPE)
				continue;
		if ((zp.farthest_updown_plyr_row = row) <= zp.current_row)
			return (zp.farthest_updown_plyr_row);
			
	} while (row > 0);	
	
	return (row);
}

uint8_t find_farthest_down (uint8_t row, uint8_t col)
{
	uint8_t	tile;
	
	do
	{
		uint8_t	bug_row;
		
		tile = ldu2[row+1][col];
		if (tile == TILE_BRICK || tile == TILE_SOLID)
			return (row);
		if (ldu2[bug_row=row][col] == TILE_SPACE)
			continue;
		if (col == 0)
			goto down_try_right;
		if (ldu2[row][col-1] != TILE_ROPE)
		{
			tile = ldu2[bug_row=row+1][col-1];
			if (!(tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_LADDER))
				goto down_try_right;
		}
		if ((zp.farthest_updown_plyr_row = row) >= zp.current_row)
			return (zp.farthest_updown_plyr_row);
				
	down_try_right:
		if (col == 27)
			continue;
		if (ldu2[bug_row][col+1] != TILE_ROPE)
		{
			tile = ldu2[row+1][col+1];
			if (!(tile == TILE_BRICK || tile == TILE_LADDER || tile == TILE_SOLID))
				continue;
		}
		if ((zp.farthest_updown_plyr_row = row) >= zp.current_row)
			return (zp.farthest_updown_plyr_row);

	} while (++row < 16);
	
	return (15);
}

void find_farthest_left_right (uint8_t row, uint8_t col)
{
	uint8_t	tile;
	
	zp.farthest_left = col;
	zp.farthest_right = col;
	zp.scanline = row;
	
//find_farthest_left:
	while (zp.farthest_left != 0)
	{
		tile = ldu1[zp.scanline][zp.farthest_left-1];
		if (tile == TILE_BRICK || tile == TILE_SOLID)
			break;
		zp.farthest_left--;
		if (tile == TILE_LADDER || tile == TILE_ROPE ||
				zp.scanline == 15)
			continue;
		tile = ldu2[zp.scanline+1][zp.farthest_left];
		if (tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_LADDER)
			continue;
		else
			break;
	}		
		
//find_farthest_right:
	while (zp.farthest_right != 27)
	{
		tile = ldu2[zp.scanline][zp.farthest_right+1];
		if (tile == TILE_BRICK || tile == TILE_SOLID)
			break;
		zp.farthest_right++;
		if (tile == TILE_LADDER || tile == TILE_ROPE ||
				zp.scanline == 15)
			continue;
		tile = ldu2[zp.scanline+1][zp.farthest_right];
		if (tile == TILE_BRICK || tile == TILE_SOLID || tile == TILE_LADDER)
			continue;
		else
			break;
	}
}

void calc_guard_xychar (uint8_t *chr, uint8_t *x_div_2, uint8_t *y)
{
	static const uint8_t guard_sprite_to_char_tbl[] =
	{
		8, 0x2B, 0x2C, 0x30, 0x31, 0x32, 0x36, 0x28, 0x29, 0x2A, 0x2D, 0x2E, 0x2F,
		0x35, 0x33, 0x34
	};

	calc_x_div_2 (zp.curr_guard_col, zp.curr_guard_x_offset, x_div_2);
	calc_scanline (zp.curr_guard_row, zp.curr_guard_y_offset, y);
	*chr = guard_sprite_to_char_tbl[zp.curr_guard_sprite];
}

void check_guard_pickup_gold (void)
{
	uint8_t	x_div_2, y;

	if (zp.curr_guard_x_offset != 2 ||
			zp.curr_guard_y_offset != 2)
		return;
	if (ldu2[zp.curr_guard_row][zp.curr_guard_col] != TILE_GOLD)
		return;
	if (zp.curr_guard_state < 0)
		return;
	zp.curr_guard_state = -1 - zp.guard_respawn_col;
	ldu2[zp.curr_guard_row][zp.curr_guard_col] = TILE_SPACE;
	zp.row = zp.curr_guard_row;
	zp.col = zp.curr_guard_col;
	display_char_pg (2, TILE_SPACE);
	calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
	wipe_char (-1, TILE_GOLD, x_div_2, y);
}

void check_guard_drop_gold (void)
{
	uint8_t	x_div_2, y;
	
	if (zp.curr_guard_state >= 0)
		return;
	if (++zp.curr_guard_state != 0)
		return;
	zp.row = zp.curr_guard_row;
	zp.col = zp.curr_guard_col;
	if (ldu2[zp.row][zp.col] == TILE_SPACE)
	{
		ldu2[zp.row][zp.col] = TILE_GOLD;
		display_char_pg (2, TILE_GOLD);
		calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
		display_transparent_char (-1, TILE_GOLD, x_div_2, y);
		return;
	}
	zp.curr_guard_state--;
}

void update_guard_sprite_index (uint8_t first, uint8_t last)
{
	zp.curr_guard_sprite++;
	if (zp.curr_guard_sprite < first || zp.curr_guard_sprite > last)
		zp.curr_guard_sprite = first;
}

void adjust_guard_x_offset (void)
{
	if (zp.curr_guard_x_offset < 2)
	{
		zp.curr_guard_x_offset++;
		check_guard_pickup_gold ();
	}
	else if (zp.curr_guard_x_offset > 2)
	{
		zp.curr_guard_x_offset--;
		check_guard_pickup_gold ();
	}
}

void adjust_guard_y_offset (void)
{
	if (zp.curr_guard_y_offset < 2)
	{
		zp.curr_guard_y_offset++;
		check_guard_pickup_gold ();
	}
	else if (zp.curr_guard_y_offset > 2)
	{
		zp.curr_guard_y_offset--;
		check_guard_pickup_gold ();
	}
}

void copy_curr_to_guard (void)
{
	guard_col[zp.curr_guard] = zp.curr_guard_col;
	guard_row[zp.curr_guard] = zp.curr_guard_row;
	guard_x_offset[zp.curr_guard] = zp.curr_guard_x_offset;
	guard_y_offset[zp.curr_guard] = zp.curr_guard_y_offset;
	guard_state[zp.curr_guard] = zp.curr_guard_state;
	guard_dir[zp.curr_guard] = zp.curr_guard_dir;
	guard_sprite[zp.curr_guard] = zp.curr_guard_sprite;
}

void copy_guard_to_curr (void)
{
	zp.curr_guard_col = guard_col[zp.curr_guard];
	zp.curr_guard_row = guard_row[zp.curr_guard];
	zp.curr_guard_x_offset = guard_x_offset[zp.curr_guard];
	zp.curr_guard_y_offset = guard_y_offset[zp.curr_guard];
	zp.curr_guard_sprite = guard_sprite[zp.curr_guard];
	zp.curr_guard_dir = guard_dir[zp.curr_guard];
	zp.curr_guard_state = guard_state[zp.curr_guard];
}

void respawn_guards_and_update_holes (void)
{
  uint8_t   chr, x_div_2, y;
  uint8_t   tile;
  int       n;
    
  check_and_handle_respawn ();

  if (++zp.guard_respawn_col == 28)
  	zp.guard_respawn_col = 0;
  	
  for (n=MAX_HOLES; n>=0; n--)
  {
    if (hole_cnt[n] == 0)
      continue;
    if (--hole_cnt[n] == 0)
      goto restore_brick;
    zp.col = hole_col[n];
    zp.row = hole_row[n];
    if (hole_cnt[n] == 20 || hole_cnt[n] == 10)
    { 
      chr = (hole_cnt[n] == 20 ? 0x37 : 0x38);
      display_char_pg (2, chr);
      calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
      //wipe_char (-1, TILE_SPACE, x_div_2, y);
      display_char_pg (1, chr);
    }
    continue;
      
  restore_brick:      
    zp.row = hole_row[n];
    zp.col = hole_col[n];
    tile = ldu1[zp.row][zp.col];
    if (tile == TILE_SPACE)
      goto redisplay_brick;
    if (tile == TILE_PLAYER)
      zp.level_active >>= 1;
    if (tile == TILE_GUARD)
    {
      unsigned  g;

    	ldu1[zp.row][zp.col] = TILE_BRICK;
    	ldu2[zp.row][zp.col] = TILE_BRICK;
    	display_char_pg (1, TILE_BRICK);
    	display_char_pg (2, TILE_BRICK);

    	//check_trapped_guards:
    	for (g=zp.no_guards; g>0; g--)
    	{
    		if (guard_col[g] != zp.col ||
    				guard_row[g] != zp.row)
    			continue;
    		if (guard_state[g] < 0)
    			zp.no_gold--;
    		guard_state[g] = 0x7f;
    		zp.curr_guard = g;
    		copy_guard_to_curr ();
    		calc_guard_xychar (&chr, &x_div_2, &y);
    		wipe_char (zp.curr_guard, chr, x_div_2, y);
    		zp.row = 1;
    		while (ldu2[zp.row][zp.guard_respawn_col] != TILE_SPACE)
    		{
    			if (++zp.guard_respawn_col == 28)
    			{
    				zp.row++;
    				zp.guard_respawn_col = 0;
    			}
    		}
    		guard_col[g] = zp.guard_respawn_col;
    		guard_row[g] = zp.row;
    		guard_cnt[g] = 20;
    		guard_y_offset[g] = 2;
    		guard_x_offset[g] = 2;
    		guard_sprite[g] = 0;
    		update_and_display_score (SCORE_KILL);
    		goto next_hole;
    	}
    }
    if (tile == TILE_GOLD)
    {
      zp.no_gold--;
      goto redisplay_brick;
    }
    
  redisplay_brick:
    ldu1[zp.row][zp.col] = TILE_BRICK;
    display_char_pg (1, TILE_BRICK);
    display_char_pg (2, TILE_BRICK);
    
  next_hole:
  	;
  }
}

void check_and_handle_respawn (void)
{
	uint8_t	  curr_guard = zp.curr_guard;
	uint8_t	  chr, x_div_2, y;
	unsigned  g;
	
	for (g=zp.no_guards; g>0; g--)
	{
		if (guard_cnt[g] == 0)
			continue;
		zp.curr_guard = g;
		copy_guard_to_curr ();
		guard_state[g] = 0x7f;
		zp.col = guard_col[g];
		zp.row = guard_row[g];
		if (--guard_cnt[g] == 0)
		{
			// finish_respawn:
			guard_cnt[g]++;
			if (ldu1[zp.row][zp.col] == TILE_SPACE)
			{
				ldu1[zp.row][zp.col] = TILE_GUARD;
				display_char_pg (2, TILE_SPACE);
				guard_state[g] = 0;
				guard_cnt[g] = 0;
				#ifndef HAS_HWSPRITES
					display_char_pg (1, TILE_GUARD);
				#else
					display_transparent_char (zp.curr_guard, TILE_GUARD, zp.col*5, zp.row*11);
				#endif
				//queue_sound ();
			}
		}
		else if (guard_cnt[g] == 19)
		{
			display_char_pg (2, 0x39);
			calc_guard_xychar (&chr, &x_div_2, &y);
			display_transparent_char (zp.curr_guard, 0x39, x_div_2, y);
		}
		else if (guard_cnt[g] == 10)
		{
			display_char_pg (2, 0x3a);
			calc_guard_xychar (&chr, &x_div_2, &y);
			display_transparent_char (zp.curr_guard, 0x3a, x_div_2, y);
		}
	}
	
	zp.curr_guard = curr_guard;
}

void cls_and_display_high_scores (void)
{
  unsigned  n;
  
	gcls (2);
	zp.display_char_page = 2;
	zp.col = 0;
	zp.row = 0;
	display_message (	"    LODE RUNNER HIGH SCORES\r\r\r"
										"    INITIALS LEVEL  SCORE\r"
										"    -------- ----- --------\r");
	for (n=1; n<=10; n++)
	{
		if (n == 10)
		{
			display_digit (1);
			display_digit (0);
		}
		else
		{
			display_character (0x80|0x20);
			display_digit (n);
		}
		if (hs_tbl[n-1].level != 0)
		{
			uint32_t score;
			uint8_t byte;

			display_message (".    ");
			display_character (0x80|hs_tbl[n-1].initial[0]);
			display_character (0x80|hs_tbl[n-1].initial[1]);
			display_character (0x80|hs_tbl[n-1].initial[2]);
			display_message ("    ");
			byte = hs_tbl[n-1].level;
			display_digit (byte/100);
			byte %= 100;
			display_digit (byte/10);
			display_digit (byte%10);
			display_message ("  ");
			score = hs_tbl[n-1].score;
			display_digit (score/10000000);
			score %= 10000000;
			display_digit (score/1000000);
			score %= 1000000;
			display_digit (score/100000);
			score %= 100000;
			display_digit (score/10000);
			score %= 10000;
			display_digit (score/1000);
			score %= 1000;
			display_digit (score/100);
			score %= 100;
			display_digit (score/10);
			display_digit (score%10);
		}
		cr ();
	}
										
	OSD_HGR2;
	zp.display_char_page = 1;
}

void cls_and_display_game_status (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);
	
	gcls (1);
	gcls (2);

	#ifdef MONO
  	osd_draw_separator (zp.display_char_page, 0xcc, 176);
  #else
  	osd_draw_separator (zp.display_char_page, 0xaa, 176);
  #endif
		
	zp.row = 16;
	zp.col = 0;
	display_message ("SCORE        MEN    LEVEL   ");
	display_no_lives ();
	display_level ();
	update_and_display_score (0);
}

void gcls (uint8_t page)
{
	OSD_PRINTF ("%s(%d)\n", __FUNCTION__, page);

  osd_gcls (page);
}

void display_no_lives (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);
	
	zp.col = 16;
	zp.row = 16;
	
	display_digit (zp.no_lives / 100);
	display_digit (zp.no_lives / 10);
	display_digit (zp.no_lives % 10);
}

void display_byte (uint8_t col, uint8_t byte)
{
	zp.col = col;
	zp.row = 16;
	display_digit (byte / 100);
	byte %= 100;
	display_digit (byte / 10);
	display_digit (byte % 10);
}

void display_level (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);
	
	display_byte (25, zp.level);
}

void update_and_display_score (uint16_t pts)
{
  uint32_t  score;
  
	//OSD_PRINTF ("%s(%d)\n", __FUNCTION__, pts);
	
	zp.score += pts;
	score = zp.score;
	zp.col = 5;
	zp.row = 16;
	display_digit (score / 1000000);
	score %= 1000000;
	display_digit (score / 100000);
	score %= 100000;
	display_digit (score / 10000);
	score %= 10000;
	display_digit (score / 1000);
	score %= 1000;
	display_digit (score / 100);
	score %= 100;
	display_digit (score / 10);
	display_digit (score % 10);
}

void display_digit (uint8_t digit)
{
	digit += 0x3b;
	display_char_pg (zp.display_char_page, digit);
	zp.col++;
}

uint8_t remap_character (uint8_t chr)
{
	uint8_t ret = chr;

	// non-alpha	
	while (chr < 0xc1 || chr > 0xdb)
	{
		ret = 0x7c;
		
		// space
		if (chr == 0xa0)
			break;
		ret = 0xdb;
		// >
		if (chr == 0xbe)
			break;
		ret++;
		// .
		if (chr == 0xae)
			break;
		ret++;
		// (
		if (chr == 0xa8)
			break;
		ret++;
		// )
		if (chr == 0xa9)
			break;
		ret++;
		// /
		if (chr == 0xaf)
			break;
		ret++;
		// -
		if (chr == 0xad)
			break;
		ret++;
		// <
		if (chr == 0xbc)
			break;
		// space
		return (0x10);			
	}

	return (ret-0x7c);	
}

void display_character (uint8_t chr)
{
	if (chr != 0x8d)		
	{
		chr = remap_character (chr);
		display_char_pg (zp.display_char_page, chr);
		zp.col++;
	}
	else
	{
		zp.row++;
		zp.col = 0;
	}	
}

void cr (void)
{
	zp.row++;
	zp.col = 0;
}

void display_char_pg (uint8_t page, uint8_t chr)
{
	uint8_t x_div_2, y;
	
	calc_colx5_scanline (0, zp.row, &x_div_2, &y);
	osd_display_char_pg (page, chr, zp.col*5, y);
}

void wipe_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	osd_wipe_char (sprite, chr, x_div_2, y);
}

void display_transparent_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	//OSD_PRINTF ("%s()\n", __FUNCTION__);

  osd_display_transparent_char (sprite, chr, x_div_2, y);
}

uint8_t check_and_update_high_score_tbl (void)
{
	unsigned	n;
	uint8_t		chr;
	
	if (zp.no_cheat == 0)
		return (0);
	
	if (zp.score == 0)
		return (0);
		
	for (n=0; n<10; n++)
	{
		if (zp.level >= hs_tbl[n].level)
			break;
		if (zp.score >= hs_tbl[n].score)
			break;
	}
	if (n == 10)
		return (0);

//add_hs_entry:
	if (n < 9)
	{
		unsigned i;
		
		for (i=9; i>n; i--)
			hs_tbl[i] = hs_tbl[i-1];
	}
	memset (hs_tbl[n].initial, ' ', 3);
	hs_tbl[n].level = zp.level;
	hs_tbl[n].score = zp.score;
	cls_and_display_high_scores ();
	zp.display_char_page = 2;
	zp.row = n + 4;
	zp.col = 7;
	zp.initial_cnt = 0;
	
	while (1)
	{
		uint8_t	key;
		
		chr = remap_character (hs_tbl[n].initial[zp.initial_cnt]);
		key = blink_char_cursor_wait_key (chr);
		if (key == LR_KEY_CR)
			break;
		if (key == LR_KEY_BS)
		{
			if (zp.initial_cnt == 0)
				beep ();
			else
			{
				zp.initial_cnt--;
				zp.col--;
			}			
			continue;
		}
		//add_initial:
		if (key == LR_KEY_RIGHT)
		{
			if (zp.initial_cnt == 2)
				beep ();
			else
			{
				zp.initial_cnt++;
				zp.col++;
			}
			continue;
		}
		if (key == LR_KEY_PERIOD ||
				key == LR_KEY_SPACE ||
				(key >= LR_KEY_A && key <= LR_KEY_Z))
		{
			//save_initial:
			hs_tbl[n].initial[zp.initial_cnt] = key;
			display_character (key);
			if (zp.initial_cnt < 2)
			{
				zp.initial_cnt++;
				zp.col++;
			}
		}
		else
			beep ();
	}
	
	//done_initials_entry:
	zp.display_char_page = 1;
		
	return (1);
}

uint8_t blink_char_cursor_wait_key (uint8_t chr)
{
	return (0);
}

void draw_end_of_screen_ladder (void)
{
  uint8_t x_div_2, y;
  int     n;
  
	OSD_PRINTF ("%s()\n", __FUNCTION__);

  // flag ladder OK  
  eos_ladder_col[0] = 0;
  for (n=zp.no_eos_ladder_tiles; n>0; n--)
  {
    if (eos_ladder_col[n] == (uint8_t)-1)
      continue;
    zp.col = eos_ladder_col[n];
    zp.row = eos_ladder_row[n];
    if (ldu2[zp.row][zp.col] != TILE_SPACE)
    {
      // flag ladder problem
      eos_ladder_col[0] = 1;
      continue;
    }    
    ldu2[zp.row][zp.col] = TILE_LADDER;
    if (ldu1[zp.row][zp.col] == TILE_SPACE)
      ldu1[zp.row][zp.col] = TILE_LADDER;
    display_char_pg (2, TILE_LADDER);
    calc_colx5_scanline (zp.col, zp.row, &x_div_2, &y);
    display_transparent_char (-1, TILE_LADDER, x_div_2, y);
    // flag tile drawn
    eos_ladder_col[n] = (uint8_t)-1;
  }
  if (eos_ladder_col[0] == 0)
	  zp.no_gold = (uint8_t)-1;
}

void beep (void)
{
}

void display_message (const char *msg)
{
	OSD_PRINTF ("%s(\"%s\")\n", __FUNCTION__, msg);
	
	while (*msg)
		display_character ((1<<7)|*(msg++));
}

uint8_t blink_char_and_wait_for_key (uint8_t chr)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);

	while (1)
	{
		unsigned timeout;

		display_char_pg (1, chr == 0 ? 0x0a : 0);
		
		timeout = 32;
		while (timeout != 0)
		{
			if (osd_keypressed ())
				break;
			osd_delay (10);
			timeout--;
		}
		if (timeout != 0)
			break;
			
		display_char_pg (1, chr);

		timeout = 32;
		while (timeout != 0)
		{
			if (osd_keypressed ())
				break;
			osd_delay (10);
			timeout--;
		}
		if (timeout != 0)
			break;
	}
	
	display_char_pg (1, chr);
	#ifdef HAS_HWSPRITES
		if (chr == TILE_PLAYER)
		  display_char_pg (1, TILE_SPACE);
	#endif
		
	return (osd_readkey () & 0xff);	
}

void play_sound (uint8_t freq, uint8_t duration)
{
}

void throttle_and_update_sound (void)
{
  osd_delay (16);
}

void calc_colx5_scanline (uint8_t col, uint8_t row, uint8_t *colx5, uint8_t *scanline)
{
	static const uint8_t row_to_scanline_tbl[] =
	{
		0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121,
		132, 143, 154, 165, 181
	};

	static const uint8_t col_x_5_tbl[] =
	{
		0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75,
		80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135
	};

	*scanline = row_to_scanline_tbl[row];
	*colx5 = col_x_5_tbl[col];
}

void calc_scanline (uint8_t row, uint8_t offset, uint8_t *scanline)
{
	static const uint8_t byte_888a[] =
	{
		(uint8_t)-5, (uint8_t)-3, 0, 2, 4
	};
	
	*scanline = row * 11 + byte_888a[offset];
}

void calc_x_div_2 (uint8_t col, uint8_t offset, uint8_t *x)
{
	static const int8_t byte_889d[] =
	{
		-2, -1, 0, 1, 2
	};

	uint8_t y;
	calc_colx5_scanline (col, 0, x, &y);
	*x += byte_889d[offset];
}

void wipe_and_draw_level (void)
{
	OSD_PRINTF ("%s()\n", __FUNCTION__);
	
	if (zp.wipe_next_time != 0)
	{
		// wiping
		zp.drawing = 0;
		osd_wipe_circle ();
	}
	zp.wipe_next_time = 1;
	zp.drawing = 1;
	display_no_lives ();
	display_level ();
	osd_draw_circle ();
}

uint8_t game_over_animation (void)
{
  // note that there are 11 frames
  // each frame is 14 scanlines high
  // and 26*4=104 pixels = 6.5=7 NG tiles wide
  // ng requires 11*7=77 tiles
  // or use NG flipping/scaling?
  static const uint8_t game_over_frame[][14] =
  {
    { 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0 },     // 1,11
    { 0, 0, 0, 0, 0, 1, 3, 0xA, 1, 0, 0, 0, 0, 0 },   // 2,10
    { 0, 0, 0, 0, 1, 2, 3, 0xA, 2, 1, 0, 0, 0, 0 },   // 3,9
    { 0, 0, 0, 1, 2, 3, 4, 9, 0xA, 2, 1, 0, 0, 0 },   // 4,8
    { 0, 0, 1, 2, 3, 4, 5, 7, 9, 0xA, 2, 1, 0, 0 },   // 5,7
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 2, 1, 0 },   // 6
		{ 0, 0, 0, 0, 0, 1, 0xA, 3, 1, 0, 0, 0, 0, 0 },   // 12,20
    { 0, 0, 0, 0, 1, 2, 0xA, 3, 2, 1, 0, 0, 0, 0 },   // 13,19
    { 0, 0, 0, 1, 2, 0xA, 9, 4, 3, 2, 1, 0, 0, 0 },   // 14,18
    { 0, 0, 1, 2, 0xA, 9, 7, 5, 4, 3, 2, 1, 0, 0 },   // 15, 17
    { 0, 1, 2, 0xA, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 },   // 16
  };

  static const uint8_t go[][26] =
  {
    { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00  
    },
    { 0x00, 0x00, 0x15, 0x55, 0x55, 0x55, 0x55, 0x55,  
      0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,  
      0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x50,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x55, 0x50, 0x15, 0x50, 0x15,  
      0x55, 0x50, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50,  
      0x15, 0x01, 0x01, 0x55, 0x50, 0x15, 0x55, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x15,  
      0x50, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50,  
      0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50,  
      0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x15, 0x50, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x01, 0x01, 0x55, 0x00, 0x15, 0x55, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x01, 0x50, 0x15, 0x50, 0x10,  
      0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x01, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x55, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x50, 0x01, 0x00, 0x00, 0x15, 0x01, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x55, 0x50, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50,  
      0x01, 0x00, 0x01, 0x55, 0x50, 0x15, 0x01, 0x01,  
      0x00, 0x00  
    }
  };
      
	static const uint8_t frame[] =
	{
		1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 7, 8, 9, 10, 11, 10, 9, 8, 7
	};
  	
  uint8_t		game_over_loop_count = 1;
	unsigned 	f;
  
  while (game_over_loop_count < 100)
  {
  	for (f=0; f<sizeof(frame); f++)
  	{
	    osd_game_over_frame (frame[f]-1, game_over_frame, go);
	    osd_delay (game_over_loop_count++);
	    if (osd_keypressed ())
	    	return (1);
	  }
  }

	for (f=0; f<6; f++)
	{
    osd_game_over_frame (frame[f-1], game_over_frame, go);
    osd_delay (game_over_loop_count++);
  }
  
  return (0);
}

const uint8_t attract_move_tbl[] =
{
	0x16, 0x4C, 0x66, 2, 0x55, 1, 0x66, 2, 0x36, 0x18, 0x55, 1, 0x44, 1,
	0x66, 0x14, 0x36, 0xD, 0x30, 0x17, 0x60, 8, 0x66, 3, 0x16, 0x16, 0x66,
	4, 0x36, 0x23, 0x32, 1, 0x62, 1, 0x55, 1, 0x66, 0x20, 0x16, 7, 0x66,
	2, 0x36, 0x25, 0x30, 0x14, 0x60, 0xE, 0x10, 0x11, 0x16, 0x25, 0x10, 8,
	0x16, 0x23, 0x10, 6, 0x60, 2, 0x30, 0xF, 0x36, 0x17, 0x66, 2, 0x16, 7,
	0x55, 1, 0x66, 0x1E, 0x16, 0x38, 0x44, 1, 0x16, 5, 0x44, 1, 0x16, 7,
	0x44, 1, 0x36, 7, 0x55, 1, 0x36, 4, 0x55, 1, 0x16, 3, 0x55, 1, 0x16,
	3, 0x36, 0xB, 0x55, 1, 0x16, 3, 0x36, 0xE, 0x44, 1, 0x66, 1, 0x60, 0xC,
	0x30, 0x29, 0x60, 2, 0x44, 1, 0x16, 0x2B, 0x10, 4, 0x60, 5, 0x30, 1,
	0x36, 0x67, 0x32, 1, 0x44, 1, 0x66, 0x2B, 0x36, 0xC, 0x30, 0x15, 0x36,
	0x12, 0x55, 1, 0x16, 3, 0x55, 1, 0x36, 5, 0x55, 1, 0x16, 3, 0x36, 8,
	0x66, 2, 0x16, 0x4A, 0x10, 4, 0x60, 7, 0x30, 9, 0x36, 0x15, 0x66, 0xA,
	0x16, 0xD, 0x44, 1, 0x66, 2, 0x16, 4, 0x44, 1, 0x16, 2, 0x44, 6, 0x16,
	4, 0x44, 1, 0x16, 2, 0x62, 0x15, 0x36, 0x31, 0x66, 1, 0x62, 4, 0x12,
	6, 0x44, 1, 0x66, 0x37, 0x36, 1, 0x30, 0x1D, 0x60, 0x33, 0x36, 0x32,
	0x66, 3, 0x16, 1, 0x10, 0x1B, 0x60, 5, 0x36, 0x28, 0x44, 1, 0x66, 0x1F,
	0x36, 0x14, 0x44, 1, 0x55, 1, 0x66, 0x2D, 0x36, 1, 0x30, 0x12, 0x60,
	0x25, 0x66, 1, 0x55, 1, 0x16, 0xD, 0x66, 2, 0x36, 9, 0x30, 0xA, 0x36,
	4, 0x44, 1, 0x36, 3, 0x44, 1, 0x36, 3, 0x16, 0x22, 0x44, 1, 0x16, 7,
	0x44, 4, 0x16, 3, 0x44, 1, 0x16, 0x27, 0x12, 0xE, 0x16, 0x1E, 0x55, 1,
	0x66, 0x19, 0x36, 1, 0x30, 3, 0x60, 7, 0x10, 0x1F, 0x60, 7, 0x30, 9,
	0x36, 0x33, 0x66, 4, 0x10, 9, 0x16, 8, 0x12, 1, 0x62, 0xC, 0x32, 1,
	0x36, 0x32, 0x44, 1, 0x16, 0xB, 0x44, 1, 0x16, 9, 0x44, 1, 0x10, 0x2C,
	0x60, 4, 0x30, 3, 0x36, 0xA, 0x44, 1, 0x16, 5, 0x44, 1, 0x36, 3, 0x44,
	1, 0x36, 3, 0x44, 1, 0x66, 3, 0x36, 3, 0x55, 1, 0x36, 8, 0x55, 1,
	0x66, 0x4C, 0x16, 9, 0x10, 0x15, 0x44, 1, 0x10, 0x2F, 0x16, 9, 0x12,
	3, 0x16, 0x12, 0x66, 2, 0x36, 6, 0x66, 0x2D, 0x55, 1, 0x16, 3, 0x10,
	0x1C, 0x55, 1, 0x16, 3, 0x44, 1, 0x36, 3, 0x32, 0x15, 0x36, 0xB, 0x30,
	0xB, 0x60, 0xC, 0x44, 1, 0x62, 0xD, 0x12, 2, 0x16, 0xD, 0x44, 1, 0x66,
	0x20, 0x36, 4, 0x30, 0x17, 0x36, 0x1E, 0x44, 1, 0x36, 0x2F, 0x30, 8,
	0x60, 3, 0x10, 0x22, 0x16, 0x1B, 0x66, 0x26, 0x55, 7, 0x16, 3, 0x55,
	1, 0x66, 0x1D, 0x16, 2, 0x10, 0x85, 0x60, 2, 0x30, 3, 0x36, 3, 0x32,
	0xF, 0x36, 3, 0x30, 0xC, 0x36, 0x20, 0x66, 1, 0x16, 0xA, 0x60, 6, 0x66,
	2, 0x36, 8, 0x30, 5, 0x60, 2, 0x66, 2, 0x16, 8, 0x10, 1, 0x60, 6,
	0x66, 1, 0x36, 8, 0x30, 4, 0x60, 3, 0x66, 1, 0x16, 8, 0x10, 2, 0x60,
	3, 0x30, 1, 0x36, 8, 0x30, 3, 0x60, 3, 0x16, 9, 0x10, 2, 0x60, 3,
	0x30, 3, 0x36, 7, 0x30, 3, 0x60, 2, 0x10, 2, 0x16, 8, 0x10, 1, 0x60,
	2, 0x30, 2, 0x36, 0xA, 0x30, 2, 0x60, 2, 0x10, 3, 0x16, 4, 0x10, 3,
	0x60, 5, 0x30, 2, 0x36, 7, 0x66, 0x16, 0x36, 2, 0x66, 0x33, 0x55, 1,
	0x36, 5, 0x55, 1, 0x36, 4, 0x55, 1, 0x36, 3, 0x55, 1, 0x36, 3, 0x55,
	1, 0x66, 0xA9, 0x62, 0xC, 0x66, 7, 0x60, 0xF, 0x55, 1, 0x66, 0x18, 0x16,
	0x2A, 0x55, 1, 0x16, 3, 0x66, 1, 0x60, 7, 0x66, 3, 0x36, 3, 0x30, 0x1B,
	0x36, 8, 0x44, 1, 0x66, 0x18, 0x36, 0xF, 0x66, 8, 0x44, 1, 0x66, 0x38,
	0x30, 0xE, 0x66, 0x11, 0x60, 4, 0x66, 0x49, 0x37, 3, 0, 0, 0, 0, 0,
	0x30, 3, 0, 0, 0, 0, 0, 0x33, 7, 0, 0, 0, 0, 0, 0x30, 3, 0, 0,
	0, 0, 0, 0x37, 3, 0, 0, 0, 0, 0, 0x30, 3, 0, 0, 0, 0, 0, 0x33,
	7, 0, 0, 0, 0, 0, 0x30, 3, 0, 0, 0, 0, 0, 0x37, 3, 0, 0, 0, 0,
	0, 0x30, 3, 0, 0, 0, 0, 0, 0x33, 7, 0, 0, 0, 0, 0, 0x30, 3, 0,
	0, 0, 0, 0, 0x37, 3, 0, 0, 0, 0, 0, 0x30, 3, 0, 0, 0, 9, 0, 0x33,
	7, 0, 0, 0, 0, 0, 0x30, 3, 0, 0x30, 0x11, 0x11, 0x11, 0x11, 0x11,
	0x11, 0x11, 0x11, 3, 0, 0x30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0
};
