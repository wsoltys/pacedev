#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

//#define ALLEGRO_STATICLINK
#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#define SHOW_PALETTE
#define SHOW_ARCADE_TILES
//#define SHOW_NEOGEO_SCREEN
#define SHOW_ARCADE_SPRITES
#define SHOW_NEOGEO_SPRITES

#define SUBDIR    "dkong"

char *tile_rom[] = { "v_5h_b.bin", "v_3pt.bin" };
char *sprite_rom[] = { "l_4m_b.bin", "l_4n_b.bin", "l_4r_b.bin", "l_4s_b.bin" };
char *colour_prom[] = { "c-2k.bpr", "c-2j.bpr", "v-5e.bpr" };

#define N_TILE_ROMS (sizeof(tile_rom)/sizeof(char *))
#define N_SPRITE_ROMS (sizeof(sprite_rom)/sizeof(char *))
#define N_COLOUR_PROMS (sizeof(colour_prom)/sizeof(char *))

uint8_t vram[2][0x400];
uint8_t tile[N_TILE_ROMS][0x0800];
uint8_t sprite[N_SPRITE_ROMS][0x0800];
uint8_t prom[N_COLOUR_PROMS][0x0100];

// original
uint8_t c1_org[1024*1024], c2_org[1024*1024];

// neo geo sprites (only 2 planes)
// - each 16x16x2=512bits = 512/8=64bytes
// - 256 tiles + 128 sprites, 2 rotations
uint8_t c13[2][(256+128)*64];

void main (int argc, char *argv[])
{
  FILE  *fp;
  int   i;
  
  // tiles
  for (i=0; i<N_TILE_ROMS; i++)
  {  
    char buf[64];
    
    sprintf (buf, "%s/%s", SUBDIR, tile_rom[i]);
    if (!(fp = fopen (buf, "rb")))
    {
      fprintf (stderr, "fopen (\"%s\") (tile) failed!\n", buf);
      exit (0);
    }
    fread (tile[i], 1, 0x0800, fp);
    fclose (fp);
  }
  
  // sprites
  for (i=0; i<N_SPRITE_ROMS; i++)
  {  
    char buf[64];
    
    sprintf (buf, "%s/%s", SUBDIR, sprite_rom[i]);
    if (!(fp = fopen (buf, "rb")))
    {
      fprintf (stderr, "fopen (\"%s\") (sprite) failed!\n", buf);
      exit (0);
    }
    fread (sprite[i], 1, 0x0800, fp);
    fclose (fp);
  }

  // colour proms
  for (i=0; i<N_COLOUR_PROMS; i++)
  {  
    char buf[64];
    
    sprintf (buf, "%s/%s", SUBDIR, colour_prom[i]);
    if (!(fp = fopen (buf, "rb")))
    {
      fprintf (stderr, "fopen (\"%s\") (prom) failed!\n", buf);
      exit (0);
    }
    fread (prom[i], 1, 0x0100, fp);
    fclose (fp);
  }

  // rotate, save vram
  fp = fopen ("dkvram.bin", "rb");
  if (fp)
  {
    fread (vram[0], 1, 0x400, fp);
    fclose (fp);
    
    // insert marker
    vram[0][0x340] = 0xFB;
    vram[0][0x0E0] = 0xFB;
    
    // rotate vram
    for (unsigned y=0; y<32; y++)
      for (unsigned x=0; x<32; x++)
        vram[1][y*32+x] = vram[0][(31-x)*32+y];
    fp = fopen ("vram.cpp", "wt");
    for (unsigned i=0; i<0x400; i++)
    {
      fprintf (fp, "0x%02X, ", vram[0][i]);
      if (i%16 == 15) fprintf (fp, "\n");
    }
    fclose (fp);
  }

  // save colour lookup prom
  fp = fopen ("cpr.cpp", "wt");
  for (unsigned c=0; c<256; c++)
  {
    fprintf (fp, "0x%02X, ", prom[2][c]);
    if (c%16 == 15) fprintf (fp, "\n");
  }
  fclose (fp);
  
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 32*16, 32*16, 0, 0);

	fp = fopen ("pal.cpp", "wt" );

  // set palette
	PALETTE pal;
	for (int c=0; c<256; c++)
  {
    uint8_t   bit0, bit1, bit2;
    uint8_t   r, g, b;
    
		/* red component */
		bit0 = (prom[1][c] >> 1) & 1;
		bit1 = (prom[1][c] >> 2) & 1;
		bit2 = (prom[1][c] >> 3) & 1;
		r = 255 - (0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2);
		/* green component */
		bit0 = (prom[0][c] >> 2) & 1;
		bit1 = (prom[0][c] >> 3) & 1;
		bit2 = (prom[1][c] >> 0) & 1;
		g = 255 - (0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2);
		/* blue component */
		bit0 = (prom[0][c] >> 0) & 1;
		bit1 = (prom[0][c] >> 1) & 1;
		b = 255 - (0x55 * bit0 + 0xaa * bit1);

		pal[c].r = r>>2; pal[c].g = g>>2; pal[c].b = b>>2;
		
		// neogeo palette entry
		// D R0 G0 B0 R4 R3 R2 R1 G4 G3 G2 G1 B4 B3 B2 B1
		uint16_t pe = 0;
		// 5 bits of colour only
		r >>= 3; b >>=3; g >>= 3;
		pe |= (r&(1<<0)) << 14;
		pe |= (g&(1<<0)) << 13;
		pe |= (b&(1<<0)) << 12;
		pe |= (r&0x1E) << 7;
		pe |= (g&0x1E) << 3;
		pe |= (b&0x1E) >> 1;

		if ((c%4) == 0) fprintf (fp, "{{ ");
		fprintf (fp, "0x%04X, ", pe);
		if ((c%4) == 3) fprintf (fp, "0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }},\n");
  }
  fclose (fp);
	set_palette_range (pal, 0, 255, 1);

  #ifdef SHOW_PALETTE
  #endif // SHOW_PALETTE
  
  #ifdef SHOW_ARCADE_TILES

  	clear_bitmap (screen);

		memset (c13, '\0', sizeof(c13));
		
		for (int rot=0; rot<2; rot++)
		{			      
	    for (int t=0; t<256; t++)
	    {
	      //  static const gfx_layout charlayout =
	      //  {
	      //  8,8,	/* 8*8 characters */
	      //  RGN_FRAC(1,2),
	      //  2,	/* 2 bits per pixel */
	      //  { RGN_FRAC(1,2), RGN_FRAC(0,2) },	/* the two bitplanes are separated */
	      //  { 0, 1, 2, 3, 4, 5, 6, 7 },	/* pretty straightforward layout */
	      //  { 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 },
	      //  8*8	/* every char takes 8 consecutive bytes */
	      //  };
	
	      int ty, tx;
	
				uint8_t	raw[2];
	
	      for (ty=0; ty<8; ty++)
	        for (tx=0; tx<8; tx++)
	        {
	        	int bit;
	        	
	        	if (rot == 0)
		          bit = t*8*8 + (7-tx)*8 + ty;
		        else
		          bit = t*8*8 + ty*8 + tx;
	          int pel = 0;
	          for (int plane=1; plane>=0; plane--)
	          {
	            uint8_t data = tile[plane][bit>>3];
	            if (rot == 0)
		            data = (data >> (7-ty)) & 0x01;
	            else
		            data = (data >> (7-tx)) & 0x01;
	            raw[plane] = data;
	            pel = (pel << 1) | data;
	          }
	          putpixel (screen, (t%16)*8+tx, ((rot*256+t)/16)*8+ty, pel);
	          
	          // create neo geo tile
	          // pixel-double horizontal and vertical
	          // each tile is 2*2*16=64 bytes
	          // 8x8 tile order 3 1
	          //                4 2
	          
	          unsigned o = t*64;
	          if (tx < 4) o += 32;											// 2nd half
	          o += ty*2*2;															// each line 4 bytes
	          c13[rot][o] |= raw[0] << (tx%4)*2;
	          c13[rot][o] |= raw[0] << (tx%4)*2+1;
	          o++;
	          c13[rot][o] |= raw[1] << (tx%4)*2;
	          c13[rot][o] |= raw[1] << (tx%4)*2+1;
	          o++;
	          c13[rot][o] |= raw[0] << (tx%4)*2;
	          c13[rot][o] |= raw[0] << (tx%4)*2+1;
	          o++;
	          c13[rot][o] |= raw[1] << (tx%4)*2;
	          c13[rot][o] |= raw[1] << (tx%4)*2+1;
	        }
      }
    }

    SS_TEXTOUT_CENTRE(screen, font, "ARCADE TILES", SCREEN_W/2, SCREEN_H-8, 15);
    while (!key[KEY_ESC]);	  
    while (key[KEY_ESC]);	  

  	clear_bitmap (screen);

		for (int t=0; t<256; t++)
		{
			for (int ty=0; ty<16; ty++)
				for (int tx=0; tx<16; tx++)
				{
					int bit = t*64*8 + ty*2*8;
					if (tx < 8) bit += 32*8;
					uint8_t pel = (c13[0][(bit>>3)+1] >> (tx%8)) & 0x01;
					pel = (pel << 1) | ((c13[0][(bit>>3)] >> (tx%8)) & 0x01);
          putpixel (screen, (t%16)*16+tx, (t/16)*16+ty, pel);
				}
		}

    SS_TEXTOUT_CENTRE(screen, font, "NEO GEO TILES", SCREEN_W/2, SCREEN_H-8, 15);
    while (!key[KEY_ESC]);	  
    while (key[KEY_ESC]);	  

  #endif // SHOW_ARCADE_TILES

  #ifdef SHOW_NEOGEO_SCREEN

		for (int rot=0; rot<2; rot++)
		{
			char buf[128];
			
	  	clear_bitmap (screen);
	
	    for (unsigned y=0; y<32; y++)
	      for (unsigned x=0; x<32; x++)
	      {
	        uint8_t t = vram[1-rot][y*32+x];
	        //uint8_t t = y*32+x;
	        
	  			for (int ty=0; ty<16; ty++)
	  				for (int tx=0; tx<16; tx++)
	  				{
	  					int bit = t*64*8 + ty*2*8;
	  					if (tx < 8) bit += 32*8;
	  					uint8_t pel = (c13[rot][(bit>>3)+1] >> (tx%8)) & 0x01;
	  					pel = (pel << 1) | ((c13[rot][(bit>>3)+0] >> (tx%8)) & 0x01);
	
		          // int color = (color_codes[tile_index % 32 + 32 * (tile_index / 32 / 4)] & 0x0f) + 0x10 * palette_bank;

							int c;
							if (rot == 0)
	            	c = (prom[2][(y%32) + 32*(y/32/4)] & 0x0f) + 0x10 * 2;
            	else
	            	c = (prom[2][(x%32) + 32*(x/32/4)] & 0x0f) + 0x10 * 2;
	            putpixel (screen, x*16+tx, y*16+ty, c*4+pel);
	  				}
	      }
	
			sprintf (buf, "NEO GEO SCREEN (rot=%d)", rot);
	    SS_TEXTOUT_CENTRE(screen, font, buf, SCREEN_W/2, SCREEN_H-8, 15);
	    while (!key[KEY_ESC]);	  
	    while (key[KEY_ESC]);	  
		}
		  
  #endif // SHOW_NEOGEO_SCREEN
  
  #ifdef SHOW_ARCADE_SPRITES

  	clear_bitmap (screen);

		for (int rot=0; rot<2; rot++)
		{
	    for (int s=0; s<128; s++)
	    {
	      //  static const gfx_layout spritelayout =
	      //  {
	      //  	16,16,	/* 16*16 sprites */
	      //  	RGN_FRAC(1,4),	/* 128 sprites */
	      //  	2,	/* 2 bits per pixel */
	      //  	{ RGN_FRAC(1,2), RGN_FRAC(0,2) },	/* the two bitplanes are separated */
	      //  	{ 0, 1, 2, 3, 4, 5, 6, 7,	/* the two halves of the sprite are separated */
	      //  			RGN_FRAC(1,4)+0, RGN_FRAC(1,4)+1, RGN_FRAC(1,4)+2, RGN_FRAC(1,4)+3, RGN_FRAC(1,4)+4, RGN_FRAC(1,4)+5, RGN_FRAC(1,4)+6, RGN_FRAC(1,4)+7 },
	      //  	{ 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
	      //  			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 },
	      //  	16*8	/* every sprite takes 16 consecutive bytes */
	      //  };
	
	      int sy, sx;
				uint8_t	raw[2];
	      
	      for (sy=0; sy<16; sy++)
	        for (sx=0; sx<16; sx++)
	        {
	        	int bit;
						int rom;
						
						if (rot == 0)
							rom = (sy & (1<<3)) >> 3;
						else
							rom = (sx & (1<<3)) >> 3;
	          if (rot == 0)
	          	bit = s*16*8 + (15-sx)*8 + (sy%8);
          	else
	          	bit = s*16*8 + sy*8 + ((15-sx)%8);
	          int pel = 0;
	          for (int plane=0; plane<2; plane++)
	          {
	            uint8_t data = sprite[(plane)*2+rom][bit>>3];
	            if (rot == 0)
	            	data = (data >> (7-(sy%8))) & 0x01;
            	else
	            	data = (data >> (7-(sx%8))) & 0x01;
	            raw[plane] = data;
	            pel = (pel << 1) | data;
	          }
	          putpixel (screen, (s%16)*16+sx, ((rot*128+s)/16)*16+sy, pel);
	          
	          // create neo geo tile
	          // each tile is 2*2*16=64 bytes
	          // 8x8 tile order 3 1
	          //                4 2
	          unsigned o = (256*64)+s*64;
	          if (sx < 8) o += 32;										// 2nd half
	          o += sy*2;															// each line 4 bytes
	          c13[rot][o] |= raw[0] << (sx%8);
	          o++;
	          c13[rot][o] |= raw[1] << (sx%8);
	        }      
	    }
		}
		
    SS_TEXTOUT_CENTRE(screen, font, "ARCADE SPRITES", SCREEN_W/2, SCREEN_H-8, 15);
    while (!key[KEY_ESC]);	  
    while (key[KEY_ESC]);	  

  #endif // SHOW_ARCADE_SPRITES
  
  #ifdef SHOW_NEOGEO_SPRITES
  
		for (int rot=0; rot<2; rot++)
		{
			char buf[128];

	  	clear_bitmap (screen);

			for (int s=0; s<128; s++)
			{
				int x = (s%16);
				int y = (s/16);
				
  			for (int ty=0; ty<16; ty++)
  				for (int tx=0; tx<16; tx++)
  				{
  					int bit = (256*64*8)+s*64*8 + ty*2*8;
  					if (tx < 8) bit += 32*8;
  					uint8_t pel = (c13[rot][(bit>>3)+1] >> (tx%8)) & 0x01;
  					pel = (pel << 1) | ((c13[rot][(bit>>3)+0] >> (tx%8)) & 0x01);

            putpixel (screen, x*16+tx, y*16+ty, pel);
  				}
			}
	
			sprintf (buf, "NEO GEO SPRITES (rot=%d)", rot);
	    SS_TEXTOUT_CENTRE(screen, font, buf, SCREEN_W/2, SCREEN_H-8, 15);
	    while (!key[KEY_ESC]);	  
	    while (key[KEY_ESC]);	
  }  
  #endif // SHOW_NEOGEO_SPRITES

  // read original roms to rip eye-catch tiles
  fp = fopen ("002-c1.c1", "rb");
  if (fp)
  {
    fread (c1_org, 1, sizeof(c1_org), fp);
    fclose (fp);
  }
  fp = fopen ("002-c2.c2", "rb");
  if (fp)
  {
    fread (c2_org, 1, sizeof(c2_org), fp);
    fclose (fp);
  }
  
  // save NEOGEO ROM (and patch with eye-catcher)
  uint8_t zero = 0x00;
  unsigned a;
  fp = fopen ("202-c1.bin", "wb");
  a = 0;
  // 256 eye-catcher tiles
  for (unsigned i=0; i<256*64; i++)
    fwrite (&c1_org[0x4C000+i], 1, 1, fp);
  // 128 sprites
  for (unsigned i=0; i<128*64; i++)
    fwrite (&c13[0][(256*64)+i], 1, 1, fp);
  // 128 sprites (rotated)
  for (unsigned i=0; i<128*64; i++)
    fwrite (&c13[1][(256*64)+i], 1, 1, fp);
  // 256 tiles
  for (unsigned i=0; i<256*64; i++)
    fwrite (&c13[0][i], 1, 1, fp);
  // 256 tiles (rotated)
  for (unsigned i=0; i<256*64; i++)
    fwrite (&c13[1][i], 1, 1, fp);
  fclose (fp);

  fp = fopen ("202-c2.bin", "wb");
  // 256 eye-catcher tiles
  for (unsigned i=0; i<256*64; i++)
    fwrite (&c2_org[0x4C000+i], 1, 1, fp);
  // 128+128+256+256 blank bitplanes
  for (unsigned i=0; i<(2*128+2*256)*64; i++)
    fwrite (&zero, 1, 1, fp);
  fclose (fp);

  // merge to SPR for CD
  FILE *fp1 = fopen ("202-c1.bin", "rb");
  FILE *fp2 = fopen ("202-c2.bin", "rb");
  FILE *fp3 = fopen ("202.spr", "wb");
  uint16_t w1, w2;
  fread (&w1, 1, 2, fp1);
  fread (&w2, 1, 2, fp2);
  while (!feof (fp1))
  {
    fwrite (&w1, 1, 2, fp3);
    fwrite (&w2, 1, 2, fp3);
    
    fread (&w1, 1, 2, fp1);
    fread (&w2, 1, 2, fp2);
  }
  fclose (fp3);
  fclose (fp2);
  fclose (fp1);

}

END_OF_MAIN();

