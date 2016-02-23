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

#define __FORCE_RODATA__

#include "src/kl/kl_dat.c"

#define DRIVER    "legendos"
#define GUID      "029"

//#define SHOW_TILES

#define N_ZX_SPR_ENTRIES    188
#define N_CPC_SPR_ENTRIES   194

#define REV(d) (((d&1)<<7)|((d&2)<<5)|((d&4)<<3)|((d&8)<<1)|((d&16)>>1)|((d&32)>>3)|((d&64)>>5)|((d&128)>>7))
#define NIBREV(d) (((d&1)<<3)|((d&2)<<1)|((d&4)>>1)|((d&8)>>3))

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
  		
  		static unsigned lu[] = { 0, 4, 5, 0 };
  		unsigned c = lu[pel];
      putpixel (screen, x+tx, y+ty, 8+c);
  	}
}

void show_ng_tiles (void)
{
	struct stat	    fs;
	int					    fd;

  FILE *fp = fopen (GUID "-c3.bin", "rb");
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
        if (b*SPP+(y*(SCRN_W/48)+x)/4 >= N_ZX_SPR_ENTRIES)
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

static uint8_t from_ascii (char ch)
{
  const char *chrset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.@ %";
  uint8_t i;
  
  for (i=0; chrset[i]; i++)
    if (chrset[i] == ch)
      return (i);
      
    return ((uint8_t)-1);
}

static uint8_t zeroes[128];

#include "border_font.c"
#include "panel_font.c"
#include "title_font.c"

void do_fix (void)
{
  // bank 3 (70 chars)
  // $00-$47 - main menu border
  // bank 4 (char $0x400-$0x4ff)
  // $00-$03 - "DAYS"
  // $04-$FF - ascii-based font
  // bank 5 (256 chars)
  // panel data
  // bank 6-8 (768 chars)
  // title screen
  
  unsigned c;
  unsigned i;

  // open FIX and copy 1st 3 banks
  // - needs to be patched wth "RETRO PORTS first!!!
  
  FILE *fpFix = fopen ("orig/" DRIVER "/" GUID "-s1.bin", "rb");
  if (!fpFix) 
  {
    fprintf (stderr, "unable to open \"%s-s1.bin\" for read!\n", GUID);
    return;
  }
  FILE *fp = fopen (GUID "-s1.bin", "wb");
  if (!fp) 
  {
    fprintf (stderr, "unable to open \"%s-s1.bin\" for write!\n", GUID);
    return;
  }
    
  for (unsigned b=0; b<3; b++)
  {
    for (unsigned c=0; c<256; c++)
    {
      uint8_t data[32];
    
      fread (data, sizeof(uint8_t), 32, fpFix);
      fwrite (data, sizeof(uint8_t), 32, fp);
    }
  }

  for (c=0; c<256; c++)
  {
    const uint8_t *pfont;

    if (c < 16*4+4+4)
      pfont = border_font[c];
    else
      pfont = zeroes;
      
    // create font data
    for (unsigned col=0; col<4; col++)
    {
      uint8_t shift[] = { 2, 0, 6, 4 };
      
      for (unsigned l=0; l<8; l++)
      {
        uint8_t data = pfont[l];
        data = (data >> shift[col]) & 0x03;
        uint8_t byte = 0;
        
        // all fonts are colour 3 to match sprite palettes
        byte |= (data & (1<<0) ? 0x10 : 0);
        byte |= (data & (1<<1) ? 0x01 : 0);
            
        fwrite (&byte, sizeof(uint8_t), 1, fp);
      }
    }
  }
        
  for (c=0; c<512; c++)
  {
    const uint8_t *pfont;
    
    if (c < 256)
    {
#if 0      
      if (c < 4)
        pfont = day_font[c];
      else
      if ((i = from_ascii ((char)c)) != (uint8_t)-1)
      {      
        fprintf (stderr, "$%02X=\'%c\'\n", c, c);
        pfont = kl_font[i];
      }
#endif
      if (c <= 'Z')
        pfont = kl_font[c];
      else
        pfont = zeroes;
      // create font data
      for (unsigned col=0; col<4; col++)
      {
        uint8_t shift[] = { 2, 0, 6, 4 };
        
        for (unsigned l=0; l<8; l++)
        {
          uint8_t data = pfont[l];
          data = (data >> shift[col]) & 0x03;
          uint8_t byte = 0;
          
          // all fonts are colour 1
          byte |= (data & (1<<0) ? 0x10 : 0);
          byte |= (data & (1<<1) ? 0x01 : 0);
              
          fwrite (&byte, sizeof(uint8_t), 1, fp);
        }
      }
    }
    else
    {
      pfont = panel_font[(c-256)*8];

      // create font data
      for (unsigned col=0; col<4; col++)
      {
        uint8_t offset[] = { 4, 6, 0, 2 };
        uint8_t i = offset[col];
        for (unsigned l=0; l<8; l++)
        {
          //static uint8_t lu[] = { 0, 1, 2, 3 };
          // color 2 is the 'lives' graphic printed on CPC
          // - make it transparent and use the sprite
          static uint8_t lu[] = { 0, 1, 0, 3 };
          
          uint8_t byte = 0;
           
          uint8_t data = pfont[l*8+i];
          //if (data == 15) byte |= 0x03;
          //else if (data == 2) byte |= 0x01;
          byte = lu[(data & 3)];
          data = pfont[l*8+i+1];
          //if (data == 15) byte |= 0x30;
          //else if (data == 2) byte |= 0x10;
          byte |= lu[(data & 3)] << 4;
              
          fwrite (&byte, sizeof(uint8_t), 1, fp);
        }
      }
    }
  }

  // title (3 banks)
  for (c=0; c<768; c++)
  {  
    const uint8_t *pfont;

    if (c < 672)    
      pfont = title_font[c*8];
    else
      pfont = zeroes;

    // create font data
    for (unsigned col=0; col<4; col++)
    {
      uint8_t offset[] = { 4, 6, 0, 2 };
      uint8_t i = offset[col];
      for (unsigned l=0; l<8; l++)
      {
        uint8_t byte = 0;
         
        uint8_t data = pfont[l*8+i];
        byte |= (data & 0x0f);
        data = pfont[l*8+i+1];
        byte |= (data & 0x0f) << 4;
            
        fwrite (&byte, sizeof(uint8_t), 1, fp);
      }
    }
  }

  // and skip same bytes in original file
  fseek (fpFix, (256+512+768)*32, SEEK_CUR);
  
  // and copy remainder of file
  uint8_t data;
  fread (&data, sizeof(uint8_t), 1, fpFix);
  while (!feof (fpFix))
  {
    fwrite (&data, sizeof(uint8_t), 1, fp);
    fread (&data, sizeof(uint8_t), 1, fpFix);
  }
  
  fclose (fpFix);
  fclose (fp);
}

void do_sprites (void)
{  
  int s;

  uint8_t widest = 0;
  uint8_t highest = 0;
  
  for (s=0; s<N_ZX_SPR_ENTRIES; s++)
  {
    const uint8_t *psprite = zx_sprite_tbl[s];
    
    uint8_t width = *(psprite++) & 0x3f;
    uint8_t height = *psprite;
    
    if (width > widest) widest = width;
    if (height > highest) highest = height;
  }

  printf ("ZX:\n");
  // N_SPRITE_ENTRIES = 188  
  printf ("N_SPRITE_ENTIRES=%d\n", s);
  // widest = 5 (3 tiles), highest = 64 (4 tiles)
  printf ("widest=%d, highest=%d\n", widest, highest);
  
  for (s=0; s<N_CPC_SPR_ENTRIES; s++)
  {
    const uint8_t *psprite = cpc_sprite_tbl[s];
    
    uint8_t width = *(psprite++) & 0x3f;
    uint8_t height = *psprite;
    
    if (width > widest) widest = width;
    if (height > highest) highest = height;
  }

  printf ("CPC:\n");
  // N_SPRITE_ENTRIES = 194
  printf ("N_SPRITE_ENTIRES=%d\n", s);
  // widest = 10/2 = 5 (3 tiles), highest = 64 (4 tiles)
  printf ("widest=%d, highest=%d\n", widest, highest);

  // going to be quicker to define sprites for each entry
  // even if we are duplicating tiles of course
  // and also allocate 3x4=12 tiles for each sprite
  // actually 16 tiles will be quicker again  
  // so 188x16 = 3008 tiles (12 bits) (kiddy stuff for Neo Geo)

  FILE *c1 = fopen (GUID "-c1.bin", "wb");  
  FILE *c2 = fopen (GUID "-c2.bin", "wb");  

  unsigned total_ns = 0;
    
	// copy 1st 256 characters from original file
  // bank = $6F (2nd set of ROMS)
	FILE *fp1 = fopen ("orig/" DRIVER "/" GUID "-c3.bin", "rb");
	FILE *fp2 = fopen ("orig/" DRIVER "/" GUID "-c4.bin", "rb");
	if (!fp1 || !fp2)
  {
    fprintf (stderr, "unable to open source c1,c2\n");
    return;
  }

  // bank = $6F  
  fseek (fp1, (0x6F-0x40)*256*64, SEEK_SET);
  fseek (fp2, (0x6F-0x40)*256*64, SEEK_SET);
  
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

  total_ns += 256;
  
#if 0
  // now do the main font & days font
  // - needs to be a multiple of 16
  for (s=0; s<64; s++)
  {
    const uint8_t *pfont;
    
    if (s < 40)
      pfont = kl_font[s];
    else if (s < 40+4)
      pfont = day_font[s-40];
    
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
#endif
  
  #define F_VFLIP (1<<7)
  #define F_HFLIP (1<<6)
  
  for (s=0; s<N_ZX_SPR_ENTRIES; s++)
  {
    const uint8_t *psprite = zx_sprite_tbl[s];
    
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
              const uint8_t *p = psprite;
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
                // bitplane0 = colour
                // bitplane1 = mask
                // gives 4 colours but #1=#3 (mask)
  
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
                  fwrite (&d, sizeof(uint8_t), 1, c1);
                  fwrite (&m, sizeof(uint8_t), 1, c1);

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
          total_ns++;
        }
      }
    }
  }

  printf ("after zx total_ns = %d\n", total_ns);

  // pad out the rest of C1,C2
  while (total_ns < 16384)
  {
    //fwrite (zeroes, sizeof(uint8_t), 64, c1);
    //fwrite (zeroes, sizeof(uint8_t), 64, c2);
    total_ns++;
  }

  fclose (c1);
  fclose (c2);
  c1 = fopen (GUID "-c3.bin", "wb");
  c2 = fopen (GUID "-c4.bin", "wb");

  // fill in 256 tiles
  // - so CPC sprites have same offset as ZX
  //   from based of ROM file (ie. $0100 vs $4100)
  for (s=0; s<256; s++)
  {
    fwrite (zeroes, sizeof(uint8_t), 64, c1);
    fwrite (zeroes, sizeof(uint8_t), 64, c2);
    total_ns++;
  }

  for (s=0; s<N_CPC_SPR_ENTRIES; s++)
  {
    const uint8_t *psprite = cpc_sprite_tbl[s];
    
    uint8_t c = *psprite & 0xc0;
    uint8_t w = *(psprite++) & 0x3f;
    uint8_t h = *(psprite++);
    uint8_t f = *(psprite++);

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
          {
            fwrite (zeroes, 64, sizeof(uint8_t), c1);
            fwrite (zeroes, 64, sizeof(uint8_t), c2);
          }
          else
          {        
            // we have some sprite data
            for (unsigned q=0; q<4; q++)
            {
              // point to start of data
              const uint8_t *p = psprite;
              if ((c & F_VFLIP) ^ vflip)
                p += ((r*16 + (q&1)*8)) *w;
              else
                p += (h-1-(r*16 + (q&1)*8)) *w;
              if ((c & F_HFLIP) ^ hflip)
                p += (w-2)-(c*4 + 2-(q&2));
              else
                p += c*4 + 2-(q&2);
              for (unsigned l=0; l<8; l++)
              {
                // 2 bitplanes
  
                if (c*2+1-((q&2)/2) >= w/2 ||
                    r*16+(q&1)*8+l >= h)
                {
                  fwrite (zeroes, sizeof(uint8_t), 2, c1);
                  fwrite (zeroes, sizeof(uint8_t), 2, c2);
                }
                else
                {
                  uint8_t d1 = *(p+0);
                  uint8_t d2 = *(p+1);
                  uint8_t b0 ,b1;
                  
                  #define CPC2NGB0(d1,d2) \
                      ((d1&8)>>3)|((d1&4)>>1)|((d1&2)<<1)|((d1&1)<<3)| \
                      ((d2&8)<<1)|((d2&4)<<3)|((d2&2)<<5)|((d2&1)<<7)
                  #define CPC2NGB1(d1,d2) \
                      ((d1&128)>>7)|((d1&64)>>5)|((d1&32)>>3)|((d1&16)>>1)| \
                      ((d2&128)>>3)|((d2&64)>>1)|((d2&32)<<1)|((d2&16)<<3)
                  b0 = CPC2NGB0(d1,d2);
                  b1 = CPC2NGB1(d1,d2);
                  if (hflip)
                  {
                    b0 = REV(b0);
                    b1 = REV(b1);
                  }
                  
                  // we want to move colour 3 up to 15
                  uint8_t col3 = 0; b1 & b0;
                  
                  fwrite (&b0, sizeof(uint8_t), 1, c1);
                  fwrite (&b1, sizeof(uint8_t), 1, c1);
                  fwrite (&col3, sizeof(uint8_t), 1, c2);
                  fwrite (&col3, sizeof(uint8_t), 1, c2);

                  if (vflip)
                    p += w;
                  else                                
                    p -= w;              
                }
              }
            }
          }
        }
      }
    }
  }
  
  fclose (c1);
  fclose (c2);

  //FILE *spr = fopen ("PB_CHR.SPR", "wb");
  //fclose (spr);
}

void make_zx_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  *r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  *g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  *b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
}

void make_cpc_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  uint8_t lu[] = { 0, 128, 255 };
  
  *r = lu[(c/3) % 3];
  *g = lu[(c/9) % 3];
  *b = lu[c % 3];
}

int main (int argc, char *argv[])
{
  memset (zeroes, 0, 128);

  unsigned c;
  for (c=0; c<27; c++)
  {
    uint8_t r, g, b;
    make_cpc_colour (c, &r, &g, &b);
    printf ("%d, %d, %d\n", r, g, b);
  }

  // menu
  // 0, 24, 2, 26
  // room attributes  
  // 0, 15, 24, 26
  // 0, 18, 20, 8
  // 0, 2, 20, 24
  // 0, 6, 24, 26

  do_sprites ();
  do_fix ();

  #ifdef SHOW_TILES
  
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
  	uint8_t r, g, b;
  	
  	#if 0
	    pal[c].r = (c<4 ? r[c] : 0);
	    pal[c].g = (c<4 ? g[c] : 0);
	    pal[c].b = (c<4 ? b[c] : 0);
    #else
    	make_zx_colour (c, &r, &b, &g);
    	pal[c].r = r;
    	pal[c].g = g;
    	pal[c].b = b;
    #endif
  }
	set_palette_range (pal, 0, 15, 1);

  show_ng_tiles ();
  
  allegro_exit ();
  
  #endif
}

END_OF_MAIN();
