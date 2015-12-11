//#include <stdlib.h>

// osd stuff

#include "osd_types.h"
#include "lr_osd.h"

extern const uint8_t tile_data_m2bpp[];
extern const uint8_t tile_data_c2bpp[];
extern const uint8_t title_data_m2bpp[];
extern const uint8_t title_data_c2bpp[];

extern void lode_runner (void);

void osd_gcls (uint8_t page)
{
}

void osd_display_char_pg (uint8_t page, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
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
#if 0
  // fixme
  rectfill (pg[0], 0, 0, 279, 175, 0);
#endif
}

void osd_draw_circle (void)
{
#if 0
  // fixme
	blit (pg[1], pg[0], 0, 0, 0, 0, 280, 176);
#endif
}

int osd_keypressed (void)
{
	return (0);
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
#if 0
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
#endif	
	return (0);
}

void osd_wipe_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
#if 0
	// quick hack for now
	blit (pg[1], pg[0], x_div_2*2, y, x_div_2*2, y, 10, 11);
#endif
}

void osd_display_transparent_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y)
{
#if 0
  // always page HGR1
	draw_rle_sprite (pg[0], tile[chr], x_div_2*2, y);
#endif
}

void osd_hgr (uint8_t page)
{
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
#if 0
  TILEMAP stm[7];
  unsigned tm;

  for (tm=0; tm<7; tm++)
  {
    stm[tm].tiles[0].block_number = tile_base+512+frame*8+tm;
    stm[tm].tiles[0].attributes = (1<<8)|0;
  }
  set_current_sprite (NEO_SPRITE(6)+tm);
	write_sprite_data(XOFF+13*7-4, YOFF+80, 15, 255, 1, 7, (const PTILEMAP)stm);
#endif
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
	#if 0
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
	setpalette(0, 2, (const PPALETTE)&pal);
#endif

	while (1)
	{
		//textoutf (13, 20, 0, 0, "LODE RUNNER");

		lode_runner ();
	}
  
  return (0);
}
