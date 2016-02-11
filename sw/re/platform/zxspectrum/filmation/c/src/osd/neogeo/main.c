#include <stdlib.h>
#include <video.h>
#include <input.h>

// osd stuff

#include "osd_types.h"
#include "kl_osd.h"

//
//  FIX LAYER
//  * BANK 3 - main menu border
//  - $00-$0F - top-left corner (4x4)
//  - $10-$1F - top-roght corner (4x4)
//  - $20-$2F - bottom-left corner (4x4)
//  - $30-$3F - bottom-righter corner (4x4)
//  - $40-$42 - top/bottom (1x3)
//  - $44-$46 - left/right (3x1)
//  * BANK 4 - Knight Lore font and "DAY" font
//  - $00-$03 - "DAY"
//  - various - ASCII characters
//  * BANK 5 - panel
//  - $00-$FF - panel characters for bottom 8 lines
//              in display order
//  * BANKS 6-8 - title screen
//  - +672 characters in display order
//
//  SPRITES
//  -   0-255 - system reserved
//  -     +64 - +40 - Kinight Lore font
//              +4  - "DAY"
//  -   188*16*4 - 188 graphics sprites
//  -         - each sprite is 16 tiles
//  -         - 4 copies of each (h/v-flipped)


#define DIP_COLOUR      0
#define DIP_MONO        1
#define DIP_MONO_GREEN  0
#define DIP_MONO_WHITE  1

#define FIX_XOFF        ((40-(256/8))/2)
#define FIX_YOFF        ((32-(192/8))/2)
#define SPR_XOFF        (FIX_XOFF*8)
#define SPR_YOFF        (FIX_YOFF*8)-16

extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

void osd_delay (unsigned ms)
{
	while (ms--)
	{
		unsigned t;

		//for (t=0; t<512; t++)
		for (t=0; t<256; t++)
			;
	}
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
    case OSD_KEY_1 :
      return (joy1 & JOY_B);
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

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t attr, uint8_t code)
{
  // only ever called to print numbers
  // - bank 4 for Knight Lore / DAYS fonts
  
  volatile uint16_t  *vram = (uint16_t *)0x3C0000;
  *vram = 0x7000+((FIX_XOFF+x/8)*32)+(FIX_YOFF+(191-y)/8);
  *(vram+2) = 32;
  *(vram+1) = 0x0400 | ((attr&7)<<12) | code;
  
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

void osd_print_sprite (uint8_t attr, POBJ32 p_obj)
{
  static TILEMAP obj_map[3];
  unsigned n, c, t;

  #if 0
  {  
    char buf[64];
    
    sprintf (buf, "OBJ=%03d, SPR=%02d, Y=%03d", 
              p_obj->graphic_no, p_obj->hw_sprite, p_obj->pixel_y);
    if (p_obj->hw_sprite == 0)
      textoutf (0, 0, 0, 0, buf);
    else
      textoutf (0, p_obj->hw_sprite-40, 0, 0, buf);
  }
  #endif

  n = 256 + 64 + (unsigned)(p_obj->graphic_no)*4*16;
  if (p_obj->flags7 & (1<<7))
    n += 2*16;
  if (p_obj->flags7 & (1<<6))
    n += 1*16;

  // setup sprite
  attr &= 7;
  for (c=0; c<3; c++)
    for (t=0; t<4; t++)
    {
      obj_map[c].tiles[t].block_number = n+c*4+t;
      obj_map[c].tiles[t].attributes = (16+attr)<<8;
    }

  set_current_sprite (p_obj->hw_sprite*3);
  write_sprite_data (SPR_XOFF + p_obj->pixel_x, 
                      SPR_YOFF+191-(p_obj->pixel_y+p_obj->data_height_lines-1),
                      0x0f, 0xff, 4, 3, obj_map);
}

void osd_print_border (void)
{
  volatile uint16_t  *vram = (uint16_t *)0x3C0000;

  #define BANK 0x0300
  
  unsigned c, r;
  // this is set by the clear_scrn function
  unsigned attr = 6;  // yellow

  for (c=0; c<32; c++)
  {
    for (r=0; r<24; r++)
    {
	    *vram = 0x7000 + (FIX_XOFF+c)*32 + FIX_YOFF+r;
	    
	    if (c < 4)
      {
	      if (r < 4)
	        *(vram+1) = BANK | (attr<<12) | ((c%4)*4+r);
	      else if (r < 20)
	        *(vram+1) = BANK | (attr<<12) | (0x44+(c%4));
	      else
	        *(vram+1) = BANK | (attr<<12) | (32+(c%4)*4+(r-20));
	    }
	    else if (c < 28)
      {
        if (r < 3)
	        *(vram+1) = BANK | (attr<<12) | (0x40+r);
	      else if (r >= 21)
	        *(vram+1) = BANK | (attr<<12) | (0x40+r-21);
      }
      else
      {
	      if (r < 4)
	        *(vram+1) = BANK | (attr<<12) | (16+(c%4)*4+r);
	      else if (r < 20)
	        *(vram+1) = BANK | (attr<<12) | (0x43+(c%4));
	      else
	        *(vram+1) = BANK | (attr<<12) | (48+(c%4)*4+(r-20));
      }
    }
  }
}

void osd_display_panel (uint8_t attr)
{
  volatile uint16_t  *vram = (uint16_t *)0x3C0000;
  unsigned c;
  uint8_t a;

  // show the scrolls and the sun/moon frame
  *(vram+2) = 32;
  for (c=0; c<256; c++)
  {
    // the sun/moon frame is RED
    // - I don't understand (c/32)>3 but it works...
    a = ((c/32)>3 && (c%32)>22 && (c%32)<29 ? 2 : attr);
    if ((c%32) == 0)
	    *vram = 0x7000+(FIX_XOFF*32)+(FIX_YOFF+16)+(c/32);
    *(vram+1) = 0x0500 | ((a&7)<<12) | c;
  }
}

void osd_debug_hook (void *context)
{
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

static void show_title (void)
{
  volatile uint16_t  *vram = (uint16_t *)0x3C0000;
  uint16_t bank = 0x0600;
  unsigned r, c;
  
  for (r=0; r<21; r++)
  {
    *vram = 0x7000 + FIX_XOFF*32 + FIX_YOFF + r;
    *(vram+2) = 32;
    bank = 0x0600 + ((r/8)<<8);    
    for (c=0; c<32; c++)
      *(vram+1) = bank | (0x000f<<12) | ((r%8)*32 + c);
  }
  
  for (c=0; c<10000/16; c++)
  {
    wait_vbl ();

    if (poll_joystick (PORT1, READ_DIRECT))
    {
      while (poll_joystick (PORT1, READ_DIRECT));
      break;
    }
  }
}

int main (int argc, char *argv[])
{
  //uint8_t *dips = (uint8_t *)0x10FD84;
  
  //uint8_t colour_mono = *(dips+6);
  //uint8_t mono_colour = *(dips+7);

	PALETTE 	pal[8];
	unsigned	p, c;

  // map palettes 0-7 with bright colours
	for (p=0; p<8; p++)
	{	
		for (c=0; c<4; c++)
		{
			uint16_t	pe = 0;
	    uint8_t r, g, b;
	
	    if (c < 2)
        r = g = b = 0;
      else
      {
  	    r = (p&(1<<1) ? (0xFF>>3) : 0x00);
  	    g = (p&(1<<2) ? (0xFF>>3) : 0x00);
  	    b = (p&(1<<0) ? (0xFF>>3) : 0x00);
      }
      
  		pe |= (r&(1<<0)) << 14;
  		pe |= (r&0x1E) << 7;
  		pe |= (b&(1<<0)) << 12;
  		pe |= (b&0x1E) >> 1;
			pe |= (g&(1<<0)) << 13;
			pe |= (g&0x1E) << 3;

			pal[p].color[c] = pe;
		}
	}
	// set palette banks for FIX layer
	setpalette(0, 8, (const PPALETTE)&pal);
	// set palette banks for SPRITE layer
	setpalette(16, 8, (const PPALETTE)&pal);

  // set full spectrum palette
	for (p=0; p<1; p++)
	{	
		for (c=0; c<16; c++)
		{
			uint16_t	pe = 0;
	    uint8_t r, g, b;

	    r = (c&(1<<1) ? ((c < 8) ? (0xCD>>3) : (0xFF>>3)) : 0x00);
	    g = (c&(1<<2) ? ((c < 8) ? (0xCD>>3) : (0xFF>>3)) : 0x00);
	    b = (c&(1<<0) ? ((c < 8) ? (0xCD>>3) : (0xFF>>3)) : 0x00);
	    
  		pe |= (r&(1<<0)) << 14;
  		pe |= (r&0x1E) << 7;
  		pe |= (b&(1<<0)) << 12;
  		pe |= (b&0x1E) >> 1;
			pe |= (g&(1<<0)) << 13;
			pe |= (g&0x1E) << 3;

			pal[p].color[c] = pe;
		}
	}
	// FIX layer title screen
	setpalette(15, 1, (const PPALETTE)&pal);

	while (1)
	{
    //eye_catcher ();

		clear_fix();
		clear_spr();
		
    show_title ();
		clear_fix();

		_vbl_count = 0;
		knight_lore ();

		while (1);
	}
  
  return (0);
}

