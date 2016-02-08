#include <stdlib.h>
#include <video.h>
#include <input.h>


// osd stuff

#include "osd_types.h"
#include "kl_osd.h"

//TILEMAP obj_map[188][4][3];
TILEMAP obj_map[40][3];

const unsigned page_sprite[3] = { 32, 64, 96 };

#define DIP_COLOUR      0
#define DIP_MONO        1
#define DIP_MONO_GREEN  0
#define DIP_MONO_WHITE  1

#define XOFF            ((320-256)/2)
#define YOFF            ((224-192)/2)
#define XZ	            15
#define YZ	            255
#define CLIP            16
#define NEO_SPRITE(s)   (128+(s))

#define ENABLE_MASK

extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

void osd_delay (unsigned ms)
{
  wait_vbl ();
  wait_vbl ();
  wait_vbl ();
}

void osd_clear_scrn (void)
{
  // nothing to do here
}

void osd_clear_scrn_buffer (void)
{
	clear_fix();
	clear_spr();
}

int osd_key (int _key)
{
  uint16_t joy1 = poll_joystick (PORT1, READ_DIRECT);
  
  switch (_key)
  {
    case OSD_KEY_0 :
      // start & pickup/drop
      return (joy1 & (JOY_START|JOY_B));
    case OSD_KEY_Z :
      return (joy1 & JOY_LEFT);
    case OSD_KEY_X :
      return (joy1 & JOY_RIGHT);
    case OSD_KEY_A :
      return (joy1 & JOY_UP);
    case OSD_KEY_Q :
      // jump
      return (joy1 & JOY_A);
    default :
      break;
  }
	return (0);
}

int osd_keypressed (void)
{
  uint16_t joy1 = poll_joystick (PORT1, READ_DIRECT);

  return (joy1 != 0);
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
  char      buf[32];
  unsigned  i = 0;

  do
  {  
    buf[i++] = (*str & 0x7f) + 1;

  } while ((*(str++) & 0x80) == 0);
  buf[i] = '\0';
  
  textout ((XOFF+x)/8, (YOFF+(191-y))/8, 0, 4, buf);
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
  // only ever printed from the std font
  // - bank 4 for Knight Lore font
  textout ((XOFF+x)/8, (YOFF+(191-y))/8, 0, 4, str);
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t code)
{
  // only ever called to print numbers
  
  static char buf[2] = " ";
  
  buf[0] = '0'+code;
  textout ((XOFF+x)/8, (YOFF+(191-y))/8, 0, 4, buf);

  return (x+8);
}

void osd_fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c)
{
  // nothing to do here
}

void osd_update_screen (void)
{
  // nothing to do here
}

void osd_blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines)
{
  // nothing to do here
}

void osd_print_sprite (uint8_t type, POBJ32 p_obj)
{
  static TILEMAP obj_map[3];

  char buf[64];
  unsigned n, c, t;

  if (0)
  {  
    sprintf (buf, "OBJ=%03d, SPR=%02d, Y=%03d", 
              p_obj->graphic_no, p_obj->unused[0], p_obj->pixel_y);
    if (p_obj->unused[0] == 0)
      textoutf (0, 0, 0, 0, buf);
    else
      textoutf (0, p_obj->unused[0]-40, 0, 0, buf);
  }

  if (type == PANEL_STATIC)
  {
    static uint8_t buf[64];
    
    unsigned r, c;
    
    if (p_obj->graphic_no != 0x86 || p_obj->pixel_x != 0x10)
      return;
    for (r=0; r<8; r++)
    {
      for (c=0; c<32; c++)
        buf[c] = r * 0x20 + c;
      buf[c] = '\0';
      if (r == 0)
        buf[0] = ' ';
      textout (XOFF/8+0, YOFF/8+16+r, 0, 5, (const char *)buf);
    }
    return;
  }
        
  if (type != DYNAMIC && type != PANEL_DYNAMIC)
    return;

  n = 256 + 64 + (unsigned)(p_obj->graphic_no)*4*16;
  if (p_obj->flags7 & (1<<7))
    n += 2*16;
  if (p_obj->flags7 & (1<<6))
    n += 1*16;

  // setup sprite
  for (c=0; c<3; c++)
    for (t=0; t<4; t++)
    {
      obj_map[c].tiles[t].block_number = n+c*4+t;
      obj_map[c].tiles[t].attributes = 16<<8;
    }

  set_current_sprite (p_obj->unused[0]*3);
  write_sprite_data (XOFF + p_obj->pixel_x, 
                      YOFF+191-(p_obj->pixel_y+p_obj->data_height_lines-1),
                      0x0f, 0xff, 4, 3, obj_map);
}

void eye_catcher (void)
{
  // display some eye-catcher stuff
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

int main (int argc, char *argv[])
{
  uint8_t *dips = (uint8_t *)0x10FD84;
  
  uint8_t colour_mono = *(dips+6);
  uint8_t mono_colour = *(dips+7);

	// transparent, black, white, white
  const uint8_t r[] = { 0x00>>3, 0x00>>3, 0xff>>3, 0xff>>3 };
  const uint8_t g[] = { 0x00>>3, 0x00>>3, 0xff>>3, 0xff>>3 };
  const uint8_t b[] = { 0x00>>3, 0x00>>3, 0xff>>3, 0xff>>3 };

	PALETTE 	pal[2];
	unsigned	p, c;
	unsigned 	o, f, t;
	unsigned  n;

	for (p=0; p<2; p++)
	{	
		for (c=0; c<4; c++)
		{
			uint16_t	pe = 0;
	
  		pe |= (r[c]&(1<<0)) << 14;
  		pe |= (r[c]&0x1E) << 7;
  		pe |= (b[c]&(1<<0)) << 12;
  		pe |= (b[c]&0x1E) >> 1;
			pe |= (g[c]&(1<<0)) << 13;
			pe |= (g[c]&0x1E) << 3;

			pal[p].color[c] = pe;
		}
	}
	setpalette(0, 2, (const PPALETTE)&pal);
	setpalette(16, 2, (const PPALETTE)&pal);

  // build 40 sprites
  for (o=0; o<40; o++)
    //for (f=0; f<4; f++)
      for (c=0; c<3; c++)
        for (t=0; t<4; t++)
        {
          obj_map[o][c].tiles[t].block_number =
            256 + 64 + o*4*16 + c*4 + t;
          obj_map[o][c].tiles[t].attributes = 16<<8;
        }
  
	while (1)
	{
		clear_fix();
		clear_spr();

    //eye_catcher ();
    
		//textoutf (13, 16, 0, 0, "KNIGHT LORE");
		_vbl_count = 0;
		wait_vbl();

#if 0
    for (o=0; o<40; o++)
    {
      set_current_sprite (o*3);
	    write_sprite_data (
	      (o%8)*40, (o/8)*48, 0x0f, 0x0ff, 
	      4, 3, (const PTILEMAP)obj_map[o]);
    }

    while (1);
#endif    

		knight_lore ();
		while (1);
	}
  
  return (0);
}

