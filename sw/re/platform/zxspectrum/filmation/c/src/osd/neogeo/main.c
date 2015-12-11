#include <stdlib.h>
#include <video.h>
#include <input.h>


// osd stuff

#include "osd_types.h"
#include "kl_osd.h"

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

#define ENABLE_MASK


extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

void osd_cls (void)
{
	#if 0
	clear_bitmap (screen);
	#endif
}

void osd_delay (unsigned ms)
{
	#if 0
  rest (ms);
	#endif
}

int osd_key (int _key)
{
	#if 0
  return (key[_key]);
	#endif
	return (0);
}

int osd_keypressed (void)
{
	#if 0
  return (keypressed ());
	#endif
	return (0);
}

int osd_readkey (void)
{
	#if 0
  return (readkey ());
	#endif
	return (0);
}

void osd_print_text_raw (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t *str)
{
	#if 0
  unsigned c, l, b;
  
  for (c=0; ; c++, str++)
  {
    uint8_t code = *str & 0x7f;

    for (l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      
      for (b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (screen, x+c*8+b, 191-y+l, 15);
        d <<= 1;
      }
    }  
    if (*str & (1<<7))
      break;
  }
	#endif
}

static uint8_t from_ascii (char ch)
{
  const char *chrset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
  uint8_t i;
  
  for (i=0; chrset[i]; i++)
    if (chrset[i] == ch)
      return (i);
      
    return ((uint8_t)-1);
}

void osd_print_text (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, char *str)
{
	#if 0
  unsigned c, l, b;
  
  for (c=0; *str; c++)
  {
    uint8_t ascii = (uint8_t)*(str++);
    uint8_t code = from_ascii (ascii);
    
    for (l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      if (d == (uint8_t)-1)
        break;
      
      for (b=0; b<8; b++)
      {
        if (d & (1<<7))
          putpixel (screen, x+c*8+b, 191-y+l, 15);
        d <<= 1;
      }
    }  
  }
	#endif
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t code)
{
	#if 0
  unsigned l, b;
  
  for (l=0; l<8; l++)
  {
    uint8_t d = gfxbase_8x8[code*8+l];
    if (d == (uint8_t)-1)
      break;
    
    for (b=0; b<8; b++)
    {
      if (d & (1<<7))
        putpixel (screen, x+b, 191-y+l, 15);
      d <<= 1;
    }
  }  
	#endif
  return (x+8);
}

void osd_print_sprite (POBJ32 p_obj)
{
	#if 0
  uint8_t *psprite;

  //DBGPRINTF("(%d,%d)\n", p_obj->x, p_obj->y);

  // references p_obj
  psprite = flip_sprite (p_obj);

  uint8_t w = *(psprite++) & 0x3f;
  uint8_t h = *(psprite++);

  unsigned x, y, b;
  
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      uint8_t m = *(psprite++);
      uint8_t d = *(psprite++);
      for (b=0; b<8; b++)
      {
#ifdef ENABLE_MASK
        if (m & (1<<7))
          putpixel (screen, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y), 0);
#endif
        if (d & (1<<7))
          putpixel (screen, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y), 15);
        m <<= 1;
        d <<= 1;
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
		if (0)
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

			static const uint16_t SNK[3][10] = 
			{
				{ 0x200, 0x201, 0x202, 0x203, 0x204, 0x205, 0x206, 0x207, 0x208, 0x209 },
				{ 0x20A, 0x20B, 0x20C, 0x20D, 0x20E, 0x20F, 0x214, 0x215, 0x216, 0x217 },
				{ 0x218, 0x219, 0x21A, 0x21B, 0x21C, 0x21D, 0x21E, 0x21F, 0x240, 0x25E }
			};
			
			static const uint16_t eye_catcher_pal[] = 
			{
				0x0000, 0x0fff, 0x0ddd, 0x0aaa, 0x7555, 0x306E, 0x0000, 0x0000,
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

      addr = 0x71F6;
			for (n=0; n<3*10; n++)
			{
			  *vram = addr;
			  *(vram+1) = 0xF000 | SNK[n/10][n%10];
		    addr += 32;
			  if ((n%10) == 9)
			    addr += - 10*32 + 1;
			}
			
			// (C)
			addr = 0x7469;
			*vram = addr;
			*(vram+1) = 0xF000 | 0x7B;
		}
				
		textoutf (13, 20, 0, 0, "KNIGHT LORE");
		_vbl_count = 0;
		wait_vbl();

		tile_base = 256;
    if (colour_mono == DIP_COLOUR)
			tile_base += 640;

		knight_lore ();
	}
  
  return (0);
}

