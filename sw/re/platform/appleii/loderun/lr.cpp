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

#include "vars.h"
#include "title_data_c2bpp.cpp"
#include "tile_data_c2bpp.cpp"
#include "level_data.cpp"
#include "debug.cpp"

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

// osd stuff - to be moved
RLE_SPRITE *tile[0x68];

void gcls (uint8_t page)
{
	fprintf (stderr, "%s(%d)\n", __FUNCTION__, page);
	
	if (page == 1)
		clear_bitmap (screen);
}

void check_start_new_game (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
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

void calc_colx5_scanline (uint8_t& scanline)
{
	static uint8_t row_to_scanline_tbl[] =
	{
		0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121,
		132, 143, 154, 165, 181
	};

	scanline = row_to_scanline_tbl[zp.row];
}

void display_char_pg (uint8_t page, uint8_t chr)
{
	uint8_t scanline;
	
	calc_colx5_scanline (scanline);
	draw_rle_sprite (screen, tile[chr], zp.col*10, scanline);
}

// osd stuff - moveme
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

void display_message (char *msg)
{
	fprintf (stderr, "%s(\"%s\")\n", __FUNCTION__, msg);
	
	while (*msg)
		display_character ((1<<7)|*(msg++));
}

void display_digit (uint8_t digit)
{
	digit += 0x3b;
	display_char_pg (zp.display_char_page, digit);
	zp.col++;
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
	fprintf (stderr, "%s(%d)\n", __FUNCTION__, pts);
	
	zp.score += pts;
	zp.col = 5;
	zp.row = 16;
	display_digit (zp.no_lives / 1000000);
	display_digit (zp.no_lives / 100000);
	display_digit (zp.no_lives / 10000);
	display_digit (zp.no_lives / 1000);
	display_digit (zp.no_lives / 100);
	display_digit (zp.no_lives / 10);
	display_digit (zp.no_lives % 10);
}

void cls_and_display_game_status (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	gcls (1);
	gcls (2);
	
	// draw separator
	//uint8_t byte = 0xcc; // mono
	uint8_t byte = 0xaa;
	for (int c=0; c<2*35; c++)
		for (int n=0; n<4; n++)
		{
			putpixel (screen, c*4+n, 176, byte>>((3-n)*2)&3);
			putpixel (screen, c*4+n, 177, byte>>((3-n)*2)&3);
			putpixel (screen, c*4+n, 178, byte>>((3-n)*2)&3);
			putpixel (screen, c*4+n, 179, byte>>((3-n)*2)&3);
		}
		
	zp.row = 16;
	zp.col = 0;
	display_message ("SCORE        MEN    LEVEL   ");
	display_no_lives ();
	display_level ();
	update_and_display_score (0);
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
  
  dbg_dump_level_packed ();
}

void wipe_and_draw_level (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void draw_level (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

  dbg_dump_level ();
  
  wipe_and_draw_level ();
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

void main_game_loop (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
	
	init_read_unpack_display_level (1);
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
	zp.attract_mode >>= 1;
	
	cls_and_display_game_status ();
	// HGR1
	
	main_game_loop ();
}

void high_score_screen (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);
}

void title_wait_for_key (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	uint16_t  timeout = 5000/10;
	
	clear_keybuf ();
	while (timeout)
	{
		if (keypressed ())
			break;
		rest (10);
		timeout--;
	}
	
	if (timeout != 0)
	{
		check_start_new_game ();
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
			zero_score_and_init_game ();
		}
		else
		{
			if (zp.attract_mode == 1)
				high_score_screen ();
		}
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
	
	// this part needs abstracting (later)
	uint8_t *ptitle_data = title_data;
	zp.row = 192;
	zp.col = 2*35;
	while (zp.row > 0)
	{
		uint8_t count = *(ptitle_data++);
		uint8_t	byte = *(ptitle_data++);
		
		while (count--)
		{
			// put byte - fixme
			for (int n=0; n<4; n++)
				putpixel (screen, (2*35-zp.col)*4+n, (192-zp.row), byte>>((3-n)*2)&3);
			if (--zp.col == 0)
			{
				zp.col = 2*35;
				zp.row--;
			}
		}
	}
	// HGR1
	title_wait_for_key ();
}

void lode_runner (void)
{
	fprintf (stderr, "%s()\n", __FUNCTION__);

	zp.game_speed = 6;
	zp.byte_64 = 0;
	zp.sound_enabled = (uint8_t)-1;
	
	display_title_screen ();
}

void main (int argc, char *argv[])
{
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 280, 192, 0, 0);

  PALETTE pal;
  uint8_t r[] = { 0x00, 255>>2,  20>>2, 255>>2 };
  uint8_t g[] = { 0x00, 106>>2, 208>>2, 255>>2 };
  uint8_t b[] = { 0x00,  60>>2, 254>>2, 255>>2 };
  for (int c=0; c<sizeof(r); c++)
  {
    pal[c].r = r[c];
    pal[c].g = g[c];
    pal[c].b = b[c];
  }
	set_palette_range (pal, 0, 3, 1);

	// setup sprites
	BITMAP *bm = create_bitmap (10, 11);
	for (int s=0; s<0x68; s++)
	{
		for (unsigned y=0; y<11; y++)
		{
			for (unsigned x=0; x<10; x++)
			{
				uint8_t data = tile_data_c2bpp[s*33+y*3+x/4];
				data >>= (3-(x%4))*2;
				data &= 3;
				putpixel (bm, x, y, data);
			}
		}
		tile[s] = get_rle_sprite (bm);
	}
	destroy_bitmap (bm);
	
	lode_runner ();

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
