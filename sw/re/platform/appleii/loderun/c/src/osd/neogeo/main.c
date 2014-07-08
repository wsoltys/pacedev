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

TILEMAP map[2][28];
const unsigned page_sprite[2] = { 32, 64 };
unsigned _page = 0;
unsigned tile_base;

#define XOFF  ((320-280)/2)
#define XZ	  9
#define YZ	  175
#define CLIP  34

extern void lode_runner (void);

void osd_gcls (uint8_t page)
{
	unsigned tm, t;
	
	for (tm=0; tm<28; tm++)
		for (t=0; t<18; t++)
			map[page-1][tm].tiles[t].block_number = tile_base;
	set_current_sprite (page_sprite[page-1]);
	//if (page == _page)
		write_sprite_data(XOFF+0, 0, XZ, YZ, CLIP, 28, (const PTILEMAP)map[page-1]);
}

void osd_display_char_pg (uint8_t page, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
	uint16_t  *vram = (uint16_t *)0x3C0000;
  uint16_t  addr = ((32*page)+(x_div_2/5))*64 + (y/11)*2;

  *vram = addr;
  *(vram+1) = tile_base+chr;

	map[page-1][x_div_2/5].tiles[y/11].block_number = tile_base + chr;
	//set_current_sprite (32);
	//if (page == _page)
	//	write_sprite_data((320-280)/2, 0, XZ, YZ, 63, 28, (const PTILEMAP)map[page-1]);
		
#if 0
  uint16_t  x = x_div_2 * 2;
  
	// fudge: fixme
	rectfill (pg[page-1], x, y, x+9, y+10, 0);
	draw_rle_sprite (pg[page-1], tile[chr], x, y);
#endif
}

void osd_draw_separator (uint8_t page, uint8_t byte, uint8_t y)
{  	
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
			map[0][tm].tiles[t].block_number = tile_base;
	set_current_sprite (page_sprite[0]);
	write_sprite_data(XOFF+0, 0, XZ, YZ, CLIP, 28, (const PTILEMAP)map[0]);

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
			map[0][tm].tiles[t].block_number = map[1][tm].tiles[t].block_number;
	set_current_sprite (page_sprite[0]);
	write_sprite_data(XOFF+0, 0, XZ, YZ, CLIP, 28, (const PTILEMAP)map[0]);
	
#if 0
  // fixme
	blit (pg[1], pg[0], 0, 0, 0, 0, 280, 176);
#endif
}

int osd_keypressed (void)
{
	return (poll_joystick(PORT1, READ_DIRECT) != 0);
}

void osd_delay (unsigned ms)
{
	unsigned t;
	
	for (t=0; t<4000; t++)
		;
#if 0
  rest (ms);
#endif
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
		case OSD_KEY_I :
			return ((port1 & JOY_UP) != 0);
		case OSD_KEY_J :
			return ((port1 & JOY_LEFT) != 0);
		case OSD_KEY_K :
			return ((port1 & JOY_DOWN) != 0);
		case OSD_KEY_L :
			return ((port1 & JOY_RIGHT) != 0);
		case OSD_KEY_U :
		case OSD_KEY_Z :
			return ((port1 & JOY_A) != 0);
		case OSD_KEY_O :
		case OSD_KEY_X :
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
  if (sprite >= 0 && sprite < 6)
  {
    stm.tiles[0].block_number = tile_base+chr;
    stm.tiles[0].attributes = 0;
    stm.tiles[1].block_number = tile_base;
    stm.tiles[1].attributes = 0;
    set_current_sprite (100+sprite);
    write_sprite_data (XOFF+x_div_2*2, y, XZ, YZ, 1, 1, (const PTILEMAP)&stm);
  }
#endif
  
#if 0
  // always page HGR1
	draw_rle_sprite (pg[0], tile[chr], x_div_2*2, y);
#endif
}

void osd_hgr (uint8_t page)
{
	change_sprite_pos (page_sprite[_page-1], XOFF, 255, 0);

	_page = page;
	//set_current_sprite (page_sprite[page-1]);
	//write_sprite_data(XOFF+0, 0, XZ, YZ, CLIP, 28, (const PTILEMAP)map[page-1]);

	change_sprite_pos (page_sprite[_page-1], XOFF, 0, CLIP);

	//textoutf(0, 27, 0, 0, "HGR=%d", page);
	
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
#if 0
	clear_keybuf ();
#endif
}

void osd_display_title_screen (uint8_t page)
{
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

int main (int argc, char *argv[])
{
	// transparent, orange, blue, white/green
  const uint8_t r[] = { 0x00>>3, 255>>3,  20>>3, 
  	#if defined(MONO) && defined(GREEN)
  											0
  	#else
  											255>>3 
  	#endif
  										};
  const uint8_t g[] = { 0x00>>3, 106>>3, 208>>3, 255>>3 };
  const uint8_t b[] = { 0x00>>3,  60>>3, 254>>3, 
  	#if defined(MONO) && defined(GREEN)
  											0
  	#else
  											255>>3 
  	#endif
  										};

	PALETTE 	pal;
	unsigned	c;
	unsigned 	m, tm, t, s;
	
	for (c=0; c<4; c++)
	{
		uint16_t	pe = 0;
						
		pe |= (r[c]&(1<<0)) << 14;
		pe |= (g[c]&(1<<0)) << 13;
		pe |= (b[c]&(1<<0)) << 12;
		pe |= (r[c]&0x1E) << 7;
		pe |= (g[c]&0x1E) << 3;
		pe |= (b[c]&0x1E) >> 1;
		
		pal.color[c] = pe;
	}
	setpalette(0, 1, (const PPALETTE)&pal);

	// build tilemaps
	for (m=0; m<2; m++)
	{
		for (tm=0; tm<28; tm++)
		{
			for (t=0; t<32; t++)
			{
				map[m][tm].tiles[t].block_number = tile_base+0;
				map[m][tm].tiles[t].attributes = 0;
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
      stm.tiles[t].attributes = 0;
    }
    set_current_sprite (100+s);
		write_sprite_data(0, 0, XZ, YZ, 1, 1, (const PTILEMAP)&stm);
  }
  
	while (1)
	{
		clear_fix();
		clear_spr();

		//textoutf (13, 20, 0, 0, "LODE RUNNER");
		//_vbl_count = 0;
		//wait_vbl();

		tile_base = 256;
		#ifndef MONO
			tile_base += 128;
		#endif
		
		_page = 0;
		
		lode_runner ();
	}
  
  return (0);
}
