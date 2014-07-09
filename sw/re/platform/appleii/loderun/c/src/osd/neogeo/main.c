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
  	
  	// and finally the sprites
  	for (s=0; s<6; s++)
  	  change_sprite_pos (NEO_SPRITE(s), 0, 255, 0);
  }
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
	return (poll_joystick(PORT1, READ_DIRECT) != 0);
}

void osd_delay (unsigned ms)
{
	unsigned t;
	
	for (t=0; t<8000; t++)
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
  if (sprite < 0)
    osd_display_char_pg (1, chr, x_div_2, y);
  else
  {
    stm.tiles[0].block_number = tile_base+chr;
    stm.tiles[0].attributes = 0;
    stm.tiles[1].block_number = tile_base;
    stm.tiles[1].attributes = 0;
    set_current_sprite (NEO_SPRITE(sprite));
    write_sprite_data (XOFF+x_div_2*2, YOFF+y, XZ, YZ, 1, 1, (const PTILEMAP)&stm);
  }
#endif
  
#if 0
  // always page HGR1
	draw_rle_sprite (pg[0], tile[chr], x_div_2*2, y);
#endif
}

void osd_hgr (uint8_t page)
{
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
	while (poll_joystick(PORT1, READ_DIRECT) != 0)
	  ;
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
  uint8_t *dips = (uint8_t *)0x10FD84;
  
  uint8_t colour_mono = *(dips+6);
  uint8_t mono_colour = *(dips+7);

	// transparent, orange, blue, white/green
  const uint8_t r[] = { 0x00>>3, 255>>3,  20>>3, 255>>3 };
  const uint8_t g[] = { 0x00>>3, 106>>3, 208>>3, 255>>3 };
  const uint8_t b[] = { 0x00>>3,  60>>3, 254>>3, 255>>3 };

	PALETTE 	pal;
	unsigned	c;
	unsigned 	m, tm, t, s;
	
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
  		
		pal.color[c] = pe;
	}
	setpalette(0, 1, (const PPALETTE)&pal);

	// build tilemaps
	for (m=0; m<3; m++)
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
    set_current_sprite (NEO_SPRITE(s));
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
    if (colour_mono == DIP_COLOUR)
			tile_base += 128;
		
		lode_runner ();
	}
  
  return (0);
}
