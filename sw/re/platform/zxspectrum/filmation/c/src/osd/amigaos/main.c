
// osd stuff

#include "osd_types.h"
#include "kl_osd.h"

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
}

int osd_keypressed (void)
{
	#if 0
  return (keypressed ());
	#endif
}

int osd_readkey (void)
{
	#if 0
  return (readkey ());
	#endif
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

		knight_lore ();
	}
  
  return (0);
}
