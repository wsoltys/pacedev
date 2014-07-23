#include <stdlib.h>
#include <video.h>
#include <input.h>

// osd stuff

#include "osd_types.h"
#include "lr_osd.h"

extern const uint8_t tile_data_m2bpp[];
extern const uint8_t tile_data_c2bpp[];
extern const uint8_t title_data_m2bpp[];
extern const uint8_t title_data_c2bpp[];

TILEMAP map[3][28];
const unsigned page_sprite[3] = { 32, 64, 96 };
unsigned tile_base;

#define DIP_COLOUR      0
#define DIP_MONO        1
#define DIP_MONO_GREEN  0
#define DIP_MONO_WHITE  1

#define XOFF            ((320-280)/2)
#define YOFF            ((224-192)/2)
#define XZ	            9
#define YZ	            175
#define CLIP            16
#define NEO_SPRITE(s)   (128+(s))

#define TILE_SEPARATOR  0x68

extern void lode_runner (void);

void osd_gcls (uint8_t page)
{
	unsigned tm, t, s;
	
	for (tm=0; tm<28; tm++)
		for (t=0; t<32; t++)
			map[page][tm].tiles[t].block_number = tile_base;
	set_current_sprite (page_sprite[page]);
	write_sprite_data (XOFF, YOFF, XZ, YZ, CLIP, 28, (const PTILEMAP)map[page]);

  // extra tilemap for status display
	if (page == 1)
  {
  	for (tm=0; tm<28; tm++)
  		for (t=0; t<32; t++)
  			map[0][tm].tiles[t].block_number = tile_base;
  	set_current_sprite (page_sprite[0]);
  	write_sprite_data (XOFF, YOFF+176-6, XZ, YZ, 2, 28, (const PTILEMAP)map[0]);
  }
	// and finally the sprites
	for (s=0; s<14; s++)
	  change_sprite_pos (NEO_SPRITE(s), 0, 255, 0);
}

void osd_display_char_pg (uint8_t page, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	uint16_t  *vram = (uint16_t *)0x3C0000;

  if (page == 1 && y >= 176)
  {
    page = 0;
    y -= (176-11);
  }

  *vram = ((32*(page+1))+(x_div_2/5))*64 + (y/11)*2;
  *(vram+1) = tile_base+chr;

  // update tilemap
	map[page][x_div_2/5].tiles[y/11].block_number = tile_base + chr;
		
#if 0
  uint16_t  x = x_div_2 * 2;
  
	// fudge: fixme
	rectfill (pg[page-1], x, y, x+9, y+10, 0);
	draw_rle_sprite (pg[page-1], tile[chr], x, y);
#endif
}

void osd_draw_separator (uint8_t page, uint8_t byte, uint8_t y)
{  	
	uint16_t  *vram = (uint16_t *)0x3C0000;
  unsigned t;
  
  for (t=0; t<28; t++)
  {
    *vram = ((32*(0+1))+t)*64;
    *(vram+1) = tile_base+TILE_SEPARATOR;

    // update tilemap
  	map[0][t].tiles[0].block_number = tile_base + TILE_SEPARATOR;
  }
  
#if 0
	for (int c=0; c<2*35; c++)
		for (int n=0; n<4; n++)
		{
			putpixel (pg[page-1], c*4+n, y+0, byte>>((3-n)*2)&3);
			putpixel (pg[page-1], c*4+n, y+1, byte>>((3-n)*2)&3);
			putpixel (pg[page-1], c*4+n, y+2, byte>>((3-n)*2)&3);
			putpixel (pg[page-1], c*4+n, y+3, byte>>((3-n)*2)&3);
		}
#endif
}		

void osd_wipe_circle (void)
{
	unsigned tm, t;
	
	for (tm=0; tm<28; tm++)
		for (t=0; t<16; t++)
			map[1][tm].tiles[t].block_number = tile_base;
	set_current_sprite (page_sprite[1]);
	write_sprite_data(XOFF, YOFF, XZ, YZ, CLIP, 28, (const PTILEMAP)map[1]);

#if 0
  // fixme
  rectfill (pg[0], 0, 0, 279, 175, 0);
#endif
}

void osd_draw_circle (void)
{
	unsigned tm, t;
	
	for (tm=0; tm<28; tm++)
		for (t=0; t<16; t++)
			map[1][tm].tiles[t].block_number = map[2][tm].tiles[t].block_number;
	set_current_sprite (page_sprite[1]);
	write_sprite_data(XOFF, YOFF, XZ, YZ, CLIP, 28, (const PTILEMAP)map[1]);
	
#if 0
  // fixme
	blit (pg[1], pg[0], 0, 0, 0, 0, 280, 176);
#endif
}

int osd_keypressed (void)
{
	return ((poll_joystick(PORT1, READ_DIRECT) &0x3FF) != 0);
}

void osd_delay (unsigned ms)
{
	while (ms--)
	{
		unsigned t;

		for (t=0; t<512; t++)
			;
	}
}

int osd_readkey (void)
{
#if 0
  return (readkey ());
#endif
	return (0);
}

int osd_key (int _key)
{
	DWORD port1;
	
	port1 = poll_joystick(PORT1, READ_DIRECT);
	switch (_key)
	{
		case LR_KEY_I :
			return ((port1 & JOY_UP) != 0);
		case LR_KEY_J :
		case LR_KEY_BS :
			return ((port1 & JOY_LEFT) != 0);
		case LR_KEY_K :
			return ((port1 & JOY_DOWN) != 0);
		case LR_KEY_L :
		case LR_KEY_RIGHT :
			return ((port1 & JOY_RIGHT) != 0);
		case LR_KEY_U :
		case LR_KEY_Z :
			return ((port1 & JOY_A) != 0);
		case LR_KEY_O :
		case LR_KEY_X :
			return ((port1 & JOY_B) != 0);
		default :
			break;
	};
	
	return (0);
}

void osd_wipe_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	if (sprite < 0)
		osd_display_char_pg (1, 0, x_div_2, y);

#if 0
	// quick hack for now
	blit (pg[1], pg[0], x_div_2*2, y, x_div_2*2, y, 10, 11);
#endif
}

void osd_display_transparent_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
#if 0  
	uint16_t  *vram = (uint16_t *)0x3C0000;
  uint16_t  addr;

  // set sprite tile, attrib
	addr = (100+sprite)*64;
	*vram = addr;
	*(vram+1) = tile_base+chr;
	*(vram+1) = 0;

  // set position
  addr = 0x8200+100+sprite;
  *vram = addr;
  *(vram+1) = 	
#else
  TILEMAP stm;
  if (sprite < 0)
    osd_display_char_pg (1, chr, x_div_2, y);
  else
  {
    stm.tiles[0].block_number = tile_base+chr;
    stm.tiles[0].attributes = 16<<8;
    stm.tiles[1].block_number = tile_base;
    stm.tiles[1].attributes = 16<<8;
    set_current_sprite (NEO_SPRITE(sprite));
    write_sprite_data (XOFF+x_div_2*2, YOFF+y, XZ, YZ, 1, 1, (const PTILEMAP)&stm);
  }
#endif
  
#if 0
  // always page HGR1
	draw_rle_sprite (pg[0], tile[chr], x_div_2*2, y);
#endif
}

static uint8_t osd_hgr_skip;

void osd_hgr (uint8_t page)
{
	if (osd_hgr_skip)
	{
		osd_hgr_skip = 0;
		return;
	}
		
  if (page == 1)
  {
  	change_sprite_pos (page_sprite[2], 0, 255, 0);
  	change_sprite_pos (page_sprite[1], XOFF, YOFF, CLIP);
  	change_sprite_pos (page_sprite[0], XOFF, YOFF+176-6, 2);
  }
  else
  {
    unsigned s;

  	// hide the sprites
  	for (s=0; s<6; s++)
  	  change_sprite_pos (NEO_SPRITE(s), 0, 255, 0);

  	change_sprite_pos (page_sprite[1], 0, 255, 0);
  	change_sprite_pos (page_sprite[0], XOFF, YOFF+176-6, 0);
  	change_sprite_pos (page_sprite[2], XOFF, YOFF, CLIP);
  }

#if 0
  if (page == 1)
    ret = HGR1;
  else
    ret = HGR2;
    
	//if (ret != 0)
	//	fprintf (stderr, "* scroll_screen(%d) failed!\n", page);    
#endif
}

void osd_flush_keybd (void)
{
	while (osd_keypressed ())
		;
}

void osd_display_title_screen (uint8_t page)
{
	unsigned tm, t;
	unsigned n = 0;

	change_sprite_pos (page_sprite[0], XOFF, YOFF+176-6, 0);
	change_sprite_pos (page_sprite[2], 0, 255, 0);
	
	for (tm=0; tm<28; tm++)
	{
		for (t=0; t<12; t++)
		{
			map[1][tm].tiles[t].block_number = tile_base+128+n;
			map[1][tm].tiles[t].attributes = 16<<8;
			n++;
		}
	}
	set_current_sprite (page_sprite[1]);
	write_sprite_data (XOFF, YOFF, XZ, 255, 12, 28, (const PTILEMAP)map[1]);

	osd_hgr_skip = 1;
		
#if 0
	#ifdef MONO
  	uint8_t *ptitle_data = title_data_m2bpp;
	#else
  	uint8_t *ptitle_data = title_data_c2bpp;
	#endif
	
	uint8_t row = 192;
	uint8_t col = 2*35;
	while (row > 0)
	{
		uint8_t count = *(ptitle_data++);
		uint8_t	byte = *(ptitle_data++);
		
		while (count--)
		{
			// put byte - fixme
			for (int n=0; n<4; n++)
				putpixel (pg[page-1], (2*35-col)*4+n, (192-row), byte>>((3-n)*2)&3);
				//pg[page-1]->line[(192-row)][(2*35-col)*4+n] = byte>>((3-n)*2)&3;
			if (--col == 0)
			{
				col = 2*35;
				row--;
			}
		}
	}
#endif
}

void osd_game_over_frame (uint8_t frame, const uint8_t game_over_frame[][14], const uint8_t gol[][26])
{
  TILEMAP stm[7];
  unsigned tm;

  for (tm=0; tm<7; tm++)
  {
    stm[tm].tiles[0].block_number = tile_base+512+frame*8+tm;
    stm[tm].tiles[0].attributes = (17<<8)|0;
  }
  set_current_sprite (NEO_SPRITE(6)+tm);
	write_sprite_data(XOFF+13*7-4, YOFF+80, 15, 255, 1, 7, (const PTILEMAP)stm);
}

void osd_load_high_scores (PHS_ENTRY hs_tbl)
{
	memcpy (hs_tbl[0].initial, "MMC", 3);
	hs_tbl[0].level = 42;
	hs_tbl[0].score = 314159;
}

void osd_save_high_scores (PHS_ENTRY hs_tbl)
{
}

int main (int argc, char *argv[])
{
  uint8_t *dips = (uint8_t *)0x10FD84;
  
  uint8_t colour_mono = *(dips+6);
  uint8_t mono_colour = *(dips+7);

	// transparent, orange, blue, white/green
  const uint8_t r[] = { 0x00>>3, 255>>3,  20>>3, 255>>3 };
  const uint8_t g[] = { 0x00>>3, 106>>3, 208>>3, 255>>3 };
  const uint8_t b[] = { 0x00>>3,  60>>3, 254>>3, 255>>3 };

	PALETTE 	pal[2];
	unsigned	p, c;
	unsigned 	m, tm, t, s;

	for (p=0; p<2; p++)
	{	
		for (c=0; c<4; c++)
		{
			uint16_t	pe = 0;
	
	    if (c < 3 ||
	        colour_mono == DIP_COLOUR ||
	        mono_colour == DIP_MONO_WHITE)
	    {
	  		pe |= (r[c]&(1<<0)) << 14;
	  		pe |= (r[c]&0x1E) << 7;
	  		pe |= (b[c]&(1<<0)) << 12;
	  		pe |= (b[c]&0x1E) >> 1;
	    }
			pe |= (g[c]&(1<<0)) << 13;
			pe |= (g[c]&0x1E) << 3;

			if (p < 1 || c < 3)	  		
				pal[p].color[c] = pe;
			else
				pal[p].color[c] = 0;
		}
	}
	setpalette(16, 2, (const PPALETTE)&pal);

	// build tilemaps
	for (m=0; m<3; m++)
	{
		for (tm=0; tm<28; tm++)
		{
			for (t=0; t<32; t++)
			{
				map[m][tm].tiles[t].block_number = tile_base+0;
				map[m][tm].tiles[t].attributes = 16<<8;
			}
		}
	}

  // setup 'sprite' sprites
  for (s=0; s<6; s++)
  {
    TILEMAP   stm;
    unsigned  t;
    
    for (t=0; t<32; t++)
    {
      stm.tiles[t].block_number = tile_base+0;
      stm.tiles[t].attributes = 16<<8;
    }
    set_current_sprite (NEO_SPRITE(s));
		write_sprite_data(0, 0, XZ, YZ, 1, 1, (const PTILEMAP)&stm);
  }

  // setup 'gameover' sprites
  {
    TILEMAP stm;
    unsigned tm, t;

    for (tm=0; tm<7; tm++)
    {
      for (t=0; t<32; t++)
      {
        stm.tiles[t].block_number = tile_base+0;
        stm.tiles[t].attributes = (17<<8)|0;
      }
    }
    set_current_sprite (NEO_SPRITE(6)+tm);
		write_sprite_data(0, 0, 15, 255, 1, 7, (const PTILEMAP)&stm);
  }

	while (1)
	{
		clear_fix();
		clear_spr();

		// display some eye-catcher stuff
		if (1)
		{
			static const uint16_t max_330_mega[2][15] =
			{
				{
					0x05, 0x07, 0x09, 0x0B, 0x0D, 0x0F, 0x15, 0x17, 0x19, 0x1B, 0x1D, 0x1F, 0x5E, 0x60, 0x7D
				},
				{
					0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E, 0x40, 0x5F, 0x7C, 0x7E
				}
			};
			
			static const uint16_t pro_gear_spec[2][17] =
			{
				{
					0x7F, 0x9A, 0x9C, 0x9E, 0xFF, 0xBB, 0xBD, 0xBF, 0xDA, 0xDC, 0xDE, 0xFA, 0xFC, 0x100, 0x102, 0x104, 0x106
				},
				{
					0x99, 0x9B, 0x9D, 0x9F, 0xBA, 0xBC, 0xBE, 0xD9, 0xDB, 0xDD, 0xDF, 0xFB, 0xFD, 0x101, 0x103, 0x105, 0x107
				}
			};

			static const uint16_t eye_catcher_pal[] = 
			{
				0x0000, 0x0fff, 0x0ddd, 0x0aaa, 0x7555, 0x0000, 0x0000, 0x0000,
				0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
			};

			PALETTE pal;						
			volatile uint16_t  *vram = (uint16_t *)0x3C0000;
			// skip top 2 lines, left column
		  uint16_t  addr = 0x7000+(12*32+16);
			unsigned n;

			for (n=0; n<16; n++)
				pal.color[n] = eye_catcher_pal[n];
			setpalette (15, 1, (const PPALETTE)&pal);
			
			*(vram+2) = 1;
			for (n=0; n<17; n++)
			{		
				*vram = addr;
				if (n == 0 || n == 16)
					*vram = addr+2;
				else
				{
					*(vram+1) = 0xf000 | max_330_mega[0][n-1];
					*(vram+1) = 0xf000 | max_330_mega[1][n-1];
				}
				*(vram+1) = 0xf000 | pro_gear_spec[0][n];
				*(vram+1) = 0xf000 | pro_gear_spec[1][n];

				addr+=32;
			}

      addr = 0x7000+(16*32)+22;			
			for (n=0; n<16; n++)
			{
			  *vram = addr;
			  *(vram+1) = 0xf000 | 0x7B; //(0x20+n);
			  if ((addr%2) == 0)
			    addr++;
			  else
			    addr += 31;
			}
			
			// (C)
			addr = 0x7469;
			*vram = addr;
			*(vram+1) = 0xF000 | 0x7B;
		}
				
		//textoutf (13, 20, 0, 0, "LODE RUNNER");
		//_vbl_count = 0;
		//wait_vbl();

		tile_base = 256;
    if (colour_mono == DIP_COLOUR)
			tile_base += 640;

		osd_hgr_skip = 0;		
		
		lode_runner ();
	}
  
  return (0);
}

