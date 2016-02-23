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
//  * BANKS 6-8 - ZX title screen
//  - +672 characters in display order
//  * BANKS 9-10 - CPC title screen
//  - +432 (18x24) characters in display order
//
//  SPRITES
//  -   0-255 - system reserved
//  -   $0100-$2FFF ZX graphics
//  -   188*16*4 - 188 graphics sprites
//  -         - each sprite is 16 tiles
//  -         - 4 copies of each (h/v-flipped)
//  -   $3000-$30FF - unused
//  -   #3100-$XXXX CPC graphics


#define DIP_COLOUR      0
#define DIP_MONO        1
#define DIP_MONO_GREEN  0
#define DIP_MONO_WHITE  1

#define FIX_XOFF        ((40-(256/8))/2)
#define FIX_YOFF        ((32-(192/8))/2)
#define SPR_XOFF        (FIX_XOFF*8)
#define SPR_YOFF        (FIX_YOFF*8)-16

extern void knight_lore (GFX_E gfx_);
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

  if (IS_ROOM_ATTR(attr))
    attr = 8+4+(attr&3);
  else    
    attr &= 7;

  *vram = 0x7000+((FIX_XOFF+x/8)*32)+(FIX_YOFF+(191-y)/8);
  *(vram+2) = 32;
  *(vram+1) = 0x0400 | (attr<<12) | code;
  
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

static uint16_t sprite_bank;

void osd_print_sprite (uint8_t attr, POBJ32 p_obj)
{
  static TILEMAP obj_map[3];
  unsigned n, c, t;
  unsigned sw = (p_obj->data_width_bytes+1)/2;
  unsigned sh = (p_obj->data_height_lines+15)/16;

  // data_width_bytes may already be 1 byte wider
  // but max width for Knight Lore is 5
  // ((5+1)+1)/2 = 3
  // - so no need to check

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

  uint8_t *psprite = flip_sprite (p_obj);

  n = sprite_bank + (unsigned)(p_obj->graphic_no)*4*16;
  if (p_obj->flags7 & (1<<7))
    n += 2*16;
  if (p_obj->flags7 & (1<<6))
    n += 1*16;

  // setup sprite
  if (gfx == GFX_ZX)
    attr &= 7;
  else
    attr &= 3;
  
  for (c=0; c<sw; c++)
    for (t=0; t<sh; t++)
    {
      obj_map[c].tiles[t].block_number = n+c*4+t;
      obj_map[c].tiles[t].attributes = (16+attr)<<8;
    }

  set_current_sprite (p_obj->hw_sprite*3);
  write_sprite_data (SPR_XOFF + p_obj->pixel_x, 
                      SPR_YOFF+191-(p_obj->pixel_y+p_obj->data_height_lines-1),
                      0x0f, 0xff, sh, sw, obj_map);
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

  if (IS_ROOM_ATTR(attr))
    attr = 8+(attr&3);
  else    
    attr &= 7;

  wait_vbl ();
    
  // show the scrolls and the sun/moon frame
  *(vram+2) = 32;
  for (c=0; c<256; c++)
  {
#if 1
    if (gfx == GFX_ZX)
      // the sun/moon frame is RED
      a = ((c/32)>3 && (c%32)>22 && (c%32)<29 ? 2 : attr);
    else if (gfx == GFX_CPC)
      a = ((c/32)>3 && (c%32)>22 && (c%32)<29 ? attr : 4+attr);
#endif
    if ((c%32) == 0)
	    *vram = 0x7000+(FIX_XOFF*32)+(FIX_YOFF+16)+(c/32);
    *(vram+1) = 0x0500 | (a<<12) | c;
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

static void make_zx_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  *r = (c&(1<<1) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
  *g = (c&(1<<2) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
  *b = (c&(1<<0) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
}

static void make_cpc_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  uint8_t lu[] = { 0, 128, 255 };
  
  *r = lu[(c/3) % 3];
  *g = lu[(c/9) % 3];
  *b = lu[c % 3];
}

static uint16_t make_ng_colour (uint8_t r, uint8_t g, uint8_t b)
{
  uint16_t pe = 0;
  
  r >>= 3;
  g >>= 3;
  b >>= 3;
  
	pe |= (r&(1<<0)) << 14;
	pe |= (r&0x1E) << 7;
	pe |= (b&(1<<0)) << 12;
	pe |= (b&0x1E) >> 1;
	pe |= (g&(1<<0)) << 13;
	pe |= (g&0x1E) << 3;

  return (pe);
}

static void show_zx_title (void)
{
  volatile uint16_t  *vram = (uint16_t *)0x3C0000;
	PALETTE 	pal[1];
  uint16_t bank = 0x0600;
  unsigned p, r, c;
  
  // set full spectrum palette
	for (c=0; c<16; c++)
	{
    uint8_t r, g, b;

    make_zx_colour(c, &r, &g, &b);
		pal[0].color[c] = make_ng_colour (r, g, b);
	}
	setpalette(15, 1, (const PPALETTE)&pal);

  for (r=0; r<21; r++)
  {
    *vram = 0x7000 + FIX_XOFF*32 + FIX_YOFF + r;
    *(vram+2) = 32;
    bank = 0x0600 + ((r/8)<<8);    
    for (c=0; c<32; c++)
      *(vram+1) = bank | (15<<12) | ((r%8)*32 + c);
  }
}

static void show_cpc_title (void)
{
  volatile uint16_t  *vram = (uint16_t *)0x3C0000;
	PALETTE 	pal[1];
  uint16_t bank = 0x0900;
  unsigned p, r, c, t;
  
  // set full spectrum palette
	for (c=0; c<4; c++)
	{
	  static const uint8_t cpc_pal[] =
	  {
      // black, orange, yellow, red
      0, 24, 6, 15
    };
    uint8_t r, g, b;

    make_cpc_colour(cpc_pal[c%4], &r, &g, &b);
		pal[0].color[c] = make_ng_colour (r, g, b);
	}
	setpalette(15, 1, (const PPALETTE)&pal);

  for (t=0, r=0; r<24; r++)
  {
    *vram = 0x7000 + (FIX_XOFF+7)*32 + FIX_YOFF + r;
    *(vram+2) = 32;
    for (c=0; c<18; c++, t++)
    {
      if ((t&0xff) == 0)
        bank = 0x0900 + t;    
      *(vram+1) = bank | (15<<12) | (t&0xff);
    }
  }
}

static void init_gfx (GFX_E gfx)
{
	PALETTE 	pal[8];
	unsigned	p, c;

  // *all* graphics modes
  // - map original spectrum palette (bright only)
  //   to palettes 0-7
  // - 0=transparent, 1,3=colour, 2=black
  // - for menu etc
	for (p=0; p<8; p++)
		for (c=0; c<4; c++)
		{
	    uint8_t r, g, b;
	
	    if (c != 1)
        r = g = b = 0;
      else
        make_zx_colour(8+p, &r, &g, &b);
      
			pal[p].color[c] = make_ng_colour (r, g, b);
		}
	// set palette banks for FIX layer
	setpalette(0, 8, (const PPALETTE)&pal);
	
  sprite_bank = 0x0100;
  
	if (gfx == GFX_ZX)
  {
    // 2nd set of FIX layer
    // - for curr_room_attrib
	  setpalette(8, 8, (const PPALETTE)&pal);
    // set palette banks for SPRITE layer
  	for (p=0; p<8; p++)
  		for (c=0; c<4; c++)
  		{
  	    uint8_t r, g, b;
  	
  	    if (c == 0 || c == 2)
          r = g = b = 0;
        else
          make_zx_colour(8+p, &r, &g, &b);
        
  			pal[p].color[c] = make_ng_colour (r, g, b);
  		}
	  setpalette(16, 8, (const PPALETTE)&pal);
	}
  else
  if (gfx == GFX_CPC)
  {
    // not used
    const uint8_t menu_pal[] =
    {
      // yellow, blue, white
      0, 24, 2, 26
    };

    const uint8_t room_pal[][4] =
    {    
      // orange, yellow, white
      { 0, 15, 24, 26 },
      // green, cyan, magenta
      { 0, 18, 20, 8 },
      // blue, cyan, yellow
      { 0, 2, 20, 24 },
      // red, yellow, white
      { 0, 6, 24, 26 }
    };

    // (room attrib table)	  
	  for (p=0; p<8; p++)
	  {
	    for (c=0; c<4; c++)
	    {
        uint8_t r, g, b;
        uint8_t i = c;

        if (c == 3)
          i = 0;
        else if (p > 3)
          i = (c == 1 ? 3 : i);
          
        make_cpc_colour(room_pal[p&3][i], &r, &g, &b);
    		pal[p].color[c] = make_ng_colour (r, g, b);
	    }
	  }
    // 2nd set of FIX layer
    // - for curr_room_attrib
    // - 1st 4: black, col1, col2, black
    // - 2nd 4: black, col3, col2, black
	  setpalette(8, 8, (const PPALETTE)&pal);
    // set palette banks for SPRITE layer
	  setpalette(16, 8, (const PPALETTE)&pal);

    sprite_bank |= 0x4000;
  }
}

int main (int argc, char *argv[])
{
  uint8_t *dips = (uint8_t *)0x10FD84;
  GFX_E gfx = (*(dips+6) ? GFX_ZX : GFX_CPC);

	while (1)
	{
	  unsigned c;
	  
    //eye_catcher ();

		clear_fix();
		clear_spr();

    if (gfx == GFX_ZX)
      show_zx_title ();
    else
    if (gfx == GFX_CPC)
      show_cpc_title ();

    for (c=0; c<10000/16; c++)
    {
      wait_vbl ();
  
      if (poll_joystick (PORT1, READ_DIRECT))
      {
        while (poll_joystick (PORT1, READ_DIRECT));
        break;
      }
    }
		clear_fix();

    // needs to be done _after_ show_XX_title
    // because it resets palette
    init_gfx (gfx);
        
		_vbl_count = 0;
		knight_lore (gfx);

		while (1);
	}
  
  return (0);
}

