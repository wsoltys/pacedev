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

// neogeo:  d:\mingw_something\setenv.bat
//          g++ gfx.cpp -o xgf -lalleg

#define DO_C_DATA

//#define DO_ASCII
//#define DO_PARSE_MAP
//#define DO_GA
//#define DO_FONT
//#define DO_SPRITE_DATA
//#define DO_SPRITE_TABLE
//#define DO_BLOCK_DATA
//#define DO_BG_DATA

const char *to_ascii = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
uint8_t ram[64*1024];
uint8_t ascii[64*1024];
unsigned widest = 0;
unsigned highest = 0;
FILE *fpdbg;

static void plot_character (unsigned ch, unsigned cx, unsigned cy, unsigned c)
{
  for (unsigned y=0; y<8; y++)
  {
    unsigned char d = ram[0x6108+ch*8+y];
    
    for (unsigned b=0; b<8; b++)
    {
      if (d & (1<<7))
        putpixel (screen, cx+b, cy+y, c);
      d <<= 1;
    }
  }
}

static void plot_ascii_character (unsigned ch, unsigned cx, unsigned cy, unsigned c)
{
  unsigned i;
  
  for (i=0; to_ascii[i]; i++)
    if (to_ascii[i] == ch)
      break;
      
  if (i == 40)
    return;
    
  plot_character (i, cx, cy, c);    
}

static unsigned plot_sprite_data (unsigned s, unsigned f, unsigned p, unsigned px, unsigned py, unsigned c, unsigned &w, unsigned &h)
{          
  w = ram[p++] & 0x3f;
  h = ram[p++];

  if (w > widest)
    widest = w;
  if (h > highest)
    highest = h;

  fprintf (fpdbg, "SPR=%03d A=$%04X (X=%02d,Y=%02d)\n", 
            s, p-2, w, h);
        
  for (unsigned y=0; y<h; y++)
    for (unsigned x=0; x<w; x++)
    {
      // skip mask
      p++;
      unsigned char d = ram[p++];
      for (unsigned b=0; b<8; b++)
      {
        if (d & (1<<7))
          if (f & (1<<6))
            if (f & (1<<7))
              putpixel (screen, px+(w*8-(x*8+b)), py+y, 3);
            else
              putpixel (screen, px+(w*8-(x*8+b)), py+(h-y), 2);
          else
            if (f & (1<<7))
              putpixel (screen, px+x*8+b, py+y, 1);
            else
              putpixel (screen, px+x*8+b, py+(h-y), 7);
                
        d <<= 1;
      }
    }

  w *= 8;    
  return (p);
}

void plot_sprite (unsigned s, unsigned f, unsigned x, unsigned y, unsigned c, unsigned &w, unsigned &h)
{
  // get sprite data address from table
  unsigned p = ram[0x7112+s*2+1];
  p = (p<<8) | ram[0x7112+s*2];
  
  plot_sprite_data (s, f, p, x, y, 3, w, h);
}

void main (int argc, char *argv[])
{
	FILE *fp, *fp2;
	struct stat	fs;
	int					fd;
	
	char				buf[1024];

  unsigned t;
  unsigned w, h;

  fpdbg = fopen ("debug.txt", "wt");
  	
	fp = fopen ("knightlore.sna", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[16384-27], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

	fp = fopen ("knightlore.bin", "wb");
	// write the relevant areas
	fwrite (&ram[0x6108], 0xd8f3-0x6108, 1, fp);
	fclose (fp);

#ifdef DO_C_DATA
  fp2 = fopen ("data.c", "wt");
  
  // font
  unsigned p = 0x6108;
  char *font = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
  fprintf (fp2, "uint8_t kl_font[][8] = \n{\n" );
  for (int c=0; c<40; c++)
  {
    fprintf (fp2, "  { ");
    for (int b=0; b<8; b++)
    {
      fprintf (fp2, "0x%02X, ", ram[p]);
      p++;
    }
    fprintf (fp2, "},  // '%c'\n", font[c]);
  }
  fprintf (fp2, "};\n");  
  fclose (fp2);
#endif

#ifdef DO_ASCII
  fp2 = fopen ("knightlore.asc", "wb");
  for (unsigned p=0x6108; p<0xd8f3; p++)
  {
    unsigned char c = ram[p] & 0x7f;
    if (c < 40)
      ascii[p] = to_ascii[c];
    else
      ascii[p] = ' ';
  }
	// write the relevant areas
	fwrite (&ascii[0x6108], 0xd8f3-0x6108, 1, fp);
  fclose (fp2);
#endif

#ifdef DO_PARSE_MAP
  // parse the map

  unsigned p = 0x6248;
  fprintf (stdout, "X,Y,Z=%03d,%03d,%03d\n",
            ram[p+0], ram[p+1], ram[p+2]);

  p = 0x6251;
  int n = 0;
  while (1)
  {
    fprintf (stdout, "id=%03d\n", ram[p+0]);
    fprintf (stdout, " byte count =%03d\n", ram[p+1]);
    fprintf (stdout, " size=%02d\n", ram[p+2]>>3);
    fprintf (stdout, " attributes =%02d\n", ram[p+2]&0x07);

    unsigned b;
    for (b=0; ram[p+3+b] != 0xff; b++)
    {
      fprintf (stdout, " BG=%03d\n", ram[p+3+b]);
      if (4+b == 1+ram[p+1])
      break;
    }
    if (4+b != 1+ram[p+1])
    {
      unsigned f;
      for (f=0; ; f++)
      {
        fprintf (stdout, " block=%02d\n", ram[p+4+b+f]>>3);
        unsigned count = (ram[p+4+b+f]&0x07)+1;
        fprintf (stdout, " count=%02d\n", count);
        unsigned c;
        for (c=0; c<count; c++, f++)
        {
          unsigned xyz = ram[p+5+b+f];
          fprintf (stdout, "  x,y,z=%02d,%02d,%02d\n",
                    xyz&0x07, (xyz>>3)&0x07, (xyz>>6)&0x03);
        }
        if (5+b+f == 1+ram[p+1])
          break;
      }
    }
    p += 1 + ram[p+1];

    if (++n == 128)
      break;
  }
#endif

#ifdef DO_GA
	// sort the list of sprite graphics addresses
	unsigned short ga[256];
	unsigned short iga = 0;
	unsigned nga = (0x728A - 0x7112) / 2;
	fprintf (stdout, "nga=%d\n", nga);
	for (unsigned i=0; i<nga; i++)
	{
		unsigned short a = ram[0x7112+i*2+1];
		a = (a<<8) | ram[0x7112+i*2];
		
		// now put it in place
		unsigned j;
		for (j=0; j<iga; j++)
			if (a <= ga[j])
				break;
		if (i > 0 && a == ga[j]) continue;
		
		// move up
		for (unsigned k=iga+1; k>j; k--)
			ga[k] = ga[k-1];
		ga[j] = a;
		iga++;
	}
	
	for (unsigned i=0; i<iga; i++)
		fprintf (stderr, "$%04X\n", ga[i]);
#endif

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 320, 192, 0, 0);

  PALETTE pal;
  for (int c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 7, 1);


#ifdef DO_FONT
	clear_bitmap (screen);
  for (unsigned c=0; c<40; c++)
  {
      plot_character (c, (c%16)*16, (c/16)*16, 7);
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

	clear_bitmap (screen);
	const char *msg[] = 
	{
	  "THIS IS THE FONT FROM A MYSTERY GAME",
	  "FROM A Z80 PLATFORM",
	  "THAT I AM CURRENTLY EVALUATING FOR",
	  "A POSSIBLE PORT TO",
	  "THE COLOR COMPUTER 3",
	  ""
	};

  for (unsigned m=0; *msg[m]; m++)
  {
    for (unsigned c=0; msg[m][c]; c++)
      plot_ascii_character (msg[m][c], (320-strlen(msg[m])*8)/2 + c*8, 16+m*16, m+2);
  }	
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

#endif


#ifdef DO_SPRITE_DATA
	unsigned p = 0x728C;
  unsigned s = 0;
  for (s=0; p<0xAE98; s++)
  {
    if (s%16 == 0)
	    clear_bitmap (screen);

    // there's a gap in the sprite data
    if (p == 0x7D98)
      p += 12;

    p = plot_sprite_data (s, 0, p, (s%8)*40, ((s%16)/8)*64, 3, w, h);

    if (s%16 == 15)
    {
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
#endif

#ifdef DO_SPRITE_TABLE
  t = 0x7112;
  unsigned s = 0;
  for (s=0; t<0x728A; s++, t+=2)
  {
    if (s%16 == 0)
	    clear_bitmap (screen);

    plot_sprite (s, 0, (s%8)*40, ((s%16)/8)*64, 3, w, h);

    if (s%16 == 15)
    {
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
#endif

#ifdef DO_BLOCK_DATA
  t = 0x6C0B;
  unsigned e = 0;
  for (e=0; t<0x6CE2; e++)
  {
    unsigned n = 0;
    unsigned sw, sh, iw=0, ih=0;
        
    if (e%8 == 0)
      clear_bitmap (screen);
    while (ram[t] != 0)    
    {
      unsigned s = ram[t++];
      unsigned w = ram[t++];
      unsigned h = ram[t++];
      unsigned z = ram[t++];
      unsigned f = ram[t++];
      unsigned o = ram[t++];
      
      plot_sprite (s, f, (e%8)*40, ih, 3, sw, sh);
      ih += sh;
    }
    t++;

    if (e%8 == 7)
    {    
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
#endif

#ifdef DO_BG_DATA
  t = 0x6D12;
  unsigned e = 0;
  for (e=0; t<0x6FF2; e++)
  {
    unsigned n = 0;
    unsigned sw, sh, iw=0, ih=0;
    
    //if (e%8 == 0)
      clear_bitmap (screen);
    while (ram[t] != 0)    
    {
      unsigned s = ram[t++];
      unsigned x = ram[t++];
      unsigned y = ram[t++];
      unsigned z = ram[t++];
      unsigned w = ram[t++];
      unsigned d = ram[t++];
      unsigned h = ram[t++];
      unsigned f = ram[t++];
      
      plot_sprite (s, f, (e%8)*40+iw, 0, 3, sw, sh);
      iw += sw; ih += sh;
    }
    t++;

    //if (e%8 == 7)
    {    
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
#endif

  fclose (fpdbg);
  
  allegro_exit ();

  //fprintf (stdout, "w=%d\n", widest);
  //fprintf (stdout, "h=%d\n", highest);
}

END_OF_MAIN();
