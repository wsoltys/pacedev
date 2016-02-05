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

#include "src/kl/kl_dat.c"

#define N_SPR_ENTRIES (sizeof(sprite_tbl)/sizeof(uint8_t *))

#define REV(d) (((d&1)<<7)|((d&2)<<5)|((d&4)<<3)|((d&8)<<1)|((d&16)>>1)|((d&32)>>3)|((d&64)>>5)|((d&128)>>7))

#define SCRN_W    (2048/4)
#define SCRN_H    (1024/4)

static uint8_t  *c13 = NULL;

void put_ng_tile (unsigned t, unsigned x, unsigned y)
{
  for (int ty=0; ty<16; ty++)
  	for (int tx=0; tx<16; tx++)
  	{
  		int bit = t*64*8 + ty*2*8;
  		if (tx < 8) bit += 32*8;
  		uint8_t pel = (c13[(bit>>3)+1] >> (tx%8)) & 0x01;
  		pel = (pel << 1) | ((c13[(bit>>3)+0] >> (tx%8)) & 0x01);
      putpixel (screen, x+tx, y+ty, pel);
  	}
}

void show_ng_tiles (void)
{
	struct stat	    fs;
	int					    fd;

  FILE *fp = fopen ("202-c1.bin", "rb");
	if (!fp)
		return;
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		return;
  if ((c13 = (uint8_t *)malloc (fs.st_size)) == NULL)
    return;
  fread (c13, sizeof(uint8_t), fs.st_size, fp);
  fclose (fp);

  #define SPP (SCRN_H/64*SCRN_W/64/4)
  
  fprintf (stderr, "sprites/page = %d\n", SPP);
  
  for (unsigned b=0; b<2; b++)
  {
  	clear_bitmap (screen);
  
    for (unsigned y=0; y<SCRN_H/64; y++)
      for (unsigned x=0; x<SCRN_W/64; x++)
      {
        if (b*SPP+(y*(SCRN_W/48)+x)/4 >= N_SPR_ENTRIES)
          break;
          
        for (unsigned c=0; c<4; c++)
          for (unsigned r=0; r<4; r++)
          {
            unsigned t = 256 +      // BIOS
                         64 +       // font
                         SCRN_H/64*SCRN_W/64 * 16 * b +
                          y*(SCRN_W/64)*16 + x*16 + c*4 + r;
  					put_ng_tile (t, x*64+c*16, y*64+r*16);
          }
      }  
      
    if (b == 0)
      for (unsigned t=0; t<44; t++)
        put_ng_tile (256+t, 16+8*t, 16);
    
    while (!key[KEY_ESC]);	  
  	while (key[KEY_ESC]);	  
  }
  
  free (c13);
}

int main (int argc, char *argv[])
{
  int s;
  
  uint8_t widest = 0;
  uint8_t highest = 0;
  
  for (s=0; s<N_SPR_ENTRIES; s++)
  {
    uint8_t *psprite = sprite_tbl[s];
    
    uint8_t width = *(psprite++) & 0x3f;
    uint8_t height = *psprite;
    
    if (width > widest) widest = width;
    if (height > highest) highest = height;
  }

  // N_SPRITE_ENTRIES = 188  
  printf ("N_SPRITE_ENTIRES=%d\n", s);
  // widest = 5 (3 tiles), highest = 64 (4 tiles)
  printf ("widest=%d, highest=%d\n", widest, highest);
  
  // going to be quicker to define sprites for each entry
  // even if we are duplicating tiles of course
  // and also allocate 3x4=12 tiles for each sprite
  // actually 16 tiles will be quicker again  
  // so 188x16 = 3008 tiles (12 bits) (kiddy stuff for Neo Geo)

  static uint8_t zeroes[128];
  memset (zeroes, 0, 128);

  FILE *c1 = fopen ("202-c1.bin", "wb");  
  FILE *c2 = fopen ("202-c2.bin", "wb");  
  
	// copy 1st 256 characters from original file
	FILE *fp1 = fopen ("002-c1.c1", "rb");
	FILE *fp2 = fopen ("002-c2.c2", "rb");
	for (unsigned i=0; i<256*64; i++)
	{
		uint8_t	byte;
		
		fread (&byte, 1, 1, fp1);
		fwrite (&byte, 1, 1, c1);
		fread (&byte, 1, 1, fp2);
		fwrite (&byte, 1, 1, c2);
	}
	fclose (fp1);
	fclose (fp2);

  // now do the main font & days font
  // - needs to be a multiple of 16
  for (s=0; s<64; s++)
  {
    uint8_t *pfont;
    
    if (s < 40)
      pfont = kl_font[s];
    else if (s < 40+4)
      pfont = days_font[s-40];
    
    if (s < 40+4)
    {
      // quadrants 0,1
      fwrite (zeroes, sizeof(uint8_t), 2*2*8, c1);
      // quadrant 3 (has font data)
      for (unsigned l=0; l<8; l++)
      {
        uint8_t d = REV(pfont[l]);
        
        // colour = 3
        fwrite (&d, sizeof(uint8_t), 1, c1);
        fwrite (&d, sizeof(uint8_t), 1, c1);
      }
      // quadrant 3
      fwrite (zeroes, sizeof(uint8_t), 2*8, c1);
    }
    else
      fwrite (zeroes, sizeof(uint8_t), 64, c1);

    // c2
    fwrite (zeroes, sizeof(uint8_t), 64, c2);
  }
  
  #define F_VFLIP (1<<7)
  #define F_HFLIP (1<<6)
  
  for (s=0; s<N_SPR_ENTRIES; s++)
  {
    uint8_t *psprite = sprite_tbl[s];
    
    uint8_t c = *psprite & 0xc0;
    uint8_t w = *(psprite++) & 0x3f;
    uint8_t h = *(psprite++);

    if (c)
      printf ("*** WARNING %d flipped ($%02X)!\n", s, c);
      
    // 4 flip orientations
    for (int f=0; f<4; f++)
    {
      uint8_t vflip = (f&2 ? F_VFLIP : 0);
      uint8_t hflip = (f&1 ? F_HFLIP : 0);
      
      // construct 4x4 tile array
      for (int c=0; c<4; c++)
      {
        for (int r=0; r<4; r++)
        {
          if (c*2 >= w || r*16 >= h)
            fwrite (zeroes, 64, sizeof(uint8_t), c1);
          else
          {        
            // we have some sprite data
            for (unsigned q=0; q<4; q++)
            {
              // point to start of data
              uint8_t *p = psprite;
              if ((c & F_VFLIP) ^ vflip)
                p += ((r*16 + (q&1)*8)) *w*2;
              else
                p += (h-1-(r*16 + (q&1)*8)) *w*2;
              if ((c & F_HFLIP) ^ hflip)
                p += (2*(w-1))-(c*2*2 + 2-(q&2));
              else
                p += c*2*2 + 2-(q&2);
              for (unsigned l=0; l<8; l++)
              {
                // bitplane0 = mask
                // bitplane1 = colour
                // gives 4 colours but #2=#3
  
                if (c*2+1-((q&2)/2) >= w ||
                    r*16+(q&1)*8+l >= h)
                  fwrite (zeroes, sizeof(uint8_t), 2, c1);
                else
                {
                  uint8_t m = *(p+0);
                  uint8_t d = *(p+1);
                  if (!hflip)
                  {
                    m = REV(m);
                    d = REV(d);
                  }
                  fwrite (&m, sizeof(uint8_t), 1, c1);
                  fwrite (&d, sizeof(uint8_t), 1, c1);

                  if (vflip)
                    p += w*2;
                  else                                
                    p -= w*2;              
                }
              }
            }
          }
                
          // and always bitplanes 2,3
          fwrite (zeroes, sizeof(uint8_t), 64, c2);
        }
      }
    }
  }
  
  fclose (c1);
  fclose (c2);

  //FILE *spr = fopen ("PB_CHR.SPR", "wb");
  //fclose (spr);

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, SCRN_W, SCRN_H, 0, 0);

  int r[] = { 0x7F>>2, 0, 0xFF>>2, 0xFF>>2 };
  int g[] = { 0x7F>>2, 0, 0xFF>>2, 0xFF>>2 };
  int b[] = { 0x7F>>2, 0, 0xFF>>2, 0xFF>>2 };
  
  PALETTE pal;
  for (int c=0; c<16; c++)
  {
    pal[c].r = (c<4 ? r[c] : 0);
    pal[c].g = (c<4 ? g[c] : 0);
    pal[c].b = (c<4 ? b[c] : 0);
  }
	set_palette_range (pal, 0, 7, 1);

  show_ng_tiles ();
  
  allegro_exit ();
}

END_OF_MAIN();
