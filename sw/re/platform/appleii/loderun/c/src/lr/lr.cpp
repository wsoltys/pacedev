#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#include "lr_osd.h"
#include "debug.h"

#include "vars.h"

extern uint8_t demo_level_data[][256];
extern uint8_t game_level_data[][256];

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
uint8_t guard_state[8];
uint8_t guard_x_offset[8];
uint8_t guard_y_offset[8];
uint8_t guard_sprite[8];
uint8_t guard_dir[8];
uint8_t guard_cnt[8];
uint8_t hole_col[0x20];
uint8_t hole_row[0x20];
uint8_t hole_cnt[0x20];

uint8_t level_data_packed[256];

uint8_t ldu1[16][28];
uint8_t ldu2[16][28];

// end of RAM

// prototypes

static void display_title_screen (void);
static void zero_score_and_init_game (void);
static void main_game_loop (void);
static bool title_wait_for_key (void);
//static void read_and_display_scores (void);
//static void high_score_screen (void);
//static void check_start_new_game (void);
static void init_read_unpack_display_level (uint8_t editor_n);
static void read_level_data (void);
static void init_and_draw_level (void);
static bool draw_level (void);
static void handle_player (void);
static void draw_player_sprite (void);
static bool move_left (void);
static bool move_right (void);
static bool move_up (void);
static bool move_down (void);
static bool dig_left (void);
static bool digging_left (void);
static bool dig_right (void);
static bool digging_right (void);
static void read_controls (void);
static void calc_char_and_addr (uint8_t& chr, uint8_t& x_div_2, uint8_t& y);
static void check_for_gold (void);
static void update_sprite_index (uint8_t first, uint8_t last);
static void adjust_x_offset_in_tile (void);
static void adjust_y_offset_within_tile (void);
static void add_hole_entry (uint8_t col);
static void cls_and_display_high_scores (void);
static void cls_and_display_game_status (void);
static void gcls (uint8_t page);
static void display_no_lives (void);
static void display_byte (uint8_t col, uint8_t byte);
static void display_level (void);
static void update_and_display_score (uint16_t pts);
static void display_digit (uint8_t digit);
static uint8_t remap_character (uint8_t chr);
static void display_character (uint8_t chr);
static void display_char_pg (uint8_t page, uint8_t chr);
static void wipe_char (uint8_t chr, uint8_t x_div_2, uint8_t y);
static void display_transparent_char (uint8_t chr, uint8_t x_div_2, uint8_t y);
static void draw_end_of_screen_ladder (void);
static void display_message (const char *msg);
static uint8_t blink_char_and_wait_for_key (uint8_t chr);
static void play_sound (uint8_t freq, uint8_t duration);
static void throttle_and_update_sound (void);
static void calc_colx5_scanline (uint8_t col, uint8_t row, uint8_t& colx5, uint8_t& scanline);
static void calc_scanline (uint8_t offset, uint8_t row, uint8_t& scanline);
static void calc_x_in_2_pixel_incs (uint8_t col, uint8_t offset, uint8_t& x);
static void wipe_and_draw_level (void);

// end of prototypes

void lode_runner (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	zp.game_speed = 6;
	zp.byte_64 = 0;
	zp.sound_enabled = (uint8_t)-1;
	
	display_title_screen ();
	OSD_HGR1;

	while (1)
	{
		// hack
		if (osd_key (OSD_KEY_ESC))
			break;

		bool key = title_wait_for_key ();
		if (key)
		{
			//check_start_new_game ();
			if ((osd_readkey () & 0xff) == 0x0D)
			{
				//read_and_display_scores ();
					cls_and_display_high_scores ();
					zp.attract_mode = 2;
					// jmp title_wait_for_key
					continue;
			}
			zp.level_0_based = 0;
			zp.level = 1;
			zp.no_cheat = 1;
			zp.attract_mode = 2;
		}
		else
		{
			if (zp.attract_mode == 0)
			{
				// init attract mode
				zp.attract_mode = 1;
				zp.level = 1;
				zp.byte_ac = 1;
				zp.no_cheat = 1;
				zp.sound_setting = zp.sound_enabled;
				zp.sound_enabled = 0;
			}
			else
			{
				if (zp.attract_mode == 1)
				{
					//high_score_screen ();
					cls_and_display_high_scores ();
					zp.attract_mode = 2;
					// jmp title_wait_for_key
					continue;
				}
			}
		}
		zero_score_and_init_game ();
		main_game_loop ();
	}
}

void display_title_screen (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	gcls (1);
	zp.attract_mode = 0;
	zp.level_0_based = 0;
	//zp.hires_page_msb1
	zp.display_char_page = 1;

  #if 0
    osd_display_title_screen (zp.display_char_page);
  #else
    zp.col = 2;
    zp.row = 8;
    display_message ("INSERT TITLE SCREEN HERE");
  #endif
}

void zero_score_and_init_game (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	zp.score = 0;
	zp.unused_97 = 0;
	zp.wipe_next_time = 0;
	zp.guard_respawn_col = 0;
	zp.demo_inp_cnt = 0;
	zp.demo_inp_ptr = 0;
	zp.no_lives = 5;
	if (zp.attract_mode >> 1)
	  ;
	cls_and_display_game_status ();
	OSD_HGR1;
	// main_game_loop ();
}

void main_game_loop (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

  static uint8_t guard_params[][3] =
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

  static uint8_t guard_trap_cnt_init_tbl[] =
  {
    0x26, 0x26, 0x2E, 0x44, 0x47, 0x49, 0x4A, 0x4B, 0x4C, 
    0x4D, 0x4E, 0x4F, 0x50
  };

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
	uint8_t data = (zp.unused_97 + zp.no_guards);
zp.byte_60 = guard_params[data][0];
	zp.byte_61 = guard_params[data][1];
	zp.byte_62 = guard_params[data][2];
	// unused_97 should be zero
	zp.guard_trap_cnt_init = guard_trap_cnt_init_tbl[zp.unused_97];

in_level_loop:
  
  if (osd_key (OSD_KEY_ESC))
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
  //respawn_guard_and_update_holes ();
  if (zp.level_active == 0)
    goto dec_lives;
  throttle_and_update_sound ();
  //handle_guards ();
  if (zp.level_active == 0)
    goto dec_lives;
  goto in_level_loop;

next_level:
  zp.level++;
  zp.level_0_based++;
  if (zp.no_lives != 255)
    zp.no_lives++;
  for (unsigned i=0; i<SCORE_LEVEL_MULT; i++)
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
  //throttle_and_update_sound ();
  if ((zp.attract_mode >> 1) == 0)
    goto end_demo;
  if (zp.no_lives > 0)
    goto main_game_loop;
    
  //check_and_update_high_score_tbl ();
  //game_over_animation ();
  return;
  
end_demo:
  zp.sound_enabled = zp.sound_setting;
}

bool title_wait_for_key (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	uint16_t  timeout = 5000/10;

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

void read_and_display_scores (void)
{
}

void high_score_screen (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void init_read_unpack_display_level (uint8_t editor_n)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
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
	
	for (unsigned h=0; h<MAX_HOLES; h++)
	  hole_cnt[h] = 0;
  for (unsigned g=0; g<MAX_GUARDS; g++)
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
	fprintf (stderr, "%s() : level_0_based = %d, level = %d, attract_mode=%d\n", 
	          __FUNCTION__, zp.level_0_based, zp.level, zp.attract_mode);
  
  uint8_t *p;
  
  if ((zp.attract_mode >> 1) != 0)
    p = game_level_data[zp.level_0_based];
  else
    p = demo_level_data[zp.level-1];
    
  memcpy (level_data_packed, p, 256);
  
  //dbg_dump_level_packed ();
}

void init_and_draw_level (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

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
	fprintf (stderr, "%s()\n", __FUNCTION__);

  //dbg_dump_level ();
  
  wipe_and_draw_level ();
  
  // wipe player and enemies from background
  for (zp.row=15; zp.row != (uint8_t)-1; zp.row--)
  {
  	for (zp.col=27; zp.col != (uint8_t)-1; zp.col--)
  	{
  		uint8_t tile = ldu1[zp.row][zp.col];
  		if (tile == TILE_PLAYER || tile == TILE_GUARD)
  			display_char_pg (2, TILE_SPACE);
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
  if (zp.dig_dir == (uint8_t)-1)
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
  calc_char_and_addr (chr, x_div_2, y);
  wipe_char (chr, x_div_2, y);
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
  
  calc_char_and_addr (chr, x_div_2, y);
  display_transparent_char (chr, x_div_2, y);
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
  calc_char_and_addr (chr, x_div_2, y);
  wipe_char (chr, x_div_2, y);
  zp.dir = (uint8_t)-1;
  adjust_y_offset_within_tile ();
  if (--zp.x_offset_within_tile == (uint8_t)-1)
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
  calc_char_and_addr (chr, x_div_2, y);
  wipe_char (chr, x_div_2, y);
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
  calc_char_and_addr (chr, x_div_2, y);
  wipe_char (chr, x_div_2, y);
  adjust_x_offset_in_tile ();
  if (--zp.y_offset_within_tile == (uint8_t)-1)
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
  calc_char_and_addr (chr, x_div_2, y);
  wipe_char (chr, x_div_2, y);
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
  zp.dig_dir = (uint8_t)-1;
  zp.key_1 = (uint8_t)-1;
  zp.key_2 = (uint8_t)-1;
  zp.dig_sprite = 0;

  return (digging_left ());
}

bool digging_left (void)
{
  static uint8_t dig_sprite_to_char_tbl[] =
  {
    0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1D, 0x1E,
		0x1E, 0, 0, 0, 0, 0x26, 0x26, 0x27, 0x27, 0x1D, 0x1D, 0x1E, 0x1E, 0,
		0, 0, 0, 0x1F, 0x1F, 0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23,
		0x24, 0x24
	};

  uint8_t chr, x_div_2, y;
  
  if (zp.current_row == 15)
    goto cant_dig_left;
  if (zp.current_col == 0)
    goto cant_dig_left;
  if (ldu1[zp.current_row+1][zp.current_col-1] != TILE_BRICK)
    goto cant_dig_left;
  if (ldu1[zp.current_row][zp.current_col-1] != TILE_SPACE)
    goto abort_dig_left;
  calc_char_and_addr (chr, x_div_2, y);
  wipe_char (chr, x_div_2, y);
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
  {
    add_hole_entry (zp.current_col-1);
    return (false);
  }
  if (zp.dig_sprite != 0)
  {
    chr = dig_sprite_to_char_tbl[zp.dig_sprite-1];
    calc_colx5_scanline (zp.current_col-1, zp.current_row, x_div_2, y);
    wipe_char (chr, x_div_2, y);
  }
  chr = dig_sprite_to_char_tbl[zp.dig_sprite];
  zp.col = zp.current_col-1;
  zp.row = zp.current_row;
  calc_colx5_scanline (zp.col, zp.row, x_div_2, y);
  display_transparent_char (chr, x_div_2, y);
  chr = dig_sprite_to_char_tbl[zp.dig_sprite+24];
  zp.row++;
  display_char_pg (1, chr);  
  zp.dig_sprite++;
  return (true);
  
abort_dig_left:
  zp.row = zp.current_row+1;
  zp.col = zp.current_col-1;
  display_char_pg (1, TILE_BRICK);
  if (zp.dig_sprite != 0)
  {
  	chr = dig_sprite_to_char_tbl[zp.dig_sprite-1];
  	calc_colx5_scanline (zp.current_col-1, zp.current_row, x_div_2, y);
    wipe_char (chr, x_div_2, y);    
  }

cant_dig_left:
//finish_dig_left:
  zp.dig_dir = 0;
  return (false);
}

bool dig_right (void)
{
  return (true);
}

bool digging_right (void)
{
  return (true);
}

void read_controls (void)
{
  zp.key_1 = 0;
  
  if (osd_key (OSD_KEY_I))
    zp.key_1 = 'I';
  if (osd_key (OSD_KEY_J))
    zp.key_1 ='J';
  if (osd_key (OSD_KEY_K))
    zp.key_1 = 'K';
  if (osd_key (OSD_KEY_L))
    zp.key_1 = 'L';
  if (osd_key (OSD_KEY_U) || osd_key (OSD_KEY_Z))
    zp.key_1 = 'U';
  if (osd_key (OSD_KEY_O) || osd_key (OSD_KEY_X))
    zp.key_1 = 'O';
    
  zp.key_2 = zp.key_1;
}

void calc_char_and_addr (uint8_t& chr, uint8_t& x_div_2, uint8_t& y)
{
  static uint8_t sprite_to_char_tbl[] =
  {
    0xB, 0xC, 0xD, 0x18, 0x19, 0x1A, 0xF, 0x13, 9, 0x10, 0x11, 0x15, 0x16,
		0x17, 0x25, 0x14, 0xE, 0x12
	};

	calc_x_in_2_pixel_incs (zp.current_col, zp.x_offset_within_tile, x_div_2);
  calc_scanline (zp.y_offset_within_tile, zp.current_row, y);
  chr = sprite_to_char_tbl[zp.sprite_index];
}

void check_for_gold (void)
{
  uint8_t x_div_2, scanline;
  
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
  calc_colx5_scanline (zp.col, zp.row, x_div_2, scanline);
  wipe_char (TILE_GOLD, x_div_2, scanline);
  update_and_display_score (SCORE_GOLD);
  //queue_sound ();
}

void update_sprite_index (uint8_t first, uint8_t last)
{
	++zp.sprite_index;
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

void add_hole_entry (uint8_t col)
{
  zp.dig_dir = 0;
  zp.col = col;
  zp.row = zp.current_row + 1;
  ldu1[zp.row][zp.col] = TILE_SPACE;
  display_char_pg (1, TILE_SPACE);
  display_char_pg (2, TILE_SPACE);
  zp.row--;
  display_char_pg (1, TILE_SPACE);
  zp.row++;
  // extra stuff
}

void cls_and_display_high_scores (void)
{
	gcls (2);
	zp.display_char_page = 2;
	zp.col = 0;
	zp.row = 0;
	display_message (	"    LODE RUNNER HIGH SCORES\r\r\r"
										"    INITIALS LEVEL  SCORE\r"
										"    -------- ----- --------\r");
										
	OSD_HGR2;
	zp.display_char_page = 1;
}

void cls_and_display_game_status (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	gcls (1);
	gcls (2);

  osd_draw_separator (zp.display_char_page, 0xaa, 176);
		
	zp.row = 16;
	zp.col = 0;
	display_message ("SCORE        MEN    LEVEL   ");
	display_no_lives ();
	display_level ();
	update_and_display_score (0);
}

void gcls (uint8_t page)
{
	fprintf (stderr, "%s(%d)\n", __FUNCTION__, page);

  osd_gcls (page);
}

void display_no_lives (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
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
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	display_byte (25, zp.level);
}

void update_and_display_score (uint16_t pts)
{
  uint32_t  score;
  
	//fprintf (stderr, "%s(%d)\n", __FUNCTION__, pts);
	
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

void display_char_pg (uint8_t page, uint8_t chr)
{
	uint8_t colx5;
	uint8_t scanline;
	
	calc_colx5_scanline (0, zp.row, colx5, scanline);
	osd_display_char_pg (page, chr, zp.col*5, scanline);
}

void wipe_char (uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	osd_wipe_char (chr, x_div_2, y);
}

void display_transparent_char (uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	//fprintf (stderr, "%s()\n", __FUNCTION__);

  osd_display_transparent_char (chr, x_div_2, y);
}

void draw_end_of_screen_ladder (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

  uint8_t x_div_2, scanline;

  // flag ladder OK  
  eos_ladder_col[0] = 0;
  for (int n=zp.no_eos_ladder_tiles; n>0; n--)
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
    calc_colx5_scanline (zp.col, zp.row, x_div_2, scanline);
    display_transparent_char (TILE_LADDER, x_div_2, scanline);
    // flag tile drawn
    eos_ladder_col[n] = (uint8_t)-1;
  }
  if (eos_ladder_col[0] == 0)
	  zp.no_gold = (uint8_t)-1;
}

void display_message (const char *msg)
{
	fprintf (stderr, "%s(\"%s\")\n", __FUNCTION__, msg);
	
	while (*msg)
		display_character ((1<<7)|*(msg++));
}

uint8_t blink_char_and_wait_for_key (uint8_t chr)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	while (1)
	{
		display_char_pg (1, chr == 0 ? 0x0a : 0);
		
		unsigned timeout = 32;
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
	
	return (osd_readkey () & 0xff);	
}

void play_sound (uint8_t freq, uint8_t duration)
{
}

void throttle_and_update_sound (void)
{
  osd_delay (16);
}

void calc_colx5_scanline (uint8_t col, uint8_t row, uint8_t& colx5, uint8_t& scanline)
{
	static uint8_t row_to_scanline_tbl[] =
	{
		0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121,
		132, 143, 154, 165, 181
	};

	static uint8_t col_x_5_tbl[] =
	{
		0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75,
		80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135
	};

	scanline = row_to_scanline_tbl[row];
	colx5 = col_x_5_tbl[col];
}

void calc_scanline (uint8_t offset, uint8_t row, uint8_t& scanline)
{
	uint8_t	byte_888a[] =
	{
		(uint8_t)-5, (uint8_t)-3, 0, 2, 4
	};
	
	scanline = row * 11 + byte_888a[offset];
}

void calc_x_in_2_pixel_incs (uint8_t col, uint8_t offset, uint8_t& x)
{
	static uint8_t byte_889d[] =
	{
		(uint8_t)-2, (uint8_t)-1, 0, 1, 2
	};

	uint8_t scanline;
	calc_colx5_scanline (col, 0, x, scanline);
	x += byte_889d[offset];
}

void wipe_and_draw_level (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
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
